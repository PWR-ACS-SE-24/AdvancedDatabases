# Zaawansowane systemy baz danych (ZSBD)

<div align="center">
Zespół B5 (baza danych dla więzienia): <br/> <b>Tomasz Chojnacki (260365), Kamila Iwańska (253027), Jakub Zehner (260285)</b>
</div>

## Zadanie 6 - Aplikacja testowa

### Budowa aplikacji

Zbudowaliśmy prostą aplikację w języku JavaScript (Node.js), korzystającą z oficjalnej biblioteki `oracledb` do łączenia z bazą danych Oracle. W&nbsp;aplikacji zawarta jest specyfikacja naszej próbki obciążeniowej (`workload.js`), składająca się z obiektów reprezentujących kwerendy, gdzie każdy taki obiekt zawiera jej treść w języku SQL (`sql`) oraz stały zestaw parametrów (`params`). Zgodnie z postanowieniami z poprzedniego etapu, z&nbsp;zestawu usunęliśmy zmianę danych nr 2, co daje nam łącznie 7 zapytań do testowania: `query1`, `query2`, `query3`, `query4`, `change1`, `change3`, `change4`. W tym pliku jest zawarta również liczba powtórzeń dla naszej próbki. Następnie stworzyliśmy funkcje pomocnicze (`util.js`), które pozwalają na:
- `explainPlan` - zapisanie do pliku planu wykonania zapytania,
- `measureTime` - pomiar rzeczywistego czasu wykonania zapytania,
- `flushMemory` - wyczyszczenie buforów pamięci podręcznej bazy danych,
- `calculateStats` - obliczenie statystyk opisowych z listy czasów wykonania zapytań,
- `getCounts` - zwrócenie listy liczb wierszy w każdej tabeli bazy.

Co istotne, wyłączamy również pamięć podręczną w naszym kliencie bazodanowym, aby uzyskać bardziej wiarygodne wyniki. Przy uruchomieniu programu najpierw łączymy się z bazą danych, a następnie zbieramy aktualne plany wykonania dla wszystkich zapytań i zapisujemy je do plików. Finalnie, po wyczyszczeniu buforów dziesięciokrotnie powtarzamy próbkę obciążeniową i zbieramy indywidualne czasy wykonania zapytań. Na końcu obliczamy statystyki opisowe dla każdego zapytania, wypisujemy wyniki na konsolę oraz zapisujemy do pliku.

### Wyniki testów

Dokumentacja czasów realizacji każdej transakcji:

| **name**  | **count** | **min**    | **max**    | **avg**    | **std** |
| :-------- | --------: | ---------: | ---------: | ---------: | ------: |
| `query1`  | 10        | 559.952    | 595.524    | 571.239    | 9.568   |
| `query2`  | 10        | 896.187    | 1 028.023  | 925.054    | 39.460  |
| `query3`  | 10        | 1 535.451  | 1 816.184  | 1 614.078  | 92.743  |
| `query4`  | 10        | 19 153.503 | 21 072.187 | 19 991.742 | 562.282 |
| `change1` | 10        | 5 344.983  | 5 526.652  | 5 417.817  | 48.015  |
| `change3` | 10        | 745.667    | 797.722    | 761.806    | 15.442  |
| `change4` | 10        | 197.039    | 208.083    | 201.527    | 3.359   |
| **sum**   | -         | 28 432.782 | 31 044.375 | 29 483.263 | -       |

Surowe dane uzyskane z programu dla weryfikacji:

| **name**  | **t0**    | **t1**    | **t2**    | **t3**    | **t4**    | **t5**    | **t6**    | **t7**    | **t8**    | **t9**    |
| :-------- | --------: | --------: | --------: | --------: | --------: | --------: | --------: | --------: | --------: | --------: |
| `query1`  | 567.866   | 559.952   | 569.545   | 571.170   | 578.330   | 573.808   | 595.524   | 565.792   | 568.710   | 561.692   |
| `query2`  | 1028.023  | 909.381   | 914.348   | 920.564   | 913.305   | 896.187   | 896.487   | 898.801   | 906.395   | 967.045   |
| `query3`  | 1697.340  | 1696.287  | 1547.445  | 1553.639  | 1536.146  | 1546.537  | 1662.579  | 1549.172  | 1535.451  | 1816.184  |
| `query4`  | 20797.890 | 20211.219 | 19153.503 | 20109.510 | 19698.494 | 19382.666 | 19666.270 | 21072.187 | 19866.273 | 19959.409 |
| `change1` | 5344.983  | 5386.286  | 5409.764  | 5421.154  | 5394.990  | 5421.486  | 5383.564  | 5473.687  | 5526.652  | 5415.604  |
| `change3` | 745.667   | 753.204   | 747.653   | 781.518   | 764.578   | 797.722   | 763.383   | 757.261   | 754.906   | 752.167   |
| `change4` | 208.083   | 197.039   | 198.135   | 202.705   | 200.546   | 202.979   | 199.020   | 205.953   | 198.775   | 202.034   |

Brak kwerendy `change2` jest celowy, zostało to uzasadnione w poprzednim etapie.

<br/>

### Wnioski

Przy badaniu czasów wykonania kwerend w relacyjnej bazie danych istotne jest zadbanie o:
- niewykonywanie tego samego zapytania wielokrotnie pod rząd, ponieważ baza danych może zoptymalizować tak trywialne dostępy do danych,
- wyczyszczenie buforów pamięci podręcznej bazy danych, aby uzyskać bardziej wiarygodne wyniki,
- wyłączenie pamięci podręcznej w kliencie bazodanowym, aby nie przechowywać wyników zapytań w pamięci programu komputerowego.

Udało nam się uzyskać powtarzalne wyniki o małym odchyleniu standardowym czasów wykonania kwerendy. Wypisywanie liczby rzędów w każdej z&nbsp;tabel gwarantuje, że każde wykonanie ma ten sam stan początkowy bazy danych. Najbardziej spójne wyniki otrzymaliśmy wykonując próbkę obciążeniową, w czasie gdy na komputerze nie działały inne zasobożerne procesy.
