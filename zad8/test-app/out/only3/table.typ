#let r(n) = text(fill: rgb("#880000"), n)
#let g(n) = text(fill: rgb("#008800"), n)
#table(
  columns: 7,
  align: right + horizon,
  fill: (x, y) => if y in (0, 1, 9) { rgb("#cce") } else if calc.rem(y, 2) == 0 { rgb("#f0f0ff") },
  table.cell(rowspan: 2, colspan: 1)[*Nazwa*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*],
  [*Nowy*], [*Zmiana*], [*`query1`*], [1 143.58], [1 132.74], [#g("-10.84")], [1 746],
  [1 746], [0], [*`query2`*], [1 701.09], [1 684.87], [#g("-16.22")], [9 834],
  [9 836], [#r("+2")], [*`query3`*], [2 148.41], [102 096.97], [#r("+99 948.56")], [11 117],
  [11 014], [#g("-103")], [*`query4`*], [13 460.99], [12 715.88], [#g("-745.11")], [98 504],
  [98 530], [#r("+26")], [*`change1`*], [7 442.11], [10 955.15], [#r("+3 513.03")], [29 726],
  [29 666], [#g("-60")], [*`change3`*], [1 214.87], [1 107.27], [#g("-107.60")], [3 954],
  [3 939], [#g("-15")], [*`change4`*], [406.13], [383.52], [#g("-22.61")], [2 474],
  [2 474], [0], [*Suma*], [*27 517.18*], [*130 076.40*], [*#r("+102 559.22")*], table.cell(rowspan: 1, colspan: 3)[—],
  
)
