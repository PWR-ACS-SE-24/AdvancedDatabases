import fs from "fs/promises";
import { workload } from "./workload.js";

/**
 * @param {oracledb.Connection} con
 * @param {Query} query
 */
async function explainPlan(con, query) {
  const { sql, params } = query;
  await con.execute(`explain plan for ${sql}`, params);
  const result = await con.execute(
    "select plan_table_output from table(dbms_xplan.display())"
  );
  return result.rows.join("\n") + "\n";
}

/**
 * @param {oracledb.Connection} con
 * @param {string} set
 */
export async function gatherAndSavePlans(con, set) {
  console.log("Gathering plans...");
  await fs.mkdir(`out/${set}/plans`, { recursive: true });
  for (const name in workload) {
    const plan = await explainPlan(con, workload[name]);
    await fs.writeFile(`out/${set}/plans/${name}.txt`, plan);
  }
  console.log("Gathered plans.");
}

/**
 * @param {oracledb.Connection} con
 * @param {string} name
 * @param {Query} query
 */
async function calculateCost(con, query) {
  const { sql, params } = query;
  await con.execute(`explain plan for ${sql}`, params);
  const result = await con.execute(
    "select plan_table_output from table(dbms_xplan.display(format => 'basic cost'))"
  );
  return Math.max(
    ...result.rows
      .slice(5)
      .map(([row]) => row.split("|")[4]?.trim())
      .filter((row) => row?.length > 0)
      .map((row) => parseInt(row, 10))
  );
}

/** @param {oracledb.Connection} con */
export async function gatherCosts(con) {
  console.log("Gathering costs...");
  /** @type {Record<string, number>} */
  const results = {};
  for (const name in workload) {
    results[name] = await calculateCost(con, workload[name]);
  }
  console.log("Gathered costs.");
  return results;
}
