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

#let indexprop(name, type, desc, code, planpart, planpred) =[
  #table(
    columns: 2,
    [*Nazwa*], [#name],
    [*Typ*], [#type],
    [*Cel*], [#desc],
    [*SQL*], [#code],
    [*Plan*], [
      #planpart
      #line(length: 100%)
      #planpred
    ]
  )
  #v(1cm)
]

#align(center)[
  #text(size: 20pt, weight: "bold", )[Zaawansowane systemy baz danych (ZSBD)]

  Zespół B5 (baza danych dla więzienia): \
  *Tomasz Chojnacki (260365), Kamila Iwańska (253027), Jakub Zehner (260285)*
]

= Zadanie 7 - Indeksy (część I)

== Propozycje indeksów

Propozycje indeksów są podzielone na podsekcje, z których każda zawiera bardzo podobne do siebie propozycje indeksów.

=== Indeksy b-drzewo dla danych czasowych

#indexprop(
  [
    - `patrol_slot_start_time_idx`
    - `patrol_slot_end_time_idx`
  ],
  "b-tree",
  [
    W `query1`, występuje kosztowne przeszukanie całej tabeli (`TABLE ACCESS FULL`) zawierającej `patrol_slot`. \ Powinien dobrze zadziałać indeks b-drzewo, który oprócz operacji porównań przyspiesza także nierówności oraz wyszukiwanie zakresów.
  ],
  [```sql
  from patrol_slot ps
 where ps.start_time >= to_timestamp(:start_time,
                'YYYY-MM-DD HH24:MI:SS')
   and ps.end_time <= to_timestamp(:end_time,
             'YYYY-MM-DD HH24:MI:SS');
  ```],
  [```
|* 14 |  TABLE ACCESS FULL                         | PATROL_SLOT                 |    68 |  1836 |    34   (3)| 00:00:01 |
```],
[```
14 - filter("PS"."START_TIME">=TO_TIMESTAMP(:START_TIME,'YYYY-MM-DD HH24:MI:SS') AND 
            "PS"."END_TIME"<=TO_TIMESTAMP(:END_TIME,'YYYY-MM-DD HH24:MI:SS'))
```]
)

#pagebreak()

#indexprop(
  [
    - `sentence_start_date_idx`
    - `sentence_real_end_date_idx`
  ],
  "b-tree",
  [
    W `query2`, występuje kosztowne przeszukanie całej tabeli (`TABLE ACCESS FULL`) zawierającej `patrol_slot`. \ Powinien dobrze zadziałać indeks b-drzewo, który oprócz operacji porównań przyspiesza także nierówności oraz wyszukiwanie zakresów.
  ],
  [```sql
   on p.id = s.fk_prisoner
    where s.start_date <= to_date(:now,
           'YYYY-MM-DD')
      and ( s.real_end_date is null
       or s.real_end_date >= to_date(:now,
        'YYYY-MM-DD') )
  ```],
  [```
|* 14 |               TABLE ACCESS FULL     | SENTENCE      |  8470 |   595K|       |  1216   (1)| 00:00:01 |
  ```],
  [```
14 - filter("S"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD') AND ("S"."REAL_END_DATE" IS NULL OR 
              "S"."REAL_END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD')))
  ```]
)

