import oracledb from "oracledb";
import progress from "cli-progress";
import { fakerPL } from "@faker-js/faker";
import { rand } from "./util.js";

const PRISONER_COUNT_MIN = 100_000;
const PRISONER_COUNT_MAX = 500_000;
const BIRTHDAY_START = new Date("1960-01-01");
const BIRTHDAY_END = new Date("2000-01-01");

/** @param {oracledb.Connection} con */
async function generatePrisoner(con) {
  const sex = Math.random() < 0.1 ? "female" : "male";
  const birthday = rand(BIRTHDAY_START.getTime(), BIRTHDAY_END.getTime());
  await con.execute(
    `insert into prisoner(pesel, first_name, last_name, birthday, sex, height_m, weight_kg)
    values (:pesel, :first, :last, :birthday, :sex, :height, :weight)`,
    {
      pesel: "00000000000", // TODO
      first: fakerPL.person.firstName(sex),
      last: fakerPL.person.lastName(sex),
      birthday, // TODO
      sex,
      height: 123,
      weight: 123,
    }
  );
}

/** @param {oracledb.Connection} con */
export async function createPrisoners(con) {
  const bar = new progress.SingleBar({});

  console.log("STAGE #3: Creating prisoners...");

  console.log("\tCreating prisoners...");
  const prisonerCount = rand(PRISONER_COUNT_MIN, PRISONER_COUNT_MAX);
  bar.start(prisonerCount, 0);
  for (let i = 0; i < prisonerCount; i++) {
    await generatePrisoner(con);
    bar.increment();
  }
  bar.stop();
}
