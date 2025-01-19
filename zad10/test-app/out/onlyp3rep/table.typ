#let r(n) = text(fill: rgb("#880000"), n)
#let g(n) = text(fill: rgb("#008800"), n)
#table(
  columns: 7,
  align: right + horizon,
  fill: (x, y) => if y in (0, 1, 9) { rgb("#cce") } else if calc.rem(y, 2) == 0 { rgb("#f0f0ff") },
  table.cell(rowspan: 2, colspan: 1)[*Nazwa*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*],
  [*Nowy*], [*Zmiana*], [*`query1`*], [800.16], [784.93], [#g("-15.23")], [1 697],
  [1 697], [0], [*`query2`*], [1 252.38], [1 345.65], [#r("+93.27")], [8 524],
  [8 524], [0], [*`query3`*], [1 911.14], [1 909.62], [#g("-1.52")], [9 649],
  [9 649], [0], [*`query4`*], [32 761.40], [35 826.26], [#r("+3 064.87")], [85 687],
  [85 687], [0], [*`query4mv`*], [254.17], [255.51], [#r("+1.34")], [1 570],
  [1 570], [0], [*`change1`*], [7 586.13], [6 790.60], [#g("-795.53")], [21 796],
  [21 796], [0], [*`change3`*], [1 387.24], [933.73], [#g("-453.51")], [3 411],
  [3 411], [0], [*`change4`*], [392.02], [259.34], [#g("-132.68")], [2 101],
  [2 101], [0], [*Suma*], [*46 344.64*], [*48 105.64*], [*#r("+1 761.00")*], table.cell(rowspan: 1, colspan: 3)[—],
  
)
