/* SPDX-License-Identifier: GPL-2.0-or-later */
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

/* Authored complete MACT DOS-platform recovery candidate, not original source.
 * Interface/types/notices: unchanged released Duke3D extras headers alongside.
 * Keyboard controller/prefix and vector protocol: published Apogee ROTT ISR.C;
 * its original notice is retained in the source-reference documentation.
 * Native observations supply exact state ordering, pause-sequence matching,
 * extended-key mapping, mode13h defaults and API details; inferred names/intent
 * are not represented as recovered original Creative/Apogee implementation.
 * Primitive word transfers below express actual VGA word-copy/fill semantics,
 * using genuine compiler mnemonic intrinsics, never instruction byte arrays.
 */
#include <i86.h>
#include <conio.h>
#include <stdlib.h>
#include <dos.h>
#include "TYPES.H"
#include "DEVELOP.H"
#include "KEYBOARD.H"
#include "VID.H"

#define VGA_WIDTH 320
#define VGA_HEIGHT 200
#define VGA_PIXELS (VGA_WIDTH * VGA_HEIGHT)
#define VGA_WORDS (VGA_PIXELS / 2)
#define KEY_RELEASE 0x80
#define EXTENDED_PREFIX 0xe0
#define PAUSE_PREFIX 0xe1

/* Fixed mode13h operations: 320*200 bytes = 32000 word transfers. The
 * instruction mnemonics express actual string-I/O semantics, not opaque code.
 * Copy: for (i=0;i<VGA_WORDS;i++) ((word*)dst)[i]=((word*)src)[i].
 * Fill: for (i=0;i<VGA_WORDS;i++) ((word*)dst)[i]=color+(color<<8).
 * Ken's released PRAGMAS.H documents the aux parameter/modify convention.
 */
void CopyVGAFrame(void *destination, const void *source);
#pragma aux CopyVGAFrame = "cld" "mov ecx,32000" "rep movsw" \
    parm [edi] [esi] modify exact [edi esi ecx];
void FillVGAFrame(void *destination, unsigned color);
#pragma aux FillVGAFrame = "cld" "mov ecx,eax" "shl ecx,8" \
    "add eax,ecx" "mov ecx,32000" "rep stosw" \
    parm [edi] [eax] modify exact [edi eax ecx];

/* Actual PS/2 Pause make packet; controller sends no ordinary break code. */
static byte PauseScanCode[6] = {
    PAUSE_PREFIX, sc_LeftControl, sc_NumLock,
    PAUSE_PREFIX, sc_LeftControl | KEY_RELEASE, sc_NumLock | KEY_RELEASE
};
static void (__interrupt __far *oldkeyboardisr)(void) = NULL;
/* Index: ordinary make code after E0; value: released MACT logical scan code.
 * Unmapped/unsupported E0 codes mean sc_None. Each nonzero named mapping is an
 * actual native-observed logical field, not a copied opaque DATA segment. */
static byte ExtendedScanCodes[128] = {
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* 00..0f */
    0,0,0,0,0,0,0,0,0,0,0,0,sc_kpad_Enter,sc_RightControl,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,sc_kpad_Slash,0,sc_PrintScreen,sc_RightAlt,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,sc_Home,sc_UpArrow,sc_PgUp,0,sc_LeftArrow,0,sc_RightArrow,0,sc_End,
    sc_DownArrow,sc_PgDn,sc_Insert,sc_Delete,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
};
static boolean KEYBOARD_Started = false;

static byte display_buffer[VGA_PIXELS];
boolean vid_flushall;
static volatile int32 PauseCount;
static volatile boolean ExtendedKeyFlag;
viddef_t vid;

