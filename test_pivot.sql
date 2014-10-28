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

call pivot('syscat.schemata');
select * from session.pivot_temp;
select * from session.pivot;


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

