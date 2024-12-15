#let diff(n) = if n == 0 { [#n] } else if n > 0 { text(fill: rgb("#880000"))[+#n] } else { text(fill: rgb("#008800"))[-#calc.abs(n)] }
#table(
  columns: 7,
  align: right + horizon,
  table.cell(rowspan: 2, colspan: 1)[*Name*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*], [*Nowy*], [*Zmiana*], [*`query1`*], [565.43], [569.46], [#diff(4.02)], [1697], [1697], [#diff(0)], [*`query2`*], [926.31], [917.19], [#diff(-9.11)], [8524], [8525], [#diff(1)], [*`query3`*], [1523.56], [72722.89], [#diff(71199.34)], [9649], [9616], [#diff(-33)], [*`query4`*], [20676.42], [22152.55], [#diff(1476.13)], [85687], [85697], [#diff(10)], [*`change1`*], [5359.34], [8181.09], [#diff(2821.76)], [21796], [21738], [#diff(-58)], [*`change3`*], [774.88], [683.48], [#diff(-91.40)], [3411], [3405], [#diff(-6)], [*`change4`*], [210.48], [203.08], [#diff(-7.40)], [2101], [2101], [#diff(0)]
)
