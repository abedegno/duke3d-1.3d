# SPDX-License-Identifier: GPL-2.0-or-later
# Named companion within one declared GAME source unit.
# Private text GLOBAL undefined names encode transport only.
.intel_syntax noprefix
.code32
.file "game_fallback.S"
.allow_index_reg
.globl spawn_
.globl checkcommandline_
.extern EGS_
.extern FindDistance2D_
.extern SafeFileExists_
.extern _CommandMusicToggleOff
.extern _CommandSoundToggleOff
.extern _actorscrptr
.extern _camerashitable
.extern _confilename
.extern _connecthead
.extern _eightytwofifty
.extern _groupfilename
.extern _headspritestat
.extern _hittype
.extern _impact_damage
.extern _movesperpacket
.extern _msx
.extern _msy
.extern _myconnectindex
.extern _networkmode
.extern _nextspritestat
.extern _numplayers
.extern _ps
.extern _sector
.extern _sintable
.extern _sprite
.extern _tempbuf
.extern _tempwallptr
.extern _ud
.extern _wall
.extern atol_
.extern badguy_
.extern changespritestat_
.extern check_fta_sounds_
.extern comlinehelp_
.extern exit_
.extern __GAME_UNIT_TEXT_game_text_checkcommandline_1432
.extern __GAME_UNIT_TEXT_game_text_checkcommandline_1464
.extern __GAME_UNIT_TEXT_game_text_checkcommandline_1488
.extern __GAME_UNIT_TEXT_game_text_checkcommandline_1500
.extern __GAME_UNIT_TEXT_game_text_checkcommandline_1512
.extern __GAME_UNIT_TEXT_game_text_checkcommandline_1532
.extern __GAME_UNIT_TEXT_game_text_checkcommandline_1552
.extern __GAME_UNIT_TEXT_game_text_checkcommandline_1572
.extern __GAME_UNIT_TEXT_game_text_checkcommandline_1596
.extern __GAME_UNIT_TEXT_game_text_checkcommandline_1608
.extern __GAME_UNIT_TEXT_game_text_checkcommandline_1624
.extern __GAME_UNIT_TEXT_game_text_checkcommandline_1644
.extern __GAME_UNIT_TEXT_game_text_checkcommandline_1664
.extern __GAME_UNIT_TEXT_game_text_checkcommandline_1672
.extern __GAME_UNIT_TEXT_game_text_spawn_440
.extern __GAME_UNIT_TEXT_game_text_spawn_496
.extern __GAME_UNIT_TEXT_game_text_spawn_536
.extern gameexit_
.extern getangle_
.extern getceilzofslope_
.extern getflorzofslope_
.extern getglobalz_
.extern insertspriteq_
.extern krand_
.extern labs_
.extern makeitfall_
.extern nextsectorneighborz_
.extern printf_
.extern puts_
.extern setinterpolation_
.extern setsectinterpolate_
.extern setsprite_
.extern sprintf_
.extern ssp_
.extern strcpy_
.extern updatesector_
.extern wallswitchcheck_
.set game_text_checkcommandline_1432, __GAME_UNIT_TEXT_game_text_checkcommandline_1432
.set game_text_checkcommandline_1464, __GAME_UNIT_TEXT_game_text_checkcommandline_1464
.set game_text_checkcommandline_1488, __GAME_UNIT_TEXT_game_text_checkcommandline_1488
.set game_text_checkcommandline_1500, __GAME_UNIT_TEXT_game_text_checkcommandline_1500
.set game_text_checkcommandline_1512, __GAME_UNIT_TEXT_game_text_checkcommandline_1512
.set game_text_checkcommandline_1532, __GAME_UNIT_TEXT_game_text_checkcommandline_1532
.set game_text_checkcommandline_1552, __GAME_UNIT_TEXT_game_text_checkcommandline_1552
.set game_text_checkcommandline_1572, __GAME_UNIT_TEXT_game_text_checkcommandline_1572
.set game_text_checkcommandline_1596, __GAME_UNIT_TEXT_game_text_checkcommandline_1596
.set game_text_checkcommandline_1608, __GAME_UNIT_TEXT_game_text_checkcommandline_1608
.set game_text_checkcommandline_1624, __GAME_UNIT_TEXT_game_text_checkcommandline_1624
.set game_text_checkcommandline_1644, __GAME_UNIT_TEXT_game_text_checkcommandline_1644
.set game_text_checkcommandline_1664, __GAME_UNIT_TEXT_game_text_checkcommandline_1664
.set game_text_checkcommandline_1672, __GAME_UNIT_TEXT_game_text_checkcommandline_1672
.set game_text_spawn_440, __GAME_UNIT_TEXT_game_text_spawn_440
.set game_text_spawn_496, __GAME_UNIT_TEXT_game_text_spawn_496
.set game_text_spawn_536, __GAME_UNIT_TEXT_game_text_spawn_536
.section GAME_INIT_ALIGN,"ax",@progbits
    {disp32} lea eax, dword ptr [eax]
    {load} mov edx, edx
.section GAME_SPAWN,"ax",@progbits
game_switch_spawn_31360:
    # Real compiler switch table: 37 named private destinations
    .long game_flow_spawn_46055
    .long game_flow_spawn_43076
    .long game_flow_spawn_46055
    .long game_flow_spawn_44694
    .long game_flow_spawn_45477
    .long game_flow_spawn_46055
    .long game_flow_spawn_46055
    .long game_flow_spawn_42866
    .long game_flow_spawn_45799
    .long game_flow_spawn_45714
    .long game_flow_spawn_47082
    .long game_flow_spawn_45983
    .long game_flow_spawn_43328
    .long game_flow_spawn_43431
    .long game_flow_spawn_46055
    .long game_flow_spawn_46055
    .long game_flow_spawn_46055
    .long game_flow_spawn_44029
    .long game_flow_spawn_47082
    .long game_flow_spawn_43118
    .long game_flow_spawn_44384
    .long game_flow_spawn_47082
    .long game_flow_spawn_47082
    .long game_flow_spawn_47082
    .long game_flow_spawn_44369
    .long game_flow_spawn_43129
    .long game_flow_spawn_46055
    .long game_flow_spawn_43291
    .long game_flow_spawn_47082
    .long game_flow_spawn_47082
    .long game_flow_spawn_46055
    .long game_flow_spawn_44999
    .long game_flow_spawn_45238
    .long game_flow_spawn_47082
    .long game_flow_spawn_47082
    .long game_flow_spawn_43256
    .long game_flow_spawn_47082
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
spawn_:
    push ebx
    push ecx
    push esi
    push edi
    push ebp
    sub esp, 0x28
    mov word ptr [esp + 36], ax
    {store} mov ebx, edx
    test ax, ax
    jl game_flow_spawn_31639
    push 0
    movsx esi, ax
    push esi
    imul esi, esi, 0x2c
    push 0
    push 0
    push 0
    push 0
    push 0
    movsx eax, dx
    push 0
    mov ecx, dword ptr [esi + _sprite + 0x8]
    mov ebx, dword ptr [esi + _sprite + 0x4]
    mov edx, dword ptr [esi + _sprite]
    push eax
    movsx eax, word ptr [esi + _sprite + 0x18]
    call EGS_
    movsx edx, ax
    {store} mov edi, eax
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    {store} mov edx, eax
    mov ax, word ptr [esi + _sprite + 0xe]
    mov word ptr [edx + _hittype + 0x1], ax
    {disp32} jmp game_flow_spawn_32407
# Target-observed in-place spawn initialization and native actor-state memory order.
# EDI is the actual sprite index; EAX addresses its71-byte weaponhit record.
game_flow_spawn_31639:
    movsx esi, dx
    {store} mov edi, edx
    imul edx, esi, 0x2c
    {disp32} lea eax, dword ptr [esi*8]
    {store} add eax, esi
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, esi
    mov cx, word ptr [edx + _sprite + 0xe]
    mov word ptr [eax + _hittype + 0x1], cx
    mov word ptr [edx + _sprite + 0x1e], bx
    mov word ptr [eax + _hittype + 0x7], bx
    {store} xor ecx, ecx
    xor bl, bl
    mov word ptr [eax + _hittype + 0x11], cx
    mov byte ptr [eax + _hittype], bl
    mov ecx, dword ptr [edx + _sprite]
    mov dword ptr [eax + _hittype + 0x23], ecx
    mov ecx, dword ptr [edx + _sprite + 0x4]
    mov dword ptr [eax + _hittype + 0x27], ecx
    mov ecx, dword ptr [edx + _sprite + 0x8]
    mov dword ptr [eax + _hittype + 0x2b], ecx
    {store} xor ecx, ecx
    mov esi, -1
    mov word ptr [eax + _hittype + 0xb], cx
    xor bh, bh
    mov word ptr [eax + _hittype + 0xf], cx
    movsx ecx, word ptr [edx + _sprite + 0x18]
    mov word ptr [eax + _hittype + 0x9], bx
    {disp32} lea ebx, dword ptr [ecx*4]
    mov word ptr [eax + _hittype + 0x5], si
    {store} add ebx, ecx
    mov word ptr [eax + _hittype + 0xd], si
    mov ecx, dword ptr [ebx*8 + _sector + 0x8]
    mov ebx, dword ptr [ebx*8 + _sector + 0x4]
    mov dword ptr [eax + _hittype + 0x13], ecx
    mov dword ptr [eax + _hittype + 0x17], ebx
    {store} xor ebx, ebx
    mov dword ptr [eax + _hittype + 0x1b], ebx
    mov dword ptr [eax + _hittype + 0x1f], ebx
    mov dword ptr [eax + _hittype + 0x43], ebx
    mov dword ptr [eax + _hittype + 0x3f], ebx
    mov dword ptr [eax + _hittype + 0x3b], ebx
    mov dword ptr [eax + _hittype + 0x37], ebx
    mov dword ptr [eax + _hittype + 0x33], ebx
    mov cx, word ptr [edx + _sprite + 0xe]
    mov dword ptr [eax + _hittype + 0x2f], ebx
    cmp cx, 0xa06
    {disp32} je game_flow_spawn_32240
    cmp cx, 0x1f6
    {disp32} je game_flow_spawn_32240
    cmp cx, 0x1f3
    {disp32} je game_flow_spawn_32240
    test byte ptr [edx + _sprite + 0xc], 0x30
    {disp32} je game_flow_spawn_32240
    cmp cx, 0x222
    jl game_flow_spawn_31962
    cmp cx, 0x225
    {disp32} jle game_flow_spawn_32240
game_flow_spawn_31962:
    movsx esi, di
    imul ebx, esi, 0x2c
    cmp byte ptr [ebx + _sprite + 0x10], 0x7f
    {disp32} je game_flow_spawn_47635
    {store} mov eax, esi
    call wallswitchcheck_
    cmp al, 1
    {disp32} jne game_flow_spawn_32178
    mov ax, word ptr [ebx + _sprite + 0xe]
    cmp ax, 0x82
    je game_flow_spawn_32102
    cmp ax, 0xaa
    je game_flow_spawn_32102
    cmp byte ptr [ebx + _sprite + 0x11], 0
    je game_flow_spawn_32102
    mov bx, word ptr [_ud + 0x590]
    cmp bx, 2
    jl game_flow_spawn_32054
    cmp bx, 1
    jle game_flow_spawn_32102
    cmp dword ptr [_ud + 0x5de], 1
    jne game_flow_spawn_32102
game_flow_spawn_32054:
    movsx eax, di
    imul eax, eax, 0x2c
    xor cl, cl
    mov byte ptr [eax + _sprite + 0x15], cl
    mov byte ptr [eax + _sprite + 0x14], cl
    xor ch, ch
    mov word ptr [eax + _sprite + 0x28], cx
    mov word ptr [eax + _sprite + 0x26], cx
    mov word ptr [eax + _sprite + 0xc], cx
    {disp32} jmp game_flow_spawn_47635
game_flow_spawn_32102:
    movsx eax, di
    imul eax, eax, 0x2c
    mov si, word ptr [eax + _sprite + 0xc]
    or esi, 0x101
    mov bl, byte ptr [eax + _sprite + 0x11]
    mov word ptr [eax + _sprite + 0xc], si
    test bl, bl
    {disp32} je game_flow_spawn_47635
    mov dx, word ptr [eax + _sprite + 0xe]
    cmp dx, 0x82
    {disp32} je game_flow_spawn_47635
    cmp dx, 0xaa
    {disp32} je game_flow_spawn_47635
    xor bh, bh
    mov byte ptr [eax + _sprite + 0x11], bh
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_32178:
    cmp word ptr [ebx + _sprite + 0x28], 0
    je game_flow_spawn_32240
    mov edx, 0xc
    {store} mov eax, esi
    call changespritestat_
    mov si, word ptr [ebx + _sprite + 0xc]
    mov ax, word ptr [_impact_damage]
    or esi, 0x101
    mov word ptr [ebx + _sprite + 0x2a], ax
    {store} mov eax, edi
    mov word ptr [ebx + _sprite + 0xc], si
    {disp32} jmp game_flow_spawn_47637
game_flow_spawn_32240:
    movsx eax, di
    imul eax, eax, 0x2c
    mov ch, byte ptr [eax + _sprite + 0xc]
    mov bx, word ptr [eax + _sprite + 0xe]
    test ch, 1
    je game_flow_spawn_32271
    or byte ptr [eax + _sprite + 0xd], 1
game_flow_spawn_32271:
    movsx eax, bx
    {disp32} lea eax, dword ptr [eax*4]
    mov ebp, dword ptr [eax + _actorscrptr]
    test ebp, ebp
    je game_flow_spawn_32372
    movsx esi, di
    imul ebx, esi, 0x2c
    mov ax, word ptr [ebp]
    mov word ptr [ebx + _sprite + 0x2a], ax
    {disp32} lea eax, dword ptr [esi*8]
    {store} add eax, esi
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, esi
    mov ecx, dword ptr [ebp + 4]
    mov dword ptr [eax + _hittype + 0x3f], ecx
    mov ecx, dword ptr [ebp + 8]
    mov dword ptr [eax + _hittype + 0x33], ecx
    mov ecx, dword ptr [ebp + 12]
    {store} mov edx, ebp
    test ecx, ecx
    je game_flow_spawn_32407
    cmp word ptr [ebx + _sprite + 0x28], 0
    jne game_flow_spawn_32407
    mov ax, word ptr [ebp + 12]
    mov word ptr [ebx + _sprite + 0x28], ax
    jmp game_flow_spawn_32407
game_flow_spawn_32372:
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov dword ptr [eax + _hittype + 0x3f], ebp
    mov dword ptr [eax + _hittype + 0x33], ebp
game_flow_spawn_32407:
    movsx ebp, di
    imul esi, ebp, 0x2c
    add esi, OFFSET FLAT:_sprite
    mov ax, word ptr [esi + 24]
    mov dword ptr [esp + 20], eax
    mov ax, word ptr [esi + 14]
    .att_syntax prefix
    cmpw $game_math_spawn_32431,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_34225
    {disp32} jbe game_flow_spawn_37763
    .att_syntax prefix
    cmpw $game_math_spawn_32447,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_33370
    {disp32} jbe game_flow_spawn_36329
    .att_syntax prefix
    cmpw $game_math_spawn_32463,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_32958
    {disp32} jbe game_flow_spawn_42369
    .att_syntax prefix
    cmpw $game_math_spawn_32479,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_32696
    {disp32} jbe game_flow_spawn_38958
    .att_syntax prefix
    cmpw $game_math_spawn_32495,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_32610
    {disp32} jbe game_flow_spawn_40946
    .att_syntax prefix
    cmpw $game_math_spawn_32507,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_32573
    {disp32} jbe game_flow_spawn_38596
    .att_syntax prefix
    cmpw $game_math_spawn_32519,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_32552
    {disp32} jbe game_flow_spawn_38349
    .att_syntax prefix
    cmpw $game_math_spawn_32531,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_36644
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_32552:
    .att_syntax prefix
    cmpw $game_math_spawn_32552,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_38596
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_32573:
    .att_syntax prefix
    cmpw $game_math_spawn_32573,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_40980
    .att_syntax prefix
    cmpw $game_math_spawn_32589,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_40980
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_32610:
    .att_syntax prefix
    cmpw $game_math_spawn_32610,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_32659
    {disp32} jbe game_flow_spawn_36735
    .att_syntax prefix
    cmpw $game_math_spawn_32622,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_36817
    .att_syntax prefix
    cmpw $game_math_spawn_32638,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_40980
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_32659:
    .att_syntax prefix
    cmpw $game_math_spawn_32659,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_38958
    .att_syntax prefix
    cmpw $game_math_spawn_32675,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_37503
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_32696:
    .att_syntax prefix
    cmpw $game_math_spawn_32696,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_32811
    {disp32} jbe game_flow_spawn_39407
    .att_syntax prefix
    cmpw $game_math_spawn_32708,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_32774
    {disp32} jbe game_flow_spawn_40980
    .att_syntax prefix
    cmpw $game_math_spawn_32720,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_32753
    {disp32} jbe game_flow_spawn_40994
    .att_syntax prefix
    cmpw $game_math_spawn_32732,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_38572
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_32753:
    .att_syntax prefix
    cmpw $game_math_spawn_32753,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_40560
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_32774:
    .att_syntax prefix
    cmpw $game_math_spawn_32774,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_42341
    .att_syntax prefix
    cmpw $game_math_spawn_32790,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_40980
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_32811:
    .att_syntax prefix
    cmpw $game_math_spawn_32811,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_32860
    {disp32} jbe game_flow_spawn_41515
    .att_syntax prefix
    cmpw $game_math_spawn_32823,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_39407
    .att_syntax prefix
    cmpw $game_math_spawn_32839,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_42369
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_32860:
    .att_syntax prefix
    cmpw $game_math_spawn_32860,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_36305
    .att_syntax prefix
    cmpw $game_math_spawn_32876,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    or byte ptr [esi + 12], 0x10
    call krand_
    and al, 7
    add al, 7
    mov edx, 5
    mov byte ptr [esi + 20], al
    call krand_
    and al, 7
    mov ecx, dword ptr [esi + 8]
    add al, 7
    sub ecx, 0x1000
    mov byte ptr [esi + 21], al
    movsx eax, di
    mov dword ptr [esi + 8], ecx
    call insertspriteq_
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_32958:
    .att_syntax prefix
    cmpw $game_math_spawn_32958,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_33175
    {disp32} jbe game_flow_spawn_40946
    .att_syntax prefix
    cmpw $game_math_spawn_32974,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_33089
    {disp32} jbe game_flow_spawn_40946
    .att_syntax prefix
    cmpw $game_math_spawn_32986,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_33052
    {disp32} jbe game_flow_spawn_40994
    .att_syntax prefix
    cmpw $game_math_spawn_32998,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_33031
    {disp32} jbe game_flow_spawn_39407
    .att_syntax prefix
    cmpw $game_math_spawn_33010,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_39407
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_33031:
    .att_syntax prefix
    cmpw $game_math_spawn_33031,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_37461
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_33052:
    .att_syntax prefix
    cmpw $game_math_spawn_33052,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_40994
    .att_syntax prefix
    cmpw $game_math_spawn_33068,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_40994
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_33089:
    .att_syntax prefix
    cmpw $game_math_spawn_33089,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_33138
    {disp32} jbe game_flow_spawn_40946
    .att_syntax prefix
    cmpw $game_math_spawn_33101,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_40946
    .att_syntax prefix
    cmpw $game_math_spawn_33117,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_40994
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_33138:
    .att_syntax prefix
    cmpw $game_math_spawn_33138,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_41662
    .att_syntax prefix
    cmpw $game_math_spawn_33154,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_40994
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_33175:
    .att_syntax prefix
    cmpw $game_math_spawn_33175,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_33290
    {disp32} jbe game_flow_spawn_40994
    .att_syntax prefix
    cmpw $game_math_spawn_33187,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_33253
    {disp32} jbe game_flow_spawn_40946
    .att_syntax prefix
    cmpw $game_math_spawn_33199,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_33232
    {disp32} jbe game_flow_spawn_39407
    .att_syntax prefix
    cmpw $game_math_spawn_33211,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_40994
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_33232:
    .att_syntax prefix
    cmpw $game_math_spawn_33232,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_40994
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_33253:
    .att_syntax prefix
    cmpw $game_math_spawn_33253,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_40994
    .att_syntax prefix
    cmpw $game_math_spawn_33269,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_40994
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_33290:
    .att_syntax prefix
    cmpw $game_math_spawn_33290,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_33339
    {disp32} jbe game_flow_spawn_40946
    .att_syntax prefix
    cmpw $game_math_spawn_33302,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_40994
    .att_syntax prefix
    cmpw $game_math_spawn_33318,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_40994
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_33339:
    .att_syntax prefix
    cmpw $game_math_spawn_33339,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_39407
    .att_syntax prefix
    cmpw $game_math_spawn_33355,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jmp game_flow_spawn_40994
