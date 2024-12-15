#let diff(n) = if n == 0 { [#n] } else if n > 0 { text(fill: rgb("#880000"))[+#n] } else { text(fill: rgb("#008800"))[-#calc.abs(n)] }
#table(
  columns: 7,
  align: right + horizon,
  table.cell(rowspan: 2, colspan: 1)[*Name*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*], [*Nowy*], [*Zmiana*], [*`query1`*], [565.43], [571.41], [#diff(5.97)], [1697], [1668], [#diff(-29)], [*`query2`*], [926.31], [1020.01], [#diff(93.71)], [8524], [6754], [#diff(-1770)], [*`query3`*], [1523.56], [1892.06], [#diff(368.50)], [9649], [5272], [#diff(-4377)], [*`query4`*], [20676.42], [23025.12], [#diff(2348.69)], [85687], [85564], [#diff(-123)], [*`change1`*], [5359.34], [7112.15], [#diff(1752.81)], [21796], [20775], [#diff(-1021)], [*`change3`*], [774.88], [707.52], [#diff(-67.36)], [3411], [3087], [#diff(-324)], [*`change4`*], [210.48], [250.27], [#diff(39.79)], [2101], [1795], [#diff(-306)]
)
