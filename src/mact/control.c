/* Private source-assisted CONTROL prototype, not original MACT source.
 * Shared flag/key/click algorithms: Jonathon Fowler's 2005 JFMact CONTROL.C,
 * explicitly derived by its author from MACT386.LIB disassembly.
 * Its 2004 JFDuke predecessor was inspected first: modern input-system glue,
 * not the native DOS implementation. Public types/headers retain notices.
 * ROTT RT_IN.C supplies related joystick scale/filter/setup ancestry.
 * Native ABI/control flow supplies shared selected-device state, DOS game-port
 * and external-controller protocol details, calibration callbacks and messages.
 * No empty stubs, aliases, fake layout fields, target instruction initializer
 * or native OBJ patch is used. Behavior and whole-byte identity remain unproved.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include <i86.h>
#include "types.h"
#include "keyboard.h"
#include "mouse.h"
#include "util_lib.h"
#include "control.h"
#include "_control.h"
#include "watcom.h"

/* All fields correspond to actual read/written external protocol members. */
typedef struct {
    word id, vector;
    int32 axes[6];
    uint32 buttons;
    byte buttonmap[32][2];
    byte analogmap[6];
    word command;
    byte digitalmap[6][2];
} external_control;

extern void ServiceEvents(void);

boolean CONTROL_RudderEnabled = false;
boolean CONTROL_MouseEnabled = false;
boolean CONTROL_ExternalEnabled = false;
boolean CONTROL_JoystickEnabled = false;
byte CONTROL_JoystickPort = 0;
static int32 CONTROL_UserInputDelay = -1;
static int32 CONTROL_MouseSensitivity = DEFAULTMOUSESENSITIVITY;
static int32 CONTROL_JoyXAxis = 0, CONTROL_JoyYAxis = 0;
static int32 CONTROL_JoyXAxis2 = 0, CONTROL_JoyYAxis2 = 0;
static boolean CONTROL_HatEnabled = false, CONTROL_ThrottleEnabled = false;
static boolean CONTROL_FlightStickMode = false;
static int32 CONTROL_NumButtons = MAXBUTTONS, CONTROL_NumAxes = MAXAXES;

static int32 (*GetTime)(void);
static boolean CONTROL_Started;
static int32 ticrate;
static int32 CONTROL_DoubleClickSpeed;

static controlbuttontype CONTROL_DeviceButtonMapping[MAXBUTTONS];
static int32 CONTROL_DeviceButtonState[MAXBUTTONS];
static int32 CONTROL_ButtonClickedTime[MAXBUTTONS];
static controlflags CONTROL_Flags[CONTROL_NUM_FLAGS];
static JoystickDef JoyDefs[MaxJoys];
static boolean CONTROL_ButtonClickedState[MAXBUTTONS];
static boolean CONTROL_ButtonClicked[MAXBUTTONS];
static byte CONTROL_ButtonClickedCount[MAXBUTTONS];
static controlkeymaptype CONTROL_KeyMapping[CONTROL_NUM_FLAGS];

static controlaxistype CONTROL_LastAxes[MAXAXES];
static int32 CONTROL_AxesScale[MAXAXES];
static controlaxistype CONTROL_Axes[MAXAXES];
static controlaxismaptype CONTROL_AxesMap[MAXAXES];

static boolean CONTROL_UserInputCleared[3];
static external_control *CONTROL_External;
boolean CONTROL_JoysPresent[MaxJoys];

uint32 CONTROL_ButtonHeldState1, CONTROL_ButtonHeldState2;
boolean CONTROL_MousePresent;
uint32 CONTROL_ButtonState1, CONTROL_ButtonState2;

extern byte Joy_mask;
extern int32 Joy_x1,Joy_y1,Joy_x2,Joy_y2;
extern void JoyStick_Vals(void);
/* Accepted symbolic joystick.asm really clobbers these registers. */
#pragma aux JoyStick_Vals modify exact [eax ebx ecx edx esi edi]
void CONTROL_GetMouseDelta(int32 *,int32 *);
byte CONTROL_GetMouseButtons(void);
boolean CONTROL_StartMouse(void);
void CONTROL_GetJoyAbs(int32);
void CONTROL_FilterJoyDelta(int32,int32 *,int32 *);
void CONTROL_GetJoyDelta(int32,int32 *,int32 *,int32 *,int32 *);
byte CONTROL_JoyButtons(int32);
void CONTROL_SetJoyScale(int32);
void CONTROL_SetupJoy(int32,int32,int32,int32,int32,int32,int32);
boolean CONTROL_StartJoy(int32);
void CONTROL_ShutJoy(int32);
void CONTROL_ExternalStartup(void);
void CONTROL_ExternalSetup(void);
void CONTROL_PollExternalControl(void);
int32 CONTROL_GetTime(void);
void CONTROL_CheckRange(int32);
void CONTROL_SetFlag(int32,boolean);
boolean CONTROL_KeyboardFunctionPressed(int32);
void CONTROL_ClearKeyboardFunction(int32);
void CONTROL_PrintKeyMap(void);
void CONTROL_PrintControlFlag(int32);
void CONTROL_ClearFlags(void);
void CONTROL_GetDeviceButtons(void);
void CONTROL_DigitizeAxis(int32);
void CONTROL_ScaleAxis(int32);
void CONTROL_ApplyAxis(int32,ControlInfo *);
void CONTROL_PollDevices(ControlInfo *);
void CONTROL_AxisFunctionState(boolean *);
void CONTROL_ButtonFunctionState(boolean *);

