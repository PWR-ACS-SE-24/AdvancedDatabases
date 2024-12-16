#let diff(n) = if n == 0 { [#n] } else if n > 0 { text(fill: rgb("#880000"))[+#n] } else { text(fill: rgb("#008800"))[-#calc.abs(n)] }
#table(
  columns: 7,
  align: right + horizon,
  table.cell(rowspan: 2, colspan: 1)[*Name*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*], [*Nowy*], [*Zmiana*], [*`query1`*], [1574.47], [1049.60], [#diff(-524.87)], [1746], [1746], [#diff(0)], [*`query2`*], [2310.49], [1826.03], [#diff(-484.46)], [9834], [9834], [#diff(0)], [*`query3`*], [3431.12], [2186.86], [#diff(-1244.26)], [11117], [11117], [#diff(0)], [*`query4`*], [19940.83], [13562.73], [#diff(-6378.10)], [98504], [98504], [#diff(0)], [*`change1`*], [12014.35], [7558.99], [#diff(-4455.36)], [29726], [29726], [#diff(0)], [*`change3`*], [1963.72], [1236.07], [#diff(-727.65)], [3954], [3888], [#diff(-66)], [*`change4`*], [613.72], [442.89], [#diff(-170.83)], [2474], [2474], [#diff(0)]
)