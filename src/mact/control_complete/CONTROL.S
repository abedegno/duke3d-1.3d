# Readable symbolic CONTROL backend; exact C counterpart retained.
# Development seed: OWN C105 compilation; no SDK/EXE instruction input.
# Native enum dispatch correction and two full register/stack restorations follow.
# Caid is meaningful but still not byte-positive for CenterJoystick/GetDeviceButtons.
.intel_syntax noprefix
.code32
.file "control.S"
.globl CONTROL_Ack_
.globl CONTROL_ApplyAxis_
.globl CONTROL_AxisFunctionState_
.globl CONTROL_ButtonFunctionState_
.globl CONTROL_CenterJoystick_
.globl CONTROL_CheckRange_
.globl CONTROL_ClearAssignments_
.globl CONTROL_ClearButton_
.globl CONTROL_ClearFlags_
.globl CONTROL_ClearKeyboardFunction_
.globl CONTROL_ClearUserInput_
.globl CONTROL_DefineFlag_
.globl CONTROL_DigitizeAxis_
.globl CONTROL_ExternalSetup_
.globl CONTROL_ExternalStartup_
.globl CONTROL_FilterJoyDelta_
.globl CONTROL_FlagActive_
.globl CONTROL_GetDeviceButtons_
.globl CONTROL_GetInput_
.globl CONTROL_GetJoyAbs_
.globl CONTROL_GetJoyDelta_
.globl CONTROL_GetMouseButtons_
.globl CONTROL_GetMouseDelta_
.globl CONTROL_GetMouseSensitivity_
.globl CONTROL_GetTime_
.globl CONTROL_GetUserInput_
.globl CONTROL_JoyButtons_
.globl CONTROL_KeyboardFunctionPressed_
.globl CONTROL_MapAnalogAxis_
.globl CONTROL_MapButton_
.globl CONTROL_MapDigitalAxis_
.globl CONTROL_MapKey_
.globl CONTROL_PollDevices_
.globl CONTROL_PollExternalControl_
.globl CONTROL_PrintAxes_
.globl CONTROL_PrintControlFlag_
.globl CONTROL_PrintKeyMap_
.globl CONTROL_ScaleAxis_
.globl CONTROL_SetAnalogAxisScale_
.globl CONTROL_SetFlag_
.globl CONTROL_SetJoyScale_
.globl CONTROL_SetMouseSensitivity_
.globl CONTROL_SetupJoy_
.globl CONTROL_ShutJoy_
.globl CONTROL_Shutdown_
.globl CONTROL_StartJoy_
.globl CONTROL_StartMouse_
.globl CONTROL_Startup_
.globl CONTROL_WaitRelease_
.globl _CONTROL_ButtonHeldState1
.globl _CONTROL_ButtonHeldState2
.globl _CONTROL_ButtonState1
.globl _CONTROL_ButtonState2
.globl _CONTROL_ExternalEnabled
.globl _CONTROL_JoysPresent
.globl _CONTROL_JoystickEnabled
.globl _CONTROL_JoystickPort
.globl _CONTROL_MouseEnabled
.globl _CONTROL_MousePresent
.globl _CONTROL_RudderEnabled
.extern MOUSE_GetDelta_
.extern MOUSE_GetButtons_
.extern MOUSE_Init_
.extern _Joy_mask
.extern JoyStick_Vals_
.extern _Joy_x2
.extern _Joy_y2
.extern _Joy_x1
.extern _Joy_y1
.extern memset_
.extern CheckParm_
.extern printf_
.extern __argv
.extern atol_
.extern int386_
.extern Error_
.extern _KB_KeyDown
.extern ServiceEvents_
.extern MOUSE_Shutdown_
.section _TEXT,"ax",@progbits
.p2align 4

# C function CONTROL_GetMouseDelta_; ordinary C counterpart supplies semantics/ABI.
CONTROL_GetMouseDelta_:
    push ebx
    push ecx
    push esi
    mov esi, eax
    mov ebx, edx
    call MOUSE_GetDelta_
    mov eax, dword ptr [esi]
    cdq
    xor eax, edx
    sub eax, edx
    mov ecx, eax
    mov eax, dword ptr [ebx]
    cdq
    xor eax, edx
    sub eax, edx
    cmp ecx, eax
    jle control_branch_80
    mov eax, dword ptr [ebx]
    mov edx, eax
    mov ecx, 3
    sar edx, 0x1f
    idiv ecx
    mov dword ptr [ebx], eax
    jmp control_branch_81
control_branch_80:
    mov eax, dword ptr [esi]
    mov edx, eax
    mov ecx, 3
    sar edx, 0x1f
    idiv ecx
    mov dword ptr [esi], eax
control_branch_81:
    shl dword ptr [esi], 5
    mov edx, dword ptr [ebx]
    {disp32} lea eax, [edx*4]
    sub eax, edx
    shl eax, 5
    mov ecx, 0xf
    mov dword ptr [ebx], eax
    mov ebx, dword ptr [_CONTROL_MouseSensitivity]
    mov eax, dword ptr [esi]
    imul ebx
    shrd eax, edx, cl
    mov dword ptr [esi], eax
    pop esi
    pop ecx
    pop ebx
    ret
    {disp8} lea eax, [eax]

# C function CONTROL_GetMouseSensitivity_; ordinary C counterpart supplies semantics/ABI.
CONTROL_GetMouseSensitivity_:
    mov eax, dword ptr [_CONTROL_MouseSensitivity]
    sub eax, 0x1000
    ret
    nop

# C function CONTROL_SetMouseSensitivity_; ordinary C counterpart supplies semantics/ABI.
CONTROL_SetMouseSensitivity_:
    add eax, 0x1000
    mov dword ptr [_CONTROL_MouseSensitivity], eax
    ret
    nop

# C function CONTROL_GetMouseButtons_; ordinary C counterpart supplies semantics/ABI.
CONTROL_GetMouseButtons_:
    {disp32} jmp MOUSE_GetButtons_
control_branch_82:
    {disp8} lea eax, [eax]

# C function CONTROL_StartMouse_; ordinary C counterpart supplies semantics/ABI.
CONTROL_StartMouse_:
    mov dword ptr [_CONTROL_NumButtons], 3
    {disp32} jmp MOUSE_Init_
control_branch_83:
    nop

# C function CONTROL_GetJoyAbs_; ordinary C counterpart supplies semantics/ABI.
CONTROL_GetJoyAbs_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    test eax, eax
    je control_branch_84
    mov byte ptr [_Joy_mask], 0xc
    call JoyStick_Vals_
    mov eax, dword ptr [_Joy_x2]
    mov dword ptr [_CONTROL_JoyXAxis], eax
    mov eax, dword ptr [_Joy_y2]
    mov dword ptr [_CONTROL_JoyYAxis], eax
    jmp control_branch_85
control_branch_84:
    mov al, byte ptr [_CONTROL_RudderEnabled]
    shl al, 2
    or al, 3
    mov byte ptr [_Joy_mask], al
    mov al, byte ptr [_CONTROL_ThrottleEnabled]
    or al, byte ptr [_CONTROL_HatEnabled]
    mov dl, byte ptr [_Joy_mask]
    shl al, 3
    or dl, al
    mov byte ptr [_Joy_mask], dl
    call JoyStick_Vals_
    mov eax, dword ptr [_Joy_x1]
    mov dword ptr [_CONTROL_JoyXAxis], eax
    mov eax, dword ptr [_Joy_y1]
    mov dword ptr [_CONTROL_JoyYAxis], eax
    mov eax, dword ptr [_Joy_x2]
    mov dword ptr [_CONTROL_JoyXAxis2], eax
    mov eax, dword ptr [_Joy_y2]
    mov dword ptr [_CONTROL_JoyYAxis2], eax
control_branch_85:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp8} lea eax, [eax]

# C function CONTROL_FilterJoyDelta_; ordinary C counterpart supplies semantics/ABI.
CONTROL_FilterJoyDelta_:
    push ecx
    push esi
    push edi
    push ebp
    mov ecx, edx
    mov esi, ebx
    mov edx, eax
    shl eax, 2
    sub eax, edx
    shl eax, 4
    add eax, OFFSET FLAT:_JoyDefs
    mov edx, dword ptr [ecx]
    mov edi, dword ptr [eax + 8]
    mov ebx, dword ptr [ebx]
    cmp edx, edi
    jge control_branch_86
    mov ebp, dword ptr [eax]
    cmp edx, ebp
    jge control_branch_87
    mov edx, ebp
control_branch_87:
    sub edx, dword ptr [eax + 8]
    mov ebp, dword ptr [eax + 0x20]
    neg edx
    imul edx, ebp
    mov dword ptr [ecx], edx
    neg edx
    mov dword ptr [ecx], edx
    jmp control_branch_88
control_branch_86:
    cmp edx, dword ptr [eax + 0x10]
    jle control_branch_89
    mov edi, dword ptr [eax + 0x18]
    cmp edx, edi
    jle control_branch_90
    mov edx, edi
control_branch_90:
    mov ebp, dword ptr [eax + 0x10]
    mov edi, dword ptr [eax + 0x28]
    sub edx, ebp
    imul edx, edi
    mov dword ptr [ecx], edx
    jmp control_branch_88
control_branch_89:
    mov dword ptr [ecx], 0
control_branch_88:
    cmp ebx, dword ptr [eax + 0xc]
    jge control_branch_91
    mov edi, dword ptr [eax + 4]
    cmp ebx, edi
    jge control_branch_92
    mov ebx, edi
control_branch_92:
    sub ebx, dword ptr [eax + 0xc]
    mov edx, dword ptr [eax + 0x24]
    neg ebx
    imul ebx, edx
    mov dword ptr [esi], ebx
    neg ebx
    mov dword ptr [esi], ebx
    pop ebp
    pop edi
    pop esi
    pop ecx
    ret
control_branch_91:
    cmp ebx, dword ptr [eax + 0x14]
    jle control_branch_93
    mov ebp, dword ptr [eax + 0x1c]
    cmp ebx, ebp
    jle control_branch_94
    mov ebx, ebp
