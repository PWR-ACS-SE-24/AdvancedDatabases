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
    #set text(font: "Liberation Mono", size: if children.pos().len() == 1 { 8pt } else { 4.25pt })
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

*`query2`:*
#plan(
   [```
Plan hash value: 3600760484
 
-------------------------------------------------------------------------------------------------------------
| Id  | Operation                           | Name          | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |               |     1 |    78 |       |  9834   (3)| 00:00:01 |
|   1 |  HASH GROUP BY                      |               |     1 |    78 |       |  9834   (3)| 00:00:01 |
|   2 |   NESTED LOOPS                      |               |     1 |    78 |       |  9833   (3)| 00:00:01 |
|   3 |    NESTED LOOPS                     |               |     1 |    78 |       |  9833   (3)| 00:00:01 |
|   4 |     NESTED LOOPS                    |               |     1 |    71 |       |  9832   (3)| 00:00:01 |
|*  5 |      HASH JOIN                      |               |     1 |    60 |       |  9831   (3)| 00:00:01 |
|*  6 |       HASH JOIN                     |               |     1 |    34 |       |  7742   (2)| 00:00:01 |
|   7 |        JOIN FILTER CREATE           | :BF0000       |     1 |    29 |       |  2046   (2)| 00:00:01 |
|   8 |         NESTED LOOPS                |               |     1 |    29 |       |  2046   (2)| 00:00:01 |
|   9 |          NESTED LOOPS               |               |     1 |    29 |       |  2046   (2)| 00:00:01 |
|  10 |           VIEW                      |               |     1 |     5 |       |  2045   (2)| 00:00:01 |
|* 11 |            FILTER                   |               |       |       |       |            |          |
|  12 |             SORT GROUP BY           |               |     1 |    89 |       |  2045   (2)| 00:00:01 |
|* 13 |              HASH JOIN              |               |  9590 |   833K|       |  2044   (2)| 00:00:01 |
|* 14 |               TABLE ACCESS FULL     | SENTENCE      |  9590 |   674K|       |  1397   (2)| 00:00:01 |
|  15 |               TABLE ACCESS FULL     | PRISONER      |   299K|  4980K|       |   645   (1)| 00:00:01 |
|* 16 |           INDEX UNIQUE SCAN         | SYS_C008848   |     1 |       |       |     0   (0)| 00:00:01 |
|* 17 |          TABLE ACCESS BY INDEX ROWID| PRISONER      |     1 |    24 |       |     1   (0)| 00:00:01 |
|  18 |        VIEW                         |               |    28 |   140 |       |  5696   (2)| 00:00:01 |
|* 19 |         FILTER                      |               |       |       |       |            |          |
|  20 |          JOIN FILTER USE            | :BF0000       |    28 |  1036 |       |  5696   (2)| 00:00:01 |
|  21 |           HASH GROUP BY             |               |    28 |  1036 |       |  5696   (2)| 00:00:01 |
|* 22 |            HASH JOIN RIGHT OUTER    |               |   806K|    28M|  9072K|  5648   (1)| 00:00:01 |
|  23 |             TABLE ACCESS FULL       | REPRIMAND     |   422K|  4122K|       |  1394   (1)| 00:00:01 |
|* 24 |             HASH JOIN OUTER         |               |   468K|    12M|  8496K|  2937   (1)| 00:00:01 |
|  25 |              TABLE ACCESS FULL      | PRISONER      |   299K|  4980K|       |   645   (1)| 00:00:01 |
|  26 |              TABLE ACCESS FULL      | SENTENCE      |   473K|  4620K|       |  1379   (1)| 00:00:01 |
|* 27 |       TABLE ACCESS FULL             | ACCOMMODATION | 10513 |   266K|       |  2088   (4)| 00:00:01 |
|* 28 |      TABLE ACCESS BY INDEX ROWID    | CELL          |     1 |    11 |       |     1   (0)| 00:00:01 |
|* 29 |       INDEX UNIQUE SCAN             | SYS_C008883   |     1 |       |       |     0   (0)| 00:00:01 |
|* 30 |     INDEX UNIQUE SCAN               | SYS_C008855   |     1 |       |       |     0   (0)| 00:00:01 |
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
   ```],
   [```
Plan hash value: 3564657038
 
-----------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                        | Name                         | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                                 |                              |     1 |    78 |       |  9736   (2)| 00:00:01 |
|   1 |  HASH GROUP BY                                   |                              |     1 |    78 |       |  9736   (2)| 00:00:01 |
|   2 |   NESTED LOOPS                                   |                              |     1 |    78 |       |  9735   (2)| 00:00:01 |
|   3 |    NESTED LOOPS                                  |                              |     1 |    78 |       |  9735   (2)| 00:00:01 |
|   4 |     NESTED LOOPS                                 |                              |     1 |    71 |       |  9734   (2)| 00:00:01 |
|   5 |      NESTED LOOPS                                |                              |     1 |    60 |       |  9733   (2)| 00:00:01 |
|*  6 |       HASH JOIN                                  |                              |     1 |    34 |       |  7717   (2)| 00:00:01 |
|   7 |        JOIN FILTER CREATE                        | :BF0000                      |     1 |    29 |       |  2021   (1)| 00:00:01 |
|   8 |         NESTED LOOPS                             |                              |     1 |    29 |       |  2021   (1)| 00:00:01 |
|   9 |          NESTED LOOPS                            |                              |     1 |    29 |       |  2021   (1)| 00:00:01 |
|  10 |           VIEW                                   |                              |     1 |     5 |       |  2020   (1)| 00:00:01 |
|* 11 |            FILTER                                |                              |       |       |       |            |          |
|  12 |             SORT GROUP BY                        |                              |     1 |    89 |       |  2020   (1)| 00:00:01 |
|* 13 |              HASH JOIN                           |                              |  9590 |   833K|       |  2019   (1)| 00:00:01 |
|* 14 |               TABLE ACCESS BY INDEX ROWID BATCHED| SENTENCE                     |  9590 |   674K|       |  1372   (1)| 00:00:01 |
|* 15 |                INDEX RANGE SCAN                  | SENTENCE_START_DATE_IDX      |  4259 |       |       |    14   (0)| 00:00:01 |
|  16 |               TABLE ACCESS FULL                  | PRISONER                     |   299K|  4980K|       |   645   (1)| 00:00:01 |
|* 17 |           INDEX UNIQUE SCAN                      | SYS_C008848                  |     1 |       |       |     0   (0)| 00:00:01 |
|* 18 |          TABLE ACCESS BY INDEX ROWID             | PRISONER                     |     1 |    24 |       |     1   (0)| 00:00:01 |
|  19 |        VIEW                                      |                              |    28 |   140 |       |  5696   (2)| 00:00:01 |
|* 20 |         FILTER                                   |                              |       |       |       |            |          |
|  21 |          JOIN FILTER USE                         | :BF0000                      |    28 |  1036 |       |  5696   (2)| 00:00:01 |
|  22 |           HASH GROUP BY                          |                              |    28 |  1036 |       |  5696   (2)| 00:00:01 |
|* 23 |            HASH JOIN RIGHT OUTER                 |                              |   806K|    28M|  9072K|  5648   (1)| 00:00:01 |
|  24 |             TABLE ACCESS FULL                    | REPRIMAND                    |   422K|  4122K|       |  1394   (1)| 00:00:01 |
|* 25 |             HASH JOIN OUTER                      |                              |   468K|    12M|  8496K|  2937   (1)| 00:00:01 |
|  26 |              TABLE ACCESS FULL                   | PRISONER                     |   299K|  4980K|       |   645   (1)| 00:00:01 |
|  27 |              TABLE ACCESS FULL                   | SENTENCE                     |   473K|  4620K|       |  1379   (1)| 00:00:01 |
|* 28 |       TABLE ACCESS BY INDEX ROWID BATCHED        | ACCOMMODATION                |     1 |    26 |       |  2016   (1)| 00:00:01 |
|* 29 |        INDEX RANGE SCAN                          | ACCOMMODATION_START_DATE_IDX | 13437 |       |       |    37   (0)| 00:00:01 |
|* 30 |      TABLE ACCESS BY INDEX ROWID                 | CELL                         |     1 |    11 |       |     1   (0)| 00:00:01 |
|* 31 |       INDEX UNIQUE SCAN                          | SYS_C008883                  |     1 |       |       |     0   (0)| 00:00:01 |
|* 32 |     INDEX UNIQUE SCAN                            | SYS_C008855                  |     1 |       |       |     0   (0)| 00:00:01 |
|  33 |    TABLE ACCESS BY INDEX ROWID                   | PRISON_BLOCK                 |     1 |     7 |       |     1   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   6 - access("P"."ID"="PC"."ID")
  11 - filter((:CRIME IS NULL OR INSTR(LISTAGG("S"."CRIME",', ') WITHIN GROUP ( ORDER BY "S"."ID"),:CRIME)>0) AND 
              (:MIN_STAY_MONTHS IS NULL OR MONTHS_BETWEEN(:NOW,MIN("S"."START_DATE"))>=TO_NUMBER(:MIN_STAY_MONTHS)) AND (:MAX_STAY_MONTHS IS 
              NULL OR MONTHS_BETWEEN(:NOW,MIN("S"."START_DATE"))<=TO_NUMBER(:MAX_STAY_MONTHS)) AND (:MIN_RELEASE_MONTHS IS NULL OR 
              MONTHS_BETWEEN(MAX("S"."PLANNED_END_DATE"),:NOW)>=TO_NUMBER(:MIN_RELEASE_MONTHS)) AND (:MAX_RELEASE_MONTHS IS NULL OR 
              MONTHS_BETWEEN(MAX("S"."PLANNED_END_DATE"),:NOW)<=TO_NUMBER(:MAX_RELEASE_MONTHS)))
  13 - access("P"."ID"="S"."FK_PRISONER")
  14 - filter("S"."REAL_END_DATE" IS NULL OR "S"."REAL_END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD'))
  15 - access("S"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD'))
  17 - access("P"."ID"="PS"."ID")
  18 - filter((:MIN_HEIGHT_M IS NULL OR "P"."HEIGHT_M">=TO_NUMBER(:MIN_HEIGHT_M)) AND (:MAX_HEIGHT_M IS NULL OR 
              "P"."HEIGHT_M"<=TO_NUMBER(:MAX_HEIGHT_M)) AND (:MIN_WEIGHT_KG IS NULL OR "P"."WEIGHT_KG">=TO_NUMBER(:MIN_WEIGHT_KG)) AND 
              (:MAX_WEIGHT_KG IS NULL OR "P"."WEIGHT_KG"<=TO_NUMBER(:MAX_WEIGHT_KG)) AND ("P"."SEX"=TO_NUMBER(:SEX) OR :SEX IS NULL) AND 
              (:MIN_AGE IS NULL OR MONTHS_BETWEEN(:NOW,INTERNAL_FUNCTION("P"."BIRTHDAY"))>=TO_NUMBER(:MIN_AGE)*12) AND (:MAX_AGE IS NULL OR 
              MONTHS_BETWEEN(:NOW,INTERNAL_FUNCTION("P"."BIRTHDAY"))<=TO_NUMBER(:MAX_AGE)*12))
  20 - filter((:MIN_SENTENCES IS NULL OR COUNT("S"."ID")>=TO_NUMBER(:MIN_SENTENCES)) AND (:MAX_SENTENCES IS NULL OR 
              COUNT("S"."ID")<=TO_NUMBER(:MAX_SENTENCES)) AND (:MIN_REPRIMANDS IS NULL OR COUNT("R"."ID")>=TO_NUMBER(:MIN_REPRIMANDS)) AND 
              (:MAX_REPRIMANDS IS NULL OR COUNT("R"."ID")<=TO_NUMBER(:MAX_REPRIMANDS)))
  23 - access("P"."ID"="R"."FK_PRISONER"(+))
  25 - access("P"."ID"="S"."FK_PRISONER"(+))
  28 - filter("A"."FK_PRISONER"="P"."ID" AND ("A"."END_DATE" IS NULL OR "A"."END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD')))
  29 - access("A"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD'))
  30 - filter("C"."IS_SOLITARY"=TO_NUMBER(:IS_IN_SOLITARY) OR :IS_IN_SOLITARY IS NULL)
  31 - access("C"."ID"="A"."FK_CELL")
  32 - access("PB"."ID"="C"."FK_BLOCK")
 
Note
-----
   - this is an adaptive plan
   ```]
)

