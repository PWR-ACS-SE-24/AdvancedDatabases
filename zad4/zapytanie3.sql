-- Wyszukanie wydarzeń związanych z więźniami w danym bloku `block_number`, które miały miejsce w określonym przedziale czasowym (`start_date` - `end_date`). Wyniki mogą być filtrowane według typu wydarzenia `event_type`, np. ucieczka, bójka. Można ograniczyć wyniki do wydarzeń dotyczących więźniów o określonych cechach: liczba wyroków (`sentence_count`), przestępstwo (`crime`), liczba reprymend (`reprimand_count`), czy obecność w izolatce (`is_in_solitary`). Zwracana jest lista wydarzeń wraz z datą, danymi więźnia i strażnika oraz treścią reprymendy.

with prisoner_blocks as (
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
),prisoner_counts as (
   select p.id,
          count(r.id) as reprimands,
          count(s.id) as sentences
     from prisoner p
    inner join reprimand r
   on p.id = r.fk_prisoner
    inner join sentence s
   on p.id = s.fk_prisoner
    group by p.id
),prisoner_sentences as (
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
)
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
  join prisoner_blocks pb
on p.id = pb.id
  join prisoner_counts pc
on p.id = pc.id
  join prisoner_sentences ps
on p.id = ps.id
 where r.issue_date >= to_date(:start_date,
           'YYYY-MM-DD')
   and r.issue_date <= to_date(:end_date,
        'YYYY-MM-DD')
   and ( :block_number is null
    or pb.block_number = :block_number )
   and ( :event_type is null
    or contains(
   r.reason,
   :event_type,
   1
) > 0 )
   and ( :sentence_count is null
    or pc.sentences = :sentence_count )
   and ( :reprimand_count is null
    or pc.reprimands = :reprimand_count )
   and ( :crime is null
    or contains(
   ps.crime,
   :crime,
   1
) > 0 )
   and ( :is_in_solitary is null
    or pb.is_solitary = :is_in_solitary );
