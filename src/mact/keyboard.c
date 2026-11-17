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

/* Private authored reconstruction of the 1996 MACT keyboard module.
 * Not the original MACT implementation. Interface/types: released Duke3D
 * KEYBOARD.H and MACT/TYPES.H, unchanged copies alongside this source.
 * ASCII character maps derive from Apogee ROTT ISR.C ASCIINames/ShiftNames;
 * archive45eafa693c3085c56b6ccd072f5a1fb5ba1986877a21e4506d4741b1bdd44729,
 * file rott/rott/ISR.C. Original notice is preserved above.
 * Native KEYBOARD behavior supplies queue policy, private-state roles, key
 * label spellings/case and the keypad decimal/slash/enter map differences.
 * Additional NULs belong to each real label literal and make the measured
 * zero alignment bytes explicit; original spelling is unknown.
 * Shared-state volatile qualification is inferred, not historical spelling.
 * No instruction array, packed target initializer or padding object is used.
 */
#include <stdio.h>
#include <string.h>
#include "TYPES.H"
#include "KEYBOARD.H"

static char KeyboardQueue[256];
volatile byte KB_KeyDown[MAXKEYBOARDSCAN];
static volatile int Keytail;
static volatile boolean KeyPadActive;
static volatile int Keyhead;

static boolean KeyboardStarted = false;
/* ROTT's integer maps become actual byte character maps here. Native keyboard
 * maps keypad decimal to '.', and its translated keypad slash/enter to /,CR. */
static char ASCIINames[128] = {
 0,27,'1','2','3','4','5','6','7','8','9','0','-','=',8,9,
 'q','w','e','r','t','y','u','i','o','p','[',']',13,0,'a','s',
 'd','f','g','h','j','k','l',';',39,'`',0,92,'z','x','c','v',
 'b','n','m',',','.','/',0,'*',0,' ',0,0,0,0,0,0,
 0,0,0,0,0,0,0,'7','8','9','-','4','5','6','+','1',
 '2','3','0','.',0,0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,'/',13,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
};
static char ShiftNames[128] = {
 0,27,'!','@','#','$','%','^','&','*','(',')','_','+',8,9,
 'Q','W','E','R','T','Y','U','I','O','P','{','}',13,0,'A','S',
 'D','F','G','H','J','K','L',':',34,'~',0,'|','Z','X','C','V',
 'B','N','M','<','>','?',0,'*',0,' ',0,0,0,0,0,0,
 0,0,0,0,0,0,0,'7','8','9','-','4','5','6','+','1',
 '2','3','0','.',0,0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,'/',13,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
};
/* Logical label table: native spelling/case retained, unavailable codes say
 * N/A. The native table has109 entries despite the public bound110; do not
 * invent a 110th pointer or silently change that historical boundary. */
static char *ScanStrings[] = {
 "N/A", "Escape\0", "1\0\0", "2\0\0", "3\0\0", "4\0\0", "5\0\0", "6\0\0",
 "7\0\0", "8\0\0", "9\0\0", "0\0\0", "-\0\0", "=\0\0", "BakSpc\0", "Tab",
 "Q\0\0", "W\0\0", "E\0\0", "R\0\0", "T\0\0", "Y\0\0", "U\0\0", "I\0\0",
 "O\0\0", "P\0\0", "[\0\0", "]\0\0", "Enter\0\0", "LCtrl\0\0", "A\0\0", "S\0\0",
 "D\0\0", "F\0\0", "G\0\0", "H\0\0", "J\0\0", "K\0\0", "L\0\0", ";\0\0",
 "'\0\0", "`\0\0", "LShift\0", "\\\0\0", "Z\0\0", "X\0\0", "C\0\0", "V\0\0",
 "B\0\0", "N\0\0", "M\0\0", ",\0\0", ".\0\0", "/\0\0", "RShift\0", "Kpad*\0\0",
 "LAlt\0\0\0", "Space\0\0", "CapLck\0", "F1\0", "F2\0", "F3\0", "F4\0", "F5\0",
 "F6\0", "F7\0", "F8\0", "F9\0", "F10", "NumLck\0", "ScrLck\0", "KPad7\0\0",
 "KPad8\0\0", "Kpad9\0\0", "Kpad-\0\0", "Kpad4\0\0", "KPad5\0\0", "KPad6\0\0", "Kpad+\0\0", "Kpad1\0\0",
 "Kpad2\0\0", "Kpad3\0\0", "Kpad0\0\0", "Kpad.\0\0", "N/A", "N/A", "N/A", "F11",
 "F12", "Pause\0\0", "Up\0", "N/A", "N/A", "N/A", "Insert\0", "Delete\0",
 "N/A", "Home\0\0\0", "End", "PgUp\0\0\0", "PgDn\0\0\0", "RAlt\0\0\0", "RCtrl\0\0", "Kpad/\0\0",
 "KpdEnt\0", "PrtScn\0", "Down\0\0\0", "Left\0\0\0", "Right\0\0"
};

