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
import { diff, f, initializeDiffTable } from "./typst.js";

const con = await oracledb.getConnection({
  user: "system",
  password: "password",
  connectString: "172.27.240.1:1521/XEPDB1",
  stmtCacheSize: 0,
});

await dropAllIndexes(con);
console.log("-----\nEVALUATING BASELINE\n-----");
await gatherAndSavePlans(con, "baseline");
const oldTimes = await gatherMeasurements(con);
const oldCosts = await gatherCosts(con);

for (const set in indexSets) {
  console.log(`-----\nEVALUATING SET ${set}\n-----`);

  let editQuery = {};
  for (const index of indexSets[set]) {
    editQuery = { ...editQuery, ...index.editQuery };
  }

  await createIndexes(con, indexSets[set]);

  await gatherAndSavePlans(con, set, editQuery);
  const newTimes = await gatherMeasurements(con, editQuery);
  const newCosts = await gatherCosts(con, editQuery);

  const table = initializeDiffTable();
  const sums = [0, 0, 0];
  for (const name of Object.keys(newTimes)) {
    table.addCell(name, { bold: true, mono: true });
    table.addCell(f(oldTimes[name].avg));
    table.addCell(f(newTimes[name].avg));
    table.addCell(diff(newTimes[name].avg - oldTimes[name].avg));
    table.addCell(f(oldCosts[name], true));
    table.addCell(f(newCosts[name], true));
    table.addCell(diff(newCosts[name] - oldCosts[name], true));
    sums[0] += oldTimes[name].avg;
    sums[1] += newTimes[name].avg;
    sums[2] += newTimes[name].avg - oldTimes[name].avg;
  }
  table.addCell("Suma", { bold: true });
  table.addCell(f(sums[0]), { bold: true });
  table.addCell(f(sums[1]), { bold: true });
  table.addCell(diff(sums[2]), { bold: true });
  table.addCell("—", { colspan: 3 });
  await fs.writeFile(`out/${set}/table.typ`, table.render());

  await dropIndexes(con, indexSets[set]);
}

await con.close();
