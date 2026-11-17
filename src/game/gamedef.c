/* SPDX-License-Identifier: GPL-2.0-or-later
 * Original source: Todd Replogle / 3D Realms. See gpl.txt.
 * Derived through gamesrc-ver-recreation/duke3d
 * fdb214ceea671341aa03d54d09fb7fe47940d3b7, GAMEDEF.C.
 * Recovered v1.3D contribution: all native CODE, initialized data, BSS and
 * relocations match. Linking, the complete executable and humanization remain
 * unfinished. See evidence/gamedef-source-reference.json.
 * Static identifier choices do not establish original variable spelling.
 */
#include "duke3d.h"



extern short otherp;

static char *last_used_end;
static short total_script_lines;
static char checking_ifelse,parsing_state,*last_used_text;
static short line_number;
static long last_used_size;
static short g_p,num_squigilly_brackets;
static long g_x;
static long *g_t;
static spritetype *g_sp;
static short g_i;
#define NUMKEYWORDS		99

/* Strings from the C source; explicit alignment residue is not executable code. */
#pragma data_seg("CONST", "DATA")
static struct {
    char text_0[16];
    char text_1[6];
    unsigned char pad_1[2];
    char text_2[8];
    char text_3[6];
    unsigned char pad_3[2];
    char text_4[5];
    unsigned char pad_4[3];
    char text_5[9];
    unsigned char pad_5[3];
    char text_6[12];
    char text_7[7];
    unsigned char pad_7[1];
    char text_8[9];
    unsigned char pad_8[3];
    char text_9[9];
    unsigned char pad_9[3];
    char text_10[5];
    unsigned char pad_10[3];
    char text_11[9];
    unsigned char pad_11[3];
    char text_12[6];
    unsigned char pad_12[2];
    char text_13[6];
    unsigned char pad_13[2];
    char text_14[8];
    char text_15[6];
    unsigned char pad_15[2];
    char text_16[5];
    unsigned char pad_16[3];
    char text_17[6];
    unsigned char pad_17[2];
    char text_18[5];
    unsigned char pad_18[3];
    char text_19[7];
    unsigned char pad_19[1];
    char text_20[3];
    unsigned char pad_20[1];
    char text_21[5];
    unsigned char pad_21[3];
    char text_22[7];
    unsigned char pad_22[1];
    char text_23[10];
    unsigned char pad_23[2];
    char text_24[3];
    unsigned char pad_24[1];
    char text_25[11];
    unsigned char pad_25[1];
    char text_26[7];
    unsigned char pad_26[1];
    char text_27[11];
    unsigned char pad_27[1];
    char text_28[7];
    unsigned char pad_28[1];
    char text_29[2];
    unsigned char pad_29[2];
    char text_30[2];
    unsigned char pad_30[2];
    char text_31[6];
    unsigned char pad_31[2];
    char text_32[5];
    unsigned char pad_32[3];
    char text_33[12];
    char text_34[9];
    unsigned char pad_34[3];
    char text_35[14];
    unsigned char pad_35[2];
    char text_36[17];
    unsigned char pad_36[3];
    char text_37[7];
    unsigned char pad_37[1];
    char text_38[7];
    unsigned char pad_38[1];
    char text_39[3];
    unsigned char pad_39[1];
    char text_40[6];
    unsigned char pad_40[2];
    char text_41[7];
    unsigned char pad_41[1];
    char text_42[12];
    char text_43[10];
    unsigned char pad_43[2];
    char text_44[10];
    unsigned char pad_44[2];
    char text_45[17];
    unsigned char pad_45[3];
    char text_46[8];
    char text_47[11];
    unsigned char pad_47[1];
    char text_48[13];
    unsigned char pad_48[3];
    char text_49[18];
    unsigned char pad_49[2];
    char text_50[10];
    unsigned char pad_50[2];
    char text_51[4];
    char text_52[6];
    unsigned char pad_52[2];
    char text_53[8];
    char text_54[6];
    unsigned char pad_54[2];
    char text_55[8];
    char text_56[11];
    unsigned char pad_56[1];
    char text_57[12];
    char text_58[5];
    unsigned char pad_58[3];
    char text_59[12];
    char text_60[12];
    char text_61[11];
    unsigned char pad_61[1];
    char text_62[8];
    char text_63[11];
    unsigned char pad_63[1];
    char text_64[10];
    unsigned char pad_64[2];
    char text_65[14];
    unsigned char pad_65[2];
    char text_66[8];
    char text_67[10];
    unsigned char pad_67[2];
    char text_68[6];
    unsigned char pad_68[2];
    char text_69[10];
    unsigned char pad_69[2];
    char text_70[13];
    unsigned char pad_70[3];
    char text_71[10];
    unsigned char pad_71[2];
    char text_72[13];
    unsigned char pad_72[3];
    char text_73[15];
    unsigned char pad_73[1];
    char text_74[10];
    unsigned char pad_74[2];
    char text_75[13];
    unsigned char pad_75[3];
    char text_76[9];
    unsigned char pad_76[3];
    char text_77[7];
    unsigned char pad_77[1];
    char text_78[11];
    unsigned char pad_78[1];
    char text_79[12];
    char text_80[6];
    unsigned char pad_80[2];
    char text_81[15];
    unsigned char pad_81[1];
    char text_82[12];
    char text_83[13];
    unsigned char pad_83[3];
    char text_84[4];
    char text_85[12];
    char text_86[6];
    unsigned char pad_86[2];
    char text_87[10];
    unsigned char pad_87[2];
    char text_88[9];
    unsigned char pad_88[3];
    char text_89[10];
    unsigned char pad_89[2];
    char text_90[15];
    unsigned char pad_90[1];
    char text_91[15];
    unsigned char pad_91[1];
    char text_92[12];
    char text_93[12];
    char text_94[14];
    unsigned char pad_94[2];
    char text_95[11];
    unsigned char pad_95[1];
    char text_96[6];
    unsigned char pad_96[2];
    char text_97[8];
    char text_98[54];
    unsigned char pad_98[2];
    char text_99[45];
    unsigned char pad_99[3];
    char text_100[47];
    unsigned char pad_100[1];
    char text_101[43];
    unsigned char pad_101[1];
    char text_102[45];
    unsigned char pad_102[3];
    char text_103[40];
    char text_104[48];
    char text_105[57];
    unsigned char pad_105[3];
    char text_106[57];
    unsigned char pad_106[3];
    char text_107[45];
    unsigned char pad_107[3];
    char text_108[55];
    unsigned char pad_108[1];
    char text_109[45];
    unsigned char pad_109[3];
    char text_110[49];
    unsigned char pad_110[3];
    char text_111[39];
    unsigned char pad_111[1];
    char text_112[18];
    unsigned char pad_112[2];
    char text_113[45];
    unsigned char pad_113[3];
    char text_114[47];
    unsigned char pad_114[1];
    char text_115[45];
    unsigned char pad_115[3];
    char text_116[51];
    unsigned char pad_116[1];
    char text_117[48];
    char text_118[48];
    char text_119[56];
    char text_120[43];
    unsigned char pad_120[1];
    char text_121[70];
    unsigned char pad_121[2];
    char text_122[65];
    unsigned char pad_122[3];
    char text_123[64];
    char text_124[60];
    char text_125[51];
    unsigned char pad_125[1];
    char text_126[66];
    unsigned char pad_126[2];
    char text_127[57];
    unsigned char pad_127[3];
    char text_128[57];
    unsigned char pad_128[3];
    char text_129[40];
    char text_130[22];
    unsigned char pad_130[2];
    char text_131[18];
    unsigned char pad_131[2];
    char text_132[37];
    unsigned char pad_132[3];
    char text_133[75];
    unsigned char pad_133[1];
    char text_134[58];
    unsigned char pad_134[2];
    char text_135[25];
    unsigned char pad_135[3];
    char text_136[2];
    unsigned char pad_136[2];
    char text_137[5];
    unsigned char pad_137[3];
    char text_138[1];
    unsigned char pad_138[3];
    char text_139[14];
    unsigned char pad_139[2];
    char text_140[66];
    unsigned char pad_140[2];
    char text_141[58];
    unsigned char pad_141[2];
    char text_142[25];
    unsigned char pad_142[3];
    char text_143[34];
    unsigned char pad_143[2];
    char text_144[5];
} gamedef_text = {
    "definelevelname",
    "actor",
    {0x0, 0xfc},
    "addammo",
    "ifrnd",
    {0x0, 0xfc},
    "enda",
    {0x9, 0x0, 0xfc},
    "ifcansee",
    {0x69, 0x74, 0x61},
    "ifhitweapon",
    "action",
    {0x74},
    "ifpdistl",
    {0x65, 0x72, 0x20},
    "ifpdistg",
    {0x72, 0x20, 0x63},
    "else",
    {0x6c, 0x20, 0x61},
    "strength",
    {0x61, 0x20, 0x62},
    "break",
    {0x0, 0x70},
    "shoot",
    {0x74, 0x20},
    "palfrom",
    "sound",
    {0x73, 0x73},
    "fall",
    {0x74, 0x74, 0x6f},
    "state",
    {0x0, 0x0},
    "ends",
    {0x65, 0x6c, 0x65},
    "define",
    {0x0},
    "//",
    {0x6f},
    "ifai",
    {0x64, 0x64, 0x61},
    "killit",
    {0x6e},
    "addweapon",
    {0x0, 0xfc},
    "ai",
    {0x61},
    "addphealth",
    {0x69},
    "ifdead",
    {0x0},
    "ifsquished",
    {0x64},
    "sizeto",
    {0x20},
    "{",
    {0x70, 0x64},
    "}",
    {0x74, 0x67},
    "spawn",
    {0x73, 0x65},
    "move",
    {0x74, 0x72, 0x65},
    "ifwasweapon",
    "ifaction",
    {0x0, 0x74, 0x20},
    "ifactioncount",
    {0x73, 0x73},
    "resetactioncount",
    {0x0, 0x0, 0x0},
    "debris",
    {0x65},
    "pstomp",
    {0x0},
    "/*",
    {0x6f},
    "cstat",
    {0x64, 0x61},
    "ifmove",
    {0x6e},
    "resetplayer",
    "ifonwater",
    {0x61, 0x6c},
    "ifinwater",
    {0x0, 0x0},
    "ifcanshoottarget",
    {0x6f, 0x0, 0x20},
    "ifcount",
    "resetcount",
    {0x65},
    "addinventory",
    {0x6f, 0x6e, 0x0},
    "ifactornotstayput",
    {0x6f, 0x6e},
    "hitradius",
    {0x73, 0x65},
    "ifp",
    "count",
    {0x0, 0x0},
    "ifactor",
    "music",
    {0x0, 0x0},
    "include",
    "ifstrength",
    {0x6e},
    "definesound",
    "guts",
    {0x61, 0x74, 0x65},
    "ifspawnedby",
    "gamestartup",
    "wackplayer",
    {0x20},
    "ifgapzl",
    "ifhitspace",
    {0x65},
    "ifoutside",
    {0x72, 0x79},
    "ifmultiplayer",
    {0x73, 0x74},
    "operate",
    "ifinspace",
    {0x73, 0x65},
    "debug",
    {0x75, 0x6e},
    "endofgame",
    {0x0, 0x0},
    "ifbulletnear",
    {0x0, 0x0, 0x0},
    "ifrespawn",
    {0x73, 0x74},
    "iffloordistl",
    {0x65, 0x73, 0x6f},
    "ifceilingdistl",
    {0x70},
    "spritepal",
    {0x6d, 0x65},
    "ifpinventory",
    {0x6c, 0x61, 0x79},
    "betaname",
    {0x7a, 0x6c, 0x0},
    "cactor",
    {0x61},
    "ifphealthl",
    {0x64},
    "definequote",
    "quote",
    {0x73, 0x74},
    "ifinouterspace",
    {0x63},
    "ifnotmoving",
    "respawnhitag",
    {0x0, 0x0, 0x0},
    "tip",
    "ifspritepal",
    "money",
    {0x61, 0x77},
    "soundonce",
    {0x72, 0x64},
    "addkills",
    {0x66, 0x63, 0x65},
    "stopsound",
    {0x0, 0x70},
    "ifawayfromwall",
    {0x69},
    "ifcanseetarget",
    {0x61},
    "globalsound",
    "lotsofglass",
    "ifgotweaponce",
    {0x65, 0x0},
    "getlastpal",
    {0x6e},
    "pkick",
    {0x70, 0x61},
    "mikesnd",
    "  * ERROR!(L%ld) Expecting key word, but found '%s'.\n",
    {0x6e, 0x64},
    "  * ERROR!(L%ld) Symbol '%s' is a key word.\n",
    {0x0, 0x69, 0x69},
    "  * ERROR!(L%ld) Parameter '%s' is undefined.\n",
    {0x70},
    "  * ERROR!(L%ld) Found '/*' with no '*/'.\n",
    {0x52},
    "  * ERROR!(L%ld) Symbol '%s' is a key word.\n",
    {0x6e, 0x64, 0x20},
    "  * ERROR!(L%ld) State '%s' not found.\n",
    "  * ERROR!(L%ld) Found 'ends' with no 'state'.\n",
    "  * ERROR!(L%ld) Found more '{' than '}' before 'ends'.\n",
    {0x0, 0x0, 0x0},
    "  * ERROR!(L%ld) Found more '}' than '{' before 'ends'.\n",
    {0x20, 0x6e, 0x6f},
    "  * ERROR!(L%ld) Symbol '%s' is a key word.\n",
    {0x6e, 0x6f, 0x20},
    "  * WARNING.(L%ld) Duplicate definition '%s' ignored.\n",
    {0x72},
    "  * ERROR!(L%ld) Symbol '%s' is a key word.\n",
    {0x20, 0x6d, 0x6f},
    "  * WARNING.(L%ld) Duplicate move '%s' ignored.\n",
    {0x64, 0x29, 0x20},
    "  * ERROR!(L%ld) Could not find '%s'.\n",
    {0x49},
    "Including: '%s'.\n",
    {0x65, 0x20},
    "  * ERROR!(L%ld) Symbol '%s' is a key word.\n",
    {0x0, 0x0, 0x0},
    "  * WARNING.(L%ld) Duplicate ai '%s' ignored.\n",
    {0x6c},
    "  * ERROR!(L%ld) Symbol '%s' is a key word.\n",
    {0x20, 0x43, 0x6f},
    "  * WARNING.(L%ld) Duplicate action '%s' ignored.\n",
    {0x28},
    "  * ERROR!(L%ld) Found 'actor' within 'state'.\n",
    "  * ERROR!(L%ld) Found 'actor' within 'actor'.\n",
    "  * WARNING.(L%ld) Found 'else' with no 'if', ignored.\n",
    "  * ERROR!(L%ld) Found more '}' than '{'.\n",
    {0x6f},
    "  * ERROR!(L%ld) Level file name exceeds character size limit of 13.\n",
    {0x77, 0x69},
    "  * ERROR!(L%ld) Level name exceeds character size limit of 32.\n",
    {0x72, 0x65, 0x64},
    "  * ERROR!(L%ld) Quote amount exceeds limit of %ld characters.\n",
    "  * ERROR!(L%ld) Quote exceeds character size limit of 64.\n",
    "  * ERROR!(L%ld) Exceeded sound limit of %ld %ld.\n",
    {0x20},
    "  * ERROR!(L%ld) Sound filename exceeded limit of 13 characters.\n",
    {0x0, 0x0},
    "  * ERROR!(L%ld) Found 'enda' without defining 'actor'.\n",
    {0x2e, 0xa, 0x0},
    "  * ERROR!(L%ld) Found more '{' than '}' before 'enda'.\n",
    {0x52, 0x52, 0x4f},
    "  * ERROR! Too many warnings or errors.",
    "\nMissing con file(s).",
    {0x0, 0x0},
    "Compiling: '%s'.\n",
    {0x6f, 0x75},
    "Found %ld warning(s), %ld error(s).\n",
    {0x2e, 0xa, 0x0},
    "\nWarnings found in %s file.  You should backup the original copies before\n",
    {0x6d},
    "before attempting to modify them.  Do you want to use the",
    {0x6e, 0x67},
    "INTERNAL DEFAULTS (y/N)?",
    {0x69, 0x6e, 0x67},
    "\n",
    {0x29, 0x2c},
    " Yes",
    {0x65, 0x72, 0x72},
    "",
    {0x72, 0x28, 0x73},
    "\nError in %s.",
    {0x67, 0x73},
    "\nErrors found in %s file.  You should backup the original copies\n",
    {0x6d, 0x62},
    "before attempting to modify them.  Do you want to use the",
    {0x67, 0x49},
    "internal defaults (Y/N)?",
    {0x6e, 0x67, 0xa},
    "Code Size:%ld bytes(%ld labels).\n",
    {0x72, 0x6f},
    "%ld\n",
};
#pragma data_seg()

