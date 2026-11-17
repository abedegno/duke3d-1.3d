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


/* MACT file library reconstruction, not historical source identity.
 * ROTT RT_UTIL.C supplies the environment/default/base and DOS directory bodies.
 * Open/close tracking, filetype dispatch, 0x7fff I/O and extension scans are
 * reconstructed from the complete original native member; names/types inferred.
 * Explicit extra NULs after actual literals preserve measured noninstruction
 * CONST storage. Historical spelling/intent of those bytes is unresolved.
 * FileNames is real initialized local state, not BSS or padding.
 * JFMACT is a later creative interpolation, never an identity authority. */
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <ctype.h>
#include <io.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <dos.h>
#include <direct.h>
typedef unsigned char byte;
typedef int boolean;
#define true 1
#define false 0
#define SLASHES '\\'
#define MAXCHARS 8
void Error(char *error, ...);
void *SafeMalloc(long size);
void SafeFree(void *ptr);
int ChangeDrive(char *drive);
static char *FileNames[20] = {0};
int SafeOpen(const char *filename, int mode, int sharemode)
{
 int handle;
 if (mode & O_CREAT)
  handle = open(filename, mode, sharemode);
 else
  handle = open(filename, mode);
 if (handle == -1)
  Error("Error opening %s: %s\n\0\0", filename, strerror(errno));
 if (handle < 20)
 {
  if (FileNames[handle]) SafeFree(FileNames[handle]);
  FileNames[handle] = (char *)SafeMalloc(strlen(filename)+1);
  strcpy(FileNames[handle],filename);
 }
 return handle;
}

int SafeOpenWrite(const char *filename, int filetype)
{
 if (filetype == 0) return SafeOpen(filename,O_RDWR | O_CREAT | O_TRUNC | O_BINARY,S_IREAD | S_IWRITE);
 else if (filetype == 1) return SafeOpen(filename,O_RDWR | O_CREAT | O_TRUNC | O_TEXT,S_IREAD | S_IWRITE);
 else { Error("SafeOpenWrite: Illegal filetype specified\0\0"); return -1; }
}

int SafeOpenRead(const char *filename, int filetype)
{
 if (filetype == 0) return SafeOpen(filename,O_RDONLY | O_BINARY,0);
 else if (filetype == 1) return SafeOpen(filename,O_RDONLY | O_TEXT,0);
 else { Error("SafeOpenRead: Illegal filetype specified\0\0\0"); return -1; }
}

int SafeOpenAppend(const char *filename, int filetype)
{
 if (filetype == 0) return SafeOpen(filename,O_RDWR | O_CREAT | O_APPEND | O_BINARY,S_IREAD | S_IWRITE);
 else if (filetype == 1) return SafeOpen(filename,O_RDWR | O_CREAT | O_APPEND | O_TEXT,S_IREAD | S_IWRITE);
 else { Error("SafeOpenAppend: Illegal filetype specified\0"); return -1; }
}

void SafeClose(int handle)
{
 if (close(handle))
 {
  if(handle < 20) Error("Unable to close file %s\n\0\0\0", FileNames[handle]);
  else Error("Unable to close file\n\0\0");
 }
 else if(handle < 20)
 {
  SafeFree(FileNames[handle]);
  FileNames[handle] = NULL;
 }
}
boolean SafeFileExists(const char *filename)
{
 return !access(filename,0);
}
long SafeFileLength(int handle)
{
 return filelength(handle);
}

void SafeRead(int handle, void *buffer, long count)
{
 unsigned iocount;
 while(count)
 {
  iocount = count > 0x7fff ? 0x7fff : count;
  if (read(handle,buffer,iocount) != iocount)
   Error("File read failure %s reading %ld bytes from file %s",strerror(errno),count,FileNames[handle]);
  buffer = (void *)((byte *)buffer + iocount);
  count -= iocount;
 }
}

