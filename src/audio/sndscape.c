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
   module: SNDSCAPE.C

   author: James R. Dose
   date:   October 25, 1994

   Low level routines to support the Ensoniq Soundscape.

   (c) Copyright 1994 James R. Dose.  All Rights Reserved.
**********************************************************************/

#include <dos.h>
#include <conio.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <time.h>
#include "interrup.h"
#include "dpmi.h"
#include "dma.h"
#include "irq.h"
#include "sndscape.h"
#include "_sndscap.h"

const int SOUNDSCAPE_Interrupts[ SOUNDSCAPE_MaxIrq + 1 ]  =
   {
   INVALID, INVALID,     0xa, INVALID,
   INVALID,     0xd, INVALID,     0xf,
   INVALID, INVALID,    0x72, INVALID,
   INVALID, INVALID, INVALID, INVALID
   };

const int SOUNDSCAPE_SampleSize[ SOUNDSCAPE_MaxMixMode + 1 ] =
   {
   MONO_8BIT_SAMPLE_SIZE,  STEREO_8BIT_SAMPLE_SIZE,
   MONO_16BIT_SAMPLE_SIZE, STEREO_16BIT_SAMPLE_SIZE
   };

static void ( __interrupt __far *SOUNDSCAPE_OldInt )( void );

/* Fixed default-directory value copied as one complete C object. */
struct ssc_directory_string { char text[12]; };

/* Existing named strings and measured residues in one source-owned CONST span. */
#pragma data_seg("CONST", "DATA")
static struct {
   struct {
   char ok[15];
   unsigned char padding_0[1];
   char env_missing[126];
   unsigned char padding_1[2];
   char ini_missing[180];
   char product_missing[61];
   unsigned char padding_3[3];
   char port_missing[58];
   unsigned char padding_4[2];
   char dma_missing[57];
   unsigned char padding_5[3];
   char irq_missing[57];
   unsigned char padding_6[3];
   char sbirq_missing[59];
   unsigned char padding_7[1];
   char sbenable_missing[62];
   unsigned char padding_8[2];
   char waveport_missing[62];
   unsigned char padding_9[2];
   char not_detected[120];
   char not_playing[32];
   char invalid_irq[55];
   unsigned char padding_12[1];
   char irq_failed[67];
   unsigned char padding_13[1];
   char dpmi_error[26];
   unsigned char padding_14[2];
   char memory_error[42];
   unsigned char padding_15[2];
   char unknown[31];
   unsigned char padding_16[1];
   char environment[9];
   unsigned char padding_17[3];
   } messages;
   struct ssc_directory_string default_directory;
   struct {
   char ini_path[14];
   unsigned char padding_19[2];
   char read_mode[2];
   unsigned char padding_20[2];
   char product_key[8];
   char soundfx[8];
   char port_key[5];
   unsigned char padding_23[3];
   char dma_key[4];
   char irq_key[4];
   char sbirq_key[6];
   unsigned char padding_26[2];
   char sbenable_key[9];
   unsigned char padding_27[3];
   char false_value[6];
   unsigned char padding_28[2];
   char waveport_key[9];
   } misc;
} ssc_constants = {
   {
   "SoundScape ok.",
   {0x20},
   "SNDSCAPE environment variable not set.  This is used to locate \n"
                       "SNDSCAPE.INI which is used to describe your sound card setup.",
   {0x65, 0x66},
   "Missing SNDSCAPE.INI file for SoundScape.  This file should be \n"
                       "located in the directory indicated by the SNDSCAPE environment \n"
                       "variable or in 'C:\SNDSCAPE' if SNDSCAPE is not set.",
   "Missing 'Product' field in SNDSCAPE.INI file for SoundScape.",
   {0x65, 0x20, 0xa},
   "Missing 'Port' field in SNDSCAPE.INI file for SoundScape.",
   {0x6d, 0x65},
   "Missing 'DMA' field in SNDSCAPE.INI file for SoundScape.",
   {0x69, 0x73, 0x73},
   "Missing 'IRQ' field in SNDSCAPE.INI file for SoundScape.",
   {0x70, 0x65, 0x2e},
   "Missing 'SBIRQ' field in SNDSCAPE.INI file for SoundScape.",
   {0x65},
   "Missing 'SBEnable' field in SNDSCAPE.INI file for SoundScape.",
   {0x73, 0x73},
   "Missing 'WavePort' field in SNDSCAPE.INI file for SoundScape.",
   {0x73, 0x73},
   "Could not detect SoundScape.  Make sure your SNDSCAPE.INI file \n"
                       "contains correct information about your hardware setup.",
   "No sound playing on SoundScape.",
   "Invalid SoundScape Irq in SBIRQ field of SNDSCAPE.INI.",
   {0x63},
   "Unable to set SoundScape IRQ.  Try selecting an IRQ of 7 or below.",
   {0x6e},
   "DPMI Error in SoundScape.",
   {0x2e, 0x0},
   "Out of conventional memory in SoundScape.",
   {0x75, 0x6e},
   "Unknown SoundScape error code.",
   {0x44},
   "SNDSCAPE",
   {0x2e, 0x0, 0x63}
   },
   { "C:\\SNDSCAPE" },
   {
   "\\SNDSCAPE.INI",
   {0x52, 0x51},
   "r",
   {0x20, 0x54},
   "Product",
   "SoundFX",
   "Port",
   {0x66, 0x20, 0x37},
   "DMA",
   "IRQ",
   "SBIRQ",
   {0x4d, 0x49},
   "SBEnable",
   {0x20, 0x53, 0x6f},
   "false",
   {0x70, 0x65},
   "WavePort"
   }
};
#pragma data_seg()



static int SOUNDSCAPE_Installed = FALSE;
static int SOUNDSCAPE_FoundCard = FALSE;

static char   *SOUNDSCAPE_DMABuffer;
static char   *SOUNDSCAPE_DMABufferEnd;
static char   *SOUNDSCAPE_CurrentDMABuffer;
static int     SOUNDSCAPE_TotalDMABufferSize;

static int      SOUNDSCAPE_TransferLength   = 0;
static int      SOUNDSCAPE_MixMode          = SOUNDSCAPE_DefaultMixMode;
static int      SOUNDSCAPE_SamplePacketSize = MONO_16BIT_SAMPLE_SIZE;
static unsigned SOUNDSCAPE_SampleRate       = SOUNDSCAPE_DefaultSampleRate;

