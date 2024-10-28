import oracledb from "oracledb";
import { createBlocks } from "./blocks.js";
import { createGuards } from "./guards.js";
import { createPrisoners } from "./prisoner.js";

const USER = "system";
const PASSWORD = "password";
const CONNECT_STRING = "172.28.192.1:1521/XEPDB1";

/** @param {oracledb.Connection} con */
async function truncate(con) {
  console.log("STAGE #0: Truncating tables...");
  await con.execute("truncate table reprimand");
  // await con.execute("truncate table patrol");
  await con.execute("truncate table sentence");
  await con.execute("truncate table accommodation");
  // await con.execute("truncate table cell");
  // await con.execute("truncate table patrol_slot");
  // await con.execute("truncate table guard");
  // await con.execute("truncate table prison_block");
  await con.execute("truncate table prisoner");
  await con.commit();
}

/**
 * @param {oracledb.Connection} con
 * @param {string} table
 */
async function countRows(con, table) {
  const result = await con.execute(`select count(*) as cnt from ${table}`);
  console.log("Created", result.rows[0][0], "rows in", table);
}

(async () => {
  const con = await oracledb.getConnection({
    user: USER,
    password: PASSWORD,
    connectString: CONNECT_STRING,
  });

  await truncate(con);
  // await createBlocks(con);
  await countRows(con, "prison_block");
  await countRows(con, "cell");
  // await createGuards(con);
  await countRows(con, "patrol_slot");
  await countRows(con, "guard");
  await countRows(con, "patrol");
  await createPrisoners(con);
  await countRows(con, "prisoner");
  await countRows(con, "sentence");

  await con.close();
})();
