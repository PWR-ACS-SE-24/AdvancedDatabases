#let r(n) = text(fill: rgb("#880000"), n)
#let g(n) = text(fill: rgb("#008800"), n)
#table(
  columns: 7,
  align: right + horizon,
  fill: (x, y) => if y in (0, 1, 9) { rgb("#cce") } else if calc.rem(y, 2) == 0 { rgb("#f0f0ff") },
  table.cell(rowspan: 2, colspan: 1)[*Nazwa*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*],
  [*Nowy*], [*Zmiana*], [*`query1`*], [1 143.58], [1 126.87], [#g("-16.71")], [1 746],
  [1 716], [#g("-30")], [*`query2`*], [1 701.09], [1 737.25], [#r("+36.16")], [9 834],
  [9 736], [#g("-98")], [*`query3`*], [2 148.41], [2 131.77], [#g("-16.64")], [11 117],
  [11 117], [0], [*`query4`*], [13 460.99], [13 612.14], [#r("+151.16")], [98 504],
  [98 143], [#g("-361")], [*`change1`*], [7 442.11], [7 434.76], [#g("-7.36")], [29 726],
  [29 726], [0], [*`change3`*], [1 214.87], [1 214.82], [#g("-0.05")], [3 954],
  [3 954], [0], [*`change4`*], [406.13], [400.65], [#g("-5.49")], [2 474],
  [2 474], [0], [*Suma*], [*27 517.18*], [*27 658.25*], [*#r("+141.07")*], table.cell(rowspan: 1, colspan: 3)[—],
  
)
