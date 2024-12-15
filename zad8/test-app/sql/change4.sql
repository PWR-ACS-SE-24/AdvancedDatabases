insert into reprimand (
   fk_guard,
   fk_prisoner,
   reason,
   issue_date
)
   select :guard_id as fk_guard,
          p.id as fk_prisoner,
          :reason as reason,
          cast(to_timestamp(:event_time,
                    'YYYY-MM-DD HH24:MI:SS') as date) as issue_date
     from prisoner p
    inner join accommodation a
   on p.id = a.fk_prisoner
    inner join cell c
   on a.fk_cell = c.id
    inner join prison_block pb
   on c.fk_block = pb.id
    where pb.block_number = :block_number
      and a.start_date <= to_timestamp(:event_time,
             'YYYY-MM-DD HH24:MI:SS')
      and ( a.end_date is null
       or a.end_date >= to_timestamp(:event_time,
             'YYYY-MM-DD HH24:MI:SS') )
      and c.is_solitary = 0;
