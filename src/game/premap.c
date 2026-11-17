/* SPDX-License-Identifier: GPL-2.0-or-later
 * Original source: Todd Replogle / 3D Realms. GPL text is in gpl.txt.
 * Duke v1.3D PREMAP reconstruction, derived from 3D Realms code
 * through gamesrc-ver-recreation/duke3d fdb214ceea671341aa03d54d09fb7fe47940d3b7.
 * Complete CODE/CONST and owned BSS pass strict native checks
 * together. Original linking and the complete executable remain unproved.
 * See evidence/premap-source-reference.json and src/game/README.md.
 */
#include "duke3d.h"

/* Original strings and explicit compiler alignment residue; no instructions. */
#pragma data_seg("CONST", "DATA")
static struct {
    char too_many_cyclers[27];
    unsigned char too_many_cyclers_alignment[1];
    char too_many_switches[29];
    unsigned char too_many_switches_alignment[3];
    char too_many_mirrors[28];
    char too_many_animwalls[34];
    unsigned char too_many_animwalls_alignment[2];
    char too_many_players[34];
    unsigned char too_many_players_alignment[2];
    char lookup_name[11];
    unsigned char lookup_name_alignment[1];
    char lookup_error[37];
    unsigned char lookup_error_alignment[3];
    char entering_user_map[18];
    unsigned char entering_user_map_alignment[2];
    char entering_level[9];
    unsigned char entering_level_alignment[3];
    char loading_level[11];
    unsigned char loading_level_alignment[1];
    char map_not_found[18];
    unsigned char map_not_found_alignment[2];
    char exit_space[2];
} premap_text = {
    "\nToo many cycling sectors.",
    {0xfc},
    "\nToo many switches (64 max).",
    {'D', ' ', 'P'},
    "\nToo many mirrors (64 max.)",
    "\nToo many 'anim' walls (max 512.)",
    {'O', 'P'},
    "\nToo many player sprites (max 8.)",
    {'N', ')'},
    "lookup.dat",
    {0x00},
    "\nERROR: File 'LOOKUP.DAT' not found.",
    {' ', 's', 'w'},
    "ENTERING USER MAP",
    {' ', 'P'},
    "ENTERING",
    {' ', 'm', 'i'},
    "LOADING...",
    {'a'},
    "Map %s not found!",
    {'m', 0x27},
    " "
};
#pragma data_seg()


extern char everyothertime;
/* Logical name for the target weapon-to-firing-tile table; owner unproved. */
extern short weapon_tiles[MAX_WEAPONS];


void xyzmirror(short i,short wn)
{
    if (waloff[wn] == 0) loadtile(wn);
	setviewtotile(wn,tilesizy[wn],tilesizx[wn]);

	drawrooms(SX,SY,SZ,SA,100+sprite[i].shade,SECT);
	display_mirror = 1; animatesprites(SX,SY,SA,65536L); display_mirror = 0;
	drawmasks();

	setviewback();
	squarerotatetile(wn);
}

void vscrn(void)
{
     long i, j, ss, x1, x2, y1, y2;

	 if(ud.screen_size < 0) ud.screen_size = 0;
	 else if(ud.screen_size > 63) ud.screen_size = 64;

     if(ud.screen_size == 0) flushperms();

	 ss = max(ud.screen_size-8,0);

	 x1 = scale(ss,xdim,160);
	 x2 = xdim-x1;

	 y1 = ss; y2 = 200;
     if ( ud.screen_size > 0 && ud.coop != 1 && ud.multimode > 1)
	 {
         j = 0;
         for(i=connecthead;i>=0;i=connectpoint2[i])
             if(i > j) j = i;

         if (j >= 1) y1 += 8;
         if (j >= 4) y1 += 8;
         if (j >= 8) y1 += 8;
         if (j >= 12) y1 += 8;
	 }

	 if (ud.screen_size >= 8) y2 -= (ss+34);

	 y1 = scale(y1,ydim,200);
	 y2 = scale(y2,ydim,200);

	 setview(x1,y1,x2-1,y2-1);

     pub = NUMPAGES;
     pus = NUMPAGES;
}

void pickrandomspot(short snum)
{
    struct player_struct *p;
    short i;

    p = &ps[snum];

    if(ud.multimode > 1)
    {
        if(ud.coop != 1) i = TRAND%numplayersprites;
        else i = 0;
    }
    else i = snum;

    p->bobposx = p->oposx = p->posx = po[i].ox;
    p->bobposy = p->oposy = p->posy = po[i].oy;
    p->oposz = p->posz = po[i].oz;
    p->ang = po[i].oa;
    p->cursectnum = po[i].os;
}

void resetplayerstats(short snum)
{
    struct player_struct *p;
    short i;

    p = &ps[snum];

    ud.show_help       = 0;
    ud.showallmap       = 0;
    if(ud.last_level == -1 || ud.recstat == 2) p->level_reset_flag = 0;
    p->dead_flag        = 0;
    p->wackedbyactor    = -1;
    p->falling_counter  = 0;
    p->quick_kick       = 0;
    p->last_full_weapon = 0;
    p->ftq              = 0;
    p->fta              = 0;
    p->tipincs          = 0;
    p->buttonpalette    = 0;
    p->actorsqu         =-1;
    p->invdisptime      = 0;
    p->refresh_inventory= 0;
    p->last_pissed_time = 0;
    p->holster_weapon   = 0;
    p->pycount          = 0;
    p->pyoff            = 0;
    p->opyoff           = 0;
    p->loogcnt          = 0;
    p->angvel           = 0;
    p->weapon_sway      = 0;
//    p->select_dir       = 0;
    p->extra_extra8     = 0;
    p->show_empty_weapon= 0;
    p->dummyplayersprite=-1;
    p->crack_time       = 0;
    p->hbomb_hold_delay = 0;
    p->transporter_hold = 0;
    p->hurt_delay       = 0;
    p->footprintcount   = 0;
    p->footprintpal     = 0;
    p->footprintshade   = 0;
    p->jumping_toggle   = 0;
    p->ohoriz = p->horiz= 140;
    p->horizoff         = 0;
    p->bobcounter       = 0;
    p->on_ground        = 0;
    p->player_par       = 0;
    p->return_to_center = 9;
    p->airleft          = 15*26;
    p->rapid_fire_hold  = 0;
    p->toggle_key_flag  = 0;
    p->access_spritenum = -1;
    if(ud.multimode > 1 && ud.coop != 1 )
        p->got_access = 7;
    else p->got_access      = 0;
    p->random_club_frame= 0;
    pus = 1;
    p->on_warping_sector = 0;
    p->spritebridge      = 0;
    p->palette = (char *) &palette[0];

    if(p->steroids_amount < 400 )
    {
        p->steroids_amount = 0;
        p->inven_icon = 0;
    }
    p->heat_on =            0;
    p->jetpack_on =         0;
    p->holoduke_on =       -1;

    p->look_ang          = 512 - ((ud.level_number&1)<<10);

    p->rotscrnang        = 0;
    p->newowner          =-1;
    p->jumping_counter   = 0;
    p->hard_landing      = 0;
    p->posxv             = 0;
    p->posyv             = 0;
    p->poszv             = 0;
    fricxv            = 0;
    fricyv            = 0;
    p->somethingonplayer =-1;
    p->one_eighty_count  = 0;
    p->cheat_phase       = 0;

    p->on_crane          = -1;

    if(weapon_tiles[p->curr_weapon] == SHOTSPARK1)
        p->kickback_pic  = 5;
    else p->kickback_pic = 0;

    p->weapon_pos        = 6;
    p->walking_snd_toggle= 0;
    p->weapon_ang        = 0;

    p->knuckle_incs      = 1;
    p->fist_incs = 0;
    p->knee_incs         = 0;
    p->jetpack_on        = 0;
    setpal(p);
}



