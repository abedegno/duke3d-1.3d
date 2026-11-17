/*
Copyright (C) 1994-1995 Apogee Software, Ltd.

This program is free software; you can redistribute it and/or
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

*/

/* Readable MACT ZONE native reconstruction using unchanged released types,
 * two-list header and list macros. ROTT supplies related source and the DPMI
 * query, not this entire original module/ABI. Historical local names unknown. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "types.h"
#include "develop.h"
#include "file_lib.h"
#include "util_lib.h"
#include "_zone.h"
/* Original public zone.h is unavailable; no substitute ABI header. */
#include "linklist.h"
#include "debug.h"
#include <dos.h>
#include <conio.h>
#define PU_PURGELEVEL 100 /* Released ROTT public API and native signed tag test. */

static memzone_t *MemoryZone[NUMZONES]={NULL};
static struct meminfo {
    unsigned LargestBlockAvail;
    unsigned MaxUnlockedPage;
    unsigned LargestLockablePage;
    unsigned LinAddrSpace;
    unsigned NumFreePagesAvail;
    unsigned NumPhysicalPagesFree;
    unsigned TotalPhysicalPages;
    unsigned FreeLinAddrSpace;
    unsigned SizeOfPageFile;
    unsigned Reserved[3];
} MemInfo;

int32 Z_AvailHeap(void);
void Z_PurgeZone(int32 zonenum);

static memzone_t *Z_GetZonePtr(int32 zonenum)
{
    if (zonenum<0 || zonenum>=NUMZONES) Error("Z_GetZonePtr: zonenum out of range.");
    return MemoryZone[zonenum];
}

static void Z_SetZonePtr(int32 zonenum,memzone_t *zone)
{
    if (zonenum<0 || zonenum>=NUMZONES) Error("Z_SetZonePtr: zonenum out of range.");
    MemoryZone[zonenum]=zone;
}

static void Z_ClearZone(int32 zonenum,memzone_t *zone)
{
    memblock_t *block;
    block=(memblock_t *)((byte *)zone+sizeof(memzone_t));
    LL_New(zone->usedlist,memblock_t,next,prev);
    zone->usedlist->user=(void **)2;
    zone->usedlist->size=0;
    zone->usedlist->zone=zonenum;
    LL_New(zone->freelist,memblock_t,next,prev);
    zone->freelist->user=(void **)2;
    zone->freelist->size=0;
    zone->freelist->zone=zonenum;
    LL_Add(zone->freelist,block,next,prev);
    block->user=NULL;
    block->size=zone->size-sizeof(memzone_t);
    block->tag=0;
    block->zone=zonenum;
}

static memzone_t *Z_AllocateZone(int32 zonenum,int32 size)
{
    memzone_t *zone;
    zone=malloc(size+sizeof(memzone_t));
    if (!zone) Error("Z_AllocateZone: Couldn't malloc %i bytes avail=%ld\n",size+sizeof(memzone_t),Z_AvailHeap());
    zone->size=size;
    Z_ClearZone(zonenum,zone);
    return zone;
}

static int32 Z_GetFreeZone(void)
{
    int32 zonenum,freezone=-1;
    for (zonenum=0;zonenum<NUMZONES;zonenum++)
        if (!Z_GetZonePtr(zonenum)) { freezone=zonenum;break; }
    if (freezone==-1) Error("Z_GetFreeZone: No inactive zones available.");
    return freezone;
}

void Z_FreeZone(int32 zonenum)
{
    memzone_t *zone=Z_GetZonePtr(zonenum);
    if (!zone) Error("Z_FreeZone: Tried to free an inactive Zone %d.\0",zonenum);
    SafeFree(zone->usedlist);
    SafeFree(zone->freelist);
    free(Z_GetZonePtr(zonenum));
    Z_SetZonePtr(zonenum,NULL);
}

int32 Z_Init(int32 size)
{
    int32 zonenum=Z_GetFreeZone();
    Z_SetZonePtr(zonenum,Z_AllocateZone(zonenum,size));
    return zonenum;
}

void Z_ShutDownZone(int32 zonenum)
{
    if (Z_GetZonePtr(zonenum)) { Z_PurgeZone(zonenum);Z_FreeZone(zonenum); }
}

void Z_ShutDown(void)
{
    int32 zonenum;
    for (zonenum=0;zonenum<NUMZONES;zonenum++)
        if (Z_GetZonePtr(zonenum)) { Z_PurgeZone(zonenum);Z_FreeZone(zonenum); }
}

int32 Z_GetSize(void *ptr)
{
    memblock_t *block=(memblock_t *)((byte *)ptr-sizeof(memblock_t));
    if (!Z_GetZonePtr(block->zone)) Error("Z_GetSize: Received pointer to inactive zone %d.\0\0\0",block->zone);
    return block->size-sizeof(memblock_t);
}