volatile int   SOUNDSCAPE_SoundPlaying;

void ( *SOUNDSCAPE_CallBack )( void );

static int  SOUNDSCAPE_IntController1Mask;
static int  SOUNDSCAPE_IntController2Mask;

// some globals for chip type, ports, DMA, IRQs ... and stuff
/* Existing private configuration and saved stack pointers share one C object. */
static struct {
   struct {
   int BasePort;  // base address of the Ensoniq gate-array chip
   int WavePort;  // the AD-1848 base address
   int DMAChan;   // the DMA channel used for PCM
   int WaveIRQ;   // the PCM IRQ
   int MIDIIRQ;   // the MPU-401 IRQ
   int ChipID;    // the Ensoniq chip type
   int SBEmul;    // SoundBlaster emulation flag
   int CDROM;     // CD-ROM flag
   int IRQIndx;   // the Wave IRQ index - for hardware regs
   int OldIRQs;   // Old IRQs flag to support older HW
   } config;
   unsigned long old_stack_pointer;
   unsigned long stack_pointer;
} ssc_private_state;

// adequate stack size
#define kStackSize 2048

/* Two measured alignment bytes before the DMA channel state. */
static struct {
   unsigned short selector;
   unsigned char padding[2];
} ssc_stack_selector = { 0, { 0x23, 0x64 } };
#define StackSelector ssc_stack_selector.selector


static unsigned short oldStackSelector;


// These declarations are necessary to use the inline assembly pragmas.

extern void GetStack(unsigned short *selptr,unsigned long *stackptr);
extern void SetStack(unsigned short selector,unsigned long stackptr);

// This function will get the current stack selector and pointer and save
// them off.
#pragma aux GetStack =	\
	"mov  [edi],esp"		\
	"mov	ax,ss"	 		\
	"mov  [esi],ax" 		\
	parm [esi] [edi]		\
	modify [eax esi edi];

// This function will set the stack selector and pointer to the specified
// values.
#pragma aux SetStack =	\
	"mov  ss,ax"			\
	"mov  esp,edx"			\
	parm [ax] [edx]		\
	modify [eax edx];

int SOUNDSCAPE_DMAChannel = -1;

int SOUNDSCAPE_ErrorCode = SOUNDSCAPE_Ok;

#define SOUNDSCAPE_SetErrorCode( status ) \
   SOUNDSCAPE_ErrorCode   = ( status );


/*---------------------------------------------------------------------
   Function: SOUNDSCAPE_ErrorString

   Returns a pointer to the error message associated with an error
   number.  A -1 returns a pointer the current error.
---------------------------------------------------------------------*/

char *SOUNDSCAPE_ErrorString
   (
   int ErrorNumber
   )

   {
   char *ErrorString;

   switch( ErrorNumber )
      {
      case SOUNDSCAPE_Warning :
      case SOUNDSCAPE_Error :
         ErrorString = SOUNDSCAPE_ErrorString( SOUNDSCAPE_ErrorCode );
         break;

      case SOUNDSCAPE_Ok :
         ErrorString = ssc_constants.messages.ok;
         break;

      case SOUNDSCAPE_EnvNotFound :
         ErrorString = ssc_constants.messages.env_missing;
         break;

      case SOUNDSCAPE_InitFileNotFound :
         ErrorString = ssc_constants.messages.ini_missing;
         break;

      case SOUNDSCAPE_MissingProductInfo :
         ErrorString = ssc_constants.messages.product_missing;
         break;

      case SOUNDSCAPE_MissingPortInfo :
         ErrorString = ssc_constants.messages.port_missing;
         break;

      case SOUNDSCAPE_MissingDMAInfo :
         ErrorString = ssc_constants.messages.dma_missing;
         break;

      case SOUNDSCAPE_MissingIRQInfo :
         ErrorString = ssc_constants.messages.irq_missing;
         break;

      case SOUNDSCAPE_MissingSBIRQInfo :
         ErrorString = ssc_constants.messages.sbirq_missing;
         break;

      case SOUNDSCAPE_MissingSBENABLEInfo :
         ErrorString = ssc_constants.messages.sbenable_missing;
         break;

      case SOUNDSCAPE_MissingWavePortInfo :
         ErrorString = ssc_constants.messages.waveport_missing;
         break;

      case SOUNDSCAPE_HardwareError :
         ErrorString = ssc_constants.messages.not_detected;
         break;

      case SOUNDSCAPE_NoSoundPlaying :
         ErrorString = ssc_constants.messages.not_playing;
         break;

      case SOUNDSCAPE_InvalidSBIrq :
         ErrorString = ssc_constants.messages.invalid_irq;
         break;

      case SOUNDSCAPE_UnableToSetIrq :
         ErrorString = ssc_constants.messages.irq_failed;
         break;

      case SOUNDSCAPE_DmaError :
         ErrorString = DMA_ErrorString( DMA_Error );
         break;

      case SOUNDSCAPE_DPMI_Error :
         ErrorString = ssc_constants.messages.dpmi_error;
         break;

      case SOUNDSCAPE_OutOfMemory :
         ErrorString = ssc_constants.messages.memory_error;
         break;

      default :
         ErrorString = ssc_constants.messages.unknown;
         break;
      }

   return( ErrorString );
   }


/**********************************************************************

   Memory locked functions:

**********************************************************************/


#define SOUNDSCAPE_LockStart SOUNDSCAPE_EnableInterrupt


/*---------------------------------------------------------------------
   Function: SOUNDSCAPE_EnableInterrupt

   Enables the triggering of the sound card interrupt.
---------------------------------------------------------------------*/

static void SOUNDSCAPE_EnableInterrupt
   (
   void
   )

   {
   int mask;

   // Unmask system interrupt
   if ( ssc_private_state.config.WaveIRQ < 8 )
      {
      mask = inp( 0x21 ) & ~( 1 << ssc_private_state.config.WaveIRQ );
      outp( 0x21, mask  );
      }
   else
      {
      mask = inp( 0xA1 ) & ~( 1 << ( ssc_private_state.config.WaveIRQ - 8 ) );
      outp( 0xA1, mask  );

      mask = inp( 0x21 ) & ~( 1 << 2 );
      outp( 0x21, mask  );
      }

   }


/*---------------------------------------------------------------------
   Function: SOUNDSCAPE_DisableInterrupt

   Disables the triggering of the sound card interrupt.
---------------------------------------------------------------------*/

