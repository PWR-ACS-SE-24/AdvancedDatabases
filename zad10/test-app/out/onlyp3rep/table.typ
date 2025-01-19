#let r(n) = text(fill: rgb("#880000"), n)
#let g(n) = text(fill: rgb("#008800"), n)
#table(
  columns: 7,
  align: right + horizon,
  fill: (x, y) => if y in (0, 1, 9) { rgb("#cce") } else if calc.rem(y, 2) == 0 { rgb("#f0f0ff") },
  table.cell(rowspan: 2, colspan: 1)[*Nazwa*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*],
  [*Nowy*], [*Zmiana*], [*`query1`*], [577.36], [554.20], [#g("-23.15")], [1 697],
  [1 697], [0], [*`query2`*], [943.45], [851.20], [#g("-92.25")], [8 524],
  [8 524], [0], [*`query3`*], [1 462.68], [1 469.04], [#r("+6.37")], [9 649],
  [9 649], [0], [*`query4`*], [16 271.36], [17 525.71], [#r("+1 254.35")], [85 687],
  [85 687], [0], [*`query4mv`*], [202.28], [192.94], [#g("-9.34")], [1 570],
  [1 570], [0], [*`change1`*], [5 256.22], [5 256.56], [#r("+0.34")], [21 796],
  [21 796], [0], [*`change3`*], [750.60], [746.27], [#g("-4.34")], [3 411],
  [3 411], [0], [*`change4`*], [240.68], [203.11], [#g("-37.57")], [2 101],
  [2 101], [0], [*Suma*], [*25 704.63*], [*26 799.04*], [*#r("+1 094.41")*], table.cell(rowspan: 1, colspan: 3)[—],
  
)
