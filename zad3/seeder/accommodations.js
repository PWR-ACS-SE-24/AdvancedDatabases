import oracledb from "oracledb";
import _ from "lodash";
import progress from "cli-progress";
import { poisson, rand } from "./util.js";
import { Room } from "./room.js";

const CURRENT_DATE = new Date("2024-10-27T00:00:00Z");

/**
 * @param {{ id: number, room: Room }[]} cells
 * @param {Date} s
 * @param {Date} e
 * @returns {number}
 */
function findCell(cells, s, e) {
  while (true) {
    const idx = rand(0, cells.length - 1);
    if (cells[idx].room.canFit(s, e)) {
      cells[idx].room.goIn(s, e);
      return cells[idx].id;
    }
  }
}

/** @param {oracledb.Connection} con */
export async function createAccommodations(con) {
  const bar = new progress.SingleBar({});

  console.log("STAGE #5: Creating accommodations...");

  console.log("\tFetching prisoner sentences...");
  const prisonerSentences = (
    await con.execute(
      `select p.id, s.start_date, s.real_end_date from prisoner p
      left join sentence s on p.id = s.fk_prisoner`
    )
  ).rows.map(([id, s, e]) => ({
    id,
    s,
    e,
  }));

  const prisoners = _.mapValues(
    _.groupBy(prisonerSentences, ({ id }) => id),
    (sentences) => {
      const intervals = sentences.map(({ s, e }) => ({
        s: s.getTime(),
        e: e?.getTime() ?? Infinity,
      }));
      intervals.sort((a, b) => a.s - b.s);
      const merged = [];
      let prev = intervals[0];
      for (let i = 1; i < intervals.length; i++) {
        let sentence = intervals[i];
        if (sentence.s <= prev.e) {
          prev.e = Math.max(prev.e, sentence.e);
        } else {
          merged.push(prev);
          prev = sentence;
        }
      }
      merged.push(prev);
      return merged.map(({ s, e }) => ({
        s: new Date(s),
        e: !Number.isFinite(e) ? null : new Date(e),
      }));
    }
  );

  const cells = (
    await con.execute("select id, place_count from cell")
  ).rows.map(([id, places]) => ({ id, room: new Room(places) }));

  console.log("\tGenerating accommodations...");
  const accommodations = [];
  bar.start(Object.entries(prisoners).length, 0);
  for (const id in prisoners) {
    const intervals = prisoners[id];
    const accommodationCount = poisson(5, intervals.length, 10);
    const intervalSplitCount = accommodationCount - intervals.length;
    for (let i = 0; i < intervalSplitCount; i++) {
      const idx = rand(0, intervals.length - 1);
      const splitPoint = new Date(
        rand(
          intervals[idx].s.getTime(),
          intervals[idx].e?.getTime() ?? CURRENT_DATE.getTime()
        )
      );
      intervals.splice(idx + 1, 0, {
        s: splitPoint,
        e: intervals[idx].e,
      });
      intervals[idx].e = splitPoint;
    }

    const prisoner = parseInt(id, 10);
    for (const { s, e } of intervals) {
      const cell = findCell(cells, s, e);
      accommodations.push({
        cell,
        prisoner,
        s,
        e,
      });
    }

    bar.increment();
  }
  bar.stop();

  console.log("\tInserting accommodations...");
  await con.executeMany(
    `insert into accommodation(fk_cell, fk_prisoner, start_date, end_date)
    values (:cell, :prisoner, :s, :e)`,
    accommodations,
    {
      autoCommit: true,
      bindDefs: {
        cell: { type: oracledb.NUMBER },
        prisoner: { type: oracledb.NUMBER },
        s: { type: oracledb.DATE },
        e: { type: oracledb.DATE },
      },
    }
  );

  await con.commit();
}
