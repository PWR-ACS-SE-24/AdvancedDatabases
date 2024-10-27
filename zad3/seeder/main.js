import oracledb from "oracledb";
import { createBlocks } from "./blocks.js";

const USER = "system";
const PASSWORD = "password";
const CONNECT_STRING = "172.28.192.1:1521/XEPDB1";

/** @param {oracledb.Connection} con */
async function truncate(con) {
  console.log("STAGE #0: Truncating tables...");
  await con.execute("truncate table reprimand");
  await con.execute("truncate table patrol");
  await con.execute("truncate table sentence");
  await con.execute("truncate table accommodation");
  await con.execute("truncate table cell");
  await con.execute("truncate table patrol_slot");
  await con.execute("truncate table guard");
  await con.execute("truncate table prison_block");
  await con.execute("truncate table prisoner");
  await con.commit();
}

(async () => {
  const con = await oracledb.getConnection({
    user: USER,
    password: PASSWORD,
    connectString: CONNECT_STRING,
  });

  await truncate(con);
  await createBlocks(con);

  await con.close();
})();
