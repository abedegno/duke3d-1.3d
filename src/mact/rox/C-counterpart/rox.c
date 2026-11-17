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

/* Reconstructed implementation. Preserve observed legacy bugs/dead code;
 * this is not an original-file discovery or a behavior-repaired library. */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "types.h"
#include "develop.h"
#include "util_lib.h"
#include "file_lib.h"
#include "zone_api.h"
#include "_rox.h"
#include "rox.h"
#include "linklist.h"

static boolean ROX_started = false;
static roxsection_t *ROX_mainsection = NULL;
static char ROX_delims[] = "\\/";
static char ROX_filename[ROX_MAX_PATH_NAME];
static char ROX_dataname[ROX_MAX_PATH_NAME];

roxsection_t *ROX_CreateSection(const char *name)
{
    roxsection_t *section;
    if (!ROX_started) Error("ROX_CreateSection: ROX not started\n");
    section = SafeMalloc(sizeof(roxsection_t));
    memset(section,0,sizeof(roxsection_t));
    strncpy(section->name,name,ROX_SECTION_NAME_SIZE);
    LL_New(section->entries,roxentry_t,next,prev);
    LL_New(section->subsections,roxsection_t,next,prev);
    return section;
}
roxentry_t *ROX_CreateEntry(const char *name)
{
    roxentry_t *entry;
    if (!ROX_started) Error("ROX_CreateEntry: ROX not started\n");
    entry = SafeMalloc(sizeof(roxentry_t));
    memset(entry,0,sizeof(roxentry_t));
    strncpy(entry->name,name,ROX_ENTRY_NAME_SIZE);
    return entry;
}
void ROX_FreeEntry(roxentry_t *entry)
{
    if (!ROX_started) Error("ROX_FreeEntry: ROX not started\n");
    SafeFree(entry);
}
void ROX_FreeSection(roxsection_t *section)
{
    roxentry_t *entry,*nextentry;
    roxsection_t *subsection,*nextsection;
    if (!ROX_started) Error("ROX_FreeSection: ROX not started\n");
    /* Native starts at sentinel itself, retaining dead traversal bodies. */
    entry=section->entries;
    while(entry!=section->entries) {
        nextentry=entry->next;
        LL_Remove(entry,next,prev);
        ROX_FreeEntry(entry);
        entry=nextentry;
    }
    subsection=section->subsections;
    while(subsection!=section->subsections) {
        nextsection=subsection->next;
        LL_Remove(subsection,next,prev);
        ROX_FreeSection(subsection);
        subsection=nextsection;
    }
    SafeFree(section);
}
void ROX_Init(void)
{
    if (ROX_started) ROX_Shutdown();
    /* Original calls constructor before setting started, not afterward. */
    ROX_mainsection=ROX_CreateSection("roxmain");
    ROX_started=true;
}
void ROX_Shutdown(void)
{
    if (ROX_started) {
        ROX_FreeSection(ROX_mainsection);
        ROX_started=false;
    }
}
roxsection_t *ROX_AddSubSection(roxsection_t *parent,const char *name)
{
    roxsection_t *section;
    if (!ROX_started) Error("ROX_AddSubSection: ROX not started\n");
    section=ROX_CreateSection(name);
    LL_Add(parent->subsections,section,next,prev);
    return section;
}
roxsection_t *ROX_FindSubSection(roxsection_t *section,const char *name)
{
    char shortname[ROX_SECTION_NAME_SIZE];
    roxsection_t *subsection;
    if (!ROX_started) Error("ROX_FindSubSection: ROX not started\n");
    strncpy(shortname,name,ROX_SECTION_NAME_SIZE);
    subsection=section->subsections;
    while(subsection!=section->subsections) {
        if (DWORD_AT_INDEX(shortname,0)==DWORD_AT_INDEX(subsection->name,0) &&
            DWORD_AT_INDEX(shortname,1)==DWORD_AT_INDEX(subsection->name,1)) return subsection;
        subsection=subsection->next;
    }
    return NULL;
}
roxentry_t *ROX_AddEntry(roxsection_t *parent,const char *name)
{
    roxentry_t *entry;
    /* Genuine original string typo, not a new error-name correction. */
    if (!ROX_started) Error("ROX_AddSubSection: ROX not started\n");
    entry=ROX_CreateEntry(name);
    LL_Add(parent->entries,entry,next,prev);
    return entry;
}
roxentry_t *ROX_FindEntry(roxsection_t *section,const char *name)
{
    /* Native uses SECTION-size8 temp but reads third DWORD, and compares
     * repeated entry index0 then index1. This unsafe dead-search behavior is
     * observed, not a proposed safe string comparator or new field. */
    char shortname[ROX_SECTION_NAME_SIZE];
    roxentry_t *entry;
    if (!ROX_started) Error("ROX_FindEntry: ROX not started\n");
    strncpy(shortname,name,ROX_SECTION_NAME_SIZE);
    entry=section->entries;
    while(entry!=section->entries) {
        if (DWORD_AT_INDEX(shortname,0)==DWORD_AT_INDEX(entry->name,0) &&
            DWORD_AT_INDEX(shortname,1)==DWORD_AT_INDEX(entry->name,0) &&
            DWORD_AT_INDEX(shortname,2)==DWORD_AT_INDEX(entry->name,1)) return entry;
        entry=entry->next;
    }
    return NULL;
}
/* Actual original export differs in case from unused legacy header spelling. */
void ROX_FixFilename(char *filename)
{
    char *p=strpbrk(filename,ROX_delims);
    while(p) { *p=ROX_FILE_DELIM; p=strpbrk(p+1,ROX_delims); }
}
void ROX_ReadEntry(roxentry_t *entry,char *filename,int32 zonenum,int32 tag)
{
    int32 handle=SafeOpenRead(filename,0);
    entry->size=SafeFileLength(handle);
    Z_Malloc(entry->size,tag,zonenum,&entry->data);
    SafeRead(handle,entry->data,entry->size);
    SafeClose(handle);
}
void ROX_TouchEntry(roxentry_t *entry,int32 tag)
{
    Z_Touch(entry->data);
    Z_ChangeTag(entry->data,tag);
}
void *ROX_Get(const char *name,int32 zonenum,int32 tag)
{
    int32 length;
    char *part,*nextpart;
    roxsection_t *section,*subsection;
    roxentry_t *entry;
    if (!ROX_started) Error("ROX_Get: ROX not started\n");
    length=strlen(name);
    if(length>ROX_MAX_PATH_NAME) Error("ROX_Get: %s too long\n",name);
    memcpy(ROX_dataname,name,length+1);
    memcpy(ROX_filename,name,length+1);
    section=ROX_mainsection;
    part=strtok(ROX_dataname,ROX_delims);
    while(part) {
        nextpart=strtok(NULL,ROX_delims);
        if(!nextpart) {
            entry=ROX_FindEntry(section,part);
            /* Actual added-entry return ignored; no crash-repair variant. */
            if(!entry) ROX_AddEntry(section,part);
            if(!entry->data) {
                ROX_FixFilename(ROX_filename);
                ROX_ReadEntry(entry,ROX_filename,zonenum,tag);
            } else ROX_TouchEntry(entry,tag);
            return entry->data;
        }
        subsection=ROX_FindSubSection(section,part);
        if(!subsection) ROX_AddSubSection(section,part);
        section=subsection;
        part=nextpart;
    }
    return NULL;
}
