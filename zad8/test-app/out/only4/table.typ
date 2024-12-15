#let diff(n) = if n == 0 { [#n] } else if n > 0 { text(fill: rgb("#880000"))[+#n] } else { text(fill: rgb("#008800"))[-#calc.abs(n)] }
#table(
  columns: 7,
  align: right + horizon,
  table.cell(rowspan: 2, colspan: 1)[*Name*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*], [*Nowy*], [*Zmiana*], [*`query1`*], [565.43], [607.20], [#diff(41.76)], [1697], [1697], [#diff(0)], [*`query2`*], [926.31], [1085.00], [#diff(158.69)], [8524], [8524], [#diff(0)], [*`query3`*], [1523.56], [1591.73], [#diff(68.17)], [9649], [9649], [#diff(0)], [*`query4`*], [20676.42], [22495.14], [#diff(1818.72)], [85687], [85687], [#diff(0)], [*`change1`*], [5359.34], [4549.57], [#diff(-809.77)], [21796], [20832], [#diff(-964)], [*`change3`*], [774.88], [752.48], [#diff(-22.40)], [3411], [3093], [#diff(-318)], [*`change4`*], [210.48], [215.67], [#diff(5.19)], [2101], [1795], [#diff(-306)]
)
