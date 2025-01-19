alter table sentence inmemory ( id,
                                fk_prisoner );
alter table reprimand inmemory ( id,
                                 fk_prisoner );
create inmemory join group p3_prisoner_id_sentence_fk_prisoner ( prisoner ( id ),sentence ( fk_prisoner ) );
