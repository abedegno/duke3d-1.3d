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


/* Readable native TOKENLIB reconstruction using unchanged released MACT
 * headers. Related ROTT SCRIPLIB parser context is not this original C source.
 * Related algorithm provenance: Copyright (C) 1994-1995 Apogee Software, Ltd.;
 * GPL v2 or later. Released headers retain their own original notices.
 * Historical local spelling/source identity is unknown; native full proof is
 * required. No original object or target payload is a producer input.
 * Explicit unused NUL suffixes inside real NUL-terminated literals express
 * native DWORD zero gaps; no sizeof/raw literal-length consumer observes them.
 * Final real literal retains its exact47-byte extent; no padding object. */
#include <stddef.h>
#include <string.h>
#include <stdlib.h>
#include "types.h"
#include "develop.h"
#include "file_lib.h"
#include "util_lib.h"
#include "tokenlib.h"
#include "_tokenli.h"

static token_t *tokenfiles[MAXTOKENFILES];
static boolean tokenlibrarycalled=false;
char token[MAXTOKEN];

int32 TOKEN_GetLineNumber(int32 handle)
{
    if (!tokenfiles[handle]) Error("TOKEN_GetLineNumber: not a valid tokenhandle\n\0\0");
    return TOKENFILE(handle,scriptline);
}

void TOKEN_Reset(int32 handle)
{
    if (!tokenfiles[handle]) Error("TOKEN_Reset: not a valid tokenhandle\n\0\0");
    TOKENFILE(handle,script_p)=TOKENFILE(handle,scriptbuffer);
    TOKENFILE(handle,scriptline)=1;
    TOKENFILE(handle,tokenready)=false;
}

boolean SkipToEOL(byte **p,byte *end)
{
    while (**p!=TOKENEOL) {
        if (*p>=end) return true;
        (*p)++;
    }
    return false;
}

void TOKEN_CheckOverflow(int32 handle)
{
    if (!tokenfiles[handle]) Error("TOKEN_CheckOverflow: not a valid tokenhandle\n\0\0");
    if (TOKENFILE(handle,script_p)>=TOKENFILE(handle,scriptend_p))
        Error("End of token file reached prematurely reading %s\n\0\0",TOKENFILE(handle,scriptfilename));
}

void TOKEN_SkipWhiteSpace(int32 handle,boolean crossline)
{
    if (!tokenfiles[handle]) Error("TOKEN_SkipWhiteSpace: not a valid tokenhandle\n\0");
    TOKEN_CheckOverflow(handle);
    while (*TOKENFILE(handle,script_p)<=TOKENSPACE) {
        if (*TOKENFILE(handle,script_p)++==TOKENEOL) {
            if (!crossline)
                Error("Line %i is incomplete\nin file %s\n\0\0",TOKENFILE(handle,scriptline),TOKENFILE(handle,scriptfilename));
            TOKENFILE(handle,scriptline)++;
        }
        TOKEN_CheckOverflow(handle);
    }
}

void TOKEN_SkipNonToken(int32 handle,boolean crossline)
{
    if (!tokenfiles[handle]) Error("TOKEN_SkipNonToken: not a valid tokenhandle\n\0\0\0");
skipspace:
    TOKEN_SkipWhiteSpace(handle,crossline);
    if (*TOKENFILE(handle,script_p)==TOKENCOMMENT || *TOKENFILE(handle,script_p)==TOKENCOMMENT2) {
        SkipToEOL(&TOKENFILE(handle,script_p),TOKENFILE(handle,scriptend_p));
        goto skipspace;
    }
}

boolean TOKEN_TokenAvailable(int32 handle,boolean crossline)
{
    byte *p;
    if (!tokenfiles[handle]) Error("TOKEN_TokenAvailable: not a valid tokenhandle\n\0");
    p=TOKENFILE(handle,script_p);
    if (p>=TOKENFILE(handle,scriptend_p)) return false;
skipspace:
    while (*p<=TOKENSPACE) {
        if (*p==TOKENEOL && !crossline) return false;
        p++;
        if (p>=TOKENFILE(handle,scriptend_p)) return false;
    }
    if (*p==TOKENCOMMENT || *p==TOKENCOMMENT2) {
        if (SkipToEOL(&p,TOKENFILE(handle,scriptend_p))==true) return false;
        goto skipspace;
    }
    return true;
}

boolean TOKEN_CommentAvailable(int32 handle,boolean crossline)
{
    byte *p;
    if (!tokenfiles[handle]) Error("TOKEN_CommentAvailable: not a valid tokenhandle\n\0\0\0");
    p=TOKENFILE(handle,script_p);
    if (p>=TOKENFILE(handle,scriptend_p)) return false;
    while (*p<=TOKENSPACE) {
        if (*p==TOKENEOL && !crossline) return false;
        p++;
        if (p>=TOKENFILE(handle,scriptend_p)) return false;
    }
    return true;
}

void TOKEN_UnGet(int32 handle)
{
    if (!tokenfiles[handle]) Error("TOKEN_UnGet: not a valid tokenhandle\n\0\0");
    TOKENFILE(handle,tokenready)=true;
}

