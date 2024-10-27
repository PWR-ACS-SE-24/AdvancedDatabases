import oracledb from "oracledb";
import { createBlocks } from "./blocks.js";

(async () => {
  const con = await oracledb.getConnection({
    user: "system",
    password: "password",
    connectString: "172.28.192.1:1521/XEPDB1",
  });

  console.log("STAGE #1: Creating blocks...");
  await createBlocks(con);

  await con.close();
})();