#indexprop(
  [
    - `accommodation_start_date_idx`
    - `accommodation_end_date_idx`
  ],
  "b-tree",
  [
    W `query2` i `query4`, występuje kosztowne przeszukanie całej tabeli (`TABLE ACCESS FULL`) zawierającej `patrol_slot`. \ Powinien dobrze zadziałać indeks b-drzewo, który oprócz operacji porównań przyspiesza także nierówności oraz wyszukiwanie zakresów.
  ],
  [
  `query2`:  
  ```sql
on p.id = ps.id
 where a.start_date <= to_date(:now,
           'YYYY-MM-DD')
   and ( a.end_date is null
    or a.end_date >= to_date(:now,
        'YYYY-MM-DD') )
  ```
  `query4` (poniższy fragment kodu jest powtórzony w kwerendzie jeszcze 3 razy):
  ```sql
      on a.fk_prisoner = p.id
       where a.start_date <= to_date(:now,
           'YYYY-MM-DD')
         and ( a.end_date is null
          or a.end_date >= to_date(:now,
        'YYYY-MM-DD') )
  ```
  ],
  [
    `query2`:
    ```
|* 27 |       TABLE ACCESS FULL             | ACCOMMODATION |  9279 |   235K|       |  1764   (2)| 00:00:01 |
    ```
    `query4`:
    ```
|* 18 |                TABLE ACCESS FULL| ACCOMMODATION |  9279 |   235K|       |  1764   (2)| 00:00:01 |
|* 41 |                TABLE ACCESS FULL| ACCOMMODATION |  9279 |   235K|       |  1764   (2)| 00:00:01 |
|* 64 |                TABLE ACCESS FULL| ACCOMMODATION |  9279 |   235K|       |  1764   (2)| 00:00:01 |
|* 87 |                TABLE ACCESS FULL| ACCOMMODATION |  9279 |   235K|       |  1764   (2)| 00:00:01 |
    ```
  ],
  [
    `query2`:
    ```
28 - filter("C"."IS_SOLITARY"=TO_NUMBER(:IS_IN_SOLITARY) OR :IS_IN_SOLITARY IS NULL)
    ```
    `query4`:
    ```
18 - filter("A"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD') AND ("A"."END_DATE" IS NULL OR 
            "A"."END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD')))
41 - filter("A"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD') AND ("A"."END_DATE" IS NULL OR 
            "A"."END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD')))
64 - filter("A"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD') AND ("A"."END_DATE" IS NULL OR 
            "A"."END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD')))
87 - filter("A"."START_DATE"<=TO_DATE(:NOW,'YYYY-MM-DD') AND ("A"."END_DATE" IS NULL OR 
            "A"."END_DATE">=TO_DATE(:NOW,'YYYY-MM-DD')))
    ```
    ]
)

#pagebreak()

=== Indeks bitmapowy dla rodzaju celi

#indexprop(
  `cell_is_solitary_idx`,
  "bitmap",
  [
        Każda cela w więzieniu jest lub nie jest izolatką, co jest oznaczone przez kolumnę `is_solitary` równą `0` lub `1`. Jednocześnie, w zapytaniu `change3`, chcemy znaleźć wolne izolatki, tak aby przypisać do nich więźniów. W tym przypadku mamy bardzo ograniczoną liczbę wartości oraz interesuje nas tylko równość, co sprawia, że indeks bitmapowy jest odpowiednią strukturą.
  ],
  [```sql
       where pb.block_number = :block_number
         and c.is_solitary = 1
         and c.id not in (
  ```],
  [```
|* 10 |         TABLE ACCESS FULL           | CELL          |    51 |   561 |   325   (1)| 00:00:01 |
  ```],
  [```
10 - filter("PB"."ID"="C"."FK_BLOCK" AND "C"."IS_SOLITARY"=1)
  ```]
)

=== Indeksy funkcyjne dla danych czasowych

