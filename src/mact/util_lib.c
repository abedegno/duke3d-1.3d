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

/* MACT utilities reconstruction, not historical source identity.
 * Numeric/endian/heapsort bodies derive from this preserved ROTT source.
 * Extra NULs after four messages express eight measured CONST alignment
 * bytes; original source spelling/intent is not established.
 * Other functions reconstructed from original native roles, 2026-11-15.
 * JFMACT creative interpolation is role reference only, not source identity. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <malloc.h>
extern int _argc;
extern char **_argv;
typedef unsigned char byte;
static void (*ShutDown)(void) = NULL;
void RegisterShutdownFunction(void (*sh)(void)) { ShutDown=sh; }
void Error(char *error, ...)
{
    va_list va;
    static int inerror = 0;
    if (inerror) return;
    inerror=1;
    if (ShutDown) ShutDown();
    va_start(va,error);
    vprintf(error,va);
    va_end(va);
    printf("\n\0\0");
    exit(1);
}
char CheckParm(char *check)
{
    char c;
    char buffer[128];
    char delimiters[]="\\-/";
    char *p;
    for(c=1;c<_argc;c++) {
        strcpy(buffer,_argv[c]);
        p=strtok(buffer,delimiters);
        if(p && !stricmp(check,p)) return c;
    }
    return 0;
}
long ParseHex (char *hex)
{
	char	*str;
	long	num;

	num = 0;
	str = hex;

	while (*str)
	{
		num <<= 4;
		if (*str >= '0' && *str <= '9')
			num += *str-'0';
		else if (*str >= 'a' && *str <= 'f')
			num += 10 + *str-'a';
		else if (*str >= 'A' && *str <= 'F')
			num += 10 + *str-'A';
		else
			Error ("Bad hex number: %s\0",hex);
		str++;
	}

	return num;
}


long ParseNum (char *str)
{
	if (str[0] == '$')
		return ParseHex (str+1);
	if (str[0] == '0' && str[1] == 'x')
		return ParseHex (str+2);
	return atol (str);
}




short	MotoShort (short l)
{
	byte	b1,b2;

	b1 = l&255;
	b2 = (l>>8)&255;

	return (b1<<8) + b2;
}

short	IntelShort (short l)
{
	return l;
}


long	MotoLong (long l)
{
	byte	b1,b2,b3,b4;

	b1 = l&255;
	b2 = (l>>8)&255;
	b3 = (l>>16)&255;
	b4 = (l>>24)&255;

	return ((long)b1<<24) + ((long)b2<<16) + ((long)b3<<8) + b4;
}

long	IntelLong (long l)
{
	return l;
}


typedef int (*PFI)();           /* pointer to a function returning int  */
typedef void (*PFV)();           /* pointer to a function returning int  */
static PFI Comp;                        /* pointer to comparison routine                */
static PFV Switch;                        /* pointer to comparison routine                */
static int Width;                       /* width of an object in bytes                  */
static char *Base;                      /* pointer to element [-1] of array             */

void HeapSort(char * base, int nel, int width, int (*compare)(), void (*switcher)())
{
static int i,n,stop;
        /*      Perform a heap sort on an array starting at base.  The array is
                nel elements large and width is the size of a single element in
                bytes.  Compare is a pointer to a comparison routine which will
                be passed pointers to two elements of the array.  It should
                return a negative number if the left-most argument is less than
                the rightmost, 0 if the two arguments are equal, a positive
                number if the left argument is greater than the right.  (That
                is, it acts like a "subtract" operator.) If compare is 0 then
                the default comparison routine, argvcmp (which sorts an
                argv-like array of pointers to strings), is used.                                       */

   Width=width;
   Comp= compare;
   Switch= switcher;
   n=nel*Width;
   Base=base-Width;
   for (i=(n/Width/2)*Width; i>=Width; i-=Width) newsift_down(i,n);
   stop=Width+Width;
   for (i=n; i>=stop; )
      {
      (*Switch)(base, Base+i);
      newsift_down(Width,i-=Width);
      }

}

/*---------------------------------------------------------------------------*/
static newsift_down(L,U) int L,U;
{  int c;

   while(1)
      {c=L+L;
      if(c>U) break;
      if( (c+Width <= U) && ((*Comp)(Base+c+Width,Base+c)>0) ) c+= Width;
      if ((*Comp)(Base+L,Base+c)>=0) break;
      (*Switch)(Base+L, Base+c);
      L=c;
      }
}




void *SafeMalloc(unsigned long size)
{
    void *p;
    p=malloc(size);
    if (!p) Error("SafeMalloc failure for %lu bytes\0\0\0",size);
    return p;
}
unsigned long SafeMallocSize(void *ptr) { return _msize(ptr); }
void SafeRealloc(void **ptr,long size)
{
    *ptr=realloc(*ptr,size);
    if(!*ptr) Error("SafeRealloc failure for %ld bytes\0\0",size);
}
void SafeFree(void *ptr)
{
    if(!ptr) Error("SafeFree : Tried to free a freed pointer\n");
    free(ptr);
}