void resetweapons(short snum)
{
    short  weapon;
    struct player_struct *p;

    p = &ps[snum];

    for ( weapon = PISTOL_WEAPON; weapon < MAX_WEAPONS; weapon++ )
        p->gotweapon[weapon] = 0;
    for ( weapon = PISTOL_WEAPON; weapon < MAX_WEAPONS; weapon++ )
        p->ammo_amount[weapon] = 0;

    p->weapon_pos = 6;
    p->kickback_pic = 5;
    p->curr_weapon = PISTOL_WEAPON;
    p->gotweapon[PISTOL_WEAPON] = 1;
    p->gotweapon[KNEE_WEAPON] = 1;
    p->ammo_amount[PISTOL_WEAPON] = 48;
    p->gotweapon[HANDREMOTE_WEAPON] = 1;
    p->last_weapon = -1;

    p->show_empty_weapon= 0;
    p->last_pissed_time = 0;
    p->holster_weapon = 0;
#ifdef WW2
   OnEvent(EVENT_RESETWEAPONS, -1, snum, -1);
#endif
}

void resetinventory(short snum)
{
    struct player_struct *p;
    short i;

    p = &ps[snum];

    p->inven_icon       = 0;
    p->boot_amount = 0;
    p->scuba_on =           0;p->scuba_amount =         0;
    p->heat_amount        = 0;p->heat_on = 0;
    p->jetpack_on =         0;p->jetpack_amount =       0;
    p->shield_amount =      max_armour_amount;
    p->holoduke_on = -1;
    p->holoduke_amount =    0;
    p->firstaid_amount = 0;
    p->steroids_amount = 0;
    p->inven_icon = 0;
#ifdef WW2
   OnEvent(EVENT_RESETINVENTORY, -1, snum, -1);
#endif
}


void resetprestat(short snum,char g)
{
    struct player_struct *p;
    short i;

    p = &ps[snum];

    spriteqloc = 0;
    for(i=0;i<64;i++) spriteq[i] = -1;

    p->hbomb_on          = 0;
    p->cheat_phase       = 0;
    p->pals_time         = 0;
    p->toggle_key_flag   = 0;
    p->secret_rooms      = 0;
    p->max_secret_rooms  = 0;
    p->actors_killed     = 0;
    p->max_actors_killed = 0;
    p->lastrandomspot = 0;
    p->weapon_pos = 6;
    p->kickback_pic = 5;
    p->last_weapon = -1;
    p->weapreccnt = 0;
    p->show_empty_weapon= 0;
    p->holster_weapon = 0;
    p->last_pissed_time = 0;

    p->one_parallax_sectnum = -1;
    p->visibility = ud.const_visibility;

    screenpeek              = myconnectindex;
    numanimwalls            = 0;
    numcyclers              = 0;
    animatecnt              = 0;
    parallaxtype            = 0;
    randomseed              = 17L;
    ud.pause_on             = 0;
    ud.camerasprite         =-1;
    ud.eog                  = 0;
    tempwallptr             = 0;
    camsprite               =-1;
    earthquaketime          = 0;

    numinterpolations = 0;
    startofdynamicinterpolations = 0;

    if( ( (g&MODE_EOL) != MODE_EOL && numplayers < 2) || (ud.coop != 1 && numplayers > 1) )
    {
        resetweapons(snum);
        resetinventory(snum);
    }
    else if(p->curr_weapon == HANDREMOTE_WEAPON)
    {
        p->ammo_amount[HANDBOMB_WEAPON]++;
        p->curr_weapon = HANDBOMB_WEAPON;
    }

    p->timebeforeexit   = 0;
    p->customexitsound  = 0;

}

void setupbackdrop(short sky)
{
    short i, skytype = 0;

    for(i=0;i<8;i++) pskyoff[i]=0;

    switch(sky)
    {
        case MOONSKY1: case BIGORBIT1: case LA: skytype = sky; break;
    }
    parallaxyscale = 32768;

    switch(skytype)
    {
        case MOONSKY1 :
            pskyoff[6]=1; pskyoff[1]=2; pskyoff[4]=2; pskyoff[2]=3;
            break;
        case BIGORBIT1: // orbit
            pskyoff[5]=1; pskyoff[6]=2; pskyoff[7]=3; pskyoff[2]=4;
            break;
        case LA:
            parallaxyscale = 16384+1024;
            pskyoff[0]=1; pskyoff[1]=2; pskyoff[2]=1; pskyoff[3]=3;
            pskyoff[4]=4; pskyoff[5]=0; pskyoff[6]=2; pskyoff[7]=3;
            break;
   }

   pskybits=3;
}

