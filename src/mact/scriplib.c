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

/* Task142 reconstruction from released MACT headers/macros and original
 * native function roles. Jonathon Fowler's 2005 interpolation is not original source;
 * its stub Parse/alternate allocation algorithm is not used here.
 * The complete native module matches the target; independent integration review
 * and original source identity remain separate obligations.
 * Each real string literal explicitly terminates its native DWORD extent with
 * NUL suffixes (except final %f, whose native terminal extent is three bytes).
 * These strings are consumed through NUL-terminated APIs, never sizeof/raw
 * literal lengths. Extra NULs do not change text/format semantics. Historical
 * spelling is unknown; no separate padding object or CONST blob is used.
 */
#include <stddef.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "types.h"
#include "develop.h"
#include "file_lib.h"
#include "scriplib.h"
#include "_scrplib.h"
#include "linklist.h"
#include "util_lib.h"
#include "tokenlib.h"

static script_t *scriptfiles[MAXSCRIPTFILES];
static boolean scriptlibrarycalled = false;

boolean SCRIPT_HandleValid(int32 handle)
{
    return scriptfiles[handle] != NULL;
}

int32 SCRIPT_New(void)
{
    int32 handle;
    if (!scriptlibrarycalled) {
        scriptlibrarycalled = true;
        memset(scriptfiles, 0, sizeof(scriptfiles));
    }
    for (handle=0; handle<MAXSCRIPTFILES; handle++) {
        if (!SCRIPT_HandleValid(handle)) {
            scriptfiles[handle] = SafeMalloc(sizeof(script_t));
            return handle;
        }
    }
    Error("SCRIPT_New: No free script file slots available\n\0\0\0");
    return -1;
}

void SCRIPT_Delete(int32 handle)
{
    if (!SCRIPT_HandleValid(handle))
        Error("SCRIPT_Delete not a valid scripthandle\n");
    SafeFree(scriptfiles[handle]);
    scriptfiles[handle] = NULL;
}

int32 SCRIPT_Init(char *name)
{
    int32 handle = SCRIPT_New();
    LL_New(SCRIPT(handle,script),ScriptSectionType,nextsection,prevsection);
    LL_New(SCRIPT(handle,scriptlines),ScriptLineType,nextline,prevline);
    SCRIPT(handle,lastsection) = NULL;
    strcpy(SCRIPT(handle,scriptfilename),name);
    return handle;
}

void SCRIPT_FreeSection(ScriptSectionType *section)
{
    ScriptEntryType *entry, *next;
    entry=section->entries->nextentry;
    while (entry!=section->entries) {
        next=entry;
        entry=entry->nextentry;
        SafeFree(next->name);
        SafeFree(next->value);
        LL_Remove(next,nextentry,preventry);
        SafeFree(next);
    }
    SafeFree(section->entries);
    SafeFree(section->name);
    section->entries=NULL;
}

void SCRIPT_Free(int32 handle)
{
    ScriptSectionType *section, *nextsection;
    ScriptLineType *line, *nextline;
    if (!SCRIPT_HandleValid(handle))
        Error("SCRIPT_Free not a valid scripthandle\n\0\0");
    section=SCRIPT(handle,script)->nextsection;
    while (section!=SCRIPT(handle,script)) {
        nextsection=section;
        section=section->nextsection;
        SCRIPT_FreeSection(nextsection);
        LL_Remove(nextsection,nextsection,prevsection);
        SafeFree(nextsection);
    }
    line=SCRIPT(handle,scriptlines)->nextline;
    while (line!=SCRIPT(handle,scriptlines)) {
        nextline=line;
        if (nextline->type==linetype_comment) SafeFree(nextline->ptr);
        line=line->nextline;
        LL_Remove(nextline,nextline,prevline);
        SafeFree(nextline);
    }
    SafeFree(SCRIPT(handle,scriptlines));
    SafeFree(SCRIPT(handle,script));
    SCRIPT_Delete(handle);
}

int32 SCRIPT_Parse(char *data,int32 length,char *name)
{
    int32 tokenhandle,scripthandle;
    boolean done=false;
    tokenhandle=TOKEN_Parse(data,length,name);
    scripthandle=SCRIPT_Init(name);
    TOKEN_Reset(tokenhandle);
    while (!done) {
        if (!TOKEN_CommentAvailable(tokenhandle,true)) done=true;
        else {
            TOKEN_GetRaw(tokenhandle);
            SCRIPT_DecodeToken(scripthandle,token);
        }
    }
    TOKEN_Free(tokenhandle);
    return scripthandle;
}

