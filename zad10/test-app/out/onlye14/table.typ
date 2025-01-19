#let r(n) = text(fill: rgb("#880000"), n)
#let g(n) = text(fill: rgb("#008800"), n)
#table(
  columns: 7,
  align: right + horizon,
  fill: (x, y) => if y in (0, 1, 9) { rgb("#cce") } else if calc.rem(y, 2) == 0 { rgb("#f0f0ff") },
  table.cell(rowspan: 2, colspan: 1)[*Nazwa*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*],
  [*Nowy*], [*Zmiana*], [*`query1`*], [800.16], [711.95], [#g("-88.21")], [1 697],
  [1 697], [0], [*`query2`*], [1 252.38], [1 052.16], [#g("-200.22")], [8 524],
  [7 435], [#g("-1 089")], [*`query3`*], [1 911.14], [1 806.79], [#g("-104.36")], [9 649],
  [8 493], [#g("-1 156")], [*`query4`*], [32 761.40], [30 692.51], [#g("-2 068.89")], [85 687],
  [82 968], [#g("-2 719")], [*`query4mv`*], [254.17], [225.39], [#g("-28.78")], [1 570],
  [1 570], [0], [*`change1`*], [7 586.13], [6 312.27], [#g("-1 273.86")], [21 796],
  [21 796], [0], [*`change3`*], [1 387.24], [950.50], [#g("-436.74")], [3 411],
  [3 343], [#g("-68")], [*`change4`*], [392.02], [339.38], [#g("-52.64")], [2 101],
  [2 101], [0], [*Suma*], [*46 344.64*], [*42 090.95*], [*#g("-4 253.69")*], table.cell(rowspan: 1, colspan: 3)[—],
  
)