#indexprop(
  `reprimand_issue_date_to_char_idx`,
  [functional (`to_char(issue_date, 'YYYY-MM-DD')`)],
  [
    W `query3` oraz `change3` występują porównania dat zamienionych na ciągi tekstowe z podanym parametrem. W tym przypadku, baza danych prawdopodobnie nie będzie w stanie zoptymalizować zapytania, pomimo utworzonych wcześniej indeksów dla zakresów czasowych, ponieważ kolumny te są najpierw transformowane funkcją `to_char`. Idealny będzie zatem indeks funkcyjny, zapisujący wynik tej funkcji.
  ],
  [
    `query3`:
    ```sql
on p.id = ps.id
 where to_char(
      r.issue_date,
      'YYYY-MM-DD'
   ) >= :start_date
   and to_char(
   r.issue_date,
   'YYYY-MM-DD'
)
    ```
    `change3`:
    ```sql
      on p.id = r.fk_prisoner
       where to_char(
         r.issue_date,
         'YYYY-MM-DD'
      )
    ```
  ],
  [
    `query3`:
    ```
|* 11 |            TABLE ACCESS FULL         | REPRIMAND     |    91 |  7462 |       |  1225   (1)| 00:00:01 |
    ```
    `change3`:
    ```
|* 20 |           TABLE ACCESS FULL         | REPRIMAND     |    91 |  6734 |  1225   (1)| 00:00:01 |
    ```
  ],
  [
    `query3`:
    ```
11 - filter((:EVENT_TYPE IS NULL OR INSTR("R"."REASON",:EVENT_TYPE)>0) AND 
            TO_CHAR(INTERNAL_FUNCTION("R"."ISSUE_DATE"),'YYYY-MM-DD')>=:START_DATE AND 
            TO_CHAR(INTERNAL_FUNCTION("R"."ISSUE_DATE"),'YYYY-MM-DD')<=:END_DATE)
    ```
    `change3`:
    ```
20 - filter((:EVENT_TYPE IS NULL OR INSTR("R"."REASON",:EVENT_TYPE)>0) AND 
            TO_CHAR(INTERNAL_FUNCTION("R"."ISSUE_DATE"),'YYYY-MM-DD')>=:START_DATE AND 
            TO_CHAR(INTERNAL_FUNCTION("R"."ISSUE_DATE"),'YYYY-MM-DD')<=:END_DATE)
    ```
  ]
)

#pagebreak()

#indexprop(
  [
    - `sentence_start_date_to_char_idx`
    - `sentence_real_end_date_to_char_idx`
  ],
  [functional (`to_char(start_date, 'YYYY-MM-DD')`, `to_char(real_end_date, 'YYYY-MM-DD')`)],
  [
    W `query3` występują porównania dat zamienionych na ciągi tekstowe z podanym parametrem. W tym przypadku, baza danych prawdopodobnie nie będzie w stanie zoptymalizować zapytania, pomimo utworzonych wcześniej indeksów dla zakresów czasowych, ponieważ kolumny te są najpierw transformowane funkcją `to_char`. Idealny będzie zatem indeks funkcyjny, zapisujący wynik tej funkcji.
  ],
  [```sql
   on p.id = s.fk_prisoner
    where to_char(
         s.start_date,
         'YYYY-MM-DD'
      ) <= :start_date
      and ( s.real_end_date is null
       or to_char(
      s.real_end_date,
      'YYYY-MM-DD'
   ) >= :end_date )
  ```],
  [```
|* 28 |            TABLE ACCESS FULL         | SENTENCE      |  8717 |   519K|       |  1216   (1)| 00:00:01 |
  ```],
  [```
28 - filter(TO_CHAR(INTERNAL_FUNCTION("S"."START_DATE"),'YYYY-MM-DD')<=:START_DATE AND 
        ("S"."REAL_END_DATE" IS NULL OR TO_CHAR(INTERNAL_FUNCTION("S"."REAL_END_DATE"),'YYYY-MM-DD')>=:END_DAT
        E))
  ```]
)

