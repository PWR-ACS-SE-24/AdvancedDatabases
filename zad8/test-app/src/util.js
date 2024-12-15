import fs from "fs/promises";
import oracledb from "oracledb";

/**
 * @param {oracledb.Connection} con
 * @param {string} name
 * @param {{ sql: string; params: Record<string, any> }} workload
 */
export async function explainPlan(con, name, workload) {
  const { sql, params } = workload;
  await con.execute(`explain plan for ${sql}`, params);
  const result = await con.execute(
    "select plan_table_output from table(dbms_xplan.display())"
  );
  const plan = result.rows.join("\n") + "\n";
  await fs.mkdir("plans", { recursive: true });
  await fs.writeFile(`plans/${name}.txt`, plan);
}

/**
 * @param {oracledb.Connection} con
 * @param {string} name
 * @param {{ sql: string; params: Record<string, any> }} workload
 */
export async function calculateCost(con, workload) {
  const { sql, params } = workload;
  await con.execute(`explain plan for ${sql}`, params);
  const result = await con.execute(
    "select plan_table_output from table(dbms_xplan.display(format => 'basic cost'))"
  );
  return Math.max(
    ...result.rows
      .slice(5)
      .map(([row]) => row.split("|")[4]?.trim())
      .filter((row) => row?.length > 0)
      .map((row) => parseInt(row, 10))
  );
}

/**
 * @param {oracledb.Connection} con
 * @param {{ sql: string; params: Record<string, any> }} workload
 * @returns {Promise<number>} in milliseconds
 */
export async function measureTime(con, workload) {
  const { sql, params } = workload;
  const t0 = performance.now();

  await con.execute(sql, params);

  const t1 = performance.now();
  await con.rollback();
  return t1 - t0;
}

/**
 * @param {oracledb.Connection} con
 * @returns {Promise<void>}
 */
export async function flushMemory(con) {
  await con.execute("alter system flush shared_pool");
  await con.execute("alter system flush buffer_cache");
}

/**
 * @param {number[]} times
 * @returns {{ count: number; min: number; max: number; avg: number; std: number }}
 */
export function calculateStats(times) {
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
 * @returns {Promise<number[]>}
 */
export function getCounts(con) {
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

  return Promise.all(
    tables.map((table) =>
      con.execute(`select count(*) from ${table}`).then((res) => res.rows[0][0])
    )
  );
}
