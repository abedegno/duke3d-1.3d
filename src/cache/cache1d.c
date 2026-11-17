// This file has been modified from Ken Silverman's original release
// "Build Engine & Tools" Copyright (c) 1993-1997 Ken Silverman
// Ken Silverman's official web site: "http://www.advsys.net/ken"
// See the included license file "BUILDLIC.TXT" for license info.

#include <dos.h>
#include <stdio.h>
#include "kpragma.h"

//   This module keeps track of a standard linear cacheing system.
//   To use this module, here's all you need to do:
//
//   Step 1: Allocate a nice BIG buffer, like from 1MB-4MB and
//           Call initcache(long cachestart, long cachesize) where
//
//              cachestart = (long)(pointer to start of BIG buffer)
//              cachesize = length of BIG buffer
//
//   Step 2: Call allocache(long *bufptr, long bufsiz, char *lockptr)
//              whenever you need to allocate a buffer, where:
//
//              *bufptr = pointer to 4-byte pointer to buffer
//                 Confused?  Using this method, cache2d can remove
//                 previously allocated things from the cache safely by
//                 setting the 4-byte pointer to 0.
//              bufsiz = number of bytes to allocate
//              *lockptr = pointer to locking char which tells whether
//                 the region can be removed or not.  If *lockptr = 0 then
//                 the region is not locked else its locked.
//
//   Step 3: If you need to remove everything from the cache, or every
//           unlocked item from the cache, you can call uninitcache();
//              Call uninitcache(0) to remove all unlocked items, or
//              Call uninitcache(1) to remove everything.
//           After calling uninitcache, it is still ok to call allocache
//           without first calling initcache.

#define MAXCACHEOBJECTS 4096

long cachecount = 0;
static char zerochar = 0;
/* v1.3D references the engine's shared cache-size word. */
extern long cachesize;
static long cachestart = 0, reserved_cache_size = 0;
long cacnum = 0;
static long agecount = 0;
long cacleng[MAXCACHEOBJECTS];
char *lockptr[MAXCACHEOBJECTS];
static long *handptr[MAXCACHEOBJECTS];

initcache(long dacachestart, long dacachesize)
{
	cachestart = dacachestart;
	cachesize = dacachesize;

	cacleng[0] = cachesize;
	lockptr[0] = &zerochar;
	cacnum = 1;
}

allocache (long *newhandle, long newbytes, char *newlockptr)
{
	long i, j, z, zz, bestz, daval, bestval, besto, o1, o2, sucklen, suckz;

	newbytes = ((newbytes+15)&0xfffffff0);

	if (newbytes > cachesize)
	{
		printf("Cachesize: %ld\n",cachesize);
		printf("*Newhandle: 0x%x, Newbytes: %ld, *Newlock: %d\n",newhandle,newbytes,*newlockptr);
		printf("BUFFER TOO BIG TO FIT IN CACHE!\n"); reportandexit();
	}

	if (*newlockptr == 0)
	{
		printf("ALLOCACHE CALLED WITH LOCK OF 0!\n");
		reportandexit();
	}

		//Find best place
	bestval = 0x7fffffff; o1 = 0;
	for(z=0;z<cacnum;z++)
	{
		o2 = o1+newbytes;
		if (o2 > cachesize) break;

		i = o1; daval = 0; zz = z;
		while (i < o2)
		{
			if (*lockptr[zz] >= 200) { daval = 0x7fffffff; break; }
			if (*lockptr[zz] > 0)
				daval += divscale4((cacleng[zz]>>10)+64,200-(*lockptr[zz]));
			i += cacleng[zz]; zz++;
		}
		if (daval < bestval) { bestval = daval; besto = o1; bestz = z; }

		o1 += cacleng[z];
	}

	if (bestval == 0x7fffffff)
		{ printf("CACHE SPACE ALL LOCKED UP!\n"); reportandexit(); }

		//Suck things out
	for(sucklen=-newbytes,suckz=bestz;sucklen<0;sucklen+=cacleng[suckz++])
		if (*lockptr[suckz]) *handptr[suckz] = 0;

		//Remove all blocks except 1
	suckz -= (bestz+1); cacnum -= suckz;
	for(z=bestz;z<cacnum;z++)
	{
		handptr[z] = handptr[z+suckz];
		cacleng[z] = cacleng[z+suckz];
		lockptr[z] = lockptr[z+suckz];
	}
	handptr[bestz] = newhandle; *newhandle = cachestart+besto;
	cacleng[bestz] = newbytes;
	lockptr[bestz] = newlockptr;
	cachecount++;

	//printf("%ld %ld %ld\n",besto,newbytes,*newlockptr);

		//Add new empty block if necessary
	if (sucklen <= 0) return;

	bestz++;
	if (bestz == cacnum)
	{
		cacnum++;
		cacleng[bestz] = sucklen;
		lockptr[bestz] = &zerochar;
		return;
	}

	if (*lockptr[bestz] == 0) { cacleng[bestz] += sucklen; return; }

	cacnum++;
	for(z=cacnum-1;z>bestz;z--)
	{
		handptr[z] = handptr[z-1];
		cacleng[z] = cacleng[z-1];
		lockptr[z] = lockptr[z-1];
	}
	cacleng[bestz] = sucklen;
	lockptr[bestz] = &zerochar;
}

