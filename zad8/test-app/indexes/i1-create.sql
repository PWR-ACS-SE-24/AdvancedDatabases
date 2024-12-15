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
