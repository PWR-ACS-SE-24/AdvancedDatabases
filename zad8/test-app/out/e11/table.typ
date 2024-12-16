#let diff(n) = if n == 0 { [#n] } else if n > 0 { text(fill: rgb("#880000"))[+#n] } else { text(fill: rgb("#008800"))[-#calc.abs(n)] }
#table(
  columns: 7,
  align: right + horizon,
  table.cell(rowspan: 2, colspan: 1)[*Name*], table.cell(rowspan: 1, colspan: 3)[*Średni czas [ms]*], table.cell(rowspan: 1, colspan: 3)[*Koszt*], [*Stary*], [*Nowy*], [*Zmiana*], [*Stary*], [*Nowy*], [*Zmiana*], [*`query1`*], [1574.47], [1019.31], [#diff(-555.16)], [1746], [1746], [#diff(0)], [*`query2`*], [2310.49], [1817.58], [#diff(-492.91)], [9834], [9834], [#diff(0)], [*`query3`*], [3431.12], [2133.20], [#diff(-1297.92)], [11117], [11117], [#diff(0)], [*`query4`*], [19940.83], [13362.65], [#diff(-6578.18)], [98504], [98504], [#diff(0)], [*`change1`*], [12014.35], [7355.62], [#diff(-4658.73)], [29726], [29726], [#diff(0)], [*`change3`*], [1963.72], [1215.91], [#diff(-747.81)], [3954], [3637], [#diff(-317)], [*`change4`*], [613.72], [428.85], [#diff(-184.87)], [2474], [2474], [#diff(0)]
)