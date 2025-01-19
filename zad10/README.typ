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

// 13.89 MB (megabytes) - inmemory (domyślna kompresja)
// 17.83 MB (megabytes) - na dysku

== Propozycja 2

=== Bez złączenia pamięciowego

=== Ze złączeniem pamięciowym

== Propozycja 3

// CIEKAWY WNIOSEK

=== Ze złączeniem na `reprimand`

=== Ze złączeniem na `prisoner`

== Eksperyment 1

=== `NO MEMCOMPRESS`

=== `MEMCOMPRESS FOR DML`

=== `MEMCOMPRESS FOR QUERY LOW` (domyślne)

=== `MEMCOMPRESS FOR QUERY HIGH`

=== `MEMCOMPRESS FOR CAPACITY LOW`

=== `MEMCOMPRESS FOR CAPACITY HIGH`

== Eksperyment 2
