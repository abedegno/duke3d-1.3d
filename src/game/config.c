/* SPDX-License-Identifier: GPL-2.0-or-later
 * Derived from 3D Realms CONFIG.C through the pinned public reconstruction.
 * See gpl.txt and evidence/game-config-source-reference.json. */
/* Reconstructed v1.3D CONFIG. Shared external state views allocate no storage.
 * The 11-byte setup-name copy uses readable Watcom inline assembly to retain
 * the literal-copy expansion after making constant-string padding explicit.
 * All emitted code, strings, alignment residue, data and relocations are
 * checked unmasked against the target. No target instructions are embedded.
 */
#include <conio.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <time.h>
#include <dos.h>
#include "duke3d.h"
extern void copy_setup_filename(const char *, char *);
#pragma aux copy_setup_filename = "movsd" "movsd" "movsw" "movsb" parm [esi] [edi] modify exact [edi esi];
#include "scriplib.h"

// we load this in to get default button and key assignments
// as well as setting up function mappings

/* String alignment bytes are explicit compiler residue, never instructions. */
#pragma data_seg("CONST", "DATA")
static struct {
    char text_0[13];
    unsigned char pad_0[3];
    char text_1[14];
    unsigned char pad_1[2];
    char text_2[10];
    unsigned char pad_2[2];
    char text_3[11];
    unsigned char pad_3[1];
    char text_4[7];
    unsigned char pad_4[1];
    char text_5[5];
    unsigned char pad_5[3];
    char text_6[5];
    unsigned char pad_6[3];
    char text_7[4];
    char text_8[8];
    char text_9[5];
    unsigned char pad_9[3];
    char text_10[7];
    unsigned char pad_10[1];
    char text_11[8];
    char text_12[10];
    unsigned char pad_12[2];
    char text_13[10];
    unsigned char pad_13[2];
    char text_14[11];
    unsigned char pad_14[1];
    char text_15[12];
    char text_16[13];
    unsigned char pad_16[3];
    char text_17[7];
    unsigned char pad_17[1];
    char text_18[9];
    unsigned char pad_18[3];
    char text_19[9];
    unsigned char pad_19[3];
    char text_20[9];
    unsigned char pad_20[3];
    char text_21[9];
    unsigned char pad_21[3];
    char text_22[9];
    unsigned char pad_22[3];
    char text_23[9];
    unsigned char pad_23[3];
    char text_24[9];
    unsigned char pad_24[3];
    char text_25[9];
    unsigned char pad_25[3];
    char text_26[9];
    unsigned char pad_26[3];
    char text_27[9];
    unsigned char pad_27[3];
    char text_28[10];
    unsigned char pad_28[2];
    char text_29[10];
    unsigned char pad_29[2];
    char text_30[15];
    unsigned char pad_30[1];
    char text_31[16];
    char text_32[10];
    unsigned char pad_32[2];
    char text_33[8];
    char text_34[12];
    char text_35[7];
    unsigned char pad_35[1];
    char text_36[11];
    unsigned char pad_36[1];
    char text_37[12];
    char text_38[4];
    char text_39[14];
    unsigned char pad_39[2];
    char text_40[15];
    unsigned char pad_40[1];
    char text_41[12];
    char text_42[15];
    unsigned char pad_42[1];
    char text_43[22];
    unsigned char pad_43[2];
    char text_44[16];
    char text_45[14];
    unsigned char pad_45[2];
    char text_46[13];
    unsigned char pad_46[3];
    char text_47[17];
    unsigned char pad_47[3];
    char text_48[9];
    unsigned char pad_48[3];
    char text_49[11];
    unsigned char pad_49[1];
    char text_50[12];
    char text_51[16];
    char text_52[11];
    unsigned char pad_52[1];
    char text_53[10];
    unsigned char pad_53[2];
    char text_54[43];
    unsigned char pad_54[1];
    char text_55[42];
    unsigned char pad_55[2];
    char text_56[76];
    char text_57[23];
    unsigned char pad_57[1];
    char text_58[8];
    char text_59[18];
    unsigned char pad_59[2];
    char text_60[2];
    unsigned char pad_60[2];
    char text_61[63];
    unsigned char pad_61[1];
    char text_62[20];
    char text_63[3];
    unsigned char pad_63[1];
    char text_64[24];
    char text_65[15];
    unsigned char pad_65[1];
    char text_66[16];
    char text_67[14];
    unsigned char pad_67[2];
    char text_68[24];
    char text_69[15];
    unsigned char pad_69[1];
    char text_70[15];
    unsigned char pad_70[1];
    char text_71[9];
    unsigned char pad_71[3];
    char text_72[22];
    unsigned char pad_72[2];
    char text_73[19];
    unsigned char pad_73[1];
    char text_74[22];
    unsigned char pad_74[2];
    char text_75[22];
    unsigned char pad_75[2];
    char text_76[20];
    char text_77[17];
    unsigned char pad_77[3];
    char text_78[18];
    unsigned char pad_78[2];
    char text_79[25];
    unsigned char pad_79[3];
    char text_80[24];
    char text_81[24];
    char text_82[13];
    unsigned char pad_82[3];
    char text_83[22];
    unsigned char pad_83[2];
    char text_84[25];
    unsigned char pad_84[3];
    char text_85[25];
    unsigned char pad_85[3];
    char text_86[23];
    unsigned char pad_86[1];
    char text_87[13];
    unsigned char pad_87[3];
    char text_88[10];
    unsigned char pad_88[2];
    char text_89[3];
    unsigned char pad_89[1];
    char text_90[62];
    unsigned char pad_90[2];
    char text_91[11];
    unsigned char pad_91[1];
    char text_92[11];
    unsigned char pad_92[1];
    char text_93[5];
    unsigned char pad_93[3];
    char text_94[4];
    char text_95[5];
    unsigned char pad_95[3];
    char text_96[20];
    char text_97[8];
    char text_98[8];
    char text_99[13];
    unsigned char pad_99[3];
    char text_100[12];
    char text_101[7];
    unsigned char pad_101[1];
    char text_102[5];
    unsigned char pad_102[3];
    char text_103[9];
    unsigned char pad_103[3];
    char text_104[12];
    char text_105[13];
    unsigned char pad_105[3];
    char text_106[11];
    unsigned char pad_106[1];
    char text_107[12];
    char text_108[11];
    unsigned char pad_108[1];
    char text_109[4];
    char text_110[11];
    unsigned char pad_110[1];
    char text_111[5];
    unsigned char pad_111[3];
    char text_112[8];
    char text_113[11];
    unsigned char pad_113[1];
    char text_114[9];
    unsigned char pad_114[3];
    char text_115[12];
    char text_116[12];
    char text_117[9];
    unsigned char pad_117[3];
    char text_118[12];
    char text_119[12];
    char text_120[12];
    char text_121[12];
    char text_122[15];
    unsigned char pad_122[1];
    char text_123[10];
    unsigned char pad_123[2];
    char text_124[12];
    char text_125[8];
    char text_126[8];
    char text_127[9];
    unsigned char pad_127[3];
    char text_128[15];
    unsigned char pad_128[1];
    char text_129[12];
    char text_130[17];
    unsigned char pad_130[3];
    char text_131[12];
    char text_132[13];
    unsigned char pad_132[3];
    char text_133[11];
    unsigned char pad_133[1];
    char text_134[14];
    unsigned char pad_134[2];
    char text_135[15];
    unsigned char pad_135[1];
    char text_136[12];
} config_text = {
    "Move_Forward",
    {0x7,0x0,0xc4},
    "Move_Backward",
    {0x0,0xc4},
    "Turn_Left",
    {0x0,0xfc},
    "Turn_Right",
    {0x61},
    "Strafe",
    {0x25},
    "Fire",
    {0x0,0x6f,0x75},
    "Open",
    {0x47,0x65,0x74},
    "Run",
    "AutoRun",
    "Jump",
    {0x66,0x6f,0x20},
    "Crouch",
    {0x6b},
    "Look_Up",
    "Look_Down",
    {0x61,0x72},
    "Look_Left",
    {0x53,0x5f},
    "Look_Right",
    {0x3a},
    "Strafe_Left",
    "Strafe_Right",
    {0x0,0x0,0x0},
    "Aim_Up",
    {0x72},
    "Aim_Down",
    {0x6f,0x76,0x65},
    "Weapon_1",
    {0x0,0x0,0xc4},
    "Weapon_2",
    {0x0,0x0,0xfc},
    "Weapon_3",
    {0x74,0x0,0x61},
    "Weapon_4",
    {0x69,0x72,0x65},
    "Weapon_5",
    {0x47,0x65,0x74},
    "Weapon_6",
    {0x75,0x6e,0x0},
    "Weapon_7",
    {0x72,0x6f,0x75},
    "Weapon_8",
    {0x55,0x70,0x0},
    "Weapon_9",
    {0x0,0x61,0x72},
    "Weapon_10",
    {0x53,0x5f},
    "Inventory",
    {0x0,0x3a},
    "Inventory_Left",
    {0x61},
    "Inventory_Right",
    "Holo_Duke",
    {0x6d,0x5f},
    "Jetpack",
    "NightVision",
    "MedKit",
    {0x32},
    "TurnAround",
    {0x33},
    "SendMessage",
    "Map",
    "Shrink_Screen",
    {0x61,0x70},
    "Enlarge_Screen",
    {0x37},
    "Center_View",
    "Holster_Weapon",
    {0x72},
    "Show_Opponents_Weapon",
    {0x0,0x3a},
    "Map_Follow_Mode",
    "See_Coop_View",
    {0x0,0x0},
    "Mouse_Aiming",
    {0x65,0x74,0x70},
    "Toggle_Crosshair",
    {0x65,0x64,0x4b},
    "Steroids",
    {0x72,0x6f,0x75},
    "Quick_Kick",
    {0x73},
    "Next_Weapon",
    "Previous_Weapon",
    "DUKE3D.CFG",
    {0x37},
    "SETUPFILE",
    {0x77,0x0},
    "\nMultiple Configuration Files Encountered\n",
    {0x5f},
    "========================================\n",
    {0x65,0x74},
    "Please choose a configuration file from the following list by pressing its\n",
    "corresponding letter:\n",
    {0x75},
    "%c. %s\n",
    "%c. %s <DEFAULT>\n",
    {0x20,0x45},
    "\n",
    {0x6f,0x75},
    "(%s will be used if no selection is made within 10 seconds.)\n\n",
    {0x66},
    "%ld seconds left. \r",
    "\n\n",
    {0x20},
    "Using Setup file: '%s'\n",
    "analog_turning",
    {0x6f},
    "analog_strafing",
    "analog_moving",
    {0x20,0x3c},
    "analog_lookingupanddown",
    "KeyDefinitions",
    {0x73},
    "MouseButton%ld",
    {0x0},
    "Controls",
    {0x64,0x65,0x20},
    "MouseButtonClicked%ld",
    {0x66,0x25},
    "MouseAnalogAxes%ld",
    {0xa},
    "MouseDigitalAxes%ld_0",
    {0x25,0x73},
    "MouseDigitalAxes%ld_1",
    {0x6c,0x6f},
    "MouseAnalogScale%ld",
    "MouseSensitivity",
    {0x6b,0x69,0x6e},
    "JoystickButton%ld",
    {0x6e,0x69},
    "JoystickButtonClicked%ld",
    {0x6e,0x74,0x72},
    "GamePadDigitalAxes%ld_0",
    "GamePadDigitalAxes%ld_1",
    "JoystickPort",
    {0x61,0x6c,0x41},
    "JoystickAnalogAxes%ld",
    {0x6c,0x41},
    "JoystickDigitalAxes%ld_0",
    {0x6c,0x65,0x25},
    "JoystickDigitalAxes%ld_1",
    {0x79,0x73,0x74},
    "JoystickAnalogScale%ld",
    {0x0},
    "EnableRudder",
    {0x69,0x67,0x69},
    "game_.sav",
    {0x5f,0x30},
    "rb",
    {0x6d},
    "ReadSetup: %s does not exist\n           Please run SETUP.EXE\n",
    {0x6f,0x79},
    "Comm Setup",
    {0x6c},
    "PlayerName",
    {0x65},
    "NAME",
    {0x74,0x69,0x63},
    "MAP",
    ".map",
    {0x78,0x65,0x73},
    "Using level: '%s'.\n",
    "RTSName",
    "Shadows",
    "Screen Setup",
    {0x69,0x67,0x69},
    "Environment",
    "Detail",
    {0x64},
    "Tilt",
    {0x3a,0x20,0x25},
    "Messages",
    {0x74,0x20,0x65},
    "ScreenWidth",
    "ScreenHeight",
    {0x6e,0x20,0x53},
    "ScreenMode",
    {0x79},
    "ScreenGamma",
    "ScreenSize",
    {0x65},
    "Out",
    "Executions",
    {0x70},
    "Misc",
    {0x73,0x69,0x6e},
    "RunMode",
    "Crosshairs",
    {0x4e},
    "FXDevice",
    {0x0,0x0,0x0},
    "Sound Setup",
    "MusicDevice",
    "FXVolume",
    {0x6c,0x0,0x64},
    "MusicVolume",
    "SoundToggle",
    "MusicToggle",
    "VoiceToggle",
    "AmbienceToggle",
    {0x65},
    "NumVoices",
    {0x72,0x65},
    "NumChannels",
    "NumBits",
    "MixRate",
    "MidiPort",
    {0x64,0x65,0x0},
    "BlasterAddress",
    {0x65},
    "BlasterType",
    "BlasterInterrupt",
    {0x44,0x65,0x76},
    "BlasterDma8",
    "BlasterDma16",
    {0x6d,0x65,0x0},
    "BlasterEmu",
    {0x0},
    "ReverseStereo",
    {0x69,0x63},
    "ControllerType",
    {0x65},
    "MouseAiming"
};
#pragma data_seg()
#include "_functio.h"