memblock_t *Z_AddFreeBlock(memblock_t *block,memzone_t *zone)
{
    memblock_t *base,*other;
    for (base=zone->freelist->next;base!=zone->freelist;base=base->next)
        if (block<=base) break;
    other=base->prev;
    if ((byte *)other+other->size==(byte *)block) {
        other->size+=block->size;
        block=other;
    } else LL_Add(base,block,next,prev);
    other=block->next;
    if ((byte *)block+block->size==(byte *)other) {
        block->size+=other->size;
        LL_Remove(other,next,prev);
    }
    block->tag=0;
    return block;
}

memblock_t *Z_FreeBlock(memblock_t *block,memzone_t *zone)
{
    if (!block->user) Error("Z_FreeBlock: freed a freed pointer\0");
    if (block->user>(void **)0x100) *block->user=NULL;
    block->user=NULL;
    LL_Remove(block,next,prev);
    return Z_AddFreeBlock(block,zone);
}

void Z_Free(void *ptr)
{
    memblock_t *block=(memblock_t *)((byte *)ptr-sizeof(memblock_t));
    memzone_t *zone=Z_GetZonePtr(block->zone);
    if (!zone) Error("Z_Free: Tried to free a pointer with inactive zone %d.\0",block->zone);
    Z_FreeBlock(block,zone);
}

void Z_FreeTags(int32 zonenum,int32 lowtag,int32 hightag)
{
    memzone_t *zone=Z_GetZonePtr(zonenum);
    memblock_t *block,*next;
    if (zone) {
        for (block=zone->usedlist->next;block!=zone->usedlist;block=next) {
            next=block->next;
            if (!block->user) Error("Z_FreeTag: found a free block in the used list\n");
            if (block->tag>=lowtag && block->tag<=hightag) Z_FreeBlock(block,zone);
        }
    }
}

void Z_PurgeZone(int32 zonenum)
{
    memzone_t *zone=Z_GetZonePtr(zonenum);
    memblock_t *block,*next;
    if (!zone) Error("Z_PurgeZone: Tried to purge an inactive Zone %d.\0\0\0",zonenum);
    for (block=zone->usedlist->next;block!=zone->usedlist;block=next) {
        next=block->next;
        if (!block->user) Error("Z_PurgeZone: found a free block in the usedlist\n\0\0\0");
        Z_FreeBlock(block,zone);
    }
}

memblock_t *Z_FindBlockInFreeList(memzone_t *zone,int32 size)
{
    memblock_t *block;
    for (block=zone->freelist->next;block!=zone->freelist;block=block->next)
        if (block->size>=size) break;
    if (block==zone->freelist) block=NULL;
    return block;
}

memblock_t *Z_FindFreeBlock(memzone_t *zone,int32 size)
{
    memblock_t *block,*next;
    block=Z_FindBlockInFreeList(zone,size);
    if (!block) {
        for (block=zone->usedlist->next;block!=zone->usedlist;block=next) {
            next=block->next;
            if (block->tag>=PU_PURGELEVEL) {
                block=Z_FreeBlock(block,zone);
                if (block->size>=size) return block;
            }
        }
        return NULL;
    }
    return block;
}

void *Z_Malloc(int32 size,int32 tag,int32 zonenum,void *user)
{
    int32 extra;
    memblock_t *base,*newblock,*next;
    memzone_t *zone;
    zone=Z_GetZonePtr(zonenum);
    if (!zone) Error("Z_Malloc: Tried to allocate %i bytes from inactive zone %d.",size,zonenum);
    size+=sizeof(memblock_t);
    base=Z_FindFreeBlock(zone,size);
    if (!base) Error("Z_Malloc: failed on allocation of %i bytes\0",size);
    extra=base->size-size;
    next=base->next;
    LL_Remove(base,next,prev);
    if (extra>MINFRAGMENT) {
        newblock=(memblock_t *)((byte *)base+size);
        newblock->size=extra;
        newblock->zone=zonenum;
        newblock->user=NULL;
        newblock->tag=0;
        LL_Add(next,newblock,next,prev);
        base->size=size;
    }
    if (user) { base->user=user;*(void **)user=(byte *)base+sizeof(memblock_t); }
    else {
        if (tag>=PU_PURGELEVEL) Error("Z_Malloc: an owner is required for purgable blocks\0");
        base->user=(void **)2;
    }
    base->tag=tag;
    base->pretag=MEMORYPRETAG;
    LL_Add(zone->usedlist,base,next,prev);
    return (byte *)base+sizeof(memblock_t);
}

void Z_Touch(void *ptr)
{
    memblock_t *block=(memblock_t *)((byte *)ptr-sizeof(memblock_t));
    memzone_t *zone=Z_GetZonePtr(block->zone);
    if (!zone) Error("Z_Touch: Tried to touch a pointer with inactive zone %d.\0\0\0",block->zone);
    LL_Move(block,zone->usedlist,next,prev);
}

