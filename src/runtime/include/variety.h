/****************************************************************************
*
*                            Open Watcom Project
*
*    Portions Copyright (c) 1983-2002 Sybase, Inc. All Rights Reserved.
*
*  ========================================================================
*
*    This file contains Original Code and/or Modifications of Original
*    Code as defined in and that are subject to the Sybase Open Watcom
*    Public License version 1.0 (the 'License'). You may not use this file
*    except in compliance with the License. BY USING THIS FILE YOU AGREE TO
*    ALL TERMS AND CONDITIONS OF THE LICENSE. A copy of the License is
*    provided with the Original Code and Modifications, and is also
*    available at www.sybase.com/developer/opensource.
*
*    The Original Code and all software distributed under the License are
*    distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
*    EXPRESS OR IMPLIED, AND SYBASE AND ALL CONTRIBUTORS HEREBY DISCLAIM
*    ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF
*    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR
*    NON-INFRINGEMENT. Please see the License for the specific language
*    governing rights and limitations under the License.
*
*  ========================================================================
*
* Description:  WHEN YOU FIGURE OUT WHAT THIS FILE DOES, PLEASE
*               DESCRIBE IT HERE!
*
****************************************************************************/


/* Modified 2026-11-15: RAND-only DOS 386 flat specialization.
 * Mapping and excluded configurations: ../README.md and source evidence.
 * _WCRTLINK: bld/hdr/watcom/_comdef.mh lines 111-115 (non-__SW_BR).
 * variety.h lines 174-245 do not override linkage for DOS.
 */
#ifndef _VARIETY_H_INCLUDED
#define _VARIETY_H_INCLUDED
#if !defined(__DOS__) || !defined(__386__) || !defined(__FLAT__) || defined(__SW_BM) || defined(__SW_BR) || defined(__PENPOINT__) || defined(__NT__) || defined(__OS2__) || defined(__NETWARE__) || defined(__WINDOWS__) || defined(__WINDOWS_386__) || defined(__GENERIC__) || defined(__QNX__) || defined(__OSI__) || defined(__MAKE_DLL_CLIB) || defined(__MAKE_DLL_MATHLIB) || defined(__MAKE_DLL_CPPLIB)
#error RAND configuration requires DOS 386 flat static runtime
#endif
#ifndef _WCRTLINK
#define _WCRTLINK
#endif
#endif