//
// Sound variables
//
int32 FXDevice;
int32 MusicDevice;
int32 FXVolume;
int32 MusicVolume;
int32 SoundToggle;
int32 MusicToggle;
int32 VoiceToggle;
int32 AmbienceToggle;
fx_blaster_config BlasterConfig;
int32 NumVoices;
int32 NumChannels;
int32 NumBits;
int32 MixRate;
int32 MidiPort;
int32 ReverseStereo;

int32 ControllerType;
int32 MouseAiming;

//
// Screen variables
//

int32 ScreenMode;
int32 ScreenWidth;
int32 ScreenHeight;

static char setupfilename[128]={SETUPFILENAME};
static int32 scripthandle;
static int32 setupread=0;
/*
===================
=
= CONFIG_GetSetupFilename
=
===================
*/
#define MAXSETUPFILES 20
void CONFIG_GetSetupFilename( void )
   {
   struct find_t fblock;
   char extension[10];
   char * src;
   char * filenames[MAXSETUPFILES];
   int32 numfiles;
   int32 i;

#ifdef NAM
   sprintf(setupfilename,"%s.CFG",basename);
#else
   copy_setup_filename(config_text.text_52,setupfilename);
#endif

   // determine extension

   src = setupfilename + strlen(setupfilename) - 1;

   while (*src != '.')
      {
      src--;
      }
   strcpy (&extension[1],src);
   extension[0] = '*';

   numfiles=0;
   if (_dos_findfirst(extension,0,&fblock)==0)
      {
      do
         {
         filenames[numfiles]=SafeMalloc(128);
         strcpy(filenames[numfiles],fblock.name);
         numfiles++;
         if (numfiles == MAXSETUPFILES)
            break;
         }
      while(!_dos_findnext(&fblock));
      }
   i = CheckParm (config_text.text_53);
   if (i!=0)
      {
      numfiles = 0;
      strcpy(setupfilename,_argv[i+1]);
      }
   if (numfiles>1)
      {
      int32 time;
      int32 oldtime;
      int32 count;

      printf(config_text.text_54);
      printf(config_text.text_55);
      printf(config_text.text_56);
      printf(config_text.text_57);
      for (i=0;i<numfiles;i++)
         {
         if (strcmpi(filenames[i],config_text.text_52))
            {
            printf(config_text.text_58,'a'+(char)i,filenames[i]);
            }
         else
            {
            printf(config_text.text_59,'a'+(char)i,filenames[i]);
            }
         }
      printf(config_text.text_60);
      printf(config_text.text_61,config_text.text_52);
      KB_FlushKeyboardQueue();
      KB_ClearKeysDown();
      count = 9;
      oldtime = clock();
      time=clock()+(10*CLOCKS_PER_SEC);
      while (clock()<time)
         {
         if (clock()>oldtime)
            {
            printf(config_text.text_62,count);
            fflush(stdout);
            oldtime = clock()+CLOCKS_PER_SEC;
            count--;
            }
         if (KB_KeyWaiting())
            {
            int32 ch = KB_Getch();
            ch -='a';
            if (ch>=0 && ch<numfiles)
               {
               strcpy (setupfilename, filenames[ch]);
               break;
               }
            }
         }
      printf(config_text.text_63);
      }
   if (numfiles==1)
      strcpy (setupfilename, filenames[0]);
   printf(config_text.text_64,setupfilename);
   i=clock()+(3*CLOCKS_PER_SEC/4);
   while (clock()<i)
      {
      ;
      }
   for (i=0;i<numfiles;i++)
      {
      SafeFree(filenames[i]);
      }
   }

