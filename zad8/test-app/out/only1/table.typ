#let diff(n) = if n == 0 { [#n] } else if n > 0 { text(fill: rgb("#880000"))[+#n] } else { text(fill: rgb("#008800"))[-#calc.abs(n)] }
#table(
  columns: 7,
  align: right + horizon,
  table.cell(rowspan: 2, colspan: 1)[*Name*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*], [*Nowy*], [*Zmiana*], [*`query1`*], [1574.47], [1057.64], [#diff(-516.83)], [1746], [1716], [#diff(-30)], [*`query2`*], [2310.49], [1860.99], [#diff(-449.50)], [9834], [9736], [#diff(-98)], [*`query3`*], [3431.12], [2190.37], [#diff(-1240.75)], [11117], [11117], [#diff(0)], [*`query4`*], [19940.83], [13742.80], [#diff(-6198.03)], [98504], [98143], [#diff(-361)], [*`change1`*], [12014.35], [7835.19], [#diff(-4179.16)], [29726], [29726], [#diff(0)], [*`change3`*], [1963.72], [1289.12], [#diff(-674.60)], [3954], [3954], [#diff(0)], [*`change4`*], [613.72], [449.41], [#diff(-164.30)], [2474], [2474], [#diff(0)]
)