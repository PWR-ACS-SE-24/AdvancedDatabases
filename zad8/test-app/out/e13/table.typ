#let diff(n) = if n == 0 { [#n] } else if n > 0 { text(fill: rgb("#880000"))[+#n] } else { text(fill: rgb("#008800"))[-#calc.abs(n)] }
#table(
  columns: 7,
  align: right + horizon,
  table.cell(rowspan: 2, colspan: 1)[*Name*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*], [*Nowy*], [*Zmiana*], [*`query1`*], [565.43], [569.94], [#diff(4.51)], [1697], [1697], [#diff(0)], [*`query2`*], [926.31], [940.06], [#diff(13.76)], [8524], [8524], [#diff(0)], [*`query3`*], [1523.56], [1574.39], [#diff(50.83)], [9649], [9649], [#diff(0)], [*`query4`*], [20676.42], [22354.63], [#diff(1678.21)], [85687], [85687], [#diff(0)], [*`change1`*], [5359.34], [5305.51], [#diff(-53.83)], [21796], [21796], [#diff(0)], [*`change3`*], [774.88], [751.23], [#diff(-23.65)], [3411], [3093], [#diff(-318)], [*`change4`*], [210.48], [202.98], [#diff(-7.51)], [2101], [1795], [#diff(-306)]
)
