/* Native-guided readable reconstruction of the released MACT mipmap API.
 * Exact original MIPMAP.C was not located. Published API, rgb_t, task-independent
 * types and allocation contracts are retained in lineage/include with notices.
 * Pixel accumulator field names are inferred from their native uses:
 * weight plus three normalized channel totals, all double precision.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include "types.h"
#include "develop.h"
#include "clrmap.h"
#include "util_lib.h"

typedef struct
   {
   double weight;
   double r,g,b;
   } mip_pixel_t;

void FoldPixel
   (
   int32 x,
   int32 y,
   int32 srcw,
   int32 destw,
   mip_pixel_t *src,
   mip_pixel_t *dest
   )
   {
   int32 srcindex = 2*x + 2*y*srcw;
   int32 destindex = x + y*destw;
   mip_pixel_t *d = dest + destindex;
   mip_pixel_t *s = src + srcindex;
   d->weight = s->weight;
   d->r = s->r;
   d->g = s->g;
   d->b = s->b;
   d->weight += s[1].weight;
   d->r += s[1].r;
   d->g += s[1].g;
   d->b += s[1].b;
   s = src + (srcindex+srcw);
   d->weight += s->weight;
   d->r += s->r;
   d->g += s->g;
   d->b += s->b;
   d->weight += s[1].weight;
   d->r += s[1].r;
   d->g += s[1].g;
   d->b += s[1].b;
   }

int32 CreateMipMap
   (
   int32 origw,
   int32 origh,
   int32 level,
   byte *srcbitmap,
   byte *destbitmap,
   byte *pal,
   boolean usediffusion
   )
   {
   mip_pixel_t *pixels,*folded,*p;
   int32 size,w,h,nextw,nexth,x,y;
   byte *c,*d,color;
   double r,g,b,er=0,eg=0,eb=0;

   size = origw*origh*sizeof(mip_pixel_t);
   pixels = SafeMalloc(size);
   folded = SafeMalloc(size/4);
   memset(pixels,0,size);
   memset(folded,0,size/4);
   w = origw;
   h = origh;
   nextw = w/2;
   nexth = h/2;
   for(y=0;y<h;y++)
      for(x=0;x<w;x++)
         {
         p = pixels+y*w+x;
         c = pal+3*srcbitmap[y*w+x];
         p->r = c[0]/256.0;
         p->g = c[1]/256.0;
         p->b = c[2]/256.0;
         p->weight = 1;
         }
   while(level>0)
      {
      for(y=0;y<nexth;y++)
         for(x=0;x<nextw;x++)
            FoldPixel(x,y,w,nextw,pixels,folded);
      size /= 4;
      memcpy(pixels,folded,size);
      w = nextw;
      h = nexth;
      nextw /= 2;
      nexth /= 2;
      level--;
      }
   for(y=0;y<h;y++)
      for(x=0;x<w;x++)
         {
         p = pixels+y*w+x;
         d = destbitmap+y*w+x;
         r = (p->r+er)/p->weight;
         g = (p->g+eg)/p->weight;
         b = (p->b+eb)/p->weight;
         color = CMAP_BestColor(r,g,b,pal,0,256);
         *d = color;
         if(usediffusion)
            {
            r -= pal[3*color]/256.0;
            g -= pal[3*color+1]/256.0;
            b -= pal[3*color+2]/256.0;
            er = r;
            eg = g;
            eb = b;
            }
         }
   SafeFree(pixels);
   SafeFree(folded);
   return(w*h);
   }
