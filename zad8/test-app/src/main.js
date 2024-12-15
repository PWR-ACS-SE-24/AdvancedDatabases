import oracledb from "oracledb";
import {
  createIndexes,
  dropAllIndexes,
  dropIndexes,
  indexSets,
} from "./indexes.js";
import { gatherMeasurements } from "./measurements.js";
import { gatherAndSavePlans, gatherCosts } from "./plans.js";

const con = await oracledb.getConnection({
  user: "system",
  password: "password",
  connectString: "localhost:1521/XEPDB1",
  stmtCacheSize: 0,
});

await dropAllIndexes(con);
console.log("-----\nEVALUATING BASELINE\n-----");
await gatherAndSavePlans(con, "baseline");
const baselineMeasurements = await gatherMeasurements(con);
const baselineCosts = await gatherCosts(con);

for (const set in indexSets) {
  console.log(`-----\nEVALUATING SET ${set}\n-----`);

  await createIndexes(con, indexSets[set]);

  await gatherAndSavePlans(con, set);
  const measurements = await gatherMeasurements(con);
  const costs = await gatherCosts(con);

  console.log({ baselineMeasurements, baselineCosts, measurements, costs });

  await dropIndexes(con, indexSets[set]);
}

await con.close();
