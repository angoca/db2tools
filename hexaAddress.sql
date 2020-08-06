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

/**
  * Retrieves the IP Address from an application ID. The first part of the
  * app id is the IP address. However, the notation could be squad dotted
  * or hexadecimal. This function retrieves all addresses in squad dotted
  * notation.
  *
  * If the connection is local, it will return 127.0.0.10.
  *
  * IN APP_ID
  *   Application ID.
  * RETURNS Address IP.
  */
CREATE OR REPLACE FUNCTION GET_ADDRESS (
  IN APP_ID VARCHAR(128)
  ) RETURNS VARCHAR(128)
  DETERMINISTIC
  NO EXTERNAL ACTION
 BEGIN
  DECLARE LOGGER_ID SMALLINT;
  DECLARE ADDRESS VARCHAR(15);
  DECLARE POS SMALLINT;
  DECLARE TOTAL_POS SMALLINT;
  DECLARE IP_ADDR VARCHAR(128);
  
  SET ADDRESS = APP_ID;
  SET POS = POSSTR(ADDRESS, '.');
  IF (POS IS NULL OR POS = 0) THEN
   SET IP_ADDR = NULL;
  ELSEIF (POS <= 5) THEN
   SET TOTAL_POS = POS;
   SET ADDRESS = SUBSTR(ADDRESS, POS + 1);
   SET POS = POSSTR(ADDRESS, '.');
   SET TOTAL_POS = TOTAL_POS + POS;
   SET ADDRESS = SUBSTR(ADDRESS, POS + 1);
   SET POS = POSSTR(ADDRESS, '.');
   SET TOTAL_POS = TOTAL_POS + POS;
   SET ADDRESS = SUBSTR(ADDRESS, POS + 1);
   SET POS = POSSTR(ADDRESS, '.');
   SET TOTAL_POS = TOTAL_POS + POS;
   SET IP_ADDR = SUBSTR(APP_ID, 1, TOTAL_POS - 1);
  ELSEIF (POS = 7) THEN
   SET ADDRESS = SUBSTR(ADDRESS, 1, POS - 1);
   IF (ADDRESS = '*LOCAL') THEN
    -- Local connexion
    SET IP_ADDR = '127.0.0.1';
   ELSE
    SET IP_ADDR = ADDRESS;
   END IF;
  ELSEIF (POS = 9) THEN
   -- Connexion from old DB2 client.
   SET ADDRESS = SUBSTR(APP_ID, 1, 8);
   SET IP_ADDR = CONVERT_IP_HEXA(ADDRESS);
  ELSE
   SET IP_ADDR = NULL;
  END IF;
  RETURN IP_ADDR;
 END @

