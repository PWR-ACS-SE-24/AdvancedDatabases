drop inmemory join group p3_prisoner_id_reprimand_fk_prisoner;
alter table reprimand no inmemory ( id,
                                    fk_prisoner );
alter table sentence no inmemory ( id,
                                   fk_prisoner );
