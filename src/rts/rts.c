//-------------------------------------------------------------------------
/*
Copyright (C) 1996, 2003 - 3D Realms Entertainment

This file is part of Duke Nukem 3D version 1.5 - Atomic Edition

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

Original Source: 1996 - Todd Replogle
Prepared for public release: 03/21/2003 - Charlie Wiederhold, 3D Realms
*/
//-------------------------------------------------------------------------

/* Reconstructed v1.3D module. The private name lump_info reproduces Watcom's
 * measured BSS order; it is not claimed to be the original spelling.
 * The shared pragma header omits the later timeroffs1mhz state/routines.
 * RTS Manager Started has no period in this release.
 *
 * Watcom 10.0 /4r /s /oteir. Every emitted module segment, including the
 * explicit alignment bytes below, is checked against the original image.
 */
#include "duke3d.h"

/* These small padding fields preserve measured, unreferenced bytes between
 * messages. Leaving them to Watcom's uninitialized constant-buffer padding
 * makes output depend on prior compiler memory contents. No code is stored
 * as a byte array. */
#pragma data_seg("CONST", "DATA")
static struct {
    char adding[16];
    char iwad[5];
    unsigned char pad_iwad[3];
    char bad_id[34];
    unsigned char pad_bad_id[2];
    char stack_fail[49];
    unsigned char pad_stack_fail[3];
    char started[21];
    unsigned char pad_started[3];
    char length[32];
    char name[33];
    unsigned char pad_name[3];
    char read_large[29];
    unsigned char pad_read_large[3];
    char read_negative[21];
    unsigned char pad_read_negative[3];
    char sound[24];
} rts_text = {
    "    Adding %s.\n",
    "IWAD",
    {0x7, 0x0, 0x2c},
    "RTS file %s doesn't have IWAD id\n",
    {0x20, 0x50},
    "RTS file could not allocate header info on stack",
    {0x73, 0x20, 0x28},
    "RTS Manager Started\n",
    {0x20, 0x70, 0x6c},
    "RTS_SoundLength: %i >= numlumps",
    "RTS_GetSoundName: %i >= numlumps",
    {0xa, 0x0, 0x49},
    "RTS_ReadLump: %i >= numlumps",
    {0x76, 0x65, 0x20},
    "RTS_ReadLump: %i < 0",
    {0x6f, 0x75, 0x6c},
    "RTS_GetSound: %i >= %i\n"
};
#pragma data_seg()

//=============
// STATICS
//=============

int32 numlumps;
static void  **lumpcache;
static lumpinfo_t *lump_info;              // location of each lump on disk
static boolean RTS_Started = false;

char lumplockbyte[11];

/*
============================================================================

                                                LUMP BASED ROUTINES

============================================================================
*/

/*
====================
=
= RTS_AddFile
=
= All files are optional, but at least one file must be found
= Files with a .rts extension are wadlink files with multiple lumps
= Other files are single lumps with the base filename for the lump name
=
====================
*/

void RTS_AddFile (char *filename)
   {
   wadinfo_t  header;
   lumpinfo_t *lump_p;
   uint32     i;
   int32      handle, length;
   int32      startlump;
   filelump_t *fileinfo;

//
// read the entire file in
//      FIXME: shared opens

   handle = SafeOpenRead( filename, filetype_binary );

   startlump = numlumps;

   // WAD file
   printf(rts_text.adding,filename);
   SafeRead( handle, &header, sizeof( header ) );
   if (strncmp(header.identification,rts_text.iwad,4))
      Error (rts_text.bad_id,filename);
   header.numlumps = IntelLong(header.numlumps);
   header.infotableofs = IntelLong(header.infotableofs);
   length = header.numlumps*sizeof(filelump_t);
   fileinfo = alloca (length);
   if (!fileinfo)
      Error (rts_text.stack_fail);
   lseek (handle, header.infotableofs, SEEK_SET);
   SafeRead (handle, fileinfo, length);
   numlumps += header.numlumps;

//
// Fill in lump_info
//
   SafeRealloc(&lump_info,numlumps*sizeof(lumpinfo_t));
   lump_p = &lump_info[startlump];

   for (i=startlump ; i<numlumps ; i++,lump_p++, fileinfo++)
      {
      lump_p->handle = handle;
      lump_p->position = IntelLong(fileinfo->filepos);
      lump_p->size = IntelLong(fileinfo->size);
      strncpy (lump_p->name, fileinfo->name, 8);
      }
   }

/*
====================
=
= RTS_Init
=
= Files with a .rts extension are idlink files with multiple lumps
=
====================
*/

void RTS_Init (char *filename)
   {
   int32 length;
   //
   // open all the files, load headers, and count lumps
   //
   numlumps = 0;
   lump_info = SafeMalloc(5);   // will be realloced as lumps are added

   printf(rts_text.started);
   if (SafeFileExists(filename))
      RTS_AddFile (filename);

   if (!numlumps) return;

   //
   // set up caching
   //
   length = (numlumps) * sizeof( *lumpcache );
   lumpcache = SafeMalloc(length);
   memset(lumpcache,0,length);
   RTS_Started = true;
   }


/*
====================
=
= RTS_NumSounds
=
====================
*/

int32 RTS_NumSounds (void)
   {
   return numlumps-1;
   }

/*
====================
=
= RTS_SoundLength
=
= Returns the buffer size needed to load the given lump
=
====================
*/

int32 RTS_SoundLength (int32 lump)
   {
   lump++;
   if (lump >= numlumps)
      Error (rts_text.length,lump);
   return lump_info[lump].size;
   }

/*
====================
=
= RTS_GetSoundName
=
====================
*/

char * RTS_GetSoundName (int32 i)
   {
   i++;
   if (i>=numlumps)
      Error (rts_text.name,i);
   return &(lump_info[i].name[0]);
   }

/*
====================
=
= RTS_ReadLump
=
= Loads the lump into the given buffer, which must be >= RTS_SoundLength()
=
====================
*/
void RTS_ReadLump (int32 lump, void *dest)
   {
   lumpinfo_t *l;

   if (lump >= numlumps)
      Error (rts_text.read_large,lump);
   if (lump < 0)
      Error (rts_text.read_negative,lump);
   l = lump_info+lump;
   lseek (l->handle, l->position, SEEK_SET);
   SafeRead(l->handle,dest,l->size);
   }

/*
====================
=
= RTS_GetSound
=
====================
*/
void *RTS_GetSound (int32 lump)
{
   lump++;
   if ((uint32)lump >= numlumps)
      Error (rts_text.sound,lump,numlumps);

   if (lumpcache[lump] == NULL)
   {
      lumplockbyte[lump] = 200;
      allocache((char *)&lumpcache[lump],(long)RTS_SoundLength(lump-1),&lumplockbyte[lump]);
      RTS_ReadLump(lump, lumpcache[lump]);
   }
   else
   {
      if (lumplockbyte[lump] < 200)
         lumplockbyte[lump] = 200;
      else
         lumplockbyte[lump]++;
   }
   return lumpcache[lump];
}