void cachespritenum(short i)
{
    char maxc;
    short j;

    if(ud.monsters_off && badguy(&sprite[i])) return;

    maxc = 1;

    switch(PN)
    {
        case HYDRENT:
            loadtile(BROKEFIREHYDRENT);
            for(j = TOILETWATER; j < (TOILETWATER+4); j++)
                if(waloff[j] == 0) loadtile(j);
            break;
        case TOILET:
            loadtile(TOILETBROKE);
            for(j = TOILETWATER; j < (TOILETWATER+4); j++)
                if(waloff[j] == 0) loadtile(j);
            break;
        case STALL:
            loadtile(STALLBROKE);
            for(j = TOILETWATER; j < (TOILETWATER+4); j++)
                if(waloff[j] == 0) loadtile(j);
            break;
        case RUBBERCAN:
            maxc = 2;
            break;
        case TOILETWATER:
            maxc = 4;
            break;
        case FEMPIC1:
            maxc = 44;
            break;
        case LIZTROOP:
        case LIZTROOPRUNNING:
        case LIZTROOPSHOOT:
        case LIZTROOPJETPACK:
        case LIZTROOPONTOILET:
        case LIZTROOPDUCKING:
            for(j = LIZTROOP; j < (LIZTROOP+72); j++)
                if(waloff[j] == 0)
                    loadtile(j);
            for(j=HEADJIB1;j<LEGJIB1+3;j++)
                if(waloff[j] == 0)
                    loadtile(j);
            maxc = 0;
            break;
        case WOODENHORSE:
            maxc = 5;
            for(j = HORSEONSIDE; j < (HORSEONSIDE+4); j++)
                if(waloff[j] == 0)
                    loadtile(j);
            break;
        case BOSS1:
        case BOSS2:
        case BOSS3:
            maxc = 30;
            break;
        case OCTABRAIN:
        case OCTABRAINSTAYPUT:
        case COMMANDER:
        case COMMANDERSTAYPUT:
            maxc = 38;
            break;
        case RECON:
            maxc = 13;
            break;
        case PIGCOP:
        case PIGCOPDIVE:
            maxc = 61;
            break;
        case SHARK:
            maxc = 30;
            break;
        case LIZMAN:
        case LIZMANSPITTING:
        case LIZMANFEEDING:
        case LIZMANJUMP:
            for(j=LIZMANHEAD1;j<LIZMANLEG1+3;j++)
                if(waloff[j] == 0)
                    loadtile(j);
            maxc = 80;
            break;
        case APLAYER:
            maxc = 0;
            if(ud.multimode > 1)
            {
                maxc = 5;
                for(j = 1420;j < 1420+106; j++)
#if (APPVER_DN3DREV < AV_DR_DN3D15)
                    if(waloff[j] == -1)
#else
                    if(waloff[j] == 0)
#endif
                        loadtile(j);
            }
            break;
        case ATOMICHEALTH:
            maxc = 14;
            break;
        case DRONE:
            maxc = 10;
            break;
        case EXPLODINGBARREL:
        case SEENINE:
        case OOZFILTER:
            maxc = 3;
            break;
        case NUKEBARREL:
        case CAMERA1:
            maxc = 5;
            break;
    }

    for(j = PN; j < (PN+maxc); j++)
        if(waloff[j] == 0)
            loadtile(j);
}

void cachegoodsprites(void)
{
    short i;

    if(ud.screen_size >= 8)
    {
        if(waloff[BOTTOMSTATUSBAR] == 0)
            loadtile(BOTTOMSTATUSBAR);
        if( ud.multimode > 1)
        {
            if(waloff[FRAGBAR] == 0)
                loadtile(FRAGBAR);
            for(i=MINIFONT;i<MINIFONT+63;i++)
                if(waloff[i] == 0)
                    loadtile(i);
        }
    }

    loadtile(VIEWSCREEN);

    for(i=STARTALPHANUM;i<ENDALPHANUM+1;i++)
        if (waloff[i] == 0)
            loadtile(i);

    for(i=FOOTPRINTS;i<FOOTPRINTS+3;i++)
        if (waloff[i] == 0)
            loadtile(i);

    for( i = BIGALPHANUM; i < BIGALPHANUM+82; i++)
        if(waloff[i] == 0)
            loadtile(i);

    for( i = BURNING; i < BURNING+14; i++)
        if(waloff[i] == 0)
            loadtile(i);

    for( i = BURNING2; i < BURNING2+14; i++)
        if(waloff[i] == 0)
            loadtile(i);

    for( i = CRACKKNUCKLES; i < CRACKKNUCKLES+4; i++)
        if(waloff[i] == 0)
            loadtile(i);

    for( i = FIRSTGUN; i < FIRSTGUN+3 ; i++ )
        if(waloff[i] == 0)
            loadtile(i);

    for( i = EXPLOSION2; i < EXPLOSION2+21 ; i++ )
        if(waloff[i] == 0)
            loadtile(i);

    loadtile(BULLETHOLE);

    for( i = FIRSTGUNRELOAD; i < FIRSTGUNRELOAD+8 ; i++ )
        if(waloff[i] == 0)
            loadtile(i);

    loadtile(FOOTPRINTS);

    for( i = JIBS1; i < (JIBS5+5); i++)
        if(waloff[i] == 0)
            loadtile(i);

    for( i = SCRAP1; i < (SCRAP1+19); i++)
        if(waloff[i] == 0)
            loadtile(i);

    for( i = SMALLSMOKE; i < (SMALLSMOKE+4); i++)
        if(waloff[i] == 0)
            loadtile(i);
}


