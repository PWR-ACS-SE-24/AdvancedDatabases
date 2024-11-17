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
          select min(rownum) as n,
                min(p.id) as id
            from prisoner p
          inner join reprimand r
          on p.id = r.fk_prisoner
          where to_char(r.issue_date, 'YYYY-MM-DD') between :start_date and :end_date
            and ( :event_type is null
              or instr(
            r.reason,
            :event_type
          ) > 0 )
          group by p.pesel
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
                or to_char(a.end_date, 'YYYY-MM-DD HH24:MI:SS') >= :now )
                and to_char(a.start_date, 'YYYY-MM-DD HH24:MI:SS') <= :now
            group by fk_cell
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
