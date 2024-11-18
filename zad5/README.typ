#set page(flipped: true)
#set par(justify: true)
#let description(body) = block(
     fill: rgb("#eee"),
     inset: 8pt,
     stroke: (left: 4pt + blue),
     body
)
#let sql(body) = [
     #set raw(lang: "sql")
     #show raw: it => [
          #set text(font: "Liberation Mono", size: 6pt)
          #it
     ]
     #align(center, body)
]
#let plan(..children) = [
  #show raw: it => [
    #set text(font: "Liberation Mono", size: if children.pos().len() == 1 { 8pt } else { 4.5pt })
    #it
  ]
  #grid(
    columns: 2,
    align: (left, right),
    column-gutter: 24pt,
    ..children
  )
]

#align(center)[
  #text(size: 20pt, weight: "bold", )[Zaawansowane systemy baz danych (ZSBD)]

  Zespół B5 (baza danych dla więzienia): \
  *Tomasz Chojnacki (260365), Kamila Iwańska (253027), Jakub Zehner (260285)*
]

= Zadanie 5 - Plany zapytań

== Wstęp

W planach zapytań z etapu 4, zgodnie z uwagami, pozbyliśmy się klauzul `WITH`, zamiast tego wklejając treść podzapytania bezpośrednio w główne zapytanie.

We wszystkich poniższych przykładach plan po lewej stronie przedstawia pierwotną wersję planu uzyskaną poprzez dopisanie `EXPLAIN PLAN FOR` przed niezmodyfikowanymi wersjami zapytań z etapu 4, natomiast plan po prawej stronie przedstawia finalną wersję planu uzyskaną po celowych pogorszeniach zapytań, chyba że zaznaczono inaczej.

== Zapytanie 1

#description[Wyszukanie strażników, którzy mogą obsadzić patrol w danym przedziale czasowym (`start_time` - `end_time`). Kwerenda zwraca `proposal_count` propozycji strażników, którzy mogą patrolować blok dla każdej warty (patrol slot) w podanym przedziale czasowym. Można wybrać jedynie strażników, którzy posiadają lub nie posiadają oświadczenia o niepełnosprawności (`has_disability_class`). Strażnik musi mieć staż pracy większy niż `experience_months` miesięcy oraz musi nadal pracować w zakładzie karnym.]

#sql[
```
SELECT ps.start_time,
       ps.end_time,
  (SELECT listagg(g.first_name || ' ' || g.last_name || ' (' || g.id || ')', ', ') within group(ORDER BY dbms_random.value)
   FROM
     (SELECT id,
             first_name,
             last_name
      FROM
        (SELECT g.id,
                g.first_name,
                g.last_name,
                ps.id AS patrol_slot_id
         FROM guard g
         CROSS JOIN patrol_slot ps
         LEFT JOIN patrol p ON p.fk_guard = g.id
         AND p.fk_patrol_slot = ps.id
         WHERE p.id IS NULL
           AND g.employment_date <= ps.start_time
           AND (g.dismissal_date IS NULL
                OR g.dismissal_date >= ps.end_time)
           AND (:has_disability_class IS NULL
                OR g.has_disability_class = :has_disability_class)
           AND (:experience_months IS NULL
                OR months_between(ps.start_time, g.employment_date) >= :experience_months)) ag
      WHERE ag.patrol_slot_id = ps.id
      ORDER BY dbms_random.value FETCH FIRST :proposal_count ROWS ONLY) g) AS guards
FROM patrol_slot ps
WHERE ps.start_time >= to_timestamp(:start_time, 'YYYY-MM-DD HH24:MI:SS')
  AND ps.end_time <= to_timestamp(:end_time, 'YYYY-MM-DD HH24:MI:SS');
```
]

Opis naszej kwerendy nie specyfikował w jakim uporządkowaniu należy zwrócić listę strażników. \ Zmieniliśmy jej kolejność z `ORDER BY g.id` na `ORDER BY dbms_random.value`, zwiększając koszt z 1594 do 1663.

#plan([
```
Plan hash value: 3939988103
 
-------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                 | Name                        | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                          |                             |    68 |  1836 |  1594   (1)| 00:00:01 |
|   1 |  SORT GROUP BY                            |                             |     1 |   271 |            |          |
|   2 |   VIEW                                    |                             |     5 |  1355 |    45   (0)| 00:00:01 |
|   3 |    SORT ORDER BY                          |                             |     5 |   420 |    45   (0)| 00:00:01 |
|*  4 |     COUNT STOPKEY                         |                             |       |       |            |          |
|*  5 |      FILTER                               |                             |       |       |            |          |
|*  6 |       HASH JOIN OUTER                     |                             |     5 |   420 |    45   (0)| 00:00:01 |
|   7 |        NESTED LOOPS                       |                             |     7 |   476 |    29   (0)| 00:00:01 |
|   8 |         TABLE ACCESS BY INDEX ROWID       | PATROL_SLOT                 |     1 |    27 |     2   (0)| 00:00:01 |
|*  9 |          INDEX UNIQUE SCAN                | SYS_C008259                 |     1 |       |     1   (0)| 00:00:01 |
|* 10 |         TABLE ACCESS FULL                 | GUARD                       |     7 |   287 |    27   (0)| 00:00:01 |
|  11 |        TABLE ACCESS BY INDEX ROWID BATCHED| PATROL                      |  2368 | 37888 |    16   (0)| 00:00:01 |
|* 12 |         INDEX RANGE SCAN                  | PATROL_FK_PATROL_SLOT_INDEX |  2368 |       |     7   (0)| 00:00:01 |
|* 13 |  TABLE ACCESS FULL                        | PATROL_SLOT                 |    68 |  1836 |    34   (3)| 00:00:01 |
-------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   4 - filter(ROWNUM<=:PROPOSAL_COUNT)
   5 - filter("P"."ID" IS NULL)
   6 - access("P"."FK_GUARD"(+)="G"."ID" AND "P"."FK_PATROL_SLOT"(+)="PS"."ID")
   9 - access("PS"."ID"=:B1)
  10 - filter(("G"."HAS_DISABILITY_CLASS"=:HAS_DISABILITY_CLASS OR :HAS_DISABILITY_CLASS IS NULL) AND 
              "PS"."START_TIME">=INTERNAL_FUNCTION("G"."EMPLOYMENT_DATE") AND ("G"."DISMISSAL_DATE" IS NULL OR 
              "PS"."END_TIME"<=INTERNAL_FUNCTION("G"."DISMISSAL_DATE")) AND (:EXPERIENCE_MONTHS IS NULL OR 
              MONTHS_BETWEEN(INTERNAL_FUNCTION("PS"."START_TIME"),INTERNAL_FUNCTION("G"."EMPLOYMENT_DATE"))>=:EXPERIENCE_MONTHS
              ))
  12 - access("P"."FK_PATROL_SLOT"(+)=:B1)
  13 - filter("PS"."START_TIME">=TO_TIMESTAMP(:START_TIME,'YYYY-MM-DD HH24:MI:SS') AND 
              "PS"."END_TIME"<=TO_TIMESTAMP(:END_TIME,'YYYY-MM-DD HH24:MI:SS'))
```
], [
```
Plan hash value: 3284811219
 
--------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                  | Name                        | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                           |                             |    68 |  1836 |  1663   (5)| 00:00:01 |
|   1 |  SORT GROUP BY                             |                             |     1 |   271 |            |          |
|   2 |   VIEW                                     |                             |     5 |  1355 |    47   (5)| 00:00:01 |
|   3 |    SORT ORDER BY                           |                             |     5 |  1485 |    47   (5)| 00:00:01 |
|*  4 |     VIEW                                   |                             |     5 |  1485 |    46   (3)| 00:00:01 |
|*  5 |      WINDOW SORT PUSHED RANK               |                             |     5 |   420 |    46   (3)| 00:00:01 |
|*  6 |       FILTER                               |                             |       |       |            |          |
|*  7 |        HASH JOIN OUTER                     |                             |     5 |   420 |    45   (0)| 00:00:01 |
|   8 |         NESTED LOOPS                       |                             |     7 |   476 |    29   (0)| 00:00:01 |
|   9 |          TABLE ACCESS BY INDEX ROWID       | PATROL_SLOT                 |     1 |    27 |     2   (0)| 00:00:01 |
|* 10 |           INDEX UNIQUE SCAN                | SYS_C008259                 |     1 |       |     1   (0)| 00:00:01 |
|* 11 |          TABLE ACCESS FULL                 | GUARD                       |     7 |   287 |    27   (0)| 00:00:01 |
|  12 |         TABLE ACCESS BY INDEX ROWID BATCHED| PATROL                      |  2368 | 37888 |    16   (0)| 00:00:01 |
|* 13 |          INDEX RANGE SCAN                  | PATROL_FK_PATROL_SLOT_INDEX |  2368 |       |     7   (0)| 00:00:01 |
|* 14 |  TABLE ACCESS FULL                         | PATROL_SLOT                 |    68 |  1836 |    34   (3)| 00:00:01 |
--------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   4 - filter("from$_subquery$_008"."rowlimit_$$_rownumber"<=:PROPOSAL_COUNT)
   5 - filter(ROW_NUMBER() OVER ( ORDER BY "DBMS_RANDOM"."VALUE"())<=:PROPOSAL_COUNT)
   6 - filter("P"."ID" IS NULL)
   7 - access("P"."FK_GUARD"(+)="G"."ID" AND "P"."FK_PATROL_SLOT"(+)="PS"."ID")
  10 - access("PS"."ID"=:B1)
  11 - filter(("G"."HAS_DISABILITY_CLASS"=:HAS_DISABILITY_CLASS OR :HAS_DISABILITY_CLASS IS NULL) AND 
              "PS"."START_TIME">=INTERNAL_FUNCTION("G"."EMPLOYMENT_DATE") AND ("G"."DISMISSAL_DATE" IS NULL OR 
              "PS"."END_TIME"<=INTERNAL_FUNCTION("G"."DISMISSAL_DATE")) AND (:EXPERIENCE_MONTHS IS NULL OR 
              MONTHS_BETWEEN(INTERNAL_FUNCTION("PS"."START_TIME"),INTERNAL_FUNCTION("G"."EMPLOYMENT_DATE"))>=:EXPERIENCE_MONTHS)
              )
  13 - access("P"."FK_PATROL_SLOT"(+)=:B1)
  14 - filter("PS"."START_TIME">=TO_TIMESTAMP(:START_TIME,'YYYY-MM-DD HH24:MI:SS') AND 
              "PS"."END_TIME"<=TO_TIMESTAMP(:END_TIME,'YYYY-MM-DD HH24:MI:SS'))
```     
])

#pagebreak()

== Zapytanie 2

#description[
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
]

#sql[
```

SELECT pb.block_number,
       count(p.id) AS prisoners_count
FROM prison_block pb
INNER JOIN cell c ON pb.id = c.fk_block
INNER JOIN accommodation a ON c.id = a.fk_cell
INNER JOIN prisoner p ON a.fk_prisoner = p.id
INNER JOIN
  (SELECT min(p.id) AS id,
          count(r.id) AS reprimands,
          count(s.id) AS sentences
   FROM prisoner p
   LEFT JOIN reprimand r ON p.id = r.fk_prisoner
   LEFT JOIN sentence s ON p.id = s.fk_prisoner
   GROUP BY p.pesel) pc ON p.id = pc.id
INNER JOIN
  (SELECT min(p.id) AS id,
          listagg(s.crime, ', ') within group(
                                              ORDER BY s.id) AS crime,
                                        min(s.start_date) AS start_date,
                                        max(s.planned_end_date) AS planned_end_date
   FROM prisoner p
   LEFT JOIN sentence s ON p.id = s.fk_prisoner
   WHERE s.start_date <= to_date(:now, 'YYYY-MM-DD')
     AND (s.real_end_date IS NULL
          OR s.real_end_date >= to_date(:now, 'YYYY-MM-DD'))
   GROUP BY p.pesel) ps ON p.id = ps.id
WHERE a.start_date <= to_date(:now, 'YYYY-MM-DD')
  AND (a.end_date IS NULL
       OR a.end_date >= to_date(:now, 'YYYY-MM-DD'))
  AND (:min_age IS NULL
       OR months_between(:now, p.birthday) >= :min_age * 12)
  AND (:max_age IS NULL
       OR months_between(:now, p.birthday) <= :max_age * 12)
  AND (:sex IS NULL
       OR p.sex = :sex)
  AND (:min_height_m IS NULL
       OR p.height_m >= :min_height_m)
  AND (:max_height_m IS NULL
       OR p.height_m <= :max_height_m)
  AND (:min_weight_kg IS NULL
       OR p.weight_kg >= :min_weight_kg)
  AND (:max_weight_kg IS NULL
       OR p.weight_kg <= :max_weight_kg)
  AND (:min_sentences IS NULL
       OR pc.sentences >= :min_sentences)
  AND (:max_sentences IS NULL
       OR pc.sentences <= :max_sentences)
  AND (:crime IS NULL
       OR instr(ps.crime, :crime) > 0)
  AND (:min_reprimands IS NULL
       OR pc.reprimands >= :min_reprimands)
  AND (:max_reprimands IS NULL
       OR pc.reprimands <= :max_reprimands)
  AND (:min_stay_months IS NULL
       OR months_between(:now, ps.start_date) >= :min_stay_months)
  AND (:max_stay_months IS NULL
       OR months_between(:now, ps.start_date) <= :max_stay_months)
  AND (:min_release_months IS NULL
       OR months_between(ps.planned_end_date, :now) >= :min_release_months)
  AND (:max_release_months IS NULL
       OR months_between(ps.planned_end_date, :now) <= :max_release_months)
  AND (:is_in_solitary IS NULL
       OR c.is_solitary = :is_in_solitary)
GROUP BY pb.id,
         pb.block_number;
```
]