agecache()
{
	long cnt;
	char ch;

	if (agecount >= cacnum) agecount = cacnum-1;
	for(cnt=(cacnum>>4);cnt>=0;cnt--)
	{
		ch = (*lockptr[agecount]);
		if (((ch-2)&255) < 198)
			(*lockptr[agecount]) = ch-1;

		agecount--; if (agecount < 0) agecount = cacnum-1;
	}
}

reportandexit()
{
	long i, j;

	setvmode(0x3);
	printf("Cachesize = %ld\n",cachesize);
	printf("Cacnum = %ld\n",cacnum);
	j = 0;
	for(i=0;i<cacnum;i++)
	{
		printf("%ld- ",i);
		printf("ptr: 0x%x, ",*handptr[i]);
		printf("leng: %ld, ",cacleng[i]);
		printf("lock: %ld\n",*lockptr[i]);
		j += cacleng[i];
	}
	printf("Cache length sum = %ld\n",j);
	exit(0);
}




#include <fcntl.h>
#include <io.h>
#include <sys\types.h>
#include <sys\stat.h>

#define MAXOPENFILES 64     //Warning: Fix filehandle if this is changed

static long numfiles, groupfil = -1, groupfilpos;
static char *filelist;
static long *fileoffs;

static long filehandle[MAXOPENFILES] =
{
	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
};
static long filepos[MAXOPENFILES];

initgroupfile(char *filename)
{
	char buf[16];
	long i, j, k;

	uninitgroupfile();

	groupfil = open(filename,O_BINARY|O_RDWR,S_IREAD);
	if (groupfil != -1)
	{
		groupfilpos = 0;
		read(groupfil,buf,16);
		if ((buf[0] != 'K') || (buf[1] != 'e') || (buf[2] != 'n') ||
			 (buf[3] != 'S') || (buf[4] != 'i') || (buf[5] != 'l') ||
			 (buf[6] != 'v') || (buf[7] != 'e') || (buf[8] != 'r') ||
			 (buf[9] != 'm') || (buf[10] != 'a') || (buf[11] != 'n'))
		{
			close(groupfil);
			groupfil = -1;
			return(-1);
		}
		numfiles = ((long)buf[12])+(((long)buf[13])<<8)+(((long)buf[14])<<16)+(((long)buf[15])<<24);

		if ((filelist = (char *)kmalloc(numfiles<<4)) == 0)
			{ printf("Not enough memory for file grouping system\n"); exit(0); }
		if ((fileoffs = (long *)kmalloc((numfiles+1)<<2)) == 0)
			{ printf("Not enough memory for file grouping system\n"); exit(0); }

		read(groupfil,filelist,numfiles<<4);

		j = 0;
		for(i=0;i<numfiles;i++)
		{
			k = ((long)filelist[(i<<4)+12])+(((long)filelist[(i<<4)+13])<<8)+(((long)filelist[(i<<4)+14])<<16)+(((long)filelist[(i<<4)+15])<<24);
			filelist[(i<<4)+12] = 0;
			fileoffs[i] = j;
			j += k;
		}
		fileoffs[numfiles] = j;
	}
	return(groupfil);
}

uninitgroupfile()
{
	if (groupfil != -1)
	{
		kfree(filelist); kfree(fileoffs);
		close(groupfil);
		groupfil = -1;
	}
}

