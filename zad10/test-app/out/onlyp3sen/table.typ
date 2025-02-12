#let r(n) = text(fill: rgb("#880000"), n)
#let g(n) = text(fill: rgb("#008800"), n)
#table(
  columns: 7,
  align: right + horizon,
  fill: (x, y) => if y in (0, 1, 9) { rgb("#cce") } else if calc.rem(y, 2) == 0 { rgb("#f0f0ff") },
  table.cell(rowspan: 2, colspan: 1)[*Nazwa*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*],
  [*Nowy*], [*Zmiana*], [*`query1`*], [1 256.90], [1 261.00], [#r("+4.10")], [1 746],
  [1 746], [0], [*`query2`*], [1 696.15], [1 670.68], [#g("-25.47")], [9 835],
  [9 835], [0], [*`query3`*], [2 334.61], [2 347.60], [#r("+12.99")], [11 119],
  [11 119], [0], [*`query4`*], [14 758.86], [14 763.03], [#r("+4.17")], [98 509],
  [98 509], [0], [*`query4mv`*], [802.10], [831.41], [#r("+29.31")], [9 784],
  [9 784], [0], [*`change1`*], [7 863.28], [7 838.46], [#g("-24.82")], [29 726],
  [29 726], [0], [*`change3`*], [1 308.54], [1 293.84], [#g("-14.70")], [3 955],
  [3 955], [0], [*`change4`*], [548.04], [403.93], [#g("-144.11")], [2 474],
  [2 474], [0], [*Suma*], [*30 568.48*], [*30 409.95*], [*#g("-158.53")*], table.cell(rowspan: 1, colspan: 3)[—],
  
)