char *keyw[NUMKEYWORDS] =
{
	gamedef_text.text_0,	// 0
	gamedef_text.text_1,			// 1	[#]
	gamedef_text.text_2,	 // 2	 [#]
	gamedef_text.text_3,			// 3	[C]
	gamedef_text.text_4,				// 4	[:]
	gamedef_text.text_5,			// 5	[C]
	gamedef_text.text_6,		// 6	[#]
	gamedef_text.text_7,			// 7	[#]
	gamedef_text.text_8,			// 8	[#]
	gamedef_text.text_9,			// 9	[#]
	gamedef_text.text_10,				// 10	[#]
	gamedef_text.text_11,			// 11	[#]
	gamedef_text.text_12,			// 12	[#]
	gamedef_text.text_13,			// 13	[#]
	gamedef_text.text_14,			// 14	[#]
	gamedef_text.text_15,			// 15	[filename.voc]
	gamedef_text.text_16,				// 16	[]
	gamedef_text.text_17,			// 17
	gamedef_text.text_18,				// 18
	gamedef_text.text_19,			// 19
	gamedef_text.text_20,				// 20
	gamedef_text.text_21,				// 21
	gamedef_text.text_22,			// 22
	gamedef_text.text_23,		// 23
	gamedef_text.text_24,				// 24
	gamedef_text.text_25,		// 25
	gamedef_text.text_26,			// 26
	gamedef_text.text_27,		// 27
	gamedef_text.text_28,			// 28
	gamedef_text.text_29,				// 29
	gamedef_text.text_30,				// 30
	gamedef_text.text_31,			// 31
	gamedef_text.text_32,				// 32
	gamedef_text.text_33,		// 33
	gamedef_text.text_34,			// 34
	gamedef_text.text_35,	// 35
	gamedef_text.text_36, // 36
	gamedef_text.text_37,			// 37
	gamedef_text.text_38,			// 38
	gamedef_text.text_39,				// 39
	gamedef_text.text_40,			// 40
	gamedef_text.text_41,			// 41
	gamedef_text.text_42,		// 42
	gamedef_text.text_43,		// 43
	gamedef_text.text_44,		// 44
	gamedef_text.text_45, // 45
	gamedef_text.text_46,			// 46
	gamedef_text.text_47,		// 47
	gamedef_text.text_48,		// 48
	gamedef_text.text_49,// 49
	gamedef_text.text_50,		// 50
	gamedef_text.text_51,				// 51
	gamedef_text.text_52,			// 52
	gamedef_text.text_53,			// 53
	gamedef_text.text_54,			// 54
	gamedef_text.text_55,			// 55
	gamedef_text.text_56,		// 56
	gamedef_text.text_57,		// 57
	gamedef_text.text_58,				// 58
	gamedef_text.text_59,		// 59
	gamedef_text.text_60,		// 60
	gamedef_text.text_61,		// 61
	gamedef_text.text_62,			// 62
	gamedef_text.text_63,		// 63
	gamedef_text.text_64,		// 64
	gamedef_text.text_65,	// 65
	gamedef_text.text_66,			// 66
	gamedef_text.text_67,		// 67
	gamedef_text.text_68,			// 68
	gamedef_text.text_69,		// 69
	gamedef_text.text_70,		// 70
	gamedef_text.text_71,		// 71
	gamedef_text.text_72,		// 72
	gamedef_text.text_73,	// 73
	gamedef_text.text_74,		// 74
	gamedef_text.text_75,		// 75
	gamedef_text.text_76,			// 76
	gamedef_text.text_77,			// 77
	gamedef_text.text_78,		// 78
	gamedef_text.text_79,		// 79
	gamedef_text.text_80,			// 80
	gamedef_text.text_81,	// 81
	gamedef_text.text_82,		// 82
	gamedef_text.text_83,		   // 83
	gamedef_text.text_84,			   // 84
	gamedef_text.text_85,		// 85
	gamedef_text.text_86,		 // 86
	gamedef_text.text_87,		 // 87
	gamedef_text.text_88,			// 88
	gamedef_text.text_89,		// 89
	gamedef_text.text_90,		// 90
	gamedef_text.text_91,	// 91
	gamedef_text.text_92,	// 92
	gamedef_text.text_93, // 93
	gamedef_text.text_94, // 94
	gamedef_text.text_95, // 95
	gamedef_text.text_96,  // 96
	gamedef_text.text_97, // 97
	gamedef_text.text_68,  // 98

};


short getincangle(short a,short na)
{
	a &= 2047;
	na &= 2047;

	if(klabs(a-na) < 1024)
		return (na-a);
	else
	{
		if(na > 1024) na -= 2048;
		if(a > 1024) a -= 2048;

		na -= 2048;
		a -= 2048;
		return (na-a);
	}
}

char ispecial(char c)
{
	if(c == 0x0a)
	{
		line_number++;
		return 1;
	}

	if(c == ' ' || c == 0x0d)
		return 1;

	return 0;
}

char isaltok(char c)
{
	return ( isalnum(c) || c == '{' || c == '}' || c == '/' || c == '*' || c == '-' || c == '_' || c == '.');
}

void getglobalz(short i)
{
	long hz,lz,zr;

	spritetype *s = &sprite[i];

	if( s->statnum == 10 || s->statnum == 6 || s->statnum == 2 || s->statnum == 1 || s->statnum == 4)
	{
		if(s->statnum == 4)
			zr = 4L;
		else zr = 127L;

		getzrange(s->x,s->y,s->z-(FOURSLEIGHT),s->sectnum,&hittype[i].ceilingz,&hz,&hittype[i].floorz,&lz,zr,CLIPMASK0);

		if( (lz&49152) == 49152 && (sprite[lz&(MAXSPRITES-1)].cstat&48) == 0 )
		{
			lz &= (MAXSPRITES-1);
			if( badguy(&sprite[lz]) && sprite[lz].pal != 1)
			{
				if( s->statnum != 4 )
				{
					hittype[i].dispicnum = -4; // No shadows on actors
					s->xvel = -256;
					ssp(i,CLIPMASK0);
				}
			}
			else if(sprite[lz].picnum == APLAYER && badguy(s) )
			{
				hittype[i].dispicnum = -4; // No shadows on actors
				s->xvel = -256;
				ssp(i,CLIPMASK0);
			}
			else if(s->statnum == 4 && sprite[lz].picnum == APLAYER)
				if(s->owner == lz)
			{
				hittype[i].ceilingz = sector[s->sectnum].ceilingz;
				hittype[i].floorz	= sector[s->sectnum].floorz;
			}
		}
	}
	else
	{
		hittype[i].ceilingz = sector[s->sectnum].ceilingz;
		hittype[i].floorz	= sector[s->sectnum].floorz;
	}
}


void makeitfall(short i)
{
	spritetype *s = &sprite[i];
	long hz,lz,c;

	if( floorspace(s->sectnum) )
		c = 0;
	else
	{
		if( ceilingspace(s->sectnum) || sector[s->sectnum].lotag == 2)
			c = 176/6;
		else c = 176;
	}

	if( ( s->statnum == 1 || s->statnum == 10 || s->statnum == 2 || s->statnum == 6 ) )
		getzrange(s->x,s->y,s->z-(FOURSLEIGHT),s->sectnum,&hittype[i].ceilingz,&hz,&hittype[i].floorz,&lz,127L,CLIPMASK0);
	else
	{
		hittype[i].ceilingz = sector[s->sectnum].ceilingz;
		hittype[i].floorz	= sector[s->sectnum].floorz;
	}

	if( s->z < hittype[i].floorz-(FOURSLEIGHT) )
	{
		if( sector[s->sectnum].lotag == 2 && s->zvel > 3122 )
			s->zvel = 3144;
		if(s->zvel < 6144)
			s->zvel += c;
		else s->zvel = 6144;
		s->z += s->zvel;
	}
	if( s->z >= hittype[i].floorz-(FOURSLEIGHT) )
	{
		s->z = hittype[i].floorz - FOURSLEIGHT;
		s->zvel = 0;
	}
}



