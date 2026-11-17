/*
 * Copyright (C) 1996, 2003 - 3D Realms Entertainment
 * Derived from released source/GAMEDEF.C:getincangle and PRAGMAS.H:klabs.
 * GPL-2.0-or-later; see dukenukem3d/GNU.TXT.
 *
 * Matching candidate: Watcom 10.0 GA, /4r /s /otexan.
 * Target: LE object 1, offset 0x239b0, length 76.
 * This local match does not uniquely identify the compiler revision.
 */

long klabs(long);
#pragma aux klabs = \
    "test eax, eax", \
    "jns skipnegate", \
    "neg eax", \
    "skipnegate:", \
    parm nomemory [eax]

short getincangle(short a,short na)
{
    a &= 2047;
    na &= 2047;

    if(klabs(a-na) < 1024)
        return (na-a);
    else
    {
        if(na > 1024) na -= 2048;
        if(a > 1024) a -= 2048;

        na -= 2048;
        a -= 2048;
        return (na-a);
    }
}
