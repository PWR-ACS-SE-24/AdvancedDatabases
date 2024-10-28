# Zaawansowane systemy baz danych (ZSBD)

<div align="center">
Zespół B5 (baza danych dla więzienia): <br/> <b>Tomasz Chojnacki (260365), Kamila Iwańska (253027), Jakub Zehner (260285)</b>
</div>

## Zadanie 3 - Baza danych

### System zarządzania bazą danych
Do realizacji zadania wybrano Oracle 21c Express Edition. Utworzono konto z danymi logowania `system` / `password` oraz połączono się z domyślną bazą danych. Dokonano połączenia z serwisem `XEPDB1` na porcie `1521`.

### Schemat bazy danych
Utworzono tabele zgodnie z diagramem przygotowanym w etapie 1. Zmieniono typ `boolean` na `number(1)`, ponieważ ten pierwszy nie jest wspierany w naszej wersji SZBD. Dokonano małych zmian w nazewnictwie, wymuszonych przez wykorzystanie słów kluczowych Oracle SQL:
- tabela `block` zamieniona na `prison_block`
- pole `number` w tabeli `prison_block` zamienione na `block_number`
- pole `number` w tabeli `cell` zamienione na `cell_number`

```SQL
create table prisoner (
   id         integer generated always as identity,
   pesel      char(11) unique not null,
   first_name varchar(255) not null,
   last_name  varchar(255) not null,
   birthday   date not null,
   sex        integer not null, -- https://en.wikipedia.org/wiki/ISO/IEC_5218
   height_m   numeric(3,2) not null,
   weight_kg  numeric(3) not null,
   primary key ( id ),
   check ( length(pesel) = 11 ),
   check ( first_name <> '' ),
   check ( last_name <> '' ),
      check ( sex = 0 -- Not known
          or sex = 1 -- Male
          or sex = 2 -- Female
          or sex = 9 ), -- Not applicable
   check ( height_m > 0 ),
   check ( weight_kg > 0 )
);
```

```SQL
create table prison_block (
   id               integer generated always as identity,
   block_number     varchar(4) unique not null,
   shower_count     integer not null,
   additional_notes varchar(2000),
   primary key ( id ),
   check ( shower_count >= 0 ),
   check ( block_number <> '' )
);
```

```SQL
create table guard (
   id                   integer generated always as identity,
   first_name           varchar(255) not null,
   last_name            varchar(255) not null,
   employment_date      date not null,
   dismissal_date       date,
   has_disability_class number(1) not null,
   monthly_salary_pln   numeric(8,2) not null,
   primary key ( id ),
   check ( first_name <> '' ),
   check ( last_name <> '' ),
      check ( dismissal_date is null
          or dismissal_date >= employment_date ),
   check ( has_disability_class in ( 0,
                                     1 ) ),
   check ( monthly_salary_pln >= 0 )
);
```

```SQL
create table patrol_slot (
   id         integer generated always as identity,
   start_time timestamp not null,
   end_time   timestamp not null,
   primary key ( id ),
   check ( end_time > start_time )
);
```

```SQL
create table cell (
   id               integer generated always as identity,
   fk_block         integer not null,
   cell_number      integer not null,
   place_count      integer not null,
   is_solitary      number(1) not null,
   additional_notes varchar(2000),
   primary key ( id ),
   foreign key ( fk_block )
      references prison_block ( id ),
   check ( cell_number >= 1 ),
   check ( place_count >= 1 ),
   check ( is_solitary in ( 0,
                            1 ) ),
   check ( is_solitary = 0
       or place_count = 1 )
);
```

```SQL
create table accommodation (
   id          integer generated always as identity,
   fk_cell     integer not null,
   fk_prisoner integer not null,
   start_date  date not null,
   end_date    date,
   primary key ( id ),
   foreign key ( fk_cell )
      references cell ( id ),
   foreign key ( fk_prisoner )
      references prisoner ( id ),
      check ( end_date is null
          or end_date >= start_date )
);
```

```SQL
create table sentence (
   id               integer generated always as identity,
   fk_prisoner      integer not null,
   crime            varchar(1000) not null,
   start_date       date not null,
   planned_end_date date not null,
   real_end_date    date,
   primary key ( id ),
   foreign key ( fk_prisoner )
      references prisoner ( id ),
   check ( crime <> '' ),
   check ( planned_end_date >= start_date ),
      check ( real_end_date is null
          or real_end_date >= start_date )
);
```

```SQL
create table patrol (
   id             integer generated always as identity,
   fk_guard       integer not null,
   fk_block       integer not null,
   fk_patrol_slot integer not null,
   is_with_dog    number(1) not null,
   primary key ( id ),
   foreign key ( fk_guard )
      references guard ( id ),
   foreign key ( fk_block )
      references prison_block ( id ),
   foreign key ( fk_patrol_slot )
      references patrol_slot ( id ),
   check ( is_with_dog in ( 0,
                            1 ) )
);
```

```SQL
create table reprimand (
   id          integer generated always as identity,
   fk_guard    integer not null,
   fk_prisoner integer not null,
   reason      varchar(2000) not null,
   issue_date  date not null,
   primary key ( id ),
   foreign key ( fk_guard )
      references guard ( id ),
   foreign key ( fk_prisoner )
      references prisoner ( id ),
   check ( reason <> '' )
);
```

