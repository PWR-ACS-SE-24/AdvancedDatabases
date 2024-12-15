#let diff(n) = if n == 0 { [#n] } else if n > 0 { text(fill: rgb("#880000"))[+#n] } else { text(fill: rgb("#008800"))[-#calc.abs(n)] }
#table(
  columns: 7,
  align: right + horizon,
  table.cell(rowspan: 2, colspan: 1)[*Name*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*], [*Nowy*], [*Zmiana*], [*`query1`*], [565.43], [566.26], [#diff(0.83)], [1697], [1697], [#diff(0)], [*`query2`*], [926.31], [1019.75], [#diff(93.44)], [8524], [6763], [#diff(-1761)], [*`query3`*], [1523.56], [1614.16], [#diff(90.61)], [9649], [5272], [#diff(-4377)], [*`query4`*], [20676.42], [22743.76], [#diff(2067.34)], [85687], [85687], [#diff(0)], [*`change1`*], [5359.34], [5298.56], [#diff(-60.78)], [21796], [21796], [#diff(0)], [*`change3`*], [774.88], [762.72], [#diff(-12.16)], [3411], [3105], [#diff(-306)], [*`change4`*], [210.48], [221.43], [#diff(10.94)], [2101], [1795], [#diff(-306)]
)