void getlabel(void)
{
	long i;

	while( isalnum(*textptr) == 0 )
	{
		if(*textptr == 0x0a) line_number++;
		textptr++;
		if( *textptr == 0)
			return;
	}

	i = 0;
	while( ispecial(*textptr) == 0 )
		label[(labelcnt<<6)+i++] = *(textptr++);

	label[(labelcnt<<6)+i] = 0;
}

long keyword(void)
{
	long i;
	char *temptextptr;

	temptextptr = textptr;

	while( isaltok(*temptextptr) == 0 )
	{
		temptextptr++;
		if( *temptextptr == 0 )
			return 0;
	}

	i = 0;
	while( isaltok(*temptextptr) )
	{
		tempbuf[i] = *(temptextptr++);
		i++;
	}
	tempbuf[i] = 0;

	for(i=0;i<NUMKEYWORDS;i++)
		if( strcmp( tempbuf,keyw[i]) == 0 )
			return i;

	return -1;
}

long transword(void) //Returns its code #
{
	long i, l;

	while( isaltok(*textptr) == 0 )
	{
		if(*textptr == 0x0a) line_number++;
		if( *textptr == 0 )
			return -1;
		textptr++;
	}

	l = 0;
	while( isaltok(*(textptr+l)) )
	{
		tempbuf[l] = textptr[l];
		l++;
	}
	tempbuf[l] = 0;

	for(i=0;i<NUMKEYWORDS;i++)
	{
		if( strcmp( tempbuf,keyw[i]) == 0 )
		{
			*scriptptr = i;
			textptr += l;
			scriptptr++;
			return i;
		}
	}

	textptr += l;

	printf(gamedef_text.text_98,line_number,tempbuf);

	error++;
	return -1;
}

void transnum(void)
{
	long i, l;

	while( isaltok(*textptr) == 0 )
	{
		if(*textptr == 0x0a) line_number++;
		textptr++;
		if( *textptr == 0 )
			return;
	}


	l = 0;
	while( isaltok(*(textptr+l)) )
	{
		tempbuf[l] = textptr[l];
		l++;
	}
	tempbuf[l] = 0;

	for(i=0;i<NUMKEYWORDS;i++)
		if( strcmp( label+(labelcnt<<6),keyw[i]) == 0 )
	{
		error++;
		printf(gamedef_text.text_99,line_number,label+(labelcnt<<6));
		textptr+=l;
	}


	for(i=0;i<labelcnt;i++)
	{
		if( strcmp(tempbuf,label+(i<<6)) == 0 )
		{
			*scriptptr = labelcode[i];
			scriptptr++;
			textptr += l;
			return;
		}
	}

	if( isdigit(*textptr) == 0 && *textptr != '-')
	{
		printf(gamedef_text.text_100,line_number,tempbuf);
		error++;
		textptr+=l;
		return;
	}

	*scriptptr = atol(textptr);
	scriptptr++;

	textptr += l;
}


