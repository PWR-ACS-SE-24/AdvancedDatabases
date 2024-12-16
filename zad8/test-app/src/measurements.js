import { N, workload } from "./workload.js";

/** @typedef {import('./types.js').Query} Query */
/** @typedef {import('./types.js').Stats} Stats */
/** @typedef {import('./types.js').EditQuery} EditQuery */

/** @param {oracledb.Connection} con */
async function flushMemory(con) {
  await con.execute("alter system flush shared_pool");
  await con.execute("alter system flush buffer_cache");
}

/**
 * @param {oracledb.Connection} con
 * @param {Query} query
 * @returns {Promise<number>} in milliseconds
 */
async function measureTime(con, query) {
  const { sql, params } = query;
  const t0 = performance.now();

  await con.execute(sql, params);

  const t1 = performance.now();
  await con.rollback();
  return t1 - t0;
}

/** @param {number[]} times */
function calculateStats(times) {
  const count = times.length;
  const min = Math.min(...times);
  const max = Math.max(...times);
  const sum = times.reduce((acc, x) => acc + x, 0);
  const avg = sum / count;
  const std = Math.sqrt(
    times.reduce((acc, x) => acc + (x - avg) ** 2, 0) / count
  );
  return { count, min, max, avg, std };
}

/**
 * @param {oracledb.Connection} con
 */
async function getCounts(con) {
  const tables = [
    "prison_block",
    "patrol",
    "guard",
    "cell",
    "patrol_slot",
    "reprimand",
    "accommodation",
    "prisoner",
    "sentence",
  ];

  /** @type {number[]} */
  const counts = await Promise.all(
    tables.map((table) =>
      con.execute(`select count(*) from ${table}`).then((res) => res.rows[0][0])
    )
  );

  return counts.join(",");
}

/**
 * @param {oracledb.Connection} con
 * @param {EditQuery} editQuery
 */
export async function gatherMeasurements(con, editQuery = {}) {
  console.log("Gathering times...");

  const wl = { ...workload, ...editQuery };

  const results = Object.fromEntries(
    Object.keys(wl).map((name) => [name, /** @type {number[]} */ ([])])
  );

  const oldCounts = await getCounts(con);

  for (let i = 0; i < N; i++) {
    console.log(`\tIteration #${i + 1}/${N}...`);
    await flushMemory(con);
    for (const name in wl) {
      const time = await measureTime(con, wl[name]);
      results[name].push(time);
    }
    const newCounts = await getCounts(con);
    if (newCounts !== oldCounts) {
      throw new Error(
        `Counts changed during iteration #${
          i + 1
        }/${N}: ${oldCounts} -> ${newCounts}`
      );
    }
  }

  /** @type {Record<string, Stats>} */
  const measurements = Object.fromEntries(
    Object.entries(results).map(([name, times]) => {
      return [name, calculateStats(times)];
    })
  );

  console.log("Gathered times.");

  return measurements;
}
