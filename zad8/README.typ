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
#let diff(n) = if n == 0 { [#n] } else if n > 0 { text(fill: rgb("#880000"))[+#n] } else { text(fill: rgb("#008800"))[-#calc.abs(n)] }

#align(center)[
  #text(size: 20pt, weight: "bold", )[Zaawansowane systemy baz danych (ZSBD)]

  Zespół B5 (baza danych dla więzienia): \
  *Tomasz Chojnacki (260365), Kamila Iwańska (253027), Jakub Zehner (260285)*
]

= Zadanie 8 - Indeksy (część II)

Workload był wykonany każdorazowo *10 razy*.

#table(
  columns: 7,
  align: right + horizon,
  table.cell(rowspan: 2, colspan: 1)[*Name*], table.cell(rowspan: 1, colspan: 3)[*Czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*], [*Nowy*], [*Zmiana*], [*`query1`*], [854.01], [1036.12], [#diff(182.11)], [1697], [1668], [#diff(-29)], [*`query2`*], [1422.65], [1435.35], [#diff(12.69)], [8524], [8487], [#diff(-37)], [*`query3`*], [1990.81], [2370.48], [#diff(379.67)], [9649], [9649], [#diff(0)], [*`query4`*], [26047.93], [23668.53], [#diff(-2379.40)], [85687], [85555], [#diff(-132)], [*`change1`*], [8212.77], [9338.22], [#diff(1125.45)], [21796], [21796], [#diff(0)], [*`change3`*], [929.47], [1514.63], [#diff(585.16)], [3411], [3411], [#diff(0)], [*`change4`*], [297.66], [381.27], [#diff(83.61)], [2101], [2101], [#diff(0)]
)

#table(
  columns: 7,
  align: right + horizon,
  table.cell(rowspan: 2, colspan: 1)[*Name*], table.cell(rowspan: 1, colspan: 3)[*Czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*], [*Nowy*], [*Zmiana*], [*`query1`*], [854.01], [1115.04], [#diff(261.03)], [1697], [1697], [#diff(0)], [*`query2`*], [1422.65], [1300.81], [#diff(-121.84)], [8524], [8524], [#diff(0)], [*`query3`*], [1990.81], [2190.04], [#diff(199.23)], [9649], [9649], [#diff(0)], [*`query4`*], [26047.93], [23423.06], [#diff(-2624.87)], [85687], [85687], [#diff(0)], [*`change1`*], [8212.77], [7112.98], [#diff(-1099.79)], [21796], [21796], [#diff(0)], [*`change3`*], [929.47], [1001.79], [#diff(72.32)], [3411], [3351], [#diff(-60)], [*`change4`*], [297.66], [257.04], [#diff(-40.62)], [2101], [2101], [#diff(0)]
)
