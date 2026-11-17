/*
 * Copyright (C) 1996, 2003 - 3D Realms Entertainment
 * Derived from released source/GAME.C timer routines and TASK_MAN.H.
 * GPL-2.0-or-later; see dukenukem3d/GNU.TXT.
 * Isolated matching unit; complete GAME.C data layout is still outstanding.
 */
typedef struct task task;
extern volatile long totalclock;
task *TS_ScheduleTask(void (*Function)(task *),int rate,int priority,void *data);
void TS_Dispatch(void);
int TS_Terminate(task *ptr);
void TS_Shutdown(void);

#define TICRATE 120
#define NULL ((void *)0)
task *TimerPtr=NULL;

void timerhandler()
{
    totalclock++;
}

void inittimer()
{
    TimerPtr = TS_ScheduleTask( timerhandler,TICRATE, 1, NULL );
    TS_Dispatch();
}

void uninittimer(void)
{
   if (TimerPtr)
      TS_Terminate( TimerPtr );
   TimerPtr = NULL;
   TS_Shutdown();
}