void CONTROL_GetMouseDelta(int32 *x,int32 *y)
{
    MOUSE_GetDelta(x,y);
    /* Native reduces the smaller component; 2005 commented sketch swaps it. */
    if (labs(*x)>labs(*y)) *y/=3; else *x/=3;
    *x *= 32; *y *= 96;
    *x = FixedMulShift(*x,CONTROL_MouseSensitivity,15);
}

int32 CONTROL_GetMouseSensitivity(void)
{
	return (CONTROL_MouseSensitivity - MINIMUMMOUSESENSITIVITY);
}

void CONTROL_SetMouseSensitivity(int32 newsensitivity)
{
	CONTROL_MouseSensitivity = newsensitivity + MINIMUMMOUSESENSITIVITY;
}

byte CONTROL_GetMouseButtons(void) { return MOUSE_GetButtons(); }

boolean CONTROL_StartMouse(void) { CONTROL_NumButtons=3; return MOUSE_Init(); }

void CONTROL_GetJoyAbs(int32 joy)
{
    if (joy) {
        Joy_mask=12; JoyStick_Vals();
        CONTROL_JoyXAxis=Joy_x2; CONTROL_JoyYAxis=Joy_y2;
    } else {
        Joy_mask=3|(CONTROL_RudderEnabled<<2);
        Joy_mask|=(CONTROL_ThrottleEnabled|CONTROL_HatEnabled)<<3;
        JoyStick_Vals();
        CONTROL_JoyXAxis=Joy_x1; CONTROL_JoyYAxis=Joy_y1;
        CONTROL_JoyXAxis2=Joy_x2; CONTROL_JoyYAxis2=Joy_y2;
    }
}

void CONTROL_FilterJoyDelta(int32 joy,int32 *dx,int32 *dy)
{
    JoystickDef *d=JoyDefs+joy; int32 x=*dx,y=*dy;
    /* Related ROTT clamp/threshold branches, actual unshifted native scale. */
    if(x<d->threshMinX) { if(x<d->joyMinX)x=d->joyMinX;
        x=-(x-d->threshMinX); x*=d->joyMultXL; *dx=x; *dx=-x; }
    else if(x>d->threshMaxX) { if(x>d->joyMaxX)x=d->joyMaxX;
        *dx=(x-d->threshMaxX)*d->joyMultXH; } else *dx=0;
    if(y<d->threshMinY) { if(y<d->joyMinY)y=d->joyMinY;
        y=-(y-d->threshMinY); y*=d->joyMultYL; *dy=y; *dy=-y; }
    else if(y>d->threshMaxY) { if(y>d->joyMaxY)y=d->joyMaxY;
        *dy=(y-d->threshMaxY)*d->joyMultYH; } else *dy=0;
}

void CONTROL_GetJoyDelta(int32 joy,int32 *x,int32 *y,int32 *r,int32 *t)
{
    CONTROL_GetJoyAbs(joy); *x=CONTROL_JoyXAxis; *y=CONTROL_JoyYAxis;
    CONTROL_FilterJoyDelta(joy,x,y);
    if(!joy&&(CONTROL_RudderEnabled||CONTROL_ThrottleEnabled)) {
        *r=CONTROL_JoyXAxis2; *t=CONTROL_JoyYAxis2; CONTROL_FilterJoyDelta(1,r,t);
    }
}

byte CONTROL_JoyButtons(int32 joy)
{
    byte buttons=inp(0x201),mask;
    if(joy) buttons>>=6; else buttons>>=4;
    if(!joy)mask=15;else mask=3;
    buttons=(buttons&mask)^mask;
    if(CONTROL_FlightStickMode) {
        switch(buttons) {
        case 3: buttons=128;break;
        case 7: buttons=64;break;
        case 11: buttons=32;break;
        case 15: buttons=16;break;
        }
    } else if(CONTROL_HatEnabled) {
        switch(CONTROL_JoyYAxis2/100) {
        case 0:buttons|=16;break;
        case 1:buttons|=32;break;
        case 2:buttons|=64;break;
        case 3:buttons|=128;break;
        }
    }
    return buttons;
}

