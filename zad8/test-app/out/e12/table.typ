#let r(n) = text(fill: rgb("#880000"), n)
#let g(n) = text(fill: rgb("#008800"), n)
#table(
  columns: 7,
  align: right + horizon,
  fill: (x, y) => if y in (0, 1, 9) { rgb("#cce") } else if calc.rem(y, 2) == 0 { rgb("#f0f0ff") },
  table.cell(rowspan: 2, colspan: 1)[*Nazwa*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*],
  [*Nowy*], [*Zmiana*], [*`query1`*], [1 143.58], [1 118.72], [#g("-24.86")], [1 746],
  [1 746], [0], [*`query2`*], [1 701.09], [1 709.96], [#r("+8.87")], [9 834],
  [9 834], [0], [*`query3`*], [2 148.41], [2 135.88], [#g("-12.53")], [11 117],
  [11 117], [0], [*`query4`*], [13 460.99], [13 402.89], [#g("-58.10")], [98 504],
  [98 504], [0], [*`change1`*], [7 442.11], [7 411.41], [#g("-30.70")], [29 726],
  [29 726], [0], [*`change3`*], [1 214.87], [1 206.51], [#g("-8.36")], [3 954],
  [3 888], [#g("-66")], [*`change4`*], [406.13], [396.00], [#g("-10.13")], [2 474],
  [2 474], [0], [*Suma*], [*27 517.18*], [*27 381.36*], [*#g("-135.82")*], table.cell(rowspan: 1, colspan: 3)[—],
  
)
