/* SPDX-License-Identifier: GPL-2.0-or-later
   Reconstructed external state declarations. These declarations allocate
   no storage. Unverified fields are not counted as recovered ownership.
   Complete game state types and their owning module remain unfinished. */
#ifndef DUKE13_SOUND_ABI_H
#define DUKE13_SOUND_ABI_H
#include <stddef.h>

#include "userdef.h"

#include "playdef.h"

typedef char player_stride_check[(sizeof(struct player_struct)==1362)?1:-1];
typedef char player_oposx_check[(offsetof(struct player_struct,oposx)==568)?1:-1];
typedef char player_oposy_check[(offsetof(struct player_struct,oposy)==572)?1:-1];
typedef char player_oposz_check[(offsetof(struct player_struct,oposz)==576)?1:-1];
typedef char player_ang_check[(offsetof(struct player_struct,ang)==640)?1:-1];
typedef char player_sector_check[(offsetof(struct player_struct,cursectnum)==646)?1:-1];
typedef char player_look_check[(offsetof(struct player_struct,look_ang)==648)?1:-1];
typedef char player_exit_check[(offsetof(struct player_struct,timebeforeexit)==748)?1:-1];
typedef char player_mode_check[(offsetof(struct player_struct,gm)==1302)?1:-1];
typedef char user_camera_check[(offsetof(struct user_defs,camerasprite)==1420)?1:-1];
typedef char user_lockout_check[(offsetof(struct user_defs,lockout)==1510)?1:-1];
typedef char user_screen_tilting_check[(offsetof(struct user_defs,screen_tilting)==1470)?1:-1];
typedef char user_shadows_check[(offsetof(struct user_defs,shadows)==1474)?1:-1];
typedef char user_detail_check[(offsetof(struct user_defs,detail)==1562)?1:-1];
typedef char user_m_marker_check[(offsetof(struct user_defs,m_marker)==1590)?1:-1];
typedef char user_screen_size_check[(offsetof(struct user_defs,screen_size)==1506)?1:-1];
typedef char user_pwlockout_check[(offsetof(struct user_defs,pwlockout)==1157)?1:-1];
typedef char user_crosshair_check[(offsetof(struct user_defs,crosshair)==1514)?1:-1];
typedef char user_savegame_check[(offsetof(struct user_defs,savegame)==937)?1:-1];
typedef char user_ridecule_check[(offsetof(struct user_defs,ridecule)==537)?1:-1];
typedef char user_rtsname_check[(offsetof(struct user_defs,rtsname)==1285)?1:-1];
typedef char user_fta_on_check[(offsetof(struct user_defs,fta_on)==1478)?1:-1];
typedef char user_brightness_check[(offsetof(struct user_defs,brightness)==1538)?1:-1];
typedef char user_executions_check[(offsetof(struct user_defs,executions)==1482)?1:-1];
typedef char user_auto_run_check[(offsetof(struct user_defs,auto_run)==1486)?1:-1];
#endif
