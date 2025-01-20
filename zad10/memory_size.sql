select segment_name,
       inmemory_size,
       populate_status
  from v$im_segments;

select segment_name,
       bytes
  from dba_segments
 where inmemory = 'ENABLED';

alter system set sga_target = 1536M scope = both;
alter system set inmemory_size = 800M scope = both;

show parameter pga_aggregate_target;
show parameter pga_aggregate_limit;
show parameter sga_target;
show parameter sga_max_size;
show parameter memory_target;
show parameter memory_max_target;
show parameter inmemory_size;