//-------------------------------------------------------------------------
/*
Copyright (C) 1996, 2003 - 3D Realms Entertainment

This file is NOT part of Duke Nukem 3D version 1.5 - Atomic Edition
However, it is either an older version of a file that is, or is
some test code written during the development of Duke Nukem 3D.
This file is provided purely for educational interest.

Duke Nukem 3D is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

Prepared for public release: 03/21/2003 - Charlie Wiederhold, 3D Realms
*/
//-------------------------------------------------------------------------

/* Authored complete MACT DEBUG semantic reconstruction, not the unrelated
 * released RBG DEBUG.C or a claim of historical source spelling. Primary API
 * and output_t remain unchanged. Preserve the native suppression predicate,
 * unbounded vsprintf/late check and empty-string before-buffer read; no repair.
 */
#include <stdarg.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/types.h>
#include "types.h"
#include "develop.h"
#include "debug.h"
#include "_debug.h"
#include "util_lib.h"
#include "file_lib.h"

void DBG_ScreenPrint(char *message);
void DBG_FileStartup(void);
void DBG_FilePrint(char *message);
void DBG_FileShutdown(void);
void DBG_CloseDebugOutput(void);
void DBG_StartDebugOutput(void);

static int32 DBG_DebugLevel=debug_normal;
static int32 DBG_DebugMode=dbgmode_level;
static int32 DBG_DebugMask[debug_max+1]={0};
static boolean DBG_Started=false;
static int32 DBG_OutMode=dbgout_screen;
static boolean DBG_FileOutputStarted=false;
static output_t DBG_Out[dbgout_endtype]={
 {NULL,DBG_ScreenPrint,NULL},
 {DBG_FileStartup,DBG_FilePrint,DBG_FileShutdown},
 {NULL,NULL,NULL},{NULL,NULL,NULL}
};
static int32 DBG_FileOutputHandle;

typedef char Required32BitOutput[(sizeof(int32)==4 && sizeof(output_t)==12 &&
 sizeof(DBG_DebugMask)==84 && sizeof(DBG_Out)==48)?1:-1];

void DBG_ScreenPrint(char *message) { printf("%s",message); }
void DBG_FileStartup(void)
{
 if (!DBG_FileOutputStarted) {
  DBG_FileOutputHandle=SafeOpenWrite(DEBUGFILE,filetype_text);
  DBG_FileOutputStarted=true;
 }
}
void DBG_FilePrint(char *message)
{ SafeWrite(DBG_FileOutputHandle,message,strlen(message)); }
void DBG_FileShutdown(void)
{
 if (DBG_FileOutputStarted) {
  SafeClose(DBG_FileOutputHandle);DBG_FileOutputStarted=false;
 }
}
void DBG_CloseDebugOutput(void)
{ if (DBG_Out[DBG_OutMode].shutdown) DBG_Out[DBG_OutMode].shutdown(); }
void DBG_StartDebugOutput(void)
{ if (DBG_Out[DBG_OutMode].startup) DBG_Out[DBG_OutMode].startup(); }
void DBG_SetDebugLevel(int32 level) { DBG_DebugLevel=level; }
int32 DBG_GetDebugLevel(void) { return DBG_DebugLevel; }
void DBG_EnableDebugLevel(int32 level) { DBG_DebugMask[level]=true; }
void DBG_DisableDebugLevel(int32 level) { DBG_DebugMask[level]=false; }
void DBG_DisableAllDebugLevels(void) { memset(DBG_DebugMask,0,sizeof(DBG_DebugMask)); }
void DBG_SetDebugMode(int32 mode) { DBG_DebugMode=mode; }
int32 DBG_GetDebugMode(void) { return DBG_DebugMode; }
void DBG_SetDebugOutputMode(int32 mode)
{ DBG_CloseDebugOutput();DBG_OutMode=mode;DBG_StartDebugOutput(); }
int32 DBG_GetDebugOutputMode(void) { return DBG_OutMode; }

void DBG_DebugString(int32 level,char *message,...)
{
 char buffer[MAXDEBUGSTRING];
 va_list args;
 int32 length;
 /* Actual mode0=mask, nonzero=level and TRUE suppresses. This differs from
  * the apparent public prose; no enum/API/condition repair is claimed. */
 if ((DBG_DebugMode!=dbgmode_level)?(level<=DBG_DebugLevel):DBG_DebugMask[level]) return;
 va_start(args,message);vsprintf(buffer,message,args);va_end(args);
 length=strlen(buffer);
 if (length>=MAXDEBUGSTRING) Error("Debug: debug string length exceeded %s\n",buffer);
 if (buffer[length-1]!='\n') {
  if (length==MAXDEBUGSTRING-1) Error("Debug: debug string length exceeded %s\n",buffer);
  buffer[length]='\n';buffer[length+1]=0;
 }
 if (DBG_Out[DBG_OutMode].print) DBG_Out[DBG_OutMode].print(buffer);
}
void DBG_DbgString(char *message,...)
{
 char buffer[MAXDEBUGSTRING];
 va_list args;
 int32 length;
 int32 level=debug_normal;
 if ((DBG_DebugMode!=dbgmode_level)?(level<=DBG_DebugLevel):DBG_DebugMask[level]) return;
 va_start(args,message);vsprintf(buffer,message,args);va_end(args);
 length=strlen(buffer);
 if (length>=MAXDEBUGSTRING) Error("Debug: debug string length exceeded %s\n",buffer);
 if (buffer[length-1]!='\n') {
  if (length==MAXDEBUGSTRING-1) Error("Debug: debug string length exceeded %s\n",buffer);
  buffer[length]='\n';buffer[length+1]=0;
 }
 if (DBG_Out[DBG_OutMode].print) DBG_Out[DBG_OutMode].print(buffer);
}
void DBG_Shutdown(void)
{ if (DBG_Started) { DBG_Started=false;DBG_CloseDebugOutput(); } }
void DBG_Startup(int32 mode,int32 level,int32 output)
{
 if (DBG_Started) DBG_Shutdown();
 DBG_Started=true;DBG_SetDebugLevel(level);DBG_DisableAllDebugLevels();
 DBG_SetDebugMode(mode);DBG_SetDebugOutputMode(output);
}
void DBG_RegisterOutputFunction(int32 mode,void(*startup)(void),void(*print)(char*),void(*shutdown)(void))
{ DBG_Out[mode].startup=startup;DBG_Out[mode].print=print;DBG_Out[mode].shutdown=shutdown; }
