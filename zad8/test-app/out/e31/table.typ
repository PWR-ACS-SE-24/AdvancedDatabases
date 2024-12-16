#let r(n) = text(fill: rgb("#880000"), n)
#let g(n) = text(fill: rgb("#008800"), n)
#table(
  columns: 7,
  align: right + horizon,
  fill: (x, y) => if y in (0, 1, 9) { rgb("#cce") } else if calc.rem(y, 2) == 0 { rgb("#f0f0ff") },
  table.cell(rowspan: 2, colspan: 1)[*Nazwa*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*],
  [*Nowy*], [*Zmiana*], [*`query1`*], [1 303.05], [1 238.11], [#g("-64.95")], [1 746],
  [1 746], [0], [*`query2`*], [2 007.88], [1 893.85], [#g("-114.03")], [9 834],
  [9 834], [0], [*`query3`*], [2 586.21], [360.57], [#g("-2 225.64")], [11 117],
  [8 512], [#g("-2 605")], [*`query4`*], [14 801.55], [14 895.06], [#r("+93.51")], [98 504],
  [98 504], [0], [*`change1`*], [8 254.11], [8 293.89], [#r("+39.78")], [29 726],
  [29 726], [0], [*`change3`*], [1 364.36], [1 358.57], [#g("-5.80")], [3 954],
  [3 954], [0], [*`change4`*], [459.79], [428.69], [#g("-31.10")], [2 474],
  [2 474], [0], [*Suma*], [*30 776.94*], [*28 468.73*], [*#g("-2 308.22")*], table.cell(rowspan: 1, colspan: 3)[—],
  
)