char parsecommand(void)
{
	long i, j, k, *tempscrptr;
	char done, *origtptr, temp_ifelse_check, tw;
	short temp_line_number;
	int fp;

	if( error > 12 || ( *textptr == '\0' ) || ( *(textptr+1) == '\0' ) ) return 1;

	tw = transword();

	switch(tw)
	{
		default:
		case -1:
			scriptptr--;
			return 0; //End
		case 39:	  //Rem endrem
			scriptptr--;
			j = line_number;
			do
			{
				textptr++;
				if(*textptr == 0x0a) line_number++;
				if( *textptr == 0 )
				{
					printf(gamedef_text.text_101,j,label+(labelcnt<<6));
					error++;
					return 0;
				}
			}
			while( *textptr != '*' || *(textptr+1) != '/' );
			textptr+=2;
			return 0;
		case 17:
			if( parsing_actor == 0 && parsing_state == 0 )
			{
				getlabel();
				scriptptr--;
				labelcode[labelcnt] = (long) scriptptr;
				labelcnt++;

				parsing_state = 1;

				return 0;
			}

			getlabel();

			for(i=0;i<NUMKEYWORDS;i++)
				if( strcmp( label+(labelcnt<<6),keyw[i]) == 0 )
				{
					error++;
					printf(gamedef_text.text_102,line_number,label+(labelcnt<<6));
					return 0;
				}

			for(j=0;j<labelcnt;j++)
			{
				if( strcmp(label+(j<<6),label+(labelcnt<<6)) == 0 )
				{
					*scriptptr = labelcode[j];
					break;
				}
			}

			if(j==labelcnt)
			{
				printf(gamedef_text.text_103,line_number,label+(labelcnt<<6));
				error++;
			}
			scriptptr++;
			return 0;

		case 15:
		case 92:
		case 87:
		case 89:
		case 93:
			transnum();
			return 0;
			
		case 18:
			if( parsing_state == 0 )
			{
				printf(gamedef_text.text_104,line_number);
				error++;
			}
//			  else
			{
				if( num_squigilly_brackets > 0 )
				{
					printf(gamedef_text.text_105,line_number);
					error++;
				}
				if( num_squigilly_brackets < 0 )
				{
					printf(gamedef_text.text_106,line_number);
					error++;
				}
				parsing_state = 0;
			}
			return 0;
		case 19:
//printf("Got definition. Getting Label. '%.20s'\n",textptr);
			getlabel();
//printf("Got label. '%.20s'\n",textptr);
			// Check to see it's already defined

			for(i=0;i<NUMKEYWORDS;i++)
				if( strcmp( label+(labelcnt<<6),keyw[i]) == 0 )
				{
					error++;
					printf(gamedef_text.text_107,line_number,label+(labelcnt<<6));
					return 0;
				}

			for(i=0;i<labelcnt;i++)
			{
				if( strcmp(label+(labelcnt<<6),label+(i<<6)) == 0 )
				{
					warning++;
					printf(gamedef_text.text_108,line_number,label+(labelcnt<<6));
					break;
				}
			}

//printf("Translating. '%.20s'\n",textptr);
			transnum();
//printf("Translated. '%.20s'\n",textptr);
			if(i == labelcnt)
			{
//				printf("Defining Definition '%s' to be '%d'\n",label+(labelcnt<<6),*(scriptptr-1));
				labelcode[labelcnt++] = *(scriptptr-1);
			}
			scriptptr -= 2;
			return 0;
		case 14:

			for(j = 0;j < 4;j++)
			{
				if( keyword() == -1 )
					transnum();
				else break;
			}

			while(j < 4)
			{
				*scriptptr = 0;
				scriptptr++;
				j++;
			}
			return 0;

		case 32:
			if( parsing_actor || parsing_state )
			{
				transnum();

				j = 0;
				while(keyword() == -1)
				{
					transnum();
					scriptptr--;
					j |= *scriptptr;
				}
				*scriptptr = j;
				scriptptr++;
			}
			else
			{
				scriptptr--;
				getlabel();
				// Check to see it's already defined

				for(i=0;i<NUMKEYWORDS;i++)
					if( strcmp( label+(labelcnt<<6),keyw[i]) == 0 )
				{
					error++;
					printf(gamedef_text.text_109,line_number,label+(labelcnt<<6));
					return 0;
				}

				for(i=0;i<labelcnt;i++)
					if( strcmp(label+(labelcnt<<6),label+(i<<6)) == 0 )
					{
						warning++;
						printf(gamedef_text.text_110,line_number,label+(labelcnt<<6));
						break;
					}
				if(i == labelcnt)
					labelcode[labelcnt++] = (long) scriptptr;
				for(j=0;j<2;j++)
				{
					if(keyword() >= 0) break;
					transnum();
				}
				for(k=j;k<2;k++)
				{
					*scriptptr = 0;
					scriptptr++;
				}
			}
			return 0;

		case 54:
			{
				// NOTE: this doesn't get stored in the PCode...
				
// music 1 stalker.mid dethtoll.mid streets.mid watrwld1.mid snake1.mid
//	  thecall.mid ahgeez.mid dethtoll.mid streets.mid watrwld1.mid snake1.mid
				scriptptr--;
				transnum(); // Volume Number (0/4)
				scriptptr--;

				k = *scriptptr-1;

				if(k >= 0) // if it's background music
				{
					i = 0;
					// get the file name...
					while(keyword() == -1)
					{
						while( isaltok(*textptr) == 0 )
						{
							if(*textptr == 0x0a) line_number++;
							textptr++;
							if( *textptr == 0 ) break;
						}
						j = 0;
						while( isaltok(*(textptr+j)) )
						{
							music_fn[k][i][j] = textptr[j];
							j++;
						}
						music_fn[k][i][j] = '\0';
						textptr += j;
						if(i > 9) break;
						i++;
					}
				}
				else
				{
					i = 0;
					while(keyword() == -1)
					{
						while( isaltok(*textptr) == 0 )
						{
							if(*textptr == 0x0a) line_number++;
							textptr++;
							if( *textptr == 0 ) break;
						}
						j = 0;
						while( isaltok(*(textptr+j)) )
						{
							env_music_fn[i][j] = textptr[j];
							j++;
						}
						env_music_fn[i][j] = '\0';

						textptr += j;
						if(i > 9) break;
						i++;
					}
				}
			}
			return 0;
		case 55:
			scriptptr--;
			while( isaltok(*textptr) == 0 )
			{
				if(*textptr == 0x0a) line_number++;
				textptr++;
				if( *textptr == 0 ) break;
			}
			j = 0;
			while( isaltok(*textptr) )
			{
				tempbuf[j] = *(textptr++);
				j++;
			}
			tempbuf[j] = '\0';

			fp = kopen4load(tempbuf,loadfromgrouponly);
			if(fp == 0)
			{
				error++;
				printf(gamedef_text.text_111,line_number,label+(labelcnt<<6));
				return 0;
			}

			j = kfilelength(fp);

			printf(gamedef_text.text_112,tempbuf);

			temp_line_number = line_number;
			line_number = 1;
			temp_ifelse_check = checking_ifelse;
			checking_ifelse = 0;
			origtptr = textptr;
			textptr = last_used_text+last_used_size;

			*(textptr+j) = 0;

			kread(fp,(char *)textptr,j);
			kclose(fp);

//sprintf(g_szBuf,"CP:%s %d",__FILE__,__LINE__);
//AddLog(g_szBuf);
			do
				done = parsecommand();
			while( done == 0 );

			textptr = origtptr;
			total_script_lines += line_number;
			line_number = temp_line_number;
			checking_ifelse = temp_ifelse_check;
//sprintf(g_szBuf,"CP:%s %d",__FILE__,__LINE__);
//AddLog(g_szBuf);

			return 0;
		case 24:
			if( parsing_actor || parsing_state )
				transnum();
			else
			{
				scriptptr--;
				getlabel();

				for(i=0;i<NUMKEYWORDS;i++)
					if( strcmp( label+(labelcnt<<6),keyw[i]) == 0 )
					{
						error++;
						printf(gamedef_text.text_113,line_number,label+(labelcnt<<6));
						return 0;
					}

				for(i=0;i<labelcnt;i++)
					if( strcmp(label+(labelcnt<<6),label+(i<<6)) == 0 )
					{
						warning++;
						printf(gamedef_text.text_114,line_number,label+(labelcnt<<6));
						break;
					}

				if(i == labelcnt)
					labelcode[labelcnt++] = (long) scriptptr;

				for(j=0;j<3;j++)
				{
					if(keyword() >= 0) break;
					if(j == 2)
					{
						k = 0;
						while(keyword() == -1)
						{
							transnum();
							scriptptr--;
							k |= *scriptptr;
						}
						*scriptptr = k;
						scriptptr++;
						return 0;
					}
					else transnum();
				}
				for(k=j;k<3;k++)
				{
					*scriptptr = 0;
					scriptptr++;
				}
			}
			return 0;

		case 7:
			if( parsing_actor || parsing_state )
				transnum();
			else
			{
				scriptptr--;
				getlabel();
				// Check to see it's already defined

				for(i=0;i<NUMKEYWORDS;i++)
					if( strcmp( label+(labelcnt<<6),keyw[i]) == 0 )
					{
						error++;
						printf(gamedef_text.text_115,line_number,label+(labelcnt<<6));
						return 0;
					}

				for(i=0;i<labelcnt;i++)
					if( strcmp(label+(labelcnt<<6),label+(i<<6)) == 0 )
					{
						warning++;
						printf(gamedef_text.text_116,line_number,label+(labelcnt<<6));
						break;
					}

				if(i == labelcnt)
					labelcode[labelcnt++] = (long) scriptptr;

				for(j=0;j<5;j++)
				{
					if(keyword() >= 0) break;
					transnum();
				}
				for(k=j;k<5;k++)
				{
					*scriptptr = 0;
					scriptptr++;
				}
			}
			return 0;

		case 1:
			if( parsing_state )
			{
				printf(gamedef_text.text_117,line_number);
				error++;
			}

			if( parsing_actor )
			{
				printf(gamedef_text.text_118,line_number);
				error++;
			}

			num_squigilly_brackets = 0;
			scriptptr--;
			parsing_actor = scriptptr;

			transnum();
			scriptptr--;
			actorscrptr[*scriptptr] = parsing_actor;

			for(j=0;j<4;j++)
			{
				*(parsing_actor+j) = 0;
				if(j == 3)
				{
					j = 0;
					while(keyword() == -1)
					{
						transnum();
						scriptptr--;
						j |= *scriptptr;
					}
					*scriptptr = j;
					scriptptr++;
					break;
				}
				else
				{
					if(keyword() >= 0)
					{
						scriptptr += (4-j);
						break;
					}
					transnum();

					*(parsing_actor+j) = *(scriptptr-1);
				}
			}

			checking_ifelse = 0;

			return 0;


		case 11:
		case 13:
		case 25:
		case 31:
		case 40:
		case 52:
		case 69:
		case 74:
		case 77:
		case 80:
		case 86:
		case 88:
		case 68:
		
		
		
		
		
		
			transnum();
			return 0;

		case 2:
		case 23:
		case 28:
		
		case 37:
		case 48:
		case 58:
			transnum();
			transnum();
			break;
		case 50:
			transnum();
			transnum();
			transnum();
			transnum();
			transnum();
			return 0;
		case 10:
			if( checking_ifelse )
			{
				checking_ifelse--;
				tempscrptr = scriptptr;
				scriptptr++; //Leave a spot for the fail location
				parsecommand();
				*tempscrptr = (long) scriptptr;
			}
			else
			{
				scriptptr--;
				warning++;
				printf(gamedef_text.text_119,line_number);
			}

			return 0;

		case 75:
			transnum();
		case 3:
		case 8:
		case 9:
		case 21:
		case 33:
		case 34:
		case 35:
		case 41:
		case 46:
		case 53:
		case 56:
		case 59:
		case 62:
		case 72:
		case 73:
//		  case 74:
		case 78:
		case 85:
		case 94:
		
			transnum();
		case 43:
		case 44:
		case 49:
		case 5:
		case 6:
		case 27:
		case 26:
		case 45:
		case 51:
		case 63:
		case 64:
		case 65:
		case 67:
		case 70:
		case 71:
		case 81:
		case 82:
		case 90:
		case 91:
		

			if(tw == 51)
			{
				j = 0;
				do
				{
					transnum();
					scriptptr--;
					j |= *scriptptr;
				}
				while(keyword() == -1);
				*scriptptr = j;
				scriptptr++;
			}

			tempscrptr = scriptptr;
			scriptptr++; //Leave a spot for the fail location

			do
			{
				j = keyword();
				if(j == 20 || j == 39)
					parsecommand();
			} while(j == 20 || j == 39);

			parsecommand();

			*tempscrptr = (long) scriptptr;

			checking_ifelse++;
			return 0;
		case 29:
			num_squigilly_brackets++;
			do
				done = parsecommand();
			while( done == 0 );
			return 0;
		case 30:
			num_squigilly_brackets--;
			if( num_squigilly_brackets < 0 )
			{
				printf(gamedef_text.text_120,line_number);
				error++;
			}
			return 1;
		case 76:
			scriptptr--;
			j = 0;
			while( *textptr != 0x0a )
			{
				betaname[j] = *textptr;
				j++; textptr++;
			}
			betaname[j] = 0;
			return 0;
		case 20:
			scriptptr--; //Negate the rem
			while( *textptr != 0x0a )
				textptr++;

			// line_number++;
			return 0;

		case 0:
			scriptptr--;
			transnum();
			scriptptr--;
			j = *scriptptr;
			transnum();
			scriptptr--;
			k = *scriptptr;
			while( *textptr == ' ' ) textptr++;

			i = 0;
			while( *textptr != ' ' && *textptr != 0x0a )
			{
				level_file_names[j*11+k][i] = *textptr;
				textptr++,i++;
				if(i > 13)
				{
					printf(gamedef_text.text_121,line_number);
					error++;
					while( *textptr != ' ') textptr++;
					break;
				}
			}
			level_names[j*11+k][i-1] = '\0';

			while( *textptr == ' ' ) textptr++;

			partime[j*11+k] =
				(((*(textptr+0)-'0')*10+(*(textptr+1)-'0'))*26*60)+
				(((*(textptr+3)-'0')*10+(*(textptr+4)-'0'))*26);

			textptr += 5;
			while( *textptr == ' ' ) textptr++;

			designertime[j*11+k] =
				(((*(textptr+0)-'0')*10+(*(textptr+1)-'0'))*26*60)+
				(((*(textptr+3)-'0')*10+(*(textptr+4)-'0'))*26);

			textptr += 5;
			while( *textptr == ' ' ) textptr++;

			i = 0;

			while( *textptr != 0x0a )
			{
				level_names[j*11+k][i] = toupper(*textptr);
				textptr++,i++;
				if(i >= 32)
				{
					printf(gamedef_text.text_122,line_number);
					error++;
					while( *textptr != 0x0a ) textptr++;
					break;
				}
			}
			level_names[j*11+k][i-1] = '\0';
			return 0;

		case 79:
			scriptptr--;
			transnum();
			k = *(scriptptr-1);
			if(k >= NUMOFFIRSTTIMEACTIVE)
			{
				printf(gamedef_text.text_123,line_number,NUMOFFIRSTTIMEACTIVE);
				error++;
			}
			scriptptr--;
			i = 0;
			while( *textptr == ' ' )
				textptr++;

			while( *textptr != 0x0a )
			{
				fta_quotes[k][i] = *textptr;
				textptr++,i++;
				if(i >= 64)
				{
					printf(gamedef_text.text_124,line_number);
					error++;
					while( *textptr != 0x0a ) textptr++;
					break;
				}
			}
			fta_quotes[k][i] = '\0';
			return 0;
		case 57:
			scriptptr--;
			transnum();
			k = *(scriptptr-1);
			if(k >= NUM_SOUNDS)
			{
				printf(gamedef_text.text_125,line_number,k,NUM_SOUNDS);
				error++;
			}
			scriptptr--;
			i = 0;
			while( *textptr == ' ')
				textptr++;

			while( *textptr != ' ' )
			{
				sounds[k][i] = *textptr;
				textptr++,i++;
				if(i >= 13)
				{
					puts(sounds[k]);
					printf(gamedef_text.text_126,line_number);
					error++;
					while( *textptr != ' ' ) textptr++;
					break;
				}
			}
			sounds[k][i] = '\0';

			transnum();
			soundps[k] = *(scriptptr-1);
			scriptptr--;
			transnum();
			soundpe[k] = *(scriptptr-1);
			scriptptr--;
			transnum();
			soundpr[k] = *(scriptptr-1);
			scriptptr--;
			transnum();
			soundm[k] = *(scriptptr-1);
			scriptptr--;
			transnum();
			soundvo[k] = *(scriptptr-1);
			scriptptr--;
			return 0;
		
			case 4:
			if( parsing_actor == 0 )
			{
				printf(gamedef_text.text_127,line_number);
				error++;
			}
//			  else
			{
				if( num_squigilly_brackets > 0 )
				{
					printf(gamedef_text.text_128,line_number);
					error++;
				}
				parsing_actor = 0;
			}

			return 0;
		case 12:
		case 16:
		case 84:
//		  case 21:
		case 22:	//KILLIT
		case 36:
		case 38:
		case 42:
		case 47:
		case 61:
		case 66:
		case 83:
		case 95:
		case 96:
		case 97:
		
		
			return 0;
		case 60:
			j = 0;
			while(j < 26)
			{
				transnum();
				scriptptr--;

				switch(j)
				{
					case 0:
						ud.const_visibility = *scriptptr;
						break;
					case 1:
						impact_damage = *scriptptr;
						break;
					case 2:
						max_player_health = *scriptptr;
						break;
					case 3:
						max_armour_amount = *scriptptr;
						break;
					case 4:
						respawnactortime = *scriptptr;break;
					case 5:
						respawnitemtime = *scriptptr;break;
					case 6:
						dukefriction = *scriptptr;break;
					case 7:rpgblastradius = *scriptptr;break;
					case 8:pipebombblastradius = *scriptptr;break;
					case 9:shrinkerblastradius = *scriptptr; break;
					case 10:tripbombblastradius = *scriptptr; break;
					case 11:morterblastradius = *scriptptr;break;
					case 12:bouncemineblastradius = *scriptptr;break;
					case 13:seenineblastradius = *scriptptr;break;

					case 14:
					case 15:
					case 16:
					case 17:
					case 18:
					case 19:
					case 20:
					case 21:
					case 22:
						max_ammo_amount[j-13] = *scriptptr;
						break;
					case 23:
						camerashitable = *scriptptr;
						break;
					case 24:
						numfreezebounces = *scriptptr;
						break;
					case 25:
						freezerhurtowner = *scriptptr;
						break;
				}
				j++;
			}
			scriptptr++;
			return 0;
	}
	return 0;
}


void passone(void)
{

	while( parsecommand() == 0 );

	if( (error+warning) > 12)
		puts(  gamedef_text.text_129);

}




void loadefs(char *filenam,char *mptr)
{
	int i;
	long fs,fp;


//sprintf(g_szBuf,"CP:%s %d",__FILE__,__LINE__);
//AddLog(g_szBuf);
	fp = kopen4load(filenam,loadfromgrouponly);
	if( fp == 0 )
	{
//sprintf(g_szBuf,"CP:%s %d",__FILE__,__LINE__);
//AddLog(g_szBuf);
		if( loadfromgrouponly == 1 )
		{
//sprintf(g_szBuf,"CP:%s %d",__FILE__,__LINE__);
//AddLog(g_szBuf);
			gameexit(gamedef_text.text_130);
		}

		loadfromgrouponly = 1;
		return; //Not there
	}
	else
	{
//sprintf(g_szBuf,"CP:%s %d",__FILE__,__LINE__);
//AddLog(g_szBuf);
		printf(gamedef_text.text_131,filenam);

		fs = kfilelength(fp);

		last_used_text = textptr = (char *) mptr;
		last_used_size = fs;

//sprintf(g_szBuf,"CP:%s %d (%ld)",__FILE__,__LINE__,fs);
//AddLog(g_szBuf);
		kread(fp,(char *)textptr,fs);
//sprintf(g_szBuf,"CP:%s %d",__FILE__,__LINE__);
//AddLog(g_szBuf);
		kclose(fp);
//sprintf(g_szBuf,"CP:%s %d",__FILE__,__LINE__);
//AddLog(g_szBuf);
	}

//sprintf(g_szBuf,"CP:%s %d",__FILE__,__LINE__);
//AddLog(g_szBuf);
	last_used_end = textptr + fs - 2;
	*last_used_end = 0;

	clearbuf(actorscrptr,MAXSPRITES,0L);

	labelcnt = 0;
	scriptptr = script+1;
	warning = 0;
	error = 0;
	line_number = 1;
	total_script_lines = 0;

//sprintf(g_szBuf,"CP:%s %d",__FILE__,__LINE__);
//AddLog(g_szBuf);
	passone(); //Tokenize
	*script = (long) scriptptr;
//sprintf(g_szBuf,"CP:%s %d",__FILE__,__LINE__);
//AddLog(g_szBuf);

	printf(gamedef_text.text_132,warning,error);

	if( error == 0 && warning != 0)
	{
		if( groupfile != -1 && loadfromgrouponly == 0 )
		{
			printf(gamedef_text.text_133,filenam);
			puts(gamedef_text.text_134);
			puts(gamedef_text.text_135);

			KB_FlushKeyboardQueue();
			while( KB_KeyWaiting() );
			i = KB_Getch();
			if(i == 'y' || i == 'Y' )
			{
				loadfromgrouponly = 1;
				printf(gamedef_text.text_136);
				puts(gamedef_text.text_137);
				return;
			}
			else gameexit(gamedef_text.text_138);
		}
	}

	if(error)
	{
		if( loadfromgrouponly )
		{
			sprintf(buf,gamedef_text.text_139,filenam);
			gameexit(buf);
		}
		else
		{
			if( groupfile != -1 && loadfromgrouponly == 0 )
			{
				printf(gamedef_text.text_140,filenam);
				puts(gamedef_text.text_141);
				puts(gamedef_text.text_142);

				KB_FlushKeyboardQueue();
				while( !KB_KeyWaiting() );

				i = KB_Getch();
				if( i == 'y' || i == 'Y' )
				{
					loadfromgrouponly = 1;
					return;
				}
				else gameexit(gamedef_text.text_138);
			}
		}
	}
	else
	{
		total_script_lines += line_number;
		printf(gamedef_text.text_143,(long)((scriptptr-script)<<2)-4,labelcnt);
	}
}