game_flow_spawn_33370:
    .att_syntax prefix
    cmpw $game_math_spawn_33370,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_33816
    {disp32} jbe game_flow_spawn_40540
    .att_syntax prefix
    cmpw $game_math_spawn_33386,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_33625
    {disp32} jbe game_flow_spawn_37677
    .att_syntax prefix
    cmpw $game_math_spawn_33402,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_33517
    {disp32} jbe game_flow_spawn_38349
    .att_syntax prefix
    cmpw $game_math_spawn_33414,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_33480
    {disp32} jbe game_flow_spawn_38473
    .att_syntax prefix
    cmpw $game_math_spawn_33426,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_33459
    {disp32} jbe game_flow_spawn_36889
    .att_syntax prefix
    cmpw $game_math_spawn_33438,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_36430
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_33459:
    .att_syntax prefix
    cmpw $game_math_spawn_33459,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_40994
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_33480:
    .att_syntax prefix
    cmpw $game_math_spawn_33480,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_39705
    .att_syntax prefix
    cmpw $game_math_spawn_33496,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_39608
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_33517:
    .att_syntax prefix
    cmpw $game_math_spawn_33517,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_33566
    {disp32} jbe game_flow_spawn_39407
    .att_syntax prefix
    cmpw $game_math_spawn_33529,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_36004
    .att_syntax prefix
    cmpw $game_math_spawn_33545,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_47464
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_33566:
    .att_syntax prefix
    cmpw $game_math_spawn_33566,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_33586
    .att_syntax prefix
    cmpw $game_math_spawn_33576,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
game_flow_spawn_33586:
    mov bx, word ptr [esi + 12]
    mov byte ptr [esi + 18], 0x20
    or ebx, 0x101
    mov word ptr [esi + 12], bx
game_flow_spawn_33604:
    movsx eax, di
    {store} xor edx, edx
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_33625:
    .att_syntax prefix
    cmpw $game_math_spawn_33625,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_33730
    {disp32} jbe game_flow_spawn_38384
    .att_syntax prefix
    cmpw $game_math_spawn_33637,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_33699
    {disp32} jbe game_flow_spawn_38349
    .att_syntax prefix
    cmpw $game_math_spawn_33649,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_33678
    {disp32} jbe game_flow_spawn_41963
    .att_syntax prefix
    cmpw $game_math_spawn_33661,%ax
    .intel_syntax noprefix
    je game_flow_spawn_33586
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_33678:
    .att_syntax prefix
    cmpw $game_math_spawn_33678,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_38572
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_33699:
    .att_syntax prefix
    cmpw $game_math_spawn_33699,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_38349
    .att_syntax prefix
    cmpw $game_math_spawn_33709,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_38349
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_33730:
    .att_syntax prefix
    cmpw $game_math_spawn_33730,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_33779
    {disp32} jbe game_flow_spawn_38349
    .att_syntax prefix
    cmpw $game_math_spawn_33742,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_38349
    .att_syntax prefix
    cmpw $game_math_spawn_33758,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_38349
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_33779:
    .att_syntax prefix
    cmpw $game_math_spawn_33779,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_38349
    .att_syntax prefix
    cmpw $game_math_spawn_33795,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_38349
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_33816:
    .att_syntax prefix
    cmpw $game_math_spawn_33816,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_34037
    {disp32} jbe game_flow_spawn_37763
    .att_syntax prefix
    cmpw $game_math_spawn_33832,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_33947
    {disp32} jbe game_flow_spawn_47464
    .att_syntax prefix
    cmpw $game_math_spawn_33844,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_33910
    {disp32} jbe game_flow_spawn_42709
    .att_syntax prefix
    cmpw $game_math_spawn_33856,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_33889
    {disp32} jbe game_flow_spawn_36430
    .att_syntax prefix
    cmpw $game_math_spawn_33868,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_40994
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_33889:
    .att_syntax prefix
    cmpw $game_math_spawn_33889,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_42770
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_33910:
    .att_syntax prefix
    cmpw $game_math_spawn_33910,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_47464
    .att_syntax prefix
    cmpw $game_math_spawn_33926,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_47200
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_33947:
    .att_syntax prefix
    cmpw $game_math_spawn_33947,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_34000
    .att_syntax prefix
    cmpw $game_math_spawn_33953,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_47464
    .att_syntax prefix
    cmpw $game_math_spawn_33963,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_47458
    .att_syntax prefix
    cmpw $game_math_spawn_33979,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_38811
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_34000:
    .att_syntax prefix
    cmpw $game_math_spawn_34000,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_39928
    .att_syntax prefix
    cmpw $game_math_spawn_34016,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_36935
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_34037:
    .att_syntax prefix
    cmpw $game_math_spawn_34037,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_34145
    {disp32} jbe game_flow_spawn_47458
    .att_syntax prefix
    cmpw $game_math_spawn_34049,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_34108
    {disp32} jbe game_flow_spawn_41662
    .att_syntax prefix
    cmpw $game_math_spawn_34061,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_37763
    .att_syntax prefix
    cmpw $game_math_spawn_34077,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    .att_syntax prefix
    cmpw $game_math_spawn_34087,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_33586
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_34108:
    .att_syntax prefix
    cmpw $game_math_spawn_34108,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_40592
    .att_syntax prefix
    cmpw $game_math_spawn_34124,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_47200
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_34145:
    .att_syntax prefix
    cmpw $game_math_spawn_34145,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_34194
    {disp32} jbe game_flow_spawn_36277
    .att_syntax prefix
    cmpw $game_math_spawn_34157,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_37763
    .att_syntax prefix
    cmpw $game_math_spawn_34173,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_33586
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_34194:
    .att_syntax prefix
    cmpw $game_math_spawn_34194,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_33586
    .att_syntax prefix
    cmpw $game_math_spawn_34204,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_47464
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_34225:
    .att_syntax prefix
    cmpw $game_math_spawn_34225,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_35157
    {disp32} jbe game_flow_spawn_33586
    .att_syntax prefix
    cmpw $game_math_spawn_34241,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_34711
    {disp32} jbe game_flow_spawn_47464
    .att_syntax prefix
    cmpw $game_math_spawn_34257,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_34488
    .att_syntax prefix
    cmpw $game_math_spawn_34267,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_33586
    .att_syntax prefix
    cmpw $game_math_spawn_34277,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_34414
    {disp32} jbe game_flow_spawn_33586
    .att_syntax prefix
    cmpw $game_math_spawn_34293,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_34377
    .att_syntax prefix
    cmpw $game_math_spawn_34299,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_33586
    .att_syntax prefix
    cmpw $game_math_spawn_34309,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_34346
    .att_syntax prefix
    cmpw $game_math_spawn_34315,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_33586
    .att_syntax prefix
    cmpw $game_math_spawn_34325,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_38713
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_34346:
    .att_syntax prefix
    cmpw $game_math_spawn_34346,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    .att_syntax prefix
    cmpw $game_math_spawn_34356,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_36277
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_34377:
    .att_syntax prefix
    cmpw $game_math_spawn_34377,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_37763
    .att_syntax prefix
    cmpw $game_math_spawn_34393,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_42290
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_34414:
    .att_syntax prefix
    cmpw $game_math_spawn_34414,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_34457
    {disp32} jbe game_flow_spawn_42599
    .att_syntax prefix
    cmpw $game_math_spawn_34426,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_42290
    .att_syntax prefix
    cmpw $game_math_spawn_34436,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_33586
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_34457:
    .att_syntax prefix
    cmpw $game_math_spawn_34457,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_33604
    .att_syntax prefix
    cmpw $game_math_spawn_34467,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_33586
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_34488:
    .att_syntax prefix
    cmpw $game_math_spawn_34488,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_34621
    {disp32} jbe game_flow_spawn_47618
    .att_syntax prefix
    cmpw $game_math_spawn_34504,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_34580
    {disp32} jbe game_flow_spawn_42502
    .att_syntax prefix
    cmpw $game_math_spawn_34516,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_34559
    {disp32} jbe game_flow_spawn_38787
    .att_syntax prefix
    cmpw $game_math_spawn_34528,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    .att_syntax prefix
    cmpw $game_math_spawn_34538,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_33586
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_34559:
    .att_syntax prefix
    cmpw $game_math_spawn_34559,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_42290
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_34580:
    .att_syntax prefix
    cmpw $game_math_spawn_34580,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    .att_syntax prefix
    cmpw $game_math_spawn_34590,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_36277
    .att_syntax prefix
    cmpw $game_math_spawn_34600,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_33586
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_34621:
    .att_syntax prefix
    cmpw $game_math_spawn_34621,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_34674
    {disp32} jbe game_flow_spawn_33586
    .att_syntax prefix
    cmpw $game_math_spawn_34633,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    .att_syntax prefix
    cmpw $game_math_spawn_34643,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_37763
    .att_syntax prefix
    cmpw $game_math_spawn_34653,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_47277
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_34674:
    .att_syntax prefix
    cmpw $game_math_spawn_34674,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_42290
    .att_syntax prefix
    cmpw $game_math_spawn_34690,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_42290
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_34711:
    .att_syntax prefix
    cmpw $game_math_spawn_34711,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_34950
    {disp32} jbe game_flow_spawn_33586
    .att_syntax prefix
    cmpw $game_math_spawn_34727,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_34860
    {disp32} jbe game_flow_spawn_33586
    .att_syntax prefix
    cmpw $game_math_spawn_34743,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_34819
    {disp32} jbe game_flow_spawn_33586
    .att_syntax prefix
    cmpw $game_math_spawn_34755,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_34798
    {disp32} jbe game_flow_spawn_37763
    .att_syntax prefix
    cmpw $game_math_spawn_34767,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    .att_syntax prefix
    cmpw $game_math_spawn_34777,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_38384
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_34798:
    .att_syntax prefix
    cmpw $game_math_spawn_34798,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_33586
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_34819:
    .att_syntax prefix
    cmpw $game_math_spawn_34819,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    .att_syntax prefix
    cmpw $game_math_spawn_34829,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_33586
    .att_syntax prefix
    cmpw $game_math_spawn_34839,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_33586
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_34860:
    .att_syntax prefix
    cmpw $game_math_spawn_34860,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_34909
    {disp32} jbe game_flow_spawn_33586
    .att_syntax prefix
    cmpw $game_math_spawn_34872,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_38349
    .att_syntax prefix
    cmpw $game_math_spawn_34888,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_38673
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_34909:
    .att_syntax prefix
    cmpw $game_math_spawn_34909,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    .att_syntax prefix
    cmpw $game_math_spawn_34919,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_33586
    .att_syntax prefix
    cmpw $game_math_spawn_34929,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_33586
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_34950:
    .att_syntax prefix
    cmpw $game_math_spawn_34950,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_35069
    {disp32} jbe game_flow_spawn_40808
    .att_syntax prefix
    cmpw $game_math_spawn_34962,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_35038
    {disp32} jbe game_flow_spawn_47513
    .att_syntax prefix
    cmpw $game_math_spawn_34974,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_35017
    {disp32} jbe game_flow_spawn_33586
    .att_syntax prefix
    cmpw $game_math_spawn_34986,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    .att_syntax prefix
    cmpw $game_math_spawn_34996,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_33586
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_35017:
    .att_syntax prefix
    cmpw $game_math_spawn_35017,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_33586
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_35038:
    .att_syntax prefix
    cmpw $game_math_spawn_35038,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_33586
    .att_syntax prefix
    cmpw $game_math_spawn_35054,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jmp game_flow_spawn_37803
game_flow_spawn_35069:
    .att_syntax prefix
    cmpw $game_math_spawn_35069,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_35106
    .att_syntax prefix
    cmpw $game_math_spawn_35075,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_40841
    .att_syntax prefix
    cmpw $game_math_spawn_35085,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_40325
    {disp32} jmp game_flow_spawn_39815
game_flow_spawn_35106:
    .att_syntax prefix
    cmpw $game_math_spawn_35106,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    .att_syntax prefix
    cmpw $game_math_spawn_35116,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_33586
    .att_syntax prefix
    cmpw $game_math_spawn_35126,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    .att_syntax prefix
    cmpw $game_math_spawn_35136,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_42570
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_35157:
    .att_syntax prefix
    cmpw $game_math_spawn_35157,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_35585
    .att_syntax prefix
    cmpw $game_math_spawn_35167,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_33586
    .att_syntax prefix
    cmpw $game_math_spawn_35177,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_35386
    {disp32} jbe game_flow_spawn_42570
    .att_syntax prefix
    cmpw $game_math_spawn_35193,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_35302
    {disp32} jbe game_flow_spawn_37729
    .att_syntax prefix
    cmpw $game_math_spawn_35205,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_35271
    {disp32} jbe game_flow_spawn_33586
    .att_syntax prefix
    cmpw $game_math_spawn_35217,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_35250
    {disp32} jbe game_flow_spawn_33586
    .att_syntax prefix
    cmpw $game_math_spawn_35229,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_37763
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_35250:
    .att_syntax prefix
    cmpw $game_math_spawn_35250,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_38349
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_35271:
    .att_syntax prefix
    cmpw $game_math_spawn_35271,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_41662
    .att_syntax prefix
    cmpw $game_math_spawn_35281,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_33586
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_35302:
    .att_syntax prefix
    cmpw $game_math_spawn_35302,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_35345
    {disp32} jbe game_flow_spawn_37729
    .att_syntax prefix
    cmpw $game_math_spawn_35314,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_47419
    .att_syntax prefix
    cmpw $game_math_spawn_35324,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_47419
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_35345:
    .att_syntax prefix
    cmpw $game_math_spawn_35345,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    .att_syntax prefix
    cmpw $game_math_spawn_35355,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_33586
    .att_syntax prefix
    cmpw $game_math_spawn_35365,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_42275
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_35386:
    .att_syntax prefix
    cmpw $game_math_spawn_35386,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_35499
    {disp32} jbe game_flow_spawn_38918
    .att_syntax prefix
    cmpw $game_math_spawn_35398,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_35462
    .att_syntax prefix
    cmpw $game_math_spawn_35404,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_33586
    .att_syntax prefix
    cmpw $game_math_spawn_35414,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_35447
    {disp32} jbe game_flow_spawn_37803
    .att_syntax prefix
    cmpw $game_math_spawn_35426,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_36277
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_35447:
    .att_syntax prefix
    cmpw $game_math_spawn_35447,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jmp game_flow_spawn_47277
game_flow_spawn_35462:
    .att_syntax prefix
    cmpw $game_math_spawn_35462,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_38918
    .att_syntax prefix
    cmpw $game_math_spawn_35478,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_37763
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_35499:
    .att_syntax prefix
    cmpw $game_math_spawn_35499,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_35548
    {disp32} jbe game_flow_spawn_33586
    .att_syntax prefix
    cmpw $game_math_spawn_35511,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_38596
    .att_syntax prefix
    cmpw $game_math_spawn_35527,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_38596
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_35548:
    .att_syntax prefix
    cmpw $game_math_spawn_35548,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_37763
    .att_syntax prefix
    cmpw $game_math_spawn_35564,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_37763
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_35585:
    .att_syntax prefix
    cmpw $game_math_spawn_35585,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_35808
    {disp32} jbe game_flow_spawn_41963
    .att_syntax prefix
    cmpw $game_math_spawn_35601,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_35710
    {disp32} jbe game_flow_spawn_42101
    .att_syntax prefix
    cmpw $game_math_spawn_35613,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_35679
    {disp32} jbe game_flow_spawn_36291
    .att_syntax prefix
    cmpw $game_math_spawn_35625,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_35658
    {disp32} jbe game_flow_spawn_37763
    .att_syntax prefix
    cmpw $game_math_spawn_35637,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_37763
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_35658:
    .att_syntax prefix
    cmpw $game_math_spawn_35658,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_41473
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_35679:
    .att_syntax prefix
    cmpw $game_math_spawn_35679,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_41963
    .att_syntax prefix
    cmpw $game_math_spawn_35689,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_41963
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_35710:
    .att_syntax prefix
    cmpw $game_math_spawn_35710,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_35767
    .att_syntax prefix
    cmpw $game_math_spawn_35716,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_41963
    .att_syntax prefix
    cmpw $game_math_spawn_35726,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    .att_syntax prefix
    cmpw $game_math_spawn_35736,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_41963
    .att_syntax prefix
    cmpw $game_math_spawn_35746,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_41963
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_35767:
    .att_syntax prefix
    cmpw $game_math_spawn_35767,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    .att_syntax prefix
    cmpw $game_math_spawn_35777,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_41963
    .att_syntax prefix
    cmpw $game_math_spawn_35787,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_41963
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_35808:
    .att_syntax prefix
    cmpw $game_math_spawn_35808,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_35904
    {disp32} jbe game_flow_spawn_41440
    .att_syntax prefix
    cmpw $game_math_spawn_35820,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_35867
    .att_syntax prefix
    cmpw $game_math_spawn_35826,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_41963
    .att_syntax prefix
    cmpw $game_math_spawn_35836,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_41642
    .att_syntax prefix
    cmpw $game_math_spawn_35846,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_41963
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_35867:
    .att_syntax prefix
    cmpw $game_math_spawn_35867,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_40905
    .att_syntax prefix
    cmpw $game_math_spawn_35883,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_spawn_39321
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_35904:
    .att_syntax prefix
    cmpw $game_math_spawn_35904,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_35931
    {disp32} jbe game_flow_spawn_40622
    .att_syntax prefix
    cmpw $game_math_spawn_35916,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_spawn_35947
    {disp32} jmp game_flow_spawn_39327
game_flow_spawn_35931:
    .att_syntax prefix
    cmpw $game_math_spawn_35931,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_spawn_47635
    {disp32} jbe game_flow_spawn_42794
game_flow_spawn_35947:
    or byte ptr [esi + 13], 0x80
    cmp word ptr [esi + 14], 4
    jne game_flow_spawn_35980
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    xor byte ptr [eax*8 + _sector + 0x23], 0x40
game_flow_spawn_35980:
    mov edx, 8
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_36004:
    mov ebx, dword ptr [esp + 36]
    test bx, bx
    jl game_flow_spawn_36061
    movsx eax, bx
    imul eax, eax, 0x2c
    movsx ecx, bx
    imul ecx, ecx, 0x2c
    mov ebx, dword ptr [eax + _sprite + 0x4]
    movsx eax, word ptr [esp + 36]
    imul eax, eax, 0x2c
    mov ecx, dword ptr [ecx + _sprite + 0x8]
    mov edx, dword ptr [eax + _sprite]
    movsx eax, di
    call setsprite_
