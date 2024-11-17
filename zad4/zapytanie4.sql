-- Zwrócenie raportu dotyczącego "Min", "Max", średniej, odchylenia standardowego i wariancji dla wzrostu, wagi, liczby wyroków, liczby reprymend, liczby przekwaterowań dla więźniów w danym bloku `block_number`. Można filtrować wyniki według płci więźniów (`sex`).

with prisoners_details as (
   select p.id,
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
       where a.start_date <= to_date(:now,
           'YYYY-MM-DD')
         and ( a.end_date is null
          or a.end_date >= to_date(:now,
        'YYYY-MM-DD') )
   ) pb
   on p.id = pb.id
    where ( :block_number is null
       or pb.block_number = :block_number )
      and ( :sex is null
       or p.sex = :sex )
    group by p.id
)
select 'Height' as "Name",
       min(height) as "Min",
       max(height) as "Max",
       round(
          avg(height),
          2
       ) as "Average",
       round(
          stddev_pop(height),
          2
       ) as "Standard deviation",
       round(
          var_pop(height),
          2
       ) as "Variance"
  from prisoners_details
union
select 'Weight' as "Name",
       min(weight) as "Min",
       max(weight) as "Max",
       round(
          avg(weight),
          2
       ) as "Average",
       round(
          stddev_pop(weight),
          2
       ) as "Standard deviation",
       round(
          var_pop(weight),
          2
       ) as "Variance"
  from prisoners_details
union
select 'Sentences' as "Name",
       min(sentencenumber) as "Min",
       max(sentencenumber) as "Max",
       round(
          avg(sentencenumber),
          2
       ) as "Average",
       round(
          stddev_pop(sentencenumber),
          2
       ) as "Standard deviation",
       round(
          var_pop(sentencenumber),
          2
       ) as "Variance"
  from prisoners_details
union
select 'Reprimands' as "Name",
       min(reprimandnumber) as "Min",
       max(reprimandnumber) as "Max",
       round(
          avg(reprimandnumber),
          2
       ) as "Average",
       round(
          stddev_pop(reprimandnumber),
          2
       ) as "Standard deviation",
       round(
          var_pop(reprimandnumber),
          2
       ) as "Variance"
  from prisoners_details
union
select 'Accomodations' as "Name",
       min(accommodationnumber) as "Min",
       max(accommodationnumber) as "Max",
       round(
          avg(accommodationnumber),
          2
       ) as "Average",
       round(
          stddev_pop(accommodationnumber),
          2
       ) as "Standard deviation",
       round(
          var_pop(accommodationnumber),
          2
       ) as "Variance"
  from prisoners_details;
