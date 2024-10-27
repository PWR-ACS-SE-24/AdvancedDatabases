import oracledb from "oracledb";
import { poisson, rand } from "./util.js";

const EMPTY_BLOCK_COUNT = 10;
const SOLITARY_BLOCK_COUNT = 10;
const NORMAL_BLOCK_COUNT = 80;

/**
 * @param {oracledb.Connection} con
 * @param {string} nr
 * @param {number} showers
 * @param {string | undefined} notes
 * @returns {Promise<number>}
 */
async function insertBlock(con, nr, showers, notes) {
  await con.execute(
    "insert into prison_block(block_number, shower_count, additional_notes) values (:nr, :showers, :notes)",
    { nr, showers, notes }
  );
  const result = await con.execute(
    "select id from prison_block where block_number = :nr",
    { nr }
  );
  return result.rows[0][0];
}

/**
 * @param {oracledb.Connection} con
 * @param {number} block
 * @param {number} nr
 * @param {number} places
 * @param {0 | 1} solitary
 * @param {string | undefined} notes
 */
async function insertCell(con, block, nr, places, solitary, notes) {
  await con.execute(
    "insert into cell(fk_block, cell_number, place_count, is_solitary, additional_notes) values (:block, :nr, :places, :solitary, :notes)",
    { block, nr, places, solitary, notes }
  );
}

/** @param {oracledb.Connection} con */
export async function createBlocks(con) {
  console.log("STAGE #1: Creating blocks...");

  console.log("\tCreating empty blocks...");
  for (let i = 1; i <= EMPTY_BLOCK_COUNT; i++) {
    await insertBlock(con, `E${i}`, 0, "Blok niezawierający cel.");
  }

  console.log("\tCreating solitary blocks...");
  for (let i = 1; i <= SOLITARY_BLOCK_COUNT; i++) {
    const cellCount = rand(100, 1000);

    const blockId = await insertBlock(
      con,
      `S${i}`,
      cellCount,
      "Blok zawierający izolatki."
    );

    for (let j = 1; j <= cellCount; j++) {
      await insertCell(con, blockId, j, 1, 1, "Izolatka.");
    }
  }

  console.log("\tCreating normal blocks...");
  for (let i = 1; i <= NORMAL_BLOCK_COUNT; i++) {
    const cellCount = rand(1000, 5000);

    const blockId = await insertBlock(
      con,
      `N${i}`,
      cellCount,
      "Blok z celami dla więźniów."
    );

    for (let j = 1; j <= cellCount; j++) {
      await insertCell(con, blockId, j, poisson(5, 1, 10), 0, "Cela normalna.");
    }
  }

  await con.commit();
}
