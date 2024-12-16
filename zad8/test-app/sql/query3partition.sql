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
  from reprimand_clone r
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
    where to_char(
         a.start_date,
         'YYYY-MM-DD'
      ) <= :start_date
      and ( a.end_date is null
       or to_char(
      a.end_date,
      'YYYY-MM-DD'
   ) >= :end_date )
) pb
on p.id = pb.id
  join (
   select min(p.id) as id,
          count(r.id) as reprimands,
          count(s.id) as sentences
     from prisoner p
    inner join reprimand_clone r
   on p.id = r.fk_prisoner
    inner join sentence s
   on p.id = s.fk_prisoner
    group by p.pesel
) pc
on p.id = pc.id
  join (
   select min(p.id) as id,
          listagg(s.crime,
                  ',') within group(
           order by dbms_random.value) as crime
     from prisoner p
    inner join sentence s
   on p.id = s.fk_prisoner
    where to_char(
         s.start_date,
         'YYYY-MM-DD'
      ) <= :start_date
      and ( s.real_end_date is null
       or to_char(
      s.real_end_date,
      'YYYY-MM-DD'
   ) >= :end_date )
    group by p.pesel
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
    or pb.is_solitary = :is_in_solitary );
