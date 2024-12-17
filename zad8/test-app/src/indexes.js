import fs from "fs/promises";
import oracledb from "oracledb";
import { query3partition } from "./workload.js";

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
  i1: await readIndex("i1"),
  i2: await readIndex("i2"),
  i3: await readIndex("i3"),
  i4: await readIndex("i4"),
  i5: await readIndex("i5"),
  e11: await readIndex("e11"),
  e12: await readIndex("e12"),
  e13: await readIndex("e13"),
  e31: await readIndex("e31", { query3: query3partition }),
  e32: await readIndex("e32", { query3: query3partition }),
};

/** @type {Record<string, IndexSet>} */
export const indexSets = {
  only1: [indexes.i1],
  only2: [indexes.i2],
  only3: [indexes.i3],
  only4: [indexes.i4],
  only5: [indexes.i5],
  all: [indexes.i1, indexes.i2, indexes.i3, indexes.i4, indexes.i5],
  e11: [indexes.e11],
  e12: [indexes.e12],
  e13: [indexes.e13],
  e31: [indexes.e31],
  e32: [indexes.e32],
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
      } catch {}
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
