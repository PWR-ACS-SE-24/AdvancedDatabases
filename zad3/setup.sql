-- STRONG ENTITIES

create table prisoner (
   id         integer
      generated always as identity,
   pesel      char(11) unique not null,
   first_name varchar(255) not null,
   last_name  varchar(255) not null,
   birthday   date not null,
   sex        integer not null, -- https://en.wikipedia.org/wiki/ISO/IEC_5218
   height_m   numeric(3,2) not null,
   weight_kg  numeric(3) not null,
   primary key ( id ),
   check ( length(pesel) = 11 ),
   check ( first_name <> '' ),
   check ( last_name <> '' ),
      check ( sex = 0 -- Not known
          or sex = 1 -- Male
          or sex = 2 -- Female
          or sex = 9 ), -- Not applicable
   check ( height_m > 0 ),
   check ( weight_kg > 0 )
);

create table prison_block (
   id               integer
      generated always as identity,
   block_number     varchar(2) unique not null,
   shower_count     integer not null,
   additional_notes varchar(2000),
   primary key ( id ),
   check ( shower_count >= 0 ),
   check ( block_number <> '' )
);

create table guard (
   id                   integer
      generated always as identity,
   first_name           varchar(255) not null,
   last_name            varchar(255) not null,
   employment_date      date not null,
   dismissal_date       date,
   has_disability_class number(1) not null,
   monthly_salary_pln   numeric(8,2) not null,
   primary key ( id ),
   check ( first_name <> '' ),
   check ( last_name <> '' ),
      check ( dismissal_date is null
          or dismissal_date >= employment_date ),
   check ( has_disability_class in ( 0,
                                     1 ) ),
   check ( monthly_salary_pln >= 0 )
);

create table patrol_slot (
   id         integer
      generated always as identity,
   start_time timestamp not null,
   end_time   timestamp not null,
   primary key ( id ),
   check ( end_time > start_time )
);

-- -- WEAK ENTITIES

create table cell (
   id               integer
      generated always as identity,
   fk_block         integer not null,
   cell_number      integer not null,
   place_count      integer not null,
   is_solitary      number(1) not null,
   additional_notes varchar(2000),
   primary key ( id ),
   foreign key ( fk_block )
      references prison_block ( id ),
   check ( cell_number >= 1 ),
   check ( place_count >= 1 ),
   check ( is_solitary in ( 0,
                            1 ) ),
   check ( is_solitary = 0
       or place_count = 1 )
);

create table accommodation (
   id          integer
      generated always as identity,
   fk_cell     integer not null,
   fk_prisoner integer not null,
   start_date  date not null,
   end_date    date,
   primary key ( id ),
   foreign key ( fk_cell )
      references cell ( id ),
   foreign key ( fk_prisoner )
      references prisoner ( id ),
      check ( end_date is null
          or end_date >= start_date )
);

create table sentence (
   id               integer
      generated always as identity,
   fk_prisoner      integer not null,
   crime            varchar(1000) not null,
   start_date       date not null,
   planned_end_date date not null,
   real_end_date    date,
   primary key ( id ),
   foreign key ( fk_prisoner )
      references prisoner ( id ),
   check ( crime <> '' ),
   check ( planned_end_date >= start_date ),
      check ( real_end_date is null
          or real_end_date >= start_date )
);

create table patrol (
   id             integer
      generated always as identity,
   fk_guard       integer not null,
   fk_block       integer not null,
   fk_patrol_slot integer not null,
   is_with_dog    number(1) not null,
   primary key ( id ),
   foreign key ( fk_guard )
      references guard ( id ),
   foreign key ( fk_block )
      references prison_block ( id ),
   foreign key ( fk_patrol_slot )
      references patrol_slot ( id ),
   check ( is_with_dog in ( 0,
                            1 ) )
);

create table reprimand (
   id          integer
      generated always as identity,
   fk_guard    integer not null,
   fk_prisoner integer not null,
   reason      varchar(2000) not null,
   issue_date  date not null,
   primary key ( id ),
   foreign key ( fk_guard )
      references guard ( id ),
   foreign key ( fk_prisoner )
      references prisoner ( id ),
   check ( reason <> '' )
);