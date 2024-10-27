import oracledb from "oracledb";
import progress from "cli-progress";
import { fakerPL } from "@faker-js/faker";
import { normal, rand } from "./util.js";

const PRISONER_COUNT_MIN = 100_000;
const PRISONER_COUNT_MAX = 500_000;
const BIRTHDAY_START = new Date("1960-01-01");
const BIRTHDAY_END = new Date("1999-12-31");

const pesels = new Set();

/**
 * @param {Date} birthday
 * @param {1 | 2} sex
 * @returns {string}
 */
function generatePesel(birthday, sex) {
  const year = birthday.getFullYear();
  const month = birthday.getMonth() + 1;
  const day = birthday.getDate();

  let yearPart = String(year).slice(-2);
  let monthPart;
  if (year >= 1900 && year < 2000) {
    monthPart = month + 0;
  } else if (year >= 2000 && year < 2100) {
    monthPart = month + 20;
  } else {
    throw new Error("Unsupported year!");
  }
  monthPart = String(monthPart).padStart(2, "0");

  const dayPart = String(day).padStart(2, "0");

  while (true) {
    const serialNumber = rand(0, 999).toString().padStart(3, "0");

    let sexDigit = sex === "male" ? 1 : 0;
    sexDigit += rand(0, 4) * 2;

    let partialPESEL = yearPart + monthPart + dayPart + serialNumber + sexDigit;

    const weights = [1, 3, 7, 9, 1, 3, 7, 9, 1, 3];
    let controlSum = 0;
    for (let i = 0; i < 10; i++) {
      controlSum += parseInt(partialPESEL[i]) * weights[i];
    }
    const controlDigit = (10 - (controlSum % 10)) % 10;

    const pesel = partialPESEL + controlDigit;
    if (pesels.has(pesel)) {
      continue;
    }
    pesels.add(pesel);
    return pesel;
  }
}

/** @returns {{ pesel: string, first: string, last: string, birthday: Date, sex: 1 | 2, height: number, weight: number }} */
function generatePrisoner() {
  const sex = Math.random() < 0.1 ? "female" : "male";
  const birthday = new Date(
    rand(BIRTHDAY_START.getTime(), BIRTHDAY_END.getTime())
  );
  const height =
    sex === "male" ? normal(1.7, 0.1, 1.5, 2.0) : normal(1.6, 0.1, 1.4, 2.0);
  const bmi = normal(24, 6, 10, 40);
  const weight = bmi * height ** 2;
  return {
    pesel: generatePesel(birthday, sex),
    first: fakerPL.person.firstName(sex),
    last: fakerPL.person.lastName(sex),
    birthday,
    sex: sex === "male" ? 1 : 2,
    height,
    weight,
  };
}

/** @param {oracledb.Connection} con */
export async function createPrisoners(con) {
  const bar = new progress.SingleBar({});

  console.log("STAGE #3: Creating prisoners...");

  console.log("\tCreating prisoners...");
  const prisonerCount = rand(PRISONER_COUNT_MIN, PRISONER_COUNT_MAX);
  const prisoners = [];
  bar.start(prisonerCount, 0);
  for (let i = 0; i < prisonerCount; i++) {
    prisoners.push(generatePrisoner());
    bar.increment();
  }
  bar.stop();

  console.log("\tInserting prisoners...");
  await con.executeMany(
    `insert into prisoner(pesel, first_name, last_name, birthday, sex, height_m, weight_kg)
    values (:pesel, :first, :last, :birthday, :sex, :height, :weight)`,
    prisoners,
    {
      autoCommit: true,
      bindDefs: {
        pesel: { type: oracledb.STRING, maxSize: 11 },
        first: { type: oracledb.STRING, maxSize: 255 },
        last: { type: oracledb.STRING, maxSize: 255 },
        birthday: { type: oracledb.DATE },
        sex: { type: oracledb.NUMBER },
        height: { type: oracledb.NUMBER },
        weight: { type: oracledb.NUMBER },
      },
    }
  );

  await con.commit();
}
