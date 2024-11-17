import fs from "fs/promises";
import oracledb from "oracledb";

/**
 * @param {oracledb.Connection} con
 * @param {string} name
 * @param {string} sql
 * @param {Record<string, any>} params
 */
export async function explainPlan(con, name, sql, params) {
  await con.execute(`explain plan for ${sql}`, params);
  const result = await con.execute(
    "select plan_table_output from table(dbms_xplan.display())"
  );
  const plan = result.rows.join("\n") + "\n";
  await fs.writeFile(`plans/${name}.txt`, plan);
}
