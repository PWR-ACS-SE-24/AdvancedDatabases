#let diff(n) = if n == 0 { [#n] } else if n > 0 { text(fill: rgb("#880000"))[+#n] } else { text(fill: rgb("#008800"))[-#calc.abs(n)] }
#table(
  columns: 7,
  align: right + horizon,
  table.cell(rowspan: 2, colspan: 1)[*Name*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*], [*Nowy*], [*Zmiana*], [*`query1`*], [565.43], [563.84], [#diff(-1.60)], [1697], [1697], [#diff(0)], [*`query2`*], [926.31], [935.91], [#diff(9.60)], [8524], [8524], [#diff(0)], [*`query3`*], [1523.56], [1567.73], [#diff(44.18)], [9649], [9649], [#diff(0)], [*`query4`*], [20676.42], [23088.87], [#diff(2412.45)], [85687], [85687], [#diff(0)], [*`change1`*], [5359.34], [5313.58], [#diff(-45.76)], [21796], [21796], [#diff(0)], [*`change3`*], [774.88], [749.15], [#diff(-25.73)], [3411], [3351], [#diff(-60)], [*`change4`*], [210.48], [205.33], [#diff(-5.16)], [2101], [2101], [#diff(0)]
)