void TOKEN_Get(int32 handle,boolean crossline)
{
    char *out;
    if (!tokenfiles[handle]) Error("TOKEN_Get: not a valid tokenhandle\n");
    if (TOKENFILE(handle,tokenready)) {
        TOKENFILE(handle,tokenready)=false;
        return;
    }
    TOKEN_SkipNonToken(handle,crossline);
    out=token;
    while (*TOKENFILE(handle,script_p)>TOKENSPACE &&
           *TOKENFILE(handle,script_p)!=TOKENCOMMENT &&
           *TOKENFILE(handle,script_p)!=TOKENCOMMENT2) {
        *out++=*TOKENFILE(handle,script_p)++;
        if (TOKENFILE(handle,script_p)==TOKENFILE(handle,scriptend_p)) break;
        if (out==&token[MAXTOKEN])
            Error("Token too large on line %i\nin file %s\n\0",TOKENFILE(handle,scriptline),TOKENFILE(handle,scriptfilename));
    }
    *out=TOKENNULL;
}

void TOKEN_GetLine(int32 handle,boolean crossline)
{
    byte *start;
    int32 length;
    if (!tokenfiles[handle]) Error("TOKEN_GetLine: not a valid tokenhandle\n");
    if (TOKENFILE(handle,tokenready)) {
        TOKENFILE(handle,tokenready)=false;
        return;
    }
    TOKEN_SkipNonToken(handle,crossline);
    start=TOKENFILE(handle,script_p);
    SkipToEOL(&TOKENFILE(handle,script_p),TOKENFILE(handle,scriptend_p));
    length=TOKENFILE(handle,script_p)-start;
    if (length<MAXTOKEN-1) {
        memcpy(token,start,length);
        token[length]=TOKENNULL;
    } else Error("Token too large on line %i\nin file %s\n\0",TOKENFILE(handle,scriptline),TOKENFILE(handle,scriptfilename));
}

void TOKEN_GetRaw(int32 handle)
{
    byte *start;
    int32 length;
    if (!tokenfiles[handle]) Error("TOKEN_GetRaw: not a valid tokenhandle\n\0");
    TOKEN_SkipWhiteSpace(handle,true);
    start=TOKENFILE(handle,script_p);
    SkipToEOL(&TOKENFILE(handle,script_p),TOKENFILE(handle,scriptend_p));
    length=TOKENFILE(handle,script_p)-start;
    if (length<MAXTOKEN-1) {
        memset(token,0,sizeof(token));
        memcpy(token,start,length+1);
    } else Error("Token too large on line %i\nin file %s\n\0",TOKENFILE(handle,scriptline),TOKENFILE(handle,scriptfilename));
}

boolean TOKEN_GetSpecific(int32 handle,char *str)
{
    if (!tokenfiles[handle]) Error("TOKEN_GetSpecific: not a valid tokenhandle\n");
    while (TOKEN_TokenAvailable(handle,true)) {
        TOKEN_Get(handle,true);
        if (!strcmp(token,str)) return true;
    }
    return false;
}

void TOKEN_GetInteger(int32 handle,int32 *number,boolean crossline)
{
    if (!tokenfiles[handle]) Error("TOKEN_GetInteger: not a valid tokenhandle\n\0");
    TOKEN_Get(handle,crossline);
    *number=atoi(token);
}

void TOKEN_GetDouble(int32 handle,double *number,boolean crossline)
{
    if (!tokenfiles[handle]) Error("TOKEN_GetDouble: not a valid tokenhandle\n\0\0");
    TOKEN_Get(handle,crossline);
    *number=strtod(token,NULL);
}

int32 TOKEN_LinesInFile(int32 handle)
{
    token_t saved;
    int32 lines;
    if (!tokenfiles[handle]) Error("TOKEN_LinesInFile: not a valid tokenhandle\n");
    memcpy(&saved,tokenfiles[handle],sizeof(token_t));
    lines=0;
    TOKEN_Reset(handle);
    while (TOKEN_TokenAvailable(handle,true)) {
        TOKEN_GetLine(handle,true);
        lines++;
    }
    memcpy(tokenfiles[handle],&saved,sizeof(token_t));
    return lines;
}

int32 TOKEN_New(void)
{
    int32 handle;
    if (!tokenlibrarycalled) {
        tokenlibrarycalled=true;
        memset(tokenfiles,0,sizeof(tokenfiles));
    }
    for (handle=0;handle<MAXTOKENFILES;handle++) {
        if (!tokenfiles[handle]) {
            tokenfiles[handle]=SafeMalloc(sizeof(token_t));
            return handle;
        }
    }
    Error("TOKEN_New: No free token file slots available\n");
    return -1;
}

void TOKEN_Free(int32 handle)
{
    if (tokenfiles[handle]) {
        if (TOKENFILE(handle,scriptbuffer)) SafeFree(TOKENFILE(handle,scriptbuffer));
        SafeFree(tokenfiles[handle]);
        tokenfiles[handle]=NULL;
    }
}

int32 TOKEN_Parse(char *data,int32 length,char *name)
{
    int32 handle=TOKEN_New();
    TOKENFILE(handle,scriptbuffer)=SafeMalloc(length);
    memcpy(TOKENFILE(handle,scriptbuffer),data,length);
    TOKEN_Reset(handle);
    TOKENFILE(handle,scriptend_p)=TOKENFILE(handle,script_p)+length;
    strcpy(TOKENFILE(handle,scriptfilename),name);
    return handle;
}

int32 TOKEN_Load(char *filename)
{
    char *data;
    int32 length,handle;
    length=LoadFile(filename,(void **)&data);
    handle=TOKEN_Parse(data,length,filename);
    SafeFree(data);
    return handle;
}