/*
===================
=
= CONFIG_FunctionNameToNum
=
===================
*/

int32 CONFIG_FunctionNameToNum( char * func )
   {
   int32 i;

   for (i=0;i<NUMGAMEFUNCTIONS;i++)
      {
      if (!stricmp(func,gamefunctions[i]))
         {
         return i;
         }
      }
   return -1;
   }

/*
===================
=
= CONFIG_FunctionNumToName
=
===================
*/

char * CONFIG_FunctionNumToName( int32 func )
   {
   if (func < NUMGAMEFUNCTIONS)
      {
      return gamefunctions[func];
      }
   else
      {
      return NULL;
      }
   }

/*
===================
=
= CONFIG_AnalogNameToNum
=
===================
*/


int32 CONFIG_AnalogNameToNum( char * func )
   {

   if (!stricmp(func,config_text.text_65))
      {
      return analog_turning;
      }
   if (!stricmp(func,config_text.text_66))
      {
      return analog_strafing;
      }
   if (!stricmp(func,config_text.text_67))
      {
      return analog_moving;
      }
   if (!stricmp(func,config_text.text_68))
      {
      return analog_lookingupanddown;
      }

   return -1;
   }

/*
===================
=
= CONFIG_SetDefaults
=
===================
*/

void CONFIG_SetDefaults( void )
   {
   SoundToggle = 1;
   MusicToggle = 1;
   VoiceToggle = 1;
   AmbienceToggle = 1;
   FXVolume = 192;
   MusicVolume = 128;
   ReverseStereo = 0;
   ud.screen_size = 8;
   ud.screen_tilting = 1;
   ud.shadows = 1;
   ud.detail = 1;
   ud.lockout = 0;
   ud.pwlockout[0] = '\0';
   ud.crosshair = 0;
   ud.m_marker = 1;
}
/*
===================
=
= CONFIG_ReadKeys
=
===================
*/

