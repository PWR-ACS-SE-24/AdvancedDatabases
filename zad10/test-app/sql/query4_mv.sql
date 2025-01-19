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
  from (
   select /*+ INDEX(query4_mv query4_mv_block_number_idx) INDEX(query4_mv query4_mv_sex_idx) */ height
     from query4_mv
    where ( :block_number is null
       or block_number = :block_number )
      and ( :sex is null
       or sex = :sex )
)
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
  from (
   select /*+ INDEX(query4_mv query4_mv_block_number_idx) INDEX(query4_mv query4_mv_sex_idx) */ weight
     from query4_mv
    where ( :block_number is null
       or block_number = :block_number )
      and ( :sex is null
       or sex = :sex )
)
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
  from (
   select /*+ INDEX(query4_mv query4_mv_block_number_idx) INDEX(query4_mv query4_mv_sex_idx) */ sentencenumber
     from query4_mv
    where ( :block_number is null
       or block_number = :block_number )
      and ( :sex is null
       or sex = :sex )
)
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
  from (
   select /*+ INDEX(query4_mv query4_mv_block_number_idx) INDEX(query4_mv query4_mv_sex_idx) */ reprimandnumber
     from query4_mv
    where ( :block_number is null
       or block_number = :block_number )
      and ( :sex is null
       or sex = :sex )
)
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
  from (
   select /*+ INDEX(query4_mv query4_mv_block_number_idx) INDEX(query4_mv query4_mv_sex_idx) */ accommodationnumber
     from query4_mv
    where ( :block_number is null
       or block_number = :block_number )
      and ( :sex is null
       or sex = :sex )
);