void CONTROL_SetJoyScale(int32 joy)
{
    JoystickDef *d; int32 range,maximum=0xa00;
    d=&JoyDefs[joy];
    range=d->threshMinX-d->joyMinX; if(!range)range=1; d->joyMultXL=maximum/range;
    range=d->joyMaxX-d->threshMaxX; if(!range)range=1; d->joyMultXH=maximum/range;
    range=d->threshMinY-d->joyMinY; if(!range)range=1; d->joyMultYL=maximum/range;
    range=d->joyMaxY-d->threshMaxY; if(!range)range=1; d->joyMultYH=maximum/range;
}

void CONTROL_SetupJoy(int32 joy,int32 minx,int32 maxx,int32 miny,int32 maxy,int32 centerx,int32 centery)
{
    JoystickDef *d=JoyDefs+joy; int32 dead;
    d->joyMinX=minx; d->joyMaxX=maxx; dead=(maxx-minx)/12; if(dead<1)dead=1;
    d->threshMinX=centerx-dead; d->threshMaxX=centerx+dead;
    d->joyMinY=miny; d->joyMaxY=maxy; dead=(maxy-miny)/12; if(dead<1)dead=1;
    d->threshMinY=centery-dead; d->threshMaxY=centery+dead;
    CONTROL_SetJoyScale(joy);
}

void CONTROL_CenterJoystick(void (*center)(void),void (*upper)(void),void (*lower)(void),void (*throttle)(void),void (*rudder)(void))
{
    UserInput ui; int32 cx,cy,minx,miny,maxx,maxy,cr,ct;
    center(); memset(&ui,0,sizeof(ui));
    while(!ui.button0&&!ui.button1) CONTROL_GetUserInput(&ui);
    CONTROL_GetJoyAbs(CONTROL_JoystickPort); cx=CONTROL_JoyXAxis;cy=CONTROL_JoyYAxis;
    CONTROL_ClearUserInput(&ui);
    upper();memset(&ui,0,sizeof(ui));
    while(!ui.button0&&!ui.button1) CONTROL_GetUserInput(&ui);
    CONTROL_GetJoyAbs(CONTROL_JoystickPort);minx=CONTROL_JoyXAxis;miny=CONTROL_JoyYAxis;
    CONTROL_ClearUserInput(&ui);
    lower();memset(&ui,0,sizeof(ui));
    while(!ui.button0&&!ui.button1) CONTROL_GetUserInput(&ui);
    CONTROL_GetJoyAbs(CONTROL_JoystickPort);maxx=CONTROL_JoyXAxis;maxy=CONTROL_JoyYAxis;
    CONTROL_ClearUserInput(&ui);
    if(labs(minx-maxx)<cx/4){minx=0;maxx=cx*2;}
    if(labs(miny-maxy)<cy/4){miny=0;maxy=cy*2;}
    if(CONTROL_ThrottleEnabled) {
        throttle();memset(&ui,0,sizeof(ui));
        while(!ui.button0&&!ui.button1) CONTROL_GetUserInput(&ui);
        CONTROL_GetJoyAbs(CONTROL_JoystickPort);ct=CONTROL_JoyYAxis2;CONTROL_ClearUserInput(&ui);
    }
    if(CONTROL_RudderEnabled) {
        rudder();memset(&ui,0,sizeof(ui));
        while(!ui.button0&&!ui.button1) CONTROL_GetUserInput(&ui);
        CONTROL_GetJoyAbs(CONTROL_JoystickPort);cr=CONTROL_JoyXAxis2;CONTROL_ClearUserInput(&ui);
    }
    CONTROL_SetupJoy(CONTROL_JoystickPort,minx,maxx,miny,maxy,cx,cy);
    minx=0;miny=0;maxx=cr*2;maxy=ct*2;
    if(CONTROL_RudderEnabled||CONTROL_FlightStickMode)
        CONTROL_SetupJoy(1,minx,maxx,miny,maxy,cr,ct);
}

boolean CONTROL_StartJoy(int32 joy)
{
    int32 x,y;
    CONTROL_GetJoyAbs(joy);x=CONTROL_JoyXAxis;y=CONTROL_JoyYAxis;
    if(!x||x>4990)return false;
    if(!y||y>4990)return false;
    CONTROL_SetupJoy(joy,0,x*2,0,y*2,x,y);
    CONTROL_NumButtons=8;return true;
}

void CONTROL_ShutJoy(int32 joy) { CONTROL_JoysPresent[joy]=false; }

