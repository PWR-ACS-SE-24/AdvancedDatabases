#let r(n) = text(fill: rgb("#880000"), n)
#let g(n) = text(fill: rgb("#008800"), n)
#table(
  columns: 7,
  align: right + horizon,
  fill: (x, y) => if y in (0, 1, 9) { rgb("#cce") } else if calc.rem(y, 2) == 0 { rgb("#f0f0ff") },
  table.cell(rowspan: 2, colspan: 1)[*Nazwa*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*],
  [*Nowy*], [*Zmiana*], [*`query1`*], [1 143.58], [1 129.85], [#g("-13.72")], [1 746],
  [1 746], [0], [*`query2`*], [1 701.09], [1 726.62], [#r("+25.53")], [9 834],
  [9 834], [0], [*`query3`*], [2 148.41], [2 120.81], [#g("-27.60")], [11 117],
  [11 117], [0], [*`query4`*], [13 460.99], [13 363.34], [#g("-97.65")], [98 504],
  [98 504], [0], [*`change1`*], [7 442.11], [7 385.08], [#g("-57.03")], [29 726],
  [29 726], [0], [*`change3`*], [1 214.87], [1 204.54], [#g("-10.33")], [3 954],
  [3 888], [#g("-66")], [*`change4`*], [406.13], [401.03], [#g("-5.10")], [2 474],
  [2 474], [0], [*Suma*], [*27 517.18*], [*27 331.28*], [*#g("-185.90")*], table.cell(rowspan: 1, colspan: 3)[—],
  
)