### Odzwierciedlone zależności

#### Powiązania
- `prisoner` ma liczbę `sentence` co najmniej 1, zgodną z rozkładem Poissona dla `λ = 1`
- istnieje 100 `prison_block` w więzieniu
- 10% `prison_block` nie ma cel, 10% `prison_block` zawiera tylko izolatki (w liczbie od 100 do 1000), pozostałe mają normalne cele (w liczbie od 1000 do 5000)
- każdy `prisoner` miał co najmniej 1 `accommodation`, może mieć więcej zgodnie z rozkładem Poissona dla `λ = 5`, wszystkie muszą mieć miejsce w czasie trwania przynajmniej jednej `sentence`; `prisoner`, który nadal odbywa karę ma aktywne `accommodation`; `accomodation` dla danego więźnia nie mogą się pokrywać w czasie; `prisoner` powinien w każdym momencie odbywania kary mieć aktywne `accommodation`
- każdy `cell` ma w dowolnym momencie w czasie co najwyżej tyle `accommodation`, ile wynosi `cell.place_count`
- `patrol` obsadza każdy `prison_block` dla każdego `patrol_slot`, za pomocą co najmniej jednego `guard` (liczba skorelowana z liczbą cel w bloku), który jest zatrudniony w czasie warty
- `prisoner` ma liczbę `reprimand`w trakcie wyroku zgodną z rozkładem Poissona dla `λ = 1` (włącznie z zerem)

#### Kolumny
- `prisoner.pesel` - spełnia reguły walidacji numerów PESEL, jest unikalny i zgodny z datą urodzenia i płcią więźnia
- `prisoner.first_name` - rzeczywiste imię odpowiadające płci więźnia
- `prisoner.last_name` - rzeczywiste nazwisko
- `prisoner.birthday` - data urodzenia dająca wiek więźnia z rozkładu jednostajnego w przedziale 17-90
- `prisoner.sex` - płeć zgodna ze standardem ISO IEC 5218 (90% osadzonych to mężczyźni)
- `prisoner.height_m` - wzrost zgodny z rozkładem normalnym dla danej płci
- `prisoner.weight_kg` - masa zgodna z rozkładem normalnym dla danej płci oraz skorelowany ze wzrostem (na podstawie BMI)
- `prison_block.number` - kolejne liczby porządkowe
- `prison_block.shower_count` - skorelowane z liczbą cel w bloku
- `prison_block.additional_notes` - opisuje zawartość bloku w zależności od liczby i rodzaju cel
- `guard.first_name` - rzeczywiste imię odpowiadające płci strażnika
- `guard.last_name` - rzeczywiste nazwisko
- `guard.employment_date` - data z przeszłości (od 2000 roku)
- `guard.dismissal_date` - jeżeli istnieje jest późniejsza niż data zatrudnienia, średni czas pracy to 5 lat zgodnie z rozkładem normalnym
- `guard.has_disability_class` - około 5% strażników ma niepełnosprawność (lekką)
- `guard.monthly_salary_pln` - wynagrodzenie strażnika uwzględnia inflację (5% rok do roku) oraz jest zależna od stażu pracy
- `patrol_slot.start_time`, `patrol_slot.end_time` - warty zaczynają się co godzinę (24 dziennie), prowadzimy ewidencję od 2000 roku
- `sentence.crime` - listą rzeczywistych przestępstw oddzielonych przecinkiem o liczności co najmniej 1, zgodnej z rozkładem Poissona dla `λ = 3` 
- `sentence.start_date` - datą z przeszłości (od 2000 roku), w której więzień miał co najmniej 17 lat
- `sentence.planned_end_date` - datą będącą powiększeniem `sentence.start_date` o długość skorelowaną z liczbą popełnionych przestępstw
- `sentence.real_end_date` - data znajdująca się w otoczeniu `sentence.planned_end_date` ale nie wcześniejsza niż `sentence.start_date`, zgodna z rozkładem normalnym
- `cell.cell_number` - kolejne liczby porządkowe
- `cell.place_count` - liczba miejsc w celi zgodna z rozkładem normalnym od 1 do 10 (za wyjątkiem `cell.is_solitary`, które mają jedno miejsce)
- `cell.additional_notes` - w 95% przypadków puste
- `accommodation.start_date` - data z zakresu odbywanych przez więźnia kar
- `accommodation.end_date` - data musi być późniejsza niż `accommodation.start_date` oraz kończyć się w zakresie trwania przynajmniej jednego `sentence`
- `patrol.is_with_dog` - około 50% wart nocnych, 25% wart dziennych odbywa z psem, wszystkie warty osób z niepełnosprawnościami są z psem (przewodnikiem)
- `reprimand.reason` - lista rzeczywistych powodów oddzielonych przecinkiem o liczności co najmniej 1, zgodnej z rozkładem Poissona dla `λ = 2`
- `reprimand.issue_date` - data z przeszłości zawarta w zakresie trwania jednego z wyroków więźnia oraz w okresie zatrudnienia strażnika

### Dokumentacja wolumetrii

| *Tabela* | *Liczba rekordów* |
| -------- | ----------------- |
TODO
