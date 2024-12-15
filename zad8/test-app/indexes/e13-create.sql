create index cell_is_solitary_composite_idx on
   cell (
      is_solitary,
      fk_block
   );
