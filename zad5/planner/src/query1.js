import { explainPlan } from "./util.js";

export async function query1(con) {
  await explainPlan(
    con,
    "query1",
    `
    select ps.start_time,
          ps.end_time,
          (
              select
                listagg(g.first_name
                        || ' '
                        || g.last_name
                        || ' ('
                        || g.id
                        || ')',
                        ', ') within group(
                  order by g.id)
                from (
                select id,
                        first_name,
                        last_name
                  from (
                    select g.id,
                          g.first_name,
                          g.last_name,
                          ps.id as patrol_slot_id
                      from guard g
                    cross join patrol_slot ps
                      left join patrol p
                    on p.fk_guard = g.id
                      and p.fk_patrol_slot = ps.id
                    where p.id is null
                      and g.employment_date <= ps.start_time
                      and ( g.dismissal_date is null
                        or g.dismissal_date >= ps.end_time )
                      and ( :has_disability_class is null
                        or g.has_disability_class = :has_disability_class )
                      and ( :experience_months is null
                        or months_between(
                      ps.start_time,
                      g.employment_date
                    ) >= :experience_months )
                ) ag
                  where ag.patrol_slot_id = ps.id
                  order by dbms_random.value
                  fetch first :proposal_count rows only
              ) g
          ) as guards
      from patrol_slot ps
    where ps.start_time >= to_timestamp(:start_time,
                    'YYYY-MM-DD HH24:MI:SS')
      and ps.end_time <= to_timestamp(:end_time,
                'YYYY-MM-DD HH24:MI:SS')
    `,
    {
      has_disability_class: 0,
      experience_months: 1,
      proposal_count: 3,
      start_time: "2024-11-01 00:00:00",
      end_time: "2024-11-01 23:59:59",
    }
  );
}