int32 SCRIPT_Load(char *filename)
{
    int32 handle,length;
    char *data;
    if (SafeFileExists(filename)) {
        length=LoadFile(filename,(void **)&data);
        handle=SCRIPT_Parse(data,length,filename);
        SafeFree(data);
    } else handle=SCRIPT_Init(filename);
    return handle;
}

void SafeWriteString(int32 handle,char *string)
{
    SafeWrite(handle,string,strlen(string));
}

void SCRIPT_Save(int32 handle,char *filename)
{
    int32 file;
    ScriptLineType *line;
    char buffer[160]; /* Actual sprintf output buffer, native frame164 incl index. */
    if (!SCRIPT_HandleValid(handle))
        Error("SCRIPT_Save not a valid scripthandle\n\0\0");
    file=SafeOpenWrite(filename,filetype_text);
    line=SCRIPT(handle,scriptlines)->nextline;
    for (;;line=line->nextline) {
        if (line==SCRIPT(handle,scriptlines)) break;
        switch (line->type) {
        case linetype_comment:
            sprintf(buffer,"%c%s%c\0",SCRIPTCOMMENT,(char *)line->ptr,SCRIPTEOL);
            SafeWriteString(file,buffer);
            break;
        case linetype_section:
            sprintf(buffer,"%c%s%c%c\0\0\0",SCRIPTSECTIONSTART,
                    ((ScriptSectionType *)line->ptr)->name,SCRIPTSECTIONEND,SCRIPTEOL);
            SafeWriteString(file,buffer);
            break;
        case linetype_entry:
            sprintf(buffer,"%s %c %s%c\0",((ScriptEntryType *)line->ptr)->name,
                    SCRIPTENTRYSEPARATOR,((ScriptEntryType *)line->ptr)->value,SCRIPTEOL);
            SafeWriteString(file,buffer);
            break;
        }
    }
    SafeClose(file);
}

ScriptLineType *SCRIPT_AddLine(ScriptLineType *root,int32 type,void *ptr)
{
    ScriptLineType *line=NewNode(ScriptLineType);
    line->type=type;
    line->ptr=ptr;
    LL_Add(root,line,nextline,prevline);
    return line;
}

ScriptSectionType *SCRIPT_SectionExists(int32 handle,char *name)
{
    ScriptSectionType *section;
    if (!SCRIPT_HandleValid(handle))
        Error("SCRIPT_SectionExists not a valid scripthandle\n\0");
    for (section=SCRIPT(handle,script)->nextsection;
         ;section=section->nextsection) {
        if (section==SCRIPT(handle,script)) break;
        if (!strcmpi(name,section->name)) return section;
    }
    return NULL;
}

void SCRIPT_AddSection(int32 handle,char *name)
{
    ScriptSectionType *section;
    int32 length;
    if (!SCRIPT_HandleValid(handle))
        Error("SCRIPT_AddSection not a valid scripthandle\n");
    if (!SCRIPT_SectionExists(handle,name)) {
        section=NewNode(ScriptSectionType);
        LL_Add(SCRIPT(handle,script),section,nextsection,prevsection);
        length=strlen(name)+1;
        section->name=SafeMalloc(length);
        memcpy(section->name,name,length);
        section->lastline=SCRIPT_AddLine(SCRIPT(handle,scriptlines),linetype_section,section);
        LL_New(section->entries,ScriptEntryType,nextentry,preventry);
    }
    SCRIPT(handle,lastsection)=SCRIPT_SectionExists(handle,name);
}

ScriptEntryType *SCRIPT_EntryExists(ScriptSectionType *section,char *name)
{
    ScriptEntryType *entry;
    for (entry=section->entries->nextentry;entry!=section->entries;entry=entry->nextentry)
        if (!strcmpi(name,entry->name)) return entry;
    return NULL;
}

