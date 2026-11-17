# Whole readable ACTORS mnemonic backend.
# GPL-2.0-or-later; primary notices and complete C aid retained.
# C prefix reconstructed once from fresh own C; existing source effector body retained.
# Humanization backlog: all mnemonic bodies; moveeffectors C has298 stack-home bytes unresolved.
.intel_syntax noprefix
.code32
.allow_index_reg
.file "ACTORS.S"
.globl _otherp
.globl addammo_
.globl addweapon_
.globl bounce_
.globl ceilingspace_
.globl checkavailinven_
.globl checkavailweapon_
.globl clearsectinterpolate_
.globl dointerpolations_
.globl floorspace_
.globl guts_
.globl gutsdir_
.globl hitradius_
.globl ifhitbyweapon_
.globl ifhitsectors_
.globl ifsquished_
.globl insertspriteq_
.globl lotsofmoney_
.globl moveactors_
.globl movecyclers_
.globl movedummyplayers_
.globl moveeffectors_
.globl moveexplosions_
.globl movefallers_
.globl movefta_
.globl movefx_
.globl moveplayers_
.globl movesprite_
.globl movestandables_
.globl movetransports_
.globl moveweapons_
.globl ms_
.globl restoreinterpolations_
.globl setinterpolation_
.globl setsectinterpolate_
.globl ssp_
.globl stopinterpolation_
.globl updateinterpolations_
.local _dmval
.local _radius_status_record
.extern EGS_
.extern FTA_
.extern FX_SetReverbDelay_
.extern FX_SetReverb_
.extern FX_StopAllSounds_
.extern FX_VoiceAvailable_
.extern FindDistance2D_
.extern LocateTheLocator_
.extern _AmbienceToggle
.extern _NumVoices
.extern _Sound
.extern _SoundToggle
.extern _actor_tog
.extern _bakipos
.extern _bouncemineblastradius
.extern _camerashitable
.extern _camsprite
.extern _connecthead
.extern _connectpoint2
.extern _curipos
.extern _cyclers
.extern _earthquaketime
.extern _fricxv
.extern _fricyv
.extern _global_random
.extern _headspritesect
.extern _headspritestat
.extern _hittype
.extern _impact_damage
.extern _max_ammo_amount
.extern _max_player_health
.extern _morterblastradius
.extern _msx
.extern _msy
.extern _myconnectindex
.extern _nextspritesect
.extern _nextspritestat
.extern _numcyclers
.extern _numenvsnds
.extern _numinterpolations
.extern _numplayers
.extern _oldipos
.extern _pipebombblastradius
.extern _po
.extern _ps
.extern _respawnitemtime
.extern _rpgblastradius
.extern _screenpeek
.extern _sector
.extern _seenineblastradius
.extern _shrinkerblastradius
.extern _sintable
.extern _soundm
.extern _soundpr
.extern _sprite
.extern _spriteq
.extern _spriteqloc
.extern _startofdynamicinterpolations
.extern _sync
.extern _tempbuf
.extern _tilesizy
.extern _tripbombblastradius
.extern _ud
.extern _wall
.extern _xdim
.extern _ydim
.extern activatebysector_
.extern activatewarpelevators_
.extern alignflorslope_
.extern badguy_
.extern callsound_
.extern cansee_
.extern changespritesect_
.extern changespritestat_
.extern check_activator_motion_
.extern check_fta_sounds_
.extern checkcursectnums_
.extern checkhitceiling_
.extern checkhitsprite_
.extern checkhitwall_
.extern clearsoundlocks_
.extern clipinsidebox_
.extern clipmove_
.extern deletesprite_
.extern dist_
.extern dragpoint_
.extern execute_
.extern findotherplayer_
.extern findplayer_
.extern gameexit_
.extern getangle_
.extern getanimationgoal_
.extern getceilzofslope_
.extern getflorzofslope_
.extern getglobalz_
.extern getincangle_
.extern hitasprite_
.extern krand_
.extern ksqrt_
.extern ldist_
.extern loadtile_
.extern makeitfall_
.extern operateactivators_
.extern operateforcefields_
.extern operatemasterswitches_
.extern operatesectors_
.extern quickkill_
.extern rotatepoint_
.extern setpal_
.extern setsprite_
.extern shoot_
.extern sound_
.extern spawn_
.extern sprintf_
.extern spritesound_
.extern stopenvsound_
.extern stopsound_
.extern updatesector_
.equ slot_x, 0
.equ slot_m, 4
.equ slot_moving_sprite_cursor_1604, 8
.equ slot_shared_sector_or_sprite_index_1471_2433, 12
.equ slot_zchange, 20
.equ slot_passenger_sector_index_1369, 24
.equ slot_enemy_sprite_cursor_467, 28
.equ slot_enemy_sprite_cursor_713, 32
.equ slot_st, 36
.equ slot_passenger_player_cursor_1362, 40
.equ slot_moving_sprite_cursor_1730, 44
.equ slot_q, 16
.equ slot_player_state_cursor_100, 48
.equ slot_t, 52
.equ slot_sc, 56
.equ slot_k, 68
.equ slot_sh, 60
.equ slot_nexti, 64
.equ slot_i, 80
.equ slot_p, 76
.equ slot_nextj, 84
.equ slot_nextk, 72
.section _TEXT,"ax",@progbits
.p2align 4
_radius_status_record:
    .byte 0,1,6,10,12,2,5 # actual primary/recovered C status values
    .byte 0x98 # existing explicitly inferred record residue, no new owner
actors_slime_frames_initializer:
    .short 5,5,6,6,7,7,6,5 # actual primary automatic frames initializer
    {disp32} lea eax, dword ptr [eax]
    {load} mov edx, edx
updateinterpolations_:
    push ebx
    mov eax, dword ptr [_numinterpolations]
    dec eax
    test eax, eax
    jge actors_C_flow_45
    pop ebx
    ret
actors_C_flow_45:
    mov ebx, dword ptr [eax*4 + _curipos]
    dec eax
    mov ebx, dword ptr [ebx]
    mov dword ptr [eax*4 + _oldipos + 4], ebx
    test eax, eax
    jge actors_C_flow_45
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
setinterpolation_:
    push ebx
    push edx
    {store} mov ebx, eax
    mov edx, dword ptr [_numinterpolations]
    cmp edx, 0x800
    jge actors_C_flow_147
    lea eax, dword ptr [edx + -1]
    jmp actors_C_flow_113
actors_C_flow_103:
    cmp ebx, dword ptr [eax*4 + _curipos]
    je actors_C_flow_147
    dec eax
actors_C_flow_113:
    test eax, eax
    jge actors_C_flow_103
    mov eax, dword ptr [_numinterpolations]
    mov dword ptr [eax*4 + _curipos], ebx
    mov edx, dword ptr [ebx]
    lea ebx, dword ptr [eax + 1]
    mov dword ptr [eax*4 + _oldipos], edx
    mov dword ptr [_numinterpolations], ebx
actors_C_flow_147:
    pop edx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp8} lea edx, dword ptr [edx + eiz*1]
stopinterpolation_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    {store} mov esi, eax
    mov edx, dword ptr [_numinterpolations]
    dec edx
    cmp edx, dword ptr [_startofdynamicinterpolations]
    jge actors_C_flow_188
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
actors_C_flow_188:
    {disp32} lea eax, dword ptr [edx*4]
    cmp esi, dword ptr [eax + _curipos]
    jne actors_C_flow_255
    mov edi, dword ptr [_numinterpolations]
    dec edi
    mov ecx, dword ptr [edi*4 + _oldipos]
    mov ebx, dword ptr [edi*4 + _curipos]
    mov dword ptr [_numinterpolations], edi
    mov dword ptr [eax + _oldipos], ecx
    mov ecx, dword ptr [edi*4 + _bakipos]
    mov dword ptr [eax + _curipos], ebx
    mov dword ptr [eax + _bakipos], ecx
actors_C_flow_255:
    dec edx
    cmp edx, dword ptr [_startofdynamicinterpolations]
    jge actors_C_flow_188
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {load} mov eax, eax
dointerpolations_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    {store} mov edi, eax
    mov ecx, dword ptr [_numinterpolations]
    {store} xor esi, esi
    {store} xor ebx, ebx
    dec ecx
    test ecx, ecx
    jge actors_C_flow_302
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
actors_C_flow_302:
    mov edx, dword ptr [ecx*4 + _curipos]
    mov ebp, dword ptr [edx]
    mov dword ptr [ecx*4 + _bakipos], ebp
    {store} mov ebp, esi
    mov esi, dword ptr [edx]
    sub esi, dword ptr [ecx*4 + _oldipos]
    {store} cmp ebp, esi
    je actors_C_flow_345
    {store} mov ebx, edi
    {store} mov eax, esi
    imul ebx
    shrd eax, edx, 0x10
    {store} mov ebx, eax
actors_C_flow_345:
    mov edx, dword ptr [ecx*4 + _oldipos]
    mov eax, dword ptr [ecx*4 + _curipos]
    {store} add edx, ebx
    dec ecx
    mov dword ptr [eax], edx
    test ecx, ecx
    jge actors_C_flow_302
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp8} lea edx, dword ptr [edx]
restoreinterpolations_:
    push ebx
    push edx
    mov eax, dword ptr [_numinterpolations]
    dec eax
    test eax, eax
    jge actors_C_flow_399
    pop edx
    pop ebx
    ret
actors_C_flow_399:
    mov ebx, dword ptr [eax*4 + _curipos]
    mov edx, dword ptr [eax*4 + _bakipos]
    dec eax
    mov dword ptr [ebx], edx
    test eax, eax
    jge actors_C_flow_399
    pop edx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp8} lea edx, dword ptr [edx]
ceilingspace_:
    push edx
    movsx edx, ax
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    test byte ptr [eax + _sector + 12], 1
    je actors_C_flow_498
    cmp byte ptr [eax + _sector + 21], 0
    jne actors_C_flow_498
    mov ax, word ptr [eax + _sector + 16]
    .att_syntax prefix
    cmpw $actors_C_math_477,%ax
    .intel_syntax noprefix
    jb actors_C_flow_498
    jbe actors_C_flow_491
    .att_syntax prefix
    cmpw $actors_C_math_485,%ax
    .intel_syntax noprefix
    jne actors_C_flow_498
actors_C_flow_491:
    mov eax, 1
    pop edx
    ret
actors_C_flow_498:
    {store} xor eax, eax
    pop edx
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp8} lea edx, dword ptr [edx + eiz*1]
floorspace_:
    push edx
    movsx edx, ax
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    test byte ptr [eax + _sector + 14], 1
    je actors_C_flow_578
    cmp byte ptr [eax + _sector + 21], 0
    jne actors_C_flow_578
    mov ax, word ptr [eax + _sector + 24]
    .att_syntax prefix
    cmpw $actors_C_math_557,%ax
    .intel_syntax noprefix
    jb actors_C_flow_578
    jbe actors_C_flow_571
    .att_syntax prefix
    cmpw $actors_C_math_565,%ax
    .intel_syntax noprefix
    jne actors_C_flow_578
actors_C_flow_571:
    mov eax, 1
    pop edx
    ret
actors_C_flow_578:
    {store} xor eax, eax
    pop edx
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp8} lea edx, dword ptr [edx + eiz*1]
addammo_:
    push ecx
    {store} mov ecx, ebx
    movsx ebx, ax
    {disp32} lea eax, dword ptr [ebx*2]
    {store} add eax, edx
    mov dx, word ptr [eax + 652]
    {store} add edx, ecx
    {disp32} lea ebx, dword ptr [ebx*4]
    mov word ptr [eax + 652], dx
    movsx edx, dx
    cmp edx, dword ptr [ebx + _max_ammo_amount]
    jle actors_C_flow_655
    mov dx, word ptr [ebx + _max_ammo_amount]
    mov word ptr [eax + 652], dx
actors_C_flow_655:
    pop ecx
    ret
    {disp8} lea eax, dword ptr [eax]
actors_C_switch_660:
    .long actors_C_flow_877
actors_C_switch_view_664: # genuine interior switch-table entry
    .long actors_C_flow_846
actors_C_switch_view_668: # genuine interior switch-table entry
    .long actors_C_flow_832
actors_C_switch_view_672: # genuine interior switch-table entry
    .long actors_C_flow_860
actors_C_switch_view_676: # genuine interior switch-table entry
    .long actors_C_flow_860
actors_C_switch_view_680: # genuine interior switch-table entry
    .long actors_C_flow_877
actors_C_switch_view_684: # genuine interior switch-table entry
    .long actors_C_flow_860
actors_C_switch_view_688: # genuine interior switch-table entry
    .long actors_C_flow_860
actors_C_switch_view_692: # genuine interior switch-table entry
    .long actors_C_flow_877
actors_C_switch_view_696: # genuine interior switch-table entry
    .long actors_C_flow_860
actors_C_switch_view_700: # genuine interior switch-table entry
    .long actors_C_flow_877
addweapon_:
    push ebx
    push ecx
    movsx ebx, dx
    {store} add ebx, eax
    cmp byte ptr [ebx + 1333], 0
    jne actors_C_flow_727
    mov byte ptr [ebx + 1333], 1
actors_C_flow_727:
    mov ch, byte ptr [eax + 1330]
    mov word ptr [eax + 730], 0
    test ch, ch
    jne actors_C_flow_771
    mov word ptr [eax + 1286], 0xffff
    mov bx, word ptr [eax + 680]
    mov word ptr [eax + 682], bx
    jmp actors_C_flow_796
actors_C_flow_771:
    mov word ptr [eax + 1286], 0xa
    mov byte ptr [eax + 1330], 0
    mov word ptr [eax + 682], 0xffff
actors_C_flow_796:
    mov word ptr [eax + 712], 0
    mov word ptr [eax + 680], dx
    cmp dx, 0xa
    ja actors_C_flow_860
    and edx, 0xffff
    jmp dword ptr cs:[edx*4 + actors_C_switch_660]
actors_C_flow_832:
    movsx edx, word ptr [eax + 724]
    mov eax, 0xa9
    jmp actors_C_flow_872
actors_C_flow_846:
    movsx edx, word ptr [eax + 724]
    mov eax, 5
    jmp actors_C_flow_872
actors_C_flow_860:
    movsx edx, word ptr [eax + 724]
    mov eax, 0xdb
actors_C_flow_872:
    call spritesound_
actors_C_flow_877:
    pop ecx
    pop ebx
    ret
checkavailinven_:
    cmp word ptr [eax + 718], 0
    jle actors_C_flow_898
    mov byte ptr [eax + 1322], 1
    ret
actors_C_flow_898:
    cmp word ptr [eax + 1278], 0
    jle actors_C_flow_916
    mov byte ptr [eax + 1322], 2
    ret
actors_C_flow_916:
    cmp word ptr [eax + 688], 0
    jle actors_C_flow_934
    mov byte ptr [eax + 1322], 3
    ret
actors_C_flow_934:
    cmp word ptr [eax + 1276], 0
    jle actors_C_flow_952
    mov byte ptr [eax + 1322], 4
    ret
actors_C_flow_952:
    cmp word ptr [eax + 744], 0
    jle actors_C_flow_970
    mov byte ptr [eax + 1322], 5
    ret
actors_C_flow_970:
    cmp word ptr [eax + 1274], 0
    jle actors_C_flow_988
    mov byte ptr [eax + 1322], 6
    ret
actors_C_flow_988:
    cmp word ptr [eax + 1296], 0
    jle actors_C_flow_1006
    mov byte ptr [eax + 1322], 7
    ret
actors_C_flow_1006:
    mov byte ptr [eax + 1322], 0
    ret
    {load} mov eax, eax
actors_C_switch_1016:
    .long actors_C_flow_1201
actors_C_switch_view_1020: # genuine interior switch-table entry
    .long actors_C_flow_1201
actors_C_switch_view_1024: # genuine interior switch-table entry
    .long actors_C_flow_1201
actors_C_switch_view_1028: # genuine interior switch-table entry
    .long actors_C_flow_1201
actors_C_switch_view_1032: # genuine interior switch-table entry
    .long actors_C_flow_1201
actors_C_switch_view_1036: # genuine interior switch-table entry
    .long actors_C_flow_1208
actors_C_switch_view_1040: # genuine interior switch-table entry
    .long actors_C_flow_1201
actors_C_switch_view_1044: # genuine interior switch-table entry
    .long actors_C_flow_1201
actors_C_switch_view_1048: # genuine interior switch-table entry
    .long actors_C_flow_1208
actors_C_switch_view_1052: # genuine interior switch-table entry
    .long actors_C_flow_1201
actors_C_switch_view_1056: # genuine interior switch-table entry
    .long actors_C_flow_1208
actors_C_switch_view_1060: # genuine interior switch-table entry
    .long actors_C_flow_1271
actors_C_switch_view_1064: # genuine interior switch-table entry
    .long actors_C_flow_1271
actors_C_switch_view_1068: # genuine interior switch-table entry
    .long actors_C_flow_1271
actors_C_switch_view_1072: # genuine interior switch-table entry
    .long actors_C_flow_1229
actors_C_switch_view_1076: # genuine interior switch-table entry
    .long actors_C_flow_1229
actors_C_switch_view_1080: # genuine interior switch-table entry
    .long actors_C_flow_1271
actors_C_switch_view_1084: # genuine interior switch-table entry
    .long actors_C_flow_1271
actors_C_switch_view_1088: # genuine interior switch-table entry
    .long actors_C_flow_1229
actors_C_switch_view_1092: # genuine interior switch-table entry
    .long actors_C_flow_1271
actors_C_switch_view_1096: # genuine interior switch-table entry
    .long actors_C_flow_1412
actors_C_switch_view_1100: # genuine interior switch-table entry
    .long actors_C_flow_1412
actors_C_switch_view_1104: # genuine interior switch-table entry
    .long actors_C_flow_1412
actors_C_switch_view_1108: # genuine interior switch-table entry
    .long actors_C_flow_1444
actors_C_switch_view_1112: # genuine interior switch-table entry
    .long actors_C_flow_1444
actors_C_switch_view_1116: # genuine interior switch-table entry
    .long actors_C_flow_1412
actors_C_switch_view_1120: # genuine interior switch-table entry
    .long actors_C_flow_1412
actors_C_switch_view_1124: # genuine interior switch-table entry
    .long actors_C_flow_1444
actors_C_switch_view_1128: # genuine interior switch-table entry
    .long actors_C_flow_1412
    {disp8} lea eax, dword ptr [eax + eiz*1]
checkavailweapon_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    sub esp, 4
    {store} mov ebx, eax
    movsx edx, word ptr [eax + 680]
    cmp word ptr [ebx + edx*2 + 652], 0
    {disp32} jg actors_C_flow_1659
    mov ax, word ptr [eax + 680]
    {store} xor esi, esi
    {store} xor edi, edi
    mov dword ptr [esp], esi
    .att_syntax prefix
    cmpw $actors_C_math_1182,%ax
    .intel_syntax noprefix
    ja actors_C_flow_1213
    {store} xor edx, edx
    {store} mov dx, ax
    jmp dword ptr cs:[edx*4 + actors_C_switch_1016]
actors_C_flow_1201:
    mov edi, 1
    jmp actors_C_flow_1213
actors_C_flow_1208:
    mov esi, 1
actors_C_flow_1213:
    test di, di
    {disp32} je actors_C_flow_1509
    mov ax, word ptr [ebx + 680]
actors_C_flow_1229:
    inc eax
    .att_syntax prefix
    cmpw $actors_C_math_1230,%ax
    .intel_syntax noprefix
    jl actors_C_flow_1248
    mov ax, word ptr [ebx + 680]
    {disp32} jmp actors_C_flow_1444
actors_C_flow_1248:
    {store} mov edx, eax
    dec edx
    cmp dx, 8
    ja actors_C_flow_1229
    and edx, 0xffff
    jmp dword ptr cs:[edx*4 + actors_C_switch_view_1060]
actors_C_flow_1271:
    movsx edx, ax
    cmp byte ptr [edx + ebx + 1333], 0
    je actors_C_flow_1229
    cmp word ptr [ebx + edx*2 + 652], 0
    jle actors_C_flow_1229
    mov dword ptr [esp], eax
actors_C_flow_1298:
    mov esi, dword ptr [esp]
    test si, si
    {disp32} je actors_C_flow_1659
    mov word ptr [ebx + 730], 0
    mov ax, word ptr [ebx + 680]
    mov word ptr [ebx + 712], 0
    mov word ptr [ebx + 682], ax
    mov ch, byte ptr [ebx + 1330]
    mov word ptr [ebx + 680], si
    cmp ch, 1
    {disp32} jne actors_C_flow_1650
    mov byte ptr [ebx + 1330], 0
    mov word ptr [ebx + 1286], 0xa
    add esp, 4
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
actors_C_flow_1389:
    {store} mov edx, eax
    dec edx
    cmp dx, 8
    ja actors_C_flow_1444
    and edx, 0xffff
    jmp dword ptr cs:[edx*4 + actors_C_switch_view_1096]
actors_C_flow_1412:
    movsx edx, ax
    cmp byte ptr [edx + ebx + 1333], 0
    je actors_C_flow_1444
    cmp word ptr [ebx + edx*2 + 652], 0
    jle actors_C_flow_1444
    mov dword ptr [esp], eax
    {disp32} jmp actors_C_flow_1298
actors_C_flow_1444:
    dec eax
    test ax, ax
    jg actors_C_flow_1389
    cmp byte ptr [ebx + 1337], 0
    je actors_C_flow_1481
    cmp word ptr [ebx + 660], 0
    jle actors_C_flow_1481
    mov dword ptr [esp], 4
    {disp32} jmp actors_C_flow_1298
actors_C_flow_1481:
    test si, si
    je actors_C_flow_1504
actors_C_flow_1486:
    {store} mov eax, ebx
    {store} xor edx, edx
    call addweapon_
    add esp, 4
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
actors_C_flow_1504:
    mov esi, 1
actors_C_flow_1509:
    test si, si
    {disp32} je actors_C_flow_1298
    mov ax, word ptr [ebx + 680]
actors_C_flow_1525:
    dec eax
    test ax, ax
    jg actors_C_flow_1540
    mov ax, word ptr [ebx + 680]
    jmp actors_C_flow_1624
actors_C_flow_1540:
    .att_syntax prefix
    cmpw $actors_C_math_1540,%ax
    .intel_syntax noprefix
    jb actors_C_flow_1525
    jbe actors_C_flow_1554
    .att_syntax prefix
    cmpw $actors_C_math_1548,%ax
    .intel_syntax noprefix
    jne actors_C_flow_1525
actors_C_flow_1554:
    movsx edx, ax
    cmp byte ptr [edx + ebx + 1333], 0
    je actors_C_flow_1525
    cmp word ptr [ebx + edx*2 + 652], 0
    jle actors_C_flow_1525
    mov dword ptr [esp], eax
    {disp32} jmp actors_C_flow_1298
actors_C_flow_1586:
    .att_syntax prefix
    cmpw $actors_C_math_1586,%ax
    .intel_syntax noprefix
    jne actors_C_flow_1624
    movsx edx, ax
    cmp byte ptr [edx + ebx + 1333], 0
    je actors_C_flow_1624
    cmp word ptr [ebx + edx*2 + 652], 0
    jle actors_C_flow_1624
    mov dword ptr [esp], eax
    {disp32} jmp actors_C_flow_1298
actors_C_flow_1624:
    inc eax
    .att_syntax prefix
    cmpw $actors_C_math_1625,%ax
    .intel_syntax noprefix
    jl actors_C_flow_1586
    test di, di
    {disp32} jne actors_C_flow_1486
    mov edi, 1
    {disp32} jmp actors_C_flow_1213
actors_C_flow_1650:
    mov word ptr [ebx + 1286], 0xffff
actors_C_flow_1659:
    add esp, 4
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
ifsquished_:
    push ebx
    push ecx
    push esi
    push edi
    {store} mov ebx, eax
    {store} mov ecx, edx
    cwde
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 14], 0x57d
    jne actors_C_flow_1716
    cmp byte ptr [_ud + 8], 1
    {disp32} je actors_C_flow_1948
actors_C_flow_1716:
    movsx esi, bx
    imul esi, esi, 0x2c
    movsx edx, word ptr [esi + _sprite + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    add eax, OFFSET FLAT:_sector
    mov edx, dword ptr [eax + 8]
    sub edx, dword ptr [eax + 4]
    cmp byte ptr [esi + _sprite + 17], 1
    jne actors_C_flow_1790
    cmp edx, 0x2000
    jge actors_C_flow_1786
    movsx eax, word ptr [eax + 34]
    test ah, 0x80
    jne actors_C_flow_1786
    mov al, 1
    jmp actors_C_flow_1813
actors_C_flow_1786:
    xor al, al
    jmp actors_C_flow_1813
actors_C_flow_1790:
    cmp edx, 0x600
    jge actors_C_flow_1811
    movsx eax, word ptr [eax + 34]
    test ah, 0x80
    jne actors_C_flow_1811
    mov al, 1
    jmp actors_C_flow_1813
actors_C_flow_1811:
    xor al, al
actors_C_flow_1813:
    test al, al
    {disp32} je actors_C_flow_1948
    movsx eax, cx
    imul eax, eax, 0x552
    mov edx, OFFSET FLAT:_ps
    {store} add edx, eax
    mov eax, 0xa
    call FTA_
    movsx edx, bx
    imul edx, edx, 0x2c
    mov eax, OFFSET FLAT:_sprite
    {store} add eax, edx
    call badguy_
    test ax, ax
    je actors_C_flow_1879
    {store} xor ecx, ecx
    mov word ptr [edx + _sprite + 32], cx
actors_C_flow_1879:
    movsx edx, bx
    imul eax, edx, 0x2c
    cmp byte ptr [eax + _sprite + 17], 1
    jne actors_C_flow_1938
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov esi, 0xa23
    mov edi, 1
    mov word ptr [eax + _hittype + 1], si
    mov word ptr [eax + _hittype + 5], di
    jmp actors_C_flow_1948
actors_C_flow_1938:
    mov eax, 1
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
actors_C_flow_1948:
    {store} xor eax, eax
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
    nop
hitradius_:
    push esi
    push edi
    push ebp
    sub esp, 0x40
    mov dword ptr [esp + 52], eax
    mov dword ptr [esp + 36], edx
    mov dword ptr [esp + 24], ebx
    mov dword ptr [esp + 40], ecx
    cwde
    imul eax, eax, 0x2c
    {store} mov edi, esp
    mov ebp, OFFSET FLAT:_sprite
    mov esi, OFFSET FLAT:_radius_status_record
    {store} add ebp, eax
    movsd dword ptr es:[edi], dword ptr [esi]
    movsw word ptr es:[edi], word ptr [esi]
    movsb byte ptr es:[edi], byte ptr [esi]
    mov dx, word ptr [ebp + 14]
    mov edi, OFFSET FLAT:_tempbuf
    cmp dx, 0xa2d
    jne actors_C_flow_2038
    cmp byte ptr [ebp + 20], 0xb
    {disp32} jb actors_C_flow_2673
actors_C_flow_2038:
    cmp word ptr [ebp + 14], 0x66e
    {disp32} je actors_C_flow_2673
    mov ebx, 1
    {store} xor edx, edx
    mov ax, word ptr [ebp + 24]
    mov dword ptr [esp + 8], edx
    mov dword ptr [esp + 28], ebx
    mov word ptr [edi], ax
actors_C_flow_2072:
    mov eax, dword ptr [esp + 8]
    lea ecx, dword ptr [eax + 1]
    movsx esi, word ptr [edi + eax*2]
    {disp32} lea eax, dword ptr [esi*4]
    lea edx, dword ptr [esi + eax]
    {disp32} lea edx, dword ptr [edx*8]
    mov ebx, dword ptr [ebp + 8]
    mov eax, dword ptr [edx + _sector + 4]
    mov dword ptr [esp + 8], ecx
    {store} sub eax, ebx
    mov ecx, dword ptr [esp + 36]
    sar eax, 8
    {store} cmp eax, ecx
    {disp32} jge actors_C_flow_2318
    movsx eax, word ptr [edx + _sector]
    shl eax, 5
    {disp8} mov ebx, dword ptr [ebp]
    mov eax, dword ptr [eax + _wall]
    {store} sub eax, ebx
    test eax, eax
    jns actors_C_flow_2157
    neg eax
actors_C_flow_2157:
    {store} mov ebx, eax
    movsx eax, word ptr [edx + _sector]
    shl eax, 5
    mov ecx, dword ptr [ebp + 4]
    mov eax, dword ptr [eax + _wall + 4]
    {store} sub eax, ecx
    test eax, eax
    jns actors_C_flow_2186
    neg eax
actors_C_flow_2186:
    {store} add ebx, eax
    mov dword ptr [esp + 32], ebx
    {store} mov eax, ebx
    cmp eax, dword ptr [esp + 36]
    jl actors_C_flow_2310
    movsx eax, word ptr [edx + _sector]
    shl eax, 5
    movsx eax, word ptr [eax + _wall + 8]
    shl eax, 5
    movsx eax, word ptr [eax + _wall + 8]
    shl eax, 5
    {disp8} mov ecx, dword ptr [ebp]
    mov eax, dword ptr [eax + _wall]
    {store} sub eax, ecx
    test eax, eax
    jns actors_C_flow_2247
    neg eax
actors_C_flow_2247:
    {store} mov ebx, eax
    movsx eax, word ptr [edx + _sector]
    shl eax, 5
    movsx eax, word ptr [eax + _wall + 8]
    shl eax, 5
    movsx eax, word ptr [eax + _wall + 8]
    shl eax, 5
    mov edx, dword ptr [ebp + 4]
    mov eax, dword ptr [eax + _wall + 4]
    {store} sub eax, edx
    test eax, eax
    jns actors_C_flow_2296
    neg eax
actors_C_flow_2296:
    {store} add ebx, eax
    mov dword ptr [esp + 32], ebx
    {store} mov eax, ebx
    cmp eax, dword ptr [esp + 36]
    jge actors_C_flow_2318
actors_C_flow_2310:
    movsx eax, si
    call checkhitceiling_
actors_C_flow_2318:
    {disp32} lea edx, dword ptr [esi*4]
    {store} add edx, esi
    {disp32} lea edx, dword ptr [edx*8]
    movsx eax, word ptr [edx + _sector]
    movsx edx, word ptr [edx + _sector + 2]
    lea ebx, dword ptr [eax + edx]
    mov edx, OFFSET FLAT:_wall
    mov dword ptr [esp + 48], eax
    shl eax, 5
    {store} add edx, eax
    mov dword ptr [esp + 12], ebx
    mov dword ptr [esp + 44], edx
    {disp32} jmp actors_C_flow_2644
actors_C_flow_2378:
    mov eax, dword ptr [esp + 44]
    {disp8} mov edx, dword ptr [ebp]
    mov eax, dword ptr [eax]
    {store} sub eax, edx
    test eax, eax
    jns actors_C_flow_2395
    neg eax
actors_C_flow_2395:
    {store} mov edx, eax
    mov eax, dword ptr [esp + 44]
    mov ebx, dword ptr [ebp + 4]
    mov eax, dword ptr [eax + 4]
    {store} sub eax, ebx
    mov ecx, dword ptr [esp + 36]
    test eax, eax
    jns actors_C_flow_2419
    neg eax
actors_C_flow_2419:
    {store} add eax, edx
    {store} cmp eax, ecx
    {disp32} jge actors_C_flow_2635
    mov edx, dword ptr [esp + 44]
    movsx edx, word ptr [edx + 12]
    test edx, edx
    jl actors_C_flow_2479
    mov esi, dword ptr [esp + 28]
    jmp actors_C_flow_2455
actors_C_flow_2447:
    movsx eax, word ptr [edi + esi*2]
    {store} cmp eax, edx
    je actors_C_flow_2460
actors_C_flow_2455:
    dec esi
    test esi, esi
    jge actors_C_flow_2447
actors_C_flow_2460:
    test esi, esi
    jge actors_C_flow_2479
    mov eax, dword ptr [esp + 28]
    lea esi, dword ptr [eax + 1]
    mov word ptr [edi + eax*2], dx
    mov dword ptr [esp + 28], esi
actors_C_flow_2479:
    mov edx, dword ptr [esp + 44]
    mov esi, dword ptr [esp + 44]
    mov eax, dword ptr [esp + 44]
    movsx edx, word ptr [edx + 8]
    {disp8} mov ecx, dword ptr [ebp]
    shl edx, 5
    mov esi, dword ptr [esi]
    mov ebx, dword ptr [edx + _wall]
    mov eax, dword ptr [eax + 4]
    {store} add esi, ebx
    mov ebx, dword ptr [edx + _wall + 4]
    sar esi, 1
    {store} add eax, ebx
    {store} add esi, ecx
    sar eax, 1
    add eax, dword ptr [ebp + 4]
    lea ebx, dword ptr [esp + 56]
    sar eax, 1
    sar esi, 1
    mov dword ptr [esp + 20], eax
    {store} mov edx, eax
    {store} mov eax, esi
    call updatesector_
    mov ecx, dword ptr [esp + 56]
    test cx, cx
    jl actors_C_flow_2635
    movsx eax, word ptr [ebp + 24]
    push eax
    mov eax, dword ptr [ebp + 8]
    mov edx, dword ptr [ebp + 4]
    push eax
    movsx ecx, cx
    push edx
    {disp8} mov ebx, dword ptr [ebp]
    mov edx, dword ptr [esp + 32]
    push ebx
    {store} mov ebx, eax
    {store} mov eax, esi
    call cansee_
    test eax, eax
    je actors_C_flow_2635
    mov ebx, dword ptr [esp + 44]
    movsx eax, word ptr [ebp + 14]
    movsx edx, word ptr [esp + 48]
    push eax
    mov ecx, dword ptr [ebp + 8]
    mov ebx, dword ptr [ebx]
    push ecx
    mov ecx, dword ptr [esp + 52]
    movsx eax, word ptr [esp + 60]
    mov ecx, dword ptr [ecx + 4]
    call checkhitwall_
actors_C_flow_2635:
    inc dword ptr [esp + 48]
    add dword ptr [esp + 44], 0x20
actors_C_flow_2644:
    movsx eax, word ptr [esp + 48]
    cmp eax, dword ptr [esp + 12]
    {disp32} jl actors_C_flow_2378
    mov eax, dword ptr [esp + 8]
    cmp eax, dword ptr [esp + 28]
    {disp32} jl actors_C_flow_2072
actors_C_flow_2673:
    call krand_
    and eax, 0x1fff
    {store} xor edi, edi
    sub eax, 0x1000
    mov dword ptr [esp + 48], edi
    mov dword ptr [esp + 16], eax
    {disp32} jmp actors_C_flow_4097
actors_C_flow_2703:
    cwde
    movzx edi, byte ptr [esp + eax]
    mov di, word ptr [edi*2 + _headspritestat]
actors_C_flow_2716:
    test di, di
    {disp32} jl actors_C_flow_4093
    movsx esi, di
    mov ax, word ptr [esi*2 + _nextspritestat]
    imul esi, esi, 0x2c
    mov ebx, dword ptr [esp + 48]
    mov dword ptr [esp + 60], eax
    add esi, OFFSET FLAT:_sprite
    test bx, bx
    je actors_C_flow_2802
    cmp bx, 5
    jge actors_C_flow_2802
    mov ax, word ptr [esi + 14]
    .att_syntax prefix
    cmpw $actors_C_math_2768,%ax
    .intel_syntax noprefix
    je actors_C_flow_2802
    .att_syntax prefix
    cmpw $actors_C_math_2774,%ax
    .intel_syntax noprefix
    je actors_C_flow_2802
    .att_syntax prefix
    cmpw $actors_C_math_2780,%ax
    .intel_syntax noprefix
    je actors_C_flow_2802
    .att_syntax prefix
    cmpw $actors_C_math_2786,%ax
    .intel_syntax noprefix
    je actors_C_flow_2802
    .att_syntax prefix
    cmpw $actors_C_math_2792,%ax
    .intel_syntax noprefix
    {disp32} jne actors_C_flow_2927
actors_C_flow_2802:
    cmp word ptr [ebp + 14], 0x66e
    jne actors_C_flow_2822
    test word ptr [esi + 12], 0x101
    {disp32} je actors_C_flow_4084
actors_C_flow_2822:
    {store} mov edx, esi
    {store} mov eax, ebp
    mov ecx, dword ptr [esp + 36]
    call dist_
    {store} cmp eax, ecx
    {disp32} jge actors_C_flow_4084
    {store} mov eax, esi
    call badguy_
    test ax, ax
    je actors_C_flow_2905
    movsx eax, word ptr [ebp + 24]
    mov edx, dword ptr [esp + 16]
    push eax
    mov eax, dword ptr [ebp + 8]
    {store} add eax, edx
    push eax
    mov ebx, dword ptr [ebp + 4]
    push ebx
    {disp8} mov ecx, dword ptr [ebp]
    mov eax, dword ptr [esi]
    push ecx
    mov ebx, dword ptr [esi + 8]
    movsx ecx, word ptr [esi + 24]
    {store} add ebx, edx
    mov edx, dword ptr [esi + 4]
    call cansee_
    test eax, eax
    {disp32} je actors_C_flow_4084
actors_C_flow_2905:
    movsx edx, word ptr [esp + 52]
    movsx eax, di
    call checkhitsprite_
    mov edi, dword ptr [esp + 60]
    {disp32} jmp actors_C_flow_2716
actors_C_flow_2927:
    cmp word ptr [esi + 42], 0
    {disp32} jl actors_C_flow_4084
    {store} cmp esi, ebp
    {disp32} je actors_C_flow_4084
    .att_syntax prefix
    cmpw $actors_C_math_2946,%ax
    .intel_syntax noprefix
    je actors_C_flow_3001
    {store} mov eax, esi
    call badguy_
    test ax, ax
    jne actors_C_flow_3001
    mov cx, word ptr [esi + 14]
    cmp cx, 0x386
    je actors_C_flow_3001
    cmp cx, 0x385
    je actors_C_flow_3001
    test word ptr [esi + 12], 0x101
    jne actors_C_flow_3001
    cmp cx, 0x5ee
    {disp32} jne actors_C_flow_4084
actors_C_flow_3001:
    cmp word ptr [ebp + 14], 0x66e
    jne actors_C_flow_3038
    cmp word ptr [esi + 14], 0x60e
    je actors_C_flow_3038
    cmp di, word ptr [ebp + 30]
    je actors_C_flow_3029
    cmp byte ptr [esi + 20], 0x18
    jae actors_C_flow_3038
actors_C_flow_3029:
    mov edi, dword ptr [esp + 60]
    {disp32} jmp actors_C_flow_2716
actors_C_flow_3038:
    cmp word ptr [ebp + 14], 0x672
    jne actors_C_flow_3061
    cmp di, word ptr [ebp + 30]
    jne actors_C_flow_3061
    mov edi, dword ptr [esp + 60]
    {disp32} jmp actors_C_flow_2716
actors_C_flow_3061:
    cmp word ptr [esi + 14], 0x57d
    jne actors_C_flow_3076
    sub dword ptr [esi + 8], 0x2600
actors_C_flow_3076:
    {store} mov edx, esi
    {store} mov eax, ebp
    call dist_
    mov dx, word ptr [esi + 14]
    mov dword ptr [esp + 32], eax
    cmp dx, 0x57d
    jne actors_C_flow_3107
    add dword ptr [esi + 8], 0x2600
actors_C_flow_3107:
    mov eax, dword ptr [esp + 32]
    cmp eax, dword ptr [esp + 36]
    {disp32} jge actors_C_flow_4084
    movsx eax, word ptr [ebp + 24]
    push eax
    mov eax, dword ptr [ebp + 8]
    sub eax, 0xc00
    mov ecx, dword ptr [ebp + 4]
    push eax
    mov ebx, dword ptr [esi + 8]
    mov edx, dword ptr [esi + 4]
    push ecx
    {disp8} mov eax, dword ptr [ebp]
    sub ebx, 0x800
    push eax
    movsx ecx, word ptr [esi + 24]
    mov eax, dword ptr [esi]
    call cansee_
    test eax, eax
    {disp32} je actors_C_flow_4084
    mov eax, dword ptr [esi + 4]
    sub eax, dword ptr [ebp + 4]
    {disp8} mov ebx, dword ptr [ebp]
    {store} mov edx, eax
    mov eax, dword ptr [esi]
    {store} sub eax, ebx
    call getangle_
    movsx edx, di
    {store} mov ebx, eax
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov word ptr [eax + _hittype + 3], bx
    mov bx, word ptr [ebp + 14]
    cmp bx, 0xa2d
    jne actors_C_flow_3251
    cmp word ptr [esi + 42], 0
    jle actors_C_flow_3251
    mov word ptr [eax + _hittype + 1], bx
    jmp actors_C_flow_3321
actors_C_flow_3251:
    cmp word ptr [ebp + 14], 0x66e
    jne actors_C_flow_3291
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov word ptr [eax + _hittype + 1], 0x66e
    jmp actors_C_flow_3321
actors_C_flow_3291:
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov word ptr [eax + _hittype + 1], 0x686
actors_C_flow_3321:
    cmp word ptr [ebp + 14], 0x66e
    {disp32} je actors_C_flow_3769
    mov eax, dword ptr [esp + 36]
    {store} mov edx, eax
    mov ebx, 3
    sar edx, 0x1f
    idiv ebx
    mov ecx, dword ptr [esp + 32]
    {store} cmp eax, ecx
    jle actors_C_flow_3399
    mov eax, dword ptr [esp + 84]
    cmp eax, dword ptr [esp + 80]
    jne actors_C_flow_3371
    inc dword ptr [esp + 84]
actors_C_flow_3371:
    mov ebx, dword ptr [esp + 84]
    mov edx, dword ptr [esp + 80]
    call krand_
    {store} sub ebx, edx
    {store} mov edx, eax
    sar edx, 0x1f
    idiv ebx
    add edx, dword ptr [esp + 80]
    jmp actors_C_flow_3504
actors_C_flow_3399:
    mov edx, dword ptr [esp + 36]
    {store} add edx, edx
    {store} mov eax, edx
    sar edx, 0x1f
    idiv ebx
    {store} cmp eax, ecx
    jle actors_C_flow_3458
    mov eax, dword ptr [esp + 80]
    cmp eax, dword ptr [esp + 40]
    jne actors_C_flow_3430
    inc dword ptr [esp + 80]
actors_C_flow_3430:
    mov ebx, dword ptr [esp + 80]
    mov edx, dword ptr [esp + 40]
    call krand_
    {store} sub ebx, edx
    {store} mov edx, eax
    sar edx, 0x1f
    idiv ebx
    add edx, dword ptr [esp + 40]
    jmp actors_C_flow_3504
actors_C_flow_3458:
    cmp ecx, dword ptr [esp + 36]
    jge actors_C_flow_3534
    mov eax, dword ptr [esp + 40]
    cmp eax, dword ptr [esp + 24]
    jne actors_C_flow_3478
    inc dword ptr [esp + 40]
actors_C_flow_3478:
    mov ebx, dword ptr [esp + 40]
    mov edx, dword ptr [esp + 24]
    call krand_
    {store} sub ebx, edx
    {store} mov edx, eax
    sar edx, 0x1f
    idiv ebx
    add edx, dword ptr [esp + 24]
actors_C_flow_3504:
    {store} mov ebx, edx
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov word ptr [eax + _hittype + 5], bx
actors_C_flow_3534:
    movsx eax, di
    imul eax, eax, 0x2c
    mov cx, word ptr [eax + _sprite + 14]
    cmp cx, 0x938
    je actors_C_flow_3633
    cmp cx, 0x7a8
    je actors_C_flow_3633
    cmp cx, 0xa46
    je actors_C_flow_3633
    cmp cx, 0xa96
    je actors_C_flow_3633
    cmp cx, 0xac8
    je actors_C_flow_3633
    cmp word ptr [eax + _sprite + 32], 0
    jge actors_C_flow_3601
    {store} xor ecx, ecx
    mov word ptr [eax + _sprite + 32], cx
actors_C_flow_3601:
    movsx eax, di
    imul eax, eax, 0x2c
    mov dx, word ptr [eax + _sprite + 42]
    mov bx, word ptr [eax + _sprite + 32]
    shl edx, 2
    {store} add ebx, edx
    mov word ptr [eax + _sprite + 32], bx
actors_C_flow_3633:
    mov cx, word ptr [esi + 14]
    cmp cx, 0x50e
    {disp32} je actors_C_flow_3754
    cmp cx, 0x520
    {disp32} je actors_C_flow_3754
    cmp cx, 0x525
    {disp32} je actors_C_flow_3754
    cmp cx, 0x529
    je actors_C_flow_3754
    cmp cx, 0x52d
    je actors_C_flow_3754
    cmp cx, 0x52b
    je actors_C_flow_3754
    cmp cx, 0x536
    je actors_C_flow_3754
    cmp cx, 0x573
    je actors_C_flow_3754
    cmp cx, 0x538
    je actors_C_flow_3754
    cmp cx, 0xd7a
    je actors_C_flow_3754
    cmp cx, 0x2f1
    je actors_C_flow_3754
    cmp cx, 0x365
    je actors_C_flow_3754
    cmp cx, 0x549
    je actors_C_flow_3754
    cmp cx, 0x386
    je actors_C_flow_3754
    cmp cx, 0x385
    jne actors_C_flow_3806
actors_C_flow_3754:
    movsx edx, word ptr [esp + 52]
    movsx eax, di
    call checkhitsprite_
    jmp actors_C_flow_3806
actors_C_flow_3769:
    cmp word ptr [ebp + 42], 0
    jne actors_C_flow_3806
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    {store} xor ebx, ebx
    mov word ptr [eax + _hittype + 5], bx
actors_C_flow_3806:
    movsx eax, di
    imul eax, eax, 0x2c
    mov bx, word ptr [eax + _sprite + 14]
    cmp bx, 0x686
    {disp32} je actors_C_flow_4084
    mov cx, word ptr [ebp + 30]
    test cx, cx
    {disp32} jl actors_C_flow_4084
    movsx edx, cx
    imul edx, edx, 0x2c
    cmp word ptr [edx + _sprite + 26], 0x400
    {disp32} jge actors_C_flow_4084
    cmp bx, 0x57d
    {disp32} jne actors_C_flow_4050
    mov ax, word ptr [eax + _sprite + 34]
    cwde
    imul eax, eax, 0x552
    cmp word ptr [eax + _ps + 690], 0
    {disp32} jl actors_C_flow_4050
    mov ecx, 0xffffffff
    mov edx, dword ptr [eax + _ps + 568]
    mov word ptr [eax + _ps + 690], cx
    mov dword ptr [eax + _ps + 532], edx
    mov edx, dword ptr [eax + _ps + 572]
    mov dword ptr [eax + _ps + 536], edx
    mov edx, dword ptr [eax + _ps + 576]
    mov dword ptr [eax + _ps + 540], edx
    mov esi, OFFSET FLAT:_ps
    mov dx, word ptr [eax + _ps + 642]
    {store} add esi, eax
    mov word ptr [eax + _ps + 640], dx
    lea ebx, dword ptr [esi + 646]
    mov edx, dword ptr [eax + _ps + 536]
    mov eax, dword ptr [eax + _ps + 532]
    call updatesector_
    {store} mov eax, esi
    call setpal_
    mov ax, word ptr [_headspritestat + 2]
actors_C_flow_4008:
    test ax, ax
    jl actors_C_flow_4050
    movsx esi, ax
    imul esi, esi, 0x2c
    cmp word ptr [esi + _sprite + 14], 0x26d
    jne actors_C_flow_4039
    {store} xor ecx, ecx
    mov word ptr [esi + _sprite + 34], cx
actors_C_flow_4039:
    cwde
    mov ax, word ptr [eax*2 + _nextspritestat]
    jmp actors_C_flow_4008
actors_C_flow_4050:
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    {store} mov edx, eax
    mov ax, word ptr [ebp + 30]
    mov word ptr [edx + _hittype + 7], ax
actors_C_flow_4084:
    mov edi, dword ptr [esp + 60]
    {disp32} jmp actors_C_flow_2716
actors_C_flow_4093:
    inc dword ptr [esp + 48]
actors_C_flow_4097:
    mov eax, dword ptr [esp + 48]
    .att_syntax prefix
    cmpw $actors_C_math_4101,%ax
    .intel_syntax noprefix
    {disp32} jl actors_C_flow_2703
    add esp, 0x40
    pop ebp
    pop edi
    pop esi
    ret 8
    {disp32} lea eax, dword ptr [eax]
    {load} mov edx, edx
movesprite_:
    push esi
    push edi
    push ebp
    sub esp, 0x20
    {store} mov esi, eax
    {store} mov ebp, edx
    mov dword ptr [esp + 12], ecx
    movsx edx, ax
    imul edx, edx, 0x2c
    mov eax, OFFSET FLAT:_sprite
    {store} add eax, edx
    call badguy_
    mov cx, word ptr [edx + _sprite + 26]
    mov byte ptr [esp + 28], al
    cmp cx, 5
    je actors_C_flow_4194
    test al, al
    {disp32} je actors_C_flow_4312
    cmp byte ptr [edx + _sprite + 20], 4
    jae actors_C_flow_4312
actors_C_flow_4194:
    movsx edi, si
    imul eax, edi, 0x2c
    {disp32} lea ebp, dword ptr [ebp*4]
    {disp32} lea ebx, dword ptr [ebx*4]
    sar ebp, 2
    mov edx, dword ptr [eax + _sprite]
    sar ebx, 2
    {store} add edx, ebp
    mov ecx, dword ptr [eax + _sprite + 4]
    mov dword ptr [eax + _sprite], edx
    mov edx, dword ptr [esp + 12]
    mov esi, dword ptr [eax + _sprite + 8]
    {disp32} lea edx, dword ptr [edx*4]
    {store} add ecx, ebx
    sar edx, 2
    mov dword ptr [eax + _sprite + 4], ecx
    {store} add esi, edx
    mov ch, byte ptr [esp + 28]
    mov dword ptr [eax + _sprite + 8], esi
    test ch, ch
    je actors_C_flow_4305
    {store} mov ecx, esi
    mov ebx, dword ptr [eax + _sprite + 4]
    mov edx, dword ptr [eax + _sprite]
    {store} mov eax, edi
    call setsprite_
actors_C_flow_4305:
    {store} xor eax, eax
    {disp32} jmp actors_C_flow_5288
actors_C_flow_4312:
    movsx edx, si
    imul edx, edx, 0x2c
    mov ax, word ptr [edx + _sprite + 24]
    mov dword ptr [esp + 24], eax
    mov eax, dword ptr [edx + _sprite + 8]
    mov dword ptr [esp], eax
    movsx eax, word ptr [edx + _sprite + 14]
    movsx ecx, word ptr [eax*2 + _tilesizy]
    {store} xor eax, eax
    mov al, byte ptr [edx + _sprite + 21]
    imul eax, ecx
    mov ecx, dword ptr [esp]
    {store} add eax, eax
    {store} sub ecx, eax
    {store} mov eax, ebp
    shl eax, 0xd
    mov dword ptr [esp + 20], eax
    {store} mov eax, ebx
    shl eax, 0xd
    mov dword ptr [esp + 4], eax
    mov eax, OFFSET FLAT:_sprite
    mov dword ptr [esp], ecx
    {store} add eax, edx
    mov cl, byte ptr [esp + 28]
    lea edi, dword ptr [eax + 4]
    test cl, cl
    {disp32} je actors_C_flow_5049
    mov ecx, dword ptr [edx + _sprite]
    mov dword ptr [esp + 16], ecx
    mov ecx, dword ptr [edx + _sprite + 4]
    mov dword ptr [esp + 8], ecx
    cmp byte ptr [edx + _sprite + 20], 0x3c
    jbe actors_C_flow_4485
    mov ebp, dword ptr [esp + 48]
    push ebp
    push 0x400
    push 0x400
    push 0x400
    mov edx, dword ptr [esp + 20]
    push edx
    mov ebx, dword ptr [esp + 40]
    lea ecx, dword ptr [esp + 44]
    push ebx
    {store} mov edx, edi
    lea ebx, dword ptr [esp + 24]
    jmp actors_C_flow_4555
actors_C_flow_4485:
    cmp word ptr [edx + _sprite + 14], 0x848
    jne actors_C_flow_4503
    mov eax, 0x124
    jmp actors_C_flow_4508
actors_C_flow_4503:
    mov eax, 0xc0
actors_C_flow_4508:
    mov ecx, dword ptr [esp + 48]
    push ecx
    push 0x400
    push 0x400
    cwde
    push eax
    movsx eax, si
    imul eax, eax, 0x2c
    shl ebx, 0xd
    push ebx
    shl ebp, 0xd
    lea ecx, dword ptr [esp + 44]
    push ebp
    add eax, OFFSET FLAT:_sprite
    lea ebx, dword ptr [esp + 24]
    lea edx, dword ptr [eax + 4]
actors_C_flow_4555:
    call clipmove_
    {store} mov ebx, eax
    mov edi, dword ptr [esp + 24]
    test di, di
    {disp32} jl actors_C_flow_4804
    {disp32} jl actors_C_flow_4988
    movsx edx, si
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov dx, word ptr [eax + _hittype + 13]
    test dx, dx
    jl actors_C_flow_4623
    {store} cmp dx, di
    {disp32} jne actors_C_flow_4804
actors_C_flow_4623:
    movsx eax, si
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 14], 0xa96
    jne actors_C_flow_4678
    cmp byte ptr [eax + _sprite + 17], 0
    jne actors_C_flow_4678
    movsx edx, word ptr [esp + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    cmp word ptr [eax*8 + _sector + 34], 3
    {disp32} jne actors_C_flow_4804
actors_C_flow_4678:
    movsx eax, si
    imul eax, eax, 0x2c
    mov cx, word ptr [eax + _sprite + 14]
    cmp cx, 0xa46
    je actors_C_flow_4705
    cmp cx, 0xa96
    jne actors_C_flow_4730
actors_C_flow_4705:
    movsx edx, word ptr [esp + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    cmp word ptr [eax*8 + _sector + 34], 1
    je actors_C_flow_4804
actors_C_flow_4730:
    movsx edx, word ptr [esp + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    cmp word ptr [eax*8 + _sector + 34], 1
    {disp32} jne actors_C_flow_4988
    movsx eax, si
    imul eax, eax, 0x2c
    mov di, word ptr [eax + _sprite + 14]
    cmp di, 0x848
    je actors_C_flow_4804
    cmp di, 0x690
    {disp32} jne actors_C_flow_4988
    cmp word ptr [eax + _sprite + 36], 0
    {disp32} jne actors_C_flow_4988
actors_C_flow_4804:
    movsx edx, si
    imul edx, edx, 0x2c
    mov eax, dword ptr [esp + 16]
    mov dword ptr [edx + _sprite], eax
    mov eax, dword ptr [esp + 8]
    movsx ebx, word ptr [esp + 24]
    mov dword ptr [edx + _sprite + 4], eax
    {disp32} lea eax, dword ptr [ebx*4]
    {store} add eax, ebx
    cmp word ptr [eax*8 + _sector + 34], 1
    jne actors_C_flow_4866
    cmp word ptr [edx + _sprite + 14], 0x848
    je actors_C_flow_4915
actors_C_flow_4866:
    movsx ebx, si
    {disp32} lea eax, dword ptr [ebx*8]
    {store} add eax, ebx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ebx
    mov eax, dword ptr [eax + _hittype + 47]
    and eax, 3
    cmp eax, 1
    jne actors_C_flow_4930
    imul edx, ebx, 0x2c
    cmp word ptr [edx + _sprite + 14], 0x780
    je actors_C_flow_4930
actors_C_flow_4915:
    call krand_
    and ah, 7
    mov word ptr [edx + _sprite + 28], ax
actors_C_flow_4930:
    movsx eax, si
    imul ecx, eax, 0x2c
    mov ebx, dword ptr [esp + 8]
    mov edx, dword ptr [esp + 16]
    mov ecx, dword ptr [ecx + _sprite + 8]
    call setsprite_
    cmp word ptr [esp + 24], 0
    jge actors_C_flow_4969
    {store} xor esi, esi
    mov dword ptr [esp + 24], esi
actors_C_flow_4969:
    movsx eax, word ptr [esp + 24]
    .att_syntax prefix
    addl $actors_C_math_4974,%eax
    .intel_syntax noprefix
    add esp, 0x20
    pop ebp
    pop edi
    pop esi
    ret 4
actors_C_flow_4988:
    movsx eax, bx
    and eax, 0xc000
    .att_syntax prefix
    cmpl $actors_C_math_4996,%eax
    .intel_syntax noprefix
    {disp32} jl actors_C_flow_5145
    movsx edi, si
    {disp32} lea eax, dword ptr [edi*8]
    {store} add eax, edi
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edi
    cmp byte ptr [eax + _hittype], 0
    jne actors_C_flow_5145
    imul edi, edi, 0x2c
    add byte ptr [edi + _sprite + 29], 3
    jmp actors_C_flow_5145
actors_C_flow_5049:
    cmp word ptr [edx + _sprite + 26], 4
    jne actors_C_flow_5098
    mov ecx, dword ptr [esp + 48]
    push ecx
    push 0x400
    push 0x400
    push 8
    mov ebp, dword ptr [esp + 20]
    push ebp
    mov edx, dword ptr [esp + 40]
    lea ebx, dword ptr [esp + 20]
    push edx
    lea ecx, dword ptr [esp + 48]
    {store} mov edx, edi
    jmp actors_C_flow_5138
actors_C_flow_5098:
    mov ebp, dword ptr [esp + 48]
    push ebp
    push 0x400
    push 0x400
    push 0x80
    mov edx, dword ptr [esp + 20]
    push edx
    mov ebx, dword ptr [esp + 40]
    lea ecx, dword ptr [esp + 44]
    push ebx
    {store} mov edx, edi
    lea ebx, dword ptr [esp + 24]
actors_C_flow_5138:
    call clipmove_
    {store} mov ebx, eax
actors_C_flow_5145:
    cmp word ptr [esp + 24], 0
    jl actors_C_flow_5182
    movsx edi, si
    imul edx, edi, 0x2c
    mov eax, dword ptr [esp + 24]
    cmp ax, word ptr [edx + _sprite + 24]
    je actors_C_flow_5182
    movsx edx, ax
    {store} mov eax, edi
    call changespritesect_
actors_C_flow_5182:
    movsx edx, si
    imul ecx, edx, 0x2c
    mov eax, dword ptr [esp + 12]
    {disp32} lea eax, dword ptr [eax*4]
    sar eax, 3
    mov edi, dword ptr [ecx + _sprite + 8]
    {store} add edi, eax
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov dword ptr [esp], edi
    mov esi, dword ptr [eax + _hittype + 23]
    {store} mov edx, eax
    {store} cmp edi, esi
    jle actors_C_flow_5261
    {store} mov eax, edi
    cmp eax, dword ptr [edx + _hittype + 19]
    jg actors_C_flow_5261
    mov dword ptr [ecx + _sprite + 8], eax
    jmp actors_C_flow_5285
actors_C_flow_5261:
    test bx, bx
    jne actors_C_flow_5285
    movsx eax, word ptr [esp + 24]
    .att_syntax prefix
    addl $actors_C_math_5271,%eax
    .intel_syntax noprefix
    add esp, 0x20
    pop ebp
    pop edi
    pop esi
    ret 4
actors_C_flow_5285:
    movsx eax, bx
actors_C_flow_5288:
    add esp, 0x20
    pop ebp
    pop edi
    pop esi
    ret 4
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
    {disp8} lea eax, dword ptr [eax]
ssp_:
    push ebx
    push ecx
    push esi
    movsx esi, ax
    imul eax, esi, 0x2c
    add eax, OFFSET FLAT:_sprite
    push edx
    mov dx, word ptr [eax + 28]
    and dh, 7
    movsx edx, dx
    movsx ebx, word ptr [edx*2 + _sintable]
    movsx edx, word ptr [eax + 32]
    imul ebx, edx
    movsx ecx, word ptr [eax + 36]
    movsx eax, word ptr [eax + 28]
    .att_syntax prefix
    addl $actors_C_math_5360,%eax
    .intel_syntax noprefix
    and eax, 0x7ff
    movsx eax, word ptr [eax*2 + _sintable]
    imul edx, eax
    sar ebx, 0xe
    sar edx, 0xe
    {store} mov eax, esi
    call movesprite_
    test eax, eax
    sete al
    xor ah, ah
    pop esi
    pop ecx
    pop ebx
    ret
    {disp8} lea eax, dword ptr [eax]
insertspriteq_:
    push ebx
    push edx
    {store} mov edx, eax
    movsx eax, word ptr [_spriteqloc]
    {store} add eax, eax
    mov bx, word ptr [eax + _spriteq]
    test bx, bx
    jl actors_C_flow_5447
    movsx eax, bx
    imul eax, eax, 0x2c
    xor bl, bl
    mov byte ptr [eax + _sprite + 20], bl
actors_C_flow_5447:
    movsx eax, word ptr [_spriteqloc]
    mov word ptr [eax*2 + _spriteq], dx
    mov ax, word ptr [_spriteqloc]
    inc eax
    xor ah, ah
    and al, 0x3f
    mov word ptr [_spriteqloc], ax
    pop edx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
lotsofmoney_:
    push ebx
    push ecx
    push esi
    push edi
    {store} mov esi, eax
    {store} mov edi, edx
    test di, di
    jg actors_C_flow_5506
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
actors_C_flow_5506:
    push 5
    push 0
    push 0
    push 0
    call krand_
    and ah, 7
    cwde
    push eax
    push 8
    push 8
    push -32
    push 0x4d1
    call krand_
    {store} mov edx, eax
    mov ebx, 0x2f00
    sar edx, 0x1f
    idiv ebx
    mov ecx, dword ptr [esi + 8]
    mov ebx, dword ptr [esi + 4]
    movsx eax, word ptr [esi + 24]
    {store} sub ecx, edx
    mov edx, dword ptr [esi]
    call EGS_
    {store} mov edx, eax
    call krand_
    {store} mov ebx, eax
    xor bh, ah
    movsx eax, dx
    imul eax, eax, 0x2c
    and bl, 0xc
    dec edi
    mov word ptr [eax + _sprite + 12], bx
    test di, di
    jg actors_C_flow_5506
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    nop
guts_:
    push esi
    push edi
    push ebp
    sub esp, 0x14
    {store} mov esi, eax
    mov dword ptr [esp + 4], edx
    mov dword ptr [esp], ebx
    mov dword ptr [esp + 8], ecx
    call badguy_
    test ax, ax
    je actors_C_flow_5663
    cmp byte ptr [esi + 20], 0x10
    jae actors_C_flow_5663
    mov bl, 8
    mov byte ptr [esp + 12], bl
    mov byte ptr [esp + 16], bl
    jmp actors_C_flow_5673
actors_C_flow_5663:
    mov dl, 0x20
    mov byte ptr [esp + 12], dl
    mov byte ptr [esp + 16], dl
actors_C_flow_5673:
    mov ebx, dword ptr [esi + 4]
    mov edx, dword ptr [esi]
    movsx eax, word ptr [esi + 24]
    mov ebp, dword ptr [esi + 8]
    call getflorzofslope_
    sub ebp, 0x800
    sub eax, 0x800
    {store} cmp ebp, eax
    jle actors_C_flow_5707
    {store} mov ebp, eax
actors_C_flow_5707:
    cmp word ptr [esi + 14], 0x780
    jne actors_C_flow_5721
    sub ebp, 0x1800
actors_C_flow_5721:
    {store} xor edi, edi
    cmp di, word ptr [esp]
    jl actors_C_flow_5736
    add esp, 0x14
    pop ebp
    pop edi
    pop esi
    ret
actors_C_flow_5736:
    call krand_
    and ah, 7
    {store} mov edx, eax
    movsx eax, word ptr [esp + 8]
    imul eax, eax, 0x552
    push 5
    movsx eax, word ptr [eax + _ps + 724]
    push eax
    mov ebx, 0xfffffe00
    call krand_
    and eax, 0x7ff
    {store} sub ebx, eax
    push ebx
    call krand_
    xor ah, ah
    and al, 0x1f
    .att_syntax prefix
    addl $actors_C_math_5794,%eax
    .intel_syntax noprefix
    cwde
    push eax
    movsx eax, dx
    push eax
    movsx eax, byte ptr [esp + 32]
    push eax
    movsx eax, byte ptr [esp + 40]
    push eax
    {store} mov ecx, ebp
    mov ebx, dword ptr [esi + 4]
    push -32
    movsx eax, word ptr [esp + 36]
    mov edx, dword ptr [esi]
    push eax
    movsx eax, word ptr [esi + 24]
    inc edi
    call EGS_
    cmp di, word ptr [esp]
    jl actors_C_flow_5736
    add esp, 0x14
    pop ebp
    pop edi
    pop esi
    ret
    nop
gutsdir_:
    push esi
    push edi
    push ebp
    sub esp, 0x14
    {store} mov esi, eax
    mov dword ptr [esp + 4], edx
    mov dword ptr [esp], ebx
    mov dword ptr [esp + 8], ecx
    call badguy_
    test ax, ax
    je actors_C_flow_5903
    cmp byte ptr [esi + 20], 0x10
    jae actors_C_flow_5903
    mov bl, 8
    mov byte ptr [esp + 12], bl
    mov byte ptr [esp + 16], bl
    jmp actors_C_flow_5913
actors_C_flow_5903:
    mov dl, 0x20
    mov byte ptr [esp + 12], dl
    mov byte ptr [esp + 16], dl
actors_C_flow_5913:
    mov ebx, dword ptr [esi + 4]
    mov edx, dword ptr [esi]
    movsx eax, word ptr [esi + 24]
    mov ebp, dword ptr [esi + 8]
    call getflorzofslope_
    sub ebp, 0x800
    sub eax, 0x800
    {store} cmp ebp, eax
    jle actors_C_flow_5947
    {store} mov ebp, eax
actors_C_flow_5947:
    cmp word ptr [esi + 14], 0x780
    jne actors_C_flow_5961
    sub ebp, 0x1800
actors_C_flow_5961:
    {store} xor edi, edi
    cmp di, word ptr [esp]
    jl actors_C_flow_5976
    add esp, 0x14
    pop ebp
    pop edi
    pop esi
    ret
actors_C_flow_5976:
    call krand_
    and ah, 7
    {store} mov edx, eax
    movsx eax, word ptr [esp + 8]
    imul eax, eax, 0x552
    push 5
    movsx eax, word ptr [eax + _ps + 724]
    push eax
    mov ebx, 0xfffffe00
    call krand_
    and eax, 0x7ff
    {store} sub ebx, eax
    push ebx
    call krand_
    xor ah, ah
    and al, 0x7f
    inc ah
    cwde
    push eax
    movsx eax, dx
    push eax
    movsx eax, byte ptr [esp + 32]
    push eax
    movsx eax, byte ptr [esp + 40]
    push eax
    {store} mov ecx, ebp
    mov ebx, dword ptr [esi + 4]
    push -32
    movsx eax, word ptr [esp + 36]
    mov edx, dword ptr [esi]
    push eax
    movsx eax, word ptr [esi + 24]
    inc edi
    call EGS_
    cmp di, word ptr [esp]
    jl actors_C_flow_5976
    add esp, 0x14
    pop ebp
    pop edi
    pop esi
    ret
    {disp8} lea eax, dword ptr [eax + eiz*1]
setsectinterpolate_:
    push ebx
    push ecx
    push edx
    push esi
    cwde
    imul eax, eax, 0x2c
    movsx edx, word ptr [eax + _sprite + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    movsx edx, word ptr [eax*8 + _sector]
    movsx esi, word ptr [eax*8 + _sector + 2]
    {store} add esi, edx
    {store} cmp edx, esi
    jl actors_C_flow_6147
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
actors_C_flow_6147:
    {store} mov ecx, edx
    mov ebx, OFFSET FLAT:_wall
    shl ecx, 5
    {store} add ebx, ecx
    {store} mov eax, ebx
    call setinterpolation_
    lea eax, dword ptr [ebx + 4]
    call setinterpolation_
    movsx eax, word ptr [ecx + _wall + 10]
    test eax, eax
    jl actors_C_flow_6244
    {store} mov ecx, eax
    mov ebx, OFFSET FLAT:_wall
    shl ecx, 5
    {store} add ebx, ecx
    {store} mov eax, ebx
    call setinterpolation_
    lea eax, dword ptr [ebx + 4]
    call setinterpolation_
    movsx eax, word ptr [ecx + _wall + 8]
    mov ebx, OFFSET FLAT:_wall
    shl eax, 5
    {store} add ebx, eax
    {store} mov eax, ebx
    call setinterpolation_
    lea eax, dword ptr [ebx + 4]
    call setinterpolation_
actors_C_flow_6244:
    inc edx
    {store} cmp edx, esi
    jl actors_C_flow_6147
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {load} mov eax, eax
clearsectinterpolate_:
    push ebx
    push ecx
    push edx
    push esi
    movsx edx, ax
    imul edx, edx, 0x2c
    movsx edx, word ptr [edx + _sprite + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov bx, word ptr [eax*8 + _sector]
    mov si, word ptr [eax*8 + _sector + 2]
    {store} add esi, ebx
    {store} cmp bx, si
    jl actors_C_flow_6310
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
actors_C_flow_6310:
    movsx edx, bx
    mov ecx, OFFSET FLAT:_wall
    shl edx, 5
    {store} add ecx, edx
    {store} mov eax, ecx
    call stopinterpolation_
    lea eax, dword ptr [ecx + 4]
    call stopinterpolation_
    mov cx, word ptr [edx + _wall + 10]
    test cx, cx
    jl actors_C_flow_6389
    movsx eax, cx
    shl eax, 5
    add eax, OFFSET FLAT:_wall
    call stopinterpolation_
    movsx eax, word ptr [edx + _wall + 10]
    shl eax, 5
    add eax, OFFSET FLAT:_wall
    add eax, 4
    call stopinterpolation_
actors_C_flow_6389:
    inc ebx
    {store} cmp bx, si
    jl actors_C_flow_6310
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
ms_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    sub esp, 0x10
    movsx edx, ax
    imul ebp, edx, 0x2c
    add ebp, OFFSET FLAT:_sprite
    movsx eax, word ptr [ebp + 28]
    .att_syntax prefix
    addl $actors_C_math_6425,%eax
    .intel_syntax noprefix
    and eax, 0x7ff
    movsx ebx, word ptr [ebp + 32]
    movsx eax, word ptr [eax*2 + _sintable]
    imul eax, ebx
    sar eax, 0xe
    {disp8} mov ebx, dword ptr [ebp]
    {store} add ebx, eax
    mov ax, word ptr [ebp + 28]
    and ah, 7
    {disp8} mov dword ptr [ebp], ebx
    cwde
    movsx ebx, word ptr [ebp + 32]
    movsx eax, word ptr [eax*2 + _sintable]
    imul eax, ebx
    mov ecx, dword ptr [ebp + 4]
    sar eax, 0xe
    {store} add ecx, eax
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov dword ptr [ebp + 4], ecx
    mov edi, dword ptr [eax + _hittype + 51]
    mov eax, dword ptr [eax + _hittype + 55]
    movsx edx, word ptr [ebp + 24]
    mov dword ptr [esp + 8], eax
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov si, word ptr [eax*8 + _sector]
    mov ax, word ptr [eax*8 + _sector + 2]
    {store} add eax, esi
    mov dword ptr [esp + 12], eax
    jmp actors_C_flow_6634
actors_C_flow_6566:
    {store} mov eax, esp
    push eax
    lea eax, dword ptr [esp + 8]
    push eax
    mov eax, dword ptr [esp + 16]
    mov ecx, dword ptr [edi*4 + _msy]
    and eax, 0x7ff
    mov ebx, dword ptr [edi*4 + _msx]
    push eax
    {store} xor edx, edx
    {store} xor eax, eax
    call rotatepoint_
    mov eax, dword ptr [esp]
    mov ecx, dword ptr [esp + 4]
    mov ebx, dword ptr [ebp + 4]
    {disp8} mov edx, dword ptr [ebp]
    {store} add ebx, eax
    {store} add edx, ecx
    movsx eax, si
    inc edi
    call dragpoint_
    inc esi
actors_C_flow_6634:
    cmp si, word ptr [esp + 12]
    jl actors_C_flow_6566
    add esp, 0x10
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp8} lea eax, dword ptr [eax]
    {load} mov ecx, ecx
movefta_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    sub esp, 0x1c
    mov di, word ptr [_headspritestat + 4]
actors_C_flow_6672:
    test di, di
    {disp32} jl actors_C_flow_7491
    movsx ebp, di
    imul esi, ebp, 0x2c
    {store} mov edx, esp
    mov ax, word ptr [ebp*2 + _nextspritestat]
    add esi, OFFSET FLAT:_sprite
    mov dword ptr [esp + 16], eax
    {store} mov eax, esi
    call findplayer_
    {store} mov edx, eax
    movsx ecx, dx
    imul ecx, ecx, 0x552
    mov ax, word ptr [esi + 24]
    mov dword ptr [esp + 20], eax
    mov dword ptr [esp + 24], eax
    movsx eax, word ptr [ecx + _ps + 724]
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 42], 0
    {disp32} jle actors_C_flow_7482
    mov edx, dword ptr [esp]
    cmp edx, 0x7530
    {disp32} jge actors_C_flow_7424
    {disp32} lea eax, dword ptr [ebp*8]
    {store} add eax, ebp
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ebp
    mov bx, word ptr [eax + _hittype + 17]
    inc ebx
    sar edx, 8
    mov word ptr [eax + _hittype + 17], bx
    movsx eax, bx
    {store} cmp eax, edx
    {disp32} jl actors_C_flow_7424
    {store} mov eax, esi
    call badguy_
    test ax, ax
    {disp32} je actors_C_flow_7064
    lea ebx, dword ptr [esp + 20]
    mov edx, dword ptr [ecx + _ps + 568]
    call krand_
    add edx, 0x40
    mov ebp, dword ptr [ecx + _ps + 572]
    and eax, 0x7f
    add ebp, 0x40
    {store} sub edx, eax
    call krand_
    and eax, 0x7f
    mov dword ptr [esp + 12], edx
    {store} sub ebp, eax
    mov eax, dword ptr [esp + 12]
    {store} mov edx, ebp
    call updatesector_
    movsx eax, word ptr [esp + 20]
    cmp eax, -1
    jne actors_C_flow_6915
    mov edi, dword ptr [esp + 16]
    {disp32} jmp actors_C_flow_6672
actors_C_flow_6915:
    call krand_
    mov edx, dword ptr [esi]
    and eax, 0x7f
    add edx, 0x40
    {store} sub edx, eax
    mov dword ptr [esp + 8], edx
    mov edx, dword ptr [esi + 4]
    call krand_
    add edx, 0x40
    and eax, 0x7f
    lea ebx, dword ptr [esp + 24]
    {store} sub edx, eax
    mov eax, dword ptr [esp + 12]
    mov dword ptr [esp + 4], edx
    {store} mov edx, ebp
    call updatesector_
    movsx eax, word ptr [esp + 24]
    cmp eax, -1
    jne actors_C_flow_6988
    mov edi, dword ptr [esp + 16]
    {disp32} jmp actors_C_flow_6672
actors_C_flow_6988:
    movsx eax, word ptr [ecx + _ps + 646]
    push eax
    call krand_
    {store} mov edx, eax
    mov ebx, 0x2000
    sar edx, 0x1f
    idiv ebx
    mov eax, dword ptr [ecx + _ps + 576]
    {store} sub eax, edx
    push eax
    push ebp
    mov eax, dword ptr [esp + 24]
    push eax
    movsx ecx, word ptr [esi + 24]
    call krand_
    {store} mov edx, eax
    mov ebx, 0x3400
    sar edx, 0x1f
    idiv ebx
    mov ebx, dword ptr [esi + 8]
    mov eax, dword ptr [esp + 24]
    {store} sub ebx, edx
    mov edx, dword ptr [esp + 20]
    jmp actors_C_flow_7135
actors_C_flow_7064:
    movsx eax, word ptr [ecx + _ps + 646]
    push eax
    call krand_
    and eax, 0x1f
    mov edx, dword ptr [ecx + _ps + 576]
    shl eax, 8
    {store} sub edx, eax
    push edx
    mov ebx, dword ptr [ecx + _ps + 572]
    push ebx
    mov ebp, dword ptr [ecx + _ps + 568]
    push ebp
    movsx ecx, word ptr [esi + 24]
    call krand_
    {store} mov ebx, eax
    and ebx, 0x1f
    mov eax, dword ptr [esi + 8]
    shl ebx, 8
    {store} sub eax, ebx
    mov edx, dword ptr [esi + 4]
    {store} mov ebx, eax
    mov eax, dword ptr [esi]
actors_C_flow_7135:
    call cansee_
    test ax, ax
    {disp32} je actors_C_flow_7394
    mov ax, word ptr [esi + 14]
    .att_syntax prefix
    cmpw $actors_C_math_7153,%ax
    .intel_syntax noprefix
    jb actors_C_flow_7207
    {disp32} jbe actors_C_flow_7251
    .att_syntax prefix
    cmpw $actors_C_math_7165,%ax
    .intel_syntax noprefix
    jb actors_C_flow_7196
    jbe actors_C_flow_7251
    .att_syntax prefix
    cmpw $actors_C_math_7173,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_7343
    jbe actors_C_flow_7251
    .att_syntax prefix
    cmpw $actors_C_math_7185,%ax
    .intel_syntax noprefix
    je actors_C_flow_7251
    {disp32} jmp actors_C_flow_7343
actors_C_flow_7196:
    .att_syntax prefix
    cmpw $actors_C_math_7196,%ax
    .intel_syntax noprefix
    je actors_C_flow_7251
    {disp32} jmp actors_C_flow_7343
actors_C_flow_7207:
    .att_syntax prefix
    cmpw $actors_C_math_7207,%ax
    .intel_syntax noprefix
    jb actors_C_flow_7245
    jbe actors_C_flow_7251
    .att_syntax prefix
    cmpw $actors_C_math_7215,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_7343
    jbe actors_C_flow_7251
    .att_syntax prefix
    cmpw $actors_C_math_7227,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_7343
    .att_syntax prefix
    cmpw $actors_C_math_7237,%ax
    .intel_syntax noprefix
    jbe actors_C_flow_7251
    jmp actors_C_flow_7343
actors_C_flow_7245:
    .att_syntax prefix
    cmpw $actors_C_math_7245,%ax
    .intel_syntax noprefix
    jne actors_C_flow_7343
actors_C_flow_7251:
    movsx edx, word ptr [esi + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    test byte ptr [eax + _sector + 12], 1
    je actors_C_flow_7288
    mov al, byte ptr [eax + _sector + 20]
    jmp actors_C_flow_7294
actors_C_flow_7288:
    mov al, byte ptr [eax + _sector + 28]
actors_C_flow_7294:
    mov byte ptr [esi + 16], al
    movsx ecx, di
    {store} mov edx, ecx
    {disp32} lea eax, dword ptr [ecx*8]
    {store} add eax, ecx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ecx
    {store} xor edx, ecx
    mov word ptr [eax + _hittype + 17], dx
    mov edx, 6
    {store} mov eax, ecx
    call changespritestat_
    jmp actors_C_flow_7424
actors_C_flow_7343:
    movsx ecx, di
    {disp32} lea eax, dword ptr [ecx*8]
    {store} add eax, ecx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ecx
    {store} xor edi, edi
    mov word ptr [eax + _hittype + 17], di
    {store} mov eax, ecx
    mov edx, 1
    call check_fta_sounds_
    {store} mov eax, ecx
    call changespritestat_
    jmp actors_C_flow_7424
actors_C_flow_7394:
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    {store} xor ecx, ecx
    mov word ptr [eax + _hittype + 17], cx
actors_C_flow_7424:
    {store} mov eax, esi
    call badguy_
    test ax, ax
    je actors_C_flow_7482
    movsx edx, word ptr [esi + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    test byte ptr [eax + _sector + 12], 1
    je actors_C_flow_7473
    mov al, byte ptr [eax + _sector + 20]
    jmp actors_C_flow_7479
actors_C_flow_7473:
    mov al, byte ptr [eax + _sector + 28]
actors_C_flow_7479:
    mov byte ptr [esi + 16], al
actors_C_flow_7482:
    mov edi, dword ptr [esp + 16]
    {disp32} jmp actors_C_flow_6672
actors_C_flow_7491:
    add esp, 0x1c
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp8} lea eax, dword ptr [eax]
ifhitsectors_:
    push ebx
    push edx
    {store} mov ebx, eax
    mov ax, word ptr [_headspritestat + 10]
actors_C_flow_7514:
    test ax, ax
    jl actors_C_flow_7558
    movsx edx, ax
    imul edx, edx, 0x2c
    cmp word ptr [edx + _sprite + 14], 0x762
    jne actors_C_flow_7545
    cmp bx, word ptr [edx + _sprite + 24]
    je actors_C_flow_7563
actors_C_flow_7545:
    movsx edx, ax
    mov ax, word ptr [edx*2 + _nextspritestat]
    jmp actors_C_flow_7514
actors_C_flow_7558:
    mov eax, 0xffffffff
actors_C_flow_7563:
    pop edx
    pop ebx
    ret
    {load} mov eax, eax
ifhitbyweapon_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    {store} mov edx, eax
    movsx ecx, ax
    {disp32} lea eax, dword ptr [ecx*8]
    {store} add eax, ecx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ecx
    mov si, word ptr [eax + _hittype + 5]
    {store} mov ebx, eax
    test si, si
    {disp32} jl actors_C_flow_8390
    imul eax, ecx, 0x2c
    cmp word ptr [eax + _sprite + 42], 0
    {disp32} jl actors_C_flow_8390
    add eax, OFFSET FLAT:_sprite
    cmp word ptr [eax + 14], 0x57d
    {disp32} jne actors_C_flow_8223
    cmp byte ptr [_ud], 0
    je actors_C_flow_7679
    cmp word ptr [ebx + _hittype + 1], 0x66e
    je actors_C_flow_7679
    mov eax, 0xffffffff
    {disp32} jmp actors_C_flow_8425
actors_C_flow_7679:
    movsx esi, dx
    {disp32} lea ebx, dword ptr [esi*8]
    {store} add ebx, esi
    {disp32} lea ebx, dword ptr [ebx*8]
    {store} sub ebx, esi
    mov di, word ptr [eax + 42]
    mov si, word ptr [ebx + _hittype + 5]
    {store} sub edi, esi
    mov word ptr [eax + 42], di
    mov si, word ptr [ebx + _hittype + 7]
    mov cx, word ptr [eax + 34]
    test si, si
    {disp32} jl actors_C_flow_7866
    test di, di
    {disp32} jg actors_C_flow_7866
    cmp word ptr [ebx + _hittype + 1], 0x669
    je actors_C_flow_7866
    movsx esi, cx
    imul esi, esi, 0x552
    mov word ptr [eax + 42], 0
    mov ax, word ptr [ebx + _hittype + 7]
    mov word ptr [esi + _ps + 674], ax
    cwde
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 14], 0x57d
    jne actors_C_flow_7820
    mov bx, word ptr [eax + _sprite + 34]
    {store} cmp cx, bx
    je actors_C_flow_7820
    mov word ptr [esi + _ps + 1288], bx
actors_C_flow_7820:
    movsx esi, cx
    imul esi, esi, 0x552
    movsx ebx, dx
    {disp32} lea eax, dword ptr [ebx*8]
    {store} add eax, ebx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ebx
    {store} mov ebx, eax
    mov ax, word ptr [esi + _ps + 724]
    mov word ptr [ebx + _hittype + 7], ax
actors_C_flow_7866:
    movsx ebx, dx
    {disp32} lea eax, dword ptr [ebx*8]
    {store} add eax, ebx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ebx
    mov ax, word ptr [eax + _hittype + 1]
    .att_syntax prefix
    cmpw $actors_C_math_7894,%ax
    .intel_syntax noprefix
    jb actors_C_flow_7932
    jbe actors_C_flow_7961
    .att_syntax prefix
    cmpw $actors_C_math_7902,%ax
    .intel_syntax noprefix
    jb actors_C_flow_7921
    jbe actors_C_flow_7961
    .att_syntax prefix
    cmpw $actors_C_math_7910,%ax
    .intel_syntax noprefix
    je actors_C_flow_7961
    {disp32} jmp actors_C_flow_8097
actors_C_flow_7921:
    .att_syntax prefix
    cmpw $actors_C_math_7921,%ax
    .intel_syntax noprefix
    je actors_C_flow_7961
    {disp32} jmp actors_C_flow_8097
actors_C_flow_7932:
    .att_syntax prefix
    cmpw $actors_C_math_7932,%ax
    .intel_syntax noprefix
    jb actors_C_flow_7951
    jbe actors_C_flow_7961
    .att_syntax prefix
    cmpw $actors_C_math_7940,%ax
    .intel_syntax noprefix
    je actors_C_flow_7961
    {disp32} jmp actors_C_flow_8097
actors_C_flow_7951:
    .att_syntax prefix
    cmpw $actors_C_math_7951,%ax
    .intel_syntax noprefix
    {disp32} jne actors_C_flow_8097
actors_C_flow_7961:
    movsx ebx, cx
    imul ebx, ebx, 0x552
    movsx ecx, dx
    {disp32} lea eax, dword ptr [ecx*8]
    {store} add eax, ecx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ecx
    movsx ecx, word ptr [eax + _hittype + 3]
    add ecx, 0x200
    and ecx, 0x7ff
    movsx esi, word ptr [ecx*2 + _sintable]
    movsx ecx, word ptr [eax + _hittype + 5]
    imul esi, ecx
    mov ax, word ptr [eax + _hittype + 3]
    and ah, 7
    cwde
    movsx eax, word ptr [eax*2 + _sintable]
    imul eax, ecx
    mov edi, dword ptr [ebx + _ps + 588]
    {disp32} lea esi, dword ptr [esi*4]
    mov ebp, dword ptr [ebx + _ps + 592]
    {store} add edi, esi
    {disp32} lea eax, dword ptr [eax*4]
    mov dword ptr [ebx + _ps + 588], edi
    {store} add ebp, eax
    mov dword ptr [ebx + _ps + 592], ebp
    {disp32} jmp actors_C_flow_8346
actors_C_flow_8097:
    movsx ebx, cx
    imul ebx, ebx, 0x552
    movsx ecx, dx
    {disp32} lea eax, dword ptr [ecx*8]
    {store} add eax, ecx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ecx
    movsx ecx, word ptr [eax + _hittype + 3]
    add ecx, 0x200
    and ecx, 0x7ff
    movsx esi, word ptr [ecx*2 + _sintable]
    movsx ecx, word ptr [eax + _hittype + 5]
    imul esi, ecx
    mov ax, word ptr [eax + _hittype + 3]
    and ah, 7
    cwde
    movsx eax, word ptr [eax*2 + _sintable]
    imul ecx, eax
    mov edi, dword ptr [ebx + _ps + 588]
    {store} add esi, esi
    mov ebp, dword ptr [ebx + _ps + 592]
    {store} add edi, esi
    {store} add ecx, ecx
    mov dword ptr [ebx + _ps + 588], edi
    {store} add ebp, ecx
    mov dword ptr [ebx + _ps + 592], ebp
    {disp32} jmp actors_C_flow_8346
actors_C_flow_8223:
    cmp word ptr [ebx + _hittype + 5], 0
    jne actors_C_flow_8262
    cmp word ptr [ebx + _hittype + 1], 0x66e
    jne actors_C_flow_8262
    cmp byte ptr [eax + 20], 0x18
    jae actors_C_flow_8262
    mov eax, 0xffffffff
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
actors_C_flow_8262:
    movsx ecx, dx
    {disp32} lea ebx, dword ptr [ecx*8]
    {store} add ebx, ecx
    {disp32} lea ebx, dword ptr [ebx*8]
    {store} sub ebx, ecx
    mov si, word ptr [eax + 42]
    sub si, word ptr [ebx + _hittype + 5]
    mov di, word ptr [eax + 14]
    mov word ptr [eax + 42], si
    cmp di, 0x7a8
    je actors_C_flow_8346
    mov cx, word ptr [eax + 30]
    test cx, cx
    jl actors_C_flow_8346
    movsx ecx, cx
    imul ecx, ecx, 0x2c
    cmp word ptr [ecx + _sprite + 26], 0x400
    jge actors_C_flow_8346
    mov bx, word ptr [ebx + _hittype + 7]
    mov word ptr [eax + 30], bx
actors_C_flow_8346:
    movsx ebx, dx
    {disp32} lea eax, dword ptr [ebx*8]
    {store} add eax, ebx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ebx
    mov word ptr [eax + _hittype + 5], 0xffff
    mov ax, word ptr [eax + _hittype + 1]
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
actors_C_flow_8390:
    movsx ebx, dx
    {disp32} lea eax, dword ptr [ebx*8]
    {store} add eax, ebx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ebx
    mov edx, 0xffffffff
    mov word ptr [eax + _hittype + 5], dx
    {store} mov eax, edx
actors_C_flow_8425:
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
movecyclers_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    sub esp, 4
    mov si, word ptr [_numcyclers]
    dec esi
    test si, si
    jge actors_C_flow_8462
    add esp, 4
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
actors_C_flow_8462:
    movsx edx, si
    {disp32} lea eax, dword ptr [edx*4]
    {store} sub eax, edx
    mov ecx, OFFSET FLAT:_cyclers
    {disp32} lea eax, dword ptr [eax*4]
    {store} add ecx, eax
    mov dx, word ptr [ecx + 2]
    and dh, 7
    movsx edx, dx
    mov ax, word ptr [ecx + 6]
    movsx edx, word ptr [edx*2 + _sintable]
    movsx ebx, ax
    sar edx, 0xa
    {store} add edx, ebx
    {store} mov ebx, edx
    mov dl, byte ptr [ecx + 4]
    mov byte ptr [esp], dl
    {store} xor edx, edx
    mov dl, byte ptr [esp]
    mov di, word ptr [ecx]
    {store} cmp bx, dx
    jge actors_C_flow_8543
    {store} mov ebx, edx
    jmp actors_C_flow_8550
actors_C_flow_8543:
    {store} cmp bx, ax
    jle actors_C_flow_8550
    {store} mov ebx, eax
actors_C_flow_8550:
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*4]
    {store} add edx, eax
    {disp32} lea edx, dword ptr [edx*8]
    mov ax, word ptr [edx + _sector + 38]
    add word ptr [ecx + 2], ax
    cmp word ptr [ecx + 10], 0
    je actors_C_flow_8685
    movsx eax, word ptr [edx + _sector]
    shl eax, 5
    mov dx, word ptr [edx + _sector + 2]
    add eax, OFFSET FLAT:_wall
    jmp actors_C_flow_8654
actors_C_flow_8611:
    cmp word ptr [eax + 28], 1
    je actors_C_flow_8650
    mov cl, byte ptr [eax + 14]
    mov byte ptr [eax + 20], bl
    test cl, 2
    je actors_C_flow_8650
    mov cx, word ptr [eax + 10]
    test cx, cx
    jl actors_C_flow_8650
    movsx ecx, cx
    shl ecx, 5
    mov byte ptr [ecx + _wall + 20], bl
actors_C_flow_8650:
    dec edx
    add eax, 0x20
actors_C_flow_8654:
    test dx, dx
    jg actors_C_flow_8611
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov byte ptr [eax*8 + _sector + 20], bl
    mov byte ptr [eax*8 + _sector + 28], bl
actors_C_flow_8685:
    dec esi
    test si, si
    {disp32} jge actors_C_flow_8462
    add esp, 4
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
movedummyplayers_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    sub esp, 8
    mov dx, word ptr [_headspritestat + 26]
actors_C_flow_8720:
    test dx, dx
    {disp32} jl actors_C_flow_9177
    movsx esi, dx
    imul ebx, esi, 0x2c
    mov ax, word ptr [esi*2 + _nextspritestat]
    mov dword ptr [esp + 4], eax
    movsx eax, word ptr [ebx + _sprite + 30]
    imul eax, eax, 0x2c
    mov di, word ptr [eax + _sprite + 34]
    movsx ecx, di
    imul ecx, ecx, 0x552
    movsx eax, word ptr [ecx + _ps + 646]
    mov dword ptr [esp], eax
    mov ebp, dword ptr [esp]
    {disp32} lea eax, dword ptr [eax*4]
    {store} add eax, ebp
    {disp32} lea eax, dword ptr [eax*8]
    cmp word ptr [eax + _sector + 34], 1
    jne actors_C_flow_8832
    movsx ebp, word ptr [ecx + _ps + 724]
    imul ebp, ebp, 0x2c
    cmp word ptr [ebp + _sprite + 42], 0
    jg actors_C_flow_8863
actors_C_flow_8832:
    movsx eax, di
    imul eax, eax, 0x552
    mov word ptr [eax + _ps + 738], 0xffff
    movsx eax, dx
    call deletesprite_
    {disp32} jmp actors_C_flow_9168
actors_C_flow_8863:
    cmp byte ptr [ecx + _ps + 1308], 0
    {disp32} je actors_C_flow_9012
    cmp byte ptr [ecx + _ps + 1303], 1
    {disp32} jne actors_C_flow_9012
    cmp word ptr [eax + _sector + 34], 1
    jne actors_C_flow_9012
    mov word ptr [ebx + _sprite + 12], 0x101
    movsx eax, word ptr [ebx + _sprite + 24]
    mov dword ptr [esp], eax
    mov ebp, dword ptr [esp]
    {disp32} lea eax, dword ptr [eax*4]
    {store} add eax, ebp
    mov eax, dword ptr [eax*8 + _sector + 4]
    .att_syntax prefix
    addl $actors_C_math_8937,%eax
    .intel_syntax noprefix
    mov dword ptr [ebx + _sprite + 8], eax
    mov ax, word ptr [ecx + _ps + 640]
    mov word ptr [ebx + _sprite + 28], ax
    {disp32} lea eax, dword ptr [esi*8]
    {store} add eax, esi
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, esi
    mov ebx, dword ptr [eax + _hittype + 47]
    cmp ebx, 8
    jne actors_C_flow_9001
    {store} xor esi, esi
    mov dword ptr [eax + _hittype + 47], esi
    jmp actors_C_flow_9078
actors_C_flow_9001:
    lea ecx, dword ptr [ebx + 1]
    mov dword ptr [eax + _hittype + 47], ecx
    jmp actors_C_flow_9078
actors_C_flow_9012:
    movsx ebx, dx
    imul ebx, ebx, 0x2c
    movsx ecx, word ptr [ebx + _sprite + 24]
    {disp32} lea eax, dword ptr [ecx*4]
    {store} add eax, ecx
    {disp32} lea eax, dword ptr [eax*8]
    cmp word ptr [eax + _sector + 34], 2
    je actors_C_flow_9063
    mov eax, dword ptr [eax + _sector + 8]
    mov dword ptr [ebx + _sprite + 8], eax
actors_C_flow_9063:
    movsx eax, dx
    imul eax, eax, 0x2c
    mov word ptr [eax + _sprite + 12], 0x8000
actors_C_flow_9078:
    movsx ebx, di
    imul ebx, ebx, 0x552
    movsx esi, dx
    imul eax, esi, 0x2c
    mov ecx, dword ptr [ebx + _ps + 532]
    mov edi, dword ptr [ebx + _ps + 568]
    mov ebp, dword ptr [eax + _sprite]
    {store} sub ecx, edi
    {store} add ebp, ecx
    mov edx, dword ptr [ebx + _ps + 572]
    mov dword ptr [eax + _sprite], ebp
    mov ecx, dword ptr [ebx + _ps + 536]
    mov ebx, dword ptr [eax + _sprite + 4]
    {store} sub ecx, edx
    mov edx, dword ptr [eax + _sprite]
    {store} add ebx, ecx
    mov ecx, dword ptr [eax + _sprite + 8]
    mov dword ptr [eax + _sprite + 4], ebx
    {store} mov eax, esi
    call setsprite_
actors_C_flow_9168:
    mov edx, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_8720
actors_C_flow_9177:
    add esp, 8
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
    nop
moveplayers_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    sub esp, 8
    mov di, word ptr [_headspritestat + 20]
actors_C_flow_9215:
    test di, di
    {disp32} jl actors_C_flow_10137
    movsx eax, di
    imul esi, eax, 0x2c
    add esi, OFFSET FLAT:_sprite
    movsx ebx, word ptr [esi + 34]
    imul ecx, ebx, 0x552
    mov dx, word ptr [eax*2 + _nextspritestat]
    mov dword ptr [esp + 4], edx
    mov dx, word ptr [esi + 30]
    add ecx, OFFSET FLAT:_ps
    test dx, dx
    {disp32} jl actors_C_flow_9796
    cmp word ptr [ecx + 690], 0
    jl actors_C_flow_9341
    mov edx, dword ptr [ecx + 568]
    mov dword ptr [esi], edx
    mov edx, dword ptr [ecx + 572]
    mov dword ptr [esi + 4], edx
    mov edx, dword ptr [ecx + 576]
    add edx, 0x2600
    mov dword ptr [esi + 8], edx
    mov dx, word ptr [ecx + 642]
    mov word ptr [esi + 28], dx
    mov ebx, dword ptr [esi + 4]
    mov ecx, dword ptr [esi + 8]
    {disp32} jmp actors_C_flow_10063
actors_C_flow_9341:
    cmp word ptr [_ud + 1424], 1
    jle actors_C_flow_9368
    {store} mov edx, esp
    {store} mov eax, ebx
    call findotherplayer_
    mov word ptr [_otherp], ax
    jmp actors_C_flow_9383
actors_C_flow_9368:
    mov ax, word ptr [esi + 34]
    {store} xor ebx, ebx
    mov word ptr [_otherp], ax
    mov dword ptr [esp], ebx
actors_C_flow_9383:
    mov ebx, dword ptr [esp]
    movsx eax, di
    movsx edx, word ptr [esi + 34]
    call execute_
    cmp word ptr [_ud + 1424], 1
    {disp32} jle actors_C_flow_9524
    movsx eax, word ptr [_otherp]
    imul eax, eax, 0x552
    movsx eax, word ptr [eax + _ps + 724]
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 42], 0
    jle actors_C_flow_9524
    cmp byte ptr [esi + 21], 0x20
    jbe actors_C_flow_9524
    cmp byte ptr [eax + _sprite + 21], 0x20
    jae actors_C_flow_9524
    cmp dword ptr [esp], 0x578
    jge actors_C_flow_9524
    cmp word ptr [ecx + 700], 0
    jne actors_C_flow_9524
    mov word ptr [ecx + 700], 1
    mov word ptr [ecx + 1286], 0xffff
    movsx eax, word ptr [_otherp]
    imul eax, eax, 0x552
    mov ax, word ptr [eax + _ps + 724]
    mov word ptr [ecx + 746], ax
actors_C_flow_9524:
    cmp byte ptr [_ud], 0
    je actors_C_flow_9558
    mov ax, word ptr [_max_player_health]
    mov word ptr [esi + 12], 0x101
    mov word ptr [esi + 42], ax
    mov word ptr [ecx + 1276], 0x63f
actors_C_flow_9558:
    cmp word ptr [esi + 42], 0
    jle actors_C_flow_9635
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov word ptr [eax + _hittype + 7], di
    movsx eax, word ptr [esi + 24]
    call ceilingspace_
    test eax, eax
    jne actors_C_flow_9623
    movsx eax, word ptr [esi + 24]
    call floorspace_
    test eax, eax
    {disp32} je actors_C_flow_9780
actors_C_flow_9623:
    {store} mov eax, ecx
    call quickkill_
    {disp32} jmp actors_C_flow_9780
actors_C_flow_9635:
    mov eax, dword ptr [esi]
    mov dword ptr [ecx + 532], eax
    mov eax, dword ptr [esi + 4]
    mov dword ptr [ecx + 536], eax
    mov eax, dword ptr [esi + 8]
    mov word ptr [ecx + 690], 0xffff
    sub eax, 0x1400
    mov bx, word ptr [ecx + 674]
    mov dword ptr [ecx + 540], eax
    test bx, bx
    jl actors_C_flow_9780
    movsx eax, bx
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 26], 0x400
    jge actors_C_flow_9780
    mov edx, dword ptr [eax + _sprite + 4]
    mov ebx, dword ptr [ecx + 536]
    mov edi, dword ptr [ecx + 532]
    mov eax, dword ptr [eax + _sprite]
    {store} sub edx, ebx
    {store} sub eax, edi
    call getangle_
    movsx edx, ax
    movsx eax, word ptr [ecx + 640]
    call getincangle_
    cwde
    {store} mov edx, eax
    sar edx, 1
    movsx eax, word ptr [ecx + 640]
    {store} add eax, edx
    mov word ptr [ecx + 640], ax
    and byte ptr [ecx + 641], 7
actors_C_flow_9780:
    mov ax, word ptr [ecx + 640]
    mov word ptr [esi + 28], ax
    {disp32} jmp actors_C_flow_10070
actors_C_flow_9796:
    movsx edx, word ptr [ecx + 1282]
    cmp edx, -1
    jne actors_C_flow_9818
    call deletesprite_
    {disp32} jmp actors_C_flow_10128
actors_C_flow_9818:
    {store} mov edx, eax
    {disp32} lea eax, dword ptr [eax*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov edx, dword ptr [esi]
    mov dword ptr [eax + _hittype + 35], edx
    mov edx, dword ptr [esi + 4]
    mov dword ptr [eax + _hittype + 39], edx
    mov edx, dword ptr [esi + 8]
    mov dword ptr [eax + _hittype + 43], edx
    mov ah, byte ptr [esi + 20]
    mov word ptr [esi + 12], 0
    cmp ah, 0x2a
    jae actors_C_flow_9892
    {store} mov dl, ah
    add dl, 4
    mov byte ptr [esi + 20], dl
    or byte ptr [esi + 12], 2
    jmp actors_C_flow_9896
actors_C_flow_9892:
    mov byte ptr [esi + 20], 0x2a
actors_C_flow_9896:
    mov bl, byte ptr [esi + 21]
    cmp bl, 0x24
    jae actors_C_flow_9914
    {store} mov bh, bl
    add bh, 4
    mov byte ptr [esi + 21], bh
    jmp actors_C_flow_9988
actors_C_flow_9914:
    movsx edx, word ptr [esi + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov byte ptr [esi + 21], 0x24
    cmp word ptr [eax*8 + _sector + 34], 2
    je actors_C_flow_9950
    movsx eax, di
    call makeitfall_
actors_C_flow_9950:
    cmp word ptr [esi + 36], 0
    jne actors_C_flow_9988
    movsx edx, word ptr [esi + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    cmp word ptr [eax*8 + _sector + 34], 1
    jne actors_C_flow_9988
    add dword ptr [esi + 8], 0x2000
actors_C_flow_9988:
    cmp word ptr [esi + 42], 8
    jge actors_C_flow_10036
    mov word ptr [esi + 32], 0x80
    mov edx, 0x10001
    mov ax, word ptr [ecx + 640]
    mov cx, word ptr [esi + 42]
    mov word ptr [esi + 28], ax
    inc ecx
    movsx eax, di
    mov word ptr [esi + 42], cx
    call ssp_
    jmp actors_C_flow_10070
actors_C_flow_10036:
    mov edx, 0x7ff
    mov ax, word ptr [ecx + 640]
    mov ebx, dword ptr [esi + 4]
    {store} sub edx, eax
    mov ecx, dword ptr [esi + 8]
    mov word ptr [esi + 28], dx
    movsx eax, di
actors_C_flow_10063:
    mov edx, dword ptr [esi]
    call setsprite_
actors_C_flow_10070:
    movsx edx, word ptr [esi + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    test byte ptr [eax + _sector + 12], 1
    je actors_C_flow_10108
    movsx edx, byte ptr [eax + _sector + 20]
    jmp actors_C_flow_10115
actors_C_flow_10108:
    movsx edx, byte ptr [eax + _sector + 28]
actors_C_flow_10115:
    movsx eax, byte ptr [esi + 16]
    {store} sub edx, eax
    sar edx, 1
    {store} add eax, edx
    mov byte ptr [esi + 16], al
actors_C_flow_10128:
    mov edi, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_9215
actors_C_flow_10137:
    add esp, 8
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
    {load} mov eax, eax
movefx_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    sub esp, 0xc
    mov di, word ptr [_headspritestat + 22]
actors_C_flow_10176:
    test di, di
    {disp32} jl actors_C_flow_11318
    movsx ecx, di
    imul eax, ecx, 0x2c
    mov esi, OFFSET FLAT:_sprite
    mov dx, word ptr [ecx*2 + _nextspritestat]
    {store} add esi, eax
    mov dword ptr [esp + 8], edx
    mov dx, word ptr [esi + 14]
    cmp dx, 5
    {disp32} jb actors_C_flow_11309
    jbe actors_C_flow_10300
    cmp dx, 9
    {disp32} jne actors_C_flow_11309
    mov dx, word ptr [eax + _sprite + 42]
    cmp dx, 0x42
    jne actors_C_flow_10275
    movsx edx, word ptr [eax + _sprite + 40]
    {store} mov eax, ecx
    call spawn_
    {store} mov eax, ecx
    call deletesprite_
    {disp32} jmp actors_C_flow_11309
actors_C_flow_10275:
    cmp dx, 0x35
    {disp32} jle actors_C_flow_11309
    {store} mov ecx, edx
    inc ecx
    mov word ptr [eax + _sprite + 42], cx
    {disp32} jmp actors_C_flow_11309
actors_C_flow_10300:
    movsx eax, word ptr [esi + 40]
    mov dword ptr [esp], eax
    {disp32} lea eax, dword ptr [ecx*8]
    {store} add eax, ecx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ecx
    mov ebx, dword ptr [_SoundToggle]
    cmp ebx, dword ptr [eax + _hittype + 51]
    je actors_C_flow_10353
    {store} xor ecx, ecx
    mov dword ptr [eax + _hittype + 51], ebx
    mov dword ptr [eax + _hittype + 47], ecx
actors_C_flow_10353:
    mov ax, word ptr [esi + 38]
    .att_syntax prefix
    cmpw $actors_C_math_10357,%ax
    .intel_syntax noprefix
    {disp32} jl actors_C_flow_10562
    .att_syntax prefix
    cmpw $actors_C_math_10367,%ax
    .intel_syntax noprefix
    {disp32} jge actors_C_flow_10562
    movsx eax, word ptr [_screenpeek]
    imul eax, eax, 0x552
    movsx eax, word ptr [eax + _ps + 724]
    imul eax, eax, 0x2c
    {store} mov edx, esi
    add eax, OFFSET FLAT:_sprite
    mov ecx, dword ptr [esp]
    call ldist_
    mov dword ptr [esp + 4], eax
    {store} cmp eax, ecx
    jge actors_C_flow_10480
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov ebp, dword ptr [eax + _hittype + 47]
    {store} mov edx, eax
    test ebp, ebp
    jne actors_C_flow_10480
    movsx eax, word ptr [esi + 38]
    sub eax, 0x3e8
    call FX_SetReverb_
    mov dword ptr [edx + _hittype + 47], 1
actors_C_flow_10480:
    mov eax, dword ptr [esp + 4]
    cmp eax, dword ptr [esp]
    {disp32} jl actors_C_flow_11309
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov ebx, dword ptr [eax + _hittype + 47]
    {store} mov edx, eax
    cmp ebx, 1
    {disp32} jne actors_C_flow_11309
    {store} xor eax, eax
    call FX_SetReverb_
    {store} xor eax, eax
    {store} xor ecx, ecx
    call FX_SetReverbDelay_
    mov dword ptr [edx + _hittype + 47], ecx
    mov edi, dword ptr [esp + 8]
    {disp32} jmp actors_C_flow_10176
actors_C_flow_10562:
    cmp word ptr [esi + 38], 0x3e7
    {disp32} jge actors_C_flow_11309
    movsx edx, word ptr [esi + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    movsx eax, word ptr [eax*8 + _sector + 34]
    cmp eax, 9
    {disp32} jae actors_C_flow_11309
    cmp dword ptr [_AmbienceToggle], 0
    {disp32} je actors_C_flow_11309
    movsx ecx, di
    imul eax, ecx, 0x2c
    movsx edx, word ptr [eax + _sprite + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov edx, dword ptr [eax*8 + _sector + 8]
    cmp edx, dword ptr [eax*8 + _sector + 4]
    {disp32} je actors_C_flow_11309
    movsx eax, word ptr [esi + 38]
    test byte ptr [eax + _soundm], 2
    {disp32} je actors_C_flow_11084
    movsx eax, word ptr [_screenpeek]
    imul eax, eax, 0x552
    movsx eax, word ptr [eax + _ps + 724]
    imul eax, eax, 0x2c
    {store} mov edx, esi
    add eax, OFFSET FLAT:_sprite
    mov ebp, dword ptr [esp]
    call dist_
    mov dword ptr [esp + 4], eax
    {store} cmp eax, ebp
    {disp32} jge actors_C_flow_11028
    {disp32} lea eax, dword ptr [ecx*8]
    {store} add eax, ecx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ecx
    cmp dword ptr [eax + _hittype + 47], 0
    {disp32} jne actors_C_flow_11028
    movsx eax, word ptr [esi + 38]
    mov al, byte ptr [eax + _soundpr]
    and eax, 0xff
    dec eax
    call FX_VoiceAvailable_
    test eax, eax
    {disp32} je actors_C_flow_11028
    {store} xor eax, eax
    mov ebx, dword ptr [_NumVoices]
    mov al, byte ptr [_numenvsnds]
    {store} cmp eax, ebx
    {disp32} jne actors_C_flow_10984
    mov bx, word ptr [_headspritestat + 22]
actors_C_flow_10814:
    test bx, bx
    {disp32} jl actors_C_flow_10972
    movsx eax, di
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 14], 5
    {disp32} jne actors_C_flow_10956
    {store} cmp bx, di
    je actors_C_flow_10956
    movsx ecx, bx
    imul ebp, ecx, 0x2c
    cmp word ptr [ebp + _sprite + 38], 0x3e7
    jge actors_C_flow_10956
    {disp32} lea eax, dword ptr [ecx*8]
    {store} add eax, ecx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ecx
    cmp dword ptr [eax + _hittype + 47], 1
    jne actors_C_flow_10956
    movsx eax, word ptr [_screenpeek]
    imul eax, eax, 0x552
    movsx eax, word ptr [eax + _ps + 724]
    imul eax, eax, 0x2c
    mov edx, OFFSET FLAT:_sprite
    {store} add edx, eax
    mov eax, OFFSET FLAT:_sprite
    {store} add eax, ebp
    call dist_
    cmp eax, dword ptr [esp + 4]
    jle actors_C_flow_10956
    {store} mov edx, ecx
    movsx eax, word ptr [ebp + _sprite + 38]
    call stopenvsound_
    jmp actors_C_flow_10972
actors_C_flow_10956:
    movsx eax, bx
    mov bx, word ptr [eax*2 + _nextspritestat]
    {disp32} jmp actors_C_flow_10814
actors_C_flow_10972:
    movsx eax, bx
    cmp eax, -1
    {disp32} je actors_C_flow_11309
actors_C_flow_10984:
    movsx ecx, di
    {store} xor eax, eax
    {store} mov edx, ecx
    mov ax, word ptr [esi + 38]
    call spritesound_
    {disp32} lea eax, dword ptr [ecx*8]
    {store} add eax, ecx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ecx
    mov dword ptr [eax + _hittype + 47], 1
actors_C_flow_11028:
    mov eax, dword ptr [esp + 4]
    cmp eax, dword ptr [esp]
    jl actors_C_flow_11084
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    cmp dword ptr [eax + _hittype + 47], 1
    jne actors_C_flow_11084
    {store} xor ebx, ebx
    mov dword ptr [eax + _hittype + 47], ebx
    movsx eax, word ptr [esi + 38]
    call stopenvsound_
actors_C_flow_11084:
    movsx eax, word ptr [esi + 38]
    test byte ptr [eax + _soundm], 0x10
    {disp32} je actors_C_flow_11309
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov ecx, dword ptr [eax + _hittype + 63]
    test ecx, ecx
    jle actors_C_flow_11150
    lea esi, dword ptr [ecx + -1]
    mov dword ptr [eax + _hittype + 63], esi
    mov edi, dword ptr [esp + 8]
    {disp32} jmp actors_C_flow_10176
actors_C_flow_11150:
    mov cx, word ptr [_connecthead]
    test cx, cx
    jge actors_C_flow_11171
    mov edi, dword ptr [esp + 8]
    {disp32} jmp actors_C_flow_10176
actors_C_flow_11171:
    mov dx, word ptr [_myconnectindex]
    {store} cmp cx, dx
    jne actors_C_flow_11289
    movsx eax, dx
    imul eax, eax, 0x552
    mov bx, word ptr [esi + 24]
    cmp bx, word ptr [eax + _ps + 646]
    jne actors_C_flow_11289
    movsx edx, word ptr [esi + 40]
    lea ebp, dword ptr [edx + 1]
    movsx eax, word ptr [_global_random]
    {store} xor edx, edx
    div ebp
    movsx eax, word ptr [esi + 38]
    {store} add eax, edx
    cwde
    call sound_
    movsx edx, word ptr [_global_random]
    mov ebp, 0x410
    {store} mov eax, edx
    sar edx, 0x1f
    idiv ebp
    {store} mov ebp, edx
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    add ebp, 0x410
    mov dword ptr [eax + _hittype + 63], ebp
actors_C_flow_11289:
    movsx eax, cx
    mov cx, word ptr [eax*2 + _connectpoint2]
    test cx, cx
    {disp32} jge actors_C_flow_11171
actors_C_flow_11309:
    mov edi, dword ptr [esp + 8]
    {disp32} jmp actors_C_flow_10176
actors_C_flow_11318:
    add esp, 0xc
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
movefallers_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    sub esp, 0xc
    mov ax, word ptr [_headspritestat + 24]
actors_C_flow_11343:
    mov dword ptr [esp + 4], eax
    mov edx, dword ptr [esp + 4]
    test dx, dx
    jl actors_C_flow_11318
    movsx ebx, dx
    imul edi, ebx, 0x2c
    mov ax, word ptr [ebx*2 + _nextspritestat]
    mov dword ptr [esp + 8], eax
    {disp32} lea eax, dword ptr [ebx*8]
    {store} add eax, ebx
    {disp32} lea eax, dword ptr [eax*8]
    add edi, OFFSET FLAT:_sprite
    {store} sub eax, ebx
    mov cx, word ptr [edi + 24]
    mov esi, dword ptr [eax + _hittype + 47]
    {store} mov edx, eax
    test esi, esi
    {disp32} jne actors_C_flow_11738
    mov ecx, dword ptr [edi + 8]
    sub ecx, 0x1000
    movsx eax, word ptr [edi + 28]
    mov dword ptr [edi + 8], ecx
    mov dword ptr [edx + _hittype + 51], eax
    movsx eax, word ptr [edi + 42]
    mov dword ptr [esp], eax
    {store} mov eax, ebx
    call ifhitbyweapon_
    test ax, ax
    {disp32} jl actors_C_flow_11683
    .att_syntax prefix
    cmpw $actors_C_math_11463,%ax
    .intel_syntax noprefix
    je actors_C_flow_11497
    .att_syntax prefix
    cmpw $actors_C_math_11469,%ax
    .intel_syntax noprefix
    je actors_C_flow_11497
    .att_syntax prefix
    cmpw $actors_C_math_11475,%ax
    .intel_syntax noprefix
    je actors_C_flow_11497
    .att_syntax prefix
    cmpw $actors_C_math_11481,%ax
    .intel_syntax noprefix
    je actors_C_flow_11497
    .att_syntax prefix
    cmpw $actors_C_math_11487,%ax
    .intel_syntax noprefix
    {disp32} jne actors_C_flow_11667
actors_C_flow_11497:
    cmp word ptr [edi + 42], 0
    {disp32} jg actors_C_flow_11683
    movsx edx, word ptr [esp + 4]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov dword ptr [eax + _hittype + 47], 1
    mov si, word ptr [_headspritestat + 24]
actors_C_flow_11548:
    test si, si
    {disp32} jl actors_C_flow_11683
    movsx ebx, si
    imul edx, ebx, 0x2c
    movsx eax, word ptr [esp + 4]
    imul eax, eax, 0x2c
    mov cx, word ptr [edx + _sprite + 40]
    cmp cx, word ptr [eax + _sprite + 40]
    jne actors_C_flow_11654
    {disp32} lea eax, dword ptr [ebx*8]
    {store} add eax, ebx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ebx
    mov dword ptr [eax + _hittype + 47], 1
    and byte ptr [edx + _sprite + 12], 0xbf
    mov ax, word ptr [edx + _sprite + 14]
    .att_syntax prefix
    cmpw $actors_C_math_11629,%ax
    .intel_syntax noprefix
    je actors_C_flow_11641
    .att_syntax prefix
    cmpw $actors_C_math_11635,%ax
    .intel_syntax noprefix
    jne actors_C_flow_11654
actors_C_flow_11641:
    movsx eax, si
    imul eax, eax, 0x2c
    or byte ptr [eax + _sprite + 13], 0x80
actors_C_flow_11654:
    movsx esi, si
    mov si, word ptr [esi*2 + _nextspritestat]
    jmp actors_C_flow_11548
actors_C_flow_11667:
    {store} xor ebx, ebx
    mov eax, dword ptr [esp]
    mov word ptr [edx + _hittype + 5], bx
    mov word ptr [edi + 42], ax
actors_C_flow_11683:
    movsx edx, word ptr [esp + 4]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov ecx, dword ptr [edi + 8]
    mov ax, word ptr [eax + _hittype + 51]
    add ecx, 0x1000
    mov word ptr [edi + 28], ax
    mov dword ptr [edi + 8], ecx
    mov eax, dword ptr [esp + 8]
    {disp32} jmp actors_C_flow_11343
actors_C_flow_11738:
    cmp esi, 1
    {disp32} jne actors_C_flow_12126
    mov si, word ptr [edi + 38]
    test si, si
    jle actors_C_flow_11809
    {store} mov eax, esi
    sub eax, 3
    mov word ptr [edi + 38], ax
    call krand_
    .att_syntax prefix
    addl $actors_C_math_11770,%eax
    .intel_syntax noprefix
    xor ah, ah
    and al, 0x7f
    mov word ptr [edi + 32], ax
    call krand_
    and ah, 3
    add ah, 4
    neg eax
    mov word ptr [edi + 36], ax
    mov eax, dword ptr [esp + 8]
    {disp32} jmp actors_C_flow_11343
actors_C_flow_11809:
    mov ax, word ptr [edi + 32]
    test ax, ax
    jle actors_C_flow_11839
    {store} mov edx, eax
    sub edx, 2
    {store} mov eax, ebx
    mov word ptr [edi + 32], dx
    mov edx, 0x10001
    call ssp_
actors_C_flow_11839:
    movsx eax, word ptr [edi + 24]
    call floorspace_
    test eax, eax
    je actors_C_flow_11859
    {store} xor ebx, ebx
    mov dword ptr [esp], ebx
    jmp actors_C_flow_11888
actors_C_flow_11859:
    movsx eax, word ptr [edi + 24]
    call ceilingspace_
    test eax, eax
    je actors_C_flow_11881
    mov dword ptr [esp], 0x1d
    jmp actors_C_flow_11888
actors_C_flow_11881:
    mov dword ptr [esp], 0xb0
actors_C_flow_11888:
    movsx edx, cx
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov eax, dword ptr [eax*8 + _sector + 8]
    mov esi, dword ptr [edi + 8]
    sub eax, 0x100
    {store} cmp eax, esi
    jle actors_C_flow_11952
    mov eax, dword ptr [esp]
    mov bx, word ptr [edi + 36]
    {store} add ebx, eax
    mov word ptr [edi + 36], bx
    cmp bx, 0x1800
    jle actors_C_flow_11945
    mov word ptr [edi + 36], 0x1800
actors_C_flow_11945:
    movsx eax, word ptr [edi + 36]
    add dword ptr [edi + 8], eax
actors_C_flow_11952:
    movsx edx, cx
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov eax, dword ptr [eax*8 + _sector + 8]
    sub eax, dword ptr [edi + 8]
    .att_syntax prefix
    cmpl $actors_C_math_11974,%eax
    .intel_syntax noprefix
    {disp32} jge actors_C_flow_12126
    call krand_
    {store} mov esi, eax
    {store} xor ebx, ebx
    and esi, 7
    mov dword ptr [esp], ebx
    inc esi
    jmp actors_C_flow_12106
actors_C_flow_12003:
    push 5
    movsx eax, word ptr [esp + 8]
    push eax
    mov edx, 0xfffffe00
    call krand_
    and eax, 0x7ff
    {store} sub edx, eax
    push edx
    call krand_
    xor ah, ah
    and al, 0x3f
    .att_syntax prefix
    addl $actors_C_math_12038,%eax
    .intel_syntax noprefix
    cwde
    push eax
    call krand_
    and ah, 7
    cwde
    push eax
    push 0x30
    push 0x30
    push -8
    call krand_
    xor ah, ah
    mov ecx, dword ptr [edi + 8]
    and al, 0xf
    mov ebx, dword ptr [edi + 4]
    .att_syntax prefix
    addl $actors_C_math_12076,%eax
    .intel_syntax noprefix
    mov edx, dword ptr [edi]
    cwde
    sub ecx, 0xc00
    push eax
    movsx eax, word ptr [edi + 24]
    call EGS_
    lea eax, dword ptr [ebp + 1]
    mov dword ptr [esp], eax
actors_C_flow_12106:
    mov ebp, dword ptr [esp]
    movsx eax, si
    {store} cmp eax, ebp
    jg actors_C_flow_12003
    movsx eax, word ptr [esp + 4]
    call deletesprite_
actors_C_flow_12126:
    mov eax, dword ptr [esp + 8]
    {disp32} jmp actors_C_flow_11343
    {disp32} lea eax, dword ptr [eax]
    {disp8} lea edx, dword ptr [edx]
movestandables_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    sub esp, 0x34
    mov di, word ptr [_headspritestat + 12]
actors_C_flow_12160:
    test di, di
    {disp32} jl actors_C_flow_19888
    movsx edx, di
    mov ax, word ptr [edx*2 + _nextspritestat]
    mov dword ptr [esp + 48], eax
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    imul ebx, edx, 0x2c
    mov esi, OFFSET FLAT:_sprite
    mov ebp, OFFSET FLAT:_hittype
    {store} add esi, ebx
    {store} add ebp, eax
    mov dword ptr [esp + 24], ebx
    mov bx, word ptr [esi + 24]
    add ebp, 0x2f
    test bx, bx
    jge actors_C_flow_12247
    {store} mov eax, edx
    call deletesprite_
    {disp32} jmp actors_C_flow_19879
actors_C_flow_12247:
    mov ecx, dword ptr [esi]
    mov dword ptr [eax + _hittype + 35], ecx
    mov ecx, dword ptr [esi + 4]
    mov dword ptr [eax + _hittype + 39], ecx
    mov ecx, dword ptr [esi + 8]
    mov dword ptr [eax + _hittype + 43], ecx
    mov eax, dword ptr [esp + 24]
    mov cx, word ptr [eax + _sprite + 14]
    cmp cx, 0x4c6
    {disp32} jl actors_C_flow_13774
    cmp cx, 0x4c9
    {disp32} jg actors_C_flow_13774
    cmp word ptr [esi + 32], 0
    je actors_C_flow_12320
    {store} mov eax, edx
    call getglobalz_
actors_C_flow_12320:
    {disp8} mov eax, dword ptr [ebp]
    test eax, eax
    {disp32} jne actors_C_flow_12502
    mov eax, dword ptr [ebp + 4]
    mov ax, word ptr [eax*2 + _headspritesect]
    mov word ptr [esp + 44], ax
actors_C_flow_12347:
    mov eax, dword ptr [esp + 44]
    test ax, ax
    {disp32} jl actors_C_flow_13321
    cwde
    mov dx, word ptr [eax*2 + _nextspritesect]
    imul eax, eax, 0x2c
    mov ax, word ptr [eax + _sprite + 26]
    .att_syntax prefix
    cmpw $actors_C_math_12379,%ax
    .intel_syntax noprefix
    jb actors_C_flow_12395
    jbe actors_C_flow_12407
    .att_syntax prefix
    cmpw $actors_C_math_12387,%ax
    .intel_syntax noprefix
    je actors_C_flow_12407
    jmp actors_C_flow_12492
actors_C_flow_12395:
    .att_syntax prefix
    cmpw $actors_C_math_12395,%ax
    .intel_syntax noprefix
    jb actors_C_flow_12492
    .att_syntax prefix
    cmpw $actors_C_math_12401,%ax
    .intel_syntax noprefix
    ja actors_C_flow_12492
actors_C_flow_12407:
    mov edx, dword ptr [ebp + 16]
    mov edi, dword ptr [esi + 4]
    mov ebx, dword ptr [edx*4 + _msy + 4]
    mov eax, dword ptr [edx*4 + _msx + 4]
    mov edx, dword ptr [esi]
    {store} sub ebx, edi
    {store} sub eax, edx
    {store} mov edx, ebx
    call getangle_
    mov word ptr [esi + 28], ax
    movsx eax, word ptr [esp + 44]
    imul ecx, eax, 0x2c
    mov edx, dword ptr [ebp + 16]
    mov ebx, dword ptr [edx*4 + _msy + 4]
    mov edx, dword ptr [edx*4 + _msx + 4]
    mov ecx, dword ptr [ecx + _sprite + 8]
    call setsprite_
    {disp8} inc dword ptr [ebp]
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_12492:
    mov word ptr [esp + 44], dx
    {disp32} jmp actors_C_flow_12347
actors_C_flow_12502:
    cmp eax, 1
    jne actors_C_flow_12565
    cmp word ptr [esi + 32], 0xb8
    jge actors_C_flow_12532
    mov cx, word ptr [esi + 32]
    mov word ptr [esi + 14], 0x4c7
    add ecx, 8
    mov word ptr [esi + 32], cx
actors_C_flow_12532:
    mov edx, 0x10001
    movsx eax, di
    call ssp_
    movsx eax, bx
    cmp eax, dword ptr [ebp + 4]
    {disp32} jne actors_C_flow_13321
    {disp8} inc dword ptr [ebp]
    {disp32} jmp actors_C_flow_13321
actors_C_flow_12565:
    cmp eax, 2
    je actors_C_flow_12579
    cmp eax, 7
    {disp32} jne actors_C_flow_12830
actors_C_flow_12579:
    add dword ptr [esi + 8], 0x600
    {disp8} cmp dword ptr [ebp], 2
    jne actors_C_flow_12673
    movsx edx, bx
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov eax, dword ptr [eax*8 + _sector + 8]
    sub eax, dword ptr [esi + 8]
    .att_syntax prefix
    cmpl $actors_C_math_12614,%eax
    .intel_syntax noprefix
    jge actors_C_flow_12639
    mov cx, word ptr [esi + 14]
    cmp cx, 0x4c6
    jle actors_C_flow_12639
    {store} mov eax, ecx
    dec eax
    mov word ptr [esi + 14], ax
actors_C_flow_12639:
    movsx edx, bx
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov ecx, dword ptr [esi + 8]
    mov eax, dword ptr [eax*8 + _sector + 8]
    {store} sub eax, ecx
    .att_syntax prefix
    cmpl $actors_C_math_12663,%eax
    .intel_syntax noprefix
    jge actors_C_flow_12673
    {disp8} inc dword ptr [ebp]
actors_C_flow_12673:
    {disp8} cmp dword ptr [ebp], 7
    {disp32} jne actors_C_flow_13321
    movsx edx, bx
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov ebx, dword ptr [esi + 8]
    mov eax, dword ptr [eax*8 + _sector + 8]
    {store} sub eax, ebx
    .att_syntax prefix
    cmpl $actors_C_math_12707,%eax
    .intel_syntax noprefix
    {disp32} jge actors_C_flow_13321
    mov dx, word ptr [esi + 14]
    cmp dx, 0x4c6
    jle actors_C_flow_12741
    {store} mov eax, edx
    dec eax
    mov word ptr [esi + 14], ax
    {disp32} jmp actors_C_flow_13321
actors_C_flow_12741:
    movsx eax, word ptr [esi + 30]
    cmp eax, -2
    jne actors_C_flow_12816
    movsx eax, word ptr [esp + 36]
    imul eax, eax, 0x552
    movsx edx, word ptr [eax + _ps + 724]
    mov eax, 0x26
    call spritesound_
    {store} mov edx, esp
    {store} mov eax, esi
    call findplayer_
    mov dword ptr [esp + 36], eax
    cwde
    imul eax, eax, 0x552
    cmp di, word ptr [eax + _ps + 722]
    jne actors_C_flow_12816
    mov word ptr [eax + _ps + 722], 0xffff
actors_C_flow_12816:
    {disp8} inc dword ptr [ebp]
    mov word ptr [esi + 30], 0xffff
    {disp32} jmp actors_C_flow_13321
actors_C_flow_12830:
    cmp eax, 3
    {disp32} jne actors_C_flow_13039
    mov dx, word ptr [esi + 14]
    inc edx
    mov word ptr [esi + 14], dx
    cmp dx, 0x4c8
    {disp32} jne actors_C_flow_13321
    movsx eax, word ptr [ebp + 4]
    call checkcursectnums_
    mov dword ptr [esp + 36], eax
    test ax, ax
    jl actors_C_flow_12941
    movsx ebx, ax
    imul ebx, ebx, 0x552
    cmp byte ptr [ebx + _ps + 1308], 0
    je actors_C_flow_12941
    mov word ptr [esi + 30], 0xfffe
    mov eax, 0x26
    movsx edx, word ptr [ebx + _ps + 724]
    mov word ptr [ebx + _ps + 722], di
    call spritesound_
    mov ax, word ptr [esi + 28]
    add ah, 4
    mov word ptr [ebx + _ps + 640], ax
    jmp actors_C_flow_13016
actors_C_flow_12941:
    mov eax, dword ptr [ebp + 4]
    mov ax, word ptr [eax*2 + _headspritesect]
actors_C_flow_12952:
    mov word ptr [esp + 44], ax
    mov ecx, dword ptr [esp + 44]
    test cx, cx
    jl actors_C_flow_13016
    movsx eax, cx
    imul eax, eax, 0x2c
    mov ax, word ptr [eax + _sprite + 26]
    .att_syntax prefix
    cmpw $actors_C_math_12979,%ax
    .intel_syntax noprefix
    jb actors_C_flow_13001
    jbe actors_C_flow_12993
    .att_syntax prefix
    cmpw $actors_C_math_12987,%ax
    .intel_syntax noprefix
    jne actors_C_flow_13001
actors_C_flow_12993:
    mov eax, dword ptr [esp + 44]
    mov word ptr [esi + 30], ax
actors_C_flow_13001:
    movsx eax, word ptr [esp + 44]
    mov ax, word ptr [eax*2 + _nextspritesect]
    jmp actors_C_flow_12952
actors_C_flow_13016:
    {disp8} mov ecx, dword ptr [ebp]
    mov dword ptr [ebp + 8], 0
    inc ecx
    {disp8} mov dword ptr [ebp], ecx
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_13039:
    cmp eax, 4
    jne actors_C_flow_13068
    mov ebx, dword ptr [ebp + 8]
    inc ebx
    mov dword ptr [ebp + 8], ebx
    cmp ebx, 0xa
    {disp32} jle actors_C_flow_13321
    {disp8} inc dword ptr [ebp]
    {disp32} jmp actors_C_flow_13321
actors_C_flow_13068:
    cmp eax, 5
    je actors_C_flow_13078
    cmp eax, 8
    jne actors_C_flow_13181
actors_C_flow_13078:
    {disp8} cmp dword ptr [ebp], 8
    jne actors_C_flow_13133
    mov cx, word ptr [esi + 14]
    cmp cx, 0x4c8
    jge actors_C_flow_13133
    movsx edx, bx
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov ebx, dword ptr [esi + 8]
    mov eax, dword ptr [eax*8 + _sector + 8]
    {store} sub eax, ebx
    .att_syntax prefix
    cmpl $actors_C_math_13119,%eax
    .intel_syntax noprefix
    jle actors_C_flow_13133
    {store} mov eax, ecx
    inc eax
    mov word ptr [esi + 14], ax
actors_C_flow_13133:
    mov eax, dword ptr [ebp + 16]
    {disp32} lea edx, dword ptr [eax*4]
    mov eax, dword ptr [esi + 8]
    cmp eax, dword ptr [edx + _msx + 8]
    jge actors_C_flow_13168
    {disp8} inc dword ptr [ebp]
    mov word ptr [esi + 32], 0
    {disp32} jmp actors_C_flow_13321
actors_C_flow_13168:
    sub eax, 0x600
    mov dword ptr [esi + 8], eax
    {disp32} jmp actors_C_flow_13321
actors_C_flow_13181:
    cmp eax, 6
    {disp32} jne actors_C_flow_13309
    mov ax, word ptr [esi + 32]
    .att_syntax prefix
    cmpw $actors_C_math_13194,%ax
    .intel_syntax noprefix
    jge actors_C_flow_13209
    {store} mov edx, eax
    add edx, 8
    mov word ptr [esi + 32], dx
actors_C_flow_13209:
    mov edx, dword ptr [ebp + 16]
    mov ebx, dword ptr [esi + 4]
    mov eax, dword ptr [edx*4 + _msy]
    {store} sub eax, ebx
    mov ecx, dword ptr [esi]
    {store} mov ebx, eax
    mov eax, dword ptr [edx*4 + _msx]
    {store} mov edx, ebx
    {store} sub eax, ecx
    call getangle_
    mov edx, 0x10001
    mov word ptr [esi + 28], ax
    movsx eax, di
    call ssp_
    mov edx, dword ptr [ebp + 16]
    mov eax, dword ptr [esi + 4]
    mov ebx, dword ptr [edx*4 + _msy]
    {store} sub eax, ebx
    {store} mov ebx, eax
    imul ebx, eax
    mov ecx, dword ptr [edx*4 + _msx]
    mov eax, dword ptr [esi]
    {store} sub eax, ecx
    imul eax, eax
    {store} add eax, ebx
    .att_syntax prefix
    cmpl $actors_C_math_13297,%eax
    .intel_syntax noprefix
    jge actors_C_flow_13321
    {disp8} inc dword ptr [ebp]
    jmp actors_C_flow_13321
actors_C_flow_13309:
    cmp eax, 9
    jne actors_C_flow_13321
    {disp8} mov dword ptr [ebp], 0
actors_C_flow_13321:
    mov ecx, dword ptr [esi + 8]
    mov ebx, dword ptr [esi + 4]
    mov eax, dword ptr [ebp + 16]
    mov edx, dword ptr [esi]
    sub ecx, 0x2200
    mov eax, dword ptr [eax*4 + _msy + 8]
    call setsprite_
    movsx eax, word ptr [esi + 30]
    cmp eax, -1
    {disp32} je actors_C_flow_19879
    {store} mov edx, esp
    {store} mov eax, esi
    call findplayer_
    {store} mov edx, eax
    mov dword ptr [esp + 36], eax
    movsx eax, di
    call ifhitbyweapon_
    test ax, ax
    jl actors_C_flow_13448
    movsx eax, word ptr [esi + 30]
    cmp eax, -2
    jne actors_C_flow_13427
    movsx eax, dx
    imul eax, eax, 0x552
    cmp di, word ptr [eax + _ps + 722]
    jne actors_C_flow_13427
    mov word ptr [eax + _ps + 722], 0xffff
actors_C_flow_13427:
    mov word ptr [esi + 30], 0xffff
    mov word ptr [esi + 14], 0x4c6
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_13448:
    mov bx, word ptr [esi + 30]
    test bx, bx
    {disp32} jl actors_C_flow_13591
    mov ecx, dword ptr [esi + 8]
    mov ebx, dword ptr [esi + 4]
    mov edx, dword ptr [esi]
    movsx eax, word ptr [esi + 30]
    call setsprite_
    movsx edx, word ptr [esi + 30]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    {store} mov edx, eax
    mov eax, dword ptr [esi]
    mov dword ptr [edx + _hittype + 35], eax
    movsx edx, word ptr [esi + 30]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    {store} mov edx, eax
    mov eax, dword ptr [esi + 4]
    mov dword ptr [edx + _hittype + 39], eax
    movsx edx, word ptr [esi + 30]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    {store} mov edx, eax
    mov eax, dword ptr [esi + 8]
    mov dword ptr [edx + _hittype + 43], eax
    mov word ptr [esi + 36], 0
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_13591:
    movsx eax, bx
    cmp eax, -2
    {disp32} jne actors_C_flow_19879
    movsx ebp, dx
    imul ebp, ebp, 0x552
    movsx eax, word ptr [ebp + _ps + 640]
    .att_syntax prefix
    addl $actors_C_math_13619,%eax
    .intel_syntax noprefix
    and eax, 0x7ff
    movsx eax, word ptr [eax*2 + _sintable]
    mov edx, dword ptr [esi]
    sar eax, 6
    {store} sub edx, eax
    mov ax, word ptr [ebp + _ps + 640]
    and ah, 7
    mov dword ptr [ebp + _ps + 532], edx
    cwde
    mov dword ptr [ebp + _ps + 568], edx
    movsx eax, word ptr [eax*2 + _sintable]
    mov edx, dword ptr [esi + 4]
    sar eax, 6
    {store} sub edx, eax
    mov dword ptr [ebp + _ps + 536], edx
    mov dword ptr [ebp + _ps + 572], edx
    mov eax, dword ptr [esi + 8]
    .att_syntax prefix
    addl $actors_C_math_13698,%eax
    .intel_syntax noprefix
    mov dword ptr [ebp + _ps + 540], eax
    mov ebx, dword ptr [ebp + _ps + 536]
    mov edx, dword ptr [ebp + _ps + 532]
    mov dword ptr [ebp + _ps + 576], eax
    {store} mov ecx, eax
    movsx eax, word ptr [ebp + _ps + 724]
    call setsprite_
    movsx eax, word ptr [ebp + _ps + 724]
    imul eax, eax, 0x2c
    mov ax, word ptr [eax + _sprite + 24]
    mov word ptr [ebp + _ps + 646], ax
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_13774:
    movsx eax, di
    imul eax, eax, 0x2c
    mov dx, word ptr [eax + _sprite + 14]
    cmp dx, 0x233
    {disp32} jl actors_C_flow_13928
    cmp dx, 0x236
    {disp32} jg actors_C_flow_13928
    {disp8} mov eax, dword ptr [ebp]
    test eax, eax
    {disp32} jle actors_C_flow_19879
    cmp eax, 0x14
    jge actors_C_flow_13866
    lea ecx, dword ptr [eax + 1]
    {disp8} mov dword ptr [ebp], ecx
    mov di, word ptr [esi + 14]
    inc edi
    mov word ptr [esi + 14], di
    cmp di, 0x236
    {disp32} jne actors_C_flow_19879
    mov word ptr [esi + 14], 0x234
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_13866:
    {store} mov edx, esp
    {store} mov eax, esi
    call findplayer_
    mov ebx, dword ptr [esp]
    mov dword ptr [esp + 36], eax
    cmp ebx, 0x200
    jle actors_C_flow_13912
    {disp8} mov dword ptr [ebp], 0
    mov word ptr [esi + 14], 0x233
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_13912:
    {disp8} mov dword ptr [ebp], 1
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_13928:
    mov ax, word ptr [esi + 14]
    .att_syntax prefix
    cmpw $actors_C_math_13932,%ax
    .intel_syntax noprefix
    je actors_C_flow_13966
    .att_syntax prefix
    cmpw $actors_C_math_13938,%ax
    .intel_syntax noprefix
    je actors_C_flow_13966
    .att_syntax prefix
    cmpw $actors_C_math_13944,%ax
    .intel_syntax noprefix
    je actors_C_flow_13966
    .att_syntax prefix
    cmpw $actors_C_math_13950,%ax
    .intel_syntax noprefix
    je actors_C_flow_13966
    .att_syntax prefix
    cmpw $actors_C_math_13956,%ax
    .intel_syntax noprefix
    {disp32} jne actors_C_flow_14443
actors_C_flow_13966:
    movsx ebx, di
    {disp32} lea eax, dword ptr [ebx*8]
    {store} add eax, ebx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ebx
    mov edx, dword ptr [eax + _hittype + 47]
    cmp edx, 1
    {disp32} jne actors_C_flow_19879
    mov ecx, dword ptr [eax + _hittype + 51]
    {store} add ecx, edx
    {store} mov edx, ecx
    and edx, 3
    mov dword ptr [eax + _hittype + 51], ecx
    test edx, edx
    {disp32} jg actors_C_flow_19879
    cmp word ptr [esi + 14], 0x3de
    jne actors_C_flow_14073
    cmp ecx, 0x20
    jne actors_C_flow_14073
    mov edx, 0x4ca
    {store} mov eax, ebx
    mov word ptr [esi + 12], 0
    call spawn_
    cwde
    imul eax, eax, 0x2c
    mov byte ptr [eax + _sprite + 16], 0x7f
    jmp actors_C_flow_14104
actors_C_flow_14073:
    mov al, byte ptr [esi + 16]
    cmp al, 0x40
    jl actors_C_flow_14097
    movsx eax, di
    call deletesprite_
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_14097:
    {store} mov ah, al
    inc ah
    mov byte ptr [esi + 16], ah
actors_C_flow_14104:
    {store} xor edx, edx
    mov dl, byte ptr [esi + 20]
    call krand_
    xor ah, ah
    and al, 7
    {store} sub edx, eax
    mov word ptr [esp + 44], dx
    cmp dx, 0xa
    jge actors_C_flow_14148
    movsx eax, di
    call deletesprite_
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_14148:
    cmp dx, 0x20
    {disp32} jge actors_C_flow_14376
    test byte ptr [_global_random], 1
    {disp32} je actors_C_flow_14376
    movsx eax, word ptr [esi + 26]
    mov ax, word ptr [eax*2 + _headspritestat]
    mov dword ptr [esp + 32], eax
actors_C_flow_14187:
    mov ecx, dword ptr [esp + 32]
    test cx, cx
    {disp32} jl actors_C_flow_14376
    movsx eax, cx
    mov cx, word ptr [eax*2 + _nextspritestat]
    cmp di, word ptr [esp + 32]
    {disp32} je actors_C_flow_14367
    movsx eax, word ptr [esp + 44]
    imul eax, eax, 0x2c
    mov dx, word ptr [eax + _sprite + 14]
    cmp dx, 0x38c
    je actors_C_flow_14272
    cmp dx, 0x38e
    je actors_C_flow_14272
    cmp dx, 0x3b7
    je actors_C_flow_14272
    cmp dx, 0x3de
    je actors_C_flow_14272
    cmp dx, 0x3d2
    jne actors_C_flow_14367
actors_C_flow_14272:
    movsx ebx, word ptr [esp + 32]
    imul edx, ebx, 0x2c
    {store} mov eax, esi
    add edx, OFFSET FLAT:_sprite
    call dist_
    .att_syntax prefix
    cmpl $actors_C_math_14293,%eax
    .intel_syntax noprefix
    jge actors_C_flow_14367
    {disp32} lea eax, dword ptr [ebx*8]
    {store} add eax, ebx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ebx
    mov dword ptr [eax + _hittype + 47], 1
    call krand_
    test al, 1
    je actors_C_flow_14352
    mov edx, 0x8df
    movsx eax, di
    call spawn_
    jmp actors_C_flow_14376
actors_C_flow_14352:
    mov edx, 0x907
    movsx eax, di
    call spawn_
    jmp actors_C_flow_14376
actors_C_flow_14367:
    mov dword ptr [esp + 32], ecx
    {disp32} jmp actors_C_flow_14187
actors_C_flow_14376:
    {store} xor edx, edx
    mov al, byte ptr [esp + 44]
    mov dl, byte ptr [esi + 21]
    mov byte ptr [esi + 20], al
    call krand_
    xor ah, ah
    and al, 7
    {store} sub edx, eax
    mov word ptr [esp + 44], dx
    cmp dx, 4
    jge actors_C_flow_14427
actors_C_flow_14410:
    movsx eax, di
    call deletesprite_
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_14427:
    mov al, byte ptr [esp + 44]
    mov byte ptr [esi + 21], al
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_14443:
    .att_syntax prefix
    cmpw $actors_C_math_14443,%ax
    .intel_syntax noprefix
    {disp32} jne actors_C_flow_15744
    movsx ebx, di
    {disp32} lea eax, dword ptr [ebx*8]
    {store} add eax, ebx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ebx
    mov ecx, dword ptr [eax + _hittype + 55]
    {store} mov edx, eax
    test ecx, ecx
    {disp32} jle actors_C_flow_14806
    dec ecx
    mov dword ptr [eax + _hittype + 55], ecx
    cmp ecx, 8
    {disp32} jne actors_C_flow_19879
    mov eax, 0x11
    {store} mov edx, ebx
    call spritesound_
    {store} xor eax, eax
    mov word ptr [esp + 44], ax
    jmp actors_C_flow_14627
actors_C_flow_14527:
    push 5
    movsx eax, di
    push eax
    mov edx, 0xfffffe00
    call krand_
    and eax, 0x7ff
    {store} sub edx, eax
    push edx
    call krand_
    xor ah, ah
    and al, 0x3f
    .att_syntax prefix
    addl $actors_C_math_14560,%eax
    .intel_syntax noprefix
    cwde
    push eax
    call krand_
    and ah, 7
    cwde
    push eax
    push 0x30
    push 0x30
    push -8
    call krand_
    xor ah, ah
    mov ecx, dword ptr [esi + 8]
    and al, 0xf
    mov ebx, dword ptr [esi + 4]
    .att_syntax prefix
    addl $actors_C_math_14598,%eax
    .intel_syntax noprefix
    mov edx, dword ptr [esi]
    cwde
    sub ecx, 0xc00
    push eax
    movsx eax, word ptr [esi + 24]
    call EGS_
    inc word ptr [esp + 44]
actors_C_flow_14627:
    cmp word ptr [esp + 44], 5
    jl actors_C_flow_14527
    movsx eax, word ptr [esi + 42]
    mov edx, dword ptr [_tripbombblastradius]
    mov dword ptr [esp], eax
    {store} mov ebx, eax
    {store} mov ecx, eax
    sar ebx, 2
    push eax
    {store} sub eax, ebx
    movsx ebp, di
    push eax
    sar ecx, 1
    {store} mov eax, ebp
    call hitradius_
    mov edx, 0x762
    {store} mov eax, ebp
    call spawn_
    mov word ptr [esp + 44], ax
    cwde
    imul edx, eax, 0x2c
    mov bx, word ptr [esi + 28]
    mov word ptr [edx + _sprite + 28], bx
    mov word ptr [edx + _sprite + 32], 0x15c
    mov edx, 0x10001
    call ssp_
    mov ax, word ptr [_headspritestat + 10]
actors_C_flow_14728:
    mov word ptr [esp + 44], ax
    mov eax, dword ptr [esp + 44]
    test ax, ax
    {disp32} jl actors_C_flow_14410
    cwde
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 14], 0xa07
    jne actors_C_flow_14791
    mov dx, word ptr [esi + 40]
    mov bx, word ptr [eax + _sprite + 40]
    {store} cmp dx, bx
    jne actors_C_flow_14791
    xor dl, bl
    mov byte ptr [eax + _sprite + 21], dl
    mov byte ptr [eax + _sprite + 20], dl
actors_C_flow_14791:
    movsx eax, word ptr [esp + 44]
    mov ax, word ptr [eax*2 + _nextspritestat]
    jmp actors_C_flow_14728
actors_C_flow_14806:
    movsx eax, word ptr [esi + 42]
    mov dword ptr [esp], eax
    movsx eax, word ptr [esi + 28]
    mov dword ptr [esp + 12], eax
    {store} mov eax, ebx
    mov word ptr [esi + 42], 1
    call ifhitbyweapon_
    test ax, ax
    jl actors_C_flow_14849
    mov dword ptr [edx + _hittype + 55], 0x10
actors_C_flow_14849:
    movsx edx, di
    {disp32} lea ebx, dword ptr [edx*8]
    mov eax, dword ptr [esp]
    {store} add ebx, edx
    mov word ptr [esi + 42], ax
    {disp32} lea ebx, dword ptr [ebx*8]
    mov eax, dword ptr [esp + 12]
    {store} sub ebx, edx
    mov word ptr [esi + 28], ax
    cmp dword ptr [ebx + _hittype + 47], 0x20
    jge actors_C_flow_14946
    {store} mov edx, esp
    {store} mov eax, esi
    call findplayer_
    mov edx, dword ptr [esp]
    mov dword ptr [esp + 36], eax
    cmp edx, 0x300
    jle actors_C_flow_14926
    inc dword ptr [ebx + _hittype + 47]
    jmp actors_C_flow_14946
actors_C_flow_14926:
    mov ecx, dword ptr [ebx + _hittype + 47]
    cmp ecx, 0x10
    jle actors_C_flow_14946
    lea ebp, dword ptr [ecx + 1]
    mov dword ptr [ebx + _hittype + 47], ebp
actors_C_flow_14946:
    movsx eax, di
    mov dword ptr [esp + 16], eax
    {disp32} lea ebp, dword ptr [eax*8]
    {store} add ebp, eax
    {disp32} lea ebp, dword ptr [ebp*8]
    {store} sub ebp, eax
    cmp dword ptr [ebp + _hittype + 47], 0x20
    {disp32} jne actors_C_flow_15496
    movsx eax, word ptr [esi + 28]
    mov dword ptr [esp + 12], eax
    mov ax, word ptr [ebp + _hittype + 67]
    mov word ptr [esi + 28], ax
    mov eax, dword ptr [esi]
    mov dword ptr [ebp + _hittype + 59], eax
    mov eax, dword ptr [esi + 4]
    mov dword ptr [ebp + _hittype + 63], eax
    mov eax, dword ptr [ebp + _hittype + 67]
    .att_syntax prefix
    addl $actors_C_math_15026,%eax
    .intel_syntax noprefix
    and eax, 0x7ff
    movsx eax, word ptr [eax*2 + _sintable]
    mov ebx, dword ptr [esi]
    sar eax, 9
    {store} add ebx, eax
    mov dword ptr [esi], ebx
    mov eax, dword ptr [ebp + _hittype + 67]
    and eax, 0x7ff
    movsx eax, word ptr [eax*2 + _sintable]
    mov ecx, dword ptr [esi + 4]
    sar eax, 9
    mov edx, dword ptr [esi]
    {store} add ecx, eax
    mov eax, dword ptr [esi + 8]
    mov dword ptr [esi + 4], ecx
    sub eax, 0x300
    mov ebx, dword ptr [esi + 4]
    {store} mov ecx, eax
    mov dword ptr [esi + 8], eax
    mov eax, dword ptr [esp + 16]
    call setsprite_
    lea edx, dword ptr [esp + 40]
    mov eax, dword ptr [esp + 16]
    call hitasprite_
    mov dword ptr [esp], eax
    mov dword ptr [ebp + _hittype + 27], eax
    mov eax, dword ptr [esp + 12]
    mov word ptr [esi + 28], ax
actors_C_flow_15140:
    cmp dword ptr [esp], 0
    {disp32} jle actors_C_flow_15370
    movsx eax, di
    mov edx, 0xa07
    mov dword ptr [esp + 8], eax
    call spawn_
    cwde
    mov dword ptr [esp + 4], eax
    imul ebp, eax, 0x2c
    mov ecx, dword ptr [ebp + _sprite + 8]
    mov ebx, dword ptr [ebp + _sprite + 4]
    mov edx, dword ptr [ebp + _sprite]
    call setsprite_
    mov ax, word ptr [esi + 40]
    mov edx, dword ptr [esp + 4]
    mov word ptr [ebp + _sprite + 40], ax
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    {store} mov edx, eax
    mov eax, dword ptr [ebp + _sprite + 8]
    mov dword ptr [edx + _hittype + 51], eax
    mov edx, dword ptr [esp + 8]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov edx, dword ptr [eax + _hittype + 67]
    add edx, 0x200
    and edx, 0x7ff
    movsx edx, word ptr [edx*2 + _sintable]
    mov ecx, dword ptr [esi]
    sar edx, 4
    {store} add ecx, edx
    mov dword ptr [esi], ecx
    mov eax, dword ptr [eax + _hittype + 67]
    and eax, 0x7ff
    movsx eax, word ptr [eax*2 + _sintable]
    mov edx, dword ptr [esi + 4]
    sar eax, 4
    {store} add edx, eax
    mov dword ptr [esi + 4], edx
    mov ebx, dword ptr [esp]
    cmp ebx, 0x400
    jge actors_C_flow_15356
    {store} mov eax, ebx
    sar eax, 5
    mov byte ptr [ebp + _sprite + 20], al
    jmp actors_C_flow_15370
actors_C_flow_15356:
    lea ecx, dword ptr [ebx + -1024]
    mov dword ptr [esp], ecx
    {disp32} jmp actors_C_flow_15140
actors_C_flow_15370:
    movsx eax, di
    mov dword ptr [esp + 20], eax
    {disp32} lea ebp, dword ptr [eax*8]
    {store} add ebp, eax
    {disp32} lea ebp, dword ptr [ebp*8]
    {store} sub ebp, eax
    inc dword ptr [ebp + _hittype + 47]
    mov eax, dword ptr [ebp + _hittype + 59]
    mov dword ptr [esi], eax
    mov edx, dword ptr [esi + 8]
    mov eax, dword ptr [ebp + _hittype + 63]
    add edx, 0x300
    mov dword ptr [esi + 4], eax
    {store} mov ecx, edx
    mov dword ptr [esi + 8], edx
    mov eax, dword ptr [esp + 20]
    mov ebx, dword ptr [esi + 4]
    mov edx, dword ptr [esi]
    call setsprite_
    {store} xor ebx, ebx
    mov eax, dword ptr [esp + 40]
    mov dword ptr [ebp + _hittype + 59], ebx
    test ax, ax
    jl actors_C_flow_15490
    mov eax, 0xd
    mov edx, dword ptr [esp + 20]
    mov dword ptr [ebp + _hittype + 55], eax
    mov eax, 0x10
    call spritesound_
    jmp actors_C_flow_15496
actors_C_flow_15490:
    mov dword ptr [ebp + _hittype + 55], ebx
actors_C_flow_15496:
    movsx edi, di
    {disp32} lea ebp, dword ptr [edi*8]
    {store} add ebp, edi
    {disp32} lea ebp, dword ptr [ebp*8]
    {store} sub ebp, edi
    cmp dword ptr [ebp + _hittype + 47], 0x21
    {disp32} jne actors_C_flow_19879
    inc dword ptr [ebp + _hittype + 51]
    mov eax, dword ptr [esi]
    mov dword ptr [ebp + _hittype + 59], eax
    mov eax, dword ptr [esi + 4]
    mov dword ptr [ebp + _hittype + 63], eax
    mov eax, dword ptr [ebp + _hittype + 67]
    .att_syntax prefix
    addl $actors_C_math_15559,%eax
    .intel_syntax noprefix
    and eax, 0x7ff
    movsx eax, word ptr [eax*2 + _sintable]
    mov ecx, dword ptr [esi]
    sar eax, 9
    {store} add ecx, eax
    mov dword ptr [esi], ecx
    mov eax, dword ptr [ebp + _hittype + 67]
    and eax, 0x7ff
    mov edx, dword ptr [esi + 4]
    mov ebx, dword ptr [esi + 8]
    movsx eax, word ptr [eax*2 + _sintable]
    sub ebx, 0x300
    sar eax, 9
    mov dword ptr [esi + 8], ebx
    {store} add edx, eax
    {store} mov ecx, ebx
    mov dword ptr [esi + 4], edx
    {store} mov eax, edi
    mov ebx, dword ptr [esi + 4]
    mov edx, dword ptr [esi]
    call setsprite_
    lea edx, dword ptr [esp + 40]
    {store} mov eax, edi
    call hitasprite_
    mov dword ptr [esp], eax
    mov eax, dword ptr [ebp + _hittype + 59]
    mov ecx, dword ptr [esi + 8]
    mov dword ptr [esi], eax
    add ecx, 0x300
    mov eax, dword ptr [ebp + _hittype + 63]
    mov edx, dword ptr [esi]
    mov dword ptr [esi + 4], eax
    {store} mov eax, edi
    mov ebx, dword ptr [esi + 4]
    mov dword ptr [esi + 8], ecx
    call setsprite_
    mov esi, dword ptr [esp]
    cmp esi, dword ptr [ebp + _hittype + 27]
    {disp32} je actors_C_flow_19879
    mov eax, 0xd
    {store} mov edx, edi
    mov dword ptr [ebp + _hittype + 55], eax
    mov eax, 0x10
    call spritesound_
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_15744:
    .att_syntax prefix
    cmpw $actors_C_math_15744,%ax
    .intel_syntax noprefix
    {disp32} jl actors_C_flow_15964
    .att_syntax prefix
    cmpw $actors_C_math_15754,%ax
    .intel_syntax noprefix
    {disp32} jg actors_C_flow_15964
    cmp word ptr [esi + 40], 0
    {disp32} jle actors_C_flow_19879
    movsx eax, word ptr [esi + 12]
    {disp8} mov dword ptr [ebp], eax
    movsx eax, word ptr [esi + 28]
    mov dword ptr [ebp + 4], eax
    movsx eax, di
    call ifhitbyweapon_
    .att_syntax prefix
    cmpw $actors_C_math_15797,%ax
    .intel_syntax noprefix
    je actors_C_flow_15827
    .att_syntax prefix
    cmpw $actors_C_math_15803,%ax
    .intel_syntax noprefix
    je actors_C_flow_15827
    .att_syntax prefix
    cmpw $actors_C_math_15809,%ax
    .intel_syntax noprefix
    je actors_C_flow_15827
    .att_syntax prefix
    cmpw $actors_C_math_15815,%ax
    .intel_syntax noprefix
    je actors_C_flow_15827
    .att_syntax prefix
    cmpw $actors_C_math_15821,%ax
    .intel_syntax noprefix
    jne actors_C_flow_15933
actors_C_flow_15827:
    mov ax, word ptr [_headspritestat + 12]
actors_C_flow_15833:
    mov word ptr [esp + 44], ax
    mov ebx, dword ptr [esp + 44]
    test bx, bx
    {disp32} jl actors_C_flow_16414
    movsx eax, bx
    imul eax, eax, 0x2c
    mov dx, word ptr [esi + 40]
    cmp dx, word ptr [eax + _sprite + 40]
    jne actors_C_flow_15918
    mov dx, word ptr [eax + _sprite + 14]
    cmp dx, 0x437
    je actors_C_flow_15891
    cmp dx, 0x4df
    jne actors_C_flow_15918
actors_C_flow_15891:
    movsx eax, word ptr [esp + 44]
    imul eax, eax, 0x2c
    movsx edx, byte ptr [eax + _sprite + 16]
    cmp edx, -32
    je actors_C_flow_15918
    mov byte ptr [eax + _sprite + 16], 0xe0
actors_C_flow_15918:
    movsx eax, word ptr [esp + 44]
    mov ax, word ptr [eax*2 + _nextspritestat]
    jmp actors_C_flow_15833
actors_C_flow_15933:
    {disp8} mov ax, word ptr [ebp]
    mov word ptr [esi + 12], ax
    mov ax, word ptr [ebp + 4]
    mov word ptr [esi + 42], 0
    mov word ptr [esi + 28], ax
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_15964:
    mov cx, word ptr [esi + 14]
    cmp cx, 0x394
    {disp32} jne actors_C_flow_16589
    movsx eax, di
    call ifhitbyweapon_
    mov word ptr [esp + 44], ax
    cwde
    cmp eax, -1
    {disp32} je actors_C_flow_19879
    {store} xor ebx, ebx
    mov dword ptr [esp + 32], ebx
    {disp32} jmp actors_C_flow_16167
actors_C_flow_16013:
    push 5
    movsx ebx, di
    push ebx
    imul ebx, ebx, 0x2c
    movsx edx, word ptr [ebx + _sprite + 36]
    call krand_
    and eax, 0xfff
    sar edx, 2
    neg eax
    {store} sub eax, edx
    push eax
    call krand_
    xor ah, ah
    and al, 0x3f
    .att_syntax prefix
    addl $actors_C_math_16056,%eax
    .intel_syntax noprefix
    cwde
    push eax
    call krand_
    and ah, 7
    cwde
    push eax
    push 0x30
    push 0x30
    push -8
    call krand_
    xor ah, ah
    and al, 3
    .att_syntax prefix
    addl $actors_C_math_16088,%eax
    .intel_syntax noprefix
    cwde
    push eax
    call krand_
    {store} mov edx, eax
    mov ecx, 0x3000
    sar edx, 0x1f
    idiv ecx
    mov eax, dword ptr [ebx + _sprite + 4]
    mov ecx, dword ptr [ebx + _sprite + 8]
    mov dword ptr [esp + 44], eax
    {store} sub ecx, edx
    mov edx, dword ptr [ebx + _sprite]
    movsx eax, word ptr [ebx + _sprite + 24]
    mov ebx, dword ptr [esp + 44]
    call EGS_
    cwde
    imul eax, eax, 0x2c
    mov byte ptr [eax + _sprite + 17], 2
    inc dword ptr [esp + 32]
actors_C_flow_16167:
    cmp word ptr [esp + 32], 0x10
    {disp32} jl actors_C_flow_16013
    movsx eax, di
    mov edx, 0x762
    mov dword ptr [esp + 28], eax
    call spawn_
    mov edx, dword ptr [esp + 28]
    mov eax, 0xe
    call spritesound_
    mov edx, dword ptr [esp + 28]
    mov eax, 0x14
    call spritesound_
    cmp word ptr [esi + 40], 0
    {disp32} jle actors_C_flow_16542
    mov ax, word ptr [_headspritestat + 12]
actors_C_flow_16241:
    mov word ptr [esp + 44], ax
    mov ecx, dword ptr [esp + 44]
    test cx, cx
    jl actors_C_flow_16337
    movsx eax, cx
    imul eax, eax, 0x2c
    mov dx, word ptr [esi + 40]
    cmp dx, word ptr [eax + _sprite + 40]
    jne actors_C_flow_16322
    mov cx, word ptr [eax + _sprite + 14]
    cmp cx, 0x437
    je actors_C_flow_16295
    cmp cx, 0x4df
    jne actors_C_flow_16322
actors_C_flow_16295:
    movsx eax, word ptr [esp + 44]
    imul eax, eax, 0x2c
    movsx edx, byte ptr [eax + _sprite + 16]
    cmp edx, -32
    je actors_C_flow_16322
    mov byte ptr [eax + _sprite + 16], 0xe0
actors_C_flow_16322:
    movsx eax, word ptr [esp + 44]
    mov ax, word ptr [eax*2 + _nextspritestat]
    jmp actors_C_flow_16241
actors_C_flow_16337:
    movsx eax, word ptr [esi + 42]
    mov dword ptr [esp], eax
    movsx eax, di
    mov edx, 0x762
    mov dword ptr [esp + 8], eax
    call spawn_
    mov ecx, dword ptr [esp]
    {store} mov ebx, ecx
    {store} mov eax, ecx
    sar ebx, 2
    push ecx
    {store} sub eax, ebx
    sar ecx, 1
    push eax
    mov eax, dword ptr [esp + 8]
    {store} sub eax, ecx
    mov edx, dword ptr [_pipebombblastradius]
    {store} mov ecx, eax
    mov eax, dword ptr [esp + 16]
    call hitradius_
    mov edx, dword ptr [esp + 8]
    mov eax, 0xe
    call spritesound_
actors_C_flow_16414:
    mov ch, 0x10
    mov ax, word ptr [_headspritestat + 6]
    mov byte ptr [_earthquaketime], ch
actors_C_flow_16428:
    mov word ptr [esp + 44], ax
    mov ecx, dword ptr [esp + 44]
    test cx, cx
    {disp32} jl actors_C_flow_17113
    movsx ebx, cx
    imul edx, ebx, 0x2c
    mov ax, word ptr [esi + 40]
    cmp ax, word ptr [edx + _sprite + 40]
    {disp32} jne actors_C_flow_17095
    {disp32} lea eax, dword ptr [ebx*8]
    {store} add eax, ebx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ebx
    mov bx, word ptr [edx + _sprite + 38]
    cmp bx, 0xd
    {disp32} jne actors_C_flow_17028
    cmp dword ptr [eax + _hittype + 55], 0
    {disp32} jne actors_C_flow_17095
    mov dword ptr [eax + _hittype + 55], 1
    movsx eax, word ptr [esp + 44]
    mov ax, word ptr [eax*2 + _nextspritestat]
    jmp actors_C_flow_16428
actors_C_flow_16542:
    push 0x19
    mov ecx, 0xf
    mov ebx, 0xa
    push 0x14
    mov eax, dword ptr [esp + 36]
    mov edx, dword ptr [_seenineblastradius]
    call hitradius_
    mov eax, dword ptr [esp + 28]
    call deletesprite_
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_16589:
    cmp cx, 0x437
    je actors_C_flow_16621
    cmp cx, 0x4df
    je actors_C_flow_16621
    cmp cx, 0x4e0
    je actors_C_flow_16621
    cmp cx, 0x4e1
    {disp32} jne actors_C_flow_17349
actors_C_flow_16621:
    movsx eax, byte ptr [esi + 16]
    cmp eax, -32
    {disp32} je actors_C_flow_16815
    cmp eax, -33
    {disp32} je actors_C_flow_16815
    cmp byte ptr [esi + 20], 0
    je actors_C_flow_16672
    movsx eax, di
    call ifhitbyweapon_
    test ax, ax
    setge al
    xor ah, ah
    mov word ptr [esp + 44], ax
    jmp actors_C_flow_16679
actors_C_flow_16672:
    {store} xor edi, edi
    mov word ptr [esp + 44], di
actors_C_flow_16679:
    cmp word ptr [esp + 44], 0
    jne actors_C_flow_16700
    movsx eax, byte ptr [esi + 16]
    cmp eax, -31
    {disp32} jne actors_C_flow_19879
actors_C_flow_16700:
    cmp word ptr [esp + 44], 0
    je actors_C_flow_16714
    mov word ptr [esi + 38], 0
actors_C_flow_16714:
    mov dword ptr [ebp + 12], 1
    mov ax, word ptr [_headspritestat + 12]
actors_C_flow_16727:
    mov word ptr [esp + 44], ax
    mov edi, dword ptr [esp + 44]
    test di, di
    {disp32} jl actors_C_flow_19879
    movsx eax, di
    imul eax, eax, 0x2c
    mov dx, word ptr [esi + 40]
    cmp dx, word ptr [eax + _sprite + 40]
    jne actors_C_flow_16800
    mov cx, word ptr [eax + _sprite + 14]
    cmp cx, 0x4df
    je actors_C_flow_16785
    cmp cx, 0x437
    jne actors_C_flow_16800
actors_C_flow_16785:
    movsx eax, word ptr [esp + 44]
    imul eax, eax, 0x2c
    mov byte ptr [eax + _sprite + 16], 0xe0
actors_C_flow_16800:
    movsx eax, word ptr [esp + 44]
    mov ax, word ptr [eax*2 + _nextspritestat]
    jmp actors_C_flow_16727
actors_C_flow_16815:
    movsx eax, byte ptr [esi + 16]
    cmp eax, -32
    jne actors_C_flow_16879
    mov dx, word ptr [esi + 38]
    test dx, dx
    jle actors_C_flow_16866
    {store} mov ebx, edx
    sub ebx, 3
    mov word ptr [esi + 38], bx
    test bx, bx
    {disp32} jg actors_C_flow_19879
    mov word ptr [esi + 38], 0xff9d
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_16866:
    mov byte ptr [esi + 16], 0xdf
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_16879:
    cmp byte ptr [esi + 20], 0
    {disp32} jbe actors_C_flow_16414
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov edx, dword ptr [eax + _hittype + 55]
    inc edx
    mov dword ptr [eax + _hittype + 55], edx
    cmp edx, 3
    {disp32} jne actors_C_flow_19879
    mov dx, word ptr [esi + 14]
    cmp dx, 0x437
    jne actors_C_flow_16956
    {store} xor edx, edx
    mov dword ptr [eax + _hittype + 55], edx
    {disp32} jmp actors_C_flow_16414
actors_C_flow_16956:
    cmp dx, 0x4e1
    {disp32} je actors_C_flow_16414
    {store} xor ecx, ecx
    mov dword ptr [eax + _hittype + 55], ecx
    mov cx, word ptr [esi + 14]
    cmp cx, 0x4e0
    jne actors_C_flow_17002
    {store} mov eax, ecx
    inc eax
    mov word ptr [esi + 14], ax
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_17002:
    cmp cx, 0x4df
    {disp32} jne actors_C_flow_19879
    mov word ptr [esi + 14], 0x4e0
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_17028:
    cmp bx, 8
    jne actors_C_flow_17062
    mov dword ptr [eax + _hittype + 63], 1
    movsx eax, word ptr [esp + 44]
    mov ax, word ptr [eax*2 + _nextspritestat]
    {disp32} jmp actors_C_flow_16428
actors_C_flow_17062:
    cmp bx, 0x12
    jne actors_C_flow_17079
    cmp dword ptr [eax + _hittype + 47], 0
    jne actors_C_flow_17095
    jmp actors_C_flow_17085
actors_C_flow_17079:
    cmp bx, 0x15
    jne actors_C_flow_17095
actors_C_flow_17085:
    mov dword ptr [eax + _hittype + 47], 1
actors_C_flow_17095:
    movsx eax, word ptr [esp + 44]
    mov ax, word ptr [eax*2 + _nextspritestat]
    {disp32} jmp actors_C_flow_16428
actors_C_flow_17113:
    sub dword ptr [esi + 8], 0x2000
    cmp dword ptr [ebp + 12], 1
    jne actors_C_flow_17132
    cmp byte ptr [esi + 20], 0
    jne actors_C_flow_17141
actors_C_flow_17132:
    movsx eax, word ptr [esi + 38]
    cmp eax, -99
    jne actors_C_flow_17215
actors_C_flow_17141:
    mov edx, 0x762
    movsx eax, word ptr [esi + 42]
    movsx ebp, di
    mov dword ptr [esp], eax
    {store} mov eax, ebp
    call spawn_
    mov ebx, dword ptr [esp]
    mov eax, dword ptr [esp]
    push ebx
    sar ebx, 2
    mov ecx, dword ptr [esp + 4]
    {store} sub eax, ebx
    sar ecx, 1
    push eax
    mov eax, dword ptr [esp + 8]
    {store} sub eax, ecx
    mov edx, dword ptr [_seenineblastradius]
    {store} mov ecx, eax
    {store} mov eax, ebp
    call hitradius_
    mov eax, 0xe
    {store} mov edx, ebp
    call spritesound_
actors_C_flow_17215:
    cmp byte ptr [esi + 20], 0
    je actors_C_flow_17332
    {store} xor ecx, ecx
    mov dword ptr [esp], ecx
    jmp actors_C_flow_17326
actors_C_flow_17228:
    push 5
    movsx eax, di
    push eax
    mov edx, 0xfffffe00
    call krand_
    and eax, 0x7ff
    {store} sub edx, eax
    push edx
    call krand_
    xor ah, ah
    and al, 0x3f
    .att_syntax prefix
    addl $actors_C_math_17261,%eax
    .intel_syntax noprefix
    cwde
    push eax
    call krand_
    and ah, 7
    cwde
    push eax
    push 0x30
    push 0x30
    push -8
    call krand_
    xor ah, ah
    mov ecx, dword ptr [esi + 8]
    and al, 0xf
    mov ebx, dword ptr [esi + 4]
    .att_syntax prefix
    addl $actors_C_math_17299,%eax
    .intel_syntax noprefix
    mov edx, dword ptr [esi]
    cwde
    sub ecx, 0xc00
    push eax
    movsx eax, word ptr [esi + 24]
    call EGS_
    inc dword ptr [esp]
actors_C_flow_17326:
    cmp dword ptr [esp], 8
    jl actors_C_flow_17228
actors_C_flow_17332:
    movsx eax, di
    call deletesprite_
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_17349:
    {store} mov edx, esp
    {store} mov eax, esi
    call findplayer_
    mov dword ptr [esp + 36], eax
    mov ax, word ptr [esi + 14]
    .att_syntax prefix
    cmpw $actors_C_math_17366,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_17546
    {disp32} jbe actors_C_flow_19838
    .att_syntax prefix
    cmpw $actors_C_math_17382,%ax
    .intel_syntax noprefix
    jb actors_C_flow_17476
    {disp32} jbe actors_C_flow_19838
    .att_syntax prefix
    cmpw $actors_C_math_17394,%ax
    .intel_syntax noprefix
    jb actors_C_flow_17441
    {disp32} jbe actors_C_flow_18177
    .att_syntax prefix
    cmpw $actors_C_math_17406,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_19879
    {disp32} jbe actors_C_flow_19838
    .att_syntax prefix
    cmpw $actors_C_math_17422,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_19838
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_17441:
    .att_syntax prefix
    cmpw $actors_C_math_17441,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_19879
    {disp32} jbe actors_C_flow_19838
    .att_syntax prefix
    cmpw $actors_C_math_17457,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_19838
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_17476:
    .att_syntax prefix
    cmpw $actors_C_math_17476,%ax
    .intel_syntax noprefix
    jb actors_C_flow_17527
    .att_syntax prefix
    cmpw $actors_C_math_17482,%ax
    .intel_syntax noprefix
    {disp32} jbe actors_C_flow_19838
    .att_syntax prefix
    cmpw $actors_C_math_17492,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_19879
    {disp32} jbe actors_C_flow_19648
    .att_syntax prefix
    cmpw $actors_C_math_17508,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_19838
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_17527:
    .att_syntax prefix
    cmpw $actors_C_math_17527,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_19838
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_17546:
    .att_syntax prefix
    cmpw $actors_C_math_17546,%ax
    .intel_syntax noprefix
    jb actors_C_flow_17644
    {disp32} jbe actors_C_flow_18024
    .att_syntax prefix
    cmpw $actors_C_math_17558,%ax
    .intel_syntax noprefix
    jb actors_C_flow_17605
    {disp32} jbe actors_C_flow_19863
    .att_syntax prefix
    cmpw $actors_C_math_17570,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_19879
    {disp32} jbe actors_C_flow_19838
    .att_syntax prefix
    cmpw $actors_C_math_17586,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_19838
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_17605:
    .att_syntax prefix
    cmpw $actors_C_math_17605,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_19879
    .att_syntax prefix
    cmpw $actors_C_math_17615,%ax
    .intel_syntax noprefix
    {disp32} jbe actors_C_flow_18296
    .att_syntax prefix
    cmpw $actors_C_math_17625,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_18659
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_17644:
    .att_syntax prefix
    cmpw $actors_C_math_17644,%ax
    .intel_syntax noprefix
    jb actors_C_flow_17687
    jbe actors_C_flow_17706
    .att_syntax prefix
    cmpw $actors_C_math_17652,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_19879
    {disp32} jbe actors_C_flow_18866
    .att_syntax prefix
    cmpw $actors_C_math_17668,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_18024
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_17687:
    .att_syntax prefix
    cmpw $actors_C_math_17687,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_18987
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_17706:
    mov ax, word ptr [esi + 34]
    .att_syntax prefix
    cmpw $actors_C_math_17710,%ax
    .intel_syntax noprefix
    {disp32} jne actors_C_flow_19879
    mov dx, word ptr [esi + 40]
    {store} sub edx, eax
    mov word ptr [esi + 40], dx
    test dx, dx
    {disp32} jg actors_C_flow_19879
    movsx edx, di
    movsx eax, bx
    call operatesectors_
    movsx eax, bx
    mov ax, word ptr [eax*2 + _headspritesect]
    mov ebp, 1
actors_C_flow_17766:
    mov word ptr [esp + 44], ax
    mov esi, dword ptr [esp + 44]
    test si, si
    {disp32} jl actors_C_flow_17332
    movsx edx, si
    imul eax, edx, 0x2c
    mov bx, word ptr [eax + _sprite + 26]
    cmp bx, 3
    {disp32} jne actors_C_flow_17964
    mov ax, word ptr [eax + _sprite + 38]
    .att_syntax prefix
    cmpw $actors_C_math_17814,%ax
    .intel_syntax noprefix
    jb actors_C_flow_17849
    jbe actors_C_flow_17871
    .att_syntax prefix
    cmpw $actors_C_math_17822,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_18006
    .att_syntax prefix
    cmpw $actors_C_math_17832,%ax
    .intel_syntax noprefix
    jbe actors_C_flow_17871
    .att_syntax prefix
    cmpw $actors_C_math_17838,%ax
    .intel_syntax noprefix
    je actors_C_flow_17871
    {disp32} jmp actors_C_flow_18006
actors_C_flow_17849:
    .att_syntax prefix
    cmpw $actors_C_math_17849,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_18006
    jbe actors_C_flow_17871
    {store} cmp ax, bx
    je actors_C_flow_17922
    {disp32} jmp actors_C_flow_18006
actors_C_flow_17871:
    movsx edx, word ptr [esp + 44]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov dword ptr [eax + _hittype + 47], 1
    movsx eax, word ptr [esp + 44]
    mov ax, word ptr [eax*2 + _nextspritesect]
    {disp32} jmp actors_C_flow_17766
actors_C_flow_17922:
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov dword ptr [eax + _hittype + 63], ebp
    movsx eax, word ptr [esp + 44]
    mov ax, word ptr [eax*2 + _nextspritesect]
    {disp32} jmp actors_C_flow_17766
actors_C_flow_17964:
    cmp bx, 6
    jne actors_C_flow_18006
    mov ax, word ptr [eax + _sprite + 14]
    .att_syntax prefix
    cmpw $actors_C_math_17977,%ax
    .intel_syntax noprefix
    jb actors_C_flow_18006
    jbe actors_C_flow_17991
    .att_syntax prefix
    cmpw $actors_C_math_17985,%ax
    .intel_syntax noprefix
    jne actors_C_flow_18006
actors_C_flow_17991:
    movsx eax, word ptr [esp + 44]
    imul eax, eax, 0x2c
    mov byte ptr [eax + _sprite + 16], 0xe1
actors_C_flow_18006:
    movsx eax, word ptr [esp + 44]
    mov ax, word ptr [eax*2 + _nextspritesect]
    {disp32} jmp actors_C_flow_17766
actors_C_flow_18024:
    cmp byte ptr [esi + 20], 0
    jne actors_C_flow_18047
    movsx eax, di
    call deletesprite_
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_18047:
    cmp dword ptr [esp], 0x800
    jge actors_C_flow_18092
    movsx eax, di
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 34], 1
    {disp32} jne actors_C_flow_19879
    mov word ptr [_camsprite], di
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_18092:
    movsx eax, word ptr [_camsprite]
    cmp eax, -1
    {disp32} je actors_C_flow_19879
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    cmp dword ptr [eax + _hittype + 47], 1
    {disp32} jne actors_C_flow_19879
    mov word ptr [_camsprite], 0xffff
    {store} xor ebx, ebx
    mov dword ptr [eax + _hittype + 47], ebx
    movsx eax, word ptr [esi + 14]
    call loadtile_
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_18177:
    cmp word ptr [esi + 32], 0
    jne actors_C_flow_18190
    mov word ptr [esi + 32], 1
actors_C_flow_18190:
    movsx ebx, di
    mov edx, 0x10001
    {store} mov eax, ebx
    call ssp_
    test ax, ax
    je actors_C_flow_18280
    {store} mov eax, ebx
    call makeitfall_
    call krand_
    test al, 1
    je actors_C_flow_18232
    sub word ptr [esi + 36], 0x100
actors_C_flow_18232:
    mov ax, word ptr [esi + 32]
    cwde
    test eax, eax
    jns actors_C_flow_18243
    neg eax
actors_C_flow_18243:
    cmp eax, 0x30
    {disp32} jge actors_C_flow_19879
    call krand_
    xor ah, ah
    mov cx, word ptr [esi + 32]
    and al, 3
    {store} add ecx, eax
    mov word ptr [esi + 32], cx
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_18280:
    {store} mov eax, ebx
    call deletesprite_
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_18296:
    cmp dword ptr [esp], 0x5000
    {disp32} jg actors_C_flow_19879
    cmp dword ptr [ebp + 12], 0
    jne actors_C_flow_18338
    movsx edx, bx
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    movsx eax, byte ptr [eax*8 + _sector + 28]
    mov dword ptr [ebp + 12], eax
actors_C_flow_18338:
    mov ecx, dword ptr [ebp + 8]
    test ecx, ecx
    je actors_C_flow_18388
    movsx edx, bx
    {disp32} lea eax, dword ptr [edx*4]
    lea esi, dword ptr [ecx + -1]
    {store} add eax, edx
    mov cl, 0x14
    mov dword ptr [ebp + 8], esi
    mov byte ptr [eax*8 + _sector + 28], cl
    mov byte ptr [eax*8 + _sector + 20], cl
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_18388:
    {store} xor eax, eax
    {store} xor edx, edx
    mov al, byte ptr [esi + 20]
    mov dl, byte ptr [esi + 21]
    {store} or eax, edx
    jne actors_C_flow_18416
    {disp8} mov al, byte ptr [ebp]
    mov byte ptr [esi + 20], al
    mov al, byte ptr [ebp + 4]
    mov byte ptr [esi + 21], al
    jmp actors_C_flow_18470
actors_C_flow_18416:
    call krand_
    test al, 8
    jne actors_C_flow_18470
    {store} xor eax, eax
    mov al, byte ptr [esi + 20]
    {disp8} mov dword ptr [ebp], eax
    {store} xor eax, eax
    mov al, byte ptr [esi + 21]
    mov dword ptr [ebp + 4], eax
    mov ax, word ptr [_global_random]
    xor ah, ah
    and al, 4
    cwde
    mov dword ptr [ebp + 8], eax
    mov byte ptr [esi + 21], 0
    mov al, byte ptr [esi + 21]
    mov byte ptr [esi + 20], al
    {disp32} jmp actors_C_flow_18338
actors_C_flow_18470:
    inc word ptr [esi + 14]
    mov ax, word ptr [_global_random]
    xor ah, ah
    and al, 7
    cwde
    mov dword ptr [esp + 12], eax
    mov al, byte ptr [esp + 12]
    add al, 8
    mov ch, byte ptr [esp + 12]
    mov byte ptr [esi + 20], al
    test ch, 1
    je actors_C_flow_18511
    xor byte ptr [esi + 12], 2
actors_C_flow_18511:
    cmp word ptr [esi + 14], 0x27b
    jne actors_C_flow_18565
    call krand_
    test al, 1
    je actors_C_flow_18565
    movsx edx, bx
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    cmp word ptr [eax*8 + _sector + 24], 0x35b
    jne actors_C_flow_18565
    mov eax, 0x15
    movsx edx, di
    call spritesound_
actors_C_flow_18565:
    cmp word ptr [esi + 14], 0x27e
    jne actors_C_flow_18579
    mov word ptr [esi + 14], 0x27a
actors_C_flow_18579:
    test byte ptr [esi + 14], 1
    je actors_C_flow_18622
    movsx edx, bx
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    xor bl, bl
    mov byte ptr [eax*8 + _sector + 28], bl
    mov byte ptr [eax*8 + _sector + 20], bl
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_18622:
    movsx edx, bx
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov dl, 0x14
    mov byte ptr [eax*8 + _sector + 28], dl
    mov byte ptr [eax*8 + _sector + 20], dl
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_18659:
    mov ecx, dword ptr [ebp + 4]
    test ecx, ecx
    je actors_C_flow_18693
    lea edi, dword ptr [ecx + -1]
    mov dword ptr [ebp + 4], edi
    test edi, edi
    {disp32} jne actors_C_flow_19879
    and byte ptr [esi + 13], 0x7f
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_18693:
    movsx eax, di
    mov edx, 0x10001
    call makeitfall_
    movsx eax, di
    call ssp_
    mov dx, word ptr [esi + 32]
    test dx, dx
    jle actors_C_flow_18732
    {store} mov ebx, edx
    sub ebx, 2
    mov word ptr [esi + 32], bx
actors_C_flow_18732:
    cmp word ptr [esi + 36], 0
    {disp32} jne actors_C_flow_19879
    mov ah, byte ptr [esi + 13]
    or ah, 0x80
    mov dl, byte ptr [esi + 17]
    mov byte ptr [esi + 13], ah
    cmp dl, 2
    je actors_C_flow_18773
    mov eax, 0x5c
    movsx edx, di
    call spritesound_
actors_C_flow_18773:
    movsx eax, word ptr [esi + 30]
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 14], 0x294
    je actors_C_flow_18808
    movsx eax, di
    call deletesprite_
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_18808:
    {disp8} mov eax, dword ptr [ebp]
    movsx edx, di
    {store} mov ebx, eax
    mov dword ptr [esi + 8], eax
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov dword ptr [eax + _hittype + 43], ebx
    call krand_
    and eax, 0x1f
    add eax, 0x30
    mov dword ptr [ebp + 4], eax
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_18866:
    cmp dword ptr [esp], 0x1000
    {disp32} jg actors_C_flow_19879
    movsx edx, bx
    {disp32} lea ecx, dword ptr [edx*4]
    {store} add ecx, edx
    movsx edx, bx
    {disp32} lea eax, dword ptr [edx*4]
    {store} add edx, eax
    {disp32} lea ecx, dword ptr [ecx*8]
    {disp32} lea edx, dword ptr [edx*8]
    mov eax, dword ptr [ecx + _sector + 4]
    sub eax, dword ptr [edx + _sector + 8]
    test eax, eax
    jns actors_C_flow_18935
    neg eax
actors_C_flow_18935:
    sar eax, 9
    mov word ptr [esp + 44], ax
    mov al, byte ptr [esp + 44]
    add al, 4
    movsx edx, bx
    mov byte ptr [esi + 21], al
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov byte ptr [esi + 20], 0x10
    mov eax, dword ptr [eax*8 + _sector + 8]
    mov dword ptr [esi + 8], eax
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_18987:
    cmp dword ptr [ebp + 4], 1
    {disp32} jne actors_C_flow_19373
    cmp word ptr [esi + 40], 0
    {disp32} jl actors_C_flow_19373
    movsx edx, bx
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov eax, dword ptr [eax*8 + _sector + 8]
    mov dword ptr [esp], eax
    cmp dword ptr [ebp + 12], 1
    {disp32} jne actors_C_flow_19207
    cmp eax, dword ptr [ebp + 8]
    jl actors_C_flow_19089
    movsx edx, bx
    {disp32} lea eax, dword ptr [edx*4]
    {store} add edx, eax
    {disp32} lea edx, dword ptr [edx*8]
    mov eax, dword ptr [esp]
    mov dword ptr [edx + _sector + 8], eax
    mov dword ptr [ebp + 4], 0
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_19089:
    movsx edx, bx
    {disp32} lea ecx, dword ptr [edx*4]
    {store} add ecx, edx
    movsx edx, bx
    {disp32} lea eax, dword ptr [edx*4]
    {disp32} lea ecx, dword ptr [ecx*8]
    {store} add eax, edx
    mov esi, dword ptr [ecx + _sector + 8]
    movsx eax, word ptr [eax*8 + _sector + 38]
    {store} add esi, eax
    movsx eax, bx
    mov dword ptr [ecx + _sector + 8], esi
    call checkcursectnums_
    mov dword ptr [esp + 36], eax
    test ax, ax
    {disp32} jl actors_C_flow_19879
    movsx ecx, ax
    imul ecx, ecx, 0x552
    movsx edx, bx
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    movsx eax, word ptr [eax*8 + _sector + 38]
    add dword ptr [ecx + _ps + 540], eax
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_19207:
    mov ecx, dword ptr [esi + 8]
    {store} cmp eax, ecx
    jg actors_C_flow_19255
    movsx edx, bx
    {disp32} lea eax, dword ptr [edx*4]
    {store} add edx, eax
    {disp32} lea edx, dword ptr [edx*8]
    mov dword ptr [edx + _sector + 8], ecx
    mov dword ptr [ebp + 4], 0
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_19255:
    movsx edx, bx
    {disp32} lea eax, dword ptr [edx*4]
    movsx ecx, bx
    {store} add edx, eax
    {disp32} lea eax, dword ptr [ecx*4]
    {disp32} lea edx, dword ptr [edx*8]
    {store} add eax, ecx
    mov esi, dword ptr [edx + _sector + 8]
    movsx eax, word ptr [eax*8 + _sector + 38]
    {store} sub esi, eax
    movsx eax, bx
    mov dword ptr [edx + _sector + 8], esi
    call checkcursectnums_
    mov dword ptr [esp + 36], eax
    test ax, ax
    {disp32} jl actors_C_flow_19879
    movsx edx, ax
    imul edx, edx, 0x552
    movsx ebx, bx
    {disp32} lea eax, dword ptr [ebx*4]
    {store} add eax, ebx
    movsx eax, word ptr [eax*8 + _sector + 38]
    sub dword ptr [edx + _ps + 540], eax
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_19373:
    cmp dword ptr [ebp + 20], 1
    {disp32} je actors_C_flow_19879
    movsx eax, bx
    call checkcursectnums_
    mov dword ptr [esp + 36], eax
    test ax, ax
    {disp32} jl actors_C_flow_19521
    cwde
    imul eax, eax, 0x552
    cmp byte ptr [eax + _ps + 1308], 0
    je actors_C_flow_19521
    {disp8} cmp dword ptr [ebp], 0
    jne actors_C_flow_19528
    movsx eax, word ptr [esi + 38]
    call check_activator_motion_
    test ax, ax
    jne actors_C_flow_19528
    {disp8} mov dword ptr [ebp], 1
    mov ecx, dword ptr [ebp + 12]
    mov dword ptr [ebp + 4], 1
    test ecx, ecx
    sete al
    and eax, 0xff
    mov dword ptr [ebp + 12], eax
    movsx eax, word ptr [esi + 38]
    movsx edx, word ptr [esp + 36]
    call operatemasterswitches_
    movsx eax, word ptr [esi + 38]
    call operateactivators_
    mov dx, word ptr [esi + 40]
    test dx, dx
    jle actors_C_flow_19528
    {store} mov ebx, edx
    dec bx
    mov word ptr [esi + 40], bx
    jne actors_C_flow_19528
    mov dword ptr [ebp + 20], 1
    jmp actors_C_flow_19528
actors_C_flow_19521:
    {disp8} mov dword ptr [ebp], 0
actors_C_flow_19528:
    cmp dword ptr [ebp + 4], 1
    {disp32} jne actors_C_flow_19879
    mov ax, word ptr [_headspritestat + 12]
actors_C_flow_19544:
    mov word ptr [esp + 44], ax
    mov eax, dword ptr [esp + 44]
    test ax, ax
    {disp32} jl actors_C_flow_19879
    {store} cmp di, ax
    je actors_C_flow_19633
    movsx edx, ax
    imul eax, edx, 0x2c
    cmp word ptr [eax + _sprite + 14], 3
    jne actors_C_flow_19633
    mov ax, word ptr [eax + _sprite + 38]
    cmp ax, word ptr [esi + 38]
    jne actors_C_flow_19633
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov dword ptr [eax + _hittype + 51], 1
    mov edx, dword ptr [ebp + 12]
    mov dword ptr [eax + _hittype + 59], edx
actors_C_flow_19633:
    movsx eax, word ptr [esp + 44]
    mov ax, word ptr [eax*2 + _nextspritestat]
    jmp actors_C_flow_19544
actors_C_flow_19648:
    movsx edx, di
    {store} mov eax, edx
    call makeitfall_
    {store} mov eax, edx
    call ifhitbyweapon_
    test ax, ax
    {disp32} jl actors_C_flow_19879
    mov eax, 0x12
    call spritesound_
    {store} xor eax, eax
    mov word ptr [esp + 44], ax
    jmp actors_C_flow_19793
actors_C_flow_19693:
    push 5
    movsx eax, di
    push eax
    mov edx, 0xfffffe00
    call krand_
    and eax, 0x7ff
    {store} sub edx, eax
    push edx
    call krand_
    xor ah, ah
    and al, 0x3f
    .att_syntax prefix
    addl $actors_C_math_19726,%eax
    .intel_syntax noprefix
    cwde
    push eax
    call krand_
    and ah, 7
    cwde
    push eax
    push 0x30
    push 0x30
    push -8
    call krand_
    xor ah, ah
    mov ecx, dword ptr [esi + 8]
    and al, 0xf
    mov ebx, dword ptr [esi + 4]
    .att_syntax prefix
    addl $actors_C_math_19764,%eax
    .intel_syntax noprefix
    mov edx, dword ptr [esi]
    cwde
    sub ecx, 0xc00
    push eax
    movsx eax, word ptr [esi + 24]
    call EGS_
    inc word ptr [esp + 44]
actors_C_flow_19793:
    cmp word ptr [esp + 44], 0xa
    jl actors_C_flow_19693
    mov dx, word ptr [esi + 38]
    test dx, dx
    je actors_C_flow_19821
    movsx edx, dx
    movsx eax, di
    call spawn_
actors_C_flow_19821:
    movsx eax, di
    call deletesprite_
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_19838:
    movsx edx, word ptr [esp + 36]
    mov ebx, dword ptr [esp]
    movsx eax, di
    call execute_
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_19863:
    mov ebx, dword ptr [esp]
    movsx edx, word ptr [esp + 36]
    movsx eax, di
    call execute_
actors_C_flow_19879:
    mov edi, dword ptr [esp + 48]
    {disp32} jmp actors_C_flow_12160
actors_C_flow_19888:
    add esp, 0x34
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
bounce_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    sub esp, 0x10
    cwde
    mov dword ptr [esp], eax
    imul ebp, eax, 0x2c
    add ebp, OFFSET FLAT:_sprite
    movsx eax, word ptr [ebp + 28]
    .att_syntax prefix
    addl $actors_C_math_19930,%eax
    .intel_syntax noprefix
    and eax, 0x7ff
    mov dx, word ptr [eax*2 + _sintable]
    mov ax, word ptr [ebp + 32]
    movsx ebx, dx
    cwde
    imul ebx
    shrd eax, edx, 0xa
    mov dword ptr [esp + 4], eax
    mov ax, word ptr [ebp + 28]
    and ah, 7
    cwde
    mov ax, word ptr [eax*2 + _sintable]
    mov dx, word ptr [ebp + 32]
    movsx ebx, ax
    movsx eax, dx
    imul ebx
    shrd eax, edx, 0xa
    mov dword ptr [esp + 12], eax
    movsx eax, word ptr [ebp + 36]
    mov dword ptr [esp + 8], eax
    mov ax, word ptr [ebp + 24]
    cwde
    {disp32} lea esi, dword ptr [eax*4]
    {store} add esi, eax
    {disp32} lea esi, dword ptr [esi*8]
    movsx ecx, word ptr [esi + _sector]
    shl ecx, 5
    movsx eax, word ptr [ecx + _wall + 8]
    shl eax, 5
    mov edx, dword ptr [eax + _wall + 4]
    mov ebx, dword ptr [eax + _wall]
    mov eax, dword ptr [ecx + _wall]
    mov edi, dword ptr [ecx + _wall + 4]
    {store} sub ebx, eax
    {store} sub edx, edi
    {store} mov eax, ebx
    call getangle_
    {store} mov edi, eax
    mov eax, dword ptr [esp]
    {disp32} lea ecx, dword ptr [eax*8]
    {store} add ecx, eax
    {disp32} lea ecx, dword ptr [ecx*8]
    {store} sub ecx, eax
    mov ebx, dword ptr [ecx + _hittype + 19]
    add ebx, dword ptr [ecx + _hittype + 23]
    mov ecx, dword ptr [ebp + 8]
    sar ebx, 1
    {store} cmp ebx, ecx
    jle actors_C_flow_20139
    movsx ecx, word ptr [esi + _sector + 18]
    jmp actors_C_flow_20146
actors_C_flow_20139:
    movsx ecx, word ptr [esi + _sector + 26]
actors_C_flow_20146:
    {store} mov eax, edi
    and eax, 0x7ff
    mov ax, word ptr [eax*2 + _sintable]
    add edi, 0x600
    movsx ebx, ax
    {store} mov eax, ecx
    and edi, 0x7ff
    imul ebx
    shrd eax, edx, 0xe
    {store} mov esi, eax
    mov ax, word ptr [edi*2 + _sintable]
    movsx ebx, ax
    {store} mov eax, ecx
    imul ebx
    shrd eax, edx, 0xe
    mov edx, dword ptr [esp + 12]
    {store} mov edi, eax
    imul edx, edi
    mov eax, dword ptr [esp + 4]
    imul eax, esi
    {store} add eax, edx
    {store} mov edx, esi
    imul edx, esi
    mov ebx, dword ptr [esp + 8]
    shl ebx, 0xc
    lea ecx, dword ptr [eax + ebx]
    {store} mov eax, edi
    imul eax, edi
    {store} add eax, edx
    lea ebx, dword ptr [eax + 16777216]
    {store} mov eax, ecx
    test eax, eax
    jns actors_C_flow_20259
    neg eax
actors_C_flow_20259:
    sar eax, 0xe
    {store} cmp eax, ebx
    jge actors_C_flow_20337
    {store} mov eax, ecx
    {store} mov edx, eax
    sar edx, 0xf
    shl eax, 0x11
    idiv ebx
    {store} mov ebx, eax
    {store} mov eax, esi
    mov esi, dword ptr [esp + 4]
    imul ebx
    shrd eax, edx, 0x10
    {store} sub esi, eax
    {store} mov eax, edi
    mov edi, dword ptr [esp + 12]
    imul ebx
    shrd eax, edx, 0x10
    {store} sub edi, eax
    mov eax, 0x1000
    imul ebx
    shrd eax, edx, 0x10
    mov edx, dword ptr [esp + 8]
    mov dword ptr [esp + 4], esi
    {store} sub edx, eax
    mov dword ptr [esp + 12], edi
    mov dword ptr [esp + 8], edx
actors_C_flow_20337:
    mov eax, dword ptr [esp + 8]
    mov edi, dword ptr [esp + 12]
    mov ebx, dword ptr [esp + 4]
    {store} mov esi, edi
    mov word ptr [ebp + 36], ax
    {store} mov eax, ebx
    imul ebx
    xchg esi, eax
    {store} mov ebx, edx
    imul edi
    {store} add eax, esi
    {store} adc edx, ebx
    shrd eax, edx, 8
    call ksqrt_
    {store} mov edx, edi
    mov word ptr [ebp + 32], ax
    mov eax, dword ptr [esp + 4]
    call getangle_
    mov word ptr [ebp + 28], ax
actors_C_flow_20396:
    add esp, 0x10
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp8} lea edx, dword ptr [edx + eiz*1]
moveweapons_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    sub esp, 0x24
    mov ax, word ptr [_headspritestat + 8]
actors_C_flow_20431:
    mov dword ptr [esp + 32], eax
    mov edx, dword ptr [esp + 32]
    test dx, dx
    {disp32} jl actors_C_flow_23830
    movsx ecx, dx
    imul esi, ecx, 0x2c
    add esi, OFFSET FLAT:_sprite
    mov ax, word ptr [ecx*2 + _nextspritestat]
    mov bx, word ptr [esi + 24]
    mov dword ptr [esp + 24], eax
    test bx, bx
    jge actors_C_flow_20493
    {store} mov eax, ecx
    call deletesprite_
    {disp32} jmp actors_C_flow_23821
actors_C_flow_20493:
    {disp32} lea edx, dword ptr [ecx*8]
    {store} add edx, ecx
    {disp32} lea edx, dword ptr [edx*8]
    {store} sub edx, ecx
    mov eax, dword ptr [esi]
    mov dword ptr [edx + _hittype + 35], eax
    mov eax, dword ptr [esi + 4]
    mov dword ptr [edx + _hittype + 39], eax
    mov eax, dword ptr [esi + 8]
    mov dword ptr [edx + _hittype + 43], eax
    mov ax, word ptr [esi + 14]
    .att_syntax prefix
    cmpw $actors_C_math_20541,%ax
    .intel_syntax noprefix
    jb actors_C_flow_20625
    {disp32} jbe actors_C_flow_21387
    .att_syntax prefix
    cmpw $actors_C_math_20553,%ax
    .intel_syntax noprefix
    jb actors_C_flow_20600
    {disp32} jbe actors_C_flow_23706
    .att_syntax prefix
    cmpw $actors_C_math_20565,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_23821
    {disp32} jbe actors_C_flow_23799
    .att_syntax prefix
    cmpw $actors_C_math_20581,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_21387
    mov eax, dword ptr [esp + 24]
    {disp32} jmp actors_C_flow_20431
actors_C_flow_20600:
    .att_syntax prefix
    cmpw $actors_C_math_20600,%ax
    .intel_syntax noprefix
    jbe actors_C_flow_20691
    .att_syntax prefix
    cmpw $actors_C_math_20606,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_23706
    mov eax, dword ptr [esp + 24]
    {disp32} jmp actors_C_flow_20431
actors_C_flow_20625:
    .att_syntax prefix
    cmpw $actors_C_math_20625,%ax
    .intel_syntax noprefix
    jb actors_C_flow_20672
    {disp32} jbe actors_C_flow_21387
    .att_syntax prefix
    cmpw $actors_C_math_20637,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_23821
    {disp32} jbe actors_C_flow_21387
    .att_syntax prefix
    cmpw $actors_C_math_20653,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_21327
    mov eax, dword ptr [esp + 24]
    {disp32} jmp actors_C_flow_20431
actors_C_flow_20672:
    .att_syntax prefix
    cmpw $actors_C_math_20672,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_21387
    mov eax, dword ptr [esp + 24]
    {disp32} jmp actors_C_flow_20431
actors_C_flow_20691:
    mov eax, dword ptr [edx + _hittype + 51]
    mov ebx, dword ptr [edx + _hittype + 51]
    and eax, 0x7ff
    add ebx, 0x20
    movsx eax, word ptr [eax*2 + _sintable]
    mov dword ptr [edx + _hittype + 51], ebx
    sar eax, 9
    mov dword ptr [edx + _hittype + 47], eax
    cmp ebx, 0x7ff
    jle actors_C_flow_20758
    {store} mov eax, ecx
    call deletesprite_
    mov eax, dword ptr [esp + 24]
    {disp32} jmp actors_C_flow_20431
actors_C_flow_20758:
    movsx eax, word ptr [esi + 30]
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 26], 0x400
    jne actors_C_flow_20807
    add eax, OFFSET FLAT:_sprite
    call badguy_
    test ax, ax
    jne actors_C_flow_20807
    {store} mov eax, ecx
    call deletesprite_
    mov eax, dword ptr [esp + 24]
    {disp32} jmp actors_C_flow_20431
actors_C_flow_20807:
    movsx eax, word ptr [esi + 30]
    imul eax, eax, 0x2c
    mov ax, word ptr [eax + _sprite + 28]
    mov word ptr [esi + 28], ax
    movsx eax, word ptr [esi + 30]
    imul eax, eax, 0x2c
    mov eax, dword ptr [eax + _sprite]
    mov dword ptr [esi], eax
    movsx eax, word ptr [esi + 30]
    imul eax, eax, 0x2c
    mov eax, dword ptr [eax + _sprite + 4]
    mov dword ptr [esi + 4], eax
    movsx eax, word ptr [esi + 30]
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 14], 0x57d
    jne actors_C_flow_20888
    mov eax, dword ptr [eax + _sprite + 8]
    sub eax, 0x2200
    mov dword ptr [esi + 8], eax
actors_C_flow_20888:
    {store} xor ebx, ebx
    mov word ptr [esp + 20], bx
    {disp32} jmp actors_C_flow_21079
actors_C_flow_20900:
    push 5
    push ebx
    push 0
    push 0
    mov al, byte ptr [esp + 36]
    push 0
    add al, al
    push 8
    sub al, 0x28
    push 8
    movsx eax, al
    push eax
    mov ax, word ptr [esi + 36]
    push 0x66f
    movsx ebx, ax
    {store} mov edi, ecx
    {store} add ebx, ebx
    {store} sbb eax, eax
    {store} cmp eax, ebx
    adc al, 0
    imul edi, eax
    movsx edx, word ptr [esi + 36]
    mov ebx, 0xc
    {store} mov eax, edx
    sar edx, 0x1f
    idiv ebx
    test eax, eax
    jns actors_C_flow_20972
    neg eax
actors_C_flow_20972:
    imul edi, eax
    add edi, dword ptr [esi + 8]
    mov ax, word ptr [esi + 28]
    and ah, 7
    cwde
    movsx ebx, word ptr [eax*2 + _sintable]
    imul ebx, ecx
    movsx eax, word ptr [esi + 28]
    .att_syntax prefix
    addl $actors_C_math_21001,%eax
    .intel_syntax noprefix
    mov edx, dword ptr [esi + 4]
    and eax, 0x7ff
    sar ebx, 9
    movsx eax, word ptr [eax*2 + _sintable]
    {store} add ebx, edx
    {store} mov edx, ecx
    imul edx, eax
    mov ecx, dword ptr [esi]
    sar edx, 9
    movsx eax, word ptr [esi + 24]
    {store} add edx, ecx
    {store} mov ecx, edi
    call EGS_
    cwde
    imul eax, eax, 0x2c
    mov edi, 0x80
    mov dl, 8
    mov word ptr [eax + _sprite + 12], di
    mov byte ptr [eax + _sprite + 17], dl
    inc word ptr [esp + 20]
actors_C_flow_21079:
    movsx ebx, word ptr [esp + 32]
    {disp32} lea edi, dword ptr [ebx*8]
    {store} add edi, ebx
    {disp32} lea edi, dword ptr [edi*8]
    {store} sub edi, ebx
    movsx ecx, word ptr [esp + 20]
    cmp ecx, dword ptr [edi + _hittype + 47]
    {disp32} jl actors_C_flow_20900
    push 5
    push ebx
    push 0
    push 0
    push 0
    push 0x20
    push 0x20
    push -40
    mov ax, word ptr [esi + 36]
    push 0x744
    movsx ebx, ax
    {store} mov ebp, ecx
    {store} add ebx, ebx
    {store} sbb eax, eax
    {store} cmp eax, ebx
    adc al, 0
    imul ebp, eax
    movsx edx, word ptr [esi + 36]
    mov ebx, 0xc
    {store} mov eax, edx
    sar edx, 0x1f
    idiv ebx
    test eax, eax
    jns actors_C_flow_21181
    neg eax
actors_C_flow_21181:
    imul eax, ebp
    add eax, dword ptr [esi + 8]
    mov dx, word ptr [esi + 28]
    and dh, 7
    movsx edx, dx
    movsx edx, word ptr [edx*2 + _sintable]
    imul edx, ecx
    mov ebx, dword ptr [esi + 4]
    sar edx, 9
    {store} add ebx, edx
    movsx edx, word ptr [esi + 28]
    add edx, 0x200
    and edx, 0x7ff
    movsx edx, word ptr [edx*2 + _sintable]
    imul edx, ecx
    sar edx, 9
    mov ecx, dword ptr [esi]
    movsx esi, word ptr [esi + 24]
    {store} add edx, ecx
    {store} mov ecx, eax
    {store} mov eax, esi
    call EGS_
    cwde
    imul eax, eax, 0x2c
    mov ebx, 0x80
    mov esi, dword ptr [edi + _hittype + 51]
    mov word ptr [eax + _sprite + 12], bx
    cmp esi, 0x200
    {disp32} jle actors_C_flow_23821
    cmp esi, 0x400
    {disp32} jge actors_C_flow_23821
    mov word ptr [eax + _sprite + 14], 0x745
    mov eax, dword ptr [esp + 24]
    {disp32} jmp actors_C_flow_20431
actors_C_flow_21327:
    cmp word ptr [esi + 34], 1
    jge actors_C_flow_21387
    mov edx, 0x65e
    {store} mov eax, ecx
    call spawn_
    cwde
    imul eax, eax, 0x2c
    mov byte ptr [eax + _sprite + 17], 1
    mov dh, 0x20
    mov byte ptr [eax + _sprite + 20], dh
    mov byte ptr [eax + _sprite + 21], dh
    {store} mov eax, ecx
    call deletesprite_
    mov eax, dword ptr [esp + 24]
    {disp32} jmp actors_C_flow_20431
actors_C_flow_21387:
    cmp word ptr [esi + 14], 0x550
    jne actors_C_flow_21419
    cmp dword ptr [_Sound + 2089], 0
    jne actors_C_flow_21419
    movsx edx, word ptr [esp + 32]
    mov eax, 0xa0
    call spritesound_
actors_C_flow_21419:
    cmp word ptr [esi + 14], 0xa2d
    jne actors_C_flow_21465
    movsx edx, word ptr [esi + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    cmp word ptr [eax*8 + _sector + 34], 2
    jne actors_C_flow_21465
    movsx eax, word ptr [esi + 32]
    movsx ecx, word ptr [esi + 36]
    sar eax, 1
    sar ecx, 1
    jmp actors_C_flow_21473
actors_C_flow_21465:
    mov ax, word ptr [esi + 32]
    movsx ecx, word ptr [esi + 36]
actors_C_flow_21473:
    mov word ptr [esp + 20], ax
    mov eax, dword ptr [esi]
    mov dword ptr [esp + 16], eax
    mov eax, dword ptr [esi + 4]
    movsx ebx, word ptr [esp + 32]
    mov dword ptr [esp + 4], eax
    {store} mov eax, ebx
    mov ebp, dword ptr [esi + 8]
    call getglobalz_
    mov dword ptr [esp + 12], 0x1000040
    mov ax, word ptr [esi + 14]
    .att_syntax prefix
    cmpw $actors_C_math_21518,%ax
    .intel_syntax noprefix
    jne actors_C_flow_21609
    {disp32} lea eax, dword ptr [ebx*8]
    {store} add eax, ebx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ebx
    cmp word ptr [eax + _hittype + 1], 0xa96
    je actors_C_flow_21609
    cmp byte ptr [esi + 20], 0xa
    jb actors_C_flow_21609
    movsx edx, word ptr [esi + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    cmp word ptr [eax*8 + _sector + 34], 2
    je actors_C_flow_21609
    mov edx, 0x919
    {store} mov eax, ebx
    call spawn_
    cwde
    imul eax, eax, 0x2c
    add dword ptr [eax + _sprite + 8], 0x100
actors_C_flow_21609:
    mov ax, word ptr [esi + 28]
    and ah, 7
    mov ebx, dword ptr [esp + 12]
    cwde
    push ebx
    movsx ebx, word ptr [eax*2 + _sintable]
    movsx eax, word ptr [esp + 24]
    imul ebx, eax
    movsx edx, word ptr [esi + 28]
    add edx, 0x200
    and edx, 0x7ff
    movsx edx, word ptr [edx*2 + _sintable]
    imul edx, eax
    movsx eax, word ptr [esp + 36]
    sar ebx, 0xe
    sar edx, 0xe
    call movesprite_
    mov bx, word ptr [esi + 14]
    mov word ptr [esp + 28], ax
    cmp bx, 0xa2d
    jne actors_C_flow_21757
    mov cx, word ptr [esi + 34]
    test cx, cx
    jl actors_C_flow_21757
    movsx ebx, cx
    imul ebx, ebx, 0x2c
    mov edx, dword ptr [esi + 4]
    mov eax, dword ptr [esi]
    mov ecx, dword ptr [ebx + _sprite + 4]
    mov edi, dword ptr [ebx + _sprite]
    {store} sub edx, ecx
    {store} sub eax, edi
    call FindDistance2D_
    .att_syntax prefix
    cmpl $actors_C_math_21738,%eax
    .intel_syntax noprefix
    jge actors_C_flow_21757
    mov ax, word ptr [esi + 34]
    or ah, 0xc0
    mov word ptr [esp + 28], ax
actors_C_flow_21757:
    mov di, word ptr [esi + 24]
    test di, di
    jge actors_C_flow_21785
    movsx eax, word ptr [esp + 32]
    call deletesprite_
    mov eax, dword ptr [esp + 24]
    {disp32} jmp actors_C_flow_20431
actors_C_flow_21785:
    movsx eax, word ptr [esp + 28]
    and eax, 0xc000
    .att_syntax prefix
    cmpl $actors_C_math_21795,%eax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_21913
    cmp word ptr [esi + 14], 0x669
    je actors_C_flow_21913
    movsx edx, word ptr [esp + 32]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov edx, dword ptr [esi + 8]
    cmp edx, dword ptr [eax + _hittype + 23]
    jge actors_C_flow_21866
    {store} mov eax, edi
    or ah, 0x40
    mov word ptr [esi + 36], 0xffff
    mov word ptr [esp + 28], ax
    jmp actors_C_flow_21913
actors_C_flow_21866:
    cmp edx, dword ptr [eax + _hittype + 19]
    jle actors_C_flow_21913
    {store} mov eax, edi
    or ah, 0x40
    movsx edx, di
    mov word ptr [esp + 28], ax
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    cmp word ptr [eax*8 + _sector + 34], 1
    je actors_C_flow_21913
    mov word ptr [esi + 36], 1
actors_C_flow_21913:
    mov bx, word ptr [esi + 14]
    cmp bx, 0x659
    {disp32} jne actors_C_flow_22172
    mov word ptr [esp + 20], 0xfffd
    mov edx, dword ptr [esp + 20]
    cmp dx, 2
    jl actors_C_flow_21950
    {disp32} jmp actors_C_flow_22201
actors_C_flow_21950:
    push 5
    movsx eax, word ptr [esi + 30]
    push eax
    push 0
    push 0
    push 0
    movsx eax, byte ptr [esi + 21]
    push eax
    movsx eax, byte ptr [esi + 20]
    push eax
    mov al, byte ptr [esp + 48]
    shl al, 2
    sub al, 0x28
    movsx eax, al
    push eax
    mov ax, word ptr [esi + 36]
    push 0x659
    movsx ebx, ax
    movsx ecx, dx
    {store} add ebx, ebx
    {store} sbb eax, eax
    {store} cmp eax, ebx
    adc al, 0
    {store} mov ebx, ecx
    imul ebx, eax
    movsx edx, word ptr [esi + 36]
    mov edi, 0x18
    {store} mov eax, edx
    sar edx, 0x1f
    idiv edi
    test eax, eax
    jns actors_C_flow_22036
    neg eax
actors_C_flow_22036:
    imul eax, ebx
    mov dx, word ptr [esi + 28]
    and dh, 7
    movsx edx, dx
    movsx edx, word ptr [edx*2 + _sintable]
    imul edx, ecx
    mov ebx, dword ptr [esi + 4]
    sar edx, 9
    {store} add ebx, edx
    movsx edx, word ptr [esi + 28]
    add edx, 0x200
    and edx, 0x7ff
    movsx edx, word ptr [edx*2 + _sintable]
    imul edx, ecx
    add eax, dword ptr [esi + 8]
    sar edx, 9
    mov ecx, dword ptr [esi]
    movsx edi, word ptr [esi + 24]
    {store} add edx, ecx
    {store} mov ecx, eax
    {store} mov eax, edi
    call EGS_
    cwde
    mov dword ptr [esp], eax
    imul eax, eax, 0x2c
    mov ebx, 0x80
    mov ecx, dword ptr [esp + 20]
    mov word ptr [eax + _sprite + 12], bx
    inc ecx
    mov dl, byte ptr [esi + 17]
    mov word ptr [esp + 20], cx
    mov byte ptr [eax + _sprite + 17], dl
    mov edx, dword ptr [esp + 20]
    cmp dx, 2
    {disp32} jl actors_C_flow_21950
    jmp actors_C_flow_22201
actors_C_flow_22172:
    cmp bx, 0x664
    jne actors_C_flow_22201
    mov di, word ptr [esi + 36]
    cmp di, 0x1800
    jge actors_C_flow_22201
    {store} mov eax, edi
    .att_syntax prefix
    addl $actors_C_math_22192,%eax
    .intel_syntax noprefix
    mov word ptr [esi + 36], ax
actors_C_flow_22201:
    mov edi, dword ptr [esp + 28]
    test di, di
    {disp32} je actors_C_flow_23678
    cmp word ptr [esi + 14], 0x550
    jne actors_C_flow_22273
    movsx eax, di
    and eax, 0xc000
    .att_syntax prefix
    cmpl $actors_C_math_22230,%eax
    .intel_syntax noprefix
    jne actors_C_flow_22261
    {store} mov eax, edi
    and ah, 0xf
    cwde
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 14], 0x57d
    {disp32} jne actors_C_flow_23821
actors_C_flow_22261:
    mov word ptr [esi + 32], 0
    mov word ptr [esi + 36], 0
actors_C_flow_22273:
    movsx eax, word ptr [esp + 28]
    and eax, 0xc000
    .att_syntax prefix
    cmpl $actors_C_math_22283,%eax
    .intel_syntax noprefix
    {disp32} jne actors_C_flow_22799
    mov cl, byte ptr [esp + 29]
    and cl, 0xf
    mov bx, word ptr [esi + 14]
    mov byte ptr [esp + 29], cl
    cmp bx, 0x669
    jne actors_C_flow_22420
    movsx edx, word ptr [esp + 28]
    imul edx, edx, 0x2c
    cmp byte ptr [edx + _sprite + 17], 1
    jne actors_C_flow_22420
    mov eax, OFFSET FLAT:_sprite
    {store} add eax, edx
    call badguy_
    test ax, ax
    jne actors_C_flow_22361
    cmp word ptr [edx + _sprite + 14], 0x57d
    jne actors_C_flow_22420
actors_C_flow_22361:
    movsx ebx, word ptr [esp + 32]
    mov edx, 0x65e
    {store} mov eax, ebx
    call spawn_
    cwde
    imul eax, eax, 0x2c
    mov dh, 1
    mov cl, 0x20
    mov byte ptr [eax + _sprite + 17], dh
    mov byte ptr [eax + _sprite + 20], cl
    mov byte ptr [eax + _sprite + 21], cl
    {store} mov eax, ebx
    call deletesprite_
    mov eax, dword ptr [esp + 24]
    {disp32} jmp actors_C_flow_20431
actors_C_flow_22420:
    movsx ebx, word ptr [esp + 28]
    {store} mov eax, ebx
    imul ecx, ebx, 0x2c
    movsx edx, word ptr [esp + 32]
    call checkhitsprite_
    cmp word ptr [ecx + _sprite + 14], 0x57d
    {disp32} jne actors_C_flow_22697
    mov eax, 2
    {store} mov edx, ebx
    mov cx, word ptr [ecx + _sprite + 34]
    call spritesound_
    cmp word ptr [esi + 14], 0x664
    {disp32} jne actors_C_flow_22697
    movsx eax, cx
    imul eax, eax, 0x552
    add dword ptr [eax + _ps + 544], 0x20
    mov dl, 8
    mov ebx, dword ptr [eax + _ps + 528]
    mov byte ptr [eax + _ps + 1361], dl
    test ebx, ebx
    {disp32} jne actors_C_flow_22697
    cmp dword ptr [_Sound + 2752], 1
    jge actors_C_flow_22550
    movsx edx, word ptr [eax + _ps + 724]
    mov eax, 0xd3
    call spritesound_
actors_C_flow_22550:
    call krand_
    xor ah, ah
    and al, 3
    .att_syntax prefix
    addl $actors_C_math_22559,%eax
    .intel_syntax noprefix
    mov word ptr [esp + 28], ax
    movsx edx, ax
    movsx eax, cx
    imul eax, eax, 0x552
    {store} xor ebx, ebx
    mov dword ptr [eax + _ps + 524], edx
    mov edx, 0x60
    mov dword ptr [esp], ebx
    mov dword ptr [eax + _ps + 528], edx
    movsx eax, word ptr [esp + 28]
    cmp eax, dword ptr [esp]
    jg actors_C_flow_22618
    {disp32} jmp actors_C_flow_22697
actors_C_flow_22618:
    call krand_
    {store} mov edx, eax
    mov ebx, dword ptr [_xdim]
    sar edx, 0x1f
    idiv ebx
    movsx ebx, cx
    imul ebx, ebx, 0x552
    mov eax, dword ptr [esp]
    mov dword ptr [ebx + eax*4 + _ps + 12], edx
    call krand_
    {store} mov edx, eax
    mov edi, dword ptr [_ydim]
    sar edx, 0x1f
    idiv edi
    mov eax, dword ptr [esp]
    inc eax
    mov dword ptr [ebx + eax*4 + _ps + 264], edx
    mov dword ptr [esp], eax
    movsx eax, word ptr [esp + 28]
    cmp eax, dword ptr [esp]
    jg actors_C_flow_22618
actors_C_flow_22697:
    mov dx, word ptr [esi + 14]
    cmp dx, 0x664
    {disp32} je actors_C_flow_23651
    cmp dx, 0xa2d
    {disp32} jne actors_C_flow_23381
    movsx ebx, word ptr [esp + 32]
    mov edx, 0x762
    {store} mov eax, ebx
    call spawn_
    cwde
    imul eax, eax, 0x2c
    mov edx, dword ptr [esp + 16]
    mov dword ptr [eax + _sprite], edx
    mov dword ptr [eax + _sprite + 8], ebp
    mov edx, dword ptr [esp + 4]
    mov dword ptr [eax + _sprite + 4], edx
    cmp byte ptr [esi + 20], 0xa
    {disp32} jae actors_C_flow_23312
    mov bh, 6
    mov byte ptr [eax + _sprite + 20], bh
    mov byte ptr [eax + _sprite + 21], bh
    {disp32} jmp actors_C_flow_23542
actors_C_flow_22799:
    .att_syntax prefix
    cmpl $actors_C_math_22799,%eax
    .intel_syntax noprefix
    {disp32} jne actors_C_flow_23161
    mov bh, byte ptr [esp + 29]
    and bh, 0x1f
    mov ax, word ptr [esi + 14]
    mov byte ptr [esp + 29], bh
    .att_syntax prefix
    cmpw $actors_C_math_22825,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_22981
    .att_syntax prefix
    cmpw $actors_C_math_22835,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_22981
    .att_syntax prefix
    cmpw $actors_C_math_22845,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_22981
    movsx eax, word ptr [esp + 28]
    shl eax, 5
    cmp word ptr [eax + _wall + 18], 0x230
    je actors_C_flow_22885
    cmp word ptr [eax + _wall + 16], 0x230
    jne actors_C_flow_22981
actors_C_flow_22885:
    movsx edx, word ptr [esp + 28]
    shl edx, 5
    movsx ebx, word ptr [edx + _wall + 8]
    mov edi, dword ptr [edx + _wall + 4]
    shl ebx, 5
    mov ebp, dword ptr [edx + _wall]
    mov ecx, dword ptr [ebx + _wall + 4]
    mov eax, dword ptr [ebx + _wall]
    {store} sub ecx, edi
    {store} sub eax, ebp
    {store} mov edx, ecx
    call getangle_
    mov dx, word ptr [esi + 28]
    {store} add eax, eax
    {store} sub eax, edx
    and ah, 7
    mov word ptr [esi + 28], ax
    mov eax, dword ptr [esp + 32]
    mov edx, 0x65e
    mov word ptr [esi + 30], ax
    cwde
    call spawn_
    mov eax, dword ptr [esp + 24]
    {disp32} jmp actors_C_flow_20431
actors_C_flow_22981:
    movsx edi, word ptr [esp + 32]
    mov ebx, dword ptr [esp + 4]
    mov edx, dword ptr [esp + 16]
    {store} mov ecx, ebp
    {store} mov eax, edi
    call setsprite_
    movsx eax, word ptr [esi + 14]
    push eax
    mov eax, dword ptr [esi + 8]
    mov ecx, dword ptr [esi + 4]
    push eax
    movsx eax, word ptr [esp + 36]
    mov ebx, dword ptr [esi]
    mov dword ptr [esp + 16], eax
    {store} mov edx, eax
    {store} mov eax, edi
    call checkhitwall_
    cmp word ptr [esi + 14], 0x669
    {disp32} jne actors_C_flow_22697
    mov eax, dword ptr [esp + 8]
    shl eax, 5
    cmp word ptr [eax + _wall + 18], 0x230
    je actors_C_flow_23080
    cmp word ptr [eax + _wall + 16], 0x230
    je actors_C_flow_23080
    dec word ptr [esi + 34]
actors_C_flow_23080:
    movsx eax, word ptr [esp + 28]
    shl eax, 5
    movsx ecx, word ptr [eax + _wall + 8]
    shl ecx, 5
    mov ebx, dword ptr [eax + _wall + 4]
    mov edx, dword ptr [ecx + _wall + 4]
    {store} sub edx, ebx
    {store} mov ebx, edx
    mov edx, dword ptr [ecx + _wall]
    mov ecx, dword ptr [eax + _wall]
    {store} mov eax, edx
    {store} mov edx, ebx
    {store} sub eax, ecx
    call getangle_
    mov di, word ptr [esi + 28]
    {store} add eax, eax
    {store} sub eax, edi
    and ah, 7
    mov word ptr [esi + 28], ax
    mov eax, dword ptr [esp + 24]
    {disp32} jmp actors_C_flow_20431
actors_C_flow_23161:
    .att_syntax prefix
    cmpl $actors_C_math_23161,%eax
    .intel_syntax noprefix
    {disp32} jne actors_C_flow_22697
    movsx edi, word ptr [esp + 32]
    mov ebx, dword ptr [esp + 4]
    mov edx, dword ptr [esp + 16]
    {store} mov ecx, ebp
    {store} mov eax, edi
    call setsprite_
    cmp word ptr [esi + 36], 0
    jge actors_C_flow_23264
    movsx edx, word ptr [esi + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    test byte ptr [eax + _sector + 12], 1
    je actors_C_flow_23255
    cmp byte ptr [eax + _sector + 21], 0
    jne actors_C_flow_23255
    {store} mov eax, edi
    call deletesprite_
    mov eax, dword ptr [esp + 24]
    {disp32} jmp actors_C_flow_20431
actors_C_flow_23255:
    movsx eax, word ptr [esi + 24]
    call checkhitceiling_
actors_C_flow_23264:
    cmp word ptr [esi + 14], 0x669
    {disp32} jne actors_C_flow_22697
    movsx ebx, word ptr [esp + 32]
    {store} mov eax, ebx
    mov edx, dword ptr [esp + 12]
    call bounce_
    {store} mov eax, ebx
    call ssp_
    dec word ptr [esi + 34]
    mov eax, dword ptr [esp + 24]
    {disp32} jmp actors_C_flow_20431
actors_C_flow_23312:
    movsx edx, word ptr [esp + 28]
    and edx, 0xc000
    cmp edx, 0x4000
    {disp32} jne actors_C_flow_23542
    cmp word ptr [esi + 36], 0
    jle actors_C_flow_23359
    mov edx, 0x8ab
    {store} mov eax, ebx
    call spawn_
    {disp32} jmp actors_C_flow_23542
actors_C_flow_23359:
    or byte ptr [eax + _sprite + 12], 8
    add dword ptr [eax + _sprite + 8], 0x3000
    {disp32} jmp actors_C_flow_23542
actors_C_flow_23381:
    cmp dx, 0x66e
    jne actors_C_flow_23440
    movsx edi, word ptr [esp + 32]
    mov edx, 0x678
    {store} mov eax, edi
    call spawn_
    mov eax, 0xf6
    {store} mov edx, edi
    call spritesound_
    push 0
    {store} xor ecx, ecx
    {store} xor ebx, ebx
    push 0
    mov edx, dword ptr [_shrinkerblastradius]
    {store} mov eax, edi
    call hitradius_
    jmp actors_C_flow_23542
actors_C_flow_23440:
    cmp dx, 0x550
    je actors_C_flow_23542
    cmp dx, 0x669
    je actors_C_flow_23542
    cmp dx, 0x659
    je actors_C_flow_23542
    movsx eax, word ptr [esp + 32]
    mov edx, 0x762
    call spawn_
    cwde
    imul eax, eax, 0x2c
    {store} xor edx, edx
    mov dl, byte ptr [esi + 20]
    sar edx, 1
    mov byte ptr [eax + _sprite + 21], dl
    mov byte ptr [eax + _sprite + 20], dl
    movsx edx, word ptr [esp + 28]
    and edx, 0xc000
    cmp edx, 0x4000
    jne actors_C_flow_23542
    cmp word ptr [esi + 36], 0
    jge actors_C_flow_23542
    or byte ptr [eax + _sprite + 12], 8
    add dword ptr [eax + _sprite + 8], 0x4800
actors_C_flow_23542:
    cmp word ptr [esi + 14], 0xa2d
    jne actors_C_flow_23651
    movsx edi, word ptr [esp + 32]
    mov eax, 9
    {store} mov edx, edi
    call spritesound_
    cmp byte ptr [esi + 20], 0xa
    jb actors_C_flow_23601
    movsx eax, word ptr [esi + 42]
    mov dword ptr [esp], eax
    {store} mov ebx, eax
    {store} mov ecx, eax
    sar ebx, 2
    push eax
    {store} sub eax, ebx
    mov edx, dword ptr [_rpgblastradius]
    push eax
    sar ecx, 1
    jmp actors_C_flow_23644
actors_C_flow_23601:
    mov ax, word ptr [_global_random]
    xor ah, ah
    and al, 3
    movsx edx, word ptr [esi + 42]
    cwde
    {store} add edx, eax
    mov dword ptr [esp], edx
    {store} mov ecx, edx
    push edx
    {store} mov ebx, edx
    {store} mov eax, edx
    sar ebx, 2
    mov edx, dword ptr [_rpgblastradius]
    {store} sub eax, ebx
    sar ecx, 1
    push eax
    sar edx, 1
actors_C_flow_23644:
    {store} mov eax, edi
    call hitradius_
actors_C_flow_23651:
    cmp word ptr [esi + 14], 0x550
    je actors_C_flow_23678
    movsx eax, word ptr [esp + 32]
    call deletesprite_
    mov eax, dword ptr [esp + 24]
    {disp32} jmp actors_C_flow_20431
actors_C_flow_23678:
    mov dx, word ptr [esi + 14]
    cmp dx, 0x550
    jne actors_C_flow_23725
    mov ah, byte ptr [esi + 16]
    inc ah
    mov byte ptr [esi + 16], ah
    cmp ah, 0x28
    {disp32} jl actors_C_flow_23821
actors_C_flow_23706:
    movsx eax, word ptr [esp + 32]
    call deletesprite_
    mov eax, dword ptr [esp + 24]
    {disp32} jmp actors_C_flow_20431
actors_C_flow_23725:
    cmp dx, 0xa2d
    jne actors_C_flow_23821
    movsx edx, word ptr [esi + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    cmp word ptr [eax*8 + _sector + 34], 2
    jne actors_C_flow_23821
    cmp byte ptr [esi + 20], 0xa
    jb actors_C_flow_23821
    call krand_
    sar eax, 8
    cmp eax, 0x47
    jl actors_C_flow_23821
    movsx eax, word ptr [esp + 32]
    mov edx, 0x295
    call spawn_
    mov eax, dword ptr [esp + 24]
    {disp32} jmp actors_C_flow_20431
actors_C_flow_23799:
    {store} mov edx, esp
    {store} mov eax, esi
    call findplayer_
    mov ebx, dword ptr [esp]
    movsx edx, ax
    {store} mov eax, ecx
    call execute_
actors_C_flow_23821:
    mov eax, dword ptr [esp + 24]
    {disp32} jmp actors_C_flow_20431
actors_C_flow_23830:
    add esp, 0x24
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
movetransports_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    sub esp, 0x28
    mov si, word ptr [_headspritestat + 18]
actors_C_flow_23856:
    test si, si
    {disp32} jl actors_C_flow_27149
    movsx edx, si
    imul eax, edx, 0x2c
    mov ax, word ptr [eax + _sprite + 24]
    movsx ebx, ax
    mov dword ptr [esp + 32], eax
    {disp32} lea eax, dword ptr [ebx*4]
    {store} add eax, ebx
    mov ax, word ptr [eax*8 + _sector + 34]
    mov dword ptr [esp + 20], eax
    mov ax, word ptr [edx*2 + _nextspritestat]
    mov dword ptr [esp + 28], eax
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov edx, dword ptr [eax + _hittype + 47]
    mov ebp, dword ptr [eax + _hittype + 63]
    test edx, edx
    jle actors_C_flow_23961
    lea ebx, dword ptr [edx + -1]
    mov dword ptr [eax + _hittype + 47], ebx
actors_C_flow_23961:
    movsx eax, word ptr [esp + 32]
    mov ax, word ptr [eax*2 + _headspritesect]
actors_C_flow_23974:
    mov dword ptr [esp + 24], eax
    mov edx, dword ptr [esp + 24]
    test dx, dx
    {disp32} jl actors_C_flow_27140
    movsx edi, dx
    mov ax, word ptr [edi*2 + _nextspritesect]
    imul edi, edi, 0x2c
    mov dword ptr [esp + 36], eax
    mov ax, word ptr [edi + _sprite + 26]
    .att_syntax prefix
    cmpw $actors_C_math_24016,%ax
    .intel_syntax noprefix
    jb actors_C_flow_24059
    .att_syntax prefix
    cmpw $actors_C_math_24022,%ax
    .intel_syntax noprefix
    {disp32} jbe actors_C_flow_25637
    .att_syntax prefix
    cmpw $actors_C_math_24032,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_27131
    jbe actors_C_flow_24074
    .att_syntax prefix
    cmpw $actors_C_math_24044,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_25637
    {disp32} jmp actors_C_flow_27131
actors_C_flow_24059:
    .att_syntax prefix
    cmpw $actors_C_math_24059,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_25591
    {disp32} jmp actors_C_flow_27131
actors_C_flow_24074:
    movsx eax, word ptr [edi + _sprite + 30]
    cmp eax, -1
    {disp32} je actors_C_flow_27131
    mov di, word ptr [edi + _sprite + 34]
    movsx eax, di
    imul eax, eax, 0x552
    mov dl, 1
    mov bx, word ptr [eax + _ps + 1290]
    mov byte ptr [eax + _ps + 1303], dl
    test bx, bx
    {disp32} jne actors_C_flow_27131
    cmp word ptr [eax + _ps + 696], 0
    {disp32} jne actors_C_flow_27131
    cmp byte ptr [eax + _ps + 1308], 0
    {disp32} je actors_C_flow_24576
    cmp word ptr [esp + 20], 0
    {disp32} jne actors_C_flow_24576
    test ebp, ebp
    {disp32} je actors_C_flow_24576
    cmp byte ptr [eax + _ps + 1324], 0
    {disp32} jne actors_C_flow_24576
    movsx ebx, si
    mov edx, 0x4ed
    {store} mov eax, ebx
    call spawn_
    mov eax, 0x46
    {store} mov edx, ebx
    call spritesound_
    mov bx, word ptr [_connecthead]
    jmp actors_C_flow_24304
actors_C_flow_24226:
    movsx eax, si
    imul eax, eax, 0x2c
    movsx edx, word ptr [eax + _sprite + 30]
    movsx eax, bx
    imul eax, eax, 0x552
    imul edx, edx, 0x2c
    mov cx, word ptr [eax + _ps + 646]
    cmp cx, word ptr [edx + _sprite + 24]
    jne actors_C_flow_24293
    mov word ptr [eax + _ps + 1288], di
    movsx eax, word ptr [eax + _ps + 724]
    imul eax, eax, 0x2c
    {store} xor edx, edx
    mov word ptr [eax + _sprite + 42], dx
actors_C_flow_24293:
    movsx eax, bx
    mov bx, word ptr [eax*2 + _connectpoint2]
actors_C_flow_24304:
    test bx, bx
    jge actors_C_flow_24226
    movsx ecx, si
    imul eax, ecx, 0x2c
    mov dword ptr [esp + 8], eax
    movsx eax, word ptr [eax + _sprite + 30]
    mov dword ptr [esp], eax
    imul edx, eax, 0x2c
    movsx ebx, di
    imul ebx, ebx, 0x552
    mov ax, word ptr [edx + _sprite + 28]
    mov word ptr [ebx + _ps + 640], ax
    {disp32} lea eax, dword ptr [ecx*8]
    {store} add eax, ecx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ecx
    mov dword ptr [eax + _hittype + 47], 0xd
    mov ecx, dword ptr [esp]
    {disp32} lea eax, dword ptr [ecx*8]
    {store} add eax, ecx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ecx
    mov dword ptr [eax + _hittype + 47], 0xd
    mov eax, dword ptr [edx + _sprite]
    mov dword ptr [ebx + _ps + 532], eax
    mov dword ptr [ebx + _ps + 568], eax
    mov dword ptr [ebx + _ps + 560], eax
    mov eax, dword ptr [edx + _sprite + 4]
    mov dword ptr [ebx + _ps + 536], eax
    mov dword ptr [ebx + _ps + 572], eax
    mov ecx, 0xd
    mov dword ptr [ebx + _ps + 564], eax
    mov eax, dword ptr [edx + _sprite + 8]
    mov word ptr [ebx + _ps + 1290], cx
    sub eax, 0x2600
    movsx ecx, word ptr [esp + 24]
    mov dword ptr [ebx + _ps + 540], eax
    movsx edx, word ptr [edx + _sprite + 24]
    mov dword ptr [ebx + _ps + 576], eax
    {store} mov eax, ecx
    call changespritesect_
    imul eax, ecx, 0x2c
    mov ax, word ptr [eax + _sprite + 24]
    mov word ptr [ebx + _ps + 646], ax
    mov eax, dword ptr [esp + 8]
    mov edx, 0x4ed
    movsx eax, word ptr [eax + _sprite + 30]
    call spawn_
    movsx edx, ax
    mov eax, 0x46
    call spritesound_
    mov eax, dword ptr [esp + 36]
    {disp32} jmp actors_C_flow_23974
actors_C_flow_24576:
    test ebp, ebp
    {disp32} jne actors_C_flow_25009
    movsx eax, si
    imul eax, eax, 0x2c
    movsx ebx, di
    imul edx, ebx, 0x552
    mov eax, dword ptr [eax + _sprite + 8]
    sub eax, dword ptr [edx + _ps + 540]
    test eax, eax
    jns actors_C_flow_24617
    neg eax
actors_C_flow_24617:
    .att_syntax prefix
    cmpl $actors_C_math_24617,%eax
    .intel_syntax noprefix
    {disp32} jge actors_C_flow_25009
    mov cl, byte ptr [edx + _ps + 1324]
    test cl, cl
    je actors_C_flow_24704
    je actors_C_flow_24659
    {disp32} lea eax, dword ptr [ebx*4]
    {store} add eax, ebx
    test byte ptr [eax*2 + _sync + 6], 1
    jne actors_C_flow_24704
actors_C_flow_24659:
    movsx edx, di
    imul eax, edx, 0x552
    cmp byte ptr [eax + _ps + 1324], 0
    {disp32} je actors_C_flow_25009
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    test byte ptr [eax*2 + _sync + 6], 2
    {disp32} je actors_C_flow_25009
actors_C_flow_24704:
    movsx edx, si
    imul edx, edx, 0x2c
    movsx ecx, word ptr [edx + _sprite + 30]
    imul ecx, ecx, 0x2c
    movsx eax, di
    mov dword ptr [esp + 4], eax
    imul eax, eax, 0x552
    mov ebx, dword ptr [ecx + _sprite]
    sub ebx, dword ptr [edx + _sprite]
    add dword ptr [eax + _ps + 532], ebx
    mov ebx, dword ptr [eax + _ps + 532]
    mov dword ptr [eax + _ps + 568], ebx
    mov ebx, dword ptr [ecx + _sprite + 4]
    mov ecx, dword ptr [edx + _sprite + 4]
    mov edx, dword ptr [eax + _ps + 536]
    {store} sub ebx, ecx
    {store} add edx, ebx
    mov dword ptr [eax + _ps + 536], edx
    mov cl, byte ptr [eax + _ps + 1324]
    mov dword ptr [eax + _ps + 572], edx
    test cl, cl
    je actors_C_flow_24879
    mov ebx, dword ptr [esp + 4]
    {disp32} lea edx, dword ptr [ebx*4]
    {store} add edx, ebx
    test byte ptr [edx*2 + _sync + 6], 1
    jne actors_C_flow_24835
    cmp cl, 0xb
    jae actors_C_flow_24879
actors_C_flow_24835:
    movsx eax, si
    imul eax, eax, 0x2c
    movsx eax, word ptr [eax + _sprite + 30]
    imul eax, eax, 0x2c
    movsx edx, di
    imul edx, edx, 0x552
    mov eax, dword ptr [eax + _sprite + 8]
    sub eax, 0x1800
    mov dword ptr [edx + _ps + 540], eax
    jmp actors_C_flow_24922
actors_C_flow_24879:
    movsx eax, si
    imul eax, eax, 0x2c
    movsx eax, word ptr [eax + _sprite + 30]
    imul eax, eax, 0x2c
    mov edx, dword ptr [eax + _sprite + 8]
    movsx eax, di
    imul eax, eax, 0x552
    add edx, 0x1800
    mov dword ptr [eax + _ps + 540], edx
actors_C_flow_24922:
    movsx ebx, di
    imul ebx, ebx, 0x552
    movsx ecx, si
    imul ecx, ecx, 0x2c
    mov eax, dword ptr [ebx + _ps + 540]
    mov dword ptr [ebx + _ps + 576], eax
    movsx eax, word ptr [ecx + _sprite + 30]
    imul eax, eax, 0x2c
    movsx edx, word ptr [eax + _sprite + 24]
    movsx eax, word ptr [esp + 24]
    call changespritesect_
    movsx eax, word ptr [ecx + _sprite + 30]
    imul eax, eax, 0x2c
    mov ax, word ptr [eax + _sprite + 24]
    mov word ptr [ebx + _ps + 646], ax
    mov eax, dword ptr [esp + 36]
    {disp32} jmp actors_C_flow_23974
actors_C_flow_25009:
    {store} xor ebx, ebx
    test ebp, ebp
    {disp32} je actors_C_flow_25189
    cmp word ptr [esp + 20], 1
    {disp32} jne actors_C_flow_25189
    movsx edx, word ptr [esp + 32]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov edx, dword ptr [eax*8 + _sector + 8]
    movsx eax, di
    imul eax, eax, 0x552
    sub edx, 0x600
    cmp edx, dword ptr [eax + _ps + 540]
    jge actors_C_flow_25189
    mov ax, word ptr [_screenpeek]
    mov ebx, 1
    {store} cmp di, ax
    jne actors_C_flow_25101
    call FX_StopAllSounds_
    call clearsoundlocks_
actors_C_flow_25101:
    movsx ecx, di
    imul ecx, ecx, 0x552
    mov eax, 0x30
    movsx edx, word ptr [ecx + _ps + 724]
    call spritesound_
    movsx eax, si
    imul eax, eax, 0x2c
    movsx eax, word ptr [eax + _sprite + 30]
    imul eax, eax, 0x2c
    movsx eax, word ptr [eax + _sprite + 24]
    mov dword ptr [esp], eax
    mov edx, dword ptr [esp]
    {disp32} lea eax, dword ptr [eax*4]
    {store} add eax, edx
    mov eax, dword ptr [eax*8 + _sector + 4]
    .att_syntax prefix
    addl $actors_C_math_25172,%eax
    .intel_syntax noprefix
    mov dword ptr [ecx + _ps + 540], eax
    mov dword ptr [ecx + _ps + 576], eax
actors_C_flow_25189:
    test ebp, ebp
    {disp32} je actors_C_flow_25395
    cmp word ptr [esp + 20], 2
    {disp32} jne actors_C_flow_25395
    movsx edx, word ptr [esp + 32]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov edx, dword ptr [eax*8 + _sector + 4]
    movsx eax, di
    imul eax, eax, 0x552
    add edx, 0x600
    cmp edx, dword ptr [eax + _ps + 540]
    {disp32} jle actors_C_flow_25395
    movsx eax, word ptr [eax + _ps + 724]
    imul eax, eax, 0x2c
    mov cx, word ptr [eax + _sprite + 42]
    mov ebx, 1
    test cx, cx
    {disp32} jle actors_C_flow_27131
    cmp di, word ptr [_screenpeek]
    jne actors_C_flow_25307
    call FX_StopAllSounds_
    call clearsoundlocks_
actors_C_flow_25307:
    movsx ecx, di
    imul ecx, ecx, 0x552
    mov eax, 0x19
    movsx edx, word ptr [ecx + _ps + 724]
    call spritesound_
    movsx eax, si
    imul eax, eax, 0x2c
    movsx eax, word ptr [eax + _sprite + 30]
    imul eax, eax, 0x2c
    movsx eax, word ptr [eax + _sprite + 24]
    mov dword ptr [esp], eax
    mov edx, dword ptr [esp]
    {disp32} lea eax, dword ptr [eax*4]
    {store} add eax, edx
    mov eax, dword ptr [eax*8 + _sector + 8]
    sub eax, 0x700
    mov dword ptr [ecx + _ps + 540], eax
    mov dword ptr [ecx + _ps + 576], eax
actors_C_flow_25395:
    cmp bx, 1
    {disp32} jne actors_C_flow_27131
    movsx edx, si
    imul edx, edx, 0x2c
    movsx ebx, di
    imul ebx, ebx, 0x552
    movsx eax, word ptr [edx + _sprite + 30]
    imul eax, eax, 0x2c
    mov edi, dword ptr [edx + _sprite]
    mov ecx, dword ptr [eax + _sprite]
    {store} sub ecx, edi
    mov edi, dword ptr [ebx + _ps + 532]
    {store} add edi, ecx
    mov dword ptr [ebx + _ps + 532], edi
    mov ecx, dword ptr [eax + _sprite + 4]
    mov dword ptr [ebx + _ps + 568], edi
    mov edi, dword ptr [edx + _sprite + 4]
    mov edx, dword ptr [ebx + _ps + 536]
    {store} sub ecx, edi
    {store} add edx, ecx
    mov dword ptr [ebx + _ps + 536], edx
    mov dword ptr [ebx + _ps + 572], edx
    mov word ptr [ebx + _ps + 1290], 0xfffe
    mov dx, word ptr [eax + _sprite + 24]
    movsx eax, word ptr [esp + 24]
    mov word ptr [ebx + _ps + 646], dx
    movsx edx, dx
    call changespritesect_
    mov eax, OFFSET FLAT:_ps
    {store} add eax, ebx
    call setpal_
    call krand_
    and eax, 0xff
    cmp eax, 0x20
    {disp32} jge actors_C_flow_27131
    mov edx, 0x564
    movsx eax, word ptr [ebx + _ps + 724]
    call spawn_
    mov eax, dword ptr [esp + 36]
    {disp32} jmp actors_C_flow_23974
actors_C_flow_25591:
    movsx eax, si
    imul eax, eax, 0x2c
    mov bx, word ptr [eax + _sprite + 14]
    cmp bx, 0x60e
    {disp32} je actors_C_flow_27131
    cmp bx, 0x780
    {disp32} je actors_C_flow_27131
    cmp bx, 0x71c
    {disp32} je actors_C_flow_27131
actors_C_flow_25637:
    movsx ecx, word ptr [esp + 24]
    imul ecx, ecx, 0x2c
    mov ax, word ptr [ecx + _sprite + 36]
    cwde
    xor dl, dl
    test eax, eax
    jns actors_C_flow_25661
    neg eax
actors_C_flow_25661:
    {store} mov ebx, eax
    mov dword ptr [esp + 16], eax
    test eax, eax
    je actors_C_flow_25720
    cmp word ptr [esp + 20], 2
    jne actors_C_flow_25720
    movsx eax, word ptr [esp + 32]
    mov dword ptr [esp], eax
    mov edi, dword ptr [esp]
    {disp32} lea eax, dword ptr [eax*4]
    {store} add eax, edi
    mov edi, dword ptr [eax*8 + _sector + 4]
    mov eax, dword ptr [ecx + _sprite + 8]
    {store} add ebx, edi
    {store} cmp ebx, eax
    jle actors_C_flow_25720
    mov dl, 1
actors_C_flow_25720:
    cmp dword ptr [esp + 16], 0
    je actors_C_flow_25778
    cmp word ptr [esp + 20], 1
    jne actors_C_flow_25778
    movsx ebx, word ptr [esp + 32]
    {disp32} lea eax, dword ptr [ebx*4]
    {store} add eax, ebx
    mov ebx, dword ptr [eax*8 + _sector + 8]
    movsx eax, word ptr [esp + 24]
    imul eax, eax, 0x2c
    sub ebx, dword ptr [esp + 16]
    cmp ebx, dword ptr [eax + _sprite + 8]
    jge actors_C_flow_25778
    mov dl, 1
actors_C_flow_25778:
    cmp word ptr [esp + 20], 0
    {disp32} jne actors_C_flow_25898
    test ebp, ebp
    jne actors_C_flow_25833
    movsx eax, word ptr [esp + 24]
    imul eax, eax, 0x2c
    movsx ebx, si
    imul ebx, ebx, 0x2c
    mov eax, dword ptr [eax + _sprite + 8]
    sub eax, dword ptr [ebx + _sprite + 8]
    test eax, eax
    jns actors_C_flow_25826
    neg eax
actors_C_flow_25826:
    .att_syntax prefix
    cmpl $actors_C_math_25826,%eax
    .intel_syntax noprefix
    jge actors_C_flow_25898
actors_C_flow_25833:
    test ebp, ebp
    je actors_C_flow_25896
    movsx edx, si
    {disp32} lea ecx, dword ptr [edx*8]
    {store} add ecx, edx
    {disp32} lea ecx, dword ptr [ecx*8]
    {store} sub ecx, edx
    cmp dword ptr [ecx + _hittype + 47], 0
    jle actors_C_flow_25896
    movsx eax, word ptr [esp + 24]
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 26], 5
    je actors_C_flow_25896
    inc dword ptr [ecx + _hittype + 47]
    {disp32} jmp actors_C_flow_27140
actors_C_flow_25896:
    mov dl, 1
actors_C_flow_25898:
    test dl, dl
    {disp32} je actors_C_flow_27131
    movsx edx, word ptr [esp + 24]
    imul edx, edx, 0x2c
    mov ax, word ptr [edx + _sprite + 14]
    .att_syntax prefix
    cmpw $actors_C_math_25921,%ax
    .intel_syntax noprefix
    jb actors_C_flow_26014
    {disp32} jbe actors_C_flow_27131
    .att_syntax prefix
    cmpw $actors_C_math_25933,%ax
    .intel_syntax noprefix
    jb actors_C_flow_25976
    {disp32} jbe actors_C_flow_27131
    .att_syntax prefix
    cmpw $actors_C_math_25945,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_26090
    {disp32} jbe actors_C_flow_27131
    .att_syntax prefix
    cmpw $actors_C_math_25961,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_27131
    {disp32} jmp actors_C_flow_26090
actors_C_flow_25976:
    .att_syntax prefix
    cmpw $actors_C_math_25976,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_26090
    .att_syntax prefix
    cmpw $actors_C_math_25986,%ax
    .intel_syntax noprefix
    {disp32} jbe actors_C_flow_27131
    .att_syntax prefix
    cmpw $actors_C_math_25996,%ax
    .intel_syntax noprefix
    jb actors_C_flow_26090
    .att_syntax prefix
    cmpw $actors_C_math_26002,%ax
    .intel_syntax noprefix
    {disp32} jbe actors_C_flow_27131
    jmp actors_C_flow_26090
actors_C_flow_26014:
    .att_syntax prefix
    cmpw $actors_C_math_26014,%ax
    .intel_syntax noprefix
    jb actors_C_flow_26046
    {disp32} jbe actors_C_flow_27131
    .att_syntax prefix
    cmpw $actors_C_math_26026,%ax
    .intel_syntax noprefix
    jb actors_C_flow_26090
    {disp32} jbe actors_C_flow_27131
    .att_syntax prefix
    cmpw $actors_C_math_26038,%ax
    .intel_syntax noprefix
    je actors_C_flow_26066
    jmp actors_C_flow_26090
actors_C_flow_26046:
    .att_syntax prefix
    cmpw $actors_C_math_26046,%ax
    .intel_syntax noprefix
    jb actors_C_flow_26090
    jbe actors_C_flow_26112
    .att_syntax prefix
    cmpw $actors_C_math_26054,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_27131
    jmp actors_C_flow_26090
actors_C_flow_26066:
    cmp word ptr [esp + 20], 2
    jne actors_C_flow_26090
    and byte ptr [edx + _sprite + 13], 0x7f
    mov eax, dword ptr [esp + 36]
    {disp32} jmp actors_C_flow_23974
actors_C_flow_26090:
    movsx eax, word ptr [esp + 24]
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 26], 5
    {disp32} je actors_C_flow_27131
actors_C_flow_26112:
    call krand_
    sar eax, 8
    cmp eax, 0x3f
    jl actors_C_flow_26148
    movsx eax, word ptr [esp + 24]
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 14], 0x295
    {disp32} je actors_C_flow_27131
actors_C_flow_26148:
    mov ecx, dword ptr [esp + 20]
    test cx, cx
    jle actors_C_flow_26239
    movsx ebx, word ptr [esp + 24]
    mov edx, 0x564
    {store} mov eax, ebx
    call spawn_
    cmp cx, 1
    jne actors_C_flow_26239
    imul ebx, ebx, 0x2c
    cmp word ptr [ebx + _sprite + 26], 4
    jne actors_C_flow_26239
    movsx edx, word ptr [ebx + _sprite + 32]
    sar edx, 1
    cwde
    {store} mov ecx, edx
    imul edx, eax, 0x2c
    mov word ptr [edx + _sprite + 32], cx
    mov bx, word ptr [ebx + _sprite + 28]
    mov word ptr [edx + _sprite + 28], bx
    mov edx, 0x10001
    call ssp_
actors_C_flow_26239:
    mov ebx, dword ptr [esp + 20]
    cmp bx, 1
    jb actors_C_flow_26274
    {disp32} jbe actors_C_flow_26807
    cmp bx, 2
    {disp32} je actors_C_flow_26928
    mov eax, dword ptr [esp + 36]
    {disp32} jmp actors_C_flow_23974
actors_C_flow_26274:
    test bx, bx
    {disp32} jne actors_C_flow_27131
    test ebp, ebp
    {disp32} je actors_C_flow_26707
    movsx eax, word ptr [esp + 32]
    call checkcursectnums_
    cwde
    cmp eax, -1
    {disp32} jne actors_C_flow_27131
    movsx ecx, si
    imul ebx, ecx, 0x2c
    movsx eax, word ptr [ebx + _sprite + 30]
    imul eax, eax, 0x2c
    movsx eax, word ptr [eax + _sprite + 24]
    call checkcursectnums_
    cwde
    cmp eax, -1
    {disp32} jne actors_C_flow_27131
    movsx edx, word ptr [ebx + _sprite + 30]
    imul edx, edx, 0x2c
    movsx eax, word ptr [esp + 24]
    mov dword ptr [esp + 12], eax
    imul eax, eax, 0x2c
    mov edi, dword ptr [ebx + _sprite]
    mov edx, dword ptr [edx + _sprite]
    {store} sub edx, edi
    add dword ptr [eax + _sprite], edx
    movsx edx, word ptr [ebx + _sprite + 30]
    imul edx, edx, 0x2c
    mov edi, dword ptr [ebx + _sprite + 4]
    mov edx, dword ptr [edx + _sprite + 4]
    {store} sub edx, edi
    add dword ptr [eax + _sprite + 4], edx
    movsx edx, word ptr [ebx + _sprite + 30]
    imul edx, edx, 0x2c
    movsx edx, word ptr [edx + _sprite + 24]
    mov dword ptr [esp], edx
    mov edi, dword ptr [esp]
    {disp32} lea edx, dword ptr [edx*4]
    {store} add edx, edi
    mov edi, dword ptr [ebx + _sprite + 8]
    mov edx, dword ptr [edx*8 + _sector + 8]
    {store} sub edi, edx
    {store} mov edx, edi
    sub dword ptr [eax + _sprite + 8], edx
    movsx edx, word ptr [ebx + _sprite + 30]
    imul edx, edx, 0x2c
    mov dx, word ptr [edx + _sprite + 28]
    mov word ptr [eax + _sprite + 28], dx
    mov edx, dword ptr [esp + 12]
    mov dword ptr [esp], edx
    mov edi, dword ptr [esp]
    {disp32} lea edx, dword ptr [edx*8]
    {store} add edx, edi
    {disp32} lea edx, dword ptr [edx*8]
    {store} sub edx, edi
    mov edi, dword ptr [eax + _sprite]
    mov dword ptr [edx + _hittype + 35], edi
    mov edi, dword ptr [eax + _sprite + 4]
    mov eax, dword ptr [eax + _sprite + 8]
    mov dword ptr [edx + _hittype + 39], edi
    mov dword ptr [edx + _hittype + 43], eax
    mov edx, 0x4ed
    {store} mov eax, ecx
    call spawn_
    movsx edx, ax
    mov eax, 0x46
    call spritesound_
    mov edx, 0x4ed
    movsx eax, word ptr [ebx + _sprite + 30]
    call spawn_
    movsx edx, ax
    mov eax, 0x46
    call spritesound_
    {disp32} lea eax, dword ptr [ecx*8]
    {store} add eax, ecx
    {disp32} lea eax, dword ptr [eax*8]
    mov edx, 0xd
    {store} sub eax, ecx
    movsx ebx, word ptr [ebx + _sprite + 30]
    mov dword ptr [eax + _hittype + 47], edx
    {disp32} lea eax, dword ptr [ebx*8]
    {store} add eax, ebx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ebx
    mov dword ptr [eax + _hittype + 47], edx
    imul edx, ebx, 0x2c
    mov eax, dword ptr [esp + 12]
    movsx edx, word ptr [edx + _sprite + 24]
    call changespritesect_
    mov eax, dword ptr [esp + 36]
    {disp32} jmp actors_C_flow_23974
actors_C_flow_26707:
    movsx ebx, si
    imul ebx, ebx, 0x2c
    movsx ecx, word ptr [esp + 24]
    imul edx, ecx, 0x2c
    movsx eax, word ptr [ebx + _sprite + 30]
    imul eax, eax, 0x2c
    mov edi, dword ptr [ebx + _sprite]
    mov eax, dword ptr [eax + _sprite]
    {store} sub eax, edi
    add dword ptr [edx + _sprite], eax
    movsx eax, word ptr [ebx + _sprite + 30]
    imul eax, eax, 0x2c
    mov edi, dword ptr [ebx + _sprite + 4]
    mov eax, dword ptr [eax + _sprite + 4]
    {store} sub eax, edi
    add dword ptr [edx + _sprite + 4], eax
    movsx eax, word ptr [ebx + _sprite + 30]
    imul eax, eax, 0x2c
    mov eax, dword ptr [eax + _sprite + 8]
    .att_syntax prefix
    addl $actors_C_math_26797,%eax
    .intel_syntax noprefix
    {disp32} jmp actors_C_flow_27047
actors_C_flow_26807:
    movsx ebx, si
    imul ebx, ebx, 0x2c
    movsx ecx, word ptr [esp + 24]
    imul edx, ecx, 0x2c
    movsx eax, word ptr [ebx + _sprite + 30]
    imul eax, eax, 0x2c
    mov edi, dword ptr [ebx + _sprite]
    mov eax, dword ptr [eax + _sprite]
    {store} sub eax, edi
    add dword ptr [edx + _sprite], eax
    movsx eax, word ptr [ebx + _sprite + 30]
    imul eax, eax, 0x2c
    mov edi, dword ptr [ebx + _sprite + 4]
    mov eax, dword ptr [eax + _sprite + 4]
    {store} sub eax, edi
    add dword ptr [edx + _sprite + 4], eax
    movsx eax, word ptr [ebx + _sprite + 30]
    imul eax, eax, 0x2c
    movsx eax, word ptr [eax + _sprite + 24]
    mov dword ptr [esp], eax
    mov edi, dword ptr [esp]
    {disp32} lea eax, dword ptr [eax*4]
    {store} add eax, edi
    mov edi, dword ptr [esp + 16]
    mov eax, dword ptr [eax*8 + _sector + 4]
    {store} add eax, edi
    jmp actors_C_flow_27047
actors_C_flow_26928:
    movsx ebx, si
    imul ebx, ebx, 0x2c
    movsx ecx, word ptr [esp + 24]
    imul edx, ecx, 0x2c
    movsx eax, word ptr [ebx + _sprite + 30]
    imul eax, eax, 0x2c
    mov edi, dword ptr [ebx + _sprite]
    mov eax, dword ptr [eax + _sprite]
    {store} sub eax, edi
    add dword ptr [edx + _sprite], eax
    movsx eax, word ptr [ebx + _sprite + 30]
    imul eax, eax, 0x2c
    mov edi, dword ptr [ebx + _sprite + 4]
    mov eax, dword ptr [eax + _sprite + 4]
    {store} sub eax, edi
    add dword ptr [edx + _sprite + 4], eax
    movsx eax, word ptr [ebx + _sprite + 30]
    imul eax, eax, 0x2c
    movsx eax, word ptr [eax + _sprite + 24]
    mov dword ptr [esp], eax
    mov edi, dword ptr [esp]
    {disp32} lea eax, dword ptr [eax*4]
    {store} add eax, edi
    mov edi, dword ptr [esp + 16]
    mov eax, dword ptr [eax*8 + _sector + 8]
    {store} sub eax, edi
actors_C_flow_27047:
    mov dword ptr [edx + _sprite + 8], eax
    {disp32} lea eax, dword ptr [ecx*8]
    {store} add eax, ecx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ecx
    mov edi, dword ptr [edx + _sprite]
    mov dword ptr [eax + _hittype + 35], edi
    mov edi, dword ptr [edx + _sprite + 4]
    mov edx, dword ptr [edx + _sprite + 8]
    mov dword ptr [eax + _hittype + 39], edi
    mov dword ptr [eax + _hittype + 43], edx
    movsx eax, word ptr [ebx + _sprite + 30]
    imul eax, eax, 0x2c
    movsx edx, word ptr [eax + _sprite + 24]
    {store} mov eax, ecx
    call changespritesect_
actors_C_flow_27131:
    mov eax, dword ptr [esp + 36]
    {disp32} jmp actors_C_flow_23974
actors_C_flow_27140:
    mov esi, dword ptr [esp + 28]
    {disp32} jmp actors_C_flow_23856
actors_C_flow_27149:
    add esp, 0x28
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    nop
actors_C_switch_27160:
    .long actors_C_flow_37853
actors_C_switch_view_27164: # genuine interior switch-table entry
    .long actors_C_flow_37975
actors_C_switch_view_27168: # genuine interior switch-table entry
    .long actors_C_flow_38039
actors_C_switch_view_27172: # genuine interior switch-table entry
    .long actors_C_flow_38039
actors_C_switch_view_27176: # genuine interior switch-table entry
    .long actors_C_flow_37975
actors_C_switch_view_27180: # genuine interior switch-table entry
    .long actors_C_flow_38039
actors_C_switch_view_27184: # genuine interior switch-table entry
    .long actors_C_flow_38039
actors_C_switch_view_27188: # genuine interior switch-table entry
    .long actors_C_flow_37975
actors_C_switch_view_27192: # genuine interior switch-table entry
    .long actors_C_flow_38039
actors_C_switch_view_27196: # genuine interior switch-table entry
    .long actors_C_flow_38039
actors_C_switch_view_27200: # genuine interior switch-table entry
    .long actors_C_flow_38039
actors_C_switch_view_27204: # genuine interior switch-table entry
    .long actors_C_flow_38039
actors_C_switch_view_27208: # genuine interior switch-table entry
    .long actors_C_flow_37975
    {disp8} lea eax, dword ptr [eax + eiz*1]
moveactors_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    sub esp, 0x30
    mov ax, word ptr [_headspritestat + 2]
actors_C_flow_27231:
    mov dword ptr [esp + 32], eax
    mov edx, dword ptr [esp + 32]
    test dx, dx
    {disp32} jl actors_C_flow_38727
    movsx edx, dx
    imul ebp, edx, 0x2c
    mov ax, word ptr [edx*2 + _nextspritestat]
    add ebp, OFFSET FLAT:_sprite
    mov dword ptr [esp + 40], eax
    mov ah, byte ptr [ebp + 20]
    mov si, word ptr [ebp + 24]
    test ah, ah
    je actors_C_flow_27295
    test si, si
    jl actors_C_flow_27295
    cmp si, 0x400
    jl actors_C_flow_27310
actors_C_flow_27295:
    movsx eax, word ptr [esp + 32]
    call deletesprite_
    {disp32} jmp actors_C_flow_38718
actors_C_flow_27310:
    {disp32} lea ebx, dword ptr [edx*8]
    {store} add ebx, edx
    {disp32} lea ebx, dword ptr [ebx*8]
    mov eax, OFFSET FLAT:_hittype
    {store} sub ebx, edx
    {store} add eax, ebx
    add eax, 0x2f
    mov dword ptr [esp + 24], eax
    {disp8} mov eax, dword ptr [ebp]
    mov dword ptr [ebx + _hittype + 35], eax
    mov eax, dword ptr [ebp + 4]
    mov dword ptr [ebx + _hittype + 39], eax
    mov eax, dword ptr [ebp + 8]
    mov dword ptr [ebx + _hittype + 43], eax
    mov ax, word ptr [ebp + 14]
    .att_syntax prefix
    cmpw $actors_C_math_27373,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_27582
    {disp32} jbe actors_C_flow_27870
    .att_syntax prefix
    cmpw $actors_C_math_27389,%ax
    .intel_syntax noprefix
    jb actors_C_flow_27459
    {disp32} jbe actors_C_flow_27870
    .att_syntax prefix
    cmpw $actors_C_math_27401,%ax
    .intel_syntax noprefix
    jb actors_C_flow_27444
    {disp32} jbe actors_C_flow_27698
    .att_syntax prefix
    cmpw $actors_C_math_27413,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_27522
    {disp32} jbe actors_C_flow_27698
    .att_syntax prefix
    cmpw $actors_C_math_27429,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_27698
    {disp32} jmp actors_C_flow_27522
actors_C_flow_27444:
    .att_syntax prefix
    cmpw $actors_C_math_27444,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_29254
    {disp32} jmp actors_C_flow_27522
actors_C_flow_27459:
    .att_syntax prefix
    cmpw $actors_C_math_27459,%ax
    .intel_syntax noprefix
    jb actors_C_flow_27512
    {disp32} jbe actors_C_flow_29712
    .att_syntax prefix
    cmpw $actors_C_math_27471,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_27522
    {disp32} jbe actors_C_flow_31665
    .att_syntax prefix
    cmpw $actors_C_math_27487,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_27522
    .att_syntax prefix
    cmpw $actors_C_math_27497,%ax
    .intel_syntax noprefix
    {disp32} jbe actors_C_flow_31806
    {disp32} jmp actors_C_flow_27522
actors_C_flow_27512:
    .att_syntax prefix
    cmpw $actors_C_math_27512,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_35384
actors_C_flow_27522:
    cmp word ptr [_ud + 1424], 2
    {disp32} jge actors_C_flow_38690
    {store} mov eax, ebp
    call badguy_
    test ax, ax
    {disp32} je actors_C_flow_38690
    mov dh, byte ptr [_actor_tog]
    cmp dh, 1
    {disp32} jne actors_C_flow_38679
    mov word ptr [ebp + 12], 0x8000
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_27582:
    .att_syntax prefix
    cmpw $actors_C_math_27582,%ax
    .intel_syntax noprefix
    jb actors_C_flow_27646
    .att_syntax prefix
    cmpw $actors_C_math_27588,%ax
    .intel_syntax noprefix
    {disp32} jbe actors_C_flow_28368
    .att_syntax prefix
    cmpw $actors_C_math_27598,%ax
    .intel_syntax noprefix
    jb actors_C_flow_27634
    {disp32} jbe actors_C_flow_37292
    .att_syntax prefix
    cmpw $actors_C_math_27610,%ax
    .intel_syntax noprefix
    jb actors_C_flow_27522
    {disp32} jbe actors_C_flow_38718
    .att_syntax prefix
    cmpw $actors_C_math_27622,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_28123
    jmp actors_C_flow_27522
actors_C_flow_27634:
    .att_syntax prefix
    cmpw $actors_C_math_27634,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_35384
    jmp actors_C_flow_27522
actors_C_flow_27646:
    .att_syntax prefix
    cmpw $actors_C_math_27646,%ax
    .intel_syntax noprefix
    jb actors_C_flow_27683
    {disp32} jbe actors_C_flow_37292
    .att_syntax prefix
    cmpw $actors_C_math_27658,%ax
    .intel_syntax noprefix
    {disp32} jbe actors_C_flow_38718
    .att_syntax prefix
    cmpw $actors_C_math_27668,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_38351
    {disp32} jmp actors_C_flow_27522
actors_C_flow_27683:
    .att_syntax prefix
    cmpw $actors_C_math_27683,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_35430
    {disp32} jmp actors_C_flow_27522
actors_C_flow_27698:
    movsx edx, word ptr [esp + 32]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov ebx, dword ptr [eax + _hittype + 47]
    inc ebx
    mov ecx, dword ptr [_respawnitemtime]
    mov dword ptr [eax + _hittype + 47], ebx
    {store} cmp ebx, ecx
    jle actors_C_flow_27760
    {store} mov eax, edx
    call deletesprite_
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_27760:
    {store} mov ebx, ecx
    mov esi, dword ptr [eax + _hittype + 47]
    sar ebx, 1
    {store} cmp ebx, esi
    jg actors_C_flow_27800
    sar ecx, 2
    {store} add ebx, ecx
    {store} cmp ebx, esi
    jle actors_C_flow_27800
    imul edx, edx, 0x2c
    mov word ptr [edx + _sprite + 14], 0xc80
    {disp32} jmp actors_C_flow_27522
actors_C_flow_27800:
    movsx ebx, word ptr [esp + 32]
    mov edx, dword ptr [_respawnitemtime]
    {disp32} lea ecx, dword ptr [ebx*8]
    mov eax, dword ptr [_respawnitemtime]
    {store} add ecx, ebx
    sar edx, 1
    {disp32} lea ecx, dword ptr [ecx*8]
    sar eax, 2
    {store} sub ecx, ebx
    {store} add eax, edx
    cmp eax, dword ptr [ecx + _hittype + 47]
    {disp32} jge actors_C_flow_27522
    imul ebx, ebx, 0x2c
    mov word ptr [ebx + _sprite + 14], 0xc8a
    {disp32} jmp actors_C_flow_27522
actors_C_flow_27870:
    movsx eax, word ptr [ebp + 36]
    mov esi, dword ptr [ebp + 8]
    {store} add esi, eax
    mov eax, dword ptr [esp + 24]
    mov dword ptr [ebp + 8], esi
    mov edi, dword ptr [eax]
    inc edi
    mov dword ptr [eax], edi
    cmp edi, 4
    jne actors_C_flow_27911
    movsx edx, word ptr [esp + 32]
    mov eax, 0xe8
    call spritesound_
actors_C_flow_27911:
    mov eax, dword ptr [esp + 24]
    cmp dword ptr [eax], 0xd0
    {disp32} jle actors_C_flow_28083
    mov eax, 9
    {store} xor edi, edi
    call sound_
    mov word ptr [esp + 36], di
    jmp actors_C_flow_28049
actors_C_flow_27946:
    push 5
    movsx eax, word ptr [esp + 36]
    push eax
    mov edx, 0xfffffe00
    call krand_
    and eax, 0x7ff
    {store} sub edx, eax
    push edx
    call krand_
    xor ah, ah
    and al, 0x3f
    .att_syntax prefix
    addl $actors_C_math_27981,%eax
    .intel_syntax noprefix
    cwde
    push eax
    call krand_
    and ah, 7
    cwde
    push eax
    push 0x30
    push 0x30
    push -8
    call krand_
    xor ah, ah
    mov ecx, dword ptr [ebp + 8]
    and al, 0xf
    mov ebx, dword ptr [ebp + 4]
    .att_syntax prefix
    addl $actors_C_math_28019,%eax
    .intel_syntax noprefix
    {disp8} mov edx, dword ptr [ebp]
    cwde
    sub ecx, 0xc00
    push eax
    movsx eax, word ptr [ebp + 24]
    call EGS_
    inc word ptr [esp + 36]
actors_C_flow_28049:
    cmp word ptr [esp + 36], 0x20
    jl actors_C_flow_27946
    mov byte ptr [_earthquaketime], 0x10
    movsx eax, word ptr [esp + 32]
    call deletesprite_
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_28083:
    test byte ptr [eax], 3
    jne actors_C_flow_28103
    movsx eax, word ptr [esp + 32]
    mov edx, 0x762
    call spawn_
actors_C_flow_28103:
    movsx eax, word ptr [esp + 32]
    mov edx, 0x10001
    call ssp_
    {disp32} jmp actors_C_flow_27522
actors_C_flow_28123:
    movsx eax, word ptr [esp + 32]
    mov edx, 0x10001
    call makeitfall_
    movsx eax, word ptr [esp + 32]
    call ssp_
    test ax, ax
    je actors_C_flow_28223
    call krand_
    test al, 0xff
    jne actors_C_flow_28177
    movsx edx, word ptr [esp + 32]
    mov eax, 0xf7
    call spritesound_
actors_C_flow_28177:
    mov eax, dword ptr [esp + 24]
    mov eax, dword ptr [eax]
    shl eax, 8
    and eax, 0x7ff
    movsx ebx, word ptr [eax*2 + _sintable]
    call krand_
    and eax, 0x1f
    lea edx, dword ptr [eax + -15]
    sar ebx, 0xb
    movsx eax, word ptr [ebp + 28]
    {store} add edx, ebx
    {store} add eax, edx
    jmp actors_C_flow_28318
actors_C_flow_28223:
    movsx edx, word ptr [esp + 32]
    {disp32} lea ebx, dword ptr [edx*8]
    {store} add ebx, edx
    {disp32} lea ebx, dword ptr [ebx*8]
    {store} sub ebx, edx
    movsx edx, word ptr [esp + 32]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    mov ecx, dword ptr [ebx + _hittype + 47]
    {disp32} lea eax, dword ptr [eax*8]
    inc ecx
    {store} sub eax, edx
    mov dword ptr [ebx + _hittype + 47], ecx
    cmp dword ptr [eax + _hittype + 47], 1
    jle actors_C_flow_28310
    movsx eax, word ptr [esp + 32]
    call deletesprite_
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_28310:
    call krand_
    and ah, 7
actors_C_flow_28318:
    mov word ptr [ebp + 28], ax
    mov ax, word ptr [ebp + 32]
    .att_syntax prefix
    cmpw $actors_C_math_28326,%ax
    .intel_syntax noprefix
    jge actors_C_flow_28341
    {store} mov edx, eax
    add edx, 2
    mov word ptr [ebp + 32], dx
actors_C_flow_28341:
    call krand_
    xor ah, ah
    and al, 3
    mov bx, word ptr [ebp + 28]
    sub eax, 6
    {store} add ebx, eax
    mov word ptr [ebp + 28], bx
    {disp32} jmp actors_C_flow_27522
actors_C_flow_28368:
    cmp word ptr [ebp + 32], 0
    {disp32} je actors_C_flow_28766
    mov ax, word ptr [_headspritestat]
    mov word ptr [esp + 36], ax
actors_C_flow_28390:
    mov eax, dword ptr [esp + 36]
    test ax, ax
    jl actors_C_flow_28465
    cwde
    mov bx, word ptr [eax*2 + _nextspritestat]
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 14], 0x387
    jne actors_C_flow_28458
    add eax, OFFSET FLAT:_sprite
    {store} mov edx, ebp
    call ldist_
    cmp eax, 0x34
    jge actors_C_flow_28458
    movsx eax, word ptr [esp + 32]
    call deletesprite_
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_28458:
    mov word ptr [esp + 36], bx
    jmp actors_C_flow_28390
actors_C_flow_28465:
    mov ax, word ptr [ebp + 28]
    and ah, 7
    cwde
    movsx edx, word ptr [eax*2 + _sintable]
    movsx eax, word ptr [ebp + 32]
    imul edx, eax
    push 0x1000040
    push 0x400
    push 0x400
    sar edx, 0xe
    push 0x18
    shl edx, 0xd
    push edx
    movsx edx, word ptr [ebp + 28]
    add edx, 0x200
    and edx, 0x7ff
    movsx edx, word ptr [edx*2 + _sintable]
    imul eax, edx
    lea ecx, dword ptr [ebp + 24]
    sar eax, 0xe
    lea ebx, dword ptr [ebp + 8]
    shl eax, 0xd
    lea edx, dword ptr [ebp + 4]
    push eax
    {store} mov eax, ebp
    call clipmove_
    movsx edx, ax
    test dh, 0xc0
    {disp32} je actors_C_flow_28693
    and edx, 0xc000
    cmp edx, 0x8000
    jne actors_C_flow_28664
    and ah, 0x1f
    movsx edx, ax
    shl edx, 5
    movsx ecx, word ptr [edx + _wall + 8]
    mov word ptr [esp + 36], ax
    shl ecx, 5
    mov edi, dword ptr [edx + _wall + 4]
    mov ebx, dword ptr [ecx + _wall + 4]
    mov eax, dword ptr [ecx + _wall]
    {store} sub ebx, edi
    mov ecx, dword ptr [edx + _wall]
    {store} mov edx, ebx
    {store} sub eax, ecx
    call getangle_
    mov dx, word ptr [ebp + 28]
    {store} add eax, eax
    {store} sub eax, edx
    and ah, 7
    mov word ptr [ebp + 28], ax
    jmp actors_C_flow_28693
actors_C_flow_28664:
    cmp edx, 0xc000
    jne actors_C_flow_28693
    and ah, 0xf
    mov word ptr [esp + 36], ax
    movsx edx, ax
    movsx eax, word ptr [esp + 32]
    call checkhitsprite_
actors_C_flow_28693:
    mov bx, word ptr [ebp + 32]
    dec ebx
    mov word ptr [ebp + 32], bx
    test bx, bx
    jge actors_C_flow_28713
    mov word ptr [ebp + 32], 0
actors_C_flow_28713:
    cmp word ptr [ebp + 14], 0x385
    {disp32} jne actors_C_flow_27522
    mov ax, word ptr [ebp + 32]
    mov word ptr [ebp + 12], 0x101
    xor ah, ah
    mov di, word ptr [ebp + 12]
    and al, 4
    {store} or edi, eax
    mov ax, word ptr [ebp + 32]
    xor ah, ah
    {store} mov edx, edi
    and al, 8
    {store} or edx, eax
    mov word ptr [ebp + 12], dx
    {disp32} jmp actors_C_flow_27522
actors_C_flow_28766:
    lea edx, dword ptr [esp + 16]
    {store} mov eax, ebp
    call findplayer_
    mov dword ptr [esp + 44], eax
    cmp dword ptr [esp + 16], 0x63c
    {disp32} jge actors_C_flow_29168
    movsx eax, word ptr [esp + 44]
    imul edx, eax, 0x552
    mov eax, dword ptr [ebp + 4]
    mov ebx, dword ptr [edx + _ps + 536]
    {store} mov edx, eax
    {store} sub edx, ebx
    movsx ebx, word ptr [esp + 44]
    imul ebx, ebx, 0x552
    {disp8} mov eax, dword ptr [ebp]
    sub eax, dword ptr [ebx + _ps + 532]
    call getangle_
    movsx edx, ax
    movsx eax, word ptr [esp + 44]
    imul eax, eax, 0x552
    movsx eax, word ptr [eax + _ps + 640]
    call getincangle_
    mov word ptr [esp + 36], ax
    cwde
    cmp eax, -64
    {disp32} jle actors_C_flow_29168
    cmp word ptr [esp + 36], 0x40
    {disp32} jge actors_C_flow_29168
    movsx edx, word ptr [esp + 44]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    test byte ptr [eax*2 + _sync + 9], 0x20
    {disp32} je actors_C_flow_29168
    movsx eax, word ptr [esp + 44]
    imul eax, eax, 0x552
    cmp byte ptr [eax + _ps + 1349], 1
    {disp32} jne actors_C_flow_29168
    mov bx, word ptr [_headspritestat + 2]
actors_C_flow_28956:
    test bx, bx
    {disp32} jl actors_C_flow_29111
    movsx eax, bx
    imul eax, eax, 0x2c
    mov cx, word ptr [eax + _sprite + 14]
    cmp cx, 0x386
    je actors_C_flow_28992
    cmp cx, 0x385
    jne actors_C_flow_29095
actors_C_flow_28992:
    movsx esi, bx
    imul esi, esi, 0x2c
    movsx ecx, word ptr [esp + 44]
    imul ecx, ecx, 0x552
    mov edx, dword ptr [esi + _sprite + 4]
    mov edi, dword ptr [ecx + _ps + 536]
    mov eax, dword ptr [esi + _sprite]
    {store} sub edx, edi
    sub eax, dword ptr [ecx + _ps + 532]
    call getangle_
    movsx edx, ax
    movsx eax, word ptr [ecx + _ps + 640]
    call getincangle_
    movsx edx, ax
    cmp edx, -64
    jle actors_C_flow_29095
    .att_syntax prefix
    cmpw $actors_C_math_29063,%ax
    .intel_syntax noprefix
    jge actors_C_flow_29095
    mov eax, OFFSET FLAT:_sprite
    lea edx, dword ptr [esp + 20]
    {store} add eax, esi
    call findplayer_
    mov eax, dword ptr [esp + 16]
    cmp eax, dword ptr [esp + 20]
    jg actors_C_flow_29111
actors_C_flow_29095:
    movsx eax, bx
    mov bx, word ptr [eax*2 + _nextspritestat]
    {disp32} jmp actors_C_flow_28956
actors_C_flow_29111:
    movsx eax, bx
    cmp eax, -1
    jne actors_C_flow_29168
    cmp byte ptr [ebp + 17], 0xc
    jne actors_C_flow_29133
    mov word ptr [ebp + 32], 0xa4
    jmp actors_C_flow_29139
actors_C_flow_29133:
    mov word ptr [ebp + 32], 0x8c
actors_C_flow_29139:
    movsx eax, word ptr [esp + 44]
    imul eax, eax, 0x552
    mov dx, word ptr [eax + _ps + 640]
    mov word ptr [ebp + 28], dx
    mov byte ptr [eax + _ps + 1349], 2
actors_C_flow_29168:
    cmp dword ptr [esp + 16], 0x200
    {disp32} jge actors_C_flow_27522
    movsx edx, word ptr [esp + 44]
    imul edx, edx, 0x552
    mov ax, word ptr [ebp + 24]
    cmp ax, word ptr [edx + _ps + 646]
    {disp32} jne actors_C_flow_27522
    mov ebx, dword ptr [ebp + 4]
    mov ecx, dword ptr [edx + _ps + 536]
    {disp8} mov eax, dword ptr [ebp]
    mov esi, dword ptr [edx + _ps + 532]
    {store} sub ebx, ecx
    {store} sub eax, esi
    {store} mov edx, ebx
    call getangle_
    mov word ptr [ebp + 32], 0x30
    mov word ptr [ebp + 28], ax
    {disp32} jmp actors_C_flow_27522
actors_C_flow_29254:
    cmp word ptr [ebp + 34], 0
    {disp32} jne actors_C_flow_29469
    mov ebx, 0x200
    mov word ptr [ebp + 34], 1
    mov edi, 0x181
    mov dword ptr [esp + 20], ebx
    {disp32} jmp actors_C_flow_29455
actors_C_flow_29290:
    {store} xor ebx, ebx
    mov word ptr [esp + 36], bx
    mov bl, 0x40
    {disp32} jmp actors_C_flow_29432
actors_C_flow_29304:
    movsx eax, word ptr [esp + 32]
    mov edx, 0xa1e
    call spawn_
    and eax, 0xffff
    imul eax, eax, 0x2c
    mov edx, dword ptr [esp + 20]
    and edx, 0x7ff
    movsx edx, word ptr [edx*2 + _sintable]
    sar edx, 5
    mov word ptr [eax + _sprite + 36], dx
    mov edx, dword ptr [esp + 20]
    add edx, 0x200
    mov word ptr [eax + _sprite + 12], di
    and edx, 0x7ff
    mov byte ptr [eax + _sprite + 18], bl
    movsx edx, word ptr [edx*2 + _sintable]
    mov word ptr [eax + _sprite + 28], cx
    sar edx, 9
    mov word ptr [eax + _sprite + 32], dx
    mov edx, dword ptr [esp + 32]
    mov word ptr [eax + _sprite + 30], dx
    {store} mov eax, ecx
    .att_syntax prefix
    addl $actors_C_math_29422,%eax
    .intel_syntax noprefix
    mov word ptr [esp + 36], ax
actors_C_flow_29432:
    mov ecx, dword ptr [esp + 36]
    cmp cx, 0x800
    {disp32} jl actors_C_flow_29304
    add dword ptr [esp + 20], 0x80
actors_C_flow_29455:
    cmp dword ptr [esp + 20], 0x600
    {disp32} jl actors_C_flow_29290
actors_C_flow_29469:
    mov eax, dword ptr [esp + 24]
    cmp dword ptr [eax + 12], 0
    jle actors_C_flow_29582
    mov dx, word ptr [ebp + 36]
    cmp dx, 0x1800
    jge actors_C_flow_29502
    {store} mov ebx, edx
    add ebx, 0xc0
    mov word ptr [ebp + 36], bx
actors_C_flow_29502:
    movsx eax, word ptr [ebp + 36]
    mov edi, dword ptr [ebp + 8]
    movsx edx, si
    {store} add edi, eax
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    mov dword ptr [ebp + 8], edi
    mov ebx, dword ptr [eax + _sector + 8]
    {store} cmp edi, ebx
    jle actors_C_flow_29546
    mov dword ptr [ebp + 8], ebx
actors_C_flow_29546:
    mov eax, dword ptr [esp + 24]
    mov ecx, dword ptr [eax + 12]
    dec ecx
    mov dword ptr [eax + 12], ecx
    {disp32} jne actors_C_flow_38718
    movsx eax, word ptr [esp + 32]
    call deletesprite_
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_29582:
    cmp dword ptr [eax + 8], 0xa
    {disp32} jle actors_C_flow_38718
    mov ax, word ptr [_headspritestat + 10]
    mov esi, dword ptr [esp + 32]
actors_C_flow_29602:
    mov word ptr [esp + 36], ax
    mov ecx, dword ptr [esp + 36]
    test cx, cx
    jl actors_C_flow_29692
    movsx edx, cx
    imul eax, edx, 0x2c
    cmp si, word ptr [eax + _sprite + 30]
    jne actors_C_flow_29677
    cmp word ptr [eax + _sprite + 14], 0xa1e
    jne actors_C_flow_29677
    call krand_
    {store} mov ebx, eax
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    and ebx, 0x3f
    {store} sub eax, edx
    inc ebx
    mov dword ptr [eax + _hittype + 51], ebx
actors_C_flow_29677:
    movsx eax, word ptr [esp + 36]
    mov ax, word ptr [eax*2 + _nextspritestat]
    jmp actors_C_flow_29602
actors_C_flow_29692:
    mov eax, dword ptr [esp + 24]
    mov dword ptr [eax + 12], 0x40
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_29712:
    {store} mov eax, edx
    call getglobalz_
    movsx edx, word ptr [ebp + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    test byte ptr [eax + _sector + 12], 1
    je actors_C_flow_29783
    movsx edx, word ptr [ebp + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    movsx edx, byte ptr [eax*8 + _sector + 20]
    movsx eax, byte ptr [ebp + 16]
    {store} sub edx, eax
    sar edx, 1
    movsx eax, byte ptr [ebp + 16]
    jmp actors_C_flow_29798
actors_C_flow_29783:
    movsx edx, byte ptr [eax + _sector + 28]
    movsx eax, byte ptr [ebp + 16]
    {store} sub edx, eax
    sar edx, 1
actors_C_flow_29798:
    {store} add eax, edx
    mov byte ptr [ebp + 16], al
    movsx edx, si
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov eax, dword ptr [eax*8 + _sector + 4]
    mov edx, dword ptr [ebp + 8]
    .att_syntax prefix
    addl $actors_C_math_29825,%eax
    .intel_syntax noprefix
    {store} cmp eax, edx
    jle actors_C_flow_29837
    mov dword ptr [ebp + 8], eax
actors_C_flow_29837:
    cmp word ptr [_ud + 1424], 2
    jge actors_C_flow_29884
    mov cl, byte ptr [_actor_tog]
    cmp cl, 1
    jne actors_C_flow_29873
    mov word ptr [ebp + 12], 0x8000
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_29873:
    cmp cl, 2
    jne actors_C_flow_29884
    mov word ptr [ebp + 12], 0x101
actors_C_flow_29884:
    movsx eax, word ptr [esp + 32]
    call ifhitbyweapon_
    test ax, ax
    {disp32} jl actors_C_flow_30041
    cmp word ptr [ebp + 42], 0
    jge actors_C_flow_29931
    mov eax, dword ptr [esp + 24]
    cmp dword ptr [eax], -1
    je actors_C_flow_29931
    mov dword ptr [eax], 0xffffffff
    mov word ptr [ebp + 42], 0
actors_C_flow_29931:
    movsx ebx, word ptr [esp + 32]
    mov eax, 0x80
    {store} mov edx, ebx
    call spritesound_
    push 5
    push ebx
    mov edx, 0xfffffe00
    call krand_
    and eax, 0x7ff
    {store} sub edx, eax
    push edx
    call krand_
    xor ah, ah
    and al, 0x3f
    .att_syntax prefix
    addl $actors_C_math_29978,%eax
    .intel_syntax noprefix
    cwde
    push eax
    call krand_
    and ah, 7
    cwde
    push eax
    push 0x30
    push 0x30
    push -8
    call krand_
    xor ah, ah
    mov ecx, dword ptr [ebp + 8]
    and al, 0xf
    mov ebx, dword ptr [ebp + 4]
    .att_syntax prefix
    addl $actors_C_math_30016,%eax
    .intel_syntax noprefix
    {disp8} mov edx, dword ptr [ebp]
    cwde
    sub ecx, 0xc00
    push eax
    movsx eax, word ptr [ebp + 24]
    call EGS_
actors_C_flow_30041:
    mov eax, dword ptr [esp + 24]
    cmp dword ptr [eax], -1
    {disp32} jne actors_C_flow_30350
    add dword ptr [ebp + 8], 0x400
    mov eax, dword ptr [esp + 24]
    inc dword ptr [eax + 8]
    test byte ptr [eax + 8], 3
    jne actors_C_flow_30089
    movsx eax, word ptr [esp + 32]
    mov edx, 0x762
    call spawn_
actors_C_flow_30089:
    movsx ebx, word ptr [esp + 32]
    {store} mov eax, ebx
    mov edx, 0x10001
    call getglobalz_
    mov si, word ptr [ebp + 28]
    mov word ptr [ebp + 32], 0x80
    add esi, 0x60
    {store} mov eax, ebx
    mov word ptr [ebp + 28], si
    call ssp_
    .att_syntax prefix
    cmpw $actors_C_math_30130,%ax
    .intel_syntax noprefix
    jne actors_C_flow_30169
    {disp32} lea eax, dword ptr [ebx*8]
    {store} add eax, ebx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ebx
    mov edx, dword ptr [ebp + 8]
    cmp edx, dword ptr [eax + _hittype + 19]
    {disp32} jle actors_C_flow_38718
actors_C_flow_30169:
    {store} xor ecx, ecx
    mov dword ptr [esp + 20], ecx
    jmp actors_C_flow_30279
actors_C_flow_30177:
    push 5
    movsx eax, word ptr [esp + 36]
    push eax
    mov edx, 0xfffffe00
    call krand_
    and eax, 0x7ff
    {store} sub edx, eax
    push edx
    call krand_
    xor ah, ah
    and al, 0x3f
    .att_syntax prefix
    addl $actors_C_math_30212,%eax
    .intel_syntax noprefix
    cwde
    push eax
    call krand_
    and ah, 7
    cwde
    push eax
    push 0x30
    push 0x30
    push -8
    call krand_
    xor ah, ah
    mov ecx, dword ptr [ebp + 8]
    and al, 0xf
    mov ebx, dword ptr [ebp + 4]
    .att_syntax prefix
    addl $actors_C_math_30250,%eax
    .intel_syntax noprefix
    {disp8} mov edx, dword ptr [ebp]
    cwde
    sub ecx, 0xc00
    push eax
    movsx eax, word ptr [ebp + 24]
    call EGS_
    inc dword ptr [esp + 20]
actors_C_flow_30279:
    cmp dword ptr [esp + 20], 0x10
    jl actors_C_flow_30177
    movsx ebx, word ptr [esp + 32]
    mov eax, 0x11
    {store} mov edx, ebx
    call spritesound_
    mov edx, 0x7d0
    {store} mov eax, ebx
    call spawn_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    inc byte ptr [eax + _ps + 1360]
    {store} mov eax, ebx
    call deletesprite_
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_30350:
    movsx edx, word ptr [esp + 32]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov eax, dword ptr [eax + _hittype + 19]
    mov esi, dword ptr [ebp + 8]
    sub eax, 0x3000
    {store} cmp eax, esi
    jge actors_C_flow_30394
    mov dword ptr [ebp + 8], eax
actors_C_flow_30394:
    lea edx, dword ptr [esp + 16]
    {store} mov eax, ebp
    call findplayer_
    mov dword ptr [esp + 44], eax
    mov ax, word ptr [ebp + 30]
    mov word ptr [esp + 36], ax
    mov eax, dword ptr [esp + 24]
    mov edi, dword ptr [eax]
    cmp edi, 4
    {disp32} jl actors_C_flow_30711
    inc dword ptr [eax + 8]
    test byte ptr [eax + 8], 0xf
    jne actors_C_flow_30508
    movsx ecx, word ptr [esp + 32]
    {store} mov edx, ecx
    {disp32} lea eax, dword ptr [ecx*8]
    {store} add eax, ecx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ecx
    mov ax, word ptr [eax + _hittype + 11]
    mov bx, word ptr [ebp + 28]
    mov word ptr [ebp + 28], ax
    mov eax, 0x7f
    call spritesound_
    mov edx, 0x659
    {store} mov eax, ecx
    call shoot_
    mov word ptr [ebp + 28], bx
actors_C_flow_30508:
    mov eax, dword ptr [esp + 24]
    cmp dword ptr [eax + 8], 0x4e
    jg actors_C_flow_30586
    movsx esi, word ptr [esp + 44]
    imul esi, esi, 0x552
    movsx eax, word ptr [esi + _ps + 646]
    push eax
    mov eax, dword ptr [esi + _ps + 540]
    mov edx, dword ptr [esi + _ps + 536]
    push eax
    movsx ecx, word ptr [ebp + 24]
    push edx
    mov ebx, dword ptr [esi + _ps + 532]
    {disp8} mov eax, dword ptr [ebp]
    push ebx
    mov ebx, dword ptr [ebp + 8]
    mov edx, dword ptr [ebp + 4]
    sub ebx, 0x1000
    call cansee_
    test eax, eax
    jne actors_C_flow_30608
actors_C_flow_30586:
    mov eax, dword ptr [esp + 24]
    mov dword ptr [eax], 0
    mov dword ptr [eax + 8], 0
    {disp32} jmp actors_C_flow_31062
actors_C_flow_30608:
    movsx edx, word ptr [esp + 32]
    {disp32} lea ebx, dword ptr [edx*8]
    {store} add ebx, edx
    mov ecx, dword ptr [ebp + 4]
    {disp32} lea ebx, dword ptr [ebx*8]
    mov eax, dword ptr [esi + _ps + 532]
    {store} sub ebx, edx
    mov edx, dword ptr [esi + _ps + 536]
    {disp8} mov esi, dword ptr [ebp]
    {store} sub edx, ecx
    {store} sub eax, esi
    call getangle_
    movsx edx, ax
    movsx eax, word ptr [ebx + _hittype + 11]
    call getincangle_
    movsx edx, ax
    mov ecx, 3
    {store} mov eax, edx
    sar edx, 0x1f
    idiv ecx
    {store} mov edx, eax
    movsx eax, word ptr [ebx + _hittype + 11]
    {store} add eax, edx
    mov word ptr [ebx + _hittype + 11], ax
    {disp32} jmp actors_C_flow_31062
actors_C_flow_30711:
    cmp edi, 2
    je actors_C_flow_30725
    cmp edi, 3
    {disp32} jne actors_C_flow_31062
actors_C_flow_30725:
    mov eax, dword ptr [esp + 24]
    mov dword ptr [eax + 12], 0
    mov dx, word ptr [ebp + 32]
    test dx, dx
    jle actors_C_flow_30756
    {store} mov ebx, edx
    sub ebx, 0x10
    mov word ptr [ebp + 32], bx
    jmp actors_C_flow_30762
actors_C_flow_30756:
    mov word ptr [ebp + 32], 0
actors_C_flow_30762:
    mov eax, dword ptr [esp + 24]
    cmp dword ptr [eax], 2
    jne actors_C_flow_30854
    movsx edx, word ptr [esp + 44]
    imul edx, edx, 0x552
    mov esi, dword ptr [ebp + 8]
    mov eax, dword ptr [edx + _ps + 540]
    {store} sub eax, esi
    mov dword ptr [esp + 20], eax
    test eax, eax
    jns actors_C_flow_30803
    neg eax
actors_C_flow_30803:
    .att_syntax prefix
    cmpl $actors_C_math_30803,%eax
    .intel_syntax noprefix
    jge actors_C_flow_30825
    mov eax, dword ptr [esp + 24]
    mov dword ptr [eax], 3
    {disp32} jmp actors_C_flow_30992
actors_C_flow_30825:
    mov ebx, dword ptr [edx + _ps + 540]
    sub ebx, dword ptr [ebp + 8]
    {store} add ebx, ebx
    {store} sbb eax, eax
    {store} cmp eax, ebx
    adc eax, 0
    shl eax, 0xa
    add dword ptr [ebp + 8], eax
    {disp32} jmp actors_C_flow_30992
actors_C_flow_30854:
    mov esi, dword ptr [eax + 8]
    inc esi
    mov dword ptr [eax + 8], esi
    cmp esi, 0x4e
    jg actors_C_flow_30934
    movsx eax, word ptr [esp + 44]
    imul eax, eax, 0x552
    movsx edx, word ptr [eax + _ps + 646]
    push edx
    mov edx, dword ptr [eax + _ps + 540]
    mov ebx, dword ptr [eax + _ps + 536]
    push edx
    mov ecx, dword ptr [eax + _ps + 532]
    {disp8} mov eax, dword ptr [ebp]
    push ebx
    mov edx, dword ptr [ebp + 4]
    mov ebx, dword ptr [ebp + 8]
    push ecx
    sub ebx, 0x1000
    movsx ecx, word ptr [ebp + 24]
    call cansee_
    test eax, eax
    jne actors_C_flow_30953
actors_C_flow_30934:
    mov eax, dword ptr [esp + 24]
    mov dword ptr [eax], 1
    mov dword ptr [eax + 8], 0
    jmp actors_C_flow_30992
actors_C_flow_30953:
    mov eax, dword ptr [esp + 24]
    test byte ptr [eax + 8], 0xf
    jne actors_C_flow_30992
    movsx ebx, word ptr [esp + 32]
    mov eax, 0x7f
    {store} mov edx, ebx
    call spritesound_
    mov edx, 0x659
    {store} mov eax, ebx
    call shoot_
actors_C_flow_30992:
    movsx edx, word ptr [esp + 44]
    imul edx, edx, 0x552
    mov ebx, dword ptr [ebp + 4]
    mov eax, dword ptr [edx + _ps + 536]
    {store} sub eax, ebx
    {disp8} mov ecx, dword ptr [ebp]
    {store} mov ebx, eax
    mov eax, dword ptr [edx + _ps + 532]
    {store} mov edx, ebx
    {store} sub eax, ecx
    call getangle_
    movsx edx, ax
    movsx eax, word ptr [ebp + 28]
    call getincangle_
    cwde
    {store} mov edx, eax
    sar edx, 2
    movsx eax, word ptr [ebp + 28]
    {store} add eax, edx
    mov word ptr [ebp + 28], ax
actors_C_flow_31062:
    mov eax, dword ptr [esp + 24]
    mov edi, dword ptr [eax]
    cmp edi, 2
    {disp32} je actors_C_flow_31617
    cmp edi, 3
    {disp32} je actors_C_flow_31617
    movsx ebx, word ptr [esp + 36]
    imul ebx, ebx, 0x2c
    mov eax, OFFSET FLAT:_sprite
    {store} mov edx, ebp
    {store} add eax, ebx
    call ldist_
    mov dword ptr [esp + 20], eax
    .att_syntax prefix
    cmpl $actors_C_math_31112,%eax
    .intel_syntax noprefix
    jg actors_C_flow_31136
    mov cx, word ptr [ebp + 32]
    sar cx, 1
    mov bx, word ptr [ebp + 28]
    mov word ptr [ebp + 32], cx
    jmp actors_C_flow_31165
actors_C_flow_31136:
    mov edx, dword ptr [ebx + _sprite + 4]
    mov ecx, dword ptr [ebp + 4]
    mov eax, dword ptr [ebx + _sprite]
    {disp8} mov esi, dword ptr [ebp]
    {store} sub edx, ecx
    {store} sub eax, esi
    call getangle_
    {store} mov ebx, eax
actors_C_flow_31165:
    mov eax, dword ptr [esp + 24]
    mov edi, dword ptr [eax]
    cmp edi, 1
    je actors_C_flow_31185
    cmp edi, 4
    {disp32} jne actors_C_flow_31387
actors_C_flow_31185:
    movsx eax, word ptr [esp + 36]
    imul eax, eax, 0x2c
    {store} mov edx, ebp
    add eax, OFFSET FLAT:_sprite
    call dist_
    mov dword ptr [esp + 20], eax
    .att_syntax prefix
    cmpl $actors_C_math_31209,%eax
    .intel_syntax noprefix
    jg actors_C_flow_31241
    mov eax, dword ptr [esp + 24]
    cmp dword ptr [eax], 1
    jne actors_C_flow_31233
    mov dword ptr [eax], 0
    jmp actors_C_flow_31290
actors_C_flow_31233:
    mov dword ptr [eax], 5
    jmp actors_C_flow_31290
actors_C_flow_31241:
    jle actors_C_flow_31264
    mov ax, word ptr [ebp + 32]
    .att_syntax prefix
    cmpw $actors_C_math_31247,%ax
    .intel_syntax noprefix
    jge actors_C_flow_31290
    {store} mov edx, eax
    add edx, 0x20
    mov word ptr [ebp + 32], dx
    jmp actors_C_flow_31290
actors_C_flow_31264:
    mov si, word ptr [ebp + 32]
    test si, si
    jle actors_C_flow_31284
    {store} mov edi, esi
    sub edi, 0x10
    mov word ptr [ebp + 32], di
    jmp actors_C_flow_31290
actors_C_flow_31284:
    mov word ptr [ebp + 32], 0
actors_C_flow_31290:
    mov eax, dword ptr [esp + 24]
    cmp dword ptr [eax], 2
    jge actors_C_flow_31302
    inc dword ptr [eax + 8]
actors_C_flow_31302:
    cmp dword ptr [esp + 16], 0x1800
    jge actors_C_flow_31387
    mov eax, dword ptr [esp + 24]
    cmp dword ptr [eax], 2
    jge actors_C_flow_31387
    cmp dword ptr [eax + 8], 0x68
    jle actors_C_flow_31387
    call krand_
    and eax, 2
    mov edx, dword ptr [esp + 24]
    add eax, 2
    mov dword ptr [edx + 8], 0
    mov dword ptr [edx], eax
    movsx edx, word ptr [esp + 32]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    {store} mov edx, eax
    mov ax, word ptr [ebp + 28]
    mov word ptr [edx + _hittype + 11], ax
actors_C_flow_31387:
    mov eax, dword ptr [esp + 24]
    mov esi, dword ptr [eax]
    test esi, esi
    je actors_C_flow_31406
    cmp esi, 5
    {disp32} jne actors_C_flow_31543
actors_C_flow_31406:
    mov eax, dword ptr [esp + 24]
    cmp dword ptr [eax], 0
    jne actors_C_flow_31423
    mov dword ptr [eax], 1
    jmp actors_C_flow_31429
actors_C_flow_31423:
    mov dword ptr [eax], 4
actors_C_flow_31429:
    mov edx, 0xffffffff
    movsx eax, word ptr [ebp + 40]
    call LocateTheLocator_
    mov word ptr [esp + 36], ax
    mov word ptr [ebp + 30], ax
    cwde
    cmp eax, -1
    jne actors_C_flow_31539
    movsx ecx, word ptr [esp + 32]
    {disp32} lea eax, dword ptr [ecx*8]
    {store} add eax, ecx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ecx
    mov ax, word ptr [eax + _hittype + 67]
    mov edx, 0xffffffff
    mov word ptr [esp + 36], ax
    mov word ptr [ebp + 40], ax
    cwde
    call LocateTheLocator_
    mov word ptr [esp + 36], ax
    mov word ptr [ebp + 30], ax
    cwde
    cmp eax, -1
    jne actors_C_flow_31543
    {store} mov eax, ecx
    call deletesprite_
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_31539:
    inc word ptr [ebp + 40]
actors_C_flow_31543:
    movsx edx, bx
    movsx eax, word ptr [ebp + 28]
    call getincangle_
    mov edx, dword ptr [esp + 24]
    cwde
    mov dword ptr [edx + 12], eax
    {store} mov edx, eax
    sar edx, 3
    movsx eax, word ptr [ebp + 28]
    {store} add eax, edx
    mov word ptr [ebp + 28], ax
    movsx eax, word ptr [esp + 36]
    imul edx, eax, 0x2c
    mov eax, dword ptr [ebp + 8]
    cmp eax, dword ptr [edx + _sprite + 8]
    jge actors_C_flow_31608
    lea esi, dword ptr [eax + 1024]
    mov dword ptr [ebp + 8], esi
    jmp actors_C_flow_31617
actors_C_flow_31608:
    lea ecx, dword ptr [eax + -1024]
    mov dword ptr [ebp + 8], ecx
actors_C_flow_31617:
    cmp dword ptr [_Sound + 1634], 0
    jne actors_C_flow_31641
    movsx edx, word ptr [esp + 32]
    mov eax, 0x7d
    call spritesound_
actors_C_flow_31641:
    movsx eax, word ptr [esp + 32]
    mov edx, 0x10001
    call ssp_
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_31665:
    {store} mov eax, edx
    call getglobalz_
    mov eax, dword ptr [ebx + _hittype + 19]
    sub eax, dword ptr [ebx + _hittype + 23]
    sar eax, 9
    mov word ptr [esp + 36], ax
    .att_syntax prefix
    cmpw $actors_C_math_31692,%ax
    .intel_syntax noprefix
    jle actors_C_flow_31705
    mov word ptr [esp + 36], 0xff
actors_C_flow_31705:
    movsx eax, word ptr [esp + 36]
    mov edx, 0x19
    sar eax, 1
    {store} sub edx, eax
    mov dword ptr [esp + 16], edx
    cmp edx, 8
    jge actors_C_flow_31738
    mov dword ptr [esp + 16], 8
    jmp actors_C_flow_31751
actors_C_flow_31738:
    cmp edx, 0x30
    jle actors_C_flow_31751
    mov dword ptr [esp + 16], 0x30
actors_C_flow_31751:
    mov al, byte ptr [esp + 36]
    mov byte ptr [ebp + 21], al
    mov al, byte ptr [esp + 16]
    movsx edx, word ptr [esp + 32]
    mov byte ptr [ebp + 20], al
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov eax, dword ptr [eax + _hittype + 19]
    mov dword ptr [ebp + 8], eax
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_31806:
    cmp word ptr [_ud + 1424], 2
    jge actors_C_flow_31853
    mov dl, byte ptr [_actor_tog]
    cmp dl, 1
    jne actors_C_flow_31842
    mov word ptr [ebp + 12], 0x8000
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_31842:
    cmp dl, 2
    jne actors_C_flow_31853
    mov word ptr [ebp + 12], 0x101
actors_C_flow_31853:
    movsx edx, si
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov edx, dword ptr [esp + 24]
    add dword ptr [edx + 4], 0x80
    test byte ptr [eax*8 + _sector + 14], 1
    je actors_C_flow_31905
    movsx eax, word ptr [esp + 32]
    call deletesprite_
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_31905:
    lea edx, dword ptr [esp + 16]
    {store} mov eax, ebp
    call findplayer_
    {store} mov ebx, eax
    mov dword ptr [esp + 44], eax
    mov eax, dword ptr [esp + 24]
    cmp dword ptr [eax], -5
    {disp32} jne actors_C_flow_32355
    mov edx, dword ptr [eax + 12]
    inc edx
    mov dword ptr [eax + 12], edx
    cmp edx, 0x118
    jle actors_C_flow_31969
    mov byte ptr [ebp + 17], 0
    mov dword ptr [eax], 0
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_31969:
    movsx edx, word ptr [esp + 32]
    {store} mov eax, edx
    call makeitfall_
    mov word ptr [ebp + 12], 0x101
    mov word ptr [ebp + 14], 0x944
    mov word ptr [ebp + 42], 1
    {store} mov eax, edx
    mov byte ptr [ebp + 17], 1
    call ifhitbyweapon_
    test ax, ax
    {disp32} jl actors_C_flow_32225
    .att_syntax prefix
    cmpw $actors_C_math_32019,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_38718
    mov word ptr [esp + 36], 0x10
    {disp32} jmp actors_C_flow_32179
actors_C_flow_32041:
    push 5
    movsx ebx, word ptr [esp + 36]
    push ebx
    mov edx, 0x400
    call krand_
    and eax, 0x3ff
    {store} sub edx, eax
    push edx
    call krand_
    xor ah, ah
    and al, 0x3f
    .att_syntax prefix
    addl $actors_C_math_32076,%eax
    .intel_syntax noprefix
    cwde
    push eax
    call krand_
    and ah, 7
    mov ecx, 3
    cwde
    movsx edx, si
    push eax
    {store} mov eax, edx
    sar edx, 0x1f
    idiv ecx
    push 0x24
    push 0x24
    lea eax, dword ptr [edx + 1031]
    push -32
    cwde
    push eax
    imul eax, ebx, 0x2c
    mov ecx, dword ptr [eax + _sprite + 8]
    mov ebx, dword ptr [eax + _sprite + 4]
    mov edx, dword ptr [eax + _sprite]
    movsx eax, word ptr [eax + _sprite + 24]
    call EGS_
    and eax, 0xffff
    imul eax, eax, 0x2c
    {store} mov edi, esi
    dec edi
    mov cl, 1
    mov word ptr [esp + 36], di
    mov byte ptr [eax + _sprite + 17], cl
actors_C_flow_32179:
    mov esi, dword ptr [esp + 36]
    test si, si
    {disp32} jge actors_C_flow_32041
    movsx ebx, word ptr [esp + 32]
    mov eax, 0x13
    {store} mov edx, ebx
    call spritesound_
    {store} mov eax, ebx
    call deletesprite_
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_32225:
    cmp dword ptr [esp + 16], 0x400
    {disp32} jge actors_C_flow_38718
    movsx ebx, bx
    imul ebx, ebx, 0x552
    cmp word ptr [ebx + _ps + 742], 0
    {disp32} jne actors_C_flow_38718
    imul edx, edx, 0x2c
    mov edi, dword ptr [ebx + _ps + 536]
    mov ebp, dword ptr [ebx + _ps + 532]
    mov ecx, dword ptr [edx + _sprite + 4]
    mov eax, dword ptr [edx + _sprite]
    {store} sub ecx, edi
    {store} sub eax, ebp
    {store} mov edx, ecx
    call getangle_
    movsx edx, ax
    movsx eax, word ptr [ebx + _ps + 640]
    call getincangle_
    movsx edx, ax
    cmp edx, -128
    {disp32} jle actors_C_flow_38718
    .att_syntax prefix
    cmpw $actors_C_math_32327,%ax
    .intel_syntax noprefix
    {disp32} jge actors_C_flow_38718
    mov word ptr [ebx + _ps + 742], 0xe
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_32355:
    cmp dword ptr [esp + 16], 0x63c
    jge actors_C_flow_32373
    mov word ptr [ebp + 12], 0
    jmp actors_C_flow_32379
actors_C_flow_32373:
    mov word ptr [ebp + 12], 0x101
actors_C_flow_32379:
    mov eax, dword ptr [esp + 24]
    cmp dword ptr [eax], -4
    {disp32} jne actors_C_flow_33491
    movsx eax, word ptr [esp + 44]
    mov dword ptr [esp + 28], eax
    imul edi, eax, 0x552
    movsx eax, word ptr [edi + _ps + 724]
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 42], 1
    jge actors_C_flow_32446
    mov eax, dword ptr [esp + 24]
    mov dword ptr [eax], 0
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_32446:
    movsx eax, word ptr [esp + 32]
    mov ecx, dword ptr [ebp + 8]
    mov ebx, dword ptr [ebp + 4]
    {disp8} mov edx, dword ptr [ebp]
    call setsprite_
    mov ax, word ptr [edi + _ps + 640]
    mov edx, dword ptr [esp + 28]
    mov word ptr [ebp + 28], ax
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    test byte ptr [eax*2 + _sync + 6], 4
    {disp32} je actors_C_flow_32866
    movsx eax, word ptr [edi + _ps + 724]
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 42], 0
    {disp32} jle actors_C_flow_32866
    mov cx, word ptr [edi + _ps + 680]
    cmp cx, 0xa
    {disp32} je actors_C_flow_32866
    cmp cx, 5
    {disp32} je actors_C_flow_32866
    cmp cx, 8
    {disp32} je actors_C_flow_32866
    test cx, cx
    {disp32} je actors_C_flow_32866
    movsx eax, cx
    cmp word ptr [edi + eax*2 + _ps + 652], 0
    {disp32} jl actors_C_flow_32866
    {store} xor edi, edi
    mov dword ptr [esp + 16], edi
    jmp actors_C_flow_32715
actors_C_flow_32599:
    push 5
    movsx eax, word ptr [esp + 36]
    push eax
    movsx edx, word ptr [ebp + 36]
    call krand_
    and eax, 0xfff
    sar edx, 2
    neg eax
    {store} sub eax, edx
    push eax
    call krand_
    xor ah, ah
    and al, 0x3f
    .att_syntax prefix
    addl $actors_C_math_32638,%eax
    .intel_syntax noprefix
    cwde
    push eax
    call krand_
    and ah, 7
    cwde
    push eax
    push 0x30
    push 0x30
    push -8
    call krand_
    xor ah, ah
    mov ecx, dword ptr [ebp + 8]
    and al, 3
    mov ebx, dword ptr [ebp + 4]
    .att_syntax prefix
    addl $actors_C_math_32676,%eax
    .intel_syntax noprefix
    {disp8} mov edx, dword ptr [ebp]
    cwde
    sub ecx, 0x800
    push eax
    movsx eax, si
    call EGS_
    cwde
    imul eax, eax, 0x2c
    mov byte ptr [eax + _sprite + 17], 6
    inc dword ptr [esp + 16]
actors_C_flow_32715:
    cmp dword ptr [esp + 16], 8
    jl actors_C_flow_32599
    movsx ebx, word ptr [esp + 32]
    mov eax, 0x95
    {store} mov edx, ebx
    call spritesound_
    mov eax, 0x45
    {store} mov edx, ebx
    call spritesound_
    call krand_
    and eax, 0xff
    cmp eax, 0x20
    jge actors_C_flow_32790
    mov edx, 0x4ca
    {store} mov eax, ebx
    call spawn_
    cwde
    imul eax, eax, 0x2c
    xor dh, dh
    mov byte ptr [eax + _sprite + 17], dh
actors_C_flow_32790:
    movsx eax, word ptr [esp + 44]
    imul eax, eax, 0x552
    mov bl, byte ptr [eax + _ps + 1360]
    inc bl
    mov edx, dword ptr [esp + 24]
    mov byte ptr [eax + _ps + 1360], bl
    mov dword ptr [edx], 0xfffffffd
    mov ebx, dword ptr [esp + 32]
    cmp bx, word ptr [eax + _ps + 720]
    jne actors_C_flow_32847
    mov word ptr [eax + _ps + 720], 0xffff
actors_C_flow_32847:
    movsx eax, word ptr [esp + 32]
    call deletesprite_
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_32866:
    movsx eax, word ptr [esp + 44]
    imul eax, eax, 0x552
    mov edx, dword ptr [eax + _ps + 540]
    add edx, dword ptr [eax + _ps + 580]
    mov ebx, dword ptr [esp + 24]
    sub edx, dword ptr [ebx + 8]
    add edx, 0x800
    mov dword ptr [ebp + 8], edx
    mov edx, 0x64
    mov esi, dword ptr [eax + _ps + 544]
    {store} mov eax, edx
    {store} sub eax, esi
    mov edi, dword ptr [ebp + 8]
    shl eax, 4
    {store} add edi, eax
    mov dword ptr [ebp + 8], edi
    mov edx, dword ptr [ebx + 8]
    cmp edx, 0x200
    jle actors_C_flow_32950
    {store} mov eax, ebx
    lea ebx, dword ptr [edx + -128]
    mov dword ptr [eax + 8], ebx
actors_C_flow_32950:
    mov eax, dword ptr [esp + 24]
    mov ecx, dword ptr [eax + 8]
    cmp ecx, 0x15c
    jge actors_C_flow_32974
    lea esi, dword ptr [ecx + 128]
    mov dword ptr [eax + 8], esi
actors_C_flow_32974:
    movsx eax, word ptr [esp + 44]
    imul eax, eax, 0x552
    cmp word ptr [eax + _ps + 690], 0
    {disp32} jl actors_C_flow_33159
    mov edi, 0xffffffff
    mov edx, dword ptr [eax + _ps + 568]
    mov word ptr [eax + _ps + 690], di
    mov dword ptr [eax + _ps + 532], edx
    mov edx, dword ptr [eax + _ps + 572]
    mov dword ptr [eax + _ps + 536], edx
    mov edx, dword ptr [eax + _ps + 576]
    mov dword ptr [eax + _ps + 540], edx
    mov ecx, OFFSET FLAT:_ps
    mov dx, word ptr [eax + _ps + 642]
    {store} add ecx, eax
    mov word ptr [eax + _ps + 640], dx
    lea ebx, dword ptr [ecx + 646]
    mov edx, dword ptr [eax + _ps + 536]
    mov eax, dword ptr [eax + _ps + 532]
    call updatesector_
    {store} mov eax, ecx
    call setpal_
    mov ax, word ptr [_headspritestat + 2]
actors_C_flow_33104:
    mov word ptr [esp + 36], ax
    mov ebx, dword ptr [esp + 36]
    test bx, bx
    jl actors_C_flow_33159
    movsx eax, bx
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 14], 0x26d
    jne actors_C_flow_33144
    {store} xor esi, esi
    mov word ptr [eax + _sprite + 34], si
actors_C_flow_33144:
    movsx eax, word ptr [esp + 36]
    mov ax, word ptr [eax*2 + _nextspritestat]
    jmp actors_C_flow_33104
actors_C_flow_33159:
    mov eax, dword ptr [esp + 24]
    cmp dword ptr [eax + 12], 0
    {disp32} jle actors_C_flow_33305
    {store} mov edi, esp
    mov esi, OFFSET FLAT:actors_slime_frames_initializer
    movsd dword ptr es:[edi], dword ptr [esi]
    movsd dword ptr es:[edi], dword ptr [esi]
    movsd dword ptr es:[edi], dword ptr [esi]
    movsd dword ptr es:[edi], dword ptr [esi]
    mov eax, dword ptr [eax + 12]
    mov ax, word ptr [esp + eax*2]
    .att_syntax prefix
    addl $actors_C_math_33191,%eax
    .intel_syntax noprefix
    mov word ptr [ebp + 14], ax
    mov eax, dword ptr [esp + 24]
    cmp dword ptr [eax + 12], 5
    jne actors_C_flow_33276
    movsx eax, word ptr [esp + 44]
    imul eax, eax, 0x552
    movsx edx, word ptr [eax + _ps + 724]
    imul edx, edx, 0x2c
    call krand_
    xor ah, ah
    and al, 3
    .att_syntax prefix
    addl $actors_C_math_33240,%eax
    .intel_syntax noprefix
    mov di, word ptr [edx + _sprite + 42]
    {store} sub edi, eax
    mov eax, 0x22
    mov word ptr [edx + _sprite + 42], di
    movsx edx, word ptr [esp + 32]
    call spritesound_
actors_C_flow_33276:
    mov eax, dword ptr [esp + 24]
    mov ecx, dword ptr [eax + 12]
    cmp ecx, 7
    jge actors_C_flow_33296
    lea esi, dword ptr [ecx + 1]
    mov dword ptr [eax + 12], esi
    jmp actors_C_flow_33337
actors_C_flow_33296:
    mov dword ptr [eax + 12], 0
    jmp actors_C_flow_33337
actors_C_flow_33305:
    mov word ptr [ebp + 14], 0x947
    call krand_
    sar eax, 8
    .att_syntax prefix
    cmpl $actors_C_math_33319,%eax
    .intel_syntax noprefix
    jl actors_C_flow_33337
    mov eax, dword ptr [esp + 24]
    mov dword ptr [eax + 12], 1
actors_C_flow_33337:
    mov eax, dword ptr [esp + 24]
    mov eax, dword ptr [eax + 4]
    and eax, 0x7ff
    movsx eax, word ptr [eax*2 + _sintable]
    sar eax, 0xd
    add eax, 0x14
    mov byte ptr [ebp + 20], al
    mov eax, dword ptr [esp + 24]
    mov eax, dword ptr [eax + 4]
    and eax, 0x7ff
    movsx eax, word ptr [eax*2 + _sintable]
    sar eax, 0xd
    add eax, 0xf
    mov byte ptr [ebp + 21], al
    movsx eax, word ptr [esp + 44]
    imul eax, eax, 0x552
    movsx edx, word ptr [eax + _ps + 640]
    add edx, 0x200
    and edx, 0x7ff
    movsx ebx, word ptr [edx*2 + _sintable]
    sar ebx, 7
    mov edx, dword ptr [eax + _ps + 532]
    {store} add edx, ebx
    {disp8} mov dword ptr [ebp], edx
    mov dx, word ptr [eax + _ps + 640]
    and dh, 7
    movsx edx, dx
    movsx edx, word ptr [edx*2 + _sintable]
    mov eax, dword ptr [eax + _ps + 536]
    sar edx, 7
    {store} add eax, edx
    mov dword ptr [ebp + 4], eax
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_33491:
    cmp word ptr [ebp + 32], 0x40
    jge actors_C_flow_33588
    cmp dword ptr [esp + 16], 0x300
    jge actors_C_flow_33588
    movsx eax, word ptr [esp + 44]
    imul eax, eax, 0x552
    movsx edx, word ptr [eax + _ps + 720]
    cmp edx, -1
    jne actors_C_flow_33588
    mov edx, dword ptr [esp + 32]
    mov word ptr [eax + _ps + 720], dx
    mov eax, dword ptr [esp + 24]
    mov ecx, dword ptr [eax]
    cmp ecx, 3
    je actors_C_flow_33558
    cmp ecx, 2
    jne actors_C_flow_33571
actors_C_flow_33558:
    mov eax, dword ptr [esp + 24]
    mov dword ptr [eax + 8], 0xc00
    jmp actors_C_flow_33578
actors_C_flow_33571:
    mov dword ptr [eax + 8], 0xfffff300
actors_C_flow_33578:
    mov eax, dword ptr [esp + 24]
    mov dword ptr [eax], 0xfffffffc
actors_C_flow_33588:
    movsx edx, word ptr [esp + 32]
    {store} mov eax, edx
    call ifhitbyweapon_
    mov word ptr [esp + 36], ax
    test ax, ax
    {disp32} jl actors_C_flow_33925
    mov eax, 0x95
    call spritesound_
    movsx eax, word ptr [esp + 44]
    imul eax, eax, 0x552
    inc byte ptr [eax + _ps + 1360]
    mov ecx, dword ptr [esp + 32]
    cmp cx, word ptr [eax + _ps + 720]
    jne actors_C_flow_33663
    mov word ptr [eax + _ps + 720], 0xffff
actors_C_flow_33663:
    cmp word ptr [esp + 36], 0x669
    jne actors_C_flow_33713
    movsx edx, word ptr [esp + 32]
    mov eax, 0x12f
    call spritesound_
    mov eax, dword ptr [esp + 24]
    mov dword ptr [eax], 0xfffffffb
    mov dword ptr [eax + 12], 0
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_33713:
    call krand_
    and eax, 0xff
    cmp eax, 0x20
    jge actors_C_flow_33755
    movsx eax, word ptr [esp + 32]
    mov edx, 0x4ca
    call spawn_
    cwde
    imul eax, eax, 0x2c
    xor dh, dh
    mov byte ptr [eax + _sprite + 17], dh
actors_C_flow_33755:
    {store} xor eax, eax
    mov dword ptr [esp + 16], eax
    jmp actors_C_flow_33885
actors_C_flow_33763:
    push 5
    movsx eax, word ptr [esp + 36]
    push eax
    movsx edx, word ptr [ebp + 36]
    call krand_
    and eax, 0xfff
    sar edx, 2
    neg eax
    {store} sub eax, edx
    push eax
    call krand_
    xor ah, ah
    and al, 0x3f
    .att_syntax prefix
    addl $actors_C_math_33802,%eax
    .intel_syntax noprefix
    cwde
    push eax
    call krand_
    and ah, 7
    cwde
    push eax
    push 0x30
    push 0x30
    push -8
    call krand_
    xor ah, ah
    mov ecx, dword ptr [ebp + 8]
    and al, 3
    mov ebx, dword ptr [ebp + 4]
    .att_syntax prefix
    addl $actors_C_math_33840,%eax
    .intel_syntax noprefix
    {disp8} mov edx, dword ptr [ebp]
    cwde
    sub ecx, 0x800
    push eax
    movsx eax, si
    call EGS_
    cwde
    imul eax, eax, 0x2c
    mov edi, dword ptr [esp + 16]
    inc edi
    mov dl, 6
    mov dword ptr [esp + 16], edi
    mov byte ptr [eax + _sprite + 17], dl
actors_C_flow_33885:
    cmp dword ptr [esp + 16], 8
    {disp32} jl actors_C_flow_33763
    mov eax, dword ptr [esp + 24]
    mov dword ptr [eax], 0xfffffffd
    movsx eax, word ptr [esp + 32]
    call deletesprite_
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_33925:
    mov eax, dword ptr [esp + 24]
    cmp dword ptr [eax], -1
    {disp32} jne actors_C_flow_34062
    {store} mov eax, edx
    call makeitfall_
    and byte ptr [ebp + 12], 0xf7
    mov dh, byte ptr [ebp + 21]
    mov word ptr [ebp + 14], 0x946
    cmp dh, 0x3e
    jbe actors_C_flow_33987
    mov ebx, 5
    mov edx, 0x8ee
    movsx ecx, word ptr [_myconnectindex]
    {store} mov eax, ebp
    call guts_
actors_C_flow_33987:
    cmp byte ptr [ebp + 20], 0x20
    jbe actors_C_flow_34003
    call krand_
    and al, 7
    sub byte ptr [ebp + 20], al
actors_C_flow_34003:
    cmp byte ptr [ebp + 21], 0x10
    jbe actors_C_flow_34028
    call krand_
    and al, 7
    sub byte ptr [ebp + 21], al
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_34028:
    mov byte ptr [ebp + 20], 0x28
    mov eax, dword ptr [esp + 24]
    mov byte ptr [ebp + 21], 0x10
    mov dword ptr [eax + 20], 0xffffffff
    mov dword ptr [eax], 0
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_34062:
    {store} mov eax, edx
    call getglobalz_
    mov eax, dword ptr [esp + 24]
    cmp dword ptr [eax], -2
    {disp32} jne actors_C_flow_34363
    {store} mov eax, edx
    call makeitfall_
    mov eax, dword ptr [esp + 24]
    imul eax, dword ptr [eax + 20], 0x2c
    {store} xor ebx, ebx
    mov word ptr [eax + _sprite + 32], bx
    mov eax, dword ptr [esp + 24]
    imul eax, dword ptr [eax + 20], 0x2c
    movsx eax, word ptr [eax + _sprite + 28]
    mov dword ptr [esp + 20], eax
    mov eax, dword ptr [esp + 24]
    imul eax, dword ptr [eax + 20], 0x2c
    mov eax, dword ptr [eax + _sprite + 8]
    mov dword ptr [ebp + 8], eax
    mov eax, dword ptr [esp + 24]
    imul eax, dword ptr [eax + 20], 0x2c
    mov edx, dword ptr [esp + 20]
    add edx, 0x200
    and edx, 0x7ff
    movsx edx, word ptr [edx*2 + _sintable]
    sar edx, 0xb
    mov eax, dword ptr [eax + _sprite]
    {store} add eax, edx
    {disp8} mov dword ptr [ebp], eax
    mov eax, dword ptr [esp + 24]
    imul edx, dword ptr [eax + 20], 0x2c
    mov ebx, dword ptr [esp + 20]
    and ebx, 0x7ff
    movsx ebx, word ptr [ebx*2 + _sintable]
    sar ebx, 0xb
    mov eax, dword ptr [edx + _sprite + 4]
    {store} add eax, ebx
    mov dword ptr [ebp + 4], eax
    mov ax, word ptr [_global_random]
    xor ah, ah
    and al, 1
    .att_syntax prefix
    addl $actors_C_math_34238,%eax
    .intel_syntax noprefix
    mov bh, byte ptr [ebp + 21]
    mov word ptr [ebp + 14], ax
    cmp bh, 0x40
    jae actors_C_flow_34272
    {store} mov ah, bh
    add ah, 2
    mov byte ptr [ebp + 21], ah
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_34272:
    mov cl, byte ptr [ebp + 20]
    cmp cl, 0x20
    jae actors_C_flow_34296
    {store} mov al, cl
    add al, 4
    mov byte ptr [ebp + 20], al
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_34296:
    mov eax, dword ptr [esp + 24]
    imul edx, dword ptr [eax + 20], 0x2c
    mov dword ptr [eax], 0xffffffff
    {store} mov eax, ebp
    add edx, OFFSET FLAT:_sprite
    call ldist_
    mov dword ptr [esp + 16], eax
    .att_syntax prefix
    cmpl $actors_C_math_34327,%eax
    .intel_syntax noprefix
    {disp32} jge actors_C_flow_38718
    mov eax, dword ptr [esp + 24]
    imul eax, dword ptr [eax + 20], 0x2c
    xor ch, ch
    mov byte ptr [eax + _sprite + 20], ch
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_34363:
    call krand_
    sar eax, 8
    .att_syntax prefix
    cmpl $actors_C_math_34371,%eax
    .intel_syntax noprefix
    {disp32} jl actors_C_flow_34544
    movsx eax, si
    mov ax, word ptr [eax*2 + _headspritesect]
actors_C_flow_34393:
    mov word ptr [esp + 36], ax
    mov edx, dword ptr [esp + 36]
    test dx, dx
    {disp32} jl actors_C_flow_34544
    movsx eax, dx
    imul eax, eax, 0x2c
    mov ax, word ptr [eax + _sprite + 14]
    .att_syntax prefix
    cmpw $actors_C_math_34424,%ax
    .intel_syntax noprefix
    jb actors_C_flow_34440
    jbe actors_C_flow_34446
    .att_syntax prefix
    cmpw $actors_C_math_34432,%ax
    .intel_syntax noprefix
    je actors_C_flow_34446
    jmp actors_C_flow_34526
actors_C_flow_34440:
    .att_syntax prefix
    cmpw $actors_C_math_34440,%ax
    .intel_syntax noprefix
    jne actors_C_flow_34526
actors_C_flow_34446:
    movsx ecx, word ptr [esp + 36]
    imul ebx, ecx, 0x2c
    mov edx, OFFSET FLAT:_sprite
    {store} mov eax, ebp
    {store} add edx, ebx
    call ldist_
    .att_syntax prefix
    cmpl $actors_C_math_34468,%eax
    .intel_syntax noprefix
    jge actors_C_flow_34526
    mov eax, dword ptr [ebp + 8]
    sub eax, dword ptr [ebx + _sprite + 8]
    test eax, eax
    jns actors_C_flow_34490
    neg eax
actors_C_flow_34490:
    .att_syntax prefix
    cmpl $actors_C_math_34490,%eax
    .intel_syntax noprefix
    jge actors_C_flow_34526
    mov eax, dword ptr [esp + 24]
    mov dword ptr [eax], 0xfffffffe
    mov dword ptr [eax + 4], 0
    mov dword ptr [eax + 20], ecx
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_34526:
    movsx eax, word ptr [esp + 36]
    mov ax, word ptr [eax*2 + _nextspritesect]
    {disp32} jmp actors_C_flow_34393
actors_C_flow_34544:
    mov eax, dword ptr [esp + 24]
    mov edx, dword ptr [eax]
    test edx, edx
    je actors_C_flow_34563
    cmp edx, 2
    {disp32} jne actors_C_flow_35057
actors_C_flow_34563:
    mov word ptr [ebp + 14], 0x942
    call krand_
    test ax, 0x1ff
    jne actors_C_flow_34595
    movsx edx, word ptr [esp + 32]
    mov eax, 0xa3
    call spritesound_
actors_C_flow_34595:
    mov eax, dword ptr [esp + 24]
    cmp dword ptr [eax], 2
    jne actors_C_flow_34713
    mov word ptr [ebp + 36], 0
    movsx edx, si
    mov bl, byte ptr [ebp + 12]
    {disp32} lea eax, dword ptr [edx*4]
    and bl, 0xf7
    {store} add eax, edx
    mov byte ptr [ebp + 12], bl
    test byte ptr [eax*8 + _sector + 12], 1
    jne actors_C_flow_34682
    movsx edx, word ptr [esp + 32]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov eax, dword ptr [eax + _hittype + 23]
    mov edi, dword ptr [ebp + 8]
    .att_syntax prefix
    addl $actors_C_math_34673,%eax
    .intel_syntax noprefix
    {store} cmp eax, edi
    jge actors_C_flow_34732
actors_C_flow_34682:
    mov ebx, dword ptr [ebp + 8]
    add ebx, 0x800
    mov eax, dword ptr [esp + 24]
    mov dword ptr [ebp + 8], ebx
    mov dword ptr [eax], 3
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_34713:
    mov dh, byte ptr [ebp + 12]
    or dh, 8
    movsx eax, word ptr [esp + 32]
    mov byte ptr [ebp + 12], dh
    call makeitfall_
actors_C_flow_34732:
    movsx eax, word ptr [esp + 32]
    mov edx, 0x10001
    call ssp_
    mov bx, word ptr [ebp + 32]
    cmp bx, 0x60
    jle actors_C_flow_34775
    {store} mov edx, ebx
    sub edx, 2
    mov word ptr [ebp + 32], dx
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_34775:
    cmp bx, 0x20
    jge actors_C_flow_34790
    {store} mov edi, ebx
    add edi, 4
    mov word ptr [ebp + 32], di
actors_C_flow_34790:
    mov eax, dword ptr [esp + 24]
    mov eax, dword ptr [eax + 4]
    .att_syntax prefix
    addl $actors_C_math_34797,%eax
    .intel_syntax noprefix
    and eax, 0x7ff
    movsx eax, word ptr [eax*2 + _sintable]
    mov edx, 0x40
    sar eax, 9
    {store} sub edx, eax
    movsx eax, word ptr [esp + 44]
    imul eax, eax, 0x552
    mov word ptr [ebp + 32], dx
    mov ebx, dword ptr [ebp + 4]
    {disp8} mov ecx, dword ptr [ebp]
    mov edx, dword ptr [eax + _ps + 536]
    mov eax, dword ptr [eax + _ps + 532]
    {store} sub edx, ebx
    {store} sub eax, ecx
    call getangle_
    movsx edx, ax
    movsx eax, word ptr [ebp + 28]
    call getincangle_
    cwde
    {store} mov edx, eax
    sar edx, 3
    movsx eax, word ptr [ebp + 28]
    {store} add eax, edx
    mov word ptr [ebp + 28], ax
    mov eax, dword ptr [esp + 24]
    mov eax, dword ptr [eax + 4]
    .att_syntax prefix
    addl $actors_C_math_34902,%eax
    .intel_syntax noprefix
    and eax, 0x7ff
    movsx eax, word ptr [eax*2 + _sintable]
    sar eax, 0xb
    add eax, 0x24
    mov byte ptr [ebp + 20], al
    mov eax, dword ptr [esp + 24]
    mov eax, dword ptr [eax + 4]
    and eax, 0x7ff
    movsx eax, word ptr [eax*2 + _sintable]
    sar eax, 0xd
    add eax, 0x10
    mov byte ptr [ebp + 21], al
    call krand_
    sar eax, 8
    .att_syntax prefix
    cmpl $actors_C_math_34966,%eax
    .intel_syntax noprefix
    jl actors_C_flow_35057
    movsx edx, si
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    test byte ptr [eax*8 + _sector + 12], 1
    jne actors_C_flow_35057
    movsx edx, word ptr [esp + 32]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    {store} mov edx, eax
    mov eax, dword ptr [eax + _hittype + 19]
    sub eax, dword ptr [edx + _hittype + 23]
    test eax, eax
    jns actors_C_flow_35038
    neg eax
actors_C_flow_35038:
    .att_syntax prefix
    cmpl $actors_C_math_35038,%eax
    .intel_syntax noprefix
    jge actors_C_flow_35057
    mov eax, dword ptr [esp + 24]
    mov word ptr [ebp + 36], 0
    inc dword ptr [eax]
actors_C_flow_35057:
    mov eax, dword ptr [esp + 24]
    cmp dword ptr [eax], 1
    {disp32} jne actors_C_flow_35193
    mov ch, byte ptr [ebp + 21]
    mov word ptr [ebp + 14], 0x942
    cmp ch, 0x28
    jae actors_C_flow_35091
    {store} mov al, ch
    add al, 8
    mov byte ptr [ebp + 21], al
actors_C_flow_35091:
    mov ah, byte ptr [ebp + 20]
    cmp ah, 8
    jbe actors_C_flow_35107
    {store} mov dl, ah
    sub dl, 4
    mov byte ptr [ebp + 20], dl
actors_C_flow_35107:
    movsx eax, word ptr [ebp + 36]
    .att_syntax prefix
    cmpl $actors_C_math_35111,%eax
    .intel_syntax noprefix
    jle actors_C_flow_35124
    sub word ptr [ebp + 36], 0x15c
actors_C_flow_35124:
    movsx eax, word ptr [ebp + 36]
    mov ebx, dword ptr [ebp + 8]
    movsx edx, word ptr [esp + 32]
    {store} add ebx, eax
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov dword ptr [ebp + 8], ebx
    mov eax, dword ptr [eax + _hittype + 23]
    .att_syntax prefix
    addl $actors_C_math_35165,%eax
    .intel_syntax noprefix
    {store} cmp eax, ebx
    jle actors_C_flow_35193
    mov dword ptr [ebp + 8], eax
    mov eax, dword ptr [esp + 24]
    mov word ptr [ebp + 32], 0
    mov dword ptr [eax], 2
actors_C_flow_35193:
    mov eax, dword ptr [esp + 24]
    cmp dword ptr [eax], 3
    {disp32} jne actors_C_flow_38718
    movsx edx, word ptr [esp + 32]
    {store} mov eax, edx
    mov word ptr [ebp + 14], 0x943
    call makeitfall_
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov eax, dword ptr [eax + _hittype + 19]
    mov edi, dword ptr [ebp + 8]
    sub eax, 0x800
    {store} cmp eax, edi
    jge actors_C_flow_35279
    mov ch, byte ptr [ebp + 21]
    mov al, byte ptr [ebp + 20]
    sub ch, 4
    add al, 2
    mov byte ptr [ebp + 21], ch
    mov byte ptr [ebp + 20], al
    jmp actors_C_flow_35311
actors_C_flow_35279:
    mov dh, byte ptr [ebp + 21]
    cmp dh, 0x24
    jae actors_C_flow_35295
    {store} mov bl, dh
    add bl, 8
    mov byte ptr [ebp + 21], bl
actors_C_flow_35295:
    mov bh, byte ptr [ebp + 20]
    cmp bh, 8
    jbe actors_C_flow_35311
    {store} mov cl, bh
    sub cl, 4
    mov byte ptr [ebp + 20], cl
actors_C_flow_35311:
    movsx edx, word ptr [esp + 32]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov eax, dword ptr [eax + _hittype + 19]
    mov edx, dword ptr [ebp + 8]
    sub eax, 0x800
    {store} cmp eax, edx
    {disp32} jge actors_C_flow_38718
    mov dword ptr [ebp + 8], eax
    mov eax, dword ptr [esp + 24]
    mov dword ptr [eax], 0
    mov word ptr [ebp + 32], 0
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_35384:
    movsx eax, word ptr [esp + 32]
    mov edx, 0xf9f
    call spawn_
    movsx edx, ax
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov dword ptr [eax + _hittype + 47], 3
actors_C_flow_35430:
    movsx eax, word ptr [ebp + 12]
    test ah, 0x80
    je actors_C_flow_35502
    mov eax, dword ptr [esp + 24]
    mov edx, dword ptr [eax + 8]
    dec edx
    mov dword ptr [eax + 8], edx
    test edx, edx
    {disp32} jg actors_C_flow_38718
    movsx ebx, word ptr [esp + 32]
    mov eax, 0x46
    {store} mov edx, ebx
    call spritesound_
    mov edx, 0x65e
    {store} mov eax, ebx
    call spawn_
    mov word ptr [ebp + 12], 0x101
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_35502:
    lea edx, dword ptr [esp + 16]
    {store} mov eax, ebp
    call findplayer_
    mov dword ptr [esp + 44], eax
    cmp dword ptr [esp + 16], 0x4c4
    jge actors_C_flow_35535
    and word ptr [ebp + 12], 0xfefe
    jmp actors_C_flow_35541
actors_C_flow_35535:
    or word ptr [ebp + 12], 0x101
actors_C_flow_35541:
    mov eax, dword ptr [esp + 24]
    mov edx, dword ptr [eax + 12]
    test edx, edx
    jne actors_C_flow_35596
    movsx eax, word ptr [esp + 32]
    call ifhitbyweapon_
    test ax, ax
    jl actors_C_flow_35596
    mov eax, dword ptr [esp + 24]
    mov dword ptr [eax + 12], 1
    mov dword ptr [eax + 16], edx
    mov dword ptr [esp + 20], edx
    mov word ptr [ebp + 32], 0
    {disp32} jmp actors_C_flow_36357
actors_C_flow_35596:
    cmp word ptr [ebp + 14], 0x3ac
    {disp32} je actors_C_flow_35859
    movsx edx, word ptr [esp + 32]
    {store} mov eax, edx
    movsx ebx, si
    call makeitfall_
    {disp32} lea eax, dword ptr [ebx*4]
    {store} add ebx, eax
    {disp32} lea ebx, dword ptr [ebx*8]
    cmp word ptr [ebx + _sector + 34], 1
    {disp32} je actors_C_flow_35787
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov edx, dword ptr [eax + _hittype + 19]
    mov ecx, dword ptr [ebp + 8]
    sub edx, 0x100
    {store} cmp edx, ecx
    jg actors_C_flow_35787
    mov di, word ptr [ebp + 34]
    cmp di, 3
    jge actors_C_flow_35787
    test di, di
    jg actors_C_flow_35721
    jne actors_C_flow_35736
    mov eax, dword ptr [eax + _hittype + 19]
    cmp eax, dword ptr [ebx + _sector + 8]
    jne actors_C_flow_35736
actors_C_flow_35721:
    movsx edx, word ptr [esp + 32]
    mov eax, 0xd
    call spritesound_
actors_C_flow_35736:
    mov eax, 4
    sub ax, word ptr [ebp + 34]
    shl eax, 8
    neg eax
    movsx edx, word ptr [ebp + 24]
    mov word ptr [ebp + 36], ax
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    cmp word ptr [eax*8 + _sector + 34], 2
    jne actors_C_flow_35783
    sar word ptr [ebp + 36], 2
actors_C_flow_35783:
    inc word ptr [ebp + 34]
actors_C_flow_35787:
    movsx edx, word ptr [esp + 32]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov edx, dword ptr [eax + _hittype + 23]
    add edx, 0x1000
    cmp edx, dword ptr [ebp + 8]
    jle actors_C_flow_35859
    movsx ebx, si
    {disp32} lea eax, dword ptr [ebx*4]
    {store} add eax, ebx
    cmp word ptr [eax*8 + _sector + 34], 2
    je actors_C_flow_35859
    mov word ptr [ebp + 36], 0
    mov dword ptr [ebp + 8], edx
actors_C_flow_35859:
    mov ax, word ptr [ebp + 28]
    and ah, 7
    cwde
    movsx ebx, word ptr [eax*2 + _sintable]
    movsx eax, word ptr [ebp + 32]
    imul ebx, eax
    movsx edx, word ptr [ebp + 28]
    add edx, 0x200
    and edx, 0x7ff
    movsx edx, word ptr [edx*2 + _sintable]
    imul edx, eax
    push 0x10001
    movsx edi, word ptr [esp + 36]
    movsx ecx, word ptr [ebp + 36]
    sar ebx, 0xe
    sar edx, 0xe
    {store} mov eax, edi
    call movesprite_
    mov word ptr [esp + 36], ax
    imul eax, edi, 0x2c
    movsx edx, word ptr [eax + _sprite + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    cmp word ptr [eax*8 + _sector + 34], 1
    jne actors_C_flow_36021
    cmp word ptr [ebp + 36], 0
    jne actors_C_flow_36021
    mov ebx, dword ptr [ebp + 8]
    add ebx, 0x2000
    mov eax, dword ptr [esp + 24]
    mov dword ptr [ebp + 8], ebx
    cmp dword ptr [eax + 20], 0
    jne actors_C_flow_36032
    mov edx, 0x564
    mov dword ptr [eax + 20], 1
    {store} mov eax, edi
    call spawn_
    jmp actors_C_flow_36032
actors_C_flow_36021:
    mov eax, dword ptr [esp + 24]
    mov dword ptr [eax + 20], 0
actors_C_flow_36032:
    mov eax, dword ptr [esp + 24]
    cmp dword ptr [eax + 12], 0
    jne actors_C_flow_36113
    mov cx, word ptr [ebp + 14]
    cmp cx, 0x3ac
    je actors_C_flow_36060
    cmp cx, 0x672
    jne actors_C_flow_36113
actors_C_flow_36060:
    cmp word ptr [esp + 36], 0
    jne actors_C_flow_36078
    cmp dword ptr [esp + 16], 0x34c
    jge actors_C_flow_36113
actors_C_flow_36078:
    mov eax, dword ptr [esp + 24]
    mov dword ptr [eax + 12], 1
    mov dword ptr [eax + 16], 0
    {store} xor eax, eax
    mov dword ptr [esp + 20], eax
    mov word ptr [ebp + 32], 0
    {disp32} jmp actors_C_flow_36357
actors_C_flow_36113:
    movsx eax, word ptr [ebp + 30]
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 14], 0x57d
    jne actors_C_flow_36144
    movsx eax, word ptr [eax + _sprite + 34]
    mov dword ptr [esp + 20], eax
    jmp actors_C_flow_36152
actors_C_flow_36144:
    mov dword ptr [esp + 20], 0xffffffff
actors_C_flow_36152:
    mov bx, word ptr [ebp + 32]
    test bx, bx
    jle actors_C_flow_36225
    movsx edx, si
    {store} mov ecx, ebx
    {disp32} lea eax, dword ptr [edx*4]
    sub ecx, 5
    {store} add eax, edx
    mov word ptr [ebp + 32], cx
    cmp word ptr [eax*8 + _sector + 34], 2
    jne actors_C_flow_36202
    {store} mov edi, ecx
    sub edi, 0xa
    mov word ptr [ebp + 32], di
actors_C_flow_36202:
    cmp word ptr [ebp + 32], 0
    jge actors_C_flow_36215
    mov word ptr [ebp + 32], 0
actors_C_flow_36215:
    test byte ptr [ebp + 32], 8
    je actors_C_flow_36225
    xor byte ptr [ebp + 12], 4
actors_C_flow_36225:
    movsx eax, word ptr [esp + 36]
    and eax, 0xc000
    .att_syntax prefix
    cmpl $actors_C_math_36235,%eax
    .intel_syntax noprefix
    jne actors_C_flow_36357
    mov ah, byte ptr [esp + 37]
    mov ebx, dword ptr [ebp + 8]
    and ah, 0x1f
    mov ecx, dword ptr [ebp + 4]
    mov byte ptr [esp + 37], ah
    movsx eax, word ptr [ebp + 14]
    movsx esi, word ptr [esp + 36]
    push eax
    {store} mov edx, esi
    movsx eax, word ptr [esp + 36]
    push ebx
    {disp8} mov ebx, dword ptr [ebp]
    shl esi, 5
    call checkhitwall_
    movsx ebx, word ptr [esi + _wall + 8]
    mov ecx, dword ptr [esi + _wall + 4]
    shl ebx, 5
    mov edi, dword ptr [esi + _wall]
    mov edx, dword ptr [ebx + _wall + 4]
    mov eax, dword ptr [ebx + _wall]
    {store} sub edx, ecx
    {store} sub eax, edi
    call getangle_
    mov dx, word ptr [ebp + 28]
    {store} add eax, eax
    mov bx, word ptr [ebp + 32]
    {store} sub eax, edx
    sar bx, 1
    and ah, 7
    mov word ptr [ebp + 32], bx
    mov word ptr [ebp + 28], ax
actors_C_flow_36357:
    mov ebx, dword ptr [esp + 20]
    test ebx, ebx
    jl actors_C_flow_36380
    imul eax, ebx, 0x552
    cmp byte ptr [eax + _ps + 1305], 0
    je actors_C_flow_36394
actors_C_flow_36380:
    mov eax, dword ptr [esp + 24]
    cmp dword ptr [eax + 12], 1
    {disp32} jne actors_C_flow_36718
actors_C_flow_36394:
    mov eax, dword ptr [esp + 24]
    mov ecx, dword ptr [eax + 16]
    inc ecx
    mov dword ptr [eax + 16], ecx
    cmp ecx, 2
    {disp32} jne actors_C_flow_36666
    movsx eax, word ptr [ebp + 42]
    mov dword ptr [esp + 16], eax
    mov ax, word ptr [ebp + 14]
    {store} xor edx, edx
    .att_syntax prefix
    cmpw $actors_C_math_36428,%ax
    .intel_syntax noprefix
    jb actors_C_flow_36444
    jbe actors_C_flow_36466
    .att_syntax prefix
    cmpw $actors_C_math_36436,%ax
    .intel_syntax noprefix
    je actors_C_flow_36458
    jmp actors_C_flow_36472
actors_C_flow_36444:
    .att_syntax prefix
    cmpw $actors_C_math_36444,%ax
    .intel_syntax noprefix
    jne actors_C_flow_36472
    mov edx, dword ptr [_pipebombblastradius]
    jmp actors_C_flow_36472
actors_C_flow_36458:
    mov edx, dword ptr [_morterblastradius]
    jmp actors_C_flow_36472
actors_C_flow_36466:
    mov edx, dword ptr [_bouncemineblastradius]
actors_C_flow_36472:
    mov edi, dword ptr [esp + 16]
    movsx esi, word ptr [esp + 32]
    {store} mov ebx, edi
    {store} mov eax, edi
    sar ebx, 2
    push edi
    {store} sub eax, ebx
    {store} mov ecx, edi
    push eax
    sar ecx, 1
    {store} mov eax, esi
    call hitradius_
    mov edx, 0x762
    {store} mov eax, esi
    call spawn_
    cmp word ptr [ebp + 36], 0
    jne actors_C_flow_36534
    mov edx, 0x8ab
    {store} mov eax, esi
    call spawn_
actors_C_flow_36534:
    movsx edx, word ptr [esp + 32]
    mov eax, 0xe
    call spritesound_
    {store} xor eax, eax
    mov dword ptr [esp + 16], eax
    jmp actors_C_flow_36659
actors_C_flow_36557:
    push 5
    movsx eax, word ptr [esp + 36]
    push eax
    mov edx, 0xfffffe00
    call krand_
    and eax, 0x7ff
    {store} sub edx, eax
    push edx
    call krand_
    xor ah, ah
    and al, 0x3f
    .att_syntax prefix
    addl $actors_C_math_36592,%eax
    .intel_syntax noprefix
    cwde
    push eax
    call krand_
    and ah, 7
    cwde
    push eax
    push 0x30
    push 0x30
    push -8
    call krand_
    xor ah, ah
    mov ecx, dword ptr [ebp + 8]
    and al, 0xf
    mov ebx, dword ptr [ebp + 4]
    .att_syntax prefix
    addl $actors_C_math_36630,%eax
    .intel_syntax noprefix
    {disp8} mov edx, dword ptr [ebp]
    cwde
    sub ecx, 0xc00
    push eax
    movsx eax, word ptr [ebp + 24]
    call EGS_
    inc dword ptr [esp + 16]
actors_C_flow_36659:
    cmp dword ptr [esp + 16], 8
    jl actors_C_flow_36557
actors_C_flow_36666:
    cmp byte ptr [ebp + 21], 0
    je actors_C_flow_36685
    mov byte ptr [ebp + 21], 0
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_36685:
    mov eax, dword ptr [esp + 24]
    cmp dword ptr [eax + 16], 0x14
    {disp32} jle actors_C_flow_37263
    movsx eax, word ptr [esp + 32]
    call deletesprite_
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_36718:
    cmp word ptr [ebp + 14], 0x1a
    {disp32} jne actors_C_flow_37263
    cmp dword ptr [esp + 16], 0x314
    {disp32} jge actors_C_flow_37263
    cmp dword ptr [eax], 7
    {disp32} jle actors_C_flow_37263
    cmp word ptr [ebp + 32], 0
    {disp32} jne actors_C_flow_37263
    movsx esi, word ptr [esp + 44]
    imul esi, esi, 0x552
    movsx eax, word ptr [esi + _ps + 646]
    push eax
    mov ebx, dword ptr [esi + _ps + 540]
    mov edx, dword ptr [ebp + 4]
    push ebx
    mov ecx, dword ptr [esi + _ps + 536]
    mov edi, dword ptr [esi + _ps + 532]
    push ecx
    {disp8} mov eax, dword ptr [ebp]
    mov ebx, dword ptr [ebp + 8]
    push edi
    sub ebx, 0x800
    movsx ecx, word ptr [ebp + 24]
    call cansee_
    test eax, eax
    {disp32} je actors_C_flow_37263
    mov edx, dword ptr [_max_ammo_amount + 20]
    movsx eax, word ptr [esi + _ps + 662]
    {store} cmp eax, edx
    {disp32} jge actors_C_flow_37263
    cmp dword ptr [_ud + 1502], 1
    jl actors_C_flow_36959
    {store} xor edi, edi
    mov esi, dword ptr [esp + 32]
    mov word ptr [esp + 36], di
    jmp actors_C_flow_36900
actors_C_flow_36878:
    movsx edx, dx
    cmp si, word ptr [eax + edx*2 + _ps + 752]
    {disp32} je actors_C_flow_38718
    inc word ptr [esp + 36]
actors_C_flow_36900:
    movsx eax, word ptr [esp + 44]
    imul eax, eax, 0x552
    mov edx, dword ptr [esp + 36]
    mov bx, word ptr [eax + _ps + 1264]
    {store} cmp dx, bx
    jl actors_C_flow_36878
    cmp bx, 0xff
    jge actors_C_flow_36959
    {store} mov edx, ebx
    inc edx
    movsx ebx, bx
    mov word ptr [eax + _ps + 1264], dx
    mov edx, dword ptr [esp + 32]
    mov word ptr [eax + ebx*2 + _ps + 752], dx
actors_C_flow_36959:
    movsx ecx, word ptr [esp + 44]
    imul ecx, ecx, 0x552
    mov edx, OFFSET FLAT:_ps
    mov ebx, 1
    mov eax, 5
    {store} add edx, ecx
    call addammo_
    mov eax, 0xd2
    movsx edx, word ptr [ecx + _ps + 724]
    call spritesound_
    cmp byte ptr [ecx + _ps + 1338], 0
    je actors_C_flow_37031
    mov ax, word ptr [ebp + 30]
    cmp ax, word ptr [ecx + _ps + 724]
    jne actors_C_flow_37057
actors_C_flow_37031:
    movsx eax, word ptr [esp + 44]
    imul eax, eax, 0x552
    mov edx, 5
    add eax, OFFSET FLAT:_ps
    call addweapon_
actors_C_flow_37057:
    movsx eax, word ptr [ebp + 30]
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 14], 0x57d
    je actors_C_flow_37118
    movsx eax, word ptr [esp + 44]
    imul eax, eax, 0x552
    xor cl, cl
    mov edi, 0x20
    mov byte ptr [eax + _ps + 1356], cl
    mov dword ptr [eax + _ps + 628], edi
    mov byte ptr [eax + _ps + 1357], 0x20
    mov byte ptr [eax + _ps + 1358], cl
actors_C_flow_37118:
    movsx ebx, word ptr [ebp + 30]
    {disp32} lea eax, dword ptr [ebx*8]
    {store} add eax, ebx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ebx
    cmp word ptr [eax + _hittype + 1], 0x1a
    jne actors_C_flow_37173
    cmp dword ptr [_ud + 1522], 0
    je actors_C_flow_37173
    imul ebx, ebx, 0x2c
    cmp word ptr [ebx + _sprite + 14], 0x57d
    jne actors_C_flow_37230
actors_C_flow_37173:
    cmp word ptr [ebp + 14], 0x1a
    jne actors_C_flow_37211
    movsx eax, word ptr [ebp + 30]
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 14], 0x57d
    je actors_C_flow_37211
    cmp dword ptr [_ud + 1502], 0
    {disp32} jne actors_C_flow_38718
actors_C_flow_37211:
    movsx eax, word ptr [esp + 32]
    call deletesprite_
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_37230:
    mov edx, dword ptr [esp + 24]
    mov eax, dword ptr [_respawnitemtime]
    mov dword ptr [edx + 8], eax
    movsx eax, word ptr [esp + 32]
    mov edx, 0xc76
    call spawn_
    mov word ptr [ebp + 12], 0x8000
actors_C_flow_37263:
    mov eax, dword ptr [esp + 24]
    mov edi, dword ptr [eax]
    cmp edi, 8
    {disp32} jge actors_C_flow_38718
    lea ebp, dword ptr [edi + 1]
    mov dword ptr [eax], ebp
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_37292:
    mov eax, dword ptr [esp + 24]
    cmp dword ptr [eax + 16], 1
    {disp32} jne actors_C_flow_37490
    movsx eax, si
    mov edi, 0xffff8000
    mov ax, word ptr [eax*2 + _headspritesect]
    mov esi, 0x448
actors_C_flow_37327:
    mov word ptr [esp + 36], ax
    mov ecx, dword ptr [esp + 36]
    test cx, cx
    {disp32} jl actors_C_flow_38718
    movsx edx, cx
    imul edx, edx, 0x2c
    mov ax, word ptr [edx + _sprite + 14]
    .att_syntax prefix
    cmpw $actors_C_math_37358,%ax
    .intel_syntax noprefix
    jb actors_C_flow_37390
    {disp32} jbe actors_C_flow_37457
    .att_syntax prefix
    cmpw $actors_C_math_37370,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_37472
    jbe actors_C_flow_37437
    .att_syntax prefix
    cmpw $actors_C_math_37382,%ax
    .intel_syntax noprefix
    je actors_C_flow_37457
    jmp actors_C_flow_37472
actors_C_flow_37390:
    .att_syntax prefix
    cmpw $actors_C_math_37390,%ax
    .intel_syntax noprefix
    jb actors_C_flow_37472
    jbe actors_C_flow_37406
    .att_syntax prefix
    cmpw $actors_C_math_37398,%ax
    .intel_syntax noprefix
    je actors_C_flow_37446
    jmp actors_C_flow_37472
actors_C_flow_37406:
    cmp word ptr [edx + _sprite + 38], 1
    jne actors_C_flow_37472
    mov ecx, 0xffffffff
    mov word ptr [edx + _sprite + 38], cx
    mov word ptr [edx + _sprite + 40], cx
    jmp actors_C_flow_37472
actors_C_flow_37437:
    mov word ptr [edx + _sprite + 14], si
    jmp actors_C_flow_37472
actors_C_flow_37446:
    mov word ptr [edx + _sprite + 14], 0x243
    jmp actors_C_flow_37472
actors_C_flow_37457:
    movsx eax, word ptr [esp + 36]
    imul eax, eax, 0x2c
    mov word ptr [eax + _sprite + 12], di
actors_C_flow_37472:
    movsx eax, word ptr [esp + 36]
    mov ax, word ptr [eax*2 + _nextspritesect]
    {disp32} jmp actors_C_flow_37327
actors_C_flow_37490:
    cmp dword ptr [eax + 4], 0x14
    jl actors_C_flow_37512
    mov dword ptr [eax + 16], 1
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_37512:
    lea edx, dword ptr [esp + 16]
    {store} mov eax, ebp
    call findplayer_
    mov dword ptr [esp + 44], eax
    mov eax, dword ptr [esp + 24]
    mov ecx, dword ptr [eax + 8]
    inc ecx
    mov dword ptr [eax + 8], ecx
    cmp ecx, 4
    jne actors_C_flow_37550
    mov dword ptr [eax + 8], 0
actors_C_flow_37550:
    cmp dword ptr [esp + 16], 0x1000
    {disp32} jge actors_C_flow_37728
    call krand_
    and eax, 0xff
    cmp eax, 0x10
    jge actors_C_flow_37698
    cmp dword ptr [_Sound + 2752], 1
    jge actors_C_flow_37616
    movsx eax, word ptr [esp + 44]
    imul eax, eax, 0x552
    movsx edx, word ptr [eax + _ps + 724]
    mov eax, 0xd3
    call spritesound_
actors_C_flow_37616:
    movsx edx, word ptr [esp + 32]
    mov eax, 0x15
    call spritesound_
    movsx eax, word ptr [esp + 44]
    imul eax, eax, 0x552
    movsx edx, word ptr [eax + _ps + 724]
    imul edx, edx, 0x2c
    mov dword ptr [eax + _ps + 628], 0x20
    mov byte ptr [eax + _ps + 1356], 0x20
    xor bh, bh
    mov di, word ptr [edx + _sprite + 42]
    mov byte ptr [eax + _ps + 1357], bh
    dec edi
    mov byte ptr [eax + _ps + 1358], bh
    mov word ptr [edx + _sprite + 42], di
actors_C_flow_37698:
    mov eax, dword ptr [esp + 24]
    mov ecx, dword ptr [eax]
    add ecx, 0x80
    mov edi, dword ptr [eax + 12]
    mov dword ptr [eax], ecx
    test edi, edi
    jne actors_C_flow_37739
    mov dword ptr [eax + 12], 1
    jmp actors_C_flow_37739
actors_C_flow_37728:
    mov eax, dword ptr [esp + 24]
    mov dword ptr [eax + 12], 0
actors_C_flow_37739:
    mov eax, dword ptr [esp + 24]
    mov edx, dword ptr [eax + 4]
    test edx, edx
    {disp32} je actors_C_flow_38186
    lea ecx, dword ptr [edx + 1]
    mov dword ptr [eax + 4], ecx
    mov edx, dword ptr [esp + 24]
    mov eax, dword ptr [ebp + 8]
    mov dword ptr [edx + 16], eax
    movsx edx, si
    {disp32} lea ebx, dword ptr [edx*4]
    {store} add ebx, edx
    {disp32} lea ebx, dword ptr [ebx*8]
    mov ecx, dword ptr [ebx + _sector + 8]
    mov edi, dword ptr [ebx + _sector + 4]
    call krand_
    {store} mov edx, eax
    {store} sub ecx, edi
    sar edx, 0x1f
    idiv ecx
    mov eax, dword ptr [ebx + _sector + 8]
    {store} sub eax, edx
    mov dword ptr [ebp + 8], eax
    mov eax, dword ptr [esp + 24]
    mov eax, dword ptr [eax + 4]
    sub eax, 3
    cmp eax, 0xc
    {disp32} ja actors_C_flow_38039
    jmp dword ptr cs:[eax*4 + actors_C_switch_27160]
actors_C_flow_37853:
    mov ebx, dword ptr [_impact_damage]
    {disp32} lea ebx, dword ptr [ebx*4]
    push ebx
    movsx eax, word ptr [esp + 36]
    push ebx
    mov edx, 0x1000
    {store} mov ecx, ebx
    call hitradius_
    mov ax, word ptr [_headspritestat + 12]
    mov ebx, 1
actors_C_flow_37896:
    mov word ptr [esp + 36], ax
    mov ecx, dword ptr [esp + 36]
    test cx, cx
    {disp32} jl actors_C_flow_38039
    movsx eax, cx
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 14], 8
    jne actors_C_flow_37960
    mov dx, word ptr [eax + _sprite + 40]
    cmp dx, word ptr [ebp + 40]
    jne actors_C_flow_37960
    cmp word ptr [eax + _sprite + 34], 0
    jne actors_C_flow_37960
    mov word ptr [eax + _sprite + 34], bx
actors_C_flow_37960:
    movsx eax, word ptr [esp + 36]
    mov ax, word ptr [eax*2 + _nextspritestat]
    jmp actors_C_flow_37896
actors_C_flow_37975:
    movsx eax, si
    mov ax, word ptr [eax*2 + _headspritesect]
    mov ebx, dword ptr [esp + 32]
actors_C_flow_37990:
    mov word ptr [esp + 36], ax
    mov edi, dword ptr [esp + 36]
    test di, di
    jl actors_C_flow_38039
    movsx edx, di
    movsx eax, word ptr [edx*2 + _nextspritesect]
    mov dword ptr [esp + 20], eax
    {store} cmp di, bx
    je actors_C_flow_38033
    {store} mov eax, edx
    call deletesprite_
    jmp actors_C_flow_38039
actors_C_flow_38033:
    mov eax, dword ptr [esp + 20]
    jmp actors_C_flow_37990
actors_C_flow_38039:
    {store} xor ebx, ebx
    mov dword ptr [esp + 16], ebx
    jmp actors_C_flow_38149
actors_C_flow_38047:
    push 5
    movsx eax, word ptr [esp + 36]
    push eax
    mov edx, 0xfffffe00
    call krand_
    and eax, 0x7ff
    {store} sub edx, eax
    push edx
    call krand_
    xor ah, ah
    and al, 0x3f
    .att_syntax prefix
    addl $actors_C_math_38082,%eax
    .intel_syntax noprefix
    cwde
    push eax
    call krand_
    and ah, 7
    cwde
    push eax
    push 0x30
    push 0x30
    push -8
    call krand_
    xor ah, ah
    mov ecx, dword ptr [ebp + 8]
    and al, 0xf
    mov ebx, dword ptr [ebp + 4]
    .att_syntax prefix
    addl $actors_C_math_38120,%eax
    .intel_syntax noprefix
    {disp8} mov edx, dword ptr [ebp]
    cwde
    sub ecx, 0xc00
    push eax
    movsx eax, word ptr [ebp + 24]
    call EGS_
    inc dword ptr [esp + 16]
actors_C_flow_38149:
    cmp dword ptr [esp + 16], 0x10
    jl actors_C_flow_38047
    mov eax, dword ptr [esp + 24]
    mov eax, dword ptr [eax + 16]
    mov dword ptr [ebp + 8], eax
    mov eax, dword ptr [esp + 24]
    mov dword ptr [eax + 16], 0
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_38186:
    movsx eax, word ptr [esp + 32]
    call ifhitbyweapon_
    test ax, ax
    {disp32} jl actors_C_flow_38718
    mov dword ptr [esp + 16], edx
    jmp actors_C_flow_38313
actors_C_flow_38211:
    push 5
    movsx eax, word ptr [esp + 36]
    push eax
    mov edx, 0xfffffe00
    call krand_
    and eax, 0x7ff
    {store} sub edx, eax
    push edx
    call krand_
    xor ah, ah
    and al, 0x3f
    .att_syntax prefix
    addl $actors_C_math_38246,%eax
    .intel_syntax noprefix
    cwde
    push eax
    call krand_
    and ah, 7
    cwde
    push eax
    push 0x30
    push 0x30
    push -8
    call krand_
    xor ah, ah
    mov ecx, dword ptr [ebp + 8]
    and al, 0xf
    mov ebx, dword ptr [ebp + 4]
    .att_syntax prefix
    addl $actors_C_math_38284,%eax
    .intel_syntax noprefix
    {disp8} mov edx, dword ptr [ebp]
    cwde
    sub ecx, 0xc00
    push eax
    movsx eax, word ptr [ebp + 24]
    call EGS_
    inc dword ptr [esp + 16]
actors_C_flow_38313:
    cmp dword ptr [esp + 16], 0x20
    jl actors_C_flow_38211
    cmp word ptr [ebp + 42], 0
    {disp32} jge actors_C_flow_38718
    mov eax, dword ptr [esp + 24]
    mov dword ptr [eax + 4], 1
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_38351:
    mov eax, dword ptr [esp + 24]
    mov esi, dword ptr [eax]
    test esi, esi
    {disp32} jne actors_C_flow_38718
    add dword ptr [eax + 4], 8
    cmp byte ptr [_camerashitable], 0
    {disp32} je actors_C_flow_38560
    movsx eax, word ptr [esp + 32]
    call ifhitbyweapon_
    mov word ptr [esp + 36], ax
    test ax, ax
    {disp32} jl actors_C_flow_38560
    mov eax, dword ptr [esp + 24]
    mov dword ptr [eax], 1
    mov word ptr [ebp + 12], 0x8000
    mov dword ptr [esp + 16], esi
    cmp dword ptr [esp + 16], 5
    jl actors_C_flow_38442
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_38442:
    push 5
    movsx eax, word ptr [esp + 36]
    push eax
    mov edx, 0xfffffe00
    call krand_
    and eax, 0x7ff
    {store} sub edx, eax
    push edx
    call krand_
    xor ah, ah
    and al, 0x3f
    .att_syntax prefix
    addl $actors_C_math_38477,%eax
    .intel_syntax noprefix
    cwde
    push eax
    call krand_
    and ah, 7
    cwde
    push eax
    push 0x30
    push 0x30
    push -8
    call krand_
    xor ah, ah
    mov ecx, dword ptr [ebp + 8]
    and al, 0xf
    mov ebx, dword ptr [ebp + 4]
    .att_syntax prefix
    addl $actors_C_math_38515,%eax
    .intel_syntax noprefix
    {disp8} mov edx, dword ptr [ebp]
    cwde
    sub ecx, 0xc00
    push eax
    movsx eax, word ptr [ebp + 24]
    call EGS_
    inc dword ptr [esp + 16]
    cmp dword ptr [esp + 16], 5
    jl actors_C_flow_38442
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_38560:
    mov ax, word ptr [ebp + 40]
    test ax, ax
    {disp32} jle actors_C_flow_38718
    movsx edx, ax
    mov eax, dword ptr [esp + 24]
    cmp edx, dword ptr [eax + 4]
    jle actors_C_flow_38599
    add word ptr [ebp + 28], 8
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_38599:
    mov ebx, dword ptr [esp + 24]
    {disp32} lea eax, dword ptr [edx*4]
    mov ecx, dword ptr [ebx + 4]
    {store} sub eax, edx
    {store} cmp eax, ecx
    jle actors_C_flow_38633
    sub word ptr [ebp + 28], 8
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_38633:
    {disp32} lea edx, dword ptr [edx*4]
    {store} cmp edx, ecx
    jle actors_C_flow_38658
    add word ptr [ebp + 28], 8
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_38658:
    mov dword ptr [ebx + 4], 8
    add word ptr [ebp + 28], 0x10
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_38679:
    cmp dh, 2
    jne actors_C_flow_38690
    mov word ptr [ebp + 12], 0x101
actors_C_flow_38690:
    lea edx, dword ptr [esp + 16]
    {store} mov eax, ebp
    call findplayer_
    mov ebx, dword ptr [esp + 16]
    movsx edx, ax
    movsx eax, word ptr [esp + 32]
    call execute_
actors_C_flow_38718:
    mov eax, dword ptr [esp + 40]
    {disp32} jmp actors_C_flow_27231
actors_C_flow_38727:
    add esp, 0x30
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
    {disp8} lea eax, dword ptr [eax]
moveexplosions_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    sub esp, 0x10
    mov ax, word ptr [_headspritestat + 10]
actors_C_flow_38767:
    mov dword ptr [esp + 8], eax
    mov edx, dword ptr [esp + 8]
    test dx, dx
    {disp32} jl actors_C_flow_20396
    movsx edx, dx
    mov ax, word ptr [edx*2 + _nextspritestat]
    mov dword ptr [esp + 4], eax
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    imul esi, edx, 0x2c
    mov edi, OFFSET FLAT:_hittype
    add esi, OFFSET FLAT:_sprite
    {store} add edi, eax
    mov bx, word ptr [esi + 24]
    add edi, 0x2f
    mov dword ptr [esp + 12], ebx
    test bx, bx
    jl actors_C_flow_38855
    cmp byte ptr [esi + 20], 0
    jne actors_C_flow_38870
actors_C_flow_38855:
    movsx eax, word ptr [esp + 8]
    call deletesprite_
    {disp32} jmp actors_C_flow_42782
actors_C_flow_38870:
    mov ebx, dword ptr [esi]
    mov dword ptr [eax + _hittype + 35], ebx
    mov ebx, dword ptr [esi + 4]
    mov dword ptr [eax + _hittype + 39], ebx
    mov ebx, dword ptr [esi + 8]
    mov dword ptr [eax + _hittype + 43], ebx
    mov ax, word ptr [esi + 14]
    .att_syntax prefix
    cmpw $actors_C_math_38900,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_39316
    {disp32} jbe actors_C_flow_40989
    .att_syntax prefix
    cmpw $actors_C_math_38916,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_39173
    {disp32} jbe actors_C_flow_40989
    .att_syntax prefix
    cmpw $actors_C_math_38932,%ax
    .intel_syntax noprefix
    jb actors_C_flow_39018
    {disp32} jbe actors_C_flow_42027
    .att_syntax prefix
    cmpw $actors_C_math_38944,%ax
    .intel_syntax noprefix
    jb actors_C_flow_38987
    {disp32} jbe actors_C_flow_39878
    .att_syntax prefix
    cmpw $actors_C_math_38956,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_39111
    {disp32} jbe actors_C_flow_42027
    .att_syntax prefix
    cmpw $actors_C_math_38972,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_40292
    {disp32} jmp actors_C_flow_39111
actors_C_flow_38987:
    .att_syntax prefix
    cmpw $actors_C_math_38987,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_39111
    {disp32} jbe actors_C_flow_42061
    .att_syntax prefix
    cmpw $actors_C_math_39003,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_42061
    {disp32} jmp actors_C_flow_39111
actors_C_flow_39018:
    .att_syntax prefix
    cmpw $actors_C_math_39018,%ax
    .intel_syntax noprefix
    jb actors_C_flow_39075
    {disp32} jbe actors_C_flow_40989
    .att_syntax prefix
    cmpw $actors_C_math_39030,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_39111
    .att_syntax prefix
    cmpw $actors_C_math_39040,%ax
    .intel_syntax noprefix
    {disp32} jbe actors_C_flow_39691
    .att_syntax prefix
    cmpw $actors_C_math_39050,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_39111
    .att_syntax prefix
    cmpw $actors_C_math_39060,%ax
    .intel_syntax noprefix
    {disp32} jbe actors_C_flow_42027
    {disp32} jmp actors_C_flow_39111
actors_C_flow_39075:
    .att_syntax prefix
    cmpw $actors_C_math_39075,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_39111
    {disp32} jbe actors_C_flow_40989
    .att_syntax prefix
    cmpw $actors_C_math_39091,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_39111
    .att_syntax prefix
    cmpw $actors_C_math_39101,%ax
    .intel_syntax noprefix
    {disp32} jbe actors_C_flow_42027
actors_C_flow_39111:
    movsx eax, word ptr [esp + 8]
    imul eax, eax, 0x2c
    mov dx, word ptr [eax + _sprite + 14]
    cmp dx, 0x956
    {disp32} jl actors_C_flow_42782
    cmp dx, 0x973
    {disp32} jg actors_C_flow_42782
    mov cx, word ptr [esi + 32]
    test cx, cx
    {disp32} jle actors_C_flow_42561
    {store} mov eax, ecx
    dec eax
    mov word ptr [esi + 32], ax
    {disp32} jmp actors_C_flow_42567
actors_C_flow_39173:
    .att_syntax prefix
    cmpw $actors_C_math_39173,%ax
    .intel_syntax noprefix
    jb actors_C_flow_39248
    {disp32} jbe actors_C_flow_40989
    .att_syntax prefix
    cmpw $actors_C_math_39185,%ax
    .intel_syntax noprefix
    jb actors_C_flow_39221
    {disp32} jbe actors_C_flow_40989
    .att_syntax prefix
    cmpw $actors_C_math_39197,%ax
    .intel_syntax noprefix
    jb actors_C_flow_39111
    {disp32} jbe actors_C_flow_40989
    .att_syntax prefix
    cmpw $actors_C_math_39209,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_40989
    jmp actors_C_flow_39111
actors_C_flow_39221:
    .att_syntax prefix
    cmpw $actors_C_math_39221,%ax
    .intel_syntax noprefix
    jb actors_C_flow_39111
    {disp32} jbe actors_C_flow_40989
    .att_syntax prefix
    cmpw $actors_C_math_39233,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_42027
    {disp32} jmp actors_C_flow_39111
actors_C_flow_39248:
    .att_syntax prefix
    cmpw $actors_C_math_39248,%ax
    .intel_syntax noprefix
    jb actors_C_flow_39291
    {disp32} jbe actors_C_flow_42027
    .att_syntax prefix
    cmpw $actors_C_math_39260,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_39111
    {disp32} jbe actors_C_flow_42027
    .att_syntax prefix
    cmpw $actors_C_math_39276,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_40989
    {disp32} jmp actors_C_flow_39111
actors_C_flow_39291:
    .att_syntax prefix
    cmpw $actors_C_math_39291,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_39111
    .att_syntax prefix
    cmpw $actors_C_math_39301,%ax
    .intel_syntax noprefix
    {disp32} jbe actors_C_flow_40392
    {disp32} jmp actors_C_flow_39111
actors_C_flow_39316:
    .att_syntax prefix
    cmpw $actors_C_math_39316,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_39476
    {disp32} jbe actors_C_flow_40989
    .att_syntax prefix
    cmpw $actors_C_math_39332,%ax
    .intel_syntax noprefix
    jb actors_C_flow_39418
    {disp32} jbe actors_C_flow_42027
    .att_syntax prefix
    cmpw $actors_C_math_39344,%ax
    .intel_syntax noprefix
    jb actors_C_flow_39387
    {disp32} jbe actors_C_flow_42027
    .att_syntax prefix
    cmpw $actors_C_math_39356,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_39111
    {disp32} jbe actors_C_flow_40989
    .att_syntax prefix
    cmpw $actors_C_math_39372,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_40989
    {disp32} jmp actors_C_flow_39111
actors_C_flow_39387:
    .att_syntax prefix
    cmpw $actors_C_math_39387,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_39111
    {disp32} jbe actors_C_flow_40514
    .att_syntax prefix
    cmpw $actors_C_math_39403,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_42027
    {disp32} jmp actors_C_flow_39111
actors_C_flow_39418:
    .att_syntax prefix
    cmpw $actors_C_math_39418,%ax
    .intel_syntax noprefix
    jb actors_C_flow_39461
    {disp32} jbe actors_C_flow_40989
    .att_syntax prefix
    cmpw $actors_C_math_39430,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_39111
    {disp32} jbe actors_C_flow_42027
    .att_syntax prefix
    cmpw $actors_C_math_39446,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_40506
    {disp32} jmp actors_C_flow_39111
actors_C_flow_39461:
    .att_syntax prefix
    cmpw $actors_C_math_39461,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_40989
    {disp32} jmp actors_C_flow_39111
actors_C_flow_39476:
    .att_syntax prefix
    cmpw $actors_C_math_39476,%ax
    .intel_syntax noprefix
    jb actors_C_flow_39562
    .att_syntax prefix
    cmpw $actors_C_math_39482,%ax
    .intel_syntax noprefix
    {disp32} jbe actors_C_flow_42310
    .att_syntax prefix
    cmpw $actors_C_math_39492,%ax
    .intel_syntax noprefix
    jb actors_C_flow_39535
    {disp32} jbe actors_C_flow_40544
    .att_syntax prefix
    cmpw $actors_C_math_39504,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_39111
    {disp32} jbe actors_C_flow_42027
    .att_syntax prefix
    cmpw $actors_C_math_39520,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_40142
    {disp32} jmp actors_C_flow_39111
actors_C_flow_39535:
    .att_syntax prefix
    cmpw $actors_C_math_39535,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_39111
    jbe actors_C_flow_39636
    .att_syntax prefix
    cmpw $actors_C_math_39547,%ax
    .intel_syntax noprefix
    {disp32} je actors_C_flow_41547
    {disp32} jmp actors_C_flow_39111
actors_C_flow_39562:
    .att_syntax prefix
    cmpw $actors_C_math_39562,%ax
    .intel_syntax noprefix
    jb actors_C_flow_39611
    {disp32} jbe actors_C_flow_42027
    .att_syntax prefix
    cmpw $actors_C_math_39574,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_39111
    .att_syntax prefix
    cmpw $actors_C_math_39584,%ax
    .intel_syntax noprefix
    jbe actors_C_flow_39636
    .att_syntax prefix
    cmpw $actors_C_math_39590,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_39111
    .att_syntax prefix
    cmpw $actors_C_math_39600,%ax
    .intel_syntax noprefix
    jbe actors_C_flow_39636
    {disp32} jmp actors_C_flow_39111
actors_C_flow_39611:
    .att_syntax prefix
    cmpw $actors_C_math_39611,%ax
    .intel_syntax noprefix
    {disp32} jb actors_C_flow_39111
    .att_syntax prefix
    cmpw $actors_C_math_39621,%ax
    .intel_syntax noprefix
    {disp32} jbe actors_C_flow_39761
    {disp32} jmp actors_C_flow_39111
actors_C_flow_39636:
    movsx eax, word ptr [esi + 38]
    movsx edx, word ptr [_global_random]
    lea ebx, dword ptr [eax + 1]
    {store} mov eax, edx
    sar edx, 0x1f
    idiv ebx
    and eax, 0x1f
    cmp eax, 4
    jle actors_C_flow_39678
    mov byte ptr [esi + 16], 0x81
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_39678:
    mov byte ptr [esi + 16], 0x7f
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_39691:
    cmp dword ptr [edi], 0xb6
    {disp32} je actors_C_flow_42782
    call krand_
    and eax, 0xf
    mov ebx, dword ptr [esi + 8]
    add eax, 0x10
    {store} add ebx, eax
    mov dword ptr [esi + 8], ebx
    mov ecx, dword ptr [edi]
    inc ecx
    mov ebx, 9
    {store} mov edx, ecx
    {store} mov eax, ecx
    sar edx, 0x1f
    idiv ebx
    mov dword ptr [edi], ecx
    test edx, edx
    {disp32} jne actors_C_flow_42782
    inc byte ptr [esi + 21]
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_39761:
    mov eax, dword ptr [edi]
    test eax, eax
    {disp32} je actors_C_flow_42782
    lea edx, dword ptr [eax + 1]
    mov dword ptr [edi], edx
    cmp edx, 8
    jne actors_C_flow_39789
    mov word ptr [esi + 14], 0x8f
    jmp actors_C_flow_39829
actors_C_flow_39789:
    cmp edx, 0x10
    jne actors_C_flow_39829
    movsx eax, word ptr [esi + 30]
    imul eax, eax, 0x2c
    mov word ptr [esi + 14], 0x90
    movsx eax, word ptr [eax + _sprite + 34]
    imul eax, eax, 0x552
    mov word ptr [eax + _ps + 732], 1
actors_C_flow_39829:
    movsx eax, word ptr [esi + 30]
    imul eax, eax, 0x2c
    movsx eax, word ptr [eax + _sprite + 34]
    imul eax, eax, 0x552
    cmp word ptr [eax + _ps + 732], 0x1a
    {disp32} jne actors_C_flow_42782
    mov word ptr [esi + 14], 0x91
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_39878:
    {store} xor eax, eax
    mov ebx, dword ptr [edi + 4]
    mov al, byte ptr [esi + 20]
    test ebx, ebx
    jle actors_C_flow_39916
    lea ecx, dword ptr [ebx + -1]
    mov dword ptr [edi + 4], ecx
    test ecx, ecx
    jne actors_C_flow_39916
    {store} mov eax, edx
    call deletesprite_
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_39916:
    movsx ebx, word ptr [esi + 30]
    {disp32} lea edx, dword ptr [ebx*8]
    {store} add edx, ebx
    {disp32} lea edx, dword ptr [edx*8]
    {store} sub edx, ebx
    cmp dword ptr [edx + _hittype + 51], 0
    jne actors_C_flow_39964
    mov edx, dword ptr [edi]
    cmp edx, 0x40
    jge actors_C_flow_39979
    lea ebx, dword ptr [edx + 1]
    add eax, 3
    mov dword ptr [edi], ebx
    jmp actors_C_flow_39979
actors_C_flow_39964:
    mov ecx, dword ptr [edi]
    cmp ecx, 0x40
    jle actors_C_flow_39979
    lea ebp, dword ptr [ecx + -1]
    sub eax, 3
    mov dword ptr [edi], ebp
actors_C_flow_39979:
    movsx edx, word ptr [esi + 30]
    imul edx, edx, 0x2c
    mov edx, dword ptr [edx + _sprite]
    mov dword ptr [esi], edx
    movsx edx, word ptr [esi + 30]
    imul edx, edx, 0x2c
    mov edx, dword ptr [edx + _sprite + 4]
    mov dword ptr [esi + 4], edx
    movsx edx, word ptr [esi + 30]
    imul edx, edx, 0x2c
    mov edx, dword ptr [edx + _sprite + 8]
    movsx ebx, word ptr [esi + 30]
    mov dword ptr [esi + 8], edx
    {disp32} lea edx, dword ptr [ebx*8]
    {store} add edx, ebx
    {disp32} lea edx, dword ptr [edx*8]
    {store} sub edx, ebx
    mov dx, word ptr [edx + _hittype + 47]
    add word ptr [esi + 28], dx
    cmp eax, 0x40
    jle actors_C_flow_40071
    mov eax, 0x40
    jmp actors_C_flow_40081
actors_C_flow_40071:
    cmp eax, 1
    jge actors_C_flow_40081
    mov eax, 1
actors_C_flow_40081:
    mov byte ptr [esi + 20], al
    mov byte ptr [esi + 21], al
    sar eax, 1
    sub eax, 0x30
    mov byte ptr [esi + 16], al
    mov bx, word ptr [edi]
    test bx, bx
    jg actors_C_flow_40112
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_40112:
    movsx eax, word ptr [esp + 8]
    mov edx, 0x10001
    call ssp_
    dec ebx
    test bx, bx
    jg actors_C_flow_40112
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_40142:
    mov esi, dword ptr [edi]
    inc esi
    mov dword ptr [edi], esi
    cmp esi, 1
    jne actors_C_flow_40245
    movsx edx, word ptr [esp + 12]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    cmp word ptr [eax*8 + _sector + 34], 1
    je actors_C_flow_40221
    movsx edx, word ptr [esp + 12]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    cmp word ptr [eax*8 + _sector + 34], 2
    je actors_C_flow_40221
    movsx eax, word ptr [esp + 8]
    call deletesprite_
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_40221:
    cmp dword ptr [_Sound + 295], 0
    jne actors_C_flow_40245
    movsx edx, word ptr [esp + 8]
    mov eax, 0x16
    call spritesound_
actors_C_flow_40245:
    cmp dword ptr [edi], 3
    jne actors_C_flow_40263
    mov ebx, dword ptr [edi + 4]
    mov dword ptr [edi], 0
    inc ebx
    mov dword ptr [edi + 4], ebx
actors_C_flow_40263:
    cmp dword ptr [edi + 4], 5
    {disp32} jne actors_C_flow_42782
    movsx eax, word ptr [esp + 8]
    call deletesprite_
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_40292:
    cmp word ptr [esi + 30], 0
    {disp32} jl actors_C_flow_42782
    mov ebx, dword ptr [edi]
    inc ebx
    mov dword ptr [edi], ebx
    cmp ebx, 7
    jle actors_C_flow_40329
    {store} mov eax, edx
    call deletesprite_
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_40329:
    cmp ebx, 4
    jle actors_C_flow_40342
    or word ptr [esi + 12], 0x202
    jmp actors_C_flow_40351
actors_C_flow_40342:
    cmp ebx, 2
    jle actors_C_flow_40351
    or byte ptr [esi + 12], 2
actors_C_flow_40351:
    movsx eax, word ptr [esi + 30]
    imul eax, eax, 0x2c
    mov al, byte ptr [eax + _sprite + 22]
    mov byte ptr [esi + 22], al
    movsx eax, word ptr [esi + 30]
    imul eax, eax, 0x2c
    mov al, byte ptr [eax + _sprite + 23]
    mov byte ptr [esi + 23], al
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_40392:
    {store} mov edx, esp
    {store} mov eax, esi
    call findplayer_
    mov ebp, dword ptr [esp]
    {store} mov ebx, eax
    cmp ebp, 0x200
    jge actors_C_flow_40506
    cwde
    imul eax, eax, 0x552
    mov dword ptr [eax + _ps + 628], 0x20
    movsx eax, bx
    imul eax, eax, 0x552
    mov byte ptr [eax + _ps + 1356], 0x20
    movsx eax, bx
    imul eax, eax, 0x552
    xor dl, dl
    mov byte ptr [eax + _ps + 1357], dl
    movsx eax, bx
    imul eax, eax, 0x552
    mov byte ptr [eax + _ps + 1358], dl
    movsx eax, bx
    imul eax, eax, 0x552
    movsx eax, word ptr [eax + _ps + 724]
    imul eax, eax, 0x2c
    sub word ptr [eax + _sprite + 42], 4
actors_C_flow_40506:
    cmp word ptr [esi + 42], 0x3e7
    jne actors_C_flow_40533
actors_C_flow_40514:
    movsx eax, word ptr [esp + 8]
    call deletesprite_
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_40533:
    mov word ptr [esi + 42], 0x3e7
    {disp32} jmp actors_C_flow_39111
actors_C_flow_40544:
    movsx edx, word ptr [esp + 8]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov edx, dword ptr [eax + _hittype + 47]
    and edx, 0x7ff
    movsx edx, word ptr [edx*2 + _sintable]
    call krand_
    sar edx, 9
    and eax, 7
    {store} add eax, edx
    movsx edx, word ptr [esp + 8]
    mov word ptr [esi + 32], ax
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    {store} mov edx, eax
    call krand_
    and eax, 0x3f
    add dword ptr [edx + _hittype + 47], eax
    movsx edx, word ptr [esp + 8]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov eax, dword ptr [eax + _hittype + 47]
    and eax, 0x7ff
    .att_syntax prefix
    cmpl $actors_C_math_40677,%eax
    .intel_syntax noprefix
    {disp32} jle actors_C_flow_40819
    movsx edx, word ptr [esp + 8]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov eax, dword ptr [eax + _hittype + 47]
    and eax, 0x7ff
    .att_syntax prefix
    cmpl $actors_C_math_40722,%eax
    .intel_syntax noprefix
    jge actors_C_flow_40819
    movsx edx, word ptr [esp + 12]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    cmp word ptr [eax*8 + _sector + 34], 2
    jne actors_C_flow_40787
    cmp word ptr [esi + 36], 0x40
    jge actors_C_flow_40819
    call krand_
    xor ah, ah
    and al, 7
    mov dx, word ptr [esi + 36]
    .att_syntax prefix
    addl $actors_C_math_40774,%eax
    .intel_syntax noprefix
    {store} add edx, eax
    mov word ptr [esi + 36], dx
    jmp actors_C_flow_40819
actors_C_flow_40787:
    cmp word ptr [esi + 36], 0x90
    jge actors_C_flow_40819
    call krand_
    xor ah, ah
    and al, 7
    mov cx, word ptr [esi + 36]
    .att_syntax prefix
    addl $actors_C_math_40808,%eax
    .intel_syntax noprefix
    {store} add ecx, eax
    mov word ptr [esi + 36], cx
actors_C_flow_40819:
    movsx ebp, word ptr [esp + 8]
    mov edx, 0x10001
    {store} mov eax, ebp
    call ssp_
    mov ebx, dword ptr [esi + 4]
    mov edx, dword ptr [esi]
    movsx eax, word ptr [esi + 24]
    call getflorzofslope_
    mov edx, dword ptr [esi + 8]
    {store} cmp eax, edx
    {disp32} jge actors_C_flow_39111
    {store} mov ecx, edx
    {store} mov eax, ebp
    mov ebx, dword ptr [esi + 4]
    mov edx, dword ptr [esi]
    call setsprite_
    mov ebx, dword ptr [esi + 4]
    mov edx, dword ptr [esi]
    movsx eax, word ptr [esi + 24]
    call getflorzofslope_
    mov dword ptr [esi + 8], eax
    {store} mov eax, ebp
    imul ebp, ebp, 0x2c
    mov ebx, 0x4d2
    call insertspriteq_
    mov word ptr [ebp + _sprite + 14], bx
    mov bx, word ptr [_headspritestat + 10]
actors_C_flow_40921:
    test bx, bx
    {disp32} jl actors_C_flow_39111
    movsx edx, bx
    imul edx, edx, 0x2c
    cmp word ptr [edx + _sprite + 14], 0x4ca
    jne actors_C_flow_40976
    add edx, OFFSET FLAT:_sprite
    {store} mov eax, esi
    call ldist_
    .att_syntax prefix
    cmpl $actors_C_math_40960,%eax
    .intel_syntax noprefix
    jge actors_C_flow_40976
    mov byte ptr [esi + 17], 2
    {disp32} jmp actors_C_flow_39111
actors_C_flow_40976:
    movsx ebx, bx
    mov bx, word ptr [ebx*2 + _nextspritestat]
    jmp actors_C_flow_40921
actors_C_flow_40989:
    mov cx, word ptr [esi + 32]
    test cx, cx
    jle actors_C_flow_41007
    {store} mov eax, ecx
    dec eax
    mov word ptr [esi + 32], ax
    jmp actors_C_flow_41013
actors_C_flow_41007:
    mov word ptr [esi + 32], 0
actors_C_flow_41013:
    movsx ebp, word ptr [esp + 12]
    mov ebx, dword ptr [esi + 4]
    mov edx, dword ptr [esi]
    {store} mov eax, ebp
    call getflorzofslope_
    {store} mov ecx, eax
    mov ebx, dword ptr [esi + 4]
    mov edx, dword ptr [esi]
    {store} mov eax, ebp
    call getceilzofslope_
    mov dword ptr [esp], eax
    {store} cmp eax, ecx
    je actors_C_flow_41067
    mov edx, dword ptr [esp + 12]
    test dx, dx
    jl actors_C_flow_41067
    cmp dx, 0x400
    jl actors_C_flow_41086
actors_C_flow_41067:
    movsx eax, word ptr [esp + 8]
    call deletesprite_
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_41086:
    sub ecx, 0x200
    mov ebx, dword ptr [esi + 8]
    {store} cmp ecx, ebx
    {disp32} jle actors_C_flow_41342
    {disp32} lea eax, dword ptr [ebp*4]
    {store} add eax, ebp
    {disp32} lea eax, dword ptr [eax*8]
    mov dx, word ptr [eax + _sector + 34]
    cmp dx, 1
    jne actors_C_flow_41151
    movsx eax, word ptr [esp + 8]
    call deletesprite_
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_41151:
    mov ebp, dword ptr [edi + 4]
    cmp ebp, 2
    jge actors_C_flow_41165
    inc ebp
    mov dword ptr [edi + 4], ebp
    jmp actors_C_flow_41245
actors_C_flow_41165:
    cmp dx, 2
    je actors_C_flow_41245
    mov dword ptr [edi + 4], 0
    mov cx, word ptr [esi + 14]
    cmp cx, 0x600
    je actors_C_flow_41203
    cmp cx, 0x5f0
    je actors_C_flow_41203
    cmp cx, 0x5f8
    jne actors_C_flow_41225
actors_C_flow_41203:
    mov ebx, dword ptr [edi]
    cmp ebx, 6
    jle actors_C_flow_41218
    mov dword ptr [edi], 0
    jmp actors_C_flow_41245
actors_C_flow_41218:
    lea ecx, dword ptr [ebx + 1]
    mov dword ptr [edi], ecx
    jmp actors_C_flow_41245
actors_C_flow_41225:
    mov eax, dword ptr [edi]
    cmp eax, 2
    jle actors_C_flow_41240
    mov dword ptr [edi], 0
    jmp actors_C_flow_41245
actors_C_flow_41240:
    lea edx, dword ptr [eax + 1]
    mov dword ptr [edi], edx
actors_C_flow_41245:
    mov bx, word ptr [esi + 36]
    cmp bx, 0x1800
    jge actors_C_flow_41311
    movsx edx, word ptr [esp + 12]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    cmp word ptr [eax*8 + _sector + 34], 2
    jne actors_C_flow_41299
    cmp bx, 0x400
    jge actors_C_flow_41311
    {store} mov edx, ebx
    add edx, 0x30
    mov word ptr [esi + 36], dx
    jmp actors_C_flow_41311
actors_C_flow_41299:
    {store} mov edi, ebx
    add edi, 0x80
    mov word ptr [esi + 36], di
actors_C_flow_41311:
    movsx eax, word ptr [esi + 28]
    .att_syntax prefix
    addl $actors_C_math_41315,%eax
    .intel_syntax noprefix
    and eax, 0x7ff
    movsx edx, word ptr [esi + 32]
    movsx eax, word ptr [eax*2 + _sintable]
    {disp32} jmp actors_C_flow_42724
actors_C_flow_41342:
    cmp dword ptr [edi + 8], 0
    jne actors_C_flow_41430
    movsx ebp, word ptr [esp + 8]
    {store} mov ecx, ebx
    mov edx, dword ptr [esi]
    {store} mov eax, ebp
    mov ebx, dword ptr [esi + 4]
    call setsprite_
    movsx edx, word ptr [esi + 24]
    cmp edx, -1
    jne actors_C_flow_41392
    {store} mov eax, ebp
    call deletesprite_
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_41392:
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    test byte ptr [eax*8 + _sector + 14], 2
    je actors_C_flow_41427
    {store} mov eax, ebp
    call deletesprite_
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_41427:
    inc dword ptr [edi + 8]
actors_C_flow_41430:
    mov ebx, dword ptr [esi + 4]
    mov edx, dword ptr [esi]
    movsx eax, word ptr [esi + 24]
    call getflorzofslope_
    mov word ptr [esi + 32], 0
    sub eax, 0x200
    mov cx, word ptr [esi + 14]
    mov dword ptr [esi + 8], eax
    cmp cx, 0x8ee
    jne actors_C_flow_41519
    inc dword ptr [edi + 4]
    test byte ptr [edi + 4], 3
    jne actors_C_flow_41490
    mov edx, dword ptr [edi]
    cmp edx, 7
    jge actors_C_flow_41490
    lea ebx, dword ptr [edx + 1]
    mov dword ptr [edi], ebx
actors_C_flow_41490:
    cmp dword ptr [edi + 4], 0x14
    {disp32} jle actors_C_flow_42782
    movsx eax, word ptr [esp + 8]
    call deletesprite_
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_41519:
    mov word ptr [esi + 14], 0x8ee
    mov dword ptr [edi], 0
actors_C_flow_41531:
    mov dword ptr [edi + 4], 0
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_41547:
    cmp dword ptr [edi], 0
    jne actors_C_flow_41611
    movsx edx, word ptr [esp + 12]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov dword ptr [edi], 1
    test byte ptr [eax*8 + _sector + 14], 2
    je actors_C_flow_41601
    movsx eax, word ptr [esp + 8]
    call deletesprite_
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_41601:
    movsx eax, word ptr [esp + 8]
    call insertspriteq_
actors_C_flow_41611:
    movsx ecx, word ptr [esp + 8]
    {store} mov eax, ecx
    {store} mov edx, esp
    call makeitfall_
    {store} mov eax, esi
    call findplayer_
    {store} mov ebx, eax
    {disp32} lea eax, dword ptr [ecx*8]
    {store} add eax, ecx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ecx
    {store} mov edx, eax
    mov eax, dword ptr [eax + _hittype + 19]
    sub eax, 0x100
    mov dword ptr [esi + 8], eax
    mov ecx, dword ptr [edi + 8]
    cmp ecx, 0x20
    jge actors_C_flow_41739
    lea ebp, dword ptr [ecx + 1]
    mov dword ptr [edi + 8], ebp
    cmp word ptr [edx + _hittype + 1], 0x3de
    jne actors_C_flow_41707
    cmp byte ptr [esi + 20], 0x40
    jae actors_C_flow_41739
    cmp byte ptr [esi + 21], 0x40
    jae actors_C_flow_41739
    jmp actors_C_flow_41719
actors_C_flow_41707:
    cmp byte ptr [esi + 20], 0x20
    jae actors_C_flow_41739
    cmp byte ptr [esi + 21], 0x20
    jae actors_C_flow_41739
actors_C_flow_41719:
    call krand_
    and al, 3
    add byte ptr [esi + 20], al
    call krand_
    and al, 3
    add byte ptr [esi + 21], al
actors_C_flow_41739:
    cmp dword ptr [esp], 0x34c
    {disp32} jge actors_C_flow_41531
    cmp byte ptr [esi + 20], 6
    {disp32} jbe actors_C_flow_41531
    cmp byte ptr [esi + 21], 6
    {disp32} jbe actors_C_flow_41531
    cmp byte ptr [esi + 17], 0
    jne actors_C_flow_41885
    call krand_
    and eax, 0xff
    cmp eax, 0x10
    jge actors_C_flow_41885
    cmp dword ptr [_Sound + 2752], 1
    jge actors_C_flow_41828
    movsx edx, bx
    imul edx, edx, 0x552
    mov eax, 0xd3
    movsx edx, word ptr [edx + _ps + 724]
    call spritesound_
actors_C_flow_41828:
    movsx eax, bx
    imul eax, eax, 0x552
    movsx edx, word ptr [eax + _ps + 724]
    imul edx, edx, 0x2c
    mov dword ptr [eax + _ps + 628], 0x20
    mov byte ptr [eax + _ps + 1356], 0x10
    xor cl, cl
    mov byte ptr [eax + _ps + 1357], cl
    mov byte ptr [eax + _ps + 1358], cl
    dec word ptr [edx + _sprite + 42]
actors_C_flow_41885:
    cmp dword ptr [edi + 4], 1
    {disp32} je actors_C_flow_42782
    movsx edx, word ptr [esp + 8]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov dword ptr [edi + 4], 1
    cmp word ptr [eax + _hittype + 1], 0x3de
    jne actors_C_flow_41954
    movsx eax, bx
    imul eax, eax, 0x552
    mov byte ptr [eax + _ps + 1304], 0xa
    jmp actors_C_flow_41970
actors_C_flow_41954:
    movsx eax, bx
    imul eax, eax, 0x552
    mov byte ptr [eax + _ps + 1304], 3
actors_C_flow_41970:
    movsx eax, bx
    imul eax, eax, 0x552
    mov dl, byte ptr [esi + 17]
    mov byte ptr [eax + _ps + 1328], dl
    movsx dx, byte ptr [esi + 16]
    mov word ptr [eax + _ps + 1294], dx
    cmp dword ptr [edi + 8], 0x20
    {disp32} jne actors_C_flow_42782
    sub byte ptr [esi + 20], 6
    sub byte ptr [esi + 21], 6
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_42027:
    {store} mov edx, esp
    {store} mov eax, esi
    call findplayer_
    mov ebx, dword ptr [esp]
    movsx edx, ax
    movsx eax, word ptr [esp + 8]
    call execute_
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_42061:
    movsx ebx, word ptr [esp + 8]
    mov edx, 0x10001
    {store} mov eax, ebx
    mov ecx, dword ptr [esp + 12]
    call ssp_
    test cx, cx
    jge actors_C_flow_42103
    {store} mov eax, ebx
    call deletesprite_
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_42103:
    movsx edx, cx
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    cmp word ptr [eax*8 + _sector + 34], 2
    jne actors_C_flow_42217
    mov ebx, dword ptr [edi + 4]
    inc ebx
    mov dword ptr [edi + 4], ebx
    cmp ebx, 8
    jle actors_C_flow_42155
    mov ebp, dword ptr [edi]
    inc ebp
    mov dword ptr [edi + 4], 0
    {store} mov eax, ebp
    and eax, 3
    mov dword ptr [edi], eax
actors_C_flow_42155:
    mov dx, word ptr [esi + 36]
    cmp dx, 0x80
    jge actors_C_flow_42175
    {store} mov ebx, edx
    add ebx, 8
    mov word ptr [esi + 36], bx
actors_C_flow_42175:
    mov cx, word ptr [esi + 32]
    test cx, cx
    jle actors_C_flow_42202
    {store} mov edi, ecx
    sub edi, 4
    mov word ptr [esi + 32], di
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_42202:
    mov word ptr [esi + 32], 0
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_42217:
    mov ecx, dword ptr [edi + 4]
    inc ecx
    mov dword ptr [edi + 4], ecx
    cmp ecx, 3
    jle actors_C_flow_42246
    mov eax, dword ptr [edi]
    inc eax
    mov dword ptr [edi + 4], 0
    {store} mov edx, eax
    and edx, 3
    mov dword ptr [edi], edx
actors_C_flow_42246:
    mov bx, word ptr [esi + 36]
    cmp bx, 0x200
    jge actors_C_flow_42266
    {store} mov ecx, ebx
    add ecx, 0x34
    mov word ptr [esi + 36], cx
actors_C_flow_42266:
    mov di, word ptr [esi + 32]
    test di, di
    jg actors_C_flow_42294
    movsx eax, word ptr [esp + 8]
    call deletesprite_
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_42294:
    {store} mov eax, edi
    dec eax
    mov word ptr [esi + 32], ax
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_42310:
    movsx eax, word ptr [esp + 8]
    call makeitfall_
    cmp word ptr [esi + 36], 0x1000
    jle actors_C_flow_42334
    mov word ptr [esi + 36], 0x1000
actors_C_flow_42334:
    mov ecx, dword ptr [esp + 12]
    test cx, cx
    jge actors_C_flow_42362
    movsx eax, word ptr [esp + 8]
    call deletesprite_
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_42362:
    movsx edx, word ptr [esp + 8]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov eax, dword ptr [eax + _hittype + 19]
    mov edx, dword ptr [esi + 8]
    sub eax, 0x100
    {store} cmp eax, edx
    jne actors_C_flow_42476
    cmp dword ptr [edi], 3
    jge actors_C_flow_42476
    mov eax, 3
    mov dx, word ptr [edi]
    {store} sub eax, edx
    {store} mov edx, eax
    call krand_
    shl edx, 8
    and ah, 1
    neg edx
    {store} sub edx, eax
    mov word ptr [esi + 36], dx
    movsx edx, cx
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    cmp word ptr [eax*8 + _sector + 34], 2
    jne actors_C_flow_42466
    sar word ptr [esi + 36], 1
actors_C_flow_42466:
    shr byte ptr [esi + 20], 1
    shr byte ptr [esi + 21], 1
    inc dword ptr [edi]
    jmp actors_C_flow_42500
actors_C_flow_42476:
    cmp dword ptr [edi], 3
    jne actors_C_flow_42500
    movsx eax, word ptr [esp + 8]
    call deletesprite_
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_42500:
    mov di, word ptr [esi + 32]
    test di, di
    jle actors_C_flow_42531
    {store} mov eax, edi
    sub eax, 2
    mov word ptr [esi + 32], ax
    xor ah, ah
    and al, 3
    shl eax, 2
    mov word ptr [esi + 12], ax
    jmp actors_C_flow_42537
actors_C_flow_42531:
    mov word ptr [esi + 32], 0
actors_C_flow_42537:
    movsx eax, word ptr [esp + 8]
    mov edx, 0x10001
    call ssp_
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_42561:
    mov word ptr [esi + 32], 0
actors_C_flow_42567:
    movsx edx, word ptr [esp + 12]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov eax, dword ptr [eax*8 + _sector + 8]
    mov ebp, dword ptr [esi + 8]
    sub eax, 0x200
    {store} cmp eax, ebp
    {disp32} jle actors_C_flow_42791
    mov eax, dword ptr [edi + 4]
    cmp eax, 1
    jge actors_C_flow_42618
    inc eax
    mov dword ptr [edi + 4], eax
    jmp actors_C_flow_42675
actors_C_flow_42618:
    mov dword ptr [edi + 4], 0
    cmp word ptr [esi + 14], 0x95e
    jge actors_C_flow_42655
    mov ecx, dword ptr [edi]
    cmp ecx, 6
    jle actors_C_flow_42648
    mov dword ptr [edi], 0
    jmp actors_C_flow_42675
actors_C_flow_42648:
    lea ebp, dword ptr [ecx + 1]
    mov dword ptr [edi], ebp
    jmp actors_C_flow_42675
actors_C_flow_42655:
    mov edx, dword ptr [edi]
    cmp edx, 2
    jle actors_C_flow_42670
    mov dword ptr [edi], 0
    jmp actors_C_flow_42675
actors_C_flow_42670:
    lea ebx, dword ptr [edx + 1]
    mov dword ptr [edi], ebx
actors_C_flow_42675:
    mov dx, word ptr [esi + 36]
    cmp dx, 0x1000
    jge actors_C_flow_42698
    {store} mov ebx, edx
    add ebx, 0x80
    mov word ptr [esi + 36], bx
actors_C_flow_42698:
    movsx eax, word ptr [esi + 28]
    .att_syntax prefix
    addl $actors_C_math_42702,%eax
    .intel_syntax noprefix
    and eax, 0x7ff
    movsx edx, word ptr [eax*2 + _sintable]
    movsx eax, word ptr [esi + 32]
actors_C_flow_42724:
    imul eax, edx
    sar eax, 0xe
    mov edx, dword ptr [esi]
    {store} add edx, eax
    mov ax, word ptr [esi + 28]
    and ah, 7
    mov dword ptr [esi], edx
    cwde
    movsx edx, word ptr [esi + 32]
    movsx eax, word ptr [eax*2 + _sintable]
    imul eax, edx
    mov ebx, dword ptr [esi + 4]
    sar eax, 0xe
    mov ecx, dword ptr [esi + 8]
    {store} add ebx, eax
    movsx eax, word ptr [esi + 36]
    mov dword ptr [esi + 4], ebx
    {store} add ecx, eax
    mov dword ptr [esi + 8], ecx
actors_C_flow_42782:
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
actors_C_flow_42791:
    cmp word ptr [esi + 14], 0x960
    jne actors_C_flow_42865
    mov bx, word ptr [esi + 34]
    test bx, bx
    jl actors_C_flow_42865
    movsx eax, word ptr [esp + 8]
    movsx edx, bx
    call spawn_
    mov ecx, dword ptr [esi + 8]
    mov ebx, dword ptr [esi + 4]
    mov edx, dword ptr [esi]
    movsx esi, ax
    {store} mov eax, esi
    call setsprite_
    {store} mov eax, esi
    imul esi, esi, 0x2c
    {store} xor ecx, ecx
    call getglobalz_
    mov word ptr [esi + _sprite + 38], cx
    mov word ptr [esi + _sprite + 40], cx
actors_C_flow_42865:
    movsx eax, word ptr [esp + 8]
    call deletesprite_
    mov eax, dword ptr [esp + 4]
    {disp32} jmp actors_C_flow_38767
# Existing symbolic effector source contribution begins; twelve real boundary LEAs retained.
actors_effector_boundary_padding:
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
moveeffectors_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    sub esp, 0x58
    {store} xor edx, edx
    mov ax, word ptr [_headspritestat + 6]
    mov dword ptr [_fricyv], edx
    mov dword ptr [_fricxv], edx
L895:
    mov dword ptr [esp + slot_i], eax
    mov edx, dword ptr [esp + slot_i]
    test dx, dx
    {disp32} jl L1292
    movsx ebx, dx
    imul ebp, ebx, 0x2c
    add ebp, OFFSET FLAT:_sprite
    mov ax, word ptr [ebx*2 + _nextspritestat]
    movsx edx, word ptr [ebp + 24]
    mov dword ptr [esp + slot_nexti], eax
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov edx, OFFSET FLAT:_sector
    {disp32} lea eax, dword ptr [eax*8]
    {store} add edx, eax
    movsx eax, word ptr [ebp + 38]
    mov dword ptr [esp + slot_st], eax
    mov ax, word ptr [ebp + 40]
    mov dword ptr [esp + slot_sh], eax
    {disp32} lea eax, dword ptr [ebx*8]
    {store} add eax, ebx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ebx
    add eax, OFFSET FLAT:_hittype
    mov dword ptr [esp + slot_sc], edx
    add eax, 0x2f
    mov ecx, dword ptr [esp + slot_st]
    mov dword ptr [esp + slot_t], eax
    cmp ecx, 0x14
    {disp32} jb L900
    {disp32} jbe L1171
    cmp ecx, 0x1f
    jb L898
    {disp32} jbe L1236
    cmp ecx, 0x23
    jb L897
    {disp32} jbe L1204
    cmp ecx, 0x80
    jb L896
    {disp32} jbe L1281
    cmp ecx, 0x82
    {disp32} jb L1291
    {disp32} jbe L1286
    cmp ecx, 0x83
    {disp32} je L1288
    {disp32} jmp L1291
L896:
    cmp ecx, 0x24
    {disp32} je L1278
    {disp32} jmp L1291
L897:
    cmp ecx, 0x21
    {disp32} jb L1266
    {disp32} jbe L1277
    {disp32} jmp L1190
L898:
    cmp ecx, 0x19
    jb L899
    {disp32} jbe L1212
    cmp ecx, 0x1b
    {disp32} jb L1216
    {disp32} jbe L1227
    cmp ecx, 0x1d
    {disp32} jb L1291
    {disp32} jbe L1235
    {disp32} jmp L974
L899:
    cmp ecx, 0x16
    {disp32} jb L1182
    {disp32} jbe L1188
    cmp ecx, 0x18
    {disp32} je L1190
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L900:
    cmp ecx, 0xa
    jb L902
    {disp32} jbe L1069
    cmp ecx, 0xe
    jb L901
    {disp32} jbe L944
    cmp ecx, 0x10
    {disp32} jb L1128
    {disp32} jbe L1133
    cmp ecx, 0x11
    {disp32} jbe L1142
    cmp ecx, 0x13
    {disp32} je L1158
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L901:
    cmp ecx, 0xc
    {disp32} jb L1078
    {disp32} jbe L1089
    {disp32} jmp L1109
L902:
    cmp ecx, 3
    jb L903
    {disp32} jbe L1020
    cmp ecx, 5
    {disp32} jb L1025
    {disp32} jbe L1038
    cmp ecx, 6
    {disp32} jbe L933
    cmp ecx, 8
    {disp32} jb L1291
    {disp32} jmp L1048
L903:
    cmp ecx, 1
    jb L904
    {disp32} jbe L930
    {disp32} jmp L1007
L904:
    test ecx, ecx
    {disp32} jne L1291
    movsx esi, word ptr [ebp + 30]
    imul eax, esi, 0x2c
    mov dx, word ptr [eax + _sprite + 38]
    mov dword ptr [esp + slot_zchange], ecx
    cmp dx, -1
    jne L905
    movsx eax, word ptr [esp + slot_i]
    call deletesprite_
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L905:
    mov eax, dword ptr [esp + slot_sc]
    movsx eax, word ptr [eax + 38]
    sar eax, 3
    mov dword ptr [esp + slot_q], eax
    mov eax, dword ptr [esp + slot_sc]
    mov bx, word ptr [eax + 34]
    {store} xor edi, edi
    cmp bx, 0x1e
    {disp32} jne L918
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    mov ecx, dword ptr [esp + slot_q]
    sar ecx, 2
    mov bx, word ptr [eax + _sprite + 42]
    mov dword ptr [esp + slot_q], ecx
    cmp bx, 1
    {disp32} jne L911
    movsx edx, word ptr [esp + slot_i]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    cmp word ptr [eax + _hittype + 11], 0x100
    jge L908
    movsx edx, word ptr [esp + slot_i]
    {disp32} lea ebx, dword ptr [edx*8]
    {store} add ebx, edx
    {disp32} lea ebx, dword ptr [ebx*8]
    {store} sub ebx, edx
    movsx edx, word ptr [esp + slot_i]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    mov cx, word ptr [ebx + _hittype + 11]
    {disp32} lea eax, dword ptr [eax*8]
    add ecx, 4
    {store} sub eax, edx
    mov word ptr [ebx + _hittype + 11], cx
    cmp word ptr [eax + _hittype + 11], 0x100
    jl L906
    movsx edx, word ptr [esp + slot_i]
    movsx eax, word ptr [ebp + 24]
    call callsound_
L906:
    cmp byte ptr [ebp + 18], 0
    je L907
    mov edi, 1
    jmp L909
L907:
    mov edi, 0xffffffff
    jmp L909
L908:
    movsx edx, word ptr [esp + slot_i]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov word ptr [eax + _hittype + 11], 0x100
L909:
    mov eax, dword ptr [esp + slot_sc]
    mov edx, dword ptr [ebp + 8]
    cmp edx, dword ptr [eax + 8]
    jge L910
    mov eax, dword ptr [esp + slot_sc]
    mov edx, dword ptr [eax + 8]
    sub edx, 0x200
    mov dword ptr [eax + 8], edx
    mov ecx, 0xfffffe00
    mov ebx, dword ptr [ebp + 8]
    mov dword ptr [esp + slot_zchange], ecx
    {store} cmp edx, ebx
    {disp32} jge L923
    mov dword ptr [eax + 8], ebx
    {disp32} jmp L923
L910:
    mov eax, dword ptr [esp + slot_sc]
    cmp edx, dword ptr [eax + 8]
    {disp32} jle L923
    mov eax, dword ptr [esp + slot_sc]
    mov ecx, 0x200
    mov edx, dword ptr [eax + 8]
    {store} add edx, ecx
    mov dword ptr [eax + 8], edx
    mov ebx, dword ptr [ebp + 8]
    mov dword ptr [esp + slot_zchange], ecx
    {store} cmp edx, ebx
    {disp32} jle L923
    mov dword ptr [eax + 8], ebx
    {disp32} jmp L923
L911:
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 42], 3
    {disp32} jne L923
    movsx edx, word ptr [esp + slot_i]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    cmp word ptr [eax + _hittype + 11], 0
    jle L914
    movsx edx, word ptr [esp + slot_i]
    {disp32} lea ebx, dword ptr [edx*8]
    {store} add ebx, edx
    {disp32} lea ebx, dword ptr [ebx*8]
    {store} sub ebx, edx
    movsx edx, word ptr [esp + slot_i]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    mov cx, word ptr [ebx + _hittype + 11]
    {disp32} lea eax, dword ptr [eax*8]
    sub ecx, 4
    {store} sub eax, edx
    mov word ptr [ebx + _hittype + 11], cx
    cmp word ptr [eax + _hittype + 11], 0
    jg L912
    movsx edx, word ptr [esp + slot_i]
    movsx eax, word ptr [ebp + 24]
    call callsound_
L912:
    cmp byte ptr [ebp + 18], 0
    je L913
    mov edi, 0xffffffff
    jmp L915
L913:
    mov edi, 1
    jmp L915
L914:
    movsx edx, word ptr [esp + slot_i]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    {store} xor ebx, ebx
    mov word ptr [eax + _hittype + 11], bx
L915:
    movsx edx, word ptr [esp + slot_i]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov edx, dword ptr [esp + slot_sc]
    mov ebx, dword ptr [eax + _hittype + 59]
    cmp ebx, dword ptr [edx + 8]
    jge L916
    mov dword ptr [esp + slot_zchange], 0xfffffe00
    mov edx, dword ptr [esp + slot_sc]
    mov ebx, dword ptr [edx + 8]
    sub ebx, 0x200
    mov dword ptr [edx + 8], ebx
    mov ecx, dword ptr [eax + _hittype + 59]
    {store} cmp ebx, ecx
    {disp32} jge L923
    jmp L917
L916:
    mov edx, dword ptr [esp + slot_sc]
    cmp ebx, dword ptr [edx + 8]
    {disp32} jle L923
    mov dword ptr [esp + slot_zchange], 0x200
    mov edx, dword ptr [esp + slot_sc]
    mov ebx, dword ptr [edx + 8]
    add ebx, 0x200
    mov dword ptr [edx + 8], ebx
    mov ecx, dword ptr [eax + _hittype + 59]
    {store} cmp ebx, ecx
    {disp32} jle L923
L917:
    mov dword ptr [edx + 8], ecx
    {disp32} jmp L923
L918:
    {disp32} lea eax, dword ptr [esi*8]
    {store} add eax, esi
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, esi
    cmp dword ptr [eax + _hittype + 47], 0
    {disp32} je L1291
    {disp32} lea eax, dword ptr [esi*8]
    {store} add eax, esi
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, esi
    cmp dword ptr [eax + _hittype + 47], 2
    jne L919
    movsx eax, word ptr [esp + slot_i]
    call deletesprite_
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L919:
    imul eax, esi, 0x2c
    cmp word ptr [eax + _sprite + 28], 0x400
    jle L920
    mov edi, 0xffffffff
    jmp L921
L920:
    mov edi, 1
L921:
    mov eax, dword ptr [esp + slot_t]
    cmp dword ptr [eax + 12], 0
    jne L922
    imul edx, esi, 0x2c
    {store} mov eax, ebp
    add edx, OFFSET FLAT:_sprite
    call ldist_
    mov edx, dword ptr [esp + slot_t]
    mov dword ptr [edx + 12], eax
L922:
    mov eax, dword ptr [esp + slot_t]
    mov ax, word ptr [eax + 12]
    mov word ptr [ebp + 32], ax
    imul eax, esi, 0x2c
    mov edx, dword ptr [eax + _sprite]
    {disp8} mov dword ptr [ebp], edx
    mov eax, dword ptr [eax + _sprite + 4]
    mov dword ptr [ebp + 4], eax
L923:
    mov eax, dword ptr [esp + slot_q]
    imul eax, edi
    mov dx, word ptr [ebp + 28]
    {store} add edx, eax
    mov eax, dword ptr [esp + slot_q]
    imul eax, edi
    mov word ptr [ebp + 28], dx
    mov edx, dword ptr [esp + slot_t]
    add dword ptr [edx + 8], eax
    test edi, edi
    {disp32} je L929
    mov eax, dword ptr [esp + slot_sc]
    test byte ptr [eax + 14], 0x40
    {disp32} je L929
    mov ax, word ptr [_connecthead]
    {disp32} jmp L926
L924:
    movsx eax, cx
    imul eax, eax, 0x552
    mov dx, word ptr [ebp + 24]
    mov dword ptr [esp + slot_player_state_cursor_100], eax
    cmp dx, word ptr [eax + _ps + 646]
    {disp32} jne L925
    mov eax, dword ptr [esp + slot_player_state_cursor_100]
    cmp byte ptr [eax + _ps + 1308], 1
    {disp32} jne L925
    mov eax, dword ptr [esp + slot_q]
    imul eax, edi
    mov edx, dword ptr [esp + slot_player_state_cursor_100]
    add word ptr [edx + _ps + 640], ax
    {store} mov eax, edx
    mov dh, byte ptr [edx + _ps + 641]
    and dh, 7
    mov byte ptr [eax + _ps + 641], dh
    mov edx, dword ptr [esp + slot_player_state_cursor_100]
    mov eax, dword ptr [esp + slot_zchange]
    mov ebx, dword ptr [edx + _ps + 540]
    {store} add ebx, eax
    {store} mov eax, esp
    push eax
    lea eax, dword ptr [esp + slot_m+4]
    push eax
    mov eax, dword ptr [esp + slot_q+8]
    imul eax, edi
    push eax
    imul eax, esi, 0x2c
    mov dword ptr [edx + _ps + 540], ebx
    mov ecx, dword ptr [edx + _ps + 536]
    mov ebx, dword ptr [edx + _ps + 532]
    mov edx, dword ptr [eax + _sprite + 4]
    mov eax, dword ptr [eax + _sprite]
    call rotatepoint_
    mov edx, dword ptr [esp + slot_player_state_cursor_100]
    mov eax, dword ptr [esp + slot_m]
    mov ecx, dword ptr [edx + _ps + 532]
    mov ebx, dword ptr [edx + _ps + 560]
    {store} sub eax, ecx
    {store} add ebx, eax
    mov ecx, dword ptr [edx + _ps + 536]
    mov dword ptr [edx + _ps + 560], ebx
    mov eax, dword ptr [esp + slot_x]
    mov ebx, dword ptr [edx + _ps + 564]
    {store} sub eax, ecx
    {store} add ebx, eax
    mov eax, dword ptr [esp + slot_m]
    mov dword ptr [edx + _ps + 564], ebx
    mov dword ptr [edx + _ps + 532], eax
    mov eax, dword ptr [esp + slot_x]
    mov dword ptr [edx + _ps + 536], eax
L925:
    movsx eax, word ptr [esp + slot_p]
    mov ax, word ptr [eax*2 + _connectpoint2]
L926:
    mov dword ptr [esp + slot_p], eax
    mov ecx, dword ptr [esp + slot_p]
    test cx, cx
    {disp32} jge L924
    movsx eax, word ptr [ebp + 24]
    mov ax, word ptr [eax*2 + _headspritesect]
L927:
    mov dword ptr [esp + slot_p], eax
    mov ecx, dword ptr [esp + slot_p]
    test cx, cx
    {disp32} jl L929
    movsx eax, cx
    imul eax, eax, 0x2c
    mov dx, word ptr [eax + _sprite + 26]
    cmp dx, 3
    {disp32} je L928
    cmp dx, 4
    je L928
    cmp word ptr [eax + _sprite + 14], 0x57d
    je L928
    mov edx, dword ptr [esp + slot_q]
    imul edx, edi
    mov bx, word ptr [eax + _sprite + 28]
    {store} add ebx, edx
    mov ecx, dword ptr [eax + _sprite + 8]
    mov word ptr [eax + _sprite + 28], bx
    mov edx, dword ptr [esp + slot_zchange]
    mov bl, byte ptr [eax + _sprite + 29]
    {store} add ecx, edx
    mov edx, OFFSET FLAT:_sprite
    and bl, 7
    mov dword ptr [eax + _sprite + 8], ecx
    {store} add edx, eax
    mov byte ptr [eax + _sprite + 29], bl
    lea ebx, dword ptr [edx + 4]
    mov ecx, dword ptr [eax + _sprite + 4]
    push ebx
    mov ebx, dword ptr [eax + _sprite]
    imul eax, esi, 0x2c
    push edx
    mov edx, dword ptr [esp + slot_q+8]
    imul edx, edi
    push edx
    mov edx, dword ptr [eax + _sprite + 4]
    mov eax, dword ptr [eax + _sprite]
    call rotatepoint_
L928:
    movsx eax, word ptr [esp + slot_p]
    mov ax, word ptr [eax*2 + _nextspritesect]
    {disp32} jmp L927
L929:
    movsx eax, word ptr [esp + slot_i]
    call ms_
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L930:
    movsx eax, word ptr [ebp + 30]
    cmp eax, -1
    {disp32} jne L1291
    mov eax, dword ptr [esp + slot_i]
    mov word ptr [ebp + 30], ax
    mov ebx, dword ptr [esp + slot_sh]
    movsx esi, word ptr [_headspritestat + 6]
L931:
    test esi, esi
    {disp32} jl L1291
    imul eax, esi, 0x2c
    cmp word ptr [eax + _sprite + 38], 0x13
    jne L932
    cmp bx, word ptr [eax + _sprite + 40]
    jne L932
    mov eax, dword ptr [esp + slot_t]
    mov dword ptr [eax], 0
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L932:
    movsx esi, word ptr [esi*2 + _nextspritestat]
    jmp L931
L933:
    mov edx, dword ptr [eax + 16]
    test edx, edx
    jle L937
    lea ebx, dword ptr [edx + -1]
    mov dword ptr [eax + 16], ebx
    cmp ebx, 0xe0
    jl L934
    sub word ptr [ebp + 32], 8
L934:
    mov eax, dword ptr [esp + slot_t]
    mov esi, dword ptr [eax + 16]
    cmp esi, 0x7f
    jle L935
    cmp esi, 0xe0
    jge L935
    mov word ptr [ebp + 32], 0
L935:
    mov eax, dword ptr [esp + slot_t]
    cmp dword ptr [eax + 16], 0x80
    jge L936
    add word ptr [ebp + 32], 8
L936:
    mov eax, dword ptr [esp + slot_t]
    cmp dword ptr [eax + 16], 0x60
    jge L938
    mov dword ptr [eax + 16], 0
L937:
    mov word ptr [ebp + 32], 0x100
L938:
    movsx esi, word ptr [_headspritestat + 6]
L939:
    test esi, esi
    {disp32} jl L943
    imul edx, esi, 0x2c
    cmp word ptr [edx + _sprite + 38], 0xe
    {disp32} jne L942
    mov eax, dword ptr [esp + slot_sh]
    cmp ax, word ptr [edx + _sprite + 40]
    {disp32} jne L942
    {disp32} lea eax, dword ptr [esi*8]
    {store} add eax, esi
    {disp32} lea eax, dword ptr [eax*8]
    mov ebx, dword ptr [esp + slot_t]
    {store} sub eax, esi
    mov edi, dword ptr [ebx]
    {store} mov ecx, eax
    cmp edi, dword ptr [eax + _hittype + 47]
    {disp32} jne L942
    mov ax, word ptr [ebp + 32]
    mov word ptr [edx + _sprite + 32], ax
    cmp dword ptr [ecx + _hittype + 67], 0
    jne L940
    mov eax, OFFSET FLAT:_sprite
    {store} add eax, edx
    {store} mov edx, ebp
    call dist_
    mov dword ptr [ecx + _hittype + 67], eax
L940:
    {disp32} lea ebx, dword ptr [esi*8]
    {store} add ebx, esi
    {disp32} lea ebx, dword ptr [ebx*8]
    {store} sub ebx, esi
    imul ecx, esi, 0x2c
    mov eax, OFFSET FLAT:_sprite
    {store} mov edx, ebp
    {store} add eax, ecx
    call dist_
    mov edx, dword ptr [ebx + _hittype + 67]
    {store} mov ebx, eax
    {store} sub ebx, edx
    {store} add ebx, ebx
    {store} sbb eax, eax
    {store} cmp eax, ebx
    adc eax, 0
    mov di, word ptr [ecx + _sprite + 42]
    mov dword ptr [esp + slot_x], eax
    test di, di
    je L941
    neg eax
    mov dword ptr [esp + slot_x], eax
L941:
    mov eax, dword ptr [esp + slot_x]
    mov dx, word ptr [ebp + 32]
    {store} add edx, eax
    {disp32} lea eax, dword ptr [esi*8]
    {store} add eax, esi
    mov word ptr [ebp + 32], dx
    {disp32} lea eax, dword ptr [eax*8]
    mov edx, dword ptr [esp + slot_t]
    {store} sub eax, esi
    mov edx, dword ptr [edx + 16]
    mov dword ptr [eax + _hittype + 63], edx
L942:
    movsx esi, word ptr [esi*2 + _nextspritestat]
    {disp32} jmp L939
L943:
    {store} xor eax, eax
    mov dword ptr [esp + slot_x], eax
L944:
    movsx eax, word ptr [ebp + 30]
    cmp eax, -1
    jne L945
    mov edx, dword ptr [esp + slot_t]
    mov eax, dword ptr [esp + slot_t]
    movsx edx, word ptr [edx]
    movsx eax, word ptr [eax + 12]
    call LocateTheLocator_
    mov word ptr [ebp + 30], ax
L945:
    movsx eax, word ptr [ebp + 30]
    cmp eax, -1
    jne L946
    mov eax, dword ptr [esp + slot_t]
    mov ebx, dword ptr [eax + 12]
    push ebx
    push OFFSET FLAT:L1296
    push OFFSET FLAT:_tempbuf
    call sprintf_
    add esp, 0xc
    mov eax, OFFSET FLAT:_tempbuf
    call gameexit_
L946:
    movsx eax, word ptr [ebp + 30]
    imul eax, eax, 0x2c
    {store} mov edx, ebp
    add eax, OFFSET FLAT:_sprite
    call ldist_
    .att_syntax prefix
    cmpl $actors_ASM_math_2494,%eax
    .intel_syntax noprefix
    jge L948
    cmp dword ptr [esp + slot_st], 6
    jne L947
    movsx eax, word ptr [ebp + 30]
    imul eax, eax, 0x2c
    test byte ptr [eax + _sprite + 40], 1
    je L947
    mov eax, dword ptr [esp + slot_t]
    mov dword ptr [eax + 16], 0x100
L947:
    mov eax, dword ptr [esp + slot_t]
    inc dword ptr [eax + 12]
    movsx edx, word ptr [eax]
    movsx eax, word ptr [eax + 12]
    call LocateTheLocator_
    mov word ptr [ebp + 30], ax
    cwde
    cmp eax, -1
    jne L948
    mov eax, dword ptr [esp + slot_t]
    mov dword ptr [eax + 12], 0
    movsx edx, word ptr [eax]
    {store} xor eax, eax
    call LocateTheLocator_
    mov word ptr [ebp + 30], ax
L948:
    cmp word ptr [ebp + 32], 0
    {disp32} je L1291
    movsx edx, word ptr [ebp + 30]
    imul edx, edx, 0x2c
    mov edi, dword ptr [ebp + 4]
    mov ebx, dword ptr [edx + _sprite + 4]
    mov eax, dword ptr [edx + _sprite]
    {disp8} mov edx, dword ptr [ebp]
    {store} sub ebx, edi
    {store} sub eax, edx
    {store} mov edx, ebx
    call getangle_
    mov dword ptr [esp + slot_x], eax
    movsx edx, word ptr [esp + slot_x]
    movsx eax, word ptr [ebp + 28]
    call getincangle_
    cwde
    mov edx, dword ptr [esp + slot_t]
    sar eax, 3
    mov ebx, dword ptr [edx + 8]
    {store} add ebx, eax
    mov dword ptr [esp + slot_q], eax
    mov dword ptr [edx + 8], ebx
    mov eax, dword ptr [esp + slot_q]
    mov cx, word ptr [ebp + 28]
    {store} add ecx, eax
    mov si, word ptr [ebp + 32]
    mov word ptr [ebp + 28], cx
    cmp si, 0x100
    {disp32} jne L950
    mov eax, dword ptr [esp + slot_sc]
    test byte ptr [eax + 14], 1
    jne L949
    test byte ptr [eax + 12], 1
    jne L949
    cmp dword ptr [_Sound + 984], 0
    jne L950
    movsx edx, word ptr [esp + slot_i]
    mov eax, 0x4b
    call spritesound_
    jmp L950
L949:
    call krand_
    sar eax, 8
    .att_syntax prefix
    cmpl $actors_ASM_math_2751,%eax
    .intel_syntax noprefix
    jl L950
    {store} mov edx, esp
    {store} mov eax, ebp
    call findplayer_
    cmp dword ptr [esp + slot_x], 0x5000
    jge L950
    movsx ebx, ax
    imul ebx, ebx, 0x552
    mov edx, dword ptr [ebp + 4]
    {disp8} mov eax, dword ptr [ebp]
    mov edi, dword ptr [ebx + _ps + 536]
    mov ecx, dword ptr [ebx + _ps + 532]
    {store} sub edx, edi
    {store} sub eax, ecx
    movsx esi, word ptr [ebp + 28]
    call getangle_
    mov edx, 0xa2d
    mov word ptr [ebp + 28], ax
    movsx eax, word ptr [esp + slot_i]
    call shoot_
    mov word ptr [ebp + 28], si
L950:
    cmp word ptr [ebp + 32], 0x40
    jg L951
    mov eax, dword ptr [esp + slot_sc]
    test byte ptr [eax + 14], 1
    jne L951
    test byte ptr [eax + 12], 1
    jne L951
    mov eax, 0x4b
    call stopsound_
L951:
    mov eax, dword ptr [esp + slot_sc]
    mov edx, dword ptr [esp + slot_sc]
    mov eax, dword ptr [eax + 8]
    sub eax, dword ptr [edx + 4]
    .att_syntax prefix
    cmpl $actors_ASM_math_2886,%eax
    .intel_syntax noprefix
    {disp32} jge L957
    cmp byte ptr [_ud + 8], 0
    {disp32} jne L957
    cmp word ptr [ebp + 32], 0xc0
    {disp32} jl L957
    mov ax, word ptr [_connecthead]
    {disp32} jmp L956
L952:
    movsx edx, dx
    imul edx, edx, 0x552
    movsx eax, word ptr [edx + _ps + 724]
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 42], 0
    {disp32} jle L955
    mov ax, word ptr [edx + _ps + 646]
    lea ebx, dword ptr [esp + slot_k]
    mov dword ptr [esp + slot_k], eax
    mov eax, dword ptr [edx + _ps + 536]
    mov ecx, dword ptr [edx + _ps + 532]
    {store} mov edx, eax
    {store} mov eax, ecx
    call updatesector_
    movsx eax, word ptr [esp + slot_k]
    cmp eax, -1
    jne L953
    cmp byte ptr [_ud + 8], 0
    je L954
L953:
    mov eax, dword ptr [esp + slot_k]
    mov cx, word ptr [ebp + 24]
    {store} cmp ax, cx
    jne L955
    movsx eax, word ptr [esp + slot_p]
    imul eax, eax, 0x552
    cmp cx, word ptr [eax + _ps + 646]
    je L955
L954:
    movsx esi, word ptr [esp + slot_p]
    imul esi, esi, 0x552
    {disp8} mov eax, dword ptr [ebp]
    mov dword ptr [esi + _ps + 532], eax
    mov eax, dword ptr [ebp + 4]
    mov dword ptr [esi + _ps + 536], eax
    mov ax, word ptr [ebp + 24]
    mov word ptr [esi + _ps + 646], ax
    mov ecx, dword ptr [ebp + 8]
    mov ebx, dword ptr [ebp + 4]
    {disp8} mov edx, dword ptr [ebp]
    movsx eax, word ptr [esi + _ps + 724]
    call setsprite_
    mov eax, OFFSET FLAT:_ps
    {store} add eax, esi
    call quickkill_
L955:
    movsx eax, word ptr [esp + slot_p]
    mov ax, word ptr [eax*2 + _connectpoint2]
L956:
    mov dword ptr [esp + slot_p], eax
    mov edx, dword ptr [esp + slot_p]
    test dx, dx
    {disp32} jge L952
L957:
    mov ax, word ptr [_connecthead]
    {disp32} jmp L962
L958:
    movsx eax, word ptr [ebp + 28]
    .att_syntax prefix
    addl $actors_ASM_math_3172,%eax
    .intel_syntax noprefix
    and eax, 0x7ff
    movsx edx, word ptr [ebp + 32]
    movsx eax, word ptr [eax*2 + _sintable]
    imul eax, edx
    sar eax, 0xe
    mov dword ptr [esp + slot_m], eax
    mov ax, word ptr [ebp + 28]
    and ah, 7
    cwde
    movsx edx, word ptr [eax*2 + _sintable]
    movsx eax, word ptr [ebp + 32]
    imul eax, edx
    movsx edx, di
    sar eax, 0xe
    shl edx, 4
    mov dword ptr [esp + slot_x], eax
    mov ax, word ptr [edx + _po + 14]
    cmp ax, word ptr [ebp + 24]
    jne L959
    mov eax, dword ptr [esp + slot_m]
    mov ebx, dword ptr [edx + _po]
    mov ecx, dword ptr [edx + _po + 4]
    {store} add ebx, eax
    mov eax, dword ptr [esp + slot_x]
    mov dword ptr [edx + _po], ebx
    {store} add ecx, eax
    mov dword ptr [edx + _po + 4], ecx
L959:
    movsx esi, word ptr [esp + slot_p]
    imul esi, esi, 0x552
    movsx eax, word ptr [esi + _ps + 724]
    imul eax, eax, 0x2c
    mov dx, word ptr [ebp + 24]
    cmp dx, word ptr [eax + _sprite + 24]
    {disp32} jne L961
    mov eax, OFFSET FLAT:_ps
    {store} add eax, esi
    lea edx, dword ptr [eax + 536]
    push edx
    .att_syntax prefix
    addl $actors_ASM_math_3339,%eax
    .intel_syntax noprefix
    mov edi, dword ptr [esp + slot_q+4]
    push eax
    mov ecx, dword ptr [esi + _ps + 536]
    mov ebx, dword ptr [esi + _ps + 532]
    push edi
    mov edx, dword ptr [ebp + 4]
    {disp8} mov eax, dword ptr [ebp]
    call rotatepoint_
    mov eax, dword ptr [esp + slot_m]
    mov edx, dword ptr [esi + _ps + 532]
    mov ebx, dword ptr [esi + _ps + 536]
    mov ecx, dword ptr [esi + _ps + 560]
    {store} add edx, eax
    mov eax, dword ptr [esp + slot_x]
    mov edi, dword ptr [esi + _ps + 564]
    {store} add ebx, eax
    mov eax, dword ptr [esp + slot_m]
    mov dword ptr [esi + _ps + 532], edx
    {store} add ecx, eax
    mov eax, dword ptr [esp + slot_x]
    mov dword ptr [esi + _ps + 536], ebx
    {store} add edi, eax
    mov dword ptr [esi + _ps + 564], edi
    mov di, word ptr [_numplayers]
    mov dword ptr [esi + _ps + 560], ecx
    cmp di, 1
    jle L960
    mov eax, dword ptr [esi + _ps + 532]
    mov dword ptr [esi + _ps + 568], eax
L960:
    movsx eax, word ptr [esp + slot_p]
    imul eax, eax, 0x552
    mov edx, dword ptr [esp + slot_q]
    add word ptr [eax + _ps + 640], dx
L961:
    movsx eax, word ptr [esp + slot_p]
    mov ax, word ptr [eax*2 + _connectpoint2]
L962:
    mov dword ptr [esp + slot_p], eax
    mov edi, dword ptr [esp + slot_p]
    test di, di
    {disp32} jge L958
    movsx eax, word ptr [ebp + 24]
    movsx esi, word ptr [eax*2 + _headspritesect]
L963:
    test esi, esi
    {disp32} jl L965
    imul edi, esi, 0x2c
    mov ax, word ptr [edi + _sprite + 14]
    .att_syntax prefix
    cmpw $actors_ASM_math_3550,%ax
    .intel_syntax noprefix
    je L964
    .att_syntax prefix
    cmpw $actors_ASM_math_3556,%ax
    .intel_syntax noprefix
    je L964
    mov eax, OFFSET FLAT:_sprite
    {store} add eax, edi
    lea edx, dword ptr [eax + 4]
    push edx
    mov ecx, dword ptr [esp + slot_q+4]
    push eax
    mov ebx, dword ptr [edi + _sprite]
    mov edx, dword ptr [ebp + 4]
    push ecx
    {disp8} mov eax, dword ptr [ebp]
    mov ecx, dword ptr [edi + _sprite + 4]
    call rotatepoint_
    mov eax, dword ptr [esp + slot_m]
    mov edx, dword ptr [edi + _sprite]
    mov ebx, dword ptr [edi + _sprite + 4]
    {store} add edx, eax
    mov eax, dword ptr [esp + slot_x]
    {store} add ebx, eax
    mov dword ptr [edi + _sprite + 4], ebx
    mov eax, dword ptr [esp + slot_q]
    mov bx, word ptr [edi + _sprite + 28]
    mov dword ptr [edi + _sprite], edx
    {store} add ebx, eax
    mov word ptr [edi + _sprite + 28], bx
L964:
    movsx esi, word ptr [esi*2 + _nextspritesect]
    {disp32} jmp L963
L965:
    movsx esi, word ptr [esp + slot_i]
    {store} mov eax, esi
    call ms_
    {store} mov eax, esi
    mov ecx, dword ptr [ebp + 8]
    mov ebx, dword ptr [ebp + 4]
    {disp8} mov edx, dword ptr [ebp]
    call setsprite_
    mov eax, dword ptr [esp + slot_sc]
    mov edx, dword ptr [esp + slot_sc]
    mov eax, dword ptr [eax + 8]
    sub eax, dword ptr [edx + 4]
    .att_syntax prefix
    cmpl $actors_ASM_math_3712,%eax
    .intel_syntax noprefix
    {disp32} jge L1291
    cmp byte ptr [_ud + 8], 0
    {disp32} jne L971
    cmp word ptr [ebp + 32], 0xc0
    {disp32} jl L971
    mov ax, word ptr [_connecthead]
    {disp32} jmp L970
L966:
    movsx edx, cx
    imul edx, edx, 0x552
    movsx eax, word ptr [edx + _ps + 724]
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 42], 0
    {disp32} jle L969
    mov ax, word ptr [edx + _ps + 646]
    lea ebx, dword ptr [esp + slot_k]
    mov dword ptr [esp + slot_k], eax
    mov eax, dword ptr [edx + _ps + 536]
    mov ecx, dword ptr [edx + _ps + 532]
    {store} mov edx, eax
    {store} mov eax, ecx
    call updatesector_
    movsx eax, word ptr [esp + slot_k]
    cmp eax, -1
    jne L967
    cmp byte ptr [_ud + 8], 0
    je L968
L967:
    mov eax, dword ptr [esp + slot_k]
    mov di, word ptr [ebp + 24]
    {store} cmp ax, di
    jne L969
    movsx eax, word ptr [esp + slot_p]
    imul eax, eax, 0x552
    cmp di, word ptr [eax + _ps + 646]
    je L969
L968:
    movsx esi, word ptr [esp + slot_p]
    imul esi, esi, 0x552
    {disp8} mov eax, dword ptr [ebp]
    mov dword ptr [esi + _ps + 532], eax
    mov eax, dword ptr [ebp + 4]
    mov dword ptr [esi + _ps + 536], eax
    mov ax, word ptr [ebp + 24]
    mov word ptr [esi + _ps + 646], ax
    mov ecx, dword ptr [ebp + 8]
    mov ebx, dword ptr [ebp + 4]
    {disp8} mov edx, dword ptr [ebp]
    movsx eax, word ptr [esi + _ps + 724]
    call setsprite_
    mov eax, OFFSET FLAT:_ps
    {store} add eax, esi
    call quickkill_
L969:
    movsx eax, word ptr [esp + slot_p]
    mov ax, word ptr [eax*2 + _connectpoint2]
L970:
    mov dword ptr [esp + slot_p], eax
    mov ecx, dword ptr [esp + slot_p]
    test cx, cx
    {disp32} jge L966
L971:
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    movsx eax, word ptr [eax + _sprite + 30]
    imul eax, eax, 0x2c
    movsx eax, word ptr [eax + _sprite + 24]
    movsx esi, word ptr [eax*2 + _headspritesect]
L972:
    test esi, esi
    {disp32} jl L1291
    imul ecx, esi, 0x2c
    mov bx, word ptr [ecx + _sprite + 26]
    movsx edi, word ptr [esi*2 + _nextspritesect]
    cmp bx, 1
    {disp32} jne L973
    mov eax, OFFSET FLAT:_sprite
    {store} add eax, ecx
    mov dword ptr [esp + slot_enemy_sprite_cursor_467], eax
    call badguy_
    test ax, ax
    {disp32} je L973
    mov ax, word ptr [ecx + _sprite + 14]
    {store} cmp ax, bx
    je L973
    .att_syntax prefix
    cmpw $actors_ASM_math_4089,%ax
    .intel_syntax noprefix
    je L973
    lea ebx, dword ptr [esp + slot_k]
    mov ax, word ptr [ecx + _sprite + 24]
    mov edx, dword ptr [ecx + _sprite + 4]
    mov dword ptr [esp + slot_k], eax
    mov eax, dword ptr [ecx + _sprite]
    call updatesector_
    cmp word ptr [ecx + _sprite + 42], 0
    jl L973
    mov eax, dword ptr [esp + slot_k]
    cmp ax, word ptr [ebp + 24]
    jne L973
    mov ebx, 0x48
    mov edx, 0x8ee
    mov eax, dword ptr [esp + slot_enemy_sprite_cursor_467]
    movsx ecx, word ptr [_myconnectindex]
    call gutsdir_
    movsx edx, word ptr [esp + slot_i]
    mov eax, 0x45
    call spritesound_
    {store} mov eax, esi
    call deletesprite_
L973:
    {store} mov esi, edi
    {disp32} jmp L972
L974:
    movsx eax, word ptr [ebp + 30]
    cmp eax, -1
    jne L975
    mov eax, dword ptr [esp + slot_t]
    cmp dword ptr [eax + 12], 0
    sete al
    {store} mov edx, eax
    mov eax, dword ptr [esp + slot_t]
    and edx, 0xff
    mov dword ptr [eax + 12], edx
    movsx edx, word ptr [eax]
    movsx eax, word ptr [eax + 12]
    call LocateTheLocator_
    mov word ptr [ebp + 30], ax
    {disp32} jmp L983
L975:
    mov eax, dword ptr [esp + slot_t]
    cmp dword ptr [eax + 16], 1
    jne L978
    movsx eax, word ptr [ebp + 30]
    imul eax, eax, 0x2c
    mov ebx, OFFSET FLAT:_sprite
    {store} mov edx, ebp
    {store} add eax, ebx
    call ldist_
    .att_syntax prefix
    cmpl $actors_ASM_math_4289,%eax
    .intel_syntax noprefix
    jge L976
    mov eax, dword ptr [esp + slot_t]
    mov dword ptr [eax + 16], 2
    jmp L978
L976:
    cmp word ptr [ebp + 32], 0
    jne L977
    mov eax, dword ptr [esp + slot_t]
    mov ebx, dword ptr [eax + 12]
    mov edx, 0xffffffff
    test ebx, ebx
    sete al
    mov si, word ptr [ebp + 40]
    xor ah, ah
    {store} add eax, esi
    cwde
    call operateactivators_
L977:
    mov di, word ptr [ebp + 32]
    cmp di, 0x100
    jge L978
    {store} mov eax, edi
    .att_syntax prefix
    addl $actors_ASM_math_4360,%eax
    .intel_syntax noprefix
    mov word ptr [ebp + 32], ax
L978:
    mov eax, dword ptr [esp + slot_t]
    cmp dword ptr [eax + 16], 2
    {disp32} jne L983
    movsx ebx, word ptr [ebp + 30]
    imul ebx, ebx, 0x2c
    mov esi, dword ptr [ebp + 4]
    {disp8} mov edi, dword ptr [ebp]
    mov edx, dword ptr [ebx + _sprite + 4]
    mov eax, dword ptr [ebx + _sprite]
    {store} sub edx, esi
    {store} sub eax, edi
    call FindDistance2D_
    .att_syntax prefix
    cmpl $actors_ASM_math_4417,%eax
    .intel_syntax noprefix
    jg L979
    mov word ptr [ebp + 32], 0
L979:
    mov dx, word ptr [ebp + 32]
    test dx, dx
    jle L980
    {store} mov ecx, edx
    sub ecx, 0x10
    mov word ptr [ebp + 32], cx
    {disp32} jmp L983
L980:
    mov word ptr [ebp + 32], 0
    mov edx, dword ptr [esp + slot_t]
    mov ax, word ptr [ebp + 40]
    add ax, word ptr [edx + 12]
    mov edx, 0xffffffff
    cwde
    call operateactivators_
    mov cl, byte ptr [ebp + 29]
    mov word ptr [ebp + 30], 0xffff
    add cl, 4
    mov eax, dword ptr [esp + slot_t]
    mov byte ptr [ebp + 29], cl
    mov dword ptr [eax + 16], 0
    movsx eax, word ptr [esp + slot_i]
    movsx edx, word ptr [ebp + 40]
    call operateforcefields_
    movsx eax, word ptr [ebp + 24]
    movsx esi, word ptr [eax*2 + _headspritesect]
L981:
    test esi, esi
    jl L983
    imul edx, esi, 0x2c
    mov bx, word ptr [edx + _sprite + 14]
    cmp bx, 1
    je L982
    cmp bx, 6
    je L982
    {disp32} lea eax, dword ptr [esi*8]
    {store} add eax, esi
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, esi
    mov ebx, dword ptr [edx + _sprite]
    mov edx, dword ptr [edx + _sprite + 4]
    mov dword ptr [eax + _hittype + 35], ebx
    mov dword ptr [eax + _hittype + 39], edx
L982:
    movsx esi, word ptr [esi*2 + _nextspritesect]
    jmp L981
L983:
    mov si, word ptr [ebp + 32]
    test si, si
    {disp32} je L1291
    movsx eax, word ptr [ebp + 28]
    .att_syntax prefix
    addl $actors_ASM_math_4629,%eax
    .intel_syntax noprefix
    and eax, 0x7ff
    movsx edi, word ptr [eax*2 + _sintable]
    movsx eax, si
    imul edi, eax
    mov dx, word ptr [ebp + 28]
    and dh, 7
    movsx edx, dx
    movsx edx, word ptr [edx*2 + _sintable]
    imul eax, edx
    sar eax, 0xe
    mov edx, dword ptr [esp + slot_sc]
    mov dword ptr [esp + slot_x], eax
    mov eax, dword ptr [esp + slot_sc]
    mov ebx, dword ptr [edx + 4]
    mov eax, dword ptr [eax + 8]
    {store} sub eax, ebx
    sar edi, 0xe
    .att_syntax prefix
    cmpl $actors_ASM_math_4699,%eax
    .intel_syntax noprefix
    {disp32} jge L989
    cmp byte ptr [_ud + 8], 0
    {disp32} jne L989
    mov ax, word ptr [_connecthead]
    {disp32} jmp L988
L984:
    movsx edx, ax
    imul edx, edx, 0x552
    movsx eax, word ptr [edx + _ps + 724]
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 42], 0
    {disp32} jle L987
    lea ebx, dword ptr [esp + slot_k]
    mov ax, word ptr [edx + _ps + 646]
    mov ecx, dword ptr [edx + _ps + 536]
    mov dword ptr [esp + slot_k], eax
    mov eax, dword ptr [edx + _ps + 532]
    {store} mov edx, ecx
    call updatesector_
    movsx eax, word ptr [esp + slot_k]
    cmp eax, -1
    jne L985
    cmp byte ptr [_ud + 8], 0
    je L986
L985:
    mov eax, dword ptr [esp + slot_k]
    mov cx, word ptr [ebp + 24]
    {store} cmp ax, cx
    jne L987
    movsx eax, word ptr [esp + slot_p]
    imul eax, eax, 0x552
    cmp cx, word ptr [eax + _ps + 646]
    je L987
L986:
    movsx esi, word ptr [esp + slot_p]
    imul esi, esi, 0x552
    {disp8} mov eax, dword ptr [ebp]
    mov dword ptr [esi + _ps + 532], eax
    mov eax, dword ptr [ebp + 4]
    mov dword ptr [esi + _ps + 536], eax
    mov ax, word ptr [ebp + 24]
    mov word ptr [esi + _ps + 646], ax
    mov ecx, dword ptr [ebp + 8]
    mov ebx, dword ptr [ebp + 4]
    {disp8} mov edx, dword ptr [ebp]
    movsx eax, word ptr [esi + _ps + 724]
    call setsprite_
    mov eax, OFFSET FLAT:_ps
    {store} add eax, esi
    call quickkill_
L987:
    movsx eax, word ptr [esp + slot_p]
    mov ax, word ptr [eax*2 + _connectpoint2]
L988:
    mov dword ptr [esp + slot_p], eax
    mov eax, dword ptr [esp + slot_p]
    test ax, ax
    {disp32} jge L984
L989:
    mov ax, word ptr [_connecthead]
    {disp32} jmp L994
L990:
    movsx edx, ax
    imul edx, edx, 0x552
    movsx eax, word ptr [edx + _ps + 724]
    imul eax, eax, 0x2c
    mov bx, word ptr [ebp + 24]
    cmp bx, word ptr [eax + _sprite + 24]
    jne L992
    mov eax, dword ptr [esp + slot_x]
    mov ecx, dword ptr [edx + _ps + 532]
    mov esi, dword ptr [edx + _ps + 536]
    {store} add ecx, edi
    {store} add esi, eax
    mov dword ptr [edx + _ps + 532], ecx
    mov cx, word ptr [_numplayers]
    mov dword ptr [edx + _ps + 536], esi
    cmp cx, 1
    jle L991
    mov eax, dword ptr [edx + _ps + 532]
    mov dword ptr [edx + _ps + 568], eax
    mov eax, dword ptr [edx + _ps + 536]
    mov dword ptr [edx + _ps + 572], eax
L991:
    movsx edx, word ptr [esp + slot_p]
    imul edx, edx, 0x552
    mov eax, dword ptr [edx + _ps + 560]
    {store} add eax, edi
    mov ebx, dword ptr [edx + _ps + 564]
    mov dword ptr [edx + _ps + 560], eax
    mov eax, dword ptr [esp + slot_x]
    {store} add ebx, eax
    mov dword ptr [edx + _ps + 564], ebx
L992:
    movsx edx, word ptr [esp + slot_p]
    shl edx, 4
    mov si, word ptr [ebp + 24]
    cmp si, word ptr [edx + _po + 14]
    jne L993
    mov eax, dword ptr [esp + slot_x]
    mov ecx, dword ptr [edx + _po]
    mov esi, dword ptr [edx + _po + 4]
    {store} add ecx, edi
    {store} add esi, eax
    mov dword ptr [edx + _po], ecx
    mov dword ptr [edx + _po + 4], esi
L993:
    movsx eax, word ptr [esp + slot_p]
    mov ax, word ptr [eax*2 + _connectpoint2]
L994:
    mov dword ptr [esp + slot_p], eax
    mov eax, dword ptr [esp + slot_p]
    test ax, ax
    {disp32} jge L990
    movsx eax, word ptr [ebp + 24]
    mov cx, word ptr [_numplayers]
    movsx esi, word ptr [eax*2 + _headspritesect]
L995:
    test esi, esi
    {disp32} jl L998
    imul edx, esi, 0x2c
    mov ax, word ptr [edx + _sprite + 14]
    .att_syntax prefix
    cmpw $actors_ASM_math_5228,%ax
    .intel_syntax noprefix
    {disp32} je L997
    .att_syntax prefix
    cmpw $actors_ASM_math_5238,%ax
    .intel_syntax noprefix
    {disp32} je L997
    cmp cx, 2
    jge L996
    {disp32} lea eax, dword ptr [esi*8]
    {store} add eax, esi
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, esi
    mov ebx, dword ptr [edx + _sprite]
    mov edx, dword ptr [edx + _sprite + 4]
    mov dword ptr [eax + _hittype + 35], ebx
    mov dword ptr [eax + _hittype + 39], edx
L996:
    imul edx, esi, 0x2c
    mov eax, dword ptr [edx + _sprite]
    {store} add eax, edi
    mov ebx, dword ptr [edx + _sprite + 4]
    mov dword ptr [edx + _sprite], eax
    add ebx, dword ptr [esp + slot_x]
    mov ax, word ptr [_numplayers]
    mov dword ptr [edx + _sprite + 4], ebx
    .att_syntax prefix
    cmpw $actors_ASM_math_5334,%ax
    .intel_syntax noprefix
    jle L997
    {disp32} lea eax, dword ptr [esi*8]
    {store} add eax, esi
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, esi
    mov ebx, dword ptr [edx + _sprite]
    mov edx, dword ptr [edx + _sprite + 4]
    mov dword ptr [eax + _hittype + 35], ebx
    mov dword ptr [eax + _hittype + 39], edx
L997:
    movsx esi, word ptr [esi*2 + _nextspritesect]
    {disp32} jmp L995
L998:
    movsx esi, word ptr [esp + slot_i]
    {store} mov eax, esi
    call ms_
    {store} mov eax, esi
    mov ecx, dword ptr [ebp + 8]
    mov ebx, dword ptr [ebp + 4]
    {disp8} mov edx, dword ptr [ebp]
    call setsprite_
    mov eax, dword ptr [esp + slot_sc]
    mov edx, dword ptr [esp + slot_sc]
    mov eax, dword ptr [eax + 8]
    sub eax, dword ptr [edx + 4]
    .att_syntax prefix
    cmpl $actors_ASM_math_5437,%eax
    .intel_syntax noprefix
    {disp32} jge L1291
    cmp byte ptr [_ud + 8], 0
    {disp32} jne L1004
    mov ax, word ptr [_connecthead]
    {disp32} jmp L1003
L999:
    movsx edx, dx
    imul edx, edx, 0x552
    movsx eax, word ptr [edx + _ps + 724]
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 42], 0
    {disp32} jle L1002
    lea ebx, dword ptr [esp + slot_k]
    mov ax, word ptr [edx + _ps + 646]
    mov ecx, dword ptr [edx + _ps + 536]
    mov dword ptr [esp + slot_k], eax
    mov eax, dword ptr [edx + _ps + 532]
    {store} mov edx, ecx
    call updatesector_
    movsx eax, word ptr [esp + slot_k]
    cmp eax, -1
    jne L1000
    cmp byte ptr [_ud + 8], 0
    je L1001
L1000:
    mov eax, dword ptr [esp + slot_k]
    mov cx, word ptr [ebp + 24]
    {store} cmp ax, cx
    jne L1002
    movsx eax, word ptr [esp + slot_p]
    imul eax, eax, 0x552
    cmp cx, word ptr [eax + _ps + 646]
    je L1002
L1001:
    movsx esi, word ptr [esp + slot_p]
    imul esi, esi, 0x552
    {disp8} mov eax, dword ptr [ebp]
    mov dword ptr [esi + _ps + 532], eax
    mov eax, dword ptr [ebp + 4]
    mov dword ptr [esi + _ps + 536], eax
    mov eax, dword ptr [esi + _ps + 532]
    mov dword ptr [esi + _ps + 568], eax
    mov eax, dword ptr [esi + _ps + 536]
    mov dword ptr [esi + _ps + 572], eax
    mov ax, word ptr [ebp + 24]
    mov word ptr [esi + _ps + 646], ax
    mov ecx, dword ptr [ebp + 8]
    mov ebx, dword ptr [ebp + 4]
    {disp8} mov edx, dword ptr [ebp]
    movsx eax, word ptr [esi + _ps + 724]
    call setsprite_
    mov eax, OFFSET FLAT:_ps
    {store} add eax, esi
    call quickkill_
L1002:
    movsx eax, word ptr [esp + slot_p]
    mov ax, word ptr [eax*2 + _connectpoint2]
L1003:
    mov dword ptr [esp + slot_p], eax
    mov edx, dword ptr [esp + slot_p]
    test dx, dx
    {disp32} jge L999
L1004:
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    movsx eax, word ptr [eax + _sprite + 30]
    imul eax, eax, 0x2c
    movsx eax, word ptr [eax + _sprite + 24]
    movsx esi, word ptr [eax*2 + _headspritesect]
L1005:
    test esi, esi
    {disp32} jl L1291
    imul ecx, esi, 0x2c
    mov ax, word ptr [ecx + _sprite + 26]
    movsx edi, word ptr [esi*2 + _nextspritesect]
    .att_syntax prefix
    cmpw $actors_ASM_math_5777,%ax
    .intel_syntax noprefix
    {disp32} jne L1006
    mov eax, OFFSET FLAT:_sprite
    {store} add eax, ecx
    mov dword ptr [esp + slot_enemy_sprite_cursor_713], eax
    call badguy_
    test ax, ax
    {disp32} je L1006
    mov dx, word ptr [ecx + _sprite + 14]
    cmp dx, 1
    je L1006
    cmp dx, 6
    je L1006
    lea ebx, dword ptr [esp + slot_k]
    mov ax, word ptr [ecx + _sprite + 24]
    mov edx, dword ptr [ecx + _sprite + 4]
    mov dword ptr [esp + slot_k], eax
    mov eax, dword ptr [ecx + _sprite]
    call updatesector_
    cmp word ptr [ecx + _sprite + 42], 0
    jl L1006
    mov eax, dword ptr [esp + slot_k]
    cmp ax, word ptr [ebp + 24]
    jne L1006
    mov ebx, 0x18
    mov edx, 0x8ee
    mov eax, dword ptr [esp + slot_enemy_sprite_cursor_713]
    movsx ecx, word ptr [_myconnectindex]
    call gutsdir_
    mov eax, 0x45
    movsx edx, si
    call spritesound_
    {store} mov eax, esi
    call deletesprite_
L1006:
    {store} mov esi, edi
    {disp32} jmp L1005
L1007:
    cmp dword ptr [eax + 16], 0
    jle L1009
    cmp dword ptr [eax], 0
    jne L1009
    mov edx, dword ptr [esp + slot_t]
    movsx eax, word ptr [esp + slot_sh]
    mov esi, dword ptr [edx + 16]
    {store} cmp eax, esi
    jle L1008
    lea edi, dword ptr [esi + 1]
    mov dword ptr [edx + 16], edi
    jmp L1009
L1008:
    mov dword ptr [edx], 1
L1009:
    mov eax, dword ptr [esp + slot_t]
    mov edx, dword ptr [eax]
    test edx, edx
    {disp32} jle L1291
    lea ebx, dword ptr [edx + 1]
    mov dword ptr [eax], ebx
    mov word ptr [ebp + 32], 3
    mov ecx, dword ptr [eax]
    cmp ecx, 0x60
    jle L1010
    mov dword ptr [eax], 0xffffffff
    mov dword ptr [eax + 16], 0xffffffff
    movsx eax, word ptr [esp + slot_i]
    call deletesprite_
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1010:
    {store} mov eax, ecx
    and eax, 0x1f
    cmp eax, 8
    jne L1011
    movsx eax, word ptr [_screenpeek]
    imul eax, eax, 0x552
    mov byte ptr [_earthquaketime], 0x30
    movsx edx, word ptr [eax + _ps + 724]
    mov eax, 0x51
    call spritesound_
L1011:
    mov eax, dword ptr [esp + slot_sc]
    mov edx, dword ptr [esp + slot_t]
    movsx eax, word ptr [eax + 26]
    sub eax, dword ptr [edx + 20]
    test eax, eax
    jns L1012
    neg eax
L1012:
    cmp eax, 8
    jge L1013
    mov ax, word ptr [edx + 20]
    mov edx, dword ptr [esp + slot_sc]
    mov word ptr [edx + 26], ax
    jmp L1014
L1013:
    mov ebx, dword ptr [esp + slot_sc]
    mov eax, dword ptr [edx + 20]
    movsx ebx, word ptr [ebx + 26]
    {store} sub eax, ebx
    {store} mov ebx, eax
    mov edx, dword ptr [esp + slot_sc]
    {store} add ebx, ebx
    {store} sbb eax, eax
    {store} cmp eax, ebx
    adc eax, 0
    shl eax, 4
    add word ptr [edx + 26], ax
L1014:
    movsx eax, word ptr [ebp + 28]
    .att_syntax prefix
    addl $actors_ASM_math_6167,%eax
    .intel_syntax noprefix
    and eax, 0x7ff
    movsx edx, word ptr [eax*2 + _sintable]
    movsx eax, word ptr [ebp + 32]
    imul eax, edx
    sar eax, 0xe
    mov dword ptr [esp + slot_m], eax
    mov ax, word ptr [ebp + 28]
    and ah, 7
    cwde
    movsx edx, word ptr [eax*2 + _sintable]
    movsx eax, word ptr [ebp + 32]
    imul eax, edx
    sar eax, 0xe
    mov dword ptr [esp + slot_x], eax
    mov ax, word ptr [_connecthead]
    jmp L1017
L1015:
    movsx edx, si
    imul edx, edx, 0x552
    mov di, word ptr [ebp + 24]
    cmp di, word ptr [edx + _ps + 646]
    jne L1016
    cmp byte ptr [edx + _ps + 1308], 0
    je L1016
    mov eax, dword ptr [esp + slot_m]
    mov ebx, dword ptr [edx + _ps + 532]
    mov ecx, dword ptr [edx + _ps + 536]
    mov esi, dword ptr [edx + _ps + 560]
    mov edi, dword ptr [edx + _ps + 564]
    {store} add ebx, eax
    mov eax, dword ptr [esp + slot_x]
    mov dword ptr [edx + _ps + 532], ebx
    {store} add ecx, eax
    mov eax, dword ptr [esp + slot_m]
    mov dword ptr [edx + _ps + 536], ecx
    {store} add esi, eax
    mov eax, dword ptr [esp + slot_x]
    mov dword ptr [edx + _ps + 560], esi
    {store} add edi, eax
    mov dword ptr [edx + _ps + 564], edi
L1016:
    movsx eax, word ptr [esp + slot_p]
    mov ax, word ptr [eax*2 + _connectpoint2]
L1017:
    mov dword ptr [esp + slot_p], eax
    mov esi, dword ptr [esp + slot_p]
    test si, si
    jge L1015
    movsx eax, word ptr [ebp + 24]
    movsx esi, word ptr [eax*2 + _headspritesect]
L1018:
    test esi, esi
    {disp32} jl L1226
    imul edx, esi, 0x2c
    mov ax, word ptr [esi*2 + _nextspritesect]
    mov dword ptr [esp + slot_nextj], eax
    cmp word ptr [edx + _sprite + 14], 1
    je L1019
    mov eax, dword ptr [esp + slot_m]
    mov ebx, dword ptr [edx + _sprite]
    mov ecx, dword ptr [edx + _sprite + 4]
    {store} add ebx, eax
    mov eax, dword ptr [esp + slot_x]
    mov dword ptr [edx + _sprite], ebx
    {store} add ecx, eax
    mov dword ptr [edx + _sprite + 4], ecx
    {store} mov eax, esi
    mov ecx, dword ptr [edx + _sprite + 8]
    mov ebx, dword ptr [edx + _sprite + 4]
    mov edx, dword ptr [edx + _sprite]
    call setsprite_
L1019:
    movsx esi, word ptr [esp + slot_nextj]
    jmp L1018
L1020:
    cmp dword ptr [eax + 16], 0
    {disp32} je L1291
    {store} mov edx, esp
    {store} mov eax, ebp
    call findplayer_
    movsx eax, word ptr [esp + slot_sh]
    movsx edx, word ptr [_global_random]
    lea ebx, dword ptr [eax + 1]
    {store} mov eax, edx
    sar edx, 0x1f
    idiv ebx
    and eax, 0x1f
    cmp eax, 4
    jge L1021
    mov eax, dword ptr [esp + slot_t]
    cmp dword ptr [eax + 8], 0
    jne L1021
    movsx eax, word ptr [ebp + 30]
    mov edx, dword ptr [esp + slot_sc]
    sar eax, 8
    mov byte ptr [edx + 21], al
    mov al, byte ptr [ebp + 30]
    mov byte ptr [edx + 29], al
    mov ax, word ptr [_global_random]
    xor ah, ah
    and al, 0xf
    movsx edx, byte ptr [ebp + 16]
    cwde
    {store} add edx, eax
    mov eax, dword ptr [esp + slot_t]
    mov dword ptr [eax], edx
    jmp L1022
L1021:
    mov edx, dword ptr [esp + slot_sc]
    mov al, byte ptr [ebp + 17]
    mov byte ptr [edx + 21], al
    mov byte ptr [edx + 29], al
    mov eax, dword ptr [esp + slot_t]
    mov edx, dword ptr [esp + slot_t]
    mov eax, dword ptr [eax + 12]
    mov dword ptr [edx], eax
L1022:
    mov eax, dword ptr [esp + slot_t]
    mov edx, dword ptr [esp + slot_sc]
    mov al, byte ptr [eax]
    mov byte ptr [edx + 20], al
    mov eax, dword ptr [esp + slot_t]
    mov al, byte ptr [eax]
    mov byte ptr [edx + 28], al
    movsx eax, word ptr [edx]
    mov edx, OFFSET FLAT:_wall
    shl eax, 5
    {store} add edx, eax
    mov eax, dword ptr [esp + slot_sc]
    movsx eax, word ptr [eax + 2]
    mov dword ptr [esp + slot_x], eax
    cmp dword ptr [esp + slot_x], 0
    jg L1023
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1023:
    cmp word ptr [edx + 28], 1
    je L1024
    mov eax, dword ptr [esp + slot_t]
    mov al, byte ptr [eax]
    mov ch, byte ptr [edx + 14]
    mov byte ptr [edx + 20], al
    test ch, 2
    je L1024
    mov cx, word ptr [edx + 10]
    test cx, cx
    jl L1024
    movsx eax, cx
    shl eax, 5
    mov bl, byte ptr [edx + 20]
    mov byte ptr [eax + _wall + 20], bl
L1024:
    mov edi, dword ptr [esp + slot_x]
    dec edi
    add edx, 0x20
    mov dword ptr [esp + slot_x], edi
    cmp dword ptr [esp + slot_x], 0
    jg L1023
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1025:
    movsx ebx, word ptr [esp + slot_sh]
    movsx edx, word ptr [_global_random]
    inc ebx
    {store} mov eax, edx
    sar edx, 0x1f
    idiv ebx
    and eax, 0x1f
    cmp eax, 4
    jge L1026
    mov ax, word ptr [_global_random]
    xor ah, ah
    and al, 0xf
    movsx edx, byte ptr [ebp + 16]
    cwde
    {store} add edx, eax
    mov eax, dword ptr [esp + slot_t]
    mov dword ptr [eax + 4], edx
    mov ax, word ptr [_global_random]
    xor ah, ah
    and al, 0xf
    movsx edx, byte ptr [ebp + 16]
    cwde
    {store} add edx, eax
    mov eax, dword ptr [esp + slot_t]
    mov dword ptr [eax], edx
    movsx eax, word ptr [ebp + 30]
    mov edx, dword ptr [esp + slot_sc]
    sar eax, 8
    mov byte ptr [edx + 21], al
    mov al, byte ptr [ebp + 30]
    mov esi, 1
    jmp L1027
L1026:
    mov eax, dword ptr [esp + slot_t]
    mov edx, dword ptr [esp + slot_t]
    mov eax, dword ptr [eax + 8]
    mov dword ptr [edx + 4], eax
    mov eax, dword ptr [edx + 12]
    mov dword ptr [edx], eax
    mov edx, dword ptr [esp + slot_sc]
    mov al, byte ptr [ebp + 17]
    mov byte ptr [edx + 21], al
    {store} xor esi, esi
L1027:
    mov byte ptr [edx + 29], al
    mov eax, dword ptr [esp + slot_t]
    mov edx, dword ptr [esp + slot_sc]
    mov al, byte ptr [eax + 4]
    mov byte ptr [edx + 28], al
    mov eax, dword ptr [esp + slot_t]
    mov al, byte ptr [eax + 4]
    mov byte ptr [edx + 20], al
    movsx eax, word ptr [edx]
    mov edx, OFFSET FLAT:_wall
    shl eax, 5
    {store} add edx, eax
    mov eax, dword ptr [esp + slot_sc]
    movsx eax, word ptr [eax + 2]
    mov dword ptr [esp + slot_x], eax
    jmp L1032
L1028:
    test esi, esi
    je L1029
    mov al, byte ptr [ebp + 30]
    jmp L1030
L1029:
    mov al, byte ptr [ebp + 17]
L1030:
    mov byte ptr [edx + 21], al
    cmp word ptr [edx + 28], 1
    je L1031
    mov eax, dword ptr [esp + slot_t]
    mov al, byte ptr [eax]
    mov bl, byte ptr [edx + 14]
    mov byte ptr [edx + 20], al
    test bl, 2
    je L1031
    mov ax, word ptr [edx + 10]
    test ax, ax
    jl L1031
    movsx ebx, ax
    shl ebx, 5
    mov al, byte ptr [edx + 20]
    mov byte ptr [ebx + _wall + 20], al
L1031:
    mov ebx, dword ptr [esp + slot_x]
    dec ebx
    add edx, 0x20
    mov dword ptr [esp + slot_x], ebx
L1032:
    cmp dword ptr [esp + slot_x], 0
    jg L1028
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    movsx eax, word ptr [eax + _sprite + 24]
    movsx esi, word ptr [eax*2 + _headspritesect]
L1033:
    test esi, esi
    jl L1037
    imul eax, esi, 0x2c
    test byte ptr [eax + _sprite + 12], 0x10
    je L1036
    mov edx, dword ptr [esp + slot_sc]
    test byte ptr [edx + 12], 1
    je L1034
    mov dl, byte ptr [edx + 20]
    jmp L1035
L1034:
    mov dl, byte ptr [edx + 28]
L1035:
    mov byte ptr [eax + _sprite + 16], dl
L1036:
    movsx esi, word ptr [esi*2 + _nextspritesect]
    jmp L1033
L1037:
    mov eax, dword ptr [esp + slot_t]
    cmp dword ptr [eax + 16], 0
    {disp32} je L1291
    movsx eax, word ptr [esp + slot_i]
    call deletesprite_
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1038:
    {store} mov edx, esp
    {store} mov eax, ebp
    call findplayer_
    mov ecx, dword ptr [esp + slot_x]
    mov dword ptr [esp + slot_p], eax
    cmp ecx, 0x2000
    jge L1039
    cwde
    imul edx, eax, 0x552
    mov eax, dword ptr [ebp + 4]
    mov edi, dword ptr [edx + _ps + 536]
    {store} mov edx, eax
    movsx eax, word ptr [esp + slot_p]
    imul ebx, eax, 0x552
    {disp8} mov eax, dword ptr [ebp]
    mov ecx, dword ptr [ebx + _ps + 532]
    {store} sub edx, edi
    {store} sub eax, ecx
    movsx esi, word ptr [ebp + 28]
    call getangle_
    mov edx, 0x659
    mov word ptr [ebp + 28], ax
    movsx eax, word ptr [esp + slot_i]
    call shoot_
    mov word ptr [ebp + 28], si
L1039:
    movsx eax, word ptr [ebp + 30]
    cmp eax, -1
    {disp32} jne L1043
    mov eax, dword ptr [esp + slot_t]
    mov edi, 0x7fffffff
    mov dword ptr [eax + 16], 0
L1040:
    mov eax, dword ptr [esp + slot_t]
    mov edx, 0xffffffff
    movsx eax, word ptr [eax + 16]
    call LocateTheLocator_
    mov word ptr [ebp + 30], ax
    cwde
    cmp eax, -1
    je L1042
    imul eax, eax, 0x2c
    mov edx, OFFSET FLAT:_sprite
    {store} add edx, eax
    movsx eax, word ptr [esp + slot_p]
    imul eax, eax, 0x552
    movsx eax, word ptr [eax + _ps + 724]
    imul eax, eax, 0x2c
    add eax, OFFSET FLAT:_sprite
    call ldist_
    mov dword ptr [esp + slot_m], eax
    {store} cmp edi, eax
    jle L1041
    movsx edx, word ptr [ebp + 30]
    {store} mov edi, eax
    mov dword ptr [esp + slot_q], edx
L1041:
    mov eax, dword ptr [esp + slot_t]
    inc dword ptr [eax + 16]
    jmp L1040
L1042:
    imul ebx, dword ptr [esp + slot_q], 0x2c
    mov eax, dword ptr [esp + slot_q]
    mov word ptr [ebp + 30], ax
    mov edi, dword ptr [ebp + 8]
    mov ebx, dword ptr [ebx + _sprite + 8]
    {store} sub ebx, edi
    {store} add ebx, ebx
    {store} sbb eax, eax
    {store} cmp eax, ebx
    adc al, 0
    shl eax, 4
    mov word ptr [ebp + 36], ax
L1043:
    movsx eax, word ptr [ebp + 30]
    imul eax, eax, 0x2c
    {store} mov edx, ebp
    add eax, OFFSET FLAT:_sprite
    call ldist_
    .att_syntax prefix
    cmpl $actors_ASM_math_7388,%eax
    .intel_syntax noprefix
    jge L1044
    movsx edx, word ptr [esp + slot_p]
    imul edx, edx, 0x552
    mov esi, dword ptr [ebp + 4]
    {disp8} mov edi, dword ptr [ebp]
    mov ebx, dword ptr [edx + _ps + 536]
    mov eax, dword ptr [edx + _ps + 532]
    {store} sub ebx, esi
    {store} sub eax, edi
    {store} mov edx, ebx
    mov cx, word ptr [ebp + 28]
    call getangle_
    mov word ptr [ebp + 30], 0xffff
    mov word ptr [ebp + 28], cx
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1044:
    movsx edx, word ptr [ebp + 30]
    imul edx, edx, 0x2c
    mov word ptr [ebp + 32], 0x100
    mov ebx, dword ptr [ebp + 4]
    mov eax, dword ptr [edx + _sprite + 4]
    {store} sub eax, ebx
    {disp8} mov ecx, dword ptr [ebp]
    {store} mov ebx, eax
    mov eax, dword ptr [edx + _sprite]
    {store} mov edx, ebx
    {store} sub eax, ecx
    call getangle_
    mov dword ptr [esp + slot_x], eax
    movsx edx, word ptr [esp + slot_x]
    movsx eax, word ptr [ebp + 28]
    call getincangle_
    cwde
    sar eax, 3
    mov dword ptr [esp + slot_q], eax
    mov si, word ptr [ebp + 28]
    mov eax, dword ptr [esp + slot_q]
    {store} add esi, eax
    mov word ptr [ebp + 28], si
    call krand_
    sar eax, 8
    .att_syntax prefix
    cmpl $actors_ASM_math_7548,%eax
    .intel_syntax noprefix
    jl L1045
    mov edx, dword ptr [esp + slot_t]
    mov eax, dword ptr [esp + slot_q]
    mov ecx, dword ptr [edx + 8]
    {store} add ecx, eax
    mov eax, dword ptr [esp + slot_sc]
    mov dword ptr [edx + 8], ecx
    mov byte ptr [eax + 20], 0x7f
    jmp L1046
L1045:
    movsx ebx, word ptr [esp + slot_p]
    imul ebx, ebx, 0x552
    mov esi, dword ptr [ebp + 4]
    {disp8} mov edi, dword ptr [ebp]
    mov edx, dword ptr [ebx + _ps + 536]
    mov eax, dword ptr [ebx + _ps + 532]
    {store} sub edx, esi
    {store} sub eax, edi
    call getangle_
    movsx edx, ax
    mov eax, dword ptr [esp + slot_t]
    mov ax, word ptr [eax + 8]
    add ah, 2
    cwde
    call getincangle_
    cwde
    mov edx, dword ptr [esp + slot_t]
    sar eax, 2
    mov ebx, dword ptr [edx + 8]
    {store} add ebx, eax
    mov eax, dword ptr [esp + slot_sc]
    mov dword ptr [edx + 8], ebx
    mov byte ptr [eax + 20], 0
L1046:
    movsx eax, word ptr [esp + slot_i]
    call ifhitbyweapon_
    movsx esi, ax
    test esi, esi
    jl L1047
    mov eax, dword ptr [esp + slot_t]
    mov esi, dword ptr [eax + 12]
    inc esi
    mov dword ptr [eax + 12], esi
    cmp esi, 5
    jne L1047
    add byte ptr [ebp + 37], 4
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov edx, OFFSET FLAT:_ps
    {store} add edx, eax
    mov eax, 7
    call FTA_
L1047:
    movsx eax, word ptr [ebp + 36]
    add dword ptr [ebp + 8], eax
    mov edx, dword ptr [esp + slot_sc]
    movsx eax, word ptr [ebp + 36]
    add dword ptr [edx + 4], eax
    mov edx, dword ptr [esp + slot_t]
    mov edx, dword ptr [edx]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    movsx edx, word ptr [ebp + 36]
    mov ecx, dword ptr [eax*8 + _sector + 4]
    {store} add ecx, edx
    movsx esi, word ptr [esp + slot_i]
    mov dword ptr [eax*8 + _sector + 4], ecx
    {store} mov eax, esi
    call ms_
    {store} mov eax, esi
    mov ecx, dword ptr [ebp + 8]
    mov ebx, dword ptr [ebp + 4]
    {disp8} mov edx, dword ptr [ebp]
    call setsprite_
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1048:
    movsx edx, word ptr [esp + slot_i]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    cmp dword ptr [eax + _hittype + 63], 0
    je L1050
    movsx edx, word ptr [esp + slot_i]
    {disp32} lea ebx, dword ptr [edx*8]
    {store} add ebx, edx
    {disp32} lea ebx, dword ptr [ebx*8]
    {store} sub ebx, edx
    movsx edx, word ptr [esp + slot_i]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    inc dword ptr [ebx + _hittype + 63]
    cmp dword ptr [eax + _hittype + 63], 8
    jle L1049
    movsx eax, word ptr [esp + slot_i]
    call deletesprite_
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1049:
    mov esi, 1
    jmp L1051
L1050:
    mov eax, dword ptr [esp + slot_sc]
    add eax, 4
    call getanimationgoal_
    {store} mov esi, eax
L1051:
    test esi, esi
    {disp32} jl L1291
    mov eax, dword ptr [esp + slot_sc]
    movsx eax, word ptr [eax + 34]
    test ah, 0x80
    jne L1052
    movsx edx, word ptr [esp + slot_i]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    cmp dword ptr [eax + _hittype + 63], 0
    je L1053
L1052:
    mov eax, dword ptr [esp + slot_t]
    mov eax, dword ptr [eax + 12]
    neg eax
    jmp L1054
L1053:
    mov eax, dword ptr [esp + slot_t]
    mov eax, dword ptr [eax + 12]
L1054:
    mov dword ptr [esp + slot_x], eax
    cmp dword ptr [esp + slot_st], 9
    jne L1055
    neg dword ptr [esp + slot_x]
L1055:
    movsx esi, word ptr [_headspritestat + 6]
L1056:
    test esi, esi
    {disp32} jl L1291
    imul eax, esi, 0x2c
    mov ebp, dword ptr [esp + slot_st]
    movsx edx, word ptr [eax + _sprite + 38]
    {store} cmp edx, ebp
    {disp32} jne L1068
    mov edi, dword ptr [esp + slot_sh]
    cmp di, word ptr [eax + _sprite + 40]
    {disp32} jne L1068
    mov cx, word ptr [eax + _sprite + 24]
    movsx eax, byte ptr [eax + _sprite + 16]
    movsx edx, cx
    mov dword ptr [esp + slot_m], eax
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    movsx edx, word ptr [eax*8 + _sector]
    shl edx, 5
    movsx edi, word ptr [eax*8 + _sector + 2]
    add edx, OFFSET FLAT:_wall
    jmp L1062
L1057:
    cmp word ptr [edx + 28], 1
    je L1061
    mov al, byte ptr [esp + slot_x]
    mov bl, byte ptr [edx + 20]
    add bl, al
    mov byte ptr [edx + 20], bl
    movsx eax, bl
    cmp eax, dword ptr [esp + slot_m]
    jge L1058
    mov al, byte ptr [esp + slot_m]
    jmp L1059
L1058:
    cmp eax, dword ptr [ebp + _hittype + 55]
    jle L1060
    mov al, byte ptr [ebp + _hittype + 55]
L1059:
    mov byte ptr [edx + 20], al
L1060:
    mov bx, word ptr [edx + 10]
    test bx, bx
    jl L1061
    movsx eax, bx
    shl eax, 5
    cmp word ptr [eax + _wall + 28], 1
    je L1061
    mov bl, byte ptr [edx + 20]
    mov byte ptr [eax + _wall + 20], bl
L1061:
    dec edi
    add edx, 0x20
L1062:
    {disp32} lea ebp, dword ptr [esi*8]
    {store} add ebp, esi
    {disp32} lea ebp, dword ptr [ebp*8]
    {store} sub ebp, esi
    test edi, edi
    jg L1057
    movsx edx, cx
    {disp32} lea eax, dword ptr [edx*4]
    {store} add edx, eax
    {disp32} lea edx, dword ptr [edx*8]
    mov al, byte ptr [esp + slot_x]
    mov bh, byte ptr [edx + _sector + 28]
    add bh, al
    mov ah, byte ptr [edx + _sector + 20]
    mov byte ptr [edx + _sector + 28], bh
    add ah, al
    mov byte ptr [edx + _sector + 20], ah
    mov ebx, dword ptr [esp + slot_m]
    movsx eax, byte ptr [edx + _sector + 28]
    {store} cmp eax, ebx
    jge L1063
    mov al, byte ptr [esp + slot_m]
    jmp L1064
L1063:
    cmp eax, dword ptr [ebp + _hittype + 47]
    jle L1065
    mov al, byte ptr [ebp + _hittype + 47]
L1064:
    mov byte ptr [edx + _sector + 28], al
L1065:
    movsx edx, cx
    {disp32} lea eax, dword ptr [edx*4]
    {store} add edx, eax
    {disp32} lea edx, dword ptr [edx*8]
    mov ebp, dword ptr [esp + slot_m]
    movsx ebx, byte ptr [edx + _sector + 20]
    {store} cmp ebx, ebp
    jge L1066
    mov al, byte ptr [esp + slot_m]
    jmp L1067
L1066:
    {disp32} lea eax, dword ptr [esi*8]
    {store} add eax, esi
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, esi
    cmp ebx, dword ptr [eax + _hittype + 51]
    jle L1068
    mov al, byte ptr [eax + _hittype + 51]
L1067:
    mov byte ptr [edx + _sector + 20], al
L1068:
    movsx esi, word ptr [esi*2 + _nextspritestat]
    {disp32} jmp L1056
L1069:
    mov ax, word ptr [edx + 34]
    xor ah, ah
    .att_syntax prefix
    cmpw $actors_ASM_math_8446,%ax
    .intel_syntax noprefix
    je L1071
    mov eax, dword ptr [edx + 8]
    cmp eax, dword ptr [edx + 4]
    jle L1070
    mov ax, word ptr [edx + 34]
    xor ah, ah
    .att_syntax prefix
    cmpw $actors_ASM_math_8466,%ax
    .intel_syntax noprefix
    jne L1071
L1070:
    mov eax, dword ptr [esp + slot_sc]
    cmp word ptr [eax + 34], 0x8017
    {disp32} jne L1076
L1071:
    mov eax, dword ptr [esp + slot_sc]
    mov ax, word ptr [eax + 34]
    xor ah, ah
    mov esi, 1
    .att_syntax prefix
    cmpw $actors_ASM_math_8503,%ax
    .intel_syntax noprefix
    je L1075
    mov ax, word ptr [_connecthead]
    jmp L1074
L1072:
    mov eax, dword ptr [esp + slot_sc]
    mov dx, word ptr [eax + 34]
    cmp dx, 0x1e
    je L1073
    cmp dx, 0x1f
    je L1073
    test dx, dx
    je L1073
    movsx eax, di
    imul eax, eax, 0x552
    movsx eax, word ptr [eax + _ps + 724]
    imul edx, eax, 0x2c
    mov ax, word ptr [ebp + 24]
    cmp ax, word ptr [edx + _sprite + 24]
    jne L1073
    {store} xor esi, esi
L1073:
    movsx eax, word ptr [esp + slot_p]
    mov ax, word ptr [eax*2 + _connectpoint2]
L1074:
    mov dword ptr [esp + slot_p], eax
    mov edi, dword ptr [esp + slot_p]
    test di, di
    jge L1072
L1075:
    cmp esi, 1
    {disp32} jne L1291
    mov edx, dword ptr [esp + slot_t]
    movsx eax, word ptr [esp + slot_sh]
    mov edi, dword ptr [edx]
    {store} cmp eax, edi
    jge L1077
    movsx edx, word ptr [esp + slot_i]
    movsx eax, word ptr [ebp + 24]
    call activatebysector_
L1076:
    mov eax, dword ptr [esp + slot_t]
    mov dword ptr [eax], 0
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1077:
    lea ebp, dword ptr [edi + esi]
    mov dword ptr [edx], ebp
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1078:
    mov ebx, dword ptr [eax + 20]
    test ebx, ebx
    jle L1079
    lea esi, dword ptr [ebx + -1]
    mov dword ptr [eax + 20], esi
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1079:
    cmp dword ptr [eax + 16], 0
    {disp32} je L1291
    mov ax, word ptr [edx]
    mov di, word ptr [edx + 2]
    movsx esi, ax
    {store} add edi, eax
    {disp32} jmp L1087
L1080:
    mov ax, word ptr [_headspritestat + 2]
L1081:
    mov dword ptr [esp + slot_k], eax
    mov ecx, dword ptr [esp + slot_k]
    test cx, cx
    jl L1083
    movsx eax, cx
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 42], 0
    jle L1082
    add eax, OFFSET FLAT:_sprite
    call badguy_
    test ax, ax
    je L1082
    movsx eax, word ptr [esp + slot_k]
    imul eax, eax, 0x2c
    mov ecx, 0x100
    {store} mov ebx, esi
    mov edx, dword ptr [eax + _sprite + 4]
    mov eax, dword ptr [eax + _sprite]
    call clipinsidebox_
    cmp eax, 1
    {disp32} je L1291
L1082:
    movsx eax, word ptr [esp + slot_k]
    mov ax, word ptr [eax*2 + _nextspritestat]
    jmp L1081
L1083:
    mov ax, word ptr [_headspritestat + 20]
L1084:
    mov dword ptr [esp + slot_k], eax
    mov ebx, dword ptr [esp + slot_k]
    test bx, bx
    {disp32} jl L1086
    movsx eax, bx
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 30], 0
    jl L1085
    mov ecx, 0x90
    {store} mov ebx, esi
    mov edx, dword ptr [eax + _sprite + 4]
    mov eax, dword ptr [eax + _sprite]
    call clipinsidebox_
    cmp eax, 1
    jne L1085
    mov eax, dword ptr [esp + slot_t]
    movsx esi, word ptr [esp + slot_i]
    mov dword ptr [eax + 20], 8
    imul eax, esi, 0x2c
    mov edx, dword ptr [esp + slot_t]
    movsx eax, word ptr [eax + _sprite + 34]
    mov ebx, dword ptr [edx + 12]
    sar eax, 3
    imul eax, ebx
    mov dword ptr [esp + slot_k], eax
    cwde
    sub dword ptr [edx + 8], eax
    mov edi, dword ptr [edx + 16]
    movsx eax, word ptr [esp + slot_k]
    {store} sub edi, eax
    {store} mov eax, esi
    mov dword ptr [edx + 16], edi
    call ms_
    {store} mov eax, esi
    mov ecx, dword ptr [ebp + 8]
    mov ebx, dword ptr [ebp + 4]
    {disp8} mov edx, dword ptr [ebp]
    call setsprite_
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1085:
    movsx eax, word ptr [esp + slot_k]
    mov ax, word ptr [eax*2 + _nextspritestat]
    {disp32} jmp L1084
L1086:
    inc esi
L1087:
    movsx eax, di
    {store} cmp esi, eax
    {disp32} jl L1080
    movsx esi, word ptr [esp + slot_i]
    imul eax, esi, 0x2c
    mov edx, dword ptr [esp + slot_t]
    movsx eax, word ptr [eax + _sprite + 34]
    mov edi, dword ptr [edx + 12]
    sar eax, 3
    imul eax, edi
    mov dword ptr [esp + slot_k], eax
    cwde
    add dword ptr [edx + 8], eax
    mov ecx, dword ptr [edx + 16]
    movsx eax, word ptr [esp + slot_k]
    {store} add ecx, eax
    {store} mov eax, esi
    mov dword ptr [edx + 16], ecx
    call ms_
    {store} mov eax, esi
    mov ecx, dword ptr [ebp + 8]
    mov ebx, dword ptr [ebp + 4]
    {disp8} mov edx, dword ptr [ebp]
    call setsprite_
    mov eax, dword ptr [esp + slot_t]
    mov esi, dword ptr [eax + 16]
    cmp esi, 0xfffffe01
    jle L1088
    cmp esi, 0x200
    {disp32} jl L1291
L1088:
    mov eax, dword ptr [esp + slot_t]
    mov dword ptr [eax + 16], 0
    movsx esi, word ptr [esp + slot_i]
    mov byte ptr [eax + 8], 0
    {store} mov eax, esi
    call ms_
    {store} mov eax, esi
    mov ecx, dword ptr [ebp + 8]
    mov ebx, dword ptr [ebp + 4]
    {disp8} mov edx, dword ptr [ebp]
    call setsprite_
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1089:
    cmp dword ptr [eax], 3
    je L1090
    cmp dword ptr [eax + 12], 1
    {disp32} jne L1099
L1090:
    mov eax, dword ptr [esp + slot_sc]
    mov byte ptr [eax + 29], 0
    mov byte ptr [eax + 21], 0
    mov edx, OFFSET FLAT:_wall
    movsx eax, word ptr [eax]
    mov esi, dword ptr [esp + slot_sc]
    shl eax, 5
    movsx esi, word ptr [esi + 2]
    {store} add edx, eax
    jmp L1093
L1091:
    cmp word ptr [edx + 28], 1
    je L1092
    mov eax, dword ptr [esp + slot_t]
    mov al, byte ptr [eax + 4]
    mov byte ptr [edx + 21], 0
    mov byte ptr [edx + 20], al
L1092:
    dec esi
    add edx, 0x20
L1093:
    test esi, esi
    jg L1091
    mov eax, dword ptr [esp + slot_t]
    mov edx, dword ptr [esp + slot_sc]
    mov al, byte ptr [eax + 4]
    mov byte ptr [edx + 28], al
    mov eax, dword ptr [esp + slot_t]
    mov al, byte ptr [eax + 8]
    mov byte ptr [edx + 20], al
    mov eax, dword ptr [esp + slot_t]
    mov dword ptr [eax], 0
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    movsx esi, word ptr [eax + _sprite + 24]
    movsx esi, word ptr [esi*2 + _headspritesect]
L1094:
    test esi, esi
    jl L1098
    imul eax, esi, 0x2c
    test byte ptr [eax + _sprite + 12], 0x10
    je L1097
    mov edx, dword ptr [esp + slot_sc]
    test byte ptr [edx + 12], 1
    je L1095
    mov dl, byte ptr [edx + 20]
    jmp L1096
L1095:
    mov dl, byte ptr [edx + 28]
L1096:
    mov byte ptr [eax + _sprite + 16], dl
L1097:
    movsx esi, word ptr [esi*2 + _nextspritesect]
    jmp L1094
L1098:
    mov eax, dword ptr [esp + slot_t]
    cmp dword ptr [eax + 12], 1
    jne L1099
    movsx eax, word ptr [esp + slot_i]
    call deletesprite_
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1099:
    mov eax, dword ptr [esp + slot_t]
    cmp dword ptr [eax], 1
    {disp32} jne L1291
    mov eax, dword ptr [esp + slot_sc]
    mov al, byte ptr [eax + 28]
    cmp al, byte ptr [ebp + 16]
    jle L1103
    mov edx, dword ptr [esp + slot_sc]
    mov al, byte ptr [ebp + 17]
    mov byte ptr [edx + 29], al
    mov byte ptr [edx + 21], al
    {store} mov eax, edx
    mov dl, byte ptr [edx + 28]
    sub dl, 2
    mov byte ptr [eax + 28], dl
    sub byte ptr [eax + 20], 2
    mov esi, dword ptr [esp + slot_sc]
    movsx eax, word ptr [eax]
    mov edx, OFFSET FLAT:_wall
    shl eax, 5
    movsx esi, word ptr [esi + 2]
    {store} add edx, eax
    jmp L1102
L1100:
    cmp word ptr [edx + 28], 1
    je L1101
    mov bl, byte ptr [edx + 20]
    mov al, byte ptr [ebp + 17]
    sub bl, 2
    mov byte ptr [edx + 21], al
    mov byte ptr [edx + 20], bl
L1101:
    dec esi
    add edx, 0x20
L1102:
    test esi, esi
    jg L1100
    jmp L1104
L1103:
    mov eax, dword ptr [esp + slot_t]
    mov dword ptr [eax], 2
L1104:
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    movsx eax, word ptr [eax + _sprite + 24]
    movsx esi, word ptr [eax*2 + _headspritesect]
L1105:
    test esi, esi
    {disp32} jl L1291
    imul eax, esi, 0x2c
    test byte ptr [eax + _sprite + 12], 0x10
    je L1108
    mov edx, dword ptr [esp + slot_sc]
    test byte ptr [edx + 12], 1
    je L1106
    mov dl, byte ptr [edx + 20]
    jmp L1107
L1106:
    mov dl, byte ptr [edx + 28]
L1107:
    mov byte ptr [eax + _sprite + 16], dl
L1108:
    movsx esi, word ptr [esi*2 + _nextspritesect]
    jmp L1105
L1109:
    cmp dword ptr [eax + 8], 0
    {disp32} je L1126
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    movsx eax, word ptr [eax + _sprite + 34]
    shl eax, 5
    or al, 1
    mov di, word ptr [ebp + 28]
    {store} mov esi, eax
    cmp di, 0x200
    {disp32} jne L1115
    cmp word ptr [ebp + 30], 0
    je L1112
    mov eax, dword ptr [esp + slot_t]
    mov ecx, dword ptr [edx + 4]
    mov eax, dword ptr [eax]
    {store} sub eax, ecx
    test eax, eax
    jns L1110
    neg eax
L1110:
    {store} cmp eax, esi
    jl L1111
    mov ebx, dword ptr [esp + slot_t]
    mov edi, dword ptr [edx + 4]
    mov ebx, dword ptr [ebx]
    {store} sub ebx, edi
    {store} add ebx, ebx
    {store} sbb eax, eax
    {store} cmp eax, ebx
    adc eax, 0
    imul eax, esi
    add dword ptr [edx + 4], eax
    {disp32} jmp L1122
L1111:
    mov eax, dword ptr [esp + slot_t]
    {disp32} jmp L1121
L1112:
    mov eax, dword ptr [esp + slot_t]
    mov ecx, dword ptr [edx + 8]
    mov eax, dword ptr [eax + 4]
    {store} sub eax, ecx
    test eax, eax
    jns L1113
    neg eax
L1113:
    {store} cmp eax, esi
    jl L1114
    mov ebx, dword ptr [esp + slot_t]
    mov edi, dword ptr [edx + 8]
    mov ebx, dword ptr [ebx + 4]
    {store} sub ebx, edi
    {store} add ebx, ebx
    {store} sbb eax, eax
    {store} cmp eax, ebx
    adc eax, 0
    imul eax, esi
    add dword ptr [edx + 8], eax
    {disp32} jmp L1122
L1114:
    mov eax, dword ptr [esp + slot_t]
    mov eax, dword ptr [eax + 4]
    mov dword ptr [edx + 8], eax
    {disp32} jmp L1122
L1115:
    mov eax, dword ptr [esp + slot_t]
    mov ecx, dword ptr [edx + 8]
    mov eax, dword ptr [eax + 4]
    {store} sub eax, ecx
    test eax, eax
    jns L1116
    neg eax
L1116:
    {store} cmp eax, esi
    jl L1117
    mov ebx, dword ptr [esp + slot_t]
    mov edi, dword ptr [edx + 8]
    mov ebx, dword ptr [ebx + 4]
    {store} sub ebx, edi
    {store} add ebx, ebx
    {store} sbb eax, eax
    {store} cmp eax, ebx
    adc eax, 0
    imul eax, esi
    add dword ptr [edx + 8], eax
    jmp L1118
L1117:
    mov eax, dword ptr [esp + slot_t]
    mov eax, dword ptr [eax + 4]
    mov dword ptr [edx + 8], eax
L1118:
    mov eax, dword ptr [esp + slot_t]
    mov edx, dword ptr [esp + slot_sc]
    mov eax, dword ptr [eax]
    sub eax, dword ptr [edx + 4]
    test eax, eax
    jns L1119
    neg eax
L1119:
    {store} cmp eax, esi
    jl L1120
    mov ebx, dword ptr [esp + slot_t]
    mov edi, dword ptr [edx + 4]
    mov ebx, dword ptr [ebx]
    {store} sub ebx, edi
    {store} add ebx, ebx
    {store} sbb eax, eax
    {store} cmp eax, ebx
    adc eax, 0
    imul eax, esi
    add dword ptr [edx + 4], eax
L1120:
    mov eax, dword ptr [esp + slot_t]
    mov edx, dword ptr [esp + slot_sc]
L1121:
    mov eax, dword ptr [eax]
    mov dword ptr [edx + 4], eax
L1122:
    mov eax, dword ptr [esp + slot_t]
    mov ecx, dword ptr [eax + 12]
    cmp ecx, 1
    {disp32} jne L1125
    lea esi, dword ptr [ecx + ecx]
    mov dword ptr [eax + 12], esi
    mov eax, dword ptr [esp + slot_sc]
    xor byte ptr [eax + 12], 1
    cmp word ptr [ebp + 28], 0x200
    {disp32} jne L1125
    mov edx, OFFSET FLAT:_wall
    movsx eax, word ptr [eax]
    mov esi, dword ptr [esp + slot_sc]
    shl eax, 5
    movsx esi, word ptr [esi + 2]
    {store} add edx, eax
    jmp L1124
L1123:
    add edx, 0x20
    mov al, byte ptr [ebp + 16]
    dec esi
    mov byte ptr [edx + -12], al
L1124:
    test esi, esi
    jg L1123
    mov edx, dword ptr [esp + slot_sc]
    mov al, byte ptr [ebp + 16]
    mov byte ptr [edx + 28], al
    mov ax, word ptr [_ps + 726]
    test ax, ax
    jl L1125
    movsx edx, ax
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov edx, dword ptr [esp + slot_sc]
    mov ax, word ptr [eax*8 + _sector + 16]
    mov word ptr [edx + 16], ax
    movsx edx, word ptr [_ps + 726]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov edx, dword ptr [esp + slot_sc]
    mov al, byte ptr [eax*8 + _sector + 20]
    mov byte ptr [edx + 20], al
L1125:
    mov eax, dword ptr [esp + slot_t]
    mov ecx, dword ptr [eax + 8]
    inc ecx
    mov dword ptr [eax + 8], ecx
    cmp ecx, 0x100
    jle L1126
    movsx eax, word ptr [esp + slot_i]
    call deletesprite_
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1126:
    mov eax, dword ptr [esp + slot_t]
    cmp dword ptr [eax + 8], 4
    {disp32} jne L1291
    cmp word ptr [ebp + 28], 0x200
    {disp32} je L1291
    {store} xor eax, eax
    mov dword ptr [esp + slot_x], eax
    cmp dword ptr [esp + slot_x], 7
    jl L1127
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1127:
    push 5
    movsx eax, word ptr [esp + slot_i+4]
    push eax
    mov edx, 0xfffffe00
    call krand_
    and eax, 0x7ff
    {store} sub edx, eax
    push edx
    call krand_
    xor ah, ah
    and al, 0x3f
    .att_syntax prefix
    addl $actors_ASM_math_10163,%eax
    .intel_syntax noprefix
    cwde
    push eax
    call krand_
    and ah, 7
    cwde
    push eax
    push 0x30
    push 0x30
    push -8
    call krand_
    xor ah, ah
    mov ecx, dword ptr [ebp + 8]
    and al, 0xf
    mov ebx, dword ptr [ebp + 4]
    .att_syntax prefix
    addl $actors_ASM_math_10201,%eax
    .intel_syntax noprefix
    {disp8} mov edx, dword ptr [ebp]
    cwde
    sub ecx, 0xc00
    push eax
    movsx eax, word ptr [ebp + 24]
    call EGS_
    inc dword ptr [esp + slot_x]
    cmp dword ptr [esp + slot_x], 7
    jl L1127
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1128:
    cmp dword ptr [eax + 16], 0
    {disp32} je L1291
    mov word ptr [ebp + 32], 0x10
    mov edi, dword ptr [eax + 16]
    cmp edi, 1
    jne L1130
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    mov edx, dword ptr [esp + slot_t]
    movsx eax, word ptr [eax + _sprite + 34]
    mov esi, dword ptr [edx + 12]
    sar eax, 3
    {store} cmp eax, esi
    jg L1129
    mov dword ptr [edx + 16], 0
    movsx edx, word ptr [esp + slot_i]
    movsx eax, word ptr [ebp + 24]
    call callsound_
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1129:
    {store} add edi, esi
    mov dword ptr [edx + 12], edi
    jmp L1132
L1130:
    cmp edi, 2
    jne L1132
    mov ebx, dword ptr [eax + 12]
    cmp ebx, 1
    jge L1131
    mov dword ptr [eax + 16], 0
    movsx edx, word ptr [esp + slot_i]
    movsx eax, word ptr [ebp + 24]
    call callsound_
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1131:
    lea ecx, dword ptr [ebx + -1]
    mov dword ptr [eax + 12], ecx
L1132:
    movsx esi, word ptr [esp + slot_i]
    {store} mov eax, esi
    call ms_
    {store} mov eax, esi
    mov ecx, dword ptr [ebp + 8]
    mov ebx, dword ptr [ebp + 4]
    {disp8} mov edx, dword ptr [ebp]
    call setsprite_
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1133:
    add dword ptr [eax + 8], 0x20
    mov eax, dword ptr [esp + slot_sc]
    mov edx, dword ptr [esp + slot_sc]
    mov eax, dword ptr [eax + 8]
    mov ebx, dword ptr [edx + 4]
    {store} cmp eax, ebx
    jge L1134
    mov byte ptr [ebp + 16], 0
    jmp L1139
L1134:
    mov edx, dword ptr [esp + slot_t]
    cmp ebx, dword ptr [edx + 12]
    jge L1139
    movsx eax, word ptr [ebp + 24]
    movsx esi, word ptr [eax*2 + _headspritesect]
L1135:
    test esi, esi
    jl L1136
    imul eax, esi, 0x2c
    mov cx, word ptr [eax + _sprite + 14]
    cmp cx, 0x440
    je L1136
    cmp cx, 0x242
    je L1136
    movsx esi, word ptr [esi*2 + _nextspritesect]
    jmp L1135
L1136:
    cmp esi, -1
    jne L1138
L1137:
    movsx eax, word ptr [esp + slot_i]
    call deletesprite_
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1138:
    mov byte ptr [ebp + 16], 1
L1139:
    cmp byte ptr [ebp + 16], 0
    je L1140
    mov eax, dword ptr [esp + slot_sc]
    add dword ptr [eax + 4], 0x400
    jmp L1141
L1140:
    mov eax, dword ptr [esp + slot_sc]
    sub dword ptr [eax + 4], 0x200
L1141:
    movsx esi, word ptr [esp + slot_i]
    {store} mov eax, esi
    call ms_
    {store} mov eax, esi
    mov ecx, dword ptr [ebp + 8]
    mov ebx, dword ptr [ebp + 4]
    {disp8} mov edx, dword ptr [ebp]
    call setsprite_
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1142:
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    mov edx, dword ptr [esp + slot_t]
    movsx eax, word ptr [eax + _sprite + 34]
    mov edx, dword ptr [edx]
    {disp32} lea eax, dword ptr [eax*4]
    imul edx, eax
    mov dword ptr [esp + slot_q], edx
    {store} mov eax, edx
    mov edx, dword ptr [esp + slot_sc]
    mov esi, dword ptr [edx + 4]
    mov edi, dword ptr [edx + 8]
    {store} add esi, eax
    {store} add edi, eax
    mov dword ptr [edx + 4], esi
    mov dword ptr [edx + 8], edi
    movsx eax, word ptr [ebp + 24]
    movsx esi, word ptr [eax*2 + _headspritesect]
L1143:
    test esi, esi
    {disp32} jl L1147
    imul eax, esi, 0x2c
    cmp word ptr [eax + _sprite + 26], 0xa
    {disp32} jne L1145
    cmp word ptr [eax + _sprite + 30], 0
    {disp32} jl L1145
    mov ax, word ptr [eax + _sprite + 34]
    mov bx, word ptr [_numplayers]
    mov dword ptr [esp + slot_p], eax
    cmp bx, 2
    jge L1144
    cwde
    imul eax, eax, 0x552
    mov edx, dword ptr [eax + _ps + 540]
    mov dword ptr [eax + _ps + 576], edx
L1144:
    movsx eax, word ptr [esp + slot_p]
    imul eax, eax, 0x552
    mov edx, dword ptr [esp + slot_q]
    mov edi, dword ptr [eax + _ps + 540]
    mov ebx, dword ptr [eax + _ps + 604]
    mov ecx, dword ptr [eax + _ps + 608]
    {store} add edi, edx
    {store} add ecx, edx
    mov dword ptr [eax + _ps + 540], edi
    {store} add ebx, edx
    mov dword ptr [eax + _ps + 608], ecx
    mov cx, word ptr [_numplayers]
    mov dword ptr [eax + _ps + 604], ebx
    cmp cx, 1
    jle L1145
    mov edx, dword ptr [eax + _ps + 540]
    mov dword ptr [eax + _ps + 576], edx
L1145:
    imul edx, esi, 0x2c
    cmp word ptr [edx + _sprite + 26], 3
    je L1146
    {disp32} lea ebx, dword ptr [esi*8]
    {store} add ebx, esi
    {disp32} lea ebx, dword ptr [ebx*8]
    {store} sub ebx, esi
    mov eax, dword ptr [edx + _sprite + 8]
    mov edi, dword ptr [edx + _sprite + 8]
    mov dword ptr [ebx + _hittype + 43], eax
    mov eax, dword ptr [esp + slot_q]
    {store} add edi, eax
    mov dword ptr [edx + _sprite + 8], edi
L1146:
    {disp32} lea eax, dword ptr [esi*8]
    {store} add eax, esi
    {disp32} lea eax, dword ptr [eax*8]
    mov edx, dword ptr [esp + slot_sc]
    {store} sub eax, esi
    mov edx, dword ptr [edx + 8]
    mov dword ptr [eax + _hittype + 19], edx
    mov edx, dword ptr [esp + slot_sc]
    mov edx, dword ptr [edx + 4]
    movsx esi, word ptr [esi*2 + _nextspritesect]
    mov dword ptr [eax + _hittype + 23], edx
    {disp32} jmp L1143
L1147:
    mov eax, dword ptr [esp + slot_t]
    mov esi, dword ptr [eax]
    test esi, esi
    {disp32} je L1291
    {disp32} je L1291
    movsx esi, word ptr [esp + slot_i]
    imul eax, esi, 0x2c
    mov ebx, dword ptr [esp + slot_t]
    movsx edx, word ptr [eax + _sprite + 34]
    mov eax, dword ptr [esp + slot_sc]
    mov ecx, dword ptr [ebx + 8]
    mov eax, dword ptr [eax + 8]
    {store} sub eax, ecx
    test eax, eax
    jns L1148
    neg eax
L1148:
    {store} cmp eax, edx
    jg L1149
    {store} mov eax, esi
    {store} xor edx, edx
    call activatewarpelevators_
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1149:
    cmp dword ptr [ebx], -1
    jne L1150
    mov eax, dword ptr [esp + slot_sc]
    mov ebx, dword ptr [ebx + 12]
    cmp ebx, dword ptr [eax + 8]
    {disp32} jl L1291
    jmp L1151
L1150:
    mov eax, dword ptr [esp + slot_sc]
    mov edi, dword ptr [ebx + 16]
    cmp edi, dword ptr [eax + 4]
    {disp32} jg L1291
L1151:
    mov eax, dword ptr [esp + slot_t]
    cmp dword ptr [eax + 4], 0
    {disp32} je L1291
    mov dword ptr [eax + 4], 0
    mov ecx, dword ptr [esp + slot_t]
    movsx esi, word ptr [_headspritestat + 6]
L1152:
    test esi, esi
    jl L1154
    movsx eax, word ptr [esp + slot_i]
    {store} cmp eax, esi
    je L1153
    imul edx, esi, 0x2c
    cmp word ptr [edx + _sprite + 38], 0x11
    jne L1153
    movsx ebx, word ptr [edx + _sprite + 24]
    {disp32} lea eax, dword ptr [ebx*4]
    {store} add eax, ebx
    movsx ebx, word ptr [eax*8 + _sector + 36]
    mov eax, dword ptr [esp + slot_sc]
    mov edi, dword ptr [ecx]
    movsx eax, word ptr [eax + 36]
    {store} sub eax, edi
    {store} cmp eax, ebx
    jne L1153
    mov eax, dword ptr [esp + slot_sh]
    cmp ax, word ptr [edx + _sprite + 40]
    je L1154
L1153:
    movsx esi, word ptr [esi*2 + _nextspritestat]
    jmp L1152
L1154:
    cmp esi, -1
    {disp32} je L1291
    movsx eax, word ptr [ebp + 24]
    mov ax, word ptr [eax*2 + _headspritesect]
L1155:
    mov dword ptr [esp + slot_k], eax
    mov ecx, dword ptr [esp + slot_k]
    test cx, cx
    {disp32} jl L1291
    movsx ecx, cx
    mov ax, word ptr [ecx*2 + _nextspritesect]
    mov dword ptr [esp + slot_nextk], eax
    imul eax, ecx, 0x2c
    cmp word ptr [eax + _sprite + 26], 0xa
    {disp32} jne L1156
    cmp word ptr [eax + _sprite + 30], 0
    {disp32} jl L1156
    mov ax, word ptr [eax + _sprite + 34]
    movsx edi, ax
    imul edi, edi, 0x552
    mov dword ptr [esp + slot_p], eax
    imul eax, esi, 0x2c
    {disp8} mov edx, dword ptr [ebp]
    mov dword ptr [esp + slot_passenger_player_cursor_1362], eax
    mov eax, dword ptr [eax + _sprite]
    mov ebx, dword ptr [edi + _ps + 532]
    {store} sub eax, edx
    {store} add ebx, eax
    mov eax, dword ptr [esp + slot_passenger_player_cursor_1362]
    mov dword ptr [edi + _ps + 532], ebx
    mov eax, dword ptr [eax + _sprite + 4]
    mov edx, dword ptr [ebp + 4]
    mov ebx, dword ptr [edi + _ps + 536]
    {store} sub eax, edx
    {store} add ebx, eax
    mov eax, dword ptr [esp + slot_passenger_player_cursor_1362]
    movsx eax, word ptr [eax + _sprite + 24]
    mov dword ptr [esp + slot_passenger_sector_index_1369], eax
    {store} mov edx, eax
    {disp32} lea eax, dword ptr [eax*4]
    mov dword ptr [edi + _ps + 536], ebx
    {store} add edx, eax
    mov eax, dword ptr [esp + slot_sc]
    mov ebx, dword ptr [edi + _ps + 540]
    mov eax, dword ptr [eax + 8]
    {disp32} lea edx, dword ptr [edx*8]
    {store} sub eax, ebx
    mov ebx, dword ptr [edx + _sector + 8]
    {store} sub ebx, eax
    {disp32} lea eax, dword ptr [ecx*8]
    {store} add eax, ecx
    {disp32} lea eax, dword ptr [eax*8]
    mov dword ptr [edi + _ps + 540], ebx
    {store} sub eax, ecx
    mov ebx, dword ptr [edx + _sector + 8]
    mov edx, dword ptr [edx + _sector + 4]
    mov dword ptr [eax + _hittype + 23], edx
    mov edx, dword ptr [edi + _ps + 532]
    mov dword ptr [edi + _ps + 568], edx
    mov dword ptr [edi + _ps + 560], edx
    mov edx, dword ptr [edi + _ps + 536]
    mov dword ptr [edi + _ps + 572], edx
    mov dword ptr [edi + _ps + 564], edx
    mov edx, dword ptr [edi + _ps + 540]
    mov dword ptr [eax + _hittype + 19], ebx
    mov dword ptr [edi + _ps + 576], edx
    mov edx, dword ptr [eax + _hittype + 19]
    mov eax, dword ptr [eax + _hittype + 23]
    mov dword ptr [edi + _ps + 604], edx
    mov dword ptr [edi + _ps + 608], eax
    {store} xor eax, eax
    mov edx, dword ptr [esp + slot_passenger_sector_index_1369]
    mov dword ptr [edi + _ps + 620], eax
    {store} mov eax, ecx
    call changespritesect_
    mov eax, dword ptr [esp + slot_passenger_player_cursor_1362]
    mov ax, word ptr [eax + _sprite + 24]
    mov word ptr [edi + _ps + 646], ax
    mov eax, dword ptr [esp + slot_nextk]
    {disp32} jmp L1155
L1156:
    movsx ecx, word ptr [esp + slot_k]
    imul eax, ecx, 0x2c
    cmp word ptr [eax + _sprite + 26], 3
    {disp32} je L1157
    imul edi, esi, 0x2c
    {disp32} lea edx, dword ptr [ecx*8]
    {store} add edx, ecx
    {disp32} lea edx, dword ptr [edx*8]
    {store} sub edx, ecx
    mov ebx, dword ptr [eax + _sprite]
    mov dword ptr [edx + _hittype + 35], ebx
    mov ebx, dword ptr [eax + _sprite + 4]
    mov dword ptr [edx + _hittype + 39], ebx
    mov ebx, dword ptr [eax + _sprite + 8]
    mov dword ptr [edx + _hittype + 43], ebx
    mov edx, dword ptr [edi + _sprite]
    {disp8} sub edx, dword ptr [ebp]
    add dword ptr [eax + _sprite], edx
    mov edx, dword ptr [edi + _sprite + 4]
    sub edx, dword ptr [ebp + 4]
    add dword ptr [eax + _sprite + 4], edx
    movsx edx, word ptr [edi + _sprite + 24]
    mov dword ptr [esp + slot_shared_sector_or_sprite_index_1471_2433], edx
    mov ebx, dword ptr [esp + slot_shared_sector_or_sprite_index_1471_2433]
    {disp32} lea edx, dword ptr [edx*4]
    {store} add ebx, edx
    mov edx, dword ptr [esp + slot_sc]
    {disp32} lea ebx, dword ptr [ebx*8]
    mov edx, dword ptr [edx + 8]
    mov ebx, dword ptr [ebx + _sector + 8]
    sub edx, dword ptr [eax + _sprite + 8]
    {store} sub ebx, edx
    mov dword ptr [eax + _sprite + 8], ebx
    {store} mov eax, ecx
    movsx edx, word ptr [edi + _sprite + 24]
    call changespritesect_
    movsx eax, word ptr [esp + slot_k]
    mov dword ptr [esp + slot_shared_sector_or_sprite_index_1471_2433], eax
    imul eax, eax, 0x2c
    mov ecx, dword ptr [eax + _sprite + 8]
    mov ebx, dword ptr [eax + _sprite + 4]
    mov edx, dword ptr [eax + _sprite]
    mov eax, dword ptr [esp + slot_shared_sector_or_sprite_index_1471_2433]
    call setsprite_
    movsx edx, word ptr [edi + _sprite + 24]
    {disp32} lea ebx, dword ptr [edx*4]
    {store} add ebx, edx
    movsx edx, word ptr [esp + slot_k]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {disp32} lea ebx, dword ptr [ebx*8]
    {store} sub eax, edx
    mov edx, dword ptr [ebx + _sector + 8]
    mov dword ptr [eax + _hittype + 19], edx
    mov edx, dword ptr [ebx + _sector + 4]
    mov dword ptr [eax + _hittype + 23], edx
L1157:
    mov eax, dword ptr [esp + slot_nextk]
    {disp32} jmp L1155
L1158:
    mov edx, dword ptr [eax]
    test edx, edx
    {disp32} je L1166
    cmp edx, 1
    {disp32} jne L1162
    lea ecx, dword ptr [edx + edx]
    mov dword ptr [eax], ecx
    mov eax, dword ptr [esp + slot_sc]
    movsx eax, word ptr [eax]
    mov dword ptr [esp + slot_x], eax
    mov eax, dword ptr [esp + slot_sc]
    mov edx, dword ptr [esp + slot_x]
    movsx eax, word ptr [eax + 2]
    {store} add edx, eax
    mov esi, dword ptr [esp + slot_x]
    mov dword ptr [esp + slot_q], edx
    jmp L1161
L1159:
    {store} mov eax, esi
    shl eax, 5
    cmp word ptr [eax + _wall + 18], 0xe6
    jne L1160
    mov dx, word ptr [eax + _wall + 14]
    {store} xor ebx, ebx
    xor dh, dh
    mov word ptr [eax + _wall + 18], bx
    and dl, 0xae
    mov cx, word ptr [eax + _wall + 10]
    mov word ptr [eax + _wall + 14], dx
    test cx, cx
    jl L1160
    movsx edx, cx
    shl edx, 5
    mov word ptr [edx + _wall + 18], bx
    movsx eax, word ptr [eax + _wall + 10]
    shl eax, 5
    mov dx, word ptr [eax + _wall + 14]
    xor dh, dh
    and dl, 0xae
    mov word ptr [eax + _wall + 14], dx
L1160:
    inc esi
L1161:
    cmp esi, dword ptr [esp + slot_q]
    jl L1159
L1162:
    mov eax, dword ptr [esp + slot_sc]
    mov edx, dword ptr [esp + slot_sc]
    mov eax, dword ptr [eax + 4]
    mov ebp, dword ptr [edx + 8]
    {store} cmp eax, ebp
    {disp32} jl L1165
    mov dword ptr [edx + 4], ebp
    movsx esi, word ptr [_headspritestat + 6]
L1163:
    test esi, esi
    {disp32} jl L1137
    imul edx, esi, 0x2c
    cmp word ptr [edx + _sprite + 38], 0
    {disp32} jne L1164
    mov ecx, dword ptr [esp + slot_sh]
    cmp cx, word ptr [edx + _sprite + 40]
    jne L1164
    movsx ecx, word ptr [edx + _sprite + 30]
    imul eax, ecx, 0x2c
    movsx eax, word ptr [eax + _sprite + 24]
    mov dword ptr [esp + slot_q], eax
    {store} mov ebx, eax
    {disp32} lea eax, dword ptr [eax*4]
    movsx edx, word ptr [edx + _sprite + 24]
    {store} add ebx, eax
    {disp32} lea eax, dword ptr [edx*4]
    {disp32} lea ebx, dword ptr [ebx*8]
    {store} add eax, edx
    mov dl, byte ptr [ebx + _sector + 29]
    mov byte ptr [eax*8 + _sector + 21], dl
    mov byte ptr [eax*8 + _sector + 29], dl
    mov dl, byte ptr [ebx + _sector + 28]
    mov byte ptr [eax*8 + _sector + 20], dl
    mov byte ptr [eax*8 + _sector + 28], dl
    {disp32} lea eax, dword ptr [ecx*8]
    {store} add eax, ecx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ecx
    mov dword ptr [eax + _hittype + 47], 2
L1164:
    movsx esi, word ptr [esi*2 + _nextspritestat]
    {disp32} jmp L1163
L1165:
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    mov ebx, dword ptr [edx + 4]
    movsx eax, word ptr [eax + _sprite + 34]
    {store} add ebx, eax
    mov dword ptr [edx + 4], ebx
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1166:
    movsx eax, word ptr [ebp + 24]
    call ifhitsectors_
    movsx esi, ax
    test esi, esi
    {disp32} jl L1291
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov edx, OFFSET FLAT:_ps
    {store} add edx, eax
    mov eax, 8
    mov esi, dword ptr [esp + slot_sh]
    call FTA_
    movsx edi, word ptr [_headspritestat + 6]
L1167:
    test edi, edi
    {disp32} jl L1291
    imul edx, edi, 0x2c
    mov ax, word ptr [edx + _sprite + 38]
    and ah, 0x7f
    cwde
    mov dword ptr [esp + slot_x], eax
    cmp eax, 1
    jb L1168
    {disp32} jbe L1169
    cmp eax, 0xc
    {disp32} jb L1170
    jbe L1169
    cmp eax, 0x13
    je L1169
    {disp32} jmp L1170
L1168:
    test eax, eax
    {disp32} jne L1170
    cmp si, word ptr [edx + _sprite + 40]
    {disp32} jne L1170
    movsx eax, word ptr [edx + _sprite + 24]
    movsx edx, word ptr [edx + _sprite + 30]
    imul edx, edx, 0x2c
    mov dword ptr [esp + slot_q], eax
    {store} mov ebx, eax
    {disp32} lea eax, dword ptr [eax*4]
    {store} add eax, ebx
    mov bl, byte ptr [edx + _sprite + 16]
    mov byte ptr [eax*8 + _sector + 20], bl
    mov dl, byte ptr [edx + _sprite + 17]
    mov byte ptr [eax*8 + _sector + 28], bl
    mov byte ptr [eax*8 + _sector + 21], dl
    mov byte ptr [eax*8 + _sector + 29], dl
    jmp L1170
L1169:
    imul ebx, edi, 0x2c
    mov eax, dword ptr [esp + slot_sh]
    cmp ax, word ptr [ebx + _sprite + 40]
    jne L1170
    {disp32} lea eax, dword ptr [edi*8]
    {store} add eax, edi
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edi
    cmp dword ptr [eax + _hittype + 47], 0
    jne L1170
    mov dword ptr [eax + _hittype + 47], 1
    mov eax, dword ptr [esp + slot_i]
    mov word ptr [ebx + _sprite + 30], ax
L1170:
    movsx edi, word ptr [edi*2 + _nextspritestat]
    {disp32} jmp L1167
L1171:
    mov ecx, dword ptr [eax]
    test ecx, ecx
    {disp32} je L1291
    cmp ecx, 1
    jne L1172
    mov word ptr [ebp + 32], 8
    jmp L1173
L1172:
    mov word ptr [ebp + 32], 0xfff8
L1173:
    mov cx, word ptr [ebp + 32]
    test cx, cx
    {disp32} je L1291
    movsx eax, word ptr [ebp + 28]
    .att_syntax prefix
    addl $actors_ASM_math_12613,%eax
    .intel_syntax noprefix
    and eax, 0x7ff
    movsx edx, cx
    movsx eax, word ptr [eax*2 + _sintable]
    imul eax, edx
    sar eax, 0xe
    mov dword ptr [esp + slot_x], eax
    mov ax, word ptr [ebp + 28]
    and ah, 7
    cwde
    movsx edi, word ptr [eax*2 + _sintable]
    movsx eax, word ptr [ebp + 32]
    imul edi, eax
    mov edx, dword ptr [esp + slot_t]
    add dword ptr [edx + 12], eax
    {disp8} mov ecx, dword ptr [ebp]
    mov esi, dword ptr [ebp + 4]
    mov eax, dword ptr [esp + slot_x]
    sar edi, 0xe
    {store} add ecx, eax
    {store} add esi, edi
    {disp8} mov dword ptr [ebp], ecx
    mov dword ptr [ebp + 4], esi
    cmp dword ptr [edx + 12], 0
    jle L1174
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    mov edx, dword ptr [esp + slot_t]
    mov edx, dword ptr [edx + 12]
    movsx eax, word ptr [eax + _sprite + 34]
    sar edx, 6
    sar eax, 6
    {store} cmp edx, eax
    jl L1175
L1174:
    mov eax, dword ptr [esp + slot_x]
    {disp8} mov ebx, dword ptr [ebp]
    mov ecx, dword ptr [ebp + 4]
    {store} sub ebx, eax
    {store} sub ecx, edi
    {disp8} mov dword ptr [ebp], ebx
    mov eax, dword ptr [esp + slot_t]
    mov dword ptr [ebp + 4], ecx
    mov dword ptr [eax], 0
    movsx edx, word ptr [esp + slot_i]
    movsx eax, word ptr [ebp + 24]
    call callsound_
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1175:
    movsx eax, word ptr [ebp + 24]
    movsx esi, word ptr [eax*2 + _headspritesect]
L1176:
    test esi, esi
    {disp32} jl L1178
    mov ax, word ptr [esi*2 + _nextspritesect]
    mov dword ptr [esp + slot_nextj], eax
    imul eax, esi, 0x2c
    mov dx, word ptr [eax + _sprite + 26]
    mov dword ptr [esp + slot_moving_sprite_cursor_1604], eax
    cmp dx, 3
    {disp32} je L1177
    cmp word ptr [eax + _sprite + 36], 0
    jne L1177
    mov edx, dword ptr [esp + slot_moving_sprite_cursor_1604]
    mov eax, dword ptr [esp + slot_x]
    mov ebx, dword ptr [edx + _sprite]
    mov ecx, dword ptr [edx + _sprite + 4]
    {store} add ebx, eax
    {store} add ecx, edi
    mov dword ptr [edx + _sprite], ebx
    mov dword ptr [edx + _sprite + 4], ecx
    {store} mov eax, esi
    mov ecx, dword ptr [edx + _sprite + 8]
    mov ebx, dword ptr [edx + _sprite + 4]
    mov edx, dword ptr [edx + _sprite]
    call setsprite_
    mov edx, dword ptr [esp + slot_moving_sprite_cursor_1604]
    movsx edx, word ptr [edx + _sprite + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    test byte ptr [eax*8 + _sector + 14], 2
    je L1177
    mov eax, dword ptr [esp + slot_moving_sprite_cursor_1604]
    cmp word ptr [eax + _sprite + 26], 2
    jne L1177
    movsx eax, si
    call makeitfall_
L1177:
    movsx esi, word ptr [esp + slot_nextj]
    {disp32} jmp L1176
L1178:
    mov eax, dword ptr [esp + slot_t]
    mov eax, dword ptr [eax + 4]
    shl eax, 5
    mov esi, dword ptr [esp + slot_x]
    mov ebx, dword ptr [eax + _wall + 4]
    mov edx, dword ptr [eax + _wall]
    mov eax, dword ptr [esp + slot_t]
    {store} add ebx, edi
    {store} add edx, esi
    movsx eax, word ptr [eax + 4]
    call dragpoint_
    mov eax, dword ptr [esp + slot_t]
    mov eax, dword ptr [eax + 8]
    shl eax, 5
    mov ebx, dword ptr [eax + _wall + 4]
    mov edx, dword ptr [eax + _wall]
    add edx, dword ptr [esp + slot_x]
    mov eax, dword ptr [esp + slot_t]
    {store} add ebx, edi
    movsx eax, word ptr [eax + 8]
    call dragpoint_
    mov ax, word ptr [_connecthead]
    {disp32} jmp L1181
L1179:
    movsx edx, si
    imul edx, edx, 0x552
    mov bx, word ptr [ebp + 24]
    cmp bx, word ptr [edx + _ps + 646]
    jne L1180
    cmp byte ptr [edx + _ps + 1308], 0
    je L1180
    mov eax, dword ptr [esp + slot_x]
    mov esi, dword ptr [edx + _ps + 532]
    {store} add esi, eax
    mov eax, dword ptr [edx + _ps + 536]
    mov dword ptr [edx + _ps + 532], esi
    {store} add eax, edi
    mov dword ptr [edx + _ps + 536], eax
    mov eax, dword ptr [edx + _ps + 532]
    mov ecx, dword ptr [edx + _ps + 540]
    mov dword ptr [edx + _ps + 568], eax
    add ecx, 0x2600
    mov eax, dword ptr [edx + _ps + 536]
    mov esi, dword ptr [edx + _ps + 532]
    mov dword ptr [edx + _ps + 572], eax
    {store} mov ebx, eax
    movsx eax, word ptr [edx + _ps + 724]
    {store} mov edx, esi
    call setsprite_
L1180:
    movsx eax, word ptr [esp + slot_p]
    mov ax, word ptr [eax*2 + _connectpoint2]
L1181:
    mov dword ptr [esp + slot_p], eax
    mov esi, dword ptr [esp + slot_p]
    test si, si
    {disp32} jge L1179
    mov edx, dword ptr [esp + slot_x]
    mov ebx, dword ptr [esp + slot_sc]
    {store} xor eax, eax
    sar edx, 3
    mov al, byte ptr [ebx + 30]
    {store} sub eax, edx
    mov byte ptr [ebx + 30], al
    {store} xor eax, eax
    sar edi, 3
    mov al, byte ptr [ebx + 31]
    {store} sub eax, edi
    mov byte ptr [ebx + 31], al
    mov edx, dword ptr [esp + slot_x]
    {store} xor eax, eax
    sar edx, 3
    mov al, byte ptr [ebx + 22]
    {store} sub eax, edx
    mov byte ptr [ebx + 22], al
    {store} xor eax, eax
    mov al, byte ptr [ebx + 23]
    {store} sub eax, edi
    mov byte ptr [ebx + 23], al
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1182:
    cmp dword ptr [eax], 0
    {disp32} je L1291
    cmp word ptr [ebp + 28], 0x600
    jne L1183
    mov edi, dword ptr [esp + slot_sc]
    add edi, 4
    jmp L1184
L1183:
    mov edi, dword ptr [esp + slot_sc]
    add edi, 8
L1184:
    mov eax, dword ptr [esp + slot_t]
    cmp dword ptr [eax], 1
    jne L1185
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    mov ebx, dword ptr [ebp + 8]
    mov ecx, dword ptr [edi]
    mov dx, word ptr [eax + _sprite + 34]
    {store} sub ebx, ecx
    shl edx, 4
    {store} add ebx, ebx
    {store} sbb eax, eax
    {store} cmp eax, ebx
    adc al, 0
    imul eax, edx
    mov word ptr [ebp + 36], ax
    mov eax, dword ptr [esp + slot_t]
    inc dword ptr [eax]
L1185:
    mov eax, dword ptr [esp + slot_sc]
    mov dx, word ptr [eax + 38]
    test dx, dx
    jne L1187
    movsx eax, word ptr [ebp + 36]
    mov edx, dword ptr [edi]
    {store} add edx, eax
    mov dword ptr [edi], edx
    {store} mov eax, edx
    sub eax, dword ptr [ebp + 8]
    test eax, eax
    jns L1186
    neg eax
L1186:
    .att_syntax prefix
    cmpl $actors_ASM_math_13406,%eax
    .intel_syntax noprefix
    {disp32} jge L1291
    mov eax, dword ptr [ebp + 8]
    mov dword ptr [edi], eax
    movsx eax, word ptr [esp + slot_i]
    call deletesprite_
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1187:
    {store} mov ebx, edx
    dec ebx
    mov word ptr [eax + 38], bx
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1188:
    cmp dword ptr [eax + 4], 0
    {disp32} je L1291
    mov edx, dword ptr [eax]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add edx, eax
    mov eax, OFFSET FLAT:_sector
    {disp32} lea edx, dword ptr [edx*8]
    {store} add eax, edx
    add eax, 4
    call getanimationgoal_
    test eax, eax
    jl L1189
    mov edx, dword ptr [esp + slot_sc]
    movsx edx, word ptr [edx + 38]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    mov edx, dword ptr [esp + slot_sc]
    add dword ptr [edx + 4], eax
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1189:
    mov eax, dword ptr [esp + slot_t]
    mov dword ptr [eax + 4], 0
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1190:
    mov eax, dword ptr [esp + slot_t]
    cmp dword ptr [eax + 16], 0
    {disp32} jne L1291
    movsx eax, word ptr [ebp + 28]
    .att_syntax prefix
    addl $actors_ASM_math_13575,%eax
    .intel_syntax noprefix
    and eax, 0x7ff
    movsx edx, word ptr [eax*2 + _sintable]
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    movsx eax, word ptr [eax + _sprite + 34]
    imul edx, eax
    sar edx, 0x12
    mov dword ptr [esp + slot_x], edx
    mov dx, word ptr [ebp + 28]
    and dh, 7
    movsx edx, dx
    {store} mov edi, eax
    movsx edx, word ptr [edx*2 + _sintable]
    imul edi, edx
    {store} xor esi, esi
    mov dword ptr [esp + slot_k], esi
    movsx esi, word ptr [ebp + 24]
    movsx esi, word ptr [esi*2 + _headspritesect]
    sar edi, 0x12
L1191:
    test esi, esi
    {disp32} jl L1201
    imul edx, esi, 0x2c
    mov ax, word ptr [esi*2 + _nextspritesect]
    mov dword ptr [esp + slot_nextj], eax
    cmp word ptr [edx + _sprite + 36], 0
    {disp32} jl L1200
    mov ax, word ptr [edx + _sprite + 26]
    .att_syntax prefix
    cmpw $actors_ASM_math_13705,%ax
    .intel_syntax noprefix
    jb L1192
    jbe L1193
    .att_syntax prefix
    cmpw $actors_ASM_math_13713,%ax
    .intel_syntax noprefix
    je L1197
    {disp32} jmp L1200
L1192:
    .att_syntax prefix
    cmpw $actors_ASM_math_13724,%ax
    .intel_syntax noprefix
    jbe L1198
    {disp32} jmp L1200
L1193:
    mov ax, word ptr [edx + _sprite + 14]
    .att_syntax prefix
    cmpw $actors_ASM_math_13742,%ax
    .intel_syntax noprefix
    jb L1194
    .att_syntax prefix
    cmpw $actors_ASM_math_13748,%ax
    .intel_syntax noprefix
    jbe L1195
    .att_syntax prefix
    cmpw $actors_ASM_math_13754,%ax
    .intel_syntax noprefix
    je L1195
    jmp L1196
L1194:
    .att_syntax prefix
    cmpw $actors_ASM_math_13762,%ax
    .intel_syntax noprefix
    jne L1196
L1195:
    imul eax, esi, 0x2c
    xor bh, bh
    mov edx, 1
    mov byte ptr [eax + _sprite + 21], bh
    mov dword ptr [esp + slot_k], edx
    mov byte ptr [eax + _sprite + 20], bh
L1196:
    imul eax, esi, 0x2c
    cmp word ptr [eax + _sprite + 14], 0x564
    {disp32} jne L1200
L1197:
    imul eax, esi, 0x2c
    cmp word ptr [eax + _sprite + 14], 0xa06
    {disp32} je L1200
L1198:
    imul eax, esi, 0x2c
    mov dx, word ptr [eax + _sprite + 14]
    cmp dx, 0x4c6
    jl L1199
    cmp dx, 0x4c9
    {disp32} jle L1200
L1199:
    imul eax, esi, 0x2c
    mov cl, byte ptr [eax + _sprite + 12]
    mov dword ptr [esp + slot_moving_sprite_cursor_1730], eax
    test cl, 0x10
    {disp32} jne L1200
    {disp32} lea eax, dword ptr [esi*8]
    {store} add eax, esi
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, esi
    mov ebx, dword ptr [esp + slot_moving_sprite_cursor_1730]
    mov edx, dword ptr [eax + _hittype + 19]
    mov ecx, dword ptr [ebx + _sprite + 8]
    sub edx, 0x1000
    {store} cmp edx, ecx
    {disp32} jge L1200
    mov edx, dword ptr [ebx + _sprite]
    mov dword ptr [eax + _hittype + 35], edx
    mov edx, dword ptr [ebx + _sprite + 4]
    mov dword ptr [eax + _hittype + 39], edx
    mov eax, dword ptr [esp + slot_x]
    {store} mov edx, ebx
    sar eax, 1
    mov ebx, dword ptr [ebx + _sprite]
    {store} add ebx, eax
    {store} mov eax, edi
    mov ecx, dword ptr [edx + _sprite + 4]
    sar eax, 1
    mov dword ptr [edx + _sprite], ebx
    {store} add ecx, eax
    {store} mov ebx, edx
    mov dword ptr [edx + _sprite + 4], ecx
    {store} mov ecx, edx
    {store} mov eax, esi
    mov ebx, dword ptr [ebx + _sprite + 4]
    mov ecx, dword ptr [ecx + _sprite + 8]
    mov edx, dword ptr [edx + _sprite]
    call setsprite_
    mov edx, dword ptr [esp + slot_moving_sprite_cursor_1730]
    movsx edx, word ptr [edx + _sprite + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    test byte ptr [eax*8 + _sector + 14], 2
    je L1200
    mov eax, dword ptr [esp + slot_moving_sprite_cursor_1730]
    cmp word ptr [eax + _sprite + 26], 2
    jne L1200
    movsx eax, si
    call makeitfall_
L1200:
    movsx esi, word ptr [esp + slot_nextj]
    {disp32} jmp L1191
L1201:
    mov ax, word ptr [_myconnectindex]
    mov dword ptr [esp + slot_p], eax
    cwde
    imul eax, eax, 0x552
    mov cx, word ptr [ebp + 24]
    cmp cx, word ptr [eax + _ps + 646]
    jne L1203
    cmp byte ptr [eax + _ps + 1308], 0
    je L1203
    mov edx, dword ptr [eax + _ps + 540]
    mov ebp, dword ptr [eax + _ps + 604]
    {store} mov eax, edx
    {store} sub eax, ebp
    test eax, eax
    jns L1202
    neg eax
L1202:
    .att_syntax prefix
    cmpl $actors_ASM_math_14143,%eax
    .intel_syntax noprefix
    jge L1203
    mov eax, dword ptr [esp + slot_x]
    mov edx, dword ptr [_fricxv]
    mov ebx, dword ptr [_fricyv]
    {disp32} lea edi, dword ptr [edi*8]
    {disp32} lea eax, dword ptr [eax*8]
    {store} add ebx, edi
    {store} add edx, eax
    mov dword ptr [_fricyv], ebx
    mov dword ptr [_fricxv], edx
L1203:
    movsx edx, word ptr [esp + slot_i]
    imul edx, edx, 0x2c
    mov ebx, dword ptr [esp + slot_sc]
    {store} xor eax, eax
    movsx edx, word ptr [edx + _sprite + 34]
    mov al, byte ptr [ebx + 30]
    sar edx, 7
    {store} add eax, edx
    mov byte ptr [ebx + 30], al
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1204:
    mov eax, dword ptr [edx + 4]
    cmp eax, dword ptr [ebp + 8]
    {disp32} jle L1208
    movsx edi, word ptr [esp + slot_i]
    {store} xor esi, esi
    {disp32} jmp L1207
L1205:
    call krand_
    and ah, 1
    mov dx, word ptr [ebp + 28]
    {store} add edx, eax
    {store} mov eax, edi
    mov word ptr [ebp + 28], dx
    mov edx, 0x919
    call spawn_
    mov dword ptr [esp + slot_k], eax
    call krand_
    {store} mov ebx, eax
    xor bh, ah
    movsx eax, word ptr [esp + slot_k]
    imul edx, eax, 0x2c
    and bl, 0x7f
    add ebx, 0x60
    mov word ptr [edx + _sprite + 32], bx
    mov edx, 0x10001
    call ssp_
    movsx eax, word ptr [esp + slot_k]
    imul edx, eax, 0x2c
    mov ecx, dword ptr [edx + _sprite + 8]
    mov ebx, dword ptr [edx + _sprite + 4]
    mov edx, dword ptr [edx + _sprite]
    call setsprite_
    call krand_
    sar eax, 8
    .att_syntax prefix
    cmpl $actors_ASM_math_14373,%eax
    .intel_syntax noprefix
    jl L1206
    mov edx, 0x762
    {store} mov eax, edi
    call spawn_
L1206:
    inc esi
L1207:
    cmp esi, 8
    {disp32} jl L1205
L1208:
    mov eax, dword ptr [esp + slot_t]
    mov eax, dword ptr [eax]
    test eax, eax
    jbe L1209
    cmp eax, 1
    je L1211
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1209:
    mov edx, dword ptr [esp + slot_sc]
    movsx eax, word ptr [ebp + 34]
    mov ebx, dword ptr [edx + 4]
    {store} add ebx, eax
    mov ecx, dword ptr [edx + 8]
    mov dword ptr [edx + 4], ebx
    {store} cmp ebx, ecx
    jle L1210
    mov dword ptr [edx + 8], ebx
L1210:
    mov eax, dword ptr [ebp + 8]
    mov edx, dword ptr [esp + slot_sc]
    .att_syntax prefix
    addl $actors_ASM_math_14459,%eax
    .intel_syntax noprefix
    cmp eax, dword ptr [edx + 4]
    {disp32} jge L1291
    mov eax, dword ptr [esp + slot_t]
    inc dword ptr [eax]
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1211:
    movsx eax, word ptr [ebp + 34]
    mov edx, dword ptr [esp + slot_sc]
    {disp32} lea eax, dword ptr [eax*4]
    mov esi, dword ptr [edx + 4]
    {store} sub esi, eax
    mov dword ptr [edx + 4], esi
    mov edx, dword ptr [esp + slot_t]
    mov edi, dword ptr [edx + 16]
    {store} cmp esi, edi
    {disp32} jge L1291
    mov edx, dword ptr [esp + slot_sc]
    mov eax, dword ptr [esp + slot_t]
    mov dword ptr [edx + 4], edi
    mov dword ptr [eax], 0
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1212:
    cmp dword ptr [eax + 16], 0
    {disp32} je L1291
    mov eax, dword ptr [edx + 8]
    mov edi, dword ptr [edx + 4]
    {store} cmp eax, edi
    jg L1213
    mov byte ptr [ebp + 16], 0
    jmp L1214
L1213:
    mov edx, dword ptr [esp + slot_t]
    cmp edi, dword ptr [edx + 16]
    jg L1214
    mov byte ptr [ebp + 16], 1
L1214:
    cmp byte ptr [ebp + 16], 0
    je L1215
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    mov edx, dword ptr [esp + slot_sc]
    movsx eax, word ptr [eax + _sprite + 34]
    mov edi, dword ptr [edx + 4]
    shl eax, 4
    {store} add edi, eax
    mov ebp, dword ptr [edx + 8]
    mov dword ptr [edx + 4], edi
    {store} cmp edi, ebp
    {disp32} jle L1291
    mov dword ptr [edx + 4], ebp
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1215:
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    mov edx, dword ptr [esp + slot_sc]
    movsx eax, word ptr [eax + _sprite + 34]
    mov ecx, dword ptr [edx + 4]
    shl eax, 4
    {store} sub ecx, eax
    mov dword ptr [edx + 4], ecx
    mov edx, dword ptr [esp + slot_t]
    mov esi, dword ptr [edx + 16]
    {store} cmp ecx, esi
    {disp32} jge L1291
    mov edx, dword ptr [esp + slot_sc]
    mov dword ptr [edx + 4], esi
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1216:
    movsx edi, word ptr [ebp + 28]
    add edi, 0x200
    mov word ptr [ebp + 32], 0x20
    and edi, 0x7ff
    movsx edx, word ptr [ebp + 32]
    movsx edi, word ptr [edi*2 + _sintable]
    imul edi, edx
    mov ax, word ptr [ebp + 28]
    and ah, 7
    cwde
    movsx eax, word ptr [eax*2 + _sintable]
    movsx edx, word ptr [ebp + 32]
    imul eax, edx
    sar eax, 0xe
    mov dword ptr [esp + slot_x], eax
    mov ch, byte ptr [ebp + 16]
    inc ch
    sar edi, 0xe
    mov byte ptr [ebp + 16], ch
    cmp ch, 7
    jle L1217
    mov eax, dword ptr [esp + slot_t]
    mov eax, dword ptr [eax + 12]
    {disp8} mov dword ptr [ebp], eax
    mov eax, dword ptr [esp + slot_t]
    mov eax, dword ptr [eax + 16]
    mov dword ptr [ebp + 4], eax
    movsx edx, word ptr [ebp + 36]
    movsx eax, byte ptr [ebp + 16]
    imul edx, eax
    movsx eax, word ptr [ebp + 36]
    {store} sub edx, eax
    mov eax, dword ptr [esp + slot_sc]
    sub dword ptr [eax + 8], edx
    mov byte ptr [ebp + 16], 0
    jmp L1218
L1217:
    mov edx, dword ptr [esp + slot_sc]
    movsx eax, word ptr [ebp + 36]
    add dword ptr [edx + 8], eax
L1218:
    movsx eax, word ptr [ebp + 24]
    movsx esi, word ptr [eax*2 + _headspritesect]
L1219:
    test esi, esi
    {disp32} jl L1221
    imul edx, esi, 0x2c
    mov ax, word ptr [esi*2 + _nextspritesect]
    mov cx, word ptr [edx + _sprite + 26]
    mov dword ptr [esp + slot_nextj], eax
    cmp cx, 3
    je L1220
    cmp cx, 0xa
    je L1220
    {disp32} lea eax, dword ptr [esi*8]
    {store} add eax, esi
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, esi
    mov ebx, dword ptr [edx + _sprite]
    mov dword ptr [eax + _hittype + 35], ebx
    mov ebx, dword ptr [edx + _sprite + 4]
    mov dword ptr [eax + _hittype + 39], ebx
    mov eax, dword ptr [edx + _sprite]
    {store} add eax, edi
    mov ebx, dword ptr [edx + _sprite + 4]
    mov dword ptr [edx + _sprite], eax
    mov eax, dword ptr [esp + slot_x]
    {store} add ebx, eax
    mov dword ptr [edx + _sprite + 4], ebx
    mov ecx, dword ptr [edx + _sprite + 8]
    movsx eax, word ptr [ebp + 36]
    {store} add ecx, eax
    mov ebx, dword ptr [edx + _sprite + 4]
    mov dword ptr [edx + _sprite + 8], ecx
    {store} mov eax, esi
    mov edx, dword ptr [edx + _sprite]
    call setsprite_
L1220:
    movsx esi, word ptr [esp + slot_nextj]
    {disp32} jmp L1219
L1221:
    mov ax, word ptr [_myconnectindex]
    mov dword ptr [esp + slot_p], eax
    cwde
    imul eax, eax, 0x552
    movsx edx, word ptr [eax + _ps + 724]
    imul edx, edx, 0x2c
    mov bx, word ptr [ebp + 24]
    cmp bx, word ptr [edx + _sprite + 24]
    jne L1222
    cmp byte ptr [eax + _ps + 1308], 0
    je L1222
    mov eax, dword ptr [esp + slot_x]
    mov ecx, dword ptr [_fricxv]
    mov esi, dword ptr [_fricyv]
    shl edi, 5
    shl eax, 5
    {store} add ecx, edi
    {store} add esi, eax
    mov dword ptr [_fricxv], ecx
    mov dword ptr [_fricyv], esi
L1222:
    mov ax, word ptr [_connecthead]
    jmp L1225
L1223:
    movsx eax, dx
    imul eax, eax, 0x552
    movsx edx, word ptr [eax + _ps + 724]
    imul edx, edx, 0x2c
    mov bx, word ptr [ebp + 24]
    cmp bx, word ptr [edx + _sprite + 24]
    jne L1224
    cmp byte ptr [eax + _ps + 1308], 0
    je L1224
    movsx edx, word ptr [ebp + 36]
    add dword ptr [eax + _ps + 540], edx
L1224:
    movsx eax, word ptr [esp + slot_p]
    mov ax, word ptr [eax*2 + _connectpoint2]
L1225:
    mov dword ptr [esp + slot_p], eax
    mov edx, dword ptr [esp + slot_p]
    test dx, dx
    jge L1223
L1226:
    movsx esi, word ptr [esp + slot_i]
    {store} mov eax, esi
    call ms_
    {store} mov eax, esi
    mov ecx, dword ptr [ebp + 8]
    mov ebx, dword ptr [ebp + 4]
    {disp8} mov edx, dword ptr [ebp]
    call setsprite_
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1227:
    cmp dword ptr [_ud + 1530], 0
    {disp32} je L1291
    movsx edx, word ptr [esp + slot_i]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    {store} mov edx, eax
    mov ax, word ptr [ebp + 28]
    mov word ptr [edx + _hittype + 11], ax
    {store} mov edx, esp
    {store} mov eax, ebp
    call findplayer_
    mov dword ptr [esp + slot_p], eax
    cwde
    imul eax, eax, 0x552
    movsx eax, word ptr [eax + _ps + 724]
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 42], 0
    {disp32} jle L1291
    mov ax, word ptr [_myconnectindex]
    cmp ax, word ptr [_screenpeek]
    {disp32} jne L1291
    mov eax, dword ptr [esp + slot_t]
    cmp dword ptr [eax], 0
    jge L1228
    mov eax, dword ptr [esp + slot_i]
    mov word ptr [_ud + 1420], ax
    mov eax, dword ptr [esp + slot_t]
    inc dword ptr [eax]
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1228:
    cmp dword ptr [_ud + 1530], 2
    {disp32} jne L1291
    movsx eax, word ptr [esp + slot_p]
    imul eax, eax, 0x552
    movsx eax, word ptr [eax + _ps + 690]
    cmp eax, -1
    {disp32} jne L1291
    movsx eax, word ptr [esp + slot_p]
    imul eax, eax, 0x552
    movsx eax, word ptr [eax + _ps + 646]
    push eax
    movsx eax, word ptr [esp + slot_p+4]
    imul eax, eax, 0x552
    mov edi, dword ptr [eax + _ps + 540]
    movsx eax, word ptr [esp + slot_p+4]
    imul eax, eax, 0x552
    movsx ecx, word ptr [esp + slot_i+4]
    imul ecx, ecx, 0x2c
    mov edx, dword ptr [eax + _ps + 536]
    movsx eax, word ptr [esp + slot_p+4]
    imul eax, eax, 0x552
    push edi
    movsx ecx, word ptr [ecx + _sprite + 24]
    push edx
    mov ebx, dword ptr [eax + _ps + 532]
    mov edx, dword ptr [ebp + 4]
    push ebx
    {disp8} mov eax, dword ptr [ebp]
    mov ebx, dword ptr [ebp + 8]
    call cansee_
    test eax, eax
    {disp32} je L1232
    movsx eax, word ptr [esp + slot_sh]
    cmp eax, dword ptr [esp + slot_x]
    {disp32} jbe L1229
    movsx edx, word ptr [esp + slot_p]
    imul edx, edx, 0x552
    mov eax, dword ptr [esp + slot_i]
    mov word ptr [_ud + 1420], ax
    mov eax, dword ptr [esp + slot_t]
    mov dword ptr [eax], 0x3e7
    movsx eax, word ptr [esp + slot_p]
    imul eax, eax, 0x552
    mov ecx, dword ptr [ebp + 4]
    {disp8} mov esi, dword ptr [ebp]
    mov edx, dword ptr [edx + _ps + 536]
    mov eax, dword ptr [eax + _ps + 532]
    {store} sub edx, ecx
    {store} sub eax, esi
    call getangle_
    movsx edx, ax
    movsx eax, word ptr [ebp + 28]
    call getincangle_
    cwde
    {store} mov edx, eax
    sar edx, 3
    movsx eax, word ptr [ebp + 28]
    {store} add eax, edx
    mov word ptr [ebp + 28], ax
    movsx eax, word ptr [esp + slot_p]
    imul eax, eax, 0x552
    mov edx, dword ptr [ebp + 8]
    sub edx, dword ptr [eax + _ps + 540]
    mov ebx, 0x101
    {store} mov eax, edx
    sar edx, 0x1f
    idiv ebx
    movsx edx, word ptr [esp + slot_i]
    imul edx, edx, 0x2c
    add eax, 0x64
    mov word ptr [edx + _sprite + 34], ax
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1229:
    mov eax, dword ptr [esp + slot_t]
    cmp dword ptr [eax], 0x3e7
    {disp32} jne L1291
    mov ecx, dword ptr [esp + slot_i]
    cmp cx, word ptr [_ud + 1420]
    jne L1230
    mov eax, dword ptr [esp + slot_t]
    mov dword ptr [eax], 0
    jmp L1231
L1230:
    mov eax, dword ptr [esp + slot_t]
    mov dword ptr [eax], 0xfffffff6
L1231:
    mov eax, dword ptr [esp + slot_i]
    mov word ptr [_ud + 1420], ax
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1232:
    movsx edx, word ptr [esp + slot_p]
    imul edx, edx, 0x552
    movsx eax, word ptr [esp + slot_p]
    imul eax, eax, 0x552
    mov ecx, dword ptr [ebp + 4]
    {disp8} mov esi, dword ptr [ebp]
    mov edx, dword ptr [edx + _ps + 536]
    mov eax, dword ptr [eax + _ps + 532]
    {store} sub edx, ecx
    {store} sub eax, esi
    call getangle_
    mov word ptr [ebp + 28], ax
    mov eax, dword ptr [esp + slot_t]
    cmp dword ptr [eax], 0x3e7
    {disp32} jne L1291
    mov ebx, dword ptr [esp + slot_i]
    cmp bx, word ptr [_ud + 1420]
    jne L1233
    mov eax, dword ptr [esp + slot_t]
    mov dword ptr [eax], 0
    jmp L1234
L1233:
    mov eax, dword ptr [esp + slot_t]
    mov dword ptr [eax], 0xffffffec
L1234:
    mov eax, dword ptr [esp + slot_i]
    mov word ptr [_ud + 1420], ax
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1235:
    mov si, word ptr [ebp + 40]
    add esi, 0x40
    {store} mov eax, esi
    and ah, 7
    cwde
    mov word ptr [ebp + 40], si
    mov dx, word ptr [eax*2 + _sintable]
    movsx ebx, dx
    movsx eax, word ptr [ebp + 34]
    imul ebx
    shrd eax, edx, 0xc
    {store} mov edi, eax
    mov eax, dword ptr [ebp + 8]
    mov edx, dword ptr [esp + slot_sc]
    {store} add eax, edi
    mov dword ptr [edx + 8], eax
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1236:
    mov edi, dword ptr [eax]
    cmp edi, 1
    {disp32} jne L1291
    mov edx, dword ptr [eax + 12]
    test edx, edx
    jle L1237
    {store} mov esi, edx
    {store} sub esi, edi
    mov dword ptr [eax + 12], esi
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1237:
    cmp edi, dword ptr [eax + 8]
    {disp32} jne L1251
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 28], 0x600
    {disp32} je L1244
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    movsx eax, word ptr [eax + _sprite + 34]
    {disp32} lea edx, dword ptr [eax*2]
    mov eax, dword ptr [esp + slot_sc]
    mov esi, dword ptr [ebp + 8]
    mov eax, dword ptr [eax + 8]
    {store} sub eax, esi
    test eax, eax
    jns L1238
    neg eax
L1238:
    {store} cmp eax, edx
    jge L1239
    mov edx, dword ptr [esp + slot_sc]
    mov eax, dword ptr [ebp + 8]
    mov dword ptr [edx + 8], eax
    mov eax, dword ptr [esp + slot_t]
    mov dword ptr [eax + 8], 0
    mov dword ptr [eax], 0
    mov edx, dword ptr [esp + slot_t]
    movsx eax, word ptr [ebp + 40]
    mov dword ptr [edx + 12], eax
    movsx edx, word ptr [esp + slot_i]
    movsx eax, word ptr [ebp + 24]
    call callsound_
L1239:
    mov eax, dword ptr [esp + slot_t]
    mov edi, dword ptr [eax]
    test edi, edi
    je L1240
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    mov edx, dword ptr [esp + slot_sc]
    mov ebx, dword ptr [edx + 8]
    movsx edi, word ptr [eax + _sprite + 34]
    mov eax, dword ptr [ebp + 8]
    {store} sub eax, ebx
    {store} mov ebx, eax
    {store} add ebx, ebx
    {store} sbb eax, eax
    {store} cmp eax, ebx
    adc eax, 0
    imul edi, eax
    add dword ptr [edx + 8], edi
L1240:
    movsx eax, word ptr [ebp + 24]
    movsx esi, word ptr [eax*2 + _headspritesect]
L1241:
    test esi, esi
    {disp32} jl L1291
    imul eax, esi, 0x2c
    cmp word ptr [eax + _sprite + 14], 0x57d
    jne L1242
    cmp word ptr [eax + _sprite + 30], 0
    jl L1242
    movsx eax, word ptr [eax + _sprite + 34]
    imul eax, eax, 0x552
    cmp byte ptr [eax + _ps + 1308], 1
    jne L1242
    add dword ptr [eax + _ps + 540], edi
L1242:
    imul edx, esi, 0x2c
    cmp word ptr [edx + _sprite + 36], 0
    jne L1243
    cmp word ptr [edx + _sprite + 26], 3
    je L1243
    {disp32} lea eax, dword ptr [esi*8]
    {store} add eax, esi
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, esi
    mov ebx, dword ptr [edx + _sprite + 8]
    mov dword ptr [eax + _hittype + 43], ebx
    lea ebp, dword ptr [ebx + edi]
    mov dword ptr [edx + _sprite + 8], ebp
    mov edx, dword ptr [esp + slot_sc]
    mov edx, dword ptr [edx + 8]
    mov dword ptr [eax + _hittype + 19], edx
L1243:
    movsx esi, word ptr [esi*2 + _nextspritesect]
    {disp32} jmp L1241
L1244:
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    mov ebx, dword ptr [esp + slot_t]
    movsx edx, word ptr [eax + _sprite + 34]
    mov eax, dword ptr [esp + slot_sc]
    mov esi, dword ptr [ebx + 4]
    mov eax, dword ptr [eax + 8]
    {store} sub eax, esi
    {store} add edx, edx
    test eax, eax
    jns L1245
    neg eax
L1245:
    {store} cmp eax, edx
    jge L1246
    mov edx, dword ptr [esp + slot_sc]
    mov eax, dword ptr [ebx + 4]
    mov dword ptr [edx + 8], eax
    movsx edx, word ptr [esp + slot_i]
    movsx eax, word ptr [ebp + 24]
    call callsound_
    mov dword ptr [ebx + 8], 0
    mov dword ptr [ebx], 0
    movsx eax, word ptr [ebp + 40]
    mov dword ptr [ebx + 12], eax
L1246:
    mov eax, dword ptr [esp + slot_t]
    mov edi, dword ptr [eax]
    test edi, edi
    je L1247
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    mov edx, dword ptr [esp + slot_sc]
    movsx edi, word ptr [eax + _sprite + 34]
    mov eax, dword ptr [esp + slot_t]
    mov ebx, dword ptr [edx + 8]
    mov eax, dword ptr [eax + 4]
    {store} sub eax, ebx
    {store} mov ebx, eax
    {store} add ebx, ebx
    {store} sbb eax, eax
    {store} cmp eax, ebx
    adc eax, 0
    imul edi, eax
    add dword ptr [edx + 8], edi
L1247:
    movsx esi, word ptr [ebp + 24]
    movsx esi, word ptr [esi*2 + _headspritesect]
L1248:
    test esi, esi
    {disp32} jl L1291
    imul eax, esi, 0x2c
    cmp word ptr [eax + _sprite + 14], 0x57d
    jne L1249
    cmp word ptr [eax + _sprite + 30], 0
    jl L1249
    movsx eax, word ptr [eax + _sprite + 34]
    imul eax, eax, 0x552
    cmp byte ptr [eax + _ps + 1308], 1
    jne L1249
    add dword ptr [eax + _ps + 540], edi
L1249:
    imul edx, esi, 0x2c
    cmp word ptr [edx + _sprite + 36], 0
    jne L1250
    cmp word ptr [edx + _sprite + 26], 3
    je L1250
    {disp32} lea eax, dword ptr [esi*8]
    {store} add eax, esi
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, esi
    mov ebx, dword ptr [edx + _sprite + 8]
    mov dword ptr [eax + _hittype + 43], ebx
    {store} add ebx, edi
    mov dword ptr [edx + _sprite + 8], ebx
    mov edx, dword ptr [esp + slot_sc]
    mov edx, dword ptr [edx + 8]
    mov dword ptr [eax + _hittype + 19], edx
L1250:
    movsx esi, word ptr [esi*2 + _nextspritesect]
    {disp32} jmp L1248
L1251:
    mov ax, word ptr [ebp + 28]
    and ah, 7
    .att_syntax prefix
    cmpw $actors_ASM_math_16643,%ax
    .intel_syntax noprefix
    {disp32} jne L1258
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    movsx eax, word ptr [eax + _sprite + 34]
    mov ebx, dword ptr [esp + slot_sc]
    {disp32} lea edx, dword ptr [eax*2]
    mov esi, dword ptr [ebx + 8]
    mov eax, dword ptr [ebp + 8]
    {store} sub eax, esi
    test eax, eax
    jns L1252
    neg eax
L1252:
    {store} cmp eax, edx
    jge L1253
    movsx edx, word ptr [esp + slot_i]
    movsx eax, word ptr [ebp + 24]
    call callsound_
    mov eax, dword ptr [esp + slot_t]
    mov dword ptr [eax], 0
    mov dword ptr [eax + 8], edi
    mov edx, dword ptr [esp + slot_t]
    movsx eax, word ptr [ebp + 40]
    mov dword ptr [edx + 12], eax
L1253:
    mov eax, dword ptr [esp + slot_t]
    mov edi, dword ptr [eax]
    test edi, edi
    je L1254
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    mov edx, dword ptr [esp + slot_sc]
    mov ebx, dword ptr [edx + 8]
    movsx edi, word ptr [eax + _sprite + 34]
    mov eax, dword ptr [ebp + 8]
    {store} sub eax, ebx
    {store} mov ebx, eax
    {store} add ebx, ebx
    {store} sbb eax, eax
    {store} cmp eax, ebx
    adc eax, 0
    imul edi, eax
    add dword ptr [edx + 8], edi
L1254:
    movsx eax, word ptr [ebp + 24]
    movsx esi, word ptr [eax*2 + _headspritesect]
L1255:
    test esi, esi
    {disp32} jl L1291
    imul eax, esi, 0x2c
    cmp word ptr [eax + _sprite + 14], 0x57d
    jne L1256
    cmp word ptr [eax + _sprite + 30], 0
    jl L1256
    movsx eax, word ptr [eax + _sprite + 34]
    imul eax, eax, 0x552
    cmp byte ptr [eax + _ps + 1308], 1
    jne L1256
    add dword ptr [eax + _ps + 540], edi
L1256:
    imul edx, esi, 0x2c
    cmp word ptr [edx + _sprite + 36], 0
    jne L1257
    cmp word ptr [edx + _sprite + 26], 3
    je L1257
    {disp32} lea eax, dword ptr [esi*8]
    {store} add eax, esi
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, esi
    mov ebx, dword ptr [edx + _sprite + 8]
    mov dword ptr [eax + _hittype + 43], ebx
    lea ebp, dword ptr [ebx + edi]
    mov dword ptr [edx + _sprite + 8], ebp
    mov edx, dword ptr [esp + slot_sc]
    mov edx, dword ptr [edx + 8]
    mov dword ptr [eax + _hittype + 19], edx
L1257:
    movsx esi, word ptr [esi*2 + _nextspritesect]
    {disp32} jmp L1255
L1258:
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    movsx eax, word ptr [eax + _sprite + 34]
    {disp32} lea edx, dword ptr [eax*2]
    mov ebx, dword ptr [esp + slot_t]
    mov eax, dword ptr [esp + slot_sc]
    mov ecx, dword ptr [ebx + 4]
    mov eax, dword ptr [eax + 8]
    {store} sub eax, ecx
    test eax, eax
    jns L1259
    neg eax
L1259:
    {store} cmp eax, edx
    jge L1260
    mov dword ptr [ebx], 0
    movsx edx, word ptr [esp + slot_i]
    movsx eax, word ptr [ebp + 24]
    call callsound_
    mov dword ptr [ebx + 8], edi
    movsx eax, word ptr [ebp + 40]
    mov dword ptr [ebx + 12], eax
L1260:
    mov eax, dword ptr [esp + slot_t]
    cmp dword ptr [eax], 0
    jne L1261
    {store} xor edi, edi
    jmp L1262
L1261:
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    mov edx, dword ptr [esp + slot_t]
    mov ebx, dword ptr [edx + 4]
    movsx edi, word ptr [eax + _sprite + 34]
    mov eax, dword ptr [ebp + 8]
    {store} sub eax, ebx
    {store} mov ebx, eax
    {store} add ebx, ebx
    {store} sbb eax, eax
    {store} cmp eax, ebx
    adc eax, 0
    imul edi, eax
    mov eax, dword ptr [esp + slot_sc]
    sub dword ptr [eax + 8], edi
L1262:
    movsx eax, word ptr [ebp + 24]
    movsx esi, word ptr [eax*2 + _headspritesect]
L1263:
    test esi, esi
    {disp32} jl L1291
    imul eax, esi, 0x2c
    cmp word ptr [eax + _sprite + 14], 0x57d
    jne L1264
    cmp word ptr [eax + _sprite + 30], 0
    jl L1264
    movsx eax, word ptr [eax + _sprite + 34]
    imul eax, eax, 0x552
    cmp byte ptr [eax + _ps + 1308], 1
    jne L1264
    sub dword ptr [eax + _ps + 540], edi
L1264:
    imul edx, esi, 0x2c
    cmp word ptr [edx + _sprite + 36], 0
    jne L1265
    cmp word ptr [edx + _sprite + 26], 3
    je L1265
    {disp32} lea eax, dword ptr [esi*8]
    {store} add eax, esi
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, esi
    mov ebx, dword ptr [edx + _sprite + 8]
    mov dword ptr [eax + _hittype + 43], ebx
    {store} sub ebx, edi
    mov dword ptr [edx + _sprite + 8], ebx
    mov edx, dword ptr [esp + slot_sc]
    mov edx, dword ptr [edx + 8]
    mov dword ptr [eax + _hittype + 19], edx
L1265:
    movsx esi, word ptr [esi*2 + _nextspritesect]
    {disp32} jmp L1263
L1266:
    mov edi, dword ptr [eax]
    cmp edi, 1
    {disp32} jne L1291
    cmp edi, dword ptr [eax + 8]
    {disp32} jne L1272
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 28], 0x600
    {disp32} je L1269
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    movsx eax, word ptr [eax + _sprite + 34]
    {disp32} lea edx, dword ptr [eax*2]
    mov eax, dword ptr [esp + slot_sc]
    mov ebx, dword ptr [ebp + 8]
    mov eax, dword ptr [eax + 4]
    {store} sub eax, ebx
    test eax, eax
    jns L1267
    neg eax
L1267:
    {store} cmp eax, edx
    jge L1268
    mov edx, dword ptr [esp + slot_sc]
    mov eax, dword ptr [ebp + 8]
    mov dword ptr [edx + 4], eax
    movsx edx, word ptr [esp + slot_i]
    movsx eax, word ptr [ebp + 24]
    call callsound_
    mov eax, dword ptr [esp + slot_t]
    mov dword ptr [eax + 8], 0
    mov dword ptr [eax], 0
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1268:
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    mov ebx, dword ptr [esp + slot_sc]
    movsx edx, word ptr [eax + _sprite + 34]
    mov eax, dword ptr [ebp + 8]
    mov ecx, dword ptr [ebx + 4]
    {store} mov ebx, eax
    {store} sub ebx, ecx
    {store} add ebx, ebx
    {store} sbb eax, eax
    {store} cmp eax, ebx
    adc eax, 0
    imul eax, edx
    mov edx, dword ptr [esp + slot_sc]
    add dword ptr [edx + 4], eax
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1269:
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    movsx eax, word ptr [eax + _sprite + 34]
    {disp32} lea edx, dword ptr [eax*2]
    mov ebx, dword ptr [esp + slot_t]
    mov eax, dword ptr [esp + slot_sc]
    mov ecx, dword ptr [ebx + 4]
    mov eax, dword ptr [eax + 4]
    {store} sub eax, ecx
    test eax, eax
    jns L1270
    neg eax
L1270:
    {store} cmp eax, edx
    jge L1271
    mov edx, dword ptr [esp + slot_sc]
    mov eax, dword ptr [ebx + 4]
    mov dword ptr [edx + 4], eax
    movsx edx, word ptr [esp + slot_i]
    movsx eax, word ptr [ebp + 24]
    call callsound_
    mov dword ptr [ebx + 8], 0
    mov dword ptr [ebx], 0
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1271:
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    movsx edx, word ptr [eax + _sprite + 34]
    mov eax, dword ptr [ebx + 4]
    mov ebx, dword ptr [esp + slot_sc]
    mov esi, dword ptr [ebx + 4]
    {store} mov ebx, eax
    {store} sub ebx, esi
    {store} add ebx, ebx
    {store} sbb eax, eax
    {store} cmp eax, ebx
    adc eax, 0
    imul eax, edx
    mov edx, dword ptr [esp + slot_sc]
    add dword ptr [edx + 4], eax
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1272:
    mov ax, word ptr [ebp + 28]
    and ah, 7
    .att_syntax prefix
    cmpw $actors_ASM_math_17599,%ax
    .intel_syntax noprefix
    jne L1274
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    movsx eax, word ptr [eax + _sprite + 34]
    {disp32} lea edx, dword ptr [eax*2]
    mov eax, dword ptr [esp + slot_sc]
    mov ebx, dword ptr [ebp + 8]
    mov eax, dword ptr [eax + 4]
    {store} sub eax, ebx
    test eax, eax
    jns L1273
    neg eax
L1273:
    {store} cmp eax, edx
    {disp32} jge L1268
    mov eax, dword ptr [esp + slot_t]
    mov edi, dword ptr [eax + 8]
    mov dword ptr [eax], 0
    test edi, edi
    sete al
    {store} mov edx, eax
    mov eax, dword ptr [esp + slot_t]
    and edx, 0xff
    mov dword ptr [eax + 8], edx
    movsx edx, word ptr [esp + slot_i]
    movsx eax, word ptr [ebp + 24]
    call callsound_
    mov edx, dword ptr [esp + slot_sc]
    mov eax, dword ptr [ebp + 8]
    mov dword ptr [edx + 4], eax
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1274:
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    mov ebx, dword ptr [esp + slot_t]
    movsx edx, word ptr [eax + _sprite + 34]
    mov eax, dword ptr [esp + slot_sc]
    mov ecx, dword ptr [ebx + 4]
    mov eax, dword ptr [eax + 4]
    {store} sub eax, ecx
    {store} add edx, edx
    test eax, eax
    jns L1275
    neg eax
L1275:
    {store} cmp eax, edx
    jge L1276
    mov edx, dword ptr [ebx + 8]
    mov dword ptr [ebx], 0
    test edx, edx
    sete al
    {store} mov edx, eax
    and edx, 0xff
    mov dword ptr [ebx + 8], edx
    movsx edx, word ptr [esp + slot_i]
    movsx eax, word ptr [ebp + 24]
    call callsound_
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1276:
    movsx eax, word ptr [esp + slot_i]
    imul eax, eax, 0x2c
    movsx edx, word ptr [eax + _sprite + 34]
    mov eax, dword ptr [ebp + 8]
    mov esi, dword ptr [ebx + 4]
    {store} mov ebx, eax
    {store} sub ebx, esi
    {store} add ebx, ebx
    {store} sbb eax, eax
    {store} cmp eax, ebx
    adc eax, 0
    imul eax, edx
    mov edx, dword ptr [esp + slot_sc]
    sub dword ptr [edx + 4], eax
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1277:
    cmp byte ptr [_earthquaketime], 0
    {disp32} jbe L1291
    call krand_
    test al, 7
    {disp32} jne L1291
    mov eax, 5
    push eax
    movsx eax, word ptr [esp + slot_i+4]
    push eax
    mov edx, 0xfffffe00
    call krand_
    and eax, 0x7ff
    {store} sub edx, eax
    push edx
    call krand_
    xor ah, ah
    and al, 0x3f
    .att_syntax prefix
    addl $actors_ASM_math_17928,%eax
    .intel_syntax noprefix
    cwde
    push eax
    call krand_
    and ah, 7
    cwde
    push eax
    mov eax, 0x30
    push eax
    push eax
    mov eax, 0xfffffff8
    push eax
    call krand_
    xor ah, ah
    mov ecx, dword ptr [ebp + 8]
    and al, 0xf
    mov ebx, dword ptr [ebp + 4]
    .att_syntax prefix
    addl $actors_ASM_math_17973,%eax
    .intel_syntax noprefix
    {disp8} mov edx, dword ptr [ebp]
    cwde
    sub ecx, 0xc00
    push eax
    movsx eax, word ptr [ebp + 24]
    call EGS_
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1278:
    mov esi, dword ptr [eax]
    test esi, esi
    {disp32} je L1291
    cmp esi, 1
    jne L1279
    {store} mov eax, ebx
    movsx edx, word ptr [edx + 38]
    call shoot_
    jmp L1280
L1279:
    cmp esi, 0x82
    jne L1280
    mov dword ptr [eax], 0
L1280:
    mov eax, dword ptr [esp + slot_t]
    inc dword ptr [eax]
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1281:
    mov edx, dword ptr [eax + 8]
    shl edx, 5
    add edx, OFFSET FLAT:_wall
    mov ax, word ptr [edx + 14]
    or al, 0x20
    test ax, ax
    {disp32} je L1291
    mov bx, word ptr [edx + 14]
    xor bh, bh
    and bl, 0xcf
    mov word ptr [edx + 14], bx
    mov ah, byte ptr [edx + 14]
    or ah, 0x10
    mov cx, word ptr [edx + 10]
    mov byte ptr [edx + 14], ah
    test cx, cx
    jl L1282
    movsx eax, cx
    shl eax, 5
    and word ptr [eax + _wall + 14], 0xdf
    movsx eax, word ptr [edx + 10]
    shl eax, 5
    or byte ptr [eax + _wall + 14], 0x10
L1282:
    mov di, word ptr [edx + 18]
    inc edi
    mov ax, word ptr [edx + 10]
    mov word ptr [edx + 18], di
    test ax, ax
    jl L1283
    cwde
    shl eax, 5
    inc word ptr [eax + _wall + 18]
L1283:
    mov eax, dword ptr [esp + slot_t]
    mov ebx, dword ptr [esp + slot_t]
    mov eax, dword ptr [eax]
    cmp eax, dword ptr [ebx + 4]
    jl L1285
    mov cx, word ptr [edx + 14]
    xor ch, ch
    and cl, 0xae
    mov si, word ptr [edx + 10]
    mov word ptr [edx + 14], cx
    test si, si
    jl L1284
    movsx eax, si
    shl eax, 5
    and word ptr [eax + _wall + 14], 0xae
L1284:
    movsx eax, word ptr [esp + slot_i]
    call deletesprite_
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1285:
    inc dword ptr [ebx]
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1286:
    mov edx, dword ptr [eax]
    cmp edx, 0x50
    jle L1287
    {store} mov eax, ebx
    call deletesprite_
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1287:
    lea ecx, dword ptr [edx + 1]
    mov edx, dword ptr [esp + slot_sc]
    mov dword ptr [eax], ecx
    mov eax, dword ptr [esp + slot_sc]
    mov esi, dword ptr [edx + 4]
    mov eax, dword ptr [eax + 8]
    {store} sub eax, esi
    mov dword ptr [esp + slot_x], eax
    call krand_
    sar eax, 8
    .att_syntax prefix
    cmpl $actors_ASM_math_18317,%eax
    .intel_syntax noprefix
    {disp32} jl L1291
    mov edx, 0x762
    {store} mov eax, ebx
    call spawn_
    mov dword ptr [esp + slot_k], eax
    call krand_
    {store} mov dl, al
    movsx eax, word ptr [esp + slot_k]
    imul eax, eax, 0x2c
    and dl, 7
    add dl, 2
    mov byte ptr [eax + _sprite + 21], dl
    mov byte ptr [eax + _sprite + 20], dl
    call krand_
    {store} mov edx, eax
    mov edi, dword ptr [esp + slot_x]
    sar edx, 0x1f
    idiv edi
    {disp32} jmp L1290
L1288:
    mov ecx, dword ptr [eax]
    cmp ecx, 0x28
    jle L1289
    {store} mov eax, ebx
    call deletesprite_
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1289:
    lea esi, dword ptr [ecx + 1]
    mov dword ptr [eax], esi
    mov eax, dword ptr [edx + 8]
    mov edi, dword ptr [edx + 4]
    {store} sub eax, edi
    mov dword ptr [esp + slot_x], eax
    call krand_
    sar eax, 8
    .att_syntax prefix
    cmpl $actors_ASM_math_18444,%eax
    .intel_syntax noprefix
    {disp32} jl L1291
    mov edx, 0x762
    {store} mov eax, ebx
    call spawn_
    mov dword ptr [esp + slot_k], eax
    call krand_
    {store} mov dl, al
    movsx eax, word ptr [esp + slot_k]
    imul eax, eax, 0x2c
    and dl, 3
    add dl, 2
    mov byte ptr [eax + _sprite + 21], dl
    mov byte ptr [eax + _sprite + 20], dl
    call krand_
    {store} mov edx, eax
    mov ebp, dword ptr [esp + slot_x]
    sar edx, 0x1f
    idiv ebp
L1290:
    movsx ebx, word ptr [esp + slot_k]
    imul ebx, ebx, 0x2c
    mov eax, dword ptr [esp + slot_sc]
    mov eax, dword ptr [eax + 8]
    {store} sub eax, edx
    mov dword ptr [ebx + _sprite + 8], eax
    call krand_
    {store} mov edx, eax
    mov ecx, 0x1ff
    sar edx, 0x1f
    idiv ecx
    mov eax, 0x100
    {store} sub eax, edx
    {store} mov edx, eax
    movsx eax, word ptr [ebx + _sprite + 28]
    {store} add eax, edx
    mov word ptr [ebx + _sprite + 28], ax
    call krand_
    {store} mov edx, eax
    xor dh, ah
    movsx eax, word ptr [esp + slot_k]
    imul ebx, eax, 0x2c
    and dl, 0x7f
    mov word ptr [ebx + _sprite + 32], dx
    mov edx, 0x10001
    call ssp_
L1291:
    mov eax, dword ptr [esp + slot_nexti]
    {disp32} jmp L895
L1292:
    mov ax, word ptr [_headspritestat + 6]
    {disp32} jmp L1295
L1293:
    movsx eax, bx
    imul eax, eax, 0x2c
    mov ebp, OFFSET FLAT:_sprite
    {store} add ebp, eax
    cmp word ptr [ebp + 38], 0x1d
    jne L1294
    movsx esi, word ptr [ebp + 24]
    {disp32} lea eax, dword ptr [esi*4]
    {store} add eax, esi
    mov edx, OFFSET FLAT:_sector
    {disp32} lea eax, dword ptr [eax*8]
    {store} add edx, eax
    mov di, word ptr [edx + 2]
    mov dword ptr [esp + slot_sc], edx
    cmp di, 4
    jne L1294
    movsx eax, word ptr [edx]
    shl eax, 5
    mov edx, OFFSET FLAT:_wall
    add eax, 0x40
    {store} add edx, eax
    movsx ebx, word ptr [edx + 12]
    {disp32} lea eax, dword ptr [ebx*4]
    {store} add eax, ebx
    mov ecx, dword ptr [eax*8 + _sector + 8]
    mov ebx, dword ptr [edx + 4]
    {store} mov eax, esi
    mov edx, dword ptr [edx]
    call alignflorslope_
L1294:
    movsx eax, word ptr [esp + slot_i]
    mov ax, word ptr [eax*2 + _nextspritestat]
L1295:
    mov dword ptr [esp + slot_i], eax
    mov ebx, dword ptr [esp + slot_i]
    test bx, bx
    {disp32} jge L1293
    add esp, 0x58
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
.section CONST,"aw",@progbits
.p2align 2
L1296:
    .asciz "Could not find any locators for SE# 6 and 14 with a hitag of %ld.\n"
.section CONST2,"aw",@progbits
.p2align 2
.section _DATA,"aw",@progbits
.p2align 2
.section _BSS,"aw",@nobits
.p2align 4
_dmval:
    .zero 4 # existing genuine private compiler C storage
_otherp:
    .zero 2 # existing genuine public short otherp
# Real mathematical immediates, forward definitions preserve their instruction context
.equ actors_C_math_477, 80
.equ actors_C_math_485, 84
.equ actors_C_math_557, 80
.equ actors_C_math_565, 84
.equ actors_C_math_1182, 10
.equ actors_C_math_1230, 11
.equ actors_C_math_1540, 5
.equ actors_C_math_1548, 8
.equ actors_C_math_1586, 5
.equ actors_C_math_1625, 11
.equ actors_C_math_2768, 908
.equ actors_C_math_2774, 910
.equ actors_C_math_2780, 951
.equ actors_C_math_2786, 990
.equ actors_C_math_2792, 978
.equ actors_C_math_2946, 2566
.equ actors_C_math_4101, 7
.equ actors_C_math_4974, 16384
.equ actors_C_math_4996, 32768
.equ actors_C_math_5271, 16384
.equ actors_C_math_5360, 512
.equ actors_C_math_5794, 48
.equ actors_C_math_6425, 512
.equ actors_C_math_7153, 1232
.equ actors_C_math_7165, 1240
.equ actors_C_math_7173, 1390
.equ actors_C_math_7185, 2566
.equ actors_C_math_7196, 1238
.equ actors_C_math_7207, 1026
.equ actors_C_math_7215, 1062
.equ actors_C_math_7227, 1227
.equ actors_C_math_7237, 1229
.equ actors_C_math_7245, 904
.equ actors_C_math_7894, 1238
.equ actors_C_math_7902, 1670
.equ actors_C_math_7910, 2605
.equ actors_C_math_7921, 1247
.equ actors_C_math_7932, 981
.equ actors_C_math_7940, 1079
.equ actors_C_math_7951, 26
.equ actors_C_math_8937, 6912
.equ actors_C_math_10357, 1000
.equ actors_C_math_10367, 2000
.equ actors_C_math_11463, 916
.equ actors_C_math_11469, 2605
.equ actors_C_math_11475, 1670
.equ actors_C_math_11481, 1247
.equ actors_C_math_11487, 1079
.equ actors_C_math_11629, 1255
.equ actors_C_math_11635, 1250
.equ actors_C_math_11770, 64
.equ actors_C_math_11974, 4096
.equ actors_C_math_12038, 64
.equ actors_C_math_12076, 2390
.equ actors_C_math_12379, 6
.equ actors_C_math_12387, 10
.equ actors_C_math_12395, 1
.equ actors_C_math_12401, 2
.equ actors_C_math_12614, 16384
.equ actors_C_math_12663, 5120
.equ actors_C_math_12707, 16384
.equ actors_C_math_12979, 1
.equ actors_C_math_12987, 6
.equ actors_C_math_13119, 8192
.equ actors_C_math_13194, 192
.equ actors_C_math_13297, 16384
.equ actors_C_math_13619, 512
.equ actors_C_math_13698, 512
.equ actors_C_math_13932, 908
.equ actors_C_math_13938, 910
.equ actors_C_math_13944, 951
.equ actors_C_math_13950, 990
.equ actors_C_math_13956, 978
.equ actors_C_math_14293, 1024
.equ actors_C_math_14443, 2566
.equ actors_C_math_14560, 64
.equ actors_C_math_14598, 2390
.equ actors_C_math_15026, 512
.equ actors_C_math_15559, 512
.equ actors_C_math_15744, 546
.equ actors_C_math_15754, 549
.equ actors_C_math_15797, 916
.equ actors_C_math_15803, 2605
.equ actors_C_math_15809, 1670
.equ actors_C_math_15815, 1247
.equ actors_C_math_15821, 1079
.equ actors_C_math_16056, 64
.equ actors_C_math_16088, 2408
.equ actors_C_math_17261, 64
.equ actors_C_math_17299, 2390
.equ actors_C_math_17366, 1026
.equ actors_C_math_17382, 1240
.equ actors_C_math_17394, 1272
.equ actors_C_math_17406, 1390
.equ actors_C_math_17422, 2333
.equ actors_C_math_17441, 1250
.equ actors_C_math_17457, 1255
.equ actors_C_math_17476, 1227
.equ actors_C_math_17482, 1229
.equ actors_C_math_17492, 1232
.equ actors_C_math_17508, 1238
.equ actors_C_math_17527, 1062
.equ actors_C_math_17546, 502
.equ actors_C_math_17558, 662
.equ actors_C_math_17570, 904
.equ actors_C_math_17586, 921
.equ actors_C_math_17605, 634
.equ actors_C_math_17615, 637
.equ actors_C_math_17625, 660
.equ actors_C_math_17644, 8
.equ actors_C_math_17652, 160
.equ actors_C_math_17668, 499
.equ actors_C_math_17687, 3
.equ actors_C_math_17710, 1
.equ actors_C_math_17814, 21
.equ actors_C_math_17822, 31
.equ actors_C_math_17832, 32
.equ actors_C_math_17838, 36
.equ actors_C_math_17849, 2
.equ actors_C_math_17977, 1079
.equ actors_C_math_17985, 1247
.equ actors_C_math_19726, 64
.equ actors_C_math_19764, 2390
.equ actors_C_math_19930, 512
.equ actors_C_math_20541, 1646
.equ actors_C_math_20553, 2521
.equ actors_C_math_20565, 2595
.equ actors_C_math_20581, 2605
.equ actors_C_math_20600, 1647
.equ actors_C_math_20606, 1670
.equ actors_C_math_20625, 1625
.equ actors_C_math_20637, 1636
.equ actors_C_math_20653, 1641
.equ actors_C_math_20672, 1360
.equ actors_C_math_21001, 512
.equ actors_C_math_21518, 2605
.equ actors_C_math_21738, 256
.equ actors_C_math_21795, 49152
.equ actors_C_math_22192, 64
.equ actors_C_math_22230, 49152
.equ actors_C_math_22283, 49152
.equ actors_C_math_22559, 3
.equ actors_C_math_22799, 32768
.equ actors_C_math_22825, 2605
.equ actors_C_math_22835, 1641
.equ actors_C_math_22845, 1636
.equ actors_C_math_23161, 16384
.equ actors_C_math_24016, 4
.equ actors_C_math_24022, 5
.equ actors_C_math_24032, 10
.equ actors_C_math_24044, 13
.equ actors_C_math_24059, 1
.equ actors_C_math_24617, 6144
.equ actors_C_math_25172, 1792
.equ actors_C_math_25826, 4096
.equ actors_C_math_25921, 1630
.equ actors_C_math_25933, 2533
.equ actors_C_math_25945, 2535
.equ actors_C_math_25961, 2566
.equ actors_C_math_25976, 2270
.equ actors_C_math_25986, 2271
.equ actors_C_math_25996, 2310
.equ actors_C_math_26002, 2311
.equ actors_C_math_26014, 1261
.equ actors_C_math_26026, 1380
.equ actors_C_math_26038, 1420
.equ actors_C_math_26046, 661
.equ actors_C_math_26054, 952
.equ actors_C_math_26797, 4096
.equ actors_C_math_27373, 1346
.equ actors_C_math_27389, 2491
.equ actors_C_math_27401, 3190
.equ actors_C_math_27413, 3200
.equ actors_C_math_27429, 3210
.equ actors_C_math_27444, 2590
.equ actors_C_math_27459, 1960
.equ actors_C_math_27471, 2300
.equ actors_C_math_27487, 2370
.equ actors_C_math_27497, 2377
.equ actors_C_math_27512, 1650
.equ actors_C_math_27582, 901
.equ actors_C_math_27588, 902
.equ actors_C_math_27598, 1088
.equ actors_C_math_27610, 1096
.equ actors_C_math_27622, 1267
.equ actors_C_math_27634, 940
.equ actors_C_math_27646, 578
.equ actors_C_math_27658, 579
.equ actors_C_math_27668, 621
.equ actors_C_math_27683, 26
.equ actors_C_math_27981, 64
.equ actors_C_math_28019, 2390
.equ actors_C_math_28326, 128
.equ actors_C_math_29063, 64
.equ actors_C_math_29422, 128
.equ actors_C_math_29825, 8192
.equ actors_C_math_29978, 64
.equ actors_C_math_30016, 2390
.equ actors_C_math_30130, 1
.equ actors_C_math_30212, 64
.equ actors_C_math_30250, 2390
.equ actors_C_math_30803, 12288
.equ actors_C_math_31112, 1524
.equ actors_C_math_31209, 1524
.equ actors_C_math_31247, 256
.equ actors_C_math_31692, 255
.equ actors_C_math_32019, 1641
.equ actors_C_math_32076, 32
.equ actors_C_math_32327, 128
.equ actors_C_math_32638, 64
.equ actors_C_math_32676, 2408
.equ actors_C_math_33191, 2370
.equ actors_C_math_33240, 5
.equ actors_C_math_33319, 223
.equ actors_C_math_33802, 64
.equ actors_C_math_33840, 2408
.equ actors_C_math_34238, 2372
.equ actors_C_math_34327, 768
.equ actors_C_math_34371, 223
.equ actors_C_math_34424, 2000
.equ actors_C_math_34432, 2120
.equ actors_C_math_34440, 1680
.equ actors_C_math_34468, 768
.equ actors_C_math_34490, 8192
.equ actors_C_math_34673, 6144
.equ actors_C_math_34797, 512
.equ actors_C_math_34902, 512
.equ actors_C_math_34966, 251
.equ actors_C_math_35038, 49152
.equ actors_C_math_35111, 4294964224
.equ actors_C_math_35165, 4096
.equ actors_C_math_36235, 32768
.equ actors_C_math_36428, 940
.equ actors_C_math_36436, 1650
.equ actors_C_math_36444, 26
.equ actors_C_math_36592, 64
.equ actors_C_math_36630, 2390
.equ actors_C_math_37358, 580
.equ actors_C_math_37370, 1088
.equ actors_C_math_37382, 1092
.equ actors_C_math_37390, 1
.equ actors_C_math_37398, 578
.equ actors_C_math_38082, 64
.equ actors_C_math_38120, 2390
.equ actors_C_math_38246, 64
.equ actors_C_math_38284, 2390
.equ actors_C_math_38477, 64
.equ actors_C_math_38515, 2390
.equ actors_C_math_38900, 1776
.equ actors_C_math_38916, 2260
.equ actors_C_math_38932, 2329
.equ actors_C_math_38944, 2590
.equ actors_C_math_38956, 2612
.equ actors_C_math_38972, 3999
.equ actors_C_math_38987, 2533
.equ actors_C_math_39003, 2535
.equ actors_C_math_39018, 2286
.equ actors_C_math_39030, 2296
.equ actors_C_math_39040, 2299
.equ actors_C_math_39050, 2310
.equ actors_C_math_39060, 2311
.equ actors_C_math_39075, 2265
.equ actors_C_math_39091, 2270
.equ actors_C_math_39101, 2271
.equ actors_C_math_39173, 2205
.equ actors_C_math_39185, 2245
.equ actors_C_math_39197, 2250
.equ actors_C_math_39209, 2255
.equ actors_C_math_39221, 2209
.equ actors_C_math_39233, 2219
.equ actors_C_math_39248, 1890
.equ actors_C_math_39260, 2200
.equ actors_C_math_39276, 2201
.equ actors_C_math_39291, 1860
.equ actors_C_math_39301, 1861
.equ actors_C_math_39316, 1520
.equ actors_C_math_39332, 1630
.equ actors_C_math_39344, 1671
.equ actors_C_math_39356, 1768
.equ actors_C_math_39372, 1772
.equ actors_C_math_39387, 1647
.equ actors_C_math_39403, 1656
.equ actors_C_math_39418, 1536
.equ actors_C_math_39430, 1620
.equ actors_C_math_39446, 1625
.equ actors_C_math_39461, 1528
.equ actors_C_math_39476, 1031
.equ actors_C_math_39482, 1033
.equ actors_C_math_39492, 1233
.equ actors_C_math_39504, 1261
.equ actors_C_math_39520, 1380
.equ actors_C_math_39535, 1046
.equ actors_C_math_39547, 1226
.equ actors_C_math_39562, 661
.equ actors_C_math_39574, 925
.equ actors_C_math_39584, 926
.equ actors_C_math_39590, 1007
.equ actors_C_math_39600, 1009
.equ actors_C_math_39611, 142
.equ actors_C_math_39621, 145
.equ actors_C_math_40677, 512
.equ actors_C_math_40722, 1596
.equ actors_C_math_40774, 4
.equ actors_C_math_40808, 4
.equ actors_C_math_40960, 348
.equ actors_C_math_41315, 512
.equ actors_C_math_42702, 512
.equ actors_ASM_math_2494, 1024
.equ actors_ASM_math_2751, 247
.equ actors_ASM_math_2886, 27648
.equ actors_ASM_math_3172, 512
.equ actors_ASM_math_3339, 532
.equ actors_ASM_math_3550, 1
.equ actors_ASM_math_3556, 6
.equ actors_ASM_math_3712, 27648
.equ actors_ASM_math_4089, 6
.equ actors_ASM_math_4289, 1920
.equ actors_ASM_math_4360, 16
.equ actors_ASM_math_4417, 128
.equ actors_ASM_math_4629, 512
.equ actors_ASM_math_4699, 27648
.equ actors_ASM_math_5228, 1
.equ actors_ASM_math_5238, 6
.equ actors_ASM_math_5334, 1
.equ actors_ASM_math_5437, 27648
.equ actors_ASM_math_5777, 1
.equ actors_ASM_math_6167, 512
.equ actors_ASM_math_7388, 1024
.equ actors_ASM_math_7548, 223
.equ actors_ASM_math_8446, 27
.equ actors_ASM_math_8466, 23
.equ actors_ASM_math_8503, 27
.equ actors_ASM_math_10163, 64
.equ actors_ASM_math_10201, 2390
.equ actors_ASM_math_12613, 512
.equ actors_ASM_math_13406, 1024
.equ actors_ASM_math_13575, 512
.equ actors_ASM_math_13705, 5
.equ actors_ASM_math_13713, 6
.equ actors_ASM_math_13724, 1
.equ actors_ASM_math_13742, 672
.equ actors_ASM_math_13748, 673
.equ actors_ASM_math_13754, 1226
.equ actors_ASM_math_13762, 550
.equ actors_ASM_math_14143, 11776
.equ actors_ASM_math_14373, 239
.equ actors_ASM_math_14459, 8192
.equ actors_ASM_math_16643, 1536
.equ actors_ASM_math_17599, 1536
.equ actors_ASM_math_17928, 64
.equ actors_ASM_math_17973, 2390
.equ actors_ASM_math_18317, 191
.equ actors_ASM_math_18444, 223
