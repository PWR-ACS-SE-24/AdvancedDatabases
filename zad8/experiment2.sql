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

-- Indeksy na materialized view:

create index query4_mv_block_number_idx on
   query4_mv (
      block_number
   );

create index query4_mv_sex_idx on
   query4_mv (
      sex
   );

drop index query4_mv_block_number_idx;
drop index query4_mv_sex_idx;