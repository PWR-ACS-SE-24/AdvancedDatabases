#let r(n) = text(fill: rgb("#880000"), n)
#let g(n) = text(fill: rgb("#008800"), n)
#table(
  columns: 7,
  align: right + horizon,
  fill: (x, y) => if y in (0, 1, 9) { rgb("#cce") } else if calc.rem(y, 2) == 0 { rgb("#f0f0ff") },
  table.cell(rowspan: 2, colspan: 1)[*Nazwa*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*],
  [*Nowy*], [*Zmiana*], [*`query1`*], [577.36], [608.16], [#r("+30.80")], [1 697],
  [819], [#g("-878")], [*`query2`*], [943.45], [849.02], [#g("-94.43")], [8 524],
  [8 524], [0], [*`query3`*], [1 462.68], [1 440.52], [#g("-22.16")], [9 649],
  [9 649], [0], [*`query4`*], [16 271.36], [17 151.87], [#r("+880.51")], [85 687],
  [85 687], [0], [*`query4mv`*], [202.28], [194.27], [#g("-8.01")], [1 570],
  [1 570], [0], [*`change1`*], [5 256.22], [5 230.88], [#g("-25.34")], [21 796],
  [21 771], [#g("-25")], [*`change3`*], [750.60], [746.05], [#g("-4.56")], [3 411],
  [3 411], [0], [*`change4`*], [240.68], [210.55], [#g("-30.13")], [2 101],
  [2 101], [0], [*Suma*], [*25 704.63*], [*26 431.33*], [*#r("+726.70")*], table.cell(rowspan: 1, colspan: 3)[—],
  
)
