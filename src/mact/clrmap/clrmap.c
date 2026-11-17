/* Readable CLRMAP reconstruction, not a claim of historical source identity.
 * Released API/types and full 3D Realms GPL notices accompany this source.
 * Arithmetic, unusual ranges/mutations and missing frees follow the native
 * behavior; mathematically cleaner color conversions are not substituted.
 */
#include <math.h>
#include "types.h"
#include "clrmap.h"
#include "_clrmap.h"
#include "util_lib.h"

/* Actual private EGA palette: the native three-channel boundary levels are
 * 87,171,255. Color names establish logical order; values are observations,
 * not a claim that every historical EGA implementation used these levels. */
#define EGA_DARK 87
#define EGA_MID 171
#define EGA_FULL 255
static byte egargb[16][3] = {
 {0,0,0}, {0,0,EGA_FULL}, {0,EGA_FULL,0}, {0,EGA_FULL,EGA_FULL},
 {EGA_FULL,0,0}, {EGA_FULL,0,EGA_FULL}, {EGA_MID,EGA_DARK,0},
 {EGA_MID,EGA_MID,EGA_MID}, {EGA_DARK,EGA_DARK,EGA_DARK},
 {EGA_DARK,EGA_DARK,EGA_FULL}, {EGA_DARK,EGA_FULL,EGA_DARK},
 {EGA_DARK,EGA_FULL,EGA_FULL}, {EGA_FULL,EGA_DARK,EGA_DARK},
 {EGA_FULL,EGA_DARK,EGA_FULL}, {EGA_FULL,EGA_FULL,EGA_DARK},
 {EGA_FULL,EGA_FULL,EGA_FULL}
};
byte egacolor[16];