void CONFIG_ReadKeys( void )
   {
   int32 i;
   int32 numkeyentries;
   int32 function;
   char keyname1[80];
   char keyname2[80];
   kb_scancode key1,key2;

   numkeyentries = SCRIPT_NumberEntries( scripthandle, config_text.text_69 );

   for (i=0;i<numkeyentries;i++)
      {
#ifndef EDUKE		  
#ifdef WW2
		  char *pszFuncName=SCRIPT_Entry( scripthandle, config_text.text_69, i );
#endif
#endif
      function = CONFIG_FunctionNameToNum(SCRIPT_Entry( scripthandle, config_text.text_69, i ));
      if (function != -1)
         {
         memset(keyname1,0,sizeof(keyname1));
         memset(keyname2,0,sizeof(keyname2));
         SCRIPT_GetDoubleString
            (
            scripthandle,
            config_text.text_69,
            SCRIPT_Entry( scripthandle,config_text.text_69, i ),
            keyname1,
            keyname2
            );
         key1 = 0;
         key2 = 0;
         if (keyname1[0])
            {
            key1 = (byte) KB_StringToScanCode( keyname1 );
            }
         if (keyname2[0])
            {
            key2 = (byte) KB_StringToScanCode( keyname2 );
            }
#ifdef WW2
//sprintf(g_szBuf,"Adding mapping for '%s' (%d) to '%s', '%s'",pszFuncName,function, keyname1, keyname2);
//AddLog(g_szBuf);
#endif
         CONTROL_MapKey( function, key1, key2 );
         }
#ifdef WW2
   else
   {
//	   sprintf(g_szBuf,"Couldn't find matching function for '%s'",pszFuncName);
//	   AddLog(g_szBuf);
   }
#endif
 	 }
   }