*`query4`:*
#plan(
   [```
Plan hash value: 171928505
 
---------------------------------------------------------------------------------------------------------
| Id  | Operation                       | Name          | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                |               |     5 |    65 |       | 98504   (2)| 00:00:04 |
|   1 |  HASH UNIQUE                    |               |     5 |    65 |       | 98504   (2)| 00:00:04 |
|   2 |   UNION-ALL                     |               |       |       |       |            |          |
|   3 |    SORT AGGREGATE               |               |     1 |    13 |       | 19701   (2)| 00:00:01 |
|   4 |     VIEW                        |               |   157K|  1999K|       | 18944   (2)| 00:00:01 |
|   5 |      HASH GROUP BY              |               |   157K|  8612K|       | 18944   (2)| 00:00:01 |
|   6 |       MERGE JOIN OUTER          |               |  2487K|   132M|       | 18944   (2)| 00:00:01 |
|   7 |        MERGE JOIN OUTER         |               |  1592K|    69M|       | 15652   (2)| 00:00:01 |
|   8 |         MERGE JOIN OUTER        |               |   323K|    10M|       |  7035   (2)| 00:00:01 |
|*  9 |          FILTER                 |               |       |       |       |            |          |
|  10 |           MERGE JOIN OUTER      |               |   157K|  3845K|       |  3939   (3)| 00:00:01 |
|  11 |            SORT JOIN            |               |   157K|  2460K|  8680K|  1494   (2)| 00:00:01 |
|* 12 |             TABLE ACCESS FULL   | PRISONER      |   157K|  2460K|       |   650   (2)| 00:00:01 |
|* 13 |            SORT JOIN            |               | 10513 | 94617 |       |  2445   (4)| 00:00:01 |
|  14 |             VIEW                |               | 10513 | 94617 |       |  2444   (4)| 00:00:01 |
|* 15 |              HASH JOIN          |               | 10513 |   420K|       |  2444   (4)| 00:00:01 |
|  16 |               TABLE ACCESS FULL | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 17 |               HASH JOIN         |               | 10513 |   349K|       |  2442   (4)| 00:00:01 |
|* 18 |                TABLE ACCESS FULL| ACCOMMODATION | 10513 |   266K|       |  2088   (4)| 00:00:01 |
|  19 |                TABLE ACCESS FULL| CELL          |   251K|  1966K|       |   351   (1)| 00:00:01 |
|* 20 |          SORT JOIN              |               |   422K|  4122K|    16M|  3096   (2)| 00:00:01 |
|  21 |           TABLE ACCESS FULL     | REPRIMAND     |   422K|  4122K|       |  1394   (1)| 00:00:01 |
|* 22 |         SORT JOIN               |               |  1493K|    15M|    57M|  8617   (2)| 00:00:01 |
|  23 |          TABLE ACCESS FULL      | ACCOMMODATION |  1493K|    15M|       |  2032   (2)| 00:00:01 |
|* 24 |        SORT JOIN                |               |   473K|  4620K|    18M|  3285   (2)| 00:00:01 |
|  25 |         TABLE ACCESS FULL       | SENTENCE      |   473K|  4620K|       |  1379   (1)| 00:00:01 |
|  26 |    SORT AGGREGATE               |               |     1 |    13 |       | 19701   (2)| 00:00:01 |
|  27 |     VIEW                        |               |   157K|  1999K|       | 18944   (2)| 00:00:01 |
|  28 |      HASH GROUP BY              |               |   157K|  8612K|       | 18944   (2)| 00:00:01 |
|  29 |       MERGE JOIN OUTER          |               |  2487K|   132M|       | 18944   (2)| 00:00:01 |
|  30 |        MERGE JOIN OUTER         |               |  1592K|    69M|       | 15652   (2)| 00:00:01 |
|  31 |         MERGE JOIN OUTER        |               |   323K|    10M|       |  7035   (2)| 00:00:01 |
|* 32 |          FILTER                 |               |       |       |       |            |          |
|  33 |           MERGE JOIN OUTER      |               |   157K|  3845K|       |  3939   (3)| 00:00:01 |
|  34 |            SORT JOIN            |               |   157K|  2460K|  8680K|  1494   (2)| 00:00:01 |
|* 35 |             TABLE ACCESS FULL   | PRISONER      |   157K|  2460K|       |   650   (2)| 00:00:01 |
|* 36 |            SORT JOIN            |               | 10513 | 94617 |       |  2445   (4)| 00:00:01 |
|  37 |             VIEW                |               | 10513 | 94617 |       |  2444   (4)| 00:00:01 |
|* 38 |              HASH JOIN          |               | 10513 |   420K|       |  2444   (4)| 00:00:01 |
|  39 |               TABLE ACCESS FULL | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 40 |               HASH JOIN         |               | 10513 |   349K|       |  2442   (4)| 00:00:01 |
|* 41 |                TABLE ACCESS FULL| ACCOMMODATION | 10513 |   266K|       |  2088   (4)| 00:00:01 |
|  42 |                TABLE ACCESS FULL| CELL          |   251K|  1966K|       |   351   (1)| 00:00:01 |
|* 43 |          SORT JOIN              |               |   422K|  4122K|    16M|  3096   (2)| 00:00:01 |
|  44 |           TABLE ACCESS FULL     | REPRIMAND     |   422K|  4122K|       |  1394   (1)| 00:00:01 |
|* 45 |         SORT JOIN               |               |  1493K|    15M|    57M|  8617   (2)| 00:00:01 |
|  46 |          TABLE ACCESS FULL      | ACCOMMODATION |  1493K|    15M|       |  2032   (2)| 00:00:01 |
|* 47 |        SORT JOIN                |               |   473K|  4620K|    18M|  3285   (2)| 00:00:01 |
|  48 |         TABLE ACCESS FULL       | SENTENCE      |   473K|  4620K|       |  1379   (1)| 00:00:01 |
|  49 |    SORT AGGREGATE               |               |     1 |    13 |       | 19701   (2)| 00:00:01 |
|  50 |     VIEW                        |               |   157K|  1999K|       | 18944   (2)| 00:00:01 |
|  51 |      HASH GROUP BY              |               |   157K|  8612K|       | 18944   (2)| 00:00:01 |
|  52 |       MERGE JOIN OUTER          |               |  2487K|   132M|       | 18944   (2)| 00:00:01 |
|  53 |        MERGE JOIN OUTER         |               |  1592K|    69M|       | 15652   (2)| 00:00:01 |
|  54 |         MERGE JOIN OUTER        |               |   323K|    10M|       |  7035   (2)| 00:00:01 |
|* 55 |          FILTER                 |               |       |       |       |            |          |
|  56 |           MERGE JOIN OUTER      |               |   157K|  3845K|       |  3939   (3)| 00:00:01 |
|  57 |            SORT JOIN            |               |   157K|  2460K|  8680K|  1494   (2)| 00:00:01 |
|* 58 |             TABLE ACCESS FULL   | PRISONER      |   157K|  2460K|       |   650   (2)| 00:00:01 |
|* 59 |            SORT JOIN            |               | 10513 | 94617 |       |  2445   (4)| 00:00:01 |
|  60 |             VIEW                |               | 10513 | 94617 |       |  2444   (4)| 00:00:01 |
|* 61 |              HASH JOIN          |               | 10513 |   420K|       |  2444   (4)| 00:00:01 |
|  62 |               TABLE ACCESS FULL | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 63 |               HASH JOIN         |               | 10513 |   349K|       |  2442   (4)| 00:00:01 |
|* 64 |                TABLE ACCESS FULL| ACCOMMODATION | 10513 |   266K|       |  2088   (4)| 00:00:01 |
|  65 |                TABLE ACCESS FULL| CELL          |   251K|  1966K|       |   351   (1)| 00:00:01 |
|* 66 |          SORT JOIN              |               |   422K|  4122K|    16M|  3096   (2)| 00:00:01 |
|  67 |           TABLE ACCESS FULL     | REPRIMAND     |   422K|  4122K|       |  1394   (1)| 00:00:01 |
|* 68 |         SORT JOIN               |               |  1493K|    15M|    57M|  8617   (2)| 00:00:01 |
|  69 |          TABLE ACCESS FULL      | ACCOMMODATION |  1493K|    15M|       |  2032   (2)| 00:00:01 |
|* 70 |        SORT JOIN                |               |   473K|  4620K|    18M|  3285   (2)| 00:00:01 |
|  71 |         TABLE ACCESS FULL       | SENTENCE      |   473K|  4620K|       |  1379   (1)| 00:00:01 |
|  72 |    SORT AGGREGATE               |               |     1 |    13 |       | 19701   (2)| 00:00:01 |
|  73 |     VIEW                        |               |   157K|  1999K|       | 18944   (2)| 00:00:01 |
|  74 |      HASH GROUP BY              |               |   157K|  8612K|       | 18944   (2)| 00:00:01 |
|  75 |       MERGE JOIN OUTER          |               |  2487K|   132M|       | 18944   (2)| 00:00:01 |
|  76 |        MERGE JOIN OUTER         |               |  1592K|    69M|       | 15652   (2)| 00:00:01 |
|  77 |         MERGE JOIN OUTER        |               |   323K|    10M|       |  7035   (2)| 00:00:01 |
|* 78 |          FILTER                 |               |       |       |       |            |          |
|  79 |           MERGE JOIN OUTER      |               |   157K|  3845K|       |  3939   (3)| 00:00:01 |
|  80 |            SORT JOIN            |               |   157K|  2460K|  8680K|  1494   (2)| 00:00:01 |
|* 81 |             TABLE ACCESS FULL   | PRISONER      |   157K|  2460K|       |   650   (2)| 00:00:01 |
|* 82 |            SORT JOIN            |               | 10513 | 94617 |       |  2445   (4)| 00:00:01 |
|  83 |             VIEW                |               | 10513 | 94617 |       |  2444   (4)| 00:00:01 |
|* 84 |              HASH JOIN          |               | 10513 |   420K|       |  2444   (4)| 00:00:01 |
|  85 |               TABLE ACCESS FULL | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 86 |               HASH JOIN         |               | 10513 |   349K|       |  2442   (4)| 00:00:01 |
|* 87 |                TABLE ACCESS FULL| ACCOMMODATION | 10513 |   266K|       |  2088   (4)| 00:00:01 |
|  88 |                TABLE ACCESS FULL| CELL          |   251K|  1966K|       |   351   (1)| 00:00:01 |
|* 89 |          SORT JOIN              |               |   422K|  4122K|    16M|  3096   (2)| 00:00:01 |
|  90 |           TABLE ACCESS FULL     | REPRIMAND     |   422K|  4122K|       |  1394   (1)| 00:00:01 |
|* 91 |         SORT JOIN               |               |  1493K|    15M|    57M|  8617   (2)| 00:00:01 |
|  92 |          TABLE ACCESS FULL      | ACCOMMODATION |  1493K|    15M|       |  2032   (2)| 00:00:01 |
|* 93 |        SORT JOIN                |               |   473K|  4620K|    18M|  3285   (2)| 00:00:01 |
|  94 |         TABLE ACCESS FULL       | SENTENCE      |   473K|  4620K|       |  1379   (1)| 00:00:01 |
|  95 |    SORT AGGREGATE               |               |     1 |    13 |       | 19701   (2)| 00:00:01 |
|  96 |     VIEW                        |               |   157K|  1999K|       | 18944   (2)| 00:00:01 |
|  97 |      HASH GROUP BY              |               |   157K|  8612K|       | 18944   (2)| 00:00:01 |
|  98 |       MERGE JOIN OUTER          |               |  2487K|   132M|       | 18944   (2)| 00:00:01 |
|  99 |        MERGE JOIN OUTER         |               |  1592K|    69M|       | 15652   (2)| 00:00:01 |
| 100 |         MERGE JOIN OUTER        |               |   323K|    10M|       |  7035   (2)| 00:00:01 |
|*101 |          FILTER                 |               |       |       |       |            |          |
| 102 |           MERGE JOIN OUTER      |               |   157K|  3845K|       |  3939   (3)| 00:00:01 |
| 103 |            SORT JOIN            |               |   157K|  2460K|  8680K|  1494   (2)| 00:00:01 |
|*104 |             TABLE ACCESS FULL   | PRISONER      |   157K|  2460K|       |   650   (2)| 00:00:01 |
|*105 |            SORT JOIN            |               | 10513 | 94617 |       |  2445   (4)| 00:00:01 |
| 106 |             VIEW                |               | 10513 | 94617 |       |  2444   (4)| 00:00:01 |
|*107 |              HASH JOIN          |               | 10513 |   420K|       |  2444   (4)| 00:00:01 |
| 108 |               TABLE ACCESS FULL | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|*109 |               HASH JOIN         |               | 10513 |   349K|       |  2442   (4)| 00:00:01 |
|*110 |                TABLE ACCESS FULL| ACCOMMODATION | 10513 |   266K|       |  2088   (4)| 00:00:01 |
| 111 |                TABLE ACCESS FULL| CELL          |   251K|  1966K|       |   351   (1)| 00:00:01 |
|*112 |          SORT JOIN              |               |   422K|  4122K|    16M|  3096   (2)| 00:00:01 |
| 113 |           TABLE ACCESS FULL     | REPRIMAND     |   422K|  4122K|       |  1394   (1)| 00:00:01 |
|*114 |         SORT JOIN               |               |  1493K|    15M|    57M|  8617   (2)| 00:00:01 |
| 115 |          TABLE ACCESS FULL      | ACCOMMODATION |  1493K|    15M|       |  2032   (2)| 00:00:01 |
|*116 |        SORT JOIN                |               |   473K|  4620K|    18M|  3285   (2)| 00:00:01 |
| 117 |         TABLE ACCESS FULL       | SENTENCE      |   473K|  4620K|       |  1379   (1)| 00:00:01 |
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
   ```],
   [```
Plan hash value: 3517137373
 
------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                         | Name                         | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                                  |                              |     5 |    65 |       | 98143   (2)| 00:00:04 |
|   1 |  HASH UNIQUE                                      |                              |     5 |    65 |       | 98143   (2)| 00:00:04 |
|   2 |   UNION-ALL                                       |                              |       |       |       |            |          |
|   3 |    SORT AGGREGATE                                 |                              |     1 |    13 |       | 19629   (2)| 00:00:01 |
|   4 |     VIEW                                          |                              |   157K|  1999K|       | 18872   (2)| 00:00:01 |
|   5 |      HASH GROUP BY                                |                              |   157K|  8612K|       | 18872   (2)| 00:00:01 |
|   6 |       MERGE JOIN OUTER                            |                              |  2487K|   132M|       | 18872   (2)| 00:00:01 |
|   7 |        MERGE JOIN OUTER                           |                              |  1592K|    69M|       | 15580   (2)| 00:00:01 |
|   8 |         MERGE JOIN OUTER                          |                              |   323K|    10M|       |  6963   (1)| 00:00:01 |
|*  9 |          FILTER                                   |                              |       |       |       |            |          |
|  10 |           MERGE JOIN OUTER                        |                              |   157K|  3845K|       |  3867   (1)| 00:00:01 |
|  11 |            SORT JOIN                              |                              |   157K|  2460K|  8680K|  1494   (2)| 00:00:01 |
|* 12 |             TABLE ACCESS FULL                     | PRISONER                     |   157K|  2460K|       |   650   (2)| 00:00:01 |
|* 13 |            SORT JOIN                              |                              | 10513 | 94617 |       |  2373   (1)| 00:00:01 |
|  14 |             VIEW                                  |                              | 10513 | 94617 |       |  2372   (1)| 00:00:01 |
|* 15 |              HASH JOIN                            |                              | 10513 |   420K|       |  2372   (1)| 00:00:01 |
|  16 |               TABLE ACCESS FULL                   | PRISON_BLOCK                 |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 17 |               HASH JOIN                           |                              | 10513 |   349K|       |  2369   (1)| 00:00:01 |
|* 18 |                TABLE ACCESS BY INDEX ROWID BATCHED| ACCOMMODATION                | 10513 |   266K|       |  2016   (1)| 00:00:01 |
|* 19 |                 INDEX RANGE SCAN                  | ACCOMMODATION_START_DATE_IDX | 13437 |       |       |    38   (0)| 00:00:01 |
|  20 |                TABLE ACCESS FULL                  | CELL                         |   251K|  1966K|       |   351   (1)| 00:00:01 |
|* 21 |          SORT JOIN                                |                              |   422K|  4122K|    16M|  3096   (2)| 00:00:01 |
|  22 |           TABLE ACCESS FULL                       | REPRIMAND                    |   422K|  4122K|       |  1394   (1)| 00:00:01 |
|* 23 |         SORT JOIN                                 |                              |  1493K|    15M|    57M|  8617   (2)| 00:00:01 |
|  24 |          TABLE ACCESS FULL                        | ACCOMMODATION                |  1493K|    15M|       |  2032   (2)| 00:00:01 |
|* 25 |        SORT JOIN                                  |                              |   473K|  4620K|    18M|  3285   (2)| 00:00:01 |
|  26 |         TABLE ACCESS FULL                         | SENTENCE                     |   473K|  4620K|       |  1379   (1)| 00:00:01 |
|  27 |    SORT AGGREGATE                                 |                              |     1 |    13 |       | 19629   (2)| 00:00:01 |
|  28 |     VIEW                                          |                              |   157K|  1999K|       | 18872   (2)| 00:00:01 |
|  29 |      HASH GROUP BY                                |                              |   157K|  8612K|       | 18872   (2)| 00:00:01 |
|  30 |       MERGE JOIN OUTER                            |                              |  2487K|   132M|       | 18872   (2)| 00:00:01 |
|  31 |        MERGE JOIN OUTER                           |                              |  1592K|    69M|       | 15580   (2)| 00:00:01 |
|  32 |         MERGE JOIN OUTER                          |                              |   323K|    10M|       |  6963   (1)| 00:00:01 |
|* 33 |          FILTER                                   |                              |       |       |       |            |          |
|  34 |           MERGE JOIN OUTER                        |                              |   157K|  3845K|       |  3867   (1)| 00:00:01 |
|  35 |            SORT JOIN                              |                              |   157K|  2460K|  8680K|  1494   (2)| 00:00:01 |
|* 36 |             TABLE ACCESS FULL                     | PRISONER                     |   157K|  2460K|       |   650   (2)| 00:00:01 |
|* 37 |            SORT JOIN                              |                              | 10513 | 94617 |       |  2373   (1)| 00:00:01 |
|  38 |             VIEW                                  |                              | 10513 | 94617 |       |  2372   (1)| 00:00:01 |
|* 39 |              HASH JOIN                            |                              | 10513 |   420K|       |  2372   (1)| 00:00:01 |
|  40 |               TABLE ACCESS FULL                   | PRISON_BLOCK                 |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 41 |               HASH JOIN                           |                              | 10513 |   349K|       |  2369   (1)| 00:00:01 |
|* 42 |                TABLE ACCESS BY INDEX ROWID BATCHED| ACCOMMODATION                | 10513 |   266K|       |  2016   (1)| 00:00:01 |
|* 43 |                 INDEX RANGE SCAN                  | ACCOMMODATION_START_DATE_IDX | 13437 |       |       |    38   (0)| 00:00:01 |
|  44 |                TABLE ACCESS FULL                  | CELL                         |   251K|  1966K|       |   351   (1)| 00:00:01 |
|* 45 |          SORT JOIN                                |                              |   422K|  4122K|    16M|  3096   (2)| 00:00:01 |
|  46 |           TABLE ACCESS FULL                       | REPRIMAND                    |   422K|  4122K|       |  1394   (1)| 00:00:01 |
|* 47 |         SORT JOIN                                 |                              |  1493K|    15M|    57M|  8617   (2)| 00:00:01 |
|  48 |          TABLE ACCESS FULL                        | ACCOMMODATION                |  1493K|    15M|       |  2032   (2)| 00:00:01 |
|* 49 |        SORT JOIN                                  |                              |   473K|  4620K|    18M|  3285   (2)| 00:00:01 |
|  50 |         TABLE ACCESS FULL                         | SENTENCE                     |   473K|  4620K|       |  1379   (1)| 00:00:01 |
|  51 |    SORT AGGREGATE                                 |                              |     1 |    13 |       | 19629   (2)| 00:00:01 |
|  52 |     VIEW                                          |                              |   157K|  1999K|       | 18872   (2)| 00:00:01 |
|  53 |      HASH GROUP BY                                |                              |   157K|  8612K|       | 18872   (2)| 00:00:01 |
|  54 |       MERGE JOIN OUTER                            |                              |  2487K|   132M|       | 18872   (2)| 00:00:01 |
|  55 |        MERGE JOIN OUTER                           |                              |  1592K|    69M|       | 15580   (2)| 00:00:01 |
|  56 |         MERGE JOIN OUTER                          |                              |   323K|    10M|       |  6963   (1)| 00:00:01 |
|* 57 |          FILTER                                   |                              |       |       |       |            |          |
|  58 |           MERGE JOIN OUTER                        |                              |   157K|  3845K|       |  3867   (1)| 00:00:01 |
|  59 |            SORT JOIN                              |                              |   157K|  2460K|  8680K|  1494   (2)| 00:00:01 |
|* 60 |             TABLE ACCESS FULL                     | PRISONER                     |   157K|  2460K|       |   650   (2)| 00:00:01 |
|* 61 |            SORT JOIN                              |                              | 10513 | 94617 |       |  2373   (1)| 00:00:01 |
|  62 |             VIEW                                  |                              | 10513 | 94617 |       |  2372   (1)| 00:00:01 |
|* 63 |              HASH JOIN                            |                              | 10513 |   420K|       |  2372   (1)| 00:00:01 |
|  64 |               TABLE ACCESS FULL                   | PRISON_BLOCK                 |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 65 |               HASH JOIN                           |                              | 10513 |   349K|       |  2369   (1)| 00:00:01 |
|* 66 |                TABLE ACCESS BY INDEX ROWID BATCHED| ACCOMMODATION                | 10513 |   266K|       |  2016   (1)| 00:00:01 |
|* 67 |                 INDEX RANGE SCAN                  | ACCOMMODATION_START_DATE_IDX | 13437 |       |       |    38   (0)| 00:00:01 |
|  68 |                TABLE ACCESS FULL                  | CELL                         |   251K|  1966K|       |   351   (1)| 00:00:01 |
|* 69 |          SORT JOIN                                |                              |   422K|  4122K|    16M|  3096   (2)| 00:00:01 |
|  70 |           TABLE ACCESS FULL                       | REPRIMAND                    |   422K|  4122K|       |  1394   (1)| 00:00:01 |
|* 71 |         SORT JOIN                                 |                              |  1493K|    15M|    57M|  8617   (2)| 00:00:01 |
|  72 |          TABLE ACCESS FULL                        | ACCOMMODATION                |  1493K|    15M|       |  2032   (2)| 00:00:01 |
|* 73 |        SORT JOIN                                  |                              |   473K|  4620K|    18M|  3285   (2)| 00:00:01 |
|  74 |         TABLE ACCESS FULL                         | SENTENCE                     |   473K|  4620K|       |  1379   (1)| 00:00:01 |
|  75 |    SORT AGGREGATE                                 |                              |     1 |    13 |       | 19629   (2)| 00:00:01 |
|  76 |     VIEW                                          |                              |   157K|  1999K|       | 18872   (2)| 00:00:01 |
|  77 |      HASH GROUP BY                                |                              |   157K|  8612K|       | 18872   (2)| 00:00:01 |
|  78 |       MERGE JOIN OUTER                            |                              |  2487K|   132M|       | 18872   (2)| 00:00:01 |
|  79 |        MERGE JOIN OUTER                           |                              |  1592K|    69M|       | 15580   (2)| 00:00:01 |
|  80 |         MERGE JOIN OUTER                          |                              |   323K|    10M|       |  6963   (1)| 00:00:01 |
|* 81 |          FILTER                                   |                              |       |       |       |            |          |
|  82 |           MERGE JOIN OUTER                        |                              |   157K|  3845K|       |  3867   (1)| 00:00:01 |
|  83 |            SORT JOIN                              |                              |   157K|  2460K|  8680K|  1494   (2)| 00:00:01 |
|* 84 |             TABLE ACCESS FULL                     | PRISONER                     |   157K|  2460K|       |   650   (2)| 00:00:01 |
|* 85 |            SORT JOIN                              |                              | 10513 | 94617 |       |  2373   (1)| 00:00:01 |
|  86 |             VIEW                                  |                              | 10513 | 94617 |       |  2372   (1)| 00:00:01 |
|* 87 |              HASH JOIN                            |                              | 10513 |   420K|       |  2372   (1)| 00:00:01 |
|  88 |               TABLE ACCESS FULL                   | PRISON_BLOCK                 |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 89 |               HASH JOIN                           |                              | 10513 |   349K|       |  2369   (1)| 00:00:01 |
|* 90 |                TABLE ACCESS BY INDEX ROWID BATCHED| ACCOMMODATION                | 10513 |   266K|       |  2016   (1)| 00:00:01 |
|* 91 |                 INDEX RANGE SCAN                  | ACCOMMODATION_START_DATE_IDX | 13437 |       |       |    38   (0)| 00:00:01 |
|  92 |                TABLE ACCESS FULL                  | CELL                         |   251K|  1966K|       |   351   (1)| 00:00:01 |
|* 93 |          SORT JOIN                                |                              |   422K|  4122K|    16M|  3096   (2)| 00:00:01 |
|  94 |           TABLE ACCESS FULL                       | REPRIMAND                    |   422K|  4122K|       |  1394   (1)| 00:00:01 |
|* 95 |         SORT JOIN                                 |                              |  1493K|    15M|    57M|  8617   (2)| 00:00:01 |
|  96 |          TABLE ACCESS FULL                        | ACCOMMODATION                |  1493K|    15M|       |  2032   (2)| 00:00:01 |
|* 97 |        SORT JOIN                                  |                              |   473K|  4620K|    18M|  3285   (2)| 00:00:01 |
|  98 |         TABLE ACCESS FULL                         | SENTENCE                     |   473K|  4620K|       |  1379   (1)| 00:00:01 |
|  99 |    SORT AGGREGATE                                 |                              |     1 |    13 |       | 19629   (2)| 00:00:01 |
| 100 |     VIEW                                          |                              |   157K|  1999K|       | 18872   (2)| 00:00:01 |
| 101 |      HASH GROUP BY                                |                              |   157K|  8612K|       | 18872   (2)| 00:00:01 |
| 102 |       MERGE JOIN OUTER                            |                              |  2487K|   132M|       | 18872   (2)| 00:00:01 |
| 103 |        MERGE JOIN OUTER                           |                              |  1592K|    69M|       | 15580   (2)| 00:00:01 |
| 104 |         MERGE JOIN OUTER                          |                              |   323K|    10M|       |  6963   (1)| 00:00:01 |
|*105 |          FILTER                                   |                              |       |       |       |            |          |
| 106 |           MERGE JOIN OUTER                        |                              |   157K|  3845K|       |  3867   (1)| 00:00:01 |
| 107 |            SORT JOIN                              |                              |   157K|  2460K|  8680K|  1494   (2)| 00:00:01 |
|*108 |             TABLE ACCESS FULL                     | PRISONER                     |   157K|  2460K|       |   650   (2)| 00:00:01 |
|*109 |            SORT JOIN                              |                              | 10513 | 94617 |       |  2373   (1)| 00:00:01 |
| 110 |             VIEW                                  |                              | 10513 | 94617 |       |  2372   (1)| 00:00:01 |
|*111 |              HASH JOIN                            |                              | 10513 |   420K|       |  2372   (1)| 00:00:01 |
| 112 |               TABLE ACCESS FULL                   | PRISON_BLOCK                 |   100 |   700 |       |     2   (0)| 00:00:01 |
|*113 |               HASH JOIN                           |                              | 10513 |   349K|       |  2369   (1)| 00:00:01 |
|*114 |                TABLE ACCESS BY INDEX ROWID BATCHED| ACCOMMODATION                | 10513 |   266K|       |  2016   (1)| 00:00:01 |
|*115 |                 INDEX RANGE SCAN                  | ACCOMMODATION_START_DATE_IDX | 13437 |       |       |    38   (0)| 00:00:01 |
| 116 |                TABLE ACCESS FULL                  | CELL                         |   251K|  1966K|       |   351   (1)| 00:00:01 |
|*117 |          SORT JOIN                                |                              |   422K|  4122K|    16M|  3096   (2)| 00:00:01 |
| 118 |           TABLE ACCESS FULL                       | REPRIMAND                    |   422K|  4122K|       |  1394   (1)| 00:00:01 |
|*119 |         SORT JOIN                                 |                              |  1493K|    15M|    57M|  8617   (2)| 00:00:01 |
| 120 |          TABLE ACCESS FULL                        | ACCOMMODATION                |  1493K|    15M|       |  2032   (2)| 00:00:01 |
|*121 |        SORT JOIN                                  |                              |   473K|  4620K|    18M|  3285   (2)| 00:00:01 |
| 122 |         TABLE ACCESS FULL                         | SENTENCE                     |   473K|  4620K|       |  1379   (1)| 00:00:01 |
------------------------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   9 - filter(:BLOCK_NUMBER IS NULL OR "PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  12 - filter("P"."SEX"=TO_NUMBER(:SEX) OR :SEX IS NULL)
  13 - access("P"."ID"="PB"."ID"(+))
       filter("P"."ID"="PB"."ID"(+))
  15 - access("PB"."ID"="C"."FK_BLOCK")
  17 - access("C"."ID"="A"."FK_CELL")
  18 - filter("A"."END_DATE" IS NULL OR "A"."END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD'))
  19 - access("A"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD'))
  21 - access("P"."ID"="R"."FK_PRISONER"(+))
       filter("P"."ID"="R"."FK_PRISONER"(+))
  23 - access("P"."ID"="A"."FK_PRISONER"(+))
       filter("P"."ID"="A"."FK_PRISONER"(+))
  25 - access("P"."ID"="S"."FK_PRISONER"(+))
       filter("P"."ID"="S"."FK_PRISONER"(+))
  33 - filter(:BLOCK_NUMBER IS NULL OR "PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  36 - filter("P"."SEX"=TO_NUMBER(:SEX) OR :SEX IS NULL)
  37 - access("P"."ID"="PB"."ID"(+))
       filter("P"."ID"="PB"."ID"(+))
  39 - access("PB"."ID"="C"."FK_BLOCK")
  41 - access("C"."ID"="A"."FK_CELL")
  42 - filter("A"."END_DATE" IS NULL OR "A"."END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD'))
  43 - access("A"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD'))
  45 - access("P"."ID"="R"."FK_PRISONER"(+))
       filter("P"."ID"="R"."FK_PRISONER"(+))
  47 - access("P"."ID"="A"."FK_PRISONER"(+))
       filter("P"."ID"="A"."FK_PRISONER"(+))
  49 - access("P"."ID"="S"."FK_PRISONER"(+))
       filter("P"."ID"="S"."FK_PRISONER"(+))
  57 - filter(:BLOCK_NUMBER IS NULL OR "PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  60 - filter("P"."SEX"=TO_NUMBER(:SEX) OR :SEX IS NULL)
  61 - access("P"."ID"="PB"."ID"(+))
       filter("P"."ID"="PB"."ID"(+))
  63 - access("PB"."ID"="C"."FK_BLOCK")
  65 - access("C"."ID"="A"."FK_CELL")
  66 - filter("A"."END_DATE" IS NULL OR "A"."END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD'))
  67 - access("A"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD'))
  69 - access("P"."ID"="R"."FK_PRISONER"(+))
       filter("P"."ID"="R"."FK_PRISONER"(+))
  71 - access("P"."ID"="A"."FK_PRISONER"(+))
       filter("P"."ID"="A"."FK_PRISONER"(+))
  73 - access("P"."ID"="S"."FK_PRISONER"(+))
       filter("P"."ID"="S"."FK_PRISONER"(+))
  81 - filter(:BLOCK_NUMBER IS NULL OR "PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  84 - filter("P"."SEX"=TO_NUMBER(:SEX) OR :SEX IS NULL)
  85 - access("P"."ID"="PB"."ID"(+))
       filter("P"."ID"="PB"."ID"(+))
  87 - access("PB"."ID"="C"."FK_BLOCK")
  89 - access("C"."ID"="A"."FK_CELL")
  90 - filter("A"."END_DATE" IS NULL OR "A"."END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD'))
  91 - access("A"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD'))
  93 - access("P"."ID"="R"."FK_PRISONER"(+))
       filter("P"."ID"="R"."FK_PRISONER"(+))
  95 - access("P"."ID"="A"."FK_PRISONER"(+))
       filter("P"."ID"="A"."FK_PRISONER"(+))
  97 - access("P"."ID"="S"."FK_PRISONER"(+))
       filter("P"."ID"="S"."FK_PRISONER"(+))
 105 - filter(:BLOCK_NUMBER IS NULL OR "PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
 108 - filter("P"."SEX"=TO_NUMBER(:SEX) OR :SEX IS NULL)
 109 - access("P"."ID"="PB"."ID"(+))
       filter("P"."ID"="PB"."ID"(+))
 111 - access("PB"."ID"="C"."FK_BLOCK")
 113 - access("C"."ID"="A"."FK_CELL")
 114 - filter("A"."END_DATE" IS NULL OR "A"."END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD'))
 115 - access("A"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD'))
 117 - access("P"."ID"="R"."FK_PRISONER"(+))
       filter("P"."ID"="R"."FK_PRISONER"(+))
 119 - access("P"."ID"="A"."FK_PRISONER"(+))
       filter("P"."ID"="A"."FK_PRISONER"(+))
 121 - access("P"."ID"="S"."FK_PRISONER"(+))
       filter("P"."ID"="S"."FK_PRISONER"(+))
 
Note
-----
   - this is an adaptive plan
   ```]
)

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