game_flow_spawn_36061:
    call krand_
    and al, 0xf
    mov byte ptr [esi + 16], 0xf0
    add al, 0x10
    mov bl, byte ptr [esi + 12]
    mov byte ptr [esi + 21], al
    or bl, 0x80
    mov byte ptr [esi + 20], al
    mov ecx, dword ptr [esp + 36]
    mov byte ptr [esi + 12], bl
    test cx, cx
    {disp32} jl game_flow_spawn_36230
    movsx eax, cx
    imul eax, eax, 0x2c
    movsx edx, word ptr [eax + _sprite + 0x18]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    mov dx, word ptr [eax + _sector + 0x22]
    cmp dx, 2
    jne game_flow_spawn_36191
    movsx eax, di
    imul eax, eax, 0x2c
    mov ebx, dword ptr [eax + _sprite + 0x4]
    mov edx, dword ptr [eax + _sprite]
    movsx eax, word ptr [eax + _sprite + 0x18]
    call getceilzofslope_
    mov bh, byte ptr [esi + 12]
    .att_syntax prefix
    addl $game_math_spawn_36175,%eax
    .intel_syntax noprefix
    or bh, 8
    mov dword ptr [esi + 8], eax
    mov byte ptr [esi + 12], bh
    jmp game_flow_spawn_36230
game_flow_spawn_36191:
    cmp dx, 1
    jne game_flow_spawn_36230
    movsx eax, di
    imul eax, eax, 0x2c
    mov ebx, dword ptr [eax + _sprite + 0x4]
    mov edx, dword ptr [eax + _sprite]
    movsx eax, word ptr [eax + _sprite + 0x18]
    call getflorzofslope_
    mov dword ptr [esi + 8], eax
game_flow_spawn_36230:
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    cmp word ptr [eax + _sector + 0x18], 0xc8
    je game_flow_spawn_36273
    cmp word ptr [eax + _sector + 0x10], 0xc8
    jne game_flow_spawn_36277
game_flow_spawn_36273:
    mov byte ptr [esi + 17], 7
game_flow_spawn_36277:
    cmp word ptr [esi + 14], 0x564
    je game_flow_spawn_36291
    or word ptr [esi + 12], 0x101
game_flow_spawn_36291:
    cmp word ptr [esi + 14], 0x227
    jne game_flow_spawn_36305
    or word ptr [esi + 12], 0x101
game_flow_spawn_36305:
    mov edx, 5
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_36329:
    mov ebx, dword ptr [esp + 36]
    test bx, bx
    jl game_flow_spawn_36355
    movsx eax, bx
    imul eax, eax, 0x2c
    mov ax, word ptr [eax + _sprite + 0x1c]
    mov word ptr [esi + 28], ax
game_flow_spawn_36355:
    mov ebp, dword ptr [esi + 8]
    sub ebp, 0x2600
    mov edx, 0x100
    mov dword ptr [esi + 8], ebp
    call krand_
    and ah, 1
    {store} sub edx, eax
    mov word ptr [esi + 36], dx
    call krand_
    xor ah, ah
    mov edx, 0x40
    and al, 0x7f
    {store} sub edx, eax
    movsx eax, di
    mov word ptr [esi + 32], dx
    mov edx, 4
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_36430:
    movsx eax, word ptr [esp + 36]
    cmp eax, -1
    {disp32} je game_flow_spawn_47635
    imul eax, eax, 0x2c
    cmp word ptr [esi + 14], 0x4ed
    jne game_flow_spawn_36496
    mov byte ptr [esi + 20], 0x1f
    mov byte ptr [esi + 21], 1
    movsx edx, word ptr [eax + _sprite + 0x18]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov eax, dword ptr [eax*8 + _sector + 0x8]
    sub eax, 0x2800
    mov dword ptr [esi + 8], eax
    jmp game_flow_spawn_36556
game_flow_spawn_36496:
    cmp word ptr [eax + _sprite + 0x1a], 4
    jne game_flow_spawn_36516
    mov byte ptr [esi + 20], 8
    mov byte ptr [esi + 21], 8
    jmp game_flow_spawn_36556
game_flow_spawn_36516:
    mov byte ptr [esi + 20], 0x30
    mov byte ptr [esi + 21], 0x40
    cmp word ptr [eax + _sprite + 0x1a], 0xa
    je game_flow_spawn_36549
    add eax, OFFSET FLAT:_sprite
    call badguy_
    test ax, ax
    je game_flow_spawn_36556
game_flow_spawn_36549:
    sub dword ptr [esi + 8], 0x2000
game_flow_spawn_36556:
    movsx eax, word ptr [esp + 36]
    imul eax, eax, 0x2c
    mov byte ptr [esi + 16], 0x81
    mov word ptr [esi + 12], 0x82
    mov edx, 5
    mov ax, word ptr [eax + _sprite + 0x1c]
    movsx ebp, di
    mov word ptr [esi + 28], ax
    {store} mov eax, ebp
    mov word ptr [esi + 32], 0x80
    call changespritestat_
    mov edx, 0x10001
    {store} mov eax, ebp
    call ssp_
    {store} mov eax, ebp
    mov ecx, dword ptr [esi + 8]
    mov ebx, dword ptr [esi + 4]
    mov edx, dword ptr [esi]
    call setsprite_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_36644:
    mov eax, dword ptr [esp + 36]
    test ax, ax
    {disp32} jl game_flow_spawn_47635
    cwde
    imul eax, eax, 0x2c
    mov dl, byte ptr [eax + _sprite + 0x14]
    mov byte ptr [esi + 20], dl
    mov dl, byte ptr [eax + _sprite + 0x15]
    mov byte ptr [esi + 21], dl
    movsx ebx, word ptr [eax + _sprite + 0xe]
    {disp32} lea eax, dword ptr [ebp*8]
    {store} add eax, ebp
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ebp
    mov edx, 5
    mov dword ptr [eax + _hittype + 0x33], ebx
    {store} mov eax, ebp
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_36735:
    mov byte ptr [esi + 20], 0x20
    mov byte ptr [esi + 21], 6
    mov edx, dword ptr [esp + 36]
    mov word ptr [esi + 12], 0x10
    test dx, dx
    jl game_flow_spawn_36793
    movsx edx, dx
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov ax, word ptr [eax + _hittype + 0x43]
    add ah, 2
    mov word ptr [esi + 28], ax
game_flow_spawn_36793:
    mov edx, 5
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_36817:
    movsx eax, word ptr [esp + 36]
    cmp eax, -1
    jne game_flow_spawn_36856
    mov edx, 2
    {store} mov eax, ebp
    mov word ptr [esi + 12], 0x8000
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_36856:
    mov byte ptr [esi + 21], 1
    mov al, byte ptr [esi + 21]
    mov edx, 5
    mov byte ptr [esi + 20], al
    {store} mov eax, ebp
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_36889:
    mov byte ptr [esi + 21], 0x10
    mov edx, 5
    mov ebx, dword ptr [esi + 8]
    mov al, byte ptr [esi + 21]
    sub ebx, 0x1a00
    mov byte ptr [esi + 20], al
    movsx eax, di
    mov dword ptr [esi + 8], ebx
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_36935:
    mov ax, word ptr [esi + 24]
    mov dword ptr [esp + 28], eax
    lea ebx, dword ptr [esp + 28]
    mov edx, dword ptr [esi + 4]
    mov eax, dword ptr [esi]
    add edx, 0x6c
    add eax, 0x6c
    call updatesector_
    cmp word ptr [esp + 28], 0
    {disp32} jl game_flow_spawn_37269
    movsx edx, word ptr [esi + 24]
    {disp32} lea ebx, dword ptr [edx*4]
    {store} add ebx, edx
    movsx edx, word ptr [esp + 28]
    {disp32} lea eax, dword ptr [edx*4]
    {disp32} lea ebx, dword ptr [ebx*8]
    {store} add eax, edx
    mov ecx, dword ptr [ebx + _sector + 0x8]
    cmp ecx, dword ptr [eax*8 + _sector + 0x8]
    {disp32} jne game_flow_spawn_37269
    lea ebx, dword ptr [esp + 28]
    mov edx, dword ptr [esi + 4]
    mov eax, dword ptr [esi]
    sub edx, 0x6c
    sub eax, 0x6c
    call updatesector_
    cmp word ptr [esp + 28], 0
    {disp32} jl game_flow_spawn_37269
    movsx edx, word ptr [esi + 24]
    {disp32} lea ebx, dword ptr [edx*4]
    {store} add ebx, edx
    movsx edx, word ptr [esp + 28]
    {disp32} lea eax, dword ptr [edx*4]
    {disp32} lea ebx, dword ptr [ebx*8]
    {store} add eax, edx
    mov ebp, dword ptr [ebx + _sector + 0x8]
    cmp ebp, dword ptr [eax*8 + _sector + 0x8]
    {disp32} jne game_flow_spawn_37269
    lea ebx, dword ptr [esp + 28]
    mov edx, dword ptr [esi + 4]
    mov eax, dword ptr [esi]
    sub edx, 0x6c
    add eax, 0x6c
    call updatesector_
    mov ecx, dword ptr [esp + 28]
    test cx, cx
    {disp32} jl game_flow_spawn_37269
    movsx edx, word ptr [esi + 24]
    {disp32} lea ebx, dword ptr [edx*4]
    {store} add ebx, edx
    movsx edx, cx
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    {disp32} lea ebx, dword ptr [ebx*8]
    mov eax, dword ptr [eax*8 + _sector + 0x8]
    cmp eax, dword ptr [ebx + _sector + 0x8]
    jne game_flow_spawn_37269
    lea ebx, dword ptr [esp + 28]
    mov edx, dword ptr [esi + 4]
    mov eax, dword ptr [esi]
    add edx, 0x6c
    sub eax, 0x6c
    call updatesector_
    mov eax, dword ptr [esp + 28]
    test ax, ax
    jl game_flow_spawn_37303
    movsx edx, word ptr [esi + 24]
    {disp32} lea ebx, dword ptr [edx*4]
    {store} add ebx, edx
    movsx edx, ax
    {disp32} lea eax, dword ptr [edx*4]
    {disp32} lea ebx, dword ptr [ebx*8]
    {store} add eax, edx
    mov ecx, dword ptr [ebx + _sector + 0x8]
    cmp ecx, dword ptr [eax*8 + _sector + 0x8]
    je game_flow_spawn_37303
game_flow_spawn_37269:
    mov byte ptr [esi + 21], 0
    mov al, byte ptr [esi + 21]
    mov edx, 5
    mov byte ptr [esi + 20], al
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_37303:
    movsx ebx, di
    imul edx, ebx, 0x2c
    movsx edx, word ptr [edx + _sprite + 0x18]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    cmp word ptr [eax*8 + _sector + 0x22], 1
    jne game_flow_spawn_37359
    mov edx, 5
    {store} mov eax, ebx
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_37359:
    mov ebx, dword ptr [esp + 36]
    test bx, bx
    jl game_flow_spawn_37457
    movsx eax, bx
    imul eax, eax, 0x2c
    mov bl, byte ptr [eax + _sprite + 0x11]
    cmp bl, 1
    jne game_flow_spawn_37390
    mov byte ptr [esi + 17], bl
    jmp game_flow_spawn_37434
game_flow_spawn_37390:
    mov cx, word ptr [eax + _sprite + 0xe]
    cmp cx, 0x4cb
    je game_flow_spawn_37430
    cmp cx, 0x3de
    je game_flow_spawn_37430
    cmp cx, 0x898
    jne game_flow_spawn_37424
    mov byte ptr [esi + 17], 7
    jmp game_flow_spawn_37434
game_flow_spawn_37424:
    mov byte ptr [esi + 17], 2
    jmp game_flow_spawn_37434
game_flow_spawn_37430:
    mov byte ptr [esi + 17], 0
game_flow_spawn_37434:
    movsx eax, word ptr [esp + 36]
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 0xe], 0x3de
    jne game_flow_spawn_37457
    mov byte ptr [esi + 16], 0x7f
game_flow_spawn_37457:
    or byte ptr [esi + 12], 0x20
game_flow_spawn_37461:
    cmp word ptr [esp + 36], 0
    jl game_flow_spawn_37479
    mov byte ptr [esi + 21], 1
    mov al, byte ptr [esi + 21]
    mov byte ptr [esi + 20], al
game_flow_spawn_37479:
    mov edx, 5
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_37503:
    mov ebp, dword ptr [_ud + 0x62a]
    movsx eax, word ptr [esi + 38]
    {store} cmp eax, ebp
    jle game_flow_spawn_37551
    mov byte ptr [esi + 21], 0
    mov al, byte ptr [esi + 21]
    mov edx, 5
    mov byte ptr [esi + 20], al
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_37551:
    mov byte ptr [esi + 20], 4
    mov byte ptr [esi + 21], 5
    mov word ptr [esi + 32], 0x10
    mov edx, 0x10001
    mov word ptr [esi + 30], di
    movsx eax, di
    mov word ptr [esi + 40], di
    call ssp_
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov dword ptr [eax + _hittype + 0x2f], 0x11
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} xor ebx, ebx
    {store} sub eax, edx
    movsx edx, di
    mov dword ptr [eax + _hittype + 0x37], ebx
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    movsx ebx, word ptr [esi + 28]
    mov dword ptr [eax + _hittype + 0x43], ebx
game_flow_spawn_37677:
    cmp word ptr [esi + 14], 0x549
    jne game_flow_spawn_37705
    mov cx, word ptr [esi + 12]
    mov word ptr [esi + 42], 0x14
    or ecx, 0x101
    mov word ptr [esi + 12], cx
game_flow_spawn_37705:
    mov edx, 2
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_37729:
    mov ax, word ptr [esi + 12]
    and eax, 0xfffffefe
    {store} xor edx, edx
    mov word ptr [esi + 12], ax
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_37763:
    mov ax, word ptr [esi + 12]
    xor ah, ah
    and al, 0x3c
    mov word ptr [esp + 36], ax
    or al, 1
    {store} xor edx, edx
    mov word ptr [esi + 12], ax
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_37803:
    cmp word ptr [esp + 36], 0
    {disp32} jl game_flow_spawn_38257
    mov ax, word ptr [esi + 24]
    mov dword ptr [esp + 16], eax
    lea ebx, dword ptr [esp + 16]
    mov edx, dword ptr [esi + 4]
    mov eax, dword ptr [esi]
    add edx, 0x54
    add eax, 0x54
    call updatesector_
    cmp word ptr [esp + 16], 0
    {disp32} jl game_flow_spawn_38183
    movsx edx, word ptr [esi + 24]
    {disp32} lea ebx, dword ptr [edx*4]
    {store} add ebx, edx
    movsx edx, word ptr [esp + 16]
    {disp32} lea eax, dword ptr [edx*4]
    {disp32} lea ebx, dword ptr [ebx*8]
    {store} add eax, edx
    mov ecx, dword ptr [ebx + _sector + 0x8]
    cmp ecx, dword ptr [eax*8 + _sector + 0x8]
    {disp32} jne game_flow_spawn_38183
    lea ebx, dword ptr [esp + 16]
    mov edx, dword ptr [esi + 4]
    mov eax, dword ptr [esi]
    sub edx, 0x54
    sub eax, 0x54
    call updatesector_
    mov ecx, dword ptr [esp + 16]
    test cx, cx
    {disp32} jl game_flow_spawn_38183
    movsx edx, word ptr [esi + 24]
    {disp32} lea ebx, dword ptr [edx*4]
    {store} add ebx, edx
    movsx edx, cx
    {disp32} lea eax, dword ptr [edx*4]
    {disp32} lea ebx, dword ptr [ebx*8]
    {store} add eax, edx
    mov ebp, dword ptr [ebx + _sector + 0x8]
    cmp ebp, dword ptr [eax*8 + _sector + 0x8]
    {disp32} jne game_flow_spawn_38183
    lea ebx, dword ptr [esp + 16]
    mov edx, dword ptr [esi + 4]
    mov eax, dword ptr [esi]
    sub edx, 0x54
    add eax, 0x54
    call updatesector_
    mov eax, dword ptr [esp + 16]
    test ax, ax
    {disp32} jl game_flow_spawn_38183
    movsx edx, word ptr [esi + 24]
    {disp32} lea ebx, dword ptr [edx*4]
    {store} add ebx, edx
    movsx edx, ax
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    {disp32} lea ebx, dword ptr [ebx*8]
    mov eax, dword ptr [eax*8 + _sector + 0x8]
    cmp eax, dword ptr [ebx + _sector + 0x8]
    jne game_flow_spawn_38183
    lea ebx, dword ptr [esp + 16]
    mov edx, dword ptr [esi + 4]
    mov eax, dword ptr [esi]
    add edx, 0x54
    sub eax, 0x54
    call updatesector_
    cmp word ptr [esp + 16], 0
    jl game_flow_spawn_38204
    movsx edx, word ptr [esi + 24]
    {disp32} lea ebx, dword ptr [edx*4]
    {store} add ebx, edx
    movsx edx, word ptr [esp + 16]
    {disp32} lea eax, dword ptr [edx*4]
    {disp32} lea ebx, dword ptr [ebx*8]
    {store} add eax, edx
    mov ecx, dword ptr [ebx + _sector + 0x8]
    cmp ecx, dword ptr [eax*8 + _sector + 0x8]
    je game_flow_spawn_38204
    mov byte ptr [esi + 21], 0
    mov al, byte ptr [esi + 21]
    mov edx, 5
    mov byte ptr [esi + 20], al
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_38183:
    mov byte ptr [esi + 21], 0
    mov al, byte ptr [esi + 21]
    mov byte ptr [esi + 20], al
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_38204:
    movsx eax, word ptr [esp + 36]
    imul eax, eax, 0x2c
    movsx edx, word ptr [eax + _sprite + 0x22]
    imul edx, edx, 0x552
    mov dl, byte ptr [edx + _ps + 0x518]
    and dl, 1
    xor dh, dh
    shl edx, 2
    add edx, 0x20
    mov word ptr [esi + 12], dx
    mov ax, word ptr [eax + _sprite + 0x1c]
    mov word ptr [esi + 28], ax
game_flow_spawn_38257:
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    mov edx, dword ptr [eax + _sector + 0x8]
    mov dword ptr [esi + 8], edx
    mov bx, word ptr [eax + _sector + 0x22]
    cmp bx, 1
    je game_flow_spawn_38316
    cmp bx, 2
    je game_flow_spawn_38316
    mov byte ptr [esi + 21], 0x20
    mov al, byte ptr [esi + 21]
    mov byte ptr [esi + 20], al
game_flow_spawn_38316:
    movsx ebx, di
    {store} mov eax, ebx
    mov edx, 5
    call insertspriteq_
    {store} mov eax, ebx
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_38349:
    mov ax, word ptr [esi + 40]
    mov word ptr [esi + 40], 0xffff
    mov dx, word ptr [esi + 14]
    mov word ptr [esi + 34], ax
    cmp dx, 0x50e
    jne game_flow_spawn_38384
    mov bx, word ptr [esi + 42]
    {store} add ebx, ebx
    mov word ptr [esi + 42], bx
game_flow_spawn_38384:
    mov cx, word ptr [esi + 14]
    cmp cx, 0x386
    je game_flow_spawn_38402
    cmp cx, 0x385
    jne game_flow_spawn_38414
game_flow_spawn_38402:
    mov word ptr [esi + 12], 0x100
    mov byte ptr [esi + 18], 8
    jmp game_flow_spawn_38449
game_flow_spawn_38414:
    mov dx, word ptr [esi + 12]
    or edx, 0x101
    mov bx, word ptr [esi + 14]
    mov word ptr [esi + 12], dx
    cmp bx, 0xd48
    je game_flow_spawn_38445
    mov byte ptr [esi + 18], 0x20
    jmp game_flow_spawn_38449
game_flow_spawn_38445:
    mov byte ptr [esi + 18], 0xff
game_flow_spawn_38449:
    mov edx, 2
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_38473:
    mov ecx, dword ptr [esp + 36]
    test cx, cx
    jl game_flow_spawn_38572
    movsx eax, cx
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 0xe], 0x57d
    jne game_flow_spawn_38572
    movsx eax, cx
    imul eax, eax, 0x2c
    mov al, byte ptr [eax + _sprite + 0x14]
    mov byte ptr [esi + 20], al
    movsx eax, cx
    imul eax, eax, 0x2c
    mov al, byte ptr [eax + _sprite + 0x15]
    mov byte ptr [esi + 21], al
    movsx eax, cx
    imul eax, eax, 0x2c
    mov al, byte ptr [eax + _sprite + 0x10]
    mov byte ptr [esi + 16], al
    movsx eax, cx
    imul eax, eax, 0x2c
    movsx eax, word ptr [eax + _sprite + 0x22]
    imul eax, eax, 0x552
    mov al, byte ptr [eax + _ps + 0x548]
    mov byte ptr [esi + 17], al