#indexprop(
  [
    - `accommodation_start_date_to_char_idx`
    - `accommodation_end_date_to_char_idx`
  ],
  [functional (`to_char(start_date, 'YYYY-MM-DD')`, `to_char(end_date, 'YYYY-MM-DD')`)],
  [
    W `query3` występują porównania dat zamienionych na ciągi tekstowe z podanym parametrem. W tym przypadku, baza danych prawdopodobnie nie będzie w stanie zoptymalizować zapytania, pomimo utworzonych wcześniej indeksów dla zakresów czasowych, ponieważ kolumny te są najpierw transformowane funkcją `to_char`. Idealny będzie zatem indeks funkcyjny, zapisujący wynik tej funkcji.
  ],
  [```sql
   on a.fk_prisoner = p.id
    where to_char(
         a.start_date,
         'YYYY-MM-DD'
      ) <= :start_date
      and ( a.end_date is null
       or to_char(
      a.end_date,
      'YYYY-MM-DD'
   ) >= :end_date )
  ```],
  [```
|* 30 |       TABLE ACCESS FULL              | ACCOMMODATION |  9577 |   243K|       |  1766   (2)| 00:00:01 |
  ```],
  [```
30 - filter(TO_CHAR(INTERNAL_FUNCTION("A"."START_DATE"),'YYYY-MM-DD')<=:START_DATE AND 
            ("A"."END_DATE" IS NULL OR TO_CHAR(INTERNAL_FUNCTION("A"."END_DATE"),'YYYY-MM-DD')>=:END_DATE))
  ```]
)

#indexprop(
  [
    - `patrol_slot_start_time_to_char_idx`
    - `patrol_slot_end_time_to_char_idx`
  ],
  [functional (`to_char(start_time, 'YYYY-MM-DD HH24:MI:SS')`, `to_char(end_time, 'YYYY-MM-DD HH24:MI:SS')`)],
  [
    W `change1` występują porównania dat zamienionych na ciągi tekstowe z podanym parametrem. W tym przypadku, baza danych prawdopodobnie nie będzie w stanie zoptymalizować zapytania, pomimo utworzonych wcześniej indeksów dla zakresów czasowych, ponieważ kolumny te są najpierw transformowane funkcją `to_char`. Idealny będzie zatem indeks funkcyjny, zapisujący wynik tej funkcji.
  ],
  [```sql
   on patrol.fk_block = prison_block.id
    where to_char(
         patrol_slot.start_time,
         'YYYY-MM-DD HH24:MI:SS'
      ) >= :start_time
      and to_char(
      patrol_slot.end_time,
      'YYYY-MM-DD HH24:MI:SS'
   ) <= :end_time
      and prison_block.block_number = :block_number
  ```],
  [```
|* 25 |           TABLE ACCESS FULL          | PATROL_SLOT                 |    68 |  1836 |    34   (3)| 00:00:01 |
  ```],
  [```
25 - filter(TO_CHAR(INTERNAL_FUNCTION("PATROL_SLOT"."START_TIME"),'YYYY-MM-DD HH24:MI:SS')>=:START_TIME 
            AND TO_CHAR(INTERNAL_FUNCTION("PATROL_SLOT"."END_TIME"),'YYYY-MM-DD HH24:MI:SS')<=:END_TIME)
  ```]
)

=== Indeksy złożone (b-drzewo) dla odwołań do wielu kolumn

#indexprop(
  `cell_fk_block_is_solitary_idx`,
  [composite b-tree (`(fk_block, is_solitary)`)],
  [
    W predykatach dla zapytań `change3` oraz `change4` występują selekcje na dwóch kolumnach połączone spójnikiem `AND`, w tym przypadku indeks złożony na obu kolumnach powinien przyspieszyć zapytanie.
  ],
  [
    `change3`:
    ```sql
      on pb.id = c.fk_block
       where pb.block_number = :block_number
         and c.is_solitary = 1
    ```
    `change4`:
    ```sql
   on c.fk_block = pb.id
    where pb.block_number = :block_number
      and c.is_solitary = 0;
    ```
  ],
  [
    `change3`:
    ```
|* 10 |         TABLE ACCESS FULL           | CELL          |    51 |   561 |   325   (1)| 00:00:01 |
    ```
    `change4`:
    ```
|*  7 |      TABLE ACCESS FULL          | CELL          |  2540 | 27940 |   325   (1)| 00:00:01 |
    ```
  ],
  [
    `change3`:
    ```
10 - filter("PB"."ID"="C"."FK_BLOCK" AND "C"."IS_SOLITARY"=1)
    ```
    `change4`:
    ```
7 - filter("C"."FK_BLOCK"="PB"."ID" AND "C"."IS_SOLITARY"=0)
    ```
  ]
)

