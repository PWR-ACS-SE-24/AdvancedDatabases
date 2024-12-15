import oracledb from "oracledb";
import { dropAllIndexes } from "./indexes.js";
import { gatherMeasurements } from "./measurements.js";
import { gatherAndSavePlans } from "./plans.js";

const con = await oracledb.getConnection({
  user: "system",
  password: "password",
  connectString: "localhost:1521/XEPDB1",
  stmtCacheSize: 0,
});

await dropAllIndexes(con);
await gatherAndSavePlans(con, "baseline");
const baselineMeasurements = await gatherMeasurements(con);

console.log(baselineMeasurements);

await con.close();
