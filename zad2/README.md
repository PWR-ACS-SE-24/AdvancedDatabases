# Zaawansowane systemy baz danych (ZSBD)

<div align="center">
Zespół B5 (baza danych dla więzienia): <br/> <b>Tomasz Chojnacki (260365), Kamila Iwańska (253027), Jakub Zehner (260285)</b>
</div>

## Zadanie 2 - Workload

### Zapytanie 1

Wyszukanie strażników, którzy mogą obsadzić patrol w danym przedziale czasowym (`start_time` - `end_time`). Kwerenda zwraca `proposal_count` propozycji strażników, którzy mogą patrolować blok dla każdej warty (patrol slot) w podanym przedziale czasowym. Można wybrać jedynie strażników, którzy posiadają lub nie posiadają oświadczenia o niepełnosprawności (`has_disability_class`). Strażnik musi mieć staż pracy większy niż `experience_months` miesięcy oraz musi nadal pracować w zakładzie karnym.

| Parametry              |
| ---------------------- |
| `start_time`           |
| `end_time`             |
| `proposal_count`       |
| `has_disability_class` |
| `experience_months`    |

### Zapytanie 2

Liczby więźniów o danych cechach z podziałem na bloki, w których przebywają. Więźniów można filtrować według następujących parametrów:

- wiek więźnia pomiędzy `min_age` a `max_age`,
- płeć więźnia (`sex`),
- wzrost więźnia pomiędzy `min_height_m` a `max_height_m`,
- waga więźnia pomiędzy `min_weight_kg` a `max_weight_kg`,
- liczba wyroków więźnia pomiędzy `min_sentences` a `max_sentences`,
- skazanie za konkretne przestępstwo (`crime`),
- liczba reprymend więźnia pomiędzy `min_reprimands` a `max_reprimands`,
- przebywanie w więzieniu od `min_stay_months` do `max_stay_months` miesięcy,
- zwalnianie z więzienia w ciągu od `min_release_months` do `max_release_months` miesięcy,
- przebywanie w izolatce lub nie (`is_in_solitary`).

| Parametry            |
| -------------------- |
| `min_age`            |
| `max_age`            |
| `sex`                |
| `min_height_m`       |
| `max_height_m`       |
| `min_weight_kg`      |
| `max_weight_kg`      |
| `min_sentences`      |
| `max_sentences`      |
| `crime`              |
| `min_reprimands`     |
| `max_reprimands`     |
| `min_stay_months`    |
| `max_stay_months`    |
| `min_release_months` |
| `max_release_months` |
| `is_in_solitary`     |

### Zapytanie 3

Wyszukanie wydarzeń związanych z więźniami w danym bloku `block_number`, które miały miejsce w określonym przedziale czasowym (`start_date` - `end_date`). Wyniki mogą być filtrowane według typu wydarzenia `event_type`, np. ucieczka, bójka. Można ograniczyć wyniki do wydarzeń dotyczących więźniów o określonych cechach: liczba wyroków (`sentence_count`), przestępstwo (`crime`), liczba reprymend (`reprimand_count`), czy obecność w izolatce (`is_in_solitary`). Zwracana jest lista wydarzeń wraz z datą, danymi więźnia i strażnika oraz treścią reprymendy.

| Parametry         |
| ----------------- |
| `block_number`    |
| `start_time`      |
| `end_time`        |
| `event_type`      |
| `sentence_count`  |
| `crime`           |
| `reprimand_count` |
| `is_in_solitary`  |

### Zapytanie 4 (dodatkowe)

Zwrócenie raportu dotyczącego minimalnej, maksymalnej i średniej dla wzrostu, wagi, liczby wyroków, liczby reprymend, liczby przekwaterowań dla więźniów w danym bloku `block_number`. Można filtrować wyniki według płci więźniów (`sex`).

| Parametry      |
| -------------- |
| `block_number` |
| `sex`          |

### Zmiana danych 1

Zwolnienie wszystkich strażników ze stażem mniejszym niż `experience_months` miesięcy, którzy nie mają zaplanowanych patroli w przyszłości oraz patrolowali blok `block_number` w określonym przedziale czasowym (`start_time` - `end_time`).

| Parametry           |
| ------------------- |
| `block_number`      |
| `start_time`        |
| `end_time`          |
| `experience_months` |

### Zmiana danych 2

Wygenerowanie wart (patrol slot) w przedziale czasowym (`start_time` - `end_time`) z określonym czasem trwania patrolu w minutach `slot_duration`.

| Parametry       |
| --------------- |
| `start_time`    |
| `end_time`      |
| `slot_duration` |

### Zmiana danych 3

Przeniesienie więźniów, którzy w przedziale czasowym (`start_time` - `end_time`) dostali reprymendę zawierającą w treści `event_type` do wolnej izolatki w bloku `block_id` z obecnego zakwaterowania. Jeżeli wolnych izolatek nie ma, to więźniowie pozostają w swoich celach.

| Parametry    |
| ------------ |
| `block_id`   |
| `start_time` |
| `end_time`   |
| `event_type` |

### Zamiana danych 4 (dodatkowa)

Wystawienie reprymendy o treści `reason` przez strażnika `guard_id` wszystkim więźniom niebędącym w izolatce i znajdującym się w bloku `block_number` w momencie `event_time`.

| Parametry      |
| -------------- |
| `block_number` |
| `event_time`   |
| `guard_id`     |
| `reason`       |
