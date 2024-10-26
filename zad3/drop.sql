begin
   begin
      execute immediate 'drop table reprimand';
   exception
      when others then
         if sqlcode != -942 then
            raise;
         end if;
   end;

   begin
      execute immediate 'drop table patrol';
   exception
      when others then
         if sqlcode != -942 then
            raise;
         end if;
   end;

   begin
      execute immediate 'drop table sentence';
   exception
      when others then
         if sqlcode != -942 then
            raise;
         end if;
   end;

   begin
      execute immediate 'drop table accommodation';
   exception
      when others then
         if sqlcode != -942 then
            raise;
         end if;
   end;

   begin
      execute immediate 'drop table cell';
   exception
      when others then
         if sqlcode != -942 then
            raise;
         end if;
   end;

   begin
      execute immediate 'drop table patrol_slot';
   exception
      when others then
         if sqlcode != -942 then
            raise;
         end if;
   end;

   begin
      execute immediate 'drop table guard';
   exception
      when others then
         if sqlcode != -942 then
            raise;
         end if;
   end;

   begin
      execute immediate 'drop table prison_block';
   exception
      when others then
         if sqlcode != -942 then
            raise;
         end if;
   end;

   begin
      execute immediate 'drop table prisoner';
   exception
      when others then
         if sqlcode != -942 then
            raise;
         end if;
   end;
end;