static void SOUNDSCAPE_DisableInterrupt
   (
   void
   )

   {
   int mask;

   // Restore interrupt mask
   if ( ssc_private_state.config.WaveIRQ < 8 )
      {
      mask  = inp( 0x21 ) & ~( 1 << ssc_private_state.config.WaveIRQ );
      mask |= SOUNDSCAPE_IntController1Mask & ( 1 << ssc_private_state.config.WaveIRQ );
      outp( 0x21, mask  );
      }
   else
      {
      mask  = inp( 0x21 ) & ~( 1 << 2 );
      mask |= SOUNDSCAPE_IntController1Mask & ( 1 << 2 );
      outp( 0x21, mask  );

      mask  = inp( 0xA1 ) & ~( 1 << ( ssc_private_state.config.WaveIRQ - 8 ) );
      mask |= SOUNDSCAPE_IntController2Mask & ( 1 << ( ssc_private_state.config.WaveIRQ - 8 ) );
      outp( 0xA1, mask  );
      }
   }


/*---------------------------------------------------------------------
   Function: SOUNDSCAPE_ServiceInterrupt

   Handles interrupt generated by sound card at the end of a voice
   transfer.  Calls the user supplied callback function.
---------------------------------------------------------------------*/

static void __interrupt __far SOUNDSCAPE_ServiceInterrupt
   (
   void
   )

   {
   // save stack
   GetStack( &oldStackSelector, &ssc_private_state.old_stack_pointer );

   // set our stack
   SetStack( StackSelector, ssc_private_state.stack_pointer );

	if ( !( inp( ssc_private_state.config.WavePort + AD_STATUS ) & 0x01 ) )
      {
      // restore stack
      SetStack( oldStackSelector, ssc_private_state.old_stack_pointer );

      // Wasn't our interrupt.  Call the old one.
      _chain_intr( SOUNDSCAPE_OldInt );
      }

   // clear the AD-1848 interrupt
	outp( ssc_private_state.config.WavePort + AD_STATUS, 0x00 );

   // Keep track of current buffer
   SOUNDSCAPE_CurrentDMABuffer += SOUNDSCAPE_TransferLength;
   if ( SOUNDSCAPE_CurrentDMABuffer >= SOUNDSCAPE_DMABufferEnd )
      {
      SOUNDSCAPE_CurrentDMABuffer = SOUNDSCAPE_DMABuffer;
      }

   // Call the caller's callback function
   if ( SOUNDSCAPE_CallBack != NULL )
      {
      SOUNDSCAPE_CallBack();
      }

   // restore stack
   SetStack( oldStackSelector, ssc_private_state.old_stack_pointer );

   // send EOI to Interrupt Controller
   if ( ssc_private_state.config.WaveIRQ > 7 )
      {
      outp( 0xA0, 0x20 );
      }
   outp( 0x20, 0x20 );
   }


/*---------------------------------------------------------------------
   Function: ga_read

   Reads Ensoniq indirect registers.
---------------------------------------------------------------------*/

static int ga_read
   (
   int rnum
   )

   {
   int data;

   outp( ssc_private_state.config.BasePort + GA_REGADDR, rnum );
   data = inp( ssc_private_state.config.BasePort + GA_REGDATA );
   return( data );
   }


/*---------------------------------------------------------------------
   Function: ga_write

   Writes to Ensoniq indirect registers.
---------------------------------------------------------------------*/

static void ga_write
   (
   int rnum,
   int value
   )

   {
	outp( ssc_private_state.config.BasePort + GA_REGADDR, rnum );
	outp( ssc_private_state.config.BasePort + GA_REGDATA, value );
   }


/*---------------------------------------------------------------------
   Function: ad_read

   Reads the AD-1848 indirect registers.  This function should not be
   used while the AD-1848 mode change is enabled
---------------------------------------------------------------------*/

static int ad_read
   (
   int rnum
   )

   {
   int data;

	outp( ssc_private_state.config.WavePort + AD_REGADDR, rnum );
	data = inp( ssc_private_state.config.WavePort + AD_REGDATA );
   return( data );
   }


/*---------------------------------------------------------------------
   Function: ad_write

   Writes to the AD-1848 indirect registers.  This function should
   not be used while the AD-1848 mode change is enabled.
---------------------------------------------------------------------*/

static void ad_write
   (
   int rnum,
   int value
   )

   {
   outp( ssc_private_state.config.WavePort + AD_REGADDR, rnum );
   outp( ssc_private_state.config.WavePort + AD_REGDATA, value );
   }


/*---------------------------------------------------------------------
   Function: tdelay

   Delay function - 250ms - for AD-1848 re-synch and autocalibration.
---------------------------------------------------------------------*/

static void tdelay
   (
   void
   )

   {
	long time;
   unsigned flags;

   flags = DisableInterrupts();
   _enable();
	time = clock() + CLOCKS_PER_SEC/4;
	while(clock() < time)
		;

   RestoreInterrupts( flags );
   }


/*---------------------------------------------------------------------
   Function: pcm_format

   Sets the PCM data format.
---------------------------------------------------------------------*/

static void pcm_format
   (
   void
   )

   {
	int format;

	// build the register value based on format
	format = 0;

   switch( SOUNDSCAPE_SampleRate )
      {
      case 11025:
         format = 0x03;
         break;

      case 22050:
         format = 0x07;
         break;

      case 44100:
         format = 0x0b;
         break;

      default:
         // Set it to 11025 hz
         format = 0x03;
         break;
      }

	// set other format bits and format globals
   if ( SOUNDSCAPE_MixMode & SIXTEEN_BIT )
      {
      format |= 0x40;
      }

   if ( SOUNDSCAPE_MixMode & STEREO )
      {
      format |= 0x10;
      }

	// enable mode change, point to format reg
	outp( ssc_private_state.config.WavePort + AD_REGADDR, 0x40 | AD_FORMAT );

	// write the format
	outp( ssc_private_state.config.WavePort + AD_REGDATA, format );

	// delay for internal re-synch
	tdelay();

	// exit mode change state
	outp( ssc_private_state.config.WavePort + AD_REGADDR, 0x00 );

	// delay for autocalibration
	tdelay();
   }


/*---------------------------------------------------------------------
   Function: SOUNDSCAPE_SetPlaybackRate

   Sets the rate at which the digitized sound will be played in
   hertz.
---------------------------------------------------------------------*/

