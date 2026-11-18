/* SPDX-License-Identifier: GPL-2.0-or-later */
/* Per-message native C storage. Names are inferred from authored labels.
 * Visible text, terminator, capacity and post-NUL residue are explicit.
 * Source: src/game/symbolic_preserved/GAME.S; no historical C spelling claim. */
#pragma data_seg("CONST", "DATA")
/* Visible NUL at 46; remaining bytes preserve authored capacity. */
static char game_text_getpackets_0[48] = "\nYou cannot play Duke with different versions.\000\020";
/* Visible NUL at 44; remaining bytes preserve authored capacity. */
static char game_text_getpackets_48[48] = "INVALID GAME PACKET!!! (%ld too many bytes)\n\000V\007\000";
/* Visible NUL at 1; remaining bytes preserve authored capacity. */
static char game_text_getpackets_96[4] = " \000\003\330";
/* Visible NUL at 33; remaining bytes preserve authored capacity. */
static char game_text_checksync_100[36] = "Out Of Sync - Please restart game\000\240V";
/* Visible NUL at 33; remaining bytes preserve authored capacity. */
static char game_text_checksync_136[36] = "RUN DN3DHELP.EXE for information.\000\000\000";
/* Visible NUL at 22; remaining bytes preserve authored capacity. */
static char game_text_checksync_172[24] = "Missed Network packet!\000i";
/* Visible NUL at 33; remaining bytes preserve authored capacity. */
static char game_text_checksync_196[36] = "RUN DN3DHELP.EXE for information.\000ME";
/* Visible NUL at 3; remaining bytes preserve authored capacity. */
static char game_text_invennum_232[4] = "%ld\000";
/* Visible NUL at 2; remaining bytes preserve authored capacity. */
static char game_text_displayfragbar_236[4] = "%d\000!";
/* Visible NUL at 1; remaining bytes preserve authored capacity. */
static char game_text_coolgaugetext_240[4] = "%\000 (";
/* Visible NUL at 2; remaining bytes preserve authored capacity. */
static char game_text_coolgaugetext_244[4] = "ON\000 ";
/* Visible NUL at 3; remaining bytes preserve authored capacity. */
static char game_text_coolgaugetext_248[4] = "OFF\000";
/* Visible NUL at 4; remaining bytes preserve authored capacity. */
static char game_text_coolgaugetext_252[8] = "AUTO\000byt";
/* Visible NUL at 31; remaining bytes preserve authored capacity. */
static char game_text_caches_260[32] = "Locked- %ld: Leng:%ld, Lock:%ld\000";
/* Visible NUL at 15; remaining bytes preserve authored capacity. */
static char game_text_caches_292[16] = "RTS Locked %ld:\000";
/* Visible NUL at 6; remaining bytes preserve authored capacity. */
static char game_text_coords_308[8] = "X= %ld\000D";
/* Visible NUL at 6; remaining bytes preserve authored capacity. */
static char game_text_coords_316[8] = "Y= %ld\000E";
/* Visible NUL at 6; remaining bytes preserve authored capacity. */
static char game_text_coords_324[8] = "Z= %ld\000f";
/* Visible NUL at 6; remaining bytes preserve authored capacity. */
static char game_text_coords_332[8] = "A= %ld\000n";
/* Visible NUL at 7; remaining bytes preserve authored capacity. */
static char game_text_coords_340[8] = "ZV= %ld\000";
/* Visible NUL at 7; remaining bytes preserve authored capacity. */
static char game_text_coords_348[8] = "OG= %ld\000";
/* Visible NUL at 7; remaining bytes preserve authored capacity. */
static char game_text_coords_356[8] = "TH= %ld\000";
/* Visible NUL at 10; remaining bytes preserve authored capacity. */
static char game_text_binscreen_364[12] = "duke3d.bin\000 ";
/* Visible NUL at 22; remaining bytes preserve authored capacity. */
static char game_text_gameexit_376[24] = "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\000a";
/* Visible NUL at 1; remaining bytes preserve authored capacity. */
static char game_text_gameexit_400[4] = "\n\000on";
/* Visible NUL at 4; remaining bytes preserve authored capacity. */
static char game_text_gameexit_404[8] = "%s%s\000ld\000";
/* Visible NUL at 10; remaining bytes preserve authored capacity. */
static char game_text_gameexit_412[12] = "duke3d.tmp\000 ";
/* Visible NUL at 2; remaining bytes preserve authored capacity. */
static char game_text_displayrest_424[4] = ": \000\000";
/* Visible NUL at 11; remaining bytes preserve authored capacity. */
static char game_text_displayrest_428[12] = "GAME PAUSED\000";
/* Visible NUL at 52; remaining bytes preserve authored capacity. */
static char game_text_spawn_440[56] = "Found lonely Sector Effector (lotag 0) at (%ld,%ld)\n\000= %";
/* Visible NUL at 38; remaining bytes preserve authored capacity. */
static char game_text_spawn_496[40] = "Too many moving sectors at (%ld,%ld).\n\000=";
/* Visible NUL at 59; remaining bytes preserve authored capacity. */
static char game_text_spawn_536[60] = "Subway found no zero'd sectors with locators\nat (%ld,%ld).\n\000";
/* Visible NUL at 12; remaining bytes preserve authored capacity. */
static char game_text_nonsharedkeys_596[16] = "duke0000.pcx\000 PA";
/* Visible NUL at 8; remaining bytes preserve authored capacity. */
static char game_text_nonsharedkeys_612[12] = "PLAYING \000d l";
/* Visible NUL at 26; remaining bytes preserve authored capacity. */
static char game_text_nonsharedkeys_624[28] = ".  USE SHIFT-F5 TO CHANGE.\000g";
/* Visible NUL at 35; remaining bytes preserve authored capacity. */
static char game_text_comlinehelp_652[36] = "Command line help.  %s [/flags...]\n\000";
/* Visible NUL at 30; remaining bytes preserve authored capacity. */
static char game_text_comlinehelp_688[32] = "    ?, /?    This help message\000.";
/* Visible NUL at 26; remaining bytes preserve authored capacity. */
static char game_text_comlinehelp_720[28] = "    /l##     Level  (1-11)\000e";
/* Visible NUL at 25; remaining bytes preserve authored capacity. */
static char game_text_comlinehelp_748[28] = "    /v#      Volume (1-3)\000d,";
/* Visible NUL at 25; remaining bytes preserve authored capacity. */
static char game_text_comlinehelp_776[28] = "    /s#      Skill  (1-4)\000YI";
/* Visible NUL at 24; remaining bytes preserve authored capacity. */
static char game_text_comlinehelp_804[28] = "    /r       Record demo\000 CH";
/* Visible NUL at 24; remaining bytes preserve authored capacity. */
static char game_text_comlinehelp_832[28] = "    /m       No monsters\000  %";
/* Visible NUL at 21; remaining bytes preserve authored capacity. */
static char game_text_comlinehelp_860[24] = "    /ns      No sound\000\000\000";
/* Visible NUL at 21; remaining bytes preserve authored capacity. */
static char game_text_comlinehelp_884[24] = "    /nm      No music\000ev";
/* Visible NUL at 69; remaining bytes preserve authored capacity. */
static char game_text_comlinehelp_908[72] = "    /t#      Respawn, 0 = Monsters, 1 = Items, 2 = Inventory, x = All\000  ";
/* Visible NUL at 77; remaining bytes preserve authored capacity. */
static char game_text_comlinehelp_980[80] = "    /c#      MP mode, 0 = DukeMatch(spawn), 1 = Coop, 2 = Dukematch(no spawn)\000\000\000";
/* Visible NUL at 34; remaining bytes preserve authored capacity. */
static char game_text_comlinehelp_1060[36] = "    /q#      Fake MP (2-8 players)\000 ";
/* Visible NUL at 41; remaining bytes preserve authored capacity. */
static char game_text_comlinehelp_1096[44] = "    /i#      Network mode (1/0) (MP only)\000en";
/* Visible NUL at 51; remaining bytes preserve authored capacity. */
static char game_text_comlinehelp_1140[52] = "    /f#      Send fewer packets (1, 2, 4) (MP only)\000";
/* Visible NUL at 46; remaining bytes preserve authored capacity. */
static char game_text_comlinehelp_1192[48] = "    /g<file> Group <file> (default DUKE3D.GRP)\000\000";
/* Visible NUL at 46; remaining bytes preserve authored capacity. */
static char game_text_comlinehelp_1240[48] = "    /x<file> Compile <file> (default GAME.CON)\000 ";
/* Visible NUL at 49; remaining bytes preserve authored capacity. */
static char game_text_comlinehelp_1288[52] = "    -8250    Passed from SETUP.EXE and COMMIT.EXE\000fe";
/* Visible NUL at 49; remaining bytes preserve authored capacity. */
static char game_text_comlinehelp_1340[52] = "    -net     Passed from SETUP.EXE and COMMIT.EXE\000 <";
/* Visible NUL at 38; remaining bytes preserve authored capacity. */
static char game_text_comlinehelp_1392[40] = "    /j       Display version with exit\000e";
/* Visible NUL at 30; remaining bytes preserve authored capacity. */
static char game_text_checkcommandline_1432[32] = "Could not find con file '%s'.\n\000C";
/* Visible NUL at 21; remaining bytes preserve authored capacity. */
static char game_text_checkcommandline_1464[24] = "Using con file: '%s'\n\000ed";
/* Visible NUL at 10; remaining bytes preserve authored capacity. */
static char game_text_checkcommandline_1488[12] = "Sound off.\000.";
/* Visible NUL at 10; remaining bytes preserve authored capacity. */
static char game_text_checkcommandline_1500[12] = "Music off.\000M";
/* Visible NUL at 17; remaining bytes preserve authored capacity. */
static char game_text_checkcommandline_1512[20] = "Network Mode %ld\n\000  ";
/* Visible NUL at 18; remaining bytes preserve authored capacity. */
static char game_text_checkcommandline_1532[20] = "Dukematch (spawn).\000.";
/* Visible NUL at 17; remaining bytes preserve authored capacity. */
static char game_text_checkcommandline_1552[20] = "Cooperative play.\000\000 ";
/* Visible NUL at 21; remaining bytes preserve authored capacity. */
static char game_text_checkcommandline_1572[24] = "Dukematch (no spawn).\000\000\000";
/* Visible NUL at 11; remaining bytes preserve authored capacity. */
static char game_text_checkcommandline_1596[12] = "Respawn on.\000";
/* Visible NUL at 13; remaining bytes preserve authored capacity. */
static char game_text_checkcommandline_1608[16] = "Monsters off.\000co";
/* Visible NUL at 16; remaining bytes preserve authored capacity. */
static char game_text_checkcommandline_1624[20] = "Fake multi Mode.\000ing";
/* Visible NUL at 16; remaining bytes preserve authored capacity. */
static char game_text_checkcommandline_1644[20] = "Demorec mode on.\000edS";
/* Visible NUL at 4; remaining bytes preserve authored capacity. */
static char game_text_checkcommandline_1664[8] = "1.3D\000off";
/* Visible NUL at 33; remaining bytes preserve authored capacity. */
static char game_text_checkcommandline_1672[36] = "Duke Nukem 3D (FULL VERSION) v%s\n\000 D";
/* Visible NUL at 8; remaining bytes preserve authored capacity. */
static char game_text_Logo_1708[12] = "logo.anm\000(sp";
/* Visible NUL at 22; remaining bytes preserve authored capacity. */
static char game_text_Logo_1720[24] = "WAITING FOR PLAYERS...\000.";
/* Visible NUL at 12; remaining bytes preserve authored capacity. */
static char game_text_loadtmb_1744[16] = "d3dtimbr.tmb\000(no";
/* Visible NUL at 23; remaining bytes preserve authored capacity. */
static char game_text_compilecons_1760[24] = "  * Compiling %s in %s\n\000";
/* Visible NUL at 19; remaining bytes preserve authored capacity. */
static char game_text_Startup_1784[20] = "Loading art header.\000";
/* Visible NUL at 12; remaining bytes preserve authored capacity. */
static char game_text_Startup_1804[16] = "tiles000.art\000ult";
/* Visible NUL at 24; remaining bytes preserve authored capacity. */
static char game_text_Startup_1820[28] = "Multiplayer initialized.\000n.\000";
/* Visible NUL at 21; remaining bytes preserve authored capacity. */
static char game_text_Startup_1848[24] = "Checking music inits.\0003D";
/* Visible NUL at 21; remaining bytes preserve authored capacity. */
static char game_text_Startup_1872[24] = "Checking sound inits.\000Dl";
/* Visible NUL at 28; remaining bytes preserve authored capacity. */
static char game_text_getnames_1896[32] = "Searching for other players.\000S..";
/* Visible NUL at 80; remaining bytes preserve authored capacity. */
static char game_text_main_1928[84] = "                                                                                \000tia";
/* Visible NUL at 32; remaining bytes preserve authored capacity. */
static char game_text_main_2012[36] = "Duke Nukem 3D Full Version v1.3D\000DCh";
/* Visible NUL at 57; remaining bytes preserve authored capacity. */
static char game_text_main_2048[60] = "\n\nYou don't have enough free memory to run Duke Nukem 3D.\000  ";
/* Visible NUL at 54; remaining bytes preserve authored capacity. */
static char game_text_main_2108[56] = "The DOS MEM command should report 6,800K (or 6.8 megs)\000 ";
/* Visible NUL at 20; remaining bytes preserve authored capacity. */
static char game_text_main_2164[24] = "'Total memory free'.\000   ";
/* Visible NUL at 58; remaining bytes preserve authored capacity. */
static char game_text_main_2188[60] = "\nDuke Nukem 3D has been licensed exclusively to TEN (Total\000o";
/* Visible NUL at 64; remaining bytes preserve authored capacity. */
static char game_text_main_2248[68] = "Entertainment Network) for wide-area networked (WAN) multiplayer\000\000\000\000";
/* Visible NUL at 7; remaining bytes preserve authored capacity. */
static char game_text_main_2316[8] = "games.\n\000";
/* Visible NUL at 57; remaining bytes preserve authored capacity. */
static char game_text_main_2324[60] = "The multiplayer code within Duke Nukem 3D has been highly\000ha";
/* Visible NUL at 63; remaining bytes preserve authored capacity. */
static char game_text_main_2384[64] = "customized to run best on TEN, where you'll experience fast and\000";
/* Visible NUL at 49; remaining bytes preserve authored capacity. */
static char game_text_main_2448[52] = "stable performance, plus other special benefits.\n\000\000\000";
/* Visible NUL at 62; remaining bytes preserve authored capacity. */
static char game_text_main_2500[64] = "We do not authorize or recommend the use of Duke Nukem 3D with\000l";
/* Visible NUL at 32; remaining bytes preserve authored capacity. */
static char game_text_main_2564[36] = "gaming services other than TEN.\n\000, w";
/* Visible NUL at 61; remaining bytes preserve authored capacity. */
static char game_text_main_2600[64] = "Duke Nukem 3D is protected by United States copyright law and\000 s";
/* Visible NUL at 22; remaining bytes preserve authored capacity. */
static char game_text_main_2664[24] = "international treaty.\n\000\000";
/* Visible NUL at 66; remaining bytes preserve authored capacity. */
static char game_text_main_2688[68] = "For the best online multiplayer gaming experience, please call TEN\000i";
/* Visible NUL at 57; remaining bytes preserve authored capacity. */
static char game_text_main_2756[60] = "at 800-8040-TEN, or visit TEN's Web Site at www.ten.net.\n\000 b";
/* Visible NUL at 27; remaining bytes preserve authored capacity. */
static char game_text_main_2816[28] = "Press any key to continue.\n\000";
/* Visible NUL at 32; remaining bytes preserve authored capacity. */
static char game_text_main_2844[36] = "Could not find group file '%s'.\n\000the";
/* Visible NUL at 13; remaining bytes preserve authored capacity. */
static char game_text_main_2880[16] = "Using: '%s'.\n\000ul";
/* Visible NUL at 74; remaining bytes preserve authored capacity. */
static char game_text_main_2896[76] = "\n=========================================================================\000s";
/* Visible NUL at 28; remaining bytes preserve authored capacity. */
static char game_text_main_2972[32] = "WARNING: 8250 UART detected.\000Pre";
/* Visible NUL at 75; remaining bytes preserve authored capacity. */
static char game_text_main_3004[76] = "Music is being disabled and lower quality sound is being set.  We apologize\000";
/* Visible NUL at 74; remaining bytes preserve authored capacity. */
static char game_text_main_3080[76] = "for this, but it is necessary to maintain high frame rates while trying to\000=";
/* Visible NUL at 73; remaining bytes preserve authored capacity. */
static char game_text_main_3156[76] = "play the game on an 8250.  We suggest upgrading to a 16550 or better UART\000\000\000";
/* Visible NUL at 52; remaining bytes preserve authored capacity. */
static char game_text_main_3232[56] = "for maximum performance.  Press any key to continue.\000mai";
/* Visible NUL at 74; remaining bytes preserve authored capacity. */
static char game_text_main_3288[76] = "=========================================================================\n\000s";
/* Visible NUL at 19; remaining bytes preserve authored capacity. */
static char game_text_main_3364[20] = "Using .RTS file:%s\n\000";
/* Visible NUL at 24; remaining bytes preserve authored capacity. */
static char game_text_main_3384[28] = "Loading palette/lookups.\000\000\000\000";
/* Visible NUL at 51; remaining bytes preserve authored capacity. */
static char game_text_main_3412[52] = "\nVESA driver for ( %ld * %ld ) not found/supported.\000";
/* Visible NUL at 9; remaining bytes preserve authored capacity. */
static char game_text_opendemoread_3464[12] = "demo_.dmo\000==";
/* Visible NUL at 9; remaining bytes preserve authored capacity. */
static char game_text_opendemowrite_3476[12] = "demo1.dmo\000==";
/* Visible NUL at 2; remaining bytes preserve authored capacity. */
static char game_text_opendemowrite_3488[4] = "wb\000=";
/* Visible NUL at 14; remaining bytes preserve authored capacity. */
static char game_text_domovethings_3492[16] = "%s is history!\000=";
/* Visible NUL at 164; remaining bytes preserve authored capacity. */
static char game_text_domovethings_3508[168] = " \nThe 'MASTER/First player' just quit the game.  All\nplayers are returned from the game. This only happens in 5-8\nplayer mode as a different network scheme is used.\000==w";
/* Visible NUL at 11; remaining bytes preserve authored capacity. */
static char game_text_dobonus_3676[12] = "cineov2.anm\000";
/* Visible NUL at 11; remaining bytes preserve authored capacity. */
static char game_text_dobonus_3688[12] = "cineov3.anm\000";
/* Visible NUL at 11; remaining bytes preserve authored capacity. */
static char game_text_dobonus_3700[12] = "RADLOGO.ANM\000";
/* Visible NUL at 12; remaining bytes preserve authored capacity. */
static char game_text_dobonus_3712[16] = "DUKETEAM.ANM\000st ";
/* Visible NUL at 18; remaining bytes preserve authored capacity. */
static char game_text_dobonus_3728[20] = "MULTIPLAYER TOTALS\000\n";
/* Visible NUL at 25; remaining bytes preserve authored capacity. */
static char game_text_dobonus_3748[28] = "PRESS ANY KEY TO CONTINUE\000\000\000";
/* Visible NUL at 55; remaining bytes preserve authored capacity. */
static char game_text_dobonus_3776[56] = "   NAME                                           KILLS\000";
/* Visible NUL at 5; remaining bytes preserve authored capacity. */
static char game_text_dobonus_3832[8] = "%-4ld\000me";
/* Visible NUL at 25; remaining bytes preserve authored capacity. */
static char game_text_dobonus_3840[28] = "stats %ld killed %ld %ld\n\000in";
/* Visible NUL at 6; remaining bytes preserve authored capacity. */
static char game_text_dobonus_3868[8] = "DEATHS\000m";
/* Visible NUL at 9; remaining bytes preserve authored capacity. */
static char game_text_dobonus_3876[12] = "COMPLETED\000NM";
/* Visible NUL at 10; remaining bytes preserve authored capacity. */
static char game_text_dobonus_3888[12] = "Your Time:\000N";
/* Visible NUL at 9; remaining bytes preserve authored capacity. */
static char game_text_dobonus_3900[12] = "Par time:\000PL";
/* Visible NUL at 16; remaining bytes preserve authored capacity. */
static char game_text_dobonus_3912[20] = "3D Realms' Time:\000S A";
/* Visible NUL at 11; remaining bytes preserve authored capacity. */
static char game_text_dobonus_3932[12] = "%02ld:%02ld\000";
/* Visible NUL at 15; remaining bytes preserve authored capacity. */
static char game_text_dobonus_3944[16] = "Enemies Killed:\000";
/* Visible NUL at 13; remaining bytes preserve authored capacity. */
static char game_text_dobonus_3960[16] = "Enemies Left:\000  ";
/* Visible NUL at 5; remaining bytes preserve authored capacity. */
static char game_text_dobonus_3976[8] = "%-3ld\000  ";
/* Visible NUL at 3; remaining bytes preserve authored capacity. */
static char game_text_dobonus_3984[4] = "N/A\000";
/* Visible NUL at 14; remaining bytes preserve authored capacity. */
static char game_text_dobonus_3988[16] = "Secrets Found:\000 ";
/* Visible NUL at 15; remaining bytes preserve authored capacity. */
static char game_text_dobonus_4004[16] = "Secrets Missed:\000";
/* Visible NUL at 6; remaining bytes preserve authored capacity. */
static char game_text_dobonus_4020[8] = "%-3ld%\000t";
/* Visible NUL at 39; remaining bytes preserve authored capacity. */
static char game_text_CenterCenter_4028[40] = "Center the joystick and press a button\n\000";
/* Visible NUL at 54; remaining bytes preserve authored capacity. */
static char game_text_UpperLeft_4068[56] = "Move joystick to upper-left corner and press a button\n\0000";
/* Visible NUL at 55; remaining bytes preserve authored capacity. */
static char game_text_LowerRight_4124[56] = "Move joystick to lower-right corner and press a button\n\000";
/* Visible NUL at 47; remaining bytes preserve authored capacity. */
static char game_text_CenterThrottle_4180[48] = "Center the throttle control and press a button\n\000";
/* Visible NUL at 45; remaining bytes preserve authored capacity. */
static char game_text_CenterRudder_4228[46] = "Center the rudder control and press a button\n\000";
#pragma data_seg()
