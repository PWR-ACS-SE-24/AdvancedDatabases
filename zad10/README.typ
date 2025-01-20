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
    #set text(font: "Liberation Mono", size: if children.pos().len() == 1 { 8pt } else { 4pt })
    #it
  ]
  #grid(
    columns: 2,
    align: (left, right),
    column-gutter: 24pt,
    ..children.pos().map(it => align(left, it))
  )
]
#let whoopsie(body) = block(
     fill: rgb("#eee"),
     inset: 8pt,
     stroke: (left: 4pt + red),
     body
)
#let blockquote(body) = block(
     inset: 8pt,
     stroke: (left: 4pt + blue),
     body
)

#align(center)[
  #text(size: 20pt, weight: "bold", )[Zaawansowane systemy baz danych (ZSBD)]

  Zespół B5 (baza danych dla więzienia): \
  *Tomasz Chojnacki (260365), Kamila Iwańska (253027), Jakub Zehner (260285)*
]

= Zadanie 10 - Składowanie kolumnowe (część II)

Włączenie składowania kolumnowego w pamięci w systemie Oracle 21c Express Edition zaczęliśmy od utworzenia kopii zapasowej wolumenu Docker przechowującego dane bazy, aby uniknąć utraty danych w przypadku niepowodzenia eksperymentu.

Następnie, logując się za pomocą SQL\*Plus kontem `sys`, przydzieliliśmy odpowiednie wartości parametrów przechowywanych w SPFILE, aby umożliwić składowanie kolumnowe w pamięci, a następnie uruchomiliśmy ponownie bazę danych:

```sql
alter system set sga_target = 1536M scope = both;
alter system set inmemory_size = 800M scope = both;
```

Końcowe wartości kluczowych parametrów (pokazane komendą `show parameter`) to:

#table(
  columns: 3,
  [*`NAME`*], [*`TYPE`*], [*`VALUE`*],
  [`pga_aggregate_target`], [`big integer`], [`512M`],
  [`pga_aggregate_limit`], [`big integer`], [`2G`],
  [`sga_target`], [`big integer`], [`1536M`],
  [`sga_max_size`], [`big integer`], [`1536M`],
  [`memory_target`], [`big integer`], [`0`],
  [`memory_max_target`], [`big integer`], [`0`],
  [`inmemory_size`], [`big integer`], [`1G`]
)

Dla wszystkich propozycji i eksperymentów, aby uzyskać średnią, workload był wykonany każdorazowo *10 razy*.

#pagebreak()

== Propozycja 1

Propozycja 1 polegała na zastosowaniu składowania kolumnowego na całej tabeli `prisoner`, celem zoptymalizowania kwerendy `query4`.

```sql
alter table prisoner inmemory priority critical;
```

Wykorzystana dla tabeli `prisoner` pamięć:
- 17.83 MB - na dysku
- *13.89 MB* - składowanie kolumnowe (domyślna kompresja)

#align(center, include("./test-app/out/onlyp1/table.typ"))

