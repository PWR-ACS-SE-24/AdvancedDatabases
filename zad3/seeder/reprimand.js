import oracledb from "oracledb";
import progress from "cli-progress";
import { poisson } from "./util.js";

const REASONS = [
  "Niesubordynacja",
  "Niewłaściwe zachowanie",
  "Kłótnie z innymi więźniami",
  "Wszczęcie bójki",
  "Niszczenie mienia",
  "Nieprzestrzeganie ciszy nocnej",
  "Opóźnione powroty do celi",
  "Próby przemytu",
  "Kradzież przedmiotów",
  "Używanie wulgaryzmów",
  "Łamanie zasad higieny",
  "Niewłaściwe przechowywanie rzeczy",
  "Odmowa pracy",
  "Niewykonywanie poleceń",
  "Przemycanie jedzenia",
  "Przekazywanie wiadomości",
  "Niszczenie ubrań więziennych",
  "Złośliwe działanie wobec personelu",
  "Próba samookaleczenia",
  "Wchodzenie na zakazane tereny",
  "Niewłaściwy ubiór",
  "Manipulowanie strażnikami",
  "Kłótnie z personelem",
  "Brak współpracy w trakcie kontroli",
  "Naruszenie zasad sanitarnych",
  "Wandalizm",
  "Użycie niedozwolonego sprzętu",
  "Spiskowanie z innymi więźniami",
  "Udział w hazardzie",
  "Niewywiązywanie się z obowiązków",
];

/**
 *
 * @param {number} prisonerId
 * @param {number} guardId
 * @param {Date} start
 * @param {Date} end
 * @returns {{fk_guard: number, fk_prisoner: number, issue_date: Date, reason: string}}
 */
function generateReprimand(prisonerId, guardId, start, end) {
  const issue_date = new Date(
    start.getTime() + Math.random() * (end.getTime() - start.getTime())
  );

  const numberOfReprimands = poisson(2, 1, 10);
  const reasonList = [];
  for (let i = 0; i < numberOfReprimands; i++) {
    reasonList.push(REASONS[rand(0, REASONS.length - 1)]);
  }
  const reason = reprimandsList.join(", ");

  return {
    fk_guard: guardId,
    fk_prisoner: prisonerId,
    issue_date,
    reason,
  };
}

/**
 * @param {oracledb.Connection} con
 */
export async function createReprimands(con) {
  const bar = new progress.SingleBar({});

  console.log("STAGE #4: Creating reprimands...");

  const prisonerSentences = (
    await con.execute(
      `select p.id, s.start_date, s.real_end_date from prisoner p left join sentence s on p.id = s.fk_prisoner`
    )
  ).rows
    .map(([id, start, end]) => ({
      id,
      start,
      end,
      reprimands: poisson(1, 0, 100),
    }))
    .filter(({ reprimands }) => reprimands > 0);

  const guards = (
    await con.execute(`select id, employment_date, dismissal_date from guard`)
  ).rows.map(([id, employment, dismissal]) => ({ id, employment, dismissal }));

  bar.start(prisonerSentences.length, 0);
  const reprimands = [];
  for (const { id, start, end, reprimands } of prisonerSentences) {
    for (let i = 0; i < reprimands; i++) {
      const possibleGuards = guards.filter(
        ({ employment, dismissal }) =>
          employment <= start && (dismissal === null || dismissal >= end)
      );
      const guard =
        possibleGuards[Math.floor(Math.random() * possibleGuards.length)];

      reprimands.push(generateReprimand(id, guard.id, start, end));
    }
    bar.increment();
  }
  bar.stop();

  console.log("\tInserting reprimands...");

  await con.executeMany(
    "insert into reprimand(fk_guard, fk_prisoner, issue_date, reason) values (:fk_guard, :fk_prisoner, :issue_date, :reason)",
    reprimands,
    {
      autoCommit: true,
      bindDefs: {
        fk_guard: { type: oracledb.NUMBER },
        fk_prisoner: { type: oracledb.NUMBER },
        issue_date: { type: oracledb.DATE },
        reason: { type: oracledb.STRING, maxSize: 1000 },
      },
    }
  );

  await con.commit();
}
