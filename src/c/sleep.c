#define win

#ifdef win
  #include <windows.h>
#else
  #include <unistd.h>
#endif

#include <sqludf.h>
#include <sqlca.h>
/**
 * File for the sleep function.
 * Taken from SQLTips4DB2LUW blog, written by Serge Rielau.
 * https://www.ibm.com/developerworks/community/blogs/SQLTips4DB2LUW/entry/sleep?lang=en
 */

/*************************************************************************
 *  function sleep: Sleep for at least seconds
 *
 *     inputs :   seconds to sleep
 *************************************************************************/

#ifdef __cplusplus
extern "C"
#endif

 SQL_API_RC SQL_API_FN sleep_sec(
     SQLUDF_INTEGER   *sec,
     SQLUDF_SMALLINT  *secNullInd,
     SQLUDF_TRAIL_ARGS)
{
 if (*secNullInd != -1 && sec > 0)
  {
#ifdef win
    Sleep(*sec * 1000);
#else
    sleep(*sec);
#endif
  }
  return (0);
}
