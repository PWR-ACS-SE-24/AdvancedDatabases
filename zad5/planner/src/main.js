import oracledb from "oracledb";
import { query1 } from "./query1.js";
import { query2 } from "./query2.js";
import { query3 } from "./query3.js";
import { query4 } from "./query4.js";

const USER = "system";
const PASSWORD = "password";
const CONNECT_STRING = "localhost:1521/XEPDB1";

const con = await oracledb.getConnection({
  user: USER,
  password: PASSWORD,
  connectString: CONNECT_STRING,
});

await query1(con);
await query2(con);
await query3(con);
await query4(con);

await con.close();