char dodge(spritetype *s)
{
	short i;
	long bx,by,mx,my,bxvect,byvect,mxvect,myvect,d;

	mx = s->x;
	my = s->y;
	mxvect = sintable[(s->ang+512)&2047]; myvect = sintable[s->ang&2047];

	for(i=headspritestat[4];i>=0;i=nextspritestat[i]) //weapons list
	{
		if( OW == i || SECT != s->sectnum)
			continue;

		bx = SX-mx;
		by = SY-my;
		bxvect = sintable[(SA+512)&2047]; byvect = sintable[SA&2047];

		if (mxvect*bx + myvect*by >= 0)
			if (bxvect*bx + byvect*by < 0)
		{
			d = bxvect*by - byvect*bx;
			if (klabs(d) < 65536*64)
			{
				s->ang -= 512+(TRAND&1024);
				return 1;
			}
		}
	}
	return 0;
}

short furthestangle(short i,short angs)
{
	short j, hitsect,hitwall,hitspr,furthest_angle, angincs;
	long hx, hy, hz, d, greatestd;
	spritetype *s = &sprite[i];

	greatestd = -(1<<30);
	angincs = 2048/angs;

	if(s->picnum != APLAYER)
		if( (g_t[0]&63) > 2 ) return( s->ang + 1024 );

	for(j=s->ang;j<(2048+s->ang);j+=angincs)
	{
		hitscan(s->x, s->y, s->z-(8<<8), s->sectnum,
			sintable[(j+512)&2047],
			sintable[j&2047],0,
			&hitsect,&hitwall,&hitspr,&hx,&hy,&hz,CLIPMASK1);

		d = klabs(hx-s->x) + klabs(hy-s->y);

		if(d > greatestd)
		{
			greatestd = d;
			furthest_angle = j;
		}
	}
	return (furthest_angle&2047);
}

short furthestcanseepoint(short i,spritetype *ts,long *dax,long *day)
{
	short j, hitsect,hitwall,hitspr, angincs, tempang;
	long hx, hy, hz, d, da;//, d, cd, ca,tempx,tempy,cx,cy;
	spritetype *s = &sprite[i];

	if( (g_t[0]&63) ) return -1;

	if(ud.multimode < 2 && ud.player_skill < 3)
		angincs = 2048/2;
	else angincs = 2048/(1+(TRAND&1));

	for(j=ts->ang;j<(2048+ts->ang);j+=(angincs-(TRAND&511)))
	{
		hitscan(ts->x, ts->y, ts->z-(16<<8), ts->sectnum,
			sintable[(j+512)&2047],
			sintable[j&2047],16384-(TRAND&32767),
			&hitsect,&hitwall,&hitspr,&hx,&hy,&hz,CLIPMASK1);

		d = klabs(hx-ts->x)+klabs(hy-ts->y);
		da = klabs(hx-s->x)+klabs(hy-s->y);

		if( d < da )
			if(cansee(hx,hy,hz,hitsect,s->x,s->y,s->z-(16<<8),s->sectnum))
		{
			*dax = hx;
			*day = hy;
			return hitsect;
		}
	}
	return -1;
}




void alterang(short a)
{
	short aang, angdif, goalang,j;
	long ticselapsed, *moveptr;

	moveptr = (long *)g_t[1];

	ticselapsed = (g_t[0])&31;

	aang = g_sp->ang;

	g_sp->xvel += (*moveptr-g_sp->xvel)/5;
	if(g_sp->zvel < 648) g_sp->zvel += ((*(moveptr+1)<<4)-g_sp->zvel)/5;

	if(a&seekplayer)
	{
		j = ps[g_p].holoduke_on;

// NOTE: looks like 'owner' is set to target sprite ID...
		
		if(j >= 0 && cansee(sprite[j].x,sprite[j].y,sprite[j].z,sprite[j].sectnum,g_sp->x,g_sp->y,g_sp->z,g_sp->sectnum) )
			g_sp->owner = j;
		else g_sp->owner = ps[g_p].i;

		if(sprite[g_sp->owner].picnum == APLAYER)
			goalang = getangle(hittype[g_i].lastvx-g_sp->x,hittype[g_i].lastvy-g_sp->y);
		else
			goalang = getangle(sprite[g_sp->owner].x-g_sp->x,sprite[g_sp->owner].y-g_sp->y);

		if(g_sp->xvel && g_sp->picnum != DRONE)
		{
			angdif = getincangle(aang,goalang);

			if(ticselapsed < 2)
			{
				if( klabs(angdif) < 256)
				{
					j = 128-(TRAND&256);
					g_sp->ang += j;
					if( hits(g_i) < 844 )
						g_sp->ang -= j;
				}
			}
			else if(ticselapsed > 18 && ticselapsed < 26) // choose
			{
				if(klabs(angdif>>2) < 128) g_sp->ang = goalang;
				else g_sp->ang += angdif>>2;
			}
		}
		else g_sp->ang = goalang;
	}

	if(ticselapsed < 1)
	{
		j = 2;
		if(a&furthestdir)
		{
			goalang = furthestangle(g_i,j);
			g_sp->ang = goalang;
			g_sp->owner = ps[g_p].i;
		}

		if(a&fleeenemy)
		{
			goalang = furthestangle(g_i,j);
			g_sp->ang = goalang; // += angdif; //  = getincangle(aang,goalang)>>1;
		}
	}
}

void move()
{
	long l, *moveptr;
	short j, a, goalang, angdif;
	long daxvel;

	a = g_sp->hitag;

	if(a == -1) a = 0;

	g_t[0]++;

	if(a&face_player)
	{
		if(ps[g_p].newowner >= 0)
			goalang = getangle(ps[g_p].oposx-g_sp->x,ps[g_p].oposy-g_sp->y);
		else goalang = getangle(ps[g_p].posx-g_sp->x,ps[g_p].posy-g_sp->y);
		angdif = getincangle(g_sp->ang,goalang)>>2;
		if(angdif > -8 && angdif < 0) angdif = 0;
		g_sp->ang += angdif;
	}

	if(a&spin)
		g_sp->ang += sintable[ ((g_t[0]<<3)&2047) ]>>6;

	if(a&face_player_slow)
	{
		if(ps[g_p].newowner >= 0)
			goalang = getangle(ps[g_p].oposx-g_sp->x,ps[g_p].oposy-g_sp->y);
		else goalang = getangle(ps[g_p].posx-g_sp->x,ps[g_p].posy-g_sp->y);
		angdif = ksgn(getincangle(g_sp->ang,goalang))<<5;
		if(angdif > -32 && angdif < 0)
		{
			angdif = 0;
			g_sp->ang = goalang;
		}
		g_sp->ang += angdif;
	}


	if((a&jumptoplayer) == jumptoplayer)
	{
		if(g_t[0] < 16)
			g_sp->zvel -= (sintable[512+(g_t[0]<<4)]>>5);
	}

	if(a&face_player_smart)
	{
		long newx,newy;

		newx = ps[g_p].posx+(ps[g_p].posxv/768);
		newy = ps[g_p].posy+(ps[g_p].posyv/768);
		goalang = getangle(newx-g_sp->x,newy-g_sp->y);
		angdif = getincangle(g_sp->ang,goalang)>>2;
		if(angdif > -8 && angdif < 0) angdif = 0;
		g_sp->ang += angdif;
	}

	if( g_t[1] == 0 || a == 0 )
	{
		if( ( badguy(g_sp) && g_sp->extra <= 0 ) || (hittype[g_i].bposx != g_sp->x) || (hittype[g_i].bposy != g_sp->y) )
		{
			hittype[g_i].bposx = g_sp->x;
			hittype[g_i].bposy = g_sp->y;
			setsprite(g_i,g_sp->x,g_sp->y,g_sp->z);
		}
		return;
	}

	moveptr = (long *)g_t[1];

	if(a&geth) g_sp->xvel += (*moveptr-g_sp->xvel)>>1;
	if(a&getv) g_sp->zvel += ((*(moveptr+1)<<4)-g_sp->zvel)>>1;

	if(a&dodgebullet)
		dodge(g_sp);

	if(g_sp->picnum != APLAYER)
		alterang(a);

	if(g_sp->xvel > -6 && g_sp->xvel < 6 ) g_sp->xvel = 0;

	a = badguy(g_sp);

	if(g_sp->xvel || g_sp->zvel)
	{
		if(a && g_sp->picnum != ROTATEGUN)
		{
			if( (g_sp->picnum == DRONE || g_sp->picnum == COMMANDER) && g_sp->extra > 0)
			{
				if(g_sp->picnum == COMMANDER)
				{
					hittype[g_i].floorz = l = getflorzofslope(g_sp->sectnum,g_sp->x,g_sp->y);
					if( g_sp->z > (l-(8<<8)) )
					{
						if( g_sp->z > (l-(8<<8)) ) g_sp->z = l-(8<<8);
						g_sp->zvel = 0;
					}

					hittype[g_i].ceilingz = l = getceilzofslope(g_sp->sectnum,g_sp->x,g_sp->y);
					if( (g_sp->z-l) < (80<<8) )
					{
						g_sp->z = l+(80<<8);
						g_sp->zvel = 0;
					}
				}
				else
				{
					if( g_sp->zvel > 0 )
					{
						hittype[g_i].floorz = l = getflorzofslope(g_sp->sectnum,g_sp->x,g_sp->y);
						if( g_sp->z > (l-(30<<8)) )
							g_sp->z = l-(30<<8);
					}
					else
					{
						hittype[g_i].ceilingz = l = getceilzofslope(g_sp->sectnum,g_sp->x,g_sp->y);
						if( (g_sp->z-l) < (50<<8) )
						{
							g_sp->z = l+(50<<8);
							g_sp->zvel = 0;
						}
					}
				}
			}
			else if(g_sp->picnum != ORGANTIC)
			{
				if(g_sp->zvel > 0 && hittype[g_i].floorz < g_sp->z)
					g_sp->z = hittype[g_i].floorz;
				if( g_sp->zvel < 0)
				{
					l = getceilzofslope(g_sp->sectnum,g_sp->x,g_sp->y);
					if( (g_sp->z-l) < (66<<8) )
					{
						g_sp->z = l+(66<<8);
						g_sp->zvel >>= 1;
					}
				}
			}
		}
		else if(g_sp->picnum == APLAYER)
			if( (g_sp->z-hittype[g_i].ceilingz) < (32<<8) )
				g_sp->z = hittype[g_i].ceilingz+(32<<8);

		daxvel = g_sp->xvel;
		angdif = g_sp->ang;

		if( a && g_sp->picnum != ROTATEGUN )
		{
			if( g_x < 960 && g_sp->xrepeat > 16 )
			{

				daxvel = -(1024-g_x);
				angdif = getangle(ps[g_p].posx-g_sp->x,ps[g_p].posy-g_sp->y);

				if(g_x < 512)
				{
					ps[g_p].posxv = 0;
					ps[g_p].posyv = 0;
				}
				else
				{
					ps[g_p].posxv = mulscale(ps[g_p].posxv,dukefriction-0x2000,16);
					ps[g_p].posyv = mulscale(ps[g_p].posyv,dukefriction-0x2000,16);
				}
			}
			else if(g_sp->picnum != DRONE && g_sp->picnum != SHARK && g_sp->picnum != COMMANDER)
			{
				if( hittype[g_i].bposz != g_sp->z || ( ud.multimode < 2 && ud.player_skill < 2 ) )
				{
					if( (g_t[0]&1) || ps[g_p].actorsqu == g_i ) return;
					else daxvel <<= 1;
				}
				else
				{
					if( (g_t[0]&3) || ps[g_p].actorsqu == g_i ) return;
					else daxvel <<= 2;
				}
			}
		}

		hittype[g_i].movflag = movesprite(g_i,
			(daxvel*(sintable[(angdif+512)&2047]))>>14,
			(daxvel*(sintable[angdif&2047]))>>14,g_sp->zvel,CLIPMASK0);
   }

   if( a )
   {
	   if (sector[g_sp->sectnum].ceilingstat&1)
		   g_sp->shade += (sector[g_sp->sectnum].ceilingshade-g_sp->shade)>>1;
	   else g_sp->shade += (sector[g_sp->sectnum].floorshade-g_sp->shade)>>1;

	   if( sector[g_sp->sectnum].floorpicnum == MIRROR )
		   deletesprite(g_i);
   }
}

