# Zaawansowane systemy baz danych (ZSBD)

<div align="center">
Zespół B5 (baza danych dla więzienia): <br/> <b>Tomasz Chojnacki (260365), Kamila Iwańska (253027), Jakub Zehner (260285)</b>
</div>

## Zadanie 9 - Składowanie kolumnowe

### Propozycja 1

Dodanie składowania kolumnowego na tabeli `prisoner`. Tabela ta używana jest w prawie każdym zapytaniu, co pozwoli nam na dobrą wstępną ocenę wpływu składowania kolumnowego na wydajność zapytań. W szczególności interesuje nas zapytanie `query4`, które korzysta bezpośrednio z tej tabeli, licząc średnią, odchylenie standardowe i wariancję dla wzrostu (`height_m`) oraz wagi (`weight_kg`) więźniów. Podejrzewamy, że wprowadzenie składowania kolumnowego pozwoli na efektywniejsze obliczenie tych statystyk, ponieważ są to funkcje agregacyjne, które [potrafią być znacznie szybsze w składowaniu kolumnowym](https://www.oracle.com/docs/tech/inmemory-aggregation-twp-2412192.pdf).

Poniżej znajdują się kluczowe z naszej perspektywy części zapytania `query4`:

```sql
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
```

```sql
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
```

### Propozycja 2

Zgodnie z wymaganiami, w nastepnej kolejności skupiliśmy się na próbie optymalizacji operacji CRUD. W tym celu odpowiednia wydała nam się tabela `guard`, wykorzystana m.in. w zapytaniu `change1`. Zapytanie to skupia się na edycji kolumny `dismissal_date`, dokonanej po selekcji rekordu na podstawie `employment_date`. Oracle DB wspiera [zoptymalizowane operacje na datach przechowywanych w pamięci](https://docs.oracle.com/en/database/oracle/oracle-database/23/nfcoa/data_analytics_in_memory.html#NFCOA-GUID-101546-3), w związku z tym podejrzewamy, że pozwoli to przyspieszyć zapytanie. Dodatkowo, wykorzystane są podzapytania `IN`/`NOT IN` na ID, więc gdyby udało się wykorzystać składowanie kolumnowe na tej kolumnie, skanowanie wartości powinno być szybsze.

Jako dodatkową, osobną próbę planujemy przetestować złączenie w pamięci do tabel `patrol` oraz `patrol_slot`, które są jedynymi innymi tabelami wykorzystanymi w tym zapytaniu oraz porównanie z wariantem bazowym (składowanie kolumnowe tabeli `guard`, ale bez złączenia w pamięci).

Poniżej znajdują się kluczowe z naszej perspektywy części zapytania `change1`:

```sql
update guard
   set
   dismissal_date = to_date(:now,
        'YYYY-MM-DD')
```

```sql
 where months_between(
      to_timestamp(:now,
                  'YYYY-MM-DD HH24:MI:SS'),
      guard.employment_date
   ) < :experience_months
```

```sql
   and id in (
   select guard.id
     from guard
```

### Propozycja 3

W trzeciej propozycji skupiliśmy się na wprowadzeniu składowania kolumnowego dla poszczególnych kolumn, zamiast całej tabeli oraz na zastosowaniu złączeń pamięciowych. Najbardziej odpowiednia do takiego testu jest naszym zdaniem kwerenda `query2`, licząca procent obłożenia cel w danym bloku przez więźniów spełniających pewne kryteria. W tym celu wykorzystane są agregacje `COUNT` na `reprimand.id` oraz `sentence.id`, które są dołączone do tabeli `prisoner` za pomocą kluczy obcych. Podobnie do propozycji 1, podejrzewamy, że składowanie kolumnowe może przyspieszyć te agregacje, a złączenia pamięciowe mogą przyspieszyć operacje `JOIN`. Planujemy wprowadzić składowanie kolumnowe dla kolumn `id` oraz `fk_prisoner` w tabelach `sentence` i `reprimand` oraz złączenie pamięciowe między `prisoner.id` a `reprimand.fk_prisoner` oraz `prisoner.id` a `sentence.fk_prisoner`.

Poniżej znajduje się kluczowa z naszej perspektywy część zapytania `query2`:

```sql
   select p.id as id,
          count(r.id) as reprimands,
          count(s.id) as sentences
     from prisoner p
     left join reprimand r
   on p.id = r.fk_prisoner
     left join sentence s
   on p.id = s.fk_prisoner
    group by p.id
```

### Eksperyment 1

W ramach eksperymentu postanowiliśmy porównać różne metody kompresji:
- `NO MEMCOMPRESS`
- `MEMCOMPRESS FOR DML`
- `MEMCOMPRESS FOR QUERY LOW` – [domyślna](https://blogs.oracle.com/in-memory/post/database-in-memory-compression)
- `MEMCOMPRESS FOR QUERY HIGH`
- `MEMCOMPRESS FOR CAPACITY LOW`
- `MEMCOMPRESS FOR CAPACITY HIGH`

Planujemy zbadać pamięć wykorzystaną przy każdej z tych metod oraz szybkość wykonywania wszystkich kwerend. Eksperyment planujemy przeprowadzić na tabeli `prisoner`, która zgodnie z Propozycją 1 jest najczęściej wykorzystywaną tabelą w zapytaniach.

### Eksperyment 2

Oracle DB wspiera wykorzystanie [składowania kolumnowego na widokach zmaterializowanych](https://docs.oracle.com/en/database/oracle/oracle-database/21/inmem/populating-objects-in-memory.html#INMEM-GUID-64B4046F-C3E3-49EB-928E-6502AA58EF4A). Jednocześnie w ramach eksperymentu wykonanego przy indeksach, przygotowaliśmy uprzednio widok zmaterializowany podzapytania z `query4`, który wykorzystujemy w nowym wariancie zapytania nazwanym `query4_mv`. Widok ten możemy teraz składować kolumnowo oraz porównać koszt i czas wykonania zapytania `query4_mv` z oraz bez składowania kolumnowego.

Poniżej znajduje się fragment utworzenia widoku oraz kluczowa z naszej perspektywy część zapytania `query4_mv`:

```sql
create materialized view query4_mv
   build immediate
   refresh
         complete
         on demand
disable query rewrite as
```

```sql
   select weight
     from query4_mv
    where ( :block_number is null
       or block_number = :block_number )
      and ( :sex is null
       or sex = :sex )
```
