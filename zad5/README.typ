#set page(flipped: true)
#let plan(..children) = [
  #show raw: it => [
    #set text(font: "Liberation Mono", size: if children.pos().len() == 1 { 8pt } else { 4pt })
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

== Wstęp

// TODO: opisać że po lewej stronie jest zawsze pierwotny plan, a po prawej finalny

== Modyfikacja zapytań

// TODO: opis modyfikacji od poprzedniego zadania

== Zapytanie 1

// TODO: opis pogorszenia

#plan([
```
Plan hash value: 3671726907
 
------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                | Name                        | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                         |                             |    68 |  1836 |  1628   (3)| 00:00:01 |
|   1 |  SORT GROUP BY                           |                             |     1 |   284 |            |          |
|*  2 |   VIEW                                   |                             |     5 |  1420 |    46   (3)| 00:00:01 |
|*  3 |    WINDOW SORT PUSHED RANK               |                             |     5 |   420 |    46   (3)| 00:00:01 |
|*  4 |     FILTER                               |                             |       |       |            |          |
|*  5 |      HASH JOIN OUTER                     |                             |     5 |   420 |    45   (0)| 00:00:01 |
|   6 |       NESTED LOOPS                       |                             |     7 |   476 |    29   (0)| 00:00:01 |
|   7 |        TABLE ACCESS BY INDEX ROWID       | PATROL_SLOT                 |     1 |    27 |     2   (0)| 00:00:01 |
|*  8 |         INDEX UNIQUE SCAN                | SYS_C008259                 |     1 |       |     1   (0)| 00:00:01 |
|*  9 |        TABLE ACCESS FULL                 | GUARD                       |     7 |   287 |    27   (0)| 00:00:01 |
|  10 |       TABLE ACCESS BY INDEX ROWID BATCHED| PATROL                      |  2368 | 37888 |    16   (0)| 00:00:01 |
|* 11 |        INDEX RANGE SCAN                  | PATROL_FK_PATROL_SLOT_INDEX |  2368 |       |     7   (0)| 00:00:01 |
|* 12 |  TABLE ACCESS FULL                       | PATROL_SLOT                 |    68 |  1836 |    34   (3)| 00:00:01 |
------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - filter("from$_subquery$_008"."rowlimit_$$_rownumber"<=:PROPOSAL_COUNT)
   3 - filter(ROW_NUMBER() OVER ( ORDER BY "DBMS_RANDOM"."VALUE"())<=:PROPOSAL_COUNT)
   4 - filter("P"."ID" IS NULL)
   5 - access("P"."FK_GUARD"(+)="G"."ID" AND "P"."FK_PATROL_SLOT"(+)="PS"."ID")
   8 - access("PS"."ID"=:B1)
   9 - filter(("G"."HAS_DISABILITY_CLASS"=:HAS_DISABILITY_CLASS OR :HAS_DISABILITY_CLASS IS NULL) AND 
              "PS"."START_TIME">=INTERNAL_FUNCTION("G"."EMPLOYMENT_DATE") AND ("G"."DISMISSAL_DATE" IS NULL OR 
              "PS"."END_TIME"<=INTERNAL_FUNCTION("G"."DISMISSAL_DATE")) AND (:EXPERIENCE_MONTHS IS NULL OR 
              MONTHS_BETWEEN(INTERNAL_FUNCTION("PS"."START_TIME"),INTERNAL_FUNCTION("G"."EMPLOYMENT_DATE"))>=:EXPERIENCE_MONTH
              S))
  11 - access("P"."FK_PATROL_SLOT"(+)=:B1)
  12 - filter("PS"."START_TIME">=TO_TIMESTAMP(:START_TIME,'YYYY-MM-DD HH24:MI:SS') AND 
              "PS"."END_TIME"<=TO_TIMESTAMP(:END_TIME,'YYYY-MM-DD HH24:MI:SS'))
```
], [])

== Zapytanie 2

// TODO: opis pogorszenia

