#let r(n) = text(fill: rgb("#880000"), n)
#let g(n) = text(fill: rgb("#008800"), n)
#table(
  columns: 7,
  align: right + horizon,
  fill: (x, y) => if y in (0, 1, 9) { rgb("#cce") } else if calc.rem(y, 2) == 0 { rgb("#f0f0ff") },
  table.cell(rowspan: 2, colspan: 1)[*Nazwa*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*],
  [*Nowy*], [*Zmiana*], [*`query1`*], [1 143.58], [1 138.00], [#g("-5.58")], [1 746],
  [1 746], [0], [*`query2`*], [1 701.09], [1 705.23], [#r("+4.14")], [9 834],
  [9 834], [0], [*`query3`*], [2 148.41], [2 112.13], [#g("-36.28")], [11 117],
  [11 117], [0], [*`query4`*], [13 460.99], [13 362.73], [#g("-98.25")], [98 504],
  [98 504], [0], [*`change1`*], [7 442.11], [6 687.89], [#g("-754.22")], [29 726],
  [28 826], [#g("-900")], [*`change3`*], [1 214.87], [1 205.43], [#g("-9.45")], [3 954],
  [3 609], [#g("-345")], [*`change4`*], [406.13], [392.97], [#g("-13.16")], [2 474],
  [2 142], [#g("-332")], [*Suma*], [*27 517.18*], [*26 604.38*], [*#g("-912.80")*], table.cell(rowspan: 1, colspan: 3)[—],
  
)
