-- Przeniesienie więźniów, którzy w przedziale czasowym (`start_date` - `end_date`) dostali reprymendę zawierającą w treści `event_type` do wolnej izolatki w bloku `block_id` z obecnego zakwaterowania. Jeżeli wolnych izolatek nie ma, to więźniowie pozostają w swoich celach.

-- create index idx_reprimand_reason on
--    reprimand (
--       reason
--    )
--       indextype is ctxsys.context;

-- insert into accommodation (
--    fk_cell,
--    fk_prisoner,
--    start_date,
--    end_date
-- )
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
on p.n = c.n;