void prelevel(char g)
{
    short i, nexti, j, startwall, endwall, lotaglist;
    short lotags[65];


    for(i=0;i<(MAXSECTORS>>3);i++) show2dsector[i] = 0;
    for(i=0;i<(MAXWALLS>>3);i++) show2dwall[i] = 0;
    for(i=0;i<(MAXSPRITES>>3);i++) show2dsprite[i] = 0;

    resetprestat(0,g);

    for(i=0;i<numsectors;i++)
    {
        sector[i].extra = 256;

        switch(sector[i].lotag)
        {
            case 20:
            case 22:
                if( sector[i].floorz > sector[i].ceilingz)
                    sector[i].lotag |= 32768;
                continue;
        }

        if(sector[i].ceilingstat&1)
        {
            if(waloff[sector[i].ceilingpicnum] == 0)
            {
                if(sector[i].ceilingpicnum == LA)
                    for(j=0;j<5;j++)
                        if(waloff[sector[i].ceilingpicnum+j] == 0)
                            loadtile(sector[i].ceilingpicnum+j);
            }
            setupbackdrop(sector[i].ceilingpicnum);

            if(ps[0].one_parallax_sectnum == -1)
                ps[0].one_parallax_sectnum = i;
        }

        if(sector[i].lotag == 32767) //Found a secret room
        {
            ps[0].max_secret_rooms++;
            continue;
        }

        if(sector[i].lotag == -1)
        {
            ps[0].exitx = wall[sector[i].wallptr].x;
            ps[0].exity = wall[sector[i].wallptr].y;
            continue;
        }
    }

    i = headspritestat[0];
    while(i >= 0)
    {
        nexti = nextspritestat[i];

#if (APPVER_DN3DREV >= AV_DR_EDK20021)
		LoadActor(i, -1, -1);
#endif

        if(sprite[i].lotag == -1 && (sprite[i].cstat&16) )
        {
            ps[0].exitx = SX;
            ps[0].exity = SY;
        }
        else switch(PN)
        {
            case GPSPEED:
                sector[SECT].extra = SLT;
                deletesprite(i);
                break;

            case CYCLER:
                if(numcyclers >= MAXCYCLERS)
                    gameexit(premap_text.too_many_cyclers);
                cyclers[numcyclers][0] = SECT;
                cyclers[numcyclers][1] = SLT;
                cyclers[numcyclers][2] = SS;
                cyclers[numcyclers][3] = sector[SECT].floorshade;
                cyclers[numcyclers][4] = SHT;
                cyclers[numcyclers][5] = (SA == 1536);
                numcyclers++;
                deletesprite(i);
                break;
        }
        i = nexti;
    }

    for(i=0;i < MAXSPRITES;i++)
    {
        if(sprite[i].statnum < MAXSTATUS)
        {
            if(PN == SECTOREFFECTOR && SLT == 14)
                continue;
            spawn(-1,i);
        }
    }

    for(i=0;i < MAXSPRITES;i++)
        if(sprite[i].statnum < MAXSTATUS)
        {
            if( PN == SECTOREFFECTOR && SLT == 14 )
                spawn(-1,i);
        }

    lotaglist = 0;

    i = headspritestat[0];
    while(i >= 0)
    {
        switch(PN)
        {
            case DIPSWITCH:
            case DIPSWITCH2:
            case ACCESSSWITCH:
            case PULLSWITCH:
            case HANDSWITCH:
            case SLOTDOOR:
            case LIGHTSWITCH:
            case SPACELIGHTSWITCH:
            case SPACEDOORSWITCH:
            case FRANKENSTINESWITCH:
            case LIGHTSWITCH2:
            case POWERSWITCH1:
            case LOCKSWITCH1:
            case POWERSWITCH2:
                break;
            case DIPSWITCH+1:
            case DIPSWITCH2+1:
            case PULLSWITCH+1:
            case HANDSWITCH+1:
            case SLOTDOOR+1:
            case LIGHTSWITCH+1:
            case SPACELIGHTSWITCH+1:
            case SPACEDOORSWITCH+1:
            case FRANKENSTINESWITCH+1:
            case LIGHTSWITCH2+1:
            case POWERSWITCH1+1:
            case LOCKSWITCH1+1:
            case POWERSWITCH2+1:
                for(j=0;j<lotaglist;j++)
                    if( SLT == lotags[j] )
                        break;

                if( j == lotaglist )
                {
                    lotags[lotaglist] = SLT;
                    lotaglist++;
                    if(lotaglist > 64)
                        gameexit(premap_text.too_many_switches);

                    j = headspritestat[3];
                    while(j >= 0)
                    {
                        if(sprite[j].lotag == 12 && sprite[j].hitag == SLT)
                            hittype[j].temp_data[0] = 1;
                        j = nextspritestat[j];
                    }
                }
                break;
        }
        i = nextspritestat[i];
    }

    mirrorcnt = 0;

    for( i = 0; i < numwalls; i++ )
    {
        walltype *wal;
        wal = &wall[i];

        if(wal->overpicnum == MIRROR && (wal->cstat&32) != 0)
        {
            j = wal->nextsector;

            if(mirrorcnt > 63)
                gameexit(premap_text.too_many_mirrors);
            if ( (j >= 0) && sector[j].ceilingpicnum != MIRROR )
            {
                sector[j].ceilingpicnum = MIRROR;
                sector[j].floorpicnum = MIRROR;
                mirrorwall[mirrorcnt] = i;
                mirrorsector[mirrorcnt] = j;
                mirrorcnt++;
                continue;
            }
        }

        if(numanimwalls >= MAXANIMWALLS)
            gameexit(premap_text.too_many_animwalls);

        animwall[numanimwalls].tag = 0;
        animwall[numanimwalls].wallnum = 0;

        switch(wal->overpicnum)
        {
            case FANSHADOW:
            case FANSPRITE:
                wall->cstat |= 65;
                animwall[numanimwalls].wallnum = i;
                numanimwalls++;
                break;

            case W_FORCEFIELD:
                if(waloff[W_FORCEFIELD] == 0)
                    for(j=0;j<3;j++)
                        loadtile(W_FORCEFIELD+j);
            case W_FORCEFIELD+1:
            case W_FORCEFIELD+2:
                if(wal->shade > 31)
                    wal->cstat = 0;
                else wal->cstat |= 85+256;


                if(wal->lotag && wal->nextwall >= 0)
                    wall[wal->nextwall].lotag =
                        wal->lotag;

            case BIGFORCE:

                animwall[numanimwalls].wallnum = i;
                numanimwalls++;

                continue;
        }

        wal->extra = -1;

        switch(wal->picnum)
        {
            case WATERTILE2:
                for(j=0;j<3;j++)
                    if(waloff[wal->picnum+j] == 0)
                        loadtile(wal->picnum+j);
                break;

            case TECHLIGHT2:
            case TECHLIGHT4:
                if(waloff[wal->picnum] == 0)
                    loadtile(wal->picnum);
                break;
            case W_TECHWALL1:
            case W_TECHWALL2:
            case W_TECHWALL3:
            case W_TECHWALL4:
                animwall[numanimwalls].wallnum = i;
//                animwall[numanimwalls].tag = -1;
                numanimwalls++;
                break;
            case SCREENBREAK6:
            case SCREENBREAK7:
            case SCREENBREAK8:
                if(waloff[SCREENBREAK6] == 0)
                    for(j=SCREENBREAK6;j<SCREENBREAK9;j++)
                        loadtile(j);
                animwall[numanimwalls].wallnum = i;
                animwall[numanimwalls].tag = -1;
                numanimwalls++;
                break;

            case FEMPIC1:
            case FEMPIC2:
            case FEMPIC3:

                wal->extra = wal->picnum;
                animwall[numanimwalls].tag = -1;
                if(ud.lockout)
                {
                    if(wal->picnum == FEMPIC1)
                        wal->picnum = BLANKSCREEN;
                    else wal->picnum = SCREENBREAK6;
                }

                animwall[numanimwalls].wallnum = i;
                animwall[numanimwalls].tag = wal->picnum;
                numanimwalls++;
                break;

            case SCREENBREAK1:
            case SCREENBREAK2:
            case SCREENBREAK3:
            case SCREENBREAK4:
            case SCREENBREAK5:

            case SCREENBREAK9:
            case SCREENBREAK10:
            case SCREENBREAK11:
            case SCREENBREAK12:
            case SCREENBREAK13:

                animwall[numanimwalls].wallnum = i;
                animwall[numanimwalls].tag = wal->picnum;
                numanimwalls++;
                break;
        }
    }

    //Invalidate textures in sector behind mirror
    for(i=0;i<mirrorcnt;i++)
    {
        startwall = sector[mirrorsector[i]].wallptr;
        endwall = startwall + sector[mirrorsector[i]].wallnum;
        for(j=startwall;j<endwall;j++)
        {
            wall[j].picnum = MIRROR;
            wall[j].overpicnum = MIRROR;
        }
    }
}