void CONTROL_ExternalStartup(void)
{
    int32 arg;
    if(CONTROL_ExternalEnabled)return;
    arg=CheckParm("control");
    if(!arg){printf("CONTROL_Startup: %s parameter is not present on the command line\n\0\0","control");return;}
    CONTROL_External=(external_control *)atol(_argv[++arg]);
    if(CONTROL_External->id!=0xdead){printf("CONTROL_Startup: External API is incompatible with this version. id=%ld\n\0\0\0",(long)CONTROL_External->id);return;}
    printf("CONTROL_Startup: External controller found on vector %x\n\0\0\0",CONTROL_External->vector);
    CONTROL_ExternalEnabled=true;
}

void CONTROL_ExternalSetup(void)
{
    int32 i,which; CONTROL_NumButtons=32;
    for(i=0;i<CONTROL_NumButtons;i++) {
        which=CONTROL_External->buttonmap[i][0];
        if(which!=BUTTONUNDEFINED)CONTROL_MapButton(which,i,false);
        which=CONTROL_External->buttonmap[i][1];
        if(which!=BUTTONUNDEFINED)CONTROL_MapButton(which,i,true);
    }
    for(i=0;i<CONTROL_NumAxes;i++) {
        which=CONTROL_External->analogmap[i];
        if(which!=AXISUNDEFINED)CONTROL_MapAnalogAxis(i,which);
        which=CONTROL_External->digitalmap[i][0];
        if(which!=AXISUNDEFINED)CONTROL_MapDigitalAxis(i,which,0);
        which=CONTROL_External->digitalmap[i][1];
        if(which!=AXISUNDEFINED)CONTROL_MapDigitalAxis(i,which,1);
    }
}

void CONTROL_PollExternalControl(void)
{
    union REGS inregs,outregs; int32 i,vector; external_control *external=CONTROL_External;
    /* Native protocol communicates through shared memory; input REGS are not initialized there. */
    if(CONTROL_ExternalEnabled) {
        external->command=1;vector=external->vector;int386(vector,&inregs,&outregs);external=CONTROL_External;
        for(i=0;i<CONTROL_NumAxes;i++)CONTROL_Axes[i].analog=external->axes[i];
    }
    CONTROL_External=external;
}

int32 CONTROL_GetTime(void)
{
	static int32 t = 0;
	t += 5;
	return t;
}

void CONTROL_CheckRange(int32 which)
{
    if(which<0||which>=CONTROL_NUM_FLAGS)Error("CONTROL_CheckRange : Index %d out of valid range for %d control flags.\0",which,CONTROL_NUM_FLAGS);
}

void CONTROL_SetFlag(int32 which, boolean active)
{
    CONTROL_CheckRange(which);
    if(CONTROL_Flags[which].toggle==INSTANT_ONOFF)CONTROL_Flags[which].active=active;
    else if(active) {
        if(!CONTROL_Flags[which].buttonheld) {
            byte nextactive=!CONTROL_Flags[which].active;
            CONTROL_Flags[which].buttonheld=true;
            CONTROL_Flags[which].active=nextactive;
        }
    } else CONTROL_Flags[which].buttonheld=false;
}

boolean CONTROL_KeyboardFunctionPressed(int32 which)
{
    boolean pressed=false;
    CONTROL_CheckRange(which);
    if(CONTROL_Flags[which].used)
        pressed=KB_KeyPressed(CONTROL_KeyMapping[which].key1)|KB_KeyPressed(CONTROL_KeyMapping[which].key2);
    return pressed;
}

void CONTROL_ClearKeyboardFunction(int32 which)
{
    CONTROL_CheckRange(which);
    if (!CONTROL_Flags[which].used) return;
    KB_KeyDown[CONTROL_KeyMapping[which].key1] = 0;
    KB_KeyDown[CONTROL_KeyMapping[which].key2] = 0;
}

void CONTROL_DefineFlag( int32 which, boolean toggle )
{
	CONTROL_CheckRange(which);

	CONTROL_Flags[which].toggle     = toggle;
	CONTROL_Flags[which].used       = true;
	CONTROL_Flags[which].active     = false;
	CONTROL_Flags[which].buttonheld = false;
	CONTROL_Flags[which].cleared    = 0;
    if(!CONTROL_FlagActive(which))Error("CONTROL_DefineFlag: assertion failed flag = %ld\n\0\0\0",which);
}

boolean CONTROL_FlagActive( int32 which )
{
	CONTROL_CheckRange(which);

	return CONTROL_Flags[which].used;
}

void CONTROL_MapKey( int32 which, kb_scancode key1, kb_scancode key2 )
{
	CONTROL_CheckRange(which);

	CONTROL_KeyMapping[which].key1 = key1;
	CONTROL_KeyMapping[which].key2 = key2;
}

void CONTROL_PrintKeyMap(void)
{
	int32 i;

	for (i=0;i<CONTROL_NUM_FLAGS;i++) {
		printf("function %2ld key1=%3x key2=%3x\n\0\0\0",
			i, CONTROL_KeyMapping[i].key1, CONTROL_KeyMapping[i].key2);
	}
}

