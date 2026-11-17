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
/* Source-contribution recovery from the related official ROTT RNG, not
 * original MACT source identity. The primary table header is unchanged.
 * MACT export names, byte return width and the DOS-time seed are recovered
 * from the original member. Unsigned return signedness is inferred from the
 * primary unsigned table; no historical caller prototype is claimed.
 * Native contribution: 227 CODE, 2052 DATA, 4 BSS, 13 fixups. Produced BSS
 * alignment is DWORD, original PARA; both fit the proved preceding boundary.
 * See evidence/mact-random-source-reference.json for lineage and limitations.
 */
#include <dos.h>
#include "_rt_rand.h"
static int rndindex;
static int sndindex=0;
int GetRandomNumberSeed(void)
{
    struct dostime_t clock;
    _dos_gettime(&clock);
    return((clock.minute * clock.second * clock.hsecond) % SIZE_OF_RANDOM_TABLE);
}
void InitializeRandomNumberGenerator(void)
{
    rndindex=GetRandomNumberSeed();
    sndindex=GetRandomNumberSeed();
}
void SetRandomNumberIndex(int i) { rndindex=i; }
int GetRandomNumberIndex(void) { return rndindex; }
unsigned char GameRandom(void)
{
    rndindex=(rndindex+1)&(SIZE_OF_RANDOM_TABLE-1);
    return RandomTable[rndindex];
}
unsigned char Random(void)
{
    sndindex=(sndindex+1)&(SIZE_OF_RANDOM_TABLE-1);
    return RandomTable[sndindex];
}