/*
===================
=
= CONFIG_SetupMouse
=
===================
*/

void CONFIG_SetupMouse( int32 scripthandle )
   {
   int32 i;
   char str[80];
   char temp[80];
   int32 function, scale;

   for (i=0;i<MAXMOUSEBUTTONS;i++)
      {
      sprintf(str,config_text.text_70,i);
      memset(temp,0,sizeof(temp));
      SCRIPT_GetString( scripthandle,config_text.text_71, str,temp);
      function = CONFIG_FunctionNameToNum(temp);
      if (function != -1)
         CONTROL_MapButton( function, i, false );
      sprintf(str,config_text.text_72,i);
      memset(temp,0,sizeof(temp));
      SCRIPT_GetString( scripthandle,config_text.text_71, str,temp);
      function = CONFIG_FunctionNameToNum(temp);
      if (function != -1)
         CONTROL_MapButton( function, i, true );
      }
   // map over the axes
   for (i=0;i<MAXMOUSEAXES;i++)
      {
      sprintf(str,config_text.text_73,i);
      memset(temp,0,sizeof(temp));
      SCRIPT_GetString(scripthandle, config_text.text_71, str,temp);
      function = CONFIG_AnalogNameToNum(temp);
      if (function != -1)
         {
         CONTROL_MapAnalogAxis(i,function);
         }
      sprintf(str,config_text.text_74,i);
      memset(temp,0,sizeof(temp));
      SCRIPT_GetString(scripthandle, config_text.text_71, str,temp);
      function = CONFIG_FunctionNameToNum(temp);
      if (function != -1)
         CONTROL_MapDigitalAxis( i, function, 0 );
      sprintf(str,config_text.text_75,i);
      memset(temp,0,sizeof(temp));
      SCRIPT_GetString(scripthandle, config_text.text_71, str,temp);
      function = CONFIG_FunctionNameToNum(temp);
      if (function != -1)
         CONTROL_MapDigitalAxis( i, function, 1 );
      sprintf(str,config_text.text_76,i);
      SCRIPT_GetNumber(scripthandle, config_text.text_71, str,&scale);
      CONTROL_SetAnalogAxisScale( i, scale );
      }

   SCRIPT_GetNumber( scripthandle, config_text.text_71,config_text.text_77,&function);
   CONTROL_SetMouseSensitivity(function);
   }