game_flow_spawn_38572:
    mov word ptr [esi + 12], 0
    mov word ptr [esi + 42], 1
    mov word ptr [esi + 32], 0x124
    mov word ptr [esi + 36], 0x168
game_flow_spawn_38596:
    cmp word ptr [esi + 14], 0xc76
    jne game_flow_spawn_38655
    mov byte ptr [esi + 21], 0x18
    mov al, byte ptr [esi + 21]
    mov byte ptr [esi + 20], al
    mov eax, dword ptr [esp + 36]
    test ax, ax
    jl game_flow_spawn_38673
    movsx edx, ax
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov eax, dword ptr [eax + _hittype + 0x13]
    mov dword ptr [esi + 8], eax
    jmp game_flow_spawn_38673
game_flow_spawn_38655:
    mov cx, word ptr [esi + 12]
    mov byte ptr [esi + 18], 0x80
    or ecx, 0x101
    mov word ptr [esi + 12], cx
game_flow_spawn_38673:
    cmp word ptr [esi + 14], 0x2fa
    jne game_flow_spawn_38689
    mov ax, word ptr [esi + 40]
    mov word ptr [esi + 34], ax
game_flow_spawn_38689:
    mov edx, 1
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_38713:
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    {store} mov edx, eax
    mov eax, dword ptr [esi]
    mov dword ptr [edx + _hittype + 0x2f], eax
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    {store} mov edx, eax
    mov eax, dword ptr [esi + 4]
    mov dword ptr [edx + _hittype + 0x33], eax
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_38787:
    mov byte ptr [esi + 21], 3
    mov al, byte ptr [esi + 21]
    mov byte ptr [esi + 20], al
    movsx eax, di
    mov word ptr [esi + 12], 0x10
    call insertspriteq_
game_flow_spawn_38811:
    cmp word ptr [esi + 14], 0x4d1
    jne game_flow_spawn_38894
    call krand_
    movsx edx, di
    {store} mov ebx, eax
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    and ebx, 0x7ff
    mov dword ptr [eax + _hittype + 0x2f], ebx
    call krand_
    xor ah, ah
    mov byte ptr [esi + 21], 8
    and al, 0xc
    mov word ptr [esi + 12], ax
    mov al, byte ptr [esi + 21]
    mov byte ptr [esi + 20], al
    call krand_
    and ah, 7
    mov word ptr [esi + 28], ax
game_flow_spawn_38894:
    mov edx, 5
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_38918:
    mov word ptr [esi + 38], 1
    mov edx, 6
    mov word ptr [esi + 42], 1
    movsx eax, di
    mov word ptr [esi + 30], di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_38958:
    mov ebx, dword ptr [esp + 36]
    test bx, bx
    {disp32} jl game_flow_spawn_47635
    movsx eax, bx
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 0xe], 0x57d
    {disp32} jne game_flow_spawn_39177
    mov ax, word ptr [eax + _sprite + 0x22]
    movsx edx, ax
    imul edx, edx, 0x552
    call krand_
    xor ah, ah
    and al, 0x3f
    mov bx, word ptr [edx + _ps + 0x280]
    movsx ecx, di
    {store} sub ebx, eax
    call krand_
    {store} mov ebp, eax
    {disp32} lea eax, dword ptr [ecx*8]
    {store} add eax, ecx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ecx
    and ebp, 1
    mov dword ptr [eax + _hittype + 0x2f], ebp
    mov ax, word ptr [esi + 14]
    add ebx, 8
    cmp ax, 0x9e7
    jne game_flow_spawn_39114
    movsx eax, word ptr [edx + _ps + 0x2ae]
    mov ecx, dword ptr [edx + _ps + 0x220]
    mov ebp, dword ptr [edx + _ps + 0x21c]
    {store} add ecx, eax
    mov eax, dword ptr [edx + _ps + 0x244]
    shl ecx, 4
    .att_syntax prefix
    addl $game_math_spawn_39107,%eax
    .intel_syntax noprefix
    jmp game_flow_spawn_39149
game_flow_spawn_39114:
    movsx eax, word ptr [edx + _ps + 0x2ae]
    mov ecx, dword ptr [edx + _ps + 0x220]
    mov ebp, dword ptr [edx + _ps + 0x21c]
    {store} add ecx, eax
    mov eax, dword ptr [edx + _ps + 0x244]
    shl ecx, 4
    .att_syntax prefix
    addl $game_math_spawn_39144,%eax
    .intel_syntax noprefix
game_flow_spawn_39149:
    sub ecx, 0x640
    {store} add eax, ebp
    {store} sub eax, ecx
    mov dword ptr [esi + 8], eax
    call krand_
    xor ah, ah
    neg eax
    mov word ptr [esi + 36], ax
    jmp game_flow_spawn_39195
game_flow_spawn_39177:
    mov eax, dword ptr [eax + _sprite + 0x8]
    sub eax, 0x2300
    mov bx, word ptr [esi + 28]
    mov dword ptr [esi + 8], eax
game_flow_spawn_39195:
    movsx edx, word ptr [esp + 36]
    imul edx, edx, 0x2c
    movsx ecx, bx
    add ecx, 0x200
    and ecx, 0x7ff
    movsx ecx, word ptr [ecx*2 + _sintable]
    sar ecx, 7
    mov eax, dword ptr [edx + _sprite]
    {store} add eax, ecx
    mov dword ptr [esi], eax
    {store} mov eax, ebx
    and ah, 7
    cwde
    movsx ecx, word ptr [eax*2 + _sintable]
    mov eax, dword ptr [edx + _sprite + 0x4]
    mov byte ptr [esi + 16], 0xf8
    mov word ptr [esi + 32], 0x14
    sar ecx, 7
    mov byte ptr [esi + 21], 4
    {store} add eax, ecx
    mov dword ptr [esi + 4], eax
    sub ebx, 0x200
    mov al, byte ptr [esi + 21]
    mov edx, 5
    mov byte ptr [esi + 20], al
    movsx eax, di
    mov word ptr [esi + 28], bx
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_39321:
    mov word ptr [esi + 42], 0x35
game_flow_spawn_39327:
    cmp word ptr [_ud + 0x590], 2
    jge game_flow_spawn_39377
    cmp byte ptr [esi + 17], 1
    jne game_flow_spawn_39377
    mov byte ptr [esi + 21], 0
    mov al, byte ptr [esi + 21]
    mov edx, 5
    mov byte ptr [esi + 20], al
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_39377:
    mov edx, 0xb
    movsx eax, di
    mov word ptr [esi + 12], 0x8000
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_39407:
    mov ebx, dword ptr [esp + 36]
    test bx, bx
    jl game_flow_spawn_39452
    movsx eax, bx
    imul eax, eax, 0x2c
    mov ax, word ptr [eax + _sprite + 0x1c]
    mov byte ptr [esi + 16], 0xc0
    mov word ptr [esi + 28], ax
    call krand_
    xor ah, ah
    and al, 4
    or al, 0x80
    mov word ptr [esi + 12], ax
game_flow_spawn_39452:
    mov cx, word ptr [esi + 14]
    cmp cx, 0x762
    je game_flow_spawn_39470
    cmp cx, 0x8ab
    jne game_flow_spawn_39493
game_flow_spawn_39470:
    mov byte ptr [esi + 20], 0x30
    mov byte ptr [esi + 21], 0x30
    mov cl, byte ptr [esi + 12]
    mov byte ptr [esi + 16], 0x81
    or cl, 0x80
    mov byte ptr [esi + 12], cl
    jmp game_flow_spawn_39549
game_flow_spawn_39493:
    cmp cx, 0x678
    jne game_flow_spawn_39510
    mov byte ptr [esi + 20], 0x20
    mov byte ptr [esi + 21], 0x20
    jmp game_flow_spawn_39549
game_flow_spawn_39510:
    cmp cx, 0x919
    jne game_flow_spawn_39527
    mov byte ptr [esi + 20], 0x18
    mov byte ptr [esi + 21], 0x18
    jmp game_flow_spawn_39549
game_flow_spawn_39527:
    cmp cx, 0x8de
    je game_flow_spawn_39541
    cmp cx, 0x906
    jne game_flow_spawn_39549
game_flow_spawn_39541:
    mov byte ptr [esi + 20], 4
    mov byte ptr [esi + 21], 4
game_flow_spawn_39549:
    cmp word ptr [esp + 36], 0
    jl game_flow_spawn_39584
    mov ebx, dword ptr [esi + 4]
    mov edx, dword ptr [esi]
    movsx eax, word ptr [esi + 24]
    call getflorzofslope_
    sub eax, 0xc00
    cmp eax, dword ptr [esi + 8]
    jge game_flow_spawn_39584
    mov dword ptr [esi + 8], eax
game_flow_spawn_39584:
    mov edx, 5
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_39608:
    mov ebx, dword ptr [esp + 36]
    test bx, bx
    jl game_flow_spawn_39681
    movsx eax, bx
    imul eax, eax, 0x2c
    mov al, byte ptr [eax + _sprite + 0x14]
    mov byte ptr [esi + 20], al
    movsx eax, bx
    imul eax, eax, 0x2c
    mov al, byte ptr [eax + _sprite + 0x15]
    movsx edx, word ptr [esi + 24]
    mov byte ptr [esi + 21], al
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov word ptr [esi + 36], 0x80
    cmp word ptr [eax*8 + _sector + 0x22], 2
    je game_flow_spawn_39681
    or byte ptr [esi + 13], 0x80
game_flow_spawn_39681:
    mov edx, 0xd
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_39705:
    mov byte ptr [esi + 21], 0
    mov al, byte ptr [esi + 21]
    mov byte ptr [esi + 20], al
    mov ax, word ptr [_ud + 0x5de]
    mov word ptr [esp + 36], ax
    .att_syntax prefix
    cmpw $game_math_spawn_39726,%ax
    .intel_syntax noprefix
    jne game_flow_spawn_39739
    {store} xor edx, edx
    mov word ptr [esp + 36], dx
game_flow_spawn_39739:
    mov bx, word ptr [_ud + 0x590]
    cmp bx, 2
    jl game_flow_spawn_39767
    cmp bx, 1
    jle game_flow_spawn_39791
    mov eax, dword ptr [esp + 36]
    cmp ax, word ptr [esi + 38]
    je game_flow_spawn_39791
game_flow_spawn_39767:
    mov edx, 5
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_39791:
    mov edx, 0xa
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_39815:
    mov edx, dword ptr [esp + 36]
    test dx, dx
    jl game_flow_spawn_39848
    movsx eax, dx
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 0xe], 0x57d
    jne game_flow_spawn_39848
    sub dword ptr [esi + 8], 0x1000
game_flow_spawn_39848:
    cmp word ptr [esi + 14], 0x295
    jne game_flow_spawn_39894
    mov eax, dword ptr [esp + 36]
    test ax, ax
    jl game_flow_spawn_39880
    cwde
    imul eax, eax, 0x2c
    mov ax, word ptr [eax + _sprite + 0x1c]
    mov word ptr [esi + 28], ax
game_flow_spawn_39880:
    call krand_
    and al, 7
    inc al
    mov byte ptr [esi + 21], al
    jmp game_flow_spawn_39901
game_flow_spawn_39894:
    mov byte ptr [esi + 21], 0x20
    mov al, byte ptr [esi + 21]
game_flow_spawn_39901:
    mov byte ptr [esi + 20], al
    mov edx, 5
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_39928:
    or word ptr [esi + 12], 0x141
    movsx edx, word ptr [esp + 20]
    mov bx, word ptr [esi + 14]
    {disp32} lea eax, dword ptr [edx*4]
    add ebx, 2
    {store} add eax, edx
    mov word ptr [esi + 14], bx
    mov eax, dword ptr [eax*8 + _sector + 0x4]
    .att_syntax prefix
    addl $game_math_spawn_39966,%eax
    .intel_syntax noprefix
    movsx edx, di
    mov dword ptr [esi + 8], eax
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    {store} mov edx, eax
    mov eax, dword ptr [_tempwallptr]
    mov dword ptr [edx + _hittype + 0x3f], eax
    {store} mov edx, eax
    mov eax, dword ptr [esi]
    mov dword ptr [edx*4 + _msx], eax
    mov eax, dword ptr [esi + 4]
    mov dword ptr [edx*4 + _msy], eax
    {store} mov eax, edx
    mov edx, dword ptr [esi + 8]
    mov bx, word ptr [_headspritestat]
    mov dword ptr [eax*4 + _msx + 0x8], edx
game_flow_spawn_40048:
    test bx, bx
    {disp32} jl game_flow_spawn_40266
    movsx ebp, bx
    imul eax, ebp, 0x2c
    cmp word ptr [eax + _sprite + 0xe], 0x4c5
    {disp32} jne game_flow_spawn_40309
    movsx edx, di
    mov dword ptr [esp + 8], edx
    imul edx, edx, 0x2c
    mov cx, word ptr [eax + _sprite + 0x28]
    cmp cx, word ptr [edx + _sprite + 0x28]
    {disp32} jne game_flow_spawn_40309
    movsx edx, word ptr [eax + _sprite + 0x18]
    mov ebx, dword ptr [esp + 8]
    mov dword ptr [esp + 4], edx
    {disp32} lea edx, dword ptr [ebx*8]
    {store} add edx, ebx
    {disp32} lea edx, dword ptr [edx*8]
    {store} sub edx, ebx
    mov ebx, dword ptr [esp + 4]
    mov dword ptr [edx + _hittype + 0x33], ebx
    mov dh, 0x30
    mov ecx, dword ptr [_tempwallptr]
    mov byte ptr [eax + _sprite + 0x14], dh
    mov dword ptr [ecx*4 + _msy + 0x8], ebp
    mov edx, dword ptr [eax + _sprite]
    mov bl, 0x80
    mov dword ptr [ecx*4 + _msx + 0x4], edx
    mov edx, dword ptr [eax + _sprite + 0x4]
    mov byte ptr [eax + _sprite + 0x15], bl
    mov dword ptr [ecx*4 + _msy + 0x4], edx
    mov edx, dword ptr [esi]
    mov dword ptr [eax + _sprite], edx
    mov edx, dword ptr [esi + 4]
    mov dword ptr [eax + _sprite + 0x4], edx
    mov edx, dword ptr [esi + 8]
    mov dword ptr [eax + _sprite + 0x8], edx
    mov dl, byte ptr [esi + 16]
    mov byte ptr [eax + _sprite + 0x10], dl
    mov ebx, dword ptr [eax + _sprite + 0x4]
    mov ecx, dword ptr [eax + _sprite + 0x8]
    mov edx, dword ptr [eax + _sprite]
    {store} mov eax, ebp
    call setsprite_
game_flow_spawn_40266:
    add dword ptr [_tempwallptr], 3
    mov edx, 6
    mov word ptr [esi + 30], 0xffff
    movsx eax, di
    mov word ptr [esi + 42], 8
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_40309:
    movsx eax, bx
    mov bx, word ptr [eax*2 + _nextspritestat]
    {disp32} jmp game_flow_spawn_40048
game_flow_spawn_40325:
    mov edx, dword ptr [esp + 36]
    test dx, dx
    jl game_flow_spawn_40350
    movsx eax, dx
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 0x1a], 0xa
    je game_flow_spawn_40372
game_flow_spawn_40350:
    movsx eax, word ptr [esp + 36]
    imul edx, eax, 0x2c
    cmp word ptr [edx + _sprite + 0x1a], 1
    {disp32} jne game_flow_spawn_40496
game_flow_spawn_40372:
    movsx eax, word ptr [esp + 36]
    imul eax, eax, 0x2c
    mov byte ptr [esi + 16], 0x20
    cmp byte ptr [eax + _sprite + 0x11], 1
    je game_flow_spawn_40411
    mov ebp, dword ptr [esi + 8]
    mov byte ptr [esi + 17], 2
    sub ebp, 0x1200
    mov dword ptr [esi + 8], ebp
    jmp game_flow_spawn_40418
game_flow_spawn_40411:
    sub dword ptr [esi + 8], 0xd00
game_flow_spawn_40418:
    movsx ebx, word ptr [_connecthead]
    imul ebx, ebx, 0x552
    mov edx, dword ptr [esi + 4]
    mov eax, dword ptr [ebx + _ps + 0x218]
    {store} sub eax, edx
    {store} mov edx, eax
    mov eax, dword ptr [ebx + _ps + 0x214]
    sub eax, dword ptr [esi]
    call getangle_
    mov word ptr [esi + 28], ax
    call krand_
    xor ah, ah
    mov edx, 0x30
    and al, 0x1f
    {store} sub edx, eax
    movsx eax, di
    mov word ptr [esi + 32], dx
    mov edx, 0x10001
    call ssp_
    jmp game_flow_spawn_40540
game_flow_spawn_40496:
    cmp eax, -1
    jne game_flow_spawn_40540
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    mov ebx, dword ptr [esi + 8]
    {disp32} lea eax, dword ptr [eax*8]
    add ebx, 0x400
    {store} sub eax, edx
    mov dword ptr [esi + 8], ebx
    mov dword ptr [eax + _hittype + 0x2f], ebx
game_flow_spawn_40540:
    cmp word ptr [esi + 14], 0x294
    je game_flow_spawn_40560
    call krand_
    and ah, 7
    mov word ptr [esi + 28], ax
game_flow_spawn_40560:
    mov edx, 6
    mov byte ptr [esi + 20], 0x18
    movsx eax, di
    mov byte ptr [esi + 21], 0x18
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_40592:
    mov edx, 6
    movsx eax, di
    mov word ptr [esi + 38], 0x270f
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_40622:
    movsx edx, word ptr [esp + 20]
    {disp32} lea ebx, dword ptr [edx*4]
    {store} add ebx, edx
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    {disp32} lea ebx, dword ptr [ebx*8]
    {store} mov edx, eax
    mov eax, dword ptr [ebx + _sector + 0x8]
    mov dword ptr [edx + _hittype + 0x37], eax
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    cmp word ptr [eax*8 + _sector + 0x22], 1
    je game_flow_spawn_40758
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    cmp word ptr [eax*8 + _sector + 0x22], 2
    je game_flow_spawn_40758
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add edx, eax
    {disp32} lea edx, dword ptr [edx*8]
    mov eax, dword ptr [esi + 8]
    mov dword ptr [edx + _sector + 0x8], eax
game_flow_spawn_40758:
    cmp byte ptr [esi + 17], 0
    je game_flow_spawn_40808
    cmp word ptr [_ud + 0x590], 1
    jle game_flow_spawn_40808
    mov byte ptr [esi + 21], 0
    mov al, byte ptr [esi + 21]
    mov edx, 5
    mov byte ptr [esi + 20], al
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_40808:
    mov dl, byte ptr [esi + 13]
    or dl, 0x80
    movsx eax, di
    mov byte ptr [esi + 13], dl
    mov edx, 6
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_40841:
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {store} xor ebx, ebx
    {disp32} lea eax, dword ptr [eax*8]
    mov bl, byte ptr [esi + 20]
    {store} sub eax, edx
    movsx edx, di
    mov dword ptr [eax + _hittype + 0x2f], ebx
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} xor ebx, ebx
    {store} sub eax, edx
    mov bl, byte ptr [esi + 21]
    mov dword ptr [eax + _hittype + 0x33], ebx
game_flow_spawn_40905:
    cmp word ptr [esi + 14], 8
    jne game_flow_spawn_40916
    or byte ptr [esi + 13], 0x80
game_flow_spawn_40916:
    mov edx, 6
    movsx eax, di
    mov word ptr [esi + 34], 0
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_40946:
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    {store} mov edx, eax
    mov ax, word ptr [esi + 24]
    mov word ptr [edx + _hittype + 0xd], ax
game_flow_spawn_40980:
    cmp word ptr [esi + 14], 0x942
    jne game_flow_spawn_40994
    mov word ptr [esi + 42], 1