control_branch_94:
    mov edx, dword ptr [eax + 0x14]
    mov ecx, dword ptr [eax + 0x2c]
    sub ebx, edx
    imul ebx, ecx
    mov dword ptr [esi], ebx
    pop ebp
    pop edi
    pop esi
    pop ecx
    ret
control_branch_93:
    mov dword ptr [esi], 0
    pop ebp
    pop edi
    pop esi
    pop ecx
    ret
    nop

# C function CONTROL_GetJoyDelta_; ordinary C counterpart supplies semantics/ABI.
CONTROL_GetJoyDelta_:
    push esi
    push edi
    mov edi, dword ptr [esp + 0xc]
    mov esi, eax
    call CONTROL_GetJoyAbs_
    mov eax, dword ptr [_CONTROL_JoyXAxis]
    mov dword ptr [edx], eax
    mov eax, dword ptr [_CONTROL_JoyYAxis]
    mov dword ptr [ebx], eax
    mov eax, esi
    call CONTROL_FilterJoyDelta_
    test esi, esi
    jne control_branch_95
    cmp dword ptr [_CONTROL_RudderEnabled], 0
    jne control_branch_96
    cmp dword ptr [_CONTROL_ThrottleEnabled], 0
    je control_branch_95
control_branch_96:
    mov eax, dword ptr [_CONTROL_JoyXAxis2]
    mov ebx, edi
    mov dword ptr [ecx], eax
    mov eax, dword ptr [_CONTROL_JoyYAxis2]
    mov edx, ecx
    mov dword ptr [edi], eax
    mov eax, 1
    call CONTROL_FilterJoyDelta_
control_branch_95:
    pop edi
    pop esi
    ret 4
    {disp8} lea eax, [eax]
# Real typed C switch table, CS-indexed dispatch.
control_hat_button_table:
.long control_case_50,control_case_51,control_case_52,control_case_53

# C function CONTROL_JoyButtons_; ordinary C counterpart supplies semantics/ABI.
CONTROL_JoyButtons_:
    push ebx
    push ecx
    push edx
    mov ecx, eax
    mov edx, 0x201
    sub eax, eax
    in al, dx
    test ecx, ecx
    je control_branch_97
    mov bl, al
    shr bl, 6
    jmp control_branch_98
control_branch_97:
    mov bl, al
    shr bl, 4
control_branch_98:
    test ecx, ecx
    jne control_branch_99
    mov cl, 0xf
    jmp control_branch_100
control_branch_99:
    mov cl, 3
control_branch_100:
    and bl, cl
    mov edx, dword ptr [_CONTROL_FlightStickMode]
    xor bl, cl
    test edx, edx
    je control_branch_101
    cmp bl, 7
    jb control_branch_102
    jbe control_branch_103
    cmp bl, 0xb
    {disp32} jb control_branch_104
    jbe control_branch_105
    cmp bl, 0xf
    je control_branch_106
    jmp control_branch_104
control_branch_102:
    cmp bl, 3
    jne control_branch_104
    mov bl, 0x80
    jmp control_branch_104
control_branch_103:
    mov bl, 0x40
    jmp control_branch_104
control_branch_105:
    mov bl, 0x20
    jmp control_branch_104
control_branch_106:
    mov bl, 0x10
    jmp control_branch_104
control_branch_101:
    cmp dword ptr [_CONTROL_HatEnabled], 0
    je control_branch_104
    mov eax, dword ptr [_CONTROL_JoyYAxis2]
    mov edx, eax
    mov ecx, 0x64
    sar edx, 0x1f
    idiv ecx
    cmp eax, 3
    ja control_branch_104
    jmp dword ptr cs:[eax*4 + control_hat_button_table]
control_case_50:
    or bl, 0x10
    mov al, bl
    pop edx
    pop ecx
    pop ebx
    ret
control_case_51:
    or bl, 0x20
    mov al, bl
    pop edx
    pop ecx
    pop ebx
    ret
control_case_52:
    or bl, 0x40
    mov al, bl
    pop edx
    pop ecx
    pop ebx
    ret
control_case_53:
    or bl, 0x80
control_branch_104:
    mov al, bl
    pop edx
    pop ecx
    pop ebx
    ret
    {load} mov eax, eax

# C function CONTROL_SetJoyScale_; ordinary C counterpart supplies semantics/ABI.
CONTROL_SetJoyScale_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    mov esi, eax
    {disp32} lea ecx, [eax*4]
    sub ecx, eax
    mov esi, OFFSET FLAT:_JoyDefs
    shl ecx, 4
    add esi, ecx
    mov ecx, dword ptr [esi + 8]
    mov edx, dword ptr [esi]
    mov ebx, 0xa00
    sub ecx, edx
    jne control_branch_107
    mov ecx, 1
control_branch_107:
    mov edx, ebx
    mov eax, ebx
    sar edx, 0x1f
    idiv ecx
    mov edi, dword ptr [esi + 0x10]
    mov ecx, dword ptr [esi + 0x18]
    mov dword ptr [esi + 0x20], eax
    sub ecx, edi
    jne control_branch_108
    mov ecx, 1
control_branch_108:
    mov edx, ebx
    mov eax, ebx
    sar edx, 0x1f
    idiv ecx
    mov ebp, dword ptr [esi + 4]
    mov ecx, dword ptr [esi + 0xc]
    mov dword ptr [esi + 0x28], eax
    sub ecx, ebp
    jne control_branch_109
    mov ecx, 1
control_branch_109:
    mov edx, ebx
    mov eax, ebx
    sar edx, 0x1f
    idiv ecx
    mov dword ptr [esi + 0x24], eax
    mov ecx, dword ptr [esi + 0x1c]
    sub ecx, dword ptr [esi + 0x14]
    jne control_branch_110
    mov ecx, 1
control_branch_110:
    mov edx, ebx
    mov eax, ebx
    sar edx, 0x1f
    idiv ecx
    mov dword ptr [esi + 0x2c], eax
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

# C function CONTROL_SetupJoy_; ordinary C counterpart supplies semantics/ABI.
CONTROL_SetupJoy_:
    push esi
    push edi
    mov esi, eax
    mov edi, ebx
    shl eax, 2
    sub eax, esi
    mov ebx, OFFSET FLAT:_JoyDefs
    shl eax, 4
    add ebx, eax
    mov dword ptr [ebx + 0x18], edi
    sub edi, edx
    mov dword ptr [ebx], edx
    mov edx, edi
    mov edi, 0xc
    mov eax, edx
    sar edx, 0x1f
    idiv edi
    cmp eax, 1
    jge control_branch_111
    mov eax, 1
control_branch_111:
    mov edx, dword ptr [esp + 0x10]
    sub edx, eax
    mov dword ptr [ebx + 8], edx
    mov edx, dword ptr [esp + 0x10]
    mov dword ptr [ebx + 4], ecx
    add edx, eax
    mov eax, dword ptr [esp + 0xc]
    mov dword ptr [ebx + 0x10], edx
    mov edx, eax
    mov dword ptr [ebx + 0x1c], eax
    sub edx, ecx
    mov ecx, 0xc
    mov eax, edx
    sar edx, 0x1f
    idiv ecx
    cmp eax, 1
    jge control_branch_112
    mov eax, 1
control_branch_112:
    mov edx, dword ptr [esp + 0x14]
    sub edx, eax
    mov dword ptr [ebx + 0xc], edx
    mov edx, dword ptr [esp + 0x14]
    add edx, eax
    mov eax, esi
    mov dword ptr [ebx + 0x14], edx
    call CONTROL_SetJoyScale_
    pop edi
    pop esi
    ret 0xc

# C function CONTROL_CenterJoystick_; ordinary C counterpart supplies semantics/ABI.
# Native-backed register/lifetime restoration of the same C calibration values.
# Stack frame44: UI0..11; callbacks12/16/24/20; rudder at60.
# Real minY36/maxY40, rudder28/throttle32. CX=ESI/CY=ECX, minX=EDI/maxX=EBP.
CONTROL_CenterJoystick_:
    push esi
    push edi
    push ebp
    sub esp, 44
    mov dword ptr [esp+12],eax
    mov dword ptr [esp+16],edx
    mov dword ptr [esp+24],ebx
    mov dword ptr [esp+20],ecx
    call dword ptr [esp+12]
    mov ebx,12
    mov eax,esp
    xor edx,edx
    call memset_
    cmp dword ptr [esp],0
    jne control_center_sample_center
control_center_wait_center:
    cmp dword ptr [esp+4],0
    jne control_center_sample_center
    mov eax,esp
    call CONTROL_GetUserInput_
    cmp dword ptr [esp],0
    je control_center_wait_center
control_center_sample_center:
    xor eax,eax
    mov ebx,12
    mov al,byte ptr [_CONTROL_JoystickPort]
    xor edx,edx
    call CONTROL_GetJoyAbs_
    mov eax,esp
    mov esi,dword ptr [_CONTROL_JoyXAxis]
    mov ecx,dword ptr [_CONTROL_JoyYAxis]
    call CONTROL_ClearUserInput_
    call dword ptr [esp+16]
    mov eax,esp
    call memset_
    cmp dword ptr [esp],0
    jne control_center_sample_upper
control_center_wait_upper:
    cmp dword ptr [esp+4],0
    jne control_center_sample_upper
    mov eax,esp
    call CONTROL_GetUserInput_
    cmp dword ptr [esp],0
    je control_center_wait_upper
control_center_sample_upper:
    xor eax,eax
    mov al,byte ptr [_CONTROL_JoystickPort]
    mov ebx,12
    call CONTROL_GetJoyAbs_
    mov eax,dword ptr [_CONTROL_JoyYAxis]
    xor edx,edx
    mov dword ptr [esp+36],eax
    mov eax,esp
    mov edi,dword ptr [_CONTROL_JoyXAxis]
    call CONTROL_ClearUserInput_
    call dword ptr [esp+24]
    mov eax,esp
    call memset_
    cmp dword ptr [esp],0
    jne control_center_sample_lower
control_center_wait_lower:
    cmp dword ptr [esp+4],0
    jne control_center_sample_lower
    mov eax,esp
    call CONTROL_GetUserInput_
    cmp dword ptr [esp],0
    je control_center_wait_lower
