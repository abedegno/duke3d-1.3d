/*
 * Copyright (C) 1996, 2003 - 3D Realms Entertainment
 * Derived from released source/GAMEDEF.C:ispecial.
 * GPL-2.0-or-later; see dukenukem3d/GNU.TXT.
 * Isolated matching unit; complete GAMEDEF.C data layout remains to recover.
 */
static short total_lines,line_number;

char ispecial(char c)
{
    if(c == 0x0a)
    {
        line_number++;
        return 1;
    }

    if(c == ' ' || c == 0x0d)
        return 1;

    return 0;
}
