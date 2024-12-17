#let r(n) = text(fill: rgb("#880000"), n)
#let g(n) = text(fill: rgb("#008800"), n)
#table(
  columns: 7,
  align: right + horizon,
  fill: (x, y) => if y in (0, 1, 9) { rgb("#cce") } else if calc.rem(y, 2) == 0 { rgb("#f0f0ff") },
  table.cell(rowspan: 2, colspan: 1)[*Nazwa*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*],
  [*Nowy*], [*Zmiana*], [*`query1`*], [1 143.58], [1 127.46], [#g("-16.12")], [1 746],
  [1 746], [0], [*`query2`*], [1 701.09], [1 784.91], [#r("+83.82")], [9 834],
  [7 748], [#g("-2 086")], [*`query3`*], [2 148.41], [2 841.01], [#r("+692.60")], [11 117],
  [6 043], [#g("-5 074")], [*`query4`*], [13 460.99], [13 686.67], [#r("+225.69")], [98 504],
  [98 504], [0], [*`change1`*], [7 442.11], [7 409.80], [#g("-32.32")], [29 726],
  [29 726], [0], [*`change3`*], [1 214.87], [1 314.82], [#r("+99.95")], [3 954],
  [3 621], [#g("-333")], [*`change4`*], [406.13], [399.81], [#g("-6.32")], [2 474],
  [2 141], [#g("-333")], [*Suma*], [*27 517.18*], [*28 564.48*], [*#r("+1 047.30")*], table.cell(rowspan: 1, colspan: 3)[—],
  
)