void newgame(char vn,char ln,char sk)
{
    struct player_struct *p = &ps[0];
    short i;

    ready2send = 0;

    if( ud.m_recstat != 2 && ud.last_level >= 0 && ud.multimode > 1 && ud.coop != 1)
        dobonus(1);

    show_shareware = 26*34;

    ud.level_number =   ln;
    ud.volume_number =  vn;
    ud.player_skill =   sk;
    ud.secretlevel =    0;
    ud.from_bonus = 0;

    ud.last_level = -1;
    if(ud.multimode < 2) p->level_reset_flag = 0;
    p->zoom            = 768;
    p->gm              = 0;

#ifdef WW2
{
	int j;
//AddLog("Newgame");
	ResetGameVars();

	InitGameVarPointers();

	ResetSystemDefaults();

    if(ud.m_coop != 1)
    {
		for(i=0;i<MAX_WEAPONS;i++)
		{
			if(aplWeaponWorksLike[i][0]==PISTOL_WEAPON)
			{
				p->curr_weapon = i;
				p->gotweapon[i] = 1;
				p->ammo_amount[i] = 48;

			}
			else if(aplWeaponWorksLike[i][0]==KNEE_WEAPON)
			{
				p->gotweapon[i] = 1;
			}
			else if(aplWeaponWorksLike[i][0]==HANDREMOTE_WEAPON)
			{
				p->gotweapon[i] = 1;
			}
		}
        p->last_weapon = -1;
    }
}
#else
    if(ud.m_coop != 1)
    {
        p->curr_weapon = PISTOL_WEAPON;
        p->gotweapon[PISTOL_WEAPON] = 1;
        p->gotweapon[KNEE_WEAPON] = 1;
        p->ammo_amount[PISTOL_WEAPON] = 48;
        p->gotweapon[HANDREMOTE_WEAPON] = 1;
        p->last_weapon = -1;
    }
#endif

    display_mirror =        0;

    if(ud.multimode > 1 )
    {
        if(numplayers < 2)
        {
            connecthead = 0;
            for(i=0;i<MAXPLAYERS;i++) connectpoint2[i] = i+1;
            connectpoint2[ud.multimode-1] = -1;
        }
    }
    else
    {
        connecthead = 0;
        connectpoint2[0] = -1;
    }
}


void resetpspritevars(char g)
{
    short i, j, nexti,circ,which_palookup;
    /* Earlier aiming state at byte1332; existing field name is provisional. */
    char aimmode[MAXPLAYERS];
    long firstx,firsty;
    spritetype *s;
    STATUSBARTYPE tsbar[MAXPLAYERS];

    EGS(ps[0].cursectnum,ps[0].posx,ps[0].posy,ps[0].posz,
        APLAYER,0,0,0,ps[0].ang,0,0,0,10);

    if(ud.recstat != 2) for(i=0;i<MAXPLAYERS;i++)
    {
        aimmode[i] = ps[i].level_reset_flag;
        if(ud.multimode > 1 && ud.coop == 1 && ud.last_level >= 0)
        {
            for(j=0;j<MAX_WEAPONS;j++)
            {
                tsbar[i].ammo_amount[j] = ps[i].ammo_amount[j];
                tsbar[i].gotweapon[j] = ps[i].gotweapon[j];
            }

            tsbar[i].shield_amount = ps[i].shield_amount;
            tsbar[i].curr_weapon = ps[i].curr_weapon;
            tsbar[i].inven_icon = ps[i].inven_icon;

            tsbar[i].firstaid_amount = ps[i].firstaid_amount;
            tsbar[i].steroids_amount = ps[i].steroids_amount;
            tsbar[i].holoduke_amount = ps[i].holoduke_amount;
            tsbar[i].jetpack_amount = ps[i].jetpack_amount;
            tsbar[i].heat_amount = ps[i].heat_amount;
            tsbar[i].scuba_amount = ps[i].scuba_amount;
            tsbar[i].boot_amount = ps[i].boot_amount;
        }
    }

    resetplayerstats(0);

    for(i=1;i<MAXPLAYERS;i++)
       memcpy(&ps[i],&ps[0],sizeof(ps[0]));

    if(ud.recstat != 2) for(i=0;i<MAXPLAYERS;i++)
    {
        ps[i].level_reset_flag = aimmode[i];
        if(ud.multimode > 1 && ud.coop == 1 && ud.last_level >= 0)
        {
            for(j=0;j<MAX_WEAPONS;j++)
            {
                ps[i].ammo_amount[j] = tsbar[i].ammo_amount[j];
                ps[i].gotweapon[j] = tsbar[i].gotweapon[j];
            }
            ps[i].shield_amount = tsbar[i].shield_amount;
            ps[i].curr_weapon = tsbar[i].curr_weapon;
            ps[i].inven_icon = tsbar[i].inven_icon;

            ps[i].firstaid_amount = tsbar[i].firstaid_amount;
            ps[i].steroids_amount= tsbar[i].steroids_amount;
            ps[i].holoduke_amount = tsbar[i].holoduke_amount;
            ps[i].jetpack_amount = tsbar[i].jetpack_amount;
            ps[i].heat_amount = tsbar[i].heat_amount;
            ps[i].scuba_amount= tsbar[i].scuba_amount;
            ps[i].boot_amount = tsbar[i].boot_amount;
        }
    }

    numplayersprites = 0;
    circ = 2048/ud.multimode;

    which_palookup = 9;
    j = connecthead;
    i = headspritestat[10];	// 10 == players...
    while(i >= 0)
    {
        nexti = nextspritestat[i];
        s = &sprite[i];

        if( numplayersprites == MAXPLAYERS)
            gameexit(premap_text.too_many_players);

        if(numplayersprites == 0)
        {
            firstx = ps[0].posx;
            firsty = ps[0].posy;
        }

        po[numplayersprites].ox = s->x;
        po[numplayersprites].oy = s->y;
        po[numplayersprites].oz = s->z;
        po[numplayersprites].oa = s->ang;
        po[numplayersprites].os = s->sectnum;

        numplayersprites++;
        if(j >= 0)
        {
            s->owner = i;
            s->shade = 0;
            s->xrepeat = 42;
            s->yrepeat = 36;
            s->cstat = 1+256;
            s->xoffset = 0;
            s->clipdist = 64;

            if( (g&MODE_EOL) != MODE_EOL || ps[j].last_extra == 0)
            {
                ps[j].last_extra = max_player_health;
                s->extra = max_player_health;
            }
            else s->extra = ps[j].last_extra;

            s->yvel = j;

            if(ud.last_level == -1)
            {
                ps[j].palookup = which_palookup; s->pal = which_palookup; ud.player_color[j] = which_palookup++;
                if( which_palookup == 17 ) which_palookup = 9;
            }
            else s->pal = ps[j].palookup = ud.player_color[j];

            ps[j].i = i;
            ps[j].frag_ps = j;
            hittype[i].owner = i;

            hittype[i].bposx = ps[j].bobposx = ps[j].oposx = ps[j].posx =        s->x;
            hittype[i].bposy = ps[j].bobposy = ps[j].oposy = ps[j].posy =        s->y;
            hittype[i].bposz = ps[j].oposz = ps[j].posz =        s->z;
            ps[j].oang  = ps[j].ang  =        s->ang;

            updatesector(s->x,s->y,&ps[j].cursectnum);

            j = connectpoint2[j];

        }
        else deletesprite(i);
        i = nexti;
    }
}

