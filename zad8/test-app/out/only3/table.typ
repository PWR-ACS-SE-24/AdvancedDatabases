#let diff(n) = if n == 0 { [#n] } else if n > 0 { text(fill: rgb("#880000"))[+#n] } else { text(fill: rgb("#008800"))[-#calc.abs(n)] }
#table(
  columns: 7,
  align: right + horizon,
  table.cell(rowspan: 2, colspan: 1)[*Name*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*], [*Nowy*], [*Zmiana*], [*`query1`*], [1574.47], [1035.95], [#diff(-538.51)], [1746], [1746], [#diff(0)], [*`query2`*], [2310.49], [1813.04], [#diff(-497.45)], [9834], [9836], [#diff(2)], [*`query3`*], [3431.12], [103481.64], [#diff(100050.52)], [11117], [11014], [#diff(-103)], [*`query4`*], [19940.83], [12892.87], [#diff(-7047.96)], [98504], [98530], [#diff(26)], [*`change1`*], [12014.35], [11104.03], [#diff(-910.32)], [29726], [29666], [#diff(-60)], [*`change3`*], [1963.72], [1122.77], [#diff(-840.95)], [3954], [3939], [#diff(-15)], [*`change4`*], [613.72], [416.86], [#diff(-196.85)], [2474], [2474], [#diff(0)]
)