*`change3`:*
#plan(
   [```
Plan hash value: 2939466326
 
-----------------------------------------------------------------------------------------------------
| Id  | Operation                           | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                    |               |     1 |    52 |  3954   (3)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL            | ACCOMMODATION |       |       |            |          |
|   2 |   SEQUENCE                          | ISEQ$$_76227  |       |       |            |          |
|*  3 |    HASH JOIN                        |               |     1 |    52 |  3954   (3)| 00:00:01 |
|   4 |     VIEW                            |               |     1 |    26 |  2449   (4)| 00:00:01 |
|   5 |      COUNT                          |               |       |       |            |          |
|*  6 |       HASH JOIN ANTI                |               |     1 |    31 |  2449   (4)| 00:00:01 |
|   7 |        NESTED LOOPS                 |               |    55 |   990 |   354   (2)| 00:00:01 |
|   8 |         TABLE ACCESS BY INDEX ROWID | PRISON_BLOCK  |     1 |     7 |     1   (0)| 00:00:01 |
|*  9 |          INDEX UNIQUE SCAN          | SYS_C008856   |     1 |       |     0   (0)| 00:00:01 |
|* 10 |         TABLE ACCESS FULL           | CELL          |    55 |   605 |   353   (2)| 00:00:01 |
|  11 |        VIEW                         | VW_NSO_1      | 10659 |   135K|  2095   (5)| 00:00:01 |
|  12 |         SORT GROUP BY               |               | 10659 |   218K|  2095   (5)| 00:00:01 |
|* 13 |          TABLE ACCESS FULL          | ACCOMMODATION | 10850 |   222K|  2093   (4)| 00:00:01 |
|  14 |     VIEW                            |               |   103 |  2678 |  1505   (2)| 00:00:01 |
|  15 |      SORT GROUP BY                  |               |   103 |  9373 |  1505   (2)| 00:00:01 |
|  16 |       COUNT                         |               |       |       |            |          |
|* 17 |        FILTER                       |               |       |       |            |          |
|  18 |         NESTED LOOPS                |               |   103 |  9373 |  1504   (1)| 00:00:01 |
|  19 |          NESTED LOOPS               |               |   103 |  9373 |  1504   (1)| 00:00:01 |
|* 20 |           TABLE ACCESS FULL         | REPRIMAND     |   103 |  7622 |  1401   (2)| 00:00:01 |
|* 21 |           INDEX UNIQUE SCAN         | SYS_C008848   |     1 |       |     0   (0)| 00:00:01 |
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
Plan hash value: 221405392
 
-------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                  | Name                 | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                           |                      |     1 |    52 |  3888   (3)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL                   | ACCOMMODATION        |       |       |            |          |
|   2 |   SEQUENCE                                 | ISEQ$$_76227         |       |       |            |          |
|*  3 |    HASH JOIN                               |                      |     1 |    52 |  3888   (3)| 00:00:01 |
|   4 |     VIEW                                   |                      |     1 |    26 |  2383   (4)| 00:00:01 |
|   5 |      COUNT                                 |                      |       |       |            |          |
|*  6 |       HASH JOIN ANTI                       |                      |     1 |    31 |  2383   (4)| 00:00:01 |
|*  7 |        HASH JOIN                           |                      |    55 |   990 |   288   (0)| 00:00:01 |
|   8 |         TABLE ACCESS BY INDEX ROWID        | PRISON_BLOCK         |     1 |     7 |     1   (0)| 00:00:01 |
|*  9 |          INDEX UNIQUE SCAN                 | SYS_C008856          |     1 |       |     0   (0)| 00:00:01 |
|  10 |         TABLE ACCESS BY INDEX ROWID BATCHED| CELL                 |  4979 | 54769 |   287   (0)| 00:00:01 |
|  11 |          BITMAP CONVERSION TO ROWIDS       |                      |       |       |            |          |
|* 12 |           BITMAP INDEX SINGLE VALUE        | CELL_IS_SOLITARY_IDX |       |       |            |          |
|  13 |        VIEW                                | VW_NSO_1             | 10659 |   135K|  2095   (5)| 00:00:01 |
|  14 |         SORT GROUP BY                      |                      | 10659 |   218K|  2095   (5)| 00:00:01 |
|* 15 |          TABLE ACCESS FULL                 | ACCOMMODATION        | 10850 |   222K|  2093   (4)| 00:00:01 |
|  16 |     VIEW                                   |                      |   103 |  2678 |  1505   (2)| 00:00:01 |
|  17 |      SORT GROUP BY                         |                      |   103 |  9373 |  1505   (2)| 00:00:01 |
|  18 |       COUNT                                |                      |       |       |            |          |
|* 19 |        FILTER                              |                      |       |       |            |          |
|  20 |         NESTED LOOPS                       |                      |   103 |  9373 |  1504   (1)| 00:00:01 |
|  21 |          NESTED LOOPS                      |                      |   103 |  9373 |  1504   (1)| 00:00:01 |
|* 22 |           TABLE ACCESS FULL                | REPRIMAND            |   103 |  7622 |  1401   (2)| 00:00:01 |
|* 23 |           INDEX UNIQUE SCAN                | SYS_C008848          |     1 |       |     0   (0)| 00:00:01 |
|  24 |          TABLE ACCESS BY INDEX ROWID       | PRISONER             |     1 |    17 |     1   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access("P"."N"="C"."N")
   6 - access("C"."ID"="FK_CELL")
   7 - access("PB"."ID"="C"."FK_BLOCK")
   9 - access("PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  12 - access("C"."IS_SOLITARY"=1)
  15 - filter(TO_CHAR(INTERNAL_FUNCTION("A"."START_DATE"),'YYYY-MM-DD HH24:MI:SS')<=:NOW AND 
              ("A"."END_DATE" IS NULL OR TO_CHAR(INTERNAL_FUNCTION("A"."END_DATE"),'YYYY-MM-DD HH24:MI:SS')>=:NOW))
  19 - filter(:END_DATE>=:START_DATE)
  22 - filter((:EVENT_TYPE IS NULL OR INSTR("R"."REASON",:EVENT_TYPE)>0) AND 
              TO_CHAR(INTERNAL_FUNCTION("R"."ISSUE_DATE"),'YYYY-MM-DD')>=:START_DATE AND 
              TO_CHAR(INTERNAL_FUNCTION("R"."ISSUE_DATE"),'YYYY-MM-DD')<=:END_DATE)
  23 - access("P"."ID"="R"."FK_PRISONER")
   ```]
)

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

*`query3`:*
#plan(
   [```
Plan hash value: 220023471
 
--------------------------------------------------------------------------------------------------------------
| Id  | Operation                            | Name          | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                     |               |     1 |  2200 |       | 11117   (2)| 00:00:01 |
|   1 |  NESTED LOOPS                        |               |     1 |  2200 |       | 11117   (2)| 00:00:01 |
|   2 |   NESTED LOOPS                       |               |     1 |  2200 |       | 11117   (2)| 00:00:01 |
|   3 |    NESTED LOOPS                      |               |     1 |  2177 |       | 11116   (2)| 00:00:01 |
|   4 |     NESTED LOOPS                     |               |     1 |  2170 |       | 11115   (2)| 00:00:01 |
|*  5 |      HASH JOIN                       |               |     1 |  2159 |       | 11114   (2)| 00:00:01 |
|*  6 |       HASH JOIN                      |               |     1 |  2133 |       |  9021   (2)| 00:00:01 |
|*  7 |        HASH JOIN                     |               |     1 |   118 |       |  6793   (2)| 00:00:01 |
|   8 |         JOIN FILTER CREATE           | :BF0000       |   103 | 10815 |       |  1504   (1)| 00:00:01 |
|   9 |          NESTED LOOPS                |               |   103 | 10815 |       |  1504   (1)| 00:00:01 |
|  10 |           NESTED LOOPS               |               |   103 | 10815 |       |  1504   (1)| 00:00:01 |
|* 11 |            TABLE ACCESS FULL         | REPRIMAND     |   103 |  8446 |       |  1401   (2)| 00:00:01 |
|* 12 |            INDEX UNIQUE SCAN         | SYS_C008848   |     1 |       |       |     0   (0)| 00:00:01 |
|  13 |           TABLE ACCESS BY INDEX ROWID| PRISONER      |     1 |    23 |       |     1   (0)| 00:00:01 |
|  14 |         VIEW                         |               |  1063 | 13819 |       |  5288   (2)| 00:00:01 |
|* 15 |          FILTER                      |               |       |       |       |            |          |
|  16 |           JOIN FILTER USE            | :BF0000       |  1063 | 28701 |       |  5288   (2)| 00:00:01 |
|  17 |            HASH GROUP BY             |               |  1063 | 28701 |       |  5288   (2)| 00:00:01 |
|* 18 |             FILTER                   |               |       |       |       |            |          |
|* 19 |              HASH JOIN               |               |   659K|    16M|  7856K|  5249   (1)| 00:00:01 |
|  20 |               TABLE ACCESS FULL      | SENTENCE      |   473K|  2310K|       |  1379   (1)| 00:00:01 |
|* 21 |               HASH JOIN              |               |   422K|  9069K|  7016K|  2799   (1)| 00:00:01 |
|  22 |                TABLE ACCESS FULL     | REPRIMAND     |   422K|  2061K|       |  1394   (1)| 00:00:01 |
|  23 |                TABLE ACCESS FULL     | PRISONER      |   299K|  4980K|       |   645   (1)| 00:00:01 |
|* 24 |        VIEW                          |               |  9870 |    18M|       |  2228   (2)| 00:00:01 |
|  25 |         SORT GROUP BY                |               |  9870 |   751K|   872K|  2228   (2)| 00:00:01 |
|* 26 |          FILTER                      |               |       |       |       |            |          |
|* 27 |           HASH JOIN                  |               |  9870 |   751K|       |  2046   (2)| 00:00:01 |
|* 28 |            TABLE ACCESS FULL         | SENTENCE      |  9870 |   587K|       |  1399   (3)| 00:00:01 |
|  29 |            TABLE ACCESS FULL         | PRISONER      |   299K|  4980K|       |   645   (1)| 00:00:01 |
|* 30 |       TABLE ACCESS FULL              | ACCOMMODATION | 10850 |   275K|       |  2093   (4)| 00:00:01 |
|* 31 |      TABLE ACCESS BY INDEX ROWID     | CELL          |     1 |    11 |       |     1   (0)| 00:00:01 |
|* 32 |       INDEX UNIQUE SCAN              | SYS_C008883   |     1 |       |       |     0   (0)| 00:00:01 |
|* 33 |     TABLE ACCESS BY INDEX ROWID      | PRISON_BLOCK  |     1 |     7 |       |     1   (0)| 00:00:01 |
|* 34 |      INDEX UNIQUE SCAN               | SYS_C008855   |     1 |       |       |     0   (0)| 00:00:01 |
|* 35 |    INDEX UNIQUE SCAN                 | SYS_C008868   |     1 |       |       |     0   (0)| 00:00:01 |
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
   ```],
   [```
Plan hash value: 1547962004
 
----------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                     | Name                                 | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                              |                                      |     1 |  2205 |       | 11014   (1)| 00:00:01 |
|   1 |  NESTED LOOPS                                 |                                      |     1 |  2205 |       | 11014   (1)| 00:00:01 |
|   2 |   NESTED LOOPS                                |                                      |     1 |  2205 |       | 11014   (1)| 00:00:01 |
|   3 |    NESTED LOOPS                               |                                      |     1 |  2182 |       | 11013   (1)| 00:00:01 |
|   4 |     NESTED LOOPS                              |                                      |     1 |  2175 |       | 11012   (1)| 00:00:01 |
|   5 |      NESTED LOOPS                             |                                      |     1 |  2164 |       | 11011   (1)| 00:00:01 |
|*  6 |       HASH JOIN                               |                                      |     1 |  2133 |       |  8996   (2)| 00:00:01 |
|*  7 |        HASH JOIN                              |                                      |     1 |   118 |       |  6780   (2)| 00:00:01 |
|   8 |         JOIN FILTER CREATE                    | :BF0000                              |   103 | 10815 |       |  1489   (1)| 00:00:01 |
|   9 |          NESTED LOOPS                         |                                      |   103 | 10815 |       |  1489   (1)| 00:00:01 |
|  10 |           NESTED LOOPS                        |                                      |   103 | 10815 |       |  1489   (1)| 00:00:01 |
|* 11 |            TABLE ACCESS BY INDEX ROWID BATCHED| REPRIMAND                            |   103 |  8446 |       |  1386   (1)| 00:00:01 |
|* 12 |             INDEX RANGE SCAN                  | REPRIMAND_ISSUE_DATE_TO_CHAR_IDX     |  1900 |       |       |     8   (0)| 00:00:01 |
|* 13 |            INDEX UNIQUE SCAN                  | SYS_C008848                          |     1 |       |       |     0   (0)| 00:00:01 |
|  14 |           TABLE ACCESS BY INDEX ROWID         | PRISONER                             |     1 |    23 |       |     1   (0)| 00:00:01 |
|  15 |         VIEW                                  |                                      |  1063 | 13819 |       |  5291   (2)| 00:00:01 |
|* 16 |          FILTER                               |                                      |       |       |       |            |          |
|  17 |           JOIN FILTER USE                     | :BF0000                              |  1063 | 28701 |       |  5291   (2)| 00:00:01 |
|  18 |            HASH GROUP BY                      |                                      |  1063 | 28701 |       |  5291   (2)| 00:00:01 |
|* 19 |             FILTER                            |                                      |       |       |       |            |          |
|* 20 |              HASH JOIN                        |                                      |   659K|    16M|  7856K|  5252   (1)| 00:00:01 |
|  21 |               TABLE ACCESS FULL               | SENTENCE                             |   473K|  2310K|       |  1381   (1)| 00:00:01 |
|* 22 |               HASH JOIN                       |                                      |   422K|  9069K|  7016K|  2799   (1)| 00:00:01 |
|  23 |                TABLE ACCESS FULL              | REPRIMAND                            |   422K|  2061K|       |  1394   (1)| 00:00:01 |
|  24 |                TABLE ACCESS FULL              | PRISONER                             |   299K|  4980K|       |   645   (1)| 00:00:01 |
|* 25 |        VIEW                                   |                                      |  9870 |    18M|       |  2215   (1)| 00:00:01 |
|  26 |         SORT GROUP BY                         |                                      |  9870 |   809K|   912K|  2215   (1)| 00:00:01 |
|* 27 |          FILTER                               |                                      |       |       |       |            |          |
|* 28 |           HASH JOIN                           |                                      |  9870 |   809K|       |  2019   (1)| 00:00:01 |
|* 29 |            TABLE ACCESS BY INDEX ROWID BATCHED| SENTENCE                             |  9870 |   645K|       |  1372   (1)| 00:00:01 |
|* 30 |             INDEX RANGE SCAN                  | SENTENCE_START_DATE_TO_CHAR_IDX      |  4259 |       |       |    16   (0)| 00:00:01 |
|  31 |            TABLE ACCESS FULL                  | PRISONER                             |   299K|  4980K|       |   645   (1)| 00:00:01 |
|* 32 |       TABLE ACCESS BY INDEX ROWID BATCHED     | ACCOMMODATION                        |     1 |    31 |       |  2016   (1)| 00:00:01 |
|* 33 |        INDEX RANGE SCAN                       | ACCOMMODATION_START_DATE_TO_CHAR_IDX | 13437 |       |       |    43   (0)| 00:00:01 |
|* 34 |      TABLE ACCESS BY INDEX ROWID              | CELL                                 |     1 |    11 |       |     1   (0)| 00:00:01 |
|* 35 |       INDEX UNIQUE SCAN                       | SYS_C008883                          |     1 |       |       |     0   (0)| 00:00:01 |
|* 36 |     TABLE ACCESS BY INDEX ROWID               | PRISON_BLOCK                         |     1 |     7 |       |     1   (0)| 00:00:01 |
|* 37 |      INDEX UNIQUE SCAN                        | SYS_C008855                          |     1 |       |       |     0   (0)| 00:00:01 |
|* 38 |    INDEX UNIQUE SCAN                          | SYS_C008868                          |     1 |       |       |     0   (0)| 00:00:01 |
|  39 |   TABLE ACCESS BY INDEX ROWID                 | GUARD                                |     1 |    23 |       |     1   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   6 - access("P"."ID"="PS"."ID")
   7 - access("P"."ID"="PC"."ID")
  11 - filter(:EVENT_TYPE IS NULL OR INSTR("R"."REASON",:EVENT_TYPE)>0)
  12 - access(TO_CHAR(INTERNAL_FUNCTION("ISSUE_DATE"),'YYYY-MM-DD')>=:START_DATE AND 
              TO_CHAR(INTERNAL_FUNCTION("ISSUE_DATE"),'YYYY-MM-DD')<=:END_DATE)
  13 - access("R"."FK_PRISONER"="P"."ID")
  16 - filter((:SENTENCE_COUNT IS NULL OR COUNT(*)=TO_NUMBER(:SENTENCE_COUNT)) AND (:REPRIMAND_COUNT IS NULL OR 
              COUNT(*)=TO_NUMBER(:REPRIMAND_COUNT)))
  19 - filter(:END_DATE>=:START_DATE)
  20 - access("P"."ID"="S"."FK_PRISONER")
  22 - access("P"."ID"="R"."FK_PRISONER")
  25 - filter(:CRIME IS NULL OR INSTR("PS"."CRIME",:CRIME)>0)
  27 - filter(:END_DATE>=:START_DATE)
  28 - access("P"."ID"="S"."FK_PRISONER")
  29 - filter("S"."REAL_END_DATE" IS NULL OR TO_CHAR(INTERNAL_FUNCTION("REAL_END_DATE"),'YYYY-MM-DD')>=:END_DATE)
  30 - access(TO_CHAR(INTERNAL_FUNCTION("START_DATE"),'YYYY-MM-DD')<=:START_DATE)
  32 - filter("P"."ID"="A"."FK_PRISONER" AND ("A"."END_DATE" IS NULL OR 
              TO_CHAR(INTERNAL_FUNCTION("END_DATE"),'YYYY-MM-DD')>=:END_DATE))
  33 - access(TO_CHAR(INTERNAL_FUNCTION("START_DATE"),'YYYY-MM-DD')<=:START_DATE)
  34 - filter("C"."IS_SOLITARY"=TO_NUMBER(:IS_IN_SOLITARY) OR :IS_IN_SOLITARY IS NULL)
  35 - access("C"."ID"="A"."FK_CELL")
  36 - filter(:BLOCK_NUMBER IS NULL OR "PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  37 - access("PB"."ID"="C"."FK_BLOCK")
  38 - access("R"."FK_GUARD"="G"."ID")
 
Note
-----
   - this is an adaptive plan
   ```]
)