control_center_sample_lower:
    xor eax,eax
    mov al,byte ptr [_CONTROL_JoystickPort]
    call CONTROL_GetJoyAbs_
    mov eax,dword ptr [_CONTROL_JoyYAxis]
    mov dword ptr [esp+40],eax
    mov eax,esp
    mov ebp,dword ptr [_CONTROL_JoyXAxis]
    call CONTROL_ClearUserInput_
    # Exact signed32 abs and division-toward-zero fallback tests.
    mov eax,edi
    sub eax,ebp
    cdq
    xor eax,edx
    sub eax,edx
    mov ebx,eax
    mov edx,esi
    mov eax,esi
    sar edx,31
    shl edx,2
    {load} sbb eax,edx
    sar eax,2
    cmp ebx,eax
    jge control_center_x_range_valid
    lea ebp,[esi*2]
    xor edi,edi
control_center_x_range_valid:
    mov eax,dword ptr [esp+36]
    sub eax,dword ptr [esp+40]
    cdq
    xor eax,edx
    sub eax,edx
    mov ebx,eax
    mov edx,ecx
    mov eax,ecx
    sar edx,31
    shl edx,2
    {load} sbb eax,edx
    sar eax,2
    cmp ebx,eax
    jge control_center_y_range_valid
    xor ebx,ebx
    lea eax,[ecx+ecx]
    mov dword ptr [esp+36],ebx
    mov dword ptr [esp+40],eax
control_center_y_range_valid:
    cmp dword ptr [_CONTROL_ThrottleEnabled],0
    je control_center_test_rudder
    call dword ptr [esp+20]
    mov ebx,12
    mov eax,esp
    xor edx,edx
    call memset_
    cmp dword ptr [esp],0
    jne control_center_sample_throttle
control_center_wait_throttle:
    cmp dword ptr [esp+4],0
    jne control_center_sample_throttle
    mov eax,esp
    call CONTROL_GetUserInput_
    cmp dword ptr [esp],0
    je control_center_wait_throttle
control_center_sample_throttle:
    xor eax,eax
    mov al,byte ptr [_CONTROL_JoystickPort]
    call CONTROL_GetJoyAbs_
    mov eax,dword ptr [_CONTROL_JoyYAxis2]
    mov dword ptr [esp+32],eax
    mov eax,esp
    call CONTROL_ClearUserInput_
control_center_test_rudder:
    cmp dword ptr [_CONTROL_RudderEnabled],0
    je control_center_setup_primary
    call dword ptr [esp+60]
    mov ebx,12
    mov eax,esp
    xor edx,edx
    call memset_
    cmp dword ptr [esp],0
    jne control_center_sample_rudder
control_center_wait_rudder:
    cmp dword ptr [esp+4],0
    jne control_center_sample_rudder
    mov eax,esp
    call CONTROL_GetUserInput_
    cmp dword ptr [esp],0
    je control_center_wait_rudder
control_center_sample_rudder:
    xor eax,eax
    mov al,byte ptr [_CONTROL_JoystickPort]
    call CONTROL_GetJoyAbs_
    mov eax,dword ptr [_CONTROL_JoyXAxis2]
    mov dword ptr [esp+28],eax
    mov eax,esp
    call CONTROL_ClearUserInput_
control_center_setup_primary:
    mov ebx,dword ptr [esp+40]
    push ecx
    mov edx,edi
    xor eax,eax
    mov ecx,dword ptr [esp+40]
    mov al,byte ptr [_CONTROL_JoystickPort]
    push esi
    xor edi,edi
    mov esi,dword ptr [esp+36]
    push ebx
    mov ebx,ebp
    mov dword ptr [esp+48],edi
    call CONTROL_SetupJoy_
    mov ecx,dword ptr [esp+32]
    mov edx,dword ptr [_CONTROL_RudderEnabled]
    lea eax,[ecx+ecx]
    lea ebp,[esi+esi]
    mov dword ptr [esp+40],eax
    test edx,edx
    jne control_center_setup_aux
    cmp dword ptr [_CONTROL_FlightStickMode],0
    je control_center_done
control_center_setup_aux:
    push ecx
    mov eax,1
    push esi
    mov ecx,dword ptr [esp+48]
    mov ebx,ebp
    push ecx
    mov edx,edi
    mov ecx,dword ptr [esp+48]
    call CONTROL_SetupJoy_
control_center_done:
    add esp,44
    pop ebp
    pop edi
    pop esi
    ret 4
    {disp8} lea eax,[eax]

# C function CONTROL_StartJoy_; ordinary C counterpart supplies semantics/ABI.
CONTROL_StartJoy_:
    push ebx
    push ecx
    push edx
    push esi
    mov esi, eax
    call CONTROL_GetJoyAbs_
    mov edx, dword ptr [_CONTROL_JoyXAxis]
    mov eax, dword ptr [_CONTROL_JoyYAxis]
    test edx, edx
    je control_branch_129
    cmp edx, 0x137e
    jle control_branch_130
control_branch_129:
    xor eax, eax
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
control_branch_130:
    test eax, eax
    je control_branch_131
    cmp eax, 0x137e
    jle control_branch_132
control_branch_131:
    xor eax, eax
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
control_branch_132:
    push eax
    push edx
    add eax, eax
    xor ecx, ecx
    push eax
    {disp32} lea ebx, [edx*2]
    mov eax, esi
    xor edx, edx
    call CONTROL_SetupJoy_
    mov edx, 8
    mov eax, 1
    mov dword ptr [_CONTROL_NumButtons], edx
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    nop

# C function CONTROL_ShutJoy_; ordinary C counterpart supplies semantics/ABI.
CONTROL_ShutJoy_:
    push edx
    xor edx, edx
    mov dword ptr [eax*4 + _CONTROL_JoysPresent], edx
    pop edx
    ret

# C function CONTROL_ExternalStartup_; ordinary C counterpart supplies semantics/ABI.
CONTROL_ExternalStartup_:
    push ebx
    push edx
    cmp dword ptr [_CONTROL_ExternalEnabled], 0
    {disp32} jne control_branch_133
    mov eax, OFFSET FLAT:arg_control
    call CheckParm_
    and eax, 0xff
    jne control_branch_134
    push OFFSET FLAT:arg_control
    push OFFSET FLAT:err_missing_control
    call printf_
    add esp, 8
    pop edx
    pop ebx
    ret
control_branch_134:
    mov edx, dword ptr [__argv]
    inc eax
    mov eax, dword ptr [edx + eax*4]
    call atol_
    mov dx, word ptr [eax]
    mov dword ptr [_CONTROL_External], eax
    cmp dx, 0xdead
    je control_branch_135
    mov eax, edx
    and eax, 0xffff
    push eax
    push OFFSET FLAT:err_external_api
    call printf_
    add esp, 8
    pop edx
    pop ebx
    ret
control_branch_135:
    mov ax, word ptr [eax + 2]
    and eax, 0xffff
    push eax
    push OFFSET FLAT:msg_external
    mov ebx, 1
    call printf_
    add esp, 8
    mov dword ptr [_CONTROL_ExternalEnabled], ebx
control_branch_133:
    pop edx
    pop ebx
    ret

# C function CONTROL_ExternalSetup_; ordinary C counterpart supplies semantics/ABI.
CONTROL_ExternalSetup_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    mov edx, 0x20
    xor ecx, ecx
    xor esi, esi
    mov dword ptr [_CONTROL_NumButtons], edx
control_branch_138:
    mov eax, dword ptr [_CONTROL_External]
    mov al, byte ptr [esi + eax + 0x20]
    and eax, 0xff
    cmp eax, 0x7f
    je control_branch_136
    mov edx, ecx
    xor ebx, ebx
    call CONTROL_MapButton_
control_branch_136:
    mov eax, dword ptr [_CONTROL_External]
    mov al, byte ptr [esi + eax + 0x21]
    and eax, 0xff
    cmp eax, 0x7f
    je control_branch_137
    mov ebx, 1
    mov edx, ecx
    call CONTROL_MapButton_
control_branch_137:
    mov ebx, dword ptr [_CONTROL_NumButtons]
    inc ecx
    add esi, 2
    cmp ecx, ebx
    jl control_branch_138
    mov esi, dword ptr [_CONTROL_NumAxes]
    xor ecx, ecx
    test esi, esi
    jle control_branch_139
    xor esi, esi
control_branch_143:
    mov eax, dword ptr [_CONTROL_External]
    xor edx, edx
    mov dl, byte ptr [ecx + eax + 0x60]
    cmp edx, 0x7f
    je control_branch_140
    mov eax, ecx
    call CONTROL_MapAnalogAxis_
control_branch_140:
    mov edx, dword ptr [_CONTROL_External]
    mov dl, byte ptr [edx + esi + 0x68]
    and edx, 0xff
    cmp edx, 0x7f
    je control_branch_141
    mov eax, ecx
    xor ebx, ebx
    call CONTROL_MapDigitalAxis_
control_branch_141:
    mov eax, dword ptr [_CONTROL_External]
    xor edx, edx
    mov dl, byte ptr [esi + eax + 0x69]
    cmp edx, 0x7f
    je control_branch_142
    mov ebx, 1
    mov eax, ecx
    call CONTROL_MapDigitalAxis_
control_branch_142:
    mov edi, dword ptr [_CONTROL_NumAxes]
    inc ecx
    add esi, 2
    cmp ecx, edi
    jl control_branch_143
control_branch_139:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

# C function CONTROL_PollExternalControl_; ordinary C counterpart supplies semantics/ABI.
CONTROL_PollExternalControl_:
    push ebx
    push ecx
    push edx
    push esi
    sub esp, 0x38
    mov esi, dword ptr [_CONTROL_External]
    cmp dword ptr [_CONTROL_ExternalEnabled], 0
    je control_branch_144
    mov word ptr [esi + 0x66], 1
    mov ax, word ptr [esi + 2]
    mov ebx, esp
    lea edx, [esp + 0x1c]
    and eax, 0xffff
    call int386_
    mov ebx, dword ptr [_CONTROL_NumAxes]
    mov esi, dword ptr [_CONTROL_External]
    test ebx, ebx
    jle control_branch_144
    {disp32} lea ecx, [ebx*4]
    xor edx, edx
    xor eax, eax