*`query2`:*
#plan(
  [```
Plan hash value: 3600760484
 
-------------------------------------------------------------------------------------------------------------
| Id  | Operation                           | Name          | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |               |     1 |    78 |       |  9835   (3)| 00:00:01 |
|   1 |  HASH GROUP BY                      |               |     1 |    78 |       |  9835   (3)| 00:00:01 |
|   2 |   NESTED LOOPS                      |               |     1 |    78 |       |  9834   (3)| 00:00:01 |
|   3 |    NESTED LOOPS                     |               |     1 |    78 |       |  9834   (3)| 00:00:01 |
|   4 |     NESTED LOOPS                    |               |     1 |    71 |       |  9833   (3)| 00:00:01 |
|*  5 |      HASH JOIN                      |               |     1 |    60 |       |  9832   (3)| 00:00:01 |
|*  6 |       HASH JOIN                     |               |     1 |    34 |       |  7743   (2)| 00:00:01 |
|   7 |        JOIN FILTER CREATE           | :BF0000       |     1 |    29 |       |  2046   (2)| 00:00:01 |
|   8 |         NESTED LOOPS                |               |     1 |    29 |       |  2046   (2)| 00:00:01 |
|   9 |          NESTED LOOPS               |               |     1 |    29 |       |  2046   (2)| 00:00:01 |
|  10 |           VIEW                      |               |     1 |     5 |       |  2045   (2)| 00:00:01 |
|* 11 |            FILTER                   |               |       |       |       |            |          |
|  12 |             SORT GROUP BY           |               |     1 |    89 |       |  2045   (2)| 00:00:01 |
|* 13 |              HASH JOIN              |               |  9590 |   833K|       |  2044   (2)| 00:00:01 |
```#highlight[```
|* 14 |               TABLE ACCESS FULL     | SENTENCE      |  9590 |   674K|       |  1397   (2)| 00:00:01 |
|  15 |               TABLE ACCESS FULL     | PRISONER      |   299K|  4980K|       |   645   (1)| 00:00:01 |
```]```
|* 16 |           INDEX UNIQUE SCAN         | SYS_C008848   |     1 |       |       |     0   (0)| 00:00:01 |
|* 17 |          TABLE ACCESS BY INDEX ROWID| PRISONER      |     1 |    24 |       |     1   (0)| 00:00:01 |
|  18 |        VIEW                         |               |    28 |   140 |       |  5697   (2)| 00:00:01 |
|* 19 |         FILTER                      |               |       |       |       |            |          |
|  20 |          JOIN FILTER USE            | :BF0000       |    28 |  1036 |       |  5697   (2)| 00:00:01 |
|  21 |           HASH GROUP BY             |               |    28 |  1036 |       |  5697   (2)| 00:00:01 |
|* 22 |            HASH JOIN RIGHT OUTER    |               |   806K|    28M|  9072K|  5649   (1)| 00:00:01 |
|  23 |             TABLE ACCESS FULL       | REPRIMAND     |   422K|  4122K|       |  1395   (1)| 00:00:01 |
|* 24 |             HASH JOIN OUTER         |               |   468K|    12M|  8496K|  2937   (1)| 00:00:01 |
```#highlight[```
|  25 |              TABLE ACCESS FULL      | PRISONER      |   299K|  4980K|       |   645   (1)| 00:00:01 |
```]```
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
Plan hash value: 2103705317
 
------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                | Name          | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                         |               |     1 |    78 |       |  8604   (3)| 00:00:01 |
|   1 |  HASH GROUP BY                           |               |     1 |    78 |       |  8604   (3)| 00:00:01 |
|   2 |   NESTED LOOPS                           |               |     1 |    78 |       |  8603   (3)| 00:00:01 |
|   3 |    NESTED LOOPS                          |               |     1 |    78 |       |  8603   (3)| 00:00:01 |
|   4 |     NESTED LOOPS                         |               |     1 |    71 |       |  8602   (3)| 00:00:01 |
|*  5 |      HASH JOIN                           |               |     1 |    60 |       |  8601   (3)| 00:00:01 |
|*  6 |       HASH JOIN                          |               |     1 |    34 |       |  6512   (2)| 00:00:01 |
|   7 |        JOIN FILTER CREATE                | :BF0000       |     1 |    29 |       |  1431   (3)| 00:00:01 |
|   8 |         NESTED LOOPS                     |               |     1 |    29 |       |  1431   (3)| 00:00:01 |
|   9 |          NESTED LOOPS                    |               |     1 |    29 |       |  1431   (3)| 00:00:01 |
|  10 |           VIEW                           |               |     1 |     5 |       |  1430   (3)| 00:00:01 |
|* 11 |            FILTER                        |               |       |       |       |            |          |
|  12 |             SORT GROUP BY                |               |     1 |    89 |       |  1430   (3)| 00:00:01 |
|* 13 |              HASH JOIN                   |               |  9590 |   833K|       |  1428   (3)| 00:00:01 |
```#highlight[```
|  14 |               JOIN FILTER CREATE         | :BF0001       |  9590 |   674K|       |  1397   (2)| 00:00:01 |
|* 15 |                TABLE ACCESS FULL         | SENTENCE      |  9590 |   674K|       |  1397   (2)| 00:00:01 |
|  16 |               JOIN FILTER USE            | :BF0001       |   299K|  4980K|       |    29  (18)| 00:00:01 |
|* 17 |                TABLE ACCESS INMEMORY FULL| PRISONER      |   299K|  4980K|       |    29  (18)| 00:00:01 |
```]```
|* 18 |           INDEX UNIQUE SCAN              | SYS_C008848   |     1 |       |       |     0   (0)| 00:00:01 |
|* 19 |          TABLE ACCESS BY INDEX ROWID     | PRISONER      |     1 |    24 |       |     1   (0)| 00:00:01 |
|  20 |        VIEW                              |               |    28 |   140 |       |  5081   (2)| 00:00:01 |
|* 21 |         FILTER                           |               |       |       |       |            |          |
|  22 |          JOIN FILTER USE                 | :BF0000       |    28 |  1036 |       |  5081   (2)| 00:00:01 |
|  23 |           HASH GROUP BY                  |               |    28 |  1036 |       |  5081   (2)| 00:00:01 |
|* 24 |            HASH JOIN RIGHT OUTER         |               |   806K|    28M|  9072K|  5033   (1)| 00:00:01 |
|  25 |             TABLE ACCESS FULL            | REPRIMAND     |   422K|  4122K|       |  1395   (1)| 00:00:01 |
|* 26 |             HASH JOIN OUTER              |               |   468K|    12M|  8496K|  2322   (1)| 00:00:01 |
```#highlight[```
|  27 |              TABLE ACCESS INMEMORY FULL  | PRISONER      |   299K|  4980K|       |    29  (18)| 00:00:01 |
```]```
|  28 |              TABLE ACCESS FULL           | SENTENCE      |   473K|  4620K|       |  1379   (1)| 00:00:01 |
|* 29 |       TABLE ACCESS FULL                  | ACCOMMODATION | 10513 |   266K|       |  2088   (4)| 00:00:01 |
|* 30 |      TABLE ACCESS BY INDEX ROWID         | CELL          |     1 |    11 |       |     1   (0)| 00:00:01 |
|* 31 |       INDEX UNIQUE SCAN                  | SYS_C008883   |     1 |       |       |     0   (0)| 00:00:01 |
|* 32 |     INDEX UNIQUE SCAN                    | SYS_C008855   |     1 |       |       |     0   (0)| 00:00:01 |
|  33 |    TABLE ACCESS BY INDEX ROWID           | PRISON_BLOCK  |     1 |     7 |       |     1   (0)| 00:00:01 |
------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   5 - access("A"."FK_PRISONER"="P"."ID")
   6 - access("P"."ID"="PC"."ID")
  11 - filter((:CRIME IS NULL OR INSTR(LISTAGG("S"."CRIME",', ') WITHIN GROUP ( ORDER BY 
              "S"."ID"),:CRIME)>0) AND (:MIN_STAY_MONTHS IS NULL OR 
              MONTHS_BETWEEN(:NOW,MIN("S"."START_DATE"))>=TO_NUMBER(:MIN_STAY_MONTHS)) AND (:MAX_STAY_MONTHS IS NULL OR 
              MONTHS_BETWEEN(:NOW,MIN("S"."START_DATE"))<=TO_NUMBER(:MAX_STAY_MONTHS)) AND (:MIN_RELEASE_MONTHS IS NULL 
              OR MONTHS_BETWEEN(MAX("S"."PLANNED_END_DATE"),:NOW)>=TO_NUMBER(:MIN_RELEASE_MONTHS)) AND 
              (:MAX_RELEASE_MONTHS IS NULL OR MONTHS_BETWEEN(MAX("S"."PLANNED_END_DATE"),:NOW)<=TO_NUMBER(:MAX_RELEASE_M
              ONTHS)))
  13 - access("P"."ID"="S"."FK_PRISONER")
  15 - filter("S"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD') AND ("S"."REAL_END_DATE" IS NULL OR 
              "S"."REAL_END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD')))
  17 - inmemory(SYS_OP_BLOOM_FILTER(:BF0001,"P"."ID"))
       filter(SYS_OP_BLOOM_FILTER(:BF0001,"P"."ID"))
  18 - access("P"."ID"="PS"."ID")
  19 - filter((:MIN_HEIGHT_M IS NULL OR "P"."HEIGHT_M">=TO_NUMBER(:MIN_HEIGHT_M)) AND (:MAX_HEIGHT_M IS 
              NULL OR "P"."HEIGHT_M"<=TO_NUMBER(:MAX_HEIGHT_M)) AND (:MIN_WEIGHT_KG IS NULL OR 
              "P"."WEIGHT_KG">=TO_NUMBER(:MIN_WEIGHT_KG)) AND (:MAX_WEIGHT_KG IS NULL OR 
              "P"."WEIGHT_KG"<=TO_NUMBER(:MAX_WEIGHT_KG)) AND ("P"."SEX"=TO_NUMBER(:SEX) OR :SEX IS NULL) AND (:MIN_AGE 
              IS NULL OR MONTHS_BETWEEN(:NOW,INTERNAL_FUNCTION("P"."BIRTHDAY"))>=TO_NUMBER(:MIN_AGE)*12) AND (:MAX_AGE 
              IS NULL OR MONTHS_BETWEEN(:NOW,INTERNAL_FUNCTION("P"."BIRTHDAY"))<=TO_NUMBER(:MAX_AGE)*12))
  21 - filter((:MIN_SENTENCES IS NULL OR COUNT("S"."ID")>=TO_NUMBER(:MIN_SENTENCES)) AND (:MAX_SENTENCES 
              IS NULL OR COUNT("S"."ID")<=TO_NUMBER(:MAX_SENTENCES)) AND (:MIN_REPRIMANDS IS NULL OR 
              COUNT("R"."ID")>=TO_NUMBER(:MIN_REPRIMANDS)) AND (:MAX_REPRIMANDS IS NULL OR 
              COUNT("R"."ID")<=TO_NUMBER(:MAX_REPRIMANDS)))
  24 - access("P"."ID"="R"."FK_PRISONER"(+))
  26 - access("P"."ID"="S"."FK_PRISONER"(+))
  29 - filter("A"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD') AND ("A"."END_DATE" IS NULL OR 
              "A"."END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD')))
  30 - filter("C"."IS_SOLITARY"=TO_NUMBER(:IS_IN_SOLITARY) OR :IS_IN_SOLITARY IS NULL)
  31 - access("C"."ID"="A"."FK_CELL")
  32 - access("PB"."ID"="C"."FK_BLOCK")
 
Note
-----
   - this is an adaptive plan
  ```]
)

#v(2cm)

*`query3`:*
#plan(
  [```
Plan hash value: 220023471
 
--------------------------------------------------------------------------------------------------------------
| Id  | Operation                            | Name          | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                     |               |     1 |  2200 |       | 11119   (2)| 00:00:01 |
|   1 |  NESTED LOOPS                        |               |     1 |  2200 |       | 11119   (2)| 00:00:01 |
|   2 |   NESTED LOOPS                       |               |     1 |  2200 |       | 11119   (2)| 00:00:01 |
|   3 |    NESTED LOOPS                      |               |     1 |  2177 |       | 11118   (2)| 00:00:01 |
|   4 |     NESTED LOOPS                     |               |     1 |  2170 |       | 11117   (2)| 00:00:01 |
|*  5 |      HASH JOIN                       |               |     1 |  2159 |       | 11116   (2)| 00:00:01 |
|*  6 |       HASH JOIN                      |               |     1 |  2133 |       |  9023   (2)| 00:00:01 |
|*  7 |        HASH JOIN                     |               |     1 |   118 |       |  6795   (2)| 00:00:01 |
```#highlight[```
|   8 |         JOIN FILTER CREATE           | :BF0000       |   103 | 10815 |       |  1505   (1)| 00:00:01 |
|   9 |          NESTED LOOPS                |               |   103 | 10815 |       |  1505   (1)| 00:00:01 |
|  10 |           NESTED LOOPS               |               |   103 | 10815 |       |  1505   (1)| 00:00:01 |
|* 11 |            TABLE ACCESS FULL         | REPRIMAND     |   103 |  8446 |       |  1402   (2)| 00:00:01 |
|* 12 |            INDEX UNIQUE SCAN         | SYS_C008848   |     1 |       |       |     0   (0)| 00:00:01 |
|  13 |           TABLE ACCESS BY INDEX ROWID| PRISONER      |     1 |    23 |       |     1   (0)| 00:00:01 |
```]```
|  14 |         VIEW                         |               |  1063 | 13819 |       |  5289   (2)| 00:00:01 |
|* 15 |          FILTER                      |               |       |       |       |            |          |
|  16 |           JOIN FILTER USE            | :BF0000       |  1063 | 28701 |       |  5289   (2)| 00:00:01 |
|  17 |            HASH GROUP BY             |               |  1063 | 28701 |       |  5289   (2)| 00:00:01 |
|* 18 |             FILTER                   |               |       |       |       |            |          |
|* 19 |              HASH JOIN               |               |   659K|    16M|  7856K|  5250   (1)| 00:00:01 |
|  20 |               TABLE ACCESS FULL      | SENTENCE      |   473K|  2310K|       |  1379   (1)| 00:00:01 |
|* 21 |               HASH JOIN              |               |   422K|  9069K|  7016K|  2800   (1)| 00:00:01 |
|  22 |                TABLE ACCESS FULL     | REPRIMAND     |   422K|  2061K|       |  1395   (1)| 00:00:01 |
```#highlight[```
|  23 |                TABLE ACCESS FULL     | PRISONER      |   299K|  4980K|       |   645   (1)| 00:00:01 |
```]```
|* 24 |        VIEW                          |               |  9870 |    18M|       |  2228   (2)| 00:00:01 |
|  25 |         SORT GROUP BY                |               |  9870 |   751K|   872K|  2228   (2)| 00:00:01 |
|* 26 |          FILTER                      |               |       |       |       |            |          |
|* 27 |           HASH JOIN                  |               |  9870 |   751K|       |  2046   (2)| 00:00:01 |
```#highlight[```
|* 28 |            TABLE ACCESS FULL         | SENTENCE      |  9870 |   587K|       |  1399   (3)| 00:00:01 |
|  29 |            TABLE ACCESS FULL         | PRISONER      |   299K|  4980K|       |   645   (1)| 00:00:01 |
```]```
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
Plan hash value: 717877435
 
-----------------------------------------------------------------------------------------------------------------
| Id  | Operation                               | Name          | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                        |               |     1 |  2200 |       |  9818   (3)| 00:00:01 |
|   1 |  NESTED LOOPS                           |               |     1 |  2200 |       |  9818   (3)| 00:00:01 |
|   2 |   NESTED LOOPS                          |               |     1 |  2193 |       |  9817   (3)| 00:00:01 |
|   3 |    NESTED LOOPS                         |               |     1 |  2182 |       |  9816   (3)| 00:00:01 |
|*  4 |     HASH JOIN                           |               |     1 |  2159 |       |  9815   (3)| 00:00:01 |
|*  5 |      HASH JOIN                          |               |     1 |  2133 |       |  7721   (2)| 00:00:01 |
|*  6 |       HASH JOIN                         |               |     1 |   118 |       |  6109   (2)| 00:00:01 |
|   7 |        JOIN FILTER CREATE               | :BF0000       |   103 | 10815 |       |  1435   (2)| 00:00:01 |
```#highlight[```
|*  8 |         HASH JOIN                       |               |   103 | 10815 |       |  1435   (2)| 00:00:01 |
|   9 |          JOIN FILTER CREATE             | :BF0001       |   103 | 10815 |       |  1435   (2)| 00:00:01 |
|* 10 |           TABLE ACCESS FULL             | REPRIMAND     |   103 |  8446 |       |  1402   (2)| 00:00:01 |
|  11 |          JOIN FILTER USE                | :BF0001       |   299K|  6737K|       |    31  (23)| 00:00:01 |
|* 12 |           TABLE ACCESS INMEMORY FULL    | PRISONER      |   299K|  6737K|       |    31  (23)| 00:00:01 |
```]```
|  13 |        VIEW                             |               |  1063 | 13819 |       |  4674   (2)| 00:00:01 |
|* 14 |         FILTER                          |               |       |       |       |            |          |
|  15 |          JOIN FILTER USE                | :BF0000       |  1063 | 28701 |       |  4674   (2)| 00:00:01 |
|  16 |           HASH GROUP BY                 |               |  1063 | 28701 |       |  4674   (2)| 00:00:01 |
|* 17 |            FILTER                       |               |       |       |       |            |          |
|* 18 |             HASH JOIN                   |               |   659K|    16M|  7856K|  4635   (1)| 00:00:01 |
|  19 |              TABLE ACCESS FULL          | SENTENCE      |   473K|  2310K|       |  1379   (1)| 00:00:01 |
|* 20 |              HASH JOIN                  |               |   422K|  9069K|  7016K|  2184   (2)| 00:00:01 |
|  21 |               TABLE ACCESS FULL         | REPRIMAND     |   422K|  2061K|       |  1395   (1)| 00:00:01 |
```#highlight[```
|  22 |               TABLE ACCESS INMEMORY FULL| PRISONER      |   299K|  4980K|       |    29  (18)| 00:00:01 |
```]```
|* 23 |       VIEW                              |               |  9870 |    18M|       |  1613   (3)| 00:00:01 |
|  24 |        SORT GROUP BY                    |               |  9870 |   751K|   872K|  1613   (3)| 00:00:01 |
|* 25 |         FILTER                          |               |       |       |       |            |          |
|* 26 |          HASH JOIN                      |               |  9870 |   751K|       |  1430   (3)| 00:00:01 |
```#highlight[```
|  27 |           JOIN FILTER CREATE            | :BF0002       |  9870 |   587K|       |  1399   (3)| 00:00:01 |
|* 28 |            TABLE ACCESS FULL            | SENTENCE      |  9870 |   587K|       |  1399   (3)| 00:00:01 |
|  29 |           JOIN FILTER USE               | :BF0002       |   299K|  4980K|       |    29  (18)| 00:00:01 |
|* 30 |            TABLE ACCESS INMEMORY FULL   | PRISONER      |   299K|  4980K|       |    29  (18)| 00:00:01 |
```]```
|* 31 |      TABLE ACCESS FULL                  | ACCOMMODATION | 10850 |   275K|       |  2093   (4)| 00:00:01 |
|  32 |     TABLE ACCESS BY INDEX ROWID         | GUARD         |     1 |    23 |       |     1   (0)| 00:00:01 |
|* 33 |      INDEX UNIQUE SCAN                  | SYS_C008868   |     1 |       |       |     0   (0)| 00:00:01 |
|* 34 |    TABLE ACCESS BY INDEX ROWID          | CELL          |     1 |    11 |       |     1   (0)| 00:00:01 |
|* 35 |     INDEX UNIQUE SCAN                   | SYS_C008883   |     1 |       |       |     0   (0)| 00:00:01 |
|* 36 |   TABLE ACCESS BY INDEX ROWID           | PRISON_BLOCK  |     1 |     7 |       |     1   (0)| 00:00:01 |
|* 37 |    INDEX UNIQUE SCAN                    | SYS_C008855   |     1 |       |       |     0   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   4 - access("P"."ID"="A"."FK_PRISONER")
   5 - access("P"."ID"="PS"."ID")
   6 - access("P"."ID"="PC"."ID")
   8 - access("R"."FK_PRISONER"="P"."ID")
  10 - filter((:EVENT_TYPE IS NULL OR INSTR("R"."REASON",:EVENT_TYPE)>0) AND 
              TO_CHAR(INTERNAL_FUNCTION("R"."ISSUE_DATE"),'YYYY-MM-DD')>=:START_DATE AND 
              TO_CHAR(INTERNAL_FUNCTION("R"."ISSUE_DATE"),'YYYY-MM-DD')<=:END_DATE)
  12 - inmemory(SYS_OP_BLOOM_FILTER(:BF0001,"P"."ID"))
       filter(SYS_OP_BLOOM_FILTER(:BF0001,"P"."ID"))
  14 - filter((:SENTENCE_COUNT IS NULL OR COUNT(*)=TO_NUMBER(:SENTENCE_COUNT)) AND (:REPRIMAND_COUNT IS 
              NULL OR COUNT(*)=TO_NUMBER(:REPRIMAND_COUNT)))
  17 - filter(:END_DATE>=:START_DATE)
  18 - access("P"."ID"="S"."FK_PRISONER")
  20 - access("P"."ID"="R"."FK_PRISONER")
  23 - filter(:CRIME IS NULL OR INSTR("PS"."CRIME",:CRIME)>0)
  25 - filter(:END_DATE>=:START_DATE)
  26 - access("P"."ID"="S"."FK_PRISONER")
  28 - filter(TO_CHAR(INTERNAL_FUNCTION("S"."START_DATE"),'YYYY-MM-DD')<=:START_DATE AND 
              ("S"."REAL_END_DATE" IS NULL OR TO_CHAR(INTERNAL_FUNCTION("S"."REAL_END_DATE"),'YYYY-MM-DD')>=:END_DATE))
  30 - inmemory(SYS_OP_BLOOM_FILTER(:BF0002,"P"."ID"))
       filter(SYS_OP_BLOOM_FILTER(:BF0002,"P"."ID"))
  31 - filter(TO_CHAR(INTERNAL_FUNCTION("A"."START_DATE"),'YYYY-MM-DD')<=:START_DATE AND ("A"."END_DATE" 
              IS NULL OR TO_CHAR(INTERNAL_FUNCTION("A"."END_DATE"),'YYYY-MM-DD')>=:END_DATE))
  33 - access("R"."FK_GUARD"="G"."ID")
  34 - filter("C"."IS_SOLITARY"=TO_NUMBER(:IS_IN_SOLITARY) OR :IS_IN_SOLITARY IS NULL)
  35 - access("C"."ID"="A"."FK_CELL")
  36 - filter(:BLOCK_NUMBER IS NULL OR "PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  37 - access("PB"."ID"="C"."FK_BLOCK")
 
Note
-----
   - this is an adaptive plan
  ```]
)

#pagebreak()

*`query4`:*
#plan(
  [```
Plan hash value: 171928505
 
---------------------------------------------------------------------------------------------------------
| Id  | Operation                       | Name          | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                |               |     5 |    65 |       | 98509   (2)| 00:00:04 |
|   1 |  HASH UNIQUE                    |               |     5 |    65 |       | 98509   (2)| 00:00:04 |
|   2 |   UNION-ALL                     |               |       |       |       |            |          |
|   3 |    SORT AGGREGATE               |               |     1 |    13 |       | 19702   (2)| 00:00:01 |
|   4 |     VIEW                        |               |   157K|  1999K|       | 18945   (2)| 00:00:01 |
|   5 |      HASH GROUP BY              |               |   157K|  8612K|       | 18945   (2)| 00:00:01 |
|   6 |       MERGE JOIN OUTER          |               |  2487K|   132M|       | 18945   (2)| 00:00:01 |
|   7 |        MERGE JOIN OUTER         |               |  1592K|    69M|       | 15653   (2)| 00:00:01 |
|   8 |         MERGE JOIN OUTER        |               |   323K|    10M|       |  7036   (2)| 00:00:01 |
|*  9 |          FILTER                 |               |       |       |       |            |          |
|  10 |           MERGE JOIN OUTER      |               |   157K|  3845K|       |  3939   (3)| 00:00:01 |
|  11 |            SORT JOIN            |               |   157K|  2460K|  8680K|  1494   (2)| 00:00:01 |
```#highlight[```
|* 12 |             TABLE ACCESS FULL   | PRISONER      |   157K|  2460K|       |   650   (2)| 00:00:01 |
```]```
|* 13 |            SORT JOIN            |               | 10513 | 94617 |       |  2445   (4)| 00:00:01 |
|  14 |             VIEW                |               | 10513 | 94617 |       |  2444   (4)| 00:00:01 |
|* 15 |              HASH JOIN          |               | 10513 |   420K|       |  2444   (4)| 00:00:01 |
|  16 |               TABLE ACCESS FULL | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 17 |               HASH JOIN         |               | 10513 |   349K|       |  2442   (4)| 00:00:01 |
|* 18 |                TABLE ACCESS FULL| ACCOMMODATION | 10513 |   266K|       |  2088   (4)| 00:00:01 |
|  19 |                TABLE ACCESS FULL| CELL          |   251K|  1966K|       |   351   (1)| 00:00:01 |
|* 20 |          SORT JOIN              |               |   422K|  4122K|    16M|  3097   (2)| 00:00:01 |
|  21 |           TABLE ACCESS FULL     | REPRIMAND     |   422K|  4122K|       |  1395   (1)| 00:00:01 |
|* 22 |         SORT JOIN               |               |  1493K|    15M|    57M|  8617   (2)| 00:00:01 |
|  23 |          TABLE ACCESS FULL      | ACCOMMODATION |  1493K|    15M|       |  2032   (2)| 00:00:01 |
|* 24 |        SORT JOIN                |               |   473K|  4620K|    18M|  3285   (2)| 00:00:01 |
|  25 |         TABLE ACCESS FULL       | SENTENCE      |   473K|  4620K|       |  1379   (1)| 00:00:01 |
|  26 |    SORT AGGREGATE               |               |     1 |    13 |       | 19702   (2)| 00:00:01 |
|  27 |     VIEW                        |               |   157K|  1999K|       | 18945   (2)| 00:00:01 |
|  28 |      HASH GROUP BY              |               |   157K|  8612K|       | 18945   (2)| 00:00:01 |
|  29 |       MERGE JOIN OUTER          |               |  2487K|   132M|       | 18945   (2)| 00:00:01 |
|  30 |        MERGE JOIN OUTER         |               |  1592K|    69M|       | 15653   (2)| 00:00:01 |
|  31 |         MERGE JOIN OUTER        |               |   323K|    10M|       |  7036   (2)| 00:00:01 |
|* 32 |          FILTER                 |               |       |       |       |            |          |
|  33 |           MERGE JOIN OUTER      |               |   157K|  3845K|       |  3939   (3)| 00:00:01 |
|  34 |            SORT JOIN            |               |   157K|  2460K|  8680K|  1494   (2)| 00:00:01 |
```#highlight[```
|* 35 |             TABLE ACCESS FULL   | PRISONER      |   157K|  2460K|       |   650   (2)| 00:00:01 |
```]```
|* 36 |            SORT JOIN            |               | 10513 | 94617 |       |  2445   (4)| 00:00:01 |
|  37 |             VIEW                |               | 10513 | 94617 |       |  2444   (4)| 00:00:01 |
|* 38 |              HASH JOIN          |               | 10513 |   420K|       |  2444   (4)| 00:00:01 |
|  39 |               TABLE ACCESS FULL | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 40 |               HASH JOIN         |               | 10513 |   349K|       |  2442   (4)| 00:00:01 |
|* 41 |                TABLE ACCESS FULL| ACCOMMODATION | 10513 |   266K|       |  2088   (4)| 00:00:01 |
|  42 |                TABLE ACCESS FULL| CELL          |   251K|  1966K|       |   351   (1)| 00:00:01 |
|* 43 |          SORT JOIN              |               |   422K|  4122K|    16M|  3097   (2)| 00:00:01 |
|  44 |           TABLE ACCESS FULL     | REPRIMAND     |   422K|  4122K|       |  1395   (1)| 00:00:01 |
|* 45 |         SORT JOIN               |               |  1493K|    15M|    57M|  8617   (2)| 00:00:01 |
|  46 |          TABLE ACCESS FULL      | ACCOMMODATION |  1493K|    15M|       |  2032   (2)| 00:00:01 |
|* 47 |        SORT JOIN                |               |   473K|  4620K|    18M|  3285   (2)| 00:00:01 |
|  48 |         TABLE ACCESS FULL       | SENTENCE      |   473K|  4620K|       |  1379   (1)| 00:00:01 |
|  49 |    SORT AGGREGATE               |               |     1 |    13 |       | 19702   (2)| 00:00:01 |
|  50 |     VIEW                        |               |   157K|  1999K|       | 18945   (2)| 00:00:01 |
|  51 |      HASH GROUP BY              |               |   157K|  8612K|       | 18945   (2)| 00:00:01 |
|  52 |       MERGE JOIN OUTER          |               |  2487K|   132M|       | 18945   (2)| 00:00:01 |
|  53 |        MERGE JOIN OUTER         |               |  1592K|    69M|       | 15653   (2)| 00:00:01 |
|  54 |         MERGE JOIN OUTER        |               |   323K|    10M|       |  7036   (2)| 00:00:01 |
|* 55 |          FILTER                 |               |       |       |       |            |          |
|  56 |           MERGE JOIN OUTER      |               |   157K|  3845K|       |  3939   (3)| 00:00:01 |
|  57 |            SORT JOIN            |               |   157K|  2460K|  8680K|  1494   (2)| 00:00:01 |
```#highlight[```
|* 58 |             TABLE ACCESS FULL   | PRISONER      |   157K|  2460K|       |   650   (2)| 00:00:01 |
```]```
|* 59 |            SORT JOIN            |               | 10513 | 94617 |       |  2445   (4)| 00:00:01 |
|  60 |             VIEW                |               | 10513 | 94617 |       |  2444   (4)| 00:00:01 |
|* 61 |              HASH JOIN          |               | 10513 |   420K|       |  2444   (4)| 00:00:01 |
|  62 |               TABLE ACCESS FULL | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 63 |               HASH JOIN         |               | 10513 |   349K|       |  2442   (4)| 00:00:01 |
|* 64 |                TABLE ACCESS FULL| ACCOMMODATION | 10513 |   266K|       |  2088   (4)| 00:00:01 |
|  65 |                TABLE ACCESS FULL| CELL          |   251K|  1966K|       |   351   (1)| 00:00:01 |
|* 66 |          SORT JOIN              |               |   422K|  4122K|    16M|  3097   (2)| 00:00:01 |
|  67 |           TABLE ACCESS FULL     | REPRIMAND     |   422K|  4122K|       |  1395   (1)| 00:00:01 |
|* 68 |         SORT JOIN               |               |  1493K|    15M|    57M|  8617   (2)| 00:00:01 |
|  69 |          TABLE ACCESS FULL      | ACCOMMODATION |  1493K|    15M|       |  2032   (2)| 00:00:01 |
|* 70 |        SORT JOIN                |               |   473K|  4620K|    18M|  3285   (2)| 00:00:01 |
|  71 |         TABLE ACCESS FULL       | SENTENCE      |   473K|  4620K|       |  1379   (1)| 00:00:01 |
|  72 |    SORT AGGREGATE               |               |     1 |    13 |       | 19702   (2)| 00:00:01 |
|  73 |     VIEW                        |               |   157K|  1999K|       | 18945   (2)| 00:00:01 |
|  74 |      HASH GROUP BY              |               |   157K|  8612K|       | 18945   (2)| 00:00:01 |
|  75 |       MERGE JOIN OUTER          |               |  2487K|   132M|       | 18945   (2)| 00:00:01 |
|  76 |        MERGE JOIN OUTER         |               |  1592K|    69M|       | 15653   (2)| 00:00:01 |
|  77 |         MERGE JOIN OUTER        |               |   323K|    10M|       |  7036   (2)| 00:00:01 |
|* 78 |          FILTER                 |               |       |       |       |            |          |
|  79 |           MERGE JOIN OUTER      |               |   157K|  3845K|       |  3939   (3)| 00:00:01 |
|  80 |            SORT JOIN            |               |   157K|  2460K|  8680K|  1494   (2)| 00:00:01 |
```#highlight[```
|* 81 |             TABLE ACCESS FULL   | PRISONER      |   157K|  2460K|       |   650   (2)| 00:00:01 |
```]```
|* 82 |            SORT JOIN            |               | 10513 | 94617 |       |  2445   (4)| 00:00:01 |
|  83 |             VIEW                |               | 10513 | 94617 |       |  2444   (4)| 00:00:01 |
|* 84 |              HASH JOIN          |               | 10513 |   420K|       |  2444   (4)| 00:00:01 |
|  85 |               TABLE ACCESS FULL | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 86 |               HASH JOIN         |               | 10513 |   349K|       |  2442   (4)| 00:00:01 |
|* 87 |                TABLE ACCESS FULL| ACCOMMODATION | 10513 |   266K|       |  2088   (4)| 00:00:01 |
|  88 |                TABLE ACCESS FULL| CELL          |   251K|  1966K|       |   351   (1)| 00:00:01 |
|* 89 |          SORT JOIN              |               |   422K|  4122K|    16M|  3097   (2)| 00:00:01 |
|  90 |           TABLE ACCESS FULL     | REPRIMAND     |   422K|  4122K|       |  1395   (1)| 00:00:01 |
|* 91 |         SORT JOIN               |               |  1493K|    15M|    57M|  8617   (2)| 00:00:01 |
|  92 |          TABLE ACCESS FULL      | ACCOMMODATION |  1493K|    15M|       |  2032   (2)| 00:00:01 |
|* 93 |        SORT JOIN                |               |   473K|  4620K|    18M|  3285   (2)| 00:00:01 |
|  94 |         TABLE ACCESS FULL       | SENTENCE      |   473K|  4620K|       |  1379   (1)| 00:00:01 |
|  95 |    SORT AGGREGATE               |               |     1 |    13 |       | 19702   (2)| 00:00:01 |
|  96 |     VIEW                        |               |   157K|  1999K|       | 18945   (2)| 00:00:01 |
|  97 |      HASH GROUP BY              |               |   157K|  8612K|       | 18945   (2)| 00:00:01 |
|  98 |       MERGE JOIN OUTER          |               |  2487K|   132M|       | 18945   (2)| 00:00:01 |
|  99 |        MERGE JOIN OUTER         |               |  1592K|    69M|       | 15653   (2)| 00:00:01 |
| 100 |         MERGE JOIN OUTER        |               |   323K|    10M|       |  7036   (2)| 00:00:01 |
|*101 |          FILTER                 |               |       |       |       |            |          |
| 102 |           MERGE JOIN OUTER      |               |   157K|  3845K|       |  3939   (3)| 00:00:01 |
| 103 |            SORT JOIN            |               |   157K|  2460K|  8680K|  1494   (2)| 00:00:01 |
```#highlight[```
|*104 |             TABLE ACCESS FULL   | PRISONER      |   157K|  2460K|       |   650   (2)| 00:00:01 |
```]```
|*105 |            SORT JOIN            |               | 10513 | 94617 |       |  2445   (4)| 00:00:01 |
| 106 |             VIEW                |               | 10513 | 94617 |       |  2444   (4)| 00:00:01 |
|*107 |              HASH JOIN          |               | 10513 |   420K|       |  2444   (4)| 00:00:01 |
| 108 |               TABLE ACCESS FULL | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|*109 |               HASH JOIN         |               | 10513 |   349K|       |  2442   (4)| 00:00:01 |
|*110 |                TABLE ACCESS FULL| ACCOMMODATION | 10513 |   266K|       |  2088   (4)| 00:00:01 |
| 111 |                TABLE ACCESS FULL| CELL          |   251K|  1966K|       |   351   (1)| 00:00:01 |
|*112 |          SORT JOIN              |               |   422K|  4122K|    16M|  3097   (2)| 00:00:01 |
| 113 |           TABLE ACCESS FULL     | REPRIMAND     |   422K|  4122K|       |  1395   (1)| 00:00:01 |
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
Plan hash value: 3930997208
 
---------------------------------------------------------------------------------------------------------------
| Id  | Operation                             | Name          | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                      |               |     5 |    65 |       | 95440   (2)| 00:00:04 |
|   1 |  HASH UNIQUE                          |               |     5 |    65 |       | 95440   (2)| 00:00:04 |
|   2 |   UNION-ALL                           |               |       |       |       |            |          |
|   3 |    SORT AGGREGATE                     |               |     1 |    13 |       | 19088   (2)| 00:00:01 |
|   4 |     VIEW                              |               |   157K|  1999K|       | 18331   (2)| 00:00:01 |
|   5 |      HASH GROUP BY                    |               |   157K|  8612K|       | 18331   (2)| 00:00:01 |
|*  6 |       FILTER                          |               |       |       |       |            |          |
|   7 |        MERGE JOIN OUTER               |               |  2487K|   132M|       | 18331   (2)| 00:00:01 |
|   8 |         MERGE JOIN OUTER              |               |  2487K|   111M|       | 15886   (2)| 00:00:01 |
|   9 |          MERGE JOIN OUTER             |               |  1592K|    56M|       | 12595   (2)| 00:00:01 |
|  10 |           MERGE JOIN OUTER            |               |   323K|  8206K|       |  3977   (2)| 00:00:01 |
|  11 |            SORT JOIN                  |               |   157K|  2460K|  8680K|   880   (3)| 00:00:01 |
```#highlight[```
|* 12 |             TABLE ACCESS INMEMORY FULL| PRISONER      |   157K|  2460K|       |    36  (34)| 00:00:01 |
```]```
|* 13 |            SORT JOIN                  |               |   422K|  4122K|    16M|  3097   (2)| 00:00:01 |
|  14 |             TABLE ACCESS FULL         | REPRIMAND     |   422K|  4122K|       |  1395   (1)| 00:00:01 |
|* 15 |           SORT JOIN                   |               |  1493K|    15M|    57M|  8617   (2)| 00:00:01 |
|  16 |            TABLE ACCESS FULL          | ACCOMMODATION |  1493K|    15M|       |  2032   (2)| 00:00:01 |
|* 17 |          SORT JOIN                    |               |   473K|  4620K|    18M|  3285   (2)| 00:00:01 |
|  18 |           TABLE ACCESS FULL           | SENTENCE      |   473K|  4620K|       |  1379   (1)| 00:00:01 |
|* 19 |         SORT JOIN                     |               | 10513 | 94617 |       |  2445   (4)| 00:00:01 |
|  20 |          VIEW                         |               | 10513 | 94617 |       |  2444   (4)| 00:00:01 |
|* 21 |           HASH JOIN                   |               | 10513 |   420K|       |  2444   (4)| 00:00:01 |
|  22 |            TABLE ACCESS FULL          | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 23 |            HASH JOIN                  |               | 10513 |   349K|       |  2442   (4)| 00:00:01 |
|* 24 |             TABLE ACCESS FULL         | ACCOMMODATION | 10513 |   266K|       |  2088   (4)| 00:00:01 |
|  25 |             TABLE ACCESS FULL         | CELL          |   251K|  1966K|       |   351   (1)| 00:00:01 |
|  26 |    SORT AGGREGATE                     |               |     1 |    13 |       | 19088   (2)| 00:00:01 |
|  27 |     VIEW                              |               |   157K|  1999K|       | 18331   (2)| 00:00:01 |
|  28 |      HASH GROUP BY                    |               |   157K|  8612K|       | 18331   (2)| 00:00:01 |
|* 29 |       FILTER                          |               |       |       |       |            |          |
|  30 |        MERGE JOIN OUTER               |               |  2487K|   132M|       | 18331   (2)| 00:00:01 |
|  31 |         MERGE JOIN OUTER              |               |  2487K|   111M|       | 15886   (2)| 00:00:01 |
|  32 |          MERGE JOIN OUTER             |               |  1592K|    56M|       | 12595   (2)| 00:00:01 |
|  33 |           MERGE JOIN OUTER            |               |   323K|  8206K|       |  3977   (2)| 00:00:01 |
|  34 |            SORT JOIN                  |               |   157K|  2460K|  8680K|   880   (3)| 00:00:01 |
```#highlight[```
|* 35 |             TABLE ACCESS INMEMORY FULL| PRISONER      |   157K|  2460K|       |    36  (34)| 00:00:01 |
```]```
|* 36 |            SORT JOIN                  |               |   422K|  4122K|    16M|  3097   (2)| 00:00:01 |
|  37 |             TABLE ACCESS FULL         | REPRIMAND     |   422K|  4122K|       |  1395   (1)| 00:00:01 |
|* 38 |           SORT JOIN                   |               |  1493K|    15M|    57M|  8617   (2)| 00:00:01 |
|  39 |            TABLE ACCESS FULL          | ACCOMMODATION |  1493K|    15M|       |  2032   (2)| 00:00:01 |
|* 40 |          SORT JOIN                    |               |   473K|  4620K|    18M|  3285   (2)| 00:00:01 |
|  41 |           TABLE ACCESS FULL           | SENTENCE      |   473K|  4620K|       |  1379   (1)| 00:00:01 |
|* 42 |         SORT JOIN                     |               | 10513 | 94617 |       |  2445   (4)| 00:00:01 |
|  43 |          VIEW                         |               | 10513 | 94617 |       |  2444   (4)| 00:00:01 |
|* 44 |           HASH JOIN                   |               | 10513 |   420K|       |  2444   (4)| 00:00:01 |
|  45 |            TABLE ACCESS FULL          | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 46 |            HASH JOIN                  |               | 10513 |   349K|       |  2442   (4)| 00:00:01 |
|* 47 |             TABLE ACCESS FULL         | ACCOMMODATION | 10513 |   266K|       |  2088   (4)| 00:00:01 |
|  48 |             TABLE ACCESS FULL         | CELL          |   251K|  1966K|       |   351   (1)| 00:00:01 |
|  49 |    SORT AGGREGATE                     |               |     1 |    13 |       | 19088   (2)| 00:00:01 |
|  50 |     VIEW                              |               |   157K|  1999K|       | 18331   (2)| 00:00:01 |
|  51 |      HASH GROUP BY                    |               |   157K|  8612K|       | 18331   (2)| 00:00:01 |
|* 52 |       FILTER                          |               |       |       |       |            |          |
|  53 |        MERGE JOIN OUTER               |               |  2487K|   132M|       | 18331   (2)| 00:00:01 |
|  54 |         MERGE JOIN OUTER              |               |  2487K|   111M|       | 15886   (2)| 00:00:01 |
|  55 |          MERGE JOIN OUTER             |               |  1592K|    56M|       | 12595   (2)| 00:00:01 |
|  56 |           MERGE JOIN OUTER            |               |   323K|  8206K|       |  3977   (2)| 00:00:01 |
|  57 |            SORT JOIN                  |               |   157K|  2460K|  8680K|   880   (3)| 00:00:01 |
```#highlight[```
|* 58 |             TABLE ACCESS INMEMORY FULL| PRISONER      |   157K|  2460K|       |    36  (34)| 00:00:01 |
```]```
|* 59 |            SORT JOIN                  |               |   422K|  4122K|    16M|  3097   (2)| 00:00:01 |
|  60 |             TABLE ACCESS FULL         | REPRIMAND     |   422K|  4122K|       |  1395   (1)| 00:00:01 |
|* 61 |           SORT JOIN                   |               |  1493K|    15M|    57M|  8617   (2)| 00:00:01 |
|  62 |            TABLE ACCESS FULL          | ACCOMMODATION |  1493K|    15M|       |  2032   (2)| 00:00:01 |
|* 63 |          SORT JOIN                    |               |   473K|  4620K|    18M|  3285   (2)| 00:00:01 |
|  64 |           TABLE ACCESS FULL           | SENTENCE      |   473K|  4620K|       |  1379   (1)| 00:00:01 |
|* 65 |         SORT JOIN                     |               | 10513 | 94617 |       |  2445   (4)| 00:00:01 |
|  66 |          VIEW                         |               | 10513 | 94617 |       |  2444   (4)| 00:00:01 |
|* 67 |           HASH JOIN                   |               | 10513 |   420K|       |  2444   (4)| 00:00:01 |
|  68 |            TABLE ACCESS FULL          | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 69 |            HASH JOIN                  |               | 10513 |   349K|       |  2442   (4)| 00:00:01 |
|* 70 |             TABLE ACCESS FULL         | ACCOMMODATION | 10513 |   266K|       |  2088   (4)| 00:00:01 |
|  71 |             TABLE ACCESS FULL         | CELL          |   251K|  1966K|       |   351   (1)| 00:00:01 |
|  72 |    SORT AGGREGATE                     |               |     1 |    13 |       | 19088   (2)| 00:00:01 |
|  73 |     VIEW                              |               |   157K|  1999K|       | 18331   (2)| 00:00:01 |
|  74 |      HASH GROUP BY                    |               |   157K|  8612K|       | 18331   (2)| 00:00:01 |
|* 75 |       FILTER                          |               |       |       |       |            |          |
|  76 |        MERGE JOIN OUTER               |               |  2487K|   132M|       | 18331   (2)| 00:00:01 |
|  77 |         MERGE JOIN OUTER              |               |  2487K|   111M|       | 15886   (2)| 00:00:01 |
|  78 |          MERGE JOIN OUTER             |               |  1592K|    56M|       | 12595   (2)| 00:00:01 |
|  79 |           MERGE JOIN OUTER            |               |   323K|  8206K|       |  3977   (2)| 00:00:01 |
|  80 |            SORT JOIN                  |               |   157K|  2460K|  8680K|   880   (3)| 00:00:01 |
```#highlight[```
|* 81 |             TABLE ACCESS INMEMORY FULL| PRISONER      |   157K|  2460K|       |    36  (34)| 00:00:01 |
```]```
|* 82 |            SORT JOIN                  |               |   422K|  4122K|    16M|  3097   (2)| 00:00:01 |
|  83 |             TABLE ACCESS FULL         | REPRIMAND     |   422K|  4122K|       |  1395   (1)| 00:00:01 |
|* 84 |           SORT JOIN                   |               |  1493K|    15M|    57M|  8617   (2)| 00:00:01 |
|  85 |            TABLE ACCESS FULL          | ACCOMMODATION |  1493K|    15M|       |  2032   (2)| 00:00:01 |
|* 86 |          SORT JOIN                    |               |   473K|  4620K|    18M|  3285   (2)| 00:00:01 |
|  87 |           TABLE ACCESS FULL           | SENTENCE      |   473K|  4620K|       |  1379   (1)| 00:00:01 |
|* 88 |         SORT JOIN                     |               | 10513 | 94617 |       |  2445   (4)| 00:00:01 |
|  89 |          VIEW                         |               | 10513 | 94617 |       |  2444   (4)| 00:00:01 |
|* 90 |           HASH JOIN                   |               | 10513 |   420K|       |  2444   (4)| 00:00:01 |
|  91 |            TABLE ACCESS FULL          | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|* 92 |            HASH JOIN                  |               | 10513 |   349K|       |  2442   (4)| 00:00:01 |
|* 93 |             TABLE ACCESS FULL         | ACCOMMODATION | 10513 |   266K|       |  2088   (4)| 00:00:01 |
|  94 |             TABLE ACCESS FULL         | CELL          |   251K|  1966K|       |   351   (1)| 00:00:01 |
|  95 |    SORT AGGREGATE                     |               |     1 |    13 |       | 19088   (2)| 00:00:01 |
|  96 |     VIEW                              |               |   157K|  1999K|       | 18331   (2)| 00:00:01 |
|  97 |      HASH GROUP BY                    |               |   157K|  8612K|       | 18331   (2)| 00:00:01 |
|* 98 |       FILTER                          |               |       |       |       |            |          |
|  99 |        MERGE JOIN OUTER               |               |  2487K|   132M|       | 18331   (2)| 00:00:01 |
| 100 |         MERGE JOIN OUTER              |               |  2487K|   111M|       | 15886   (2)| 00:00:01 |
| 101 |          MERGE JOIN OUTER             |               |  1592K|    56M|       | 12595   (2)| 00:00:01 |
| 102 |           MERGE JOIN OUTER            |               |   323K|  8206K|       |  3977   (2)| 00:00:01 |
| 103 |            SORT JOIN                  |               |   157K|  2460K|  8680K|   880   (3)| 00:00:01 |
```#highlight[```
|*104 |             TABLE ACCESS INMEMORY FULL| PRISONER      |   157K|  2460K|       |    36  (34)| 00:00:01 |
```]```
|*105 |            SORT JOIN                  |               |   422K|  4122K|    16M|  3097   (2)| 00:00:01 |
| 106 |             TABLE ACCESS FULL         | REPRIMAND     |   422K|  4122K|       |  1395   (1)| 00:00:01 |
|*107 |           SORT JOIN                   |               |  1493K|    15M|    57M|  8617   (2)| 00:00:01 |
| 108 |            TABLE ACCESS FULL          | ACCOMMODATION |  1493K|    15M|       |  2032   (2)| 00:00:01 |
|*109 |          SORT JOIN                    |               |   473K|  4620K|    18M|  3285   (2)| 00:00:01 |
| 110 |           TABLE ACCESS FULL           | SENTENCE      |   473K|  4620K|       |  1379   (1)| 00:00:01 |
|*111 |         SORT JOIN                     |               | 10513 | 94617 |       |  2445   (4)| 00:00:01 |
| 112 |          VIEW                         |               | 10513 | 94617 |       |  2444   (4)| 00:00:01 |
|*113 |           HASH JOIN                   |               | 10513 |   420K|       |  2444   (4)| 00:00:01 |
| 114 |            TABLE ACCESS FULL          | PRISON_BLOCK  |   100 |   700 |       |     2   (0)| 00:00:01 |
|*115 |            HASH JOIN                  |               | 10513 |   349K|       |  2442   (4)| 00:00:01 |
|*116 |             TABLE ACCESS FULL         | ACCOMMODATION | 10513 |   266K|       |  2088   (4)| 00:00:01 |
| 117 |             TABLE ACCESS FULL         | CELL          |   251K|  1966K|       |   351   (1)| 00:00:01 |
---------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   6 - filter(:BLOCK_NUMBER IS NULL OR "PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  12 - inmemory("P"."SEX"=TO_NUMBER(:SEX) OR :SEX IS NULL)
       filter("P"."SEX"=TO_NUMBER(:SEX) OR :SEX IS NULL)
  13 - access("P"."ID"="R"."FK_PRISONER"(+))
       filter("P"."ID"="R"."FK_PRISONER"(+))
  15 - access("P"."ID"="A"."FK_PRISONER"(+))
       filter("P"."ID"="A"."FK_PRISONER"(+))
  17 - access("P"."ID"="S"."FK_PRISONER"(+))
       filter("P"."ID"="S"."FK_PRISONER"(+))
  19 - access("P"."ID"="PB"."ID"(+))
       filter("P"."ID"="PB"."ID"(+))
  21 - access("PB"."ID"="C"."FK_BLOCK")
  23 - access("C"."ID"="A"."FK_CELL")
  24 - filter("A"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD') AND ("A"."END_DATE" IS NULL OR 
              "A"."END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD')))
  29 - filter(:BLOCK_NUMBER IS NULL OR "PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  35 - inmemory("P"."SEX"=TO_NUMBER(:SEX) OR :SEX IS NULL)
       filter("P"."SEX"=TO_NUMBER(:SEX) OR :SEX IS NULL)
  36 - access("P"."ID"="R"."FK_PRISONER"(+))
       filter("P"."ID"="R"."FK_PRISONER"(+))
  38 - access("P"."ID"="A"."FK_PRISONER"(+))
       filter("P"."ID"="A"."FK_PRISONER"(+))
  40 - access("P"."ID"="S"."FK_PRISONER"(+))
       filter("P"."ID"="S"."FK_PRISONER"(+))
  42 - access("P"."ID"="PB"."ID"(+))
       filter("P"."ID"="PB"."ID"(+))
  44 - access("PB"."ID"="C"."FK_BLOCK")
  46 - access("C"."ID"="A"."FK_CELL")
  47 - filter("A"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD') AND ("A"."END_DATE" IS NULL OR 
              "A"."END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD')))
  52 - filter(:BLOCK_NUMBER IS NULL OR "PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  58 - inmemory("P"."SEX"=TO_NUMBER(:SEX) OR :SEX IS NULL)
       filter("P"."SEX"=TO_NUMBER(:SEX) OR :SEX IS NULL)
  59 - access("P"."ID"="R"."FK_PRISONER"(+))
       filter("P"."ID"="R"."FK_PRISONER"(+))
  61 - access("P"."ID"="A"."FK_PRISONER"(+))
       filter("P"."ID"="A"."FK_PRISONER"(+))
  63 - access("P"."ID"="S"."FK_PRISONER"(+))
       filter("P"."ID"="S"."FK_PRISONER"(+))
  65 - access("P"."ID"="PB"."ID"(+))
       filter("P"."ID"="PB"."ID"(+))
  67 - access("PB"."ID"="C"."FK_BLOCK")
  69 - access("C"."ID"="A"."FK_CELL")
  70 - filter("A"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD') AND ("A"."END_DATE" IS NULL OR 
              "A"."END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD')))
  75 - filter(:BLOCK_NUMBER IS NULL OR "PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
  81 - inmemory("P"."SEX"=TO_NUMBER(:SEX) OR :SEX IS NULL)
       filter("P"."SEX"=TO_NUMBER(:SEX) OR :SEX IS NULL)
  82 - access("P"."ID"="R"."FK_PRISONER"(+))
       filter("P"."ID"="R"."FK_PRISONER"(+))
  84 - access("P"."ID"="A"."FK_PRISONER"(+))
       filter("P"."ID"="A"."FK_PRISONER"(+))
  86 - access("P"."ID"="S"."FK_PRISONER"(+))
       filter("P"."ID"="S"."FK_PRISONER"(+))
  88 - access("P"."ID"="PB"."ID"(+))
       filter("P"."ID"="PB"."ID"(+))
  90 - access("PB"."ID"="C"."FK_BLOCK")
  92 - access("C"."ID"="A"."FK_CELL")
  93 - filter("A"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD') AND ("A"."END_DATE" IS NULL OR 
              "A"."END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD')))
  98 - filter(:BLOCK_NUMBER IS NULL OR "PB"."BLOCK_NUMBER"=:BLOCK_NUMBER)
 104 - inmemory("P"."SEX"=TO_NUMBER(:SEX) OR :SEX IS NULL)
       filter("P"."SEX"=TO_NUMBER(:SEX) OR :SEX IS NULL)
 105 - access("P"."ID"="R"."FK_PRISONER"(+))
       filter("P"."ID"="R"."FK_PRISONER"(+))
 107 - access("P"."ID"="A"."FK_PRISONER"(+))
       filter("P"."ID"="A"."FK_PRISONER"(+))
 109 - access("P"."ID"="S"."FK_PRISONER"(+))
       filter("P"."ID"="S"."FK_PRISONER"(+))
 111 - access("P"."ID"="PB"."ID"(+))
       filter("P"."ID"="PB"."ID"(+))
 113 - access("PB"."ID"="C"."FK_BLOCK")
 115 - access("C"."ID"="A"."FK_CELL")
 116 - filter("A"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD') AND ("A"."END_DATE" IS NULL OR 
              "A"."END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD')))
 
Note
-----
   - this is an adaptive plan
  ```]
)

Udało się zgodnie z planem usprawnić kwerendę `query4`, a dodatkowo znacząco zmalał koszt kwerend `query2` i `query3`. Czas wykonywania zapytań praktycznie się nie zmienił, jedyne sensowne różnice można zauważyć w przypadku `query2`, jednakże jest to zmiana mniejsza niż dla `change4`, którego plan w ogóle się nie zmienił.

== Propozycja 2

Propozycja 2 polegała na zastosowaniu składowania kolumnowego na całej tabeli `guard`, wykorzystywanej m.in. w zapytaniu `change1`. Ponadto, jako podeksperyment zawarty w drugiej podsekcji tego rozdziału, dodaliśmy złączenie pamięciowe do tabeli `patrol` oraz `patrol_slot` licząc na dodatkową poprawę wydajności zapytań.

Wykorzystana dla tabeli `guard` pamięć (w obu przypadkach):
- 0.78 MB - na dysku
- *1.31 MB* - składowanie kolumnowe (domyślna kompresja)

#pagebreak()

=== P2 -- Bez złączenia pamięciowego

```sql
alter table guard inmemory priority critical;
```

#align(center, include("./test-app/out/onlyp2/table.typ"))

*`query1:`*
#plan(
  [```
Plan hash value: 2723260768
 
--------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                  | Name                        | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                           |                             |    68 |  1836 |  1746   (6)| 00:00:01 |
|   1 |  SORT GROUP BY                             |                             |     1 |   271 |            |          |
|   2 |   VIEW                                     |                             |     6 |  1626 |    50   (6)| 00:00:01 |
|   3 |    SORT ORDER BY                           |                             |     6 |  1782 |    50   (6)| 00:00:01 |
|*  4 |     VIEW                                   |                             |     6 |  1782 |    49   (5)| 00:00:01 |
|*  5 |      WINDOW SORT PUSHED RANK               |                             |     6 |   504 |    49   (5)| 00:00:01 |
|*  6 |       FILTER                               |                             |       |       |            |          |
|*  7 |        HASH JOIN OUTER                     |                             |     6 |   504 |    48   (3)| 00:00:01 |
|   8 |         NESTED LOOPS                       |                             |     8 |   544 |    32   (4)| 00:00:01 |
|   9 |          TABLE ACCESS BY INDEX ROWID       | PATROL_SLOT                 |     1 |    27 |     2   (0)| 00:00:01 |
|* 10 |           INDEX UNIQUE SCAN                | SYS_C008873                 |     1 |       |     1   (0)| 00:00:01 |
```#highlight[```
|* 11 |          TABLE ACCESS FULL                 | GUARD                       |     8 |   328 |    29   (0)| 00:00:01 |
```]```
|  12 |         TABLE ACCESS BY INDEX ROWID BATCHED| PATROL                      |  2560 | 40960 |    16   (0)| 00:00:01 |
|* 13 |          INDEX RANGE SCAN                  | PATROL_FK_PATROL_SLOT_INDEX |  2560 |       |     7   (0)| 00:00:01 |
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
  ```],
  [```
Plan hash value: 2723260768
 
--------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                  | Name                        | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                           |                             |    68 |  1836 |   809  (13)| 00:00:01 |
|   1 |  SORT GROUP BY                             |                             |     1 |   271 |            |          |
|   2 |   VIEW                                     |                             |     6 |  1626 |    22  (10)| 00:00:01 |
|   3 |    SORT ORDER BY                           |                             |     6 |  1782 |    22  (10)| 00:00:01 |
|*  4 |     VIEW                                   |                             |     6 |  1782 |    21   (5)| 00:00:01 |
|*  5 |      WINDOW SORT PUSHED RANK               |                             |     6 |   504 |    21   (5)| 00:00:01 |
|*  6 |       FILTER                               |                             |       |       |            |          |
|*  7 |        HASH JOIN OUTER                     |                             |     6 |   504 |    20   (0)| 00:00:01 |
|   8 |         NESTED LOOPS                       |                             |     8 |   544 |     4   (0)| 00:00:01 |
|   9 |          TABLE ACCESS BY INDEX ROWID       | PATROL_SLOT                 |     1 |    27 |     2   (0)| 00:00:01 |
|* 10 |           INDEX UNIQUE SCAN                | SYS_C008873                 |     1 |       |     1   (0)| 00:00:01 |
```#highlight[```
|* 11 |          TABLE ACCESS INMEMORY FULL        | GUARD                       |     8 |   328 |     2   (0)| 00:00:01 |
```]```
|  12 |         TABLE ACCESS BY INDEX ROWID BATCHED| PATROL                      |  2560 | 40960 |    16   (0)| 00:00:01 |
|* 13 |          INDEX RANGE SCAN                  | PATROL_FK_PATROL_SLOT_INDEX |  2560 |       |     7   (0)| 00:00:01 |
|* 14 |  TABLE ACCESS FULL                         | PATROL_SLOT                 |    68 |  1836 |    34   (3)| 00:00:01 |
--------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   4 - filter("from$_subquery$_008"."rowlimit_$$_rownumber"<=:PROPOSAL_COUNT)
   5 - filter(ROW_NUMBER() OVER ( ORDER BY "DBMS_RANDOM"."VALUE"())<=:PROPOSAL_COUNT)
   6 - filter("P"."ID" IS NULL)
   7 - access("P"."FK_GUARD"(+)="G"."ID" AND "P"."FK_PATROL_SLOT"(+)="PS"."ID")
  10 - access("PS"."ID"=:B1)
  11 - inmemory(("G"."HAS_DISABILITY_CLASS"=:HAS_DISABILITY_CLASS OR :HAS_DISABILITY_CLASS IS NULL) AND 
              "PS"."START_TIME">=INTERNAL_FUNCTION("G"."EMPLOYMENT_DATE") AND ("G"."DISMISSAL_DATE" IS NULL OR 
              "PS"."END_TIME"<=INTERNAL_FUNCTION("G"."DISMISSAL_DATE")) AND (:EXPERIENCE_MONTHS IS NULL OR 
              MONTHS_BETWEEN(INTERNAL_FUNCTION("PS"."START_TIME"),INTERNAL_FUNCTION("G"."EMPLOYMENT_DATE"))>=:EXPERIENCE_MONTHS)
              )
       filter(("G"."HAS_DISABILITY_CLASS"=:HAS_DISABILITY_CLASS OR :HAS_DISABILITY_CLASS IS NULL) AND 
              "PS"."START_TIME">=INTERNAL_FUNCTION("G"."EMPLOYMENT_DATE") AND ("G"."DISMISSAL_DATE" IS NULL OR 
              "PS"."END_TIME"<=INTERNAL_FUNCTION("G"."DISMISSAL_DATE")) AND (:EXPERIENCE_MONTHS IS NULL OR 
              MONTHS_BETWEEN(INTERNAL_FUNCTION("PS"."START_TIME"),INTERNAL_FUNCTION("G"."EMPLOYMENT_DATE"))>=:EXPERIENCE_MONTHS)
              )
  13 - access("P"."FK_PATROL_SLOT"(+)=:B1)
  14 - filter("PS"."START_TIME">=TO_TIMESTAMP(:START_TIME,'YYYY-MM-DD HH24:MI:SS') AND 
              "PS"."END_TIME"<=TO_TIMESTAMP(:END_TIME,'YYYY-MM-DD HH24:MI:SS'))
  ```]
)

=== P2 -- Ze złączeniem pamięciowym

```sql
alter table guard inmemory priority critical;
create inmemory join group p2_guard_patrol_join_group ( guard ( id ),patrol ( fk_guard ) );
create inmemory join group p2_patrol_patrol_slot_join_group ( patrol ( fk_patrol_slot ),patrol_slot ( id ) );
```

#align(center, include("./test-app/out/onlyp2group/table.typ"))

*`query1:`*
#plan(
  [```
Plan hash value: 2723260768
 
--------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                  | Name                        | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                           |                             |    68 |  1836 |  1746   (6)| 00:00:01 |
|   1 |  SORT GROUP BY                             |                             |     1 |   271 |            |          |
|   2 |   VIEW                                     |                             |     6 |  1626 |    50   (6)| 00:00:01 |
|   3 |    SORT ORDER BY                           |                             |     6 |  1782 |    50   (6)| 00:00:01 |
|*  4 |     VIEW                                   |                             |     6 |  1782 |    49   (5)| 00:00:01 |
|*  5 |      WINDOW SORT PUSHED RANK               |                             |     6 |   504 |    49   (5)| 00:00:01 |
|*  6 |       FILTER                               |                             |       |       |            |          |
|*  7 |        HASH JOIN OUTER                     |                             |     6 |   504 |    48   (3)| 00:00:01 |
|   8 |         NESTED LOOPS                       |                             |     8 |   544 |    32   (4)| 00:00:01 |
|   9 |          TABLE ACCESS BY INDEX ROWID       | PATROL_SLOT                 |     1 |    27 |     2   (0)| 00:00:01 |
|* 10 |           INDEX UNIQUE SCAN                | SYS_C008873                 |     1 |       |     1   (0)| 00:00:01 |
```#highlight[```
|* 11 |          TABLE ACCESS FULL                 | GUARD                       |     8 |   328 |    29   (0)| 00:00:01 |
```]```
|  12 |         TABLE ACCESS BY INDEX ROWID BATCHED| PATROL                      |  2560 | 40960 |    16   (0)| 00:00:01 |
|* 13 |          INDEX RANGE SCAN                  | PATROL_FK_PATROL_SLOT_INDEX |  2560 |       |     7   (0)| 00:00:01 |
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
  ```],
  [```
Plan hash value: 2723260768
 
--------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                  | Name                        | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                           |                             |    68 |  1836 |   809  (13)| 00:00:01 |
|   1 |  SORT GROUP BY                             |                             |     1 |   271 |            |          |
|   2 |   VIEW                                     |                             |     6 |  1626 |    22  (10)| 00:00:01 |
|   3 |    SORT ORDER BY                           |                             |     6 |  1782 |    22  (10)| 00:00:01 |
|*  4 |     VIEW                                   |                             |     6 |  1782 |    21   (5)| 00:00:01 |
|*  5 |      WINDOW SORT PUSHED RANK               |                             |     6 |   504 |    21   (5)| 00:00:01 |
|*  6 |       FILTER                               |                             |       |       |            |          |
|*  7 |        HASH JOIN OUTER                     |                             |     6 |   504 |    20   (0)| 00:00:01 |
|   8 |         NESTED LOOPS                       |                             |     8 |   544 |     4   (0)| 00:00:01 |
|   9 |          TABLE ACCESS BY INDEX ROWID       | PATROL_SLOT                 |     1 |    27 |     2   (0)| 00:00:01 |
|* 10 |           INDEX UNIQUE SCAN                | SYS_C008873                 |     1 |       |     1   (0)| 00:00:01 |
```#highlight[```
|* 11 |          TABLE ACCESS INMEMORY FULL        | GUARD                       |     8 |   328 |     2   (0)| 00:00:01 |
```]```
|  12 |         TABLE ACCESS BY INDEX ROWID BATCHED| PATROL                      |  2560 | 40960 |    16   (0)| 00:00:01 |
|* 13 |          INDEX RANGE SCAN                  | PATROL_FK_PATROL_SLOT_INDEX |  2560 |       |     7   (0)| 00:00:01 |
|* 14 |  TABLE ACCESS FULL                         | PATROL_SLOT                 |    68 |  1836 |    34   (3)| 00:00:01 |
--------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   4 - filter("from$_subquery$_008"."rowlimit_$$_rownumber"<=:PROPOSAL_COUNT)
   5 - filter(ROW_NUMBER() OVER ( ORDER BY "DBMS_RANDOM"."VALUE"())<=:PROPOSAL_COUNT)
   6 - filter("P"."ID" IS NULL)
   7 - access("P"."FK_GUARD"(+)="G"."ID" AND "P"."FK_PATROL_SLOT"(+)="PS"."ID")
  10 - access("PS"."ID"=:B1)
  11 - inmemory(("G"."HAS_DISABILITY_CLASS"=:HAS_DISABILITY_CLASS OR :HAS_DISABILITY_CLASS IS NULL) AND 
              "PS"."START_TIME">=INTERNAL_FUNCTION("G"."EMPLOYMENT_DATE") AND ("G"."DISMISSAL_DATE" IS NULL OR 
              "PS"."END_TIME"<=INTERNAL_FUNCTION("G"."DISMISSAL_DATE")) AND (:EXPERIENCE_MONTHS IS NULL OR 
              MONTHS_BETWEEN(INTERNAL_FUNCTION("PS"."START_TIME"),INTERNAL_FUNCTION("G"."EMPLOYMENT_DATE"))>=:EXPERIENCE_MONTHS)
              )
       filter(("G"."HAS_DISABILITY_CLASS"=:HAS_DISABILITY_CLASS OR :HAS_DISABILITY_CLASS IS NULL) AND 
              "PS"."START_TIME">=INTERNAL_FUNCTION("G"."EMPLOYMENT_DATE") AND ("G"."DISMISSAL_DATE" IS NULL OR 
              "PS"."END_TIME"<=INTERNAL_FUNCTION("G"."DISMISSAL_DATE")) AND (:EXPERIENCE_MONTHS IS NULL OR 
              MONTHS_BETWEEN(INTERNAL_FUNCTION("PS"."START_TIME"),INTERNAL_FUNCTION("G"."EMPLOYMENT_DATE"))>=:EXPERIENCE_MONTHS)
              )
  13 - access("P"."FK_PATROL_SLOT"(+)=:B1)
  14 - filter("PS"."START_TIME">=TO_TIMESTAMP(:START_TIME,'YYYY-MM-DD HH24:MI:SS') AND 
              "PS"."END_TIME"<=TO_TIMESTAMP(:END_TIME,'YYYY-MM-DD HH24:MI:SS'))
  ```]
)

=== P2 -- Podsumowanie

Zgodnie z planami, koszt kwerendy `change1` zmalał, jednakże dużo większe zyski obserwowalne są dla kwerendy `query1`. Wykorzystanie złączenia pamięciowego dało identyczne pod względem kosztu wyniki jak jego brak, dając jedynie nieznacznie szybsze wykonanie zapytania. Prawdopodobnie system Oracle zadecydował nie wykorzystać złączenia pamięciowego.

== Propozycja 3

W przypadku trzeciej propozycji postanowiliśmy skupić się na składowaniu kolumnowym dla poszczególnych kolumn danej tabeli oraz na zastosowaniu złączeń pamięciowych. Wykorzystaliśmy w tym celu kwerendę `query2`, korzystającą z tabel `reprimand` i `sentence` oraz ich złączeń do tabeli `prisoner`.

Początkowo planowaliśmy wykonać to za pomocą następującego kodu:
```sql
alter table sentence inmemory ( id,
                                fk_prisoner );
alter table reprimand inmemory ( id,
                                 fk_prisoner );
create inmemory join group p3_prisoner_id_sentence_fk_prisoner ( prisoner ( id ),sentence ( fk_prisoner ) );
create inmemory join group p3_prisoner_id_reprimand_fk_prisoner ( prisoner ( id ),reprimand ( fk_prisoner ) );
```

#v(1cm)

#whoopsie[
Niestety, powyższe zapytanie zwróciło błąd *`ORA-00957: duplicate column name`* przy wykonywaniu ostatniej klauzuli. Po chwili debugowania dotarliśmy do wniosku, że problem jest niezwiązany z dwoma pierwszymi zapytaniami więc zmniejszyliśmy fragment testowy do następującego kodu:
```sql
create inmemory join group p3_prisoner_id_sentence_fk_prisoner ( prisoner ( id ),sentence ( fk_prisoner ) );
create inmemory join group p3_prisoner_id_reprimand_fk_prisoner ( prisoner ( id ),reprimand ( fk_prisoner ) );
```

Warto zauważyć, że oba złączenia korzystają z takich samych nazw kolumn, natomiast w różnych tabelach (w przypadku pierwszego złączenia `sentence.fk_prisoner`, a w przypadku drugiego `reprimand.fk_prisoner`), co może sugerować genezę błędu `duplicate column name`, jednakże nie widzimy powodu, dla którego takie złączenie miałoby być niemożliwe do wykonania. Druga komenda `create inmemory join group` nie jest błędna, ponieważ uruchamiając ją jako pierwszą nie pojawia się żaden błąd, jednakże pojawia się on wtedy przy próbie uruchomienia pierwszej komendy.

Oficjalna dokumentacja Oracle nie zawiera informacji na temat występowania błędu `ORA-00957` w kontekście złączeń pamięciowych, jedynie mówiąc, że pojawia się on przy próbie zdefiniowania dwóch kolumn o tej samej nazwie w jednej tabeli.

W celu rozwiązania problemu wykonaliśmy następujące próby:
- Zmiana kolejności tworzenia złączeń pamięciowych.
- Zmiana nazw złączeń pamięciowych.
- Zmiana kolejności kolumn w złączeniach pamięciowych:
  - `sentence(fk_prisoner), prisoner(id)` oraz `reprimand(fk_prisoner), prisoner(id)`,
  - `prisoner(id), sentence(fk_prisoner)` oraz `reprimand(fk_prisoner), prisoner(id)`,
  - `sentence(fk_prisoner), prisoner(id)` oraz `prisoner(id), reprimand(fk_prisoner)`.

Po przetestowaniu wszystkich kombinacji, w obliczu braku dokumentacji, doszliśmy do wniosku, że Oracle *nie pozwala na zdefiniowanie złączenia pamięciowego, które korzysta z tych samych nazw kolumn, nawet jeżeli znajdują się one w różnych tabelach*.
]

W związku z tym, propozycję trzecią rozdzieliliśmy na dwie, gdzie w pierwszej tworzymy jedynie złączenie do tabeli `reprimand`, a w drugiej do tabeli `sentence`.

=== P3 -- Ze złączeniem z `reprimand`

```sql
alter table sentence inmemory ( id,
                                fk_prisoner );
alter table reprimand inmemory ( id,
                                 fk_prisoner );
create inmemory join group p3_prisoner_id_reprimand_fk_prisoner ( prisoner ( id ),reprimand ( fk_prisoner ) );
```

#align(center, include("./test-app/out/onlyp3rep/table.typ"))

=== P3 -- Ze złączeniem z `sentence`

```sql
alter table sentence inmemory ( id,
                                fk_prisoner );
alter table reprimand inmemory ( id,
                                 fk_prisoner );
create inmemory join group p3_prisoner_id_sentence_fk_prisoner ( prisoner ( id ),sentence ( fk_prisoner ) );
```

#align(center, include("./test-app/out/onlyp3sen/table.typ"))

=== P3 -- Podsumowanie

Dla obu przypadków nie zauważyliśmy zmiany kosztu ani zauważalnej zmiany czasu wykonania żadnego z zapytań. Warto nadmienić, że wykonane przez nas cząstkowe eksperymenty, były z uwagi na błąd Oracle zmienione względem pierwotnych planów, przez co motywacja do zastosowania w tym miejscu składowania kolumnowego jest niestety nieaktualna.

== Połączenie wszystkich propozycji

Następnie, w ramach dodatku nad propozycją z poprzedniej listy, postanowiliśmy połączyć wszystkie propozycje w jednym eksperymencie, aby sprawdzić sumaryczne efekty. W związku z występującym w propozycji trzeciej błędem, zdecydowaliśmy się na zastosowanie tylko dwóch pierwszych propozycji, tj. włączenia składowania kolumnowego na tabelach `prisoner` i `guard`.

```sql
alter table prisoner inmemory priority critical;
alter table guard inmemory priority critical;
```

Sumarycznie wykorzystane zostało *15.21 MB pamięci*, dając następujące wyniki:

#align(center, include("./test-app/out/p1andp2/table.typ"))

Jak widać, koszt znacząco zmalał, jednakże czas wykonania zapytań pozostał praktycznie bez zmian, a wręcz się pogorszył. Poszczególne plany zapytań nie będą analizowane, ponieważ zmiany ich kosztów stanowią sumę zmian z poszczególnych propozycji, więc wychodzimy z założenia, że nie wyciągniemy z~nich żadnych nowych wniosków.

== Eksperyment 1

Eksperyment pierwszy polegał na porównaniu różnych metod kompresji, wymienionych w poniższych podsekcjach, dla tabeli `prisoner`, która jest tabelą wykorzystywaną najczęściej w zapytaniach. Na dole rozdziału znajduje się podsumowanie wyników.

=== E1 -- `NO MEMCOMPRESS`

```sql
alter table prisoner inmemory priority critical no memcompress;
```

Wykorzystana dla tabeli `prisoner` pamięć:
- 17.83 MB - na dysku
- *15.14 MB* - składowanie kolumnowe (`NO MEMCOMPRESS`)

#align(center, include("./test-app/out/onlye11/table.typ"))

#pagebreak()

=== E1 -- `MEMCOMPRESS FOR DML`

```sql
alter table prisoner inmemory priority critical memcompress for dml;
```

Wykorzystana dla tabeli `prisoner` pamięć:
- 17.83 MB - na dysku
- *15.14 MB* - składowanie kolumnowe (`MEMCOMPRESS FOR DML`)

#align(center, include("./test-app/out/onlye12/table.typ"))

#pagebreak()

=== E1 -- `MEMCOMPRESS FOR QUERY LOW` (domyślne)

```sql
alter table prisoner inmemory priority critical memcompress for query low;
```

Wykorzystana dla tabeli `prisoner` pamięć:
- 17.83 MB - na dysku
- *13.89 MB* - składowanie kolumnowe (`MEMCOMPRESS FOR QUERY LOW`)

#align(center, include("./test-app/out/onlye13/table.typ"))

#pagebreak()

=== E1 -- `MEMCOMPRESS FOR QUERY HIGH`

```sql
alter table prisoner inmemory priority critical memcompress for query high;
```

Wykorzystana dla tabeli `prisoner` pamięć:
- 17.83 MB - na dysku
- *7.60 MB* - składowanie kolumnowe (`MEMCOMPRESS FOR QUERY HIGH`)

#align(center, include("./test-app/out/onlye14/table.typ"))

#pagebreak()

=== E1 -- `MEMCOMPRESS FOR CAPACITY LOW`

```sql
alter table prisoner inmemory priority critical memcompress for capacity low;
```

Wykorzystana dla tabeli `prisoner` pamięć:
- 17.83 MB - na dysku
- *6.55 MB* - składowanie kolumnowe (`MEMCOMPRESS FOR CAPACITY LOW`)

#align(center, include("./test-app/out/onlye15/table.typ"))

#pagebreak()

=== E1 -- `MEMCOMPRESS FOR CAPACITY HIGH`

```sql
alter table prisoner inmemory priority critical memcompress for capacity high;
```

Wykorzystana dla tabeli `prisoner` pamięć:
- 17.83 MB - na dysku
- *5.51 MB* - składowanie kolumnowe (`MEMCOMPRESS FOR CAPACITY HIGH`)

#align(center, include("./test-app/out/onlye16/table.typ"))

#pagebreak()

=== E1 -- Podsumowanie

#let r(n) = text(fill: rgb("#880000"), n)
#let g(n) = text(fill: rgb("#008800"), n)
#align(center,table(
  align: horizon + right,
  columns: 7,
  fill: (x, y) => if y in (0, 1) { rgb("#cce") } else if calc.rem(y, 2) == 0 { rgb("#f0f0ff") },
  table.cell(rowspan: 2)[*Metoda kompresji*], table.cell(colspan: 2)[*Wykorzystana pamięć [MB]*], table.cell(colspan: 2)[*Koszt zapytań*], table.cell(colspan: 2)[*Czas zapytań [ms]*],
  [*Wartość*], [*Kompresja*], [*Wartość*], [*Zmiana*], [*Wartość*], [*Zmiana*],
  [*`NO MEMCOMPRESS`*], [15.14], [---], [161 486], [---], [30 451], [---],
  [*`MEMCOMPRESS FOR DML`*], [15.14], [0%], [161 486], [0], [30 303], [#g[-148]],
  [*`MEMCOMPRESS FOR QUERY LOW`*], [13.89], [#g[-8.3%]], [161 475], [#g[-11]], [30 319], [#g[-132]],
  [*`MEMCOMPRESS FOR QUERY HIGH`*], [7.60], [#g[-49.9%]], [161 475], [#g[-11]], [30 339], [#g[-112]],
  [*`MEMCOMPRESS FOR CAPACITY LOW`*], [6.55], [#g[-56.8%]], [161 517], [#r[+31]], [30 339], [#g[-112]],
  [*`MEMCOMPRESS FOR CAPACITY HIGH`*], [5.51], [#g[-63.7%]], [161 513], [#r[+27]], [30 433], [#g[-18]]
))

Każda kolejna metoda kompresji zmniejszała w znaczący sposób wykorzystaną pamięć, jednocześnie powodując śladowe zmiany kosztów oraz czasów wykonywania zapytań. W przypadku analizowanej bazy danych, opłacalne byłoby zastosowanie kompresji `MEMCOMPRESS FOR CAPACITY HIGH` z uwagi na największe oszczędności pamięci przy pomijalnych stratach wydajności.

Warto zauważyć również, że wyniki dla `NO MEMCOMPRESS` oraz `MEMCOMPRESS FOR DML` są tożsame. Z informacji, do których dotarliśmy wynika, że tryb `FOR DML` w praktyce wykonuje kompresję jedynie, kiedy wszystkie wartości w kolumnie są takie same, co u nas oczywiście nie ma miejsca:

#blockquote[
  #quote[_I think it's also worth mentioning that compression numbers for `NO MEMCOMPRESS` and `MEMCOMPRESS FOR DML` are basically the same. That's because `MEMCOMPRESS FOR DML` is optimized for DML operations and performs little or no data compression. In practice, it will only provide compression if all of the column values are the same._] --- #link("https://blogs.oracle.com/in-memory/post/database-in-memory-compression")
]

== Eksperyment 2

Eksperyment drugi polegał na próbie wykorzystania składowania kolumnowego na widokach zmaterializowanych. Wykorzystujemy mechanizm widoku zmaterializowanego w zapytaniu `query4_mv`, korzystającym z (niefortunnie nazwanego identycznie) widoku `query4_mv`. Oracle wspiera składowanie kolumnowe na widokach zmaterializowanych, zatem postanowiliśmy sprawdzić, jakie efekty przyniesie to w naszym przypadku.

```sql
alter materialized view query4_mv inmemory priority critical;
```

Wykorzystana dla widoku zmaterializowanego `query4_mv` pamięć:
- 9.44 MB - na dysku
- *5.51 MB* - składowanie kolumnowe (domyślna kompresja)

#align(center, include("./test-app/out/onlye2/table.typ"))

*`query4_mv`:*
#plan(
  [```
Plan hash value: 1298516637
 
-------------------------------------------------------------------------------------
| Id  | Operation               | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT        |           |     5 |   150 |  1570   (1)| 00:00:01 |
|   1 |  HASH UNIQUE            |           |     5 |   150 |  1570   (1)| 00:00:01 |
|   2 |   UNION-ALL             |           |       |       |            |          |
|   3 |    SORT AGGREGATE       |           |     1 |    30 |   314   (1)| 00:00:01 |
```#highlight[```
|*  4 |     MAT_VIEW ACCESS FULL| QUERY4_MV |   889 | 26670 |   313   (1)| 00:00:01 |
```]```
|   5 |    SORT AGGREGATE       |           |     1 |    30 |   314   (1)| 00:00:01 |
```#highlight[```
|*  6 |     MAT_VIEW ACCESS FULL| QUERY4_MV |   889 | 26670 |   313   (1)| 00:00:01 |
```]```
|   7 |    SORT AGGREGATE       |           |     1 |    30 |   314   (1)| 00:00:01 |
```#highlight[```
|*  8 |     MAT_VIEW ACCESS FULL| QUERY4_MV |   889 | 26670 |   313   (1)| 00:00:01 |
```]```
|   9 |    SORT AGGREGATE       |           |     1 |    30 |   314   (1)| 00:00:01 |
```#highlight[```
|* 10 |     MAT_VIEW ACCESS FULL| QUERY4_MV |   889 | 26670 |   313   (1)| 00:00:01 |
```]```
|  11 |    SORT AGGREGATE       |           |     1 |    30 |   314   (1)| 00:00:01 |
```#highlight[```
|* 12 |     MAT_VIEW ACCESS FULL| QUERY4_MV |   889 | 26670 |   313   (1)| 00:00:01 |
```]```
-------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   4 - filter((:BLOCK_NUMBER IS NULL OR "BLOCK_NUMBER"=:BLOCK_NUMBER) AND 
              (:SEX IS NULL OR "SEX"=TO_NUMBER(:SEX)))
   6 - filter((:BLOCK_NUMBER IS NULL OR "BLOCK_NUMBER"=:BLOCK_NUMBER) AND 
              (:SEX IS NULL OR "SEX"=TO_NUMBER(:SEX)))
   8 - filter((:BLOCK_NUMBER IS NULL OR "BLOCK_NUMBER"=:BLOCK_NUMBER) AND 
              (:SEX IS NULL OR "SEX"=TO_NUMBER(:SEX)))
  10 - filter((:BLOCK_NUMBER IS NULL OR "BLOCK_NUMBER"=:BLOCK_NUMBER) AND 
              (:SEX IS NULL OR "SEX"=TO_NUMBER(:SEX)))
  12 - filter((:BLOCK_NUMBER IS NULL OR "BLOCK_NUMBER"=:BLOCK_NUMBER) AND 
              (:SEX IS NULL OR "SEX"=TO_NUMBER(:SEX)))
 
Hint Report (identified by operation id / Query Block Name / Object Alias):
Total hints for statement: 10 (U - Unused (10))
---------------------------------------------------------------------------
 
   4 -  SEL$F5BB74E1 / "QUERY4_MV"@"SEL$2"
         U -  INDEX(query4_mv query4_mv_block_number_idx)
         U -  INDEX(query4_mv query4_mv_sex_idx)
 
   6 -  SEL$07BDC5B4 / "QUERY4_MV"@"SEL$4"
         U -  INDEX(query4_mv query4_mv_block_number_idx)
         U -  INDEX(query4_mv query4_mv_sex_idx)
 
   8 -  SEL$ABDE6DFF / "QUERY4_MV"@"SEL$6"
         U -  INDEX(query4_mv query4_mv_block_number_idx)
         U -  INDEX(query4_mv query4_mv_sex_idx)
 
  10 -  SEL$8A3193DA / "QUERY4_MV"@"SEL$8"
         U -  INDEX(query4_mv query4_mv_block_number_idx)
         U -  INDEX(query4_mv query4_mv_sex_idx)
 
  12 -  SEL$0EE6DB63 / "QUERY4_MV"@"SEL$10"
         U -  INDEX(query4_mv query4_mv_block_number_idx)
         U -  INDEX(query4_mv query4_mv_sex_idx)
 
Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
  ```],
  [```
Plan hash value: 1298516637
 
----------------------------------------------------------------------------------------------
| Id  | Operation                        | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                 |           |     5 |   150 |  1570   (1)| 00:00:01 |
|   1 |  HASH UNIQUE                     |           |     5 |   150 |  1570   (1)| 00:00:01 |
|   2 |   UNION-ALL                      |           |       |       |            |          |
|   3 |    SORT AGGREGATE                |           |     1 |    30 |   314   (1)| 00:00:01 |
```#highlight[```
|*  4 |     MAT_VIEW ACCESS INMEMORY FULL| QUERY4_MV |   889 | 26670 |   313   (1)| 00:00:01 |
```]```
|   5 |    SORT AGGREGATE                |           |     1 |    30 |   314   (1)| 00:00:01 |
```#highlight[```
|*  6 |     MAT_VIEW ACCESS INMEMORY FULL| QUERY4_MV |   889 | 26670 |   313   (1)| 00:00:01 |
```]```
|   7 |    SORT AGGREGATE                |           |     1 |    30 |   314   (1)| 00:00:01 |
```#highlight[```
|*  8 |     MAT_VIEW ACCESS INMEMORY FULL| QUERY4_MV |   889 | 26670 |   313   (1)| 00:00:01 |
```]```
|   9 |    SORT AGGREGATE                |           |     1 |    30 |   314   (1)| 00:00:01 |
```#highlight[```
|* 10 |     MAT_VIEW ACCESS INMEMORY FULL| QUERY4_MV |   889 | 26670 |   313   (1)| 00:00:01 |
```]```
|  11 |    SORT AGGREGATE                |           |     1 |    30 |   314   (1)| 00:00:01 |
```#highlight[```
|* 12 |     MAT_VIEW ACCESS INMEMORY FULL| QUERY4_MV |   889 | 26670 |   313   (1)| 00:00:01 |
```]```
----------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   4 - inmemory((:BLOCK_NUMBER IS NULL OR "BLOCK_NUMBER"=:BLOCK_NUMBER) AND (:SEX IS 
              NULL OR "SEX"=TO_NUMBER(:SEX)))
       filter((:BLOCK_NUMBER IS NULL OR "BLOCK_NUMBER"=:BLOCK_NUMBER) AND (:SEX IS 
              NULL OR "SEX"=TO_NUMBER(:SEX)))
   6 - inmemory((:BLOCK_NUMBER IS NULL OR "BLOCK_NUMBER"=:BLOCK_NUMBER) AND (:SEX IS 
              NULL OR "SEX"=TO_NUMBER(:SEX)))
       filter((:BLOCK_NUMBER IS NULL OR "BLOCK_NUMBER"=:BLOCK_NUMBER) AND (:SEX IS 
              NULL OR "SEX"=TO_NUMBER(:SEX)))
   8 - inmemory((:BLOCK_NUMBER IS NULL OR "BLOCK_NUMBER"=:BLOCK_NUMBER) AND (:SEX IS 
              NULL OR "SEX"=TO_NUMBER(:SEX)))
       filter((:BLOCK_NUMBER IS NULL OR "BLOCK_NUMBER"=:BLOCK_NUMBER) AND (:SEX IS 
              NULL OR "SEX"=TO_NUMBER(:SEX)))
  10 - inmemory((:BLOCK_NUMBER IS NULL OR "BLOCK_NUMBER"=:BLOCK_NUMBER) AND (:SEX IS 
              NULL OR "SEX"=TO_NUMBER(:SEX)))
       filter((:BLOCK_NUMBER IS NULL OR "BLOCK_NUMBER"=:BLOCK_NUMBER) AND (:SEX IS 
              NULL OR "SEX"=TO_NUMBER(:SEX)))
  12 - inmemory((:BLOCK_NUMBER IS NULL OR "BLOCK_NUMBER"=:BLOCK_NUMBER) AND (:SEX IS 
              NULL OR "SEX"=TO_NUMBER(:SEX)))
       filter((:BLOCK_NUMBER IS NULL OR "BLOCK_NUMBER"=:BLOCK_NUMBER) AND (:SEX IS 
              NULL OR "SEX"=TO_NUMBER(:SEX)))
 
Hint Report (identified by operation id / Query Block Name / Object Alias):
Total hints for statement: 10 (U - Unused (10))
---------------------------------------------------------------------------
 
   4 -  SEL$F5BB74E1 / "QUERY4_MV"@"SEL$2"
         U -  INDEX(query4_mv query4_mv_block_number_idx)
         U -  INDEX(query4_mv query4_mv_sex_idx)
 
   6 -  SEL$07BDC5B4 / "QUERY4_MV"@"SEL$4"
         U -  INDEX(query4_mv query4_mv_block_number_idx)
         U -  INDEX(query4_mv query4_mv_sex_idx)
 
   8 -  SEL$ABDE6DFF / "QUERY4_MV"@"SEL$6"
         U -  INDEX(query4_mv query4_mv_block_number_idx)
         U -  INDEX(query4_mv query4_mv_sex_idx)
 
  10 -  SEL$8A3193DA / "QUERY4_MV"@"SEL$8"
         U -  INDEX(query4_mv query4_mv_block_number_idx)
         U -  INDEX(query4_mv query4_mv_sex_idx)
 
  12 -  SEL$0EE6DB63 / "QUERY4_MV"@"SEL$10"
         U -  INDEX(query4_mv query4_mv_block_number_idx)
         U -  INDEX(query4_mv query4_mv_sex_idx)
 
Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
  ```]
)

Jak widać, *koszt zapytania zmalał o ponad 95%*, jednakże nie odznaczyło się to mocno na czasie wykonania zapytania.

Istotną różnicę widać natomiast w porównaniu z `query4`, umieszczonym również w każdej tabeli, które jest odpowiednikiem zapytania `query4_mv`, bez wykorzystania widoku zmaterializowanego. W takim zestawieniu, *czas wykonania zapytania spada o 99%*, a jego *koszt spada ponad tysiąckrotnie*. Ta poprawa wraz ze znalezionym w trzeciej propozycji błędem, stanowi najciekawsze obserwacje z naszych badań.
