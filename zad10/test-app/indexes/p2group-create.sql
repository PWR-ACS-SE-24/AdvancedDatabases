alter table guard inmemory priority critical;
create inmemory join group p2_guard_patrol_join_group ( guard ( id ),patrol ( fk_guard ) );
create inmemory join group p2_patrol_patrol_slot_join_group ( patrol ( fk_patrol_slot ),patrol_slot ( id ) );