control_branch_145:
    mov ebx, esi
    add edx, 8
    mov ebx, dword ptr [ebx + eax + 4]
    add eax, 4
    mov dword ptr [edx + _CONTROL_Axes-8], ebx
    cmp eax, ecx
    jl control_branch_145
control_branch_144:
    mov dword ptr [_CONTROL_External], esi
    add esp, 0x38
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    nop

# C function CONTROL_GetTime_; ordinary C counterpart supplies semantics/ABI.
CONTROL_GetTime_:
    push edx
    mov edx, dword ptr [control_clock_ticks]
    add edx, 5
    mov dword ptr [control_clock_ticks], edx
    mov eax, edx
    pop edx
    ret

# C function CONTROL_CheckRange_; ordinary C counterpart supplies semantics/ABI.
CONTROL_CheckRange_:
    test eax, eax
    jl control_branch_146
    cmp eax, 0x40
    jl control_branch_147
control_branch_146:
    push 0x40
    push eax
    push OFFSET FLAT:err_range
    call Error_
    add esp, 0xc
control_branch_147:
    ret
    {load} mov eax, eax

# C function CONTROL_SetFlag_; ordinary C counterpart supplies semantics/ABI.
CONTROL_SetFlag_:
    push ebx
    push ecx
    mov ebx, eax
    call CONTROL_CheckRange_
    {disp32} lea eax, [ebx*8]
    cmp byte ptr [eax + _CONTROL_Flags+2], 0
    jne control_branch_148
    mov byte ptr [eax + _CONTROL_Flags], dl
    pop ecx
    pop ebx
    ret
control_branch_148:
    test edx, edx
    je control_branch_149
    cmp byte ptr [eax + _CONTROL_Flags+3], 0
    jne control_branch_150
    mov dh, byte ptr [eax + _CONTROL_Flags]
    mov cl, 1
    test dh, dh
    sete al
    mov byte ptr [ebx*8 + _CONTROL_Flags+3], cl
    mov byte ptr [ebx*8 + _CONTROL_Flags], al
    pop ecx
    pop ebx
    ret
control_branch_149:
    xor ch, ch
    mov byte ptr [eax + _CONTROL_Flags+3], ch
control_branch_150:
    pop ecx
    pop ebx
    ret

# C function CONTROL_KeyboardFunctionPressed_; ordinary C counterpart supplies semantics/ABI.
CONTROL_KeyboardFunctionPressed_:
    push ebx
    push edx
    mov edx, eax
    call CONTROL_CheckRange_
    mov ah, byte ptr [edx*8 + _CONTROL_Flags+1]
    xor ebx, ebx
    test ah, ah
    je control_branch_151
    mov bl, byte ptr [edx*2 + _CONTROL_KeyMapping]
    and ebx, 0xff
    cmp byte ptr [ebx + _KB_KeyDown], 0
    setne bl
    xor eax, eax
    mov al, byte ptr [edx*2 + _CONTROL_KeyMapping+1]
    and ebx, 0xff
    cmp byte ptr [eax + _KB_KeyDown], 0
    setne al
    xor edx, edx
    mov dl, al
    or ebx, edx
control_branch_151:
    mov eax, ebx
    pop edx
    pop ebx
    ret
    {disp8} lea eax, [eax]

# C function CONTROL_ClearKeyboardFunction_; ordinary C counterpart supplies semantics/ABI.
CONTROL_ClearKeyboardFunction_:
    push ebx
    push edx
    mov edx, eax
    call CONTROL_CheckRange_
    cmp byte ptr [edx*8 + _CONTROL_Flags+1], 0
    je control_branch_152
    xor eax, eax
    mov al, byte ptr [edx*2 + _CONTROL_KeyMapping]
    xor bl, bl
    mov byte ptr [eax + _KB_KeyDown], bl
    xor eax, eax
    mov al, byte ptr [edx*2 + _CONTROL_KeyMapping+1]
    mov byte ptr [eax + _KB_KeyDown], bl
control_branch_152:
    pop edx
    pop ebx
    ret
    {load} mov eax, eax

# C function CONTROL_DefineFlag_; ordinary C counterpart supplies semantics/ABI.
CONTROL_DefineFlag_:
    push ebx
    push ecx
    mov ebx, eax
    mov ecx, edx
    call CONTROL_CheckRange_
    mov ah, 1
    mov byte ptr [ebx*8 + _CONTROL_Flags+2], dl
    xor dl, dl
    mov byte ptr [ebx*8 + _CONTROL_Flags+1], ah
    mov byte ptr [ebx*8 + _CONTROL_Flags], dl
    mov byte ptr [ebx*8 + _CONTROL_Flags+3], dl
    xor edx, edx
    mov eax, ebx
    mov dword ptr [ebx*8 + _CONTROL_Flags+4], edx
    call CONTROL_CheckRange_
    mov dl, byte ptr [ebx*8 + _CONTROL_Flags+1]
    and edx, 0xff
    jne control_branch_153
    push ebx
    push OFFSET FLAT:err_define
    call Error_
    add esp, 8
control_branch_153:
    pop ecx
    pop ebx
    ret
    nop

# C function CONTROL_FlagActive_; ordinary C counterpart supplies semantics/ABI.
CONTROL_FlagActive_:
    push edx
    mov edx, eax
    call CONTROL_CheckRange_
    mov al, byte ptr [edx*8 + _CONTROL_Flags+1]
    and eax, 0xff
    pop edx
    ret
    {load} mov eax, eax

# C function CONTROL_MapKey_; ordinary C counterpart supplies semantics/ABI.
CONTROL_MapKey_:
    push ecx
    mov ecx, eax
    call CONTROL_CheckRange_
    mov byte ptr [ecx*2 + _CONTROL_KeyMapping], dl
    mov byte ptr [ecx*2 + _CONTROL_KeyMapping+1], bl
    pop ecx
    ret

# C function CONTROL_PrintKeyMap_; ordinary C counterpart supplies semantics/ABI.
CONTROL_PrintKeyMap_:
    push ebx
    push edx
    xor ebx, ebx
    xor edx, edx
control_branch_154:
    xor eax, eax
    mov al, byte ptr [edx + _CONTROL_KeyMapping+1]
    push eax
    xor eax, eax
    mov al, byte ptr [edx + _CONTROL_KeyMapping]
    push eax
    push ebx
    push OFFSET FLAT:msg_keymap
    add edx, 2
    call printf_
    inc ebx
    add esp, 0x10
    cmp ebx, 0x40
    jl control_branch_154
    pop edx
    pop ebx
    ret
    {load} mov eax, eax

# C function CONTROL_PrintControlFlag_; ordinary C counterpart supplies semantics/ABI.
CONTROL_PrintControlFlag_:
    push ebx
    push edx
    mov edx, eax
    mov ebx, dword ptr [eax*8 + _CONTROL_Flags+4]
    push ebx
    xor ebx, ebx
    mov bl, byte ptr [eax*8 + _CONTROL_Flags+3]
    push ebx
    xor ebx, ebx
    mov bl, byte ptr [eax*8 + _CONTROL_Flags+2]
    push ebx
    xor ebx, ebx
    mov bl, byte ptr [eax*8 + _CONTROL_Flags+1]
    push ebx
    mov al, byte ptr [eax*8 + _CONTROL_Flags]
    and eax, 0xff
    push eax
    push edx
    push OFFSET FLAT:msg_flag
    call printf_
    add esp, 0x1c
    pop edx
    pop ebx
    ret

# C function CONTROL_PrintAxes_; ordinary C counterpart supplies semantics/ABI.
CONTROL_PrintAxes_:
    push ebx
    push edx
    mov edx, dword ptr [_CONTROL_NumAxes]
    push edx
    push OFFSET FLAT:msg_numaxes
    xor ebx, ebx
    call printf_
    xor edx, edx
    add esp, 8
control_branch_155:
    xor eax, eax
    mov al, byte ptr [edx + _CONTROL_AxesMap+2]
    push eax
    xor eax, eax
    mov al, byte ptr [edx + _CONTROL_AxesMap+1]
    push eax
    xor eax, eax
    mov al, byte ptr [edx + _CONTROL_AxesMap]
    push eax
    push ebx
    push OFFSET FLAT:msg_axis
    add edx, 4
    call printf_
    inc ebx
    add esp, 0x14
    cmp ebx, 6
    jl control_branch_155
    pop edx
    pop ebx
    ret
    nop

# C function CONTROL_MapButton_; ordinary C counterpart supplies semantics/ABI.
CONTROL_MapButton_:
    push ecx
    push edi
    mov ecx, eax
    call CONTROL_CheckRange_
    test edx, edx
    jl control_branch_156
    cmp edx, dword ptr [_CONTROL_NumButtons]
    jl control_branch_157
control_branch_156:
    mov edi, dword ptr [_CONTROL_NumButtons]
    push edi
    push edx
    push OFFSET FLAT:err_button
    call Error_
    add esp, 0xc
control_branch_157:
    shl edx, 2
    test ebx, ebx
    je control_branch_158
    mov byte ptr [edx + _CONTROL_DeviceButtonMapping+1], cl
    pop edi
    pop ecx
    ret
control_branch_158:
    mov byte ptr [edx + _CONTROL_DeviceButtonMapping], cl
    pop edi
    pop ecx
    ret
    nop

# C function CONTROL_MapAnalogAxis_; ordinary C counterpart supplies semantics/ABI.
CONTROL_MapAnalogAxis_:
    push ebx
    mov ebx, eax
    test eax, eax
    jl control_branch_159
    cmp eax, 6
    jl control_branch_160
control_branch_159:
    push 6
    push ebx
    push OFFSET FLAT:err_analog_axis
    call Error_
    add esp, 0xc
control_branch_160:
    test edx, edx
    jl control_branch_161
    cmp ebx, 6
    jl control_branch_162
control_branch_161:
    push 6
    push edx
    push OFFSET FLAT:err_analog_function
    call Error_
    add esp, 0xc