void HSV_TO_RGB(hsv_t *hsv,rgb_t *rgb)
{
 int32 sector; double fraction,p,q,t;
 if(fabs(hsv->s)<=0.035) {rgb->r=hsv->v;rgb->g=hsv->v;rgb->b=hsv->v;}
 else {
  if(hsv->h==360.0) hsv->h=0.0;
  hsv->h/=60.0; /* actual observable input mutation */
  sector=(int32)hsv->h; fraction=hsv->h-sector;
  p=hsv->v*(1.0-hsv->s);
  q=hsv->v*(1.0-hsv->s*fraction);
  t=hsv->v*(1.0-hsv->s*(1.0-fraction));
  switch(sector) {
   case 0:rgb->r=hsv->v;rgb->g=t;rgb->b=p;break;
   case 1:rgb->r=q;rgb->g=hsv->v;rgb->b=p;break;
   case 2:rgb->r=p;rgb->g=hsv->v;rgb->b=t;break;
   case 3:rgb->r=p;rgb->g=q;rgb->b=hsv->v;break;
   case 4:rgb->r=t;rgb->g=p;rgb->b=hsv->v;break;
   case 5:rgb->r=hsv->v;rgb->g=p;rgb->b=q;break;
  }
 }
}
void RGB_TO_HSV(rgb_t *color,hsv_t *hsv)
{
 rgb_t rgb=*color; double maximum,minimum,delta;
 if(rgb.r>rgb.g) {if(rgb.r>rgb.b)maximum=rgb.r;else maximum=rgb.b;}
 else {if(rgb.g>rgb.b)maximum=rgb.g;else maximum=rgb.b;}
 if(rgb.r<rgb.g) {if(rgb.r<rgb.b)minimum=rgb.r;else minimum=rgb.b;}
 else {if(rgb.g<rgb.b)minimum=rgb.g;else minimum=rgb.b;}
 hsv->v=maximum;
 if(maximum!=0.0)hsv->s=(maximum-minimum)/maximum;else hsv->s=0.0;
 if(fabs(hsv->s)<=0.035)hsv->h=-1.0;
 else {
  delta=maximum-minimum;
  if(rgb.r==maximum)hsv->h=(rgb.g-rgb.b)/delta;
  else if(rgb.g==maximum)hsv->h=2.0+(rgb.b-rgb.r)/delta;
  else if(rgb.b==maximum)hsv->h=4.0+(rgb.r-rgb.g)/delta;
  hsv->h*=60.0;if(hsv->h<0.0)hsv->h+=360.0;
 }
}
void GetDarkenedColor(rgb_t *rgb,int32 level,int32 levels)
{
 hsv_t hsv;double saturation_step,value_step;int32 i;
 RGB_TO_HSV(rgb,&hsv);levels--;
 if(hsv.s>=0.0039) {
  saturation_step=(1.0-hsv.s)/levels;value_step=hsv.v/levels;
  for(i=0;i<level;i++){hsv.s+=saturation_step;hsv.v-=value_step;}
  if(hsv.v<0.0)hsv.v=0.0;if(hsv.s>1.0)hsv.s=1.0;
 }else{
  value_step=hsv.v/levels;hsv.h=-1.0;
  for(i=0;i<level;i++)hsv.v-=value_step;
  if(hsv.v<0.0)hsv.v=0.0;
 }
 HSV_TO_RGB(&hsv,rgb);
}
void RGB_TO_YIQ(rgb_t *rgb,yiq_t *yiq)
{
 yiq->y=.2989*rgb->r+.5866*rgb->g+.1144*rgb->b;
 yiq->i=.5959*rgb->r-.2741*rgb->g-.3218*rgb->b;
 yiq->q=.2113*rgb->r-.5227*rgb->g+.3113*rgb->b;
}
void YIQ_TO_RGB(yiq_t *yiq,rgb_t *rgb)
{
 rgb->r=yiq->y+.9562*yiq->i+.6210*yiq->q;
 rgb->g=yiq->y-.2717*yiq->i-.6485*yiq->q;
 rgb->b=yiq->y-1.1053*yiq->i+1.702*yiq->q;
}
void RGB_TO_XYZ(rgb_t *rgb,xyz_t *xyz)
{
 xyz->x=.412453*rgb->r+.357580*rgb->g+.180423*rgb->b;
 xyz->y=.212671*rgb->r+.715160*rgb->g+.072169*rgb->b;
 xyz->z=.019334*rgb->r+.119193*rgb->g+.950277*rgb->b;
}
void XYZ_TO_RGB(xyz_t *xyz,rgb_t *rgb)
{
 rgb->r=3.240479*xyz->x-1.537150*xyz->y-.498535*xyz->z;
 rgb->g=-.969256*xyz->x+1.875991*xyz->y+.041556*xyz->z;
 rgb->b=.055648*xyz->x-.204043*xyz->y+1.057311*xyz->z;
 if(rgb->r<0.0)rgb->r=0.0;if(rgb->g<0.0)rgb->g=0.0;if(rgb->b<0.0)rgb->b=0.0;
}
void XYZ_TO_LUV(xyz_t *xyz,luv_t *luv)
{
 double yr=xyz->y,den,up,vp;
 if(yr>=.008856)luv->l=116.0*pow(yr,1.0/3.0)-16.0;else luv->l=903.3*yr;
 if(luv->l<=0.0){luv->l=0.0;luv->u=0.0;luv->v=0.0;return;}
 den=xyz->x+15.0*xyz->y+3.0*xyz->z;
 up=4.0*xyz->x/den;vp=9.0*xyz->y/den;
 luv->u=13.0*luv->l*(up-.197837857865288);
 luv->v=13.0*luv->l*(vp-.4683385450740464);
}
void LUV_TO_XYZ(luv_t *luv,xyz_t *xyz)
{
 double up,vp,un=.197837857865288;
 if(fabs(luv->l)<=.0001){xyz->x=0.0;xyz->y=0.0;xyz->z=0.0;return;}
 xyz->y=pow((luv->l+16.0)/116.0,3.0);
 vp=luv->v/(13.0*luv->l)+.4683385450740464;
 if(fabs(vp)<.2){
  /* Actual legacy input mutation; Y above is not recomputed. */
  luv->l=-luv->v/-3.4884010859626033;
  vp=luv->v/(13.0*luv->l)+.4683385450740464;
 }
 up=luv->u/(13.0*luv->l)+un;
 xyz->z=((up-4.0)*3.0*xyz->y*(5.0*vp-3.0)-15.0*up*vp*xyz->y)/(12.0*vp);
 xyz->x=-(3.0*xyz->z+3.0*xyz->y*(5.0*vp-3.0)/vp);
}
void CMAP_BuildYIQPalette(yiq_t **out,byte *pal,byte low,byte high)
{
 int32 i;rgb_t rgb;yiq_t *p;
 *out=SafeMalloc((high-low+1)*sizeof(yiq_t));p=*out;
 for(i=low;i<high;i++) { /* native exclusive high despite extra allocation */
  rgb.r=pal[3*i]/256.0;rgb.g=pal[3*i+1]/256.0;rgb.b=pal[3*i+2]/256.0;
  RGB_TO_YIQ(&rgb,p);p++;
 }
}
byte CMAP_GetBestColor(rgb_t *rgb,byte *pal,int32 low,int32 high)
{
 int32 i,best=low;double dr,dg,db,dist,min=MAXDISTORTION;rgb_t candidate;
 for(i=low;i<=high;i++){
  candidate.r=pal[3*i]/256.0;candidate.g=pal[3*i+1]/256.0;candidate.b=pal[3*i+2]/256.0;
  dr=rgb->r-candidate.r;dg=rgb->g-candidate.g;db=rgb->b-candidate.b;
  dist=ColorDistortion(dr,dg,db);if(dist<min){min=dist;best=i;}
 }return best;
}
byte CMAP_GetBestColorFast(rgb_t *rgb,rgb_t *pal,int32 low,int32 high)
{
 int32 i,best=low;double dr,dg,db,dist,min=MAXDISTORTION;
 for(i=low;i<=high;i++,pal++){
  dr=rgb->r-pal->r;dg=rgb->g-pal->g;db=rgb->b-pal->b;
  dist=ColorDistortion(dr,dg,db);if(dist<min){min=dist;best=i;}
 }return best;
}
byte CMAP_GetBestYIQColor(yiq_t *yiq,yiq_t *pal,int32 low,int32 high)
{
 int32 i,best=low;double dy,di,dq,dist,min=MAXDISTORTION;
 for(i=low;i<=high;i++,pal++){
  dy=yiq->y-pal->y;di=yiq->i-pal->i;dq=yiq->q-pal->q;
  dist=ColorDistortion(dy,di,dq);if(dist<min){min=dist;best=i;}
 }return best;
}
byte CMAP_BestColor(double r,double g,double b,byte *pal,int32 low,int32 high)
{
 rgb_t rgb;rgb.r=r;rgb.g=g;rgb.b=b;return CMAP_GetBestColor(&rgb,pal,low,high);
}
void CMAP_CreateFloatPalette(rgb_t **out,byte *pal)
{
 int32 i;*out=SafeMalloc(256*sizeof(rgb_t));
 for(i=0;i<256;i++){(*out)[i].r=pal[3*i]/256.0;(*out)[i].g=pal[3*i+1]/256.0;(*out)[i].b=pal[3*i+2]/256.0;}
}
int32 CMAP_CalculateTranslucentMap(byte *map,byte *pal,byte weight,byte start,byte stop,byte low,byte high)
{
 rgb_t *colors,rgb;double w=weight/256.0,other=1.0-w;byte *begin=map;int32 i,j;
 CMAP_CreateFloatPalette(&colors,pal);
 for(i=start;i<=stop;i++)for(j=0;j<256;j++){
  rgb.r=other*colors[j].r+w*colors[i].r;rgb.g=other*colors[j].g+w*colors[i].g;rgb.b=other*colors[j].b+w*colors[i].b;
  *map++=CMAP_GetBestColorFast(&rgb,colors+low,low,high);
 }SafeFree(colors);return map-begin;
}
void CMAP_CalculateColorMap(byte *map,byte *pal,byte levels,rgb_t *dest,byte weight,byte start,byte stop,byte low,byte high,boolean reverse)
{
 rgb_t *colors,rgb;int32 step,level,k,i;CMAP_CreateFloatPalette(&colors,pal);
 if(reverse==true){level=levels;step=-1;}else{level=1;step=1;}
 for(k=0;k<levels;k++,level+=step)for(i=start;i<=stop;i++){
  rgb.r=colors[i].r+(dest->r-colors[i].r)*weight/255.0*(levels-level)/(levels-1);
  rgb.g=colors[i].g+(dest->g-colors[i].g)*weight/255.0*(levels-level)/(levels-1);
  rgb.b=colors[i].b+(dest->b-colors[i].b)*weight/255.0*(levels-level)/(levels-1);
  *map++=CMAP_GetBestColorFast(&rgb,colors+low,low,high);
 } /* Actual native allocation is not freed here. */
}
void CMAP_CalculateLightMap(byte *map,byte *pal,byte levels,byte first,byte last,byte start,byte stop,byte low,byte high)
{
 rgb_t *colors,rgb;xyz_t xyz;luv_t luv;double percent=first,step=(last-(double)first)/(levels-1);int32 k,i;
 CMAP_CreateFloatPalette(&colors,pal);
 for(k=0;k<levels;k++,percent+=step)for(i=start;i<=stop;i++){
  RGB_TO_XYZ(colors+i,&xyz);XYZ_TO_LUV(&xyz,&luv);luv.l=luv.l*percent*.01;
  if(luv.l>100.0)luv.l=100.0;LUV_TO_XYZ(&luv,&xyz);XYZ_TO_RGB(&xyz,&rgb);
  *map++=CMAP_GetBestColorFast(&rgb,colors+low,low,high);
 } /* Actual native allocation is not freed here either. */
}
void CMAP_BuildColorMap(byte **out,byte *pal,byte levels,byte numdark,byte dark,byte light,rgb_t *lowrgb,rgb_t *highrgb,byte start,byte stop,byte low,byte high,boolean reverse)
{
 *out=SafeMalloc(levels*(stop-start+1));
 /* The native body ignores numdark and both rgb pointers, despite the API. */
 if(reverse==true)CMAP_CalculateLightMap(*out,pal,levels,dark,light,start,stop,low,high);
 else CMAP_CalculateLightMap(*out,pal,levels,light,dark,start,stop,low,high);
}
void CMAP_BuildMonochromeMap(byte **out,byte *pal,byte red,byte green,byte blue,byte start,byte stop,byte low,byte high)
{
 int32 i;double y;rgb_t rgb;*out=SafeMalloc(stop-start+1);
 for(i=start;i<=stop;i++){
  y=.299*(pal[3*i]/256.0)+.587*(pal[3*i+1]/256.0)+.114*(pal[3*i+2]/256.0);
  rgb.r=y*red;rgb.g=y*green;rgb.b=y*blue;
  (*out)[i-start]=CMAP_GetBestColor(&rgb,pal,low,high);
 }
}
byte CMAP_GetIntensity(byte base,byte color,byte *pal,int32 levels)
{
 int32 i,best=0;double dr,dg,db,dist,min=MAXDISTORTION;
 for(i=0;i<levels;i++){
  dr=pal[3*base]*(double)(levels-i)/(levels-1)-pal[3*color];
  dg=pal[3*base+1]*(double)(levels-i)/(levels-1)-pal[3*color+1];
  db=pal[3*base+2]*(double)(levels-i)/(levels-1)-pal[3*color+2];
  dist=ColorDistortion(dr,dg,db);if(dist<min){min=dist;best=i;}
 }return best;
}
void CMAP_FindEGAColors(char *pal)
{
 int32 i;for(i=0;i<16;i++)egacolor[i]=CMAP_BestColor(egargb[i][0]/256.0,egargb[i][1]/256.0,egargb[i][2]/256.0,(byte*)pal,0,255);
}
