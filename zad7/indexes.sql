-- Indeksy b-drzewo dla danych czasowych

create index patrol_slot_start_time_idx on
   patrol_slot (
      start_time
   );
create index patrol_slot_end_time_idx on
   patrol_slot (
      end_time
   );
create index sentence_start_date_idx on
   sentence (
      start_date
   );
create index sentence_real_end_date_idx on
   sentence (
      real_end_date
   );
create index accommodation_start_date_idx on
   accommodation (
      start_date
   );
create index accommodation_end_date_idx on
   accommodation (
      end_date
   );

drop index patrol_slot_start_time_idx;
drop index patrol_slot_end_time_idx;
drop index sentence_start_date_idx;
drop index sentence_real_end_date_idx;
drop index accommodation_start_date_idx;
drop index accommodation_end_date_idx;

-- Indeks bitmapowy dla rodzaju celi 

create bitmap index cell_is_solitary_idx on
   cell (
      is_solitary
   );

drop index cell_is_solitary_idx;

-- Indeksy funkcyjne dla danych czasowych

create index reprimand_issue_date_to_char_idx on
   reprimand ( to_char(
      issue_date,
      'YYYY-MM-DD'
   ) );
create index sentence_start_date_to_char_idx on
   sentence ( to_char(
      start_date,
      'YYYY-MM-DD'
   ) );
create index sentence_real_end_date_to_char_idx on
   sentence ( to_char(
      real_end_date,
      'YYYY-MM-DD'
   ) );
create index accommodation_start_date_to_char_idx on
   accommodation ( to_char(
      start_date,
      'YYYY-MM-DD'
   ) );
create index accommodation_end_date_to_char_idx on
   accommodation ( to_char(
      end_date,
      'YYYY-MM-DD'
   ) );
create index patrol_slot_start_time_to_char_idx on
   patrol_slot ( to_char(
      start_time,
      'YYYY-MM-DD HH24:MI:SS'
   ) );
create index patrol_slot_end_time_to_char_idx on
   patrol_slot ( to_char(
      end_time,
      'YYYY-MM-DD HH24:MI:SS'
   ) );


drop index reprimand_issue_date_to_char_idx;
drop index sentence_start_date_to_char_idx;
drop index sentence_real_end_date_to_char_idx;
drop index accommodation_start_date_to_char_idx;
drop index accommodation_end_date_to_char_idx;
drop index patrol_slot_start_time_to_char_idx;
drop index patrol_slot_end_time_to_char_idx;

-- Indeksy złożone (b-drzewo) dla odwołań do wielu kolumn

create index cell_fk_block_is_solitary_idx on
   cell (
      fk_block,
      is_solitary
   );
create index patrol_fk_guard_fk_block_idx on
   patrol (
      fk_guard,
      fk_block
   );

drop index cell_fk_block_is_solitary_idx;
drop index patrol_fk_guard_fk_block_idx;

-- ???

create index accommodation_fk_prisoner_idx on
   accommodation (
      fk_prisoner
   );

drop index accommodation_fk_prisoner_idx;
