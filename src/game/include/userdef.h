/* SPDX-License-Identifier: GPL-2.0-or-later
 * Restored external user-state declaration from the pinned 3D Realms header.
 * Measured offsets support existing contributor and save/load references.
 * Remaining ancestral fields and the owning GLOBAL module still require
 * verification. This header allocates no storage. player_color is a readable
 * reconstruction name, not an established original developer spelling.
 */
#ifndef DUKE13_USERDEF_H
#define DUKE13_USERDEF_H
#include <stddef.h>
struct user_defs
{
    char god,warp_on,cashman,eog,showallmap;
    char clipping,show_help,scrollmode,over_shoulder_on;
    char user_name[16][32];
    char player_color[16];
    char ridecule[10][40];
    char savegame[10][22];
    char pwlockout[128],rtsname[128];
    char overhead_on,last_overhead,showweapons;

    short pause_on,from_bonus;
    short camerasprite,last_camsprite;
    short multimode,last_level,secretlevel;

    long const_visibility,uw_framerate;
    long camera_time,folfvel,folavel,folx,foly,fola;
    long reccnt;

    long entered_name,screen_tilting,shadows,fta_on,executions,auto_run;
    long coords,tickrate,m_coop,coop,screen_size,lockout,crosshair;

    long respawn_monsters,respawn_items,respawn_inventory,recstat,monsters_off,brightness;
    long m_respawn_items,m_respawn_monsters,m_respawn_inventory,m_recstat,m_monsters_off,detail;
    long m_player_skill,m_level_number,m_volume_number;
    long player_skill,level_number,volume_number,m_marker,marker;

};

typedef char user_declared_extent_check[(sizeof(struct user_defs)==1598)?1:-1];
typedef char user_measured_god_check[(offsetof(struct user_defs,god)==0)?1:-1];
typedef char user_measured_eog_check[(offsetof(struct user_defs,eog)==3)?1:-1];
typedef char user_measured_over_shoulder_on_check[(offsetof(struct user_defs,over_shoulder_on)==8)?1:-1];
typedef char user_measured_user_name_check[(offsetof(struct user_defs,user_name)==9)?1:-1];
typedef char user_measured_player_color_check[(offsetof(struct user_defs,player_color)==521)?1:-1];
typedef char user_measured_ridecule_check[(offsetof(struct user_defs,ridecule)==537)?1:-1];
typedef char user_measured_savegame_check[(offsetof(struct user_defs,savegame)==937)?1:-1];
typedef char user_measured_pwlockout_check[(offsetof(struct user_defs,pwlockout)==1157)?1:-1];
typedef char user_measured_rtsname_check[(offsetof(struct user_defs,rtsname)==1285)?1:-1];
typedef char user_measured_overhead_on_check[(offsetof(struct user_defs,overhead_on)==1413)?1:-1];
typedef char user_measured_last_overhead_check[(offsetof(struct user_defs,last_overhead)==1414)?1:-1];
typedef char user_measured_showweapons_check[(offsetof(struct user_defs,showweapons)==1415)?1:-1];
typedef char user_measured_pause_on_check[(offsetof(struct user_defs,pause_on)==1416)?1:-1];
typedef char user_measured_from_bonus_check[(offsetof(struct user_defs,from_bonus)==1418)?1:-1];
typedef char user_measured_camerasprite_check[(offsetof(struct user_defs,camerasprite)==1420)?1:-1];
typedef char user_measured_last_camsprite_check[(offsetof(struct user_defs,last_camsprite)==1422)?1:-1];
typedef char user_measured_multimode_check[(offsetof(struct user_defs,multimode)==1424)?1:-1];
typedef char user_measured_last_level_check[(offsetof(struct user_defs,last_level)==1426)?1:-1];
typedef char user_measured_secretlevel_check[(offsetof(struct user_defs,secretlevel)==1428)?1:-1];
typedef char user_measured_screen_tilting_check[(offsetof(struct user_defs,screen_tilting)==1470)?1:-1];
typedef char user_measured_shadows_check[(offsetof(struct user_defs,shadows)==1474)?1:-1];
typedef char user_measured_fta_on_check[(offsetof(struct user_defs,fta_on)==1478)?1:-1];
typedef char user_measured_executions_check[(offsetof(struct user_defs,executions)==1482)?1:-1];
typedef char user_measured_auto_run_check[(offsetof(struct user_defs,auto_run)==1486)?1:-1];
typedef char user_measured_screen_size_check[(offsetof(struct user_defs,screen_size)==1506)?1:-1];
typedef char user_measured_lockout_check[(offsetof(struct user_defs,lockout)==1510)?1:-1];
typedef char user_measured_crosshair_check[(offsetof(struct user_defs,crosshair)==1514)?1:-1];
typedef char user_measured_respawn_monsters_check[(offsetof(struct user_defs,respawn_monsters)==1518)?1:-1];
typedef char user_measured_respawn_items_check[(offsetof(struct user_defs,respawn_items)==1522)?1:-1];
typedef char user_measured_respawn_inventory_check[(offsetof(struct user_defs,respawn_inventory)==1526)?1:-1];
typedef char user_measured_monsters_off_check[(offsetof(struct user_defs,monsters_off)==1534)?1:-1];
typedef char user_measured_brightness_check[(offsetof(struct user_defs,brightness)==1538)?1:-1];
typedef char user_measured_detail_check[(offsetof(struct user_defs,detail)==1562)?1:-1];
typedef char user_measured_player_skill_check[(offsetof(struct user_defs,player_skill)==1578)?1:-1];
typedef char user_measured_level_number_check[(offsetof(struct user_defs,level_number)==1582)?1:-1];
typedef char user_measured_volume_number_check[(offsetof(struct user_defs,volume_number)==1586)?1:-1];
typedef char user_measured_m_marker_check[(offsetof(struct user_defs,m_marker)==1590)?1:-1];
typedef char user_measured_marker_check[(offsetof(struct user_defs,marker)==1594)?1:-1];
#endif
