-- Indeksy b-drzewo dla danych czasowych

create index patrol_slot_start_time_idx on
   patrol_slot (
      start_time
   );
create index patrol_slot_end_time_idx on
   patrol_slot (
      end_time
   );
create index sentence_start_date_idx on
   sentence (
      start_date
   );
create index sentence_real_end_date_idx on
   sentence (
      real_end_date
   );
create index accommodation_start_date_idx on
   accommodation (
      start_date
   );
create index accommodation_end_date_idx on
   accommodation (
      end_date
   );

drop index patrol_slot_start_time_idx;
drop index patrol_slot_end_time_idx;
drop index sentence_start_date_idx;
drop index sentence_real_end_date_idx;
drop index accommodation_start_date_idx;
drop index accommodation_end_date_idx;

-- Indeks bitmapowy dla rodzaju celi 

create bitmap index cell_is_solitary_idx on
   cell (
      is_solitary
   );

drop index cell_is_solitary_idx;

-- Indeksy funkcyjne dla danych czasowych

create index reprimand_issue_date_to_char_idx on
   reprimand ( to_char(
      issue_date,
      'YYYY-MM-DD'
   ) );
create index sentence_start_date_to_char_idx on
   sentence ( to_char(
      start_date,
      'YYYY-MM-DD'
   ) );
create index sentence_real_end_date_to_char_idx on
   sentence ( to_char(
      real_end_date,
      'YYYY-MM-DD'
   ) );
create index accommodation_start_date_to_char_idx on
   accommodation ( to_char(
      start_date,
      'YYYY-MM-DD'
   ) );
create index accommodation_end_date_to_char_idx on
   accommodation ( to_char(
      end_date,
      'YYYY-MM-DD'
   ) );
create index patrol_slot_start_time_to_char_idx on
   patrol_slot ( to_char(
      start_time,
      'YYYY-MM-DD HH24:MI:SS'
   ) );
create index patrol_slot_end_time_to_char_idx on
   patrol_slot ( to_char(
      end_time,
      'YYYY-MM-DD HH24:MI:SS'
   ) );


drop index reprimand_issue_date_to_char_idx;
drop index sentence_start_date_to_char_idx;
drop index sentence_real_end_date_to_char_idx;
drop index accommodation_start_date_to_char_idx;
drop index accommodation_end_date_to_char_idx;
drop index patrol_slot_start_time_to_char_idx;
drop index patrol_slot_end_time_to_char_idx;

-- Indeksy złożone (b-drzewo) dla odwołań do wielu kolumn

create index cell_fk_block_is_solitary_idx on
   cell (
      fk_block,
      is_solitary
   );
create index patrol_fk_guard_fk_block_idx on
   patrol (
      fk_guard,
      fk_block
   );

drop index cell_fk_block_is_solitary_idx;
drop index patrol_fk_guard_fk_block_idx;

-- Eksperyment 2
create materialized view query4_mv
   build immediate
   refresh
         complete
         on demand
disable query rewrite as
   (
      select p.id,
             pb.block_number,
             p.sex,
             min(p.height_m) as height,
             min(p.weight_kg) as weight,
             count(distinct s.id) as sentencenumber,
             count(distinct r.id) as reprimandnumber,
             count(distinct a.id) as accommodationnumber
        from prisoner p
        left join sentence s
      on p.id = s.fk_prisoner
        left join reprimand r
      on p.id = r.fk_prisoner
        left join accommodation a
      on p.id = a.fk_prisoner
        left join (
         select p.id,
                pb.block_number
           from prison_block pb
          inner join cell c
         on pb.id = c.fk_block
          inner join accommodation a
         on c.id = a.fk_cell
          inner join prisoner p
         on a.fk_prisoner = p.id
          where a.start_date <= to_date('2024-10-20','YYYY-MM-DD')
            and ( a.end_date is null
             or a.end_date >= to_date('2024-10-20','YYYY-MM-DD') )
      ) pb
      on p.id = pb.id
       group by p.id,
                pb.block_number,
                p.sex
   );

drop materialized view query4_mv;

-- select 'Height' as "Name",
--        min(height) as "Min",
--        max(height) as "Max",
--        round(
--           avg(height),
--           2
--        ) as "Average",
--        round(
--           stddev_pop(height),
--           2
--        ) as "Standard deviation",
--        round(
--           var_pop(height),
--           2
--        ) as "Variance"
--   from (
--    select height
--      from query4_mv
--     where ( :block_number is null
--        or block_number = :block_number )
--       and ( :sex is null
--        or sex = :sex )
-- )
-- union
-- select 'Weight' as "Name",
--        min(weight) as "Min",
--        max(weight) as "Max",
--        round(
--           avg(weight),
--           2
--        ) as "Average",
--        round(
--           stddev_pop(weight),
--           2
--        ) as "Standard deviation",
--        round(
--           var_pop(weight),
--           2
--        ) as "Variance"
--   from (
--    select weight
--      from query4_mv
--     where ( :block_number is null
--        or block_number = :block_number )
--       and ( :sex is null
--        or sex = :sex )
-- )
-- union
-- select 'Sentences' as "Name",
--        min(sentencenumber) as "Min",
--        max(sentencenumber) as "Max",
--        round(
--           avg(sentencenumber),
--           2
--        ) as "Average",
--        round(
--           stddev_pop(sentencenumber),
--           2
--        ) as "Standard deviation",
--        round(
--           var_pop(sentencenumber),
--           2
--        ) as "Variance"
--   from (
--    select sentencenumber
--      from query4_mv
--     where ( :block_number is null
--        or block_number = :block_number )
--       and ( :sex is null
--        or sex = :sex )
-- )
-- union
-- select 'Reprimands' as "Name",
--        min(reprimandnumber) as "Min",
--        max(reprimandnumber) as "Max",
--        round(
--           avg(reprimandnumber),
--           2
--        ) as "Average",
--        round(
--           stddev_pop(reprimandnumber),
--           2
--        ) as "Standard deviation",
--        round(
--           var_pop(reprimandnumber),
--           2
--        ) as "Variance"
--   from (
--    select reprimandnumber
--      from query4_mv
--     where ( :block_number is null
--        or block_number = :block_number )
--       and ( :sex is null
--        or sex = :sex )
-- )
-- union
-- select 'Accomodations' as "Name",
--        min(accommodationnumber) as "Min",
--        max(accommodationnumber) as "Max",
--        round(
--           avg(accommodationnumber),
--           2
--        ) as "Average",
--        round(
--           stddev_pop(accommodationnumber),
--           2
--        ) as "Standard deviation",
--        round(
--           var_pop(accommodationnumber),
--           2
--        ) as "Variance"
--   from (
--    select accommodationnumber
--      from query4_mv
--     where ( :block_number is null
--        or block_number = :block_number )
--       and ( :sex is null
--        or sex = :sex )
-- );