W drodze eksperymentacji zastąpiliśmy klauzule `LEFT JOIN` na `INNER JOIN` tam, gdzie mieliśmy pewność, że w prawej tabeli zawsze znajdzie się co najmniej jeden rekord. Miało to miejsce np. pomiędzy zakwaterowaniem a więźniem (każde zakwaterowanie ma dokładnie jednego więźnia), czy pomiędzy blokiem a celą (każdy blok ma co najmniej jedną celę). W wyniku zmian, koszt wzrósł z 5416 do 7139.

Następnie, zauważając, że w wielu miejscach grupujemy po kluczu głównym więźnia, zastąpiliśmy te grupowania PESELem, który również jest unikalny i jednoznacznie identyfikuje więźnia, ale nie ma na sobie indeksu. W efekcie, koszt wzrósł z 7139 do 8522.

#pagebreak()

#plan([
```
Plan hash value: 3568620633
 
-----------------------------------------------------------------------------------------------------
| Id  | Operation                           | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |               |     1 |   101 |  5416   (1)| 00:00:01 |
|   1 |  HASH GROUP BY                      |               |     1 |   101 |  5416   (1)| 00:00:01 |
|   2 |   NESTED LOOPS                      |               |     1 |   101 |  5415   (1)| 00:00:01 |
|   3 |    NESTED LOOPS                     |               |     1 |   101 |  5415   (1)| 00:00:01 |
|   4 |     NESTED LOOPS                    |               |     1 |    94 |  5414   (1)| 00:00:01 |
|*  5 |      HASH JOIN                      |               |     1 |    83 |  5413   (1)| 00:00:01 |
|*  6 |       FILTER                        |               |       |       |            |          |
|   7 |        NESTED LOOPS OUTER           |               |     1 |    57 |  3649   (1)| 00:00:01 |
|   8 |         NESTED LOOPS                |               |     1 |    29 |  1218   (1)| 00:00:01 |
|   9 |          VIEW                       |               |     1 |     5 |  1217   (1)| 00:00:01 |
|* 10 |           FILTER                    |               |       |       |            |          |
|  11 |            SORT GROUP BY            |               |     1 |    72 |  1217   (1)| 00:00:01 |
|* 12 |             TABLE ACCESS FULL       | SENTENCE      |  8470 |   595K|  1216   (1)| 00:00:01 |
|* 13 |          TABLE ACCESS BY INDEX ROWID| PRISONER      |     1 |    24 |     1   (0)| 00:00:01 |
|* 14 |           INDEX UNIQUE SCAN         | SYS_C008234   |     1 |       |     0   (0)| 00:00:01 |
|  15 |         VIEW PUSHED PREDICATE       |               |     1 |    28 |  2432   (1)| 00:00:01 |
|  16 |          SORT GROUP BY              |               |     1 |    25 |  2432   (1)| 00:00:01 |
|* 17 |           HASH JOIN OUTER           |               |     1 |    25 |  2432   (1)| 00:00:01 |
|  18 |            NESTED LOOPS OUTER       |               |     1 |    15 |  1210   (1)| 00:00:01 |
|* 19 |             INDEX UNIQUE SCAN       | SYS_C008234   |     1 |     5 |     1   (0)| 00:00:01 |
|* 20 |             TABLE ACCESS FULL       | SENTENCE      |     1 |    10 |  1209   (1)| 00:00:01 |
|* 21 |            TABLE ACCESS FULL        | REPRIMAND     |     2 |    20 |  1221   (1)| 00:00:01 |
|* 22 |       TABLE ACCESS FULL             | ACCOMMODATION |  9279 |   235K|  1764   (2)| 00:00:01 |
|* 23 |      TABLE ACCESS BY INDEX ROWID    | CELL          |     1 |    11 |     1   (0)| 00:00:01 |
|* 24 |       INDEX UNIQUE SCAN             | SYS_C008269   |     1 |       |     0   (0)| 00:00:01 |
|* 25 |     INDEX UNIQUE SCAN               | SYS_C008241   |     1 |       |     0   (0)| 00:00:01 |
|  26 |    TABLE ACCESS BY INDEX ROWID      | PRISON_BLOCK  |     1 |     7 |     1   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   5 - access("A"."FK_PRISONER"="P"."ID")
   6 - filter((:MIN_SENTENCES IS NULL OR "PC"."SENTENCES">=TO_NUMBER(:MIN_SENTENCES)) AND 
              (:MAX_SENTENCES IS NULL OR "PC"."SENTENCES"<=TO_NUMBER(:MAX_SENTENCES)) AND (:MIN_REPRIMANDS 
              IS NULL OR "PC"."REPRIMANDS">=TO_NUMBER(:MIN_REPRIMANDS)) AND (:MAX_REPRIMANDS IS NULL OR 
              "PC"."REPRIMANDS"<=TO_NUMBER(:MAX_REPRIMANDS)))
  10 - filter((:CRIME IS NULL OR INSTR(LISTAGG("S"."CRIME",', ') WITHIN GROUP ( ORDER BY 
              "S"."ID"),:CRIME)>0) AND (:MIN_STAY_MONTHS IS NULL OR 
              MONTHS_BETWEEN(:NOW,MIN("S"."START_DATE"))>=TO_NUMBER(:MIN_STAY_MONTHS)) AND 
              (:MAX_STAY_MONTHS IS NULL OR MONTHS_BETWEEN(:NOW,MIN("S"."START_DATE"))<=TO_NUMBER(:MAX_STAY_
              MONTHS)) AND (:MIN_RELEASE_MONTHS IS NULL OR MONTHS_BETWEEN(MAX("S"."PLANNED_END_DATE"),:NOW)
              >=TO_NUMBER(:MIN_RELEASE_MONTHS)) AND (:MAX_RELEASE_MONTHS IS NULL OR 
              MONTHS_BETWEEN(MAX("S"."PLANNED_END_DATE"),:NOW)<=TO_NUMBER(:MAX_RELEASE_MONTHS)))
  12 - filter("S"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD') AND ("S"."REAL_END_DATE" IS NULL 
              OR "S"."REAL_END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD')))
  13 - filter((:MIN_HEIGHT_M IS NULL OR "P"."HEIGHT_M">=TO_NUMBER(:MIN_HEIGHT_M)) AND 
              (:MAX_HEIGHT_M IS NULL OR "P"."HEIGHT_M"<=TO_NUMBER(:MAX_HEIGHT_M)) AND (:MIN_WEIGHT_KG IS 
              NULL OR "P"."WEIGHT_KG">=TO_NUMBER(:MIN_WEIGHT_KG)) AND (:MAX_WEIGHT_KG IS NULL OR 
              "P"."WEIGHT_KG"<=TO_NUMBER(:MAX_WEIGHT_KG)) AND ("P"."SEX"=TO_NUMBER(:SEX) OR :SEX IS NULL) 
              AND (:MIN_AGE IS NULL OR MONTHS_BETWEEN(:NOW,INTERNAL_FUNCTION("P"."BIRTHDAY"))>=TO_NUMBER(:M
              IN_AGE)*12) AND (:MAX_AGE IS NULL OR MONTHS_BETWEEN(:NOW,INTERNAL_FUNCTION("P"."BIRTHDAY"))<=
              TO_NUMBER(:MAX_AGE)*12))
  14 - access("P"."ID"="PS"."ID")
  17 - access("P"."ID"="R"."FK_PRISONER"(+))
  19 - access("P"."ID"="P"."ID")
  20 - filter("S"."FK_PRISONER"(+)="P"."ID" AND "P"."ID"="S"."FK_PRISONER"(+))
  21 - filter("R"."FK_PRISONER"(+)="P"."ID")
  22 - filter("A"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD') AND ("A"."END_DATE" IS NULL OR 
              "A"."END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD')))
  23 - filter("C"."IS_SOLITARY"=TO_NUMBER(:IS_IN_SOLITARY) OR :IS_IN_SOLITARY IS NULL)
  24 - access("C"."ID"="A"."FK_CELL")
  25 - access("PB"."ID"="C"."FK_BLOCK")
 
Note
-----
   - this is an adaptive plan
```
], [
```
Plan hash value: 22423709
 
-------------------------------------------------------------------------------------------------------------
| Id  | Operation                           | Name          | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |               |     1 |    78 |       |  8522   (1)| 00:00:01 |
|   1 |  HASH GROUP BY                      |               |     1 |    78 |       |  8522   (1)| 00:00:01 |
|   2 |   NESTED LOOPS                      |               |     1 |    78 |       |  8521   (1)| 00:00:01 |
|   3 |    NESTED LOOPS                     |               |     1 |    78 |       |  8521   (1)| 00:00:01 |
|   4 |     NESTED LOOPS                    |               |     1 |    71 |       |  8520   (1)| 00:00:01 |
|*  5 |      HASH JOIN                      |               |     1 |    60 |       |  8519   (1)| 00:00:01 |
|*  6 |       HASH JOIN                     |               |     1 |    34 |       |  6755   (1)| 00:00:01 |
|   7 |        JOIN FILTER CREATE           | :BF0000       |     1 |    29 |       |  1786   (1)| 00:00:01 |
|   8 |         NESTED LOOPS                |               |     1 |    29 |       |  1786   (1)| 00:00:01 |
|   9 |          NESTED LOOPS               |               |     1 |    29 |       |  1786   (1)| 00:00:01 |
|  10 |           VIEW                      |               |     1 |     5 |       |  1785   (1)| 00:00:01 |
|* 11 |            FILTER                   |               |       |       |       |            |          |
|  12 |             SORT GROUP BY           |               |     1 |    89 |       |  1785   (1)| 00:00:01 |
|* 13 |              HASH JOIN              |               |  8470 |   736K|       |  1784   (1)| 00:00:01 |
|* 14 |               TABLE ACCESS FULL     | SENTENCE      |  8470 |   595K|       |  1216   (1)| 00:00:01 |
|  15 |               TABLE ACCESS FULL     | PRISONER      |   264K|  4392K|       |   568   (1)| 00:00:01 |
|* 16 |           INDEX UNIQUE SCAN         | SYS_C008234   |     1 |       |       |     0   (0)| 00:00:01 |
|* 17 |          TABLE ACCESS BY INDEX ROWID| PRISONER      |     1 |    24 |       |     1   (0)| 00:00:01 |
|  18 |        VIEW                         |               |    24 |   120 |       |  4969   (1)| 00:00:01 |
|* 19 |         FILTER                      |               |       |       |       |            |          |
|  20 |          JOIN FILTER USE            | :BF0000       |    24 |   888 |       |  4969   (1)| 00:00:01 |
|  21 |           HASH GROUP BY             |               |    24 |   888 |       |  4969   (1)| 00:00:01 |
|* 22 |            HASH JOIN RIGHT OUTER    |               |   709K|    25M|  7992K|  4951   (1)| 00:00:01 |
|  23 |             TABLE ACCESS FULL       | REPRIMAND     |   371K|  3630K|       |  1221   (1)| 00:00:01 |
|* 24 |             HASH JOIN OUTER         |               |   412K|    10M|  7496K|  2577   (1)| 00:00:01 |
|  25 |              TABLE ACCESS FULL      | PRISONER      |   264K|  4392K|       |   568   (1)| 00:00:01 |
|  26 |              TABLE ACCESS FULL      | SENTENCE      |   416K|  4070K|       |  1209   (1)| 00:00:01 |
|* 27 |       TABLE ACCESS FULL             | ACCOMMODATION |  9279 |   235K|       |  1764   (2)| 00:00:01 |
|* 28 |      TABLE ACCESS BY INDEX ROWID    | CELL          |     1 |    11 |       |     1   (0)| 00:00:01 |
|* 29 |       INDEX UNIQUE SCAN             | SYS_C008269   |     1 |       |       |     0   (0)| 00:00:01 |
|* 30 |     INDEX UNIQUE SCAN               | SYS_C008241   |     1 |       |       |     0   (0)| 00:00:01 |
|  31 |    TABLE ACCESS BY INDEX ROWID      | PRISON_BLOCK  |     1 |     7 |       |     1   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   5 - access("A"."FK_PRISONER"="P"."ID")
   6 - access("P"."ID"="PC"."ID")
  11 - filter((:CRIME IS NULL OR INSTR(LISTAGG("S"."CRIME",', ') WITHIN GROUP ( ORDER BY 
              "S"."ID"),:CRIME)>0) AND (:MIN_STAY_MONTHS IS NULL OR 
              MONTHS_BETWEEN(:NOW,MIN("S"."START_DATE"))>=TO_NUMBER(:MIN_STAY_MONTHS)) AND (:MAX_STAY_MONTHS IS 
              NULL OR MONTHS_BETWEEN(:NOW,MIN("S"."START_DATE"))<=TO_NUMBER(:MAX_STAY_MONTHS)) AND 
              (:MIN_RELEASE_MONTHS IS NULL OR MONTHS_BETWEEN(MAX("S"."PLANNED_END_DATE"),:NOW)>=TO_NUMBER(:MIN_RELE
              ASE_MONTHS)) AND (:MAX_RELEASE_MONTHS IS NULL OR MONTHS_BETWEEN(MAX("S"."PLANNED_END_DATE"),:NOW)<=TO
              _NUMBER(:MAX_RELEASE_MONTHS)))
  13 - access("P"."ID"="S"."FK_PRISONER")
  14 - filter("S"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD') AND ("S"."REAL_END_DATE" IS NULL OR 
              "S"."REAL_END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD')))
  16 - access("P"."ID"="PS"."ID")
  17 - filter((:MIN_HEIGHT_M IS NULL OR "P"."HEIGHT_M">=TO_NUMBER(:MIN_HEIGHT_M)) AND (:MAX_HEIGHT_M 
              IS NULL OR "P"."HEIGHT_M"<=TO_NUMBER(:MAX_HEIGHT_M)) AND (:MIN_WEIGHT_KG IS NULL OR 
              "P"."WEIGHT_KG">=TO_NUMBER(:MIN_WEIGHT_KG)) AND (:MAX_WEIGHT_KG IS NULL OR 
              "P"."WEIGHT_KG"<=TO_NUMBER(:MAX_WEIGHT_KG)) AND ("P"."SEX"=TO_NUMBER(:SEX) OR :SEX IS NULL) AND 
              (:MIN_AGE IS NULL OR MONTHS_BETWEEN(:NOW,INTERNAL_FUNCTION("P"."BIRTHDAY"))>=TO_NUMBER(:MIN_AGE)*12) 
              AND (:MAX_AGE IS NULL OR MONTHS_BETWEEN(:NOW,INTERNAL_FUNCTION("P"."BIRTHDAY"))<=TO_NUMBER(:MAX_AGE)*
              12))
  19 - filter((:MIN_SENTENCES IS NULL OR COUNT("S"."ID")>=TO_NUMBER(:MIN_SENTENCES)) AND 
              (:MAX_SENTENCES IS NULL OR COUNT("S"."ID")<=TO_NUMBER(:MAX_SENTENCES)) AND (:MIN_REPRIMANDS IS NULL 
              OR COUNT("R"."ID")>=TO_NUMBER(:MIN_REPRIMANDS)) AND (:MAX_REPRIMANDS IS NULL OR 
              COUNT("R"."ID")<=TO_NUMBER(:MAX_REPRIMANDS)))
  22 - access("P"."ID"="R"."FK_PRISONER"(+))
  24 - access("P"."ID"="S"."FK_PRISONER"(+))
  27 - filter("A"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD') AND ("A"."END_DATE" IS NULL OR 
              "A"."END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD')))
  28 - filter("C"."IS_SOLITARY"=TO_NUMBER(:IS_IN_SOLITARY) OR :IS_IN_SOLITARY IS NULL)
  29 - access("C"."ID"="A"."FK_CELL")
  30 - access("PB"."ID"="C"."FK_BLOCK")
 
Note
-----
   - this is an adaptive plan
```
])

