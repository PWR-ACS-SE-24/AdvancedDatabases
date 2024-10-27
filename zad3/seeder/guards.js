import oracledb from "oracledb";
import { fakerPL } from "@faker-js/faker";
import { normal, rand } from "./util.js";

const START_TIMESTAMP = new Date("2000-01-01T00:00:00Z");
const CURRENT_TIMESTAMP = new Date("2024-10-27T00:00:00Z");
const END_TIMESTAMP = new Date("2024-12-31T23:59:59Z");
const PATROL_DURATION_MS = 8 * 60 * 60 * 1000; // 8 hours
const YEAR_IN_MS = 365 * 24 * 60 * 60 * 1000;
const CELLS_PER_GUARD = 100;
const INFLATION_MULTIPLIER = 1.05;
const GUARD_BASE_SALARY = 5000;
const GUARD_SALARY_EXPERIENCE_MULTIPLIER = 0.1;

/**
 * @param {oracledb.Connection} con
 * @param {number} patrolSlotId
 * @param {Date} start
 * @param {Date} end
 */
async function ensureGuard(con, patrolSlotId, start, end) {
  let result = await con.execute(
    `select g.id from guard g
    inner join patrol p on g.id = p.fk_guard
    where p.fk_patrol_slot <> :psid
      and g.employment_date <= :s
      and (g.dismissal_date is null or g.dismissal_date >= :e)`,
    { psid: patrolSlotId, s: start, e: end }
  );
  const guardId = result.rows[0]?.[0];
  if (guardId) {
    return guardId;
  }

  const gender = Math.random() < 0.1 ? "female" : "male";
  const employment = new Date(
    Math.max(start.getTime() - rand(0, YEAR_IN_MS), START_TIMESTAMP)
  );
  let dismissal = new Date(
    end.getTime() +
      normal(10 * YEAR_IN_MS, 2 * YEAR_IN_MS, 2 * YEAR_IN_MS, 20 * YEAR_IN_MS)
  );
  if (dismissal > CURRENT_TIMESTAMP) {
    dismissal = null;
  }
  const disability = Math.random() < 0.05 ? 1 : 0;
  const worksUntilMs = (dismissal ?? CURRENT_TIMESTAMP).getTime();
  const inflationYears =
    (worksUntilMs - START_TIMESTAMP.getTime()) / YEAR_IN_MS;
  const experienceYears = (worksUntilMs - employment.getTime()) / YEAR_IN_MS;
  const salary =
    GUARD_BASE_SALARY *
    (1 + experienceYears * GUARD_SALARY_EXPERIENCE_MULTIPLIER) *
    Math.pow(INFLATION_MULTIPLIER, inflationYears);
  result = await con.execute(
    `insert into guard(first_name, last_name, employment_date, dismissal_date, has_disability_class, monthly_salary_pln)
    values (:first, :last, :employment, :dismissal, :disability, :salary)
    returning id into :id`,
    {
      first: fakerPL.person.firstName(gender),
      last: fakerPL.person.lastName(gender),
      employment,
      dismissal,
      disability,
      salary,
      id: { type: oracledb.NUMBER, dir: oracledb.BIND_OUT },
    }
  );
  return result.outBinds.id[0];
}

/**
 *
 * @param {oracledb.Connection} con
 */
export async function createGuards(con) {
  console.log("STAGE #2: Creating guards...");

  console.log("\tCreating patrol slots...");
  for (
    let ts = START_TIMESTAMP.getTime();
    ts < END_TIMESTAMP.getTime();
    ts += PATROL_DURATION_MS
  ) {
    await con.execute(
      "insert into patrol_slot(start_time, end_time) values (:s, :e)",
      {
        s: new Date(ts),
        e: new Date(ts + PATROL_DURATION_MS - 1),
      }
    );
  }

  console.log("\tCreating patrols...");
  const patrolSlots = (
    await con.execute("select id, start_time, end_time from patrol_slot")
  ).rows;
  const blocks = (
    await con.execute(
      "select min(pb.id), count(c.id) as cnt from prison_block pb inner join cell c on pb.id = c.fk_block group by pb.id"
    )
  ).rows;
  for (const [patrolSlotId, start, end] of patrolSlots) {
    for (const [blockId, cellCount] of blocks) {
      const patrolCount = Math.floor(cellCount / CELLS_PER_GUARD) + 1;
      for (let i = 0; i < patrolCount; i++) {
        const guardId = await ensureGuard(con, patrolSlotId, start, end);
        await con.execute(
          "insert into patrol(fk_guard, fk_block, fk_patrol_slot, is_with_dog) values (:guard, :block, :slot, :dog)",
          {
            guard: guardId,
            block: blockId,
            slot: patrolSlotId,
            dog: Math.random() < 0.05 ? 1 : 0,
          }
        );
      }
    }
  }

  await con.commit();
}
