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
/**********************************************************************
   module: IRQ.C

   author: James R. Dose
   date:   August 26, 1994

   Low level routines to set and restore IRQ's through DPMI.

   (c) Copyright 1994 James R. Dose.  All Rights Reserved.
**********************************************************************/

#include <dos.h>
#include <stdlib.h>
#include "irq.h"

#define D32RealSeg(P) ( ( ( ( unsigned long )( P ) ) >> 4 ) & 0xFFFF )
#define D32RealOff(P) ( ( ( unsigned long )( P ) ) & 0xF )

typedef struct
   {
   unsigned long  drdi;
   unsigned long  drsi;
   unsigned long  drbp;
   unsigned long  drxx;
   unsigned long  drbx;
   unsigned long  drdx;
   unsigned long  drcx;
   unsigned long  drax;

   unsigned short drflags;
   unsigned short dres;
   unsigned short drds;
   unsigned short drfs;
   unsigned short drgs;
   unsigned short drip;
   unsigned short drcs;
   unsigned short drsp;
   unsigned short drss;
   } DPMI_REGS;

/* Initialized state retains the measured two-byte residue before callback. */
#pragma data_seg("_DATA", "DATA")
#pragma pack(2)
static struct {
   DPMI_REGS registers;
   unsigned char padding[2];
} irq_registers = { { 0 }, { 0x9, 0x2f } };
#pragma pack(4)
#define rmregs irq_registers.registers
static void ( __interrupt __far *IRQ_Callback )( void ) = NULL;

static char *IRQ_RealModeCode = NULL;
#pragma data_seg()

/* One private DPMI state. Every member is an existing real field.
 * WORD-granularity tail retains the actual54-byte state; no padding member.
 * Private representation only: no released/public interface type changes. */
#pragma pack(2)
static struct {
   union REGS Regs;
   struct SREGS SegRegs;
   unsigned long IRQ_ProtectedModeOffset;
   unsigned short IRQ_ProtectedModeSelector;
   unsigned short IRQ_CallBackOffset;
   unsigned short IRQ_RealModeOffset;
   unsigned short IRQ_RealModeSegment;
   unsigned short IRQ_CallBackSegment;
} irq_state;
#pragma pack(4)

static void *D32DosMemAlloc
   (
   unsigned long size
   )

   {
   // DPMI allocate DOS memory
   irq_state.Regs.x.eax = 0x0100;

   // Number of paragraphs requested
   irq_state.Regs.x.ebx = ( size + 15 ) >> 4;

   int386( 0x31, &irq_state.Regs, &irq_state.Regs );

   if ( irq_state.Regs.x.cflag != 0 )
      {
      // Failed
      return ( ( unsigned long )0 );
      }

   return( ( void * )( ( irq_state.Regs.x.eax & 0xFFFF ) << 4  ) );
   }

// Intermediary function: DPMI calls this, making it
// easier to write in C
// handle 16-bit incoming stack

void fixebp
   (
   void
   );

#pragma aux fixebp = \
        "mov   bx,  ss" \
        "lar   ebx, ebx" \
        "bt    ebx, 22" \
        "jc    bigstk" \
        "movzx esp, sp" \
        "mov   ebp, esp" \
        "bigstk:" \
modify exact [ ebx ];

#pragma aux rmcallback parm [];

void rmcallback
   (
   unsigned short _far *stkp
   )

   {
   // "Pop" the real mode return frame so we
   // can resume where we left off
   rmregs.drip = *stkp++;
   rmregs.drcs = *stkp++;

   rmregs.drsp = FP_OFF(stkp);

   // Call protected-mode handler
   IRQ_Callback();
   }

static void _interrupt _cdecl callback_x
   (
   // regs pushed in this order by prologue

   int rgs,
   int rfs,
   int res,
   int rds,
   int rdi,
   int rsi,
   int rbp,
   int rsp,
   int rbx,
   int rdx,
   int rcx,
   int rax
   )

   {
//   unsigned short _far *stkp;
//   return;

   fixebp();
   rmcallback (MK_FP(rds, rsi));
   }

/*
static void _interrupt _cdecl callback_x
   (
   // regs pushed in this order by prologue

   int rgs,
   int rfs,
   int res,
   int rds,
   int rdi,
   int rsi,
   int rbp,
   int rsp,
   int rbx,
   int rdx,
   int rcx,
   int rax
   )

   {
   unsigned short _far *stkp;

   fixebp();
   stkp = MK_FP(rds, rsi);

   // "Pop" the real mode return frame so we
   // can resume where we left off
   rmregs.drip = *stkp++;
   rmregs.drcs = *stkp++;

   rmregs.drsp = FP_OFF(stkp);

   // Call protected-mode handler
   IRQ_Callback();
   }
*/