void SCRIPT_AddEntry(int32 handle,char *sectionname,char *entryname,char *value)
{
    ScriptSectionType *section;
    ScriptEntryType *entry;
    boolean exists;
    int32 length;
    if (!SCRIPT_HandleValid(handle))
        Error("SCRIPT_AddEntry not a valid scripthandle\n\0\0");
    section=SCRIPT_SectionExists(handle,sectionname);
    if (!section) {
        SCRIPT_AddSection(handle,sectionname);
        section=SCRIPT_SectionExists(handle,sectionname);
    }
    exists=(SCRIPT_EntryExists(section,entryname)!=NULL);
    if (!exists) {
        entry=NewNode(ScriptEntryType);
        LL_Add(section->entries,entry,nextentry,preventry);
        entry->name=NULL;
        entry->value=NULL;
    } else entry=SCRIPT_EntryExists(section,entryname);
    if (!entry->name) {
        length=strlen(entryname)+1;
        entry->name=SafeMalloc(length);
        memcpy(entry->name,entryname,length);
    }
    if (entry->value) SafeFree(entry->value);
    length=strlen(value)+1;
    entry->value=SafeMalloc(length);
    memcpy(entry->value,value,length);
    if (!exists)
        section->lastline=SCRIPT_AddLine(section->lastline->nextline,linetype_entry,entry);
}

void SCRIPT_DecodeToken(int32 handle,char *str)
{
    char *name,*start,*comment,*value;
    int32 length;
    ScriptLineType *root,*line;
    if (*str==SCRIPTSECTIONSTART) {
        name=++str;
        while (*str!=SCRIPTSECTIONEND) {
            if (*str==SCRIPTNULL)
                Error("No matching bracket found for section %s in file %s\n\0\0\0",
                      name,SCRIPT(handle,scriptfilename));
            str++;
        }
        *str=SCRIPTNULL;
        SCRIPT_AddSection(handle,name);
    } else if (*str==SCRIPTCOMMENT) {
        start=++str;
        while (*str>=SCRIPTSPACE) str++;
        length=str-start+1;
        comment=SafeMalloc(length);
        memset(comment,0,length);
        if (length>1) memcpy(comment,start,length-1);
        if (SCRIPT(handle,lastsection)) {
            /* Native captures the insertion root before the real allocation. */
            root=SCRIPT(handle,lastsection)->lastline->nextline;
            line=NewNode(ScriptLineType);
            line->type=linetype_comment;
            line->ptr=comment;
            LL_Add(root,line,nextline,prevline);
            SCRIPT(handle,lastsection)->lastline=line;
        }
        /* Actual native allocation remains unreleased if no section exists. */
    } else {
        name=str;
        while (*str>SCRIPTSPACE && *str!=SCRIPTENTRYSEPARATOR) str++;
        if (*str==SCRIPTENTRYSEPARATOR) {
            *str=SCRIPTNULL;
            while (*str<=SCRIPTSPACE) str++;
        } else {
            *str=SCRIPTNULL;
            str++;
            while (*str<=SCRIPTSPACE) str++;
            if (*str!=SCRIPTENTRYSEPARATOR)
                Error("No entry separator found for %s in %s\n\0",
                      SCRIPT(handle,lastsection)->name,SCRIPT(handle,scriptfilename));
            str++;
            while (*str<=SCRIPTSPACE) str++;
        }
        value=str;
        while (*str>=SCRIPTSPACE) str++;
        *str=SCRIPTNULL;
        SCRIPT_AddEntry(handle,SCRIPT(handle,lastsection)->name,name,value);
    }
}

int32 SCRIPT_NumberSections(int32 handle)
{
    ScriptSectionType *section;
    int32 count;
    if (!SCRIPT_HandleValid(handle))
        Error("SCRIPT_NumberSections not a valid scripthandle\n");
    section=SCRIPT(handle,script)->nextsection;
    count=0;
    for (;;section=section->nextsection) {
        if (section==SCRIPT(handle,script)) break;
        count++;
    }
    return count;
}

char *SCRIPT_Section(int32 handle,int32 which)
{
    ScriptSectionType *section;
    int32 count;
    if (!SCRIPT_HandleValid(handle))
        Error("SCRIPT_Section not a valid scripthandle\n\0\0\0");
    section=SCRIPT(handle,script)->nextsection;
    count=0;
    while (section!=SCRIPT(handle,script) && count!=which) {
        count++;
        section=section->nextsection;
    }
    if (section==SCRIPT(handle,script))
        Error("There are only %ld sections, section %ld could not be found\n\0\0\0",
              SCRIPT_NumberSections(handle),which);
    return section->name;
}

int32 SCRIPT_NumberEntries(int32 handle,char *name)
{
    ScriptSectionType *section;
    ScriptEntryType *entry;
    int32 count;
    if (!SCRIPT_HandleValid(handle))
        Error("SCRIPT_NumberEntries not a valid scripthandle\n\0");
    count=0;
    section=SCRIPT_SectionExists(handle,name);
    if (section)
        for (entry=section->entries->nextentry;entry!=section->entries;entry=entry->nextentry)
            count++;
    return count;
}