void resettimevars(void)
{
    short i;
    vel = svel = angvel = horiz = 0;
    syncvaltail = 0L;
    syncvaltottail = 0L;
    syncstat = 0;
    bufferjitter = 1;
    mymaxlag = otherminlag = 0;
    clearbufbyte(myminlag,MAXPLAYERS<<2,0L);
    clearbufbyte(&loc,sizeof(input),0L);
    for(i=0;i<MAXPLAYERS;i++)
    {
        clearbufbyte(&sync[i],sizeof(input),0L);
        ps[i].frag = ps[i].fraggedself = 0;
        syncvalhead[i] = 0;
    }
    clearbufbyte(&frags[0][0],(MAXPLAYERS*MAXPLAYERS)<<1,0L);
    totalclock = 0L;
    ototalclock = 0L;
    lockclock = 0L;
    ready2send = 1;
}

void genspriteremaps(void)
{
    long j,fp;
    signed char look_pos;
    char *lookfn = premap_text.lookup_name;
    char numl;

    fp = kopen4load(lookfn,loadfromgrouponly);
    if(fp != -1)
        kread(fp,(char *)&numl,1);
    else
        gameexit(premap_text.lookup_error);

    for(j=0;j < numl;j++)
    {
        kread(fp,(signed char *)&look_pos,1);
        kread(fp,tempbuf,256);
        makepalookup((long)look_pos,tempbuf,0,0,0,1);
    }

    kread(fp,&waterpal[0],768);
    kread(fp,&slimepal[0],768);
    kread(fp,&titlepal[0],768);
    kread(fp,&drealms[0],768);
    kread(fp,&endingpal[0],768);

    palette[765] = palette[766] = palette[767] = 0;
    slimepal[765] = slimepal[766] = slimepal[767] = 0;
    waterpal[765] = waterpal[766] = waterpal[767] = 0;

    kclose(fp);
}

/* Provisional name for the real byte owned here and shared with GAME. */
char wait_abort;

void waitforeverybody(void)
{
    long i,j,t;
    if(numplayers < 2) return;
    wait_abort = 0;
    if(myconnectindex == connecthead)
    {
        for(j=1;j<=2;j++)
        {
            for(i=connectpoint2[connecthead];i>=0;i=connectpoint2[i]) playerreadyflag[i] = 0;
            t = totalclock-(movesperpacket<<3);
            do
            {
                if(KB_KeyPressed(sc_Escape)) {wait_abort=1; return;}
                getpackets();
                if(totalclock >= t+(movesperpacket<<3))
                {
                    t = totalclock;
                    packbuf[1] = j;
                    packbuf[0] = 250;
                    for(i=connectpoint2[connecthead];i>=0;i=connectpoint2[i])
                        if(playerreadyflag[i] != j) sendpacket(i,packbuf,2);
                }
                for(i=connectpoint2[connecthead];i>=0;i=connectpoint2[i])
                    if(playerreadyflag[i] != j) break;
            } while(i >= 0);
        }
    }
    else
    {
        playerreadyflag[connecthead] = 0;
        while(playerreadyflag[connecthead] < 2)
        {
            if(KB_KeyPressed(sc_Escape)) {wait_abort=1; return;}
            getpackets();
        }
    }
}

/* Logical names for the packet-9 comparison; callers/ownership unproved. */
extern volatile long received_sync_value;
char compare_network_value(long value)
{
    long t = totalclock,i;
    tempbuf[0] = 9;
    tempbuf[1] = value;
    tempbuf[2] = (value&0xff00)>>8;
    tempbuf[3] = (value&0xff0000)>>16;
    tempbuf[4] = (value&0x7f000000)>>24;
    if(connectpoint2[myconnectindex] < 0) i = connecthead;
    else i = connectpoint2[myconnectindex];
    sendpacket(i,tempbuf,5);
    received_sync_value = -1;
    while(received_sync_value == -1)
    {
        if(totalclock >= t)
        {
            getpackets();
            t = totalclock+8;
        }
    }
    return value != received_sync_value;
}

