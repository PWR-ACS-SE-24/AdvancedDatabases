import fs from "fs/promises";
import oracledb from "oracledb";
import {
  createIndexes,
  dropAllIndexes,
  dropIndexes,
  indexSets,
} from "./indexes.js";
import { gatherMeasurements } from "./measurements.js";
import { gatherAndSavePlans, gatherCosts } from "./plans.js";
import { initializeDiffTable } from "./typst.js";

const con = await oracledb.getConnection({
  user: "system",
  password: "password",
  connectString: "localhost:1521/XEPDB1",
  stmtCacheSize: 0,
});

await dropAllIndexes(con);
console.log("-----\nEVALUATING BASELINE\n-----");
await gatherAndSavePlans(con, "baseline");
const oldTimes = await gatherMeasurements(con);
const oldCosts = await gatherCosts(con);

for (const set in indexSets) {
  console.log(`-----\nEVALUATING SET ${set}\n-----`);

  await createIndexes(con, indexSets[set]);

  await gatherAndSavePlans(con, set);
  const newTimes = await gatherMeasurements(con);
  const newCosts = await gatherCosts(con);

  const table = initializeDiffTable();
  for (const name of Object.keys(newTimes)) {
    table.addCell(name, { bold: true, mono: true });
    table.addCell(oldTimes[name].avg.toFixed(2));
    table.addCell(newTimes[name].avg.toFixed(2));
    const timeDiff = (newTimes[name].avg - oldTimes[name].avg).toFixed(2);
    table.addCell(`#diff(${timeDiff})`);
    table.addCell(oldCosts[name]);
    table.addCell(newCosts[name]);
    table.addCell(`#diff(${newCosts[name] - oldCosts[name]})`);
  }
  await fs.writeFile(`out/${set}/table.txt`, table.render());

  await dropIndexes(con, indexSets[set]);
}

await con.close();
