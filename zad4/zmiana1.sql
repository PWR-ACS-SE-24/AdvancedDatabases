-- Zwolnienie wszystkich strażników ze stażem mniejszym niż `experience_months` miesięcy, którzy nie mają zaplanowanych patroli w przyszłości oraz patrolowali blok `block_number` w określonym przedziale czasowym (`start_time` - `end_time`).

-- update guard
--    set
--    dismissal_date = to_date(:now,
--         'YYYY-MM-DD')
select *
  from guard
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
);