/*
===================
=
= CONFIG_SetupGamePad
=
===================
*/

void CONFIG_SetupGamePad( int32 scripthandle )
   {
   int32 i;
   char str[80];
   char temp[80];
   int32 function;


   for (i=0;i<MAXJOYBUTTONS;i++)
      {
      sprintf(str,config_text.text_78,i);
      memset(temp,0,sizeof(temp));
      SCRIPT_GetString( scripthandle,config_text.text_71, str,temp);
      function = CONFIG_FunctionNameToNum(temp);
      if (function != -1)
         CONTROL_MapButton( function, i, false );
      sprintf(str,config_text.text_79,i);
      memset(temp,0,sizeof(temp));
      SCRIPT_GetString( scripthandle,config_text.text_71, str,temp);
      function = CONFIG_FunctionNameToNum(temp);
      if (function != -1)
         CONTROL_MapButton( function, i, true );
      }
   // map over the axes
   for (i=0;i<MAXGAMEPADAXES;i++)
      {
      sprintf(str,config_text.text_80,i);
      memset(temp,0,sizeof(temp));
      SCRIPT_GetString(scripthandle, config_text.text_71, str,temp);
      function = CONFIG_FunctionNameToNum(temp);
      if (function != -1)
         CONTROL_MapDigitalAxis( i, function, 0 );
      sprintf(str,config_text.text_81,i);
      memset(temp,0,sizeof(temp));
      SCRIPT_GetString(scripthandle, config_text.text_71, str,temp);
      function = CONFIG_FunctionNameToNum(temp);
      if (function != -1)
         CONTROL_MapDigitalAxis( i, function, 1 );
      }
   SCRIPT_GetNumber( scripthandle, config_text.text_71,config_text.text_82,&function);
   CONTROL_JoystickPort = function;
   }

/*
===================
=
= CONFIG_SetupJoystick
=
===================
*/

void CONFIG_SetupJoystick( int32 scripthandle )
   {
   int32 i;
   char str[80];
   char temp[80];
   int32 function, scale;

   for (i=0;i<MAXJOYBUTTONS;i++)
      {
      sprintf(str,config_text.text_78,i);
      memset(temp,0,sizeof(temp));
      SCRIPT_GetString( scripthandle,config_text.text_71, str,temp);
      function = CONFIG_FunctionNameToNum(temp);
      if (function != -1)
         CONTROL_MapButton( function, i, false );
      sprintf(str,config_text.text_79,i);
      memset(temp,0,sizeof(temp));
      SCRIPT_GetString( scripthandle,config_text.text_71, str,temp);
      function = CONFIG_FunctionNameToNum(temp);
      if (function != -1)
         CONTROL_MapButton( function, i, true );
      }
   // map over the axes
   for (i=0;i<MAXJOYAXES;i++)
      {
      sprintf(str,config_text.text_83,i);
      memset(temp,0,sizeof(temp));
      SCRIPT_GetString(scripthandle, config_text.text_71, str,temp);
      function = CONFIG_AnalogNameToNum(temp);
      if (function != -1)
         {
         CONTROL_MapAnalogAxis(i,function);
         }
      sprintf(str,config_text.text_84,i);
      memset(temp,0,sizeof(temp));
      SCRIPT_GetString(scripthandle, config_text.text_71, str,temp);
      function = CONFIG_FunctionNameToNum(temp);
      if (function != -1)
         CONTROL_MapDigitalAxis( i, function, 0 );
      sprintf(str,config_text.text_85,i);
      memset(temp,0,sizeof(temp));
      SCRIPT_GetString(scripthandle, config_text.text_71, str,temp);
      function = CONFIG_FunctionNameToNum(temp);
      if (function != -1)
         CONTROL_MapDigitalAxis( i, function, 1 );
      sprintf(str,config_text.text_86,i);
      SCRIPT_GetNumber(scripthandle, config_text.text_71, str,&scale);
      CONTROL_SetAnalogAxisScale( i, scale );
      }
   // read in JoystickPort
   SCRIPT_GetNumber( scripthandle, config_text.text_71,config_text.text_82,&function);
   CONTROL_JoystickPort = function;
   // read in rudder state
   SCRIPT_GetNumber( scripthandle, config_text.text_71,config_text.text_87,&CONTROL_RudderEnabled);
   }

void readsavenames(void)
{
    long dummy;
    short i;
	// also need to change in menues.c loadplayer()2
// *** VERSIONS RESTORATION ***
// Taken From the EDuke changelog for Build 23 (06/20/00):
//
// "Saved files were not being detected correctly on initialization."
#if (APPVER_DN3DREV >= AV_DR_EDK20023)
    char *fn = {"egam_.sav"};
#else
#ifdef EDUKE	
    char *fn = {"egame_.sav"};
#else
    char *fn = {config_text.text_88};
#endif
#endif
    FILE *fil;

    for (i=0;i<10;i++)
    {
        fn[4] = i+'0';
        if ((fil = fopen(fn,config_text.text_89)) == NULL ) continue;
        dfread(&dummy,4,1,fil);

        if(dummy != 103) return;
        dfread(&ud.savegame[i][0],19,1,fil);
        fclose(fil);
    }
}