control_branch_162:
    mov byte ptr [ebx*4 + _CONTROL_AxesMap], dl
    pop ebx
    ret
    {load} mov eax, eax

# C function CONTROL_SetAnalogAxisScale_; ordinary C counterpart supplies semantics/ABI.
CONTROL_SetAnalogAxisScale_:
    push ebx
    mov ebx, eax
    test eax, eax
    jl control_branch_163
    cmp eax, 6
    jl control_branch_164
control_branch_163:
    push 6
    push ebx
    push OFFSET FLAT:err_axis_scale
    call Error_
    add esp, 0xc
control_branch_164:
    mov dword ptr [ebx*4 + _CONTROL_AxesScale], edx
    pop ebx
    ret
    {disp8} lea eax, [eax]

# C function CONTROL_MapDigitalAxis_; ordinary C counterpart supplies semantics/ABI.
CONTROL_MapDigitalAxis_:
    push ecx
    mov ecx, eax
    mov eax, edx
    call CONTROL_CheckRange_
    test ecx, ecx
    jl control_branch_165
    cmp ecx, 6
    jl control_branch_166
control_branch_165:
    push 6
    push ecx
    push OFFSET FLAT:err_digital_axis
    call Error_
    add esp, 0xc
control_branch_166:
    cmp ebx, 1
    jb control_branch_167
    cmp ebx, 2
    jbe control_branch_168
    cmp ebx, 3
    je control_branch_169
    pop ecx
    ret
control_branch_167:
    test ebx, ebx
    jne control_branch_170
control_branch_169:
    mov byte ptr [ecx*4 + _CONTROL_AxesMap+2], dl
    pop ecx
    ret
control_branch_168:
    mov byte ptr [ecx*4 + _CONTROL_AxesMap+1], dl
control_branch_170:
    pop ecx
    ret
    {load} mov eax, eax

# C function CONTROL_ClearFlags_; ordinary C counterpart supplies semantics/ABI.
CONTROL_ClearFlags_:
    push edx
    xor eax, eax
control_branch_171:
    add eax, 8
    xor dl, dl
    mov byte ptr [eax + _CONTROL_Flags-7], dl
    cmp eax, 0x200
    jne control_branch_171
    pop edx
    ret
    nop

# C function CONTROL_ClearAssignments_; ordinary C counterpart supplies semantics/ABI.
CONTROL_ClearAssignments_:
    push ebx
    push edx
    mov ebx, 0x80
    mov edx, 0x7f
    mov eax, OFFSET FLAT:_CONTROL_DeviceButtonMapping
    call memset_
    mov ebx, 0x80
    mov edx, 0x7f
    mov eax, OFFSET FLAT:_CONTROL_KeyMapping
    call memset_
    mov ebx, 0x30
    mov eax, OFFSET FLAT:_CONTROL_Axes
    xor edx, edx
    call memset_
    mov edx, 0x10000
    xor eax, eax
control_branch_172:
    add eax, 4
    mov dword ptr [eax + _CONTROL_AxesScale-4], edx
    cmp eax, 0x18
    jne control_branch_172
    mov ebx, 0x30
    mov eax, OFFSET FLAT:_CONTROL_LastAxes
    xor edx, edx
    call memset_
    mov ebx, 0x18
    mov edx, 0x7f
    mov eax, OFFSET FLAT:_CONTROL_AxesMap
    call memset_
    pop edx
    pop ebx
    ret

# C function CONTROL_GetDeviceButtons_; ordinary C counterpart supplies semantics/ABI.
# Same C double-click machine with the actual retained byte count/state values.
CONTROL_GetDeviceButtons_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    call dword ptr [_GetTime]
    mov edx,dword ptr [_CONTROL_MouseEnabled]
    mov edi,eax
    xor esi,esi
    test edx,edx
    je control_buttons_test_joystick
    call MOUSE_GetButtons_
    movzx esi,al
control_buttons_test_joystick:
    cmp dword ptr [_CONTROL_JoystickEnabled],0
    je control_buttons_test_external
    xor eax,eax
    mov al,byte ptr [_CONTROL_JoystickPort]
    call CONTROL_JoyButtons_
    movzx esi,al
control_buttons_test_external:
    cmp dword ptr [_CONTROL_ExternalEnabled],0
    je control_buttons_begin
    mov esi,dword ptr [_CONTROL_External]
    mov esi,dword ptr [esi+28]
control_buttons_begin:
    mov ebp,dword ptr [_CONTROL_NumButtons]
    xor edx,edx
    test ebp,ebp
    {disp32} jle control_buttons_done
    mov ebp,dword ptr [_CONTROL_DoubleClickSpeed]
    xor eax,eax
    add ebp,edi
control_buttons_each:
    mov cl,dl
    mov ebx,esi
    shr ebx,cl
    and ebx,1
    xor ecx,ecx
    mov dword ptr [eax+_CONTROL_DeviceButtonState],ebx
    mov dword ptr [eax+_CONTROL_ButtonClickedState],ecx
    test ebx,ebx
    je control_buttons_released
    cmp dword ptr [eax+_CONTROL_ButtonClicked],0
    jne control_buttons_held
    mov ebx,1
    mov ch,byte ptr [edx+_CONTROL_ButtonClickedCount]
    mov dword ptr [eax+_CONTROL_ButtonClicked],ebx
    test ch,ch
    je control_buttons_first
    cmp edi,dword ptr [eax+_CONTROL_ButtonClickedTime]
    jl control_buttons_double
control_buttons_first:
    mov bh,1
    mov dword ptr [eax+_CONTROL_ButtonClickedTime],ebp
    mov byte ptr [edx+_CONTROL_ButtonClickedCount],bh
    jmp control_buttons_next
control_buttons_double:
    xor ecx,ecx
    mov dword ptr [eax+_CONTROL_ButtonClickedState],ebx
    mov bl,2
    mov dword ptr [eax+_CONTROL_ButtonClickedTime],ecx
    mov byte ptr [edx+_CONTROL_ButtonClickedCount],bl
    jmp control_buttons_next
control_buttons_held:
    cmp byte ptr [edx+_CONTROL_ButtonClickedCount],2
    jne control_buttons_next
    mov dword ptr [eax+_CONTROL_ButtonClickedState],1
    jmp control_buttons_next
control_buttons_released:
    cmp byte ptr [edx+_CONTROL_ButtonClickedCount],2
    jne control_buttons_clear_clicked
    xor bh,ch
    mov byte ptr [edx+_CONTROL_ButtonClickedCount],bh
control_buttons_clear_clicked:
    xor ecx,ecx
    mov dword ptr [eax+_CONTROL_ButtonClicked],ecx
control_buttons_next:
    mov ebx,dword ptr [_CONTROL_NumButtons]
    inc edx
    add eax,4
    cmp edx,ebx
    jl control_buttons_each
control_buttons_done:
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {load} mov eax,eax

# C function CONTROL_DigitizeAxis_; ordinary C counterpart supplies semantics/ABI.
CONTROL_DigitizeAxis_:
    push ebx
    push ecx
    push edx
    push edi
    {disp32} lea edx, [eax*8]
    mov eax, OFFSET FLAT:_CONTROL_Axes
    add eax, edx
    mov ebx, dword ptr [eax]
    add edx, OFFSET FLAT:_CONTROL_LastAxes
    test ebx, ebx
    jle control_branch_184
    cmp ebx, 0x200
    jle control_branch_185
    mov dword ptr [eax + 4], 1
    pop edi
    pop edx
    pop ecx
    pop ebx
    ret
control_branch_185:
    cmp ebx, 0x80
    jle control_branch_186
    mov ecx, dword ptr [edx + 4]
    cmp ecx, 1
    jne control_branch_186
    mov dword ptr [eax + 4], ecx
    pop edi
    pop edx
    pop ecx
    pop ebx
    ret
control_branch_184:
    cmp ebx, 0xfffffe00
    jge control_branch_187
    mov dword ptr [eax + 4], 0xffffffff
    pop edi
    pop edx
    pop ecx
    pop ebx
    ret
control_branch_187:
    cmp ebx, -0x80
    jge control_branch_186
    mov edi, dword ptr [edx + 4]
    cmp edi, -1
    jne control_branch_186
    mov dword ptr [eax + 4], edi
control_branch_186:
    pop edi
    pop edx
    pop ecx
    pop ebx
    ret
    nop

# C function CONTROL_ScaleAxis_; ordinary C counterpart supplies semantics/ABI.
CONTROL_ScaleAxis_:
    push ebx
    push ecx
    push edx
    push esi
    {disp32} lea esi, [eax*8]
    add esi, OFFSET FLAT:_CONTROL_Axes
    mov ecx, 0x10
    mov eax, dword ptr [eax*4 + _CONTROL_AxesScale]
    mov ebx, dword ptr [esi]
    imul ebx
    shrd eax, edx, cl
    mov dword ptr [esi], eax
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    nop
# Real typed C switch table, CS-indexed dispatch.
control_apply_analog_table:
.long control_case_55,control_case_56,control_case_57,control_case_58,control_case_59,control_case_60

# C function CONTROL_ApplyAxis_; ordinary C counterpart supplies semantics/ABI.
CONTROL_ApplyAxis_:
    push ebx
    mov bl, byte ptr [eax*4 + _CONTROL_AxesMap]
    cmp bl, 5
    ja control_branch_188
    and ebx, 0xff
    jmp dword ptr cs:[ebx*4 + control_apply_analog_table]
control_case_55:
    mov eax, dword ptr [eax*8 + _CONTROL_Axes]
    add dword ptr [edx + 0xc], eax
    pop ebx
    ret
control_case_56:
    mov eax, dword ptr [eax*8 + _CONTROL_Axes]
    add dword ptr [edx], eax
    pop ebx
    ret
control_case_57:
    mov eax, dword ptr [eax*8 + _CONTROL_Axes]
    add dword ptr [edx + 0x10], eax
    pop ebx
    ret
control_case_58:
    mov eax, dword ptr [eax*8 + _CONTROL_Axes]
    add dword ptr [edx + 4], eax
    pop ebx
    ret
control_case_59:
    mov eax, dword ptr [eax*8 + _CONTROL_Axes]
    add dword ptr [edx + 0x14], eax
    pop ebx
    ret