game_flow_spawn_40994:
    cmp byte ptr [esi + 17], 0
    je game_flow_spawn_41012
    mov ax, word ptr [esi + 42]
    {store} add eax, eax
    mov word ptr [esi + 42], ax
    jmp game_flow_spawn_41062
game_flow_spawn_41012:
    mov ax, word ptr [esi + 14]
    .att_syntax prefix
    cmpw $game_math_spawn_41016,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_41040
    jbe game_flow_spawn_41058
    .att_syntax prefix
    cmpw $game_math_spawn_41024,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_41062
    jbe game_flow_spawn_41058
    .att_syntax prefix
    cmpw $game_math_spawn_41032,%ax
    .intel_syntax noprefix
    je game_flow_spawn_41058
    jmp game_flow_spawn_41062
game_flow_spawn_41040:
    .att_syntax prefix
    cmpw $game_math_spawn_41040,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_41062
    .att_syntax prefix
    cmpw $game_math_spawn_41046,%ax
    .intel_syntax noprefix
    jbe game_flow_spawn_41058
    .att_syntax prefix
    cmpw $game_math_spawn_41052,%ax
    .intel_syntax noprefix
    jne game_flow_spawn_41062
game_flow_spawn_41058:
    mov byte ptr [esi + 17], 0x16
game_flow_spawn_41062:
    mov dx, word ptr [esi + 14]
    cmp dx, 0xa46
    je game_flow_spawn_41094
    cmp dx, 0xa96
    je game_flow_spawn_41094
    cmp dx, 0xa47
    je game_flow_spawn_41094
    cmp dx, 0xac8
    jne game_flow_spawn_41162
game_flow_spawn_41094:
    mov ebx, dword ptr [esp + 36]
    test bx, bx
    jl game_flow_spawn_41128
    movsx eax, bx
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 0xe], 9
    jne game_flow_spawn_41128
    mov al, byte ptr [eax + _sprite + 0x11]
    mov byte ptr [esi + 17], al
game_flow_spawn_41128:
    cmp byte ptr [esi + 17], 0
    je game_flow_spawn_41148
    mov byte ptr [esi + 18], 0x50
    mov byte ptr [esi + 20], 0x28
    mov byte ptr [esi + 21], 0x28
    jmp game_flow_spawn_41195
game_flow_spawn_41148:
    mov byte ptr [esi + 20], 0x50
    mov byte ptr [esi + 21], 0x50
    mov byte ptr [esi + 18], 0xa4
    jmp game_flow_spawn_41195
game_flow_spawn_41162:
    mov dx, word ptr [esi + 14]
    mov byte ptr [esi + 18], 0x50
    cmp dx, 0x60e
    je game_flow_spawn_41187
    mov byte ptr [esi + 20], 0x28
    mov byte ptr [esi + 21], 0x28
    jmp game_flow_spawn_41195
game_flow_spawn_41187:
    mov byte ptr [esi + 20], 0x18
    mov byte ptr [esi + 21], 0x18
game_flow_spawn_41195:
    cmp word ptr [esp + 36], 0
    jl game_flow_spawn_41209
    mov word ptr [esi + 38], 0
game_flow_spawn_41209:
    mov ebp, dword ptr [_ud + 0x62a]
    movsx eax, word ptr [esi + 38]
    {store} cmp eax, ebp
    jg game_flow_spawn_41232
    cmp dword ptr [_ud + 0x5fe], 1
    jne game_flow_spawn_41266
game_flow_spawn_41232:
    mov byte ptr [esi + 21], 0
    mov al, byte ptr [esi + 21]
    mov edx, 5
    mov byte ptr [esi + 20], al
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_41266:
    movsx eax, di
    call makeitfall_
    cmp word ptr [esi + 14], 0x4f3
    jne game_flow_spawn_41312
    call krand_
    mov byte ptr [esi + 21], 0x30
    and ah, 7
    mov word ptr [esi + 12], 0
    mov word ptr [esi + 28], ax
    mov al, byte ptr [esi + 21]
    mov byte ptr [esi + 20], al
    jmp game_flow_spawn_41356
game_flow_spawn_41312:
    mov bx, word ptr [esi + 12]
    or ebx, 0x101
    mov cx, word ptr [esi + 14]
    mov word ptr [esi + 12], bx
    cmp cx, 0x60e
    je game_flow_spawn_41356
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    inc byte ptr [eax + _ps + 0x54f]
game_flow_spawn_41356:
    cmp word ptr [esi + 14], 0x974
    jne game_flow_spawn_41368
    or byte ptr [esi + 12], 0x80
game_flow_spawn_41368:
    cmp word ptr [esp + 36], 0
    {disp32} jl game_flow_spawn_38449
    movsx ebx, di
    {disp32} lea eax, dword ptr [ebx*8]
    {store} add eax, ebx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ebx
    {store} xor ecx, ecx
    mov word ptr [eax + _hittype + 0x11], cx
    {store} mov eax, ebx
    mov edx, 1
    call check_fta_sounds_
    {store} mov eax, ebx
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_41440:
    mov ch, byte ptr [esi + 13]
    mov edx, 7
    or ch, 0x80
    movsx eax, di
    mov byte ptr [esi + 13], ch
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_41473:
    mov edx, 6
    mov cx, word ptr [esi + 12]
    mov byte ptr [esi + 16], 0xf4
    or ecx, 0x101
    movsx eax, di
    mov word ptr [esi + 12], cx
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_41515:
    mov edx, dword ptr [esp + 36]
    mov byte ptr [esi + 16], 0xf4
    test dx, dx
    jl game_flow_spawn_41547
    movsx eax, dx
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 0xe], 0x4cb
    jne game_flow_spawn_41547
    mov byte ptr [esi + 17], 8
game_flow_spawn_41547:
    movsx ebx, di
    mov edx, 1
    {store} mov eax, ebx
    call changespritestat_
    {store} mov eax, ebx
    {disp32} lea edx, dword ptr [ebx*8]
    {store} add edx, ebx
    {disp32} lea edx, dword ptr [edx*8]
    {store} sub edx, ebx
    call getglobalz_
    mov eax, dword ptr [edx + _hittype + 0x13]
    sub eax, dword ptr [edx + _hittype + 0x17]
    sar eax, 9
    mov word ptr [esp + 36], ax
    mov al, byte ptr [esp + 36]
    mov byte ptr [esi + 21], al
    movsx eax, word ptr [esp + 36]
    mov edx, 0x19
    sar eax, 1
    {store} sub edx, eax
    mov byte ptr [esi + 20], dl
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_41642:
    mov byte ptr [esi + 21], 9
    mov word ptr [esi + 34], 4
    mov word ptr [esi + 30], di
    mov al, byte ptr [esi + 21]
    mov byte ptr [esi + 20], al
game_flow_spawn_41662:
    cmp word ptr [esi + 14], 0x7a8
    {disp32} jne game_flow_spawn_41820
    mov ebp, dword ptr [_ud + 0x62a]
    movsx eax, word ptr [esi + 38]
    {store} cmp eax, ebp
    jle game_flow_spawn_41722
    mov byte ptr [esi + 21], 0
    mov al, byte ptr [esi + 21]
    mov edx, 5
    mov byte ptr [esi + 20], al
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_41722:
    movsx ecx, word ptr [_myconnectindex]
    imul ecx, ecx, 0x552
    movsx ebx, di
    {store} mov edx, ebx
    {disp32} lea eax, dword ptr [ebx*8]
    {store} add eax, ebx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ebx
    {store} xor edx, ebx
    mov dword ptr [eax + _hittype + 0x43], edx
    inc byte ptr [ecx + _ps + 0x54f]
    cmp dword ptr [_ud + 0x5fe], 1
    jne game_flow_spawn_41814
    mov byte ptr [esi + 21], 0
    mov al, byte ptr [esi + 21]
    mov edx, 5
    mov byte ptr [esi + 20], al
    {store} mov eax, ebx
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_41814:
    mov word ptr [esi + 42], 0x82
game_flow_spawn_41820:
    mov cx, word ptr [esi + 14]
    cmp cx, 0x440
    je game_flow_spawn_41838
    cmp cx, 0x242
    jne game_flow_spawn_41848
game_flow_spawn_41838:
    mov ax, word ptr [_impact_damage]
    mov word ptr [esi + 42], ax
game_flow_spawn_41848:
    movsx eax, di
    imul edx, eax, 0x2c
    mov bx, word ptr [edx + _sprite + 0xc]
    or ebx, 0x101
    mov cx, word ptr [_ud + 0x590]
    mov word ptr [edx + _sprite + 0xc], bx
    cmp cx, 2
    jge game_flow_spawn_41924
    cmp byte ptr [esi + 17], 0
    je game_flow_spawn_41924
    mov byte ptr [esi + 21], 0
    mov dl, byte ptr [esi + 21]
    mov byte ptr [esi + 20], dl
    mov edx, 5
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_41924:
    movsx eax, di
    imul edx, eax, 0x2c
    mov bl, 0xef
    mov byte ptr [esi + 17], 0
    mov byte ptr [edx + _sprite + 0x10], bl
    mov edx, 2
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_41963:
    cmp word ptr [esp + 36], 0
    jl game_flow_spawn_42010
    mov word ptr [esi + 38], 0
    mov edx, 0x10001
    mov ebp, dword ptr [esi + 8]
    mov word ptr [esi + 36], 0xfc00
    sub ebp, 0x2000
    movsx eax, di
    mov dword ptr [esi + 8], ebp
    call ssp_
    jmp game_flow_spawn_42014
game_flow_spawn_42010:
    mov word ptr [esi + 30], di
game_flow_spawn_42014:
    cmp word ptr [_ud + 0x590], 2
    jge game_flow_spawn_42030
    cmp byte ptr [esi + 17], 0
    jne game_flow_spawn_42044
game_flow_spawn_42030:
    mov edx, dword ptr [_ud + 0x62a]
    movsx eax, word ptr [esi + 38]
    {store} cmp eax, edx
    jle game_flow_spawn_42078
game_flow_spawn_42044:
    mov byte ptr [esi + 21], 0
    mov al, byte ptr [esi + 21]
    mov edx, 5
    mov byte ptr [esi + 20], al
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_42078:
    mov byte ptr [esi + 17], 0
    call krand_
    xor ah, ah
    mov bx, word ptr [esi + 12]
    and al, 0xc
    {store} or ebx, eax
    mov word ptr [esi + 12], bx
game_flow_spawn_42101:
    cmp word ptr [esi + 14], 0x64
    jne game_flow_spawn_42116
    mov word ptr [esi + 12], 0x80
    jmp game_flow_spawn_42122
game_flow_spawn_42116:
    mov word ptr [esi + 12], 0
game_flow_spawn_42122:
    cmp word ptr [_ud + 0x590], 1
    jle game_flow_spawn_42182
    cmp dword ptr [_ud + 0x5de], 1
    je game_flow_spawn_42182
    cmp word ptr [esi + 14], 0x3c
    jne game_flow_spawn_42182
    mov byte ptr [esi + 21], 0
    mov al, byte ptr [esi + 21]
    mov edx, 5
    mov byte ptr [esi + 20], al
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_42182:
    cmp word ptr [esi + 14], 0x28
    jne game_flow_spawn_42195
    mov byte ptr [esi + 21], 0x10
    jmp game_flow_spawn_42199
game_flow_spawn_42195:
    mov byte ptr [esi + 21], 0x20
game_flow_spawn_42199:
    mov al, byte ptr [esi + 21]
    mov byte ptr [esi + 20], al
    mov ecx, dword ptr [esp + 36]
    mov byte ptr [esi + 16], 0xef
    test cx, cx
    jl game_flow_spawn_42242
    mov edx, 1
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_42242:
    movsx ebx, di
    mov edx, 2
    {store} mov eax, ebx
    call changespritestat_
    {store} mov eax, ebx
    call makeitfall_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_42275:
    movsx eax, di
    imul eax, eax, 0x2c
    mov word ptr [eax + _sprite + 0x26], 1
game_flow_spawn_42290:
    movsx eax, di
    imul edx, eax, 0x2c
    mov ebx, 0x101
    mov ecx, 1
    mov word ptr [edx + _sprite + 0xc], bx
    mov word ptr [edx + _sprite + 0x2a], cx
    mov edx, 6
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_42341:
    mov edx, 6
    movsx eax, di
    mov byte ptr [esi + 16], 0x81
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_42369:
    mov byte ptr [esi + 16], 0x81
    mov ecx, dword ptr [esp + 36]
    mov word ptr [esi + 12], 0x80
    test cx, cx
    jge game_flow_spawn_42412
    mov edx, 5
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_42412:
    mov byte ptr [esi + 21], 0
    mov ebx, dword ptr [esi + 4]
    mov edx, dword ptr [esi]
    mov al, byte ptr [esi + 21]
    {store} mov ecx, ebx
    mov byte ptr [esi + 20], al
    movsx eax, di
    call setsprite_
    mov ax, word ptr [esi + 24]
    test ax, ax
    jl game_flow_spawn_42478
    movsx edx, ax
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    test byte ptr [eax*8 + _sector + 0xe], 1
    jne game_flow_spawn_42478
    mov byte ptr [esi + 21], 0x10
    mov al, byte ptr [esi + 21]
    mov byte ptr [esi + 20], al
game_flow_spawn_42478:
    mov edx, 5
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_42502:
    mov byte ptr [esi + 21], 0x18
    mov byte ptr [esi + 16], 0x81
    mov ax, word ptr [esi + 12]
    mov word ptr [esi + 30], di
    or eax, 0x101
    mov word ptr [esi + 12], ax
    mov al, byte ptr [esi + 21]
    mov byte ptr [esi + 20], al
    mov ax, word ptr [_impact_damage]
    shl eax, 2
    mov edx, 2
    mov word ptr [esi + 42], ax
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_42570:
    mov word ptr [esi + 42], 1
    cmp byte ptr [_camerashitable], 0
    je game_flow_spawn_42593
    mov word ptr [esi + 12], 0x101
    jmp game_flow_spawn_42599
game_flow_spawn_42593:
    mov word ptr [esi + 12], 0
game_flow_spawn_42599:
    cmp word ptr [_ud + 0x590], 2
    jge game_flow_spawn_42649
    cmp byte ptr [esi + 17], 0
    je game_flow_spawn_42649
    mov byte ptr [esi + 21], 0
    mov al, byte ptr [esi + 21]
    mov edx, 5
    mov byte ptr [esi + 20], al
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_42649:
    mov dx, word ptr [esi + 14]
    mov byte ptr [esi + 17], 0
    cmp dx, 0x22a
    {disp32} je game_flow_spawn_47635
    cmp dx, 0x3d1
    {disp32} je game_flow_spawn_47635
    mov edx, 1
    movsx eax, di
    mov word ptr [esi + 14], 0x26d
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_42709:
    mov eax, dword ptr [esp + 36]
    test ax, ax
    jl game_flow_spawn_42770
    cwde
    imul eax, eax, 0x2c
    mov ax, word ptr [eax + _sprite + 0x1c]
    mov word ptr [esi + 12], 0x92
    mov byte ptr [esi + 21], 1
    mov word ptr [esi + 28], ax
    mov al, byte ptr [esi + 21]
    mov edx, 0x10001
    mov byte ptr [esi + 20], al
    movsx eax, di
    mov word ptr [esi + 32], 0xfff8
    call ssp_
game_flow_spawn_42770:
    mov edx, 6
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_42794:
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov ax, word ptr [eax*8 + _sector + 0x26]
    mov byte ptr [esi + 21], 0
    mov word ptr [esi + 34], ax
    mov al, byte ptr [esi + 21]
    mov bh, byte ptr [esi + 13]
    mov byte ptr [esi + 20], al
    or bh, 0x80
    mov ax, word ptr [esi + 38]
    mov byte ptr [esi + 13], bh
    .att_syntax prefix
    cmpw $game_math_spawn_42843,%ax
    .intel_syntax noprefix
    {disp32} ja game_flow_spawn_47082
    and eax, 0xffff
    jmp dword ptr cs:[eax*4 + game_switch_spawn_31360]
game_flow_spawn_42866:
    {store} xor ecx, ecx
    mov word ptr [esp + 36], cx
    jmp game_flow_spawn_42957
game_flow_spawn_42875:
    movsx eax, dx
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 0x1a], 0x400
    jge game_flow_spawn_42952
    cmp word ptr [eax + _sprite + 0xe], 1
    jne game_flow_spawn_42952
    cmp word ptr [eax + _sprite + 0x26], 7
    jne game_flow_spawn_42952
    {store} cmp di, dx
    je game_flow_spawn_42952
    movsx edx, di
    imul edx, edx, 0x2c
    mov ax, word ptr [eax + _sprite + 0x28]
    cmp ax, word ptr [edx + _sprite + 0x28]
    jne game_flow_spawn_42952
    mov eax, dword ptr [esp + 36]
    mov word ptr [edx + _sprite + 0x1e], ax
    jmp game_flow_spawn_42968
game_flow_spawn_42952:
    inc word ptr [esp + 36]
game_flow_spawn_42957:
    mov edx, dword ptr [esp + 36]
    cmp dx, 0x1000
    jl game_flow_spawn_42875
game_flow_spawn_42968:
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    movsx edx, di
    imul edx, edx, 0x2c
    mov eax, dword ptr [eax*8 + _sector + 0x8]
    cmp eax, dword ptr [edx + _sprite + 0x8]
    sete al
    movsx ebx, di
    {store} mov ecx, eax
    {disp32} lea eax, dword ptr [ebx*8]
    {store} add eax, ebx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ebx
    and ecx, 0xff
    mov dword ptr [eax + _hittype + 0x3f], ecx
    imul eax, ebx, 0x2c
    {store} xor esi, esi
    mov edx, 9
    mov word ptr [eax + _sprite + 0xc], si
    {store} mov eax, ebx
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_43076:
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov word ptr [esi + 30], 0xffff
    mov dword ptr [eax + _hittype + 0x2f], 1
    {disp32} jmp game_flow_spawn_47082
game_flow_spawn_43118:
    mov word ptr [esi + 30], 0xffff
    {disp32} jmp game_flow_spawn_47082
game_flow_spawn_43129:
    movsx edx, word ptr [esp + 20]
    {disp32} lea ebx, dword ptr [edx*4]
    {store} add ebx, edx
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    {disp32} lea ebx, dword ptr [ebx*8]
    {store} mov edx, eax
    mov eax, dword ptr [ebx + _sector + 0x4]
    mov dword ptr [edx + _hittype + 0x3f], eax
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add edx, eax
    {disp32} lea edx, dword ptr [edx*8]
    mov eax, dword ptr [esi + 8]
    mov dword ptr [edx + _sector + 0x4], eax
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add edx, eax
    mov eax, OFFSET FLAT:_sector
    {disp32} lea edx, dword ptr [edx*8]
    {store} add eax, edx
    add eax, 4
    call setinterpolation_
    {disp32} jmp game_flow_spawn_47082
game_flow_spawn_43256:
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add edx, eax
    {disp32} lea edx, dword ptr [edx*8]
    mov eax, dword ptr [esi + 8]
    mov dword ptr [edx + _sector + 0x4], eax
    {disp32} jmp game_flow_spawn_47082
game_flow_spawn_43291:
    cmp dword ptr [_ud + 0x5fa], 1
    {disp32} jne game_flow_spawn_47082
    mov byte ptr [esi + 21], 0x40
    mov cl, byte ptr [esi + 13]
    mov al, byte ptr [esi + 21]
    and cl, 0x7f
    mov byte ptr [esi + 20], al
    mov byte ptr [esi + 13], cl
    {disp32} jmp game_flow_spawn_47082
game_flow_spawn_43328:
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    movsx edx, di
    movsx ebx, byte ptr [eax*8 + _sector + 0x1c]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    movsx edx, word ptr [esp + 20]
    mov dword ptr [eax + _hittype + 0x33], ebx
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    movsx edx, di
    movsx ebx, byte ptr [eax*8 + _sector + 0x14]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov dword ptr [eax + _hittype + 0x37], ebx
    {disp32} jmp game_flow_spawn_47082
