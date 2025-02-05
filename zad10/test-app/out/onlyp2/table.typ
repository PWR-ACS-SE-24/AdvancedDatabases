#let r(n) = text(fill: rgb("#880000"), n)
#let g(n) = text(fill: rgb("#008800"), n)
#table(
  columns: 7,
  align: right + horizon,
  fill: (x, y) => if y in (0, 1, 9) { rgb("#cce") } else if calc.rem(y, 2) == 0 { rgb("#f0f0ff") },
  table.cell(rowspan: 2, colspan: 1)[*Nazwa*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*],
  [*Nowy*], [*Zmiana*], [*`query1`*], [1 256.90], [1 285.86], [#r("+28.96")], [1 746],
  [809], [#g("-937")], [*`query2`*], [1 696.15], [1 676.96], [#g("-19.18")], [9 835],
  [9 835], [0], [*`query3`*], [2 334.61], [2 345.58], [#r("+10.97")], [11 119],
  [11 119], [0], [*`query4`*], [14 758.86], [14 614.05], [#g("-144.82")], [98 509],
  [98 509], [0], [*`query4mv`*], [802.10], [839.66], [#r("+37.56")], [9 784],
  [9 784], [0], [*`change1`*], [7 863.28], [7 864.79], [#r("+1.51")], [29 726],
  [29 698], [#g("-28")], [*`change3`*], [1 308.54], [1 306.97], [#g("-1.56")], [3 955],
  [3 955], [0], [*`change4`*], [548.04], [431.55], [#g("-116.49")], [2 474],
  [2 474], [0], [*Suma*], [*30 568.48*], [*30 365.43*], [*#g("-203.05")*], table.cell(rowspan: 1, colspan: 3)[—],
  
)
