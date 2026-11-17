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

//***************************************************************************
//
//    WAD.C - Wad managment utilities
//
//***************************************************************************

/* Authored Task453 reconstruction. Released WAD/WADTYPE API and related ROTT
 * W_WAD.C establish ancestry; original MACT WAD.C has not been located.
 * Original whole-native roles guide MACT additions, bugs and widths.
 * Real NUL-terminated literals carry their observed DWORD zero suffixes;
 * no sizeof/raw-length consumer observes the unused suffix capacity. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <io.h>
#include "types.h"
#include "develop.h"
#include "wadtype.h"
#include "wad.h"
#include "_wad.h"
#include "util_lib.h"
#include "file_lib.h"
#include "crc.h"
/* Released public ZONE header absent; exact signatures corroborated by the
 * independently recovered MACT ZONE implementations and WAD call operands. */
extern void *Z_Malloc(int32 size,int32 tag,int32 zone,void *user);
extern void Z_ChangeTag(void *ptr,int32 tag);
extern void Z_Touch(void *ptr);
static dword numlumps=0;
static void **lumpcache=NULL;
static lumpinfo_t *lumpinfo=NULL;
static boolean wadfileopened=false;
static char *lumptypenames[]={
 "unknown", "pic", "lpic\0\0\0", "post\0\0\0", "post_raw\0\0\0", "raw",
 "patch255\0\0\0", "patch\0\0", "palette", "patch255_all\0\0\0", "patch_all\0\0",
 "mipmap\0", "font\0\0\0", "color_font\0", "intensity_font\0", "sound\0\0", "<LABEL>",
 "colormap\0\0\0", "transmap\0\0\0", "tileset", "model\0\0", "frame\0\0" };
static char wadfilename[128];
static filelump_t *table_p,*table;
static int32 wadhandle;