game_flow_spawn_43431:
    movsx edx, word ptr [esp + 20]
    {disp32} lea ebx, dword ptr [edx*4]
    {store} add ebx, edx
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {disp32} lea ebx, dword ptr [ebx*8]
    {store} sub eax, edx
    mov edx, dword ptr [ebx + _sector + 0x4]
    mov dword ptr [eax + _hittype + 0x2f], edx
    movsx edx, word ptr [esp + 20]
    {disp32} lea ebx, dword ptr [edx*4]
    {store} add ebx, edx
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    {disp32} lea ebx, dword ptr [ebx*8]
    {store} mov edx, eax
    mov eax, dword ptr [ebx + _sector + 0x8]
    mov dword ptr [edx + _hittype + 0x33], eax
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov eax, dword ptr [eax + _hittype + 0x2f]
    sub eax, dword ptr [esi + 8]
    test eax, eax
    jns game_flow_spawn_43577
    neg eax
game_flow_spawn_43577:
    movsx edx, di
    {store} mov ebx, eax
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov ecx, dword ptr [esi + 8]
    mov eax, dword ptr [eax + _hittype + 0x33]
    {store} sub eax, ecx
    test eax, eax
    jns game_flow_spawn_43617
    neg eax
game_flow_spawn_43617:
    {store} cmp ebx, eax
    setl al
    xor ah, ah
    mov cx, word ptr [esi + 28]
    mov word ptr [esi + 30], ax
    cmp cx, 0x200
    jne game_flow_spawn_43695
    test ax, ax
    je game_flow_spawn_43663
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov edx, dword ptr [esi + 8]
    jmp game_flow_spawn_43719
game_flow_spawn_43663:
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add edx, eax
    {disp32} lea edx, dword ptr [edx*8]
    mov eax, dword ptr [esi + 8]
    mov dword ptr [edx + _sector + 0x8], eax
    jmp game_flow_spawn_43726
game_flow_spawn_43695:
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov edx, dword ptr [esi + 8]
    mov dword ptr [eax*8 + _sector + 0x8], edx
game_flow_spawn_43719:
    mov dword ptr [eax*8 + _sector + 0x4], edx
game_flow_spawn_43726:
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add edx, eax
    {disp32} lea edx, dword ptr [edx*8]
    mov ch, byte ptr [edx + _sector + 0xc]
    test ch, 1
    {disp32} je game_flow_spawn_47082
    {store} mov al, ch
    xor al, 1
    movsx ebx, di
    mov byte ptr [edx + _sector + 0xc], al
    {disp32} lea eax, dword ptr [ebx*8]
    {store} add eax, ebx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ebx
    mov dword ptr [eax + _hittype + 0x3b], 1
    cmp word ptr [esi + 30], 0
    jne game_flow_spawn_43833
    cmp word ptr [esi + 28], 0x200
    jne game_flow_spawn_43833
    xor byte ptr [edx + _sector + 0xc], 1
    {store} xor edx, edx
    mov dword ptr [eax + _hittype + 0x3b], edx
game_flow_spawn_43833:
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    mov dl, byte ptr [eax + _sector + 0x1c]
    mov byte ptr [eax + _sector + 0x14], dl
    cmp word ptr [esi + 28], 0x200
    {disp32} jne game_flow_spawn_47082
    mov dx, word ptr [eax + _sector]
    mov bx, word ptr [eax + _sector + 0x2]
    mov dword ptr [esp + 24], edx
    {store} mov ecx, edx
    mov word ptr [esp + 36], dx
    {store} add ecx, ebx
    mov ebx, dword ptr [esp + 36]
    {store} cmp cx, bx
    jg game_flow_spawn_43919
    {disp32} jmp game_flow_spawn_47082
game_flow_spawn_43919:
    movsx eax, bx
    shl eax, 5
    movsx eax, word ptr [eax + _wall + 0xc]
    test eax, eax
    jl game_flow_spawn_44010
    {store} mov edx, eax
    {disp32} lea eax, dword ptr [eax*4]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    test byte ptr [eax + _sector + 0xc], 1
    jne game_flow_spawn_44010
    movsx ebx, word ptr [esp + 20]
    {disp32} lea edx, dword ptr [ebx*4]
    {store} add edx, ebx
    mov bx, word ptr [eax + _sector + 0x10]
    mov word ptr [edx*8 + _sector + 0x10], bx
    mov al, byte ptr [eax + _sector + 0x14]
    mov byte ptr [edx*8 + _sector + 0x14], al
    {disp32} jmp game_flow_spawn_47082
game_flow_spawn_44010:
    inc word ptr [esp + 36]
    mov ebx, dword ptr [esp + 36]
    {store} cmp cx, bx
    jg game_flow_spawn_43919
    {disp32} jmp game_flow_spawn_47082
game_flow_spawn_44029:
    movsx edx, word ptr [esp + 20]
    {disp32} lea ebx, dword ptr [edx*4]
    {store} add ebx, edx
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    {disp32} lea ebx, dword ptr [ebx*8]
    {store} mov edx, eax
    mov eax, dword ptr [ebx + _sector + 0x8]
    mov dword ptr [edx + _hittype + 0x37], eax
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    mov ecx, 0xffffffff
    {store} add eax, edx
    {store} mov ebx, ecx
    mov edx, dword ptr [eax*8 + _sector + 0x8]
    movsx eax, word ptr [esp + 20]
    call nextsectorneighborz_
    movsx edx, ax
    {disp32} lea ebx, dword ptr [edx*4]
    {store} add ebx, edx
    movsx edx, di
    mov word ptr [esp + 36], ax
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {disp32} lea ebx, dword ptr [ebx*8]
    {store} sub eax, edx
    mov edx, dword ptr [ebx + _sector + 0x4]
    mov dword ptr [eax + _hittype + 0x3b], edx
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    mov ecx, 1
    {store} add eax, edx
    {store} mov ebx, ecx
    mov edx, dword ptr [eax*8 + _sector + 0x4]
    movsx eax, word ptr [esp + 20]
    call nextsectorneighborz_
    movsx edx, ax
    {disp32} lea ebx, dword ptr [edx*4]
    {store} add ebx, edx
    movsx edx, di
    mov word ptr [esp + 36], ax
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {disp32} lea ebx, dword ptr [ebx*8]
    {store} sub eax, edx
    mov edx, dword ptr [ebx + _sector + 0x8]
    mov bx, word ptr [_numplayers]
    mov dword ptr [eax + _hittype + 0x3f], edx
    cmp bx, 2
    {disp32} jge game_flow_spawn_47082
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add edx, eax
    mov eax, OFFSET FLAT:_sector
    {disp32} lea edx, dword ptr [edx*8]
    {store} add eax, edx
    add eax, 8
    movsx edx, word ptr [esp + 20]
    call setinterpolation_
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov edx, OFFSET FLAT:_sector
    {disp32} lea eax, dword ptr [eax*8]
    {store} add eax, edx
    add eax, 4
    call setinterpolation_
    {disp32} jmp game_flow_spawn_47082
game_flow_spawn_44369:
    mov bx, word ptr [esi + 34]
    {store} add ebx, ebx
    mov word ptr [esi + 34], bx
    {disp32} jmp game_flow_spawn_47082
game_flow_spawn_44384:
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov ax, word ptr [eax*8 + _sector]
    movsx edx, word ptr [esp + 20]
    mov dword ptr [esp + 24], eax
    {disp32} lea eax, dword ptr [edx*4]
    mov ebp, 0x7fffffff
    {store} add eax, edx
    mov dword ptr [esp], ebp
    mov ecx, dword ptr [esp + 24]
    mov dx, word ptr [eax*8 + _sector + 0x2]
    mov ebx, dword ptr [esp + 24]
    {store} add ecx, edx
    jmp game_flow_spawn_44501
game_flow_spawn_44452:
    movsx edx, bx
    shl edx, 5
    mov ebp, dword ptr [esi + 4]
    mov eax, dword ptr [edx + _wall]
    mov edx, dword ptr [edx + _wall + 0x4]
    {store} sub ebp, edx
    {store} mov edx, ebp
    mov ebp, dword ptr [esi]
    {store} sub ebp, eax
    {store} mov eax, ebp
    call FindDistance2D_
    cmp eax, dword ptr [esp]
    jge game_flow_spawn_44500
    mov dword ptr [esp], eax
    mov dword ptr [esp + 32], ebx
game_flow_spawn_44500:
    inc ebx
game_flow_spawn_44501:
    {store} cmp bx, cx
    jl game_flow_spawn_44452
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    movsx ebx, word ptr [esp + 32]
    mov dword ptr [eax + _hittype + 0x33], ebx
    mov eax, 0x7fffffff
    mov ebx, dword ptr [esp + 24]
    mov dword ptr [esp], eax
    jmp game_flow_spawn_44652
game_flow_spawn_44552:
    movsx eax, bx
    {store} mov edx, eax
    mov ebp, dword ptr [esi + 4]
    shl edx, 5
    mov dword ptr [esp + 12], eax
    mov eax, dword ptr [edx + _wall]
    mov edx, dword ptr [edx + _wall + 0x4]
    {store} sub ebp, edx
    {store} mov edx, ebp
    mov ebp, dword ptr [esi]
    {store} sub ebp, eax
    {store} mov eax, ebp
    call FindDistance2D_
    mov ebp, dword ptr [esp]
    {store} mov edx, eax
    {store} cmp eax, ebp
    jge game_flow_spawn_44651
    movsx eax, di
    mov dword ptr [esp + 4], eax
    mov ebp, dword ptr [esp + 4]
    {disp32} lea eax, dword ptr [eax*8]
    {store} add eax, ebp
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ebp
    mov ebp, dword ptr [esp + 12]
    cmp ebp, dword ptr [eax + _hittype + 0x33]
    je game_flow_spawn_44651
    mov dword ptr [esp], edx
    mov dword ptr [esp + 32], ebx
game_flow_spawn_44651:
    inc ebx
game_flow_spawn_44652:
    {store} cmp bx, cx
    jl game_flow_spawn_44552
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    movsx ebx, word ptr [esp + 32]
    mov dword ptr [eax + _hittype + 0x37], ebx
    {disp32} jmp game_flow_spawn_47082
game_flow_spawn_44694:
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    movsx edx, di
    movsx ebx, byte ptr [eax*8 + _sector + 0x1c]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    movsx edx, word ptr [esp + 20]
    mov dword ptr [eax + _hittype + 0x3b], ebx
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov dl, byte ptr [esi + 16]
    mov byte ptr [eax*8 + _sector + 0x1c], dl
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov dl, byte ptr [esi + 16]
    mov byte ptr [eax*8 + _sector + 0x14], dl
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov al, byte ptr [eax*8 + _sector + 0x15]
    xor ah, ah
    shl eax, 8
    movsx edx, word ptr [esp + 20]
    mov word ptr [esi + 30], ax
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov al, byte ptr [eax*8 + _sector + 0x1d]
    mov cx, word ptr [esi + 30]
    xor ah, ah
    movsx edx, word ptr [esp + 20]
    {store} or ecx, eax
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov word ptr [esi + 30], cx
    mov ax, word ptr [eax*8 + _sector]
    movsx edx, word ptr [esp + 20]
    mov dword ptr [esp + 24], eax
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov ecx, dword ptr [esp + 24]
    mov dx, word ptr [eax*8 + _sector + 0x2]
    mov ebx, dword ptr [esp + 24]
    {store} add ecx, edx
    {store} cmp bx, cx
    jl game_flow_spawn_44922
    {disp32} jmp game_flow_spawn_47082
game_flow_spawn_44922:
    movsx eax, bx
    shl eax, 5
    test byte ptr [eax + _wall + 0x1c], 1
    jne game_flow_spawn_44946
    mov dl, byte ptr [esi + 16]
    mov byte ptr [eax + _wall + 0x14], dl
game_flow_spawn_44946:
    movsx eax, bx
    shl eax, 5
    test byte ptr [eax + _wall + 0xe], 2
    je game_flow_spawn_44988
    mov dx, word ptr [eax + _wall + 0xa]
    test dx, dx
    jl game_flow_spawn_44988
    movsx edx, dx
    shl edx, 5
    mov al, byte ptr [esi + 16]
    mov byte ptr [edx + _wall + 0x14], al
game_flow_spawn_44988:
    inc ebx
    {store} cmp bx, cx
    jl game_flow_spawn_44922
    {disp32} jmp game_flow_spawn_47082
game_flow_spawn_44999:
    movsx edx, word ptr [esp + 20]
    {disp32} lea ebx, dword ptr [edx*4]
    {store} add ebx, edx
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    {disp32} lea ebx, dword ptr [ebx*8]
    {store} mov edx, eax
    mov eax, dword ptr [ebx + _sector + 0x8]
    mov dword ptr [edx + _hittype + 0x33], eax
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    movsx ebx, word ptr [esi + 40]
    mov dword ptr [eax + _hittype + 0x37], ebx
    cmp word ptr [esi + 28], 0x600
    je game_flow_spawn_45124
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add edx, eax
    {disp32} lea edx, dword ptr [edx*8]
    mov eax, dword ptr [esi + 8]
    mov dword ptr [edx + _sector + 0x8], eax
game_flow_spawn_45124:
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov dx, word ptr [eax*8 + _sector]
    mov dword ptr [esp + 24], edx
    {store} mov ecx, edx
    mov dx, word ptr [eax*8 + _sector + 0x2]
    mov ebx, dword ptr [esp + 24]
    {store} add ecx, edx
    jmp game_flow_spawn_45194
game_flow_spawn_45168:
    movsx eax, bx
    shl eax, 5
    cmp word ptr [eax + _wall + 0x1c], 0
    jne game_flow_spawn_45193
    mov word ptr [eax + _wall + 0x1c], 0x270f
game_flow_spawn_45193:
    inc ebx
game_flow_spawn_45194:
    {store} cmp bx, cx
    jl game_flow_spawn_45168
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    add eax, OFFSET FLAT:_sector
    add eax, 8
    call setinterpolation_
    {disp32} jmp game_flow_spawn_47082
game_flow_spawn_45238:
    movsx edx, word ptr [esp + 20]
    {disp32} lea ebx, dword ptr [edx*4]
    {store} add ebx, edx
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    {disp32} lea ebx, dword ptr [ebx*8]
    {store} mov edx, eax
    mov eax, dword ptr [ebx + _sector + 0x4]
    mov dword ptr [edx + _hittype + 0x33], eax
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    movsx ebx, word ptr [esi + 40]
    mov dword ptr [eax + _hittype + 0x37], ebx
    cmp word ptr [esi + 28], 0x600
    je game_flow_spawn_45363
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add edx, eax
    {disp32} lea edx, dword ptr [edx*8]
    mov eax, dword ptr [esi + 8]
    mov dword ptr [edx + _sector + 0x4], eax
game_flow_spawn_45363:
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov dx, word ptr [eax*8 + _sector]
    mov dword ptr [esp + 24], edx
    {store} mov ecx, edx
    mov dx, word ptr [eax*8 + _sector + 0x2]
    mov ebx, dword ptr [esp + 24]
    {store} add ecx, edx
    jmp game_flow_spawn_45433
game_flow_spawn_45407:
    movsx eax, bx
    shl eax, 5
    cmp word ptr [eax + _wall + 0x1c], 0
    jne game_flow_spawn_45432
    mov word ptr [eax + _wall + 0x1c], 0x270f
game_flow_spawn_45432:
    inc ebx
game_flow_spawn_45433:
    {store} cmp bx, cx
    jl game_flow_spawn_45407
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    add eax, OFFSET FLAT:_sector
    add eax, 4
    call setinterpolation_
    {disp32} jmp game_flow_spawn_47082
game_flow_spawn_45477:
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    movsx edx, di
    movsx ebx, byte ptr [eax*8 + _sector + 0x1c]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    movsx edx, word ptr [esp + 20]
    mov dword ptr [eax + _hittype + 0x37], ebx
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov ax, word ptr [eax*8 + _sector]
    movsx edx, word ptr [esp + 20]
    mov dword ptr [esp + 24], eax
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov ecx, dword ptr [esp + 24]
    add cx, word ptr [eax*8 + _sector + 0x2]
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov al, byte ptr [eax*8 + _sector + 0x15]
    xor ah, ah
    shl eax, 8
    movsx edx, word ptr [esp + 20]
    mov word ptr [esi + 30], ax
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov al, byte ptr [eax*8 + _sector + 0x1d]
    mov bx, word ptr [esi + 30]
    xor ah, ah
    {store} or ebx, eax
    mov word ptr [esi + 30], bx
    mov ebx, dword ptr [esp + 24]
    {store} cmp bx, cx
    jl game_flow_spawn_45655
    {disp32} jmp game_flow_spawn_47082
game_flow_spawn_45655:
    movsx eax, bx
    shl eax, 5
    movsx edx, di
    movsx ebp, byte ptr [eax + _wall + 0x14]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    cmp ebp, dword ptr [eax + _hittype + 0x3b]
    jle game_flow_spawn_45703
    mov dword ptr [eax + _hittype + 0x3b], ebp
game_flow_spawn_45703:
    inc ebx
    {store} cmp bx, cx
    jl game_flow_spawn_45655
    {disp32} jmp game_flow_spawn_47082
game_flow_spawn_45714:
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    cmp word ptr [eax*8 + _sector + 0x22], 0
    je game_flow_spawn_45799
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov ebp, dword ptr [esi + 8]
    mov eax, dword ptr [eax*8 + _sector + 0x4]
    {store} sub eax, ebp
    call labs_
    .att_syntax prefix
    cmpl $game_math_spawn_45770,%eax
    .intel_syntax noprefix
    jle game_flow_spawn_45799
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    or byte ptr [eax*8 + _sector + 0x23], 0x80
game_flow_spawn_45799:
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    movsx ebx, di
    {store} add edx, eax
    {disp32} lea eax, dword ptr [ebx*8]
    {store} add eax, ebx
    {disp32} lea edx, dword ptr [edx*8]
    {disp32} lea eax, dword ptr [eax*8]
    movsx ecx, byte ptr [edx + _sector + 0x1c]
    {store} sub eax, ebx
    movsx ebx, byte ptr [edx + _sector + 0x14]
    mov dword ptr [eax + _hittype + 0x2f], ecx
    mov dword ptr [eax + _hittype + 0x33], ebx
    mov ax, word ptr [edx + _sector]
    mov bx, word ptr [edx + _sector + 0x2]
    {store} mov ecx, eax
    mov dword ptr [esp + 24], eax
    {store} add ecx, ebx
    {store} mov ebx, eax
    jmp game_flow_spawn_45942
game_flow_spawn_45893:
    movsx eax, bx
    shl eax, 5
    movsx edx, di
    movsx ebp, byte ptr [eax + _wall + 0x14]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    cmp ebp, dword ptr [eax + _hittype + 0x37]
    jle game_flow_spawn_45941
    mov dword ptr [eax + _hittype + 0x37], ebp
game_flow_spawn_45941:
    inc ebx
game_flow_spawn_45942:
    {store} cmp bx, cx
    jl game_flow_spawn_45893
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov dword ptr [eax + _hittype + 0x3b], 1
    {disp32} jmp game_flow_spawn_47082
game_flow_spawn_45983:
    cmp word ptr [esi + 28], 0x400
    jle game_flow_spawn_46024
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov dword ptr [eax + _hittype + 0x3b], 2
    jmp game_flow_spawn_46055
game_flow_spawn_46024:
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov dword ptr [eax + _hittype + 0x3b], 0xfffffffe
game_flow_spawn_46055:
    cmp word ptr [esi + 38], 0
    {disp32} jne game_flow_spawn_46343
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    cmp word ptr [eax*8 + _sector + 0x22], 0x1e
    jne game_flow_spawn_46187
    cmp byte ptr [esi + 17], 0
    je game_flow_spawn_46112
    movsx eax, di
    imul eax, eax, 0x2c
    mov byte ptr [eax + _sprite + 0x12], 1
    jmp game_flow_spawn_46126
