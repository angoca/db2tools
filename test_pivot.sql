--#SET TERMINATOR ;

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
 * Tests for the pivot procedure.
 *
 * Version: 2014-10-28
 * Author: Andres Gomez Casanova (AngocA)
 * Made in COLOMBIA.
 */

-- Test a real table.
call pivot('syscat.bufferpools');
select * from session.pivot_temp;
select * from session.pivot;


call pivot(null);
call pivot('');


-- Test an example table.
drop table test1;
create table test1 (names varchar(16), amt1 int, amt2 int);
insert into test1 values
  ('Mike', 6000, 5000),
  ('Jerry', 1000, 10),
  ('King', 500, 2000),
  ('Mary', 400, 5000),
  ('Harry', 100, 500);
call pivot('test1');
select * from session.pivot_temp;
select * from session.pivot;


-- Test a double in first column (error).
drop table test2;
create table test2 (names varchar(16), amt1 int, amt2 int);
insert into test2 values
  ('Mike', 6000, 5000),
  ('Jerry', 1000, 10),
  ('King', 500, 2000),
  ('Mary', 400, 5000),
  ('Mike', 400, 500),
  ('Harry', 100, 500);
call pivot('test2');
select * from session.pivot_temp;
select * from session.pivot;


-- Test a null in the first column (error).
drop table test3;
create table test3 (names varchar(16), amt1 int, amt2 int);
insert into test3 values
  ('Mike', 6000, 5000),
  ('Jerry', 1000, 10),
  ('King', 500, 2000),
  ('Mary', 400, 5000),
  (null, 100, 500);
call pivot('test3');
select * from session.pivot_temp;
select * from session.pivot;


-- Test a null value in another column.
drop table test4;
create table test4 (names varchar(16), amt1 int, amt2 int);
insert into test4 values
  ('Mike', 6000, 5000),
  ('Jerry', 1000, 10),
  ('King', 500, 2000),
  ('Mary', null, 5000),
  ('Harry', 100, 500);
call pivot('test4');
select * from session.pivot_temp;
select * from session.pivot;


-- Test limit of integer.
drop table test5;
create table test5 (names varchar(16), amt1 int, amt2 int);
insert into test5 values
  ('Mike', 2147483647, 2147483647),
  ('Jerry', 2147483647, 2147483647),
  ('King', 500, 2000),
  ('Mary', 400, 5000),
  ('Harry', 100, 500);
call pivot('test5');
select * from session.pivot_temp;
select * from session.pivot;


-- Test precision of other datatypes.
drop table test6;
create table test6 (names varchar(16), amt1 int, date date,
  timestamp timestamp, value dec(5,2));
insert into test6 values
  ('Mike', 2147483647, '2014-10-29', current timestamp, 5.4),
  ('Jerry', 2147483647, '2014-10-20', current timestamp, 4),
  ('King', 500, '2014-10-09', current timestamp, 123.45),
  ('Mary', 400, '2010-10-29', current timestamp, 12.1),
  ('Harry', 100, '2004-10-29', current timestamp, 3.65);
call pivot('test6');
select * from session.pivot_temp;
select * from session.pivot;


-- Test decimal values.
drop table test7;
create table test7 (names char(5), value dec(5,2));
insert into test7 values
  ('Mike', 5.4),
  ('Jerry', 4),
  ('King', 123.45),
  ('Mary', 12.1),
  ('Harry', 3.65);
call pivot('test7');
select * from session.pivot_temp;
select * from session.pivot;


-- Test a table with a lot of rows.
drop table test8;
create table test8 (name1 varchar(512), name2 varchar(512), name3 varchar(512),
  name4 varchar(512), name5 varchar(512), name6 varchar(512),
  name7 varchar(512), name8 varchar(512));
insert into test8 values
  ('Mike1', 'Mike2', 'Mike3', 'Mike4', 'Mike5', 'Mike6', 'Mike7', 'Mike8'),
  ('Jerry1', 'Jerry2', 'Jerry3', 'Jerry4', 'Jerry5', 'Jerry6', 'Jerry7', 'Jerry8'),
  ('King1', 'King2', 'King3', 'King4', 'King5', 'King6', 'King7', 'King8'),
  ('Mary', 'Mary', 'Mary', 'Mary', 'Mary', 'Mary', 'Mary', 'Mary');
call pivot('test8');
select * from session.pivot_temp;
select * from session.pivot;


-- Test row limit.
drop table test9;
create table test9 (name1 varchar(512), name2 varchar(479), val int);
insert into test9 values
  ('Mike1', 'Mike', 1),
  ('Jerry1', 'Jerry', 2),
  ('King1', 'King', 3),
  ('Mary1', 'Mary', 4),
  ('Mike2', 'Mike', 1),
  ('Jerry2', 'Jerry', 2),
  ('King2', 'King', 3),
  ('Mary2', 'Mary', 3);
call pivot('test9');
select * from session.pivot_temp;
select * from session.pivot;


-- Test row limit.
drop table test10;
create table test10 (name1 varchar(512), name2 varchar(32672));
insert into test10 values
  ('Mike1', 'Mike'),
  ('Jerry1', 'Jerry'),
  ('King1', 'King'),
  ('Mary1', 'Mary');
call pivot('test10');
select * from session.pivot_temp;
select * from session.pivot;