#indexprop(
  `patrol_fk_guard_fk_block_idx`,
  [composite b-tree (`(fk_guard, fk_block)`)],
  [
    W predykatach dla zapytania `change1` występuje selekcja na dwóch kolumnach połączone spójnikiem `AND`, w tym przypadku indeks złożony na obu kolumnach powinien przyspieszyć zapytanie.
  ],
  [```sql
   select guard.id
     from guard
    inner join patrol
   on guard.id = patrol.fk_guard
    inner join patrol_slot
   on patrol.fk_patrol_slot = patrol_slot.id
    inner join prison_block
   on patrol.fk_block = prison_block.id
  ```],
  [```
|* 27 |         TABLE ACCESS BY INDEX ROWID  | PATROL                      |     1 |    13 |    14   (0)| 00:00:01 |
  ```],
  [```
27 - filter("PATROL"."FK_GUARD"="ID" AND "PATROL"."FK_BLOCK"="PRISON_BLOCK"."ID")
  ```]
)

=== Dodanie indeksów na kluczach obcych

W trakcie naszych badań dowiedzieliśmy się, że baza danych Oracle w przeciwieństwie do MySQL nie tworzy automatycznie indeksów dla kluczy obcych. W związku z tym, proponujemy stworzenie indeksów b-drzewo dla wszystkich kluczy obcych w tabelach, które są używane w zapytaniach oraz porównanie kosztów oraz czasów wykonania zapytań przed i po dodaniu indeksów.

== Propozycje eksperymentów

=== Eksperyment 1 -- porównanie indeksu b--tree, bitmapowego oraz złożonych dla `is_solitary`

Niestety w naszej bazie danych, kolumny, na których możnaby zastosować indeks bitmapowy zawierają jedynie dwie możliwe wartości, są to `cell.is_solitary`, `patrol.is_with_dog`, `prisoner.sex` oraz `guard.has_disability_class`.

Jednocześnie, według dokumentacji #footnote[https://docs.oracle.com/en/database/oracle/oracle-database/23/cncpt/indexes-and-index-organized-tables.html]

=== Eksperyment 2 -- dodawanie indeksów w `MATERIALIZED VIEW`

Kwerenda `query4` wykorzystuje kilkukrotnie to samo kosztowne podzapytanie w czterech segmentach, które są później połączone przez `UNION`. Mieliśmy problemy z wymyśleniem sposobu optymalizacji tego fragmentu z wykorzystaniem indeksów, ponieważ wszystkie selekcje i grupowania są stosowane na podzapytaniu, a nie kolumnach z tabel.

Możliwe jest jednak wyciągnięcie warunków tak, aby wewnętrzne podzapytanie korzystało tylko z parametru `:now`:, który ma oznaczać obecną datę. Następnie z tego podzapytania można *utworzyć `MATERIALIZED VIEW`*, który byłby odświeżany codziennie (`REFRESH COMPLETE ON DEMAND`). Wtedy, zamiast wykonywać to podzapytanie czterokrotnie przy każdym wywołaniu kwerendy, obliczymy jego wartość raz na dobę.

Opłacalność zastosowania tego widoku zależy od tego, jak często w rzeczywistym systemie będzie wykonywana kwerenda `query4`.

Następnie, wszystkie cztery wystąpienia tego podzapytania (zastąpionego widokiem) zawierają selekcję w zależności od jego kolumn, w związku z czym można utworzyć na nich *indeksy*. Warto sprawdzić, czy takie indeksy przyspieszą zapytanie.

Planujemy porównanie czasów i kosztów czterech wariantów:
- *podstawowy* (stan na etap 6),
- *wyciągnięcie podzapytania* (`WITH`),
- *widok* zmaterializowany (`MATERIALIZED VIEW`),
- *widok* zmaterializowany *+ indeksy*.

=== Eksperyment 3 -- porównanie indeksu z partycjonowaniem dla `issue_date`