void SOUNDSCAPE_SetPlaybackRate
   (
   unsigned rate
   )

   {
   if ( rate < 20000 )
      {
      rate = 11025;
      }
   else if ( rate < 30000 )
      {
      rate = 22050;
      }
   else
      {
      rate = 44100;
      }

   SOUNDSCAPE_SampleRate = rate;

   // Set the rate
   pcm_format();
   }


/*---------------------------------------------------------------------
   Function: SOUNDSCAPE_GetPlaybackRate

   Returns the rate at which the digitized sound will be played in
   hertz.
---------------------------------------------------------------------*/

unsigned SOUNDSCAPE_GetPlaybackRate
   (
   void
   )

   {
   return( SOUNDSCAPE_SampleRate );
   }


/*---------------------------------------------------------------------
   Function: SOUNDSCAPE_SetMixMode

   Sets the sound card to play samples in mono or stereo.
---------------------------------------------------------------------*/

int SOUNDSCAPE_SetMixMode
   (
   int mode
   )

   {
   SOUNDSCAPE_MixMode = mode & SOUNDSCAPE_MaxMixMode;
   SOUNDSCAPE_SamplePacketSize = SOUNDSCAPE_SampleSize[ SOUNDSCAPE_MixMode ];

   // Set the mixmode
   pcm_format();

   return( mode );
   }


/*---------------------------------------------------------------------
   Function: SOUNDSCAPE_StopPlayback

   Ends the DMA transfer of digitized sound to the sound card.
---------------------------------------------------------------------*/

void SOUNDSCAPE_StopPlayback
   (
   void
   )

   {
   // Don't allow anymore interrupts
   SOUNDSCAPE_DisableInterrupt();

	/* stop the AD-1848 */
	ad_write( AD_CONFIG, 0x00 );

	/* let it finish it's cycles */
	tdelay();

   // Disable the DMA channel
   DMA_EndTransfer( ssc_private_state.config.DMAChan );

   SOUNDSCAPE_SoundPlaying = FALSE;

   SOUNDSCAPE_DMABuffer = NULL;
   }


/*---------------------------------------------------------------------
   Function: SOUNDSCAPE_SetupDMABuffer

   Programs the DMAC for sound transfer.
---------------------------------------------------------------------*/

static int SOUNDSCAPE_SetupDMABuffer
   (
   char *BufferPtr,
   int   BufferSize,
   int   mode
   )

   {
   int DmaStatus;

   DmaStatus = DMA_SetupTransfer( ssc_private_state.config.DMAChan, BufferPtr, BufferSize, mode );
   if ( DmaStatus == DMA_Error )
      {
      SOUNDSCAPE_SetErrorCode( SOUNDSCAPE_DmaError );
      return( SOUNDSCAPE_Error );
      }

   SOUNDSCAPE_DMAChannel         = ssc_private_state.config.DMAChan;
   SOUNDSCAPE_DMABuffer          = BufferPtr;
   SOUNDSCAPE_CurrentDMABuffer   = BufferPtr;
   SOUNDSCAPE_TotalDMABufferSize = BufferSize;
   SOUNDSCAPE_DMABufferEnd       = BufferPtr + BufferSize;

   return( SOUNDSCAPE_Ok );
   }


/*---------------------------------------------------------------------
   Function: SOUNDSCAPE_GetCurrentPos

   Returns the offset within the current sound being played.
---------------------------------------------------------------------*/

int SOUNDSCAPE_GetCurrentPos
   (
   void
   )

   {
   char *CurrentAddr;
   int   offset;

   if ( !SOUNDSCAPE_SoundPlaying )
      {
      SOUNDSCAPE_SetErrorCode( SOUNDSCAPE_NoSoundPlaying );
      return( SOUNDSCAPE_Error );
      }

   CurrentAddr = DMA_GetCurrentPos( ssc_private_state.config.DMAChan );

   offset = ( int )( ( ( unsigned long )CurrentAddr ) -
      ( ( unsigned long )SOUNDSCAPE_CurrentDMABuffer ) );

   if ( SOUNDSCAPE_MixMode & SIXTEEN_BIT )
      {
      offset >>= 1;
      }

   if ( SOUNDSCAPE_MixMode & STEREO )
      {
      offset >>= 1;
      }

   return( offset );
   }


/*---------------------------------------------------------------------
   Function: SOUNDSCAPE_BeginPlayback

   Starts playback of digitized sound.
---------------------------------------------------------------------*/

static int SOUNDSCAPE_BeginPlayback
   (
   int length
   )

   {
   int SampleLength;
   int LoByte;
   int HiByte;

   if ( SOUNDSCAPE_MixMode & SIXTEEN_BIT )
      {
      SampleLength = length / 2;
      }
   else
      {
      SampleLength = length;
      }

   if ( SOUNDSCAPE_MixMode & STEREO )
      {
      SampleLength >>= 1;
      }

   SampleLength--;

	// setup the AD-1848 interrupt count
	// set the interrupt count value based on the format.
	// count will decrement every sample period and generate
	// an interrupt when in rolls over. we want this always
	// to be at every 1/2 buffer, regardless of the data format,
	// so the count must be adjusted accordingly.
   HiByte = hibyte( SampleLength );
   LoByte = lobyte( SampleLength );
	ad_write( AD_LCOUNT, LoByte );
	ad_write( AD_UCOUNT, HiByte );

	/* unmask the host DMA controller */
   SOUNDSCAPE_EnableInterrupt();

	/* start the AD-1848 */
	ad_write(AD_CONFIG, 0x01);

   SOUNDSCAPE_SoundPlaying = TRUE;

   return( SOUNDSCAPE_Ok );
   }


/*---------------------------------------------------------------------
   Function: SOUNDSCAPE_BeginBufferedPlayback

   Begins multibuffered playback of digitized sound on the sound card.
---------------------------------------------------------------------*/

