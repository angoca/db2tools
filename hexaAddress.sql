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
 * Set of routines to convert an hexadecimal IP address into a dot decimal
 * IP address. These functions requires hex3dec functions.
 *
 * HEX01: The hexadecimal value is not valid.
 * 22003: The maximal hexadecimal value is 7F000000 equivalent to 2130706432.
 *
 * Version: 2014-07-01
 * Author: Andres Gomez Casanova (AngocA)
 * Made in COLOMBIA.
 */

/**
  * Converts a given hexadecimal IP address into a dotted quad address.
  * For more information: https://en.wikipedia.org/wiki/Dot-decimal_notation
  *
  * If any of the values is invalid, the SQLSTATE HEX01 will be raised.
  *
  * When the first part of the network is 0 in hexadecimal, DB2 converts this
  * to G. This function accepts a G as the first character.
  *
  * IN HEXA_ADDRESS
  *   IP address in hexadecimal notation to convert.
  * RETURNS IP address in dotted squad notation.
  */
CREATE OR REPLACE FUNCTION CONVERT_IP_HEXA(
  IN HEXA_ADDRESS VARCHAR(8)
  ) RETURNS VARCHAR(15)
  DETERMINISTIC
  NO EXTERNAL ACTION
 BEGIN
  DECLARE NUMBER CHAR(2);
  DECLARE RET VARCHAR(15);
  DECLARE TEMP CHAR(1);

  SET NUMBER = SUBSTR(HEXA_ADDRESS, 1, 2);
  SET TEMP = SUBSTR(NUMBER, 1, 1);
  IF (TEMP = 'G') THEN
   SET NUMBER = '0' || SUBSTR(NUMBER, 2, 1);
  END IF;
  SET RET = HEX_TO_DECIMAL(NUMBER) || '.';
  SET NUMBER = SUBSTR(HEXA_ADDRESS, 3, 2);
  SET RET = RET || HEX_TO_DECIMAL(NUMBER) || '.';
  SET NUMBER = SUBSTR(HEXA_ADDRESS, 5, 2);
  SET RET = RET || HEX_TO_DECIMAL(NUMBER) || '.';
  SET NUMBER = SUBSTR(HEXA_ADDRESS, 7, 2);
  SET RET = RET || HEX_TO_DECIMAL(NUMBER);
  RETURN RET;
 END @

