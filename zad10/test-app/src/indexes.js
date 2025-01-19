import fs from "fs/promises";
import oracledb from "oracledb";

/** @typedef {import('./types.js').IndexEntry} IndexEntry */
/** @typedef {import('./types.js').IndexSet} IndexSet */
/** @typedef {import('./types.js').EditQuery} EditQuery */

/**
 * @param {string} name
 * @param {EditQuery} editQuery
 */
const readIndex = async (name, editQuery = {}) => {
  const create = await fs
    .readFile(`indexes/${name}-create.sql`, "utf-8")
    .then((t) => t.split(";").slice(0, -1));

  const drop = await fs
    .readFile(`indexes/${name}-drop.sql`, "utf-8")
    .then((t) => t.split(";").slice(0, -1));

  return { create, drop, editQuery };
};

/** @type {Record<string, IndexEntry>} */
const indexes = {
  p1: await readIndex("p1"),
  p2: await readIndex("p2"),
  p2group: await readIndex("p2group"),
  p3rep: await readIndex("p3rep"),
  p3sen: await readIndex("p3sen"),
};

/** @type {Record<string, IndexSet>} */
export const indexSets = {
  onlyp1: [indexes.p1],
  onlyp2: [indexes.p2],
  onlyp2group: [indexes.p2group],
  onlyp3rep: [indexes.p3rep],
  onlyp3sen: [indexes.p3sen],
};

/** @param {oracledb.Connection} con */
export async function dropAllIndexes(con) {
  console.log("Dropping all indexes...");
  for (const index in indexes) {
    for (const query of indexes[index].drop) {
      try {
        await con.execute(query);
      } catch {}
    }
  }
  console.log("Dropped all indexes.");
}

/**
 * @param {oracledb.Connection} con
 * @param {IndexSet} set
 */
export async function createIndexes(con, set) {
  for (const index of set) {
    for (const query of index.create) {
      try {
        await con.execute(query);
      } catch (err) {
        console.log(err);
      }
    }
  }
}

/**
 * @param {oracledb.Connection} con
 * @param {IndexSet} set
 */
export async function dropIndexes(con, set) {
  for (const index of set) {
    for (const query of index.drop) {
      try {
        await con.execute(query);
      } catch {}
    }
  }
}