== Zapytanie 3

#description[Wyszukanie wydarzeń związanych z więźniami w danym bloku `block_number`, które miały miejsce w określonym przedziale czasowym (`start_date` - `end_date`). Wyniki mogą być filtrowane według typu wydarzenia `event_type`, np. ucieczka, bójka. Można ograniczyć wyniki do wydarzeń dotyczących więźniów o określonych cechach: liczba wyroków (`sentence_count`), przestępstwo (`crime`), liczba reprymend (`reprimand_count`), czy obecność w izolatce (`is_in_solitary`). Zwracana jest lista wydarzeń wraz z datą, danymi więźnia i strażnika oraz treścią reprymendy.]

#sql[
```
SELECT r.id,
       r.issue_date,
       p.first_name || ' ' || p.last_name || ' (' || p.id || ')' AS prisoner,
       g.first_name || ' ' || g.last_name || ' (' || g.id || ')' AS guard,
       r.reason
FROM reprimand r
JOIN prisoner p ON r.fk_prisoner = p.id
JOIN guard g ON r.fk_guard = g.id
JOIN
  (SELECT p.id,
          pb.id AS block_id,
          pb.block_number,
          c.is_solitary
   FROM prison_block pb
   INNER JOIN cell c ON pb.id = c.fk_block
   INNER JOIN accommodation a ON c.id = a.fk_cell
   INNER JOIN prisoner p ON a.fk_prisoner = p.id
   WHERE to_char(a.start_date, 'YYYY-MM-DD') <= :start_date
     AND (a.end_date IS NULL
          OR to_char(a.end_date, 'YYYY-MM-DD') >= :end_date)) pb ON p.id = pb.id
JOIN
  (SELECT min(p.id) AS id,
          count(r.id) AS reprimands,
          count(s.id) AS sentences
   FROM prisoner p
   INNER JOIN reprimand r ON p.id = r.fk_prisoner
   INNER JOIN sentence s ON p.id = s.fk_prisoner
   GROUP BY p.pesel) pc ON p.id = pc.id
JOIN
  (SELECT min(p.id) AS id,
          listagg(s.crime, ',') within group(
                                             ORDER BY dbms_random.value) AS crime
   FROM prisoner p
   INNER JOIN sentence s ON p.id = s.fk_prisoner
   WHERE to_char(s.start_date, 'YYYY-MM-DD') <= :start_date
     AND (s.real_end_date IS NULL
          OR to_char(s.real_end_date, 'YYYY-MM-DD') >= :end_date)
   GROUP BY p.pesel) ps ON p.id = ps.id
WHERE to_char(r.issue_date, 'YYYY-MM-DD') >= :start_date
  AND to_char(r.issue_date, 'YYYY-MM-DD') <= :end_date
  AND (:block_number IS NULL
       OR pb.block_number = :block_number)
  AND (:event_type IS NULL
       OR instr(r.reason, :event_type) > 0)
  AND (:sentence_count IS NULL
       OR pc.sentences = :sentence_count)
  AND (:reprimand_count IS NULL
       OR pc.reprimands = :reprimand_count)
  AND (:crime IS NULL
       OR instr(ps.crime, :crime) > 0)
  AND (:is_in_solitary IS NULL
       OR pb.is_solitary = :is_in_solitary);
```
]

Podobnie do poprzedniego przykładu, zamieniliśmy zapytania grupujące po kluczu głównym więźnia na grupowanie po PESELu. Następnie analogicznie do zapytania pierwszego, zmieniliśmy uporządkowanie przestępstw na liście na losowe. Dodatkowo, zmieniliśmy porównania, w których używaliśmy funkcji na parametrze zapytania, tak aby używać funkcji na danych z tabeli, np. `a.start_date <= to_date(:start_date, 'YYYY-MM-DD')` zostało zamienione na równoważne `to_char(a.start_date, 'YYYY-MM-DD') <= :start_date`, co pozwoli w następnych etapach wykorzystać indeksy funkcyjne.

Łącznie koszt zapytania wzrósł z 7381 do 9645.

