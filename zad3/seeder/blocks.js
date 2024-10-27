import oracledb from "oracledb";

const EMPTY_BLOCK_COUNT = 10;
const SOLITARY_BLOCK_COUNT = 10;
const NORMAL_BLOCK_COUNT = 80;

/**
 *
 * @param {oracledb.Connection} con
 */
export async function createBlocks(con) {
  for (let i = 0; i < EMPTY_BLOCK_COUNT; i++) {
    await con.execute(
      "insert into prison_block(block_number, shower_count, additional_notes) values (:nr, 23, 'ab')",
      { nr: `E${i}` }
    );
  }
}
