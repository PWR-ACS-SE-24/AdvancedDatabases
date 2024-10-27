import oracledb from "oracledb";
import progress from "cli-progress";
import { poisson, rand } from "./util.js";

const EMPTY_BLOCK_COUNT = 10;
const SOLITARY_BLOCK_COUNT = 10;
const NORMAL_BLOCK_COUNT = 80;

/**
 * @param {oracledb.Connection} con
 * @param {string} nr
 * @param {number} showers
 * @param {string | null} notes
 * @returns {Promise<number>}
 */
async function insertBlock(con, nr, showers, notes) {
  const result = await con.execute(
    `insert into prison_block(block_number, shower_count, additional_notes)
    values (:nr, :showers, :notes)
    returning id into :id`,
    {
      nr,
      showers,
      notes,
      id: { type: oracledb.NUMBER, dir: oracledb.BIND_OUT },
    }
  );
  return result.outBinds.id[0];
}

/**
 * @param {oracledb.Connection} con
 * @param {number} block
 * @param {number} count
 * @param {(i: number) => ({ nr: number, places: number, solitary: 0 | 1, notes: string | null })} generator
 */
async function insertCells(con, block, count, generator) {
  const cells = Array.from({ length: count }, (_, i) => ({
    block,
    ...generator(i + 1),
  }));

  await con.executeMany(
    `insert into cell(fk_block, cell_number, place_count, is_solitary, additional_notes)
    values (:block, :nr, :places, :solitary, :notes)`,
    cells,
    {
      autoCommit: true,
      bindDefs: {
        block: { type: oracledb.NUMBER },
        nr: { type: oracledb.NUMBER },
        places: { type: oracledb.NUMBER },
        solitary: { type: oracledb.NUMBER },
        notes: {
          type: oracledb.STRING,
          maxSize: cells.reduce(
            (max, { notes }) => Math.max(max, notes?.length ?? 0),
            0
          ),
        },
      },
    }
  );
}

/** @param {oracledb.Connection} con */
export async function createBlocks(con) {
  const bar = new progress.SingleBar({});

  console.log("STAGE #1: Creating blocks...");

  console.log("\tCreating empty blocks...");
  bar.start(EMPTY_BLOCK_COUNT, 0);
  for (let i = 1; i <= EMPTY_BLOCK_COUNT; i++) {
    await insertBlock(con, `E${i}`, 0, "Blok niezawierający cel.");
    bar.increment();
  }
  bar.stop();

  console.log("\tCreating solitary blocks...");
  bar.start(SOLITARY_BLOCK_COUNT, 0);
  for (let i = 1; i <= SOLITARY_BLOCK_COUNT; i++) {
    const cellCount = rand(100, 1000);

    const blockId = await insertBlock(
      con,
      `S${i}`,
      cellCount,
      "Blok zawierający izolatki."
    );

    await insertCells(con, blockId, cellCount, (j) => ({
      nr: j,
      places: 1,
      solitary: 1,
      notes: "Izolatka.",
    }));

    bar.increment();
  }
  bar.stop();

  console.log("\tCreating normal blocks...");
  bar.start(NORMAL_BLOCK_COUNT, 0);
  for (let i = 1; i <= NORMAL_BLOCK_COUNT; i++) {
    const cellCount = rand(1000, 5000);

    const blockId = await insertBlock(
      con,
      `N${i}`,
      cellCount,
      "Blok z celami dla więźniów."
    );

    await insertCells(con, blockId, cellCount, (j) => ({
      nr: j,
      places: poisson(5, 1, 10),
      solitary: 0,
      notes: "Cela normalna.",
    }));

    bar.increment();
  }
  bar.stop();

  await con.commit();
}