game_flow_spawn_46112:
    movsx eax, di
    imul eax, eax, 0x2c
    xor ch, ch
    mov byte ptr [eax + _sprite + 0x12], ch
game_flow_spawn_46126:
    movsx edx, word ptr [esp + 20]
    {disp32} lea ebx, dword ptr [edx*4]
    {store} add ebx, edx
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {disp32} lea ebx, dword ptr [ebx*8]
    {store} sub eax, edx
    mov edx, dword ptr [ebx + _sector + 0x8]
    mov word ptr [ebx + _sector + 0x24], di
    mov dword ptr [eax + _hittype + 0x3b], edx
game_flow_spawn_46187:
    {store} xor eax, eax
    mov word ptr [esp + 36], ax
    jmp game_flow_spawn_46280
game_flow_spawn_46196:
    movsx eax, bx
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 0x1a], 0x400
    jge game_flow_spawn_46275
    mov dx, word ptr [eax + _sprite + 0xe]
    cmp dx, 1
    jne game_flow_spawn_46275
    cmp dx, word ptr [eax + _sprite + 0x26]
    jne game_flow_spawn_46275
    mov dx, word ptr [eax + _sprite + 0x28]
    cmp dx, word ptr [esi + 40]
    jne game_flow_spawn_46275
    cmp word ptr [esi + 28], 0x200
    jne game_flow_spawn_46291
    mov edx, dword ptr [eax + _sprite]
    mov dword ptr [esi], edx
    mov eax, dword ptr [eax + _sprite + 0x4]
    mov dword ptr [esi + 4], eax
    jmp game_flow_spawn_46291
game_flow_spawn_46275:
    inc word ptr [esp + 36]
game_flow_spawn_46280:
    mov ebx, dword ptr [esp + 36]
    cmp bx, 0x1000
    jl game_flow_spawn_46196
game_flow_spawn_46291:
    cmp word ptr [esp + 36], 0x1000
    jne game_flow_spawn_46335
    mov ebx, dword ptr [esi + 4]
    push ebx
    mov ecx, dword ptr [esi]
    push ecx
    push OFFSET FLAT:game_text_spawn_440
    push OFFSET FLAT:_tempbuf
    call sprintf_
    add esp, 0x10
    mov eax, OFFSET FLAT:_tempbuf
    call gameexit_
game_flow_spawn_46335:
    mov eax, dword ptr [esp + 36]
    mov word ptr [esi + 30], ax
game_flow_spawn_46343:
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov dx, word ptr [eax*8 + _sector]
    mov dword ptr [esp + 24], edx
    {store} mov ecx, edx
    add cx, word ptr [eax*8 + _sector + 0x2]
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    {store} mov edx, eax
    mov eax, dword ptr [_tempwallptr]
    mov ebx, dword ptr [esp + 24]
    mov dword ptr [edx + _hittype + 0x33], eax
    jmp game_flow_spawn_46524
game_flow_spawn_46419:
    movsx eax, bx
    shl eax, 5
    mov ebp, dword ptr [esi]
    mov edx, dword ptr [eax + _wall]
    {store} sub edx, ebp
    mov ebp, dword ptr [_tempwallptr]
    mov dword ptr [ebp*4 + _msx], edx
    mov edx, dword ptr [eax + _wall + 0x4]
    sub edx, dword ptr [esi + 4]
    mov dword ptr [ebp*4 + _msy], edx
    lea edx, dword ptr [ebp + 1]
    mov dword ptr [_tempwallptr], edx
    cmp edx, 0x7ff
    jle game_flow_spawn_46523
    mov edx, dword ptr [eax + _wall + 0x4]
    push edx
    mov ebp, dword ptr [eax + _wall]
    push ebp
    push OFFSET FLAT:game_text_spawn_496
    push OFFSET FLAT:_tempbuf
    call sprintf_
    add esp, 0x10
    mov eax, OFFSET FLAT:_tempbuf
    call gameexit_
game_flow_spawn_46523:
    inc ebx
game_flow_spawn_46524:
    {store} cmp bx, cx
    jl game_flow_spawn_46419
    mov bx, word ptr [esi + 38]
    cmp bx, 0x1e
    je game_flow_spawn_46561
    cmp bx, 6
    je game_flow_spawn_46561
    cmp bx, 0xe
    je game_flow_spawn_46561
    cmp bx, 5
    {disp32} jne game_flow_spawn_46844
game_flow_spawn_46561:
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov dx, word ptr [eax*8 + _sector]
    mov bx, word ptr [eax*8 + _sector + 0x2]
    mov dword ptr [esp + 24], edx
    {store} mov ecx, edx
    movsx eax, word ptr [eax*8 + _sector + 0x24]
    {store} add ecx, ebx
    cmp eax, -1
    setne al
    xor ah, ah
    movsx edx, word ptr [esp + 20]
    mov word ptr [esi + 42], ax
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov word ptr [eax*8 + _sector + 0x24], di
    {store} xor eax, eax
    mov ebx, dword ptr [esp + 24]
    mov word ptr [esp + 36], ax
    jmp game_flow_spawn_46734
game_flow_spawn_46654:
    movsx edx, bx
    shl edx, 5
    mov ax, word ptr [edx + _wall + 0xc]
    test ax, ax
    jl game_flow_spawn_46733
    cwde
    mov dword ptr [esp + 4], eax
    mov ebp, dword ptr [esp + 4]
    {disp32} lea eax, dword ptr [eax*4]
    {store} add eax, ebp
    {disp32} lea eax, dword ptr [eax*8]
    cmp word ptr [eax + _sector + 0x24], 0
    jne game_flow_spawn_46733
    cmp word ptr [eax + _sector + 0x22], 3
    jge game_flow_spawn_46733
    mov bx, word ptr [edx + _wall + 0xc]
    mov word ptr [esp + 36], 1
    jmp game_flow_spawn_46739
game_flow_spawn_46733:
    inc ebx
game_flow_spawn_46734:
    {store} cmp bx, cx
    jl game_flow_spawn_46654
game_flow_spawn_46739:
    cmp word ptr [esp + 36], 0
    jne game_flow_spawn_46782
    mov eax, dword ptr [esi + 4]
    push eax
    mov edx, dword ptr [esi]
    push edx
    push OFFSET FLAT:game_text_spawn_536
    push OFFSET FLAT:_tempbuf
    call sprintf_
    add esp, 0x10
    mov eax, OFFSET FLAT:_tempbuf
    call gameexit_
game_flow_spawn_46782:
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    movsx ebx, bx
    mov word ptr [esi + 30], 0xffff
    mov dword ptr [eax + _hittype + 0x2f], ebx
    cmp word ptr [esi + 38], 0x1e
    {disp32} je game_flow_spawn_47082
    movsx edx, word ptr [esi + 40]
    mov dword ptr [eax + _hittype + 0x3b], edx
    {disp32} jmp game_flow_spawn_47082
game_flow_spawn_46844:
    cmp bx, 0x10
    jne game_flow_spawn_46909
    movsx edx, word ptr [esp + 20]
    {disp32} lea ebx, dword ptr [edx*4]
    {store} add ebx, edx
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {disp32} lea ebx, dword ptr [ebx*8]
    {store} sub eax, edx
    mov edx, dword ptr [ebx + _sector + 0x4]
    mov dword ptr [eax + _hittype + 0x3b], edx
    {disp32} jmp game_flow_spawn_47082
game_flow_spawn_46909:
    cmp bx, 0x1a
    jne game_flow_spawn_47005
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov edx, dword ptr [esi]
    mov dword ptr [eax + _hittype + 0x3b], edx
    mov edx, dword ptr [esi + 4]
    mov dword ptr [eax + _hittype + 0x3f], edx
    movsx edx, word ptr [esp + 20]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add edx, eax
    {disp32} lea edx, dword ptr [edx*8]
    mov al, byte ptr [esi + 16]
    cmp al, byte ptr [edx + _sector + 0x1c]
    jne game_flow_spawn_46993
    mov word ptr [esi + 36], 0xff00
    jmp game_flow_spawn_46999
game_flow_spawn_46993:
    mov word ptr [esi + 36], 0x100
game_flow_spawn_46999:
    mov byte ptr [esi + 16], 0
    jmp game_flow_spawn_47082