char getsound(unsigned short num)
{
    short fp;
    long   l;

    if(num >= NUM_SOUNDS || SoundToggle == 0) return 0;
    if (FXDevice == NumSoundCards) return 0;

    fp = kopen4load(sounds[num],loadfromgrouponly);
    if(fp == -1) return 0;

    l = kfilelength( fp );
    soundsiz[num] = l;

    if( (ud.level_number == 0 && ud.volume_number == 0 && (num == 189 || num == 232 || num == 99 || num == 233 || num == 17 ) ) ||
#if (APPVER_DN3DREV < AV_DR_DN3DGPLSRC)
        ( l < 12800 ) )
#else
        ( l < 12288 ) )
#endif
    {
#if (APPVER_DN3DREV < AV_DR_DN3D15)
        Sound[num].lock = 2;
#else
        Sound[num].lock = 199;
#endif
        allocache((long *)&Sound[num].ptr,l,&Sound[num].lock);
        if(Sound[num].ptr != NULL)
            kread( fp, Sound[num].ptr , l);
    }
    kclose( fp );
    return 1;
}

void precachenecessarysounds(void)
{
#if (APPVER_DN3DREV < AV_DR_DN3DGPLSRC)
    short i;
#else
    short i, j;
#endif

    if (FXDevice == NumSoundCards) return;
#if (APPVER_DN3DREV >= AV_DR_DN3DGPLSRC)
    j = 0;
#endif

    for(i=0;i<NUM_SOUNDS;i++)
        if(Sound[i].ptr == 0)
#if (APPVER_DN3DREV >= AV_DR_DN3DGPLSRC)
        {
            j++;
            if( (j&7) == 0 )
                getpackets();
#endif
            getsound(i);
#if (APPVER_DN3DREV >= AV_DR_DN3DGPLSRC)
        }
#endif
}


void cacheit(void)
{
    short i,j;

    precachenecessarysounds();

    cachegoodsprites();

    for(i=0;i<numwalls;i++)
        if( waloff[wall[i].picnum] == 0 )
    {
        if(waloff[wall[i].picnum] == 0)
            loadtile(wall[i].picnum);
        if(wall[i].overpicnum >= 0 && waloff[wall[i].overpicnum] == 0 )
            loadtile(wall[i].overpicnum);
    }

    for(i=0;i<numsectors;i++)
    {
        if( waloff[sector[i].floorpicnum] == 0 )
            loadtile( sector[i].floorpicnum );
        if( waloff[sector[i].ceilingpicnum] == 0 )
        {
            loadtile( sector[i].ceilingpicnum );
            if( waloff[sector[i].ceilingpicnum] == LA)
            {
                loadtile(LA+1);
                loadtile(LA+2);
            }
        }

        j = headspritesect[i];
        while(j >= 0)
        {
            if(sprite[j].xrepeat != 0 && sprite[j].yrepeat != 0 && (sprite[j].cstat&32768) == 0)
                if(waloff[sprite[j].picnum] == 0)
                    cachespritenum(j);
            j = nextspritesect[j];
        }
    }
}


void dofrontscreens(void)
{
    long tincs,i,j;

    if(ud.recstat != 2)
    {
        ps[myconnectindex].palette = palette;
        for(j=0;j<63;j+=7) palto(0,0,0,j);
        i = ud.screen_size;
        ud.screen_size = 0;
        vscrn();
        clearview(0L);

#ifdef WW2
		SetGameVarID(g_iReturnVarID,LOADSCREEN, -1, -1);
		OnEvent(EVENT_GETLOADTILE, -1, -1, -1);
		rotatesprite(320<<15,200<<15,65536L,0,GetGameVarID(g_iReturnVarID, -1, -1),0,0,2+8+64,0,0,xdim-1,ydim-1);
#else
		rotatesprite(320<<15,200<<15,65536L,0,LOADSCREEN,0,0,2+8+64,0,0,xdim-1,ydim-1);
#endif

        if( boardfilename[0] != 0 && ud.level_number == 7 && ud.volume_number == 0 )
        {
            menutext(160,90,0,0,premap_text.entering_user_map);
            menutext(160,90+16+8,0,0,boardfilename);
        }
        else
        {
            menutext(160,90,0,0,premap_text.entering_level);
            menutext(160,90+16+8,0,0,level_names[(ud.volume_number*11) + ud.level_number]);
        }

        nextpage();

        for(j=63;j>0;j-=7) palto(0,0,0,j);

        KB_FlushKeyboardQueue();
        ud.screen_size = i;
    }
    else
    {
        clearview(0L);
        ps[myconnectindex].palette = palette;
        palto(0,0,0,0);
        rotatesprite(320<<15,200<<15,65536L,0,LOADSCREEN,0,0,2+8+64,0,0,xdim-1,ydim-1);
        menutext(160,105,0,0,premap_text.loading_level);
        nextpage();
    }
}

