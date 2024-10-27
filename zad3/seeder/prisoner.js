import oracledb from "oracledb";

const PRISONER_COUNT_MIN = 100_000;
const PRISONER_COUNT_MAX = 500_000;

/** @param {oracledb.Connection} con */
export async function createPrisoners(con) {
  const bar = new progress.SingleBar({});

  console.log("STAGE #3: Creating prisoners...");

  console.log("\tCreating prisoners...");
}
