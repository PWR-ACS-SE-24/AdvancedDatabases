import fs from "fs/promises";
import oracledb from "oracledb";

/** @param {string} name */
const readIndex = async (name) => {
  const create = await fs
    .readFile(`indexes/${name}-create.sql`, "utf-8")
    .then((t) => t.split(";").slice(0, -1));

  const drop = await fs
    .readFile(`indexes/${name}-drop.sql`, "utf-8")
    .then((t) => t.split(";").slice(0, -1));

  return { create, drop };
};

const indexes = {
  i1: await readIndex("i1"),
  i2: await readIndex("i2"),
  i3: await readIndex("i3"),
  i4: await readIndex("i4"),
  i5: await readIndex("i5"),
  e11: await readIndex("e11"),
  e12: await readIndex("e12"),
  e13: await readIndex("e13"),
};

export const indexSets = [
  [indexes.i1],
  [indexes.i2],
  [indexes.i3],
  [indexes.i4],
  [indexes.i5],
  [indexes.i1, indexes.i2, indexes.i3, indexes.i4, indexes.i5],
  [indexes.e11],
  [indexes.e12],
  [indexes.e13],
];

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
