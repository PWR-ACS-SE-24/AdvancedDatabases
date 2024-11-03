-- Wygenerowanie wart (patrol slot) w przedziale czasowym (`start_time` - `end_time`) z określonym czasem trwania patrolu w minutach `slot_duration`.

select to_timestamp(:start_time,
             'YYYY-MM-DD HH24:MI:SS') + ( interval '1' minute * :slot_duration * level ) as start_time,
       to_timestamp(:start_time,
                    'YYYY-MM-DD HH24:MI:SS') + ( interval '1' minute * :slot_duration * ( level + 1 ) - interval '1' second )
                    as end_time
  from dual
connect by
   level <= trunc(extract(day from(to_timestamp(:end_time,
        'YYYY-MM-DD HH24:MI:SS') - to_timestamp(:start_time,
        'YYYY-MM-DD HH24:MI:SS')) * 24 * 60) / :slot_duration);
