// #set page(flipped: true)
#let plan(..children) = [
  #show raw: it => [
    #set text(font: "Liberation Mono", size: 4pt)
    #it
  ]
  #grid(
    columns: 2,
    align: (left, right),
    column-gutter: 20pt,
    ..children
  )
]

#align(center)[
  #text(size: 20pt, weight: "bold", )[Zaawansowane systemy baz danych (ZSBD)]

  Zespół B5 (baza danych dla więzienia): \
  *Tomasz Chojnacki (260365), Kamila Iwańska (253027), Jakub Zehner (260285)*
]

= Zadanie 5 - Plany zapytań

== Modyfikacja zapytań

== Zapytanie 1

== Zapytanie 2

== Zapytanie 3

== Zapytanie 4
#plan([
```
Explained.

Plan hash value: 1418518406
 
------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                | Name                      | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                         |                           |     5 |    65 |       |  4752   (1)| 00:00:01 |
|   1 |  TEMP TABLE TRANSFORMATION               |                           |       |       |       |            |          |
|   2 |   LOAD AS SELECT (CURSOR DURATION MEMORY)| SYS_TEMP_0FD9D6623_9D5625 |       |       |       |            |          |
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
|  28 |       TABLE ACCESS FULL                  | SYS_TEMP_0FD9D6623_9D5625 |   138K|  7596K|       |   288   (1)| 00:00:01 |
|  29 |     SORT AGGREGATE                       |                           |     1 |    13 |       |   950   (1)| 00:00:01 |
|  30 |      VIEW                                |                           |   138K|  1763K|       |   288   (1)| 00:00:01 |
|  31 |       TABLE ACCESS FULL                  | SYS_TEMP_0FD9D6623_9D5625 |   138K|  7596K|       |   288   (1)| 00:00:01 |
|  32 |     SORT AGGREGATE                       |                           |     1 |    13 |       |   950   (1)| 00:00:01 |
|  33 |      VIEW                                |                           |   138K|  1763K|       |   288   (1)| 00:00:01 |
|  34 |       TABLE ACCESS FULL                  | SYS_TEMP_0FD9D6623_9D5625 |   138K|  7596K|       |   288   (1)| 00:00:01 |
|  35 |     SORT AGGREGATE                       |                           |     1 |    13 |       |   950   (1)| 00:00:01 |
|  36 |      VIEW                                |                           |   138K|  1763K|       |   288   (1)| 00:00:01 |
|  37 |       TABLE ACCESS FULL                  | SYS_TEMP_0FD9D6623_9D5625 |   138K|  7596K|       |   288   (1)| 00:00:01 |
|  38 |     SORT AGGREGATE                       |                           |     1 |    13 |       |   950   (1)| 00:00:01 |
|  39 |      VIEW                                |                           |   138K|  1763K|       |   288   (1)| 00:00:01 |
|  40 |       TABLE ACCESS FULL                  | SYS_TEMP_0FD9D6623_9D5625 |   138K|  7596K|       |   288   (1)| 00:00:01 |
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

65 rows selected.
```
])

== Zmiana 1

== Zmiana 2

== Zmiana 3

== Zmiana 4