kopen4load(char *filename, char searchfirst)
{
	long i, j, fil, newhandle;
	char ch1, ch2, bad;

	newhandle = MAXOPENFILES-1;
	while (filehandle[newhandle] != -1)
	{
		newhandle--;
		if (newhandle < 0)
		{
			printf("TOO MANY FILES OPEN IN FILE GROUPING SYSTEM!");
			exit(0);
		}
	}

	if (searchfirst == 0)
		if ((fil = open(filename,O_BINARY|O_RDONLY)) != -1)
		{
			filehandle[newhandle] = fil;
			filepos[newhandle] = -1;
			return(newhandle);
		}
	if (groupfil != -1)
	{
		for(i=numfiles-1;i>=0;i--)
		{
			j = 0; bad = 0;
			while ((filename[j] != 0) && (j < 13))
			{
				ch1 = filename[j]; if ((ch1 >= 97) && (ch1 <= 123)) ch1 -= 32;
				ch2 = filelist[(i<<4)+j]; if ((ch2 >= 97) && (ch2 <= 123)) ch2 -= 32;
				if (ch1 != ch2) { bad = 1; break; }
				j++;
			}
			if (bad != 0) continue;

			filepos[newhandle] = 0;
			filehandle[newhandle] = i;
			return(newhandle);
		}
	}
	return(-1);
}

kread(long handle, void *buffer, long leng)
{
	long i, filenum;

	filenum = filehandle[handle];
	if (filepos[handle] < 0) return(read(filenum,buffer,leng));

	if (groupfil != -1)
	{
		i = fileoffs[filenum]+filepos[handle];
		if (i != groupfilpos)
		{
			lseek(groupfil,i+((numfiles+1)<<4),SEEK_SET);
			groupfilpos = i;
		}
		leng = min(leng,(fileoffs[filenum+1]-fileoffs[filenum])-filepos[handle]);
		leng = read(groupfil,buffer,leng);
		filepos[handle] += leng;
		groupfilpos += leng;
		return(leng);
	}

	return(0);
}

klseek(long handle, long offset, long whence)
{
	long i;

	if (filepos[handle] < 0) return(lseek(filehandle[handle],offset,whence));
	if (groupfil != -1)
	{
		switch(whence)
		{
			case SEEK_SET: filepos[handle] = offset; break;
			case SEEK_END: i = filehandle[handle];
								filepos[handle] = (fileoffs[i+1]-fileoffs[i])+offset;
								break;
			case SEEK_CUR: filepos[handle] += offset; break;
		}
		return(filepos[handle]);
	}
	return(-1);
}

kfilelength(long handle)
{
	long i;

	if (filepos[handle] < 0) return(filelength(filehandle[handle]));
	i = filehandle[handle];
	return(fileoffs[i+1]-fileoffs[i]);
}

kclose(long handle)
{
	if (handle < 0) return;
	if (filepos[handle] < 0) close(filehandle[handle]);
	filehandle[handle] = -1;
}




	//Internal LZW variables
#define LZWSIZE 16384           //Watch out for shorts!
static char *lzwbuf1, *lzwbuf4, *lzwbuf5, lzwbuflock[5];
static short *lzwbuf2, *lzwbuf3;

kdfread(void *buffer, size_t dasizeof, size_t count, long fil)
{
	long i, j, k, kgoal;
	short leng;
	char *ptr;

	lzwbuflock[0] = lzwbuflock[1] = lzwbuflock[2] = lzwbuflock[3] = lzwbuflock[4] = 200;
	if (lzwbuf1 == NULL) allocache((long *)&lzwbuf1,LZWSIZE+(LZWSIZE>>4),&lzwbuflock[0]);
	if (lzwbuf2 == NULL) allocache((long *)&lzwbuf2,(LZWSIZE+(LZWSIZE>>4))*2,&lzwbuflock[1]);
	if (lzwbuf3 == NULL) allocache((long *)&lzwbuf3,(LZWSIZE+(LZWSIZE>>4))*2,&lzwbuflock[2]);
	if (lzwbuf4 == NULL) allocache((long *)&lzwbuf4,LZWSIZE,&lzwbuflock[3]);
	if (lzwbuf5 == NULL) allocache((long *)&lzwbuf5,LZWSIZE+(LZWSIZE>>4),&lzwbuflock[4]);

	if (dasizeof > LZWSIZE) { count *= dasizeof; dasizeof = 1; }
	ptr = (char *)buffer;

	kread(fil,&leng,2); kread(fil,lzwbuf5,(long)leng);
	k = 0; kgoal = uncompress(lzwbuf5,(long)leng,lzwbuf4);

	copybufbyte(lzwbuf4,ptr,(long)dasizeof);
	k += (long)dasizeof;

	for(i=1;i<count;i++)
	{
		if (k >= kgoal)
		{
			kread(fil,&leng,2); kread(fil,lzwbuf5,(long)leng);
			k = 0; kgoal = uncompress(lzwbuf5,(long)leng,lzwbuf4);
		}
		for(j=0;j<dasizeof;j++) ptr[j+dasizeof] = ((ptr[j]+lzwbuf4[j+k])&255);
		k += dasizeof;
		ptr += dasizeof;
	}
	lzwbuflock[0] = lzwbuflock[1] = lzwbuflock[2] = lzwbuflock[3] = lzwbuflock[4] = 1;
}

