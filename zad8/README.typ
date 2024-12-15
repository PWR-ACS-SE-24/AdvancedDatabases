#set page(flipped: true)
#set par(justify: true)
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

= Zadanie 8 - Indeksy (część II)

Dla wszystkich indeksó i eksperymentów, aby uzyskać średnią workload był wykonany każdorazowo *10 razy*.

== Indeksy

=== Indeksy b-drzewo dla danych czasowych

#sql[
```
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
```
]

#align(center, include("./test-app/out/only1/table.typ"))

=== Indeks bitmapowy dla rodzaju celi

#sql[
```
create bitmap index cell_is_solitary_idx on
   cell (
      is_solitary
   );
```
]

#align(center, include("./test-app/out/only2/table.typ"))

=== Indeksy funkcyjne dla danych czasowych

#sql[
```
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
```
]

#align(center, include("./test-app/out/only3/table.typ"))

=== Indeksy złożone (b-drzewo) dla odwołań do wielu kolumn

#sql[
```
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
```
]

#align(center, include("./test-app/out/only4/table.typ"))

=== Dodanie indeksów na kluczach obcych

#sql[
```
create index patrol_fk_guard_idx on
   patrol (
      fk_guard
   );
create index patrol_fk_block_idx on
   patrol (
      fk_block
   );
create index cell_fk_block_idx on
   cell (
      fk_block
   );
create index reprimand_fk_guard_idx on
   reprimand (
      fk_guard
   );
create index reprimand_fk_prisoner_idx on
   reprimand (
      fk_prisoner
   );
create index accommodation_fk_cell_idx on
   accommodation (
      fk_cell
   );
create index accommodation_fk_prisoner_idx on
   accommodation (
      fk_prisoner
   );
create index sentence_fk_prisoner_idx on
   sentence (
      fk_prisoner
   );
```
]

#align(center, include("./test-app/out/only5/table.typ"))

=== Nałożenie wszystkich indeksów jednocześnie

#align(center, include("./test-app/out/all/table.typ"))

== Eksperymenty

=== Eksperyment 1 -- porównanie indeksu b--tree, bitmapowego oraz złożonych dla `is_solitary`

==== Indeks b-drzewo

#sql[```
create index cell_is_solitary_btree_idx on
   cell (
      is_solitary
   );
```]

#align(center, include("./test-app/out/e11/table.typ"))

#plan(
   [```
Plan hash value: 4186454845
 
