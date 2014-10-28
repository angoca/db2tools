--#SET TERMINATOR @

/*
 This file is part of db2tools: Set of routines that can ease your daily work
 Copyright (C)  2014  Andres Gomez Casanova (@AngocA)

 db2unit is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 db2unit is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.

 Andres Gomez Casanova <angocaATyahooDOTcom>
*/

/**
 * Checks prerequisites.
 *
 * Version: 2014-10-28
 * Author: Andres Gomez Casanova (AngocA)
 * Made in COLOMBIA.
 */

--create table my_table (names varchar(16), amt1 int, amt2 int) @
--insert into my_table values
--  ('Mike', 6000, 5000),
--  ('Jerry', 1000, 10),
--  ('King', 500, 2000),
--  ('Mary',400,5000),
--  ('Harry',100,500) @
--create user temporary tablespace ut4k pagesize 4k @
 
create or replace procedure test ()
begin
 
declare id smallint;
declare rows smallint;
declare col_name varchar(128);
declare sentence varchar(128);
declare max_precision integer default 0;
declare max_cols smallint;
declare at_end boolean default true;
declare names_cursor cursor
   for col_names_rs;
declare continue handler for not found
   set at_end = false;
 
call logger.get_logger('test', id);
call logger.error(id, '>Start');
 
max_precision: begin
  declare handle integer;
  declare i integer default 2;
  declare col_count integer;
  declare col dbms_sql.desc_tab;
  call dbms_sql.open_cursor(handle);
  call dbms_sql.parse(handle, 'select * from my_table', dbms_sql.native);
  call dbms_sql.describe_columns(handle, col_count, col);
  if (col_count > 0) then
   call logger.warn(id, 'Retrieving max col value');
   fetchLoop: loop
    if (i > col_count) then
     leave fetchLoop;
    end if;
    call logger.debug(id, 'Column ' || i || ', ' || col[i].col_name || ': '
      ||col[i].col_max_len);
    if (col[i].col_max_len > max_precision) then
     set max_precision = col[i].col_max_len;
    end if;
    set i = i + 1;
   end loop;
   set max_cols = i;
   call logger.warn(id, 'Max precision ' || max_precision);
   call logger.warn(id, 'Max columns  ' || max_cols);
  end if;
  call dbms_sql.close_cursor(handle);
end max_precision;
 
drop_current: begin
  declare drop_table varchar(256) default 'drop table session.pivot';
  declare stmt statement;
  declare continue handler for sqlstate '42704' begin end;
  prepare stmt from drop_table;
  execute stmt;
  set drop_table = 'drop table session.pivot2';
  prepare stmt from drop_table;
  execute stmt;
end drop_current;
 
pivot_table: begin
  declare stmt statement;
  set rows = (select count(1) from my_table);
  call logger.warn(id, 'Rows: ' || rows);
  if (rows > 1012) then
   call logger.error(id, 'Max rows');
  else
 
   temp_table: begin
    declare create_table varchar(1024) default 'create table session.pivot (row varchar(128), ';
 
    set sentence = 'select names from my_table';
    prepare col_names_rs from sentence;
    open names_cursor;
    fetch names_cursor into col_name;
    while (at_end != false) do
     call logger.debug(id, 'Row: ' || col_name);
     set create_table = create_table || col_name || ' varchar(' || max_precision
       || ')';
     call logger.debug(id, create_table);
     fetch names_cursor into col_name;
     if (at_end != false) then
      set create_table = create_table || ', ';
     end if;
    end while;
    set create_table = create_table || ')';
    call logger.warn(id, create_table);
    prepare stmt from create_table;
    execute stmt;
    set create_table = 'create table session.pivot2 like session.pivot';
    prepare stmt from create_table;
    execute stmt;
   end temp_table;
 
   fill: begin
    declare handle1 integer;
    declare handle2 integer;
    declare handle3 integer;
    declare col_count1 integer;
    declare col_count2 integer;
    declare col1 dbms_sql.desc_tab;
    declare col2 dbms_sql.desc_tab;
    declare col_name varchar(128);
    declare i integer default 2;
    declare j integer default 1;
    declare statement varchar(256);
    declare value varchar(32672);
    declare status integer;
 
    call dbms_sql.open_cursor(handle1);
    call dbms_sql.parse(handle1, 'select * from my_table', dbms_sql.native);
    call dbms_sql.describe_columns(handle1, col_count1, col1);
    if (col_count1 > 0) then
     fetchLoop: loop
      if (i > col_count1) then
       leave fetchLoop;
      end if;
      set statement = 'select ' || col1[i].col_name || ' from my_table';
      call logger.warn(id, 'Statement ' || statement);
      call dbms_sql.open_cursor(handle2);
      call dbms_sql.parse(handle2, statement, dbms_sql.native);
      call dbms_sql.define_column_varchar(handle2, 1, value, max_precision);
      call dbms_sql.execute(handle2, status);
      set j = 2;
      fetch_loop2: loop
       call dbms_sql.fetch_rows(handle2, status);
       call logger.warn(id, 'Status ' || status);
       if (status = 0) then
        leave fetch_loop2;
       end if;
       call dbms_sql.column_value_varchar(handle2, 1, value);
 
       call dbms_sql.open_cursor(handle3);
       call dbms_sql.parse(handle3, 'select * from session.pivot', dbms_sql.native);
       call dbms_sql.describe_columns(handle3, col_count2, col2);
       set col_name = col2[j].col_name;
       call dbms_sql.close_cursor(handle3);
 
       call logger.debug(id, 'Value ' || value);
       call logger.debug(id, 'Col ' || col_name);
       set statement = 'insert into session.pivot (row, ' || col_name || ') values (''' || col1[i].col_name || ''', ''' || value || ''')';
       call logger.info(id, 'Stmt ' || statement);
       prepare stmt from statement;
       execute stmt;
       set j = j + 1;
      end loop fetch_loop2;
      set i = i + 1;
      call dbms_sql.close_cursor(handle2);
     end loop;
    end if;
    call dbms_sql.close_cursor(handle1);
   end fill;
 
   max: begin
    declare handle integer;
    declare i integer default 2;
    declare col_count integer;
    declare col dbms_sql.desc_tab;
    declare statement varchar(256);
    declare value varchar(32672);
    declare status integer;
    declare col_group varchar(32672);
 
    call dbms_sql.open_cursor(handle);
    call dbms_sql.parse(handle, 'select * from session.pivot', dbms_sql.native);
    call dbms_sql.describe_columns(handle, col_count, col);
    set col_group = col[1].col_name;
    if (col_count > 0) then
     set statement = 'insert into session.pivot2 select row,';
     fetchLoop: loop
      if (i > col_count) then
       leave fetchLoop;
      end if;
      set statement = statement || ' max(' || col[i].col_name || ')';
      if (i <> col_count) then
       set statement = statement || ',';
      end if;
      call logger.debug(id, statement);
      set i = i + 1;
     end loop;
     set statement = statement || ' from session.pivot group by row';
     call logger.debug(id, statement);
     call dbms_sql.close_cursor(handle);
     call dbms_sql.open_cursor(handle);
     call dbms_sql.parse(handle, statement, dbms_sql.native);
     call dbms_sql.execute(handle, status);
     call dbms_sql.close_cursor(handle);
    end if;
   end max;
  end if;
end pivot_table;
 
call logger.error(id, '<Finished');
end @
call test() @
select * from session.pivot @
select * from session.pivot2 @
 