#plan([
```
Plan hash value: 1091244389
 
---------------------------------------------------------------------------------------------------------------
| Id  | Operation                             | Name          | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                      |               |     1 |   198 |       |  7381   (1)| 00:00:01 |
|   1 |  NESTED LOOPS                         |               |     1 |   198 |       |  7381   (1)| 00:00:01 |
|   2 |   NESTED LOOPS                        |               |     1 |   198 |       |  7381   (1)| 00:00:01 |
|   3 |    NESTED LOOPS                       |               |     1 |   175 |       |  7380   (1)| 00:00:01 |
|   4 |     NESTED LOOPS                      |               |     1 |   168 |       |  7379   (1)| 00:00:01 |
|*  5 |      HASH JOIN                        |               |     1 |   157 |       |  7378   (1)| 00:00:01 |
|*  6 |       HASH JOIN                       |               |     1 |   131 |       |  5614   (1)| 00:00:01 |
|   7 |        JOIN FILTER CREATE             | :BF0000       |     1 |   118 |       |  2531   (1)| 00:00:01 |
|*  8 |         HASH JOIN                     |               |     1 |   118 |       |  2531   (1)| 00:00:01 |
|   9 |          JOIN FILTER CREATE           | :BF0001       |    91 |  9555 |       |  1314   (1)| 00:00:01 |
|  10 |           NESTED LOOPS                |               |    91 |  9555 |       |  1314   (1)| 00:00:01 |
|  11 |            NESTED LOOPS               |               |    91 |  9555 |       |  1314   (1)| 00:00:01 |
|* 12 |             TABLE ACCESS FULL         | REPRIMAND     |    91 |  7462 |       |  1223   (1)| 00:00:01 |
|* 13 |             INDEX UNIQUE SCAN         | SYS_C008234   |     1 |       |       |     0   (0)| 00:00:01 |
|  14 |            TABLE ACCESS BY INDEX ROWID| PRISONER      |     1 |    23 |       |     1   (0)| 00:00:01 |
|  15 |          VIEW                         |               |   822 | 10686 |       |  1217   (1)| 00:00:01 |
|* 16 |           FILTER                      |               |       |       |       |            |          |
|  17 |            SORT GROUP BY              |               |   822 | 54252 |       |  1217   (1)| 00:00:01 |
|  18 |             JOIN FILTER USE           | :BF0001       |  8470 |   545K|       |  1216   (1)| 00:00:01 |
|* 19 |              TABLE ACCESS FULL        | SENTENCE      |  8470 |   545K|       |  1216   (1)| 00:00:01 |
|  20 |        VIEW                           |               |   643 |  8359 |       |  3083   (1)| 00:00:01 |
|* 21 |         FILTER                        |               |       |       |       |            |          |
|  22 |          HASH GROUP BY                |               |   643 |  6430 |       |  3083   (1)| 00:00:01 |
|* 23 |           FILTER                      |               |       |       |       |            |          |
|* 24 |            HASH JOIN                  |               |   579K|  5659K|  6176K|  3068   (1)| 00:00:01 |
|  25 |             TABLE ACCESS FULL         | REPRIMAND     |   371K|  1815K|       |  1221   (1)| 00:00:01 |
|  26 |             JOIN FILTER USE           | :BF0000       |   416K|  2035K|       |  1209   (1)| 00:00:01 |
|* 27 |              TABLE ACCESS FULL        | SENTENCE      |   416K|  2035K|       |  1209   (1)| 00:00:01 |
|* 28 |       TABLE ACCESS FULL               | ACCOMMODATION |  9279 |   235K|       |  1764   (2)| 00:00:01 |
|* 29 |      TABLE ACCESS BY INDEX ROWID      | CELL          |     1 |    11 |       |     1   (0)| 00:00:01 |
|* 30 |       INDEX UNIQUE SCAN               | SYS_C008269   |     1 |       |       |     0   (0)| 00:00:01 |
|* 31 |     TABLE ACCESS BY INDEX ROWID       | PRISON_BLOCK  |     1 |     7 |       |     1   (0)| 00:00:01 |
|* 32 |      INDEX UNIQUE SCAN                | SYS_C008241   |     1 |       |       |     0   (0)| 00:00:01 |
|* 33 |    INDEX UNIQUE SCAN                  | SYS_C008254   |     1 |       |       |     0   (0)| 00:00:01 |
|  34 |   TABLE ACCESS BY INDEX ROWID         | GUARD         |     1 |    23 |       |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   5 - access("P"."ID"="A"."FK_PRISONER")
   6 - access("P"."ID"="PC"."ID")
   8 - access("P"."ID"="PS"."ID")
  12 - filter((:EVENT_TYPE IS NULL OR INSTR("R"."REASON",:EVENT_TYPE)>0) AND 
              "R"."ISSUE_DATE">=TO_DATE(:START_DATE,'YYYY-MM-DD') AND 
              "R"."ISSUE_DATE"<=TO_DATE(:END_DATE,'YYYY-MM-DD'))
  13 - access("R"."FK_PRISONER"="P"."ID")
  16 - filter(:CRIME IS NULL OR INSTR(LISTAGG("S"."CRIME",',') WITHIN GROUP ( ORDER BY 
              "S"."ID"),:CRIME)>0)
  19 - filter("S"."START_DATE"<=TO_DATE(:START_DATE,'YYYY-MM-DD') AND ("S"."REAL_END_DATE" IS NULL OR 
              "S"."REAL_END_DATE">=TO_DATE(:END_DATE,'YYYY-MM-DD')) AND 
              SYS_OP_BLOOM_FILTER(:BF0001,"S"."FK_PRISONER"))
  21 - filter((:SENTENCE_COUNT IS NULL OR COUNT(*)=TO_NUMBER(:SENTENCE_COUNT)) AND (:REPRIMAND_COUNT 
              IS NULL OR COUNT(*)=TO_NUMBER(:REPRIMAND_COUNT)))
  23 - filter(TO_DATE(:END_DATE,'YYYY-MM-DD')>=TO_DATE(:START_DATE,'YYYY-MM-DD'))
  24 - access("S"."FK_PRISONER"="R"."FK_PRISONER")
  27 - filter(SYS_OP_BLOOM_FILTER(:BF0000,"S"."FK_PRISONER"))
  28 - filter("A"."START_DATE"<=TO_DATE(:START_DATE,'YYYY-MM-DD') AND ("A"."END_DATE" IS NULL OR 
              "A"."END_DATE">=TO_DATE(:END_DATE,'YYYY-MM-DD')))
  29 - filter("C"."IS_SOLITARY"=TO_NUMBER(:IS_IN_SOLITARY) OR :IS_IN_SOLITARY IS NULL)
  30 - access("C"."ID"="A"."FK_CELL")
  31 - filter(:BLOCK_NUMBER IS NULL OR "PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  32 - access("PB"."ID"="C"."FK_BLOCK")
  33 - access("R"."FK_GUARD"="G"."ID")
 
Note
-----
   - this is an adaptive plan
```
], [
```
Plan hash value: 2214415418
 
--------------------------------------------------------------------------------------------------------------
| Id  | Operation                            | Name          | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                     |               |     1 |  2200 |       |  9645   (1)| 00:00:01 |
|   1 |  NESTED LOOPS                        |               |     1 |  2200 |       |  9645   (1)| 00:00:01 |
|   2 |   NESTED LOOPS                       |               |     1 |  2200 |       |  9645   (1)| 00:00:01 |
|   3 |    NESTED LOOPS                      |               |     1 |  2177 |       |  9644   (1)| 00:00:01 |
|   4 |     NESTED LOOPS                     |               |     1 |  2170 |       |  9643   (1)| 00:00:01 |
|*  5 |      HASH JOIN                       |               |     1 |  2159 |       |  9642   (1)| 00:00:01 |
|*  6 |       HASH JOIN                      |               |     1 |  2133 |       |  7876   (1)| 00:00:01 |
|*  7 |        HASH JOIN                     |               |     1 |   118 |       |  5929   (1)| 00:00:01 |
|   8 |         JOIN FILTER CREATE           | :BF0000       |    91 |  9555 |       |  1314   (1)| 00:00:01 |
|   9 |          NESTED LOOPS                |               |    91 |  9555 |       |  1314   (1)| 00:00:01 |
|  10 |           NESTED LOOPS               |               |    91 |  9555 |       |  1314   (1)| 00:00:01 |
|* 11 |            TABLE ACCESS FULL         | REPRIMAND     |    91 |  7462 |       |  1223   (1)| 00:00:01 |
|* 12 |            INDEX UNIQUE SCAN         | SYS_C008234   |     1 |       |       |     0   (0)| 00:00:01 |
|  13 |           TABLE ACCESS BY INDEX ROWID| PRISONER      |     1 |    23 |       |     1   (0)| 00:00:01 |
|  14 |         VIEW                         |               |   937 | 12181 |       |  4615   (1)| 00:00:01 |
|* 15 |          FILTER                      |               |       |       |       |            |          |
|  16 |           JOIN FILTER USE            | :BF0000       |   937 | 25299 |       |  4615   (1)| 00:00:01 |
|  17 |            HASH GROUP BY             |               |   937 | 25299 |       |  4615   (1)| 00:00:01 |
|* 18 |             FILTER                   |               |       |       |       |            |          |
|* 19 |              HASH JOIN               |               |   579K|    14M|  6920K|  4600   (1)| 00:00:01 |
|  20 |               TABLE ACCESS FULL      | SENTENCE      |   416K|  2035K|       |  1209   (1)| 00:00:01 |
|* 21 |               HASH JOIN              |               |   371K|  7987K|  6176K|  2454   (1)| 00:00:01 |
|  22 |                TABLE ACCESS FULL     | REPRIMAND     |   371K|  1815K|       |  1221   (1)| 00:00:01 |
|  23 |                TABLE ACCESS FULL     | PRISONER      |   264K|  4392K|       |   568   (1)| 00:00:01 |
|* 24 |        VIEW                          |               |  8717 |    16M|       |  1947   (1)| 00:00:01 |
|  25 |         SORT GROUP BY                |               |  8717 |   663K|   768K|  1947   (1)| 00:00:01 |
|* 26 |          FILTER                      |               |       |       |       |            |          |
|* 27 |           HASH JOIN                  |               |  8717 |   663K|       |  1784   (1)| 00:00:01 |
|* 28 |            TABLE ACCESS FULL         | SENTENCE      |  8717 |   519K|       |  1216   (1)| 00:00:01 |
|  29 |            TABLE ACCESS FULL         | PRISONER      |   264K|  4392K|       |   568   (1)| 00:00:01 |
|* 30 |       TABLE ACCESS FULL              | ACCOMMODATION |  9577 |   243K|       |  1766   (2)| 00:00:01 |
|* 31 |      TABLE ACCESS BY INDEX ROWID     | CELL          |     1 |    11 |       |     1   (0)| 00:00:01 |
|* 32 |       INDEX UNIQUE SCAN              | SYS_C008269   |     1 |       |       |     0   (0)| 00:00:01 |
|* 33 |     TABLE ACCESS BY INDEX ROWID      | PRISON_BLOCK  |     1 |     7 |       |     1   (0)| 00:00:01 |
|* 34 |      INDEX UNIQUE SCAN               | SYS_C008241   |     1 |       |       |     0   (0)| 00:00:01 |
|* 35 |    INDEX UNIQUE SCAN                 | SYS_C008254   |     1 |       |       |     0   (0)| 00:00:01 |
|  36 |   TABLE ACCESS BY INDEX ROWID        | GUARD         |     1 |    23 |       |     1   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   5 - access("P"."ID"="A"."FK_PRISONER")
   6 - access("P"."ID"="PS"."ID")
   7 - access("P"."ID"="PC"."ID")
  11 - filter((:EVENT_TYPE IS NULL OR INSTR("R"."REASON",:EVENT_TYPE)>0) AND 
              TO_CHAR(INTERNAL_FUNCTION("R"."ISSUE_DATE"),'YYYY-MM-DD')>=:START_DATE AND 
              TO_CHAR(INTERNAL_FUNCTION("R"."ISSUE_DATE"),'YYYY-MM-DD')<=:END_DATE)
  12 - access("R"."FK_PRISONER"="P"."ID")
  15 - filter((:SENTENCE_COUNT IS NULL OR COUNT(*)=TO_NUMBER(:SENTENCE_COUNT)) AND (:REPRIMAND_COUNT 
              IS NULL OR COUNT(*)=TO_NUMBER(:REPRIMAND_COUNT)))
  18 - filter(:END_DATE>=:START_DATE)
  19 - access("P"."ID"="S"."FK_PRISONER")
  21 - access("P"."ID"="R"."FK_PRISONER")
  24 - filter(:CRIME IS NULL OR INSTR("PS"."CRIME",:CRIME)>0)
  26 - filter(:END_DATE>=:START_DATE)
  27 - access("P"."ID"="S"."FK_PRISONER")
  28 - filter(TO_CHAR(INTERNAL_FUNCTION("S"."START_DATE"),'YYYY-MM-DD')<=:START_DATE AND 
              ("S"."REAL_END_DATE" IS NULL OR TO_CHAR(INTERNAL_FUNCTION("S"."REAL_END_DATE"),'YYYY-MM-DD')>=:END_DAT
              E))
  30 - filter(TO_CHAR(INTERNAL_FUNCTION("A"."START_DATE"),'YYYY-MM-DD')<=:START_DATE AND 
              ("A"."END_DATE" IS NULL OR TO_CHAR(INTERNAL_FUNCTION("A"."END_DATE"),'YYYY-MM-DD')>=:END_DATE))
  31 - filter("C"."IS_SOLITARY"=TO_NUMBER(:IS_IN_SOLITARY) OR :IS_IN_SOLITARY IS NULL)
  32 - access("C"."ID"="A"."FK_CELL")
  33 - filter(:BLOCK_NUMBER IS NULL OR "PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  34 - access("PB"."ID"="C"."FK_BLOCK")
  35 - access("R"."FK_GUARD"="G"."ID")
 
Note
-----
   - this is an adaptive plan
```
])

== Zapytanie 4

#description[Zwrócenie raportu dotyczącego minimalnej, maksymalnej i średniej dla wzrostu, wagi, liczby wyroków, liczby reprymend, liczby przekwaterowań dla więźniów w danym bloku `block_number`. Można filtrować wyniki według płci więźniów (`sex`).]

#sql[
```

SELECT 'Height' AS "Name",
       min(height) AS "Min",
       max(height) AS "Max",
       round(avg(height), 2) AS "Average",
       round(stddev_pop(height), 2) AS "Standard deviation",
       round(var_pop(height), 2) AS "Variance"
FROM
  (SELECT p.id,
          min(p.height_m) AS height,
          min(p.weight_kg) AS weight,
          count(DISTINCT s.id) AS sentencenumber,
          count(DISTINCT r.id) AS reprimandnumber,
          count(DISTINCT a.id) AS accommodationnumber
   FROM prisoner p
   LEFT JOIN sentence s ON p.id = s.fk_prisoner
   LEFT JOIN reprimand r ON p.id = r.fk_prisoner
   LEFT JOIN accommodation a ON p.id = a.fk_prisoner
   LEFT JOIN
     (SELECT p.id,
             pb.block_number
      FROM prison_block pb
      INNER JOIN cell c ON pb.id = c.fk_block
      INNER JOIN accommodation a ON c.id = a.fk_cell
      INNER JOIN prisoner p ON a.fk_prisoner = p.id
      WHERE a.start_date <= to_date(:now, 'YYYY-MM-DD')
        AND (a.end_date IS NULL
             OR a.end_date >= to_date(:now, 'YYYY-MM-DD'))) pb ON p.id = pb.id
   WHERE (:block_number IS NULL
          OR pb.block_number = :block_number)
     AND (:sex IS NULL
          OR p.sex = :sex)
   GROUP BY p.id)
UNION
SELECT 'Weight' AS "Name",
       min(weight) AS "Min",
       max(weight) AS "Max",
       round(avg(weight), 2) AS "Average",
       round(stddev_pop(weight), 2) AS "Standard deviation",
       round(var_pop(weight), 2) AS "Variance"
FROM
  (SELECT p.id,
          min(p.height_m) AS height,
          min(p.weight_kg) AS weight,
          count(DISTINCT s.id) AS sentencenumber,
          count(DISTINCT r.id) AS reprimandnumber,
          count(DISTINCT a.id) AS accommodationnumber
   FROM prisoner p
   LEFT JOIN sentence s ON p.id = s.fk_prisoner
   LEFT JOIN reprimand r ON p.id = r.fk_prisoner
   LEFT JOIN accommodation a ON p.id = a.fk_prisoner
   LEFT JOIN
     (SELECT p.id,
             pb.block_number
      FROM prison_block pb
      INNER JOIN cell c ON pb.id = c.fk_block
      INNER JOIN accommodation a ON c.id = a.fk_cell
      INNER JOIN prisoner p ON a.fk_prisoner = p.id
      WHERE a.start_date <= to_date(:now, 'YYYY-MM-DD')
        AND (a.end_date IS NULL
             OR a.end_date >= to_date(:now, 'YYYY-MM-DD'))) pb ON p.id = pb.id
   WHERE (:block_number IS NULL
          OR pb.block_number = :block_number)
     AND (:sex IS NULL
          OR p.sex = :sex)
   GROUP BY p.id)
UNION
SELECT 'Sentences' AS "Name",
       min(sentencenumber) AS "Min",
       max(sentencenumber) AS "Max",
       round(avg(sentencenumber), 2) AS "Average",
       round(stddev_pop(sentencenumber), 2) AS "Standard deviation",
       round(var_pop(sentencenumber), 2) AS "Variance"
FROM
  (SELECT p.id,
          min(p.height_m) AS height,
          min(p.weight_kg) AS weight,
          count(DISTINCT s.id) AS sentencenumber,
          count(DISTINCT r.id) AS reprimandnumber,
          count(DISTINCT a.id) AS accommodationnumber
   FROM prisoner p
   LEFT JOIN sentence s ON p.id = s.fk_prisoner
   LEFT JOIN reprimand r ON p.id = r.fk_prisoner
   LEFT JOIN accommodation a ON p.id = a.fk_prisoner
   LEFT JOIN
     (SELECT p.id,
             pb.block_number
      FROM prison_block pb
      INNER JOIN cell c ON pb.id = c.fk_block
      INNER JOIN accommodation a ON c.id = a.fk_cell
      INNER JOIN prisoner p ON a.fk_prisoner = p.id
      WHERE a.start_date <= to_date(:now, 'YYYY-MM-DD')
        AND (a.end_date IS NULL
             OR a.end_date >= to_date(:now, 'YYYY-MM-DD'))) pb ON p.id = pb.id
   WHERE (:block_number IS NULL
          OR pb.block_number = :block_number)
     AND (:sex IS NULL
          OR p.sex = :sex)
   GROUP BY p.id)
UNION
SELECT 'Reprimands' AS "Name",
       min(reprimandnumber) AS "Min",
       max(reprimandnumber) AS "Max",
       round(avg(reprimandnumber), 2) AS "Average",
       round(stddev_pop(reprimandnumber), 2) AS "Standard deviation",
       round(var_pop(reprimandnumber), 2) AS "Variance"
FROM
  (SELECT p.id,
          min(p.height_m) AS height,
          min(p.weight_kg) AS weight,
          count(DISTINCT s.id) AS sentencenumber,
          count(DISTINCT r.id) AS reprimandnumber,
          count(DISTINCT a.id) AS accommodationnumber
   FROM prisoner p
   LEFT JOIN sentence s ON p.id = s.fk_prisoner
   LEFT JOIN reprimand r ON p.id = r.fk_prisoner
   LEFT JOIN accommodation a ON p.id = a.fk_prisoner
   LEFT JOIN
     (SELECT p.id,
             pb.block_number
      FROM prison_block pb
      INNER JOIN cell c ON pb.id = c.fk_block
      INNER JOIN accommodation a ON c.id = a.fk_cell
      INNER JOIN prisoner p ON a.fk_prisoner = p.id
      WHERE a.start_date <= to_date(:now, 'YYYY-MM-DD')
        AND (a.end_date IS NULL
             OR a.end_date >= to_date(:now, 'YYYY-MM-DD'))) pb ON p.id = pb.id
   WHERE (:block_number IS NULL
          OR pb.block_number = :block_number)
     AND (:sex IS NULL
          OR p.sex = :sex)
   GROUP BY p.id)
UNION
SELECT 'Accomodations' AS "Name",
       min(accommodationnumber) AS "Min",
       max(accommodationnumber) AS "Max",
       round(avg(accommodationnumber), 2) AS "Average",
       round(stddev_pop(accommodationnumber), 2) AS "Standard deviation",
       round(var_pop(accommodationnumber), 2) AS "Variance"
FROM
  (SELECT p.id,
          min(p.height_m) AS height,
          min(p.weight_kg) AS weight,
          count(DISTINCT s.id) AS sentencenumber,
          count(DISTINCT r.id) AS reprimandnumber,
          count(DISTINCT a.id) AS accommodationnumber
   FROM prisoner p
   LEFT JOIN sentence s ON p.id = s.fk_prisoner
   LEFT JOIN reprimand r ON p.id = r.fk_prisoner
   LEFT JOIN accommodation a ON p.id = a.fk_prisoner
   LEFT JOIN
     (SELECT p.id,
             pb.block_number
      FROM prison_block pb
      INNER JOIN cell c ON pb.id = c.fk_block
      INNER JOIN accommodation a ON c.id = a.fk_cell
      INNER JOIN prisoner p ON a.fk_prisoner = p.id
      WHERE a.start_date <= to_date(:now, 'YYYY-MM-DD')
        AND (a.end_date IS NULL
             OR a.end_date >= to_date(:now, 'YYYY-MM-DD'))) pb ON p.id = pb.id
   WHERE (:block_number IS NULL
          OR pb.block_number = :block_number)
     AND (:sex IS NULL
          OR p.sex = :sex)
   GROUP BY p.id);
```
]