int SOUNDSCAPE_BeginBufferedPlayback
   (
   char    *BufferStart,
   int      BufferSize,
   int      NumDivisions,
   unsigned SampleRate,
   int      MixMode,
   void  ( *CallBackFunc )( void )
   )

   {
   int DmaStatus;
   int TransferLength;

   if ( SOUNDSCAPE_SoundPlaying )
      {
      SOUNDSCAPE_StopPlayback();
      }

   SOUNDSCAPE_SetMixMode( MixMode );

   DmaStatus = SOUNDSCAPE_SetupDMABuffer( BufferStart, BufferSize,
      DMA_AutoInitRead );
   if ( DmaStatus == SOUNDSCAPE_Error )
      {
      return( SOUNDSCAPE_Error );
      }

   SOUNDSCAPE_SetPlaybackRate( SampleRate );

   SOUNDSCAPE_SetCallBack( CallBackFunc );

   SOUNDSCAPE_EnableInterrupt();

   TransferLength = BufferSize / NumDivisions;
   SOUNDSCAPE_TransferLength = TransferLength;

   SOUNDSCAPE_BeginPlayback( TransferLength );

   return( SOUNDSCAPE_Ok );
   }


/*---------------------------------------------------------------------
   Function: SOUNDSCAPE_GetCardInfo

   Returns the maximum number of bits that can represent a sample
   (8 or 16) and the number of channels (1 for mono, 2 for stereo).
---------------------------------------------------------------------*/

int SOUNDSCAPE_GetCardInfo
   (
   int *MaxSampleBits,
   int *MaxChannels
   )

   {
   int status;

   status = SOUNDSCAPE_FindCard();
   if ( status == SOUNDSCAPE_Ok )
      {
      *MaxChannels = 2;
      *MaxSampleBits = 16;
      return( SOUNDSCAPE_Ok );
      }

   return( status );
   }


/*---------------------------------------------------------------------
   Function: SOUNDSCAPE_SetCallBack

   Specifies the user function to call at the end of a sound transfer.
---------------------------------------------------------------------*/

void SOUNDSCAPE_SetCallBack
   (
   void ( *func )( void )
   )

   {
   SOUNDSCAPE_CallBack = func;
   }


/*---------------------------------------------------------------------
   Function: SOUNDSCAPE_LockEnd

   Used for determining the length of the functions to lock in memory.
---------------------------------------------------------------------*/

static void SOUNDSCAPE_LockEnd
   (
   void
   )

   {
   }


/*---------------------------------------------------------------------
   Function: SOUNDSCAPE_UnlockMemory

   Unlocks all neccessary data.
---------------------------------------------------------------------*/

static void SOUNDSCAPE_UnlockMemory
   (
   void
   )

   {
   DPMI_UnlockMemoryRegion( SOUNDSCAPE_LockStart, SOUNDSCAPE_LockEnd );
   DPMI_Unlock( ssc_private_state.config );
   DPMI_Unlock( SOUNDSCAPE_OldInt );
   DPMI_Unlock( SOUNDSCAPE_Installed );
   DPMI_Unlock( SOUNDSCAPE_DMABuffer );
   DPMI_Unlock( SOUNDSCAPE_DMABufferEnd );
   DPMI_Unlock( SOUNDSCAPE_CurrentDMABuffer );
   DPMI_Unlock( SOUNDSCAPE_TotalDMABufferSize );
   DPMI_Unlock( SOUNDSCAPE_TransferLength );
   DPMI_Unlock( SOUNDSCAPE_MixMode );
   DPMI_Unlock( SOUNDSCAPE_SamplePacketSize );
   DPMI_Unlock( SOUNDSCAPE_SampleRate );
   DPMI_Unlock( SOUNDSCAPE_SoundPlaying );
   DPMI_Unlock( SOUNDSCAPE_CallBack );
   DPMI_Unlock( SOUNDSCAPE_IntController1Mask );
   DPMI_Unlock( SOUNDSCAPE_IntController2Mask );
   }


/*---------------------------------------------------------------------
   Function: SOUNDSCAPE_LockMemory

   Locks all neccessary data.
---------------------------------------------------------------------*/

static int SOUNDSCAPE_LockMemory
   (
   void
   )

   {
   int status;

   status  = DPMI_LockMemoryRegion( SOUNDSCAPE_LockStart, SOUNDSCAPE_LockEnd );
   status |= DPMI_Lock( ssc_private_state.config );
   status |= DPMI_Lock( SOUNDSCAPE_OldInt );
   status |= DPMI_Lock( SOUNDSCAPE_Installed );
   status |= DPMI_Lock( SOUNDSCAPE_DMABuffer );
   status |= DPMI_Lock( SOUNDSCAPE_DMABufferEnd );
   status |= DPMI_Lock( SOUNDSCAPE_CurrentDMABuffer );
   status |= DPMI_Lock( SOUNDSCAPE_TotalDMABufferSize );
   status |= DPMI_Lock( SOUNDSCAPE_TransferLength );
   status |= DPMI_Lock( SOUNDSCAPE_MixMode );
   status |= DPMI_Lock( SOUNDSCAPE_SamplePacketSize );
   status |= DPMI_Lock( SOUNDSCAPE_SampleRate );
   status |= DPMI_Lock( SOUNDSCAPE_SoundPlaying );
   status |= DPMI_Lock( SOUNDSCAPE_CallBack );
   status |= DPMI_Lock( SOUNDSCAPE_IntController1Mask );
   status |= DPMI_Lock( SOUNDSCAPE_IntController2Mask );

   if ( status != DPMI_Ok )
      {
      SOUNDSCAPE_UnlockMemory();
      SOUNDSCAPE_SetErrorCode( SOUNDSCAPE_DPMI_Error );
      return( SOUNDSCAPE_Error );
      }

   return( SOUNDSCAPE_Ok );
   }


/*---------------------------------------------------------------------
   Function: allocateTimerStack

   Allocate a block of memory from conventional (low) memory and return
   the selector (which can go directly into a segment register) of the
   memory block or 0 if an error occured.
---------------------------------------------------------------------*/

static unsigned short allocateTimerStack
   (
   unsigned short size
   )

   {
   union REGS regs;

   // clear all registers
   memset( &regs, 0, sizeof( regs ) );

   // DPMI allocate conventional memory
   regs.w.ax = 0x100;

   // size in paragraphs
   regs.w.bx = ( size + 15 ) / 16;

   int386( 0x31, &regs, &regs );
   if (!regs.w.cflag)
      {
      // DPMI call returns selector in dx
      // (ax contains real mode segment
      // which is ignored here)

      return( regs.w.dx );
      }

   // Couldn't allocate memory.
   return( NULL );
   }


/*---------------------------------------------------------------------
   Function: deallocateTimerStack

   Deallocate a block of conventional (low) memory given a selector to
   it.  Assumes the block was allocated with DPMI function 0x100.
---------------------------------------------------------------------*/

