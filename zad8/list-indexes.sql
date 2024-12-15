select *
  from all_indexes
 where lower(table_name) in ( 'prison_block',
                              'patrol',
                              'guard',
                              'cell',
                              'patrol_slot',
                              'reprimand',
                              'accommodation',
                              'prisoner',
                              'sentence' );

-- IMPORTANT, DO NOT REMOVE
create index patrol_fk_patrol_slot_idx on
   patrol (
      fk_patrol_slot
   );
