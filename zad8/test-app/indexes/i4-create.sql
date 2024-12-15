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
