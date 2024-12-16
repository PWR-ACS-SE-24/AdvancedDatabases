#let diff(n) = if n == 0 { [#n] } else if n > 0 { text(fill: rgb("#880000"))[+#n] } else { text(fill: rgb("#008800"))[-#calc.abs(n)] }
#table(
  columns: 7,
  align: right + horizon,
  table.cell(rowspan: 2, colspan: 1)[*Name*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*], [*Nowy*], [*Zmiana*], [*`query1`*], [1574.47], [1015.95], [#diff(-558.52)], [1746], [1746], [#diff(0)], [*`query2`*], [2310.49], [1833.54], [#diff(-476.95)], [9834], [9834], [#diff(0)], [*`query3`*], [3431.12], [2189.59], [#diff(-1241.53)], [11117], [11117], [#diff(0)], [*`query4`*], [19940.83], [13344.32], [#diff(-6596.51)], [98504], [98504], [#diff(0)], [*`change1`*], [12014.35], [6595.90], [#diff(-5418.45)], [29726], [28826], [#diff(-900)], [*`change3`*], [1963.72], [1209.47], [#diff(-754.25)], [3954], [3609], [#diff(-345)], [*`change4`*], [613.72], [467.05], [#diff(-146.67)], [2474], [2142], [#diff(-332)]
)