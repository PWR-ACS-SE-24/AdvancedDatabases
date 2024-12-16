#let r(n) = text(fill: rgb("#880000"), n)
#let g(n) = text(fill: rgb("#008800"), n)
#table(
  columns: 7,
  align: right + horizon,
  fill: (x, y) => if y in (0, 1, 9) { rgb("#cce") } else if calc.rem(y, 2) == 0 { rgb("#f0f0ff") },
  table.cell(rowspan: 2, colspan: 1)[*Nazwa*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*],
  [*Nowy*], [*Zmiana*], [*`query1`*], [1 303.05], [1 289.94], [#g("-13.11")], [1 746],
  [1 746], [0], [*`query2`*], [2 007.88], [2 123.93], [#r("+116.05")], [9 834],
  [9 834], [0], [*`query3`*], [2 586.21], [2 740.10], [#r("+153.88")], [11 117],
  [11 396], [#r("+279")], [*`query4`*], [14 801.55], [15 043.81], [#r("+242.27")], [98 504],
  [98 504], [0], [*`change1`*], [8 254.11], [8 438.54], [#r("+184.44")], [29 726],
  [29 726], [0], [*`change3`*], [1 364.36], [1 366.26], [#r("+1.89")], [3 954],
  [3 954], [0], [*`change4`*], [459.79], [479.00], [#r("+19.21")], [2 474],
  [2 474], [0], [*Suma*], [*30 776.94*], [*31 481.58*], [*#r("+704.63")*], table.cell(rowspan: 1, colspan: 3)[—],
  
)
