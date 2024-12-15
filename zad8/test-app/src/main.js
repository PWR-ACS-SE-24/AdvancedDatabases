import oracledb from "oracledb";
import { explainPlan } from "./util.js";
import { workload } from "./workload.js";

const con = await oracledb.getConnection({
  user: "system",
  password: "password",
  connectString: "localhost:1521/XEPDB1",
  stmtCacheSize: 0,
});

for (const name in workload) {
  await explainPlan(con, name, workload[name]);
}

const results = Object.fromEntries(
  Object.keys(workload).map((name) => [name, []])
);

for (let i = 0; i < N; i++) {
  console.log(`Iteration #${i + 1}/${N}, counts:`);
  console.log((await getCounts(con)).join(","));
  await flushMemory(con);
  for (const name in workload) {
    const time = await measureTime(con, workload[name]);
    results[name].push(time);
  }
}

const csv =
  `name,count,min,max,avg,std,${Array.from({ length: N })
    .map((_, i) => `t${i}`)
    .join(",")}\n` +
  Object.entries(results)
    .map(([name, times]) => {
      const s = calculateStats(times);
      const cols = [s.min, s.max, s.avg, s.std, ...times];
      return `${name},${s.count},${cols.map((c) => c.toFixed(3)).join(",")}`;
    })
    .join("\n");

console.log(csv);
await fs.writeFile("results.csv", csv);

await con.close();