void SafeWrite(int handle, void *buffer, long count)
{
 unsigned iocount;
 while(count)
 {
  iocount = count > 0x7fff ? 0x7fff : count;
  if (write(handle,buffer,iocount) != iocount)
   Error("File write failure %s writing %ld bytes to file %s\0",strerror(errno),count,FileNames[handle]);
  buffer = (void *)((byte *)buffer + iocount);
  count -= iocount;
 }
}
long	LoadFile (char *filename, void **bufferptr)
{
	int		handle;
	long	length;

	handle = SafeOpenRead (filename,0);
	length = filelength (handle);
	*bufferptr = SafeMalloc (length);
	SafeRead (handle,*bufferptr, length);
	SafeClose (handle);
	return length;
}
void	SaveFile (char *filename, void *buffer, long count)
{
	int		handle;

	handle = SafeOpenWrite (filename,0);
	SafeWrite (handle, buffer, count);
	SafeClose (handle);
}
void GetPathFromEnvironment( char *fullname, const char *envname, const char *filename )
   {
   char *path;

   path = getenv( envname );

   if ( path != NULL )
      {
      strcpy( fullname, path );
      if ( fullname[ strlen( fullname ) ] != '\\' )
         {
         strcat( fullname, "\\\0\0" );
         }
      strcat( fullname, filename );
      }
   else
      {
      strcpy( fullname, filename );
      }
   }
void DefaultExtension (char *path, char *extension)
{
	char	*src;
//
// if path doesn't have a .EXT, append extension
// (extension should include the .)
//
	src = path + strlen(path) - 1;

	while (*src != '\\' && src != path)
	{
		if (*src == '.')
			return;			// it has an extension
		src--;
	}

	strcat (path, extension);
}
void DefaultPath (char *path, char *basepath)
{
	char	temp[128];

	if (path[0] == '\\')
		return;							// absolute path location
	strcpy (temp,path);
	strcpy (path,basepath);
	strcat (path,temp);
}
void ExtractFileBase (char *path, char *dest)
{
	char	*src;
	int		length;

	src = path + strlen(path) - 1;

//
// back up until a \ or the start
//
	while (src != path && *(src-1) != '\\')
		src--;

//
// copy up to eight characters
//
	memset (dest,0,8);
	length = 0;
	while (*src && *src != '.')
	{
		if (++length == 9)
			Error ("Filename base of %s > 8 chars\0\0",path);
		*dest++ = tolower(*src++);
	}
}

boolean GetExtension(char *filename, char *extension)
{
 char *src;
 src = filename + strlen(filename) - 1;
 while (src != filename && *(src-1) != '.') src--;
 if (src == filename) return false;
 strcpy(extension,src);
 return true;
}
void SetExtension(char *filename, const char *extension)
{
 char *src;
 src = filename + strlen(filename) - 1;
 while (src != filename && *(src-1) != '.') src--;
 src--;
 *src=0;
 strcat(src,extension);
}
char * GetPath (char * path, char *dir)
{
   boolean done      = 0;
   char *dr          = dir;
   int cnt           = 0;

   if (*path == SLASHES)
      path++;

   while (!done)
   {
      *dr = *path;

      cnt++;                  // make sure the number of characters in the dir
      if (cnt > MAXCHARS)     // name doesn't exceed acceptable limits.
         Error ("ERROR : Directory name can only be %d characters long.\n", MAXCHARS);

      path++;
      dr++;

      if ((*path == SLASHES) || (*path == NULL))
         done = true;
   }

   *dr = 0;
   return (path);
}
boolean ChangeDirectory (char *path)
{
   char *p;
   char dir[9];
   char *d;

   d = &dir[0];
   p = path;
   memset (dir, 0, 9);

   // Check for a drive at the beginning of the path
   if (*(p+1) == ':')
   {
      *d++ = *p++;      // drive letter
      *d++ = *p++;      // colon

      if (ChangeDrive (dir) == false)
         return (false);
   }

   if (*p == SLASHES)
   {
      chdir ("\\");
      p++;
   }

   d = &dir[0];
   while (*p)
   {
      p = GetPath (p, d);

      if (chdir (d) == -1)
         return (false);
   }

   return (true);
}
boolean ChangeDrive (char *drive)
{
   unsigned d, total, tempd;

   d = toupper (*drive);

   d = d - 'A' + 1;

   _dos_setdrive (d, &total);
   _dos_getdrive (&tempd);

   if (d != tempd)
      return (false);

   return (true);
}