control_case_60:
    mov eax, dword ptr [eax*8 + _CONTROL_Axes]
    add dword ptr [edx + 8], eax
control_branch_188:
    pop ebx
    ret
    {load} mov eax, eax

# C function CONTROL_PollDevices_; ordinary C counterpart supplies semantics/ABI.
CONTROL_PollDevices_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    sub esp, 8
    mov dword ptr [esp], eax
    mov ecx, 0x30
    mov esi, OFFSET FLAT:_CONTROL_Axes
    mov edi, OFFSET FLAT:_CONTROL_LastAxes
    mov ebx, 0x30
    push edi
    mov eax, ecx
    shr ecx, 2
    # C memcpy: repeat all ECX dwords; native GA/105 uses REPNE MOVSD.
    repne movsd dword ptr es:[edi], dword ptr [esi]
    {load} mov cl, al
    and cl, 3
    repne movsb byte ptr es:[edi], byte ptr [esi]
    pop edi
    xor edx, edx
    mov eax, OFFSET FLAT:_CONTROL_Axes
    call memset_
    mov ebx, 0x18
    mov eax, dword ptr [esp]
    xor edx, edx
    call memset_
    cmp dword ptr [_CONTROL_MouseEnabled], 0
    je control_branch_189
    mov edx, OFFSET FLAT:_CONTROL_Axes+8
    mov eax, OFFSET FLAT:_CONTROL_Axes
    call CONTROL_GetMouseDelta_
    jmp control_branch_190
control_branch_189:
    cmp dword ptr [_CONTROL_JoystickEnabled], 0
    je control_branch_191
    push OFFSET FLAT:_CONTROL_Axes+24
    mov ecx, OFFSET FLAT:_CONTROL_Axes+16
    mov ebx, OFFSET FLAT:_CONTROL_Axes+8
    xor eax, eax
    mov edx, OFFSET FLAT:_CONTROL_Axes
    mov al, byte ptr [_CONTROL_JoystickPort]
    call CONTROL_GetJoyDelta_
    mov eax, dword ptr [_CONTROL_Axes]
    mov edx, eax
    sar edx, 0x1f
    {load} sub eax, edx
    sar eax, 1
    mov dword ptr [_CONTROL_Axes], eax
    mov eax, dword ptr [_CONTROL_Axes+16]
    mov edx, eax
    sar edx, 0x1f
    {load} sub eax, edx
    sar eax, 1
    mov dword ptr [_CONTROL_Axes+16], eax
    jmp control_branch_190
control_branch_191:
    cmp dword ptr [_CONTROL_ExternalEnabled], 0
    je control_branch_190
    call CONTROL_PollExternalControl_
control_branch_190:
    mov edi, dword ptr [_CONTROL_NumAxes]
    xor esi, esi
    test edi, edi
    {disp32} jle control_branch_192
    mov ebp, OFFSET FLAT:_CONTROL_Axes
    mov dword ptr [esp + 4], esi
    xor edi, edi
control_branch_195:
    mov eax, esi
    call CONTROL_DigitizeAxis_
    mov eax, dword ptr [esp + 4]
    mov ecx, 0x10
    {disp8} mov ebx, dword ptr [ebp]
    mov eax, dword ptr [eax + _CONTROL_AxesScale]
    imul ebx
    shrd eax, edx, cl
    {disp8} mov dword ptr [ebp], eax
    cmp dword ptr [edi + _CONTROL_Axes], 0x7fff
    jle control_branch_193
    mov dword ptr [edi + _CONTROL_Axes], 0x7fff
control_branch_193:
    cmp dword ptr [edi + _CONTROL_Axes], 0xffff8001
    jge control_branch_194
    mov dword ptr [edi + _CONTROL_Axes], 0xffff8001
control_branch_194:
    mov edx, dword ptr [esp]
    mov eax, esi
    call CONTROL_ApplyAxis_
    add ebp, 8
    add edi, 8
    mov eax, dword ptr [esp + 4]
    mov edx, dword ptr [_CONTROL_NumAxes]
    add eax, 4
    inc esi
    mov dword ptr [esp + 4], eax
    cmp esi, edx
    jl control_branch_195
control_branch_192:
    call CONTROL_GetDeviceButtons_
    add esp, 8
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp8} lea eax, [eax]

# C function CONTROL_AxisFunctionState_; ordinary C counterpart supplies semantics/ABI.
CONTROL_AxisFunctionState_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    mov edi, dword ptr [_CONTROL_NumAxes]
    mov esi, eax
    xor ebx, ebx
    test edi, edi
    jle control_branch_196
    xor edx, edx
    xor eax, eax
control_branch_200:
    mov ecx, dword ptr [edx + _CONTROL_Axes+4]
    test ecx, ecx
    je control_branch_197
    jle control_branch_198
    xor ecx, ecx
    mov cl, byte ptr [eax + _CONTROL_AxesMap+1]
    cmp ecx, 0x7f
    je control_branch_197
    jmp control_branch_199
control_branch_198:
    xor ecx, ecx
    mov cl, byte ptr [eax + _CONTROL_AxesMap+2]
    cmp ecx, 0x7f
    je control_branch_197
control_branch_199:
    mov dword ptr [esi + ecx*4], 1
control_branch_197:
    add edx, 8
    inc ebx
    add eax, 4
    cmp ebx, edi
    jl control_branch_200
control_branch_196:
    mov dword ptr [_CONTROL_NumAxes], edi
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp8} lea eax, [eax]

# C function CONTROL_ButtonFunctionState_; ordinary C counterpart supplies semantics/ABI.
CONTROL_ButtonFunctionState_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    mov edi, dword ptr [_CONTROL_NumButtons]
    mov ecx, eax
    xor edx, edx
    test edi, edi
    jle control_branch_201
    xor eax, eax
control_branch_204:
    xor ebx, ebx
    mov bl, byte ptr [eax + _CONTROL_DeviceButtonMapping+1]
    cmp ebx, 0x7f
    je control_branch_202
    mov esi, dword ptr [eax + _CONTROL_ButtonClickedState]
    or dword ptr [ecx + ebx*4], esi
control_branch_202:
    xor ebx, ebx
    mov bl, byte ptr [eax + _CONTROL_DeviceButtonMapping]
    cmp ebx, 0x7f
    je control_branch_203
    mov esi, dword ptr [eax + _CONTROL_DeviceButtonState]
    or dword ptr [ecx + ebx*4], esi
control_branch_203:
    inc edx
    add eax, 4
    cmp edx, edi
    jl control_branch_204
control_branch_201:
    mov dword ptr [_CONTROL_NumButtons], edi
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp8} lea eax, [eax]

# C function CONTROL_GetUserInput_; ordinary C counterpart supplies semantics/ABI.
CONTROL_GetUserInput_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    sub esp, 0x18
    mov ebx, eax
    mov eax, esp
    call CONTROL_PollDevices_
    mov edx, dword ptr [_ticrate]
    {disp32} lea eax, [edx*4]
    sub eax, edx
    shl eax, 3
    add edx, eax
    shl edx, 3
    mov ecx, 0x3e8
    mov eax, edx
    sar edx, 0x1f
    idiv ecx
    mov byte ptr [ebx + 8], 8
    mov edx, eax
    call dword ptr [_GetTime]
    add eax, edx
    cmp eax, dword ptr [_CONTROL_UserInputDelay]
    jge control_branch_205
    mov dword ptr [_CONTROL_UserInputDelay], 0xffffffff
control_branch_205:
    call dword ptr [_GetTime]
    cmp eax, dword ptr [_CONTROL_UserInputDelay]
    jl control_branch_206
    mov edi, dword ptr [_CONTROL_Axes+12]
    cmp edi, -1
    jne control_branch_207
    mov byte ptr [ebx + 8], 0
    jmp control_branch_206
control_branch_207:
    cmp edi, 1
    jne control_branch_208
    mov byte ptr [ebx + 8], 4
    jmp control_branch_206
control_branch_208:
    mov eax, dword ptr [_CONTROL_Axes+4]
    cmp eax, -1
    jne control_branch_209
    mov byte ptr [ebx + 8], 6
    jmp control_branch_206
control_branch_209:
    cmp eax, 1
    jne control_branch_206
    mov byte ptr [ebx + 8], 2
control_branch_206:
    mov eax, dword ptr [_CONTROL_DeviceButtonState]
    mov dword ptr [ebx], eax
    mov eax, dword ptr [_CONTROL_DeviceButtonState+4]
    mov dword ptr [ebx + 4], eax
    cmp byte ptr [_KB_KeyDown+90], 0
    jne control_branch_210
    cmp byte ptr [_KB_KeyDown+72], 0
    je control_branch_211
control_branch_210:
    mov byte ptr [ebx + 8], 0
    jmp control_branch_212
control_branch_211:
    cmp byte ptr [_KB_KeyDown+106], 0
    jne control_branch_213
    cmp byte ptr [_KB_KeyDown+80], 0
    je control_branch_214
control_branch_213:
    mov byte ptr [ebx + 8], 4
    jmp control_branch_212
control_branch_214:
    cmp byte ptr [_KB_KeyDown+107], 0
    jne control_branch_215
    cmp byte ptr [_KB_KeyDown+75], 0
    je control_branch_216
control_branch_215:
    mov byte ptr [ebx + 8], 6
    jmp control_branch_212
control_branch_216:
    cmp byte ptr [_KB_KeyDown+108], 0
    jne control_branch_217
    cmp byte ptr [_KB_KeyDown+77], 0
    je control_branch_212
control_branch_217:
    mov byte ptr [ebx + 8], 2
control_branch_212:
    cmp byte ptr [_KB_KeyDown+57], 0
    jne control_branch_218
    cmp byte ptr [_KB_KeyDown+28], 0
    jne control_branch_218
    cmp byte ptr [_KB_KeyDown+104], 0
    je control_branch_219
control_branch_218:
    mov dword ptr [ebx], 1
control_branch_219:
    cmp byte ptr [_KB_KeyDown+1], 0
    je control_branch_220
    mov dword ptr [ebx + 4], 1
