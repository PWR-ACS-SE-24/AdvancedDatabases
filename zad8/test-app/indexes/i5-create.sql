create index patrol_fk_guard_idx on
   patrol (
      fk_guard
   );
create index patrol_fk_block_idx on
   patrol (
      fk_block
   );
create index cell_fk_block_idx on
   cell (
      fk_block
   );
create index reprimand_fk_guard_idx on
   reprimand (
      fk_guard
   );
create index reprimand_fk_prisoner_idx on
   reprimand (
      fk_prisoner
   );
create index accommodation_fk_cell_idx on
   accommodation (
      fk_cell
   );
create index accommodation_fk_prisoner_idx on
   accommodation (
      fk_prisoner
   );
create index sentence_fk_prisoner_idx on
   sentence (
      fk_prisoner
   );