/* Inferred no-argument register-ABI hooks observed in the native module. */
extern void ServiceEvents(void);
extern void KEYBOARD_Startup(void);
extern void KEYBOARD_Shutdown(void);

void KB_KeyEvent(int scancode, boolean keypressed)
{
    char ch;
    if (!keypressed) {
        KB_KeyDown[scancode] = false;
        return;
    }
    KB_KeyDown[scancode] = true;
    KB_LastScan = scancode;
    if (!KB_KeypadActive() && ((scancode >= 0x47 && scancode <= 0x53) ||
                         (scancode >= 0x67 && scancode <= 0x68) ||
                         scancode == sc_Kpad_Star))
        ch = 0;
    else if (KB_KeyDown[sc_RightShift] || KB_KeyDown[sc_LeftShift])
        ch = ShiftNames[scancode];
    else
        ch = ASCIINames[scancode];
    KB_Addch(ch);
    if (!ch) KB_Addch(scancode);
}

boolean KB_KeyWaiting(void) { return Keyhead != Keytail; }

char KB_Getch(void)
{
    char ch;
    while (!KB_KeyWaiting()) ServiceEvents();
    ch = KeyboardQueue[Keyhead];
    Keyhead = (Keyhead + 1) & 255;
    return ch;
}

void KB_Addch(char ch)
{
    int next = (Keytail + 1) & 255;
    if (next != Keyhead) {
        KeyboardQueue[Keytail] = ch;
        Keytail = next;
    }
}

void KB_TurnKeypadOn(void) { KeyPadActive = true; }
void KB_TurnKeypadOff(void) { KeyPadActive = false; }
boolean KB_KeypadActive(void) { return KeyPadActive; }
void KB_FlushKeyboardQueue(void) { Keyhead = 0; Keytail = 0; }
void KB_ClearKeysDown(void)
{
    KB_LastScan = sc_None;
    memset((void *)KB_KeyDown, 0, MAXKEYBOARDSCAN);
}
char *KB_ScanCodeToString(kb_scancode scancode)
{
    if (scancode >= sc_LastScanCode) scancode = sc_None;
    return ScanStrings[scancode];
}
kb_scancode KB_StringToScanCode(char *string)
{
    kb_scancode scan;
    for (scan = 0; scan < sc_LastScanCode; scan++)
        if (!strcmpi(ScanStrings[scan],string)) return scan;
    return sc_None;
}
void KB_Startup(void)
{
    if (KeyboardStarted) return;
    KeyboardStarted = true;
    KB_TurnKeypadOff();
    KB_FlushKeyboardQueue();
    KB_ClearKeysDown();
    KEYBOARD_Startup();
    printf("KB_Startup: Keyboard Started\n");
}
void KB_Shutdown(void)
{
    if (!KeyboardStarted) return;
    KeyboardStarted = false;
    KEYBOARD_Shutdown();
    KB_FlushKeyboardQueue();
    KB_ClearKeysDown();
}
volatile kb_scancode KB_LastScan;
