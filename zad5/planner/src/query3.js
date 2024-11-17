import { explainPlan } from "./util.js";

export async function query3(con) {
  await explainPlan(
    con,
    "query3",
    `
    select r.id,
          r.issue_date,
          p.first_name
          || ' '
          || p.last_name
          || ' ('
          || p.id
          || ')' as prisoner,
          g.first_name
          || ' '
          || g.last_name
          || ' ('
          || g.id
          || ')' as guard,
          r.reason
      from reprimand r
      join prisoner p
    on r.fk_prisoner = p.id
      join guard g
    on r.fk_guard = g.id
      join (
      select p.id,
              pb.id as block_id,
              pb.block_number,
              c.is_solitary
        from prison_block pb
        inner join cell c
      on pb.id = c.fk_block
        inner join accommodation a
      on c.id = a.fk_cell
        inner join prisoner p
      on a.fk_prisoner = p.id
        where a.start_date <= to_date(:start_date,
              'YYYY-MM-DD')
          and ( a.end_date is null
          or a.end_date >= to_date(:end_date,
            'YYYY-MM-DD') )
    ) pb
    on p.id = pb.id
      join (
      select p.id,
              count(r.id) as reprimands,
              count(s.id) as sentences
        from prisoner p
        inner join reprimand r
      on p.id = r.fk_prisoner
        inner join sentence s
      on p.id = s.fk_prisoner
        group by p.id
    ) pc
    on p.id = pc.id
      join (
      select p.id,
              listagg(s.crime,
                      ',') within group(
              order by s.id) as crime
        from prisoner p
        inner join sentence s
      on p.id = s.fk_prisoner
        where s.start_date <= to_date(:start_date,
              'YYYY-MM-DD')
          and ( s.real_end_date is null
          or s.real_end_date >= to_date(:end_date,
            'YYYY-MM-DD') )
        group by p.id
    ) ps
    on p.id = ps.id
    where r.issue_date >= to_date(:start_date,
              'YYYY-MM-DD')
      and r.issue_date <= to_date(:end_date,
            'YYYY-MM-DD')
      and ( :block_number is null
        or pb.block_number = :block_number )
      and ( :event_type is null
        or instr(
      r.reason,
      :event_type
    ) > 0 )
      and ( :sentence_count is null
        or pc.sentences = :sentence_count )
      and ( :reprimand_count is null
        or pc.reprimands = :reprimand_count )
      and ( :crime is null
        or instr(
      ps.crime,
      :crime
    ) > 0 )
      and ( :is_in_solitary is null
        or pb.is_solitary = :is_in_solitary )
    `,
    {
      start_date: "2024-01-01",
      end_date: "2024-01-07",
      block_number: null,
      event_type: "Wandalizm",
      sentence_count: null,
      reprimand_count: null,
      crime: null,
      is_in_solitary: null,
    }
  );
}
