"""Logical C data/storage, independently readable; no native object inputs."""
import json
# True control.c string arguments. Each compiler-owned logical capacity includes
# its own unused NUL suffix; the terminal literal is not rounded up.
LITERALS=[
('arg_control','control',8),
('err_missing_control','CONTROL_Startup: %s parameter is not present on the command line\n',68),
('err_external_api','CONTROL_Startup: External API is incompatible with this version. id=%ld\n',76),
('msg_external','CONTROL_Startup: External controller found on vector %x\n',60),
('err_range','CONTROL_CheckRange : Index %d out of valid range for %d control flags.',72),
('err_define','CONTROL_DefineFlag: assertion failed flag = %ld\n',52),
('msg_keymap','function %2ld key1=%3x key2=%3x\n',36),
('msg_flag','function %2ld active=%ld used=%ld toggle=%ld buttonheld=%ld cleared=%ld\n',76),
('msg_numaxes','numaxes=%ld\n',16),
('msg_axis','axis=%ld analog=%ld digital1=%ld digital2=%ld\n',48),
('err_button','CONTROL_MapButton : button %d out of valid range for %d buttons.',68),
('err_analog_axis','CONTROL_MapAnalogAxis : axis %d out of valid range for %d axes.',64),
('err_analog_function','CONTROL_MapAnalogAxis : analog function %d out of valid range for %d analog functions.',88),
('err_axis_scale','CONTROL_SetAnalogAxisScale : axis %d out of valid range for %d axes.',72),
('err_digital_axis','CONTROL_MapDigitalAxis : axis %d out of valid range for %d axes.',68),
('msg_mouse','CONTROL_Startup: Mouse Present\n',32),
('msg_gamepad','CONTROL_Startup: GamePad Present\n',36),
('msg_joystick','CONTROL_Startup: Joystick Present\n',36),
('msg_flightstick','CONTROL_Startup: FlightStick Present\n',40),
('msg_thrustmaster','CONTROL_Startup: ThrustMaster Present\n',39)]
# Global/local scope is specified separately by the complete source declaration.
DATA=[('_CONTROL_RudderEnabled',0),('_CONTROL_MouseEnabled',0),('_CONTROL_ExternalEnabled',0),('_CONTROL_JoystickEnabled',0),('_CONTROL_JoystickPort',0),('_CONTROL_UserInputDelay',-1),('_CONTROL_MouseSensitivity',0x7000+0x1000),('_CONTROL_JoyXAxis',0),('_CONTROL_JoyYAxis',0),('_CONTROL_JoyXAxis2',0),('_CONTROL_JoyYAxis2',0),('_CONTROL_HatEnabled',0),('_CONTROL_ThrottleEnabled',0),('_CONTROL_FlightStickMode',0),('_CONTROL_NumButtons',32),('_CONTROL_NumAxes',6),('control_clock_ticks',0)]
# Genuine arrays/scalars and measured released-type sizeof values under /zp4.
# No padding object: these allocations cover the entire real BSS1612.
BSS=[('_CONTROL_LastAxes',6,8),('_CONTROL_AxesScale',6,4),('_CONTROL_Axes',6,8),('_CONTROL_AxesMap',6,4),('_CONTROL_DeviceButtonMapping',32,4),('_CONTROL_DeviceButtonState',32,4),('_CONTROL_ButtonClickedTime',32,4),('_CONTROL_Flags',64,8),('_JoyDefs',2,48),('_CONTROL_ButtonClickedState',32,4),('_CONTROL_ButtonClicked',32,4),('_CONTROL_ButtonClickedCount',32,1),('_CONTROL_KeyMapping',64,2),('_CONTROL_JoysPresent',2,4),('_CONTROL_UserInputCleared',3,4),('_CONTROL_External',1,4),('_GetTime',1,4),('_CONTROL_Started',1,4),('_ticrate',1,4),('_CONTROL_DoubleClickSpeed',1,4),('_CONTROL_ButtonHeldState1',1,4),('_CONTROL_ButtonHeldState2',1,4),('_CONTROL_MousePresent',1,4),('_CONTROL_ButtonState1',1,4),('_CONTROL_ButtonState2',1,4)]
def generate():
 out=['# Logical C literals; each actual string owns its unused NUL capacity.'];offsets={};at=0
 for name,text,capacity in LITERALS:
  raw=text.encode('ascii');assert len(raw)<capacity;offsets[at]=name;out += [name+':','.ascii '+json.dumps(text+'\0'*(capacity-len(raw))).replace('\\u0000','\\000')];at+=capacity
 assert at==1055
 return '\n'.join(out)+'\n',offsets
