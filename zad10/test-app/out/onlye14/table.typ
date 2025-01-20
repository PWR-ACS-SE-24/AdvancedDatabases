#let r(n) = text(fill: rgb("#880000"), n)
#let g(n) = text(fill: rgb("#008800"), n)
#table(
  columns: 7,
  align: right + horizon,
  fill: (x, y) => if y in (0, 1, 9) { rgb("#cce") } else if calc.rem(y, 2) == 0 { rgb("#f0f0ff") },
  table.cell(rowspan: 2, colspan: 1)[*Nazwa*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*],
  [*Nowy*], [*Zmiana*], [*`query1`*], [1 256.90], [1 224.70], [#g("-32.20")], [1 746],
  [1 746], [0], [*`query2`*], [1 696.15], [1 606.25], [#g("-89.89")], [9 835],
  [8 604], [#g("-1 231")], [*`query3`*], [2 334.61], [2 443.30], [#r("+108.69")], [11 119],
  [9 818], [#g("-1 301")], [*`query4`*], [14 758.86], [14 696.66], [#g("-62.20")], [98 509],
  [95 440], [#g("-3 069")], [*`query4mv`*], [802.10], [811.40], [#r("+9.29")], [9 784],
  [9 784], [0], [*`change1`*], [7 863.28], [7 827.20], [#g("-36.08")], [29 726],
  [29 726], [0], [*`change3`*], [1 308.54], [1 309.41], [#r("+0.87")], [3 955],
  [3 883], [#g("-72")], [*`change4`*], [548.04], [420.17], [#g("-127.87")], [2 474],
  [2 474], [0], [*Suma*], [*30 568.48*], [*30 339.09*], [*#g("-229.39")*], table.cell(rowspan: 1, colspan: 3)[—],
  
)
