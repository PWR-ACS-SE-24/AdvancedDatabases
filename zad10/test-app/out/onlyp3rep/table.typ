#let r(n) = text(fill: rgb("#880000"), n)
#let g(n) = text(fill: rgb("#008800"), n)
#table(
  columns: 7,
  align: right + horizon,
  fill: (x, y) => if y in (0, 1, 9) { rgb("#cce") } else if calc.rem(y, 2) == 0 { rgb("#f0f0ff") },
  table.cell(rowspan: 2, colspan: 1)[*Nazwa*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*],
  [*Nowy*], [*Zmiana*], [*`query1`*], [1 256.90], [1 270.81], [#r("+13.91")], [1 746],
  [1 746], [0], [*`query2`*], [1 696.15], [1 694.96], [#g("-1.18")], [9 835],
  [9 835], [0], [*`query3`*], [2 334.61], [2 322.62], [#g("-11.99")], [11 119],
  [11 119], [0], [*`query4`*], [14 758.86], [14 780.41], [#r("+21.55")], [98 509],
  [98 509], [0], [*`query4mv`*], [802.10], [833.55], [#r("+31.44")], [9 784],
  [9 784], [0], [*`change1`*], [7 863.28], [7 849.86], [#g("-13.42")], [29 726],
  [29 726], [0], [*`change3`*], [1 308.54], [1 299.00], [#g("-9.54")], [3 955],
  [3 955], [0], [*`change4`*], [548.04], [399.16], [#g("-148.88")], [2 474],
  [2 474], [0], [*Suma*], [*30 568.48*], [*30 450.37*], [*#g("-118.11")*], table.cell(rowspan: 1, colspan: 3)[—],
  
)
