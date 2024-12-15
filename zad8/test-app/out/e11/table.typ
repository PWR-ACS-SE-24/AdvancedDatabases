#let diff(n) = if n == 0 { [#n] } else if n > 0 { text(fill: rgb("#880000"))[+#n] } else { text(fill: rgb("#008800"))[-#calc.abs(n)] }
#table(
  columns: 7,
  align: right + horizon,
  table.cell(rowspan: 2, colspan: 1)[*Name*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*], [*Nowy*], [*Zmiana*], [*`query1`*], [565.43], [569.82], [#diff(4.39)], [1697], [1697], [#diff(0)], [*`query2`*], [926.31], [991.40], [#diff(65.09)], [8524], [8524], [#diff(0)], [*`query3`*], [1523.56], [1555.30], [#diff(31.75)], [9649], [9649], [#diff(0)], [*`query4`*], [20676.42], [22332.10], [#diff(1655.68)], [85687], [85687], [#diff(0)], [*`change1`*], [5359.34], [5331.11], [#diff(-28.23)], [21796], [21796], [#diff(0)], [*`change3`*], [774.88], [755.52], [#diff(-19.36)], [3411], [3119], [#diff(-292)], [*`change4`*], [210.48], [208.15], [#diff(-2.33)], [2101], [2101], [#diff(0)]
)