char parse(void);

void parseifelse(long condition)
{
	if( condition )
	{
		// skip 'else' pointer.. and...
		insptr+=2;
		parse();
	}
	else
	{
		insptr = (long *) *(insptr+1);
		if(*insptr == 10)
		{
			// else...

			// skip 'else' and...
			insptr+=2;
			
			parse();
		}
	}
}

// long *it = 0x00589a04;

char parse(void)
{
	long j, l, s;


	if(killit_flag) return 1;

//	  if(*it == 1668249134L) gameexit("\nERR");

	switch(*insptr)
	{
		case 3:
			insptr++;
			parseifelse( rnd(*insptr));
			break;
		case 45:

			if(g_x > 1024)
			{
				short temphit, sclip, angdif;

				if( badguy(g_sp) && g_sp->xrepeat > 56 )
				{
					sclip = 3084;
					angdif = 48;
				}
				else
				{
					sclip = 768;
					angdif = 16;
				}

				j = hitasprite(g_i,&temphit);
				if(j == (1<<30))
				{
					parseifelse(1);
					break;
				}
				if(j > sclip)
				{
					if(temphit >= 0 && sprite[temphit].picnum == g_sp->picnum)
						j = 0;
					else
					{
						g_sp->ang += angdif;j = hitasprite(g_i,&temphit);g_sp->ang -= angdif;
						if(j > sclip)
						{
							if(temphit >= 0 && sprite[temphit].picnum == g_sp->picnum)
								j = 0;
							else
							{
								g_sp->ang -= angdif;j = hitasprite(g_i,&temphit);g_sp->ang += angdif;
								if( j > 768 )
								{
									if(temphit >= 0 && sprite[temphit].picnum == g_sp->picnum)
										j = 0;
									else j = 1;
								}
								else j = 0;
							}
						}
						else j = 0;
					}
				}
				else j =  0;
			}
			else j = 1;

			parseifelse(j);
			break;
		case 91:
			j = cansee(g_sp->x,g_sp->y,g_sp->z-((TRAND&41)<<8),g_sp->sectnum,ps[g_p].posx,ps[g_p].posy,ps[g_p].posz/*-((TRAND&41)<<8)*/,sprite[ps[g_p].i].sectnum);
			parseifelse(j);
			if( j ) hittype[g_i].timetosleep = SLEEPTIME;
			break;

		case 49:
			parseifelse(hittype[g_i].actorstayput == -1);
			break;
		case 5:
		{
			spritetype *s;
			short sect;

			// select sprite for monster to target
			// if holoduke is on, let them target holoduke first.
			// 
			if(ps[g_p].holoduke_on >= 0)
			{
				s = &sprite[ps[g_p].holoduke_on];
				j = cansee(g_sp->x,g_sp->y,g_sp->z-(TRAND&((32<<8)-1)),g_sp->sectnum,
					   s->x,s->y,s->z,s->sectnum);
				
				if(j == 0)
				{
					// they can't see player's holoduke
					// check for player...
					s = &sprite[ps[g_p].i];
				}
			}
			else s = &sprite[ps[g_p].i];	// holoduke not on. look for player

			// can they see player, (or player's holoduke)
			j = cansee(g_sp->x,g_sp->y,g_sp->z-(TRAND&((47<<8))),g_sp->sectnum,
				s->x,s->y,s->z-(24<<8),s->sectnum);

			if(j == 0)
			{
				// they can't see it.

				// Huh?.  This does nothing....
				// (the result is always j==0....)
				if( ( klabs(hittype[g_i].lastvx-g_sp->x)+klabs(hittype[g_i].lastvy-g_sp->y) ) <
					( klabs(hittype[g_i].lastvx-s->x)+klabs(hittype[g_i].lastvy-s->y) ) )
						j = 0;

				// um yeah, this if() will always fire....
				if( j == 0 )
				{
					// search around for target player
					
					// also modifies 'target' x&y if found..
					
					j = furthestcanseepoint(g_i,s,&hittype[g_i].lastvx,&hittype[g_i].lastvy);

					if(j == -1) j = 0;
					else j = 1;
				}
			}
			else
			{
				// else, they did see it.
				// save where we were looking...
				hittype[g_i].lastvx = s->x;
				hittype[g_i].lastvy = s->y;
			}

			if( j == 1 && ( g_sp->statnum == 1 || g_sp->statnum == 6 ) )
				hittype[g_i].timetosleep = SLEEPTIME;

			parseifelse(j == 1);
			break;
		}

		case 6:
			parseifelse(ifhitbyweapon(g_i) >= 0);
			break;
		case 27:
			parseifelse( ifsquished(g_i, g_p) == 1);
			break;
		case 26:
			{
				j = g_sp->extra;
				if(g_sp->picnum == APLAYER)
					j--;
				parseifelse(j < 0);
			}
			break;
		case 24:
			insptr++;
			g_t[5] = *insptr;
			g_t[4] = *(long *)(g_t[5]);		  // Action
			g_t[1] = *(long *)(g_t[5]+4);		// move
			g_sp->hitag = *(long *)(g_t[5]+8);	  // Ai
			g_t[0] = g_t[2] = g_t[3] = 0;
			if(g_sp->hitag&random_angle)
				g_sp->ang = TRAND&2047;
			insptr++;
			break;
		case 7:
			insptr++;
			g_t[2] = 0;
			g_t[3] = 0;
			g_t[4] = *insptr;
			insptr++;
			break;

		case 8:
			insptr++;
			parseifelse(g_x < *insptr);
			if(g_x > MAXSLEEPDIST && hittype[g_i].timetosleep == 0)
				hittype[g_i].timetosleep = SLEEPTIME;
			break;
		case 9:
			insptr++;
			parseifelse(g_x > *insptr);
			if(g_x > MAXSLEEPDIST && hittype[g_i].timetosleep == 0)
				hittype[g_i].timetosleep = SLEEPTIME;
			break;
		case 10:
			insptr = (long *) *(insptr+1);
			break;
		case 11:
			insptr++;
			g_sp->extra = *insptr;
			insptr++;
			break;
		case 94:
			insptr++;

			if(ud.coop >= 1)
			{
				if(*insptr == 0)
				{
					for(j=0;j < ps[g_p].weapreccnt;j++)
						if( ps[g_p].weaprecs[j] == g_sp->picnum )
							break;

					parseifelse(j < ps[g_p].weapreccnt && g_sp->owner == g_i);
				}
				else if(ps[g_p].weapreccnt < 256)
				{
					ps[g_p].weaprecs[ps[g_p].weapreccnt++] = g_sp->picnum;
					parseifelse(g_sp->owner == g_i);
				}
			}
			else parseifelse(0);
			break;
		case 95:
			insptr++;
			if(g_sp->picnum == APLAYER)
				g_sp->pal = ps[g_sp->yvel].palookup;
			else g_sp->pal = hittype[g_i].tempang;
			hittype[g_i].tempang = 0;
			break;
		case 97:
			insptr++;
			if(Sound[g_sp->yvel].num == 0)
				spritesound(g_sp->yvel,g_i);
			break;
		case 96:
			insptr++;

			if( ud.multimode > 1 && g_sp->picnum == APLAYER )
			{
				if(ps[otherp].quick_kick == 0)
					ps[otherp].quick_kick = 14;
			}
			else if(g_sp->picnum != APLAYER && ps[g_p].quick_kick == 0)
				ps[g_p].quick_kick = 14;
			break;
		case 28:
			insptr++;

			j = ((*insptr)-g_sp->xrepeat)<<1;
			if( klabs(j) > 2 ) g_sp->xrepeat += ksgn(j);

			insptr++;

			j = ((*insptr)-g_sp->yrepeat)<<1;
			if( klabs(j) > 2 ) g_sp->yrepeat += ksgn(j);

			insptr++;

			break;
		case 13:
			insptr++;
			shoot(g_i,(short)*insptr);
			insptr++;
			break;
		case 87:
			insptr++;
			if( Sound[*insptr].num == 0 )
				spritesound((short) *insptr,g_i);
			insptr++;
			break;
		case 89:
			insptr++;
			if( Sound[*insptr].num > 0 )
				stopsound((short)*insptr);
			insptr++;
			break;
		case 92:
			insptr++;
			if(g_p == screenpeek || ud.coop==1)
				spritesound((short) *insptr,ps[screenpeek].i);
			insptr++;
			break;
		case 15:
			insptr++;
			spritesound((short) *insptr,g_i);
			insptr++;
			break;
		case 84:
			insptr++;
			ps[g_p].tipincs = 26;
			break;
		case 16:
			insptr++;
			g_sp->xoffset = 0;
			g_sp->yoffset = 0;
//			  if(!gotz)
			{
				long c;

				if( floorspace(g_sp->sectnum) )
					c = 0;
				else
				{
					if( ceilingspace(g_sp->sectnum) || sector[g_sp->sectnum].lotag == 2)
						c = 176/6;
					else c = 176;
				}

				if( hittype[g_i].cgg <= 0 || (sector[g_sp->sectnum].floorstat&2) )
				{
					getglobalz(g_i);
					hittype[g_i].cgg = 6;
				}
				else hittype[g_i].cgg --;

				if( g_sp->z < (hittype[g_i].floorz-FOURSLEIGHT) )
				{
					g_sp->zvel += c;
					g_sp->z+=g_sp->zvel;

					if(g_sp->zvel > 6144) g_sp->zvel = 6144;
				}
				else
				{
					g_sp->z = hittype[g_i].floorz - FOURSLEIGHT;

					if( badguy(g_sp) || ( g_sp->picnum == APLAYER && g_sp->owner >= 0) )
					{

						if( g_sp->zvel > 3084 && g_sp->extra <= 1)
						{
							if(g_sp->pal != 1 && g_sp->picnum != DRONE)
							{
								if(g_sp->picnum == APLAYER && g_sp->extra > 0)
									goto SKIPJIBS;
								guts(g_sp,JIBS6,15,g_p);
								spritesound(SQUISHED,g_i);
								spawn(g_i,BLOODPOOL);
							}

							SKIPJIBS:

							hittype[g_i].picnum = SHOTSPARK1;
							hittype[g_i].extra = 1;
							g_sp->zvel = 0;
						}
						else if(g_sp->zvel > 2048 && sector[g_sp->sectnum].lotag != 1)
						{

							j = g_sp->sectnum;
							pushmove(&g_sp->x,&g_sp->y,&g_sp->z,&j,128L,(4L<<8),(4L<<8),CLIPMASK0);
							if(j != g_sp->sectnum && j >= 0 && j < MAXSECTORS)
								changespritesect(g_i,j);

							spritesound(THUD,g_i);
						}
					}
					if(sector[g_sp->sectnum].lotag == 1)
						switch (g_sp->picnum)
						{
							case OCTABRAIN:
							case COMMANDER:
							case DRONE:
								break;
							default:
								g_sp->z += (24<<8);
								break;
						}
					else g_sp->zvel = 0;
				}
			}

			break;
		case 4:
		case 12:
		case 18:
			return 1;
		case 30:
			insptr++;
			return 1;
		case 2:
			insptr++;
			if( ps[g_p].ammo_amount[*insptr] >= max_ammo_amount[*insptr] )
			{
				killit_flag = 2;
				break;
			}
			addammo( *insptr, &ps[g_p], *(insptr+1) );
			if(ps[g_p].curr_weapon == KNEE_WEAPON)
				if( ps[g_p].gotweapon[*insptr] )
					addweapon( &ps[g_p], *insptr );
			insptr += 2;
			break;
		case 86:
			insptr++;
			lotsofmoney(g_sp,*insptr);
			insptr++;
			break;
		case 88:
			insptr++;
			ps[g_p].actors_killed += *insptr;
			insptr++;
			hittype[g_i].actorstayput = -1;
			break;
		case 93:
			insptr++;
			spriteglass(g_i,*insptr);
			insptr++;
			break;
		case 22:
			insptr++;
			killit_flag = 1;
			break;
		case 23:
			insptr++;
			if( ps[g_p].gotweapon[*insptr] == 0 ) addweapon( &ps[g_p], *insptr );
			else if( ps[g_p].ammo_amount[*insptr] >= max_ammo_amount[*insptr] )
			{
				 killit_flag = 2;
				 break;
			}
			addammo( *insptr, &ps[g_p], *(insptr+1) );
			insptr+=2;
			break;
		case 68:
			insptr++;
			printf(gamedef_text.text_144,*insptr);
			insptr++;
			break;
		case 69:
			insptr++;
			ps[g_p].timebeforeexit = *insptr;
			ps[g_p].customexitsound = -1;
			ud.eog = 1;
			insptr++;
			break;
		case 25:
			insptr++;

			j = sprite[ps[g_p].i].extra;

			if(g_sp->picnum != ATOMICHEALTH)
			{
				if( j > max_player_health && *insptr > 0 )
				{
					insptr++;
					break;
				}
				else
				{
					if(j > 0)
						j += *insptr;
					if ( j > max_player_health && *insptr > 0 )
						j = max_player_health;
				}
			}
			else
			{
				if( j > 0 )
					j += *insptr;
				if ( j > (max_player_health<<1) )
					j = (max_player_health<<1);
			}

			if(j < 0) j = 0;

			if(ud.god == 0)
			{
				if(*insptr > 0)
				{
					if( ( j - *insptr ) < (max_player_health>>2) &&
						j >= (max_player_health>>2) )
							spritesound(DUKE_GOTHEALTHATLOW,ps[g_p].i);

					ps[g_p].last_extra = j;
				}

				sprite[ps[g_p].i].extra = j;
			}

			insptr++;
			break;
		case 17:
			{
				long *tempscrptr;

				tempscrptr = insptr+2;

				insptr = (long *) *(insptr+1);
				while(1) if(parse()) break;
				insptr = tempscrptr;
			}
			break;
		case 29:
			insptr++;
			while(1) if(parse()) break;
			break;
		case 32:
			g_t[0]=0;
			insptr++;
			g_t[1] = *insptr;
			insptr++;
			g_sp->hitag = *insptr;
			insptr++;
			if(g_sp->hitag&random_angle)
				g_sp->ang = TRAND&2047;
			break;
		case 31:
			insptr++;
			if(g_sp->sectnum >= 0 && g_sp->sectnum < MAXSECTORS)
				spawn(g_i,*insptr);
			insptr++;
			break;
		case 33:
			insptr++;
			parseifelse( hittype[g_i].picnum == *insptr);
			break;
		case 21:
			insptr++;
			parseifelse(g_t[5] == *insptr);
			break;
		case 34:
			insptr++;
			parseifelse(g_t[4] == *insptr);
			break;
		case 35:
			insptr++;
			parseifelse(g_t[2] >= *insptr);
			break;
		case 36:
			insptr++;
			g_t[2] = 0;
			break;
		case 37:
			{
				short dnum;

				insptr++;
				dnum = *insptr;
				insptr++;

				if(g_sp->sectnum >= 0 && g_sp->sectnum < MAXSECTORS)
					for(j=(*insptr)-1;j>=0;j--)
				{
					if(g_sp->picnum == BLIMP && dnum == SCRAP1)
						s = 0;
					else s = (TRAND%3);

					l = EGS(g_sp->sectnum,
							g_sp->x,g_sp->y,g_sp->z-(16<<8),
							dnum+s,g_sp->shade,32+(TRAND&15),32+(TRAND&15),
							TRAND&2047,(TRAND&127)+32,
							-(TRAND&2047),g_i,5);
					if(g_sp->picnum == BLIMP && dnum == SCRAP1)
						sprite[l].yvel = weaponsandammosprites[j%14];
					else sprite[l].yvel = -1;
					sprite[l].pal = g_sp->pal;
				}
				insptr++;
			}
			break;
		case 52:
			insptr++;
			g_t[0] = (short) *insptr;
			insptr++;
			break;
		case 40:
			insptr++;
			g_sp->cstat = (short) *insptr;
			insptr++;
			break;
		case 41:
			insptr++;
			parseifelse(g_t[1] == *insptr);
			break;
		case 42:
			insptr++;

//AddLog("resetplayer");				
			if(ud.multimode < 2)
			{
				if( lastsavedpos >= 0 && ud.recstat != 2 )
				{
					ps[g_p].gm = MODE_MENU;
					KB_ClearKeyDown(sc_Space);
					cmenu(15000);
				}
				else ps[g_p].gm = MODE_RESTART;

			}
			else
			{
				pickrandomspot(g_p);
				g_sp->x = hittype[g_i].bposx = ps[g_p].bobposx = ps[g_p].oposx = ps[g_p].posx;
				g_sp->y = hittype[g_i].bposy = ps[g_p].bobposy = ps[g_p].oposy =ps[g_p].posy;
				g_sp->z = hittype[g_i].bposy = ps[g_p].oposz =ps[g_p].posz;
				updatesector(ps[g_p].posx,ps[g_p].posy,&ps[g_p].cursectnum);
				setsprite(ps[g_p].i,ps[g_p].posx,ps[g_p].posy,ps[g_p].posz+PHEIGHT);
				g_sp->cstat = 257;

				g_sp->shade = -12;
				g_sp->clipdist = 64;
				g_sp->xrepeat = 42;
				g_sp->yrepeat = 36;
				g_sp->owner = g_i;
				g_sp->xoffset = 0;
				g_sp->pal = ps[g_p].palookup;

				ps[g_p].last_extra = g_sp->extra = max_player_health;
				ps[g_p].horiz = 100;
				ps[g_p].on_crane = -1;
				ps[g_p].frag_ps = g_p;
				ps[g_p].horizoff = 0;
				ps[g_p].opyoff = 0;
				ps[g_p].wackedbyactor = -1;
				ps[g_p].shield_amount = max_armour_amount;
				ps[g_p].dead_flag = 0;
				ps[g_p].pals_time = 0;
				ps[g_p].footprintcount = 0;
				ps[g_p].weapreccnt = 0;
				ps[g_p].fta = 0;
				ps[g_p].ftq = 0;
				ps[g_p].posxv = ps[g_p].posyv = 0;


				ps[g_p].falling_counter = 0;

				hittype[g_i].extra = -1;
				hittype[g_i].owner = g_i;

				hittype[g_i].cgg = 0;
				hittype[g_i].movflag = 0;
				hittype[g_i].tempang = 0;
				hittype[g_i].actorstayput = -1;
				hittype[g_i].dispicnum = 0;
				hittype[g_i].owner = ps[g_p].i;

				resetinventory(g_p);
				resetweapons(g_p);

				cameradist = 0;
				cameraclock = totalclock;
			}
			setpal(&ps[g_p]);
//AddLog("EOF: resetplayer");

			break;
		case 43:
			parseifelse( klabs(g_sp->z-sector[g_sp->sectnum].floorz) < (32<<8) && sector[g_sp->sectnum].lotag == 1);
			break;
		case 44:
			parseifelse( sector[g_sp->sectnum].lotag == 2);
			break;
		case 46:
			insptr++;
			parseifelse(g_t[0] >= *insptr);
			break;
		case 53:
			insptr++;
			parseifelse(g_sp->picnum == *insptr);
			break;
		case 47:
			insptr++;
			g_t[0] = 0;
			break;
		case 48:
			insptr+=2;
			switch(*(insptr-1))
			{
				case 0:
					ps[g_p].steroids_amount = *insptr;
					ps[g_p].inven_icon = 2;
					break;
				case 1:
					ps[g_p].shield_amount +=		  *insptr;// 100;
					if(ps[g_p].shield_amount > max_player_health)
						ps[g_p].shield_amount = max_player_health;
					break;
				case 2:
					ps[g_p].scuba_amount =			   *insptr;// 1600;
					ps[g_p].inven_icon = 6;
					break;
				case 3:
					ps[g_p].holoduke_amount =		   *insptr;// 1600;
					ps[g_p].inven_icon = 3;
					break;
				case 4:
					ps[g_p].jetpack_amount =		   *insptr;// 1600;
					ps[g_p].inven_icon = 4;
					break;
				case 6:
					switch(g_sp->pal)
					{
						case  0: ps[g_p].got_access |= 1;break;
						case 21: ps[g_p].got_access |= 2;break;
						case 23: ps[g_p].got_access |= 4;break;
					}
					break;
				case 7:
					ps[g_p].heat_amount = *insptr;
					ps[g_p].inven_icon = 5;
					break;
				case 9:
					ps[g_p].inven_icon = 1;
					ps[g_p].firstaid_amount = *insptr;
					break;
				case 10:
					ps[g_p].inven_icon = 7;
					ps[g_p].boot_amount = *insptr;
					break;
			}
			insptr++;
			break;
		case 50:
			hitradius(g_i,*(insptr+1),*(insptr+2),*(insptr+3),*(insptr+4),*(insptr+5));
			insptr+=6;
			break;
		case 51:
			{
				insptr++;

				l = *insptr;
				j = 0;

				s = g_sp->xvel;

				if( (l&8) && ps[g_p].on_ground && (sync[g_p].bits&2) )
					   j = 1;
				else if( (l&16) && ps[g_p].jumping_counter == 0 && !ps[g_p].on_ground &&
					ps[g_p].poszv > 2048 )
						j = 1;
				else if( (l&32) && ps[g_p].jumping_counter > 348 )
					   j = 1;
				else if( (l&1) && s >= 0 && s < 8)
					   j = 1;
				else if( (l&2) && s >= 8 && !(sync[g_p].bits&(1<<5)) )
					   j = 1;
				else if( (l&4) && s >= 8 && sync[g_p].bits&(1<<5) )
					   j = 1;
				else if( (l&64) && ps[g_p].posz < (g_sp->z-(48<<8)) )
					   j = 1;
				else if( (l&128) && s <= -8 && !(sync[g_p].bits&(1<<5)) )
					   j = 1;
				else if( (l&256) && s <= -8 && (sync[g_p].bits&(1<<5)) )
					   j = 1;
				else if( (l&512) && ( ps[g_p].curr_weapon == KNEE_WEAPON && ps[g_p].kickback_pic > 0 ) )
					   j = 1;
				else if( (l&1024) && sprite[ps[g_p].i].xrepeat < 32 )
					   j = 1;
				else if( (l&2048) && ps[g_p].jetpack_on )
					   j = 1;
				else if( (l&4096) && ps[g_p].steroids_amount > 0 && ps[g_p].steroids_amount < 400 )
					   j = 1;
				else if( (l&8192) && ps[g_p].on_ground)
					   j = 1;
				else if( (l&16384) && sprite[ps[g_p].i].xrepeat > 32 && sprite[ps[g_p].i].extra > 0 && ps[g_p].timebeforeexit == 0 )
					   j = 1;
				else if( (l&32768) && sprite[ps[g_p].i].extra <= 0)
					   j = 1;
				else if( (l&65536L) )
				{
					if(g_sp->picnum == APLAYER && ud.multimode > 1)
						j = getincangle(ps[otherp].ang,getangle(ps[g_p].posx-ps[otherp].posx,ps[g_p].posy-ps[otherp].posy));
					else
						j = getincangle(ps[g_p].ang,getangle(g_sp->x-ps[g_p].posx,g_sp->y-ps[g_p].posy));

					if( j > -128 && j < 128 )
						j = 1;
					else
						j = 0;
				}

				parseifelse((long) j);

			}
			break;
		case 56:
			insptr++;
			parseifelse(g_sp->extra <= *insptr);
			break;
		case 58:
			insptr += 2;
			guts(g_sp,*(insptr-1),*insptr,g_p);
			insptr++;
			break;
		case 59:
			insptr++;
			if(g_sp->owner >= 0 && sprite[g_sp->owner].picnum == *insptr)
				parseifelse(1);
			else parseifelse(hittype[g_i].picnum == *insptr);
			break;
		case 61:
			insptr++;
			forceplayerangle(&ps[g_p]);
			return 0;
		case 62:
			insptr++;
			parseifelse( (( hittype[g_i].floorz - hittype[g_i].ceilingz ) >> 8 ) < *insptr);
			break;
		case 63:
			parseifelse( sync[g_p].bits&(1<<29));
			break;
		case 64:
			parseifelse(sector[g_sp->sectnum].ceilingstat&1);
			break;
		case 65:
			parseifelse(ud.multimode > 1);
			break;
		case 66:
			insptr++;
			if( sector[g_sp->sectnum].lotag == 0 )
			{
				neartag(g_sp->x,g_sp->y,g_sp->z-(32<<8),g_sp->sectnum,g_sp->ang,&neartagsector,&neartagwall,&neartagsprite,&neartaghitdist,768L,1);
				if( neartagsector >= 0 && isanearoperator(sector[neartagsector].lotag) )
					if( (sector[neartagsector].lotag&0xff) == 23 || sector[neartagsector].floorz == sector[neartagsector].ceilingz )
						if( (sector[neartagsector].lotag&16384) == 0 )
							if( (sector[neartagsector].lotag&32768) == 0 )
						{
							j = headspritesect[neartagsector];
							while(j >= 0)
							{
								if(sprite[j].picnum == ACTIVATOR)
									break;
								j = nextspritesect[j];
							}
							if(j == -1)
								operatesectors(neartagsector,g_i);
						}
			}
			break;
		case 67:
			parseifelse(ceilingspace(g_sp->sectnum));
			break;

		case 74:
			insptr++;
			if(g_sp->picnum != APLAYER)
				hittype[g_i].tempang = g_sp->pal;
			g_sp->pal = *insptr;
			insptr++;
			break;

		case 77:
			insptr++;
			g_sp->picnum = *insptr;
			insptr++;
			break;

		case 70:
			parseifelse( dodge(g_sp) == 1);
			break;
		case 71:
			if( badguy(g_sp) )
				parseifelse( ud.respawn_monsters );
			else if( inventory(g_sp) )
				parseifelse( ud.respawn_inventory );
			else
				parseifelse( ud.respawn_items );
			break;
		case 72:
			insptr++;
//			  getglobalz(g_i);
			parseifelse( (hittype[g_i].floorz - g_sp->z) <= ((*insptr)<<8));
			break;
		case 73:
			insptr++;
//			  getglobalz(g_i);
			parseifelse( ( g_sp->z - hittype[g_i].ceilingz ) <= ((*insptr)<<8));
			break;
		case 14:

			insptr++;
			ps[g_p].pals_time = *insptr;
			insptr++;
			for(j=0;j<3;j++)
			{
				ps[g_p].pals[j] = *insptr;
				insptr++;
			}
			break;

/*		  case 74:
			insptr++;
			getglobalz(g_i);
			parseifelse( (( hittype[g_i].floorz - hittype[g_i].ceilingz ) >> 8 ) >= *insptr);
			break;
*/
		case 78:
			insptr++;
			parseifelse( sprite[ps[g_p].i].extra < *insptr);
			break;

		case 75:
			{
				insptr++;
				j = 0;
				switch(*(insptr++))
				{
					case 0:if( ps[g_p].steroids_amount != *insptr)
						   j = 1;
						break;
					case 1:if(ps[g_p].shield_amount != max_player_health )
							j = 1;
						break;
					case 2:if(ps[g_p].scuba_amount != *insptr) j = 1;break;
					case 3:if(ps[g_p].holoduke_amount != *insptr) j = 1;break;
					case 4:if(ps[g_p].jetpack_amount != *insptr) j = 1;break;
					case 6:
						switch(g_sp->pal)
						{
							case  0: if(ps[g_p].got_access&1) j = 1;break;
							case 21: if(ps[g_p].got_access&2) j = 1;break;
							case 23: if(ps[g_p].got_access&4) j = 1;break;
						}
						break;
					case 7:if(ps[g_p].heat_amount != *insptr) j = 1;break;
					case 9:
						if(ps[g_p].firstaid_amount != *insptr) j = 1;break;
					case 10:
						if(ps[g_p].boot_amount != *insptr) j = 1;break;
				}

				parseifelse(j);
				break;
			}
		case 38:
			insptr++;
			if( ps[g_p].knee_incs == 0 && sprite[ps[g_p].i].xrepeat >= 40 )
				if( cansee(g_sp->x,g_sp->y,g_sp->z-(4<<8),g_sp->sectnum,ps[g_p].posx,ps[g_p].posy,ps[g_p].posz+(16<<8),sprite[ps[g_p].i].sectnum) )
			{
				ps[g_p].knee_incs = 1;
				if(ps[g_p].weapon_pos == 0)
					ps[g_p].weapon_pos = -1;
				ps[g_p].actorsqu = g_i;
			}
			break;
		case 90:
			{
				short s1;

				s1 = g_sp->sectnum;

				j = 0;

					updatesector(g_sp->x+108,g_sp->y+108,&s1);
					if( s1 == g_sp->sectnum )
					{
						updatesector(g_sp->x-108,g_sp->y-108,&s1);
						if( s1 == g_sp->sectnum )
						{
							updatesector(g_sp->x+108,g_sp->y-108,&s1);
							if( s1 == g_sp->sectnum )
							{
								updatesector(g_sp->x-108,g_sp->y+108,&s1);
								if( s1 == g_sp->sectnum )
									j = 1;
							}
						}
					}
					parseifelse( j );
			}

			break;
		case 80:
			insptr++;
			FTA(*insptr,&ps[g_p]);
			insptr++;
			break;
		case 81:
			parseifelse( floorspace(g_sp->sectnum));
			break;
		case 82:
			parseifelse( (hittype[g_i].movflag&49152) > 16384 );
			break;
		case 83:
			insptr++;
			switch(g_sp->picnum)
			{
				case FEM1:
				case FEM2:
				case FEM3:
				case FEM4:
				case FEM5:
				case FEM6:
				case FEM7:
				case FEM8:
				case FEM9:

				case PODFEM1:
				case NAKED1:
				case STATUE:
					if(g_sp->yvel) operaterespawns(g_sp->yvel);
					break;
				default:
					if(g_sp->hitag >= 0) operaterespawns(g_sp->hitag);
					break;
			}
			break;
		case 85:
			insptr++;
			parseifelse( g_sp->pal == *insptr);
			break;

		default:
			killit_flag = 1;
			break;
	}
	return 0;
}


