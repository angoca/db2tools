drop table my_table @
create table my_table (names varchar(16), amt1 int, amt2 int) @
insert into my_table values
  ('Mike', 6000, 5000),
  ('Jerry', 1000, 10),
  ('King', 500, 2000),
  ('Mary',400,5000),
  ('Harry',100,500) @
call pivot('my_table') @
select * from session.pivot_temp @
select * from session.pivot @

call pivot('syscat.schemata') @
select * from session.pivot_temp @
select * from session.pivot @
select * from syscat.schemata


drop table test2 @
create table test2 (names varchar(16), amt1 int, amt2 int) @
insert into test2 values
  ('Mike', 6000, 5000),
  ('Jerry', 1000, 10),
  ('King', 500, 2000),
  ('Mary',400,5000),
  ('Mike', 400, 500),
  ('Harry',100,500) @
call pivot('test2') @
select * from session.pivot_temp @
select * from session.pivot @


drop table test3 @
create table test3 (names varchar(16), amt1 int, amt2 int) @
insert into test3 values
  ('Mike', 6000, 5000),
  ('Jerry', 1000, 10),
  ('King', 500, 2000),
  ('Mary',400,5000),
  (null,100,500) @
call pivot('test3') @
select * from session.pivot_temp @
select * from session.pivot @
