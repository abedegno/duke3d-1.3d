#include "types.h"
#include "vector.h"
static int near_value(appfloat a, appfloat b) { return a-b<0.000001 && b-a<0.000001; }
int main(void)
{
    fpvector_t a={1,2,3}, b={4,5,6}, c, unit, axis={0,0,1}, x={1,0,0};
    appfloat length;
    FP_VectorAdd(&c,&a,&b); if(!near_value(c.x,5)||!near_value(c.y,7)||!near_value(c.z,9)) return 1;
    FP_VectorSub(&c,&a,&b); if(!near_value(c.x,-3)||!near_value(c.y,-3)||!near_value(c.z,-3)) return 2;
    FP_ScaleVector(&c,&a,2.0); if(!near_value(c.x,2)||!near_value(c.y,4)||!near_value(c.z,6)) return 3;
    FP_CrossProduct(&c,&a,&b); if(!near_value(c.x,-3)||!near_value(c.y,6)||!near_value(c.z,-3)) return 4;
    if(!near_value(FP_2x2Det(1,2,3,4),-2)) return 5;
    if(!near_value(FP_TripleProduct(&axis,&a,&b),-3)) return 6;
    c.x=3;c.y=4;c.z=0; if(!near_value(FP_VectorLength(&c),5)) return 7;
    FP_DecomposeVector(&c,&unit,&length);if(!near_value(length,5)||!near_value(unit.x,0.6)||!near_value(unit.y,0.8)) return 8;
    FP_NormalizeVector(&c);if(!near_value(c.x,0.6)||!near_value(c.y,0.8)||!near_value(c.z,0)) return 9;
    c=FP_RotateVAV(&x,&axis,0.0,1.0);if(!near_value(c.x,0)||!near_value(c.y,1)||!near_value(c.z,0)) return 10;
    return 0;
}