void execute(short i,short p,long x)
{
	char done;

	g_i = i;	// Sprite ID
	g_p = p;	// Player ID
	g_x = x;	// ??
	g_sp = &sprite[g_i];	// Pointer to sprite structure
	g_t = &hittype[g_i].temp_data[0];	// Sprite's 'extra' data

	if( actorscrptr[g_sp->picnum] == 0 ) return;

	insptr = 4 + (actorscrptr[g_sp->picnum]);

	killit_flag = 0;

	if(g_sp->sectnum < 0 || g_sp->sectnum >= MAXSECTORS)
	{
		if(badguy(g_sp))
			ps[g_p].actors_killed++;
		deletesprite(g_i);
		return;
	}

	if(g_t[4])
	{
		g_sp->lotag += TICSPERFRAME;
		if(g_sp->lotag > *(long *)(g_t[4]+16) )
		{
			g_t[2]++;
			g_sp->lotag = 0;
			g_t[3] +=  *(long *)( g_t[4]+12 );
		}
		if( klabs(g_t[3]) >= klabs( *(long *)(g_t[4]+4) * *(long *)(g_t[4]+12) ) )
			g_t[3] = 0;
	}

	do
		done = parse();
	while( done == 0 );

	if(killit_flag == 1)
	{
		// if player was set to squish, first stop that...
		if(ps[g_p].actorsqu == g_i)
			ps[g_p].actorsqu = -1;
		deletesprite(g_i);
	}
	else
	{
		move();

		if( g_sp->statnum == 1)
		{
			if( badguy(g_sp) )
			{
				if( g_sp->xrepeat > 60 ) return;
				if( ud.respawn_monsters == 1 && g_sp->extra <= 0 ) return;
			}
			else if( ud.respawn_items == 1 && (g_sp->cstat&32768) ) return;

			if(hittype[g_i].timetosleep > 1)
				hittype[g_i].timetosleep--;
			else if(hittype[g_i].timetosleep == 1)
				 changespritestat(g_i,2);
		}

		else if(g_sp->statnum == 6)
			switch(g_sp->picnum)
			{
				case RUBBERCAN:
				case EXPLODINGBARREL:
				case WOODENHORSE:
				case HORSEONSIDE:
				case CANWITHSOMETHING:
				case FIREBARREL:
				case NUKEBARREL:
				case NUKEBARRELDENTED:
				case NUKEBARRELLEAKED:
				case TRIPBOMB:
				case EGG:
					if(hittype[g_i].timetosleep > 1)
						hittype[g_i].timetosleep--;
					else if(hittype[g_i].timetosleep == 1)
						changespritestat(g_i,2);
					break;
			}
	}
}