*`query4`:*
#plan(
   [```
Plan hash value: 171928505
 
---------------------------------------------------------------------------------------------------------
| Id  | Operation                       | Name          | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                |               |     5 |    65 |       | 98504   (2)| 00:00:04 |
|   1 |  HASH UNIQUE                    |               |     5 |    65 |       | 98504   (2)| 00:00:04 |
|   2 |   UNION-ALL                     |               |       |       |       |            |          |
|   3 |    SORT AGGREGATE               |               |     1 |    13 |       | 19701   (2)| 00:00:01 |
|   4 |     VIEW                        |               |   157K|  1999K|       | 18944   (2)| 00:00:01 |
|   5 |      HASH GROUP BY              |               |   157K|  8612K|       | 18944   (2)| 00:00:01 |
|   6 |       MERGE JOIN OUTER          |               |  2487K|   132M|       | 18944   (2)| 00:00:01 |
|   7 |        MERGE JOIN OUTER         |               |  1592K|    69M|       | 15652   (2)| 00:00:01 |
|   8 |         MERGE JOIN OUTER        |               |   323K|    10M|       |  7035   (2)| 00:00:01 |
|*  9 |          FILTER                 |               |       |       |       |            |          |
|  10 |           MERGE JOIN OUTER      |               |   157K|  3845K|       |  3939   (3)| 00:00:01 |
|  11 |            SORT JOIN            |               |   157K|  2460K|  8680K|  1494   (2)| 00:00:01 |
|* 12 |             TABLE ACCESS FULL   | PRISONER      |   157K|  2460K|       |   650   (2)| 00:00:01 |
|* 13 |            SORT JOIN            |               | 10513 | 94617 |       |  2445   (4)| 00:00:01 |
|  14 |             VIEW                |               | 10513 | 94617 |       |  2444   (4)| 00:00:01 |
|* 15 |              HASH JOIN          |               | 10513 |   420K|       |  2444   (4)| 00:00:01 |
|  16 |               TABLE ACCESS FULL | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 17 |               HASH JOIN         |               | 10513 |   349K|       |  2442   (4)| 00:00:01 |
|* 18 |                TABLE ACCESS FULL| ACCOMMODATION | 10513 |   266K|       |  2088   (4)| 00:00:01 |
|  19 |                TABLE ACCESS FULL| CELL          |   251K|  1966K|       |   351   (1)| 00:00:01 |
|* 20 |          SORT JOIN              |               |   422K|  4122K|    16M|  3096   (2)| 00:00:01 |
|  21 |           TABLE ACCESS FULL     | REPRIMAND     |   422K|  4122K|       |  1394   (1)| 00:00:01 |
|* 22 |         SORT JOIN               |               |  1493K|    15M|    57M|  8617   (2)| 00:00:01 |
|  23 |          TABLE ACCESS FULL      | ACCOMMODATION |  1493K|    15M|       |  2032   (2)| 00:00:01 |
|* 24 |        SORT JOIN                |               |   473K|  4620K|    18M|  3285   (2)| 00:00:01 |
|  25 |         TABLE ACCESS FULL       | SENTENCE      |   473K|  4620K|       |  1379   (1)| 00:00:01 |
|  26 |    SORT AGGREGATE               |               |     1 |    13 |       | 19701   (2)| 00:00:01 |
|  27 |     VIEW                        |               |   157K|  1999K|       | 18944   (2)| 00:00:01 |
|  28 |      HASH GROUP BY              |               |   157K|  8612K|       | 18944   (2)| 00:00:01 |
|  29 |       MERGE JOIN OUTER          |               |  2487K|   132M|       | 18944   (2)| 00:00:01 |
|  30 |        MERGE JOIN OUTER         |               |  1592K|    69M|       | 15652   (2)| 00:00:01 |
|  31 |         MERGE JOIN OUTER        |               |   323K|    10M|       |  7035   (2)| 00:00:01 |
|* 32 |          FILTER                 |               |       |       |       |            |          |
|  33 |           MERGE JOIN OUTER      |               |   157K|  3845K|       |  3939   (3)| 00:00:01 |
|  34 |            SORT JOIN            |               |   157K|  2460K|  8680K|  1494   (2)| 00:00:01 |
|* 35 |             TABLE ACCESS FULL   | PRISONER      |   157K|  2460K|       |   650   (2)| 00:00:01 |
|* 36 |            SORT JOIN            |               | 10513 | 94617 |       |  2445   (4)| 00:00:01 |
|  37 |             VIEW                |               | 10513 | 94617 |       |  2444   (4)| 00:00:01 |
|* 38 |              HASH JOIN          |               | 10513 |   420K|       |  2444   (4)| 00:00:01 |
|  39 |               TABLE ACCESS FULL | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 40 |               HASH JOIN         |               | 10513 |   349K|       |  2442   (4)| 00:00:01 |
|* 41 |                TABLE ACCESS FULL| ACCOMMODATION | 10513 |   266K|       |  2088   (4)| 00:00:01 |
|  42 |                TABLE ACCESS FULL| CELL          |   251K|  1966K|       |   351   (1)| 00:00:01 |
|* 43 |          SORT JOIN              |               |   422K|  4122K|    16M|  3096   (2)| 00:00:01 |
|  44 |           TABLE ACCESS FULL     | REPRIMAND     |   422K|  4122K|       |  1394   (1)| 00:00:01 |
|* 45 |         SORT JOIN               |               |  1493K|    15M|    57M|  8617   (2)| 00:00:01 |
|  46 |          TABLE ACCESS FULL      | ACCOMMODATION |  1493K|    15M|       |  2032   (2)| 00:00:01 |
|* 47 |        SORT JOIN                |               |   473K|  4620K|    18M|  3285   (2)| 00:00:01 |
|  48 |         TABLE ACCESS FULL       | SENTENCE      |   473K|  4620K|       |  1379   (1)| 00:00:01 |
|  49 |    SORT AGGREGATE               |               |     1 |    13 |       | 19701   (2)| 00:00:01 |
|  50 |     VIEW                        |               |   157K|  1999K|       | 18944   (2)| 00:00:01 |
|  51 |      HASH GROUP BY              |               |   157K|  8612K|       | 18944   (2)| 00:00:01 |
|  52 |       MERGE JOIN OUTER          |               |  2487K|   132M|       | 18944   (2)| 00:00:01 |
|  53 |        MERGE JOIN OUTER         |               |  1592K|    69M|       | 15652   (2)| 00:00:01 |
|  54 |         MERGE JOIN OUTER        |               |   323K|    10M|       |  7035   (2)| 00:00:01 |
|* 55 |          FILTER                 |               |       |       |       |            |          |
|  56 |           MERGE JOIN OUTER      |               |   157K|  3845K|       |  3939   (3)| 00:00:01 |
|  57 |            SORT JOIN            |               |   157K|  2460K|  8680K|  1494   (2)| 00:00:01 |
|* 58 |             TABLE ACCESS FULL   | PRISONER      |   157K|  2460K|       |   650   (2)| 00:00:01 |
|* 59 |            SORT JOIN            |               | 10513 | 94617 |       |  2445   (4)| 00:00:01 |
|  60 |             VIEW                |               | 10513 | 94617 |       |  2444   (4)| 00:00:01 |
|* 61 |              HASH JOIN          |               | 10513 |   420K|       |  2444   (4)| 00:00:01 |
|  62 |               TABLE ACCESS FULL | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 63 |               HASH JOIN         |               | 10513 |   349K|       |  2442   (4)| 00:00:01 |
|* 64 |                TABLE ACCESS FULL| ACCOMMODATION | 10513 |   266K|       |  2088   (4)| 00:00:01 |
|  65 |                TABLE ACCESS FULL| CELL          |   251K|  1966K|       |   351   (1)| 00:00:01 |
|* 66 |          SORT JOIN              |               |   422K|  4122K|    16M|  3096   (2)| 00:00:01 |
|  67 |           TABLE ACCESS FULL     | REPRIMAND     |   422K|  4122K|       |  1394   (1)| 00:00:01 |
|* 68 |         SORT JOIN               |               |  1493K|    15M|    57M|  8617   (2)| 00:00:01 |
|  69 |          TABLE ACCESS FULL      | ACCOMMODATION |  1493K|    15M|       |  2032   (2)| 00:00:01 |
|* 70 |        SORT JOIN                |               |   473K|  4620K|    18M|  3285   (2)| 00:00:01 |
|  71 |         TABLE ACCESS FULL       | SENTENCE      |   473K|  4620K|       |  1379   (1)| 00:00:01 |
|  72 |    SORT AGGREGATE               |               |     1 |    13 |       | 19701   (2)| 00:00:01 |
|  73 |     VIEW                        |               |   157K|  1999K|       | 18944   (2)| 00:00:01 |
|  74 |      HASH GROUP BY              |               |   157K|  8612K|       | 18944   (2)| 00:00:01 |
|  75 |       MERGE JOIN OUTER          |               |  2487K|   132M|       | 18944   (2)| 00:00:01 |
|  76 |        MERGE JOIN OUTER         |               |  1592K|    69M|       | 15652   (2)| 00:00:01 |
|  77 |         MERGE JOIN OUTER        |               |   323K|    10M|       |  7035   (2)| 00:00:01 |
|* 78 |          FILTER                 |               |       |       |       |            |          |
|  79 |           MERGE JOIN OUTER      |               |   157K|  3845K|       |  3939   (3)| 00:00:01 |
|  80 |            SORT JOIN            |               |   157K|  2460K|  8680K|  1494   (2)| 00:00:01 |
|* 81 |             TABLE ACCESS FULL   | PRISONER      |   157K|  2460K|       |   650   (2)| 00:00:01 |
|* 82 |            SORT JOIN            |               | 10513 | 94617 |       |  2445   (4)| 00:00:01 |
|  83 |             VIEW                |               | 10513 | 94617 |       |  2444   (4)| 00:00:01 |
|* 84 |              HASH JOIN          |               | 10513 |   420K|       |  2444   (4)| 00:00:01 |
|  85 |               TABLE ACCESS FULL | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 86 |               HASH JOIN         |               | 10513 |   349K|       |  2442   (4)| 00:00:01 |
|* 87 |                TABLE ACCESS FULL| ACCOMMODATION | 10513 |   266K|       |  2088   (4)| 00:00:01 |
|  88 |                TABLE ACCESS FULL| CELL          |   251K|  1966K|       |   351   (1)| 00:00:01 |
|* 89 |          SORT JOIN              |               |   422K|  4122K|    16M|  3096   (2)| 00:00:01 |
|  90 |           TABLE ACCESS FULL     | REPRIMAND     |   422K|  4122K|       |  1394   (1)| 00:00:01 |
|* 91 |         SORT JOIN               |               |  1493K|    15M|    57M|  8617   (2)| 00:00:01 |
|  92 |          TABLE ACCESS FULL      | ACCOMMODATION |  1493K|    15M|       |  2032   (2)| 00:00:01 |
|* 93 |        SORT JOIN                |               |   473K|  4620K|    18M|  3285   (2)| 00:00:01 |
|  94 |         TABLE ACCESS FULL       | SENTENCE      |   473K|  4620K|       |  1379   (1)| 00:00:01 |
|  95 |    SORT AGGREGATE               |               |     1 |    13 |       | 19701   (2)| 00:00:01 |
|  96 |     VIEW                        |               |   157K|  1999K|       | 18944   (2)| 00:00:01 |
|  97 |      HASH GROUP BY              |               |   157K|  8612K|       | 18944   (2)| 00:00:01 |
|  98 |       MERGE JOIN OUTER          |               |  2487K|   132M|       | 18944   (2)| 00:00:01 |
|  99 |        MERGE JOIN OUTER         |               |  1592K|    69M|       | 15652   (2)| 00:00:01 |
| 100 |         MERGE JOIN OUTER        |               |   323K|    10M|       |  7035   (2)| 00:00:01 |
|*101 |          FILTER                 |               |       |       |       |            |          |
| 102 |           MERGE JOIN OUTER      |               |   157K|  3845K|       |  3939   (3)| 00:00:01 |
| 103 |            SORT JOIN            |               |   157K|  2460K|  8680K|  1494   (2)| 00:00:01 |
|*104 |             TABLE ACCESS FULL   | PRISONER      |   157K|  2460K|       |   650   (2)| 00:00:01 |
|*105 |            SORT JOIN            |               | 10513 | 94617 |       |  2445   (4)| 00:00:01 |
| 106 |             VIEW                |               | 10513 | 94617 |       |  2444   (4)| 00:00:01 |
|*107 |              HASH JOIN          |               | 10513 |   420K|       |  2444   (4)| 00:00:01 |
| 108 |               TABLE ACCESS FULL | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|*109 |               HASH JOIN         |               | 10513 |   349K|       |  2442   (4)| 00:00:01 |
|*110 |                TABLE ACCESS FULL| ACCOMMODATION | 10513 |   266K|       |  2088   (4)| 00:00:01 |
| 111 |                TABLE ACCESS FULL| CELL          |   251K|  1966K|       |   351   (1)| 00:00:01 |
|*112 |          SORT JOIN              |               |   422K|  4122K|    16M|  3096   (2)| 00:00:01 |
| 113 |           TABLE ACCESS FULL     | REPRIMAND     |   422K|  4122K|       |  1394   (1)| 00:00:01 |
|*114 |         SORT JOIN               |               |  1493K|    15M|    57M|  8617   (2)| 00:00:01 |
| 115 |          TABLE ACCESS FULL      | ACCOMMODATION |  1493K|    15M|       |  2032   (2)| 00:00:01 |
|*116 |        SORT JOIN                |               |   473K|  4620K|    18M|  3285   (2)| 00:00:01 |
| 117 |         TABLE ACCESS FULL       | SENTENCE      |   473K|  4620K|       |  1379   (1)| 00:00:01 |
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
   ```],
   [```
Plan hash value: 171928505
 
---------------------------------------------------------------------------------------------------------
| Id  | Operation                       | Name          | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                |               |     5 |    65 |       | 98530   (2)| 00:00:04 |
|   1 |  HASH UNIQUE                    |               |     5 |    65 |       | 98530   (2)| 00:00:04 |
|   2 |   UNION-ALL                     |               |       |       |       |            |          |
|   3 |    SORT AGGREGATE               |               |     1 |    13 |       | 19707   (2)| 00:00:01 |
|   4 |     VIEW                        |               |   157K|  1999K|       | 18950   (2)| 00:00:01 |
|   5 |      HASH GROUP BY              |               |   157K|  8612K|       | 18950   (2)| 00:00:01 |
|   6 |       MERGE JOIN OUTER          |               |  2487K|   132M|       | 18950   (2)| 00:00:01 |
|   7 |        MERGE JOIN OUTER         |               |  1592K|    69M|       | 15656   (2)| 00:00:01 |
|   8 |         MERGE JOIN OUTER        |               |   323K|    10M|       |  7035   (2)| 00:00:01 |
|*  9 |          FILTER                 |               |       |       |       |            |          |
|  10 |           MERGE JOIN OUTER      |               |   157K|  3845K|       |  3939   (3)| 00:00:01 |
|  11 |            SORT JOIN            |               |   157K|  2460K|  8680K|  1494   (2)| 00:00:01 |
|* 12 |             TABLE ACCESS FULL   | PRISONER      |   157K|  2460K|       |   650   (2)| 00:00:01 |
|* 13 |            SORT JOIN            |               | 10513 | 94617 |       |  2445   (4)| 00:00:01 |
|  14 |             VIEW                |               | 10513 | 94617 |       |  2444   (4)| 00:00:01 |
|* 15 |              HASH JOIN          |               | 10513 |   420K|       |  2444   (4)| 00:00:01 |
|  16 |               TABLE ACCESS FULL | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 17 |               HASH JOIN         |               | 10513 |   349K|       |  2442   (4)| 00:00:01 |
|* 18 |                TABLE ACCESS FULL| ACCOMMODATION | 10513 |   266K|       |  2088   (4)| 00:00:01 |
|  19 |                TABLE ACCESS FULL| CELL          |   251K|  1966K|       |   351   (1)| 00:00:01 |
|* 20 |          SORT JOIN              |               |   422K|  4122K|    16M|  3096   (2)| 00:00:01 |
|  21 |           TABLE ACCESS FULL     | REPRIMAND     |   422K|  4122K|       |  1394   (1)| 00:00:01 |
|* 22 |         SORT JOIN               |               |  1493K|    15M|    57M|  8621   (2)| 00:00:01 |
|  23 |          TABLE ACCESS FULL      | ACCOMMODATION |  1493K|    15M|       |  2036   (2)| 00:00:01 |
|* 24 |        SORT JOIN                |               |   473K|  4620K|    18M|  3288   (2)| 00:00:01 |
|  25 |         TABLE ACCESS FULL       | SENTENCE      |   473K|  4620K|       |  1381   (1)| 00:00:01 |
|  26 |    SORT AGGREGATE               |               |     1 |    13 |       | 19707   (2)| 00:00:01 |
|  27 |     VIEW                        |               |   157K|  1999K|       | 18950   (2)| 00:00:01 |
|  28 |      HASH GROUP BY              |               |   157K|  8612K|       | 18950   (2)| 00:00:01 |
|  29 |       MERGE JOIN OUTER          |               |  2487K|   132M|       | 18950   (2)| 00:00:01 |
|  30 |        MERGE JOIN OUTER         |               |  1592K|    69M|       | 15656   (2)| 00:00:01 |
|  31 |         MERGE JOIN OUTER        |               |   323K|    10M|       |  7035   (2)| 00:00:01 |
|* 32 |          FILTER                 |               |       |       |       |            |          |
|  33 |           MERGE JOIN OUTER      |               |   157K|  3845K|       |  3939   (3)| 00:00:01 |
|  34 |            SORT JOIN            |               |   157K|  2460K|  8680K|  1494   (2)| 00:00:01 |
|* 35 |             TABLE ACCESS FULL   | PRISONER      |   157K|  2460K|       |   650   (2)| 00:00:01 |
|* 36 |            SORT JOIN            |               | 10513 | 94617 |       |  2445   (4)| 00:00:01 |
|  37 |             VIEW                |               | 10513 | 94617 |       |  2444   (4)| 00:00:01 |
|* 38 |              HASH JOIN          |               | 10513 |   420K|       |  2444   (4)| 00:00:01 |
|  39 |               TABLE ACCESS FULL | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 40 |               HASH JOIN         |               | 10513 |   349K|       |  2442   (4)| 00:00:01 |
|* 41 |                TABLE ACCESS FULL| ACCOMMODATION | 10513 |   266K|       |  2088   (4)| 00:00:01 |
|  42 |                TABLE ACCESS FULL| CELL          |   251K|  1966K|       |   351   (1)| 00:00:01 |
|* 43 |          SORT JOIN              |               |   422K|  4122K|    16M|  3096   (2)| 00:00:01 |
|  44 |           TABLE ACCESS FULL     | REPRIMAND     |   422K|  4122K|       |  1394   (1)| 00:00:01 |
|* 45 |         SORT JOIN               |               |  1493K|    15M|    57M|  8621   (2)| 00:00:01 |
|  46 |          TABLE ACCESS FULL      | ACCOMMODATION |  1493K|    15M|       |  2036   (2)| 00:00:01 |
|* 47 |        SORT JOIN                |               |   473K|  4620K|    18M|  3288   (2)| 00:00:01 |
|  48 |         TABLE ACCESS FULL       | SENTENCE      |   473K|  4620K|       |  1381   (1)| 00:00:01 |
|  49 |    SORT AGGREGATE               |               |     1 |    13 |       | 19707   (2)| 00:00:01 |
|  50 |     VIEW                        |               |   157K|  1999K|       | 18950   (2)| 00:00:01 |
|  51 |      HASH GROUP BY              |               |   157K|  8612K|       | 18950   (2)| 00:00:01 |
|  52 |       MERGE JOIN OUTER          |               |  2487K|   132M|       | 18950   (2)| 00:00:01 |
|  53 |        MERGE JOIN OUTER         |               |  1592K|    69M|       | 15656   (2)| 00:00:01 |
|  54 |         MERGE JOIN OUTER        |               |   323K|    10M|       |  7035   (2)| 00:00:01 |
|* 55 |          FILTER                 |               |       |       |       |            |          |
|  56 |           MERGE JOIN OUTER      |               |   157K|  3845K|       |  3939   (3)| 00:00:01 |
|  57 |            SORT JOIN            |               |   157K|  2460K|  8680K|  1494   (2)| 00:00:01 |
|* 58 |             TABLE ACCESS FULL   | PRISONER      |   157K|  2460K|       |   650   (2)| 00:00:01 |
|* 59 |            SORT JOIN            |               | 10513 | 94617 |       |  2445   (4)| 00:00:01 |
|  60 |             VIEW                |               | 10513 | 94617 |       |  2444   (4)| 00:00:01 |
|* 61 |              HASH JOIN          |               | 10513 |   420K|       |  2444   (4)| 00:00:01 |
|  62 |               TABLE ACCESS FULL | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 63 |               HASH JOIN         |               | 10513 |   349K|       |  2442   (4)| 00:00:01 |
|* 64 |                TABLE ACCESS FULL| ACCOMMODATION | 10513 |   266K|       |  2088   (4)| 00:00:01 |
|  65 |                TABLE ACCESS FULL| CELL          |   251K|  1966K|       |   351   (1)| 00:00:01 |
|* 66 |          SORT JOIN              |               |   422K|  4122K|    16M|  3096   (2)| 00:00:01 |
|  67 |           TABLE ACCESS FULL     | REPRIMAND     |   422K|  4122K|       |  1394   (1)| 00:00:01 |
|* 68 |         SORT JOIN               |               |  1493K|    15M|    57M|  8621   (2)| 00:00:01 |
|  69 |          TABLE ACCESS FULL      | ACCOMMODATION |  1493K|    15M|       |  2036   (2)| 00:00:01 |
|* 70 |        SORT JOIN                |               |   473K|  4620K|    18M|  3288   (2)| 00:00:01 |
|  71 |         TABLE ACCESS FULL       | SENTENCE      |   473K|  4620K|       |  1381   (1)| 00:00:01 |
|  72 |    SORT AGGREGATE               |               |     1 |    13 |       | 19707   (2)| 00:00:01 |
|  73 |     VIEW                        |               |   157K|  1999K|       | 18950   (2)| 00:00:01 |
|  74 |      HASH GROUP BY              |               |   157K|  8612K|       | 18950   (2)| 00:00:01 |
|  75 |       MERGE JOIN OUTER          |               |  2487K|   132M|       | 18950   (2)| 00:00:01 |
|  76 |        MERGE JOIN OUTER         |               |  1592K|    69M|       | 15656   (2)| 00:00:01 |
|  77 |         MERGE JOIN OUTER        |               |   323K|    10M|       |  7035   (2)| 00:00:01 |
|* 78 |          FILTER                 |               |       |       |       |            |          |
|  79 |           MERGE JOIN OUTER      |               |   157K|  3845K|       |  3939   (3)| 00:00:01 |
|  80 |            SORT JOIN            |               |   157K|  2460K|  8680K|  1494   (2)| 00:00:01 |
|* 81 |             TABLE ACCESS FULL   | PRISONER      |   157K|  2460K|       |   650   (2)| 00:00:01 |
|* 82 |            SORT JOIN            |               | 10513 | 94617 |       |  2445   (4)| 00:00:01 |
|  83 |             VIEW                |               | 10513 | 94617 |       |  2444   (4)| 00:00:01 |
|* 84 |              HASH JOIN          |               | 10513 |   420K|       |  2444   (4)| 00:00:01 |
|  85 |               TABLE ACCESS FULL | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 86 |               HASH JOIN         |               | 10513 |   349K|       |  2442   (4)| 00:00:01 |
|* 87 |                TABLE ACCESS FULL| ACCOMMODATION | 10513 |   266K|       |  2088   (4)| 00:00:01 |
|  88 |                TABLE ACCESS FULL| CELL          |   251K|  1966K|       |   351   (1)| 00:00:01 |
|* 89 |          SORT JOIN              |               |   422K|  4122K|    16M|  3096   (2)| 00:00:01 |
|  90 |           TABLE ACCESS FULL     | REPRIMAND     |   422K|  4122K|       |  1394   (1)| 00:00:01 |
|* 91 |         SORT JOIN               |               |  1493K|    15M|    57M|  8621   (2)| 00:00:01 |
|  92 |          TABLE ACCESS FULL      | ACCOMMODATION |  1493K|    15M|       |  2036   (2)| 00:00:01 |
|* 93 |        SORT JOIN                |               |   473K|  4620K|    18M|  3288   (2)| 00:00:01 |
|  94 |         TABLE ACCESS FULL       | SENTENCE      |   473K|  4620K|       |  1381   (1)| 00:00:01 |
|  95 |    SORT AGGREGATE               |               |     1 |    13 |       | 19701   (2)| 00:00:01 |
|  96 |     VIEW                        |               |   157K|  1999K|       | 18944   (2)| 00:00:01 |
|  97 |      HASH GROUP BY              |               |   157K|  8612K|       | 18944   (2)| 00:00:01 |
|  98 |       MERGE JOIN OUTER          |               |  2487K|   132M|       | 18944   (2)| 00:00:01 |
|  99 |        MERGE JOIN OUTER         |               |  1592K|    69M|       | 15652   (2)| 00:00:01 |
| 100 |         MERGE JOIN OUTER        |               |   323K|    10M|       |  7035   (2)| 00:00:01 |
|*101 |          FILTER                 |               |       |       |       |            |          |
| 102 |           MERGE JOIN OUTER      |               |   157K|  3845K|       |  3939   (3)| 00:00:01 |
| 103 |            SORT JOIN            |               |   157K|  2460K|  8680K|  1494   (2)| 00:00:01 |
|*104 |             TABLE ACCESS FULL   | PRISONER      |   157K|  2460K|       |   650   (2)| 00:00:01 |
|*105 |            SORT JOIN            |               | 10513 | 94617 |       |  2445   (4)| 00:00:01 |
| 106 |             VIEW                |               | 10513 | 94617 |       |  2444   (4)| 00:00:01 |
|*107 |              HASH JOIN          |               | 10513 |   420K|       |  2444   (4)| 00:00:01 |
| 108 |               TABLE ACCESS FULL | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|*109 |               HASH JOIN         |               | 10513 |   349K|       |  2442   (4)| 00:00:01 |
|*110 |                TABLE ACCESS FULL| ACCOMMODATION | 10513 |   266K|       |  2088   (4)| 00:00:01 |
| 111 |                TABLE ACCESS FULL| CELL          |   251K|  1966K|       |   351   (1)| 00:00:01 |
|*112 |          SORT JOIN              |               |   422K|  4122K|    16M|  3096   (2)| 00:00:01 |
| 113 |           TABLE ACCESS FULL     | REPRIMAND     |   422K|  4122K|       |  1394   (1)| 00:00:01 |
|*114 |         SORT JOIN               |               |  1493K|    15M|    57M|  8617   (2)| 00:00:01 |
| 115 |          TABLE ACCESS FULL      | ACCOMMODATION |  1493K|    15M|       |  2032   (2)| 00:00:01 |
|*116 |        SORT JOIN                |               |   473K|  4620K|    18M|  3285   (2)| 00:00:01 |
| 117 |         TABLE ACCESS FULL       | SENTENCE      |   473K|  4620K|       |  1379   (1)| 00:00:01 |
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
   ```]
)