W poprzednim etapie wykorzystywaliśmy zapytanie pomocnicze nazwane za pomocą `WITH`, które było następnie kilkukrotnie wykorzystywane w głównym zapytaniu. W celu pogorszenia planu zapytania, zastąpiliśmy każde jego wykorzystanie poprzez bezpośrednie wklejenie treści tego zapytania. Warto zauważyć, że po lewej stronie widzimy na w korzeniu koszt 4752, jednakże pod nim znajduje się gałąź z kosztem 16473 odpowiedzialna za obliczenie wyniku podzapytania. System przechował ten wynik w tabeli tymczasowej `SYS_TEMP_0FD9D6644_9D80EB`, co pozwoliło na wielokrotne wykorzystanie go w głównym zapytaniu.

Po zmianie, koszt zapytania wzrósł do 85677 oraz znacząco powiększyło się drzewo planu w związku z wielokrotnym wykorzystaniem takiego samego podzapytania, którego Oracle nie był w stanie zoptymalizować i liczy kilkukrotnie.

#pagebreak()

#plan([
```
Plan hash value: 1418518406
 
------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                | Name                      | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                         |                           |     5 |    65 |       |  4752   (1)| 00:00:01 |
|   1 |  TEMP TABLE TRANSFORMATION               |                           |       |       |       |            |          |
|   2 |   LOAD AS SELECT (CURSOR DURATION MEMORY)| SYS_TEMP_0FD9D6644_9D80EB |       |       |       |            |          |
|   3 |    HASH GROUP BY                         |                           |   138K|  7596K|       | 16473   (1)| 00:00:01 |
|   4 |     MERGE JOIN OUTER                     |                           |  2179K|   116M|       | 16473   (1)| 00:00:01 |
|   5 |      MERGE JOIN OUTER                    |                           |  1398K|    61M|       | 13597   (1)| 00:00:01 |
|   6 |       MERGE JOIN OUTER                   |                           |   284K|  9724K|       |  6110   (1)| 00:00:01 |
|*  7 |        FILTER                            |                           |       |       |       |            |          |
|   8 |         MERGE JOIN OUTER                 |                           |   138K|  3391K|       |  3403   (2)| 00:00:01 |
|   9 |          SORT JOIN                       |                           |   138K|  2170K|  7656K|  1311   (1)| 00:00:01 |
|* 10 |           TABLE ACCESS FULL              | PRISONER                  |   138K|  2170K|       |   569   (1)| 00:00:01 |
|* 11 |          SORT JOIN                       |                           |  9279 | 83511 |       |  2092   (2)| 00:00:01 |
|  12 |           VIEW                           |                           |  9279 | 83511 |       |  2091   (2)| 00:00:01 |
|* 13 |            HASH JOIN                     |                           |  9279 |   371K|       |  2091   (2)| 00:00:01 |
|  14 |             TABLE ACCESS FULL            | PRISON_BLOCK              |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 15 |             HASH JOIN                    |                           |  9279 |   308K|       |  2089   (2)| 00:00:01 |
|* 16 |              TABLE ACCESS FULL           | ACCOMMODATION             |  9279 |   235K|       |  1764   (2)| 00:00:01 |
|  17 |              TABLE ACCESS FULL           | CELL                      |   233K|  1821K|       |   324   (1)| 00:00:01 |
|* 18 |        SORT JOIN                         |                           |   371K|  3630K|    14M|  2707   (1)| 00:00:01 |
|  19 |         TABLE ACCESS FULL                | REPRIMAND                 |   371K|  3630K|       |  1221   (1)| 00:00:01 |
|* 20 |       SORT JOIN                          |                           |  1314K|    13M|    50M|  7487   (1)| 00:00:01 |
|  21 |        TABLE ACCESS FULL                 | ACCOMMODATION             |  1314K|    13M|       |  1744   (1)| 00:00:01 |
|* 22 |      SORT JOIN                           |                           |   416K|  4070K|    15M|  2874   (1)| 00:00:01 |
|  23 |       TABLE ACCESS FULL                  | SENTENCE                  |   416K|  4070K|       |  1209   (1)| 00:00:01 |
|  24 |   HASH UNIQUE                            |                           |     5 |    65 |       |  4752   (1)| 00:00:01 |
|  25 |    UNION-ALL                             |                           |       |       |       |            |          |
|  26 |     SORT AGGREGATE                       |                           |     1 |    13 |       |   950   (1)| 00:00:01 |
|  27 |      VIEW                                |                           |   138K|  1763K|       |   288   (1)| 00:00:01 |
|  28 |       TABLE ACCESS FULL                  | SYS_TEMP_0FD9D6644_9D80EB |   138K|  7596K|       |   288   (1)| 00:00:01 |
|  29 |     SORT AGGREGATE                       |                           |     1 |    13 |       |   950   (1)| 00:00:01 |
|  30 |      VIEW                                |                           |   138K|  1763K|       |   288   (1)| 00:00:01 |
|  31 |       TABLE ACCESS FULL                  | SYS_TEMP_0FD9D6644_9D80EB |   138K|  7596K|       |   288   (1)| 00:00:01 |
|  32 |     SORT AGGREGATE                       |                           |     1 |    13 |       |   950   (1)| 00:00:01 |
|  33 |      VIEW                                |                           |   138K|  1763K|       |   288   (1)| 00:00:01 |
|  34 |       TABLE ACCESS FULL                  | SYS_TEMP_0FD9D6644_9D80EB |   138K|  7596K|       |   288   (1)| 00:00:01 |
|  35 |     SORT AGGREGATE                       |                           |     1 |    13 |       |   950   (1)| 00:00:01 |
|  36 |      VIEW                                |                           |   138K|  1763K|       |   288   (1)| 00:00:01 |
|  37 |       TABLE ACCESS FULL                  | SYS_TEMP_0FD9D6644_9D80EB |   138K|  7596K|       |   288   (1)| 00:00:01 |
|  38 |     SORT AGGREGATE                       |                           |     1 |    13 |       |   950   (1)| 00:00:01 |
|  39 |      VIEW                                |                           |   138K|  1763K|       |   288   (1)| 00:00:01 |
|  40 |       TABLE ACCESS FULL                  | SYS_TEMP_0FD9D6644_9D80EB |   138K|  7596K|       |   288   (1)| 00:00:01 |
------------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   7 - filter(:BLOCK_NUMBER IS NULL OR "PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  10 - filter("P"."SEX"=TO_NUMBER(:SEX) OR :SEX IS NULL)
  11 - access("P"."ID"="PB"."ID"(+))
       filter("P"."ID"="PB"."ID"(+))
  13 - access("PB"."ID"="C"."FK_BLOCK")
  15 - access("C"."ID"="A"."FK_CELL")
  16 - filter("A"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD') AND ("A"."END_DATE" IS NULL OR 
              "A"."END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD')))
  18 - access("P"."ID"="R"."FK_PRISONER"(+))
       filter("P"."ID"="R"."FK_PRISONER"(+))
  20 - access("P"."ID"="A"."FK_PRISONER"(+))
       filter("P"."ID"="A"."FK_PRISONER"(+))
  22 - access("P"."ID"="S"."FK_PRISONER"(+))
       filter("P"."ID"="S"."FK_PRISONER"(+))
```
], [
```
Plan hash value: 171928505
 
---------------------------------------------------------------------------------------------------------
| Id  | Operation                       | Name          | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                |               |     5 |    65 |       | 85677   (1)| 00:00:04 |
|   1 |  HASH UNIQUE                    |               |     5 |    65 |       | 85677   (1)| 00:00:04 |
|   2 |   UNION-ALL                     |               |       |       |       |            |          |
|   3 |    SORT AGGREGATE               |               |     1 |    13 |       | 17135   (1)| 00:00:01 |
|   4 |     VIEW                        |               |   138K|  1763K|       | 16473   (1)| 00:00:01 |
|   5 |      HASH GROUP BY              |               |   138K|  7596K|       | 16473   (1)| 00:00:01 |
|   6 |       MERGE JOIN OUTER          |               |  2179K|   116M|       | 16473   (1)| 00:00:01 |
|   7 |        MERGE JOIN OUTER         |               |  1398K|    61M|       | 13597   (1)| 00:00:01 |
|   8 |         MERGE JOIN OUTER        |               |   284K|  9724K|       |  6110   (1)| 00:00:01 |
|*  9 |          FILTER                 |               |       |       |       |            |          |
|  10 |           MERGE JOIN OUTER      |               |   138K|  3391K|       |  3403   (2)| 00:00:01 |
|  11 |            SORT JOIN            |               |   138K|  2170K|  7656K|  1311   (1)| 00:00:01 |
|* 12 |             TABLE ACCESS FULL   | PRISONER      |   138K|  2170K|       |   569   (1)| 00:00:01 |
|* 13 |            SORT JOIN            |               |  9279 | 83511 |       |  2092   (2)| 00:00:01 |
|  14 |             VIEW                |               |  9279 | 83511 |       |  2091   (2)| 00:00:01 |
|* 15 |              HASH JOIN          |               |  9279 |   371K|       |  2091   (2)| 00:00:01 |
|  16 |               TABLE ACCESS FULL | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 17 |               HASH JOIN         |               |  9279 |   308K|       |  2089   (2)| 00:00:01 |
|* 18 |                TABLE ACCESS FULL| ACCOMMODATION |  9279 |   235K|       |  1764   (2)| 00:00:01 |
|  19 |                TABLE ACCESS FULL| CELL          |   233K|  1821K|       |   324   (1)| 00:00:01 |
|* 20 |          SORT JOIN              |               |   371K|  3630K|    14M|  2707   (1)| 00:00:01 |
|  21 |           TABLE ACCESS FULL     | REPRIMAND     |   371K|  3630K|       |  1221   (1)| 00:00:01 |
|* 22 |         SORT JOIN               |               |  1314K|    13M|    50M|  7487   (1)| 00:00:01 |
|  23 |          TABLE ACCESS FULL      | ACCOMMODATION |  1314K|    13M|       |  1744   (1)| 00:00:01 |
|* 24 |        SORT JOIN                |               |   416K|  4070K|    15M|  2874   (1)| 00:00:01 |
|  25 |         TABLE ACCESS FULL       | SENTENCE      |   416K|  4070K|       |  1209   (1)| 00:00:01 |
|  26 |    SORT AGGREGATE               |               |     1 |    13 |       | 17135   (1)| 00:00:01 |
|  27 |     VIEW                        |               |   138K|  1763K|       | 16473   (1)| 00:00:01 |
|  28 |      HASH GROUP BY              |               |   138K|  7596K|       | 16473   (1)| 00:00:01 |
|  29 |       MERGE JOIN OUTER          |               |  2179K|   116M|       | 16473   (1)| 00:00:01 |
|  30 |        MERGE JOIN OUTER         |               |  1398K|    61M|       | 13597   (1)| 00:00:01 |
|  31 |         MERGE JOIN OUTER        |               |   284K|  9724K|       |  6110   (1)| 00:00:01 |
|* 32 |          FILTER                 |               |       |       |       |            |          |
|  33 |           MERGE JOIN OUTER      |               |   138K|  3391K|       |  3403   (2)| 00:00:01 |
|  34 |            SORT JOIN            |               |   138K|  2170K|  7656K|  1311   (1)| 00:00:01 |
|* 35 |             TABLE ACCESS FULL   | PRISONER      |   138K|  2170K|       |   569   (1)| 00:00:01 |
|* 36 |            SORT JOIN            |               |  9279 | 83511 |       |  2092   (2)| 00:00:01 |
|  37 |             VIEW                |               |  9279 | 83511 |       |  2091   (2)| 00:00:01 |
|* 38 |              HASH JOIN          |               |  9279 |   371K|       |  2091   (2)| 00:00:01 |
|  39 |               TABLE ACCESS FULL | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 40 |               HASH JOIN         |               |  9279 |   308K|       |  2089   (2)| 00:00:01 |
|* 41 |                TABLE ACCESS FULL| ACCOMMODATION |  9279 |   235K|       |  1764   (2)| 00:00:01 |
|  42 |                TABLE ACCESS FULL| CELL          |   233K|  1821K|       |   324   (1)| 00:00:01 |
|* 43 |          SORT JOIN              |               |   371K|  3630K|    14M|  2707   (1)| 00:00:01 |
|  44 |           TABLE ACCESS FULL     | REPRIMAND     |   371K|  3630K|       |  1221   (1)| 00:00:01 |
|* 45 |         SORT JOIN               |               |  1314K|    13M|    50M|  7487   (1)| 00:00:01 |
|  46 |          TABLE ACCESS FULL      | ACCOMMODATION |  1314K|    13M|       |  1744   (1)| 00:00:01 |
|* 47 |        SORT JOIN                |               |   416K|  4070K|    15M|  2874   (1)| 00:00:01 |
|  48 |         TABLE ACCESS FULL       | SENTENCE      |   416K|  4070K|       |  1209   (1)| 00:00:01 |
|  49 |    SORT AGGREGATE               |               |     1 |    13 |       | 17135   (1)| 00:00:01 |
|  50 |     VIEW                        |               |   138K|  1763K|       | 16473   (1)| 00:00:01 |
|  51 |      HASH GROUP BY              |               |   138K|  7596K|       | 16473   (1)| 00:00:01 |
|  52 |       MERGE JOIN OUTER          |               |  2179K|   116M|       | 16473   (1)| 00:00:01 |
|  53 |        MERGE JOIN OUTER         |               |  1398K|    61M|       | 13597   (1)| 00:00:01 |
|  54 |         MERGE JOIN OUTER        |               |   284K|  9724K|       |  6110   (1)| 00:00:01 |
|* 55 |          FILTER                 |               |       |       |       |            |          |
|  56 |           MERGE JOIN OUTER      |               |   138K|  3391K|       |  3403   (2)| 00:00:01 |
|  57 |            SORT JOIN            |               |   138K|  2170K|  7656K|  1311   (1)| 00:00:01 |
|* 58 |             TABLE ACCESS FULL   | PRISONER      |   138K|  2170K|       |   569   (1)| 00:00:01 |
|* 59 |            SORT JOIN            |               |  9279 | 83511 |       |  2092   (2)| 00:00:01 |
|  60 |             VIEW                |               |  9279 | 83511 |       |  2091   (2)| 00:00:01 |
|* 61 |              HASH JOIN          |               |  9279 |   371K|       |  2091   (2)| 00:00:01 |
|  62 |               TABLE ACCESS FULL | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 63 |               HASH JOIN         |               |  9279 |   308K|       |  2089   (2)| 00:00:01 |
|* 64 |                TABLE ACCESS FULL| ACCOMMODATION |  9279 |   235K|       |  1764   (2)| 00:00:01 |
|  65 |                TABLE ACCESS FULL| CELL          |   233K|  1821K|       |   324   (1)| 00:00:01 |
|* 66 |          SORT JOIN              |               |   371K|  3630K|    14M|  2707   (1)| 00:00:01 |
|  67 |           TABLE ACCESS FULL     | REPRIMAND     |   371K|  3630K|       |  1221   (1)| 00:00:01 |
|* 68 |         SORT JOIN               |               |  1314K|    13M|    50M|  7487   (1)| 00:00:01 |
|  69 |          TABLE ACCESS FULL      | ACCOMMODATION |  1314K|    13M|       |  1744   (1)| 00:00:01 |
|* 70 |        SORT JOIN                |               |   416K|  4070K|    15M|  2874   (1)| 00:00:01 |
|  71 |         TABLE ACCESS FULL       | SENTENCE      |   416K|  4070K|       |  1209   (1)| 00:00:01 |
|  72 |    SORT AGGREGATE               |               |     1 |    13 |       | 17135   (1)| 00:00:01 |
|  73 |     VIEW                        |               |   138K|  1763K|       | 16473   (1)| 00:00:01 |
|  74 |      HASH GROUP BY              |               |   138K|  7596K|       | 16473   (1)| 00:00:01 |
|  75 |       MERGE JOIN OUTER          |               |  2179K|   116M|       | 16473   (1)| 00:00:01 |
|  76 |        MERGE JOIN OUTER         |               |  1398K|    61M|       | 13597   (1)| 00:00:01 |
|  77 |         MERGE JOIN OUTER        |               |   284K|  9724K|       |  6110   (1)| 00:00:01 |
|* 78 |          FILTER                 |               |       |       |       |            |          |
|  79 |           MERGE JOIN OUTER      |               |   138K|  3391K|       |  3403   (2)| 00:00:01 |
|  80 |            SORT JOIN            |               |   138K|  2170K|  7656K|  1311   (1)| 00:00:01 |
|* 81 |             TABLE ACCESS FULL   | PRISONER      |   138K|  2170K|       |   569   (1)| 00:00:01 |
|* 82 |            SORT JOIN            |               |  9279 | 83511 |       |  2092   (2)| 00:00:01 |
|  83 |             VIEW                |               |  9279 | 83511 |       |  2091   (2)| 00:00:01 |
|* 84 |              HASH JOIN          |               |  9279 |   371K|       |  2091   (2)| 00:00:01 |
|  85 |               TABLE ACCESS FULL | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 86 |               HASH JOIN         |               |  9279 |   308K|       |  2089   (2)| 00:00:01 |
|* 87 |                TABLE ACCESS FULL| ACCOMMODATION |  9279 |   235K|       |  1764   (2)| 00:00:01 |
|  88 |                TABLE ACCESS FULL| CELL          |   233K|  1821K|       |   324   (1)| 00:00:01 |
|* 89 |          SORT JOIN              |               |   371K|  3630K|    14M|  2707   (1)| 00:00:01 |
|  90 |           TABLE ACCESS FULL     | REPRIMAND     |   371K|  3630K|       |  1221   (1)| 00:00:01 |
|* 91 |         SORT JOIN               |               |  1314K|    13M|    50M|  7487   (1)| 00:00:01 |
|  92 |          TABLE ACCESS FULL      | ACCOMMODATION |  1314K|    13M|       |  1744   (1)| 00:00:01 |
|* 93 |        SORT JOIN                |               |   416K|  4070K|    15M|  2874   (1)| 00:00:01 |
|  94 |         TABLE ACCESS FULL       | SENTENCE      |   416K|  4070K|       |  1209   (1)| 00:00:01 |
|  95 |    SORT AGGREGATE               |               |     1 |    13 |       | 17135   (1)| 00:00:01 |
|  96 |     VIEW                        |               |   138K|  1763K|       | 16473   (1)| 00:00:01 |
|  97 |      HASH GROUP BY              |               |   138K|  7596K|       | 16473   (1)| 00:00:01 |
|  98 |       MERGE JOIN OUTER          |               |  2179K|   116M|       | 16473   (1)| 00:00:01 |
|  99 |        MERGE JOIN OUTER         |               |  1398K|    61M|       | 13597   (1)| 00:00:01 |
| 100 |         MERGE JOIN OUTER        |               |   284K|  9724K|       |  6110   (1)| 00:00:01 |
|*101 |          FILTER                 |               |       |       |       |            |          |
| 102 |           MERGE JOIN OUTER      |               |   138K|  3391K|       |  3403   (2)| 00:00:01 |
| 103 |            SORT JOIN            |               |   138K|  2170K|  7656K|  1311   (1)| 00:00:01 |
|*104 |             TABLE ACCESS FULL   | PRISONER      |   138K|  2170K|       |   569   (1)| 00:00:01 |
|*105 |            SORT JOIN            |               |  9279 | 83511 |       |  2092   (2)| 00:00:01 |
| 106 |             VIEW                |               |  9279 | 83511 |       |  2091   (2)| 00:00:01 |
|*107 |              HASH JOIN          |               |  9279 |   371K|       |  2091   (2)| 00:00:01 |
| 108 |               TABLE ACCESS FULL | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|*109 |               HASH JOIN         |               |  9279 |   308K|       |  2089   (2)| 00:00:01 |
|*110 |                TABLE ACCESS FULL| ACCOMMODATION |  9279 |   235K|       |  1764   (2)| 00:00:01 |
| 111 |                TABLE ACCESS FULL| CELL          |   233K|  1821K|       |   324   (1)| 00:00:01 |
|*112 |          SORT JOIN              |               |   371K|  3630K|    14M|  2707   (1)| 00:00:01 |
| 113 |           TABLE ACCESS FULL     | REPRIMAND     |   371K|  3630K|       |  1221   (1)| 00:00:01 |
|*114 |         SORT JOIN               |               |  1314K|    13M|    50M|  7487   (1)| 00:00:01 |
| 115 |          TABLE ACCESS FULL      | ACCOMMODATION |  1314K|    13M|       |  1744   (1)| 00:00:01 |
|*116 |        SORT JOIN                |               |   416K|  4070K|    15M|  2874   (1)| 00:00:01 |
| 117 |         TABLE ACCESS FULL       | SENTENCE      |   416K|  4070K|       |  1209   (1)| 00:00:01 |
---------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   9 - filter(:BLOCK_NUMBER IS NULL OR "PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  12 - filter("P"."SEX"=TO_NUMBER(:SEX) OR :SEX IS NULL)
  13 - access("P"."ID"="PB"."ID"(+))
       filter("P"."ID"="PB"."ID"(+))
  15 - access("PB"."ID"="C"."FK_BLOCK")
  17 - access("C"."ID"="A"."FK_CELL")
  18 - filter("A"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD') AND ("A"."END_DATE" IS NULL OR 
              "A"."END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD')))
  20 - access("P"."ID"="R"."FK_PRISONER"(+))
       filter("P"."ID"="R"."FK_PRISONER"(+))
  22 - access("P"."ID"="A"."FK_PRISONER"(+))
       filter("P"."ID"="A"."FK_PRISONER"(+))
  24 - access("P"."ID"="S"."FK_PRISONER"(+))
       filter("P"."ID"="S"."FK_PRISONER"(+))
  32 - filter(:BLOCK_NUMBER IS NULL OR "PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  35 - filter("P"."SEX"=TO_NUMBER(:SEX) OR :SEX IS NULL)
  36 - access("P"."ID"="PB"."ID"(+))
       filter("P"."ID"="PB"."ID"(+))
  38 - access("PB"."ID"="C"."FK_BLOCK")
  40 - access("C"."ID"="A"."FK_CELL")
  41 - filter("A"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD') AND ("A"."END_DATE" IS NULL OR 
              "A"."END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD')))
  43 - access("P"."ID"="R"."FK_PRISONER"(+))
       filter("P"."ID"="R"."FK_PRISONER"(+))
  45 - access("P"."ID"="A"."FK_PRISONER"(+))
       filter("P"."ID"="A"."FK_PRISONER"(+))
  47 - access("P"."ID"="S"."FK_PRISONER"(+))
       filter("P"."ID"="S"."FK_PRISONER"(+))
  55 - filter(:BLOCK_NUMBER IS NULL OR "PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  58 - filter("P"."SEX"=TO_NUMBER(:SEX) OR :SEX IS NULL)
  59 - access("P"."ID"="PB"."ID"(+))
       filter("P"."ID"="PB"."ID"(+))
  61 - access("PB"."ID"="C"."FK_BLOCK")
  63 - access("C"."ID"="A"."FK_CELL")
  64 - filter("A"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD') AND ("A"."END_DATE" IS NULL OR 
              "A"."END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD')))
  66 - access("P"."ID"="R"."FK_PRISONER"(+))
       filter("P"."ID"="R"."FK_PRISONER"(+))
  68 - access("P"."ID"="A"."FK_PRISONER"(+))
       filter("P"."ID"="A"."FK_PRISONER"(+))
  70 - access("P"."ID"="S"."FK_PRISONER"(+))
       filter("P"."ID"="S"."FK_PRISONER"(+))
  78 - filter(:BLOCK_NUMBER IS NULL OR "PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  81 - filter("P"."SEX"=TO_NUMBER(:SEX) OR :SEX IS NULL)
  82 - access("P"."ID"="PB"."ID"(+))
       filter("P"."ID"="PB"."ID"(+))
  84 - access("PB"."ID"="C"."FK_BLOCK")
  86 - access("C"."ID"="A"."FK_CELL")
  87 - filter("A"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD') AND ("A"."END_DATE" IS NULL OR 
              "A"."END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD')))
  89 - access("P"."ID"="R"."FK_PRISONER"(+))
       filter("P"."ID"="R"."FK_PRISONER"(+))
  91 - access("P"."ID"="A"."FK_PRISONER"(+))
       filter("P"."ID"="A"."FK_PRISONER"(+))
  93 - access("P"."ID"="S"."FK_PRISONER"(+))
       filter("P"."ID"="S"."FK_PRISONER"(+))
 101 - filter(:BLOCK_NUMBER IS NULL OR "PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
 104 - filter("P"."SEX"=TO_NUMBER(:SEX) OR :SEX IS NULL)
 105 - access("P"."ID"="PB"."ID"(+))
       filter("P"."ID"="PB"."ID"(+))
 107 - access("PB"."ID"="C"."FK_BLOCK")
 109 - access("C"."ID"="A"."FK_CELL")
 110 - filter("A"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD') AND ("A"."END_DATE" IS NULL OR 
              "A"."END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD')))
 112 - access("P"."ID"="R"."FK_PRISONER"(+))
       filter("P"."ID"="R"."FK_PRISONER"(+))
 114 - access("P"."ID"="A"."FK_PRISONER"(+))
       filter("P"."ID"="A"."FK_PRISONER"(+))
 116 - access("P"."ID"="S"."FK_PRISONER"(+))
       filter("P"."ID"="S"."FK_PRISONER"(+))
 
Note
-----
   - this is an adaptive plan
```
])

