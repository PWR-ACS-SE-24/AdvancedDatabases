#let r(n) = text(fill: rgb("#880000"), n)
#let g(n) = text(fill: rgb("#008800"), n)
#table(
  columns: 7,
  align: right + horizon,
  fill: (x, y) => if y in (0, 1, 9) { rgb("#cce") } else if calc.rem(y, 2) == 0 { rgb("#f0f0ff") },
  table.cell(rowspan: 2, colspan: 1)[*Nazwa*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*],
  [*Nowy*], [*Zmiana*], [*`query1`*], [1 143.58], [1 133.53], [#g("-10.04")], [1 746],
  [1 746], [0], [*`query2`*], [1 701.09], [1 695.82], [#g("-5.27")], [9 834],
  [9 834], [0], [*`query3`*], [2 148.41], [2 113.96], [#g("-34.45")], [11 117],
  [11 117], [0], [*`query4`*], [13 460.99], [13 374.84], [#g("-86.15")], [98 504],
  [98 504], [0], [*`change1`*], [7 442.11], [7 385.99], [#g("-56.12")], [29 726],
  [29 726], [0], [*`change3`*], [1 214.87], [1 211.28], [#g("-3.59")], [3 954],
  [3 637], [#g("-317")], [*`change4`*], [406.13], [393.32], [#g("-12.82")], [2 474],
  [2 474], [0], [*Suma*], [*27 517.18*], [*27 308.74*], [*#g("-208.44")*], table.cell(rowspan: 1, colspan: 3)[—],
  
)