*`change1`:*
#plan(
   [```
Plan hash value: 3371688238
 
----------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                            | Name                        | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------------------------------
|   0 | UPDATE STATEMENT                     |                             |     1 |    35 |       | 29726   (2)| 00:00:02 |
|   1 |  UPDATE                              | GUARD                       |       |       |       |            |          |
|   2 |   NESTED LOOPS SEMI                  |                             |     1 |    35 |       | 29726   (2)| 00:00:02 |
|*  3 |    HASH JOIN ANTI                    |                             |     1 |    33 |       | 28731   (2)| 00:00:02 |
|*  4 |     TABLE ACCESS FULL                | GUARD                       |   129 |  2580 |       |    29   (0)| 00:00:01 |
|   5 |     VIEW                             | VW_NSO_1                    | 14217 |   180K|       | 28702   (2)| 00:00:02 |
|   6 |      NESTED LOOPS SEMI               |                             | 14217 |   499K|       | 28702   (2)| 00:00:02 |
|   7 |       VIEW                           | VW_GBF_20                   | 14217 |   180K|       | 28700   (2)| 00:00:02 |
|   8 |        SORT GROUP BY                 |                             | 14217 |   360K|   121M| 28700   (2)| 00:00:02 |
|   9 |         NESTED LOOPS                 |                             |  3506K|    86M|       | 19319   (1)| 00:00:01 |
|  10 |          NESTED LOOPS                |                             |  3507K|    86M|       | 19319   (1)| 00:00:01 |
|* 11 |           TABLE ACCESS FULL          | PATROL_SLOT                 |  1370 | 21920 |       |    34   (3)| 00:00:01 |
|* 12 |           INDEX RANGE SCAN           | PATROL_FK_PATROL_SLOT_INDEX |  2560 |       |       |     5   (0)| 00:00:01 |
|  13 |          TABLE ACCESS BY INDEX ROWID | PATROL                      |  2560 | 25600 |       |    14   (0)| 00:00:01 |
|* 14 |       INDEX UNIQUE SCAN              | SYS_C008868                 |     1 |    23 |       |     0   (0)| 00:00:01 |
|  15 |    VIEW PUSHED PREDICATE             | VW_NSO_2                    |     1 |     2 |       |   994   (1)| 00:00:01 |
|  16 |     NESTED LOOPS                     |                             |     1 |    36 |       |   994   (1)| 00:00:01 |
|* 17 |      INDEX UNIQUE SCAN               | SYS_C008868                 |     1 |    23 |       |     1   (0)| 00:00:01 |
|  18 |      VIEW                            | VW_GBF_56                   |     1 |    13 |       |   993   (1)| 00:00:01 |
|  19 |       SORT GROUP BY                  |                             |     1 |    47 |       |   993   (1)| 00:00:01 |
|  20 |        NESTED LOOPS                  |                             |     1 |    47 |       |   993   (1)| 00:00:01 |
|  21 |         NESTED LOOPS                 |                             |   174K|    47 |       |   993   (1)| 00:00:01 |
|  22 |          NESTED LOOPS                |                             |    68 |  2312 |       |    35   (3)| 00:00:01 |
|  23 |           TABLE ACCESS BY INDEX ROWID| PRISON_BLOCK                |     1 |     7 |       |     1   (0)| 00:00:01 |
|* 24 |            INDEX UNIQUE SCAN         | SYS_C008856                 |     1 |       |       |     0   (0)| 00:00:01 |
|* 25 |           TABLE ACCESS FULL          | PATROL_SLOT                 |    68 |  1836 |       |    34   (3)| 00:00:01 |
|* 26 |          INDEX RANGE SCAN            | PATROL_FK_PATROL_SLOT_INDEX |  2560 |       |       |     5   (0)| 00:00:01 |
|* 27 |         TABLE ACCESS BY INDEX ROWID  | PATROL                      |     1 |    13 |       |    14   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------------------------------------
 
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
  25 - filter(TO_CHAR(INTERNAL_FUNCTION("PATROL_SLOT"."START_TIME"),'YYYY-MM-DD HH24:MI:SS')>=:START_TIME AND 
              TO_CHAR(INTERNAL_FUNCTION("PATROL_SLOT"."END_TIME"),'YYYY-MM-DD HH24:MI:SS')<=:END_TIME)
  26 - access("PATROL"."FK_PATROL_SLOT"="PATROL_SLOT"."ID")
  27 - filter("PATROL"."FK_GUARD"="ID" AND "PATROL"."FK_BLOCK"="PRISON_BLOCK"."ID")
   ```],
   [```
Plan hash value: 1080582287
 
-------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                    | Name                               | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------------------------------------------------
|   0 | UPDATE STATEMENT                             |                                    |     1 |    35 |       | 29666   (2)| 00:00:02 |
|   1 |  UPDATE                                      | GUARD                              |       |       |       |            |          |
|   2 |   NESTED LOOPS SEMI                          |                                    |     1 |    35 |       | 29666   (2)| 00:00:02 |
|*  3 |    HASH JOIN ANTI                            |                                    |     1 |    33 |       | 28702   (2)| 00:00:02 |
|*  4 |     TABLE ACCESS FULL                        | GUARD                              |   129 |  2580 |       |    29   (0)| 00:00:01 |
|   5 |     VIEW                                     | VW_NSO_1                           | 14217 |   180K|       | 28672   (2)| 00:00:02 |
|   6 |      NESTED LOOPS SEMI                       |                                    | 14217 |   499K|       | 28672   (2)| 00:00:02 |
|   7 |       VIEW                                   | VW_GBF_20                          | 14217 |   180K|       | 28671   (2)| 00:00:02 |
|   8 |        SORT GROUP BY                         |                                    | 14217 |   360K|   121M| 28671   (2)| 00:00:02 |
|   9 |         NESTED LOOPS                         |                                    |  3506K|    86M|       | 19290   (1)| 00:00:01 |
|  10 |          NESTED LOOPS                        |                                    |  3507K|    86M|       | 19290   (1)| 00:00:01 |
|  11 |           TABLE ACCESS BY INDEX ROWID BATCHED| PATROL_SLOT                        |  1370 | 21920 |       |     5   (0)| 00:00:01 |
|* 12 |            INDEX RANGE SCAN                  | PATROL_SLOT_START_TIME_TO_CHAR_IDX |   247 |       |       |     3   (0)| 00:00:01 |
|* 13 |           INDEX RANGE SCAN                   | PATROL_FK_PATROL_SLOT_INDEX        |  2560 |       |       |     5   (0)| 00:00:01 |
|  14 |          TABLE ACCESS BY INDEX ROWID         | PATROL                             |  2560 | 25600 |       |    14   (0)| 00:00:01 |
|* 15 |       INDEX UNIQUE SCAN                      | SYS_C008868                        |     1 |    23 |       |     0   (0)| 00:00:01 |
|  16 |    VIEW PUSHED PREDICATE                     | VW_NSO_2                           |     1 |     2 |       |   964   (1)| 00:00:01 |
|  17 |     NESTED LOOPS                             |                                    |     1 |    36 |       |   964   (1)| 00:00:01 |
|* 18 |      INDEX UNIQUE SCAN                       | SYS_C008868                        |     1 |    23 |       |     1   (0)| 00:00:01 |
|  19 |      VIEW                                    | VW_GBF_56                          |     1 |    13 |       |   963   (1)| 00:00:01 |
|  20 |       SORT GROUP BY                          |                                    |     1 |    47 |       |   963   (1)| 00:00:01 |
|  21 |        NESTED LOOPS                          |                                    |     1 |    47 |       |   963   (1)| 00:00:01 |
|  22 |         NESTED LOOPS                         |                                    |   174K|    47 |       |   963   (1)| 00:00:01 |
|  23 |          NESTED LOOPS                        |                                    |    68 |  2312 |       |     5   (0)| 00:00:01 |
|  24 |           TABLE ACCESS BY INDEX ROWID        | PRISON_BLOCK                       |     1 |     7 |       |     1   (0)| 00:00:01 |
|* 25 |            INDEX UNIQUE SCAN                 | SYS_C008856                        |     1 |       |       |     0   (0)| 00:00:01 |
|* 26 |           TABLE ACCESS BY INDEX ROWID BATCHED| PATROL_SLOT                        |    68 |  1836 |       |     4   (0)| 00:00:01 |
|* 27 |            INDEX RANGE SCAN                  | PATROL_SLOT_END_TIME_TO_CHAR_IDX   |   247 |       |       |     2   (0)| 00:00:01 |
|* 28 |          INDEX RANGE SCAN                    | PATROL_FK_PATROL_SLOT_INDEX        |  2560 |       |       |     5   (0)| 00:00:01 |
|* 29 |         TABLE ACCESS BY INDEX ROWID          | PATROL                             |     1 |    13 |       |    14   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access("ID"="ID")
   4 - filter("DISMISSAL_DATE" IS NULL AND MONTHS_BETWEEN(TO_TIMESTAMP(:NOW,'YYYY-MM-DD 
              HH24:MI:SS'),INTERNAL_FUNCTION("GUARD"."EMPLOYMENT_DATE"))<:EXPERIENCE_MONTHS)
  12 - access(TO_CHAR(INTERNAL_FUNCTION("START_TIME"),'YYYY-MM-DD HH24:MI:SS')>=:NOW)
  13 - access("PATROL"."FK_PATROL_SLOT"="PATROL_SLOT"."ID")
  15 - access("GUARD"."ID"="ITEM_1")
  18 - access("GUARD"."ID"="ID")
  25 - access("PRISON_BLOCK"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  26 - filter(TO_CHAR(INTERNAL_FUNCTION("START_TIME"),'YYYY-MM-DD HH24:MI:SS')>=:START_TIME)
  27 - access(TO_CHAR(INTERNAL_FUNCTION("END_TIME"),'YYYY-MM-DD HH24:MI:SS')<=:END_TIME)
  28 - access("PATROL"."FK_PATROL_SLOT"="PATROL_SLOT"."ID")
  29 - filter("PATROL"."FK_GUARD"="ID" AND "PATROL"."FK_BLOCK"="PRISON_BLOCK"."ID")
   ```]
)

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

