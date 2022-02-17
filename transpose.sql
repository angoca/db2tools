--#SET TERMINATOR @

/*
 This file is part of db2tools: Set of routines that can ease your daily work
 Copyright (C)  2014  Andres Gomez Casanova (@AngocA)

 db2tools is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 db2tools is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.

 Andres Gomez Casanova <angocaATyahooDOTcom>
*/

/**
 * Transposes a table to see the values in a better display. This stored 
 * procedure requires log4db2.
 *
 * Error codes:
 * PINUL: Tablename is null.
 * PIUNI: Values in first column are not unique.
 * PIMAX: Rows exceed the column quantity limit.
 * PITYP: Invalid column datatype to transpose.
 *
 * Version: 2014-10-28
 * Author: Andres Gomez Casanova (AngocA)
 * Made in COLOMBIA.
 */

/*
-- In order to work correctly, it could be necessary to have user and system
-- temporary tablespaces with 32 page size.
create bufferpool bp32k pagesize 32k @
create user temporary tablespace ut32k pagesize 32k bufferpool bp32k @
create system temporary tablespace st32k pagesize 32k bufferpool bp32k @
*/

/**
 * Transposes the table whose name is passed as parameter.
 *
 * in tablename
 *   Name of the table to transpose. It could include the schema in the 
 * schemaName.tableName format.
 */
