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

#align(center)[
  #text(size: 20pt, weight: "bold", )[Zaawansowane systemy baz danych (ZSBD)]

  Zespół B5 (baza danych dla więzienia): \
  *Tomasz Chojnacki (260365), Kamila Iwańska (253027), Jakub Zehner (260285)*
]

= Zadanie 10 - Składowanie kolumnowe (część II)

== Propozycja 1

// prisoner
// 13.89 MB (megabytes) - inmemory (domyślna kompresja)
// 17.83 MB (megabytes) - na dysku

== Propozycja 2

// guard
// 1.311 MB (megabytes) - inmemory (domyślna kompresja)
// 0.7864 MB (megabytes) - na dysku

=== Bez złączenia pamięciowego

=== Ze złączeniem pamięciowym

== Propozycja 3

// CIEKAWY WNIOSEK

=== Ze złączeniem na `reprimand`

=== Ze złączeniem na `prisoner`

== Eksperyment 1

=== `NO MEMCOMPRESS`

// prisoner
// 15.14 MB (megabytes) - inmemory
// 17.83 MB (megabytes) - na dysku

=== `MEMCOMPRESS FOR DML`

// prisoner
// 15.14 MB (megabytes) - inmemory
// 17.83 MB (megabytes) - na dysku

// I think it's also worth mentioning that compression numbers for NO MEMCOMPRESS and MEMCOMPRESS FOR DML are basically the same. That's because MEMCOMPRESS FOR DML is optimized for DML operations and performs little or no data compression. In practice, it will only provide compression if all of the column values are the same.
// https://blogs.oracle.com/in-memory/post/database-in-memory-compression

=== `MEMCOMPRESS FOR QUERY LOW` (domyślne)

// prisoner
// 13.89 MB (megabytes) - inmemory
// 17.83 MB (megabytes) - na dysku

=== `MEMCOMPRESS FOR QUERY HIGH`

// prisoner
// 7.602 MB (megabytes) - inmemory
// 17.83 MB (megabytes) - na dysku

=== `MEMCOMPRESS FOR CAPACITY LOW`

// prisoner
// 6.554 MB (megabytes) - inmemory
// 17.83 MB (megabytes) - na dysku

=== `MEMCOMPRESS FOR CAPACITY HIGH`

// prisoner
// 5.505 MB (megabytes) - inmemory
// 17.83 MB (megabytes) - na dysku

=== Podsumowanie

== Eksperyment 2

// query4_mv
// 5.505 MB (megabytes) - inmemory
// 9.437 MB (megabytes) - na dysku

// porównanie z indeksami?
