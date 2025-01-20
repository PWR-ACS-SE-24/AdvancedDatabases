#let r(n) = text(fill: rgb("#880000"), n)
#let g(n) = text(fill: rgb("#008800"), n)
#table(
  columns: 7,
  align: right + horizon,
  fill: (x, y) => if y in (0, 1, 9) { rgb("#cce") } else if calc.rem(y, 2) == 0 { rgb("#f0f0ff") },
  table.cell(rowspan: 2, colspan: 1)[*Nazwa*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*],
  [*Nowy*], [*Zmiana*], [*`query1`*], [1 256.90], [1 248.07], [#g("-8.83")], [1 746],
  [1 746], [0], [*`query2`*], [1 696.15], [1 653.70], [#g("-42.45")], [9 835],
  [9 835], [0], [*`query3`*], [2 334.61], [2 332.73], [#g("-1.87")], [11 119],
  [11 119], [0], [*`query4`*], [14 758.86], [14 713.55], [#g("-45.31")], [98 509],
  [98 509], [0], [*`query4mv`*], [802.10], [817.92], [#r("+15.82")], [9 784],
  [9 784], [0], [*`change1`*], [7 863.28], [7 859.21], [#g("-4.07")], [29 726],
  [29 726], [0], [*`change3`*], [1 308.54], [1 291.53], [#g("-17.01")], [3 955],
  [3 955], [0], [*`change4`*], [548.04], [401.82], [#g("-146.23")], [2 474],
  [2 474], [0], [*Suma*], [*30 568.48*], [*30 318.54*], [*#g("-249.94")*], table.cell(rowspan: 1, colspan: 3)[—],
  
)
