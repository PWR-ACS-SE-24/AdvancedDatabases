import { explainPlan } from "./util.js";

export async function change1(con) {
  await explainPlan(
    con,
    "change1",
    `
    update guard
      set
      dismissal_date = to_date(:now,
            'YYYY-MM-DD')
    where months_between(
          to_timestamp(:now,
                      'YYYY-MM-DD HH24:MI:SS'),
          guard.employment_date
      ) < :experience_months
      and dismissal_date is null
      and id not in (
      select guard.id
        from guard
        inner join patrol
      on guard.id = patrol.fk_guard
        inner join patrol_slot
      on patrol.fk_patrol_slot = patrol_slot.id
        where patrol_slot.start_time >= to_timestamp(:now,
                'YYYY-MM-DD HH24:MI:SS')
    )
      and id in (
      select guard.id
        from guard
        inner join patrol
      on guard.id = patrol.fk_guard
        inner join patrol_slot
      on patrol.fk_patrol_slot = patrol_slot.id
        inner join prison_block
      on patrol.fk_block = prison_block.id
        where patrol_slot.start_time >= to_timestamp(:start_time,
                    'YYYY-MM-DD HH24:MI:SS')
          and patrol_slot.end_time <= to_timestamp(:end_time,
                'YYYY-MM-DD HH24:MI:SS')
          and prison_block.block_number = :block_number
    )
    `,
    {
      now: "2025-01-01",
      experience_months: 24,
      start_time: "2024-01-01 00:00:00",
      end_time: "2024-01-01 23:59:59",
      block_number: "N1",
    }
  );
}