#pagebreak()

== Zmiana danych 1

#description[Zwolnienie wszystkich strażników ze stażem mniejszym niż `experience_months` miesięcy, którzy nie mają zaplanowanych patroli w przyszłości oraz patrolowali blok `block_number` w określonym przedziale czasowym (`start_time` - `end_time`).]

#sql[
```

UPDATE guard
SET dismissal_date = to_date(:now, 'YYYY-MM-DD')
WHERE months_between(to_timestamp(:now, 'YYYY-MM-DD HH24:MI:SS'), guard.employment_date) < :experience_months
  AND dismissal_date IS NULL
  AND id NOT IN
    (SELECT guard.id
     FROM guard
     INNER JOIN patrol ON guard.id = patrol.fk_guard
     INNER JOIN patrol_slot ON patrol.fk_patrol_slot = patrol_slot.id
     WHERE to_char(patrol_slot.start_time, 'YYYY-MM-DD HH24:MI:SS') >= :now
     GROUP BY guard.id,
              guard.first_name,
              guard.last_name)
  AND id IN
    (SELECT guard.id
     FROM guard
     INNER JOIN patrol ON guard.id = patrol.fk_guard
     INNER JOIN patrol_slot ON patrol.fk_patrol_slot = patrol_slot.id
     INNER JOIN prison_block ON patrol.fk_block = prison_block.id
     WHERE to_char(patrol_slot.start_time, 'YYYY-MM-DD HH24:MI:SS') >= :start_time
       AND to_char(patrol_slot.end_time, 'YYYY-MM-DD HH24:MI:SS') <= :end_time
       AND prison_block.block_number = :block_number
     GROUP BY guard.id,
              guard.first_name,
              guard.last_name);
```
]