static void deallocateTimerStack
   (
   unsigned short selector
   )

   {
   union REGS regs;

   if ( selector != NULL )
      {
      // clear all registers
      memset( &regs, 0, sizeof( regs ) );

      regs.w.ax = 0x101;
      regs.w.dx = selector;
      int386( 0x31, &regs, &regs );
      }
   }


/*---------------------------------------------------------------------
   Function: parse

   Parses for the right hand string of an .INI file equate.
---------------------------------------------------------------------*/

static int parse
   (
   char *val,
   char *str,
   FILE *p1
   )

   {
	int  i;
	int  j;
   char tmpstr[ 81 ];

	rewind( p1 );

	while( !feof( p1 ) )
      {
      // get a new string
      fgets( tmpstr, 81, p1 );
      if( ( tmpstr[ 0 ] == '[' ) || ( tmpstr[ 0 ] == ';' ) ||
         ( tmpstr[ 0 ] == '\n' ) )
         {
         continue;
         }

		// parse up to the '='
      i = 0;
      while( ( tmpstr[ i ] != '=' ) && ( tmpstr[ i ] != '\n' ) )
         {
         i++;
         }

		if( tmpstr[ i ] != '=' )
         {
         continue;
         }

		tmpstr[ i ] = '\0';

		// see if it's the one we want
		if ( strcmp( tmpstr, str ) )
         {
         continue;
         }

		// copy the right hand value to the destination string
      i++;
		for( j = 0; j < 32; j++ )
         {
         if ( ( tmpstr[ i ] == ' ' ) || ( tmpstr[ i ] == '\t' ) ||
            ( tmpstr[ i ] == ',' ) || ( tmpstr[ i ] == '\n' ) )
            {
            break;
            }

			val[ j ] = tmpstr[ i ];
         i++;
         }
		val[j] = '\0';

      return( TRUE );
      }

   return( FALSE );
   }


/*---------------------------------------------------------------------
   Function: SOUNDSCAPE_FindCard

   Determines if a SoundScape is present and where it is located.
---------------------------------------------------------------------*/

static int SOUNDSCAPE_FindCard
   (
   void
   )

   {
   int   found;
   int   status;
   int   tmp;
	char *cp;
   union { char text[33]; struct ssc_directory_string directory; } path;
	FILE *fp;

   if ( SOUNDSCAPE_FoundCard )
      {
      return( SOUNDSCAPE_Ok );
      }

	cp = getenv( ssc_constants.messages.environment );
   if ( cp == NULL )
      {
      path.directory = ssc_constants.default_directory;
      }
   else
      {
      strcpy( path.text, cp );
      }

   strcat(path.text, ssc_constants.misc.ini_path);

	fp = fopen( path.text, ssc_constants.misc.read_mode );
   if ( fp == NULL )
      {
      if ( cp == NULL )
         {
         SOUNDSCAPE_SetErrorCode( SOUNDSCAPE_EnvNotFound );
         return( SOUNDSCAPE_Error );
         }

      SOUNDSCAPE_SetErrorCode( SOUNDSCAPE_InitFileNotFound );
      return( SOUNDSCAPE_Error );
      }

	found = parse( path.text, ssc_constants.misc.product_key, fp );
   if ( !found )
      {
      fclose( fp );
      SOUNDSCAPE_SetErrorCode( SOUNDSCAPE_MissingProductInfo );
      return( SOUNDSCAPE_Error );
      }

	if( strstr( path.text, ssc_constants.misc.soundfx ) == NULL )
      {
      ssc_private_state.config.OldIRQs = FALSE;
      }
	else
      {
		ssc_private_state.config.OldIRQs = TRUE;
      }

	found = parse( path.text, ssc_constants.misc.port_key, fp );
   if ( !found )
      {
      fclose( fp );
      SOUNDSCAPE_SetErrorCode( SOUNDSCAPE_MissingPortInfo );
      return( SOUNDSCAPE_Error );
      }

	ssc_private_state.config.BasePort = strtol( path.text, ( char ** )0, 16);

	found = parse( path.text, ssc_constants.misc.dma_key, fp );
   if ( !found )
      {
      fclose( fp );
      SOUNDSCAPE_SetErrorCode( SOUNDSCAPE_MissingDMAInfo );
      return( SOUNDSCAPE_Error );
      }

	ssc_private_state.config.DMAChan = ( int )strtol( path.text, ( char ** )0, 10 );
   status = DMA_VerifyChannel( ssc_private_state.config.DMAChan );
   if ( status == DMA_Error )
      {
      fclose( fp );
      SOUNDSCAPE_SetErrorCode( SOUNDSCAPE_DmaError );
      return( SOUNDSCAPE_Error );
      }

	found = parse( path.text, ssc_constants.misc.irq_key, fp );
   if ( !found )
      {
      fclose( fp );
      SOUNDSCAPE_SetErrorCode( SOUNDSCAPE_MissingIRQInfo );
      return( SOUNDSCAPE_Error );
      }

	ssc_private_state.config.MIDIIRQ = ( int )strtol( path.text, ( char ** )0, 10 );
   if ( ssc_private_state.config.MIDIIRQ == 2 )
      {
      ssc_private_state.config.MIDIIRQ = 9;
      }

	found = parse( path.text, ssc_constants.misc.sbirq_key, fp );
   if ( !found )
      {
      fclose( fp );
      SOUNDSCAPE_SetErrorCode( SOUNDSCAPE_MissingSBIRQInfo );
      return( SOUNDSCAPE_Error );
      }

	ssc_private_state.config.WaveIRQ = ( int )strtol( path.text, ( char ** )0, 10 );
	if ( ssc_private_state.config.WaveIRQ == 2 )
      {
		ssc_private_state.config.WaveIRQ = 9;
      }

   if ( !VALID_IRQ( ssc_private_state.config.WaveIRQ ) )
      {
      fclose( fp );
      SOUNDSCAPE_SetErrorCode( SOUNDSCAPE_InvalidSBIrq );
      return( SOUNDSCAPE_Error );
      }

   if ( SOUNDSCAPE_Interrupts[ ssc_private_state.config.WaveIRQ ] == INVALID )
      {
      fclose( fp );
      SOUNDSCAPE_SetErrorCode( SOUNDSCAPE_InvalidSBIrq );
      return( SOUNDSCAPE_Error );
      }

	found = parse( path.text, ssc_constants.misc.sbenable_key, fp );
   if ( !found )
      {
      fclose( fp );
      SOUNDSCAPE_SetErrorCode( SOUNDSCAPE_MissingSBENABLEInfo );
      return( SOUNDSCAPE_Error );
      }

	if( !strcmp( path.text, ssc_constants.misc.false_value ) )
      {
      ssc_private_state.config.SBEmul = FALSE;
      }
	else
      {
      ssc_private_state.config.SBEmul = TRUE;
      }

	// do a hardware test
	outp( ssc_private_state.config.BasePort + GA_REGADDR, 0x00f5 );
	tmp = inp( ssc_private_state.config.BasePort + GA_REGADDR );
	if ( ( tmp & 0x000f ) != 0x0005 )
      {
      fclose( fp );
      SOUNDSCAPE_SetErrorCode( SOUNDSCAPE_HardwareError );
      return( SOUNDSCAPE_Error );
      }

	if( ( tmp & 0x00f0 ) == 0x00f0 )
      {
      fclose( fp );
      SOUNDSCAPE_SetErrorCode( SOUNDSCAPE_HardwareError );
      return( SOUNDSCAPE_Error );
      }

	// formulate the chip ID
	tmp >>= 4;
	if( tmp == 0 )
      {
      ssc_private_state.config.ChipID = ODIE;
      }
	else if ( !( tmp & 0x0008 ) )
      {
		ssc_private_state.config.ChipID = OPUS;
      }
	else
      {
		ssc_private_state.config.ChipID = MMIC;
      }

	// parse for the AD-1848 address if necessary
	if( ssc_private_state.config.ChipID == ODIE )
      {
      found = parse( path.text, ssc_constants.misc.waveport_key, fp );
      if ( !found )
         {
         fclose( fp );
         SOUNDSCAPE_SetErrorCode( SOUNDSCAPE_MissingWavePortInfo );
         return( SOUNDSCAPE_Error );
         }

      ssc_private_state.config.WavePort = strtol( path.text, ( char ** )0, 16 );
      }
	else
      {
      // otherwise, the base address is fixed
      ssc_private_state.config.WavePort = ssc_private_state.config.BasePort + AD_OFFSET;
      }

	// we're done with the file
	fclose( fp );

	// if it's an ODIE board, note CD-ROM decode enable
	if ( ssc_private_state.config.ChipID == ODIE )
      {
		ssc_private_state.config.CDROM = ga_read( GA_CDCFG ) & 0x80;
      }

	// build the Wave IRQ index value
	if( !ssc_private_state.config.OldIRQs )
      {
      switch( ssc_private_state.config.WaveIRQ )
         {
         case 9 :
            ssc_private_state.config.IRQIndx = 0;
            break;

         case 5 :
            ssc_private_state.config.IRQIndx = 1;
            break;

         case 7 :
            ssc_private_state.config.IRQIndx = 2;
            break;

         default :
            ssc_private_state.config.IRQIndx = 3;
            break;
         }
      }
   else
      {
      switch( ssc_private_state.config.WaveIRQ )
         {
         case 9 :
            ssc_private_state.config.IRQIndx = 0;
            break;

         case 5 :
            ssc_private_state.config.IRQIndx = 2;
            break;

         case 7 :
            ssc_private_state.config.IRQIndx = 1;
            break;

         default :
            ssc_private_state.config.IRQIndx = 3;
            break;
         }
      }

   SOUNDSCAPE_FoundCard = TRUE;
   SOUNDSCAPE_SetErrorCode( SOUNDSCAPE_Ok );
   return( SOUNDSCAPE_Ok );
   }


