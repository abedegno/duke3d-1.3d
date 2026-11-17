/* Reconstructed MACT DOS timing body; primary API/notices in types.h and timelib.h. */
#include <dos.h>
#include "types.h"
#include "timelib.h"

int32 starttics, stoptics;

int32 I_Time(void)
{
    struct dostime_t time;
    _dos_gettime(&time);
    return time.hour * 3600000 + time.minute * 60000 +
           time.second * 1000 + time.hsecond * 10;
}

void TIMELIB_StartTiming(void)
{
    starttics = I_Time();
}

int32 TIMELIB_StopTiming(void)
{
    stoptics = I_Time();
    return stoptics - starttics;
}