control_branch_220:
    cmp dword ptr [_CONTROL_UserInputCleared+4], 0
    je control_branch_221
    mov esi, dword ptr [ebx]
    test esi, esi
    jne control_branch_222
    mov dword ptr [_CONTROL_UserInputCleared+4], esi
    jmp control_branch_221
control_branch_222:
    mov dword ptr [ebx], 0
control_branch_221:
    cmp dword ptr [_CONTROL_UserInputCleared+8], 0
    je control_branch_223
    mov eax, dword ptr [ebx + 4]
    test eax, eax
    jne control_branch_224
    mov dword ptr [_CONTROL_UserInputCleared+8], eax
    jmp control_branch_223
control_branch_224:
    mov dword ptr [ebx + 4], 0
control_branch_223:
    add esp, 0x18
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp8} lea eax, [eax]
# Real typed C switch table, CS-indexed dispatch.
control_clear_direction_table:
.long control_case_62,control_case_63,control_case_64,control_case_63,control_case_65,control_case_63,control_case_66

# C function CONTROL_ClearUserInput_; ordinary C counterpart supplies semantics/ABI.
CONTROL_ClearUserInput_:
    push ebx
    push ecx
    push edx
    mov ebx, eax
    mov al, byte ptr [eax + 8]
    cmp al, 6
    {disp32} ja control_case_63
    and eax, 0xff
    jmp dword ptr cs:[eax*4 + control_clear_direction_table]
control_case_62:
    mov edx, dword ptr [_ticrate]
    {disp32} lea eax, [edx*4]
    sub eax, edx
    shl eax, 3
    add edx, eax
    shl edx, 3
    mov ecx, 0x3e8
    mov eax, edx
    sar edx, 0x1f
    idiv ecx
    mov dword ptr [_CONTROL_UserInputCleared], 1
    mov edx, eax
    call dword ptr [_GetTime]
    add eax, edx
    mov dword ptr [_CONTROL_UserInputDelay], eax
    xor ah, ah
    mov byte ptr [_KB_KeyDown+90], ah
    mov byte ptr [_KB_KeyDown+72], ah
    {disp32} jmp control_case_63
control_case_65:
    mov edx, dword ptr [_ticrate]
    {disp32} lea eax, [edx*4]
    sub eax, edx
    shl eax, 3
    mov ecx, 1
    add edx, eax
    mov dword ptr [_CONTROL_UserInputCleared], ecx
    shl edx, 3
    mov ecx, 0x3e8
    mov eax, edx
    sar edx, 0x1f
    idiv ecx
    mov edx, eax
    call dword ptr [_GetTime]
    add eax, edx
    mov dword ptr [_CONTROL_UserInputDelay], eax
    xor dh, dh
    mov byte ptr [_KB_KeyDown+106], dh
    mov byte ptr [_KB_KeyDown+80], dh
    {disp32} jmp control_case_63
control_case_64:
    mov edx, dword ptr [_ticrate]
    {disp32} lea eax, [edx*4]
    sub eax, edx
    shl eax, 3
    add edx, eax
    shl edx, 3
    mov ecx, 0x3e8
    mov eax, edx
    sar edx, 0x1f
    idiv ecx
    mov dword ptr [_CONTROL_UserInputCleared], 1
    mov edx, eax
    call dword ptr [_GetTime]
    add eax, edx
    xor ch, ch
    mov dword ptr [_CONTROL_UserInputDelay], eax
    mov byte ptr [_KB_KeyDown+107], ch
    mov byte ptr [_KB_KeyDown+75], ch
    jmp control_case_63
control_case_66:
    mov dword ptr [_CONTROL_UserInputCleared], 1
    mov edx, dword ptr [_ticrate]
    {disp32} lea eax, [edx*4]
    sub eax, edx
    shl eax, 3
    add edx, eax
    shl edx, 3
    mov ecx, 0x3e8
    mov eax, edx
    sar edx, 0x1f
    idiv ecx
    mov edx, eax
    call dword ptr [_GetTime]
    add eax, edx
    mov dword ptr [_CONTROL_UserInputDelay], eax
    xor ah, ah
    mov byte ptr [_KB_KeyDown+108], ah
    mov byte ptr [_KB_KeyDown+77], ah
control_case_63:
    cmp dword ptr [ebx], 0
    je control_branch_225
    mov dword ptr [_CONTROL_UserInputCleared+4], 1
control_branch_225:
    cmp dword ptr [ebx + 4], 0
    je control_branch_226
    mov dword ptr [_CONTROL_UserInputCleared+8], 1
control_branch_226:
    pop edx
    pop ecx
    pop ebx
    ret
    {disp8} lea eax, [eax]

# C function CONTROL_ClearButton_; ordinary C counterpart supplies semantics/ABI.
CONTROL_ClearButton_:
    push ebx
    push ecx
    push edx
    push esi
    mov edx, eax
    call CONTROL_CheckRange_
    cmp edx, 0x1f
    jle control_branch_227
    mov eax, 1
    lea ecx, [edx - 0x20]
    shl eax, cl
    mov ecx, eax
    mov esi, dword ptr [_CONTROL_ButtonState2]
    not ecx
    and esi, ecx
    mov dword ptr [_CONTROL_ButtonState2], esi
    jmp control_branch_228
control_branch_227:
    mov eax, 1
    mov cl, dl
    shl eax, cl
    mov ecx, eax
    mov ebx, dword ptr [_CONTROL_ButtonState1]
    not ecx
    and ebx, ecx
    mov dword ptr [_CONTROL_ButtonState1], ebx
control_branch_228:
    mov dword ptr [edx*8 + _CONTROL_Flags+4], 1
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp8} lea eax, [eax]

# C function CONTROL_GetInput_; ordinary C counterpart supplies semantics/ABI.
CONTROL_GetInput_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    sub esp, 0x104
    mov edx, eax
    call ServiceEvents_
    mov ebx, 0x100
    mov eax, edx
    mov ecx, 0xffffffe0
    call CONTROL_PollDevices_
    xor esi, esi
    mov eax, esp
    xor edx, edx
    xor edi, edi
    call memset_
    mov eax, esp
    {disp32} mov dword ptr [esp + 0x100], ecx
    call CONTROL_ButtonFunctionState_
    mov eax, esp
    xor edx, edx
    call CONTROL_AxisFunctionState_
    mov eax, dword ptr [_CONTROL_ButtonState1]
    xor ebx, ebx
    mov dword ptr [_CONTROL_ButtonHeldState1], eax
    mov eax, dword ptr [_CONTROL_ButtonState2]
    mov dword ptr [_CONTROL_ButtonState1], edx
    mov dword ptr [_CONTROL_ButtonHeldState2], eax
    mov dword ptr [_CONTROL_ButtonState2], edx
control_branch_232:
    mov eax, ebx
    call CONTROL_KeyboardFunctionPressed_
    mov edx, dword ptr [esp + edi]
    or edx, eax
    mov eax, ebx
    call CONTROL_SetFlag_
    mov eax, dword ptr [esi + _CONTROL_Flags+4]
    test eax, eax
    je control_branch_229
    cmp byte ptr [esi + _CONTROL_Flags], 0
    jne control_branch_230
    xor ebp, ebp
    mov dword ptr [esi + _CONTROL_Flags+4], ebp
    jmp control_branch_230
control_branch_229:
    cmp ebx, 0x1f
    jle control_branch_231
    {disp32} mov cl, byte ptr [esp + 0x100]
    mov al, byte ptr [esi + _CONTROL_Flags]
    shl eax, cl
    or dword ptr [_CONTROL_ButtonState2], eax
    jmp control_branch_230
control_branch_231:
    mov cl, bl
    mov al, byte ptr [esi + _CONTROL_Flags]
    mov edx, dword ptr [_CONTROL_ButtonState1]
    shl eax, cl
    or edx, eax
    mov dword ptr [_CONTROL_ButtonState1], edx
control_branch_230:
    {disp32} mov ebp, dword ptr [esp + 0x100]
    add esi, 8
    add edi, 4
    inc ebp
    inc ebx
    {disp32} mov dword ptr [esp + 0x100], ebp
    cmp ebx, 0x40
    jl control_branch_232
    add esp, 0x104
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {load} mov eax, eax

# C function CONTROL_WaitRelease_; ordinary C counterpart supplies semantics/ABI.
CONTROL_WaitRelease_:
    sub esp, 0xc
control_branch_233:
    mov eax, esp
    call CONTROL_GetUserInput_
    cmp byte ptr [esp + 8], 8
    jne control_branch_233
    cmp dword ptr [esp], 0
    jne control_branch_233
    cmp dword ptr [esp + 4], 0
    jne control_branch_233
    add esp, 0xc
    ret
    {load} mov eax, eax

# C function CONTROL_Ack_; ordinary C counterpart supplies semantics/ABI.
CONTROL_Ack_:
    push ebx
    push ecx
    push edx
    push esi
    push ebp
    sub esp, 0x18
    lea eax, [esp + 0xc]
    call CONTROL_GetUserInput_
    xor ebx, ebx
control_branch_241:
    mov eax, esp
    call CONTROL_GetUserInput_
    mov edx, dword ptr [esp]
    cmp ebx, edx
    jne control_branch_234
    mov dword ptr [esp + 0xc], edx
control_branch_234:
    mov ecx, dword ptr [esp + 4]
    cmp ebx, ecx
    jne control_branch_235
    mov dword ptr [esp + 0x10], ecx
control_branch_235:
    mov esi, dword ptr [esp + 0xc]
    cmp ebx, esi
    jne control_branch_236
    cmp esi, dword ptr [esp]
    je control_branch_236
    mov eax, 1
    jmp control_branch_237
control_branch_236:
    mov eax, ebx
control_branch_237:
    mov ebp, dword ptr [esp + 0x10]
    mov edx, eax
    cmp ebx, ebp
    jne control_branch_238
    cmp ebp, dword ptr [esp + 4]
    je control_branch_238
    mov eax, 1
    jmp control_branch_239
control_branch_238:
    mov eax, ebx
control_branch_239:
    test edx, edx
    jne control_branch_240
    test eax, eax
    je control_branch_241