#plan([
```
Plan hash value: 1379684122
 
-------------------------------------------------------------------------------------------------------------
| Id  | Operation                           | Name          | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |               |     1 |    78 |       |  7139   (2)| 00:00:01 |
|   1 |  HASH GROUP BY                      |               |     1 |    78 |       |  7139   (2)| 00:00:01 |
|   2 |   NESTED LOOPS                      |               |     1 |    78 |       |  7138   (2)| 00:00:01 |
|   3 |    NESTED LOOPS                     |               |     1 |    78 |       |  7138   (2)| 00:00:01 |
|   4 |     NESTED LOOPS                    |               |     1 |    71 |       |  7137   (2)| 00:00:01 |
|*  5 |      HASH JOIN                      |               |     1 |    60 |       |  7136   (2)| 00:00:01 |
|*  6 |       HASH JOIN                     |               |     1 |    34 |       |  5371   (1)| 00:00:01 |
|   7 |        JOIN FILTER CREATE           | :BF0000       |     1 |    29 |       |  1218   (1)| 00:00:01 |
|   8 |         NESTED LOOPS                |               |     1 |    29 |       |  1218   (1)| 00:00:01 |
|   9 |          NESTED LOOPS               |               |     1 |    29 |       |  1218   (1)| 00:00:01 |
|  10 |           VIEW                      |               |     1 |     5 |       |  1217   (1)| 00:00:01 |
|* 11 |            FILTER                   |               |       |       |       |            |          |
|  12 |             SORT GROUP BY           |               |     1 |    72 |       |  1217   (1)| 00:00:01 |
|* 13 |              TABLE ACCESS FULL      | SENTENCE      |  8470 |   595K|       |  1216   (1)| 00:00:01 |
|* 14 |           INDEX UNIQUE SCAN         | SYS_C008234   |     1 |       |       |     0   (0)| 00:00:01 |
|* 15 |          TABLE ACCESS BY INDEX ROWID| PRISONER      |     1 |    24 |       |     1   (0)| 00:00:01 |
|  16 |        VIEW                         |               |    24 |   120 |       |  4154   (1)| 00:00:01 |
|* 17 |         FILTER                      |               |       |       |       |            |          |
|  18 |          HASH GROUP BY              |               |    24 |   600 |       |  4154   (1)| 00:00:01 |
|* 19 |           HASH JOIN RIGHT OUTER     |               |   709K|    16M|  7992K|  4136   (1)| 00:00:01 |
|  20 |            TABLE ACCESS FULL        | REPRIMAND     |   371K|  3630K|       |  1221   (1)| 00:00:01 |
|  21 |            JOIN FILTER USE          | :BF0000       |   412K|  6041K|       |  1996   (1)| 00:00:01 |
|* 22 |             HASH JOIN OUTER         |               |   412K|  6041K|  4400K|  1996   (1)| 00:00:01 |
|  23 |              INDEX FAST FULL SCAN   | SYS_C008234   |   264K|  1291K|       |   137   (1)| 00:00:01 |
|  24 |              TABLE ACCESS FULL      | SENTENCE      |   416K|  4070K|       |  1209   (1)| 00:00:01 |
|* 25 |       TABLE ACCESS FULL             | ACCOMMODATION |  9279 |   235K|       |  1764   (2)| 00:00:01 |
|* 26 |      TABLE ACCESS BY INDEX ROWID    | CELL          |     1 |    11 |       |     1   (0)| 00:00:01 |
|* 27 |       INDEX UNIQUE SCAN             | SYS_C008269   |     1 |       |       |     0   (0)| 00:00:01 |
|* 28 |     INDEX UNIQUE SCAN               | SYS_C008241   |     1 |       |       |     0   (0)| 00:00:01 |
|  29 |    TABLE ACCESS BY INDEX ROWID      | PRISON_BLOCK  |     1 |     7 |       |     1   (0)| 00:00:01 |
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
  13 - filter("S"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD') AND ("S"."REAL_END_DATE" IS NULL OR 
              "S"."REAL_END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD')))
  14 - access("P"."ID"="PS"."ID")
  15 - filter((:MIN_HEIGHT_M IS NULL OR "P"."HEIGHT_M">=TO_NUMBER(:MIN_HEIGHT_M)) AND (:MAX_HEIGHT_M 
              IS NULL OR "P"."HEIGHT_M"<=TO_NUMBER(:MAX_HEIGHT_M)) AND (:MIN_WEIGHT_KG IS NULL OR 
              "P"."WEIGHT_KG">=TO_NUMBER(:MIN_WEIGHT_KG)) AND (:MAX_WEIGHT_KG IS NULL OR 
              "P"."WEIGHT_KG"<=TO_NUMBER(:MAX_WEIGHT_KG)) AND ("P"."SEX"=TO_NUMBER(:SEX) OR :SEX IS NULL) AND 
              (:MIN_AGE IS NULL OR MONTHS_BETWEEN(:NOW,INTERNAL_FUNCTION("P"."BIRTHDAY"))>=TO_NUMBER(:MIN_AGE)*12) 
              AND (:MAX_AGE IS NULL OR MONTHS_BETWEEN(:NOW,INTERNAL_FUNCTION("P"."BIRTHDAY"))<=TO_NUMBER(:MAX_AGE)*
              12))
  17 - filter((:MIN_SENTENCES IS NULL OR COUNT("S"."ID")>=TO_NUMBER(:MIN_SENTENCES)) AND 
              (:MAX_SENTENCES IS NULL OR COUNT("S"."ID")<=TO_NUMBER(:MAX_SENTENCES)) AND (:MIN_REPRIMANDS IS NULL 
              OR COUNT("R"."ID")>=TO_NUMBER(:MIN_REPRIMANDS)) AND (:MAX_REPRIMANDS IS NULL OR 
              COUNT("R"."ID")<=TO_NUMBER(:MAX_REPRIMANDS)))
  19 - access("P"."ID"="R"."FK_PRISONER"(+))
  22 - access("P"."ID"="S"."FK_PRISONER"(+))
  25 - filter("A"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD') AND ("A"."END_DATE" IS NULL OR 
              "A"."END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD')))
  26 - filter("C"."IS_SOLITARY"=TO_NUMBER(:IS_IN_SOLITARY) OR :IS_IN_SOLITARY IS NULL)
  27 - access("C"."ID"="A"."FK_CELL")
  28 - access("PB"."ID"="C"."FK_BLOCK")
 
Note
-----
   - this is an adaptive plan
```
], [])

