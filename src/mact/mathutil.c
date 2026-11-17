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


/* Reconstructed MACT math utilities, derived from the related ROTT routines.
   Historical MACT source spelling is not asserted. See the source-reference
   evidence for function renamings, axis returns and high-precision distance. */
#include <stdlib.h>
#define SWAP(a,b) \
   {              \
   a=(a)^(b);     \
   b=(a)^(b);     \
   a=(a)^(b);     \
   }              \

//******************************************************************************
//
// FindDistance
//
//******************************************************************************

int FindDistance2D(int ix, int iy)
{
  int   t;

  ix= abs(ix);        /* absolute values */
  iy= abs(iy);

  if (iy==0) return ix;
  if (ix==0) return iy;

  if (ix<iy)
     SWAP(ix,iy);

  t = iy + (iy>>1);

  return (ix - (ix>>5) - (ix>>7)  + (t>>2) + (t>>6));
}


//******************************************************************************
//
// Find_3D_Distance
//
//******************************************************************************

int FindDistance3D(int ix, int iy, int iz)
   {
   int   t;

   ix= abs(ix);           /* absolute values */
   iy= abs(iy);
   iz= abs(iz);

   if (ix<iy)
     SWAP(ix,iy);

   if (ix<iz)
     SWAP(ix,iz);

   t = iy + iz;

   return (ix - (ix>>4) + (t>>2) + (t>>3));
   }

//******************************************************************************
//

typedef long fixed;
#define ANGLESDIV8 (2048/8)
#define FINEANGLES 2048
#include "watcom.h"
#include "rt_sqrt.h"

/* Recovered fixed-point high precision distance: scale inputs to retain range,
   sum rounded fixed squares, take the historical fixed square root, rescale. */
long FindDistance3D_HP(long x, long y, long z)
{
 x >>= 5; y >>= 5; z >>= 5;
 x = FixedMul(x,x);
 y = FixedMul(y,y);
 z = FixedMul(z,z);
 return FixedSqrtHP(x+y+z) << 5;
}
int ArcTangentAppx(int dx, int dy)
{int absdx, absdy;
 fixed angle;
 fixed ratio;


 if (!(dx||dy))
  return 0;
 absdx = abs(dx);
 absdy = abs(dy);
 if (absdx >= absdy)
  ratio = FixedDiv2(absdy,absdx);
 else
  ratio = FixedDiv2(absdx,absdy);

 if (dx >= 0)
  {if (dy >= 0)
	 {if (absdx >= absdy)
		angle = ratio;	    // 1st octant
	  else
		angle = (2<<16) - ratio; // 2nd octant
	 }
	else
	 {if (absdx >= absdy)
		angle = (8<<16) - ratio; // 8th octant
	  else
		angle = (6<<16) + ratio; // 7th octant
	 }
  }
 else
  {if (dy >= 0)
	 {if (absdx >= absdy)
		angle = (4<<16) - ratio; // 4th octant
	  else
		angle = (2<<16) + ratio; // 3rd octant
	 }
	else
	 {if (absdx >= absdy)
		angle = (4<<16) + ratio; // 5th octant
	  else
		angle = (6<<16) - ratio; // 6th octant
	 }
  }

 return (((int)FixedMul(angle,ANGLESDIV8))&(FINEANGLES-1));
}



//******************************************************************************
//
