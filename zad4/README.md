# Zaawansowane systemy baz danych (ZSBD)

<div align="center">
Zespół B5 (baza danych dla więzienia): <br/> <b>Tomasz Chojnacki (260365), Kamila Iwańska (253027), Jakub Zehner (260285)</b>
</div>

## Zadanie 4 - Workload

### Zapytanie 1

Wyszukanie strażników, którzy mogą obsadzić patrol w danym przedziale czasowym (`start_time` - `end_time`). Kwerenda zwraca `proposal_count` propozycji strażników, którzy mogą patrolować blok dla każdej warty (patrol slot) w podanym przedziale czasowym. Można wybrać jedynie strażników, którzy posiadają lub nie posiadają oświadczenia o niepełnosprawności (`has_disability_class`). Strażnik musi mieć staż pracy większy niż `experience_months` miesięcy oraz musi nadal pracować w zakładzie karnym.

```sql
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
```

### Zapytanie 2

Liczby więźniów o danych cechach z podziałem na bloki, w których przebywają. Więźniów można filtrować według następujących parametrów:

- wiek więźnia pomiędzy `min_age` a `max_age`,
- płeć więźnia (`sex`),
- wzrost więźnia pomiędzy `min_height_m` a `max_height_m`,
- waga więźnia pomiędzy `min_weight_kg` a `max_weight_kg`,
- liczba wyroków więźnia pomiędzy `min_sentences` a `max_sentences`,
- skazanie za konkretne przestępstwo (`crime`),
- liczba reprymend więźnia pomiędzy `min_reprimands` a `max_reprimands`,
- przebywanie w więzieniu od `min_stay_months` do `max_stay_months` miesięcy,
- zwalnianie z więzienia w ciągu od `min_release_months` do `max_release_months` miesięcy,
- przebywanie w izolatce lub nie (`is_in_solitary`).

```sql
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
```

### Zapytanie 3

Wyszukanie wydarzeń związanych z więźniami w danym bloku `block_number`, które miały miejsce w określonym przedziale czasowym (`start_date` - `end_date`). Wyniki mogą być filtrowane według typu wydarzenia `event_type`, np. ucieczka, bójka. Można ograniczyć wyniki do wydarzeń dotyczących więźniów o określonych cechach: liczba wyroków (`sentence_count`), przestępstwo (`crime`), liczba reprymend (`reprimand_count`), czy obecność w izolatce (`is_in_solitary`). Zwracana jest lista wydarzeń wraz z datą, danymi więźnia i strażnika oraz treścią reprymendy.

```sql
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
```

### Zapytanie 4 (dodatkowe)

Zwrócenie raportu dotyczącego minimalnej, maksymalnej i średniej dla wzrostu, wagi, liczby wyroków, liczby reprymend, liczby przekwaterowań dla więźniów w danym bloku `block_number`. Można filtrować wyniki według płci więźniów (`sex`).

```sql
with prisoner_blocks as (
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
),prisoners_details as (
   select prisoner.id,
          min(prisoner.height_m) as height,
          min(prisoner.weight_kg) as weight,
          count(distinct sentence.id) as sentencenumber,
          count(distinct reprimand.id) as reprimandnumber,
          count(distinct accommodation.id) as accommodationnumber
     from prisoner
     left join sentence
   on prisoner.id = sentence.fk_prisoner
     left join reprimand
   on prisoner.id = reprimand.fk_prisoner
     left join accommodation
   on prisoner.id = accommodation.fk_prisoner
     left join prisoner_blocks
   on prisoner.id = prisoner_blocks.id
    where ( :block_number is null
       or prisoner_blocks.block_number = :block_number )
      and ( :sex is null
       or prisoner.sex = :sex )
    group by prisoner.id
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
```

### Zmiana danych 1

Zwolnienie wszystkich strażników ze stażem mniejszym niż `experience_months` miesięcy, którzy nie mają zaplanowanych patroli w przyszłości oraz patrolowali blok `block_number` w określonym przedziale czasowym (`start_time` - `end_time`).

```sql
update guard
   set
   dismissal_date = to_date(:now,
        'YYYY-MM-DD')
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
```

### Zmiana danych 2

Wygenerowanie wart (patrol slot) w przedziale czasowym (`start_time` - `end_time`) z określonym czasem trwania patrolu w minutach `slot_duration`.

Zauważono, że na tego typu zapytaniu będzie trudno dokonać optymalizacji, ponieważ nie używa ono żadnych danych z tabel.

```sql
insert into patrol_slot (start_time, end_time)
select to_timestamp(:start_time,
             'YYYY-MM-DD HH24:MI:SS') + ( interval '1' minute * :slot_duration * level ) as start_time,
       to_timestamp(:start_time,
                    'YYYY-MM-DD HH24:MI:SS') + ( interval '1' minute * :slot_duration * ( level + 1 ) - interval '1' second )
                    as end_time
  from dual
connect by
   level <= trunc(extract(day from(to_timestamp(:end_time,
        'YYYY-MM-DD HH24:MI:SS') - to_timestamp(:start_time,
        'YYYY-MM-DD HH24:MI:SS')) * 24 * 60) / :slot_duration);
```

### Zmiana danych 3

Umieszczenie więźniów, którzy w przedziale czasowym (`start_date` - `end_date`) dostali reprymendę zawierającą w treści `event_type` do wolnej izolatki w bloku `block_id` z obecnego zakwaterowania. Jeżeli wolnych izolatek nie ma, to więźniowie pozostają w swoich celach.


```sql
insert into accommodation (
   fk_cell,
   fk_prisoner,
   start_date,
   end_date
)
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
          or contains(
         r.reason,
         :event_type,
         1
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
```

### Zmiana danych 4

Wystawienie reprymendy o treści `reason` przez strażnika `guard_id` wszystkim więźniom niebędącym w izolatce i znajdującym się w bloku `block_number` w momencie `event_time`.

```sql
insert into reprimand (fk_guard, fk_prisoner, reason, issue_date)
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
```