void CONTROL_PrintControlFlag(int32 which)
{
	printf("function %2ld active=%ld used=%ld toggle=%ld buttonheld=%ld cleared=%ld\n\0\0\0",
		which, CONTROL_Flags[which].active, CONTROL_Flags[which].used,
		CONTROL_Flags[which].toggle, CONTROL_Flags[which].buttonheld,
		CONTROL_Flags[which].cleared);
}

void CONTROL_PrintAxes(void)
{
    int32 i;printf("numaxes=%ld\n\0\0\0",CONTROL_NumAxes);
    for(i=0;i<MAXAXES;i++)printf("axis=%ld analog=%ld digital1=%ld digital2=%ld\n\0",i,(long)CONTROL_AxesMap[i].analogmap,(long)CONTROL_AxesMap[i].minmap,(long)CONTROL_AxesMap[i].maxmap);
}

void CONTROL_MapButton(int32 whichfunction,int32 whichbutton,boolean doubleclicked)
{
    CONTROL_CheckRange(whichfunction);
    if(whichbutton<0||whichbutton>=CONTROL_NumButtons)Error("CONTROL_MapButton : button %d out of valid range for %d buttons.\0\0\0",whichbutton,CONTROL_NumButtons);
    if(doubleclicked)CONTROL_DeviceButtonMapping[whichbutton].doubleclicked=whichfunction;
    else CONTROL_DeviceButtonMapping[whichbutton].singleclicked=whichfunction;
}

void CONTROL_MapAnalogAxis(int32 whichaxis,int32 whichanalog)
{
    if(whichaxis<0||whichaxis>=MAXAXES)Error("CONTROL_MapAnalogAxis : axis %d out of valid range for %d axes.",whichaxis,MAXAXES);
    /* Native second upper bound tests the axis again, not whichanalog. */
    if(whichanalog<0||whichaxis>=analog_maxtype)Error("CONTROL_MapAnalogAxis : analog function %d out of valid range for %d analog functions.\0",whichanalog,analog_maxtype);
    CONTROL_AxesMap[whichaxis].analogmap=whichanalog;
}

void CONTROL_SetAnalogAxisScale(int32 whichaxis,int32 scale)
{
    if(whichaxis<0||whichaxis>=MAXAXES)Error("CONTROL_SetAnalogAxisScale : axis %d out of valid range for %d axes.\0\0\0",whichaxis,MAXAXES);
    CONTROL_AxesScale[whichaxis]=scale;
}

void CONTROL_MapDigitalAxis(int32 whichaxis,int32 whichfunction,int32 direction)
{
    CONTROL_CheckRange(whichfunction);
    if(whichaxis<0||whichaxis>=MAXAXES)Error("CONTROL_MapDigitalAxis : axis %d out of valid range for %d axes.\0\0\0",whichaxis,MAXAXES);
    switch(direction) {
    case axis_up:
    case axis_right:
        CONTROL_AxesMap[whichaxis].maxmap=whichfunction;
        break;
    case axis_down:
    case axis_left:
        CONTROL_AxesMap[whichaxis].minmap=whichfunction;
        break;
    }
}

void CONTROL_ClearFlags(void)
{
	int32 i;

	for (i=0;i<CONTROL_NUM_FLAGS;i++)
		CONTROL_Flags[i].used = false;
}

void CONTROL_ClearAssignments(void)
{
    int32 i;
    memset(CONTROL_DeviceButtonMapping,BUTTONUNDEFINED,sizeof(CONTROL_DeviceButtonMapping));
    memset(CONTROL_KeyMapping,KEYUNDEFINED,sizeof(CONTROL_KeyMapping));
    memset(CONTROL_Axes,0,sizeof(CONTROL_Axes));
    for(i=0;i<MAXAXES;i++)CONTROL_AxesScale[i]=NORMALAXISSCALE;
    memset(CONTROL_LastAxes,0,sizeof(CONTROL_LastAxes));
    memset(CONTROL_AxesMap,AXISUNDEFINED,sizeof(CONTROL_AxesMap));
}