dfread(void *buffer, size_t dasizeof, size_t count, FILE *fil)
{
	long i, j, k, kgoal;
	short leng;
	char *ptr;

	lzwbuflock[0] = lzwbuflock[1] = lzwbuflock[2] = lzwbuflock[3] = lzwbuflock[4] = 200;
	if (lzwbuf1 == NULL) allocache((long *)&lzwbuf1,LZWSIZE+(LZWSIZE>>4),&lzwbuflock[0]);
	if (lzwbuf2 == NULL) allocache((long *)&lzwbuf2,(LZWSIZE+(LZWSIZE>>4))*2,&lzwbuflock[1]);
	if (lzwbuf3 == NULL) allocache((long *)&lzwbuf3,(LZWSIZE+(LZWSIZE>>4))*2,&lzwbuflock[2]);
	if (lzwbuf4 == NULL) allocache((long *)&lzwbuf4,LZWSIZE,&lzwbuflock[3]);
	if (lzwbuf5 == NULL) allocache((long *)&lzwbuf5,LZWSIZE+(LZWSIZE>>4),&lzwbuflock[4]);

	if (dasizeof > LZWSIZE) { count *= dasizeof; dasizeof = 1; }
	ptr = (char *)buffer;

	fread(&leng,2,1,fil); fread(lzwbuf5,(long)leng,1,fil);
	k = 0; kgoal = uncompress(lzwbuf5,(long)leng,lzwbuf4);

	copybufbyte(lzwbuf4,ptr,(long)dasizeof);
	k += (long)dasizeof;

	for(i=1;i<count;i++)
	{
		if (k >= kgoal)
		{
			fread(&leng,2,1,fil); fread(lzwbuf5,(long)leng,1,fil);
			k = 0; kgoal = uncompress(lzwbuf5,(long)leng,lzwbuf4);
		}
		for(j=0;j<dasizeof;j++) ptr[j+dasizeof] = ((ptr[j]+lzwbuf4[j+k])&255);
		k += dasizeof;
		ptr += dasizeof;
	}
	lzwbuflock[0] = lzwbuflock[1] = lzwbuflock[2] = lzwbuflock[3] = lzwbuflock[4] = 1;
}

dfwrite(void *buffer, size_t dasizeof, size_t count, FILE *fil)
{
	long i, j, k;
	short leng;
	char *ptr;

	lzwbuflock[0] = lzwbuflock[1] = lzwbuflock[2] = lzwbuflock[3] = lzwbuflock[4] = 200;
	if (lzwbuf1 == NULL) allocache((long *)&lzwbuf1,LZWSIZE+(LZWSIZE>>4),&lzwbuflock);
	if (lzwbuf2 == NULL) allocache((long *)&lzwbuf2,(LZWSIZE+(LZWSIZE>>4))*2,&lzwbuflock);
	if (lzwbuf3 == NULL) allocache((long *)&lzwbuf3,(LZWSIZE+(LZWSIZE>>4))*2,&lzwbuflock);
	if (lzwbuf4 == NULL) allocache((long *)&lzwbuf4,LZWSIZE,&lzwbuflock);
	if (lzwbuf5 == NULL) allocache((long *)&lzwbuf5,LZWSIZE+(LZWSIZE>>4),&lzwbuflock);

	if (dasizeof > LZWSIZE) { count *= dasizeof; dasizeof = 1; }
	ptr = (char *)buffer;

	copybufbyte(ptr,lzwbuf4,(long)dasizeof);
	k = dasizeof;

	if (k > LZWSIZE-dasizeof)
	{
		leng = (short)compress(lzwbuf4,k,lzwbuf5); k = 0;
		fwrite(&leng,2,1,fil); fwrite(lzwbuf5,(long)leng,1,fil);
	}

	for(i=1;i<count;i++)
	{
		for(j=0;j<dasizeof;j++) lzwbuf4[j+k] = ((ptr[j+dasizeof]-ptr[j])&255);
		k += dasizeof;
		if (k > LZWSIZE-dasizeof)
		{
			leng = (short)compress(lzwbuf4,k,lzwbuf5); k = 0;
			fwrite(&leng,2,1,fil); fwrite(lzwbuf5,(long)leng,1,fil);
		}
		ptr += dasizeof;
	}
	if (k > 0)
	{
		leng = (short)compress(lzwbuf4,k,lzwbuf5);
		fwrite(&leng,2,1,fil); fwrite(lzwbuf5,(long)leng,1,fil);
	}
	lzwbuflock[0] = lzwbuflock[1] = lzwbuflock[2] = lzwbuflock[3] = lzwbuflock[4] = 1;
}

