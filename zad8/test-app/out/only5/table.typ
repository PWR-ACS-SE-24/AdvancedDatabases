#let diff(n) = if n == 0 { [#n] } else if n > 0 { text(fill: rgb("#880000"))[+#n] } else { text(fill: rgb("#008800"))[-#calc.abs(n)] }
#table(
  columns: 7,
  align: right + horizon,
  table.cell(rowspan: 2, colspan: 1)[*Name*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*], [*Nowy*], [*Zmiana*], [*`query1`*], [1574.47], [1052.83], [#diff(-521.63)], [1746], [1746], [#diff(0)], [*`query2`*], [2310.49], [1919.68], [#diff(-390.81)], [9834], [7748], [#diff(-2086)], [*`query3`*], [3431.12], [3273.69], [#diff(-157.44)], [11117], [6043], [#diff(-5074)], [*`query4`*], [19940.83], [13661.95], [#diff(-6278.88)], [98504], [98504], [#diff(0)], [*`change1`*], [12014.35], [7356.95], [#diff(-4657.41)], [29726], [29726], [#diff(0)], [*`change3`*], [1963.72], [1379.02], [#diff(-584.70)], [3954], [3621], [#diff(-333)], [*`change4`*], [613.72], [449.96], [#diff(-163.76)], [2474], [2141], [#diff(-333)]
)