create or replace procedure transpose (
  in tablename varchar(128)
  )
 begin
  declare id smallint;
  declare max_precision integer default 0;

  call logger.get_logger('TransposeTable', id);
  call logger.error(id, '> Start');

  -- Checks that the values of the first column are different and not null.
  check_values: begin
   declare sentence varchar(32672);
   declare col_name varchar(128);
   declare qty_diff int;
   declare qty int;
   declare handle integer;
   declare col_count integer;
   declare col dbms_sql.desc_tab;
   declare stmt statement;

   if (tablename is null or tablename = '') then
    signal sqlstate value 'PINUL'
      set message_text = 'Tablename is null or empty';
   else
    call logger.warn(id, 'Transposing: ' || tablename);
   end if;

   call dbms_sql.open_cursor(handle);
   call dbms_sql.parse(handle, 'select * from ' || tablename, dbms_sql.native);
   call dbms_sql.describe_columns(handle, col_count, col);
   set col_name = col[1].col_name;
   call dbms_sql.close_cursor(handle);
   set sentence = 'set ? = (select count(1) from table(select count(1) from '
     || tablename || ' where ' || col_name || ' is not null group by '
     || col_name || '))';
   prepare stmt from sentence;
   execute stmt into qty_diff;
   set sentence = 'set ? = (select count(1) from ' || tablename || ')'  ;
   prepare stmt from sentence;
   execute stmt into qty;
   if (qty_diff <> qty) then
    call logger.fatal(id, 'First column is not unique or it has nulls');
    signal sqlstate value 'PIUNI'
      set message_text = 'First column is not unique or it has nulls';
   end if;
  end check_values;

  -- Tries to transpose the table.
  check_max: begin
   declare rows smallint;
   declare sentence varchar(32672);
   declare col_name varchar(128);
   declare stmt statement;

   set sentence = 'set ? = (select count(1) from ' || tablename || ')';
   prepare stmt from sentence;
   execute stmt into rows;
   call logger.warn(id, 'Rows: ' || rows);
   if (rows > 1012) then
    -- The quantity of rows is bigger that the maximal quantity of columns.
    -- Impossible to transpose.
    call logger.fatal(id, 'Max rows reached');
    signal sqlstate value 'PIMAX'
      set message_text = 'Rows are bigger that max columns';
   end if;
  end check_max;

  -- Retrieves the maximal precision of the row, to create all columns with
  -- that precision.
  max_precision: begin
   declare sentence varchar(32672);
   declare handle integer;
   declare i integer default 2;
   declare col_count integer;
   declare col_type integer;
   declare temp_pres integer;
   declare col dbms_sql.desc_tab;
   declare stmt statement;

   call dbms_sql.open_cursor(handle);
   call dbms_sql.parse(handle, 'select * from ' || tablename, dbms_sql.native);
   call dbms_sql.describe_columns(handle, col_count, col);
   if (col_count > 0) then
    call logger.info(id, 'Retrieving maximal column value');
    fetchLoop: loop
     if (i > col_count) then
      leave fetchLoop;
     end if;
     call logger.debug(id, 'Column ' || i || ', ' || col[i].col_name || ': '
       || col[i].col_max_len || ', ' || col[i].col_type);
     set col_type = col[i].col_type;
     if (col_type = 500 or col_type = 501) then
      -- Smallint.
      set temp_pres = 5;
     elseif (col_type = 496 or col_type = 497) then
      -- Integer.
      set temp_pres = 10;
     elseif (col_type = 492 or col_type = 493) then
      -- Bigint.
      set temp_pres = 19;
     elseif (col_type = 452 or col_type = 453 or col_type = 448
       or col_type = 449) then
      -- Char, varchar.
      set sentence = 'set ? = (select max(length(' || col[i].col_name
        || ')) from ' || tablename || ')';
      prepare stmt from sentence;
      execute stmt into temp_pres;
      --set temp_pres = col[i].col_max_len;
     elseif (col_type = 384 or col_type = 385) then
      -- Date.
      set temp_pres = 11;
     elseif (col_type = 388 or col_type = 389) then
      -- Time.
      set temp_pres = 9;
     elseif (col_type = 392 or col_type = 393) then
      -- Timestamp.
      set temp_pres = 33;
     elseif (col_type = 484 or col_type = 485) then
      -- Decimal.
      set temp_pres = col[i].col_max_len + col[i].col_scale + 1;
     elseif  (col_type = 988 or col_type = 989 or col_type = 916
       or col_type = 917 or col_type = 960 or col_type = 961 or col_type = 404
       or col_type = 405 or col_type = 920 or col_type = 921 or col_type = 964
       or col_type = 965 or col_type = 408 or col_type = 409 or col_type = 456
       or col_type = 457) then
      call logger.fatal(id, 'Invalid data type (' || col_type
        || ') at column ' || col[i].col_name);
      signal sqlstate value 'PITYP'
      set message_text = 'Invalid data type';
     end if;
     if (temp_pres > max_precision) then
      set max_precision = temp_pres;
     end if;
     set i = i + 1;
    end loop;
    call logger.warn(id, 'Columns: ' || i);
    call logger.warn(id, 'Maximal precision: ' || max_precision);
   end if;
   call dbms_sql.close_cursor(handle);
  end max_precision;

  -- Deletes existent session table for transposing.
  drop_current: begin
   declare drop_table varchar(256) default 'drop table session.transpose_temp';
   declare stmt statement;
   declare continue handler for sqlstate '42704' begin end;

   prepare stmt from drop_table;
   execute stmt;
   set drop_table = 'drop table session.transpose';
   prepare stmt from drop_table;
   execute stmt;
  end drop_current;

  -- Transposes the table by creating two temporal tables.
  temp_table: begin
   declare create_table varchar(32672) default
     'create table session.transpose_temp (row varchar(128), ';
   declare sentence varchar(32672);
   declare handle integer;
   declare col_name varchar(128);
   declare at_end boolean default true;
   declare col_count integer;
   declare col dbms_sql.desc_tab;
   declare names_cursor cursor
     for col_names_rs;
   declare continue handler for not found
     set at_end = false;

   call dbms_sql.open_cursor(handle);
   call dbms_sql.parse(handle, 'select * from ' || tablename, dbms_sql.native);
   call dbms_sql.describe_columns(handle, col_count, col);
   set col_name = col[1].col_name;
   call dbms_sql.close_cursor(handle);

   set sentence = 'select ' || col_name || ' from ' || tablename;
   prepare col_names_rs from sentence;
   open names_cursor;
   fetch names_cursor into col_name;
   -- Scans every value of the first column.
   while (at_end != false) do
    call logger.debug(id, 'Row: ' || col_name);
    set create_table = create_table || col_name || ' varchar('
      || max_precision || ')';
    --call logger.debug(id, create_table);
    fetch names_cursor into col_name;
    if (at_end != false) then
     set create_table = create_table || ', ';
    end if;
   end while;
   set create_table = create_table || ')';
   --call logger.debug(id, create_table);
   prepare stmt from create_table;
   execute stmt;
   set create_table = 'create table session.transpose like session.transpose_temp';
   prepare stmt from create_table;
   execute stmt;
  end temp_table;

  -- Fills the temporal table with the values of the source table.
  -- One value per row.
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
   declare statement varchar(32672);
   declare value varchar(32672);
   declare status integer;

   call dbms_sql.open_cursor(handle1);
   call dbms_sql.parse(handle1, 'select * from ' || tablename,
     dbms_sql.native);
   call dbms_sql.describe_columns(handle1, col_count1, col1);
   if (col_count1 > 0) then
    fetchLoop: loop
     if (i > col_count1) then
      leave fetchLoop;
     end if;
     set statement = 'select ' || col1[i].col_name || ' from ' || tablename;
     call logger.info(id, 'Stmt: ''' || statement || '''');
     call dbms_sql.open_cursor(handle2);
     call dbms_sql.parse(handle2, statement, dbms_sql.native);
     call dbms_sql.define_column_varchar(handle2, 1, value, max_precision);
     call dbms_sql.execute(handle2, status);
     set j = 2;
     fetch_loop2: loop
      call dbms_sql.fetch_rows(handle2, status);
      call logger.debug(id, 'Status: ' || status);
      if (status = 0) then
       leave fetch_loop2;
      end if;
      call dbms_sql.column_value_varchar(handle2, 1, value);

      call dbms_sql.open_cursor(handle3);
      call dbms_sql.parse(handle3, 'select * from session.transpose_temp',
        dbms_sql.native);
      call dbms_sql.describe_columns(handle3, col_count2, col2);
      set col_name = col2[j].col_name;
      call dbms_sql.close_cursor(handle3);

      call logger.debug(id, 'Value ' || value);
      call logger.debug(id, 'Col ' || col_name);
      set statement = 'insert into session.transpose_temp (row, ' || col_name
        || ') values (''' || col1[i].col_name || ''', '
        || coalesce ('''' || value || '''', 'null') || ')';
      call logger.info(id, 'Stmt: ''' || statement || '''');
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

  -- Reduces the values to one row per values of a column.
  max: begin
   declare handle integer;
   declare i integer default 2;
   declare col_count integer;
   declare col dbms_sql.desc_tab;
   declare statement varchar(32672);
   declare value varchar(32672);
   declare status integer;
   declare col_group varchar(128);

   call dbms_sql.open_cursor(handle);
   call dbms_sql.parse(handle, 'select * from session.transpose_temp',
     dbms_sql.native);
   call dbms_sql.describe_columns(handle, col_count, col);
   set col_group = col[1].col_name;
   if (col_count > 0) then
    set statement = 'insert into session.transpose select row,';
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
    set statement = statement || ' from session.transpose_temp group by row';
    call logger.debug(id, statement);
    call dbms_sql.close_cursor(handle);
    call dbms_sql.open_cursor(handle);
    call dbms_sql.parse(handle, statement, dbms_sql.native);
    call dbms_sql.execute(handle, status);
    call dbms_sql.close_cursor(handle);
   end if;
  end max;

  call logger.error(id, '< Finished');
 end @