/*
===================
=
= CONFIG_ReadSetup
=
===================
*/

void CONFIG_ReadSetup( void )
{
   int32 dummy;
   char commmacro[] = "CommbatMacro# ";

   if (!SafeFileExists(setupfilename))
      {
      Error(config_text.text_90,setupfilename);
      }

   CONFIG_SetDefaults();
   scripthandle = SCRIPT_Load( setupfilename );

   for(dummy = 0;dummy < 10;dummy++)
   {
       commmacro[13] = dummy+'0';
       SCRIPT_GetString( scripthandle, config_text.text_91,commmacro,&ud.ridecule[dummy][0]);
   }

   SCRIPT_GetString( scripthandle, config_text.text_91,config_text.text_92,&myname[0]);

   dummy = CheckParm(config_text.text_93);
   if( dummy ) strcpy(myname,_argv[dummy+1]);
   dummy = CheckParm(config_text.text_94);
#ifndef VOLUMEONE
   if( dummy )
   {
       strcpy(boardfilename,_argv[dummy+1]);
       if( strchr(boardfilename,'.') == 0)
           strcat(boardfilename,config_text.text_95);
       printf(config_text.text_96,boardfilename);
   }
   else
#else
    if( dummy )
        puts("The -map option is available in the registered version only!");
#endif
       boardfilename[0] = 0;

   SCRIPT_GetString( scripthandle, config_text.text_91,config_text.text_97,&ud.rtsname[0]);

   SCRIPT_GetNumber( scripthandle, config_text.text_99, config_text.text_98,&ud.shadows);
   SCRIPT_GetString( scripthandle, config_text.text_99,config_text.text_100,&ud.pwlockout[0]);
   SCRIPT_GetNumber( scripthandle, config_text.text_99, config_text.text_101,&ud.detail);
   SCRIPT_GetNumber( scripthandle, config_text.text_99, config_text.text_102,&ud.screen_tilting);
   SCRIPT_GetNumber( scripthandle, config_text.text_99, config_text.text_103,&ud.fta_on);
   SCRIPT_GetNumber( scripthandle, config_text.text_99, config_text.text_104,&ScreenWidth);
   SCRIPT_GetNumber( scripthandle, config_text.text_99, config_text.text_105,&ScreenHeight);
   SCRIPT_GetNumber( scripthandle, config_text.text_99, config_text.text_106,&ScreenMode);
   SCRIPT_GetNumber( scripthandle, config_text.text_99, config_text.text_107,&ud.brightness);
   SCRIPT_GetNumber( scripthandle, config_text.text_99, config_text.text_108,&ud.screen_size);
   SCRIPT_GetNumber( scripthandle, config_text.text_99, config_text.text_109,&ud.lockout);

   SCRIPT_GetNumber( scripthandle, config_text.text_111, config_text.text_110,&ud.executions);
   ud.executions++;
   SCRIPT_GetNumber( scripthandle, config_text.text_111, config_text.text_112,&ud.auto_run);
   SCRIPT_GetNumber( scripthandle, config_text.text_111, config_text.text_113,&ud.crosshair);
   SCRIPT_GetNumber( scripthandle, config_text.text_115, config_text.text_114,&FXDevice);
   SCRIPT_GetNumber( scripthandle, config_text.text_115, config_text.text_116,&MusicDevice);
   SCRIPT_GetNumber( scripthandle, config_text.text_115, config_text.text_117,&FXVolume);
   SCRIPT_GetNumber( scripthandle, config_text.text_115, config_text.text_118,&MusicVolume);
   SCRIPT_GetNumber( scripthandle, config_text.text_115, config_text.text_119,&SoundToggle);
   SCRIPT_GetNumber( scripthandle, config_text.text_115, config_text.text_120,&MusicToggle);
   SCRIPT_GetNumber( scripthandle, config_text.text_115, config_text.text_121,&VoiceToggle);
   SCRIPT_GetNumber( scripthandle, config_text.text_115, config_text.text_122,&AmbienceToggle);
   SCRIPT_GetNumber( scripthandle, config_text.text_115, config_text.text_123,&NumVoices);
   SCRIPT_GetNumber( scripthandle, config_text.text_115, config_text.text_124,&NumChannels);
   SCRIPT_GetNumber( scripthandle, config_text.text_115, config_text.text_125,&NumBits);
   SCRIPT_GetNumber( scripthandle, config_text.text_115, config_text.text_126,&MixRate);
   SCRIPT_GetNumber( scripthandle, config_text.text_115, config_text.text_127,&MidiPort);
   SCRIPT_GetNumber( scripthandle, config_text.text_115, config_text.text_128,&dummy);
   BlasterConfig.Address = dummy;
   SCRIPT_GetNumber( scripthandle, config_text.text_115, config_text.text_129,&dummy);
   BlasterConfig.Type = dummy;
   SCRIPT_GetNumber( scripthandle, config_text.text_115, config_text.text_130,&dummy);
   BlasterConfig.Interrupt = dummy;
   SCRIPT_GetNumber( scripthandle, config_text.text_115, config_text.text_131,&dummy);
   BlasterConfig.Dma8 = dummy;
   SCRIPT_GetNumber( scripthandle, config_text.text_115, config_text.text_132,&dummy);
   BlasterConfig.Dma16 = dummy;
   SCRIPT_GetNumber( scripthandle, config_text.text_115, config_text.text_133,&dummy);
   BlasterConfig.Emu = dummy;
   SCRIPT_GetNumber( scripthandle, config_text.text_115, config_text.text_134,&dummy);
   ReverseStereo = dummy;

   SCRIPT_GetNumber( scripthandle, config_text.text_71,config_text.text_135,&ControllerType);
   SCRIPT_GetNumber( scripthandle, config_text.text_71,config_text.text_136,&MouseAiming);

   CONTROL_ClearAssignments();

   CONFIG_ReadKeys();

   switch (ControllerType)
      {
      case controltype_keyboardandmouse:
         CONFIG_SetupMouse(scripthandle);
         break;
      case controltype_keyboardandjoystick:
      case controltype_keyboardandflightstick:
      case controltype_keyboardandthrustmaster:
         CONFIG_SetupJoystick(scripthandle);
         break;
      case controltype_keyboardandgamepad:
         CONFIG_SetupGamePad(scripthandle);
         break;

      }
   setupread = 1;
   }

