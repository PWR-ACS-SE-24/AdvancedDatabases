#let r(n) = text(fill: rgb("#880000"), n)
#let g(n) = text(fill: rgb("#008800"), n)
#table(
  columns: 7,
  align: right + horizon,
  fill: (x, y) => if y in (0, 1, 9) { rgb("#cce") } else if calc.rem(y, 2) == 0 { rgb("#f0f0ff") },
  table.cell(rowspan: 2, colspan: 1)[*Nazwa*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*],
  [*Nowy*], [*Zmiana*], [*`query1`*], [1 143.58], [1 118.62], [#g("-24.96")], [1 746],
  [1 746], [0], [*`query2`*], [1 701.09], [1 700.07], [#g("-1.02")], [9 834],
  [9 834], [0], [*`query3`*], [2 148.41], [2 133.55], [#g("-14.86")], [11 117],
  [11 117], [0], [*`query4`*], [13 460.99], [13 398.28], [#g("-62.71")], [98 504],
  [98 504], [0], [*`change1`*], [7 442.11], [7 366.46], [#g("-75.65")], [29 726],
  [29 726], [0], [*`change3`*], [1 214.87], [1 206.29], [#g("-8.58")], [3 954],
  [3 609], [#g("-345")], [*`change4`*], [406.13], [386.27], [#g("-19.87")], [2 474],
  [2 142], [#g("-332")], [*Suma*], [*27 517.18*], [*27 309.53*], [*#g("-207.65")*], table.cell(rowspan: 1, colspan: 3)[—],
  
)