*`change1`:*
#plan(
   [```
Plan hash value: 3371688238
 
----------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                            | Name                        | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------------------------------
|   0 | UPDATE STATEMENT                     |                             |     1 |    35 |       | 29726   (2)| 00:00:02 |
|   1 |  UPDATE                              | GUARD                       |       |       |       |            |          |
|   2 |   NESTED LOOPS SEMI                  |                             |     1 |    35 |       | 29726   (2)| 00:00:02 |
|*  3 |    HASH JOIN ANTI                    |                             |     1 |    33 |       | 28731   (2)| 00:00:02 |
|*  4 |     TABLE ACCESS FULL                | GUARD                       |   129 |  2580 |       |    29   (0)| 00:00:01 |
|   5 |     VIEW                             | VW_NSO_1                    | 14217 |   180K|       | 28702   (2)| 00:00:02 |
|   6 |      NESTED LOOPS SEMI               |                             | 14217 |   499K|       | 28702   (2)| 00:00:02 |
|   7 |       VIEW                           | VW_GBF_20                   | 14217 |   180K|       | 28700   (2)| 00:00:02 |
|   8 |        SORT GROUP BY                 |                             | 14217 |   360K|   121M| 28700   (2)| 00:00:02 |
|   9 |         NESTED LOOPS                 |                             |  3506K|    86M|       | 19319   (1)| 00:00:01 |
|  10 |          NESTED LOOPS                |                             |  3507K|    86M|       | 19319   (1)| 00:00:01 |
|* 11 |           TABLE ACCESS FULL          | PATROL_SLOT                 |  1370 | 21920 |       |    34   (3)| 00:00:01 |
|* 12 |           INDEX RANGE SCAN           | PATROL_FK_PATROL_SLOT_INDEX |  2560 |       |       |     5   (0)| 00:00:01 |
|  13 |          TABLE ACCESS BY INDEX ROWID | PATROL                      |  2560 | 25600 |       |    14   (0)| 00:00:01 |
|* 14 |       INDEX UNIQUE SCAN              | SYS_C008868                 |     1 |    23 |       |     0   (0)| 00:00:01 |
|  15 |    VIEW PUSHED PREDICATE             | VW_NSO_2                    |     1 |     2 |       |   994   (1)| 00:00:01 |
|  16 |     NESTED LOOPS                     |                             |     1 |    36 |       |   994   (1)| 00:00:01 |
|* 17 |      INDEX UNIQUE SCAN               | SYS_C008868                 |     1 |    23 |       |     1   (0)| 00:00:01 |
|  18 |      VIEW                            | VW_GBF_56                   |     1 |    13 |       |   993   (1)| 00:00:01 |
|  19 |       SORT GROUP BY                  |                             |     1 |    47 |       |   993   (1)| 00:00:01 |
|  20 |        NESTED LOOPS                  |                             |     1 |    47 |       |   993   (1)| 00:00:01 |
|  21 |         NESTED LOOPS                 |                             |   174K|    47 |       |   993   (1)| 00:00:01 |
|  22 |          NESTED LOOPS                |                             |    68 |  2312 |       |    35   (3)| 00:00:01 |
|  23 |           TABLE ACCESS BY INDEX ROWID| PRISON_BLOCK                |     1 |     7 |       |     1   (0)| 00:00:01 |
|* 24 |            INDEX UNIQUE SCAN         | SYS_C008856                 |     1 |       |       |     0   (0)| 00:00:01 |
|* 25 |           TABLE ACCESS FULL          | PATROL_SLOT                 |    68 |  1836 |       |    34   (3)| 00:00:01 |
|* 26 |          INDEX RANGE SCAN            | PATROL_FK_PATROL_SLOT_INDEX |  2560 |       |       |     5   (0)| 00:00:01 |
|* 27 |         TABLE ACCESS BY INDEX ROWID  | PATROL                      |     1 |    13 |       |    14   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------------------------------------
 
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
  25 - filter(TO_CHAR(INTERNAL_FUNCTION("PATROL_SLOT"."START_TIME"),'YYYY-MM-DD HH24:MI:SS')>=:START_TIME AND 
              TO_CHAR(INTERNAL_FUNCTION("PATROL_SLOT"."END_TIME"),'YYYY-MM-DD HH24:MI:SS')<=:END_TIME)
  26 - access("PATROL"."FK_PATROL_SLOT"="PATROL_SLOT"."ID")
  27 - filter("PATROL"."FK_GUARD"="ID" AND "PATROL"."FK_BLOCK"="PRISON_BLOCK"."ID")
   ```],
   [```
Plan hash value: 459225027
 
------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                   | Name                         | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------------------------------------------
|   0 | UPDATE STATEMENT                            |                              |     1 |    35 |       | 28826   (2)| 00:00:02 |
|   1 |  UPDATE                                     | GUARD                        |       |       |       |            |          |
|   2 |   NESTED LOOPS SEMI                         |                              |     1 |    35 |       | 28826   (2)| 00:00:02 |
|*  3 |    HASH JOIN ANTI                           |                              |     1 |    33 |       | 28731   (2)| 00:00:02 |
|*  4 |     TABLE ACCESS FULL                       | GUARD                        |   129 |  2580 |       |    29   (0)| 00:00:01 |
|   5 |     VIEW                                    | VW_NSO_1                     | 14217 |   180K|       | 28702   (2)| 00:00:02 |
|   6 |      NESTED LOOPS SEMI                      |                              | 14217 |   499K|       | 28702   (2)| 00:00:02 |
|   7 |       VIEW                                  | VW_GBF_20                    | 14217 |   180K|       | 28700   (2)| 00:00:02 |
|   8 |        SORT GROUP BY                        |                              | 14217 |   360K|   121M| 28700   (2)| 00:00:02 |
|   9 |         NESTED LOOPS                        |                              |  3506K|    86M|       | 19319   (1)| 00:00:01 |
|  10 |          NESTED LOOPS                       |                              |  3507K|    86M|       | 19319   (1)| 00:00:01 |
|* 11 |           TABLE ACCESS FULL                 | PATROL_SLOT                  |  1370 | 21920 |       |    34   (3)| 00:00:01 |
|* 12 |           INDEX RANGE SCAN                  | PATROL_FK_PATROL_SLOT_INDEX  |  2560 |       |       |     5   (0)| 00:00:01 |
|  13 |          TABLE ACCESS BY INDEX ROWID        | PATROL                       |  2560 | 25600 |       |    14   (0)| 00:00:01 |
|* 14 |       INDEX UNIQUE SCAN                     | SYS_C008868                  |     1 |    23 |       |     0   (0)| 00:00:01 |
|  15 |    VIEW PUSHED PREDICATE                    | VW_NSO_2                     |     1 |     2 |       |    95   (3)| 00:00:01 |
|  16 |     NESTED LOOPS                            |                              |     1 |    36 |       |    95   (3)| 00:00:01 |
|* 17 |      INDEX UNIQUE SCAN                      | SYS_C008868                  |     1 |    23 |       |     1   (0)| 00:00:01 |
|  18 |      VIEW                                   | VW_GBF_56                    |     1 |    13 |       |    94   (3)| 00:00:01 |
|  19 |       SORT GROUP BY                         |                              |     1 |    47 |       |    94   (3)| 00:00:01 |
|* 20 |        HASH JOIN SEMI                       |                              |     1 |    47 |       |    94   (3)| 00:00:01 |
|  21 |         NESTED LOOPS                        |                              |    55 |  1100 |       |    59   (0)| 00:00:01 |
|  22 |          TABLE ACCESS BY INDEX ROWID        | PRISON_BLOCK                 |     1 |     7 |       |     1   (0)| 00:00:01 |
|* 23 |           INDEX UNIQUE SCAN                 | SYS_C008856                  |     1 |       |       |     0   (0)| 00:00:01 |
|  24 |          TABLE ACCESS BY INDEX ROWID BATCHED| PATROL                       |    55 |   715 |       |    58   (0)| 00:00:01 |
|* 25 |           INDEX RANGE SCAN                  | PATROL_FK_GUARD_FK_BLOCK_IDX |    55 |       |       |     2   (0)| 00:00:01 |
|* 26 |         TABLE ACCESS FULL                   | PATROL_SLOT                  |    68 |  1836 |       |    34   (3)| 00:00:01 |
------------------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access("ID"="ID")
   4 - filter("DISMISSAL_DATE" IS NULL AND MONTHS_BETWEEN(TO_TIMESTAMP(:NOW,'YYYY-MM-DD 
              HH24:MI:SS'),INTERNAL_FUNCTION("GUARD"."EMPLOYMENT_DATE"))<:EXPERIENCE_MONTHS)
  11 - filter(TO_CHAR(INTERNAL_FUNCTION("PATROL_SLOT"."START_TIME"),'YYYY-MM-DD HH24:MI:SS')>=:NOW)
  12 - access("PATROL"."FK_PATROL_SLOT"="PATROL_SLOT"."ID")
  14 - access("GUARD"."ID"="ITEM_1")
  17 - access("GUARD"."ID"="ID")
  20 - access("PATROL"."FK_PATROL_SLOT"="PATROL_SLOT"."ID")
  23 - access("PRISON_BLOCK"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  25 - access("PATROL"."FK_GUARD"="ID" AND "PATROL"."FK_BLOCK"="PRISON_BLOCK"."ID")
  26 - filter(TO_CHAR(INTERNAL_FUNCTION("PATROL_SLOT"."START_TIME"),'YYYY-MM-DD HH24:MI:SS')>=:START_TIME AND 
              TO_CHAR(INTERNAL_FUNCTION("PATROL_SLOT"."END_TIME"),'YYYY-MM-DD HH24:MI:SS')<=:END_TIME)
   ```]
)

*`change3`:*
#plan(
   [```
Plan hash value: 2939466326
 
-----------------------------------------------------------------------------------------------------
| Id  | Operation                           | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                    |               |     1 |    52 |  3954   (3)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL            | ACCOMMODATION |       |       |            |          |
|   2 |   SEQUENCE                          | ISEQ$$_76227  |       |       |            |          |
|*  3 |    HASH JOIN                        |               |     1 |    52 |  3954   (3)| 00:00:01 |
|   4 |     VIEW                            |               |     1 |    26 |  2449   (4)| 00:00:01 |
|   5 |      COUNT                          |               |       |       |            |          |
|*  6 |       HASH JOIN ANTI                |               |     1 |    31 |  2449   (4)| 00:00:01 |
|   7 |        NESTED LOOPS                 |               |    55 |   990 |   354   (2)| 00:00:01 |
|   8 |         TABLE ACCESS BY INDEX ROWID | PRISON_BLOCK  |     1 |     7 |     1   (0)| 00:00:01 |
|*  9 |          INDEX UNIQUE SCAN          | SYS_C008856   |     1 |       |     0   (0)| 00:00:01 |
|* 10 |         TABLE ACCESS FULL           | CELL          |    55 |   605 |   353   (2)| 00:00:01 |
|  11 |        VIEW                         | VW_NSO_1      | 10659 |   135K|  2095   (5)| 00:00:01 |
|  12 |         SORT GROUP BY               |               | 10659 |   218K|  2095   (5)| 00:00:01 |
|* 13 |          TABLE ACCESS FULL          | ACCOMMODATION | 10850 |   222K|  2093   (4)| 00:00:01 |
|  14 |     VIEW                            |               |   103 |  2678 |  1505   (2)| 00:00:01 |
|  15 |      SORT GROUP BY                  |               |   103 |  9373 |  1505   (2)| 00:00:01 |
|  16 |       COUNT                         |               |       |       |            |          |
|* 17 |        FILTER                       |               |       |       |            |          |
|  18 |         NESTED LOOPS                |               |   103 |  9373 |  1504   (1)| 00:00:01 |
|  19 |          NESTED LOOPS               |               |   103 |  9373 |  1504   (1)| 00:00:01 |
|* 20 |           TABLE ACCESS FULL         | REPRIMAND     |   103 |  7622 |  1401   (2)| 00:00:01 |
|* 21 |           INDEX UNIQUE SCAN         | SYS_C008848   |     1 |       |     0   (0)| 00:00:01 |
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
Plan hash value: 4016608909
 
----------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                  | Name                          | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                           |                               |     1 |    52 |  3609   (3)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL                   | ACCOMMODATION                 |       |       |            |          |
|   2 |   SEQUENCE                                 | ISEQ$$_76227                  |       |       |            |          |
|*  3 |    HASH JOIN                               |                               |     1 |    52 |  3609   (3)| 00:00:01 |
|   4 |     VIEW                                   |                               |     1 |    26 |  2104   (5)| 00:00:01 |
|   5 |      COUNT                                 |                               |       |       |            |          |
|*  6 |       HASH JOIN ANTI                       |                               |     1 |    31 |  2104   (5)| 00:00:01 |
|   7 |        NESTED LOOPS                        |                               |    55 |   990 |     9   (0)| 00:00:01 |
|   8 |         TABLE ACCESS BY INDEX ROWID        | PRISON_BLOCK                  |     1 |     7 |     1   (0)| 00:00:01 |
|*  9 |          INDEX UNIQUE SCAN                 | SYS_C008856                   |     1 |       |     0   (0)| 00:00:01 |
|  10 |         TABLE ACCESS BY INDEX ROWID BATCHED| CELL                          |    55 |   605 |     8   (0)| 00:00:01 |
|* 11 |          INDEX RANGE SCAN                  | CELL_FK_BLOCK_IS_SOLITARY_IDX |    55 |       |     7   (0)| 00:00:01 |
|  12 |        VIEW                                | VW_NSO_1                      | 10659 |   135K|  2095   (5)| 00:00:01 |
|  13 |         SORT GROUP BY                      |                               | 10659 |   218K|  2095   (5)| 00:00:01 |
|* 14 |          TABLE ACCESS FULL                 | ACCOMMODATION                 | 10850 |   222K|  2093   (4)| 00:00:01 |
|  15 |     VIEW                                   |                               |   103 |  2678 |  1505   (2)| 00:00:01 |
|  16 |      SORT GROUP BY                         |                               |   103 |  9373 |  1505   (2)| 00:00:01 |
|  17 |       COUNT                                |                               |       |       |            |          |
|* 18 |        FILTER                              |                               |       |       |            |          |
|  19 |         NESTED LOOPS                       |                               |   103 |  9373 |  1504   (1)| 00:00:01 |
|  20 |          NESTED LOOPS                      |                               |   103 |  9373 |  1504   (1)| 00:00:01 |
|* 21 |           TABLE ACCESS FULL                | REPRIMAND                     |   103 |  7622 |  1401   (2)| 00:00:01 |
|* 22 |           INDEX UNIQUE SCAN                | SYS_C008848                   |     1 |       |     0   (0)| 00:00:01 |
|  23 |          TABLE ACCESS BY INDEX ROWID       | PRISONER                      |     1 |    17 |     1   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access("P"."N"="C"."N")
   6 - access("C"."ID"="FK_CELL")
   9 - access("PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  11 - access("PB"."ID"="C"."FK_BLOCK" AND "C"."IS_SOLITARY"=1)
  14 - filter(TO_CHAR(INTERNAL_FUNCTION("A"."START_DATE"),'YYYY-MM-DD HH24:MI:SS')<=:NOW AND ("A"."END_DATE" IS 
              NULL OR TO_CHAR(INTERNAL_FUNCTION("A"."END_DATE"),'YYYY-MM-DD HH24:MI:SS')>=:NOW))
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
Plan hash value: 87624460
 
-------------------------------------------------------------------------------------------------
| Id  | Operation                       | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                |               |   121 |  5324 |  2474   (5)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL        | REPRIMAND     |       |       |            |          |
|   2 |   SEQUENCE                      | ISEQ$$_76236  |       |       |            |          |
|*  3 |    HASH JOIN                    |               |   121 |  5324 |  2474   (5)| 00:00:01 |
|   4 |     NESTED LOOPS                |               |  2742 | 49356 |   354   (2)| 00:00:01 |
|   5 |      TABLE ACCESS BY INDEX ROWID| PRISON_BLOCK  |     1 |     7 |     1   (0)| 00:00:01 |
|*  6 |       INDEX UNIQUE SCAN         | SYS_C008856   |     1 |       |     0   (0)| 00:00:01 |
|*  7 |      TABLE ACCESS FULL          | CELL          |  2742 | 30162 |   353   (2)| 00:00:01 |
|*  8 |     TABLE ACCESS FULL           | ACCOMMODATION | 10850 |   275K|  2119   (6)| 00:00:01 |
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
Plan hash value: 3842168537
 
-------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                               | Name                          | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                        |                               |   121 |  5324 |  2142   (6)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL                | REPRIMAND                     |       |       |            |          |
|   2 |   SEQUENCE                              | ISEQ$$_76236                  |       |       |            |          |
|*  3 |    HASH JOIN                            |                               |   121 |  5324 |  2142   (6)| 00:00:01 |
|   4 |     NESTED LOOPS                        |                               |  2742 | 49356 |    22   (0)| 00:00:01 |
|   5 |      TABLE ACCESS BY INDEX ROWID        | PRISON_BLOCK                  |     1 |     7 |     1   (0)| 00:00:01 |
|*  6 |       INDEX UNIQUE SCAN                 | SYS_C008856                   |     1 |       |     0   (0)| 00:00:01 |
|   7 |      TABLE ACCESS BY INDEX ROWID BATCHED| CELL                          |  2742 | 30162 |    21   (0)| 00:00:01 |
|*  8 |       INDEX RANGE SCAN                  | CELL_FK_BLOCK_IS_SOLITARY_IDX |  2742 |       |     7   (0)| 00:00:01 |
|*  9 |     TABLE ACCESS FULL                   | ACCOMMODATION                 | 10850 |   275K|  2119   (6)| 00:00:01 |
-------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access("A"."FK_CELL"="C"."ID")
   6 - access("PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
   8 - access("C"."FK_BLOCK"="PB"."ID" AND "C"."IS_SOLITARY"=0)
   9 - filter(INTERNAL_FUNCTION("A"."START_DATE")<=TO_TIMESTAMP(:EVENT_TIME,'YYYY-MM-DD HH24:MI:SS') AND 
              ("A"."END_DATE" IS NULL OR INTERNAL_FUNCTION("A"."END_DATE")>=TO_TIMESTAMP(:EVENT_TIME,'YYYY-MM-DD HH24:MI:SS')))
   ```]
)

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

*`query2`:*
#plan(
   [```
Plan hash value: 3600760484
 
-------------------------------------------------------------------------------------------------------------
| Id  | Operation                           | Name          | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |               |     1 |    78 |       |  9834   (3)| 00:00:01 |
|   1 |  HASH GROUP BY                      |               |     1 |    78 |       |  9834   (3)| 00:00:01 |
|   2 |   NESTED LOOPS                      |               |     1 |    78 |       |  9833   (3)| 00:00:01 |
|   3 |    NESTED LOOPS                     |               |     1 |    78 |       |  9833   (3)| 00:00:01 |
|   4 |     NESTED LOOPS                    |               |     1 |    71 |       |  9832   (3)| 00:00:01 |
|*  5 |      HASH JOIN                      |               |     1 |    60 |       |  9831   (3)| 00:00:01 |
|*  6 |       HASH JOIN                     |               |     1 |    34 |       |  7742   (2)| 00:00:01 |
|   7 |        JOIN FILTER CREATE           | :BF0000       |     1 |    29 |       |  2046   (2)| 00:00:01 |
|   8 |         NESTED LOOPS                |               |     1 |    29 |       |  2046   (2)| 00:00:01 |
|   9 |          NESTED LOOPS               |               |     1 |    29 |       |  2046   (2)| 00:00:01 |
|  10 |           VIEW                      |               |     1 |     5 |       |  2045   (2)| 00:00:01 |
|* 11 |            FILTER                   |               |       |       |       |            |          |
|  12 |             SORT GROUP BY           |               |     1 |    89 |       |  2045   (2)| 00:00:01 |
|* 13 |              HASH JOIN              |               |  9590 |   833K|       |  2044   (2)| 00:00:01 |
|* 14 |               TABLE ACCESS FULL     | SENTENCE      |  9590 |   674K|       |  1397   (2)| 00:00:01 |
|  15 |               TABLE ACCESS FULL     | PRISONER      |   299K|  4980K|       |   645   (1)| 00:00:01 |
|* 16 |           INDEX UNIQUE SCAN         | SYS_C008848   |     1 |       |       |     0   (0)| 00:00:01 |
|* 17 |          TABLE ACCESS BY INDEX ROWID| PRISONER      |     1 |    24 |       |     1   (0)| 00:00:01 |
|  18 |        VIEW                         |               |    28 |   140 |       |  5696   (2)| 00:00:01 |
|* 19 |         FILTER                      |               |       |       |       |            |          |
|  20 |          JOIN FILTER USE            | :BF0000       |    28 |  1036 |       |  5696   (2)| 00:00:01 |
|  21 |           HASH GROUP BY             |               |    28 |  1036 |       |  5696   (2)| 00:00:01 |
|* 22 |            HASH JOIN RIGHT OUTER    |               |   806K|    28M|  9072K|  5648   (1)| 00:00:01 |
|  23 |             TABLE ACCESS FULL       | REPRIMAND     |   422K|  4122K|       |  1394   (1)| 00:00:01 |
|* 24 |             HASH JOIN OUTER         |               |   468K|    12M|  8496K|  2937   (1)| 00:00:01 |
|  25 |              TABLE ACCESS FULL      | PRISONER      |   299K|  4980K|       |   645   (1)| 00:00:01 |
|  26 |              TABLE ACCESS FULL      | SENTENCE      |   473K|  4620K|       |  1379   (1)| 00:00:01 |
|* 27 |       TABLE ACCESS FULL             | ACCOMMODATION | 10513 |   266K|       |  2088   (4)| 00:00:01 |
|* 28 |      TABLE ACCESS BY INDEX ROWID    | CELL          |     1 |    11 |       |     1   (0)| 00:00:01 |
|* 29 |       INDEX UNIQUE SCAN             | SYS_C008883   |     1 |       |       |     0   (0)| 00:00:01 |
|* 30 |     INDEX UNIQUE SCAN               | SYS_C008855   |     1 |       |       |     0   (0)| 00:00:01 |
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
   ```],
   [```
Plan hash value: 1822899948
 
----------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                | Name                          | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                         |                               |     1 |    78 |       |  7748   (2)| 00:00:01 |
|   1 |  HASH GROUP BY                           |                               |     1 |    78 |       |  7748   (2)| 00:00:01 |
|   2 |   NESTED LOOPS                           |                               |     1 |    78 |       |  7747   (2)| 00:00:01 |
|   3 |    NESTED LOOPS                          |                               |     1 |    78 |       |  7747   (2)| 00:00:01 |
|   4 |     NESTED LOOPS                         |                               |     1 |    71 |       |  7746   (2)| 00:00:01 |
|   5 |      NESTED LOOPS                        |                               |     1 |    60 |       |  7745   (2)| 00:00:01 |
|*  6 |       HASH JOIN                          |                               |     1 |    34 |       |  7742   (2)| 00:00:01 |
|   7 |        JOIN FILTER CREATE                | :BF0000                       |     1 |    29 |       |  2046   (2)| 00:00:01 |
|   8 |         NESTED LOOPS                     |                               |     1 |    29 |       |  2046   (2)| 00:00:01 |
|   9 |          NESTED LOOPS                    |                               |     1 |    29 |       |  2046   (2)| 00:00:01 |
|  10 |           VIEW                           |                               |     1 |     5 |       |  2045   (2)| 00:00:01 |
|* 11 |            FILTER                        |                               |       |       |       |            |          |
|  12 |             SORT GROUP BY                |                               |     1 |    89 |       |  2045   (2)| 00:00:01 |
|* 13 |              HASH JOIN                   |                               |  9590 |   833K|       |  2044   (2)| 00:00:01 |
|* 14 |               TABLE ACCESS FULL          | SENTENCE                      |  9590 |   674K|       |  1397   (2)| 00:00:01 |
|  15 |               TABLE ACCESS FULL          | PRISONER                      |   299K|  4980K|       |   645   (1)| 00:00:01 |
|* 16 |           INDEX UNIQUE SCAN              | SYS_C008848                   |     1 |       |       |     0   (0)| 00:00:01 |
|* 17 |          TABLE ACCESS BY INDEX ROWID     | PRISONER                      |     1 |    24 |       |     1   (0)| 00:00:01 |
|  18 |        VIEW                              |                               |    28 |   140 |       |  5696   (2)| 00:00:01 |
|* 19 |         FILTER                           |                               |       |       |       |            |          |
|  20 |          JOIN FILTER USE                 | :BF0000                       |    28 |  1036 |       |  5696   (2)| 00:00:01 |
|  21 |           HASH GROUP BY                  |                               |    28 |  1036 |       |  5696   (2)| 00:00:01 |
|* 22 |            HASH JOIN RIGHT OUTER         |                               |   806K|    28M|  9072K|  5648   (1)| 00:00:01 |
|  23 |             TABLE ACCESS FULL            | REPRIMAND                     |   422K|  4122K|       |  1394   (1)| 00:00:01 |
|* 24 |             HASH JOIN OUTER              |                               |   468K|    12M|  8496K|  2937   (1)| 00:00:01 |
|  25 |              TABLE ACCESS FULL           | PRISONER                      |   299K|  4980K|       |   645   (1)| 00:00:01 |
|  26 |              TABLE ACCESS FULL           | SENTENCE                      |   473K|  4620K|       |  1379   (1)| 00:00:01 |
|* 27 |       TABLE ACCESS BY INDEX ROWID BATCHED| ACCOMMODATION                 |     1 |    26 |       |     3   (0)| 00:00:01 |
|* 28 |        INDEX RANGE SCAN                  | ACCOMMODATION_FK_PRISONER_IDX |     5 |       |       |     2   (0)| 00:00:01 |
|* 29 |      TABLE ACCESS BY INDEX ROWID         | CELL                          |     1 |    11 |       |     1   (0)| 00:00:01 |
|* 30 |       INDEX UNIQUE SCAN                  | SYS_C008883                   |     1 |       |       |     0   (0)| 00:00:01 |
|* 31 |     INDEX UNIQUE SCAN                    | SYS_C008855                   |     1 |       |       |     0   (0)| 00:00:01 |
|  32 |    TABLE ACCESS BY INDEX ROWID           | PRISON_BLOCK                  |     1 |     7 |       |     1   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   6 - access("P"."ID"="PC"."ID")
  11 - filter((:CRIME IS NULL OR INSTR(LISTAGG("S"."CRIME",', ') WITHIN GROUP ( ORDER BY "S"."ID"),:CRIME)>0) AND 
              (:MIN_STAY_MONTHS IS NULL OR MONTHS_BETWEEN(:NOW,MIN("S"."START_DATE"))>=TO_NUMBER(:MIN_STAY_MONTHS)) AND 
              (:MAX_STAY_MONTHS IS NULL OR MONTHS_BETWEEN(:NOW,MIN("S"."START_DATE"))<=TO_NUMBER(:MAX_STAY_MONTHS)) AND 
              (:MIN_RELEASE_MONTHS IS NULL OR MONTHS_BETWEEN(MAX("S"."PLANNED_END_DATE"),:NOW)>=TO_NUMBER(:MIN_RELEASE_MONTHS)) AND 
              (:MAX_RELEASE_MONTHS IS NULL OR MONTHS_BETWEEN(MAX("S"."PLANNED_END_DATE"),:NOW)<=TO_NUMBER(:MAX_RELEASE_MONTHS)))
  13 - access("P"."ID"="S"."FK_PRISONER")
  14 - filter("S"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD') AND ("S"."REAL_END_DATE" IS NULL OR 
              "S"."REAL_END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD')))
  16 - access("P"."ID"="PS"."ID")
  17 - filter((:MIN_HEIGHT_M IS NULL OR "P"."HEIGHT_M">=TO_NUMBER(:MIN_HEIGHT_M)) AND (:MAX_HEIGHT_M IS NULL OR 
              "P"."HEIGHT_M"<=TO_NUMBER(:MAX_HEIGHT_M)) AND (:MIN_WEIGHT_KG IS NULL OR "P"."WEIGHT_KG">=TO_NUMBER(:MIN_WEIGHT_KG)) AND 
              (:MAX_WEIGHT_KG IS NULL OR "P"."WEIGHT_KG"<=TO_NUMBER(:MAX_WEIGHT_KG)) AND ("P"."SEX"=TO_NUMBER(:SEX) OR :SEX IS NULL) 
              AND (:MIN_AGE IS NULL OR MONTHS_BETWEEN(:NOW,INTERNAL_FUNCTION("P"."BIRTHDAY"))>=TO_NUMBER(:MIN_AGE)*12) AND (:MAX_AGE IS 
              NULL OR MONTHS_BETWEEN(:NOW,INTERNAL_FUNCTION("P"."BIRTHDAY"))<=TO_NUMBER(:MAX_AGE)*12))
  19 - filter((:MIN_SENTENCES IS NULL OR COUNT("S"."ID")>=TO_NUMBER(:MIN_SENTENCES)) AND (:MAX_SENTENCES IS NULL OR 
              COUNT("S"."ID")<=TO_NUMBER(:MAX_SENTENCES)) AND (:MIN_REPRIMANDS IS NULL OR COUNT("R"."ID")>=TO_NUMBER(:MIN_REPRIMANDS)) 
              AND (:MAX_REPRIMANDS IS NULL OR COUNT("R"."ID")<=TO_NUMBER(:MAX_REPRIMANDS)))
  22 - access("P"."ID"="R"."FK_PRISONER"(+))
  24 - access("P"."ID"="S"."FK_PRISONER"(+))
  27 - filter("A"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD') AND ("A"."END_DATE" IS NULL OR 
              "A"."END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD')))
  28 - access("A"."FK_PRISONER"="P"."ID")
  29 - filter("C"."IS_SOLITARY"=TO_NUMBER(:IS_IN_SOLITARY) OR :IS_IN_SOLITARY IS NULL)
  30 - access("C"."ID"="A"."FK_CELL")
  31 - access("PB"."ID"="C"."FK_BLOCK")
 
Note
-----
   - this is an adaptive plan
   ```]
)