compress(char *lzwinbuf, long uncompleng, char *lzwoutbuf)
{
	long i, addr, newaddr, addrcnt, zx, *longptr;
	long bytecnt1, bytecnt2, numbits, oneupnumbits;
	short *shortptr;
	char bitcnt;

	for(i=255;i>=0;i--) { lzwbuf1[i] = i; lzwbuf3[i] = (i+1)&255; }
	clearbuf(lzwbuf2,256>>1,0xffffffff);
	clearbuf(lzwoutbuf,((uncompleng+15)+3)>>2,0L);

	addrcnt = 256; bytecnt1 = 0; bytecnt2 = 4; bitcnt = 0;
	numbits = 9; oneupnumbits = (1<<9);
	do
	{
		addr = lzwinbuf[bytecnt1];
		do
		{
			bytecnt1++;
			if (bytecnt1 == uncompleng) break;
			if (lzwbuf2[addr] < 0) {lzwbuf2[addr] = addrcnt; break;}
			newaddr = lzwbuf2[addr];
			while (lzwbuf1[newaddr] != lzwinbuf[bytecnt1])
			{
				zx = lzwbuf3[newaddr];
				if (zx < 0) {lzwbuf3[newaddr] = addrcnt; break;}
				newaddr = zx;
			}
			if (lzwbuf3[newaddr] == addrcnt) break;
			addr = newaddr;
		} while (addr >= 0);
		lzwbuf1[addrcnt] = lzwinbuf[bytecnt1];
		lzwbuf2[addrcnt] = -1;
		lzwbuf3[addrcnt] = -1;

		longptr = (long *)&lzwoutbuf[bytecnt2];
		longptr[0] |= (addr<<bitcnt);
		bitcnt += numbits; bytecnt2 += (bitcnt>>3); bitcnt &= 7;

		addrcnt++;
		if (addrcnt == oneupnumbits) { numbits++; oneupnumbits <<= 1; }
	} while ((bytecnt1 < uncompleng) && (bytecnt2 < uncompleng));

	longptr = (long *)&lzwoutbuf[bytecnt2];
	longptr[0] |= (addr<<bitcnt);
	bitcnt += numbits; bytecnt2 += (bitcnt>>3); bitcnt &= 7;

	shortptr = (short *)lzwoutbuf;
	shortptr[0] = (short)uncompleng;
	if (bytecnt2 < uncompleng)
	{
		shortptr[1] = (short)addrcnt;
		return(bytecnt2);
	}
	shortptr[1] = (short)0;
	for(i=0;i<uncompleng;i++) lzwoutbuf[i+4] = lzwinbuf[i];
	return(uncompleng+4);
}

uncompress(char *lzwinbuf, long compleng, char *lzwoutbuf)
{
	long strtot, currstr, numbits, oneupnumbits;
	long i, dat, leng, inbytecnt, outbytecnt, *longptr;
	short *shortptr;
	char bitcnt;

	shortptr = (short *)lzwinbuf;
	strtot = (long)shortptr[1];
	if (strtot == 0)
	{
		copybuf(lzwinbuf+4,lzwoutbuf,((compleng-4)+3)>>2);
		return((long)shortptr[0]); //uncompleng
	}
	for(i=255;i>=0;i--) { lzwbuf2[i] = i; lzwbuf3[i] = i; }
	bitcnt = 0; currstr = 256; inbytecnt = 4; outbytecnt = 0;
	numbits = 9; oneupnumbits = (1<<9);
	do
	{
		longptr = (long *)&lzwinbuf[inbytecnt];
		dat = ((longptr[0]>>bitcnt) & (oneupnumbits-1));
		bitcnt += numbits; inbytecnt += (bitcnt>>3); bitcnt &= 7;
		lzwbuf3[currstr] = dat;

		for(leng=0;dat>=256;leng++,dat=lzwbuf3[dat])
			lzwbuf1[leng] = lzwbuf2[dat];

		lzwoutbuf[outbytecnt++] = dat;
		for(i=leng-1;i>=0;i--) lzwoutbuf[outbytecnt++] = lzwbuf1[i];

		lzwbuf2[currstr-1] = dat; lzwbuf2[currstr] = dat;
		currstr++;
		if (currstr >= oneupnumbits) { numbits++; oneupnumbits <<= 1; }
	} while (currstr < strtot);
	return((long)shortptr[0]); //uncompleng
}