/*
===================
=
= CONFIG_WriteSetup
=
===================
*/

void CONFIG_WriteSetup( void )
   {
   int32 dummy;

   if (!setupread) return;

   SCRIPT_PutNumber( scripthandle, config_text.text_99, config_text.text_98,ud.shadows,false,false);
   SCRIPT_PutString( scripthandle, config_text.text_99, config_text.text_100,ud.pwlockout);
   SCRIPT_PutNumber( scripthandle, config_text.text_99, config_text.text_101,ud.detail,false,false);
   SCRIPT_PutNumber( scripthandle, config_text.text_99, config_text.text_102,ud.screen_tilting,false,false);
   SCRIPT_PutNumber( scripthandle, config_text.text_99, config_text.text_103,ud.fta_on,false,false);
   SCRIPT_PutNumber( scripthandle, config_text.text_99, config_text.text_109,ud.lockout,false,false);
   SCRIPT_PutNumber( scripthandle, config_text.text_115, config_text.text_117,FXVolume,false,false);
   SCRIPT_PutNumber( scripthandle, config_text.text_115, config_text.text_118,MusicVolume,false,false);
   SCRIPT_PutNumber( scripthandle, config_text.text_115, config_text.text_119,SoundToggle,false,false);
   SCRIPT_PutNumber( scripthandle, config_text.text_115, config_text.text_121,VoiceToggle,false,false);
   SCRIPT_PutNumber( scripthandle, config_text.text_115, config_text.text_122,AmbienceToggle,false,false);
   SCRIPT_PutNumber( scripthandle, config_text.text_115, config_text.text_120,MusicToggle,false,false);
   SCRIPT_PutNumber( scripthandle, config_text.text_115, config_text.text_134,ReverseStereo,false,false);
   SCRIPT_PutNumber( scripthandle, config_text.text_99, config_text.text_108,ud.screen_size,false,false);
   SCRIPT_PutNumber( scripthandle, config_text.text_99, config_text.text_107,ud.brightness,false,false);
   SCRIPT_PutNumber( scripthandle, config_text.text_111, config_text.text_110,ud.executions,false,false);
   SCRIPT_PutNumber( scripthandle, config_text.text_111, config_text.text_112,ud.auto_run,false,false);
   SCRIPT_PutNumber( scripthandle, config_text.text_111, config_text.text_113,ud.crosshair,false,false);

   switch (ControllerType)
      {
      case controltype_keyboardandmouse:
         dummy = CONTROL_GetMouseSensitivity();
         SCRIPT_PutNumber( scripthandle, config_text.text_71,config_text.text_77,dummy,false,false);
         break;
      }
   SCRIPT_Save (scripthandle, setupfilename);
   SCRIPT_Free (scripthandle);
   }

