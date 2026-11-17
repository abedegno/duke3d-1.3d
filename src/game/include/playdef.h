/* SPDX-License-Identifier: GPL-2.0-or-later
 * Restored external player declaration from the pinned 3D Realms header.
 * The stride, sound-used offsets and palette-lookup offset have target checks.
 * Other ancestral fields and inferred array extents require the remaining
 * game modules to verify them. This header allocates no storage and does not
 * establish ownership of the player array. See player-declaration.json.
 */
#ifndef DUKE13_PLAYDEF_H
#define DUKE13_PLAYDEF_H
#include <stddef.h>
struct player_struct
{
    long zoom,exitx,exity,loogiex[64],loogiey[64],numloogs,loogcnt;
    long posx, posy, posz, horiz, ohoriz, ohorizoff, invdisptime;
    long bobposx,bobposy,oposx,oposy,oposz,pyoff,opyoff;
    long posxv,posyv,poszv,last_pissed_time,truefz,truecz;
    long player_par,visibility;
    long bobcounter,weapon_sway;
    long pals_time,randomflamex,crack_time;



    short ang,oang,angvel,cursectnum,look_ang,last_extra;
    short ammo_amount[11],wackedbyactor,frag,fraggedself;

    short curr_weapon, last_weapon, tipincs, horizoff;
    short holoduke_amount,newowner,hurt_delay,hbomb_hold_delay;
    short jumping_counter,airleft,knee_incs,access_incs;
    short fta,ftq,access_wallnum,access_spritenum;
    short kickback_pic,got_access,weapon_ang,firstaid_amount;
    short somethingonplayer,on_crane,i,one_parallax_sectnum;
    short over_shoulder_on,random_club_frame,fist_incs;
    short one_eighty_count,cheat_phase;
    short dummyplayersprite,extra_extra8,quick_kick;
    short heat_amount,actorsqu,timebeforeexit,customexitsound;

    short weaprecs[256],weapreccnt,interface_toggle_flag;

    short rotscrnang,dead_flag,show_empty_weapon;
    short scuba_amount,jetpack_amount,steroids_amount,shield_amount;
    short holoduke_on,pycount,weapon_pos,frag_ps;
    short transporter_hold,last_full_weapon,footprintshade,boot_amount;
	// transporter_hold if >0, is the time that the player can't move.
	// last_pissed_time is the time since the player last pissed...
	//   used as count-down to getting health from toilet

    int scream_voice;

    char gm,on_warping_sector,footprintcount;
    char hbomb_on,jumping_toggle,rapid_fire_hold,on_ground;
    char name[13],inven_icon,buttonpalette;

    char jetpack_on,spritebridge,lastrandomspot;
    char scuba_on,footprintpal,heat_on;

    char  holster_weapon,falling_counter;
    /* Provisional name: conditionally cleared during level/player reset. */
    char  level_reset_flag,gotweapon[11],refresh_inventory,*palette;

    char toggle_key_flag,knuckle_incs; // ,select_dir;
    char walking_snd_toggle, palookup, hard_landing;
    char max_secret_rooms,secret_rooms,/*fire_flag,*/pals[3];
    char max_actors_killed,actors_killed,return_to_center;

};

typedef char restored_player_extent_check[(sizeof(struct player_struct)==1362)?1:-1];
#endif