== Zapytanie 3

// TODO: opis pogorszenia

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
], [])

== Zapytanie 4

// TODO: opis pogorszenia

#plan([
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
], [])

== Zmiana 1

// TODO: opis pogorszenia

#plan([
```
Plan hash value: 3671726907
 
------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                | Name                        | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                         |                             |    68 |  1836 |  1628   (3)| 00:00:01 |
|   1 |  SORT GROUP BY                           |                             |     1 |   284 |            |          |
|*  2 |   VIEW                                   |                             |     5 |  1420 |    46   (3)| 00:00:01 |
|*  3 |    WINDOW SORT PUSHED RANK               |                             |     5 |   420 |    46   (3)| 00:00:01 |
|*  4 |     FILTER                               |                             |       |       |            |          |
|*  5 |      HASH JOIN OUTER                     |                             |     5 |   420 |    45   (0)| 00:00:01 |
|   6 |       NESTED LOOPS                       |                             |     7 |   476 |    29   (0)| 00:00:01 |
|   7 |        TABLE ACCESS BY INDEX ROWID       | PATROL_SLOT                 |     1 |    27 |     2   (0)| 00:00:01 |
|*  8 |         INDEX UNIQUE SCAN                | SYS_C008259                 |     1 |       |     1   (0)| 00:00:01 |
|*  9 |        TABLE ACCESS FULL                 | GUARD                       |     7 |   287 |    27   (0)| 00:00:01 |
|  10 |       TABLE ACCESS BY INDEX ROWID BATCHED| PATROL                      |  2368 | 37888 |    16   (0)| 00:00:01 |
|* 11 |        INDEX RANGE SCAN                  | PATROL_FK_PATROL_SLOT_INDEX |  2368 |       |     7   (0)| 00:00:01 |
|* 12 |  TABLE ACCESS FULL                       | PATROL_SLOT                 |    68 |  1836 |    34   (3)| 00:00:01 |
------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - filter("from$_subquery$_008"."rowlimit_$$_rownumber"<=:PROPOSAL_COUNT)
   3 - filter(ROW_NUMBER() OVER ( ORDER BY "DBMS_RANDOM"."VALUE"())<=:PROPOSAL_COUNT)
   4 - filter("P"."ID" IS NULL)
   5 - access("P"."FK_GUARD"(+)="G"."ID" AND "P"."FK_PATROL_SLOT"(+)="PS"."ID")
   8 - access("PS"."ID"=:B1)
   9 - filter(("G"."HAS_DISABILITY_CLASS"=:HAS_DISABILITY_CLASS OR :HAS_DISABILITY_CLASS IS NULL) AND 
              "PS"."START_TIME">=INTERNAL_FUNCTION("G"."EMPLOYMENT_DATE") AND ("G"."DISMISSAL_DATE" IS NULL OR 
              "PS"."END_TIME"<=INTERNAL_FUNCTION("G"."DISMISSAL_DATE")) AND (:EXPERIENCE_MONTHS IS NULL OR 
              MONTHS_BETWEEN(INTERNAL_FUNCTION("PS"."START_TIME"),INTERNAL_FUNCTION("G"."EMPLOYMENT_DATE"))>=:EXPERIENCE_MONTH
              S))
  11 - access("P"."FK_PATROL_SLOT"(+)=:B1)
  12 - filter("PS"."START_TIME">=TO_TIMESTAMP(:START_TIME,'YYYY-MM-DD HH24:MI:SS') AND 
              "PS"."END_TIME"<=TO_TIMESTAMP(:END_TIME,'YYYY-MM-DD HH24:MI:SS'))
```
], [])

== Zmiana 2

// TODO: opis pogorszenia

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

== Zmiana 3

// TODO: opis pogorszenia

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
], [])

== Zmiana 4

// TODO: opis pogorszenia

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
], [])