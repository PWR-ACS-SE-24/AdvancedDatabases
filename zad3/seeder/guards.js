import oracledb from "oracledb";
import { fakerPL } from "@faker-js/faker";
import progress from "cli-progress";
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
 * @param {Date} start
 * @param {Date} end
 * @returns {{ first: string, last: string, employment: Date, dismissal: Date | null, disability: 0 | 1, salary: number }}
 */
function generateGuard(start, end) {
  const sex = Math.random() < 0.1 ? "female" : "male";
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
    Math.round(
      GUARD_BASE_SALARY *
        (1 + experienceYears * GUARD_SALARY_EXPERIENCE_MULTIPLIER) *
        Math.pow(INFLATION_MULTIPLIER, inflationYears) *
        100
    ) / 100;
  return {
    first: fakerPL.person.firstName(sex),
    last: fakerPL.person.lastName(sex),
    employment,
    dismissal,
    disability,
    salary,
  };
}

/** @param {oracledb.Connection} con */
export async function createGuards(con) {
  console.log("STAGE #2: Creating guards...");

  console.log("\tCreating patrol slots...");
  const slots = [];
  for (
    let ts = START_TIMESTAMP.getTime();
    ts < END_TIMESTAMP.getTime();
    ts += PATROL_DURATION_MS
  ) {
    slots.push({ s: new Date(ts), e: new Date(ts + PATROL_DURATION_MS - 1) });
  }
  await con.executeMany(
    "insert into patrol_slot(start_time, end_time) values (:s, :e)",
    slots,
    {
      autoCommit: true,
      bindDefs: { s: { type: oracledb.DATE }, e: { type: oracledb.DATE } },
    }
  );

  const bar = new progress.SingleBar({});

  console.log("\tCreating patrols with guards...");
  const patrolSlots = (
    await con.execute("select id, start_time, end_time from patrol_slot")
  ).rows;
  const blocks = (
    await con.execute(
      "select min(pb.id), count(c.id) as cnt from prison_block pb inner join cell c on pb.id = c.fk_block group by pb.id"
    )
  ).rows;
  const guardsForOneSlot = blocks
    .map(([_, cellCount]) => Math.floor(cellCount / CELLS_PER_GUARD) + 1)
    .reduce((a, b) => a + b, 0);
  bar.start(patrolSlots.length, 0);
  for (const [patrolSlotId, start, end] of patrolSlots) {
    const availableGuards = (
      await con.execute(
        `
      SELECT g.id, g.has_disability_class FROM guard g
      LEFT JOIN patrol p ON p.fk_guard = g.id AND p.fk_patrol_slot = :psid
      WHERE p.fk_guard IS NULL and g.employment_date <= :s
          and (g.dismissal_date is null or g.dismissal_date >= :e)
      `,
        { psid: patrolSlotId, s: start, e: end }
      )
    ).rows.map((row) => ({ id: row[0], disability: row[1] }));

    const missingGuards = guardsForOneSlot - availableGuards.length;
    if (missingGuards > 0) {
      const newGuards = [];
      for (let i = 0; i < missingGuards; i++) {
        newGuards.push(generateGuard(start, end));
      }
      const createdGuards = (
        await con.executeMany(
          `insert into guard(first_name, last_name, employment_date, dismissal_date, has_disability_class, monthly_salary_pln)
          values (:first, :last, :employment, :dismissal, :disability, :salary)
          returning id into :id`,
          newGuards,
          {
            autoCommit: true,
            bindDefs: {
              first: { type: oracledb.STRING, maxSize: 255 },
              last: { type: oracledb.STRING, maxSize: 255 },
              employment: { type: oracledb.DATE },
              dismissal: { type: oracledb.DATE },
              disability: { type: oracledb.NUMBER },
              salary: { type: oracledb.NUMBER },
              id: { type: oracledb.NUMBER, dir: oracledb.BIND_OUT },
            },
          }
        )
      ).outBinds.map((row, i) => ({
        id: row.id[0],
        disability: newGuards[i].disability,
      }));
      availableGuards.push(...createdGuards);
    }

    const patrols = [];
    const isNight = start.getHours() <= 6 || start.getHours() >= 20;
    for (const [blockId, cellCount] of blocks) {
      const patrolCount = Math.floor(cellCount / CELLS_PER_GUARD) + 1;
      for (let i = 0; i < patrolCount; i++) {
        let dog = Math.random() < (isNight ? 0.5 : 0.25) ? 1 : 0;
        let guard = availableGuards.pop();
        if (guard.disability) {
          dog = 1; // przewodnik
        }
        patrols.push({
          guard: guard.id,
          block: blockId,
          slot: patrolSlotId,
          dog,
        });
      }
    }
    await con.executeMany(
      `insert into patrol(fk_guard, fk_block, fk_patrol_slot, is_with_dog) values (:guard, :block, :slot, :dog)`,
      patrols,
      {
        autoCommit: true,
        bindDefs: {
          guard: { type: oracledb.NUMBER },
          block: { type: oracledb.NUMBER },
          slot: { type: oracledb.NUMBER },
          dog: { type: oracledb.NUMBER },
        },
      }
    );

    bar.increment();
  }
  bar.stop();

  await con.commit();
}
