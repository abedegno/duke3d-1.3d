/* SPDX-License-Identifier: GPL-2.0-or-later
 * Derived from pinned _FUNCTIO.H. Function-name pointers refer to the typed
 * CONFIG constant table, including explicit measured alignment residue. */
// _functio.h

// file created by makehead.exe
// these headers contain default key assignments, as well as
// default button assignments and game function names
// axis defaults are also included


#ifndef _function_private_
#define _function_private_
#ifdef __cplusplus
extern "C" {
#endif
char * gamefunctions[NUMGAMEFUNCTIONS] = {
    config_text.text_0,
    config_text.text_1,
    config_text.text_2,
    config_text.text_3,
    config_text.text_4,
    config_text.text_5,
    config_text.text_6,
    config_text.text_7,
    config_text.text_8,
    config_text.text_9,
    config_text.text_10,
    config_text.text_11,
    config_text.text_12,
    config_text.text_13,
    config_text.text_14,
    config_text.text_15,
    config_text.text_16,
    config_text.text_17,
    config_text.text_18,
    config_text.text_19,
    config_text.text_20,
    config_text.text_21,
    config_text.text_22,
    config_text.text_23,
    config_text.text_24,
    config_text.text_25,
    config_text.text_26,
    config_text.text_27,
    config_text.text_28,
    config_text.text_29,
    config_text.text_30,
    config_text.text_31,
    config_text.text_32,
    config_text.text_33,
    config_text.text_34,
    config_text.text_35,
    config_text.text_36,
    config_text.text_37,
    config_text.text_38,
    config_text.text_39,
    config_text.text_40,
    config_text.text_41,
    config_text.text_42,
    config_text.text_43,
    config_text.text_44,
    config_text.text_45,
    config_text.text_46,
    config_text.text_47,
    config_text.text_48,
    config_text.text_49,
    config_text.text_50,
    config_text.text_51
};
#ifdef __SETUP__

#define NUMKEYENTRIES 52

static char * keydefaults[NUMKEYENTRIES*3] =
   {
   "Move_Forward", "Up", "Kpad8", 
   "Move_Backward", "Down", "Kpad2", 
   "Turn_Left", "Left", "Kpad4", 
   "Turn_Right", "Right", "KPad6", 
   "Strafe", "LAlt", "RAlt", 
   "Fire", "LCtrl", "RCtrl", 
   "Open", "Space", "", 
   "Run", "LShift", "RShift", 
   "AutoRun", "CapLck", "", 
   "Jump", "A", "/", 
   "Crouch", "Z", "", 
   "Look_Up", "PgUp", "Kpad9", 
   "Look_Down", "PgDn", "Kpad3", 
   "Look_Left", "Insert", "Kpad0", 
   "Look_Right", "Delete", "Kpad.", 
   "Strafe_Left", ",", "", 
   "Strafe_Right", ".", "", 
   "Aim_Up", "Home", "KPad7", 
   "Aim_Down", "End", "Kpad1", 
   "Weapon_1", "1", "", 
   "Weapon_2", "2", "", 
   "Weapon_3", "3", "", 
   "Weapon_4", "4", "", 
   "Weapon_5", "5", "", 
   "Weapon_6", "6", "", 
   "Weapon_7", "7", "", 
   "Weapon_8", "8", "", 
   "Weapon_9", "9", "", 
   "Weapon_10", "0", "", 
   "Inventory", "Enter", "KpdEnt", 
   "Inventory_Left", "[", "", 
   "Inventory_Right", "]", "", 
#if defined(EDUKE) || (!defined(WW2GI) && (APPVER_DN3DREV >= AV_DR_EDK20021))
//#if defined(EDUKE) || !defined(WW2GI)
"Hologram", "H", "", 
"Jetpack", "J", "", 
"NightVision", "N", "",
#elif (APPVER_DN3DREV >= AV_DR_WW2GI10)
//#else
"Special1", "H", "", //   "Hologram", "H", "", 
"Special2", "J", "", //   "Jetpack", "J", "", 
"Special3", "N", "", //   "NightVision", "N", "",
#else // APPVER_DN3DREV < AV_DR_WW2GI10
   "Holo_Duke", "H", "",
   "Jetpack", "J", "",
   "NightVision", "N", "",
#endif
   "MedKit", "M", "", 
   "TurnAround", "BakSpc", "", 
   "SendMessage", "T", "", 
   "Map", "Tab", "", 
   "Shrink_Screen", "-", "Kpad-", 
   "Enlarge_Screen", "=", "Kpad+", 
   "Center_View", "KPad5", "", 
   "Holster_Weapon", "ScrLck", "", 
   "Show_Opponents_Weapon", "W", "", 
   "Map_Follow_Mode", "F", "", 
   "See_Coop_View", "K", "", 
   "Mouse_Aiming", "U", "", 
   "Toggle_Crosshair", "I", "", 
#if (APPVER_DN3DREV >= AV_DR_WW2GI10)
#if defined(EDUKE) || (!defined(WW2GI) && (APPVER_DN3DREV >= AV_DR_EDK20021))
//#if defined(EDUKE) || !defined(WW2GI)
"Steroids", "R", "",
#else
"Special4", "R", "", //   "Steroids", "R", "",
#endif
   "Quick_Stab", "`", "", 
#else // APPVER_DN3DREV < AV_DR_WW2GI10
   "Steroids", "R", "",
   "Quick_Kick", "`", "",
#endif
   "Next_Weapon", "'", "", 
   "Previous_Weapon", ";", ""
   };


static char * mousedefaults[] =
   {
   "Fire",
   "Strafe",
   "Move_Forward",
   };


static char * mouseclickeddefaults[] =
   {
   "",
   "Open",
   "",
   };


static char * joystickdefaults[] =
   {
   "Fire",
   "Strafe",
   "Run",
   "Open",
   "Aim_Down",
   "Look_Right",
   "Aim_Up",
   "Look_Left",
   };


static char * joystickclickeddefaults[] =
   {
   "",
   "Inventory",
   "Jump",
   "Crouch",
   "",
   "",
   "",
   "",
   };


static char * mouseanalogdefaults[] =
   {
   "analog_turning",
   "analog_moving",
   };


static char * mousedigitaldefaults[] =
   {
   "",
   "",
   "",
   "",
   };


static char * gamepaddigitaldefaults[] =
   {
   "Turn_Left",
   "Turn_Right",
   "Move_Forward",
   "Move_Backward",
   };


static char * joystickanalogdefaults[] =
   {
   "analog_turning",
   "analog_moving",
   "analog_strafing",
   "",
   };


static char * joystickdigitaldefaults[] =
   {
   "",
   "",
   "",
   "",
   "",
   "",
   "Run",
   "",
   };
#endif
#ifdef __cplusplus
};
#endif
#endif