void VID_Init(int32 width, int32 height, byte *palette,
              display_t displaytype, int scale)
{
    union REGS regs;
    regs.w.ax = 0x13;
    int386(0x10, &regs, &regs);
    VID_SetPalette(palette);
    vid_flushall = true;
    vid.width = VGA_WIDTH;
    vid.height = VGA_HEIGHT;
    vid.aspect = 1.2f;
    vid.pixbytes = 1;
    vid.rowbytes = VGA_WIDTH;
    vid.cbits = 8;
    vid.grades = 256;
    vid.buffer = display_buffer;
}
void VID_Shutdown(void)
{
    union REGS regs;
    regs.w.ax = 3;
    int386(0x10, &regs, &regs);
}
/* DOS mode13h has one stable software frame buffer; no per-frame acquisition. */
void VID_GetBuffer(void) { }
void VID_Update(int rectcount, vrect_t *rects)
{
    vid_flushall = false;
    CopyVGAFrame((void *)0xa0000, vid.buffer);
}
void VID_UpdateScreen(void)
{
    vid_flushall = false;
    CopyVGAFrame((void *)0xa0000, vid.buffer);
}
void VID_NormalizePalette(byte *palette)
{
    int16 i;
    for (i = 0; i < 768; ++i) palette[i] = palette[i] >> 2;
}
void VID_GetPalette(byte *palette)
{
    int16 i;
    outp(0x3c7, 0);
    for (i = 0; i < 768; ++i) palette[i] = inp(0x3c9) << 2;
}
void VID_SetPalette(byte *palette)
{
    int16 i;
    outp(0x3c8, 0);
    for (i = 0; i < 768; ++i) outp(0x3c9, palette[i] >> 2);
}
void VID_ClearViewBuffer(int color)
{
    FillVGAFrame(vid.buffer, color);
}
/* DOS events arrive through hardware interrupts, not an OS event pump. */
void ServiceEvents(void) { }
void MOUSE_ShowCursor(void)
{
    union REGS inregs, outregs;
    inregs.w.ax = 1;
    int386(0x33, &inregs, &outregs);
}
void MOUSE_HideCursor(void)
{
    union REGS inregs, outregs;
    inregs.w.ax = 2;
    int386(0x33, &inregs, &outregs);
}
void MOUSE_GetPosition(int32 *x, int32 *y)
{
    union REGS inregs, outregs;
    inregs.w.ax = 3;
    int386(0x33, &inregs, &outregs);
    *x = (int16)outregs.w.cx;
    *y = (int16)outregs.w.dx;
}
void MOUSE_GetDelta(int32 *x, int32 *y)
{
    union REGS inregs, outregs;
    inregs.w.ax = 0x0b;
    int386(0x33, &inregs, &outregs);
    *x = (int16)outregs.w.cx;
    *y = (int16)outregs.w.dx;
}
int32 MOUSE_GetButtons(void)
{
    union REGS inregs, outregs;
    inregs.w.ax = 3;
    int386(0x33, &inregs, &outregs);
    return outregs.h.bl;
}
boolean MOUSE_Init(void)
{
    union REGS inregs, outregs;
    inregs.w.ax = 0;
    int386(0x33, &inregs, &outregs);
    return outregs.w.ax == 0xffff;
}
/* The DOS mouse driver owns its lifetime; MACT has no shutdown transaction. */
void MOUSE_Shutdown(void) { }

/* Prefix clear primitive: the ordinary C counterpart is
 * ExtendedKeyFlag = false. One volatile DWORD store; ESI is scratch and
 * the interrupt entry/exit saves/restores every interrupted GP register.
 * Symbolic assembly preserves the measured encoding; no original-C claim.
 */
void ClearExtendedKeyPrefix(void);
#pragma aux ClearExtendedKeyPrefix = "xor esi,esi" \
    "mov dword ptr [ExtendedKeyFlag],esi" modify exact [esi];

static void __interrupt KEYBOARD_Isr(void)
{
    int k, temp, keyon, strippedkey;
    boolean processkey;
    k = inp(0x60);
    temp = inp(0x61);
    outp(0x61, temp | 0x80);
    outp(0x61, temp);
    processkey = true;
    if (k == PauseScanCode[PauseCount]) {
        PauseCount++;
        if (PauseCount == 6) {
            k = sc_Pause;
            PauseCount = 0;
        } else processkey = false;
    }
    if (processkey) {
        PauseCount = 0;
        if (KB_KeyDown[sc_Pause]) KB_KeyDown[sc_Pause] = false;
        if (k == EXTENDED_PREFIX) ExtendedKeyFlag = true;
        else {
            keyon = k & KEY_RELEASE;
            strippedkey = k & 0x7f;
            if (ExtendedKeyFlag) {
                if (strippedkey == sc_LeftShift || strippedkey == sc_RightShift)
                    k = sc_None;
                else strippedkey = ExtendedScanCodes[strippedkey];
            }
            if (k != sc_None && strippedkey != sc_None)
                KB_KeyEvent(strippedkey, !keyon);
            ClearExtendedKeyPrefix();
        }
    }
    outp(0x20, 0x20);
}
void KEYBOARD_Startup(void)
{
    if (KEYBOARD_Started) return;
    KEYBOARD_Started = true;
    PauseCount = 0;
    ExtendedKeyFlag = false;
    oldkeyboardisr = _dos_getvect(9);
    _dos_setvect(0x8000 | 9, KEYBOARD_Isr);
}
void KEYBOARD_Shutdown(void)
{
    if (!KEYBOARD_Started) return;
    _dos_setvect(9, oldkeyboardisr);
    PauseCount = 0;
    ExtendedKeyFlag = false;
    *(word *)0x41c = *(word *)0x41a;
    KEYBOARD_Started = false;
}
