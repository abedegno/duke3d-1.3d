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

/* Analysis reconstruction of MACT rgb.c, 2026.
 * Function names/scopes and storage roles come from original OMF metadata.
 * Algorithm inferred from instruction analysis; not recovered historical source.
 * ROTT RT_UTIL.C supplied a related BestColor/FindEGAColors comparison and the
 * matching standard EGA RGB values. Signed difference table indexing below
 * reflects observed code; no safety correction or inferred absolute was added.
 */
unsigned char RGB_Lookup[64][64][64];
unsigned char RGB_EGATable[16];
static int WeightBlue[256];
static int WeightGreen[256];
static int WeightRed[256];
static int WeightTable = 0;
static unsigned char egargb[48] = {
 0,0,0, 0,0,171, 0,171,0, 0,171,171,
 171,0,0, 171,0,171, 171,87,0, 171,171,171,
 87,87,87, 87,87,255, 87,255,87, 87,255,255,
 255,87,87, 255,87,255, 255,255,87, 255,255,255
};
extern void VID_GetPalette(unsigned char *palette);

void RGB_FindEGAColors(void)
{
 int i;
 for(i=0;i<16;i++)
  RGB_EGATable[i]=RGB_Lookup[(int)egargb[i*3]>>2][(int)egargb[i*3+1]>>2][(int)egargb[i*3+2]>>2];
}

static void RGB_MakeWeightTable(void)
{
 int i, square;
 for(i=0;i<256;i++) {
  square=i*i;
  WeightRed[i]=213*square/1000;
  WeightGreen[i]=715*square/1000;
  WeightBlue[i]=72*square/1000;
 }
 WeightTable=1;
}

unsigned char RGB_FindBestColor(short r, short g, short b, unsigned char *palette)
{
 int i, dr,dg,db, bestdistortion,distortion,bestcolor;
 unsigned char *pal;
 if(!WeightTable) RGB_MakeWeightTable();
 bestdistortion=WeightRed[r]+WeightGreen[g]+WeightBlue[b];
 bestcolor=0;
 pal=palette;
 for(i=0;i<=255;i++,pal+=3) {
  dr=r-(int)pal[0]; dg=g-(int)pal[1]; db=b-(int)pal[2];
  distortion=WeightRed[dr]+WeightGreen[dg]+WeightBlue[db];
  if(distortion<bestdistortion) {
   if(!distortion) return i;
   bestdistortion=distortion; bestcolor=i;
  }
 }
 return bestcolor;
}

unsigned char RGB_GetBestColor(short r, short g, short b)
{
 unsigned char palette[768];
 VID_GetPalette(palette);
 return RGB_FindBestColor(r,g,b,palette);
}

#if !defined(DUKE13D_RGB_TABLE_ASM) || !DUKE13D_RGB_TABLE_ASM
void RGB_MakeColorTable(void)
{
 unsigned char palette[768];
 int r,g,b;
 VID_GetPalette(palette);
 for(r=0;r<64;r++)
  for(g=0;g<64;g++)
   for(b=0;b<64;b++)
    RGB_Lookup[r][g][b]=RGB_FindBestColor(r<<2,g<<2,b<<2,palette);
 RGB_FindEGAColors();
}

#else
extern void RGB_MakeColorTable(void);
#endif