int IRQ_SetVector
   (
   int vector,
   void ( __interrupt __far *function )( void )
   )

   {
   void far *fp;

   IRQ_Callback = function;

   // Save the starting real-mode and protected-mode handler addresses

   // DPMI get protected mode vector */
   irq_state.Regs.w.ax = 0x0204;
   irq_state.Regs.w.bx = vector;
   int386( 0x31, &irq_state.Regs, &irq_state.Regs );
   irq_state.IRQ_ProtectedModeSelector = irq_state.Regs.w.cx;
   irq_state.IRQ_ProtectedModeOffset = irq_state.Regs.x.edx;

   // DPMI get real mode vector
   irq_state.Regs.w.ax = 0x0200;
   irq_state.Regs.w.bx = vector;
   int386( 0x31, &irq_state.Regs, &irq_state.Regs );
   irq_state.IRQ_RealModeSegment = irq_state.Regs.w.cx;
   irq_state.IRQ_RealModeOffset = irq_state.Regs.w.dx;

   // Set up callback
   // DPMI allocate real mode callback
   irq_state.Regs.w.ax = 0x0303;
   fp = ( void far * )callback_x;
   irq_state.SegRegs.ds   = FP_SEG( fp );
   irq_state.Regs.x.esi = FP_OFF( fp );
   fp      = ( void _far * )&rmregs;
   irq_state.SegRegs.es   = FP_SEG( fp );
   irq_state.Regs.x.edi = FP_OFF( fp );
   int386x( 0x31, &irq_state.Regs, &irq_state.Regs, &irq_state.SegRegs );

   irq_state.IRQ_CallBackSegment = irq_state.Regs.w.cx;
   irq_state.IRQ_CallBackOffset = irq_state.Regs.w.dx;

   if ( irq_state.Regs.x.cflag != 0 )
      {
      return( IRQ_Error );
      }

   if ( IRQ_RealModeCode == NULL )
      {
      // Allocate 6 bytes of low memory for real mode interrupt handler
      IRQ_RealModeCode = D32DosMemAlloc( 6 );
      if ( IRQ_RealModeCode == NULL )
         {
         // Free callback
         irq_state.Regs.w.ax = 0x304;
         irq_state.Regs.w.cx = irq_state.IRQ_CallBackSegment;
         irq_state.Regs.w.dx = irq_state.IRQ_CallBackOffset;
         int386x( 0x31, &irq_state.Regs, &irq_state.Regs, &irq_state.SegRegs );

         return( IRQ_Error );
         }
      }

   // Poke code (to call callback) into real mode handler

   // CALL FAR PTR (callback)
   IRQ_RealModeCode[ 0 ] = '\x9A';
   {
   unsigned short callback_offset;
   callback_offset = irq_state.IRQ_CallBackOffset;
   // Native construction reads the offset before writing IRET, then writes
   // the two real WORD operands. Keep that observed memory behavior explicit.
   IRQ_RealModeCode[ 5 ] = '\xCF';
   *( ( unsigned short * )&IRQ_RealModeCode[ 1 ] ) = callback_offset;
   }
   *( ( unsigned short * )&IRQ_RealModeCode[ 3 ] ) = irq_state.IRQ_CallBackSegment;

   // Install protected mode handler
   // DPMI set protected mode vector
   irq_state.Regs.w.ax = 0x0205;
   irq_state.Regs.w.bx = vector;
   fp = function;

   irq_state.Regs.w.cx  = FP_SEG( fp );
   irq_state.Regs.x.edx = FP_OFF( fp );
   int386( 0x31, &irq_state.Regs, &irq_state.Regs );

   // Install callback address as real mode handler
   // DPMI set real mode vector
   irq_state.Regs.w.ax = 0x0201;
   irq_state.Regs.w.bx = vector;
   irq_state.Regs.w.cx = D32RealSeg( IRQ_RealModeCode );
   irq_state.Regs.w.dx = D32RealOff( IRQ_RealModeCode );
   int386( 0x31, &irq_state.Regs, &irq_state.Regs );

   return( IRQ_Ok );
   }

int IRQ_RestoreVector
   (
   int vector
   )

   {
   // Restore original interrupt handlers
   // DPMI set real mode vector
   irq_state.Regs.w.ax = 0x0201;
   irq_state.Regs.w.bx = vector;
   irq_state.Regs.w.cx = irq_state.IRQ_RealModeSegment;
   irq_state.Regs.w.dx = irq_state.IRQ_RealModeOffset;
   int386( 0x31, &irq_state.Regs, &irq_state.Regs );

   irq_state.Regs.w.ax = 0x0205;
   irq_state.Regs.w.bx = vector;
   irq_state.Regs.w.cx = irq_state.IRQ_ProtectedModeSelector;
   irq_state.Regs.x.edx = irq_state.IRQ_ProtectedModeOffset;
   int386( 0x31, &irq_state.Regs, &irq_state.Regs );

   // Free callback
   irq_state.Regs.w.ax = 0x304;
   irq_state.Regs.w.cx = irq_state.IRQ_CallBackSegment;
   irq_state.Regs.w.dx = irq_state.IRQ_CallBackOffset;
   int386x( 0x31, &irq_state.Regs, &irq_state.Regs, &irq_state.SegRegs );

   if ( irq_state.Regs.x.cflag )
      {
      return( IRQ_Error );
      }

   return( IRQ_Ok );
   }