char *SCRIPT_Entry(int32 handle,char *name,int32 which)
{
    ScriptSectionType *section;
    ScriptEntryType *entry;
    int32 count;
    if (!SCRIPT_HandleValid(handle))
        Error("SCRIPT_Entry not a valid scripthandle\n\0");
    count=0;
    section=SCRIPT_SectionExists(handle,name);
    entry=section->entries->nextentry;
    while (entry!=section->entries && count!=which) {
        count++;
        entry=entry->nextentry;
    }
    if (entry==section->entries)
        Error("There are only %ld entries in section %s, entry %ld could not be found\n",
              SCRIPT_NumberEntries(handle,name),name,which);
    return entry->name;
}

char *SCRIPT_GetRaw(int32 handle,char *sectionname,char *entryname)
{
    ScriptSectionType *section;
    ScriptEntryType *entry;
    char *value;
    if (!SCRIPT_HandleValid(handle))
        Error("SCRIPT_GetRaw not a valid scripthandle\n");
    section=SCRIPT_SectionExists(handle,sectionname);
    value=NULL;
    if (section) {
        entry=SCRIPT_EntryExists(section,entryname);
        if (entry) value=entry->value;
    }
    return value;
}

void SCRIPT_GetString(int32 handle,char *sectionname,char *entryname,char *dest)
{
    char *raw,*start,*value;
    int32 length;
    if (!SCRIPT_HandleValid(handle))
        Error("SCRIPT_GetString not a valid scripthandle\n\0");
    value=SCRIPT_GetRaw(handle,sectionname,entryname);
    if (value) {
        raw=value;
        if (*raw!=SCRIPTSTRINGSEPARATOR)
            Error("SCRIPT_GetString: no %c found\n\0",SCRIPTSTRINGSEPARATOR);
        start=++raw;
        while (*raw!=SCRIPTSTRINGSEPARATOR) {
            raw++;
            if (raw-start>80)
                Error("SCRIPT_GetString: no %c found at end of string %s\0\0",
                      SCRIPTSTRINGSEPARATOR,start);
        }
        length=raw-start;
        memcpy(dest,start,length);
        dest[length]=SCRIPTNULL;
    }
}

void SCRIPT_GetDoubleString(int32 handle,char *sectionname,char *entryname,char *dest1,char *dest2)
{
    char *raw,*start,*value;
    if (!SCRIPT_HandleValid(handle))
        Error("SCRIPT_GetDoubleString not a valid scripthandle\n\0\0\0");
    value=SCRIPT_GetRaw(handle,sectionname,entryname);
    if (value) {
        raw=value;
        if (*raw!=SCRIPTSTRINGSEPARATOR)
            Error("SCRIPT_GetDoubleString: no %c found\n\0\0\0",SCRIPTSTRINGSEPARATOR);
        start=++raw;
        while (*raw!=SCRIPTSTRINGSEPARATOR) {
            raw++;
            if (raw-start>80)
                Error("SCRIPT_GetDoubleString: no %c found at end of string %s",
                      SCRIPTSTRINGSEPARATOR,start);
        }
        memcpy(dest1,start,raw-start);
        dest1[raw-start]=SCRIPTNULL;
        raw++;
        while (*raw!=SCRIPTSTRINGSEPARATOR) {
            raw++;
            if (raw-start>80)
                Error("SCRIPT_GetDoubleString: no %c found at start of string2 %s\0",
                      SCRIPTSTRINGSEPARATOR,start);
        }
        start=++raw;
        while (*raw!=SCRIPTSTRINGSEPARATOR) {
            raw++;
            if (raw-start>80)
                Error("SCRIPT_GetDoubleString: no %c found at end of string2 %s\0\0\0",
                      SCRIPTSTRINGSEPARATOR,start);
        }
        memcpy(dest2,start,raw-start);
        dest2[raw-start]=SCRIPTNULL;
    }
}

boolean SCRIPT_GetNumber(int32 handle,char *sectionname,char *entryname,int32 *number)
{
    char *raw;
    if (!SCRIPT_HandleValid(handle))
        Error("SCRIPT_GetNumber not a valid scripthandle\n\0");
    raw=SCRIPT_GetRaw(handle,sectionname,entryname);
    if (raw) {
        if (*raw==SCRIPTDEFAULTVALUE) return true;
        if (raw[0]==SCRIPTHEXFIRST && raw[1]==SCRIPTHEXSECOND)
            sscanf(raw+2,"%lx",number);
        else sscanf(raw,"%ld",number);
    }
    return false;
}

