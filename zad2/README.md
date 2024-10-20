# Zaawansowane systemy baz danych (ZSBD)

<div align="center">
Zespół B5 (baza danych dla więzienia): <br/> <b>Tomasz Chojnacki (260365), Kamila Iwańska (253027), Jakub Zehner (260285)</b>
</div>

## Zadanie 2 - Workload

### Zapytanie 1

Wyszukanie strażników, którzy mogą obsadzić patrole w danym bloku `block_id` w danym przedziale czasowym (`start_time` - `end_time`). Kwerenda zwraca `proposal_count` propozycji strażników, którzy mogą patrolować blok dla każdej warty (patrol slot) w podanym przedziale czasowym. Można wybrać jedynie strażników, którzy posiadają lub nie posiadają oświadczenia o niepełnosprawności (`has_disability_class`). Strażnik musi mieć staż pracy większy niż `experience_months` miesięcy oraz musi nadal pracować w zakładzie karnym.

| Parametry              |
| ---------------------- |
| `block_id`             |
| `start_time`           |
| `end_time`             |
| `proposal_count`       |
| `has_disability_class` |
| `experience_months`    |

### Zapytanie 2

Zwrócenie procentu (spośród wszystkich więźniów) i liczby więźniów o danych cechach przebywających w danym bloku `block_id`. Więźniów można filtrować według następujących parametrów:

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
| `block_id`           |
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

Wyszukanie wydarzeń związanych z więźniami w danym bloku `block_id`, które miały miejsce w określonym przedziale czasowym (`start_time` - `end_time`). Wyniki mogą być filtrowane według typu wydarzenia `event_type`, np. ucieczka, bójka. Można ograniczyć wyniki do wydarzeń dotyczących więźniów o określonych cechach: liczba wyroków (`sentence_count`), przestępstwo (`crime`), liczba reprymend (`reprimand_count`), czy obecność w izolatce (`is_in_solitary`). Zwracana jest lista wydarzeń wraz z datą oraz treścią reprymendy.

| Parametry         |
| ----------------- |
| `block_id`        |
| `start_time`      |
| `end_time`        |
| `event_type`      |
| `sentence_count`  |
| `crime`           |
| `reprimand_count` |
| `is_in_solitary`  |

### Zmiana danych 1

Zwolnienie wszystkich strażników ze stażem mniejszym niż `experience_months` miesięcy, którzy nie mają zaplanowanych patroli w przyszłości oraz patrolowali blok `block_id` w określonym przedziale czasowym (`start_time` - `end_time`).

| Parametry           |
| ------------------- |
| `block_id`          |
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
