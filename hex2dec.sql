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
 * Set of routines to convert an hexadecimal value into decimal.
 *
 * HEX01: The hexadecimal value is not valid.
 * 22003: The maximal hexadecimal value is 7F000000 equivalent to 2130706432.
 *
 * Version: 2014-07-01
 * Author: Andres Gomez Casanova (AngocA)
 * Made in COLOMBIA.
 */

/**
 * Converts a hexadecimal digit into decimal digit. The values are stored
 * as characters. The values could be in upper or lower case.
 *
 * If a given value is given, the HEX01 signal will be raised.
 *
 * IN HEXA
 *   Hexadecimal value to process.
 * RETURNS Decimal representation of the given value.
 */
CREATE OR REPLACE FUNCTION CONVERT_HEXA (
  IN HEXA CHAR(1)
  ) RETURNS SMALLINT
  DETERMINISTIC
  NO EXTERNAL ACTION
 BEGIN
  DECLARE RET SMALLINT;
  DECLARE MESSAGE VARCHAR(70);
  SET HEXA = UPPER(HEXA);
  CASE HEXA
    WHEN '0' THEN
     SET RET = 0;
    WHEN '1' THEN
     SET RET = 1;
    WHEN '2' THEN
     SET RET = 2;
    WHEN '3' THEN
     SET RET = 3;
    WHEN '4' THEN
     SET RET = 4;
    WHEN '5' THEN
     SET RET = 5;
    WHEN '6' THEN
     SET RET = 6;
    WHEN '7' THEN
     SET RET = 7;
    WHEN '8' THEN
     SET RET = 8;
    WHEN '9' THEN
     SET RET = 9;
    WHEN 'A' THEN
     SET RET = 10;
    WHEN 'B' THEN
     SET RET = 11;
    WHEN 'C' THEN
     SET RET = 12;
    WHEN 'D' THEN
     SET RET = 13;
    WHEN 'E' THEN
     SET RET = 14;
    WHEN 'F' THEN
     SET RET = 15;
    ELSE
     SET MESSAGE = 'Invalid value for an hexadecimal: ' || HEXA;
     SIGNAL SQLSTATE 'HEX01'
       SET MESSAGE_TEXT = MESSAGE;
  END CASE;
  RETURN RET;  
 END @

/**
  * Converts a hexadecimal value into a decimal value. If any of the
  * hexadecimal digits is invalid, the HEX01 signal will be raised.
  *
  * For more information about the conversion:
  * http://www.wikihow.com/Convert-Hexadecimal-to-Binary-or-Decimal
  *
  * The maximum hexadecimal value is 7F000000. If a bigger value is passed,
  * the SQLSTATE 22003 will be raised.
  *
  * IN HEXA
  *  Hexadecimal value to convert.
  * RETURN a bigint that represents the given value.
  */
CREATE OR REPLACE FUNCTION HEX_TO_DECIMAL (
  IN HEXA VARCHAR(8)
  ) RETURNS BIGINT
  DETERMINISTIC
  NO EXTERNAL ACTION
 BEGIN
  DECLARE LENGTH SMALLINT;
  DECLARE INDEX SMALLINT;
  DECLARE DIGIT BIGINT;
  DECLARE RET BIGINT;
  DECLARE EXIT HANDLER FOR SQLSTATE '22003'
    RESIGNAL 
    SET MESSAGE_TEXT = 'Max value for hexadecimal is ''7F000000''';

  SET LENGTH = LENGTH(HEXA);
  SET INDEX = 1;
  SET RET = 0;
  WHILE (INDEX <= LENGTH) DO
   SET DIGIT = CONVERT_HEXA(SUBSTR(HEXA, INDEX, 1))
     * POWER (16, LENGTH - INDEX);
   SET RET = RET + DIGIT;
   SET INDEX = INDEX + 1;
  END WHILE;
  RETURN RET;
 END @