void SCRIPT_GetBoolean(int32 handle,char *sectionname,char *entryname,boolean *value)
{
    char *raw;
    int32 number;
    if (!SCRIPT_HandleValid(handle))
        Error("SCRIPT_GetBoolean not a valid scripthandle\n");
    raw=SCRIPT_GetRaw(handle,sectionname,entryname);
    if (raw) {
        sscanf(raw,"%ld",&number);
        if (number==0) *value=false;
        else *value=true;
    }
}

void SCRIPT_GetDouble(int32 handle,char *sectionname,char *entryname,double *number)
{
    char *raw;
    if (!SCRIPT_HandleValid(handle))
        Error("SCRIPT_GetDouble not a valid scripthandle\n\0");
    raw=SCRIPT_GetRaw(handle,sectionname,entryname);
    if (raw && *raw!=SCRIPTDEFAULTVALUE) sscanf(raw,"%lf",number);
}

void SCRIPT_PutComment(int32 handle,char *sectionname,char *comment)
{
    ScriptSectionType *section;
    char *copy;
    if (!SCRIPT_HandleValid(handle))
        Error("SCRIPT_ not a valid scripthandle\n\0\0");
    section=SCRIPT_SectionExists(handle,sectionname);
    if (!section) {
        SCRIPT_AddSection(handle,sectionname);
        section=SCRIPT_SectionExists(handle,sectionname);
    }
    copy=SafeMalloc(strlen(comment)+1);
    strcpy(copy,comment);
    section->lastline=SCRIPT_AddLine(section->lastline->nextline,linetype_comment,copy);
}

void SCRIPT_PutEOL(int32 handle,char *sectionname)
{
    SCRIPT_PutComment(handle,sectionname," \0\0");
}

void SCRIPT_PutMultiComment(int32 handle,char *sectionname,char *comment,...)
{
    char buffer[200];
    va_list args;
    va_start(args,comment);
    vsprintf(buffer,comment,args);
    va_end(args);
    SCRIPT_PutComment(handle,sectionname,buffer);
}

/* Published API wrappers; canonical GA coalescing, not aliases/stubs. */
void SCRIPT_PutSection(int32 handle,char *sectionname)
{
    SCRIPT_AddSection(handle,sectionname);
}

void SCRIPT_PutRaw(int32 handle,char *sectionname,char *entryname,char *raw)
{
    SCRIPT_AddEntry(handle,sectionname,entryname,raw);
}

void SCRIPT_PutString(int32 handle,char *sectionname,char *entryname,char *string)
{
    char raw[80];
    sprintf(raw,"%c%s%c\0",SCRIPTSTRINGSEPARATOR,string,SCRIPTSTRINGSEPARATOR);
    SCRIPT_AddEntry(handle,sectionname,entryname,raw);
}

void SCRIPT_PutDoubleString(int32 handle,char *sectionname,char *entryname,char *string1,char *string2)
{
    char raw[80];
    sprintf(raw,"%c%s%c %c%s%c\0\0",SCRIPTSTRINGSEPARATOR,string1,SCRIPTSTRINGSEPARATOR,
            SCRIPTSTRINGSEPARATOR,string2,SCRIPTSTRINGSEPARATOR);
    SCRIPT_AddEntry(handle,sectionname,entryname,raw);
}

void SCRIPT_PutNumber(int32 handle,char *sectionname,char *entryname,int32 number,
                      boolean hexadecimal,boolean defaultvalue)
{
    char raw[80];
    if (defaultvalue) sprintf(raw,"%c\0",SCRIPTDEFAULTVALUE);
    else if (hexadecimal) sprintf(raw,"%c%c%lx",SCRIPTHEXFIRST,SCRIPTHEXSECOND,number);
    else sprintf(raw,"%ld",number);
    SCRIPT_AddEntry(handle,sectionname,entryname,raw);
}

void SCRIPT_PutBoolean(int32 handle,char *sectionname,char *entryname,boolean value)
{
    char raw[80];
    if (value) sprintf(raw,"1\0\0");
    else sprintf(raw,"0\0\0");
    SCRIPT_AddEntry(handle,sectionname,entryname,raw);
}

void SCRIPT_PutDouble(int32 handle,char *sectionname,char *entryname,double number,boolean defaultvalue)
{
    char raw[80];
    if (defaultvalue) sprintf(raw,"%c\0",SCRIPTDEFAULTVALUE);
    else sprintf(raw,"%f",number);
    SCRIPT_AddEntry(handle,sectionname,entryname,raw);
}