-----------------------------------------------------------------------------------------------------
| Id  | Operation                           | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                    |               |     1 |    52 |  3411   (2)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL            | ACCOMMODATION |       |       |            |          |
|   2 |   SEQUENCE                          | ISEQ$$_75806  |       |       |            |          |
|*  3 |    HASH JOIN                        |               |     1 |    52 |  3411   (2)| 00:00:01 |
|   4 |     VIEW                            |               |     1 |    26 |  2093   (2)| 00:00:01 |
|   5 |      COUNT                          |               |       |       |            |          |
|*  6 |       HASH JOIN ANTI                |               |     1 |    31 |  2093   (2)| 00:00:01 |
|   7 |        NESTED LOOPS                 |               |    51 |   918 |   326   (1)| 00:00:01 |
|   8 |         TABLE ACCESS BY INDEX ROWID | PRISON_BLOCK  |     1 |     7 |     1   (0)| 00:00:01 |
|*  9 |          INDEX UNIQUE SCAN          | SYS_C008242   |     1 |       |     0   (0)| 00:00:01 |
```
#highlight[```
|* 10 |         TABLE ACCESS FULL           | CELL          |    51 |   561 |   325   (1)| 00:00:01 |
```]
```
|  11 |        VIEW                         | VW_NSO_1      |  9418 |   119K|  1767   (2)| 00:00:01 |
|  12 |         SORT GROUP BY               |               |  9418 |   193K|  1767   (2)| 00:00:01 |
|* 13 |          TABLE ACCESS FULL          | ACCOMMODATION |  9577 |   196K|  1766   (2)| 00:00:01 |
|  14 |     VIEW                            |               |    91 |  2366 |  1317   (1)| 00:00:01 |
|  15 |      SORT GROUP BY                  |               |    91 |  8281 |  1317   (1)| 00:00:01 |
|  16 |       COUNT                         |               |       |       |            |          |
|* 17 |        FILTER                       |               |       |       |            |          |
|  18 |         NESTED LOOPS                |               |    91 |  8281 |  1316   (1)| 00:00:01 |
|  19 |          NESTED LOOPS               |               |    91 |  8281 |  1316   (1)| 00:00:01 |
|* 20 |           TABLE ACCESS FULL         | REPRIMAND     |    91 |  6734 |  1225   (1)| 00:00:01 |
|* 21 |           INDEX UNIQUE SCAN         | SYS_C008234   |     1 |       |     0   (0)| 00:00:01 |
|  22 |          TABLE ACCESS BY INDEX ROWID| PRISONER      |     1 |    17 |     1   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access("P"."N"="C"."N")
   6 - access("C"."ID"="FK_CELL")
   9 - access("PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  10 - filter("PB"."ID"="C"."FK_BLOCK" AND "C"."IS_SOLITARY"=1)
  13 - filter(TO_CHAR(INTERNAL_FUNCTION("A"."START_DATE"),'YYYY-MM-DD HH24:MI:SS')<=:NOW AND 
              ("A"."END_DATE" IS NULL OR TO_CHAR(INTERNAL_FUNCTION("A"."END_DATE"),'YYYY-MM-DD 
              HH24:MI:SS')>=:NOW))
  17 - filter(:END_DATE>=:START_DATE)
  20 - filter((:EVENT_TYPE IS NULL OR INSTR("R"."REASON",:EVENT_TYPE)>0) AND 
              TO_CHAR(INTERNAL_FUNCTION("R"."ISSUE_DATE"),'YYYY-MM-DD')>=:START_DATE AND 
              TO_CHAR(INTERNAL_FUNCTION("R"."ISSUE_DATE"),'YYYY-MM-DD')<=:END_DATE)
  21 - access("P"."ID"="R"."FK_PRISONER")
   ```],
   [```
Plan hash value: 770489658
 
-------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                  | Name                       | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                           |                            |     1 |    52 |  3119   (2)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL                   | ACCOMMODATION              |       |       |            |          |
|   2 |   SEQUENCE                                 | ISEQ$$_75806               |       |       |            |          |
|*  3 |    HASH JOIN                               |                            |     1 |    52 |  3119   (2)| 00:00:01 |
|   4 |     VIEW                                   |                            |     1 |    26 |  1801   (2)| 00:00:01 |
|   5 |      COUNT                                 |                            |       |       |            |          |
|*  6 |       HASH JOIN ANTI                       |                            |     1 |    31 |  1801   (2)| 00:00:01 |
|   7 |        NESTED LOOPS                        |                            |    51 |   918 |    34   (0)| 00:00:01 |
|   8 |         TABLE ACCESS BY INDEX ROWID        | PRISON_BLOCK               |     1 |     7 |     1   (0)| 00:00:01 |
|*  9 |          INDEX UNIQUE SCAN                 | SYS_C008242                |     1 |       |     0   (0)| 00:00:01 |
```
#highlight[```
|* 10 |         TABLE ACCESS BY INDEX ROWID BATCHED| CELL                       |    51 |   561 |    33   (0)| 00:00:01 |
|* 11 |          INDEX RANGE SCAN                  | CELL_IS_SOLITARY_BTREE_IDX |  4549 |       |     9   (0)| 00:00:01 |
```]
```
|  12 |        VIEW                                | VW_NSO_1                   |  9418 |   119K|  1767   (2)| 00:00:01 |
|  13 |         SORT GROUP BY                      |                            |  9418 |   193K|  1767   (2)| 00:00:01 |
|* 14 |          TABLE ACCESS FULL                 | ACCOMMODATION              |  9577 |   196K|  1766   (2)| 00:00:01 |
|  15 |     VIEW                                   |                            |    91 |  2366 |  1317   (1)| 00:00:01 |
|  16 |      SORT GROUP BY                         |                            |    91 |  8281 |  1317   (1)| 00:00:01 |
|  17 |       COUNT                                |                            |       |       |            |          |
|* 18 |        FILTER                              |                            |       |       |            |          |
|  19 |         NESTED LOOPS                       |                            |    91 |  8281 |  1316   (1)| 00:00:01 |
|  20 |          NESTED LOOPS                      |                            |    91 |  8281 |  1316   (1)| 00:00:01 |
|* 21 |           TABLE ACCESS FULL                | REPRIMAND                  |    91 |  6734 |  1225   (1)| 00:00:01 |
|* 22 |           INDEX UNIQUE SCAN                | SYS_C008234                |     1 |       |     0   (0)| 00:00:01 |
|  23 |          TABLE ACCESS BY INDEX ROWID       | PRISONER                   |     1 |    17 |     1   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access("P"."N"="C"."N")
   6 - access("C"."ID"="FK_CELL")
   9 - access("PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  10 - filter("PB"."ID"="C"."FK_BLOCK")
  11 - access("C"."IS_SOLITARY"=1)
  14 - filter(TO_CHAR(INTERNAL_FUNCTION("A"."START_DATE"),'YYYY-MM-DD HH24:MI:SS')<=:NOW AND ("A"."END_DATE" IS 
              NULL OR TO_CHAR(INTERNAL_FUNCTION("A"."END_DATE"),'YYYY-MM-DD HH24:MI:SS')>=:NOW))
  18 - filter(:END_DATE>=:START_DATE)
  21 - filter((:EVENT_TYPE IS NULL OR INSTR("R"."REASON",:EVENT_TYPE)>0) AND 
              TO_CHAR(INTERNAL_FUNCTION("R"."ISSUE_DATE"),'YYYY-MM-DD')>=:START_DATE AND 
              TO_CHAR(INTERNAL_FUNCTION("R"."ISSUE_DATE"),'YYYY-MM-DD')<=:END_DATE)
  22 - access("P"."ID"="R"."FK_PRISONER")
   ```]
)

==== Indeks bitmapowy

#sql[```
create bitmap index cell_is_solitary_bitmap_idx on
   cell (
      is_solitary
   );
```]

#align(center, include("./test-app/out/e12/table.typ"))

#plan(
   [```
Plan hash value: 4186454845
 
-----------------------------------------------------------------------------------------------------
| Id  | Operation                           | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                    |               |     1 |    52 |  3411   (2)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL            | ACCOMMODATION |       |       |            |          |
|   2 |   SEQUENCE                          | ISEQ$$_75806  |       |       |            |          |
|*  3 |    HASH JOIN                        |               |     1 |    52 |  3411   (2)| 00:00:01 |
|   4 |     VIEW                            |               |     1 |    26 |  2093   (2)| 00:00:01 |
|   5 |      COUNT                          |               |       |       |            |          |
|*  6 |       HASH JOIN ANTI                |               |     1 |    31 |  2093   (2)| 00:00:01 |
```
#highlight[```
|   7 |        NESTED LOOPS                 |               |    51 |   918 |   326   (1)| 00:00:01 |
|   8 |         TABLE ACCESS BY INDEX ROWID | PRISON_BLOCK  |     1 |     7 |     1   (0)| 00:00:01 |
|*  9 |          INDEX UNIQUE SCAN          | SYS_C008242   |     1 |       |     0   (0)| 00:00:01 |
|* 10 |         TABLE ACCESS FULL           | CELL          |    51 |   561 |   325   (1)| 00:00:01 |
```]
```
|  11 |        VIEW                         | VW_NSO_1      |  9418 |   119K|  1767   (2)| 00:00:01 |
|  12 |         SORT GROUP BY               |               |  9418 |   193K|  1767   (2)| 00:00:01 |
|* 13 |          TABLE ACCESS FULL          | ACCOMMODATION |  9577 |   196K|  1766   (2)| 00:00:01 |
|  14 |     VIEW                            |               |    91 |  2366 |  1317   (1)| 00:00:01 |
|  15 |      SORT GROUP BY                  |               |    91 |  8281 |  1317   (1)| 00:00:01 |
|  16 |       COUNT                         |               |       |       |            |          |
|* 17 |        FILTER                       |               |       |       |            |          |
|  18 |         NESTED LOOPS                |               |    91 |  8281 |  1316   (1)| 00:00:01 |
|  19 |          NESTED LOOPS               |               |    91 |  8281 |  1316   (1)| 00:00:01 |
|* 20 |           TABLE ACCESS FULL         | REPRIMAND     |    91 |  6734 |  1225   (1)| 00:00:01 |
|* 21 |           INDEX UNIQUE SCAN         | SYS_C008234   |     1 |       |     0   (0)| 00:00:01 |
|  22 |          TABLE ACCESS BY INDEX ROWID| PRISONER      |     1 |    17 |     1   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access("P"."N"="C"."N")
   6 - access("C"."ID"="FK_CELL")
   9 - access("PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  10 - filter("PB"."ID"="C"."FK_BLOCK" AND "C"."IS_SOLITARY"=1)
  13 - filter(TO_CHAR(INTERNAL_FUNCTION("A"."START_DATE"),'YYYY-MM-DD HH24:MI:SS')<=:NOW AND 
              ("A"."END_DATE" IS NULL OR TO_CHAR(INTERNAL_FUNCTION("A"."END_DATE"),'YYYY-MM-DD 
              HH24:MI:SS')>=:NOW))
  17 - filter(:END_DATE>=:START_DATE)
  20 - filter((:EVENT_TYPE IS NULL OR INSTR("R"."REASON",:EVENT_TYPE)>0) AND 
              TO_CHAR(INTERNAL_FUNCTION("R"."ISSUE_DATE"),'YYYY-MM-DD')>=:START_DATE AND 
              TO_CHAR(INTERNAL_FUNCTION("R"."ISSUE_DATE"),'YYYY-MM-DD')<=:END_DATE)
  21 - access("P"."ID"="R"."FK_PRISONER")
   ```],
   [```
Plan hash value: 1155780036
 
--------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                  | Name                        | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                           |                             |     1 |    52 |  3351   (2)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL                   | ACCOMMODATION               |       |       |            |          |
|   2 |   SEQUENCE                                 | ISEQ$$_75806                |       |       |            |          |
|*  3 |    HASH JOIN                               |                             |     1 |    52 |  3351   (2)| 00:00:01 |
|   4 |     VIEW                                   |                             |     1 |    26 |  2034   (2)| 00:00:01 |
|   5 |      COUNT                                 |                             |       |       |            |          |
|*  6 |       HASH JOIN ANTI                       |                             |     1 |    31 |  2034   (2)| 00:00:01 |
```
#highlight[```
|*  7 |        HASH JOIN                           |                             |    51 |   918 |   267   (1)| 00:00:01 |
|   8 |         TABLE ACCESS BY INDEX ROWID        | PRISON_BLOCK                |     1 |     7 |     1   (0)| 00:00:01 |
|*  9 |          INDEX UNIQUE SCAN                 | SYS_C008242                 |     1 |       |     0   (0)| 00:00:01 |
|  10 |         TABLE ACCESS BY INDEX ROWID BATCHED| CELL                        |  4549 | 50039 |   266   (1)| 00:00:01 |
|  11 |          BITMAP CONVERSION TO ROWIDS       |                             |       |       |            |          |
|* 12 |           BITMAP INDEX SINGLE VALUE        | CELL_IS_SOLITARY_BITMAP_IDX |       |       |            |          |
```]
```
|  13 |        VIEW                                | VW_NSO_1                    |  9418 |   119K|  1767   (2)| 00:00:01 |
|  14 |         SORT GROUP BY                      |                             |  9418 |   193K|  1767   (2)| 00:00:01 |
|* 15 |          TABLE ACCESS FULL                 | ACCOMMODATION               |  9577 |   196K|  1766   (2)| 00:00:01 |
|  16 |     VIEW                                   |                             |    91 |  2366 |  1317   (1)| 00:00:01 |
|  17 |      SORT GROUP BY                         |                             |    91 |  8281 |  1317   (1)| 00:00:01 |
|  18 |       COUNT                                |                             |       |       |            |          |
|* 19 |        FILTER                              |                             |       |       |            |          |
|  20 |         NESTED LOOPS                       |                             |    91 |  8281 |  1316   (1)| 00:00:01 |
|  21 |          NESTED LOOPS                      |                             |    91 |  8281 |  1316   (1)| 00:00:01 |
|* 22 |           TABLE ACCESS FULL                | REPRIMAND                   |    91 |  6734 |  1225   (1)| 00:00:01 |
|* 23 |           INDEX UNIQUE SCAN                | SYS_C008234                 |     1 |       |     0   (0)| 00:00:01 |
|  24 |          TABLE ACCESS BY INDEX ROWID       | PRISONER                    |     1 |    17 |     1   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access("P"."N"="C"."N")
   6 - access("C"."ID"="FK_CELL")
   7 - access("PB"."ID"="C"."FK_BLOCK")
   9 - access("PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  12 - access("C"."IS_SOLITARY"=1)
  15 - filter(TO_CHAR(INTERNAL_FUNCTION("A"."START_DATE"),'YYYY-MM-DD HH24:MI:SS')<=:NOW AND ("A"."END_DATE" IS 
              NULL OR TO_CHAR(INTERNAL_FUNCTION("A"."END_DATE"),'YYYY-MM-DD HH24:MI:SS')>=:NOW))
  19 - filter(:END_DATE>=:START_DATE)
  22 - filter((:EVENT_TYPE IS NULL OR INSTR("R"."REASON",:EVENT_TYPE)>0) AND 
              TO_CHAR(INTERNAL_FUNCTION("R"."ISSUE_DATE"),'YYYY-MM-DD')>=:START_DATE AND 
              TO_CHAR(INTERNAL_FUNCTION("R"."ISSUE_DATE"),'YYYY-MM-DD')<=:END_DATE)
  23 - access("P"."ID"="R"."FK_PRISONER")
   ```]
)

==== Indeks złożony

#sql[
```
create index cell_is_solitary_composite_idx on
   cell (
      is_solitary,
      fk_block
   );
```]

#align(center, include("./test-app/out/e13/table.typ"))

*`change3`:*
#plan(
   [```
Plan hash value: 4186454845
 
-----------------------------------------------------------------------------------------------------
| Id  | Operation                           | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                    |               |     1 |    52 |  3411   (2)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL            | ACCOMMODATION |       |       |            |          |
|   2 |   SEQUENCE                          | ISEQ$$_75806  |       |       |            |          |
|*  3 |    HASH JOIN                        |               |     1 |    52 |  3411   (2)| 00:00:01 |
|   4 |     VIEW                            |               |     1 |    26 |  2093   (2)| 00:00:01 |
|   5 |      COUNT                          |               |       |       |            |          |
|*  6 |       HASH JOIN ANTI                |               |     1 |    31 |  2093   (2)| 00:00:01 |
|   7 |        NESTED LOOPS                 |               |    51 |   918 |   326   (1)| 00:00:01 |
|   8 |         TABLE ACCESS BY INDEX ROWID | PRISON_BLOCK  |     1 |     7 |     1   (0)| 00:00:01 |
|*  9 |          INDEX UNIQUE SCAN          | SYS_C008242   |     1 |       |     0   (0)| 00:00:01 |
```
#highlight[```
|* 10 |         TABLE ACCESS FULL           | CELL          |    51 |   561 |   325   (1)| 00:00:01 |
```]
```
|  11 |        VIEW                         | VW_NSO_1      |  9418 |   119K|  1767   (2)| 00:00:01 |
|  12 |         SORT GROUP BY               |               |  9418 |   193K|  1767   (2)| 00:00:01 |
|* 13 |          TABLE ACCESS FULL          | ACCOMMODATION |  9577 |   196K|  1766   (2)| 00:00:01 |
|  14 |     VIEW                            |               |    91 |  2366 |  1317   (1)| 00:00:01 |
|  15 |      SORT GROUP BY                  |               |    91 |  8281 |  1317   (1)| 00:00:01 |
|  16 |       COUNT                         |               |       |       |            |          |
|* 17 |        FILTER                       |               |       |       |            |          |
|  18 |         NESTED LOOPS                |               |    91 |  8281 |  1316   (1)| 00:00:01 |
|  19 |          NESTED LOOPS               |               |    91 |  8281 |  1316   (1)| 00:00:01 |
|* 20 |           TABLE ACCESS FULL         | REPRIMAND     |    91 |  6734 |  1225   (1)| 00:00:01 |
|* 21 |           INDEX UNIQUE SCAN         | SYS_C008234   |     1 |       |     0   (0)| 00:00:01 |
|  22 |          TABLE ACCESS BY INDEX ROWID| PRISONER      |     1 |    17 |     1   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access("P"."N"="C"."N")
   6 - access("C"."ID"="FK_CELL")
   9 - access("PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  10 - filter("PB"."ID"="C"."FK_BLOCK" AND "C"."IS_SOLITARY"=1)
  13 - filter(TO_CHAR(INTERNAL_FUNCTION("A"."START_DATE"),'YYYY-MM-DD HH24:MI:SS')<=:NOW AND 
              ("A"."END_DATE" IS NULL OR TO_CHAR(INTERNAL_FUNCTION("A"."END_DATE"),'YYYY-MM-DD 
              HH24:MI:SS')>=:NOW))
  17 - filter(:END_DATE>=:START_DATE)
  20 - filter((:EVENT_TYPE IS NULL OR INSTR("R"."REASON",:EVENT_TYPE)>0) AND 
              TO_CHAR(INTERNAL_FUNCTION("R"."ISSUE_DATE"),'YYYY-MM-DD')>=:START_DATE AND 
              TO_CHAR(INTERNAL_FUNCTION("R"."ISSUE_DATE"),'YYYY-MM-DD')<=:END_DATE)
  21 - access("P"."ID"="R"."FK_PRISONER")
   ```],
   [```
Plan hash value: 3160685875
 
-----------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                  | Name                           | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                           |                                |     1 |    52 |  3093   (2)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL                   | ACCOMMODATION                  |       |       |            |          |
|   2 |   SEQUENCE                                 | ISEQ$$_75806                   |       |       |            |          |
|*  3 |    HASH JOIN                               |                                |     1 |    52 |  3093   (2)| 00:00:01 |
|   4 |     VIEW                                   |                                |     1 |    26 |  1775   (2)| 00:00:01 |
|   5 |      COUNT                                 |                                |       |       |            |          |
|*  6 |       HASH JOIN ANTI                       |                                |     1 |    31 |  1775   (2)| 00:00:01 |
|   7 |        NESTED LOOPS                        |                                |    51 |   918 |     8   (0)| 00:00:01 |
|   8 |         TABLE ACCESS BY INDEX ROWID        | PRISON_BLOCK                   |     1 |     7 |     1   (0)| 00:00:01 |
|*  9 |          INDEX UNIQUE SCAN                 | SYS_C008242                    |     1 |       |     0   (0)| 00:00:01 |
```
#highlight[```
|  10 |         TABLE ACCESS BY INDEX ROWID BATCHED| CELL                           |    51 |   561 |     7   (0)| 00:00:01 |
|* 11 |          INDEX RANGE SCAN                  | CELL_IS_SOLITARY_COMPOSITE_IDX |    51 |       |     6   (0)| 00:00:01 |
```]
```
|  12 |        VIEW                                | VW_NSO_1                       |  9418 |   119K|  1767   (2)| 00:00:01 |
|  13 |         SORT GROUP BY                      |                                |  9418 |   193K|  1767   (2)| 00:00:01 |
|* 14 |          TABLE ACCESS FULL                 | ACCOMMODATION                  |  9577 |   196K|  1766   (2)| 00:00:01 |
|  15 |     VIEW                                   |                                |    91 |  2366 |  1317   (1)| 00:00:01 |
|  16 |      SORT GROUP BY                         |                                |    91 |  8281 |  1317   (1)| 00:00:01 |
|  17 |       COUNT                                |                                |       |       |            |          |
|* 18 |        FILTER                              |                                |       |       |            |          |
|  19 |         NESTED LOOPS                       |                                |    91 |  8281 |  1316   (1)| 00:00:01 |
|  20 |          NESTED LOOPS                      |                                |    91 |  8281 |  1316   (1)| 00:00:01 |
|* 21 |           TABLE ACCESS FULL                | REPRIMAND                      |    91 |  6734 |  1225   (1)| 00:00:01 |
|* 22 |           INDEX UNIQUE SCAN                | SYS_C008234                    |     1 |       |     0   (0)| 00:00:01 |
|  23 |          TABLE ACCESS BY INDEX ROWID       | PRISONER                       |     1 |    17 |     1   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access("P"."N"="C"."N")
   6 - access("C"."ID"="FK_CELL")
   9 - access("PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  11 - access("C"."IS_SOLITARY"=1 AND "PB"."ID"="C"."FK_BLOCK")
  14 - filter(TO_CHAR(INTERNAL_FUNCTION("A"."START_DATE"),'YYYY-MM-DD HH24:MI:SS')<=:NOW AND ("A"."END_DATE" IS NULL 
              OR TO_CHAR(INTERNAL_FUNCTION("A"."END_DATE"),'YYYY-MM-DD HH24:MI:SS')>=:NOW))
  18 - filter(:END_DATE>=:START_DATE)
  21 - filter((:EVENT_TYPE IS NULL OR INSTR("R"."REASON",:EVENT_TYPE)>0) AND 
              TO_CHAR(INTERNAL_FUNCTION("R"."ISSUE_DATE"),'YYYY-MM-DD')>=:START_DATE AND 
              TO_CHAR(INTERNAL_FUNCTION("R"."ISSUE_DATE"),'YYYY-MM-DD')<=:END_DATE)
  22 - access("P"."ID"="R"."FK_PRISONER")
   ```]
)

*`change4`:*
#plan(
   [```
Plan hash value: 244708335
 
-------------------------------------------------------------------------------------------------
| Id  | Operation                       | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                |               |   106 |  4664 |  2101   (2)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL        | REPRIMAND     |       |       |            |          |
|   2 |   SEQUENCE                      | ISEQ$$_75815  |       |       |            |          |
|*  3 |    HASH JOIN                    |               |   106 |  4664 |  2101   (2)| 00:00:01 |
|   4 |     NESTED LOOPS                |               |  2540 | 45720 |   326   (1)| 00:00:01 |
|   5 |      TABLE ACCESS BY INDEX ROWID| PRISON_BLOCK  |     1 |     7 |     1   (0)| 00:00:01 |
|*  6 |       INDEX UNIQUE SCAN         | SYS_C008242   |     1 |       |     0   (0)| 00:00:01 |
```
#highlight[```
|*  7 |      TABLE ACCESS FULL          | CELL          |  2540 | 27940 |   325   (1)| 00:00:01 |
```]
```
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
   ```],
   [```
Plan hash value: 3792824840
 
--------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                               | Name                           | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                        |                                |   106 |  4664 |  1795   (3)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL                | REPRIMAND                      |       |       |            |          |
|   2 |   SEQUENCE                              | ISEQ$$_75815                   |       |       |            |          |
|*  3 |    HASH JOIN                            |                                |   106 |  4664 |  1795   (3)| 00:00:01 |
|   4 |     NESTED LOOPS                        |                                |  2540 | 45720 |    20   (0)| 00:00:01 |
|   5 |      TABLE ACCESS BY INDEX ROWID        | PRISON_BLOCK                   |     1 |     7 |     1   (0)| 00:00:01 |
|*  6 |       INDEX UNIQUE SCAN                 | SYS_C008242                    |     1 |       |     0   (0)| 00:00:01 |
```
#highlight[```
|   7 |      TABLE ACCESS BY INDEX ROWID BATCHED| CELL                           |  2540 | 27940 |    19   (0)| 00:00:01 |
|*  8 |       INDEX RANGE SCAN                  | CELL_IS_SOLITARY_COMPOSITE_IDX |  2540 |       |     6   (0)| 00:00:01 |
```]
```
|*  9 |     TABLE ACCESS FULL                   | ACCOMMODATION                  |  9577 |   243K|  1775   (3)| 00:00:01 |
--------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access("A"."FK_CELL"="C"."ID")
   6 - access("PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
   8 - access("C"."IS_SOLITARY"=0 AND "C"."FK_BLOCK"="PB"."ID")
   9 - filter(INTERNAL_FUNCTION("A"."START_DATE")<=TO_TIMESTAMP(:EVENT_TIME,'YYYY-MM-DD HH24:MI:SS') AND 
              ("A"."END_DATE" IS NULL OR INTERNAL_FUNCTION("A"."END_DATE")>=TO_TIMESTAMP(:EVENT_TIME,'YYYY-MM-DD HH24:MI:SS')))
   ```]
)

=== Eksperyment 2 -- dodawanie indeksów w `MATERIALIZED VIEW`

TODO

=== Eksperyment 3 -- porównanie efektywności indeksowania i partycjonowania dla kolumny `issue_date` w tabeli `reprimand`

TODO
