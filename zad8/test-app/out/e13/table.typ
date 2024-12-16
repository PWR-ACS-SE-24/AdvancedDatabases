#let diff(n) = if n == 0 { [#n] } else if n > 0 { text(fill: rgb("#880000"))[+#n] } else { text(fill: rgb("#008800"))[-#calc.abs(n)] }
#table(
  columns: 7,
  align: right + horizon,
  table.cell(rowspan: 2, colspan: 1)[*Name*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*], [*Nowy*], [*Zmiana*], [*`query1`*], [1574.47], [1027.06], [#diff(-547.41)], [1746], [1746], [#diff(0)], [*`query2`*], [2310.49], [1802.68], [#diff(-507.81)], [9834], [9834], [#diff(0)], [*`query3`*], [3431.12], [2145.72], [#diff(-1285.40)], [11117], [11117], [#diff(0)], [*`query4`*], [19940.83], [13343.28], [#diff(-6597.55)], [98504], [98504], [#diff(0)], [*`change1`*], [12014.35], [7381.07], [#diff(-4633.28)], [29726], [29726], [#diff(0)], [*`change3`*], [1963.72], [1220.99], [#diff(-742.73)], [3954], [3609], [#diff(-345)], [*`change4`*], [613.72], [440.26], [#diff(-173.46)], [2474], [2142], [#diff(-332)]
)