-- Wyszukanie strażników, którzy mogą obsadzić patrol w danym przedziale czasowym (`start_time` - `end_time`). Kwerenda zwraca `proposal_count` propozycji strażników, którzy mogą patrolować blok dla każdej warty (patrol slot) w podanym przedziale czasowym. Można wybrać jedynie strażników, którzy posiadają lub nie posiadają oświadczenia o niepełnosprawności (`has_disability_class`). Strażnik musi mieć staż pracy większy niż `experience_months` miesięcy oraz musi nadal pracować w zakładzie karnym.

-- start_time = 2020-06-01 00:00:00
-- end_time = 2020-12-31 23:59:59
-- proposal_count = 5
-- has_disability_class = 0
-- experience_months = 4
with available_guards as (
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
)
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
               from available_guards ag
              where ag.patrol_slot_id = ps.id
              order by dbms_random.value
              fetch first :proposal_count rows only
          ) g
       ) as guards
  from patrol_slot ps
 where ps.start_time >= to_timestamp(:start_time,
                'YYYY-MM-DD HH24:MI:SS')
   and ps.end_time <= to_timestamp(:end_time,
             'YYYY-MM-DD HH24:MI:SS');