*`query3`:*
#plan(
   [```
Plan hash value: 220023471
 
--------------------------------------------------------------------------------------------------------------
| Id  | Operation                            | Name          | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                     |               |     1 |  2200 |       | 11117   (2)| 00:00:01 |
|   1 |  NESTED LOOPS                        |               |     1 |  2200 |       | 11117   (2)| 00:00:01 |
|   2 |   NESTED LOOPS                       |               |     1 |  2200 |       | 11117   (2)| 00:00:01 |
|   3 |    NESTED LOOPS                      |               |     1 |  2177 |       | 11116   (2)| 00:00:01 |
|   4 |     NESTED LOOPS                     |               |     1 |  2170 |       | 11115   (2)| 00:00:01 |
|*  5 |      HASH JOIN                       |               |     1 |  2159 |       | 11114   (2)| 00:00:01 |
|*  6 |       HASH JOIN                      |               |     1 |  2133 |       |  9021   (2)| 00:00:01 |
|*  7 |        HASH JOIN                     |               |     1 |   118 |       |  6793   (2)| 00:00:01 |
|   8 |         JOIN FILTER CREATE           | :BF0000       |   103 | 10815 |       |  1504   (1)| 00:00:01 |
|   9 |          NESTED LOOPS                |               |   103 | 10815 |       |  1504   (1)| 00:00:01 |
|  10 |           NESTED LOOPS               |               |   103 | 10815 |       |  1504   (1)| 00:00:01 |
|* 11 |            TABLE ACCESS FULL         | REPRIMAND     |   103 |  8446 |       |  1401   (2)| 00:00:01 |
|* 12 |            INDEX UNIQUE SCAN         | SYS_C008848   |     1 |       |       |     0   (0)| 00:00:01 |
|  13 |           TABLE ACCESS BY INDEX ROWID| PRISONER      |     1 |    23 |       |     1   (0)| 00:00:01 |
|  14 |         VIEW                         |               |  1063 | 13819 |       |  5288   (2)| 00:00:01 |
|* 15 |          FILTER                      |               |       |       |       |            |          |
|  16 |           JOIN FILTER USE            | :BF0000       |  1063 | 28701 |       |  5288   (2)| 00:00:01 |
|  17 |            HASH GROUP BY             |               |  1063 | 28701 |       |  5288   (2)| 00:00:01 |
|* 18 |             FILTER                   |               |       |       |       |            |          |
|* 19 |              HASH JOIN               |               |   659K|    16M|  7856K|  5249   (1)| 00:00:01 |
|  20 |               TABLE ACCESS FULL      | SENTENCE      |   473K|  2310K|       |  1379   (1)| 00:00:01 |
|* 21 |               HASH JOIN              |               |   422K|  9069K|  7016K|  2799   (1)| 00:00:01 |
|  22 |                TABLE ACCESS FULL     | REPRIMAND     |   422K|  2061K|       |  1394   (1)| 00:00:01 |
|  23 |                TABLE ACCESS FULL     | PRISONER      |   299K|  4980K|       |   645   (1)| 00:00:01 |
|* 24 |        VIEW                          |               |  9870 |    18M|       |  2228   (2)| 00:00:01 |
|  25 |         SORT GROUP BY                |               |  9870 |   751K|   872K|  2228   (2)| 00:00:01 |
|* 26 |          FILTER                      |               |       |       |       |            |          |
|* 27 |           HASH JOIN                  |               |  9870 |   751K|       |  2046   (2)| 00:00:01 |
|* 28 |            TABLE ACCESS FULL         | SENTENCE      |  9870 |   587K|       |  1399   (3)| 00:00:01 |
|  29 |            TABLE ACCESS FULL         | PRISONER      |   299K|  4980K|       |   645   (1)| 00:00:01 |
|* 30 |       TABLE ACCESS FULL              | ACCOMMODATION | 10850 |   275K|       |  2093   (4)| 00:00:01 |
|* 31 |      TABLE ACCESS BY INDEX ROWID     | CELL          |     1 |    11 |       |     1   (0)| 00:00:01 |
|* 32 |       INDEX UNIQUE SCAN              | SYS_C008883   |     1 |       |       |     0   (0)| 00:00:01 |
|* 33 |     TABLE ACCESS BY INDEX ROWID      | PRISON_BLOCK  |     1 |     7 |       |     1   (0)| 00:00:01 |
|* 34 |      INDEX UNIQUE SCAN               | SYS_C008855   |     1 |       |       |     0   (0)| 00:00:01 |
|* 35 |    INDEX UNIQUE SCAN                 | SYS_C008868   |     1 |       |       |     0   (0)| 00:00:01 |
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
   ```],
   [```
Plan hash value: 3851442093
 
----------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                | Name                          | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                         |                               |     1 |  2200 |       |  6043   (2)| 00:00:01 |
|   1 |  NESTED LOOPS                            |                               |     1 |  2200 |       |  6043   (2)| 00:00:01 |
|   2 |   NESTED LOOPS                           |                               |     1 |  2193 |       |  6042   (2)| 00:00:01 |
|   3 |    NESTED LOOPS                          |                               |     1 |  2182 |       |  6041   (2)| 00:00:01 |
|   4 |     NESTED LOOPS                         |                               |     1 |  2159 |       |  6040   (2)| 00:00:01 |
|   5 |      NESTED LOOPS                        |                               |     1 |  2133 |       |  6037   (2)| 00:00:01 |
|*  6 |       HASH JOIN                          |                               |    35 | 71785 |       |  5943   (2)| 00:00:01 |
|*  7 |        HASH JOIN                         |                               |  1063 | 38268 |       |  3714   (3)| 00:00:01 |
|   8 |         VIEW                             |                               |  1063 | 13819 |       |  3067   (3)| 00:00:01 |
|*  9 |          FILTER                          |                               |       |       |       |            |          |
|  10 |           HASH GROUP BY                  |                               |  1063 | 28701 |       |  3067   (3)| 00:00:01 |
|* 11 |            FILTER                        |                               |       |       |       |            |          |
|* 12 |             HASH JOIN                    |                               |   659K|    16M|  7856K|  3028   (2)| 00:00:01 |
|  13 |              INDEX FAST FULL SCAN        | SENTENCE_FK_PRISONER_IDX      |   473K|  2310K|       |   291   (2)| 00:00:01 |
|* 14 |              HASH JOIN                   |                               |   422K|  9069K|  7016K|  1665   (2)| 00:00:01 |
|  15 |               INDEX FAST FULL SCAN       | REPRIMAND_FK_PRISONER_IDX     |   422K|  2061K|       |   260   (2)| 00:00:01 |
|  16 |               TABLE ACCESS FULL          | PRISONER                      |   299K|  4980K|       |   645   (1)| 00:00:01 |
|  17 |         TABLE ACCESS FULL                | PRISONER                      |   299K|  6737K|       |   645   (1)| 00:00:01 |
|* 18 |        VIEW                              |                               |  9870 |    18M|       |  2228   (2)| 00:00:01 |
|  19 |         SORT GROUP BY                    |                               |  9870 |   751K|   872K|  2228   (2)| 00:00:01 |
|* 20 |          FILTER                          |                               |       |       |       |            |          |
|* 21 |           HASH JOIN                      |                               |  9870 |   751K|       |  2046   (2)| 00:00:01 |
|* 22 |            TABLE ACCESS FULL             | SENTENCE                      |  9870 |   587K|       |  1399   (3)| 00:00:01 |
|  23 |            TABLE ACCESS FULL             | PRISONER                      |   299K|  4980K|       |   645   (1)| 00:00:01 |
|* 24 |       TABLE ACCESS BY INDEX ROWID BATCHED| REPRIMAND                     |     1 |    82 |       |     3   (0)| 00:00:01 |
|* 25 |        INDEX RANGE SCAN                  | REPRIMAND_FK_PRISONER_IDX     |     2 |       |       |     2   (0)| 00:00:01 |
|* 26 |      TABLE ACCESS BY INDEX ROWID BATCHED | ACCOMMODATION                 |     1 |    26 |       |     3   (0)| 00:00:01 |
|* 27 |       INDEX RANGE SCAN                   | ACCOMMODATION_FK_PRISONER_IDX |     5 |       |       |     2   (0)| 00:00:01 |
|  28 |     TABLE ACCESS BY INDEX ROWID          | GUARD                         |     1 |    23 |       |     1   (0)| 00:00:01 |
|* 29 |      INDEX UNIQUE SCAN                   | SYS_C008868                   |     1 |       |       |     0   (0)| 00:00:01 |
|* 30 |    TABLE ACCESS BY INDEX ROWID           | CELL                          |     1 |    11 |       |     1   (0)| 00:00:01 |
|* 31 |     INDEX UNIQUE SCAN                    | SYS_C008883                   |     1 |       |       |     0   (0)| 00:00:01 |
|* 32 |   TABLE ACCESS BY INDEX ROWID            | PRISON_BLOCK                  |     1 |     7 |       |     1   (0)| 00:00:01 |
|* 33 |    INDEX UNIQUE SCAN                     | SYS_C008855                   |     1 |       |       |     0   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   6 - access("P"."ID"="PS"."ID")
   7 - access("P"."ID"="PC"."ID")
   9 - filter((:SENTENCE_COUNT IS NULL OR COUNT(*)=TO_NUMBER(:SENTENCE_COUNT)) AND (:REPRIMAND_COUNT IS NULL OR 
              COUNT(*)=TO_NUMBER(:REPRIMAND_COUNT)))
  11 - filter(:END_DATE>=:START_DATE)
  12 - access("P"."ID"="S"."FK_PRISONER")
  14 - access("P"."ID"="R"."FK_PRISONER")
  18 - filter(:CRIME IS NULL OR INSTR("PS"."CRIME",:CRIME)>0)
  20 - filter(:END_DATE>=:START_DATE)
  21 - access("P"."ID"="S"."FK_PRISONER")
  22 - filter(TO_CHAR(INTERNAL_FUNCTION("S"."START_DATE"),'YYYY-MM-DD')<=:START_DATE AND ("S"."REAL_END_DATE" IS NULL OR 
              TO_CHAR(INTERNAL_FUNCTION("S"."REAL_END_DATE"),'YYYY-MM-DD')>=:END_DATE))
  24 - filter((:EVENT_TYPE IS NULL OR INSTR("R"."REASON",:EVENT_TYPE)>0) AND 
              TO_CHAR(INTERNAL_FUNCTION("R"."ISSUE_DATE"),'YYYY-MM-DD')>=:START_DATE AND 
              TO_CHAR(INTERNAL_FUNCTION("R"."ISSUE_DATE"),'YYYY-MM-DD')<=:END_DATE)
  25 - access("R"."FK_PRISONER"="P"."ID")
  26 - filter(TO_CHAR(INTERNAL_FUNCTION("A"."START_DATE"),'YYYY-MM-DD')<=:START_DATE AND ("A"."END_DATE" IS NULL OR 
              TO_CHAR(INTERNAL_FUNCTION("A"."END_DATE"),'YYYY-MM-DD')>=:END_DATE))
  27 - access("P"."ID"="A"."FK_PRISONER")
  29 - access("R"."FK_GUARD"="G"."ID")
  30 - filter("C"."IS_SOLITARY"=TO_NUMBER(:IS_IN_SOLITARY) OR :IS_IN_SOLITARY IS NULL)
  31 - access("C"."ID"="A"."FK_CELL")
  32 - filter(:BLOCK_NUMBER IS NULL OR "PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  33 - access("PB"."ID"="C"."FK_BLOCK")
 
Note
-----
   - this is an adaptive plan
   ```]
)

*`change3`:*
#plan(
   [```
Plan hash value: 2939466326
 
-----------------------------------------------------------------------------------------------------
| Id  | Operation                           | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                    |               |     1 |    52 |  3954   (3)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL            | ACCOMMODATION |       |       |            |          |
|   2 |   SEQUENCE                          | ISEQ$$_76227  |       |       |            |          |
|*  3 |    HASH JOIN                        |               |     1 |    52 |  3954   (3)| 00:00:01 |
|   4 |     VIEW                            |               |     1 |    26 |  2449   (4)| 00:00:01 |
|   5 |      COUNT                          |               |       |       |            |          |
|*  6 |       HASH JOIN ANTI                |               |     1 |    31 |  2449   (4)| 00:00:01 |
|   7 |        NESTED LOOPS                 |               |    55 |   990 |   354   (2)| 00:00:01 |
|   8 |         TABLE ACCESS BY INDEX ROWID | PRISON_BLOCK  |     1 |     7 |     1   (0)| 00:00:01 |
|*  9 |          INDEX UNIQUE SCAN          | SYS_C008856   |     1 |       |     0   (0)| 00:00:01 |
|* 10 |         TABLE ACCESS FULL           | CELL          |    55 |   605 |   353   (2)| 00:00:01 |
|  11 |        VIEW                         | VW_NSO_1      | 10659 |   135K|  2095   (5)| 00:00:01 |
|  12 |         SORT GROUP BY               |               | 10659 |   218K|  2095   (5)| 00:00:01 |
|* 13 |          TABLE ACCESS FULL          | ACCOMMODATION | 10850 |   222K|  2093   (4)| 00:00:01 |
|  14 |     VIEW                            |               |   103 |  2678 |  1505   (2)| 00:00:01 |
|  15 |      SORT GROUP BY                  |               |   103 |  9373 |  1505   (2)| 00:00:01 |
|  16 |       COUNT                         |               |       |       |            |          |
|* 17 |        FILTER                       |               |       |       |            |          |
|  18 |         NESTED LOOPS                |               |   103 |  9373 |  1504   (1)| 00:00:01 |
|  19 |          NESTED LOOPS               |               |   103 |  9373 |  1504   (1)| 00:00:01 |
|* 20 |           TABLE ACCESS FULL         | REPRIMAND     |   103 |  7622 |  1401   (2)| 00:00:01 |
|* 21 |           INDEX UNIQUE SCAN         | SYS_C008848   |     1 |       |     0   (0)| 00:00:01 |
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
Plan hash value: 1909057338
 
----------------------------------------------------------------------------------------------------------------
| Id  | Operation                                  | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                           |                   |     1 |    52 |  3621   (3)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL                   | ACCOMMODATION     |       |       |            |          |
|   2 |   SEQUENCE                                 | ISEQ$$_76227      |       |       |            |          |
|*  3 |    HASH JOIN                               |                   |     1 |    52 |  3621   (3)| 00:00:01 |
|   4 |     VIEW                                   |                   |     1 |    26 |  2116   (5)| 00:00:01 |
|   5 |      COUNT                                 |                   |       |       |            |          |
|*  6 |       HASH JOIN ANTI                       |                   |     1 |    31 |  2116   (5)| 00:00:01 |
|   7 |        NESTED LOOPS                        |                   |    55 |   990 |    21   (0)| 00:00:01 |
|   8 |         TABLE ACCESS BY INDEX ROWID        | PRISON_BLOCK      |     1 |     7 |     1   (0)| 00:00:01 |
|*  9 |          INDEX UNIQUE SCAN                 | SYS_C008856       |     1 |       |     0   (0)| 00:00:01 |
|* 10 |         TABLE ACCESS BY INDEX ROWID BATCHED| CELL              |    55 |   605 |    20   (0)| 00:00:01 |
|* 11 |          INDEX RANGE SCAN                  | CELL_FK_BLOCK_IDX |  2797 |       |     5   (0)| 00:00:01 |
|  12 |        VIEW                                | VW_NSO_1          | 10659 |   135K|  2095   (5)| 00:00:01 |
|  13 |         SORT GROUP BY                      |                   | 10659 |   218K|  2095   (5)| 00:00:01 |
|* 14 |          TABLE ACCESS FULL                 | ACCOMMODATION     | 10850 |   222K|  2093   (4)| 00:00:01 |
|  15 |     VIEW                                   |                   |   103 |  2678 |  1505   (2)| 00:00:01 |
|  16 |      SORT GROUP BY                         |                   |   103 |  9373 |  1505   (2)| 00:00:01 |
|  17 |       COUNT                                |                   |       |       |            |          |
|* 18 |        FILTER                              |                   |       |       |            |          |
|  19 |         NESTED LOOPS                       |                   |   103 |  9373 |  1504   (1)| 00:00:01 |
|  20 |          NESTED LOOPS                      |                   |   103 |  9373 |  1504   (1)| 00:00:01 |
|* 21 |           TABLE ACCESS FULL                | REPRIMAND         |   103 |  7622 |  1401   (2)| 00:00:01 |
|* 22 |           INDEX UNIQUE SCAN                | SYS_C008848       |     1 |       |     0   (0)| 00:00:01 |
|  23 |          TABLE ACCESS BY INDEX ROWID       | PRISONER          |     1 |    17 |     1   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access("P"."N"="C"."N")
   6 - access("C"."ID"="FK_CELL")
   9 - access("PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  10 - filter("C"."IS_SOLITARY"=1)
  11 - access("PB"."ID"="C"."FK_BLOCK")
  14 - filter(TO_CHAR(INTERNAL_FUNCTION("A"."START_DATE"),'YYYY-MM-DD HH24:MI:SS')<=:NOW AND 
              ("A"."END_DATE" IS NULL OR TO_CHAR(INTERNAL_FUNCTION("A"."END_DATE"),'YYYY-MM-DD HH24:MI:SS')>=:NOW))
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
Plan hash value: 87624460
 
-------------------------------------------------------------------------------------------------
| Id  | Operation                       | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                |               |   121 |  5324 |  2474   (5)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL        | REPRIMAND     |       |       |            |          |
|   2 |   SEQUENCE                      | ISEQ$$_76236  |       |       |            |          |
|*  3 |    HASH JOIN                    |               |   121 |  5324 |  2474   (5)| 00:00:01 |
|   4 |     NESTED LOOPS                |               |  2742 | 49356 |   354   (2)| 00:00:01 |
|   5 |      TABLE ACCESS BY INDEX ROWID| PRISON_BLOCK  |     1 |     7 |     1   (0)| 00:00:01 |
|*  6 |       INDEX UNIQUE SCAN         | SYS_C008856   |     1 |       |     0   (0)| 00:00:01 |
|*  7 |      TABLE ACCESS FULL          | CELL          |  2742 | 30162 |   353   (2)| 00:00:01 |
|*  8 |     TABLE ACCESS FULL           | ACCOMMODATION | 10850 |   275K|  2119   (6)| 00:00:01 |
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
Plan hash value: 2769465380
 
-------------------------------------------------------------------------------------------------------------
| Id  | Operation                               | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                        |                   |   121 |  5324 |  2141   (6)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL                | REPRIMAND         |       |       |            |          |
|   2 |   SEQUENCE                              | ISEQ$$_76236      |       |       |            |          |
|*  3 |    HASH JOIN                            |                   |   121 |  5324 |  2141   (6)| 00:00:01 |
|   4 |     NESTED LOOPS                        |                   |  2742 | 49356 |    21   (0)| 00:00:01 |
|   5 |      TABLE ACCESS BY INDEX ROWID        | PRISON_BLOCK      |     1 |     7 |     1   (0)| 00:00:01 |
|*  6 |       INDEX UNIQUE SCAN                 | SYS_C008856       |     1 |       |     0   (0)| 00:00:01 |
|*  7 |      TABLE ACCESS BY INDEX ROWID BATCHED| CELL              |  2742 | 30162 |    20   (0)| 00:00:01 |
|*  8 |       INDEX RANGE SCAN                  | CELL_FK_BLOCK_IDX |  2797 |       |     5   (0)| 00:00:01 |
|*  9 |     TABLE ACCESS FULL                   | ACCOMMODATION     | 10850 |   275K|  2119   (6)| 00:00:01 |
-------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access("A"."FK_CELL"="C"."ID")
   6 - access("PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
   7 - filter("C"."IS_SOLITARY"=0)
   8 - access("C"."FK_BLOCK"="PB"."ID")
   9 - filter(INTERNAL_FUNCTION("A"."START_DATE")<=TO_TIMESTAMP(:EVENT_TIME,'YYYY-MM-DD HH24:MI:SS') 
              AND ("A"."END_DATE" IS NULL OR INTERNAL_FUNCTION("A"."END_DATE")>=TO_TIMESTAMP(:EVENT_TIME,'YYYY-MM-D
              D HH24:MI:SS')))
   ```]
)

