# Logical C literals; each actual string owns its unused NUL capacity.
arg_control:
.ascii "control\000"
err_missing_control:
.ascii "CONTROL_Startup: %s parameter is not present on the command line\n\000\000\000"
err_external_api:
.ascii "CONTROL_Startup: External API is incompatible with this version. id=%ld\n\000\000\000\000"
msg_external:
.ascii "CONTROL_Startup: External controller found on vector %x\n\000\000\000\000"
err_range:
.ascii "CONTROL_CheckRange : Index %d out of valid range for %d control flags.\000\000"
err_define:
.ascii "CONTROL_DefineFlag: assertion failed flag = %ld\n\000\000\000\000"
msg_keymap:
.ascii "function %2ld key1=%3x key2=%3x\n\000\000\000\000"
msg_flag:
.ascii "function %2ld active=%ld used=%ld toggle=%ld buttonheld=%ld cleared=%ld\n\000\000\000\000"
msg_numaxes:
.ascii "numaxes=%ld\n\000\000\000\000"
msg_axis:
.ascii "axis=%ld analog=%ld digital1=%ld digital2=%ld\n\000\000"
err_button:
.ascii "CONTROL_MapButton : button %d out of valid range for %d buttons.\000\000\000\000"
err_analog_axis:
.ascii "CONTROL_MapAnalogAxis : axis %d out of valid range for %d axes.\000"
err_analog_function:
.ascii "CONTROL_MapAnalogAxis : analog function %d out of valid range for %d analog functions.\000\000"
err_axis_scale:
.ascii "CONTROL_SetAnalogAxisScale : axis %d out of valid range for %d axes.\000\000\000\000"
err_digital_axis:
.ascii "CONTROL_MapDigitalAxis : axis %d out of valid range for %d axes.\000\000\000\000"
msg_mouse:
.ascii "CONTROL_Startup: Mouse Present\n\000"
msg_gamepad:
.ascii "CONTROL_Startup: GamePad Present\n\000\000\000"
msg_joystick:
.ascii "CONTROL_Startup: Joystick Present\n\000\000"
msg_flightstick:
.ascii "CONTROL_Startup: FlightStick Present\n\000\000\000"
msg_thrustmaster:
.ascii "CONTROL_Startup: ThrustMaster Present\n\000"
