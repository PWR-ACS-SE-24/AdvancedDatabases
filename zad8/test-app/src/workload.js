import fs from "fs/promises";

/**
 * @param {string} name
 * @returns {Promise<string>}
 */
const readSql = (name) =>
  fs.readFile(`sql/${name}.sql`, "utf-8").then((text) => text.replace(";", ""));

export const N = 10;

export const workload = {
  query1: {
    sql: await readSql("query1"),
    params: {
      has_disability_class: 0,
      experience_months: 1,
      proposal_count: 3,
      start_time: "2024-09-01 00:00:00",
      end_time: "2024-10-31 23:59:59",
    },
  },
  query2: {
    sql: await readSql("query2"),
    params: {
      now: "2024-10-20",
      min_age: null,
      max_age: null,
      sex: null,
      min_height_m: null,
      max_height_m: null,
      min_weight_kg: null,
      max_weight_kg: null,
      min_sentences: null,
      max_sentences: null,
      crime: "Piractwo",
      min_reprimands: null,
      max_reprimands: null,
      min_stay_months: null,
      max_stay_months: null,
      min_release_months: null,
      max_release_months: null,
      is_in_solitary: null,
    },
  },
  query3: {
    sql: await readSql("query3"),
    params: {
      start_date: "2024-01-01",
      end_date: "2024-01-07",
      block_number: null,
      event_type: "Wandalizm",
      sentence_count: null,
      reprimand_count: null,
      crime: null,
      is_in_solitary: null,
    },
  },
  query4: {
    sql: await readSql("query4"),
    params: {
      now: "2024-10-20",
      block_number: null,
      sex: null,
    },
  },
  change1: {
    sql: await readSql("change1"),
    params: {
      now: "2025-01-01",
      experience_months: 24,
      start_time: "2024-01-01 00:00:00",
      end_time: "2024-01-01 23:59:59",
      block_number: "N1",
    },
  },
  change3: {
    sql: await readSql("change3"),
    params: {
      now: "2024-10-20",
      start_date: "2024-09-01",
      end_date: "2024-09-30",
      event_type: "Spiskowanie",
      block_number: "S1",
    },
  },
  change4: {
    sql: await readSql("change4"),
    params: {
      guard_id: 1,
      reason: "Wszczęcie bójki",
      event_time: "2024-09-01 13:00:00",
      block_number: "N1",
    },
  },
};
