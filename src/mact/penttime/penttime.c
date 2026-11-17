/* Reconstructed MACT Pentium timing implementation; original notices in headers. */
#include <stdio.h>
#include "types.h"
#include "penttime.h"
#include "timer.h"
extern void PENT_Start(void);
extern void PENT_Stop(void);
extern void ServiceEvents(void);
extern uint32 PENT_timeh, PENT_timel;
static float64 PENT_megahertz;
static uint32 PENT_timer[2];
static float64 PENT_overhead;

void PENT_GetTime(uint32 *value);
void PENT_Init(void)
{
    float64 samples[10], total = 0;
    int32 ticks = 0;
    int32 handle, i;
    PENT_Start();
    PENT_Stop();
    PENT_GetTime(PENT_timer);
    handle = TIME_AddTimer(100, &ticks);
    for (i = 0; i < 10; ++i) {
        ticks = 0;
        PENT_Start();
        while (ticks != 10) ServiceEvents();
        PENT_Stop();
        PENT_GetTime(PENT_timer);
        samples[i] = PENT_Cycles();
    }
    for (i = 0; i < 10; ++i) total += samples[i];
    total *= 0.1;
    PENT_megahertz = total * 10;
    printf("PENT: machine is operating at %f\n", PENT_megahertz * 0.000001);
    TIME_RemoveTimer(handle);
    PENT_Start();
    PENT_Stop();
    PENT_GetTime(PENT_timer);
    PENT_overhead = PENT_Cycles();
}
void PENT_GetTime(uint32 *value)
{
    value[0] = PENT_timeh;
    value[1] = PENT_timel;
}
void PENT_StartTimer(void) { PENT_Start(); }
void PENT_StopTimer(void)
{
    PENT_Stop();
    PENT_timer[0] = PENT_timeh;
    PENT_timer[1] = PENT_timel;
}
float64 PENT_Cycles(void)
{
    return PENT_timer[0] * 4294967296.0 + PENT_timer[1] - PENT_overhead;
}
float64 PENT_Time(void)
{
    return (PENT_timer[0] * 4294967296.0 + PENT_timer[1] - PENT_overhead) / PENT_megahertz;
}