// "Duke 2000"
// "Virchua Duke"
// "Son of Death
// "Cromium"
// "Potent"
// "Flotsom"

// Volume One
// "Duke is brain dead",
// "BOOT TO THE HEAD"
// Damage too duke
// Weapons are computer cont.  Only logical thinking
// is disappearing.
// " Flips! "
// Flash on screen, inst.
// "BUMS"
// "JAIL"/"MENTAL WARD (Cop code for looney?  T. asks Cop.)"
// "GUTS OR GLORY"

// ( Duke's Mission

// Duke:	"Looks like some kind of transporter...?"
// Byte:	"...YES"

// Duke:	"Waa, here goes nuthin'. "
// (Duke puts r. arm in device)

// Duke:	AAAAHHHHHHHHHHHHHHHHHHHHHHHHH!!!
// (Duke's arm is seved.)
// Byte:	NO.NO.NO.NO.NO.NO.NO...
// ( Byte directs duke to the nearest heat source)
// (Shut Up Mode)
// ( Duke Staggers, end of arm bleeding, usual oozing arm guts. )
// Byte: Left, Left, Left, Left, Right.
// ( Duke, loozing consc, trips on broken pipe, )
// ( hits temple on edge of step. )
// ( Rats everywhere, byte pushing them away with weapon,
// ( eventually covered, show usual groosums, Duke appears dead
// ( Duke wakes up, in hospital, vision less blurry
// ( Hospital doing brain scan, 1/3 cran. mass MISSING!
// Doc: Hummm?	( Grabbing upper lip to "appear" smart. )

// Stand back boys

// Schrapnel has busted my scull!
// Now I'm insane, Mental ward, got to escape.
// Search light everywhere.

// (M)Mendor, The Tree Dweller.
// (M)BashMan, The Destructor.
// (M)Lash, The Scavenger.
// (F)Mag, The Slut.
// (F)
// NRA OR SOMETHIN'

// Duke Nukem
// 5th Dimention
// Pentagon Man!


// I Hope your not stupid!
// The 70's meet the future.
// Dirty Harry style.  70's music with futuristic edge
// The Instant De-Welder(tm)
// I think I'm going to puke...
// Badge attitude.
// He's got a Badge(LA 3322), a Bulldog, a Bronco (beat up/bondoed).
// Gfx:
// Lite rail systems
// A church.  Large cross
// Sniper Scope,
// Really use the phone
// The Boiler Room
// The IRS, nuking other government buildings?
// You wouldn't have a belt of booz, would ya?
// Slow turning signes
// More persise shooting/descructions
// Faces, use phoneoms and its lookup.	Talking, getting in fights.
// Drug dealers, pimps, and all galore
// Weapons, Anything lying around.
// Trees to clime, burning trees.
// Sledge Hammer, Sledge hammer with Spike
// sancurary, get away from it all.
// Goodlife = ( War + Greed ) / Peace
// Monsterism			(ACTION)
// Global Hunter		(RPG)
// Slick a Wick			(PUZZLE)
// Roach Condo			(FUNNY)
// AntiProfit			(RPG)
// Pen Patrol			(TD SIM)
// 97.5 KPIG! - Wanker County
// "Fauna" - Native Indiginouns Animal Life
