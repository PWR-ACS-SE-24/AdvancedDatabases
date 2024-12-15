#let diff(n) = if n == 0 { [#n] } else if n > 0 { text(fill: rgb("#880000"))[+#n] } else { text(fill: rgb("#008800"))[-#calc.abs(n)] }
#table(
  columns: 7,
  align: right + horizon,
  table.cell(rowspan: 2, colspan: 1)[*Name*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*], [*Nowy*], [*Zmiana*], [*`query1`*], [565.43], [559.94], [#diff(-5.49)], [1697], [1668], [#diff(-29)], [*`query2`*], [926.31], [945.07], [#diff(18.76)], [8524], [8487], [#diff(-37)], [*`query3`*], [1523.56], [1565.41], [#diff(41.85)], [9649], [9649], [#diff(0)], [*`query4`*], [20676.42], [21830.52], [#diff(1154.09)], [85687], [85555], [#diff(-132)], [*`change1`*], [5359.34], [5354.02], [#diff(-5.32)], [21796], [21796], [#diff(0)], [*`change3`*], [774.88], [758.57], [#diff(-16.31)], [3411], [3411], [#diff(0)], [*`change4`*], [210.48], [209.86], [#diff(-0.63)], [2101], [2101], [#diff(0)]
)
