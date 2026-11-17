/* Recovered memory-to-memory MACT LBM semantics. Released interface notices
 * are retained in include/. This is reconstructed C, not recovered original.
 * Native quirks are deliberately preserved; see SEMANTICS.md. */
#include <string.h>
#include "TYPES.H"
#include "UTIL_LIB.H"
#include "LBMLIB.H"
#include "_LBMLIB.H"
static byte bitplanes[9][BPLANESIZE];
int32 Align(int32 count) { if(count&1) return count+1; return count; }
byte *LBMRLEDecompress(byte *source, byte *dest, int32 width)
{
 int32 count=0; byte repeat;
 do {
  repeat=*source++;
  if(repeat>0x80) {repeat=(repeat^0xff)+2; memset(dest,*source++,repeat);dest+=repeat;}
  else if(repeat<0x80) {repeat++;memcpy(dest,source,repeat);dest+=repeat;source+=repeat;}
  else repeat=0;
  count+=repeat;
 } while(count<width);
 if(count>width) Error("LBMRLEDecompress: Decompression exceeded width!\n");
 return source;
}
void MungeBitPlanes(int32 width,byte *dest,int32 planes)
{
 int32 x,p,offset=0,remaining=8; int32 color;
 for(x=0;x<width;x++) {
  color=0;
  for(p=0;p<planes;p++) color|=bitplanes[p][offset]<<p;
  *dest++=color;
  if(--remaining==0) {remaining=8;offset++;}
 }
}
int32 LoadLBM(byte *compressed,byte *uncompressed,byte *palette,int32 *lbmwidth,int32 *lbmheight)
{
 bmhd_t bmhd; int32 stencil=0,length,id,formtype,y,p,planes,rowsize;
 byte *end,*chunk,*dest,*source;
 source=compressed;
 if(*(int32 *)source!=FORMID) Error("LoadLBM: No FORM ID at start of file!\n");
 source+=4; length=MotoLong(*(int32 *)source);source+=4;end=source+Align(length);
 formtype=*(int32 *)source;
 if(formtype!=ILBMID&&formtype!=PBMID)
  Error("Unrecognized form type: %c%c%c%c\n",formtype&255,(formtype>>8)&255,(formtype>>16)&255,(formtype>>24)&255);
 source+=4;
 while(source<end) {
  id=*(int32 *)source;source+=4;length=MotoLong(*(int32 *)source);source+=4;chunk=source;
  switch(id) {
  case BMHDID:
   memcpy(&bmhd,chunk,sizeof(bmhd));
   bmhd.w=MotoShort(bmhd.w);bmhd.h=MotoShort(bmhd.h);
   bmhd.x=MotoShort(bmhd.x);bmhd.y=MotoShort(bmhd.y);
   bmhd.pageWidth=MotoShort(bmhd.pageWidth);bmhd.pageHeight=MotoShort(bmhd.pageHeight);
   *lbmwidth=bmhd.w;*lbmheight=bmhd.h;
   if(bmhd.w>320||bmhd.h>200) return LoadLBM_badsize;
   break;
  case CMAPID:memset(palette,0,768);memcpy(palette,chunk,length);break;
  case BODYID:
   dest=uncompressed;
   if(formtype==PBMID) {
    for(y=0;y<bmhd.h;y++) {
     if(bmhd.compression==cm_rle1) chunk=LBMRLEDecompress(chunk,dest,bmhd.w);
     else if(bmhd.compression==cm_none) {memcpy(dest,chunk,bmhd.w);chunk+=Align(bmhd.w);}
     dest+=bmhd.w;
    }
   } else {
    planes=bmhd.nPlanes;
    if(bmhd.masking==ms_mask){planes++;stencil=1;}
    rowsize=((bmhd.w+15)/16)*2;
    for(y=0;y<bmhd.h;y++) {
     for(p=0;p<planes;p++) {
      if(bmhd.compression==cm_rle1) chunk=LBMRLEDecompress(chunk,bitplanes[p],rowsize);
      else if(bmhd.compression==cm_none){memcpy(bitplanes[p],chunk,rowsize);chunk+=rowsize;}
     }
     MungeBitPlanes(bmhd.w,dest,bmhd.nPlanes);dest+=bmhd.w;
    }
   }
   break;
  }
  source+=Align(length);
 }
 return stencil?LoadLBM_stencil:LoadLBM_Okay;
}
int32 SaveLBM(byte *uncompressed,byte *compressed,byte *palette,int32 lbmwidth,int32 lbmheight)
{
 bmhd_t bmhd;byte *dest=compressed,*formlength,*chunklength;int32 length;
 *dest++='F';*dest++='O';*dest++='R';*dest++='M';formlength=dest;dest+=4;
 *dest++='P';*dest++='B';*dest++='M';*dest++=' ';
 *dest++='B';*dest++='M';*dest++='H';*dest++='D';
 memset(&bmhd,0,sizeof(bmhd));bmhd.w=MotoShort(lbmwidth);bmhd.h=MotoShort(lbmheight);
 bmhd.nPlanes=MotoShort(8);bmhd.xAspect=MotoShort(5);bmhd.yAspect=MotoShort(6);
 bmhd.pageWidth=MotoShort(lbmwidth);bmhd.pageHeight=MotoShort(lbmheight);
 chunklength=dest;dest+=4;memcpy(dest,&bmhd,sizeof(bmhd));dest+=sizeof(bmhd);
 length=dest-chunklength-4;*(int32 *)chunklength=MotoLong(length);if(length&1)*dest++=0;
 *dest++='C';*dest++='M';*dest++='A';*dest++='P';chunklength=dest;dest+=4;
 memcpy(dest,palette,768);dest+=768;length=dest-chunklength-4;*(int32 *)chunklength=MotoLong(length);if(length&1)*dest++=0;
 *dest++='B';*dest++='O';*dest++='D';*dest++='Y';chunklength=dest;dest+=4;
 memcpy(dest,uncompressed,lbmwidth*lbmheight);dest+=lbmwidth*lbmheight;
 length=dest-chunklength-4;*(int32 *)chunklength=MotoLong(length);if(length&1)*dest++=0;
 length=dest-formlength-4;*(int32 *)formlength=MotoLong(length);if(length&1)*dest++=0;
 return dest-compressed;
}