wadfileinfo_t *WAD_ReadHeader(const char *filename)
{
 wadfileinfo_t *wad=SafeMalloc(sizeof(wadfileinfo_t));
 wadinfo_t header;
 char name[100];
 int32 directory_bytes;
 wad->filehandle=SafeOpenRead(filename,filetype_binary);
 if(strcmpi(filename+strlen(filename)-3,"wad")!=0) {
  wad->fileinfo=SafeMalloc(sizeof(filelump_t));
  wad->fileinfo->filepos=0;
  wad->fileinfo->size=IntelLong(SafeFileLength(wad->filehandle));
  wad->fileinfo->lumptype=0;
  wad->numlumps=1;
  strcpy(name,filename);
  ExtractFileBase(name,wad->fileinfo->name);
 } else {
  SafeRead(wad->filehandle,&header,sizeof(header));
  if(strncmp(header.identification,"IWAD\0\0\0",4)!=0)
   Error("Wad file %s doesn't have IWAD id\n\0\0",filename);
  header.numlumps=IntelLong(header.numlumps);
  header.infotableofs=IntelLong(header.infotableofs);
  directory_bytes=header.numlumps*sizeof(filelump_t);
  wad->fileinfo=SafeMalloc(directory_bytes);
  wad->numlumps=header.numlumps;
  lseek(wad->filehandle,header.infotableofs,SEEK_SET);
  SafeRead(wad->filehandle,wad->fileinfo,directory_bytes);
 }
 return wad;
}
void WAD_AddFile(const char *filename)
{
 wadfileinfo_t *wad=WAD_ReadHeader(filename);
 lumpinfo_t *lump;
 int32 i,size,oldsize;
 printf("    Adding %s.\n",filename);
 size=(numlumps+wad->numlumps)*sizeof(lumpinfo_t);
 if(!lumpinfo) lumpinfo=SafeMalloc(size);
 else SafeRealloc((void **)&lumpinfo,size);
 size=(numlumps+wad->numlumps)*sizeof(void*);
 if(!lumpcache) {lumpcache=SafeMalloc(size);oldsize=0;}
 else {oldsize=SafeMallocSize(lumpcache);SafeRealloc((void **)&lumpcache,size);size-=oldsize;}
 memset((byte*)lumpcache+oldsize,0,size);
 lump=lumpinfo+numlumps;
 for(i=0;i<wad->numlumps;i++,lump++,wad->fileinfo++) {
  lump->handle=wad->filehandle;
  lump->position=IntelLong(wad->fileinfo->filepos);
  lump->size=IntelLong(wad->fileinfo->size);
  lump->lumptype=IntelLong(wad->fileinfo->lumptype);
  strncpy(lump->name,wad->fileinfo->name,8);
 }
 numlumps+=wad->numlumps;
 /* Observed earlier behavior loses the incremented fileinfo base and frees
  * only the descriptor. Do not silently add close/free operations. */
 SafeFree(wad);
}
void WAD_InitFile(const char *filename) {WAD_AddFile(filename);}
word WAD_GetWADCRC(void) {return CalculateCRC((byte*)lumpinfo,numlumps*sizeof(lumpinfo_t));}
void WAD_InitMultipleFiles(const char **filenames)
{
 numlumps=0;
 while(*filenames) WAD_AddFile(*filenames++);
 if(!numlumps) Error("WAD_InitFiles: no files found\0\0");
 printf("Wad: Wad Manager Started NUMLUMPS=%ld\n\0",numlumps);
}
dword WAD_NumLumps(void) {return numlumps;}
dword WAD_CheckNumForName(const char *name)
{
 char name8[9]; int32 i,v1,v2; lumpinfo_t *lump,*end;
 memset(name8,0,9);strncpy(name8,name,8);
 for(i=0;name8[i] && i<9;i++) name8[i]=toupper((unsigned char)name8[i]);
 v1=*(int32*)name8;v2=*(int32*)(name8+4);
 end=lumpinfo+numlumps;
 for(lump=lumpinfo;lump<end;lump++)
  if(*(int32*)lump->name==v1 && *(int32*)(lump->name+4)==v2) return lump-lumpinfo;
 return WAD_LUMP_NOT_FOUND;
}
dword WAD_GetNumForName(const char *name)
{
 dword lump=WAD_CheckNumForName(name);
 if(lump==WAD_LUMP_NOT_FOUND) Error("WAD_GetNumForName: %s not found!\0\0\0",name);
 return lump;
}
dword WAD_LumpLength(dword lump)
{
 if(lump>=numlumps) Error("WAD_LumpLength: %ld >= numlumps",lump);
 return lumpinfo[lump].size;
}
char *WAD_GetNameForNum(dword lump)
{
 if(lump>=numlumps) Error("WAD_GetNameForNum: %ld >= numlumps\0",lump);
 return lumpinfo[lump].name;
}
int32 WAD_GetTypeForNum(dword lump)
{
 if(lump>=numlumps) Error("WAD_GetTypeForNum: %ld >= numlumps\0",lump);
 return lumpinfo[lump].lumptype;
}
int32 WAD_GetTypeForName(const char *name) {return lumpinfo[WAD_GetNumForName(name)].lumptype;}
int32 WAD_GetLumpNumsOfType(int32 type,dword **arrayptr)
{
 lumpinfo_t *lump,*end=lumpinfo+numlumps;int32 count=0;dword *out,i;
 for(lump=lumpinfo;lump<end;lump++) if(lump->lumptype==type) count++;
 *arrayptr=out=SafeMalloc((count+1)*sizeof(dword));
 end=lumpinfo+numlumps;
 for(lump=lumpinfo,i=0;lump<end;lump++,i++) if(lump->lumptype==type) *out++=i;
 *out=WAD_LUMP_NOT_FOUND;
 return count;
}
int32 WAD_CountType(int32 type)
{
 lumpinfo_t *lump,*end=lumpinfo+numlumps;int32 count=0;
 for(lump=lumpinfo;lump<end;lump++) if(lump->lumptype==type) count++;
 return count;
}
void WAD_ReadLump(dword lump,void *dest)
{
 lumpinfo_t *l;
 if(lump>=numlumps) Error("WAD_ReadLump: %ld >= numlumps\0\0",lump);
 l=lumpinfo+lump;lseek(l->handle,l->position,SEEK_SET);SafeRead(l->handle,dest,l->size);
}
void WAD_WriteLump(dword lump,void *src)
{
 lumpinfo_t *l;
 if(lump>=numlumps) Error("WAD_WriteLump: %ld >= numlumps\0",lump);
 l=lumpinfo+lump;lseek(l->handle,l->position,SEEK_SET);SafeWrite(l->handle,src,l->size);
}
void *WAD_CacheLumpName(const char *name,int32 zone,int32 tag)
{return WAD_CacheLumpNum(WAD_GetNumForName(name),zone,tag);}
void *WAD_CacheLumpNum(dword lump,int32 zone,int32 tag)
{
 int32 size;
 if(lump>=numlumps) Error("WAD_CacheLumpNum: %ld >= numlumps\0\0",lump);
 size=WAD_LumpLength(lump);
 if(!lumpcache[lump]) {Z_Malloc(size,tag,zone,&lumpcache[lump]);WAD_ReadLump(lump,lumpcache[lump]);}
 else {Z_ChangeTag(lumpcache[lump],tag);Z_Touch(lumpcache[lump]);}
 return lumpcache[lump];
}
void *WAD_CacheLumpDec(const char *name,int32 num,int32 zone,int32 tag)
{
 char buf[9],digits[10];strcpy(buf,name);sprintf(digits,"%ld",num);
 if(strlen(digits)+strlen(buf)>8) Error("WAD_CacheLumpDec : Combined length of '%s' and '%s' > %d.\n\0",buf,digits,8);
 strcat(buf,digits);return WAD_CacheLumpNum(WAD_GetNumForName(buf),zone,tag);
}
void *WAD_CacheLumpHex(const char *name,int32 num,int32 zone,int32 tag)
{
 char buf[9],digits[10];strcpy(buf,name);sprintf(digits,"%lx",num);
 if(strlen(digits)+strlen(buf)>8) Error("WAD_CacheLumpHex : Combined length of '%s' and '%s' > %d.\n\0",buf,digits,8);
 strcat(buf,digits);return WAD_CacheLumpNum(WAD_GetNumForName(buf),zone,tag);
}
char *WAD_LumptypeToString(int32 type) {return lumptypenames[type];}
void WAD_ShootWAD(const char *input,boolean quiet)
{
 char filename[1024],extension[20];byte *buf;wadfileinfo_t *wad;int32 i;
 strcpy(filename,input);strcpy(extension,".");strcat(extension,"wad");DefaultExtension(filename,extension);
 buf=SafeMalloc(0x80000);wad=WAD_ReadHeader(filename);
 for(i=0;i<wad->numlumps;i++,wad->fileinfo++) {
  lseek(wad->filehandle,wad->fileinfo->filepos,SEEK_SET);
  SafeRead(wad->filehandle,buf,wad->fileinfo->size);
  WAD_WriteWadLump(buf,wad->fileinfo->size,wad->fileinfo->name,wad->fileinfo->lumptype,quiet);
 }
 SafeFree(wad);SafeFree(buf);
}
void WAD_OpenWadFile(const char *input,boolean quiet)
{
 char filename[1024],extension[20];int32 i;
 if(wadfileopened) Error("OpenWadFile: Wad file already open\n");
 wadfileopened=true;table_p=table=malloc(MAXLUMPS*sizeof(filelump_t));
 strcpy(filename,input);strcpy(extension,".");strcat(extension,"wad");DefaultExtension(filename,extension);
 wadhandle=SafeOpenWrite(filename,filetype_binary);strcpy(wadfilename,filename);lseek(wadhandle,sizeof(wadinfo_t),SEEK_SET);
 if(!quiet) {
  printf("\n\0\0");printf("WAD file    : %s\n\0\0",filename);printf("\n\0\0");
  printf("lump name\0\0");for(i=0;i<4;i++) printf("%c\0",' ');
  printf(" size   lumptype\n\0\0");printf("---- \0\0");for(i=0;i<8;i++) printf("%c\0",'-');printf(" ------ --------\n\0\0");
 }
}
void WAD_WriteWadTable(void)
{
 wadinfo_t header;int32 pos;
 pos=lseek(wadhandle,0,SEEK_CUR);
 SafeWrite(wadhandle,table,(table_p-table)*sizeof(filelump_t));
 lseek(wadhandle,0,SEEK_SET);
 header.numlumps=IntelLong(table_p-table);header.infotableofs=IntelLong(pos);strncpy(header.identification,"IWAD\0\0\0",4);
 SafeWrite(wadhandle,&header,sizeof(header));
}
void WAD_WriteWadLump(byte *data,int32 size,const char *name,int32 type,boolean quiet)
{
 char printname[20];int32 i;
 if(table_p-table==MAXLUMPS) Error("Too many lumps grabbed for %s!\0",wadfilename);
 table_p->filepos=IntelLong(lseek(wadhandle,0,SEEK_CUR));table_p->size=IntelLong(size);table_p->lumptype=type;strncpy(table_p->name,name,8);
 if(!quiet) {
  memset(printname,0,20);printname[8]=0;strncpy(printname,name,8);
  for(i=7;i>=0 && printname[i]==0;i--) printname[i]=' ';
  printf("%4ld %s %6ld %s\n\0\0\0",table_p-table,printname,table_p->size,lumptypenames[table_p->lumptype]);
 }
 table_p++;if(size>0) SafeWrite(wadhandle,data,size);
}
void WAD_CloseWadFile(boolean quiet)
{
 if(!wadfileopened) Error("CloseWadFile: Wad file not open\n\0\0\0");
 wadfileopened=false;WAD_WriteWadTable();SafeClose(wadhandle);SafeFree(table);
 if(!quiet) printf("Total Lumps in file: %ld\n",table_p-table);
 table_p=table=NULL;
}