void Z_Realloc(void **ptr,int32 newsize)
{
    memblock_t *block=(memblock_t *)((byte *)*ptr-sizeof(memblock_t));
    int32 zonenum=block->zone;
    memzone_t *zone=Z_GetZonePtr(zonenum);
    int32 oldsize,tag;
    void *newptr;
    void **owner;
    if (!zone) Error("Z_Realloc: Tried to reallocate pointer to inactive zone %d.",block->zone);
    oldsize=block->size;
    tag=block->tag;
    owner=block->user;
    if (owner!=ptr) owner=NULL;
    newptr=Z_Malloc(newsize,tag,zonenum,owner);
    /* Native copies the stored full block size from the current *ptr. */
    memcpy(newptr,*ptr,oldsize);
    Z_Free(*ptr);
    *ptr=newptr;
}

int32 Z_ZoneUsed(int32 zonenum)
{
    memzone_t *zone=Z_GetZonePtr(zonenum);
    memblock_t *block;
    int32 total;
    if (!zone) Error("Z_ZoneUsed: Zone %d not active.",zonenum);
    total=0;
    for (block=zone->usedlist->next;block!=zone->usedlist;block=block->next) total+=block->size;
    return total;
}

int32 Z_ZoneMaxFree(int32 zonenum)
{
    memzone_t *zone=Z_GetZonePtr(zonenum);
    memblock_t *block;
    int32 maximum;
    if (!zone) Error("Z_ZoneUsed: Zone %d not active.",zonenum);
    maximum=0;
    for (block=zone->freelist->next;block!=zone->freelist;block=block->next)
        if (block->size>maximum) maximum=block->size;
    return maximum;
}

int32 Z_ZoneSize(int32 zonenum)
{
    memzone_t *zone=Z_GetZonePtr(zonenum);
    if (!zone) Error("Z_ZoneSize: Zone %d not active.",zonenum);
    return zone->size;
}

void Z_ChangeTag(void *ptr,int32 tag)
{
    memblock_t *block=(memblock_t *)((byte *)ptr-sizeof(memblock_t));
    if (!Z_GetZonePtr(block->zone)) Error("Z_ChangeTag: Received pointer to inactive zone %d.\0",block->zone);
    block->tag=tag;
}

/* This body and real DPMI meminfo fields derive from released ROTT Z_ZONE.C. */
int32 Z_AvailHeap(void)
{
    union REGS zregs;
    struct SREGS zsregs;
    memset(&zsregs,0,sizeof(zsregs));
    zregs.x.eax=0x500;
    zsregs.es=FP_SEG(&MemInfo);
    zregs.x.edi=FP_OFF(&MemInfo);
    int386x(DPMI_INT,&zregs,&zregs,&zsregs);
    return (int32)MemInfo.LargestBlockAvail;
}

void Z_DumpHeap(int32 lowtag,int32 hightag)
{
    memblock_t *block;
    int32 total;
    int32 zonenum;
    memzone_t *zone;
    for (zonenum=0;zonenum<NUMZONES;zonenum++) {
        zone=Z_GetZonePtr(zonenum);
        if (!zone) Dbg("ZONE %d not active.\n\0\0\0",zonenum);
        else {
            Dbg("ZONE %d\n\0\0\0",zonenum);
            Dbg("zone size: %i  location: %p\n\0\0\0",zone->size,zone);
            Dbg("tag range: %i to %i\n\0\0\0",lowtag,hightag);
            total=0;
            for (block=zone->usedlist->next;block!=zone->usedlist;block=block->next) {
                if (block->tag>=lowtag && block->tag<=hightag) {
                    Dbg("block:%p    size:%7i    user:%p    tag:%3i\n",block,block->size,block->user,block->tag);
                    total+=block->size;
                }
                if ((byte *)block+block->size!=(byte *)block->next)
                    Dbg("ERROR: block size does not touch the next block\n\0\0\0");
                if (block->next->prev!=block)
                    Dbg("ERROR: next block doesn't have proper back link\n\0\0\0");
                if (!block->user && !block->next->user)
                    Dbg("ERROR: two consecutive free blocks\n");
            }
            Dbg("Total Size of blocks = %ld\n",total);
        }
    }
}

void Z_CheckHeap(void)
{
    int32 zonenum;
    memzone_t *zone;
    memblock_t *block;
    for (zonenum=0;zonenum<NUMZONES;zonenum++) {
        zone=Z_GetZonePtr(zonenum);
        if (zone) {
            for (block=zone->usedlist->next;block!=zone->usedlist;block=block->next) {
                if ((byte *)block+block->size!=(byte *)block->next)
                    Error("Z_CheckHeap: block size does not touch the next block\n\0");
                if (block->next->prev!=block)
                    Error("Z_CheckHeap: next block doesn't have proper back link\n\0");
                if (!block->user && !block->next->user)
                    Error("Z_CheckHeap: two consecutive free blocks\n\0\0");
                if (block->tag>0 && block->user>(void **)0)
                    if (block->pretag!=MEMORYPRETAG) Error("Z_CheckHeap: Corrupted pretag\n");
            }
        }
    }
}