/*---------------------------------------------------------------------
   Function: SOUNDSCAPE_Setup

   Setup the Soundscape card for native mode PCM.
---------------------------------------------------------------------*/

static int SOUNDSCAPE_Setup
   (
   void
   )

   {
   int tmp;
   int Interrupt;
   int status;

	// if necessary, clear any pending SB ints
	if ( ssc_private_state.config.SBEmul )
      {
      inp( SB_IACK );
      }

   SOUNDSCAPE_DisableInterrupt();

	// make sure the AD-1848 is not running
	if ( ad_read( AD_CONFIG ) & 0x01 )
      {
      SOUNDSCAPE_StopPlayback();
      }

	// if necessary, do some signal re-routing
	if( ssc_private_state.config.ChipID != MMIC )
      {
      // get the gate-array off of the DMA channel
		ga_write( GA_DMACHB, 0x20 );

      if ( !ssc_private_state.config.OldIRQs )
         {
         switch( ssc_private_state.config.MIDIIRQ )
            {
            case 5 :
               tmp = 1;
               break;

            case 7 :
               tmp = 2;
               break;

            case 9 :
               tmp = 0;
               break;

            default :
               tmp = 3;
               break;
            }
         }
      else
         {
         switch( ssc_private_state.config.MIDIIRQ )
            {
            case 5 :
               tmp = 2;
               break;

            case 7 :
               tmp = 1;
               break;

            case 9 :
               tmp = 0;
               break;

            default :
               tmp = 3;
               break;
            }
         }

      // set HostIRQ to MIDIIRQ for now
      ga_write( GA_INTCFG, 0xf0 | ( tmp << 2 ) | tmp );

      // now, route the AD-1848 stuff ...
		if ( ssc_private_state.config.ChipID == OPUS )
         {
         // set the AD-1848 chip decode
         ga_write( GA_HMCTL, ( ga_read( GA_HMCTL ) & 0xcf ) | 0x10 );
         }
      // setup the DMA polarity
		ga_write( GA_DMACFG, 0x50 );

		// init the CD-ROM (AD-1848) config register
		ga_write( GA_CDCFG, 0x89 | ( ssc_private_state.config.DMAChan << 4 ) | ( ssc_private_state.config.IRQIndx << 1 ) );

      // enable mode change, point to config reg
		outp( ssc_private_state.config.WavePort + AD_REGADDR, 0x40 | AD_CONFIG );

      // set interf cnfg reg for DMA mode, single chan, autocal on
		outp( ssc_private_state.config.WavePort + AD_REGDATA, 0x0c );

      // exit mode change state
		outp( ssc_private_state.config.WavePort + AD_REGADDR, 0x00 );

      // delay for autocalibration
      tdelay();
      }

   // Install our interrupt handler
   Interrupt = SOUNDSCAPE_Interrupts[ ssc_private_state.config.WaveIRQ ];
   SOUNDSCAPE_OldInt = _dos_getvect( Interrupt );
   if ( ssc_private_state.config.WaveIRQ < 8 )
      {
      _dos_setvect( Interrupt, SOUNDSCAPE_ServiceInterrupt );
      }
   else
      {
      status = IRQ_SetVector( Interrupt, SOUNDSCAPE_ServiceInterrupt );
      if ( status != IRQ_Ok )
         {
         SOUNDSCAPE_SetErrorCode( SOUNDSCAPE_UnableToSetIrq );
         return( SOUNDSCAPE_Error );
         }
      }

	// max left and right volumes
	ad_write( AD_LEFTOUT, 0 );
	ad_write( AD_RIGHTOUT, 0 );

	// clear any pending interrupt condition
	outp( ssc_private_state.config.WavePort + AD_STATUS, 0x00 );

	// enable the interrupt pin
	ad_write( AD_PINCTRL, ad_read( AD_PINCTRL ) | 0x02 );

   SOUNDSCAPE_EnableInterrupt();

   SOUNDSCAPE_SetErrorCode( SOUNDSCAPE_Ok );
   return( SOUNDSCAPE_Ok );
   }


