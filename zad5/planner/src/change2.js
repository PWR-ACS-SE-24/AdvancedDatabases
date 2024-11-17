import { explainPlan } from "./util.js";

export async function change2(con) {
  const start_time = "2024-01-01 00:00:00";
  const end_time = "2024-12-31 23:59:59";
  const slot_duration = 15;

  await explainPlan(
    con,
    "change2",
    `
    insert into patrol_slot (start_time, end_time)
    select to_timestamp('${start_time}',
                'YYYY-MM-DD HH24:MI:SS') + ( interval '1' minute * ${slot_duration} * level ) as start_time,
          to_timestamp('${start_time}',
                        'YYYY-MM-DD HH24:MI:SS') + ( interval '1' minute * ${slot_duration} * ( level + 1 ) - interval '1' second )
                        as end_time
      from dual
    connect by
      level <= trunc(extract(day from(to_timestamp('${end_time}',
            'YYYY-MM-DD HH24:MI:SS') - to_timestamp('${start_time}',
            'YYYY-MM-DD HH24:MI:SS')) * 24 * 60) / ${slot_duration})
    `,
    {}
  );
}
