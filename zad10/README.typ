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
TODO

*`query3`:*
TODO

*`query4`:*
TODO

Udało się zgodnie z planem usprawnić kwerendę `query4`, a dodatkowo znacząco zmalał koszt kwerend `query2` i `query3`. Czas wykonywania zapytań praktycznie się nie zmienił, jedyne sensowne różnice można zauważyć w przypadku `query2`, jednakże jest to zmiana mniejsza niż dla `change4`, którego plan w ogóle się nie zmienił.

== Propozycja 2

Propozycja 2 polegała na zastosowaniu składowania kolumnowego na całej tabeli `guard`, wykorzystywanej m.in. w zapytaniu `change1`. Ponadto, jako podeksperyment zawarty w drugiej podsekcji tego rozdziału, dodaliśmy złączenie pamięciowe do tabeli `patrol` oraz `patrol_slot` licząc na dodatkową poprawę wydajności zapytań.

Wykorzystana dla tabeli `guard` pamięć (w obu przypadkach):
- 0.78 MB - na dysku
- *1.31 MB* - składowanie kolumnowe (domyślna kompresja)

=== P2 -- Bez złączenia pamięciowego

```sql
alter table guard inmemory priority critical;
```

#align(center, include("./test-app/out/onlyp2/table.typ"))

*`query1:`*
TODO

=== P2 -- Ze złączeniem pamięciowym

```sql
alter table guard inmemory priority critical;
create inmemory join group p2_guard_patrol_join_group ( guard ( id ),patrol ( fk_guard ) );
create inmemory join group p2_patrol_patrol_slot_join_group ( patrol ( fk_patrol_slot ),patrol_slot ( id ) );
```

#align(center, include("./test-app/out/onlyp2group/table.typ"))

*`query1:`*
TODO

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

=== `NO MEMCOMPRESS`

```sql
alter table prisoner inmemory priority critical no memcompress;
```

Wykorzystana dla tabeli `prisoner` pamięć:
- 17.83 MB - na dysku
- *15.14 MB* - składowanie kolumnowe (`NO MEMCOMPRESS`)

#align(center, include("./test-app/out/onlye11/table.typ"))

=== `MEMCOMPRESS FOR DML`

```sql
alter table prisoner inmemory priority critical memcompress for dml;
```

Wykorzystana dla tabeli `prisoner` pamięć:
- 17.83 MB - na dysku
- *15.14 MB* - składowanie kolumnowe (`MEMCOMPRESS FOR DML`)

#align(center, include("./test-app/out/onlye12/table.typ"))

=== `MEMCOMPRESS FOR QUERY LOW` (domyślne)

```sql
alter table prisoner inmemory priority critical memcompress for query low;
```

Wykorzystana dla tabeli `prisoner` pamięć:
- 17.83 MB - na dysku
- *13.89 MB* - składowanie kolumnowe (`MEMCOMPRESS FOR QUERY LOW`)

#align(center, include("./test-app/out/onlye13/table.typ"))

=== `MEMCOMPRESS FOR QUERY HIGH`

```sql
alter table prisoner inmemory priority critical memcompress for query high;
```

Wykorzystana dla tabeli `prisoner` pamięć:
- 17.83 MB - na dysku
- *7.60 MB* - składowanie kolumnowe (`MEMCOMPRESS FOR QUERY HIGH`)

#align(center, include("./test-app/out/onlye14/table.typ"))

=== `MEMCOMPRESS FOR CAPACITY LOW`

```sql
alter table prisoner inmemory priority critical memcompress for capacity low;
```

Wykorzystana dla tabeli `prisoner` pamięć:
- 17.83 MB - na dysku
- *6.55 MB* - składowanie kolumnowe (`MEMCOMPRESS FOR CAPACITY LOW`)

#align(center, include("./test-app/out/onlye15/table.typ"))

=== `MEMCOMPRESS FOR CAPACITY HIGH`

```sql
alter table prisoner inmemory priority critical memcompress for capacity high;
```

Wykorzystana dla tabeli `prisoner` pamięć:
- 17.83 MB - na dysku
- *5.51 MB* - składowanie kolumnowe (`MEMCOMPRESS FOR CAPACITY HIGH`)

#align(center, include("./test-app/out/onlye16/table.typ"))

=== Podsumowanie

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

// I think it's also worth mentioning that compression numbers for NO MEMCOMPRESS and MEMCOMPRESS FOR DML are basically the same. That's because MEMCOMPRESS FOR DML is optimized for DML operations and performs little or no data compression. In practice, it will only provide compression if all of the column values are the same.
// 

== Eksperyment 2

// query4_mv
// 5.505 MB (megabytes) - inmemory
// 9.437 MB (megabytes) - na dysku

// porównanie z indeksami?