=== Nałożenie wszystkich proponowanych indeksów jednocześnie

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

*`change3`:*
#plan(
   [```
Plan hash value: 2939466326
 
-----------------------------------------------------------------------------------------------------
| Id  | Operation                           | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                    |               |     1 |    52 |  3954   (3)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL            | ACCOMMODATION |       |       |            |          |
|   2 |   SEQUENCE                          | ISEQ$$_76227  |       |       |            |          |
|*  3 |    HASH JOIN                        |               |     1 |    52 |  3954   (3)| 00:00:01 |
|   4 |     VIEW                            |               |     1 |    26 |  2449   (4)| 00:00:01 |
|   5 |      COUNT                          |               |       |       |            |          |
|*  6 |       HASH JOIN ANTI                |               |     1 |    31 |  2449   (4)| 00:00:01 |
|   7 |        NESTED LOOPS                 |               |    55 |   990 |   354   (2)| 00:00:01 |
|   8 |         TABLE ACCESS BY INDEX ROWID | PRISON_BLOCK  |     1 |     7 |     1   (0)| 00:00:01 |
|*  9 |          INDEX UNIQUE SCAN          | SYS_C008856   |     1 |       |     0   (0)| 00:00:01 |
|* 10 |         TABLE ACCESS FULL           | CELL          |    55 |   605 |   353   (2)| 00:00:01 |
|  11 |        VIEW                         | VW_NSO_1      | 10659 |   135K|  2095   (5)| 00:00:01 |
|  12 |         SORT GROUP BY               |               | 10659 |   218K|  2095   (5)| 00:00:01 |
|* 13 |          TABLE ACCESS FULL          | ACCOMMODATION | 10850 |   222K|  2093   (4)| 00:00:01 |
|  14 |     VIEW                            |               |   103 |  2678 |  1505   (2)| 00:00:01 |
|  15 |      SORT GROUP BY                  |               |   103 |  9373 |  1505   (2)| 00:00:01 |
|  16 |       COUNT                         |               |       |       |            |          |
|* 17 |        FILTER                       |               |       |       |            |          |
|  18 |         NESTED LOOPS                |               |   103 |  9373 |  1504   (1)| 00:00:01 |
|  19 |          NESTED LOOPS               |               |   103 |  9373 |  1504   (1)| 00:00:01 |
|* 20 |           TABLE ACCESS FULL         | REPRIMAND     |   103 |  7622 |  1401   (2)| 00:00:01 |
|* 21 |           INDEX UNIQUE SCAN         | SYS_C008848   |     1 |       |     0   (0)| 00:00:01 |
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
Plan hash value: 212087080
 
-------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                  | Name                       | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                           |                            |     1 |    52 |  3637   (3)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL                   | ACCOMMODATION              |       |       |            |          |
|   2 |   SEQUENCE                                 | ISEQ$$_76227               |       |       |            |          |
|*  3 |    HASH JOIN                               |                            |     1 |    52 |  3637   (3)| 00:00:01 |
|   4 |     VIEW                                   |                            |     1 |    26 |  2132   (4)| 00:00:01 |
|   5 |      COUNT                                 |                            |       |       |            |          |
|*  6 |       HASH JOIN ANTI                       |                            |     1 |    31 |  2132   (4)| 00:00:01 |
|   7 |        NESTED LOOPS                        |                            |    55 |   990 |    37   (0)| 00:00:01 |
|   8 |         TABLE ACCESS BY INDEX ROWID        | PRISON_BLOCK               |     1 |     7 |     1   (0)| 00:00:01 |
|*  9 |          INDEX UNIQUE SCAN                 | SYS_C008856                |     1 |       |     0   (0)| 00:00:01 |
|* 10 |         TABLE ACCESS BY INDEX ROWID BATCHED| CELL                       |    55 |   605 |    36   (0)| 00:00:01 |
|* 11 |          INDEX RANGE SCAN                  | CELL_IS_SOLITARY_BTREE_IDX |  4979 |       |    10   (0)| 00:00:01 |
|  12 |        VIEW                                | VW_NSO_1                   | 10659 |   135K|  2095   (5)| 00:00:01 |
|  13 |         SORT GROUP BY                      |                            | 10659 |   218K|  2095   (5)| 00:00:01 |
|* 14 |          TABLE ACCESS FULL                 | ACCOMMODATION              | 10850 |   222K|  2093   (4)| 00:00:01 |
|  15 |     VIEW                                   |                            |   103 |  2678 |  1505   (2)| 00:00:01 |
|  16 |      SORT GROUP BY                         |                            |   103 |  9373 |  1505   (2)| 00:00:01 |
|  17 |       COUNT                                |                            |       |       |            |          |
|* 18 |        FILTER                              |                            |       |       |            |          |
|  19 |         NESTED LOOPS                       |                            |   103 |  9373 |  1504   (1)| 00:00:01 |
|  20 |          NESTED LOOPS                      |                            |   103 |  9373 |  1504   (1)| 00:00:01 |
|* 21 |           TABLE ACCESS FULL                | REPRIMAND                  |   103 |  7622 |  1401   (2)| 00:00:01 |
|* 22 |           INDEX UNIQUE SCAN                | SYS_C008848                |     1 |       |     0   (0)| 00:00:01 |
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

*`change3`:*
#plan(
   [```
Plan hash value: 2939466326
 
-----------------------------------------------------------------------------------------------------
| Id  | Operation                           | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                    |               |     1 |    52 |  3954   (3)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL            | ACCOMMODATION |       |       |            |          |
|   2 |   SEQUENCE                          | ISEQ$$_76227  |       |       |            |          |
|*  3 |    HASH JOIN                        |               |     1 |    52 |  3954   (3)| 00:00:01 |
|   4 |     VIEW                            |               |     1 |    26 |  2449   (4)| 00:00:01 |
|   5 |      COUNT                          |               |       |       |            |          |
|*  6 |       HASH JOIN ANTI                |               |     1 |    31 |  2449   (4)| 00:00:01 |
|   7 |        NESTED LOOPS                 |               |    55 |   990 |   354   (2)| 00:00:01 |
|   8 |         TABLE ACCESS BY INDEX ROWID | PRISON_BLOCK  |     1 |     7 |     1   (0)| 00:00:01 |
|*  9 |          INDEX UNIQUE SCAN          | SYS_C008856   |     1 |       |     0   (0)| 00:00:01 |
|* 10 |         TABLE ACCESS FULL           | CELL          |    55 |   605 |   353   (2)| 00:00:01 |
|  11 |        VIEW                         | VW_NSO_1      | 10659 |   135K|  2095   (5)| 00:00:01 |
|  12 |         SORT GROUP BY               |               | 10659 |   218K|  2095   (5)| 00:00:01 |
|* 13 |          TABLE ACCESS FULL          | ACCOMMODATION | 10850 |   222K|  2093   (4)| 00:00:01 |
|  14 |     VIEW                            |               |   103 |  2678 |  1505   (2)| 00:00:01 |
|  15 |      SORT GROUP BY                  |               |   103 |  9373 |  1505   (2)| 00:00:01 |
|  16 |       COUNT                         |               |       |       |            |          |
|* 17 |        FILTER                       |               |       |       |            |          |
|  18 |         NESTED LOOPS                |               |   103 |  9373 |  1504   (1)| 00:00:01 |
|  19 |          NESTED LOOPS               |               |   103 |  9373 |  1504   (1)| 00:00:01 |
|* 20 |           TABLE ACCESS FULL         | REPRIMAND     |   103 |  7622 |  1401   (2)| 00:00:01 |
|* 21 |           INDEX UNIQUE SCAN         | SYS_C008848   |     1 |       |     0   (0)| 00:00:01 |
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
Plan hash value: 3959622293
 
--------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                  | Name                        | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                           |                             |     1 |    52 |  3888   (3)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL                   | ACCOMMODATION               |       |       |            |          |
|   2 |   SEQUENCE                                 | ISEQ$$_76227                |       |       |            |          |
|*  3 |    HASH JOIN                               |                             |     1 |    52 |  3888   (3)| 00:00:01 |
|   4 |     VIEW                                   |                             |     1 |    26 |  2383   (4)| 00:00:01 |
|   5 |      COUNT                                 |                             |       |       |            |          |
|*  6 |       HASH JOIN ANTI                       |                             |     1 |    31 |  2383   (4)| 00:00:01 |
|*  7 |        HASH JOIN                           |                             |    55 |   990 |   288   (0)| 00:00:01 |
|   8 |         TABLE ACCESS BY INDEX ROWID        | PRISON_BLOCK                |     1 |     7 |     1   (0)| 00:00:01 |
|*  9 |          INDEX UNIQUE SCAN                 | SYS_C008856                 |     1 |       |     0   (0)| 00:00:01 |
|  10 |         TABLE ACCESS BY INDEX ROWID BATCHED| CELL                        |  4979 | 54769 |   287   (0)| 00:00:01 |
|  11 |          BITMAP CONVERSION TO ROWIDS       |                             |       |       |            |          |
|* 12 |           BITMAP INDEX SINGLE VALUE        | CELL_IS_SOLITARY_BITMAP_IDX |       |       |            |          |
|  13 |        VIEW                                | VW_NSO_1                    | 10659 |   135K|  2095   (5)| 00:00:01 |
|  14 |         SORT GROUP BY                      |                             | 10659 |   218K|  2095   (5)| 00:00:01 |
|* 15 |          TABLE ACCESS FULL                 | ACCOMMODATION               | 10850 |   222K|  2093   (4)| 00:00:01 |
|  16 |     VIEW                                   |                             |   103 |  2678 |  1505   (2)| 00:00:01 |
|  17 |      SORT GROUP BY                         |                             |   103 |  9373 |  1505   (2)| 00:00:01 |
|  18 |       COUNT                                |                             |       |       |            |          |
|* 19 |        FILTER                              |                             |       |       |            |          |
|  20 |         NESTED LOOPS                       |                             |   103 |  9373 |  1504   (1)| 00:00:01 |
|  21 |          NESTED LOOPS                      |                             |   103 |  9373 |  1504   (1)| 00:00:01 |
|* 22 |           TABLE ACCESS FULL                | REPRIMAND                   |   103 |  7622 |  1401   (2)| 00:00:01 |
|* 23 |           INDEX UNIQUE SCAN                | SYS_C008848                 |     1 |       |     0   (0)| 00:00:01 |
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
Plan hash value: 2939466326
 
-----------------------------------------------------------------------------------------------------
| Id  | Operation                           | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                    |               |     1 |    52 |  3954   (3)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL            | ACCOMMODATION |       |       |            |          |
|   2 |   SEQUENCE                          | ISEQ$$_76227  |       |       |            |          |
|*  3 |    HASH JOIN                        |               |     1 |    52 |  3954   (3)| 00:00:01 |
|   4 |     VIEW                            |               |     1 |    26 |  2449   (4)| 00:00:01 |
|   5 |      COUNT                          |               |       |       |            |          |
|*  6 |       HASH JOIN ANTI                |               |     1 |    31 |  2449   (4)| 00:00:01 |
|   7 |        NESTED LOOPS                 |               |    55 |   990 |   354   (2)| 00:00:01 |
|   8 |         TABLE ACCESS BY INDEX ROWID | PRISON_BLOCK  |     1 |     7 |     1   (0)| 00:00:01 |
|*  9 |          INDEX UNIQUE SCAN          | SYS_C008856   |     1 |       |     0   (0)| 00:00:01 |
|* 10 |         TABLE ACCESS FULL           | CELL          |    55 |   605 |   353   (2)| 00:00:01 |
|  11 |        VIEW                         | VW_NSO_1      | 10659 |   135K|  2095   (5)| 00:00:01 |
|  12 |         SORT GROUP BY               |               | 10659 |   218K|  2095   (5)| 00:00:01 |
|* 13 |          TABLE ACCESS FULL          | ACCOMMODATION | 10850 |   222K|  2093   (4)| 00:00:01 |
|  14 |     VIEW                            |               |   103 |  2678 |  1505   (2)| 00:00:01 |
|  15 |      SORT GROUP BY                  |               |   103 |  9373 |  1505   (2)| 00:00:01 |
|  16 |       COUNT                         |               |       |       |            |          |
|* 17 |        FILTER                       |               |       |       |            |          |
|  18 |         NESTED LOOPS                |               |   103 |  9373 |  1504   (1)| 00:00:01 |
|  19 |          NESTED LOOPS               |               |   103 |  9373 |  1504   (1)| 00:00:01 |
|* 20 |           TABLE ACCESS FULL         | REPRIMAND     |   103 |  7622 |  1401   (2)| 00:00:01 |
|* 21 |           INDEX UNIQUE SCAN         | SYS_C008848   |     1 |       |     0   (0)| 00:00:01 |
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
Plan hash value: 2756498725
 
-----------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                  | Name                           | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                           |                                |     1 |    52 |  3609   (3)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL                   | ACCOMMODATION                  |       |       |            |          |
|   2 |   SEQUENCE                                 | ISEQ$$_76227                   |       |       |            |          |
|*  3 |    HASH JOIN                               |                                |     1 |    52 |  3609   (3)| 00:00:01 |
|   4 |     VIEW                                   |                                |     1 |    26 |  2104   (5)| 00:00:01 |
|   5 |      COUNT                                 |                                |       |       |            |          |
|*  6 |       HASH JOIN ANTI                       |                                |     1 |    31 |  2104   (5)| 00:00:01 |
|   7 |        NESTED LOOPS                        |                                |    55 |   990 |     9   (0)| 00:00:01 |
|   8 |         TABLE ACCESS BY INDEX ROWID        | PRISON_BLOCK                   |     1 |     7 |     1   (0)| 00:00:01 |
|*  9 |          INDEX UNIQUE SCAN                 | SYS_C008856                    |     1 |       |     0   (0)| 00:00:01 |
|  10 |         TABLE ACCESS BY INDEX ROWID BATCHED| CELL                           |    55 |   605 |     8   (0)| 00:00:01 |
|* 11 |          INDEX RANGE SCAN                  | CELL_IS_SOLITARY_COMPOSITE_IDX |    55 |       |     7   (0)| 00:00:01 |
|  12 |        VIEW                                | VW_NSO_1                       | 10659 |   135K|  2095   (5)| 00:00:01 |
|  13 |         SORT GROUP BY                      |                                | 10659 |   218K|  2095   (5)| 00:00:01 |
|* 14 |          TABLE ACCESS FULL                 | ACCOMMODATION                  | 10850 |   222K|  2093   (4)| 00:00:01 |
|  15 |     VIEW                                   |                                |   103 |  2678 |  1505   (2)| 00:00:01 |
|  16 |      SORT GROUP BY                         |                                |   103 |  9373 |  1505   (2)| 00:00:01 |
|  17 |       COUNT                                |                                |       |       |            |          |
|* 18 |        FILTER                              |                                |       |       |            |          |
|  19 |         NESTED LOOPS                       |                                |   103 |  9373 |  1504   (1)| 00:00:01 |
|  20 |          NESTED LOOPS                      |                                |   103 |  9373 |  1504   (1)| 00:00:01 |
|* 21 |           TABLE ACCESS FULL                | REPRIMAND                      |   103 |  7622 |  1401   (2)| 00:00:01 |
|* 22 |           INDEX UNIQUE SCAN                | SYS_C008848                    |     1 |       |     0   (0)| 00:00:01 |
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
Plan hash value: 87624460
 
-------------------------------------------------------------------------------------------------
| Id  | Operation                       | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                |               |   121 |  5324 |  2474   (5)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL        | REPRIMAND     |       |       |            |          |
|   2 |   SEQUENCE                      | ISEQ$$_76236  |       |       |            |          |
|*  3 |    HASH JOIN                    |               |   121 |  5324 |  2474   (5)| 00:00:01 |
|   4 |     NESTED LOOPS                |               |  2742 | 49356 |   354   (2)| 00:00:01 |
|   5 |      TABLE ACCESS BY INDEX ROWID| PRISON_BLOCK  |     1 |     7 |     1   (0)| 00:00:01 |
|*  6 |       INDEX UNIQUE SCAN         | SYS_C008856   |     1 |       |     0   (0)| 00:00:01 |
|*  7 |      TABLE ACCESS FULL          | CELL          |  2742 | 30162 |   353   (2)| 00:00:01 |
|*  8 |     TABLE ACCESS FULL           | ACCOMMODATION | 10850 |   275K|  2119   (6)| 00:00:01 |
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
Plan hash value: 2246849140
 
--------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                               | Name                           | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                        |                                |   121 |  5324 |  2142   (6)| 00:00:01 |
|   1 |  LOAD TABLE CONVENTIONAL                | REPRIMAND                      |       |       |            |          |
|   2 |   SEQUENCE                              | ISEQ$$_76236                   |       |       |            |          |
|*  3 |    HASH JOIN                            |                                |   121 |  5324 |  2142   (6)| 00:00:01 |
|   4 |     NESTED LOOPS                        |                                |  2742 | 49356 |    22   (0)| 00:00:01 |
|   5 |      TABLE ACCESS BY INDEX ROWID        | PRISON_BLOCK                   |     1 |     7 |     1   (0)| 00:00:01 |
|*  6 |       INDEX UNIQUE SCAN                 | SYS_C008856                    |     1 |       |     0   (0)| 00:00:01 |
|   7 |      TABLE ACCESS BY INDEX ROWID BATCHED| CELL                           |  2742 | 30162 |    21   (0)| 00:00:01 |
|*  8 |       INDEX RANGE SCAN                  | CELL_IS_SOLITARY_COMPOSITE_IDX |  2742 |       |     7   (0)| 00:00:01 |
|*  9 |     TABLE ACCESS FULL                   | ACCOMMODATION                  | 10850 |   275K|  2119   (6)| 00:00:01 |
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

==== Wnioski

TODO

=== Eksperyment 2 -- dodawanie indeksów w `MATERIALIZED VIEW`

TODO

=== Eksperyment 3 -- porównanie efektywności indeksowania i partycjonowania dla kolumny `issue_date` w tabeli `reprimand`

TODO