W poniższym przykładzie nie udało nam się wprowadzić dużego wzrostu kosztu. Jedyne dwie zmiany, jakich dokonaliśmy, to analogiczna do poprzednich przykładów zmiana wywołania funkcji na parametrze na wywołanie funkcji na danych: `patrol_slot.start_time >= to_timestamp(:start_time, 'YYYY-MM-DD HH24:MI:SS')` na `to_char(patrol_slot.start_time, 'YYYY-MM-DD HH24:MI:SS') >= :start_time` oraz wprowadzenie redundantnego grupowania `group by guard.id, guard.first_name, guard.last_name` w podzapytaniu, na którym stosujemy kwantyfikator `IN` / `NOT IN`.

#pagebreak()

#plan([
```
Plan hash value: 1944716788
 
-----------------------------------------------------------------------------------------------------------------
| Id  | Operation                         | Name                        | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------------------
|   0 | UPDATE STATEMENT                  |                             |     1 |    35 | 20278   (1)| 00:00:01 |
|   1 |  UPDATE                           | GUARD                       |       |       |            |          |
|   2 |   NESTED LOOPS SEMI               |                             |     1 |    35 | 20278   (1)| 00:00:01 |
|*  3 |    HASH JOIN ANTI                 |                             |     1 |    33 | 19289   (1)| 00:00:01 |
|*  4 |     TABLE ACCESS FULL             | GUARD                       |   119 |  2380 |    27   (0)| 00:00:01 |
|   5 |     VIEW                          | VW_NSO_1                    |  3243K|    40M| 19253   (1)| 00:00:01 |
|   6 |      NESTED LOOPS                 |                             |  3243K|    80M| 19253   (1)| 00:00:01 |
|   7 |       NESTED LOOPS                |                             |  3244K|    80M| 19253   (1)| 00:00:01 |
|*  8 |        TABLE ACCESS FULL          | PATROL_SLOT                 |  1370 | 21920 |    34   (3)| 00:00:01 |
|*  9 |        INDEX RANGE SCAN           | PATROL_FK_PATROL_SLOT_INDEX |  2368 |       |     5   (0)| 00:00:01 |
|  10 |       TABLE ACCESS BY INDEX ROWID | PATROL                      |  2368 | 23680 |    14   (0)| 00:00:01 |
|  11 |    VIEW PUSHED PREDICATE          | VW_NSO_2                    |     1 |     2 |   989   (1)| 00:00:01 |
|  12 |     NESTED LOOPS                  |                             |     1 |    47 |   989   (1)| 00:00:01 |
|  13 |      NESTED LOOPS                 |                             |   161K|    47 |   989   (1)| 00:00:01 |
|  14 |       NESTED LOOPS                |                             |    68 |  2312 |    35   (3)| 00:00:01 |
|  15 |        TABLE ACCESS BY INDEX ROWID| PRISON_BLOCK                |     1 |     7 |     1   (0)| 00:00:01 |
|* 16 |         INDEX UNIQUE SCAN         | SYS_C008242                 |     1 |       |     0   (0)| 00:00:01 |
|* 17 |        TABLE ACCESS FULL          | PATROL_SLOT                 |    68 |  1836 |    34   (3)| 00:00:01 |
|* 18 |       INDEX RANGE SCAN            | PATROL_FK_PATROL_SLOT_INDEX |  2368 |       |     5   (0)| 00:00:01 |
|* 19 |      TABLE ACCESS BY INDEX ROWID  | PATROL                      |     1 |    13 |    14   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access("ID"="ID")
   4 - filter("DISMISSAL_DATE" IS NULL AND MONTHS_BETWEEN(TO_TIMESTAMP(:NOW,'YYYY-MM-DD 
              HH24:MI:SS'),INTERNAL_FUNCTION("GUARD"."EMPLOYMENT_DATE"))<:EXPERIENCE_MONTHS)
   8 - filter("PATROL_SLOT"."START_TIME">=TO_TIMESTAMP(:NOW,'YYYY-MM-DD HH24:MI:SS'))
   9 - access("PATROL"."FK_PATROL_SLOT"="PATROL_SLOT"."ID")
  16 - access("PRISON_BLOCK"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  17 - filter("PATROL_SLOT"."START_TIME">=TO_TIMESTAMP(:START_TIME,'YYYY-MM-DD HH24:MI:SS') AND 
              "PATROL_SLOT"."END_TIME"<=TO_TIMESTAMP(:END_TIME,'YYYY-MM-DD HH24:MI:SS'))
  18 - access("PATROL"."FK_PATROL_SLOT"="PATROL_SLOT"."ID")
  19 - filter("PATROL"."FK_GUARD"="ID" AND "PATROL"."FK_BLOCK"="PRISON_BLOCK"."ID")
 
Note
-----
   - this is an adaptive plan
```
], [
```
Plan hash value: 4220876432
 
--------------------------------------------------------------------------------------------------------------------
| Id  | Operation                            | Name                        | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------------------------
|   0 | UPDATE STATEMENT                     |                             |     1 |    35 | 20358   (1)| 00:00:01 |
|   1 |  UPDATE                              | GUARD                       |       |       |            |          |
|   2 |   NESTED LOOPS SEMI                  |                             |     1 |    35 | 20358   (1)| 00:00:01 |
|*  3 |    HASH JOIN ANTI                    |                             |     1 |    33 | 19368   (1)| 00:00:01 |
|*  4 |     TABLE ACCESS FULL                | GUARD                       |   119 |  2380 |    27   (0)| 00:00:01 |
|   5 |     VIEW                             | VW_NSO_1                    | 13140 |   166K| 19341   (1)| 00:00:01 |
|   6 |      NESTED LOOPS SEMI               |                             | 13140 |   461K| 19341   (1)| 00:00:01 |
|   7 |       VIEW                           | VW_GBF_20                   | 13140 |   166K| 19340   (1)| 00:00:01 |
|   8 |        SORT GROUP BY                 |                             | 13140 |   333K| 19340   (1)| 00:00:01 |
|   9 |         NESTED LOOPS                 |                             |  3243K|    80M| 19253   (1)| 00:00:01 |
|  10 |          NESTED LOOPS                |                             |  3244K|    80M| 19253   (1)| 00:00:01 |
|* 11 |           TABLE ACCESS FULL          | PATROL_SLOT                 |  1370 | 21920 |    34   (3)| 00:00:01 |
|* 12 |           INDEX RANGE SCAN           | PATROL_FK_PATROL_SLOT_INDEX |  2368 |       |     5   (0)| 00:00:01 |
|  13 |          TABLE ACCESS BY INDEX ROWID | PATROL                      |  2368 | 23680 |    14   (0)| 00:00:01 |
|* 14 |       INDEX UNIQUE SCAN              | SYS_C008254                 |     1 |    23 |     0   (0)| 00:00:01 |
|  15 |    VIEW PUSHED PREDICATE             | VW_NSO_2                    |     1 |     2 |   990   (1)| 00:00:01 |
|  16 |     NESTED LOOPS                     |                             |     1 |    36 |   990   (1)| 00:00:01 |
|* 17 |      INDEX UNIQUE SCAN               | SYS_C008254                 |     1 |    23 |     1   (0)| 00:00:01 |
|  18 |      VIEW                            | VW_GBF_56                   |     1 |    13 |   989   (1)| 00:00:01 |
|  19 |       SORT GROUP BY                  |                             |     1 |    47 |   989   (1)| 00:00:01 |
|  20 |        NESTED LOOPS                  |                             |     1 |    47 |   989   (1)| 00:00:01 |
|  21 |         NESTED LOOPS                 |                             |   161K|    47 |   989   (1)| 00:00:01 |
|  22 |          NESTED LOOPS                |                             |    68 |  2312 |    35   (3)| 00:00:01 |
|  23 |           TABLE ACCESS BY INDEX ROWID| PRISON_BLOCK                |     1 |     7 |     1   (0)| 00:00:01 |
|* 24 |            INDEX UNIQUE SCAN         | SYS_C008242                 |     1 |       |     0   (0)| 00:00:01 |
|* 25 |           TABLE ACCESS FULL          | PATROL_SLOT                 |    68 |  1836 |    34   (3)| 00:00:01 |
|* 26 |          INDEX RANGE SCAN            | PATROL_FK_PATROL_SLOT_INDEX |  2368 |       |     5   (0)| 00:00:01 |
|* 27 |         TABLE ACCESS BY INDEX ROWID  | PATROL                      |     1 |    13 |    14   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access("ID"="ID")
   4 - filter("DISMISSAL_DATE" IS NULL AND MONTHS_BETWEEN(TO_TIMESTAMP(:NOW,'YYYY-MM-DD 
              HH24:MI:SS'),INTERNAL_FUNCTION("GUARD"."EMPLOYMENT_DATE"))<:EXPERIENCE_MONTHS)
  11 - filter(TO_CHAR(INTERNAL_FUNCTION("PATROL_SLOT"."START_TIME"),'YYYY-MM-DD HH24:MI:SS')>=:NOW)
  12 - access("PATROL"."FK_PATROL_SLOT"="PATROL_SLOT"."ID")
  14 - access("GUARD"."ID"="ITEM_1")
  17 - access("GUARD"."ID"="ID")
  24 - access("PRISON_BLOCK"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  25 - filter(TO_CHAR(INTERNAL_FUNCTION("PATROL_SLOT"."START_TIME"),'YYYY-MM-DD HH24:MI:SS')>=:START_TIME 
              AND TO_CHAR(INTERNAL_FUNCTION("PATROL_SLOT"."END_TIME"),'YYYY-MM-DD HH24:MI:SS')<=:END_TIME)
  26 - access("PATROL"."FK_PATROL_SLOT"="PATROL_SLOT"."ID")
  27 - filter("PATROL"."FK_GUARD"="ID" AND "PATROL"."FK_BLOCK"="PRISON_BLOCK"."ID")
```
])

== Zmiana danych 2

#description[Wygenerowanie wart (patrol slot) w przedziale czasowym (`start_time` - `end_time`) z określonym czasem trwania patrolu w minutach `slot_duration`.]