void CONTROL_GetDeviceButtons(void)
{
    int32 i,bs,t=GetTime();uint32 buttons=0;
    if(CONTROL_MouseEnabled)buttons=CONTROL_GetMouseButtons();
    if(CONTROL_JoystickEnabled)buttons=CONTROL_JoyButtons(CONTROL_JoystickPort);
    if(CONTROL_ExternalEnabled)buttons=CONTROL_External->buttons;
    for(i=0;i<CONTROL_NumButtons;i++) {
        bs=(buttons>>i)&1;CONTROL_DeviceButtonState[i]=bs;CONTROL_ButtonClickedState[i]=false;
        if(bs) {
            if(!CONTROL_ButtonClicked[i]) {
                byte count=CONTROL_ButtonClickedCount[i];
                CONTROL_ButtonClicked[i]=true;
                if(!count||t>=CONTROL_ButtonClickedTime[i]) {
                    CONTROL_ButtonClickedTime[i]=t+CONTROL_DoubleClickSpeed;CONTROL_ButtonClickedCount[i]=1;
                } else {
                    CONTROL_ButtonClickedState[i]=true;CONTROL_ButtonClickedTime[i]=0;CONTROL_ButtonClickedCount[i]=2;
                }
            } else if(CONTROL_ButtonClickedCount[i]==2)CONTROL_ButtonClickedState[i]=true;
        } else {
            if(CONTROL_ButtonClickedCount[i]==2)CONTROL_ButtonClickedCount[i]=0;
            CONTROL_ButtonClicked[i]=false;
        }
    }
}

void CONTROL_DigitizeAxis(int32 axis)
{
    controlaxistype *current=&CONTROL_Axes[axis],*previous=&CONTROL_LastAxes[axis];
	if (current->analog > 0) {
		if (current->analog > THRESHOLD) {			// if very much in one direction,
			current->digital = 1;				// set affirmative
		} else {
			if (current->analog > MINTHRESHOLD) {		// if hanging in limbo,
				if (previous->digital == 1)	// set if in same direction as last time
					current->digital = 1;
			}
		}
	} else {
		if (current->analog < -THRESHOLD) {
			current->digital = -1;
		} else {
			if (current->analog < -MINTHRESHOLD) {
				if (previous->digital == -1)
					current->digital = -1;
			}
		}
	}
}

void CONTROL_ScaleAxis(int32 axis)
{
    controlaxistype *current=&CONTROL_Axes[axis];
    current->analog=FixedMulShift(CONTROL_AxesScale[axis],current->analog,16);
}

void CONTROL_ApplyAxis(int32 axis, ControlInfo *info)
{
	switch (CONTROL_AxesMap[axis].analogmap) {
		case analog_turning:          info->dyaw   += CONTROL_Axes[axis].analog; break;
		case analog_strafing:         info->dx     += CONTROL_Axes[axis].analog; break;
		case analog_lookingupanddown: info->dpitch += CONTROL_Axes[axis].analog; break;
		case analog_elevation:        info->dy     += CONTROL_Axes[axis].analog; break;
		case analog_rolling:          info->droll  += CONTROL_Axes[axis].analog; break;
		case analog_moving:           info->dz     += CONTROL_Axes[axis].analog; break;
		default: break;
	}
}

void CONTROL_PollDevices(ControlInfo *info)
{
    int32 i;memcpy(CONTROL_LastAxes,CONTROL_Axes,sizeof(CONTROL_Axes));
    memset(CONTROL_Axes,0,sizeof(CONTROL_Axes));memset(info,0,sizeof(*info));
    if(CONTROL_MouseEnabled)CONTROL_GetMouseDelta(&CONTROL_Axes[0].analog,&CONTROL_Axes[1].analog);
    else if(CONTROL_JoystickEnabled) {
        CONTROL_GetJoyDelta(CONTROL_JoystickPort,&CONTROL_Axes[0].analog,&CONTROL_Axes[1].analog,&CONTROL_Axes[2].analog,&CONTROL_Axes[3].analog);
        CONTROL_Axes[0].analog/=2;CONTROL_Axes[2].analog/=2;
    } else if(CONTROL_ExternalEnabled)CONTROL_PollExternalControl();
    for(i=0;i<CONTROL_NumAxes;i++) {
        CONTROL_DigitizeAxis(i);CONTROL_ScaleAxis(i);LIMITCONTROL(&CONTROL_Axes[i].analog);CONTROL_ApplyAxis(i,info);
    }
    CONTROL_GetDeviceButtons();
}

void CONTROL_AxisFunctionState(boolean *p)
{
    int32 i,j;
    for(i=0;i<CONTROL_NumAxes;i++) {
        if(!CONTROL_Axes[i].digital)continue;
        if(CONTROL_Axes[i].digital>0) {
            j=CONTROL_AxesMap[i].minmap;
            if(j!=AXISUNDEFINED)p[j]=1;
        } else {
            j=CONTROL_AxesMap[i].maxmap;
            if(j!=AXISUNDEFINED)p[j]=1;
        }
    }
}

void CONTROL_ButtonFunctionState(boolean *p)
{
    int32 i,j;for(i=0;i<CONTROL_NumButtons;i++) {
        j=CONTROL_DeviceButtonMapping[i].doubleclicked;
        if(j!=KEYUNDEFINED)p[j]|=CONTROL_ButtonClickedState[i];
        j=CONTROL_DeviceButtonMapping[i].singleclicked;
        if(j!=KEYUNDEFINED)p[j]|=CONTROL_DeviceButtonState[i];
    }
}

