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

-- Test to convert hex digits.
values convert_hexa('0');
values convert_hexa('1');
values convert_hexa('5');
values convert_hexa('9');
values convert_hexa('A');
values convert_hexa('F');
values convert_hexa('a');

values convert_hexa('G');
values convert_hexa('10');

-- Test to convert hexa numbers.
values hex_to_decimal('0');
values hex_to_decimal('10');
values hex_to_decimal('A');
values hex_to_decimal('F');
values hex_to_decimal('FFFF');
values hex_to_decimal('7F000000');

values hex_to_decimal('FFFFFFFF');