#sql[
```
INSERT INTO patrol_slot (start_time, end_time)
SELECT to_timestamp(:start+TIME, 'YYYY-MM-DD HH24:MI:SS') + (interval '1' MINUTE * :slot_duration * LEVEL) AS start_time,
       to_timestamp(:start_time, 'YYYY-MM-DD HH24:MI:SS') + (interval '1' MINUTE * :slot_duration * (LEVEL + 1) - interval '1' SECOND) AS end_time
FROM dual CONNECT BY LEVEL <= trunc(extract(DAY
                                            FROM(to_timestamp(:end_time, 'YYYY-MM-DD HH24:MI:SS') - to_timestamp(:start_time, 'YYYY-MM-DD HH24:MI:SS')) * 24 * 60) / :slot_duration)
```
]

#pagebreak()

Już w poprzednim etapie raportowaliśmy problemy związane z tym zapytaniem. Zauważyliśmy, że nie zależy ono od żadnej z istniejących w naszej bazie danych tabel. W związku z tym, próby jego pogarszania jak i optymalizacji nie przyniosłyby żadnych rezultatów. Jako że w ramach etapu 2 utworzyliśmy cztery kwerendy zmieniające dane, a wymagane były jedynie trzy, *podjęliśmy decyzję o usunięciu tego zapytania* z naszego zestawu. Dla kompletności, poniżej znajduje się plan dla tego zapytania.

#plan([
```
Plan hash value: 2763155797
 
---------------------------------------------------------------------------------------
| Id  | Operation                      | Name         | Rows  | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT               |              |     1 |     2   (0)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL       | PATROL_SLOT  |       |            |          |
|   2 |   SEQUENCE                     | ISEQ$$_75800 |       |            |          |
|*  3 |    CONNECT BY WITHOUT FILTERING|              |       |            |          |
|   4 |     FAST DUAL                  |              |     1 |     2   (0)| 00:00:01 |
---------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - filter(LEVEL<=TRUNC(EXTRACT(DAY FROM INTERVAL'+000527039 
              23:36:00.000000000' DAY(9) TO SECOND(9))/15))
```
])

== Zmiana danych 3

#description[Umieszczenie więźniów, którzy w przedziale czasowym (`start_date` - `end_date`) dostali reprymendę zawierającą w treści `event_type` do wolnej izolatki w bloku `block_id` z obecnego zakwaterowania. Jeżeli wolnych izolatek nie ma, to więźniowie pozostają w swoich celach.]

#sql[
```

INSERT INTO accommodation (fk_cell, fk_prisoner, start_date, end_date)
SELECT c.id AS fk_cell,
       p.id AS fk_prisoner,
       to_timestamp(:now, 'YYYY-MM-DD HH24:MI:SS') AS start_date,
       NULL AS end_date
FROM
  (SELECT min(rownum) AS n,
          min(p.id) AS id
   FROM prisoner p
   INNER JOIN reprimand r ON p.id = r.fk_prisoner
   WHERE to_char(r.issue_date, 'YYYY-MM-DD') BETWEEN :start_date AND :end_date
     AND (:event_type IS NULL
          OR instr(r.reason, :event_type) > 0)
   GROUP BY p.pesel) p
INNER JOIN
  (SELECT rownum AS n,
          c.id
   FROM cell c
   INNER JOIN prison_block pb ON pb.id = c.fk_block
   WHERE pb.block_number = :block_number
     AND c.is_solitary = 1
     AND c.id NOT IN
       (SELECT fk_cell
        FROM accommodation a
        WHERE (a.end_date IS NULL
               OR to_char(a.end_date, 'YYYY-MM-DD HH24:MI:SS') >= :now)
          AND to_char(a.start_date, 'YYYY-MM-DD HH24:MI:SS') <= :now
        GROUP BY fk_cell)) c ON p.n = c.n;
```
]

W zmianie danych nr 3 ponownie zastosowaliśmy redundantne operacje grupowania oraz wykorzystaliśmy kolumnę PESEL zamiast klucza głównego więźnia.

#plan([
```
Plan hash value: 2065737253
 
----------------------------------------------------------------------------------------------------
| Id  | Operation                          | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                   |               |  1084 | 56368 |  3325   (2)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL           | ACCOMMODATION |       |       |            |          |
|   2 |   SEQUENCE                         | ISEQ$$_75806  |       |       |            |          |
|*  3 |    HASH JOIN                       |               |  1084 | 56368 |  3325   (2)| 00:00:01 |
|   4 |     VIEW                           |               |    91 |  2366 |  1223   (1)| 00:00:01 |
|   5 |      COUNT                         |               |       |       |            |          |
|*  6 |       FILTER                       |               |       |       |            |          |
|*  7 |        TABLE ACCESS FULL           | REPRIMAND     |    91 |  6734 |  1223   (1)| 00:00:01 |
|   8 |     VIEW                           |               |  1191 | 30966 |  2101   (2)| 00:00:01 |
|   9 |      COUNT                         |               |       |       |            |          |
|* 10 |       HASH JOIN ANTI               |               |  1191 | 46449 |  2101   (2)| 00:00:01 |
|  11 |        NESTED LOOPS                |               |  1295 | 23310 |   326   (1)| 00:00:01 |
|  12 |         TABLE ACCESS BY INDEX ROWID| PRISON_BLOCK  |     1 |     7 |     1   (0)| 00:00:01 |
|* 13 |          INDEX UNIQUE SCAN         | SYS_C008242   |     1 |       |     0   (0)| 00:00:01 |
|* 14 |         TABLE ACCESS FULL          | CELL          |  1295 | 14245 |   325   (1)| 00:00:01 |
|* 15 |        TABLE ACCESS FULL           | ACCOMMODATION |  9577 |   196K|  1775   (3)| 00:00:01 |
----------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access("P"."N"="C"."N")
   6 - filter(TO_DATE(:END_DATE,'YYYY-MM-DD')>=TO_DATE(:START_DATE,'YYYY-MM-DD'))
   7 - filter((:EVENT_TYPE IS NULL OR INSTR("R"."REASON",:EVENT_TYPE)>0) AND 
              "R"."ISSUE_DATE">=TO_DATE(:START_DATE,'YYYY-MM-DD') AND 
              "R"."ISSUE_DATE"<=TO_DATE(:END_DATE,'YYYY-MM-DD'))
  10 - access("C"."ID"="FK_CELL")
  13 - access("PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  14 - filter("PB"."ID"="C"."FK_BLOCK" AND "C"."IS_SOLITARY"=1)
  15 - filter(INTERNAL_FUNCTION("A"."START_DATE")<=TO_TIMESTAMP(:NOW,'YYYY-MM-DD 
              HH24:MI:SS') AND ("A"."END_DATE" IS NULL OR INTERNAL_FUNCTION("A"."END_DATE")>=TO_TIMESTAMP(
              :NOW,'YYYY-MM-DD HH24:MI:SS')))
```
], [
```
Plan hash value: 3737721188
 
-----------------------------------------------------------------------------------------------------
| Id  | Operation                           | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                    |               |  1084 | 56368 |  3409   (2)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL            | ACCOMMODATION |       |       |            |          |
|   2 |   SEQUENCE                          | ISEQ$$_75806  |       |       |            |          |
|*  3 |    HASH JOIN                        |               |  1084 | 56368 |  3409   (2)| 00:00:01 |
|   4 |     VIEW                            |               |    91 |  2366 |  1315   (1)| 00:00:01 |
|   5 |      SORT GROUP BY                  |               |    91 |  8281 |  1315   (1)| 00:00:01 |
|   6 |       COUNT                         |               |       |       |            |          |
|*  7 |        FILTER                       |               |       |       |            |          |
|   8 |         NESTED LOOPS                |               |    91 |  8281 |  1314   (1)| 00:00:01 |
|   9 |          NESTED LOOPS               |               |    91 |  8281 |  1314   (1)| 00:00:01 |
|* 10 |           TABLE ACCESS FULL         | REPRIMAND     |    91 |  6734 |  1223   (1)| 00:00:01 |
|* 11 |           INDEX UNIQUE SCAN         | SYS_C008234   |     1 |       |     0   (0)| 00:00:01 |
|  12 |          TABLE ACCESS BY INDEX ROWID| PRISONER      |     1 |    17 |     1   (0)| 00:00:01 |
|  13 |     VIEW                            |               |  1191 | 30966 |  2093   (2)| 00:00:01 |
|  14 |      COUNT                          |               |       |       |            |          |
|* 15 |       HASH JOIN ANTI                |               |  1191 | 36921 |  2093   (2)| 00:00:01 |
|  16 |        NESTED LOOPS                 |               |  1295 | 23310 |   326   (1)| 00:00:01 |
|  17 |         TABLE ACCESS BY INDEX ROWID | PRISON_BLOCK  |     1 |     7 |     1   (0)| 00:00:01 |
|* 18 |          INDEX UNIQUE SCAN          | SYS_C008242   |     1 |       |     0   (0)| 00:00:01 |
|* 19 |         TABLE ACCESS FULL           | CELL          |  1295 | 14245 |   325   (1)| 00:00:01 |
|  20 |        VIEW                         | VW_NSO_1      |  9577 |   121K|  1767   (2)| 00:00:01 |
|  21 |         SORT GROUP BY               |               |  9577 |   196K|  1767   (2)| 00:00:01 |
|* 22 |          TABLE ACCESS FULL          | ACCOMMODATION |  9577 |   196K|  1766   (2)| 00:00:01 |
-----------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access("P"."N"="C"."N")
   7 - filter(:END_DATE>=:START_DATE)
  10 - filter((:EVENT_TYPE IS NULL OR INSTR("R"."REASON",:EVENT_TYPE)>0) AND 
              TO_CHAR(INTERNAL_FUNCTION("R"."ISSUE_DATE"),'YYYY-MM-DD')>=:START_DATE AND 
              TO_CHAR(INTERNAL_FUNCTION("R"."ISSUE_DATE"),'YYYY-MM-DD')<=:END_DATE)
  11 - access("P"."ID"="R"."FK_PRISONER")
  15 - access("C"."ID"="FK_CELL")
  18 - access("PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  19 - filter("PB"."ID"="C"."FK_BLOCK" AND "C"."IS_SOLITARY"=1)
  22 - filter(TO_CHAR(INTERNAL_FUNCTION("A"."START_DATE"),'YYYY-MM-DD HH24:MI:SS')<=:NOW AND 
              ("A"."END_DATE" IS NULL OR TO_CHAR(INTERNAL_FUNCTION("A"."END_DATE"),'YYYY-MM-DD 
              HH24:MI:SS')>=:NOW))
```
])

== Zmiana danych 4

#description[Wystawienie reprymendy o treści `reason` przez strażnika `guard_id` wszystkim więźniom niebędącym w izolatce i znajdującym się w bloku `block_number` w momencie `event_time`.]

#sql[
```

INSERT INTO reprimand (fk_guard, fk_prisoner, reason, issue_date)
SELECT :guard_id AS fk_guard,
       p.id AS fk_prisoner,
       :reason AS reason,
       cast(to_timestamp(:event_time, 'YYYY-MM-DD HH24:MI:SS') AS date) AS issue_date
FROM prisoner p
INNER JOIN accommodation a ON p.id = a.fk_prisoner
INNER JOIN cell c ON a.fk_cell = c.id
INNER JOIN prison_block pb ON c.fk_block = pb.id
WHERE pb.block_number = :block_number
  AND a.start_date <= to_timestamp(:event_time, 'YYYY-MM-DD HH24:MI:SS')
  AND (a.end_date IS NULL
       OR a.end_date >= to_timestamp(:event_time, 'YYYY-MM-DD HH24:MI:SS'))
  AND c.is_solitary = 0;
```
]

#plan([
```
Plan hash value: 244708335
 
-------------------------------------------------------------------------------------------------
| Id  | Operation                       | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                |               |   106 |  4664 |  2101   (2)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL        | REPRIMAND     |       |       |            |          |
|   2 |   SEQUENCE                      | ISEQ$$_75815  |       |       |            |          |
|*  3 |    HASH JOIN                    |               |   106 |  4664 |  2101   (2)| 00:00:01 |
|   4 |     NESTED LOOPS                |               |  1295 | 23310 |   326   (1)| 00:00:01 |
|   5 |      TABLE ACCESS BY INDEX ROWID| PRISON_BLOCK  |     1 |     7 |     1   (0)| 00:00:01 |
|*  6 |       INDEX UNIQUE SCAN         | SYS_C008242   |     1 |       |     0   (0)| 00:00:01 |
|*  7 |      TABLE ACCESS FULL          | CELL          |  1295 | 14245 |   325   (1)| 00:00:01 |
|*  8 |     TABLE ACCESS FULL           | ACCOMMODATION |  9577 |   243K|  1775   (3)| 00:00:01 |
-------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access("A"."FK_CELL"="C"."ID")
   6 - access("PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
   7 - filter("C"."FK_BLOCK"="PB"."ID" AND "C"."IS_SOLITARY"=0)
   8 - filter(INTERNAL_FUNCTION("A"."START_DATE")<=TO_TIMESTAMP(:EVENT_TIME,'YYYY-MM-DD 
              HH24:MI:SS') AND ("A"."END_DATE" IS NULL OR INTERNAL_FUNCTION("A"."END_DATE")>=TO_TIMESTA
              MP(:EVENT_TIME,'YYYY-MM-DD HH24:MI:SS')))
```
])
