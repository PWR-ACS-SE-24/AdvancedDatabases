#let r(n) = text(fill: rgb("#880000"), n)
#let g(n) = text(fill: rgb("#008800"), n)
#table(
  columns: 7,
  align: right + horizon,
  fill: (x, y) => if y in (0, 1, 9) { rgb("#cce") } else if calc.rem(y, 2) == 0 { rgb("#f0f0ff") },
  table.cell(rowspan: 2, colspan: 1)[*Nazwa*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*],
  [*Nowy*], [*Zmiana*], [*`query1`*], [1 143.58], [1 134.17], [#g("-9.40")], [1 746],
  [1 746], [0], [*`query2`*], [1 701.09], [1 678.71], [#g("-22.38")], [9 834],
  [9 834], [0], [*`query3`*], [2 148.41], [351.32], [#g("-1 797.09")], [11 117],
  [11 412], [#r("+295")], [*`query4`*], [13 460.99], [13 558.35], [#r("+97.36")], [98 504],
  [98 504], [0], [*`change1`*], [7 442.11], [7 368.06], [#g("-74.06")], [29 726],
  [29 726], [0], [*`change3`*], [1 214.87], [1 223.12], [#r("+8.25")], [3 954],
  [3 954], [0], [*`change4`*], [406.13], [410.65], [#r("+4.52")], [2 474],
  [2 474], [0], [*Suma*], [*27 517.18*], [*25 724.37*], [*#g("-1 792.81")*], table.cell(rowspan: 1, colspan: 3)[—],
  
)