void enterlevel(char g)
{
    short i,j;
    long l;
    char levname[256];

    if( (g&MODE_DEMO) != MODE_DEMO ) ud.recstat = ud.m_recstat;
    ud.respawn_monsters = ud.m_respawn_monsters;
    ud.respawn_items    = ud.m_respawn_items;
    ud.respawn_inventory    = ud.m_respawn_inventory;
    ud.monsters_off = ud.m_monsters_off;
    ud.coop = ud.m_coop;
    ud.marker = ud.m_marker;

#ifdef WW2
//sprintf(g_szBuf,"ENTERLEVEL L=%d V=%d",ud.level_number, ud.volume_number);
//AddLog(g_szBuf);
	 // variables are set by pointer...
    OnEvent(EVENT_ENTERLEVEL, -1, -1, -1);
#endif
    if( (g&MODE_DEMO) == 0 && ud.recstat == 2)
        ud.recstat = 0;

#if (APPVER_DN3DREV >= AV_DR_DN3DGPLSRC) // VERSIONS RESTORATION - Relocated from 1.4
    FX_StopAllSounds();
    clearsoundlocks();
    FX_SetReverb(0);
#endif

    i = ud.screen_size;
    ud.screen_size = 0;
    dofrontscreens();
    vscrn();
    ud.screen_size = i;

    if(ud.recstat != 2)
    {
        MUSIC_StopSong();
        music_select = (ud.volume_number*11) + ud.level_number;
        playmusic(&music_fn[0][music_select][0]);
    }


#ifndef VOLUMEONE

    if( boardfilename[0] != 0 && ud.m_level_number == 7 && ud.m_volume_number == 0 )
    {
        if ( loadboard( boardfilename,&ps[0].posx, &ps[0].posy, &ps[0].posz, &ps[0].ang,&ps[0].cursectnum ) == -1 )
        {
            sprintf(tempbuf,premap_text.map_not_found,boardfilename);
            gameexit(tempbuf);
        }
    }
    else if ( loadboard( level_file_names[ (ud.volume_number*11)+ud.level_number],&ps[0].posx, &ps[0].posy, &ps[0].posz, &ps[0].ang,&ps[0].cursectnum ) == -1)
    {
        sprintf(tempbuf,premap_text.map_not_found,level_file_names[(ud.volume_number*11)+ud.level_number]);
        gameexit(tempbuf);
    }

#else

    l = strlen(level_file_names[ (ud.volume_number*11)+ud.level_number]);
    copybufbyte( level_file_names[ (ud.volume_number*11)+ud.level_number],&levname[0],l);
    levname[l] = 255;
    levname[l+1] = 0;

    if ( loadboard( levname,&ps[0].posx, &ps[0].posy, &ps[0].posz, &ps[0].ang,&ps[0].cursectnum ) == -1)
    {
        sprintf(tempbuf,premap_text.map_not_found,level_file_names[(ud.volume_number*11)+ud.level_number]);
        gameexit(tempbuf);
    }
#endif

    FX_StopAllSounds();
    clearsoundlocks();
    FX_SetReverb(0);

    prelevel(g);

    allignwarpelevators();
    resetpspritevars(g);

    cachedebug = 0;
    automapping = 0;
    cacheit();

    if( (g&MODE_GAME) || (g&MODE_EOL) )
        ps[myconnectindex].gm = MODE_GAME;
    else if(g&MODE_RESTART)
    {
        if(ud.recstat == 2)
            ps[myconnectindex].gm = MODE_DEMO;
        else ps[myconnectindex].gm = MODE_GAME;
    }

    if( (ud.recstat == 1) && (g&MODE_RESTART) != MODE_RESTART )
        opendemowrite();

#ifdef VOLUMEONE
    if(ud.level_number == 0 && ud.recstat != 2) FTA(40,&ps[myconnectindex]);
#endif

    for(i=connecthead;i>=0;i=connectpoint2[i])
        switch(sector[sprite[ps[i].i].sectnum].floorpicnum)
        {
            case HURTRAIL:
            case FLOORSLIME:
            case FLOORPLASMA:
                resetweapons(i);
                resetinventory(i);
                ps[i].gotweapon[PISTOL_WEAPON] = 0;
                ps[i].ammo_amount[PISTOL_WEAPON] = 0;
                ps[i].curr_weapon = KNEE_WEAPON;
                ps[i].kickback_pic = 0;
                break;
        }

     /* Restore local prediction state before resuming play. */


      myx = omyx = ps[myconnectindex].posx;
      myy = omyy = ps[myconnectindex].posy;
      myz = omyz = ps[myconnectindex].posz;
      myxvel = myyvel = myzvel = 0;
      myang = omyang = ps[myconnectindex].ang;
      myhoriz = omyhoriz = ps[myconnectindex].horiz;
      myhorizoff = omyhorizoff = ps[myconnectindex].horizoff;
      mycursectnum = ps[myconnectindex].cursectnum;
      myjumpingcounter = ps[myconnectindex].jumping_counter;
      myjumpingtoggle = ps[myconnectindex].jumping_toggle;
      myonground = ps[myconnectindex].on_ground;
      myhardlanding = ps[myconnectindex].hard_landing;
      myreturntocenter = ps[myconnectindex].return_to_center;


     ps[myconnectindex].palette = palette;
     palto(0,0,0,0);

     setpal(&ps[myconnectindex]);
     flushperms();

     everyothertime = 0;
     global_random = 0;

     ud.last_level = ud.level_number+1;

     for(i=connecthead;i>=0;i=connectpoint2[i]) myminlag[i] = 0;
     /* Preserve the period compiler's grouping of FIFO and lag resets. */
     fakemovefifoplc = otherminlag = mymaxlag = 0;
     movefifoplc = movefifosendplc = 0;
     clearbufbyte(inputfifo,sizeof(input)*MOVEFIFOSIZ*MAXPLAYERS,0L);
     clearbuf(movefifoend,MAXPLAYERS,0L);
     avgfvel = avgsvel = avgavel = avghorz = avgbits = 0;

     for(i=numinterpolations-1;i>=0;i--) bakipos[i] = *curipos[i];

     restorepalette = 1;

     flushpackets();
     waitforeverybody();

     palto(0,0,0,0);
     vscrn();
     clearview(0L);
     nextpage();
#if (APPVER_DN3DREV >= AV_DR_DN3D15)
     displayrooms(myconnectindex,65536);
#endif

     clearbufbyte(playerquitflag,MAXPLAYERS,0x01010101);
     if(wait_abort == 1) gameexit(premap_text.exit_space);
     resettimevars();
     ps[myconnectindex].over_shoulder_on = 0;
}

/*
Duke Nukem V

Layout:

      Settings:
        Suburbs
          Duke inflitrating neighborhoods inf. by aliens
        Death Valley:
          Sorta like a western.  Bull-skulls halb buried in the sand
          Military compound:  Aliens take over nuke-missle silo, duke
            must destroy.
          Abondend Aircraft field
        Vegas:
          Blast anything bright!  Alien lights camoflauged.
          Alien Drug factory. The Blue Liquid
        Mountainal Cave:
          Interior cave battles.
        Jungle:
          Trees, canopee, animals, a mysterious hole in the earth
        Penetencury:
          Good use of spotlights:
      Inventory:
        Wood,
        Metal,
        Torch,
        Rope,
        Plastique,
        Cloth,
        Wiring,
        Glue,
        Cigars,
        Food,
        Duck Tape,
        Nails,
        Piping,
        Petrol,
        Uranium,
        Gold,
        Prism,
        Power Cell,

        Hand spikes (Limited usage, they become dull)
        Oxygent     (Oxygen mixed with stimulant)


      Player Skills:
        R-Left,R-Right,Foward,Back
        Strafe, Jump, Double Flip Jump for distance
        Help, Escape
        Fire/Use
        Use Menu

Programming:
     Images: Polys
     Actors:
       Multi-Object sections for change (head,arms,legs,torsoe,all change)
       Facial expressions.  Pal lookup per poly?

     struct imagetype
        {
            int *itable; // AngX,AngY,AngZ,Xoff,Yoff,Zoff;
            int *idata;
            struct imagetype *prev, *next;
        }

*/