game_flow_spawn_47005:
    cmp bx, 2
    jne game_flow_spawn_47082
    movsx edx, word ptr [esi + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    movsx edx, di
    movsx ebx, word ptr [eax*8 + _sector + 0x1a]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov dword ptr [eax + _hittype + 0x43], ebx
    movsx edx, word ptr [esi + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    {store} xor edx, edx
    mov word ptr [eax*8 + _sector + 0x1a], dx
game_flow_spawn_47082:
    mov ax, word ptr [esi + 38]
    .att_syntax prefix
    cmpw $game_math_spawn_47086,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_47134
    {disp32} jbe game_flow_spawn_47168
    .att_syntax prefix
    cmpw $game_math_spawn_47098,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_47126
    .att_syntax prefix
    cmpw $game_math_spawn_47104,%ax
    .intel_syntax noprefix
    jbe game_flow_spawn_47168
    .att_syntax prefix
    cmpw $game_math_spawn_47110,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_47176
    jbe game_flow_spawn_47168
    .att_syntax prefix
    cmpw $game_math_spawn_47118,%ax
    .intel_syntax noprefix
    je game_flow_spawn_47158
    jmp game_flow_spawn_47176
game_flow_spawn_47126:
    .att_syntax prefix
    cmpw $game_math_spawn_47126,%ax
    .intel_syntax noprefix
    je game_flow_spawn_47158
    jmp game_flow_spawn_47176
game_flow_spawn_47134:
    .att_syntax prefix
    cmpw $game_math_spawn_47134,%ax
    .intel_syntax noprefix
    jb game_flow_spawn_47150
    jbe game_flow_spawn_47168
    .att_syntax prefix
    cmpw $game_math_spawn_47142,%ax
    .intel_syntax noprefix
    je game_flow_spawn_47158
    jmp game_flow_spawn_47176
game_flow_spawn_47150:
    .att_syntax prefix
    cmpw $game_math_spawn_47150,%ax
    .intel_syntax noprefix
    jbe game_flow_spawn_47168
    jmp game_flow_spawn_47176
game_flow_spawn_47158:
    cmp word ptr [_numplayers], 1
    jg game_flow_spawn_47176
game_flow_spawn_47168:
    movsx eax, di
    call setsectinterpolate_
game_flow_spawn_47176:
    mov edx, 3
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_47200:
    mov cl, byte ptr [esi + 20]
    mov byte ptr [esi + 16], 0xf0
    cmp cl, 8
    ja game_flow_spawn_47230
    mov word ptr [esi + 12], 0x8000
    mov byte ptr [esi + 21], 0
    mov al, byte ptr [esi + 21]
    mov byte ptr [esi + 20], al
    jmp game_flow_spawn_47236
game_flow_spawn_47230:
    mov word ptr [esi + 12], 0x101
game_flow_spawn_47236:
    mov ax, word ptr [_impact_damage]
    shl eax, 2
    mov edx, 6
    mov word ptr [esi + 42], ax
    movsx eax, di
    mov word ptr [esi + 30], di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_47277:
    cmp word ptr [esi + 14], 0x394
    jne game_flow_spawn_47306
    mov word ptr [esi + 12], 0x101
    mov ax, word ptr [_impact_damage]
    shl eax, 2
    mov word ptr [esi + 42], ax
    jmp game_flow_spawn_47321
game_flow_spawn_47306:
    mov dl, byte ptr [esi + 12]
    mov word ptr [esi + 42], 1
    or dl, 0x11
    mov byte ptr [esi + 12], dl
game_flow_spawn_47321:
    cmp word ptr [_ud + 0x590], 2
    jge game_flow_spawn_47371
    cmp byte ptr [esi + 17], 0
    je game_flow_spawn_47371
    mov byte ptr [esi + 21], 0
    mov al, byte ptr [esi + 21]
    mov edx, 5
    mov byte ptr [esi + 20], al
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_47371:
    movsx ebx, di
    mov edx, 6
    {store} mov eax, ebx
    mov word ptr [esi + 30], di
    call changespritestat_
    mov edx, 0x10001
    {store} mov eax, ebx
    mov word ptr [esi + 32], 8
    call ssp_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_47419:
    mov word ptr [esi + 38], 1
    mov byte ptr [esi + 18], 8
    mov cx, word ptr [esi + 12]
    mov word ptr [esi + 30], di
    or ecx, 0x101
    mov word ptr [esi + 12], cx
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_47458:
    mov word ptr [esi + 42], 0
game_flow_spawn_47464:
    cmp word ptr [esp + 36], 0
    jl game_flow_spawn_47482
    mov byte ptr [esi + 21], 0x20
    mov al, byte ptr [esi + 21]
    mov byte ptr [esi + 20], al
game_flow_spawn_47482:
    mov ebx, dword ptr [esp + 36]
    movsx eax, di
    mov byte ptr [esi + 18], 0x48
    call makeitfall_
    test bx, bx
    jl game_flow_spawn_47509
    mov word ptr [esi + 30], bx
    jmp game_flow_spawn_47513
game_flow_spawn_47509:
    mov word ptr [esi + 30], di
game_flow_spawn_47513:
    cmp dword ptr [_ud + 0x5fe], 1
    jne game_flow_spawn_47564
    cmp word ptr [esi + 14], 0x2a3
    jne game_flow_spawn_47564
    mov byte ptr [esi + 21], 0
    mov al, byte ptr [esi + 21]
    mov edx, 5
    mov byte ptr [esi + 20], al
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_47564:
    cmp word ptr [esi + 14], 0x2a3
    jne game_flow_spawn_47576
    mov byte ptr [esi + 18], 0x18
game_flow_spawn_47576:
    call krand_
    xor ah, ah
    and al, 4
    or eax, 0x101
    mov edx, 2
    mov word ptr [esi + 12], ax
    movsx eax, di
    call changespritestat_
    {store} mov eax, edi
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spawn_47618:
    mov edx, 6
    movsx eax, di
    mov byte ptr [esi + 16], 0xf0
    call changespritestat_
game_flow_spawn_47635:
    {store} mov eax, edi
game_flow_spawn_47637:
    add esp, 0x28
game_flow_spawn_47640:
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
    {disp8} lea eax, dword ptr [eax] # native three-byte identity alignment before real animation table
.section GAME_CMD,"ax",@progbits
    nop
game_switch_checkcommandline_62568:
    # Real compiler switch table: 58 named private destinations
    .long game_flow_checkcommandline_62964
    .long game_flow_checkcommandline_62964
    .long game_flow_checkcommandline_62964
    .long game_flow_checkcommandline_62964
    .long game_flow_checkcommandline_63251
    .long game_flow_checkcommandline_63418
    .long game_flow_checkcommandline_62964
    .long game_flow_checkcommandline_63368
    .long game_flow_checkcommandline_63067
    .long game_flow_checkcommandline_62964
    .long game_flow_checkcommandline_63195
    .long game_flow_checkcommandline_63759
    .long game_flow_checkcommandline_62964
    .long game_flow_checkcommandline_63693
    .long game_flow_checkcommandline_63553
    .long game_flow_checkcommandline_63097
    .long game_flow_checkcommandline_62964
    .long game_flow_checkcommandline_62964
    .long game_flow_checkcommandline_63593
    .long game_flow_checkcommandline_63666
    .long game_flow_checkcommandline_63819
    .long game_flow_checkcommandline_63431
    .long game_flow_checkcommandline_62964
    .long game_flow_checkcommandline_63784
    .long game_flow_checkcommandline_62964
    .long game_flow_checkcommandline_62978
    .long game_flow_checkcommandline_62964
    .long game_flow_checkcommandline_62964
    .long game_flow_checkcommandline_62964
    .long game_flow_checkcommandline_62964
    .long game_flow_checkcommandline_62964
    .long game_flow_checkcommandline_62964
    .long game_flow_checkcommandline_62964
    .long game_flow_checkcommandline_62964
    .long game_flow_checkcommandline_62964
    .long game_flow_checkcommandline_62964
    .long game_flow_checkcommandline_63251
    .long game_flow_checkcommandline_63418
    .long game_flow_checkcommandline_62964
    .long game_flow_checkcommandline_63368
    .long game_flow_checkcommandline_63067
    .long game_flow_checkcommandline_62964
    .long game_flow_checkcommandline_63195
    .long game_flow_checkcommandline_63759
    .long game_flow_checkcommandline_62964
    .long game_flow_checkcommandline_63693
    .long game_flow_checkcommandline_63553
    .long game_flow_checkcommandline_63097
    .long game_flow_checkcommandline_62964
    .long game_flow_checkcommandline_62964
    .long game_flow_checkcommandline_63593
    .long game_flow_checkcommandline_63666
    .long game_flow_checkcommandline_63819
    .long game_flow_checkcommandline_63431
    .long game_flow_checkcommandline_62964
    .long game_flow_checkcommandline_63784
    .long game_flow_checkcommandline_62964
    .long game_flow_checkcommandline_62978
checkcommandline_:
    push ebx
    push ecx
    push esi
    push edi
    push ebp
    {store} mov edi, eax
    {store} mov ecx, edx
    mov esi, 1
    mov edx, 1
    xor ah, ah
    {store} xor ebx, ebx
    mov dword ptr [_ud + 0x5c6], edx
    mov byte ptr [_ud], ah
    mov dword ptr [_ud + 0x606], ebx
    xor dl, dl
    mov dword ptr [_ud + 0x60a], ebx
    mov byte ptr [_ud + 0x1], dl
    xor dh, dh
    mov dword ptr [_ud + 0x60e], ebx
    mov byte ptr [_ud + 0x2], dh
    cmp edi, 1
    {disp32} jle game_flow_spawn_47640
game_flow_checkcommandline_62878:
    movsx eax, si
    {store} cmp eax, edi
    {disp32} jge game_flow_spawn_47640
    mov ebx, dword ptr [ecx + eax*4]
    mov al, byte ptr [ebx]
    cmp al, 0x2d
    jne game_flow_checkcommandline_62914
    cmp byte ptr [ebx + 1], 0x38
    jne game_flow_checkcommandline_62911
    mov byte ptr [_eightytwofifty], 1
game_flow_checkcommandline_62911:
    inc esi
    jmp game_flow_checkcommandline_62878
game_flow_checkcommandline_62914:
    cmp al, 0x3f
    jne game_flow_checkcommandline_62932
    {store} mov eax, ecx
    call comlinehelp_
    {store} xor eax, eax
    call exit_
game_flow_checkcommandline_62932:
    cmp byte ptr [ebx], 0x2f
    {disp32} jne game_flow_checkcommandline_63851
    mov al, byte ptr [ebx + 1]
    sub al, 0x3f
    inc ebx
    cmp al, 0x39
    ja game_flow_checkcommandline_62964
    and eax, 0xff
    jmp dword ptr cs:[eax*4 + game_switch_checkcommandline_62568]
game_flow_checkcommandline_62964:
    {store} mov eax, ecx
    call comlinehelp_
    {store} xor eax, eax
    call exit_
game_flow_checkcommandline_62978:
    mov dh, byte ptr [ebx + 1]
    inc ebx
    test dh, dh
    {disp32} je game_flow_checkcommandline_63851
    mov eax, OFFSET FLAT:_confilename
    {store} mov edx, ebx
    call strcpy_
    {store} mov eax, ebx
    call SafeFileExists_
    test eax, eax
    jne game_flow_checkcommandline_63043
    push OFFSET FLAT:_confilename
    push OFFSET FLAT:game_text_checkcommandline_1432
    call printf_
    add esp, 8
    {store} xor eax, eax
    call exit_
    {disp32} jmp game_flow_checkcommandline_63851
game_flow_checkcommandline_63043:
    push OFFSET FLAT:_confilename
    push OFFSET FLAT:game_text_checkcommandline_1464
    call printf_
    add esp, 8
    inc esi
    {disp32} jmp game_flow_checkcommandline_62878
game_flow_checkcommandline_63067:
    mov al, byte ptr [ebx + 1]
    inc ebx
    test al, al
    {disp32} je game_flow_checkcommandline_63851
    mov eax, OFFSET FLAT:_groupfilename
    {store} mov edx, ebx
    call strcpy_
    inc esi
    {disp32} jmp game_flow_checkcommandline_62878
game_flow_checkcommandline_63097:
    mov dh, byte ptr [ebx + 1]
    inc ebx
    cmp dh, 0x73
    je game_flow_checkcommandline_63111
    cmp dh, 0x53
    jne game_flow_checkcommandline_63138
game_flow_checkcommandline_63111:
    mov ebp, 2
    mov eax, OFFSET FLAT:game_text_checkcommandline_1488
    mov dword ptr [_CommandSoundToggleOff], ebp
    call puts_
    inc esi
    {disp32} jmp game_flow_checkcommandline_62878
game_flow_checkcommandline_63138:
    cmp dh, 0x6d
    je game_flow_checkcommandline_63148
    cmp dh, 0x4d
    jne game_flow_checkcommandline_63175
game_flow_checkcommandline_63148:
    mov ebx, 1
    mov eax, OFFSET FLAT:game_text_checkcommandline_1500
    mov dword ptr [_CommandMusicToggleOff], ebx
    call puts_
    inc esi
    {disp32} jmp game_flow_checkcommandline_62878
game_flow_checkcommandline_63175:
    {store} mov eax, ecx
    call comlinehelp_
    {store} xor eax, eax
    call exit_
    inc esi
    {disp32} jmp game_flow_checkcommandline_62878
game_flow_checkcommandline_63195:
    mov ah, byte ptr [ebx + 1]
    inc ebx
    cmp ah, 0x30
    jne game_flow_checkcommandline_63212
    xor dl, dl
    mov byte ptr [_networkmode], dl
game_flow_checkcommandline_63212:
    cmp byte ptr [ebx], 0x31
    jne game_flow_checkcommandline_63224
    mov byte ptr [_networkmode], 1
game_flow_checkcommandline_63224:
    {store} xor eax, eax
    mov al, byte ptr [_networkmode]
    push eax
    push OFFSET FLAT:game_text_checkcommandline_1512
    call printf_
    add esp, 8
    inc esi
    {disp32} jmp game_flow_checkcommandline_62878
game_flow_checkcommandline_63251:
    mov al, byte ptr [ebx + 1]
    inc ebx
    cmp al, 0x30
    je game_flow_checkcommandline_63267
    cmp al, 0x31
    je game_flow_checkcommandline_63267
    cmp al, 0x32
    jne game_flow_checkcommandline_63281
game_flow_checkcommandline_63267:
    {store} xor eax, eax
    mov al, byte ptr [ebx]
    sub eax, 0x30
    mov dword ptr [_ud + 0x5da], eax
    jmp game_flow_checkcommandline_63289
game_flow_checkcommandline_63281:
    {store} xor edx, edx
    mov dword ptr [_ud + 0x5da], edx
game_flow_checkcommandline_63289:
    mov eax, dword ptr [_ud + 0x5da]
    cmp eax, 1
    jb game_flow_checkcommandline_63312
    jbe game_flow_checkcommandline_63336
    cmp eax, 2
    je game_flow_checkcommandline_63352
    inc esi
    {disp32} jmp game_flow_checkcommandline_62878
game_flow_checkcommandline_63312:
    test eax, eax
    {disp32} jne game_flow_checkcommandline_63851
    mov eax, OFFSET FLAT:game_text_checkcommandline_1532
    call puts_
    inc esi
    {disp32} jmp game_flow_checkcommandline_62878
game_flow_checkcommandline_63336:
    mov eax, OFFSET FLAT:game_text_checkcommandline_1552
    call puts_
    inc esi
    {disp32} jmp game_flow_checkcommandline_62878
game_flow_checkcommandline_63352:
    mov eax, OFFSET FLAT:game_text_checkcommandline_1572
    call puts_
    inc esi
    {disp32} jmp game_flow_checkcommandline_62878
game_flow_checkcommandline_63368:
    mov ah, byte ptr [ebx + 1]
    inc ebx
    cmp ah, 0x31
    jne game_flow_checkcommandline_63384
    mov byte ptr [_movesperpacket], 1
game_flow_checkcommandline_63384:
    cmp byte ptr [ebx], 0x32
    jne game_flow_checkcommandline_63396
    mov byte ptr [_movesperpacket], 2
game_flow_checkcommandline_63396:
    cmp byte ptr [ebx], 0x34
    {disp32} jne game_flow_checkcommandline_63851
    mov byte ptr [_movesperpacket], 4
    inc esi
    {disp32} jmp game_flow_checkcommandline_62878
game_flow_checkcommandline_63418:
    mov byte ptr [_ud + 0x5], 1
    inc esi
    {disp32} jmp game_flow_checkcommandline_62878
game_flow_checkcommandline_63431:
    mov dh, byte ptr [ebx + 1]
    inc ebx
    cmp dh, 0x31
    jne game_flow_checkcommandline_63452
    mov dword ptr [_ud + 0x60a], 1
    jmp game_flow_checkcommandline_63537
game_flow_checkcommandline_63452:
    cmp dh, 0x32
    jne game_flow_checkcommandline_63483
    mov dword ptr [_ud + 0x606], 1
    mov eax, OFFSET FLAT:game_text_checkcommandline_1596
    call puts_
    inc esi
    {disp32} jmp game_flow_checkcommandline_62878
game_flow_checkcommandline_63483:
    cmp dh, 0x33
    jne game_flow_checkcommandline_63514
    mov dword ptr [_ud + 0x60e], 1
    mov eax, OFFSET FLAT:game_text_checkcommandline_1596
    call puts_
    inc esi
    {disp32} jmp game_flow_checkcommandline_62878
game_flow_checkcommandline_63514:
    mov edx, 1
    mov dword ptr [_ud + 0x60a], edx
    mov dword ptr [_ud + 0x606], edx
    mov dword ptr [_ud + 0x60e], edx
game_flow_checkcommandline_63537:
    mov eax, OFFSET FLAT:game_text_checkcommandline_1596
    call puts_
    inc esi
    {disp32} jmp game_flow_checkcommandline_62878
game_flow_checkcommandline_63553:
    mov eax, 1
    {store} xor edx, edx
    mov dword ptr [_ud + 0x616], eax
    mov dword ptr [_ud + 0x62a], edx
    mov eax, OFFSET FLAT:game_text_checkcommandline_1608
    mov dword ptr [_ud + 0x61e], edx
    call puts_
    inc esi
    {disp32} jmp game_flow_checkcommandline_62878
game_flow_checkcommandline_63593:
    mov eax, OFFSET FLAT:game_text_checkcommandline_1624
    call puts_
    mov dl, byte ptr [ebx + 1]
    inc ebx
    test dl, dl
    jne game_flow_checkcommandline_63622
    mov word ptr [_ud + 0x590], 1
    jmp game_flow_checkcommandline_63648
game_flow_checkcommandline_63622:
    {store} mov eax, ebx
    call atol_
    {store} mov edx, eax
    mov ebx, 0x10
    sar edx, 0x1f
    idiv ebx
    mov word ptr [_ud + 0x590], dx
game_flow_checkcommandline_63648:
    {store} xor eax, eax
    mov dword ptr [_ud + 0x5de], eax
    mov dword ptr [_ud + 0x5da], eax
    inc esi
    {disp32} jmp game_flow_checkcommandline_62878
game_flow_checkcommandline_63666:
    mov ebp, 1
    mov eax, OFFSET FLAT:game_text_checkcommandline_1644
    mov dword ptr [_ud + 0x612], ebp
    call puts_
    inc esi
    {disp32} jmp game_flow_checkcommandline_62878
game_flow_checkcommandline_63693:
    mov dh, 1
    lea eax, dword ptr [ebx + 1]
    mov byte ptr [_ud + 0x1], dh
    call atol_
    lea edx, dword ptr [eax + -1]
    mov ebx, 0xb
    {store} mov eax, edx
    sar edx, 0x1f
    idiv ebx
    mov ebp, 1
    mov dword ptr [_ud + 0x62a], ebp
    mov dword ptr [_ud + 0x61e], ebp
    mov dword ptr [_ud + 0x62e], edx
    mov dword ptr [_ud + 0x622], edx
    inc esi
    {disp32} jmp game_flow_checkcommandline_62878
game_flow_checkcommandline_63759:
    push OFFSET FLAT:game_text_checkcommandline_1664
    push OFFSET FLAT:game_text_checkcommandline_1672
    call printf_
    add esp, 8
    {store} xor eax, eax
    call exit_
game_flow_checkcommandline_63784:
    mov byte ptr [_ud + 0x1], 1
    lea eax, dword ptr [ebx + 1]
    call atol_
    and eax, 3
    dec eax
    mov dword ptr [_ud + 0x632], eax
    mov dword ptr [_ud + 0x626], eax
    inc esi
    {disp32} jmp game_flow_checkcommandline_62878
game_flow_checkcommandline_63819:
    lea eax, dword ptr [ebx + 1]
    call atol_
    {store} mov edx, eax
    mov ebx, 5
    sar edx, 0x1f
    idiv ebx
    mov dword ptr [_ud + 0x62a], edx
    mov dword ptr [_ud + 0x61e], edx
game_flow_checkcommandline_63851:
    inc esi
    {disp32} jmp game_flow_checkcommandline_62878
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
    {disp8} lea eax, dword ptr [eax]
.equ game_math_spawn_32431, 1024
.equ game_math_spawn_32447, 1647
.equ game_math_spawn_32463, 2271
.equ game_math_spawn_32479, 2533
.equ game_math_spawn_32495, 2631
.equ game_math_spawn_32507, 3190
.equ game_math_spawn_32519, 3450
.equ game_math_spawn_32531, 3999
.equ game_math_spawn_32552, 3400
.equ game_math_spawn_32573, 2710
.equ game_math_spawn_32589, 2760
.equ game_math_spawn_32610, 2567
.equ game_math_spawn_32622, 2590
.equ game_math_spawn_32638, 2630
.equ game_math_spawn_32659, 2535
.equ game_math_spawn_32675, 2566
.equ game_math_spawn_32696, 2329
.equ game_math_spawn_32708, 2370
.equ game_math_spawn_32720, 2420
.equ game_math_spawn_32732, 2491
.equ game_math_spawn_32753, 2380
.equ game_math_spawn_32774, 2333
.equ game_math_spawn_32790, 2360
.equ game_math_spawn_32811, 2300
.equ game_math_spawn_32823, 2310
.equ game_math_spawn_32839, 2311
.equ game_math_spawn_32860, 2286
.equ game_math_spawn_32876, 2296
.equ game_math_spawn_32958, 1921
.equ game_math_spawn_32974, 2121
.equ game_math_spawn_32986, 2165
.equ game_math_spawn_32998, 2219
.equ game_math_spawn_33010, 2270
.equ game_math_spawn_33031, 2200
.equ game_math_spawn_33052, 2150
.equ game_math_spawn_33068, 2160
.equ game_math_spawn_33089, 2001
.equ game_math_spawn_33101, 2045
.equ game_math_spawn_33117, 2120
.equ game_math_spawn_33138, 1960
.equ game_math_spawn_33154, 2000
.equ game_math_spawn_33175, 1741
.equ game_math_spawn_33187, 1821
.equ game_math_spawn_33199, 1890
.equ game_math_spawn_33211, 1920
.equ game_math_spawn_33232, 1880
.equ game_math_spawn_33253, 1744
.equ game_math_spawn_33269, 1820
.equ game_math_spawn_33290, 1682
.equ game_math_spawn_33302, 1715
.equ game_math_spawn_33318, 1725
.equ game_math_spawn_33339, 1656
.equ game_math_spawn_33355, 1680
.equ game_math_spawn_33370, 1272
.equ game_math_spawn_33386, 1353
.equ game_math_spawn_33402, 1395
.equ game_math_spawn_33414, 1518
.equ game_math_spawn_33426, 1620
.equ game_math_spawn_33438, 1630
.equ game_math_spawn_33459, 1550
.equ game_math_spawn_33480, 1405
.equ game_math_spawn_33496, 1420
.equ game_math_spawn_33517, 1360
.equ game_math_spawn_33529, 1380
.equ game_math_spawn_33545, 1390
.equ game_math_spawn_33566, 1355
.equ game_math_spawn_33576, 1358
.equ game_math_spawn_33625, 1324
.equ game_math_spawn_33637, 1336
.equ game_math_spawn_33649, 1348
.equ game_math_spawn_33661, 1352
.equ game_math_spawn_33678, 1346
.equ game_math_spawn_33699, 1325
.equ game_math_spawn_33709, 1334
.equ game_math_spawn_33730, 1317
.equ game_math_spawn_33742, 1321
.equ game_math_spawn_33758, 1323
.equ game_math_spawn_33779, 1294
.equ game_math_spawn_33795, 1312
.equ game_math_spawn_33816, 1174
.equ game_math_spawn_33832, 1238
.equ game_math_spawn_33844, 1250
.equ game_math_spawn_33856, 1261
.equ game_math_spawn_33868, 1267
.equ game_math_spawn_33889, 1255
.equ game_math_spawn_33910, 1240
.equ game_math_spawn_33926, 1247
.equ game_math_spawn_33947, 1227
.equ game_math_spawn_33953, 1229
.equ game_math_spawn_33963, 1232
.equ game_math_spawn_33979, 1233
.equ game_math_spawn_34000, 1222
.equ game_math_spawn_34016, 1226
.equ game_math_spawn_34037, 1062
.equ game_math_spawn_34049, 1088
.equ game_math_spawn_34061, 1124
.equ game_math_spawn_34077, 1157
.equ game_math_spawn_34087, 1166
.equ game_math_spawn_34108, 1069
.equ game_math_spawn_34124, 1079
.equ game_math_spawn_34145, 1046
.equ game_math_spawn_34157, 1059
.equ game_math_spawn_34173, 1060
.equ game_math_spawn_34194, 1025
.equ game_math_spawn_34204, 1026
.equ game_math_spawn_34225, 616
.equ game_math_spawn_34241, 904
.equ game_math_spawn_34257, 971
.equ game_math_spawn_34267, 973
.equ game_math_spawn_34277, 981
.equ game_math_spawn_34293, 994
.equ game_math_spawn_34299, 996
.equ game_math_spawn_34309, 1012
.equ game_math_spawn_34315, 1014
.equ game_math_spawn_34325, 1020
.equ game_math_spawn_34346, 1007
.equ game_math_spawn_34356, 1009
.equ game_math_spawn_34377, 988
.equ game_math_spawn_34393, 990
.equ game_math_spawn_34414, 977
.equ game_math_spawn_34426, 978
.equ game_math_spawn_34436, 979
.equ game_math_spawn_34457, 974
.equ game_math_spawn_34467, 975
.equ game_math_spawn_34488, 921
.equ game_math_spawn_34504, 940
.equ game_math_spawn_34516, 952
.equ game_math_spawn_34528, 954
.equ game_math_spawn_34538, 957
.equ game_math_spawn_34559, 951
.equ game_math_spawn_34580, 925
.equ game_math_spawn_34590, 926
.equ game_math_spawn_34600, 939
.equ game_math_spawn_34621, 911
.equ game_math_spawn_34633, 913
.equ game_math_spawn_34643, 915
.equ game_math_spawn_34653, 916
.equ game_math_spawn_34674, 908
.equ game_math_spawn_34690, 910
.equ game_math_spawn_34711, 689
.equ game_math_spawn_34727, 765
.equ game_math_spawn_34743, 779
.equ game_math_spawn_34755, 830
.equ game_math_spawn_34767, 901
.equ game_math_spawn_34777, 902
.equ game_math_spawn_34798, 792
.equ game_math_spawn_34819, 768
.equ game_math_spawn_34829, 769
.equ game_math_spawn_34839, 774
.equ game_math_spawn_34860, 716
.equ game_math_spawn_34872, 753
.equ game_math_spawn_34888, 762
.equ game_math_spawn_34909, 694
.equ game_math_spawn_34919, 695
.equ game_math_spawn_34929, 697
.equ game_math_spawn_34950, 662
.equ game_math_spawn_34962, 675
.equ game_math_spawn_34974, 680
.equ game_math_spawn_34986, 685
.equ game_math_spawn_34996, 686
.equ game_math_spawn_35017, 678
.equ game_math_spawn_35038, 669
.equ game_math_spawn_35054, 672
.equ game_math_spawn_35069, 634
.equ game_math_spawn_35075, 637
.equ game_math_spawn_35085, 660
.equ game_math_spawn_35106, 618
.equ game_math_spawn_35116, 619
.equ game_math_spawn_35126, 621
.equ game_math_spawn_35136, 625
.equ game_math_spawn_35157, 342
.equ game_math_spawn_35167, 343
.equ game_math_spawn_35177, 554
.equ game_math_spawn_35193, 577
.equ game_math_spawn_35205, 602
.equ game_math_spawn_35217, 607
.equ game_math_spawn_35229, 609
.equ game_math_spawn_35250, 603
.equ game_math_spawn_35271, 578
.equ game_math_spawn_35281, 595
.equ game_math_spawn_35302, 568
.equ game_math_spawn_35314, 569
.equ game_math_spawn_35324, 571
.equ game_math_spawn_35345, 556
.equ game_math_spawn_35355, 557
.equ game_math_spawn_35365, 563
.equ game_math_spawn_35386, 499
.equ game_math_spawn_35398, 516
.equ game_math_spawn_35404, 517
.equ game_math_spawn_35414, 550
.equ game_math_spawn_35426, 551
.equ game_math_spawn_35447, 546
.equ game_math_spawn_35462, 502
.equ game_math_spawn_35478, 514
.equ game_math_spawn_35499, 407
.equ game_math_spawn_35511, 487
.equ game_math_spawn_35527, 489
.equ game_math_spawn_35548, 387
.equ game_math_spawn_35564, 391
.equ game_math_spawn_35585, 37
.equ game_math_spawn_35601, 60
.equ game_math_spawn_35613, 142
.equ game_math_spawn_35625, 255
.equ game_math_spawn_35637, 285
.equ game_math_spawn_35658, 160
.equ game_math_spawn_35679, 61
.equ game_math_spawn_35689, 100
.equ game_math_spawn_35710, 46
.equ game_math_spawn_35716, 49
.equ game_math_spawn_35726, 51
.equ game_math_spawn_35736, 57
.equ game_math_spawn_35746, 59
.equ game_math_spawn_35767, 40
.equ game_math_spawn_35777, 42
.equ game_math_spawn_35787, 44
.equ game_math_spawn_35808, 6
.equ game_math_spawn_35820, 21
.equ game_math_spawn_35826, 25
.equ game_math_spawn_35836, 26
.equ game_math_spawn_35846, 29
.equ game_math_spawn_35867, 8
.equ game_math_spawn_35883, 9
.equ game_math_spawn_35904, 3
.equ game_math_spawn_35916, 4
.equ game_math_spawn_35931, 1
.equ game_math_spawn_36175, 4096
.equ game_math_spawn_39107, 1536
.equ game_math_spawn_39144, 768
.equ game_math_spawn_39726, 2
.equ game_math_spawn_39966, 12288
.equ game_math_spawn_41016, 1725
.equ game_math_spawn_41024, 1741
.equ game_math_spawn_41032, 1744
.equ game_math_spawn_41040, 1680
.equ game_math_spawn_41046, 1682
.equ game_math_spawn_41052, 1715
.equ game_math_spawn_42843, 36
.equ game_math_spawn_45770, 1024
.equ game_math_spawn_47086, 11
.equ game_math_spawn_47098, 15
.equ game_math_spawn_47104, 16
.equ game_math_spawn_47110, 26
.equ game_math_spawn_47118, 30
.equ game_math_spawn_47126, 14
.equ game_math_spawn_47134, 5
.equ game_math_spawn_47142, 6
.equ game_math_spawn_47150, 1
