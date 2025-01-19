select segment_name,
       inmemory_size,
       populate_status
  from v$im_segments;

select segment_name,
       bytes
  from dba_segments
 where inmemory = 'ENABLED';
