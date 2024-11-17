import { explainPlan } from "./util.js";

export async function change3(con) {
  await explainPlan(
    con,
    "change3",
    `
    insert into accommodation (
      fk_cell,
      fk_prisoner,
      start_date,
      end_date
    )
      select c.id as fk_cell,
              p.id as fk_prisoner,
              to_timestamp(:now,
                          'YYYY-MM-DD HH24:MI:SS') as start_date,
              null as end_date
        from (
          select rownum as n,
                p.id
            from prisoner p
          inner join reprimand r
          on p.id = r.fk_prisoner
          where r.issue_date between to_date(:start_date,
            'YYYY-MM-DD') and to_date(:end_date,
            'YYYY-MM-DD')
            and ( :event_type is null
              or instr(
            r.reason,
            :event_type
          ) > 0 )
      ) p
        inner join (
          select rownum as n,
                c.id
            from cell c
          inner join prison_block pb
          on pb.id = c.fk_block
          where pb.block_number = :block_number
            and c.is_solitary = 1
            and c.id not in (
            select fk_cell
              from accommodation a
              where ( a.end_date is null
                or a.end_date >= to_timestamp(:now,
                'YYYY-MM-DD HH24:MI:SS') )
                and a.start_date <= to_timestamp(:now,
                'YYYY-MM-DD HH24:MI:SS')
          )
      ) c
      on p.n = c.n
    `,
    {
      now: "2024-10-20",
      start_date: "2024-09-01",
      end_date: "2024-09-30",
      event_type: "Spiskowanie",
      block_number: "S1",
    }
  );
}