void CONTROL_GetUserInput( UserInput *info )
{
	ControlInfo ci;

	CONTROL_PollDevices( &ci );

	info->dir = dir_None;

	// checks if CONTROL_UserInputDelay is too far in the future due to clock skew?
	if (GetTime() + ((ticrate * USERINPUTDELAY) / 1000) < CONTROL_UserInputDelay)
		CONTROL_UserInputDelay = -1;

	if (GetTime() >= CONTROL_UserInputDelay) {
		if (CONTROL_Axes[1].digital == -1)
			info->dir = dir_North;
		else if (CONTROL_Axes[1].digital == 1)
			info->dir = dir_South;
		else if (CONTROL_Axes[0].digital == -1)
			info->dir = dir_West;
		else if (CONTROL_Axes[0].digital == 1)
			info->dir = dir_East;

	}

	info->button0 = CONTROL_DeviceButtonState[0];
	info->button1 = CONTROL_DeviceButtonState[1];

	if (KB_KeyDown[sc_UpArrow] || KB_KeyDown[sc_kpad_8])
		info->dir = dir_North;
	else if (KB_KeyDown[sc_DownArrow] || KB_KeyDown[sc_kpad_2])
		info->dir = dir_South;
	else if (KB_KeyDown[sc_LeftArrow] || KB_KeyDown[sc_kpad_4])
		info->dir = dir_West;
	else if (KB_KeyDown[sc_RightArrow] || KB_KeyDown[sc_kpad_6])
		info->dir = dir_East;

	if (KB_KeyDown[BUTTON0_SCAN_1] || KB_KeyDown[BUTTON0_SCAN_2] || KB_KeyDown[BUTTON0_SCAN_3])
		info->button0 = 1;
	if (KB_KeyDown[BUTTON1_SCAN])
		info->button1 = 1;

	if (CONTROL_UserInputCleared[1]) {
		if (!info->button0)
			CONTROL_UserInputCleared[1] = false;
		else
			info->button0 = false;
	}
	if (CONTROL_UserInputCleared[2]) {
		if (!info->button1)
			CONTROL_UserInputCleared[2] = false;
		else
			info->button1 = false;
	}
}

void CONTROL_ClearUserInput( UserInput *info )
{
    switch(info->dir) {
    case dir_North:
        CONTROL_UserInputCleared[0]=true;
        CONTROL_UserInputDelay=GetTime()+((ticrate*USERINPUTDELAY)/1000);
        KB_KeyDown[sc_UpArrow]=0;
        KB_KeyDown[sc_kpad_8]=0;
        break;
    case dir_South:
        CONTROL_UserInputCleared[0]=true;
        CONTROL_UserInputDelay=GetTime()+((ticrate*USERINPUTDELAY)/1000);
        KB_KeyDown[sc_DownArrow]=0;
        KB_KeyDown[sc_kpad_2]=0;
        break;
    case dir_East:
        CONTROL_UserInputCleared[0]=true;
        CONTROL_UserInputDelay=GetTime()+((ticrate*USERINPUTDELAY)/1000);
        KB_KeyDown[sc_LeftArrow]=0;
        KB_KeyDown[sc_kpad_4]=0;
        break;
    case dir_West:
        CONTROL_UserInputCleared[0]=true;
        CONTROL_UserInputDelay=GetTime()+((ticrate*USERINPUTDELAY)/1000);
        KB_KeyDown[sc_RightArrow]=0;
        KB_KeyDown[sc_kpad_6]=0;
        break;
    }
    if(info->button0)CONTROL_UserInputCleared[1]=true;
    if(info->button1)CONTROL_UserInputCleared[2]=true;
}

void CONTROL_ClearButton( int32 whichbutton )
{
	CONTROL_CheckRange( whichbutton );
	BUTTONCLEAR( whichbutton );
	CONTROL_Flags[whichbutton].cleared = true;
}

void CONTROL_GetInput( ControlInfo *info )
{
	int32 i, periphs[CONTROL_NUM_FLAGS];

	ServiceEvents();
	CONTROL_PollDevices( info );

	memset(periphs, 0, sizeof(periphs));
	CONTROL_ButtonFunctionState(periphs);
	CONTROL_AxisFunctionState(periphs);

	CONTROL_ButtonHeldState1 = CONTROL_ButtonState1;
	CONTROL_ButtonHeldState2 = CONTROL_ButtonState2;
	CONTROL_ButtonState1 = CONTROL_ButtonState2 = 0;

	for (i=0; i<CONTROL_NUM_FLAGS; i++) {
		CONTROL_SetFlag(i, CONTROL_KeyboardFunctionPressed(i) | periphs[i]);

		if (CONTROL_Flags[i].cleared) {
            if (CONTROL_Flags[i].active == false) CONTROL_Flags[i].cleared = false;
        } else {
            if (i > 31)
                CONTROL_ButtonState2 |= CONTROL_Flags[i].active << (i - 32);
            else
                CONTROL_ButtonState1 |= CONTROL_Flags[i].active << i;
        }
	}
}

