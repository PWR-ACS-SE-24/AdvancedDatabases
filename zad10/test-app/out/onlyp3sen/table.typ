#let r(n) = text(fill: rgb("#880000"), n)
#let g(n) = text(fill: rgb("#008800"), n)
#table(
  columns: 7,
  align: right + horizon,
  fill: (x, y) => if y in (0, 1, 9) { rgb("#cce") } else if calc.rem(y, 2) == 0 { rgb("#f0f0ff") },
  table.cell(rowspan: 2, colspan: 1)[*Nazwa*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*],
  [*Nowy*], [*Zmiana*], [*`query1`*], [577.36], [555.63], [#g("-21.73")], [1 697],
  [1 697], [0], [*`query2`*], [943.45], [848.07], [#g("-95.38")], [8 524],
  [8 524], [0], [*`query3`*], [1 462.68], [1 430.44], [#g("-32.24")], [9 649],
  [9 649], [0], [*`query4`*], [16 271.36], [16 816.39], [#r("+545.03")], [85 687],
  [85 687], [0], [*`query4mv`*], [202.28], [193.65], [#g("-8.63")], [1 570],
  [1 570], [0], [*`change1`*], [5 256.22], [5 292.58], [#r("+36.36")], [21 796],
  [21 796], [0], [*`change3`*], [750.60], [763.96], [#r("+13.35")], [3 411],
  [3 411], [0], [*`change4`*], [240.68], [243.39], [#r("+2.71")], [2 101],
  [2 101], [0], [*Suma*], [*25 704.63*], [*26 144.11*], [*#r("+439.47")*], table.cell(rowspan: 1, colspan: 3)[—],
  
)