control_branch_240:
    add esp, 0x18
    pop ebp
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp8} lea eax, [eax]
# Real typed C switch table, CS-indexed dispatch.
control_start_device_table:
# Enum2 joystick selects FOUR axes; enum4 gamepad selects TWO.
.long control_case_68,control_case_71,control_case_70,control_case_69,control_case_72,control_case_73
# Real typed C switch table, CS-indexed dispatch.
control_start_message_table:
.long control_case_75,control_case_76,control_case_77,control_case_78,control_case_79

# C function CONTROL_Startup_; ordinary C counterpart supplies semantics/ABI.
CONTROL_Startup_:
    push ecx
    push esi
    push edi
    push ebp
    sub esp, 4
    mov byte ptr [esp], al
    cmp dword ptr [_CONTROL_Started], 1
    {disp32} je control_branch_242
    test edx, edx
    je control_branch_243
    mov dword ptr [_GetTime], edx
    jmp control_branch_244
control_branch_243:
    mov dword ptr [_GetTime], OFFSET FLAT:CONTROL_GetTime_
control_branch_244:
    mov dword ptr [_ticrate], ebx
    {disp32} lea eax, [ebx*8]
    sub eax, ebx
    shl eax, 3
    lea edx, [ebx + eax]
    mov ebx, 0x64
    mov eax, edx
    sar edx, 0x1f
    idiv ebx
    mov dword ptr [_CONTROL_DoubleClickSpeed], eax
    cmp eax, 1
    jge control_branch_245
    mov dword ptr [_CONTROL_DoubleClickSpeed], 1
control_branch_245:
    mov dl, byte ptr [_CONTROL_JoystickPort]
    xor eax, eax
    xor ecx, ecx
    xor esi, esi
    test dl, dl
    je control_branch_246
    mov dh, byte ptr [esp]
    cmp dh, 4
    jb control_branch_246
    cmp dh, 6
    ja control_branch_246
    mov byte ptr [esp], 2
control_branch_246:
    mov dl, byte ptr [esp]
    dec dl
    cmp dl, 5
    {disp32} ja control_branch_247
    and edx, 0xff
    jmp dword ptr cs:[edx*4 + control_start_device_table]
control_case_68:
    mov ebx, 2
    mov eax, 1
    mov dword ptr [_CONTROL_NumAxes], ebx
    {disp32} jmp control_branch_247
# Gamepad: genuine2-axis value EBP shares throttle/axes commit with thrustmaster.
control_case_69:
    mov ecx, 1
    xor edx, edx
    mov ebp, 2
    mov dword ptr [_CONTROL_FlightStickMode], edx
    mov dword ptr [_CONTROL_HatEnabled], edx
    jmp control_branch_248
# Joystick: genuine4-axis value EDX has the independent three flag resets.
control_case_71:
    mov ecx, 1
    xor ebx, ebx
    mov edx, 4
    mov dword ptr [_CONTROL_FlightStickMode], ebx
    mov dword ptr [_CONTROL_HatEnabled], ebx
    mov dword ptr [_CONTROL_ThrottleEnabled], ebx
    mov dword ptr [_CONTROL_NumAxes], edx
    jmp control_branch_247
control_case_70:
    mov edx, 6
    mov esi, 1
    mov dword ptr [_CONTROL_NumAxes], edx
    jmp control_branch_247
control_case_72:
    mov ecx, 1
    mov ebp, 4
    xor ebx, ebx
    mov dword ptr [_CONTROL_FlightStickMode], ecx
    mov dword ptr [_CONTROL_HatEnabled], ebx
    mov dword ptr [_CONTROL_ThrottleEnabled], ecx
    jmp control_branch_249
control_case_73:
    mov ecx, 1
    xor edx, edx
    mov ebp, 4
    mov dword ptr [_CONTROL_FlightStickMode], edx
    mov dword ptr [_CONTROL_HatEnabled], ecx
control_branch_248:
    mov dword ptr [_CONTROL_ThrottleEnabled], edx
control_branch_249:
    mov dword ptr [_CONTROL_NumAxes], ebp
control_branch_247:
    xor edi, edi
    mov dword ptr [_CONTROL_MousePresent], edi
    test eax, eax
    je control_branch_250
    mov dword ptr [_CONTROL_NumButtons], 3
    call MOUSE_Init_
    mov dword ptr [_CONTROL_MousePresent], eax
control_branch_250:
    mov eax, dword ptr [_CONTROL_MousePresent]
    test eax, eax
    jne control_branch_251
    mov dword ptr [_CONTROL_MouseEnabled], eax
    jmp control_branch_252
control_branch_251:
    push OFFSET FLAT:msg_mouse
    mov edx, 1
    call printf_
    add esp, 4
    mov dword ptr [_CONTROL_MouseEnabled], edx
control_branch_252:
    xor edx, edx
    xor ebx, ebx
control_branch_254:
    xor edi, edi
    mov dword ptr [ebx + _CONTROL_JoysPresent], edi
    test ecx, ecx
    je control_branch_253
    mov eax, edx
    call CONTROL_StartJoy_
    mov dword ptr [ebx + _CONTROL_JoysPresent], eax
    test eax, eax
    je control_branch_253
    mov dword ptr [_CONTROL_JoystickEnabled], 1
control_branch_253:
    inc edx
    add ebx, 4
    cmp edx, 2
    jl control_branch_254
    cmp dword ptr [_CONTROL_JoystickEnabled], 0
    je control_case_76
    mov al, byte ptr [esp]
    sub al, 2
    cmp al, 4
    ja control_case_76
    and eax, 0xff
    jmp dword ptr cs:[eax*4 + control_start_message_table]
control_case_77:
    push OFFSET FLAT:msg_gamepad
    jmp control_branch_255
control_case_75:
    push OFFSET FLAT:msg_joystick
    jmp control_branch_255
control_case_78:
    push OFFSET FLAT:msg_flightstick
    jmp control_branch_255
control_case_79:
    push OFFSET FLAT:msg_thrustmaster
control_branch_255:
    call printf_
    add esp, 4
control_case_76:
    test esi, esi
    je control_branch_256
    call CONTROL_ExternalStartup_
control_branch_256:
    mov ebx, 0xc
    mov eax, OFFSET FLAT:_CONTROL_UserInputCleared
    xor esi, esi
    xor edx, edx
    mov dword ptr [_CONTROL_ButtonState1], esi
    mov dword ptr [_CONTROL_ButtonState2], esi
    mov dword ptr [_CONTROL_ButtonHeldState1], esi
    mov dword ptr [_CONTROL_ButtonHeldState2], esi
    call memset_
    xor eax, eax
control_branch_257:
    add eax, 8
    xor cl, cl
    mov byte ptr [eax + _CONTROL_Flags-7], cl
    cmp eax, 0x200
    jne control_branch_257
    cmp dword ptr [_CONTROL_ExternalEnabled], 0
    je control_branch_258
    call CONTROL_ExternalSetup_
control_branch_258:
    mov dword ptr [_CONTROL_Started], 1
control_branch_242:
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop ecx
    ret
    nop

# C function CONTROL_Shutdown_; ordinary C counterpart supplies semantics/ABI.
CONTROL_Shutdown_:
    push ebx
    cmp dword ptr [_CONTROL_Started], 0
    je control_branch_259
    xor eax, eax
control_branch_260:
    add eax, 4
    xor ebx, ebx
    mov dword ptr [eax + _CONTROL_JoysPresent-4], ebx
    cmp eax, 8
    jne control_branch_260
    call MOUSE_Shutdown_
    mov dword ptr [_CONTROL_Started], ebx
control_branch_259:
    pop ebx
    ret

.section CONST,"aw",@progbits
.p2align 2
.include "CONTROL_LITERALS.INC"
.section CONST2,"aw",@progbits
.p2align 2
.section _DATA,"aw",@progbits
.p2align 2
_CONTROL_RudderEnabled:
.long 0
_CONTROL_MouseEnabled:
.long 0
_CONTROL_ExternalEnabled:
.long 0
_CONTROL_JoystickEnabled:
.long 0
_CONTROL_JoystickPort:
.byte 0
.p2align 2
_CONTROL_UserInputDelay:
.long -1
_CONTROL_MouseSensitivity:
.long 32768
_CONTROL_JoyXAxis:
.long 0
_CONTROL_JoyYAxis:
.long 0
_CONTROL_JoyXAxis2:
.long 0
_CONTROL_JoyYAxis2:
.long 0
_CONTROL_HatEnabled:
.long 0
_CONTROL_ThrottleEnabled:
.long 0
_CONTROL_FlightStickMode:
.long 0
_CONTROL_NumButtons:
.long 32
_CONTROL_NumAxes:
.long 6
control_clock_ticks:
.long 0

.section _BSS,"aw",@nobits
.p2align 4
_CONTROL_LastAxes:
.skip 6*8
_CONTROL_AxesScale:
.skip 6*4
_CONTROL_Axes:
.skip 6*8
_CONTROL_AxesMap:
.skip 6*4
_CONTROL_DeviceButtonMapping:
.skip 32*4
_CONTROL_DeviceButtonState:
.skip 32*4
_CONTROL_ButtonClickedTime:
.skip 32*4
_CONTROL_Flags:
.skip 64*8
_JoyDefs:
.skip 2*48
_CONTROL_ButtonClickedState:
.skip 32*4
_CONTROL_ButtonClicked:
.skip 32*4
_CONTROL_ButtonClickedCount:
.skip 32*1
_CONTROL_KeyMapping:
.skip 64*2
_CONTROL_JoysPresent:
.skip 2*4
_CONTROL_UserInputCleared:
.skip 3*4
_CONTROL_External:
.skip 1*4
_GetTime:
.skip 1*4
_CONTROL_Started:
.skip 1*4
_ticrate:
.skip 1*4
_CONTROL_DoubleClickSpeed:
.skip 1*4
_CONTROL_ButtonHeldState1:
.skip 1*4
_CONTROL_ButtonHeldState2:
.skip 1*4
_CONTROL_MousePresent:
.skip 1*4
_CONTROL_ButtonState1:
.skip 1*4
_CONTROL_ButtonState2:
.skip 1*4
