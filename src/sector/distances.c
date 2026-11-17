/*
 * Copyright (C) 1996, 2003 - 3D Realms Entertainment
 * Derived from released source/SECTOR.C and BUILD.H.
 * GPL-2.0-or-later; see dukenukem3d/GNU.TXT.
 *
 * v1.3D ldist returns FindDistance2D directly. The later released source
 * adds one; the extra INC EAX does not occur in the reference executable.
 */
typedef struct
{
    long x, y, z;
    short cstat, picnum;
    signed char shade;
    char pal, clipdist, filler;
    unsigned char xrepeat, yrepeat;
    signed char xoffset, yoffset;
    short sectnum, statnum;
    short ang, owner, xvel, yvel, zvel;
    short lotag, hitag, extra;
} spritetype;

long FindDistance2D(long dx,long dy);
long FindDistance3D(long dx,long dy,long dz);

long ldist(spritetype *s1,spritetype *s2)
{
    long vx,vy;
    vx = s1->x - s2->x;
    vy = s1->y - s2->y;
    return(FindDistance2D(vx,vy));
}

long dist(spritetype *s1,spritetype *s2)
{
    long vx,vy,vz;
    vx = s1->x - s2->x;
    vy = s1->y - s2->y;
    vz = s1->z - s2->z;
    return(FindDistance3D(vx,vy,vz>>4));
}
