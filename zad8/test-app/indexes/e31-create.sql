create table reprimand_clone (
   id          integer,
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
)
   partition by range (
      issue_date
   )
   ( partition p2000
      values less than ( to_date('2001-01-01','YYYY-MM-DD') ),
   partition p2001
      values less than ( to_date('2002-01-01','YYYY-MM-DD') ),
   partition p2002
      values less than ( to_date('2003-01-01','YYYY-MM-DD') ),
   partition p2003
      values less than ( to_date('2004-01-01','YYYY-MM-DD') ),
   partition p2004
      values less than ( to_date('2005-01-01','YYYY-MM-DD') ),
   partition p2005
      values less than ( to_date('2006-01-01','YYYY-MM-DD') ),
   partition p2006
      values less than ( to_date('2007-01-01','YYYY-MM-DD') ),
   partition p2007
      values less than ( to_date('2008-01-01','YYYY-MM-DD') ),
   partition p2008
      values less than ( to_date('2009-01-01','YYYY-MM-DD') ),
   partition p2009
      values less than ( to_date('2010-01-01','YYYY-MM-DD') ),
   partition p2010
      values less than ( to_date('2011-01-01','YYYY-MM-DD') ),
   partition p2011
      values less than ( to_date('2012-01-01','YYYY-MM-DD') ),
   partition p2012
      values less than ( to_date('2013-01-01','YYYY-MM-DD') ),
   partition p2013
      values less than ( to_date('2014-01-01','YYYY-MM-DD') ),
   partition p2014
      values less than ( to_date('2015-01-01','YYYY-MM-DD') ),
   partition p2015
      values less than ( to_date('2016-01-01','YYYY-MM-DD') ),
   partition p2016
      values less than ( to_date('2017-01-01','YYYY-MM-DD') ),
   partition p2017
      values less than ( to_date('2018-01-01','YYYY-MM-DD') ),
   partition p2018
      values less than ( to_date('2019-01-01','YYYY-MM-DD') ),
   partition p2019
      values less than ( to_date('2020-01-01','YYYY-MM-DD') ),
   partition p2020
      values less than ( to_date('2021-01-01','YYYY-MM-DD') ),
   partition p2021
      values less than ( to_date('2022-01-01','YYYY-MM-DD') ),
   partition p2022
      values less than ( to_date('2023-01-01','YYYY-MM-DD') ),
   partition p2023
      values less than ( to_date('2024-01-01','YYYY-MM-DD') ),
   partition p2024
      values less than ( to_date('2025-01-01','YYYY-MM-DD') )
   );

insert into reprimand_clone
   select *
     from reprimand;
