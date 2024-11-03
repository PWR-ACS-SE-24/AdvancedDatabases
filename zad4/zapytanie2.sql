-- Liczby więźniów o danych cechach z podziałem na bloki, w których przebywają. Więźniów można filtrować według następujących parametrów:
-- - wiek więźnia pomiędzy `min_age` a `max_age`,
-- - płeć więźnia (`sex`),
-- - wzrost więźnia pomiędzy `min_height_m` a `max_height_m`,
-- - waga więźnia pomiędzy `min_weight_kg` a `max_weight_kg`,
-- - liczba wyroków więźnia pomiędzy `min_sentences` a `max_sentences`,
-- - skazanie za konkretne przestępstwo (`crime`),
-- - liczba reprymend więźnia pomiędzy `min_reprimands` a `max_reprimands`,
-- - przebywanie w więzieniu od `min_stay_months` do `max_stay_months` miesięcy,
-- - zwalnianie z więzienia w ciągu od `min_release_months` do `max_release_months` miesięcy,
-- - przebywanie w izolatce lub nie (`is_in_solitary`).

with prisoner_counts as (
   select p.id,
          count(r.id) as reprimands,
          count(s.id) as sentences
     from prisoner p
     left join reprimand r
   on p.id = r.fk_prisoner
     left join sentence s
   on p.id = s.fk_prisoner
    group by p.id
),prisoner_sentences as (
   select p.id,
          listagg(s.crime,
                  ', ') within group(
           order by s.id) as crime,
          min(s.start_date) as start_date,
          max(s.planned_end_date) as planned_end_date
     from prisoner p
     left join sentence s
   on p.id = s.fk_prisoner
    where s.start_date <= to_date(:now,
           'YYYY-MM-DD')
      and ( s.real_end_date is null
       or s.real_end_date >= to_date(:now,
        'YYYY-MM-DD') )
    group by p.id
)
select pb.block_number,
       count(p.id) as prisoners_count
  from prison_block pb
 inner join cell c
on pb.id = c.fk_block
 inner join accommodation a
on c.id = a.fk_cell
 inner join prisoner p
on a.fk_prisoner = p.id
 inner join prisoner_counts pc
on p.id = pc.id
 inner join prisoner_sentences ps
on p.id = ps.id
 where a.start_date <= to_date(:now,
           'YYYY-MM-DD')
   and ( a.end_date is null
    or a.end_date >= to_date(:now,
        'YYYY-MM-DD') )
   and ( :min_age is null
    or months_between(
   :now,
   p.birthday
) >= :min_age * 12 )
   and ( :max_age is null
    or months_between(
   :now,
   p.birthday
) <= :max_age * 12 )
   and ( :sex is null
    or p.sex = :sex )
   and ( :min_height_m is null
    or p.height_m >= :min_height_m )
   and ( :max_height_m is null
    or p.height_m <= :max_height_m )
   and ( :min_weight_kg is null
    or p.weight_kg >= :min_weight_kg )
   and ( :max_weight_kg is null
    or p.weight_kg <= :max_weight_kg )
   and ( :min_sentences is null
    or pc.sentences >= :min_sentences )
   and ( :max_sentences is null
    or pc.sentences <= :max_sentences )
   and ( :crime is null
    or contains(
   ps.crime,
   :crime,
   1
) > 0 )
   and ( :min_reprimands is null
    or pc.reprimands >= :min_reprimands )
   and ( :max_reprimands is null
    or pc.reprimands <= :max_reprimands )
   and ( :min_stay_months is null
    or months_between(
   :now,
   ps.start_date
) >= :min_stay_months )
   and ( :max_stay_months is null
    or months_between(
   :now,
   ps.start_date
) <= :max_stay_months )
   and ( :min_release_months is null
    or months_between(
   ps.planned_end_date,
   :now
) >= :min_release_months )
   and ( :max_release_months is null
    or months_between(
   ps.planned_end_date,
   :now
) <= :max_release_months )
   and ( :is_in_solitary is null
    or c.is_solitary = :is_in_solitary )
 group by pb.id,
          pb.block_number;
