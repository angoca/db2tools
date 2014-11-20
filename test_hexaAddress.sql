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
 * Tests for the hex2decimal functions.
 *
 * Version: 2014-07-01
 * Author: Andres Gomez Casanova (AngocA)
 * Made in COLOMBIA.
 */

-- Tests Hexa values
-- 10.1.0.70
values CONVERT_IP_HEXA('0A010046');
-- 10.1.0.71 The first level represents also a 0 in DB2.
values CONVERT_IP_HEXA('GA010047');

-- Test the extraction of IP addresses from an application ID.
-- 10.1.11.131
values get_address('10.1.11.131.3515.141120023017');
-- 10.1.15.185
values get_address('10.1.15.185.4782.141120144011');
-- 10.1.0.70
values get_address('0A010046.C23B.141120144312');
-- 127.0.0.1
values get_address('*LOCAL.imag107p.141120142800');