/*---------------------------------------------------------------------
   Function: SOUNDSCAPE_GetMIDIPort

   Gets the address of the SoundScape MIDI port.
---------------------------------------------------------------------*/

int SOUNDSCAPE_GetMIDIPort
   (
   void
   )

   {
   int status;

   status = SOUNDSCAPE_FindCard();
   if ( status != SOUNDSCAPE_Ok )
      {
      return( status );
      }

   return( ssc_private_state.config.BasePort );
   }


/*---------------------------------------------------------------------
   Function: SOUNDSCAPE_Init

   Initializes the sound card and prepares the module to play
   digitized sounds.
---------------------------------------------------------------------*/

int SOUNDSCAPE_Init
   (
   void
   )

   {
   int status;

   if ( SOUNDSCAPE_Installed )
      {
      SOUNDSCAPE_Shutdown();
      }

   // Save the interrupt masks
   SOUNDSCAPE_IntController1Mask = inp( 0x21 );
   SOUNDSCAPE_IntController2Mask = inp( 0xA1 );

   SOUNDSCAPE_SoundPlaying = FALSE;
   SOUNDSCAPE_SetCallBack( NULL );
   SOUNDSCAPE_DMABuffer = NULL;

   status = SOUNDSCAPE_FindCard();
   if ( status != SOUNDSCAPE_Ok )
      {
      return( status );
      }

   status = SOUNDSCAPE_LockMemory();
   if ( status != SOUNDSCAPE_Ok )
      {
      SOUNDSCAPE_UnlockMemory();
      return( status );
      }

   StackSelector = allocateTimerStack( kStackSize );
   if ( StackSelector == NULL )
      {
      SOUNDSCAPE_UnlockMemory();
      SOUNDSCAPE_SetErrorCode( SOUNDSCAPE_OutOfMemory );
      return( SOUNDSCAPE_Error );
      }

   // Leave a little room at top of stack just for the hell of it...
   ssc_private_state.stack_pointer = kStackSize - sizeof( long );

   SOUNDSCAPE_Installed = TRUE;

   status = SOUNDSCAPE_Setup();
   if ( status != SOUNDSCAPE_Ok )
      {
      SOUNDSCAPE_Shutdown();
      return( status );
      }

//	printf("Testing DMA and IRQ ...\n");
//	if( test_dma_irq() )
//      {
//      printf("\t\007Hardware Not Responding\n\n");
//      close_soundscape();
//      return( SOUNDSCAPE_Error );
//      }

   SOUNDSCAPE_SetPlaybackRate( SOUNDSCAPE_DefaultSampleRate );
   SOUNDSCAPE_SetMixMode( SOUNDSCAPE_DefaultMixMode );

   SOUNDSCAPE_SetErrorCode( SOUNDSCAPE_Ok );
   return( SOUNDSCAPE_Ok );
   }


/*---------------------------------------------------------------------
   Function: SOUNDSCAPE_Shutdown

   Ends transfer of sound data to the sound card and restores the
   system resources used by the card.
---------------------------------------------------------------------*/

void SOUNDSCAPE_Shutdown
   (
   void
   )

   {
   int Interrupt;

   // Halt the DMA transfer
   SOUNDSCAPE_StopPlayback();

	// disable the AD-1848 interrupt pin
	ad_write( AD_PINCTRL, ad_read( AD_PINCTRL ) & 0xfd );

	// if necessary, do some signal re-routing
	if ( ssc_private_state.config.ChipID != MMIC )
      {
		// re-init the CD-ROM (AD-1848) config register as needed.
		// this will disable the AD-1848 interface.
		if ( ssc_private_state.config.ChipID == ODIE )
         {
         ga_write( GA_CDCFG, ssc_private_state.config.CDROM );
         }
		else
         {
         ga_write( GA_CDCFG, ga_read( GA_CDCFG ) & 0x7f);
         }

		// if necessary, reset the SoundBlaster IRQ
		if ( ssc_private_state.config.SBEmul )
         {
         ga_write( GA_INTCFG, ( ga_read( GA_INTCFG ) & 0xf3 ) |
            ( ssc_private_state.config.IRQIndx << 2 ) );
         }

      // re-assign the gate-array DMA channel
		ga_write( GA_DMACHB, 0x80 | ( ssc_private_state.config.DMAChan << 4 ) );
      }

   // Restore the original interrupt
   Interrupt = SOUNDSCAPE_Interrupts[ ssc_private_state.config.WaveIRQ ];
   if ( ssc_private_state.config.WaveIRQ >= 8 )
      {
      IRQ_RestoreVector( Interrupt );
      }
   _dos_setvect( Interrupt, SOUNDSCAPE_OldInt );

   SOUNDSCAPE_SoundPlaying = FALSE;

   SOUNDSCAPE_DMABuffer = NULL;

   SOUNDSCAPE_SetCallBack( NULL );

   SOUNDSCAPE_UnlockMemory();

   if ( StackSelector != NULL )
      {
      deallocateTimerStack( StackSelector );
      StackSelector = NULL;
      }

   SOUNDSCAPE_Installed = FALSE;
   }