void CONTROL_WaitRelease(void)
{
    UserInput ui;do{CONTROL_GetUserInput(&ui);}while(ui.dir!=dir_None||ui.button0||ui.button1);
}

void CONTROL_Ack(void)
{
    UserInput previous,current;boolean b0,b1;
    CONTROL_GetUserInput(&previous);
    do {
        CONTROL_GetUserInput(&current);
        if(!current.button0)previous.button0=0;
        if(!current.button1)previous.button1=0;
        b0=!previous.button0&&current.button0;b1=!previous.button1&&current.button1;
    }while(!b0&&!b1);
}

void CONTROL_Startup(controltype which,int32 (*timefunction)(void),int32 tickspersecond)
{
    int32 i;boolean mouse,joy,external;
    if(CONTROL_Started==true)return;
    if(timefunction)GetTime=timefunction;else GetTime=CONTROL_GetTime;
    ticrate=tickspersecond;
    CONTROL_DoubleClickSpeed=tickspersecond*57/100;if(CONTROL_DoubleClickSpeed<1)CONTROL_DoubleClickSpeed=1;
    mouse=false;joy=false;external=false;
    if(CONTROL_JoystickPort&&which>=controltype_keyboardandgamepad&&which<=controltype_keyboardandthrustmaster)which=controltype_keyboardandjoystick;
    switch(which) {
      case controltype_keyboardandmouse:mouse=true;CONTROL_NumAxes=2;break;
      case controltype_keyboardandjoystick:joy=true;CONTROL_FlightStickMode=false;CONTROL_HatEnabled=false;CONTROL_ThrottleEnabled=false;CONTROL_NumAxes=2;break;
      case controltype_keyboardandgamepad:joy=true;CONTROL_FlightStickMode=false;CONTROL_HatEnabled=false;CONTROL_ThrottleEnabled=false;CONTROL_NumAxes=4;break;
      case controltype_keyboardandexternal:external=true;CONTROL_NumAxes=6;break;
      case controltype_keyboardandflightstick:joy=true;CONTROL_FlightStickMode=true;CONTROL_HatEnabled=false;CONTROL_ThrottleEnabled=true;CONTROL_NumAxes=4;break;
      case controltype_keyboardandthrustmaster:joy=true;CONTROL_FlightStickMode=false;CONTROL_HatEnabled=true;CONTROL_ThrottleEnabled=false;CONTROL_NumAxes=4;break;
      default:break;
    }
    CONTROL_MousePresent=false;if(mouse)CONTROL_MousePresent=CONTROL_StartMouse();
    if(!CONTROL_MousePresent)CONTROL_MouseEnabled=false;
    else{printf("CONTROL_Startup: Mouse Present\n");CONTROL_MouseEnabled=true;}
    for(i=0;i<MaxJoys;i++){CONTROL_JoysPresent[i]=false;if(joy){CONTROL_JoysPresent[i]=CONTROL_StartJoy(i);if(CONTROL_JoysPresent[i])CONTROL_JoystickEnabled=true;}}
    if(CONTROL_JoystickEnabled)switch(which){
      case controltype_keyboardandgamepad:printf("CONTROL_Startup: GamePad Present\n\0\0");break;
      case controltype_keyboardandjoystick:printf("CONTROL_Startup: Joystick Present\n\0");break;
      case controltype_keyboardandflightstick:printf("CONTROL_Startup: FlightStick Present\n\0\0");break;
      case controltype_keyboardandthrustmaster:printf("CONTROL_Startup: ThrustMaster Present\n");break;
      default:break;
    }
    if(external)CONTROL_ExternalStartup();
    CONTROL_ButtonState1=0;CONTROL_ButtonState2=0;CONTROL_ButtonHeldState1=0;CONTROL_ButtonHeldState2=0;
    memset(CONTROL_UserInputCleared,0,sizeof(CONTROL_UserInputCleared));CONTROL_ClearFlags();
    if(CONTROL_ExternalEnabled)CONTROL_ExternalSetup();CONTROL_Started=true;
}

void CONTROL_Shutdown(void)
{
    int32 i;if(!CONTROL_Started)return;for(i=0;i<MaxJoys;i++)CONTROL_JoysPresent[i]=false;
    MOUSE_Shutdown();CONTROL_Started=false;
}
