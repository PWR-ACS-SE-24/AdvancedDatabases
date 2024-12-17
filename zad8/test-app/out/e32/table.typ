#let r(n) = text(fill: rgb("#880000"), n)
#let g(n) = text(fill: rgb("#008800"), n)
#table(
  columns: 7,
  align: right + horizon,
  fill: (x, y) => if y in (0, 1, 9) { rgb("#cce") } else if calc.rem(y, 2) == 0 { rgb("#f0f0ff") },
  table.cell(rowspan: 2, colspan: 1)[*Nazwa*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*],
  [*Nowy*], [*Zmiana*], [*`query1`*], [1 143.58], [1 146.88], [#r("+3.30")], [1 746],
  [1 746], [0], [*`query2`*], [1 701.09], [1 677.36], [#g("-23.73")], [9 834],
  [9 834], [0], [*`query3`*], [2 148.41], [2 408.76], [#r("+260.35")], [11 117],
  [11 396], [#r("+279")], [*`query4`*], [13 460.99], [13 506.01], [#r("+45.02")], [98 504],
  [98 504], [0], [*`change1`*], [7 442.11], [7 361.75], [#g("-80.36")], [29 726],
  [29 726], [0], [*`change3`*], [1 214.87], [1 215.39], [#r("+0.52")], [3 954],
  [3 954], [0], [*`change4`*], [406.13], [405.87], [#g("-0.27")], [2 474],
  [2 474], [0], [*Suma*], [*27 517.18*], [*27 722.01*], [*#r("+204.83")*], table.cell(rowspan: 1, colspan: 3)[—],
  
)
