#let r(n) = text(fill: rgb("#880000"), n)
#let g(n) = text(fill: rgb("#008800"), n)
#table(
  columns: 7,
  align: right + horizon,
  fill: (x, y) => if y in (0, 1, 9) { rgb("#cce") } else if calc.rem(y, 2) == 0 { rgb("#f0f0ff") },
  table.cell(rowspan: 2, colspan: 1)[*Nazwa*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*],
  [*Nowy*], [*Zmiana*], [*`query1`*], [577.36], [548.86], [#g("-28.50")], [1 697],
  [1 697], [0], [*`query2`*], [943.45], [842.01], [#g("-101.44")], [8 524],
  [8 524], [0], [*`query3`*], [1 462.68], [1 418.72], [#g("-43.96")], [9 649],
  [9 649], [0], [*`query4`*], [16 271.36], [17 043.31], [#r("+771.95")], [85 687],
  [85 687], [0], [*`query4mv`*], [202.28], [172.35], [#g("-29.93")], [1 570],
  [71], [#g("-1 499")], [*`change1`*], [5 256.22], [5 120.14], [#g("-136.09")], [21 796],
  [21 796], [0], [*`change3`*], [750.60], [734.29], [#g("-16.32")], [3 411],
  [3 411], [0], [*`change4`*], [240.68], [217.92], [#g("-22.76")], [2 101],
  [2 101], [0], [*Suma*], [*25 704.63*], [*26 097.60*], [*#r("+392.97")*], table.cell(rowspan: 1, colspan: 3)[—],
  
)
