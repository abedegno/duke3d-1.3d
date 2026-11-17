; 22 frame-relative roles; compiler scratch names provisional humanization backlog.
; Physical shared slot preserves disjoint masters1471/2433; all alias offsets retained.
slot_x equ 0
slot_m equ 4
slot_moving_sprite_cursor_1604 equ 8
slot_shared_sector_or_sprite_index_1471_2433 equ 12
slot_zchange equ 20
slot_passenger_sector_index_1369 equ 24
slot_enemy_sprite_cursor_467 equ 28
slot_enemy_sprite_cursor_713 equ 32
slot_st equ 36
slot_passenger_player_cursor_1362 equ 40
slot_moving_sprite_cursor_1730 equ 44
slot_q equ 16
slot_player_state_cursor_100 equ 48
slot_t equ 52
slot_sc equ 56
slot_k equ 68
slot_sh equ 60
slot_nexti equ 64
slot_i equ 80
slot_p equ 76
slot_nextj equ 84
slot_nextk equ 72
; ACTORS symbolic assembly stand-in; humanization backlog: restore readable C identity.
; Copyright (C) 1996, 2003 - 3D Realms Entertainment
; Copyright (C) 2000, 2003 - Matt Saettler (EDuke Enhancements)
; Alternate assembler NASM 2.16.03; not original Watcom source or toolchain.
; Own-C translation and named-home provenance: evidence/actors-effector-source.json
; SPDX-License-Identifier: GPL-2.0-or-later; readable counterpart actors.c (default C body remains available)
bits 32
extern alignflorslope_
extern activatewarpelevators_
extern clipinsidebox_
extern activatebysector_
extern getanimationgoal_
extern operateforcefields_
extern _numplayers
extern _po
extern stopsound_
extern gameexit_
extern sprintf_
extern callsound_
extern _fricxv
extern _fricyv
extern getceilzofslope_
extern _camerashitable
extern _impact_damage
extern _bouncemineblastradius
extern _morterblastradius
extern LocateTheLocator_
extern shoot_
extern _respawnitemtime
extern _actor_tog
extern clearsoundlocks_
extern FX_StopAllSounds_
extern _sync
extern _rpgblastradius
extern _shrinkerblastradius
extern _ydim
extern _xdim
extern FindDistance2D_
extern _Sound
extern ksqrt_
extern operateactivators_
extern operatemasterswitches_
extern check_activator_motion_
extern loadtile_
extern _camsprite
extern operatesectors_
extern _seenineblastradius
extern _earthquaketime
extern _pipebombblastradius
extern hitasprite_
extern _tripbombblastradius
extern checkcursectnums_
extern _nextspritesect
extern _headspritesect
extern getglobalz_
extern _connectpoint2
extern sound_
extern _global_random
extern _myconnectindex
extern _connecthead
extern stopenvsound_
extern _numenvsnds
extern _NumVoices
extern FX_VoiceAvailable_
extern _soundpr
extern _soundm
extern _AmbienceToggle
extern FX_SetReverbDelay_
extern FX_SetReverb_
extern ldist_
extern _screenpeek
extern _SoundToggle
extern spawn_
extern makeitfall_
extern getincangle_
extern quickkill_
extern _max_player_health
extern execute_
extern findotherplayer_
extern deletesprite_
extern _cyclers
extern _numcyclers
extern check_fta_sounds_
extern changespritestat_
extern findplayer_
extern dragpoint_
extern rotatepoint_
extern _msx
extern _msy
extern getflorzofslope_
extern EGS_
extern _spriteq
extern _spriteqloc
extern _sintable
extern changespritesect_
extern clipmove_
extern _tilesizy
extern setsprite_
extern setpal_
extern getangle_
extern checkhitsprite_
extern dist_
extern _nextspritestat
extern _headspritestat
extern krand_
extern checkhitwall_
extern cansee_
extern updatesector_
extern checkhitceiling_
extern _wall
extern _tempbuf
extern _hittype
extern badguy_
extern FTA_
extern _ps
extern _ud
extern _sprite
extern spritesound_
extern _max_ammo_amount
extern _sector
extern _bakipos
extern _startofdynamicinterpolations
extern _oldipos
extern _curipos
extern _numinterpolations
extern gutsdir_
extern ifhitbyweapon_
extern ifhitsectors_
extern ms_
extern ssp_
segment _TEXT public align=1 use32 class=CODE
global moveeffectors_
; Own-C compiler boundary padding, now explicitly source-owned by this companion.
; Original instructions: LEA EAX,[EAX+disp32(0)] then LEA EDX,[EDX+disp32(0)].
actors_effector_boundary_padding:
    lea eax,[dword eax+0]
    lea edx,[dword edx+0]
moveeffectors_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    sub esp,strict byte 88
    xor edx,edx
    mov ax,word [_headspritestat+0x6]
    mov dword [_fricyv],edx
    mov dword [_fricxv],edx
L895:
    mov dword [esp+slot_i],eax
    mov edx,dword [esp+slot_i]
    test dx,dx
    jl near L1292
    movsx ebx,dx
    imul ebp,ebx,strict byte 44
    add ebp,_sprite
    mov ax,word [nosplit ebx*2+_nextspritestat]
    movsx edx,word [ebp+0x18]
    mov dword [esp+slot_nexti],eax
    lea eax,[edx*4+0x0]
    add eax,edx
    mov edx,_sector
    lea eax,[eax*8+0x0]
    add edx,eax
    movsx eax,word [ebp+0x26]
    mov dword [esp+slot_st],eax
    mov ax,word [ebp+0x28]
    mov dword [esp+slot_sh],eax
    lea eax,[ebx*8+0x0]
    add eax,ebx
    lea eax,[eax*8+0x0]
    sub eax,ebx
    add eax,_hittype
    mov dword [esp+slot_sc],edx
    add eax,strict byte 47
    mov ecx,dword [esp+slot_st]
    mov dword [esp+slot_t],eax
    cmp ecx,strict byte 20
    jb near L900
    jbe near L1171
    cmp ecx,strict byte 31
    jb short L898
    jbe near L1236
    cmp ecx,strict byte 35
    jb short L897
    jbe near L1204
    cmp ecx,strict dword 0x00000080
    jb short L896
    jbe near L1281
    cmp ecx,strict dword 0x00000082
    jb near L1291
    jbe near L1286
    cmp ecx,strict dword 0x00000083
    je near L1288
    jmp near L1291
L896:
    cmp ecx,strict byte 36
    je near L1278
    jmp near L1291
L897:
    cmp ecx,strict byte 33
    jb near L1266
    jbe near L1277
    jmp near L1190
L898:
    cmp ecx,strict byte 25
    jb short L899
    jbe near L1212
    cmp ecx,strict byte 27
    jb near L1216
    jbe near L1227
    cmp ecx,strict byte 29
    jb near L1291
    jbe near L1235
    jmp near L974
L899:
    cmp ecx,strict byte 22
    jb near L1182
    jbe near L1188
    cmp ecx,strict byte 24
    je near L1190
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L900:
    cmp ecx,strict byte 10
    jb short L902
    jbe near L1069
    cmp ecx,strict byte 14
    jb short L901
    jbe near L944
    cmp ecx,strict byte 16
    jb near L1128
    jbe near L1133
    cmp ecx,strict byte 17
    jbe near L1142
    cmp ecx,strict byte 19
    je near L1158
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L901:
    cmp ecx,strict byte 12
    jb near L1078
    jbe near L1089
    jmp near L1109
L902:
    cmp ecx,strict byte 3
    jb short L903
    jbe near L1020
    cmp ecx,strict byte 5
    jb near L1025
    jbe near L1038
    cmp ecx,strict byte 6
    jbe near L933
    cmp ecx,strict byte 8
    jb near L1291
    jmp near L1048
L903:
    cmp ecx,strict byte 1
    jb short L904
    jbe near L930
    jmp near L1007
L904:
    test ecx,ecx
    jne near L1291
    movsx esi,word [ebp+0x1e]
    imul eax,esi,strict byte 44
    mov dx,word [eax+_sprite+0x26]
    mov dword [esp+slot_zchange],ecx
    cmp dx,strict byte -1
    jne short L905
    movsx eax,word [esp+slot_i]
    call near deletesprite_
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L905:
    mov eax,dword [esp+slot_sc]
    movsx eax,word [eax+0x26]
    sar eax,0x03
    mov dword [esp+slot_q],eax
    mov eax,dword [esp+slot_sc]
    mov bx,word [eax+0x22]
    xor edi,edi
    cmp bx,strict byte 30
    jne near L918
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    mov ecx,dword [esp+slot_q]
    sar ecx,0x02
    mov bx,word [eax+_sprite+0x2a]
    mov dword [esp+slot_q],ecx
    cmp bx,strict byte 1
    jne near L911
    movsx edx,word [esp+slot_i]
    lea eax,[edx*8+0x0]
    add eax,edx
    lea eax,[eax*8+0x0]
    sub eax,edx
    cmp word [eax+_hittype+0x0b],strict word 0x0100
    jge short L908
    movsx edx,word [esp+slot_i]
    lea ebx,[edx*8+0x0]
    add ebx,edx
    lea ebx,[ebx*8+0x0]
    sub ebx,edx
    movsx edx,word [esp+slot_i]
    lea eax,[edx*8+0x0]
    add eax,edx
    mov cx,word [ebx+_hittype+0x0b]
    lea eax,[eax*8+0x0]
    add ecx,strict byte 4
    sub eax,edx
    mov word [ebx+_hittype+0x0b],cx
    cmp word [eax+_hittype+0x0b],strict word 0x0100
    jl short L906
    movsx edx,word [esp+slot_i]
    movsx eax,word [ebp+0x18]
    call near callsound_
L906:
    cmp byte [ebp+0x12],0x00
    je short L907
    mov edi,0x00000001
    jmp short L909
L907:
    mov edi,0x0ffffffff
    jmp short L909
L908:
    movsx edx,word [esp+slot_i]
    lea eax,[edx*8+0x0]
    add eax,edx
    lea eax,[eax*8+0x0]
    sub eax,edx
    mov word [eax+_hittype+0x0b],0x0100
L909:
    mov eax,dword [esp+slot_sc]
    mov edx,dword [ebp+0x8]
    cmp edx,dword [eax+0x8]
    jge short L910
    mov eax,dword [esp+slot_sc]
    mov edx,dword [eax+0x8]
    sub edx,strict dword 0x00000200
    mov dword [eax+0x8],edx
    mov ecx,0x0fffffe00
    mov ebx,dword [ebp+0x8]
    mov dword [esp+slot_zchange],ecx
    cmp edx,ebx
    jge near L923
    mov dword [eax+0x8],ebx
    jmp near L923
L910:
    mov eax,dword [esp+slot_sc]
    cmp edx,dword [eax+0x8]
    jle near L923
    mov eax,dword [esp+slot_sc]
    mov ecx,0x00000200
    mov edx,dword [eax+0x8]
    add edx,ecx
    mov dword [eax+0x8],edx
    mov ebx,dword [ebp+0x8]
    mov dword [esp+slot_zchange],ecx
    cmp edx,ebx
    jle near L923
    mov dword [eax+0x8],ebx
    jmp near L923
L911:
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    cmp word [eax+_sprite+0x2a],strict byte 3
    jne near L923
    movsx edx,word [esp+slot_i]
    lea eax,[edx*8+0x0]
    add eax,edx
    lea eax,[eax*8+0x0]
    sub eax,edx
    cmp word [eax+_hittype+0x0b],strict byte 0
    jle short L914
    movsx edx,word [esp+slot_i]
    lea ebx,[edx*8+0x0]
    add ebx,edx
    lea ebx,[ebx*8+0x0]
    sub ebx,edx
    movsx edx,word [esp+slot_i]
    lea eax,[edx*8+0x0]
    add eax,edx
    mov cx,word [ebx+_hittype+0x0b]
    lea eax,[eax*8+0x0]
    sub ecx,strict byte 4
    sub eax,edx
    mov word [ebx+_hittype+0x0b],cx
    cmp word [eax+_hittype+0x0b],strict byte 0
    jg short L912
    movsx edx,word [esp+slot_i]
    movsx eax,word [ebp+0x18]
    call near callsound_
L912:
    cmp byte [ebp+0x12],0x00
    je short L913
    mov edi,0x0ffffffff
    jmp short L915
L913:
    mov edi,0x00000001
    jmp short L915
L914:
    movsx edx,word [esp+slot_i]
    lea eax,[edx*8+0x0]
    add eax,edx
    lea eax,[eax*8+0x0]
    sub eax,edx
    xor ebx,ebx
    mov word [eax+_hittype+0x0b],bx
L915:
    movsx edx,word [esp+slot_i]
    lea eax,[edx*8+0x0]
    add eax,edx
    lea eax,[eax*8+0x0]
    sub eax,edx
    mov edx,dword [esp+slot_sc]
    mov ebx,dword [eax+_hittype+0x3b]
    cmp ebx,dword [edx+0x8]
    jge short L916
    mov dword [esp+slot_zchange],0x0fffffe00
    mov edx,dword [esp+slot_sc]
    mov ebx,dword [edx+0x8]
    sub ebx,strict dword 0x00000200
    mov dword [edx+0x8],ebx
    mov ecx,dword [eax+_hittype+0x3b]
    cmp ebx,ecx
    jge near L923
    jmp short L917
L916:
    mov edx,dword [esp+slot_sc]
    cmp ebx,dword [edx+0x8]
    jle near L923
    mov dword [esp+slot_zchange],0x00000200
    mov edx,dword [esp+slot_sc]
    mov ebx,dword [edx+0x8]
    add ebx,strict dword 0x00000200
    mov dword [edx+0x8],ebx
    mov ecx,dword [eax+_hittype+0x3b]
    cmp ebx,ecx
    jle near L923
L917:
    mov dword [edx+0x8],ecx
    jmp near L923
L918:
    lea eax,[esi*8+0x0]
    add eax,esi
    lea eax,[eax*8+0x0]
    sub eax,esi
    cmp dword [eax+_hittype+0x2f],strict byte 0
    je near L1291
    lea eax,[esi*8+0x0]
    add eax,esi
    lea eax,[eax*8+0x0]
    sub eax,esi
    cmp dword [eax+_hittype+0x2f],strict byte 2
    jne short L919
    movsx eax,word [esp+slot_i]
    call near deletesprite_
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L919:
    imul eax,esi,strict byte 44
    cmp word [eax+_sprite+0x1c],strict word 0x0400
    jle short L920
    mov edi,0x0ffffffff
    jmp short L921
L920:
    mov edi,0x00000001
L921:
    mov eax,dword [esp+slot_t]
    cmp dword [eax+0x0c],strict byte 0
    jne short L922
    imul edx,esi,strict byte 44
    mov eax,ebp
    add edx,_sprite
    call near ldist_
    mov edx,dword [esp+slot_t]
    mov dword [edx+0x0c],eax
L922:
    mov eax,dword [esp+slot_t]
    mov ax,word [eax+0x0c]
    mov word [ebp+0x20],ax
    imul eax,esi,strict byte 44
    mov edx,dword [eax+_sprite]
    mov dword [ebp+0x0],edx
    mov eax,dword [eax+_sprite+0x4]
    mov dword [ebp+0x4],eax
L923:
    mov eax,dword [esp+slot_q]
    imul eax,edi
    mov dx,word [ebp+0x1c]
    add edx,eax
    mov eax,dword [esp+slot_q]
    imul eax,edi
    mov word [ebp+0x1c],dx
    mov edx,dword [esp+slot_t]
    add dword [edx+0x8],eax
    test edi,edi
    je near L929
    mov eax,dword [esp+slot_sc]
    test byte [eax+0x0e],0x40
    je near L929
    mov ax,word [_connecthead]
    jmp near L926
L924:
    movsx eax,cx
    imul eax,strict dword 0x00000552
    mov dx,word [ebp+0x18]
    mov dword [esp+slot_player_state_cursor_100],eax
    cmp dx,word [eax+_ps+0x286]
    jne near L925
    mov eax,dword [esp+slot_player_state_cursor_100]
    cmp byte [eax+_ps+0x51c],0x01
    jne near L925
    mov eax,dword [esp+slot_q]
    imul eax,edi
    mov edx,dword [esp+slot_player_state_cursor_100]
    add word [edx+_ps+0x280],ax
    mov eax,edx
    mov dh,byte [edx+_ps+0x281]
    and dh,0x07
    mov byte [eax+_ps+0x281],dh
    mov edx,dword [esp+slot_player_state_cursor_100]
    mov eax,dword [esp+slot_zchange]
    mov ebx,dword [edx+_ps+0x21c]
    add ebx,eax
    mov eax,esp
    push eax
    lea eax,[esp+slot_m+4]
    push eax
    mov eax,dword [esp+slot_q+8]
    imul eax,edi
    push eax
    imul eax,esi,strict byte 44
    mov dword [edx+_ps+0x21c],ebx
    mov ecx,dword [edx+_ps+0x218]
    mov ebx,dword [edx+_ps+0x214]
    mov edx,dword [eax+_sprite+0x4]
    mov eax,dword [eax+_sprite]
    call near rotatepoint_
    mov edx,dword [esp+slot_player_state_cursor_100]
    mov eax,dword [esp+slot_m]
    mov ecx,dword [edx+_ps+0x214]
    mov ebx,dword [edx+_ps+0x230]
    sub eax,ecx
    add ebx,eax
    mov ecx,dword [edx+_ps+0x218]
    mov dword [edx+_ps+0x230],ebx
    mov eax,dword [esp+slot_x]
    mov ebx,dword [edx+_ps+0x234]
    sub eax,ecx
    add ebx,eax
    mov eax,dword [esp+slot_m]
    mov dword [edx+_ps+0x234],ebx
    mov dword [edx+_ps+0x214],eax
    mov eax,dword [esp+slot_x]
    mov dword [edx+_ps+0x218],eax
L925:
    movsx eax,word [esp+slot_p]
    mov ax,word [nosplit eax*2+_connectpoint2]
L926:
    mov dword [esp+slot_p],eax
    mov ecx,dword [esp+slot_p]
    test cx,cx
    jge near L924
    movsx eax,word [ebp+0x18]
    mov ax,word [nosplit eax*2+_headspritesect]
L927:
    mov dword [esp+slot_p],eax
    mov ecx,dword [esp+slot_p]
    test cx,cx
    jl near L929
    movsx eax,cx
    imul eax,strict byte 44
    mov dx,word [eax+_sprite+0x1a]
    cmp dx,strict byte 3
    je near L928
    cmp dx,strict byte 4
    je short L928
    cmp word [eax+_sprite+0x0e],strict word 0x057d
    je short L928
    mov edx,dword [esp+slot_q]
    imul edx,edi
    mov bx,word [eax+_sprite+0x1c]
    add ebx,edx
    mov ecx,dword [eax+_sprite+0x8]
    mov word [eax+_sprite+0x1c],bx
    mov edx,dword [esp+slot_zchange]
    mov bl,byte [eax+_sprite+0x1d]
    add ecx,edx
    mov edx,_sprite
    and bl,0x07
    mov dword [eax+_sprite+0x8],ecx
    add edx,eax
    mov byte [eax+_sprite+0x1d],bl
    lea ebx,[edx+0x4]
    mov ecx,dword [eax+_sprite+0x4]
    push ebx
    mov ebx,dword [eax+_sprite]
    imul eax,esi,strict byte 44
    push edx
    mov edx,dword [esp+slot_q+8]
    imul edx,edi
    push edx
    mov edx,dword [eax+_sprite+0x4]
    mov eax,dword [eax+_sprite]
    call near rotatepoint_
L928:
    movsx eax,word [esp+slot_p]
    mov ax,word [nosplit eax*2+_nextspritesect]
    jmp near L927
L929:
    movsx eax,word [esp+slot_i]
    call near ms_
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L930:
    movsx eax,word [ebp+0x1e]
    cmp eax,strict byte -1
    jne near L1291
    mov eax,dword [esp+slot_i]
    mov word [ebp+0x1e],ax
    mov ebx,dword [esp+slot_sh]
    movsx esi,word [_headspritestat+0x6]
L931:
    test esi,esi
    jl near L1291
    imul eax,esi,strict byte 44
    cmp word [eax+_sprite+0x26],strict byte 19
    jne short L932
    cmp bx,word [eax+_sprite+0x28]
    jne short L932
    mov eax,dword [esp+slot_t]
    mov dword [eax],0x00000000
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L932:
    movsx esi,word [nosplit esi*2+_nextspritestat]
    jmp short L931
L933:
    mov edx,dword [eax+0x10]
    test edx,edx
    jle short L937
    lea ebx,[edx-0x1]
    mov dword [eax+0x10],ebx
    cmp ebx,strict dword 0x000000e0
    jl short L934
    sub word [ebp+0x20],strict byte 8
L934:
    mov eax,dword [esp+slot_t]
    mov esi,dword [eax+0x10]
    cmp esi,strict byte 127
    jle short L935
    cmp esi,strict dword 0x000000e0
    jge short L935
    mov word [ebp+0x20],0x0000
L935:
    mov eax,dword [esp+slot_t]
    cmp dword [eax+0x10],strict dword 0x00000080
    jge short L936
    add word [ebp+0x20],strict byte 8
L936:
    mov eax,dword [esp+slot_t]
    cmp dword [eax+0x10],strict byte 96
    jge short L938
    mov dword [eax+0x10],0x00000000
L937:
    mov word [ebp+0x20],0x0100
L938:
    movsx esi,word [_headspritestat+0x6]
L939:
    test esi,esi
    jl near L943
    imul edx,esi,strict byte 44
    cmp word [edx+_sprite+0x26],strict byte 14
    jne near L942
    mov eax,dword [esp+slot_sh]
    cmp ax,word [edx+_sprite+0x28]
    jne near L942
    lea eax,[esi*8+0x0]
    add eax,esi
    lea eax,[eax*8+0x0]
    mov ebx,dword [esp+slot_t]
    sub eax,esi
    mov edi,dword [ebx]
    mov ecx,eax
    cmp edi,dword [eax+_hittype+0x2f]
    jne near L942
    mov ax,word [ebp+0x20]
    mov word [edx+_sprite+0x20],ax
    cmp dword [ecx+_hittype+0x43],strict byte 0
    jne short L940
    mov eax,_sprite
    add eax,edx
    mov edx,ebp
    call near dist_
    mov dword [ecx+_hittype+0x43],eax
L940:
    lea ebx,[esi*8+0x0]
    add ebx,esi
    lea ebx,[ebx*8+0x0]
    sub ebx,esi
    imul ecx,esi,strict byte 44
    mov eax,_sprite
    mov edx,ebp
    add eax,ecx
    call near dist_
    mov edx,dword [ebx+_hittype+0x43]
    mov ebx,eax
    sub ebx,edx
    add ebx,ebx
    sbb eax,eax
    cmp eax,ebx
    adc eax,strict byte 0
    mov di,word [ecx+_sprite+0x2a]
    mov dword [esp+slot_x],eax
    test di,di
    je short L941
    neg eax
    mov dword [esp+slot_x],eax
L941:
    mov eax,dword [esp+slot_x]
    mov dx,word [ebp+0x20]
    add edx,eax
    lea eax,[esi*8+0x0]
    add eax,esi
    mov word [ebp+0x20],dx
    lea eax,[eax*8+0x0]
    mov edx,dword [esp+slot_t]
    sub eax,esi
    mov edx,dword [edx+0x10]
    mov dword [eax+_hittype+0x3f],edx
L942:
    movsx esi,word [nosplit esi*2+_nextspritestat]
    jmp near L939
L943:
    xor eax,eax
    mov dword [esp+slot_x],eax
L944:
    movsx eax,word [ebp+0x1e]
    cmp eax,strict byte -1
    jne short L945
    mov edx,dword [esp+slot_t]
    mov eax,dword [esp+slot_t]
    movsx edx,word [edx]
    movsx eax,word [eax+0x0c]
    call near LocateTheLocator_
    mov word [ebp+0x1e],ax
L945:
    movsx eax,word [ebp+0x1e]
    cmp eax,strict byte -1
    jne short L946
    mov eax,dword [esp+slot_t]
    mov ebx,dword [eax+0x0c]
    push ebx
    push strict dword L1296
    push strict dword _tempbuf
    call near sprintf_
    add esp,strict byte 12
    mov eax,_tempbuf
    call near gameexit_
L946:
    movsx eax,word [ebp+0x1e]
    imul eax,strict byte 44
    mov edx,ebp
    add eax,_sprite
    call near ldist_
    cmp eax,strict dword 0x00000400
    jge short L948
    cmp dword [esp+slot_st],strict byte 6
    jne short L947
    movsx eax,word [ebp+0x1e]
    imul eax,strict byte 44
    test byte [eax+_sprite+0x28],0x01
    je short L947
    mov eax,dword [esp+slot_t]
    mov dword [eax+0x10],0x00000100
L947:
    mov eax,dword [esp+slot_t]
    inc dword [eax+0x0c]
    movsx edx,word [eax]
    movsx eax,word [eax+0x0c]
    call near LocateTheLocator_
    mov word [ebp+0x1e],ax
    cwde
    cmp eax,strict byte -1
    jne short L948
    mov eax,dword [esp+slot_t]
    mov dword [eax+0x0c],0x00000000
    movsx edx,word [eax]
    xor eax,eax
    call near LocateTheLocator_
    mov word [ebp+0x1e],ax
L948:
    cmp word [ebp+0x20],strict byte 0
    je near L1291
    movsx edx,word [ebp+0x1e]
    imul edx,strict byte 44
    mov edi,dword [ebp+0x4]
    mov ebx,dword [edx+_sprite+0x4]
    mov eax,dword [edx+_sprite]
    mov edx,dword [ebp+0x0]
    sub ebx,edi
    sub eax,edx
    mov edx,ebx
    call near getangle_
    mov dword [esp+slot_x],eax
    movsx edx,word [esp+slot_x]
    movsx eax,word [ebp+0x1c]
    call near getincangle_
    cwde
    mov edx,dword [esp+slot_t]
    sar eax,0x03
    mov ebx,dword [edx+0x8]
    add ebx,eax
    mov dword [esp+slot_q],eax
    mov dword [edx+0x8],ebx
    mov eax,dword [esp+slot_q]
    mov cx,word [ebp+0x1c]
    add ecx,eax
    mov si,word [ebp+0x20]
    mov word [ebp+0x1c],cx
    cmp si,strict word 0x0100
    jne near L950
    mov eax,dword [esp+slot_sc]
    test byte [eax+0x0e],0x01
    jne short L949
    test byte [eax+0x0c],0x01
    jne short L949
    cmp dword [_Sound+0x3d8],strict byte 0
    jne short L950
    movsx edx,word [esp+slot_i]
    mov eax,0x0000004b
    call near spritesound_
    jmp short L950
L949:
    call near krand_
    sar eax,0x08
    cmp eax,strict dword 0x000000f7
    jl short L950
    mov edx,esp
    mov eax,ebp
    call near findplayer_
    cmp dword [esp+slot_x],strict dword 0x00005000
    jge short L950
    movsx ebx,ax
    imul ebx,strict dword 0x00000552
    mov edx,dword [ebp+0x4]
    mov eax,dword [ebp+0x0]
    mov edi,dword [ebx+_ps+0x218]
    mov ecx,dword [ebx+_ps+0x214]
    sub edx,edi
    sub eax,ecx
    movsx esi,word [ebp+0x1c]
    call near getangle_
    mov edx,0x00000a2d
    mov word [ebp+0x1c],ax
    movsx eax,word [esp+slot_i]
    call near shoot_
    mov word [ebp+0x1c],si
L950:
    cmp word [ebp+0x20],strict byte 64
    jg short L951
    mov eax,dword [esp+slot_sc]
    test byte [eax+0x0e],0x01
    jne short L951
    test byte [eax+0x0c],0x01
    jne short L951
    mov eax,0x0000004b
    call near stopsound_
L951:
    mov eax,dword [esp+slot_sc]
    mov edx,dword [esp+slot_sc]
    mov eax,dword [eax+0x8]
    sub eax,dword [edx+0x4]
    cmp eax,strict dword 0x00006c00
    jge near L957
    cmp byte [_ud+0x8],0x00
    jne near L957
    cmp word [ebp+0x20],strict word 0x00c0
    jl near L957
    mov ax,word [_connecthead]
    jmp near L956
L952:
    movsx edx,dx
    imul edx,strict dword 0x00000552
    movsx eax,word [edx+_ps+0x2d4]
    imul eax,strict byte 44
    cmp word [eax+_sprite+0x2a],strict byte 0
    jle near L955
    mov ax,word [edx+_ps+0x286]
    lea ebx,[esp+slot_k]
    mov dword [esp+slot_k],eax
    mov eax,dword [edx+_ps+0x218]
    mov ecx,dword [edx+_ps+0x214]
    mov edx,eax
    mov eax,ecx
    call near updatesector_
    movsx eax,word [esp+slot_k]
    cmp eax,strict byte -1
    jne short L953
    cmp byte [_ud+0x8],0x00
    je short L954
L953:
    mov eax,dword [esp+slot_k]
    mov cx,word [ebp+0x18]
    cmp ax,cx
    jne short L955
    movsx eax,word [esp+slot_p]
    imul eax,strict dword 0x00000552
    cmp cx,word [eax+_ps+0x286]
    je short L955
L954:
    movsx esi,word [esp+slot_p]
    imul esi,strict dword 0x00000552
    mov eax,dword [ebp+0x0]
    mov dword [esi+_ps+0x214],eax
    mov eax,dword [ebp+0x4]
    mov dword [esi+_ps+0x218],eax
    mov ax,word [ebp+0x18]
    mov word [esi+_ps+0x286],ax
    mov ecx,dword [ebp+0x8]
    mov ebx,dword [ebp+0x4]
    mov edx,dword [ebp+0x0]
    movsx eax,word [esi+_ps+0x2d4]
    call near setsprite_
    mov eax,_ps
    add eax,esi
    call near quickkill_
L955:
    movsx eax,word [esp+slot_p]
    mov ax,word [nosplit eax*2+_connectpoint2]
L956:
    mov dword [esp+slot_p],eax
    mov edx,dword [esp+slot_p]
    test dx,dx
    jge near L952
L957:
    mov ax,word [_connecthead]
    jmp near L962
L958:
    movsx eax,word [ebp+0x1c]
    add eax,strict dword 0x00000200
    and eax,strict dword 0x000007ff
    movsx edx,word [ebp+0x20]
    movsx eax,word [nosplit eax*2+_sintable]
    imul eax,edx
    sar eax,0x0e
    mov dword [esp+slot_m],eax
    mov ax,word [ebp+0x1c]
    and ah,0x07
    cwde
    movsx edx,word [nosplit eax*2+_sintable]
    movsx eax,word [ebp+0x20]
    imul eax,edx
    movsx edx,di
    sar eax,0x0e
    shl edx,0x04
    mov dword [esp+slot_x],eax
    mov ax,word [edx+_po+0x0e]
    cmp ax,word [ebp+0x18]
    jne short L959
    mov eax,dword [esp+slot_m]
    mov ebx,dword [edx+_po]
    mov ecx,dword [edx+_po+0x4]
    add ebx,eax
    mov eax,dword [esp+slot_x]
    mov dword [edx+_po],ebx
    add ecx,eax
    mov dword [edx+_po+0x4],ecx
L959:
    movsx esi,word [esp+slot_p]
    imul esi,strict dword 0x00000552
    movsx eax,word [esi+_ps+0x2d4]
    imul eax,strict byte 44
    mov dx,word [ebp+0x18]
    cmp dx,word [eax+_sprite+0x18]
    jne near L961
    mov eax,_ps
    add eax,esi
    lea edx,[eax+0x218]
    push edx
    add eax,strict dword 0x00000214
    mov edi,dword [esp+slot_q+4]
    push eax
    mov ecx,dword [esi+_ps+0x218]
    mov ebx,dword [esi+_ps+0x214]
    push edi
    mov edx,dword [ebp+0x4]
    mov eax,dword [ebp+0x0]
    call near rotatepoint_
    mov eax,dword [esp+slot_m]
    mov edx,dword [esi+_ps+0x214]
    mov ebx,dword [esi+_ps+0x218]
    mov ecx,dword [esi+_ps+0x230]
    add edx,eax
    mov eax,dword [esp+slot_x]
    mov edi,dword [esi+_ps+0x234]
    add ebx,eax
    mov eax,dword [esp+slot_m]
    mov dword [esi+_ps+0x214],edx
    add ecx,eax
    mov eax,dword [esp+slot_x]
    mov dword [esi+_ps+0x218],ebx
    add edi,eax
    mov dword [esi+_ps+0x234],edi
    mov di,word [_numplayers]
    mov dword [esi+_ps+0x230],ecx
    cmp di,strict byte 1
    jle short L960
    mov eax,dword [esi+_ps+0x214]
    mov dword [esi+_ps+0x238],eax
L960:
    movsx eax,word [esp+slot_p]
    imul eax,strict dword 0x00000552
    mov edx,dword [esp+slot_q]
    add word [eax+_ps+0x280],dx
L961:
    movsx eax,word [esp+slot_p]
    mov ax,word [nosplit eax*2+_connectpoint2]
L962:
    mov dword [esp+slot_p],eax
    mov edi,dword [esp+slot_p]
    test di,di
    jge near L958
    movsx eax,word [ebp+0x18]
    movsx esi,word [nosplit eax*2+_headspritesect]
L963:
    test esi,esi
    jl near L965
    imul edi,esi,strict byte 44
    mov ax,word [edi+_sprite+0x0e]
    cmp ax,strict word 0x0001
    je short L964
    cmp ax,strict word 0x0006
    je short L964
    mov eax,_sprite
    add eax,edi
    lea edx,[eax+0x4]
    push edx
    mov ecx,dword [esp+slot_q+4]
    push eax
    mov ebx,dword [edi+_sprite]
    mov edx,dword [ebp+0x4]
    push ecx
    mov eax,dword [ebp+0x0]
    mov ecx,dword [edi+_sprite+0x4]
    call near rotatepoint_
    mov eax,dword [esp+slot_m]
    mov edx,dword [edi+_sprite]
    mov ebx,dword [edi+_sprite+0x4]
    add edx,eax
    mov eax,dword [esp+slot_x]
    add ebx,eax
    mov dword [edi+_sprite+0x4],ebx
    mov eax,dword [esp+slot_q]
    mov bx,word [edi+_sprite+0x1c]
    mov dword [edi+_sprite],edx
    add ebx,eax
    mov word [edi+_sprite+0x1c],bx
L964:
    movsx esi,word [nosplit esi*2+_nextspritesect]
    jmp near L963
L965:
    movsx esi,word [esp+slot_i]
    mov eax,esi
    call near ms_
    mov eax,esi
    mov ecx,dword [ebp+0x8]
    mov ebx,dword [ebp+0x4]
    mov edx,dword [ebp+0x0]
    call near setsprite_
    mov eax,dword [esp+slot_sc]
    mov edx,dword [esp+slot_sc]
    mov eax,dword [eax+0x8]
    sub eax,dword [edx+0x4]
    cmp eax,strict dword 0x00006c00
    jge near L1291
    cmp byte [_ud+0x8],0x00
    jne near L971
    cmp word [ebp+0x20],strict word 0x00c0
    jl near L971
    mov ax,word [_connecthead]
    jmp near L970
L966:
    movsx edx,cx
    imul edx,strict dword 0x00000552
    movsx eax,word [edx+_ps+0x2d4]
    imul eax,strict byte 44
    cmp word [eax+_sprite+0x2a],strict byte 0
    jle near L969
    mov ax,word [edx+_ps+0x286]
    lea ebx,[esp+slot_k]
    mov dword [esp+slot_k],eax
    mov eax,dword [edx+_ps+0x218]
    mov ecx,dword [edx+_ps+0x214]
    mov edx,eax
    mov eax,ecx
    call near updatesector_
    movsx eax,word [esp+slot_k]
    cmp eax,strict byte -1
    jne short L967
    cmp byte [_ud+0x8],0x00
    je short L968
L967:
    mov eax,dword [esp+slot_k]
    mov di,word [ebp+0x18]
    cmp ax,di
    jne short L969
    movsx eax,word [esp+slot_p]
    imul eax,strict dword 0x00000552
    cmp di,word [eax+_ps+0x286]
    je short L969
L968:
    movsx esi,word [esp+slot_p]
    imul esi,strict dword 0x00000552
    mov eax,dword [ebp+0x0]
    mov dword [esi+_ps+0x214],eax
    mov eax,dword [ebp+0x4]
    mov dword [esi+_ps+0x218],eax
    mov ax,word [ebp+0x18]
    mov word [esi+_ps+0x286],ax
    mov ecx,dword [ebp+0x8]
    mov ebx,dword [ebp+0x4]
    mov edx,dword [ebp+0x0]
    movsx eax,word [esi+_ps+0x2d4]
    call near setsprite_
    mov eax,_ps
    add eax,esi
    call near quickkill_
L969:
    movsx eax,word [esp+slot_p]
    mov ax,word [nosplit eax*2+_connectpoint2]
L970:
    mov dword [esp+slot_p],eax
    mov ecx,dword [esp+slot_p]
    test cx,cx
    jge near L966
L971:
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    movsx eax,word [eax+_sprite+0x1e]
    imul eax,strict byte 44
    movsx eax,word [eax+_sprite+0x18]
    movsx esi,word [nosplit eax*2+_headspritesect]
L972:
    test esi,esi
    jl near L1291
    imul ecx,esi,strict byte 44
    mov bx,word [ecx+_sprite+0x1a]
    movsx edi,word [nosplit esi*2+_nextspritesect]
    cmp bx,strict byte 1
    jne near L973
    mov eax,_sprite
    add eax,ecx
    mov dword [esp+slot_enemy_sprite_cursor_467],eax
    call near badguy_
    test ax,ax
    je near L973
    mov ax,word [ecx+_sprite+0x0e]
    cmp ax,bx
    je short L973
    cmp ax,strict word 0x0006
    je short L973
    lea ebx,[esp+slot_k]
    mov ax,word [ecx+_sprite+0x18]
    mov edx,dword [ecx+_sprite+0x4]
    mov dword [esp+slot_k],eax
    mov eax,dword [ecx+_sprite]
    call near updatesector_
    cmp word [ecx+_sprite+0x2a],strict byte 0
    jl short L973
    mov eax,dword [esp+slot_k]
    cmp ax,word [ebp+0x18]
    jne short L973
    mov ebx,0x00000048
    mov edx,0x000008ee
    mov eax,dword [esp+slot_enemy_sprite_cursor_467]
    movsx ecx,word [_myconnectindex]
    call near gutsdir_
    movsx edx,word [esp+slot_i]
    mov eax,0x00000045
    call near spritesound_
    mov eax,esi
    call near deletesprite_
L973:
    mov esi,edi
    jmp near L972
L974:
    movsx eax,word [ebp+0x1e]
    cmp eax,strict byte -1
    jne short L975
    mov eax,dword [esp+slot_t]
    cmp dword [eax+0x0c],strict byte 0
    sete al
    mov edx,eax
    mov eax,dword [esp+slot_t]
    and edx,strict dword 0x000000ff
    mov dword [eax+0x0c],edx
    movsx edx,word [eax]
    movsx eax,word [eax+0x0c]
    call near LocateTheLocator_
    mov word [ebp+0x1e],ax
    jmp near L983
L975:
    mov eax,dword [esp+slot_t]
    cmp dword [eax+0x10],strict byte 1
    jne short L978
    movsx eax,word [ebp+0x1e]
    imul eax,strict byte 44
    mov ebx,_sprite
    mov edx,ebp
    add eax,ebx
    call near ldist_
    cmp eax,strict dword 0x00000780
    jge short L976
    mov eax,dword [esp+slot_t]
    mov dword [eax+0x10],0x00000002
    jmp short L978
L976:
    cmp word [ebp+0x20],strict byte 0
    jne short L977
    mov eax,dword [esp+slot_t]
    mov ebx,dword [eax+0x0c]
    mov edx,0x0ffffffff
    test ebx,ebx
    sete al
    mov si,word [ebp+0x28]
    xor ah,ah
    add eax,esi
    cwde
    call near operateactivators_
L977:
    mov di,word [ebp+0x20]
    cmp di,strict word 0x0100
    jge short L978
    mov eax,edi
    add eax,strict dword 0x00000010
    mov word [ebp+0x20],ax
L978:
    mov eax,dword [esp+slot_t]
    cmp dword [eax+0x10],strict byte 2
    jne near L983
    movsx ebx,word [ebp+0x1e]
    imul ebx,strict byte 44
    mov esi,dword [ebp+0x4]
    mov edi,dword [ebp+0x0]
    mov edx,dword [ebx+_sprite+0x4]
    mov eax,dword [ebx+_sprite]
    sub edx,esi
    sub eax,edi
    call near FindDistance2D_
    cmp eax,strict dword 0x00000080
    jg short L979
    mov word [ebp+0x20],0x0000
L979:
    mov dx,word [ebp+0x20]
    test dx,dx
    jle short L980
    mov ecx,edx
    sub ecx,strict byte 16
    mov word [ebp+0x20],cx
    jmp near L983
L980:
    mov word [ebp+0x20],0x0000
    mov edx,dword [esp+slot_t]
    mov ax,word [ebp+0x28]
    add ax,word [edx+0x0c]
    mov edx,0x0ffffffff
    cwde
    call near operateactivators_
    mov cl,byte [ebp+0x1d]
    mov word [ebp+0x1e],0x0ffff
    add cl,0x04
    mov eax,dword [esp+slot_t]
    mov byte [ebp+0x1d],cl
    mov dword [eax+0x10],0x00000000
    movsx eax,word [esp+slot_i]
    movsx edx,word [ebp+0x28]
    call near operateforcefields_
    movsx eax,word [ebp+0x18]
    movsx esi,word [nosplit eax*2+_headspritesect]
L981:
    test esi,esi
    jl short L983
    imul edx,esi,strict byte 44
    mov bx,word [edx+_sprite+0x0e]
    cmp bx,strict byte 1
    je short L982
    cmp bx,strict byte 6
    je short L982
    lea eax,[esi*8+0x0]
    add eax,esi
    lea eax,[eax*8+0x0]
    sub eax,esi
    mov ebx,dword [edx+_sprite]
    mov edx,dword [edx+_sprite+0x4]
    mov dword [eax+_hittype+0x23],ebx
    mov dword [eax+_hittype+0x27],edx
L982:
    movsx esi,word [nosplit esi*2+_nextspritesect]
    jmp short L981
L983:
    mov si,word [ebp+0x20]
    test si,si
    je near L1291
    movsx eax,word [ebp+0x1c]
    add eax,strict dword 0x00000200
    and eax,strict dword 0x000007ff
    movsx edi,word [nosplit eax*2+_sintable]
    movsx eax,si
    imul edi,eax
    mov dx,word [ebp+0x1c]
    and dh,0x07
    movsx edx,dx
    movsx edx,word [nosplit edx*2+_sintable]
    imul eax,edx
    sar eax,0x0e
    mov edx,dword [esp+slot_sc]
    mov dword [esp+slot_x],eax
    mov eax,dword [esp+slot_sc]
    mov ebx,dword [edx+0x4]
    mov eax,dword [eax+0x8]
    sub eax,ebx
    sar edi,0x0e
    cmp eax,strict dword 0x00006c00
    jge near L989
    cmp byte [_ud+0x8],0x00
    jne near L989
    mov ax,word [_connecthead]
    jmp near L988
L984:
    movsx edx,ax
    imul edx,strict dword 0x00000552
    movsx eax,word [edx+_ps+0x2d4]
    imul eax,strict byte 44
    cmp word [eax+_sprite+0x2a],strict byte 0
    jle near L987
    lea ebx,[esp+slot_k]
    mov ax,word [edx+_ps+0x286]
    mov ecx,dword [edx+_ps+0x218]
    mov dword [esp+slot_k],eax
    mov eax,dword [edx+_ps+0x214]
    mov edx,ecx
    call near updatesector_
    movsx eax,word [esp+slot_k]
    cmp eax,strict byte -1
    jne short L985
    cmp byte [_ud+0x8],0x00
    je short L986
L985:
    mov eax,dword [esp+slot_k]
    mov cx,word [ebp+0x18]
    cmp ax,cx
    jne short L987
    movsx eax,word [esp+slot_p]
    imul eax,strict dword 0x00000552
    cmp cx,word [eax+_ps+0x286]
    je short L987
L986:
    movsx esi,word [esp+slot_p]
    imul esi,strict dword 0x00000552
    mov eax,dword [ebp+0x0]
    mov dword [esi+_ps+0x214],eax
    mov eax,dword [ebp+0x4]
    mov dword [esi+_ps+0x218],eax
    mov ax,word [ebp+0x18]
    mov word [esi+_ps+0x286],ax
    mov ecx,dword [ebp+0x8]
    mov ebx,dword [ebp+0x4]
    mov edx,dword [ebp+0x0]
    movsx eax,word [esi+_ps+0x2d4]
    call near setsprite_
    mov eax,_ps
    add eax,esi
    call near quickkill_
L987:
    movsx eax,word [esp+slot_p]
    mov ax,word [nosplit eax*2+_connectpoint2]
L988:
    mov dword [esp+slot_p],eax
    mov eax,dword [esp+slot_p]
    test ax,ax
    jge near L984
L989:
    mov ax,word [_connecthead]
    jmp near L994
L990:
    movsx edx,ax
    imul edx,strict dword 0x00000552
    movsx eax,word [edx+_ps+0x2d4]
    imul eax,strict byte 44
    mov bx,word [ebp+0x18]
    cmp bx,word [eax+_sprite+0x18]
    jne short L992
    mov eax,dword [esp+slot_x]
    mov ecx,dword [edx+_ps+0x214]
    mov esi,dword [edx+_ps+0x218]
    add ecx,edi
    add esi,eax
    mov dword [edx+_ps+0x214],ecx
    mov cx,word [_numplayers]
    mov dword [edx+_ps+0x218],esi
    cmp cx,strict byte 1
    jle short L991
    mov eax,dword [edx+_ps+0x214]
    mov dword [edx+_ps+0x238],eax
    mov eax,dword [edx+_ps+0x218]
    mov dword [edx+_ps+0x23c],eax
L991:
    movsx edx,word [esp+slot_p]
    imul edx,strict dword 0x00000552
    mov eax,dword [edx+_ps+0x230]
    add eax,edi
    mov ebx,dword [edx+_ps+0x234]
    mov dword [edx+_ps+0x230],eax
    mov eax,dword [esp+slot_x]
    add ebx,eax
    mov dword [edx+_ps+0x234],ebx
L992:
    movsx edx,word [esp+slot_p]
    shl edx,0x04
    mov si,word [ebp+0x18]
    cmp si,word [edx+_po+0x0e]
    jne short L993
    mov eax,dword [esp+slot_x]
    mov ecx,dword [edx+_po]
    mov esi,dword [edx+_po+0x4]
    add ecx,edi
    add esi,eax
    mov dword [edx+_po],ecx
    mov dword [edx+_po+0x4],esi
L993:
    movsx eax,word [esp+slot_p]
    mov ax,word [nosplit eax*2+_connectpoint2]
L994:
    mov dword [esp+slot_p],eax
    mov eax,dword [esp+slot_p]
    test ax,ax
    jge near L990
    movsx eax,word [ebp+0x18]
    mov cx,word [_numplayers]
    movsx esi,word [nosplit eax*2+_headspritesect]
L995:
    test esi,esi
    jl near L998
    imul edx,esi,strict byte 44
    mov ax,word [edx+_sprite+0x0e]
    cmp ax,strict word 0x0001
    je near L997
    cmp ax,strict word 0x0006
    je near L997
    cmp cx,strict byte 2
    jge short L996
    lea eax,[esi*8+0x0]
    add eax,esi
    lea eax,[eax*8+0x0]
    sub eax,esi
    mov ebx,dword [edx+_sprite]
    mov edx,dword [edx+_sprite+0x4]
    mov dword [eax+_hittype+0x23],ebx
    mov dword [eax+_hittype+0x27],edx
L996:
    imul edx,esi,strict byte 44
    mov eax,dword [edx+_sprite]
    add eax,edi
    mov ebx,dword [edx+_sprite+0x4]
    mov dword [edx+_sprite],eax
    add ebx,dword [esp+slot_x]
    mov ax,word [_numplayers]
    mov dword [edx+_sprite+0x4],ebx
    cmp ax,strict word 0x0001
    jle short L997
    lea eax,[esi*8+0x0]
    add eax,esi
    lea eax,[eax*8+0x0]
    sub eax,esi
    mov ebx,dword [edx+_sprite]
    mov edx,dword [edx+_sprite+0x4]
    mov dword [eax+_hittype+0x23],ebx
    mov dword [eax+_hittype+0x27],edx
L997:
    movsx esi,word [nosplit esi*2+_nextspritesect]
    jmp near L995
L998:
    movsx esi,word [esp+slot_i]
    mov eax,esi
    call near ms_
    mov eax,esi
    mov ecx,dword [ebp+0x8]
    mov ebx,dword [ebp+0x4]
    mov edx,dword [ebp+0x0]
    call near setsprite_
    mov eax,dword [esp+slot_sc]
    mov edx,dword [esp+slot_sc]
    mov eax,dword [eax+0x8]
    sub eax,dword [edx+0x4]
    cmp eax,strict dword 0x00006c00
    jge near L1291
    cmp byte [_ud+0x8],0x00
    jne near L1004
    mov ax,word [_connecthead]
    jmp near L1003
L999:
    movsx edx,dx
    imul edx,strict dword 0x00000552
    movsx eax,word [edx+_ps+0x2d4]
    imul eax,strict byte 44
    cmp word [eax+_sprite+0x2a],strict byte 0
    jle near L1002
    lea ebx,[esp+slot_k]
    mov ax,word [edx+_ps+0x286]
    mov ecx,dword [edx+_ps+0x218]
    mov dword [esp+slot_k],eax
    mov eax,dword [edx+_ps+0x214]
    mov edx,ecx
    call near updatesector_
    movsx eax,word [esp+slot_k]
    cmp eax,strict byte -1
    jne short L1000
    cmp byte [_ud+0x8],0x00
    je short L1001
L1000:
    mov eax,dword [esp+slot_k]
    mov cx,word [ebp+0x18]
    cmp ax,cx
    jne short L1002
    movsx eax,word [esp+slot_p]
    imul eax,strict dword 0x00000552
    cmp cx,word [eax+_ps+0x286]
    je short L1002
L1001:
    movsx esi,word [esp+slot_p]
    imul esi,strict dword 0x00000552
    mov eax,dword [ebp+0x0]
    mov dword [esi+_ps+0x214],eax
    mov eax,dword [ebp+0x4]
    mov dword [esi+_ps+0x218],eax
    mov eax,dword [esi+_ps+0x214]
    mov dword [esi+_ps+0x238],eax
    mov eax,dword [esi+_ps+0x218]
    mov dword [esi+_ps+0x23c],eax
    mov ax,word [ebp+0x18]
    mov word [esi+_ps+0x286],ax
    mov ecx,dword [ebp+0x8]
    mov ebx,dword [ebp+0x4]
    mov edx,dword [ebp+0x0]
    movsx eax,word [esi+_ps+0x2d4]
    call near setsprite_
    mov eax,_ps
    add eax,esi
    call near quickkill_
L1002:
    movsx eax,word [esp+slot_p]
    mov ax,word [nosplit eax*2+_connectpoint2]
L1003:
    mov dword [esp+slot_p],eax
    mov edx,dword [esp+slot_p]
    test dx,dx
    jge near L999
L1004:
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    movsx eax,word [eax+_sprite+0x1e]
    imul eax,strict byte 44
    movsx eax,word [eax+_sprite+0x18]
    movsx esi,word [nosplit eax*2+_headspritesect]
L1005:
    test esi,esi
    jl near L1291
    imul ecx,esi,strict byte 44
    mov ax,word [ecx+_sprite+0x1a]
    movsx edi,word [nosplit esi*2+_nextspritesect]
    cmp ax,strict word 0x0001
    jne near L1006
    mov eax,_sprite
    add eax,ecx
    mov dword [esp+slot_enemy_sprite_cursor_713],eax
    call near badguy_
    test ax,ax
    je near L1006
    mov dx,word [ecx+_sprite+0x0e]
    cmp dx,strict byte 1
    je short L1006
    cmp dx,strict byte 6
    je short L1006
    lea ebx,[esp+slot_k]
    mov ax,word [ecx+_sprite+0x18]
    mov edx,dword [ecx+_sprite+0x4]
    mov dword [esp+slot_k],eax
    mov eax,dword [ecx+_sprite]
    call near updatesector_
    cmp word [ecx+_sprite+0x2a],strict byte 0
    jl short L1006
    mov eax,dword [esp+slot_k]
    cmp ax,word [ebp+0x18]
    jne short L1006
    mov ebx,0x00000018
    mov edx,0x000008ee
    mov eax,dword [esp+slot_enemy_sprite_cursor_713]
    movsx ecx,word [_myconnectindex]
    call near gutsdir_
    mov eax,0x00000045
    movsx edx,si
    call near spritesound_
    mov eax,esi
    call near deletesprite_
L1006:
    mov esi,edi
    jmp near L1005
L1007:
    cmp dword [eax+0x10],strict byte 0
    jle short L1009
    cmp dword [eax],strict byte 0
    jne short L1009
    mov edx,dword [esp+slot_t]
    movsx eax,word [esp+slot_sh]
    mov esi,dword [edx+0x10]
    cmp eax,esi
    jle short L1008
    lea edi,[esi+0x1]
    mov dword [edx+0x10],edi
    jmp short L1009
L1008:
    mov dword [edx],0x00000001
L1009:
    mov eax,dword [esp+slot_t]
    mov edx,dword [eax]
    test edx,edx
    jle near L1291
    lea ebx,[edx+0x1]
    mov dword [eax],ebx
    mov word [ebp+0x20],0x0003
    mov ecx,dword [eax]
    cmp ecx,strict byte 96
    jle short L1010
    mov dword [eax],0x0ffffffff
    mov dword [eax+0x10],0x0ffffffff
    movsx eax,word [esp+slot_i]
    call near deletesprite_
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1010:
    mov eax,ecx
    and eax,strict byte 31
    cmp eax,strict byte 8
    jne short L1011
    movsx eax,word [_screenpeek]
    imul eax,strict dword 0x00000552
    mov byte [_earthquaketime],0x30
    movsx edx,word [eax+_ps+0x2d4]
    mov eax,0x00000051
    call near spritesound_
L1011:
    mov eax,dword [esp+slot_sc]
    mov edx,dword [esp+slot_t]
    movsx eax,word [eax+0x1a]
    sub eax,dword [edx+0x14]
    test eax,eax
    jns short L1012
    neg eax
L1012:
    cmp eax,strict byte 8
    jge short L1013
    mov ax,word [edx+0x14]
    mov edx,dword [esp+slot_sc]
    mov word [edx+0x1a],ax
    jmp short L1014
L1013:
    mov ebx,dword [esp+slot_sc]
    mov eax,dword [edx+0x14]
    movsx ebx,word [ebx+0x1a]
    sub eax,ebx
    mov ebx,eax
    mov edx,dword [esp+slot_sc]
    add ebx,ebx
    sbb eax,eax
    cmp eax,ebx
    adc eax,strict byte 0
    shl eax,0x04
    add word [edx+0x1a],ax
L1014:
    movsx eax,word [ebp+0x1c]
    add eax,strict dword 0x00000200
    and eax,strict dword 0x000007ff
    movsx edx,word [nosplit eax*2+_sintable]
    movsx eax,word [ebp+0x20]
    imul eax,edx
    sar eax,0x0e
    mov dword [esp+slot_m],eax
    mov ax,word [ebp+0x1c]
    and ah,0x07
    cwde
    movsx edx,word [nosplit eax*2+_sintable]
    movsx eax,word [ebp+0x20]
    imul eax,edx
    sar eax,0x0e
    mov dword [esp+slot_x],eax
    mov ax,word [_connecthead]
    jmp short L1017
L1015:
    movsx edx,si
    imul edx,strict dword 0x00000552
    mov di,word [ebp+0x18]
    cmp di,word [edx+_ps+0x286]
    jne short L1016
    cmp byte [edx+_ps+0x51c],0x00
    je short L1016
    mov eax,dword [esp+slot_m]
    mov ebx,dword [edx+_ps+0x214]
    mov ecx,dword [edx+_ps+0x218]
    mov esi,dword [edx+_ps+0x230]
    mov edi,dword [edx+_ps+0x234]
    add ebx,eax
    mov eax,dword [esp+slot_x]
    mov dword [edx+_ps+0x214],ebx
    add ecx,eax
    mov eax,dword [esp+slot_m]
    mov dword [edx+_ps+0x218],ecx
    add esi,eax
    mov eax,dword [esp+slot_x]
    mov dword [edx+_ps+0x230],esi
    add edi,eax
    mov dword [edx+_ps+0x234],edi
L1016:
    movsx eax,word [esp+slot_p]
    mov ax,word [nosplit eax*2+_connectpoint2]
L1017:
    mov dword [esp+slot_p],eax
    mov esi,dword [esp+slot_p]
    test si,si
    jge short L1015
    movsx eax,word [ebp+0x18]
    movsx esi,word [nosplit eax*2+_headspritesect]
L1018:
    test esi,esi
    jl near L1226
    imul edx,esi,strict byte 44
    mov ax,word [nosplit esi*2+_nextspritesect]
    mov dword [esp+slot_nextj],eax
    cmp word [edx+_sprite+0x0e],strict byte 1
    je short L1019
    mov eax,dword [esp+slot_m]
    mov ebx,dword [edx+_sprite]
    mov ecx,dword [edx+_sprite+0x4]
    add ebx,eax
    mov eax,dword [esp+slot_x]
    mov dword [edx+_sprite],ebx
    add ecx,eax
    mov dword [edx+_sprite+0x4],ecx
    mov eax,esi
    mov ecx,dword [edx+_sprite+0x8]
    mov ebx,dword [edx+_sprite+0x4]
    mov edx,dword [edx+_sprite]
    call near setsprite_
L1019:
    movsx esi,word [esp+slot_nextj]
    jmp short L1018
L1020:
    cmp dword [eax+0x10],strict byte 0
    je near L1291
    mov edx,esp
    mov eax,ebp
    call near findplayer_
    movsx eax,word [esp+slot_sh]
    movsx edx,word [_global_random]
    lea ebx,[eax+0x1]
    mov eax,edx
    sar edx,0x1f
    idiv ebx
    and eax,strict byte 31
    cmp eax,strict byte 4
    jge short L1021
    mov eax,dword [esp+slot_t]
    cmp dword [eax+0x8],strict byte 0
    jne short L1021
    movsx eax,word [ebp+0x1e]
    mov edx,dword [esp+slot_sc]
    sar eax,0x08
    mov byte [edx+0x15],al
    mov al,byte [ebp+0x1e]
    mov byte [edx+0x1d],al
    mov ax,word [_global_random]
    xor ah,ah
    and al,0x0f
    movsx edx,byte [ebp+0x10]
    cwde
    add edx,eax
    mov eax,dword [esp+slot_t]
    mov dword [eax],edx
    jmp short L1022
L1021:
    mov edx,dword [esp+slot_sc]
    mov al,byte [ebp+0x11]
    mov byte [edx+0x15],al
    mov byte [edx+0x1d],al
    mov eax,dword [esp+slot_t]
    mov edx,dword [esp+slot_t]
    mov eax,dword [eax+0x0c]
    mov dword [edx],eax
L1022:
    mov eax,dword [esp+slot_t]
    mov edx,dword [esp+slot_sc]
    mov al,byte [eax]
    mov byte [edx+0x14],al
    mov eax,dword [esp+slot_t]
    mov al,byte [eax]
    mov byte [edx+0x1c],al
    movsx eax,word [edx]
    mov edx,_wall
    shl eax,0x05
    add edx,eax
    mov eax,dword [esp+slot_sc]
    movsx eax,word [eax+0x2]
    mov dword [esp+slot_x],eax
    cmp dword [esp+slot_x],strict byte 0
    jg short L1023
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1023:
    cmp word [edx+0x1c],strict byte 1
    je short L1024
    mov eax,dword [esp+slot_t]
    mov al,byte [eax]
    mov ch,byte [edx+0x0e]
    mov byte [edx+0x14],al
    test ch,0x02
    je short L1024
    mov cx,word [edx+0x0a]
    test cx,cx
    jl short L1024
    movsx eax,cx
    shl eax,0x05
    mov bl,byte [edx+0x14]
    mov byte [eax+_wall+0x14],bl
L1024:
    mov edi,dword [esp+slot_x]
    dec edi
    add edx,strict byte 32
    mov dword [esp+slot_x],edi
    cmp dword [esp+slot_x],strict byte 0
    jg short L1023
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1025:
    movsx ebx,word [esp+slot_sh]
    movsx edx,word [_global_random]
    inc ebx
    mov eax,edx
    sar edx,0x1f
    idiv ebx
    and eax,strict byte 31
    cmp eax,strict byte 4
    jge short L1026
    mov ax,word [_global_random]
    xor ah,ah
    and al,0x0f
    movsx edx,byte [ebp+0x10]
    cwde
    add edx,eax
    mov eax,dword [esp+slot_t]
    mov dword [eax+0x4],edx
    mov ax,word [_global_random]
    xor ah,ah
    and al,0x0f
    movsx edx,byte [ebp+0x10]
    cwde
    add edx,eax
    mov eax,dword [esp+slot_t]
    mov dword [eax],edx
    movsx eax,word [ebp+0x1e]
    mov edx,dword [esp+slot_sc]
    sar eax,0x08
    mov byte [edx+0x15],al
    mov al,byte [ebp+0x1e]
    mov esi,0x00000001
    jmp short L1027
L1026:
    mov eax,dword [esp+slot_t]
    mov edx,dword [esp+slot_t]
    mov eax,dword [eax+0x8]
    mov dword [edx+0x4],eax
    mov eax,dword [edx+0x0c]
    mov dword [edx],eax
    mov edx,dword [esp+slot_sc]
    mov al,byte [ebp+0x11]
    mov byte [edx+0x15],al
    xor esi,esi
L1027:
    mov byte [edx+0x1d],al
    mov eax,dword [esp+slot_t]
    mov edx,dword [esp+slot_sc]
    mov al,byte [eax+0x4]
    mov byte [edx+0x1c],al
    mov eax,dword [esp+slot_t]
    mov al,byte [eax+0x4]
    mov byte [edx+0x14],al
    movsx eax,word [edx]
    mov edx,_wall
    shl eax,0x05
    add edx,eax
    mov eax,dword [esp+slot_sc]
    movsx eax,word [eax+0x2]
    mov dword [esp+slot_x],eax
    jmp short L1032
L1028:
    test esi,esi
    je short L1029
    mov al,byte [ebp+0x1e]
    jmp short L1030
L1029:
    mov al,byte [ebp+0x11]
L1030:
    mov byte [edx+0x15],al
    cmp word [edx+0x1c],strict byte 1
    je short L1031
    mov eax,dword [esp+slot_t]
    mov al,byte [eax]
    mov bl,byte [edx+0x0e]
    mov byte [edx+0x14],al
    test bl,0x02
    je short L1031
    mov ax,word [edx+0x0a]
    test ax,ax
    jl short L1031
    movsx ebx,ax
    shl ebx,0x05
    mov al,byte [edx+0x14]
    mov byte [ebx+_wall+0x14],al
L1031:
    mov ebx,dword [esp+slot_x]
    dec ebx
    add edx,strict byte 32
    mov dword [esp+slot_x],ebx
L1032:
    cmp dword [esp+slot_x],strict byte 0
    jg short L1028
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    movsx eax,word [eax+_sprite+0x18]
    movsx esi,word [nosplit eax*2+_headspritesect]
L1033:
    test esi,esi
    jl short L1037
    imul eax,esi,strict byte 44
    test byte [eax+_sprite+0x0c],0x10
    je short L1036
    mov edx,dword [esp+slot_sc]
    test byte [edx+0x0c],0x01
    je short L1034
    mov dl,byte [edx+0x14]
    jmp short L1035
L1034:
    mov dl,byte [edx+0x1c]
L1035:
    mov byte [eax+_sprite+0x10],dl
L1036:
    movsx esi,word [nosplit esi*2+_nextspritesect]
    jmp short L1033
L1037:
    mov eax,dword [esp+slot_t]
    cmp dword [eax+0x10],strict byte 0
    je near L1291
    movsx eax,word [esp+slot_i]
    call near deletesprite_
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1038:
    mov edx,esp
    mov eax,ebp
    call near findplayer_
    mov ecx,dword [esp+slot_x]
    mov dword [esp+slot_p],eax
    cmp ecx,strict dword 0x00002000
    jge short L1039
    cwde
    imul edx,eax,strict dword 0x00000552
    mov eax,dword [ebp+0x4]
    mov edi,dword [edx+_ps+0x218]
    mov edx,eax
    movsx eax,word [esp+slot_p]
    imul ebx,eax,strict dword 0x00000552
    mov eax,dword [ebp+0x0]
    mov ecx,dword [ebx+_ps+0x214]
    sub edx,edi
    sub eax,ecx
    movsx esi,word [ebp+0x1c]
    call near getangle_
    mov edx,0x00000659
    mov word [ebp+0x1c],ax
    movsx eax,word [esp+slot_i]
    call near shoot_
    mov word [ebp+0x1c],si
L1039:
    movsx eax,word [ebp+0x1e]
    cmp eax,strict byte -1
    jne near L1043
    mov eax,dword [esp+slot_t]
    mov edi,0x7fffffff
    mov dword [eax+0x10],0x00000000
L1040:
    mov eax,dword [esp+slot_t]
    mov edx,0x0ffffffff
    movsx eax,word [eax+0x10]
    call near LocateTheLocator_
    mov word [ebp+0x1e],ax
    cwde
    cmp eax,strict byte -1
    je short L1042
    imul eax,strict byte 44
    mov edx,_sprite
    add edx,eax
    movsx eax,word [esp+slot_p]
    imul eax,strict dword 0x00000552
    movsx eax,word [eax+_ps+0x2d4]
    imul eax,strict byte 44
    add eax,_sprite
    call near ldist_
    mov dword [esp+slot_m],eax
    cmp edi,eax
    jle short L1041
    movsx edx,word [ebp+0x1e]
    mov edi,eax
    mov dword [esp+slot_q],edx
L1041:
    mov eax,dword [esp+slot_t]
    inc dword [eax+0x10]
    jmp short L1040
L1042:
    imul ebx,dword [esp+slot_q],strict byte 44
    mov eax,dword [esp+slot_q]
    mov word [ebp+0x1e],ax
    mov edi,dword [ebp+0x8]
    mov ebx,dword [ebx+_sprite+0x8]
    sub ebx,edi
    add ebx,ebx
    sbb eax,eax
    cmp eax,ebx
    adc al,0x00
    shl eax,0x04
    mov word [ebp+0x24],ax
L1043:
    movsx eax,word [ebp+0x1e]
    imul eax,strict byte 44
    mov edx,ebp
    add eax,_sprite
    call near ldist_
    cmp eax,strict dword 0x00000400
    jge short L1044
    movsx edx,word [esp+slot_p]
    imul edx,strict dword 0x00000552
    mov esi,dword [ebp+0x4]
    mov edi,dword [ebp+0x0]
    mov ebx,dword [edx+_ps+0x218]
    mov eax,dword [edx+_ps+0x214]
    sub ebx,esi
    sub eax,edi
    mov edx,ebx
    mov cx,word [ebp+0x1c]
    call near getangle_
    mov word [ebp+0x1e],0x0ffff
    mov word [ebp+0x1c],cx
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1044:
    movsx edx,word [ebp+0x1e]
    imul edx,strict byte 44
    mov word [ebp+0x20],0x0100
    mov ebx,dword [ebp+0x4]
    mov eax,dword [edx+_sprite+0x4]
    sub eax,ebx
    mov ecx,dword [ebp+0x0]
    mov ebx,eax
    mov eax,dword [edx+_sprite]
    mov edx,ebx
    sub eax,ecx
    call near getangle_
    mov dword [esp+slot_x],eax
    movsx edx,word [esp+slot_x]
    movsx eax,word [ebp+0x1c]
    call near getincangle_
    cwde
    sar eax,0x03
    mov dword [esp+slot_q],eax
    mov si,word [ebp+0x1c]
    mov eax,dword [esp+slot_q]
    add esi,eax
    mov word [ebp+0x1c],si
    call near krand_
    sar eax,0x08
    cmp eax,strict dword 0x000000df
    jl short L1045
    mov edx,dword [esp+slot_t]
    mov eax,dword [esp+slot_q]
    mov ecx,dword [edx+0x8]
    add ecx,eax
    mov eax,dword [esp+slot_sc]
    mov dword [edx+0x8],ecx
    mov byte [eax+0x14],0x7f
    jmp short L1046
L1045:
    movsx ebx,word [esp+slot_p]
    imul ebx,strict dword 0x00000552
    mov esi,dword [ebp+0x4]
    mov edi,dword [ebp+0x0]
    mov edx,dword [ebx+_ps+0x218]
    mov eax,dword [ebx+_ps+0x214]
    sub edx,esi
    sub eax,edi
    call near getangle_
    movsx edx,ax
    mov eax,dword [esp+slot_t]
    mov ax,word [eax+0x8]
    add ah,0x02
    cwde
    call near getincangle_
    cwde
    mov edx,dword [esp+slot_t]
    sar eax,0x02
    mov ebx,dword [edx+0x8]
    add ebx,eax
    mov eax,dword [esp+slot_sc]
    mov dword [edx+0x8],ebx
    mov byte [eax+0x14],0x00
L1046:
    movsx eax,word [esp+slot_i]
    call near ifhitbyweapon_
    movsx esi,ax
    test esi,esi
    jl short L1047
    mov eax,dword [esp+slot_t]
    mov esi,dword [eax+0x0c]
    inc esi
    mov dword [eax+0x0c],esi
    cmp esi,strict byte 5
    jne short L1047
    add byte [ebp+0x25],0x04
    movsx eax,word [_myconnectindex]
    imul eax,strict dword 0x00000552
    mov edx,_ps
    add edx,eax
    mov eax,0x00000007
    call near FTA_
L1047:
    movsx eax,word [ebp+0x24]
    add dword [ebp+0x8],eax
    mov edx,dword [esp+slot_sc]
    movsx eax,word [ebp+0x24]
    add dword [edx+0x4],eax
    mov edx,dword [esp+slot_t]
    mov edx,dword [edx]
    lea eax,[edx*4+0x0]
    add eax,edx
    movsx edx,word [ebp+0x24]
    mov ecx,dword [eax*8+_sector+0x4]
    add ecx,edx
    movsx esi,word [esp+slot_i]
    mov dword [eax*8+_sector+0x4],ecx
    mov eax,esi
    call near ms_
    mov eax,esi
    mov ecx,dword [ebp+0x8]
    mov ebx,dword [ebp+0x4]
    mov edx,dword [ebp+0x0]
    call near setsprite_
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1048:
    movsx edx,word [esp+slot_i]
    lea eax,[edx*8+0x0]
    add eax,edx
    lea eax,[eax*8+0x0]
    sub eax,edx
    cmp dword [eax+_hittype+0x3f],strict byte 0
    je short L1050
    movsx edx,word [esp+slot_i]
    lea ebx,[edx*8+0x0]
    add ebx,edx
    lea ebx,[ebx*8+0x0]
    sub ebx,edx
    movsx edx,word [esp+slot_i]
    lea eax,[edx*8+0x0]
    add eax,edx
    lea eax,[eax*8+0x0]
    sub eax,edx
    inc dword [ebx+_hittype+0x3f]
    cmp dword [eax+_hittype+0x3f],strict byte 8
    jle short L1049
    movsx eax,word [esp+slot_i]
    call near deletesprite_
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1049:
    mov esi,0x00000001
    jmp short L1051
L1050:
    mov eax,dword [esp+slot_sc]
    add eax,strict byte 4
    call near getanimationgoal_
    mov esi,eax
L1051:
    test esi,esi
    jl near L1291
    mov eax,dword [esp+slot_sc]
    movsx eax,word [eax+0x22]
    test ah,0x80
    jne short L1052
    movsx edx,word [esp+slot_i]
    lea eax,[edx*8+0x0]
    add eax,edx
    lea eax,[eax*8+0x0]
    sub eax,edx
    cmp dword [eax+_hittype+0x3f],strict byte 0
    je short L1053
L1052:
    mov eax,dword [esp+slot_t]
    mov eax,dword [eax+0x0c]
    neg eax
    jmp short L1054
L1053:
    mov eax,dword [esp+slot_t]
    mov eax,dword [eax+0x0c]
L1054:
    mov dword [esp+slot_x],eax
    cmp dword [esp+slot_st],strict byte 9
    jne short L1055
    neg dword [esp+slot_x]
L1055:
    movsx esi,word [_headspritestat+0x6]
L1056:
    test esi,esi
    jl near L1291
    imul eax,esi,strict byte 44
    mov ebp,dword [esp+slot_st]
    movsx edx,word [eax+_sprite+0x26]
    cmp edx,ebp
    jne near L1068
    mov edi,dword [esp+slot_sh]
    cmp di,word [eax+_sprite+0x28]
    jne near L1068
    mov cx,word [eax+_sprite+0x18]
    movsx eax,byte [eax+_sprite+0x10]
    movsx edx,cx
    mov dword [esp+slot_m],eax
    lea eax,[edx*4+0x0]
    add eax,edx
    movsx edx,word [eax*8+_sector]
    shl edx,0x05
    movsx edi,word [eax*8+_sector+0x2]
    add edx,_wall
    jmp short L1062
L1057:
    cmp word [edx+0x1c],strict byte 1
    je short L1061
    mov al,byte [esp+slot_x]
    mov bl,byte [edx+0x14]
    add bl,al
    mov byte [edx+0x14],bl
    movsx eax,bl
    cmp eax,dword [esp+slot_m]
    jge short L1058
    mov al,byte [esp+slot_m]
    jmp short L1059
L1058:
    cmp eax,dword [ebp+_hittype+0x37]
    jle short L1060
    mov al,byte [ebp+_hittype+0x37]
L1059:
    mov byte [edx+0x14],al
L1060:
    mov bx,word [edx+0x0a]
    test bx,bx
    jl short L1061
    movsx eax,bx
    shl eax,0x05
    cmp word [eax+_wall+0x1c],strict byte 1
    je short L1061
    mov bl,byte [edx+0x14]
    mov byte [eax+_wall+0x14],bl
L1061:
    dec edi
    add edx,strict byte 32
L1062:
    lea ebp,[esi*8+0x0]
    add ebp,esi
    lea ebp,[ebp*8+0x0]
    sub ebp,esi
    test edi,edi
    jg short L1057
    movsx edx,cx
    lea eax,[edx*4+0x0]
    add edx,eax
    lea edx,[edx*8+0x0]
    mov al,byte [esp+slot_x]
    mov bh,byte [edx+_sector+0x1c]
    add bh,al
    mov ah,byte [edx+_sector+0x14]
    mov byte [edx+_sector+0x1c],bh
    add ah,al
    mov byte [edx+_sector+0x14],ah
    mov ebx,dword [esp+slot_m]
    movsx eax,byte [edx+_sector+0x1c]
    cmp eax,ebx
    jge short L1063
    mov al,byte [esp+slot_m]
    jmp short L1064
L1063:
    cmp eax,dword [ebp+_hittype+0x2f]
    jle short L1065
    mov al,byte [ebp+_hittype+0x2f]
L1064:
    mov byte [edx+_sector+0x1c],al
L1065:
    movsx edx,cx
    lea eax,[edx*4+0x0]
    add edx,eax
    lea edx,[edx*8+0x0]
    mov ebp,dword [esp+slot_m]
    movsx ebx,byte [edx+_sector+0x14]
    cmp ebx,ebp
    jge short L1066
    mov al,byte [esp+slot_m]
    jmp short L1067
L1066:
    lea eax,[esi*8+0x0]
    add eax,esi
    lea eax,[eax*8+0x0]
    sub eax,esi
    cmp ebx,dword [eax+_hittype+0x33]
    jle short L1068
    mov al,byte [eax+_hittype+0x33]
L1067:
    mov byte [edx+_sector+0x14],al
L1068:
    movsx esi,word [nosplit esi*2+_nextspritestat]
    jmp near L1056
L1069:
    mov ax,word [edx+0x22]
    xor ah,ah
    cmp ax,strict word 0x001b
    je short L1071
    mov eax,dword [edx+0x8]
    cmp eax,dword [edx+0x4]
    jle short L1070
    mov ax,word [edx+0x22]
    xor ah,ah
    cmp ax,strict word 0x0017
    jne short L1071
L1070:
    mov eax,dword [esp+slot_sc]
    cmp word [eax+0x22],strict word 0x8017
    jne near L1076
L1071:
    mov eax,dword [esp+slot_sc]
    mov ax,word [eax+0x22]
    xor ah,ah
    mov esi,0x00000001
    cmp ax,strict word 0x001b
    je short L1075
    mov ax,word [_connecthead]
    jmp short L1074
L1072:
    mov eax,dword [esp+slot_sc]
    mov dx,word [eax+0x22]
    cmp dx,strict byte 30
    je short L1073
    cmp dx,strict byte 31
    je short L1073
    test dx,dx
    je short L1073
    movsx eax,di
    imul eax,strict dword 0x00000552
    movsx eax,word [eax+_ps+0x2d4]
    imul edx,eax,strict byte 44
    mov ax,word [ebp+0x18]
    cmp ax,word [edx+_sprite+0x18]
    jne short L1073
    xor esi,esi
L1073:
    movsx eax,word [esp+slot_p]
    mov ax,word [nosplit eax*2+_connectpoint2]
L1074:
    mov dword [esp+slot_p],eax
    mov edi,dword [esp+slot_p]
    test di,di
    jge short L1072
L1075:
    cmp esi,strict byte 1
    jne near L1291
    mov edx,dword [esp+slot_t]
    movsx eax,word [esp+slot_sh]
    mov edi,dword [edx]
    cmp eax,edi
    jge short L1077
    movsx edx,word [esp+slot_i]
    movsx eax,word [ebp+0x18]
    call near activatebysector_
L1076:
    mov eax,dword [esp+slot_t]
    mov dword [eax],0x00000000
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1077:
    lea ebp,[edi+esi]
    mov dword [edx],ebp
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1078:
    mov ebx,dword [eax+0x14]
    test ebx,ebx
    jle short L1079
    lea esi,[ebx-0x1]
    mov dword [eax+0x14],esi
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1079:
    cmp dword [eax+0x10],strict byte 0
    je near L1291
    mov ax,word [edx]
    mov di,word [edx+0x2]
    movsx esi,ax
    add edi,eax
    jmp near L1087
L1080:
    mov ax,word [_headspritestat+0x2]
L1081:
    mov dword [esp+slot_k],eax
    mov ecx,dword [esp+slot_k]
    test cx,cx
    jl short L1083
    movsx eax,cx
    imul eax,strict byte 44
    cmp word [eax+_sprite+0x2a],strict byte 0
    jle short L1082
    add eax,_sprite
    call near badguy_
    test ax,ax
    je short L1082
    movsx eax,word [esp+slot_k]
    imul eax,strict byte 44
    mov ecx,0x00000100
    mov ebx,esi
    mov edx,dword [eax+_sprite+0x4]
    mov eax,dword [eax+_sprite]
    call near clipinsidebox_
    cmp eax,strict byte 1
    je near L1291
L1082:
    movsx eax,word [esp+slot_k]
    mov ax,word [nosplit eax*2+_nextspritestat]
    jmp short L1081
L1083:
    mov ax,word [_headspritestat+0x14]
L1084:
    mov dword [esp+slot_k],eax
    mov ebx,dword [esp+slot_k]
    test bx,bx
    jl near L1086
    movsx eax,bx
    imul eax,strict byte 44
    cmp word [eax+_sprite+0x1e],strict byte 0
    jl short L1085
    mov ecx,0x00000090
    mov ebx,esi
    mov edx,dword [eax+_sprite+0x4]
    mov eax,dword [eax+_sprite]
    call near clipinsidebox_
    cmp eax,strict byte 1
    jne short L1085
    mov eax,dword [esp+slot_t]
    movsx esi,word [esp+slot_i]
    mov dword [eax+0x14],0x00000008
    imul eax,esi,strict byte 44
    mov edx,dword [esp+slot_t]
    movsx eax,word [eax+_sprite+0x22]
    mov ebx,dword [edx+0x0c]
    sar eax,0x03
    imul eax,ebx
    mov dword [esp+slot_k],eax
    cwde
    sub dword [edx+0x8],eax
    mov edi,dword [edx+0x10]
    movsx eax,word [esp+slot_k]
    sub edi,eax
    mov eax,esi
    mov dword [edx+0x10],edi
    call near ms_
    mov eax,esi
    mov ecx,dword [ebp+0x8]
    mov ebx,dword [ebp+0x4]
    mov edx,dword [ebp+0x0]
    call near setsprite_
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1085:
    movsx eax,word [esp+slot_k]
    mov ax,word [nosplit eax*2+_nextspritestat]
    jmp near L1084
L1086:
    inc esi
L1087:
    movsx eax,di
    cmp esi,eax
    jl near L1080
    movsx esi,word [esp+slot_i]
    imul eax,esi,strict byte 44
    mov edx,dword [esp+slot_t]
    movsx eax,word [eax+_sprite+0x22]
    mov edi,dword [edx+0x0c]
    sar eax,0x03
    imul eax,edi
    mov dword [esp+slot_k],eax
    cwde
    add dword [edx+0x8],eax
    mov ecx,dword [edx+0x10]
    movsx eax,word [esp+slot_k]
    add ecx,eax
    mov eax,esi
    mov dword [edx+0x10],ecx
    call near ms_
    mov eax,esi
    mov ecx,dword [ebp+0x8]
    mov ebx,dword [ebp+0x4]
    mov edx,dword [ebp+0x0]
    call near setsprite_
    mov eax,dword [esp+slot_t]
    mov esi,dword [eax+0x10]
    cmp esi,strict dword 0x0fffffe01
    jle short L1088
    cmp esi,strict dword 0x00000200
    jl near L1291
L1088:
    mov eax,dword [esp+slot_t]
    mov dword [eax+0x10],0x00000000
    movsx esi,word [esp+slot_i]
    mov byte [eax+0x8],0x00
    mov eax,esi
    call near ms_
    mov eax,esi
    mov ecx,dword [ebp+0x8]
    mov ebx,dword [ebp+0x4]
    mov edx,dword [ebp+0x0]
    call near setsprite_
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1089:
    cmp dword [eax],strict byte 3
    je short L1090
    cmp dword [eax+0x0c],strict byte 1
    jne near L1099
L1090:
    mov eax,dword [esp+slot_sc]
    mov byte [eax+0x1d],0x00
    mov byte [eax+0x15],0x00
    mov edx,_wall
    movsx eax,word [eax]
    mov esi,dword [esp+slot_sc]
    shl eax,0x05
    movsx esi,word [esi+0x2]
    add edx,eax
    jmp short L1093
L1091:
    cmp word [edx+0x1c],strict byte 1
    je short L1092
    mov eax,dword [esp+slot_t]
    mov al,byte [eax+0x4]
    mov byte [edx+0x15],0x00
    mov byte [edx+0x14],al
L1092:
    dec esi
    add edx,strict byte 32
L1093:
    test esi,esi
    jg short L1091
    mov eax,dword [esp+slot_t]
    mov edx,dword [esp+slot_sc]
    mov al,byte [eax+0x4]
    mov byte [edx+0x1c],al
    mov eax,dword [esp+slot_t]
    mov al,byte [eax+0x8]
    mov byte [edx+0x14],al
    mov eax,dword [esp+slot_t]
    mov dword [eax],0x00000000
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    movsx esi,word [eax+_sprite+0x18]
    movsx esi,word [nosplit esi*2+_headspritesect]
L1094:
    test esi,esi
    jl short L1098
    imul eax,esi,strict byte 44
    test byte [eax+_sprite+0x0c],0x10
    je short L1097
    mov edx,dword [esp+slot_sc]
    test byte [edx+0x0c],0x01
    je short L1095
    mov dl,byte [edx+0x14]
    jmp short L1096
L1095:
    mov dl,byte [edx+0x1c]
L1096:
    mov byte [eax+_sprite+0x10],dl
L1097:
    movsx esi,word [nosplit esi*2+_nextspritesect]
    jmp short L1094
L1098:
    mov eax,dword [esp+slot_t]
    cmp dword [eax+0x0c],strict byte 1
    jne short L1099
    movsx eax,word [esp+slot_i]
    call near deletesprite_
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1099:
    mov eax,dword [esp+slot_t]
    cmp dword [eax],strict byte 1
    jne near L1291
    mov eax,dword [esp+slot_sc]
    mov al,byte [eax+0x1c]
    cmp al,byte [ebp+0x10]
    jle short L1103
    mov edx,dword [esp+slot_sc]
    mov al,byte [ebp+0x11]
    mov byte [edx+0x1d],al
    mov byte [edx+0x15],al
    mov eax,edx
    mov dl,byte [edx+0x1c]
    sub dl,0x02
    mov byte [eax+0x1c],dl
    sub byte [eax+0x14],0x02
    mov esi,dword [esp+slot_sc]
    movsx eax,word [eax]
    mov edx,_wall
    shl eax,0x05
    movsx esi,word [esi+0x2]
    add edx,eax
    jmp short L1102
L1100:
    cmp word [edx+0x1c],strict byte 1
    je short L1101
    mov bl,byte [edx+0x14]
    mov al,byte [ebp+0x11]
    sub bl,0x02
    mov byte [edx+0x15],al
    mov byte [edx+0x14],bl
L1101:
    dec esi
    add edx,strict byte 32
L1102:
    test esi,esi
    jg short L1100
    jmp short L1104
L1103:
    mov eax,dword [esp+slot_t]
    mov dword [eax],0x00000002
L1104:
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    movsx eax,word [eax+_sprite+0x18]
    movsx esi,word [nosplit eax*2+_headspritesect]
L1105:
    test esi,esi
    jl near L1291
    imul eax,esi,strict byte 44
    test byte [eax+_sprite+0x0c],0x10
    je short L1108
    mov edx,dword [esp+slot_sc]
    test byte [edx+0x0c],0x01
    je short L1106
    mov dl,byte [edx+0x14]
    jmp short L1107
L1106:
    mov dl,byte [edx+0x1c]
L1107:
    mov byte [eax+_sprite+0x10],dl
L1108:
    movsx esi,word [nosplit esi*2+_nextspritesect]
    jmp short L1105
L1109:
    cmp dword [eax+0x8],strict byte 0
    je near L1126
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    movsx eax,word [eax+_sprite+0x22]
    shl eax,0x05
    or al,0x01
    mov di,word [ebp+0x1c]
    mov esi,eax
    cmp di,strict word 0x0200
    jne near L1115
    cmp word [ebp+0x1e],strict byte 0
    je short L1112
    mov eax,dword [esp+slot_t]
    mov ecx,dword [edx+0x4]
    mov eax,dword [eax]
    sub eax,ecx
    test eax,eax
    jns short L1110
    neg eax
L1110:
    cmp eax,esi
    jl short L1111
    mov ebx,dword [esp+slot_t]
    mov edi,dword [edx+0x4]
    mov ebx,dword [ebx]
    sub ebx,edi
    add ebx,ebx
    sbb eax,eax
    cmp eax,ebx
    adc eax,strict byte 0
    imul eax,esi
    add dword [edx+0x4],eax
    jmp near L1122
L1111:
    mov eax,dword [esp+slot_t]
    jmp near L1121
L1112:
    mov eax,dword [esp+slot_t]
    mov ecx,dword [edx+0x8]
    mov eax,dword [eax+0x4]
    sub eax,ecx
    test eax,eax
    jns short L1113
    neg eax
L1113:
    cmp eax,esi
    jl short L1114
    mov ebx,dword [esp+slot_t]
    mov edi,dword [edx+0x8]
    mov ebx,dword [ebx+0x4]
    sub ebx,edi
    add ebx,ebx
    sbb eax,eax
    cmp eax,ebx
    adc eax,strict byte 0
    imul eax,esi
    add dword [edx+0x8],eax
    jmp near L1122
L1114:
    mov eax,dword [esp+slot_t]
    mov eax,dword [eax+0x4]
    mov dword [edx+0x8],eax
    jmp near L1122
L1115:
    mov eax,dword [esp+slot_t]
    mov ecx,dword [edx+0x8]
    mov eax,dword [eax+0x4]
    sub eax,ecx
    test eax,eax
    jns short L1116
    neg eax
L1116:
    cmp eax,esi
    jl short L1117
    mov ebx,dword [esp+slot_t]
    mov edi,dword [edx+0x8]
    mov ebx,dword [ebx+0x4]
    sub ebx,edi
    add ebx,ebx
    sbb eax,eax
    cmp eax,ebx
    adc eax,strict byte 0
    imul eax,esi
    add dword [edx+0x8],eax
    jmp short L1118
L1117:
    mov eax,dword [esp+slot_t]
    mov eax,dword [eax+0x4]
    mov dword [edx+0x8],eax
L1118:
    mov eax,dword [esp+slot_t]
    mov edx,dword [esp+slot_sc]
    mov eax,dword [eax]
    sub eax,dword [edx+0x4]
    test eax,eax
    jns short L1119
    neg eax
L1119:
    cmp eax,esi
    jl short L1120
    mov ebx,dword [esp+slot_t]
    mov edi,dword [edx+0x4]
    mov ebx,dword [ebx]
    sub ebx,edi
    add ebx,ebx
    sbb eax,eax
    cmp eax,ebx
    adc eax,strict byte 0
    imul eax,esi
    add dword [edx+0x4],eax
L1120:
    mov eax,dword [esp+slot_t]
    mov edx,dword [esp+slot_sc]
L1121:
    mov eax,dword [eax]
    mov dword [edx+0x4],eax
L1122:
    mov eax,dword [esp+slot_t]
    mov ecx,dword [eax+0x0c]
    cmp ecx,strict byte 1
    jne near L1125
    lea esi,[ecx+ecx]
    mov dword [eax+0x0c],esi
    mov eax,dword [esp+slot_sc]
    xor byte [eax+0x0c],0x01
    cmp word [ebp+0x1c],strict word 0x0200
    jne near L1125
    mov edx,_wall
    movsx eax,word [eax]
    mov esi,dword [esp+slot_sc]
    shl eax,0x05
    movsx esi,word [esi+0x2]
    add edx,eax
    jmp short L1124
L1123:
    add edx,strict byte 32
    mov al,byte [ebp+0x10]
    dec esi
    mov byte [edx-0x0c],al
L1124:
    test esi,esi
    jg short L1123
    mov edx,dword [esp+slot_sc]
    mov al,byte [ebp+0x10]
    mov byte [edx+0x1c],al
    mov ax,word [_ps+0x2d6]
    test ax,ax
    jl short L1125
    movsx edx,ax
    lea eax,[edx*4+0x0]
    add eax,edx
    mov edx,dword [esp+slot_sc]
    mov ax,word [eax*8+_sector+0x10]
    mov word [edx+0x10],ax
    movsx edx,word [_ps+0x2d6]
    lea eax,[edx*4+0x0]
    add eax,edx
    mov edx,dword [esp+slot_sc]
    mov al,byte [eax*8+_sector+0x14]
    mov byte [edx+0x14],al
L1125:
    mov eax,dword [esp+slot_t]
    mov ecx,dword [eax+0x8]
    inc ecx
    mov dword [eax+0x8],ecx
    cmp ecx,strict dword 0x00000100
    jle short L1126
    movsx eax,word [esp+slot_i]
    call near deletesprite_
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1126:
    mov eax,dword [esp+slot_t]
    cmp dword [eax+0x8],strict byte 4
    jne near L1291
    cmp word [ebp+0x1c],strict word 0x0200
    je near L1291
    xor eax,eax
    mov dword [esp+slot_x],eax
    cmp dword [esp+slot_x],strict byte 7
    jl short L1127
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1127:
    push 0x00000005
    movsx eax,word [esp+slot_i+4]
    push eax
    mov edx,0x0fffffe00
    call near krand_
    and eax,strict dword 0x000007ff
    sub edx,eax
    push edx
    call near krand_
    xor ah,ah
    and al,0x3f
    add eax,strict dword 0x00000040
    cwde
    push eax
    call near krand_
    and ah,0x07
    cwde
    push eax
    push 0x00000030
    push 0x00000030
    push 0x0fffffff8
    call near krand_
    xor ah,ah
    mov ecx,dword [ebp+0x8]
    and al,0x0f
    mov ebx,dword [ebp+0x4]
    add eax,strict dword 0x00000956
    mov edx,dword [ebp+0x0]
    cwde
    sub ecx,strict dword 0x00000c00
    push eax
    movsx eax,word [ebp+0x18]
    call near EGS_
    inc dword [esp+slot_x]
    cmp dword [esp+slot_x],strict byte 7
    jl short L1127
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1128:
    cmp dword [eax+0x10],strict byte 0
    je near L1291
    mov word [ebp+0x20],0x0010
    mov edi,dword [eax+0x10]
    cmp edi,strict byte 1
    jne short L1130
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    mov edx,dword [esp+slot_t]
    movsx eax,word [eax+_sprite+0x22]
    mov esi,dword [edx+0x0c]
    sar eax,0x03
    cmp eax,esi
    jg short L1129
    mov dword [edx+0x10],0x00000000
    movsx edx,word [esp+slot_i]
    movsx eax,word [ebp+0x18]
    call near callsound_
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1129:
    add edi,esi
    mov dword [edx+0x0c],edi
    jmp short L1132
L1130:
    cmp edi,strict byte 2
    jne short L1132
    mov ebx,dword [eax+0x0c]
    cmp ebx,strict byte 1
    jge short L1131
    mov dword [eax+0x10],0x00000000
    movsx edx,word [esp+slot_i]
    movsx eax,word [ebp+0x18]
    call near callsound_
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1131:
    lea ecx,[ebx-0x1]
    mov dword [eax+0x0c],ecx
L1132:
    movsx esi,word [esp+slot_i]
    mov eax,esi
    call near ms_
    mov eax,esi
    mov ecx,dword [ebp+0x8]
    mov ebx,dword [ebp+0x4]
    mov edx,dword [ebp+0x0]
    call near setsprite_
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1133:
    add dword [eax+0x8],strict byte 32
    mov eax,dword [esp+slot_sc]
    mov edx,dword [esp+slot_sc]
    mov eax,dword [eax+0x8]
    mov ebx,dword [edx+0x4]
    cmp eax,ebx
    jge short L1134
    mov byte [ebp+0x10],0x00
    jmp short L1139
L1134:
    mov edx,dword [esp+slot_t]
    cmp ebx,dword [edx+0x0c]
    jge short L1139
    movsx eax,word [ebp+0x18]
    movsx esi,word [nosplit eax*2+_headspritesect]
L1135:
    test esi,esi
    jl short L1136
    imul eax,esi,strict byte 44
    mov cx,word [eax+_sprite+0x0e]
    cmp cx,strict word 0x0440
    je short L1136
    cmp cx,strict word 0x0242
    je short L1136
    movsx esi,word [nosplit esi*2+_nextspritesect]
    jmp short L1135
L1136:
    cmp esi,strict byte -1
    jne short L1138
L1137:
    movsx eax,word [esp+slot_i]
    call near deletesprite_
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1138:
    mov byte [ebp+0x10],0x01
L1139:
    cmp byte [ebp+0x10],0x00
    je short L1140
    mov eax,dword [esp+slot_sc]
    add dword [eax+0x4],strict dword 0x00000400
    jmp short L1141
L1140:
    mov eax,dword [esp+slot_sc]
    sub dword [eax+0x4],strict dword 0x00000200
L1141:
    movsx esi,word [esp+slot_i]
    mov eax,esi
    call near ms_
    mov eax,esi
    mov ecx,dword [ebp+0x8]
    mov ebx,dword [ebp+0x4]
    mov edx,dword [ebp+0x0]
    call near setsprite_
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1142:
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    mov edx,dword [esp+slot_t]
    movsx eax,word [eax+_sprite+0x22]
    mov edx,dword [edx]
    lea eax,[eax*4+0x0]
    imul edx,eax
    mov dword [esp+slot_q],edx
    mov eax,edx
    mov edx,dword [esp+slot_sc]
    mov esi,dword [edx+0x4]
    mov edi,dword [edx+0x8]
    add esi,eax
    add edi,eax
    mov dword [edx+0x4],esi
    mov dword [edx+0x8],edi
    movsx eax,word [ebp+0x18]
    movsx esi,word [nosplit eax*2+_headspritesect]
L1143:
    test esi,esi
    jl near L1147
    imul eax,esi,strict byte 44
    cmp word [eax+_sprite+0x1a],strict byte 10
    jne near L1145
    cmp word [eax+_sprite+0x1e],strict byte 0
    jl near L1145
    mov ax,word [eax+_sprite+0x22]
    mov bx,word [_numplayers]
    mov dword [esp+slot_p],eax
    cmp bx,strict byte 2
    jge short L1144
    cwde
    imul eax,strict dword 0x00000552
    mov edx,dword [eax+_ps+0x21c]
    mov dword [eax+_ps+0x240],edx
L1144:
    movsx eax,word [esp+slot_p]
    imul eax,strict dword 0x00000552
    mov edx,dword [esp+slot_q]
    mov edi,dword [eax+_ps+0x21c]
    mov ebx,dword [eax+_ps+0x25c]
    mov ecx,dword [eax+_ps+0x260]
    add edi,edx
    add ecx,edx
    mov dword [eax+_ps+0x21c],edi
    add ebx,edx
    mov dword [eax+_ps+0x260],ecx
    mov cx,word [_numplayers]
    mov dword [eax+_ps+0x25c],ebx
    cmp cx,strict byte 1
    jle short L1145
    mov edx,dword [eax+_ps+0x21c]
    mov dword [eax+_ps+0x240],edx
L1145:
    imul edx,esi,strict byte 44
    cmp word [edx+_sprite+0x1a],strict byte 3
    je short L1146
    lea ebx,[esi*8+0x0]
    add ebx,esi
    lea ebx,[ebx*8+0x0]
    sub ebx,esi
    mov eax,dword [edx+_sprite+0x8]
    mov edi,dword [edx+_sprite+0x8]
    mov dword [ebx+_hittype+0x2b],eax
    mov eax,dword [esp+slot_q]
    add edi,eax
    mov dword [edx+_sprite+0x8],edi
L1146:
    lea eax,[esi*8+0x0]
    add eax,esi
    lea eax,[eax*8+0x0]
    mov edx,dword [esp+slot_sc]
    sub eax,esi
    mov edx,dword [edx+0x8]
    mov dword [eax+_hittype+0x13],edx
    mov edx,dword [esp+slot_sc]
    mov edx,dword [edx+0x4]
    movsx esi,word [nosplit esi*2+_nextspritesect]
    mov dword [eax+_hittype+0x17],edx
    jmp near L1143
L1147:
    mov eax,dword [esp+slot_t]
    mov esi,dword [eax]
    test esi,esi
    je near L1291
    je near L1291
    movsx esi,word [esp+slot_i]
    imul eax,esi,strict byte 44
    mov ebx,dword [esp+slot_t]
    movsx edx,word [eax+_sprite+0x22]
    mov eax,dword [esp+slot_sc]
    mov ecx,dword [ebx+0x8]
    mov eax,dword [eax+0x8]
    sub eax,ecx
    test eax,eax
    jns short L1148
    neg eax
L1148:
    cmp eax,edx
    jg short L1149
    mov eax,esi
    xor edx,edx
    call near activatewarpelevators_
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1149:
    cmp dword [ebx],strict byte -1
    jne short L1150
    mov eax,dword [esp+slot_sc]
    mov ebx,dword [ebx+0x0c]
    cmp ebx,dword [eax+0x8]
    jl near L1291
    jmp short L1151
L1150:
    mov eax,dword [esp+slot_sc]
    mov edi,dword [ebx+0x10]
    cmp edi,dword [eax+0x4]
    jg near L1291
L1151:
    mov eax,dword [esp+slot_t]
    cmp dword [eax+0x4],strict byte 0
    je near L1291
    mov dword [eax+0x4],0x00000000
    mov ecx,dword [esp+slot_t]
    movsx esi,word [_headspritestat+0x6]
L1152:
    test esi,esi
    jl short L1154
    movsx eax,word [esp+slot_i]
    cmp eax,esi
    je short L1153
    imul edx,esi,strict byte 44
    cmp word [edx+_sprite+0x26],strict byte 17
    jne short L1153
    movsx ebx,word [edx+_sprite+0x18]
    lea eax,[ebx*4+0x0]
    add eax,ebx
    movsx ebx,word [eax*8+_sector+0x24]
    mov eax,dword [esp+slot_sc]
    mov edi,dword [ecx]
    movsx eax,word [eax+0x24]
    sub eax,edi
    cmp eax,ebx
    jne short L1153
    mov eax,dword [esp+slot_sh]
    cmp ax,word [edx+_sprite+0x28]
    je short L1154
L1153:
    movsx esi,word [nosplit esi*2+_nextspritestat]
    jmp short L1152
L1154:
    cmp esi,strict byte -1
    je near L1291
    movsx eax,word [ebp+0x18]
    mov ax,word [nosplit eax*2+_headspritesect]
L1155:
    mov dword [esp+slot_k],eax
    mov ecx,dword [esp+slot_k]
    test cx,cx
    jl near L1291
    movsx ecx,cx
    mov ax,word [nosplit ecx*2+_nextspritesect]
    mov dword [esp+slot_nextk],eax
    imul eax,ecx,strict byte 44
    cmp word [eax+_sprite+0x1a],strict byte 10
    jne near L1156
    cmp word [eax+_sprite+0x1e],strict byte 0
    jl near L1156
    mov ax,word [eax+_sprite+0x22]
    movsx edi,ax
    imul edi,strict dword 0x00000552
    mov dword [esp+slot_p],eax
    imul eax,esi,strict byte 44
    mov edx,dword [ebp+0x0]
    mov dword [esp+slot_passenger_player_cursor_1362],eax
    mov eax,dword [eax+_sprite]
    mov ebx,dword [edi+_ps+0x214]
    sub eax,edx
    add ebx,eax
    mov eax,dword [esp+slot_passenger_player_cursor_1362]
    mov dword [edi+_ps+0x214],ebx
    mov eax,dword [eax+_sprite+0x4]
    mov edx,dword [ebp+0x4]
    mov ebx,dword [edi+_ps+0x218]
    sub eax,edx
    add ebx,eax
    mov eax,dword [esp+slot_passenger_player_cursor_1362]
    movsx eax,word [eax+_sprite+0x18]
    mov dword [esp+slot_passenger_sector_index_1369],eax
    mov edx,eax
    lea eax,[eax*4+0x0]
    mov dword [edi+_ps+0x218],ebx
    add edx,eax
    mov eax,dword [esp+slot_sc]
    mov ebx,dword [edi+_ps+0x21c]
    mov eax,dword [eax+0x8]
    lea edx,[edx*8+0x0]
    sub eax,ebx
    mov ebx,dword [edx+_sector+0x8]
    sub ebx,eax
    lea eax,[ecx*8+0x0]
    add eax,ecx
    lea eax,[eax*8+0x0]
    mov dword [edi+_ps+0x21c],ebx
    sub eax,ecx
    mov ebx,dword [edx+_sector+0x8]
    mov edx,dword [edx+_sector+0x4]
    mov dword [eax+_hittype+0x17],edx
    mov edx,dword [edi+_ps+0x214]
    mov dword [edi+_ps+0x238],edx
    mov dword [edi+_ps+0x230],edx
    mov edx,dword [edi+_ps+0x218]
    mov dword [edi+_ps+0x23c],edx
    mov dword [edi+_ps+0x234],edx
    mov edx,dword [edi+_ps+0x21c]
    mov dword [eax+_hittype+0x13],ebx
    mov dword [edi+_ps+0x240],edx
    mov edx,dword [eax+_hittype+0x13]
    mov eax,dword [eax+_hittype+0x17]
    mov dword [edi+_ps+0x25c],edx
    mov dword [edi+_ps+0x260],eax
    xor eax,eax
    mov edx,dword [esp+slot_passenger_sector_index_1369]
    mov dword [edi+_ps+0x26c],eax
    mov eax,ecx
    call near changespritesect_
    mov eax,dword [esp+slot_passenger_player_cursor_1362]
    mov ax,word [eax+_sprite+0x18]
    mov word [edi+_ps+0x286],ax
    mov eax,dword [esp+slot_nextk]
    jmp near L1155
L1156:
    movsx ecx,word [esp+slot_k]
    imul eax,ecx,strict byte 44
    cmp word [eax+_sprite+0x1a],strict byte 3
    je near L1157
    imul edi,esi,strict byte 44
    lea edx,[ecx*8+0x0]
    add edx,ecx
    lea edx,[edx*8+0x0]
    sub edx,ecx
    mov ebx,dword [eax+_sprite]
    mov dword [edx+_hittype+0x23],ebx
    mov ebx,dword [eax+_sprite+0x4]
    mov dword [edx+_hittype+0x27],ebx
    mov ebx,dword [eax+_sprite+0x8]
    mov dword [edx+_hittype+0x2b],ebx
    mov edx,dword [edi+_sprite]
    sub edx,dword [ebp+0x0]
    add dword [eax+_sprite],edx
    mov edx,dword [edi+_sprite+0x4]
    sub edx,dword [ebp+0x4]
    add dword [eax+_sprite+0x4],edx
    movsx edx,word [edi+_sprite+0x18]
    mov dword [esp+slot_shared_sector_or_sprite_index_1471_2433],edx
    mov ebx,dword [esp+slot_shared_sector_or_sprite_index_1471_2433]
    lea edx,[edx*4+0x0]
    add ebx,edx
    mov edx,dword [esp+slot_sc]
    lea ebx,[ebx*8+0x0]
    mov edx,dword [edx+0x8]
    mov ebx,dword [ebx+_sector+0x8]
    sub edx,dword [eax+_sprite+0x8]
    sub ebx,edx
    mov dword [eax+_sprite+0x8],ebx
    mov eax,ecx
    movsx edx,word [edi+_sprite+0x18]
    call near changespritesect_
    movsx eax,word [esp+slot_k]
    mov dword [esp+slot_shared_sector_or_sprite_index_1471_2433],eax
    imul eax,strict byte 44
    mov ecx,dword [eax+_sprite+0x8]
    mov ebx,dword [eax+_sprite+0x4]
    mov edx,dword [eax+_sprite]
    mov eax,dword [esp+slot_shared_sector_or_sprite_index_1471_2433]
    call near setsprite_
    movsx edx,word [edi+_sprite+0x18]
    lea ebx,[edx*4+0x0]
    add ebx,edx
    movsx edx,word [esp+slot_k]
    lea eax,[edx*8+0x0]
    add eax,edx
    lea eax,[eax*8+0x0]
    lea ebx,[ebx*8+0x0]
    sub eax,edx
    mov edx,dword [ebx+_sector+0x8]
    mov dword [eax+_hittype+0x13],edx
    mov edx,dword [ebx+_sector+0x4]
    mov dword [eax+_hittype+0x17],edx
L1157:
    mov eax,dword [esp+slot_nextk]
    jmp near L1155
L1158:
    mov edx,dword [eax]
    test edx,edx
    je near L1166
    cmp edx,strict byte 1
    jne near L1162
    lea ecx,[edx+edx]
    mov dword [eax],ecx
    mov eax,dword [esp+slot_sc]
    movsx eax,word [eax]
    mov dword [esp+slot_x],eax
    mov eax,dword [esp+slot_sc]
    mov edx,dword [esp+slot_x]
    movsx eax,word [eax+0x2]
    add edx,eax
    mov esi,dword [esp+slot_x]
    mov dword [esp+slot_q],edx
    jmp short L1161
L1159:
    mov eax,esi
    shl eax,0x05
    cmp word [eax+_wall+0x12],strict word 0x00e6
    jne short L1160
    mov dx,word [eax+_wall+0x0e]
    xor ebx,ebx
    xor dh,dh
    mov word [eax+_wall+0x12],bx
    and dl,0x0ae
    mov cx,word [eax+_wall+0x0a]
    mov word [eax+_wall+0x0e],dx
    test cx,cx
    jl short L1160
    movsx edx,cx
    shl edx,0x05
    mov word [edx+_wall+0x12],bx
    movsx eax,word [eax+_wall+0x0a]
    shl eax,0x05
    mov dx,word [eax+_wall+0x0e]
    xor dh,dh
    and dl,0x0ae
    mov word [eax+_wall+0x0e],dx
L1160:
    inc esi
L1161:
    cmp esi,dword [esp+slot_q]
    jl short L1159
L1162:
    mov eax,dword [esp+slot_sc]
    mov edx,dword [esp+slot_sc]
    mov eax,dword [eax+0x4]
    mov ebp,dword [edx+0x8]
    cmp eax,ebp
    jl near L1165
    mov dword [edx+0x4],ebp
    movsx esi,word [_headspritestat+0x6]
L1163:
    test esi,esi
    jl near L1137
    imul edx,esi,strict byte 44
    cmp word [edx+_sprite+0x26],strict byte 0
    jne near L1164
    mov ecx,dword [esp+slot_sh]
    cmp cx,word [edx+_sprite+0x28]
    jne short L1164
    movsx ecx,word [edx+_sprite+0x1e]
    imul eax,ecx,strict byte 44
    movsx eax,word [eax+_sprite+0x18]
    mov dword [esp+slot_q],eax
    mov ebx,eax
    lea eax,[eax*4+0x0]
    movsx edx,word [edx+_sprite+0x18]
    add ebx,eax
    lea eax,[edx*4+0x0]
    lea ebx,[ebx*8+0x0]
    add eax,edx
    mov dl,byte [ebx+_sector+0x1d]
    mov byte [eax*8+_sector+0x15],dl
    mov byte [eax*8+_sector+0x1d],dl
    mov dl,byte [ebx+_sector+0x1c]
    mov byte [eax*8+_sector+0x14],dl
    mov byte [eax*8+_sector+0x1c],dl
    lea eax,[ecx*8+0x0]
    add eax,ecx
    lea eax,[eax*8+0x0]
    sub eax,ecx
    mov dword [eax+_hittype+0x2f],0x00000002
L1164:
    movsx esi,word [nosplit esi*2+_nextspritestat]
    jmp near L1163
L1165:
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    mov ebx,dword [edx+0x4]
    movsx eax,word [eax+_sprite+0x22]
    add ebx,eax
    mov dword [edx+0x4],ebx
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1166:
    movsx eax,word [ebp+0x18]
    call near ifhitsectors_
    movsx esi,ax
    test esi,esi
    jl near L1291
    movsx eax,word [_myconnectindex]
    imul eax,strict dword 0x00000552
    mov edx,_ps
    add edx,eax
    mov eax,0x00000008
    mov esi,dword [esp+slot_sh]
    call near FTA_
    movsx edi,word [_headspritestat+0x6]
L1167:
    test edi,edi
    jl near L1291
    imul edx,edi,strict byte 44
    mov ax,word [edx+_sprite+0x26]
    and ah,0x7f
    cwde
    mov dword [esp+slot_x],eax
    cmp eax,strict byte 1
    jb short L1168
    jbe near L1169
    cmp eax,strict byte 12
    jb near L1170
    jbe short L1169
    cmp eax,strict byte 19
    je short L1169
    jmp near L1170
L1168:
    test eax,eax
    jne near L1170
    cmp si,word [edx+_sprite+0x28]
    jne near L1170
    movsx eax,word [edx+_sprite+0x18]
    movsx edx,word [edx+_sprite+0x1e]
    imul edx,strict byte 44
    mov dword [esp+slot_q],eax
    mov ebx,eax
    lea eax,[eax*4+0x0]
    add eax,ebx
    mov bl,byte [edx+_sprite+0x10]
    mov byte [eax*8+_sector+0x14],bl
    mov dl,byte [edx+_sprite+0x11]
    mov byte [eax*8+_sector+0x1c],bl
    mov byte [eax*8+_sector+0x15],dl
    mov byte [eax*8+_sector+0x1d],dl
    jmp short L1170
L1169:
    imul ebx,edi,strict byte 44
    mov eax,dword [esp+slot_sh]
    cmp ax,word [ebx+_sprite+0x28]
    jne short L1170
    lea eax,[edi*8+0x0]
    add eax,edi
    lea eax,[eax*8+0x0]
    sub eax,edi
    cmp dword [eax+_hittype+0x2f],strict byte 0
    jne short L1170
    mov dword [eax+_hittype+0x2f],0x00000001
    mov eax,dword [esp+slot_i]
    mov word [ebx+_sprite+0x1e],ax
L1170:
    movsx edi,word [nosplit edi*2+_nextspritestat]
    jmp near L1167
L1171:
    mov ecx,dword [eax]
    test ecx,ecx
    je near L1291
    cmp ecx,strict byte 1
    jne short L1172
    mov word [ebp+0x20],0x0008
    jmp short L1173
L1172:
    mov word [ebp+0x20],0x0fff8
L1173:
    mov cx,word [ebp+0x20]
    test cx,cx
    je near L1291
    movsx eax,word [ebp+0x1c]
    add eax,strict dword 0x00000200
    and eax,strict dword 0x000007ff
    movsx edx,cx
    movsx eax,word [nosplit eax*2+_sintable]
    imul eax,edx
    sar eax,0x0e
    mov dword [esp+slot_x],eax
    mov ax,word [ebp+0x1c]
    and ah,0x07
    cwde
    movsx edi,word [nosplit eax*2+_sintable]
    movsx eax,word [ebp+0x20]
    imul edi,eax
    mov edx,dword [esp+slot_t]
    add dword [edx+0x0c],eax
    mov ecx,dword [ebp+0x0]
    mov esi,dword [ebp+0x4]
    mov eax,dword [esp+slot_x]
    sar edi,0x0e
    add ecx,eax
    add esi,edi
    mov dword [ebp+0x0],ecx
    mov dword [ebp+0x4],esi
    cmp dword [edx+0x0c],strict byte 0
    jle short L1174
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    mov edx,dword [esp+slot_t]
    mov edx,dword [edx+0x0c]
    movsx eax,word [eax+_sprite+0x22]
    sar edx,0x06
    sar eax,0x06
    cmp edx,eax
    jl short L1175
L1174:
    mov eax,dword [esp+slot_x]
    mov ebx,dword [ebp+0x0]
    mov ecx,dword [ebp+0x4]
    sub ebx,eax
    sub ecx,edi
    mov dword [ebp+0x0],ebx
    mov eax,dword [esp+slot_t]
    mov dword [ebp+0x4],ecx
    mov dword [eax],0x00000000
    movsx edx,word [esp+slot_i]
    movsx eax,word [ebp+0x18]
    call near callsound_
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1175:
    movsx eax,word [ebp+0x18]
    movsx esi,word [nosplit eax*2+_headspritesect]
L1176:
    test esi,esi
    jl near L1178
    mov ax,word [nosplit esi*2+_nextspritesect]
    mov dword [esp+slot_nextj],eax
    imul eax,esi,strict byte 44
    mov dx,word [eax+_sprite+0x1a]
    mov dword [esp+slot_moving_sprite_cursor_1604],eax
    cmp dx,strict byte 3
    je near L1177
    cmp word [eax+_sprite+0x24],strict byte 0
    jne short L1177
    mov edx,dword [esp+slot_moving_sprite_cursor_1604]
    mov eax,dword [esp+slot_x]
    mov ebx,dword [edx+_sprite]
    mov ecx,dword [edx+_sprite+0x4]
    add ebx,eax
    add ecx,edi
    mov dword [edx+_sprite],ebx
    mov dword [edx+_sprite+0x4],ecx
    mov eax,esi
    mov ecx,dword [edx+_sprite+0x8]
    mov ebx,dword [edx+_sprite+0x4]
    mov edx,dword [edx+_sprite]
    call near setsprite_
    mov edx,dword [esp+slot_moving_sprite_cursor_1604]
    movsx edx,word [edx+_sprite+0x18]
    lea eax,[edx*4+0x0]
    add eax,edx
    test byte [eax*8+_sector+0x0e],0x02
    je short L1177
    mov eax,dword [esp+slot_moving_sprite_cursor_1604]
    cmp word [eax+_sprite+0x1a],strict byte 2
    jne short L1177
    movsx eax,si
    call near makeitfall_
L1177:
    movsx esi,word [esp+slot_nextj]
    jmp near L1176
L1178:
    mov eax,dword [esp+slot_t]
    mov eax,dword [eax+0x4]
    shl eax,0x05
    mov esi,dword [esp+slot_x]
    mov ebx,dword [eax+_wall+0x4]
    mov edx,dword [eax+_wall]
    mov eax,dword [esp+slot_t]
    add ebx,edi
    add edx,esi
    movsx eax,word [eax+0x4]
    call near dragpoint_
    mov eax,dword [esp+slot_t]
    mov eax,dword [eax+0x8]
    shl eax,0x05
    mov ebx,dword [eax+_wall+0x4]
    mov edx,dword [eax+_wall]
    add edx,dword [esp+slot_x]
    mov eax,dword [esp+slot_t]
    add ebx,edi
    movsx eax,word [eax+0x8]
    call near dragpoint_
    mov ax,word [_connecthead]
    jmp near L1181
L1179:
    movsx edx,si
    imul edx,strict dword 0x00000552
    mov bx,word [ebp+0x18]
    cmp bx,word [edx+_ps+0x286]
    jne short L1180
    cmp byte [edx+_ps+0x51c],0x00
    je short L1180
    mov eax,dword [esp+slot_x]
    mov esi,dword [edx+_ps+0x214]
    add esi,eax
    mov eax,dword [edx+_ps+0x218]
    mov dword [edx+_ps+0x214],esi
    add eax,edi
    mov dword [edx+_ps+0x218],eax
    mov eax,dword [edx+_ps+0x214]
    mov ecx,dword [edx+_ps+0x21c]
    mov dword [edx+_ps+0x238],eax
    add ecx,strict dword 0x00002600
    mov eax,dword [edx+_ps+0x218]
    mov esi,dword [edx+_ps+0x214]
    mov dword [edx+_ps+0x23c],eax
    mov ebx,eax
    movsx eax,word [edx+_ps+0x2d4]
    mov edx,esi
    call near setsprite_
L1180:
    movsx eax,word [esp+slot_p]
    mov ax,word [nosplit eax*2+_connectpoint2]
L1181:
    mov dword [esp+slot_p],eax
    mov esi,dword [esp+slot_p]
    test si,si
    jge near L1179
    mov edx,dword [esp+slot_x]
    mov ebx,dword [esp+slot_sc]
    xor eax,eax
    sar edx,0x03
    mov al,byte [ebx+0x1e]
    sub eax,edx
    mov byte [ebx+0x1e],al
    xor eax,eax
    sar edi,0x03
    mov al,byte [ebx+0x1f]
    sub eax,edi
    mov byte [ebx+0x1f],al
    mov edx,dword [esp+slot_x]
    xor eax,eax
    sar edx,0x03
    mov al,byte [ebx+0x16]
    sub eax,edx
    mov byte [ebx+0x16],al
    xor eax,eax
    mov al,byte [ebx+0x17]
    sub eax,edi
    mov byte [ebx+0x17],al
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1182:
    cmp dword [eax],strict byte 0
    je near L1291
    cmp word [ebp+0x1c],strict word 0x0600
    jne short L1183
    mov edi,dword [esp+slot_sc]
    add edi,strict byte 4
    jmp short L1184
L1183:
    mov edi,dword [esp+slot_sc]
    add edi,strict byte 8
L1184:
    mov eax,dword [esp+slot_t]
    cmp dword [eax],strict byte 1
    jne short L1185
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    mov ebx,dword [ebp+0x8]
    mov ecx,dword [edi]
    mov dx,word [eax+_sprite+0x22]
    sub ebx,ecx
    shl edx,0x04
    add ebx,ebx
    sbb eax,eax
    cmp eax,ebx
    adc al,0x00
    imul eax,edx
    mov word [ebp+0x24],ax
    mov eax,dword [esp+slot_t]
    inc dword [eax]
L1185:
    mov eax,dword [esp+slot_sc]
    mov dx,word [eax+0x26]
    test dx,dx
    jne short L1187
    movsx eax,word [ebp+0x24]
    mov edx,dword [edi]
    add edx,eax
    mov dword [edi],edx
    mov eax,edx
    sub eax,dword [ebp+0x8]
    test eax,eax
    jns short L1186
    neg eax
L1186:
    cmp eax,strict dword 0x00000400
    jge near L1291
    mov eax,dword [ebp+0x8]
    mov dword [edi],eax
    movsx eax,word [esp+slot_i]
    call near deletesprite_
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1187:
    mov ebx,edx
    dec ebx
    mov word [eax+0x26],bx
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1188:
    cmp dword [eax+0x4],strict byte 0
    je near L1291
    mov edx,dword [eax]
    lea eax,[edx*4+0x0]
    add edx,eax
    mov eax,_sector
    lea edx,[edx*8+0x0]
    add eax,edx
    add eax,strict byte 4
    call near getanimationgoal_
    test eax,eax
    jl short L1189
    mov edx,dword [esp+slot_sc]
    movsx edx,word [edx+0x26]
    lea eax,[edx*8+0x0]
    add eax,edx
    mov edx,dword [esp+slot_sc]
    add dword [edx+0x4],eax
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1189:
    mov eax,dword [esp+slot_t]
    mov dword [eax+0x4],0x00000000
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1190:
    mov eax,dword [esp+slot_t]
    cmp dword [eax+0x10],strict byte 0
    jne near L1291
    movsx eax,word [ebp+0x1c]
    add eax,strict dword 0x00000200
    and eax,strict dword 0x000007ff
    movsx edx,word [nosplit eax*2+_sintable]
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    movsx eax,word [eax+_sprite+0x22]
    imul edx,eax
    sar edx,0x12
    mov dword [esp+slot_x],edx
    mov dx,word [ebp+0x1c]
    and dh,0x07
    movsx edx,dx
    mov edi,eax
    movsx edx,word [nosplit edx*2+_sintable]
    imul edi,edx
    xor esi,esi
    mov dword [esp+slot_k],esi
    movsx esi,word [ebp+0x18]
    movsx esi,word [nosplit esi*2+_headspritesect]
    sar edi,0x12
L1191:
    test esi,esi
    jl near L1201
    imul edx,esi,strict byte 44
    mov ax,word [nosplit esi*2+_nextspritesect]
    mov dword [esp+slot_nextj],eax
    cmp word [edx+_sprite+0x24],strict byte 0
    jl near L1200
    mov ax,word [edx+_sprite+0x1a]
    cmp ax,strict word 0x0005
    jb short L1192
    jbe short L1193
    cmp ax,strict word 0x0006
    je short L1197
    jmp near L1200
L1192:
    cmp ax,strict word 0x0001
    jbe short L1198
    jmp near L1200
L1193:
    mov ax,word [edx+_sprite+0x0e]
    cmp ax,strict word 0x02a0
    jb short L1194
    cmp ax,strict word 0x02a1
    jbe short L1195
    cmp ax,strict word 0x04ca
    je short L1195
    jmp short L1196
L1194:
    cmp ax,strict word 0x0226
    jne short L1196
L1195:
    imul eax,esi,strict byte 44
    xor bh,bh
    mov edx,0x00000001
    mov byte [eax+_sprite+0x15],bh
    mov dword [esp+slot_k],edx
    mov byte [eax+_sprite+0x14],bh
L1196:
    imul eax,esi,strict byte 44
    cmp word [eax+_sprite+0x0e],strict word 0x0564
    jne near L1200
L1197:
    imul eax,esi,strict byte 44
    cmp word [eax+_sprite+0x0e],strict word 0x0a06
    je near L1200
L1198:
    imul eax,esi,strict byte 44
    mov dx,word [eax+_sprite+0x0e]
    cmp dx,strict word 0x04c6
    jl short L1199
    cmp dx,strict word 0x04c9
    jle near L1200
L1199:
    imul eax,esi,strict byte 44
    mov cl,byte [eax+_sprite+0x0c]
    mov dword [esp+slot_moving_sprite_cursor_1730],eax
    test cl,0x10
    jne near L1200
    lea eax,[esi*8+0x0]
    add eax,esi
    lea eax,[eax*8+0x0]
    sub eax,esi
    mov ebx,dword [esp+slot_moving_sprite_cursor_1730]
    mov edx,dword [eax+_hittype+0x13]
    mov ecx,dword [ebx+_sprite+0x8]
    sub edx,strict dword 0x00001000
    cmp edx,ecx
    jge near L1200
    mov edx,dword [ebx+_sprite]
    mov dword [eax+_hittype+0x23],edx
    mov edx,dword [ebx+_sprite+0x4]
    mov dword [eax+_hittype+0x27],edx
    mov eax,dword [esp+slot_x]
    mov edx,ebx
    sar eax,1
    mov ebx,dword [ebx+_sprite]
    add ebx,eax
    mov eax,edi
    mov ecx,dword [edx+_sprite+0x4]
    sar eax,1
    mov dword [edx+_sprite],ebx
    add ecx,eax
    mov ebx,edx
    mov dword [edx+_sprite+0x4],ecx
    mov ecx,edx
    mov eax,esi
    mov ebx,dword [ebx+_sprite+0x4]
    mov ecx,dword [ecx+_sprite+0x8]
    mov edx,dword [edx+_sprite]
    call near setsprite_
    mov edx,dword [esp+slot_moving_sprite_cursor_1730]
    movsx edx,word [edx+_sprite+0x18]
    lea eax,[edx*4+0x0]
    add eax,edx
    test byte [eax*8+_sector+0x0e],0x02
    je short L1200
    mov eax,dword [esp+slot_moving_sprite_cursor_1730]
    cmp word [eax+_sprite+0x1a],strict byte 2
    jne short L1200
    movsx eax,si
    call near makeitfall_
L1200:
    movsx esi,word [esp+slot_nextj]
    jmp near L1191
L1201:
    mov ax,word [_myconnectindex]
    mov dword [esp+slot_p],eax
    cwde
    imul eax,strict dword 0x00000552
    mov cx,word [ebp+0x18]
    cmp cx,word [eax+_ps+0x286]
    jne short L1203
    cmp byte [eax+_ps+0x51c],0x00
    je short L1203
    mov edx,dword [eax+_ps+0x21c]
    mov ebp,dword [eax+_ps+0x25c]
    mov eax,edx
    sub eax,ebp
    test eax,eax
    jns short L1202
    neg eax
L1202:
    cmp eax,strict dword 0x00002e00
    jge short L1203
    mov eax,dword [esp+slot_x]
    mov edx,dword [_fricxv]
    mov ebx,dword [_fricyv]
    lea edi,[edi*8+0x0]
    lea eax,[eax*8+0x0]
    add ebx,edi
    add edx,eax
    mov dword [_fricyv],ebx
    mov dword [_fricxv],edx
L1203:
    movsx edx,word [esp+slot_i]
    imul edx,strict byte 44
    mov ebx,dword [esp+slot_sc]
    xor eax,eax
    movsx edx,word [edx+_sprite+0x22]
    mov al,byte [ebx+0x1e]
    sar edx,0x07
    add eax,edx
    mov byte [ebx+0x1e],al
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1204:
    mov eax,dword [edx+0x4]
    cmp eax,dword [ebp+0x8]
    jle near L1208
    movsx edi,word [esp+slot_i]
    xor esi,esi
    jmp near L1207
L1205:
    call near krand_
    and ah,0x01
    mov dx,word [ebp+0x1c]
    add edx,eax
    mov eax,edi
    mov word [ebp+0x1c],dx
    mov edx,0x00000919
    call near spawn_
    mov dword [esp+slot_k],eax
    call near krand_
    mov ebx,eax
    xor bh,ah
    movsx eax,word [esp+slot_k]
    imul edx,eax,strict byte 44
    and bl,0x7f
    add ebx,strict byte 96
    mov word [edx+_sprite+0x20],bx
    mov edx,0x00010001
    call near ssp_
    movsx eax,word [esp+slot_k]
    imul edx,eax,strict byte 44
    mov ecx,dword [edx+_sprite+0x8]
    mov ebx,dword [edx+_sprite+0x4]
    mov edx,dword [edx+_sprite]
    call near setsprite_
    call near krand_
    sar eax,0x08
    cmp eax,strict dword 0x000000ef
    jl short L1206
    mov edx,0x00000762
    mov eax,edi
    call near spawn_
L1206:
    inc esi
L1207:
    cmp esi,strict byte 8
    jl near L1205
L1208:
    mov eax,dword [esp+slot_t]
    mov eax,dword [eax]
    test eax,eax
    jbe short L1209
    cmp eax,strict byte 1
    je short L1211
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1209:
    mov edx,dword [esp+slot_sc]
    movsx eax,word [ebp+0x22]
    mov ebx,dword [edx+0x4]
    add ebx,eax
    mov ecx,dword [edx+0x8]
    mov dword [edx+0x4],ebx
    cmp ebx,ecx
    jle short L1210
    mov dword [edx+0x8],ebx
L1210:
    mov eax,dword [ebp+0x8]
    mov edx,dword [esp+slot_sc]
    add eax,strict dword 0x00002000
    cmp eax,dword [edx+0x4]
    jge near L1291
    mov eax,dword [esp+slot_t]
    inc dword [eax]
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1211:
    movsx eax,word [ebp+0x22]
    mov edx,dword [esp+slot_sc]
    lea eax,[eax*4+0x0]
    mov esi,dword [edx+0x4]
    sub esi,eax
    mov dword [edx+0x4],esi
    mov edx,dword [esp+slot_t]
    mov edi,dword [edx+0x10]
    cmp esi,edi
    jge near L1291
    mov edx,dword [esp+slot_sc]
    mov eax,dword [esp+slot_t]
    mov dword [edx+0x4],edi
    mov dword [eax],0x00000000
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1212:
    cmp dword [eax+0x10],strict byte 0
    je near L1291
    mov eax,dword [edx+0x8]
    mov edi,dword [edx+0x4]
    cmp eax,edi
    jg short L1213
    mov byte [ebp+0x10],0x00
    jmp short L1214
L1213:
    mov edx,dword [esp+slot_t]
    cmp edi,dword [edx+0x10]
    jg short L1214
    mov byte [ebp+0x10],0x01
L1214:
    cmp byte [ebp+0x10],0x00
    je short L1215
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    mov edx,dword [esp+slot_sc]
    movsx eax,word [eax+_sprite+0x22]
    mov edi,dword [edx+0x4]
    shl eax,0x04
    add edi,eax
    mov ebp,dword [edx+0x8]
    mov dword [edx+0x4],edi
    cmp edi,ebp
    jle near L1291
    mov dword [edx+0x4],ebp
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1215:
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    mov edx,dword [esp+slot_sc]
    movsx eax,word [eax+_sprite+0x22]
    mov ecx,dword [edx+0x4]
    shl eax,0x04
    sub ecx,eax
    mov dword [edx+0x4],ecx
    mov edx,dword [esp+slot_t]
    mov esi,dword [edx+0x10]
    cmp ecx,esi
    jge near L1291
    mov edx,dword [esp+slot_sc]
    mov dword [edx+0x4],esi
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1216:
    movsx edi,word [ebp+0x1c]
    add edi,strict dword 0x00000200
    mov word [ebp+0x20],0x0020
    and edi,strict dword 0x000007ff
    movsx edx,word [ebp+0x20]
    movsx edi,word [nosplit edi*2+_sintable]
    imul edi,edx
    mov ax,word [ebp+0x1c]
    and ah,0x07
    cwde
    movsx eax,word [nosplit eax*2+_sintable]
    movsx edx,word [ebp+0x20]
    imul eax,edx
    sar eax,0x0e
    mov dword [esp+slot_x],eax
    mov ch,byte [ebp+0x10]
    inc ch
    sar edi,0x0e
    mov byte [ebp+0x10],ch
    cmp ch,0x07
    jle short L1217
    mov eax,dword [esp+slot_t]
    mov eax,dword [eax+0x0c]
    mov dword [ebp+0x0],eax
    mov eax,dword [esp+slot_t]
    mov eax,dword [eax+0x10]
    mov dword [ebp+0x4],eax
    movsx edx,word [ebp+0x24]
    movsx eax,byte [ebp+0x10]
    imul edx,eax
    movsx eax,word [ebp+0x24]
    sub edx,eax
    mov eax,dword [esp+slot_sc]
    sub dword [eax+0x8],edx
    mov byte [ebp+0x10],0x00
    jmp short L1218
L1217:
    mov edx,dword [esp+slot_sc]
    movsx eax,word [ebp+0x24]
    add dword [edx+0x8],eax
L1218:
    movsx eax,word [ebp+0x18]
    movsx esi,word [nosplit eax*2+_headspritesect]
L1219:
    test esi,esi
    jl near L1221
    imul edx,esi,strict byte 44
    mov ax,word [nosplit esi*2+_nextspritesect]
    mov cx,word [edx+_sprite+0x1a]
    mov dword [esp+slot_nextj],eax
    cmp cx,strict byte 3
    je short L1220
    cmp cx,strict byte 10
    je short L1220
    lea eax,[esi*8+0x0]
    add eax,esi
    lea eax,[eax*8+0x0]
    sub eax,esi
    mov ebx,dword [edx+_sprite]
    mov dword [eax+_hittype+0x23],ebx
    mov ebx,dword [edx+_sprite+0x4]
    mov dword [eax+_hittype+0x27],ebx
    mov eax,dword [edx+_sprite]
    add eax,edi
    mov ebx,dword [edx+_sprite+0x4]
    mov dword [edx+_sprite],eax
    mov eax,dword [esp+slot_x]
    add ebx,eax
    mov dword [edx+_sprite+0x4],ebx
    mov ecx,dword [edx+_sprite+0x8]
    movsx eax,word [ebp+0x24]
    add ecx,eax
    mov ebx,dword [edx+_sprite+0x4]
    mov dword [edx+_sprite+0x8],ecx
    mov eax,esi
    mov edx,dword [edx+_sprite]
    call near setsprite_
L1220:
    movsx esi,word [esp+slot_nextj]
    jmp near L1219
L1221:
    mov ax,word [_myconnectindex]
    mov dword [esp+slot_p],eax
    cwde
    imul eax,strict dword 0x00000552
    movsx edx,word [eax+_ps+0x2d4]
    imul edx,strict byte 44
    mov bx,word [ebp+0x18]
    cmp bx,word [edx+_sprite+0x18]
    jne short L1222
    cmp byte [eax+_ps+0x51c],0x00
    je short L1222
    mov eax,dword [esp+slot_x]
    mov ecx,dword [_fricxv]
    mov esi,dword [_fricyv]
    shl edi,0x05
    shl eax,0x05
    add ecx,edi
    add esi,eax
    mov dword [_fricxv],ecx
    mov dword [_fricyv],esi
L1222:
    mov ax,word [_connecthead]
    jmp short L1225
L1223:
    movsx eax,dx
    imul eax,strict dword 0x00000552
    movsx edx,word [eax+_ps+0x2d4]
    imul edx,strict byte 44
    mov bx,word [ebp+0x18]
    cmp bx,word [edx+_sprite+0x18]
    jne short L1224
    cmp byte [eax+_ps+0x51c],0x00
    je short L1224
    movsx edx,word [ebp+0x24]
    add dword [eax+_ps+0x21c],edx
L1224:
    movsx eax,word [esp+slot_p]
    mov ax,word [nosplit eax*2+_connectpoint2]
L1225:
    mov dword [esp+slot_p],eax
    mov edx,dword [esp+slot_p]
    test dx,dx
    jge short L1223
L1226:
    movsx esi,word [esp+slot_i]
    mov eax,esi
    call near ms_
    mov eax,esi
    mov ecx,dword [ebp+0x8]
    mov ebx,dword [ebp+0x4]
    mov edx,dword [ebp+0x0]
    call near setsprite_
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1227:
    cmp dword [_ud+0x5fa],strict byte 0
    je near L1291
    movsx edx,word [esp+slot_i]
    lea eax,[edx*8+0x0]
    add eax,edx
    lea eax,[eax*8+0x0]
    sub eax,edx
    mov edx,eax
    mov ax,word [ebp+0x1c]
    mov word [edx+_hittype+0x0b],ax
    mov edx,esp
    mov eax,ebp
    call near findplayer_
    mov dword [esp+slot_p],eax
    cwde
    imul eax,strict dword 0x00000552
    movsx eax,word [eax+_ps+0x2d4]
    imul eax,strict byte 44
    cmp word [eax+_sprite+0x2a],strict byte 0
    jle near L1291
    mov ax,word [_myconnectindex]
    cmp ax,word [_screenpeek]
    jne near L1291
    mov eax,dword [esp+slot_t]
    cmp dword [eax],strict byte 0
    jge short L1228
    mov eax,dword [esp+slot_i]
    mov word [_ud+0x58c],ax
    mov eax,dword [esp+slot_t]
    inc dword [eax]
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1228:
    cmp dword [_ud+0x5fa],strict byte 2
    jne near L1291
    movsx eax,word [esp+slot_p]
    imul eax,strict dword 0x00000552
    movsx eax,word [eax+_ps+0x2b2]
    cmp eax,strict byte -1
    jne near L1291
    movsx eax,word [esp+slot_p]
    imul eax,strict dword 0x00000552
    movsx eax,word [eax+_ps+0x286]
    push eax
    movsx eax,word [esp+slot_p+4]
    imul eax,strict dword 0x00000552
    mov edi,dword [eax+_ps+0x21c]
    movsx eax,word [esp+slot_p+4]
    imul eax,strict dword 0x00000552
    movsx ecx,word [esp+slot_i+4]
    imul ecx,strict byte 44
    mov edx,dword [eax+_ps+0x218]
    movsx eax,word [esp+slot_p+4]
    imul eax,strict dword 0x00000552
    push edi
    movsx ecx,word [ecx+_sprite+0x18]
    push edx
    mov ebx,dword [eax+_ps+0x214]
    mov edx,dword [ebp+0x4]
    push ebx
    mov eax,dword [ebp+0x0]
    mov ebx,dword [ebp+0x8]
    call near cansee_
    test eax,eax
    je near L1232
    movsx eax,word [esp+slot_sh]
    cmp eax,dword [esp+slot_x]
    jbe near L1229
    movsx edx,word [esp+slot_p]
    imul edx,strict dword 0x00000552
    mov eax,dword [esp+slot_i]
    mov word [_ud+0x58c],ax
    mov eax,dword [esp+slot_t]
    mov dword [eax],0x000003e7
    movsx eax,word [esp+slot_p]
    imul eax,strict dword 0x00000552
    mov ecx,dword [ebp+0x4]
    mov esi,dword [ebp+0x0]
    mov edx,dword [edx+_ps+0x218]
    mov eax,dword [eax+_ps+0x214]
    sub edx,ecx
    sub eax,esi
    call near getangle_
    movsx edx,ax
    movsx eax,word [ebp+0x1c]
    call near getincangle_
    cwde
    mov edx,eax
    sar edx,0x03
    movsx eax,word [ebp+0x1c]
    add eax,edx
    mov word [ebp+0x1c],ax
    movsx eax,word [esp+slot_p]
    imul eax,strict dword 0x00000552
    mov edx,dword [ebp+0x8]
    sub edx,dword [eax+_ps+0x21c]
    mov ebx,0x00000101
    mov eax,edx
    sar edx,0x1f
    idiv ebx
    movsx edx,word [esp+slot_i]
    imul edx,strict byte 44
    add eax,strict byte 100
    mov word [edx+_sprite+0x22],ax
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1229:
    mov eax,dword [esp+slot_t]
    cmp dword [eax],strict dword 0x000003e7
    jne near L1291
    mov ecx,dword [esp+slot_i]
    cmp cx,word [_ud+0x58c]
    jne short L1230
    mov eax,dword [esp+slot_t]
    mov dword [eax],0x00000000
    jmp short L1231
L1230:
    mov eax,dword [esp+slot_t]
    mov dword [eax],0x0fffffff6
L1231:
    mov eax,dword [esp+slot_i]
    mov word [_ud+0x58c],ax
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1232:
    movsx edx,word [esp+slot_p]
    imul edx,strict dword 0x00000552
    movsx eax,word [esp+slot_p]
    imul eax,strict dword 0x00000552
    mov ecx,dword [ebp+0x4]
    mov esi,dword [ebp+0x0]
    mov edx,dword [edx+_ps+0x218]
    mov eax,dword [eax+_ps+0x214]
    sub edx,ecx
    sub eax,esi
    call near getangle_
    mov word [ebp+0x1c],ax
    mov eax,dword [esp+slot_t]
    cmp dword [eax],strict dword 0x000003e7
    jne near L1291
    mov ebx,dword [esp+slot_i]
    cmp bx,word [_ud+0x58c]
    jne short L1233
    mov eax,dword [esp+slot_t]
    mov dword [eax],0x00000000
    jmp short L1234
L1233:
    mov eax,dword [esp+slot_t]
    mov dword [eax],0x0ffffffec
L1234:
    mov eax,dword [esp+slot_i]
    mov word [_ud+0x58c],ax
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1235:
    mov si,word [ebp+0x28]
    add esi,strict byte 64
    mov eax,esi
    and ah,0x07
    cwde
    mov word [ebp+0x28],si
    mov dx,word [nosplit eax*2+_sintable]
    movsx ebx,dx
    movsx eax,word [ebp+0x22]
    imul ebx
    shrd eax,edx,0x0c
    mov edi,eax
    mov eax,dword [ebp+0x8]
    mov edx,dword [esp+slot_sc]
    add eax,edi
    mov dword [edx+0x8],eax
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1236:
    mov edi,dword [eax]
    cmp edi,strict byte 1
    jne near L1291
    mov edx,dword [eax+0x0c]
    test edx,edx
    jle short L1237
    mov esi,edx
    sub esi,edi
    mov dword [eax+0x0c],esi
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1237:
    cmp edi,dword [eax+0x8]
    jne near L1251
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    cmp word [eax+_sprite+0x1c],strict word 0x0600
    je near L1244
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    movsx eax,word [eax+_sprite+0x22]
    lea edx,[nosplit eax*2+0x0]
    mov eax,dword [esp+slot_sc]
    mov esi,dword [ebp+0x8]
    mov eax,dword [eax+0x8]
    sub eax,esi
    test eax,eax
    jns short L1238
    neg eax
L1238:
    cmp eax,edx
    jge short L1239
    mov edx,dword [esp+slot_sc]
    mov eax,dword [ebp+0x8]
    mov dword [edx+0x8],eax
    mov eax,dword [esp+slot_t]
    mov dword [eax+0x8],0x00000000
    mov dword [eax],0x00000000
    mov edx,dword [esp+slot_t]
    movsx eax,word [ebp+0x28]
    mov dword [edx+0x0c],eax
    movsx edx,word [esp+slot_i]
    movsx eax,word [ebp+0x18]
    call near callsound_
L1239:
    mov eax,dword [esp+slot_t]
    mov edi,dword [eax]
    test edi,edi
    je short L1240
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    mov edx,dword [esp+slot_sc]
    mov ebx,dword [edx+0x8]
    movsx edi,word [eax+_sprite+0x22]
    mov eax,dword [ebp+0x8]
    sub eax,ebx
    mov ebx,eax
    add ebx,ebx
    sbb eax,eax
    cmp eax,ebx
    adc eax,strict byte 0
    imul edi,eax
    add dword [edx+0x8],edi
L1240:
    movsx eax,word [ebp+0x18]
    movsx esi,word [nosplit eax*2+_headspritesect]
L1241:
    test esi,esi
    jl near L1291
    imul eax,esi,strict byte 44
    cmp word [eax+_sprite+0x0e],strict word 0x057d
    jne short L1242
    cmp word [eax+_sprite+0x1e],strict byte 0
    jl short L1242
    movsx eax,word [eax+_sprite+0x22]
    imul eax,strict dword 0x00000552
    cmp byte [eax+_ps+0x51c],0x01
    jne short L1242
    add dword [eax+_ps+0x21c],edi
L1242:
    imul edx,esi,strict byte 44
    cmp word [edx+_sprite+0x24],strict byte 0
    jne short L1243
    cmp word [edx+_sprite+0x1a],strict byte 3
    je short L1243
    lea eax,[esi*8+0x0]
    add eax,esi
    lea eax,[eax*8+0x0]
    sub eax,esi
    mov ebx,dword [edx+_sprite+0x8]
    mov dword [eax+_hittype+0x2b],ebx
    lea ebp,[ebx+edi]
    mov dword [edx+_sprite+0x8],ebp
    mov edx,dword [esp+slot_sc]
    mov edx,dword [edx+0x8]
    mov dword [eax+_hittype+0x13],edx
L1243:
    movsx esi,word [nosplit esi*2+_nextspritesect]
    jmp near L1241
L1244:
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    mov ebx,dword [esp+slot_t]
    movsx edx,word [eax+_sprite+0x22]
    mov eax,dword [esp+slot_sc]
    mov esi,dword [ebx+0x4]
    mov eax,dword [eax+0x8]
    sub eax,esi
    add edx,edx
    test eax,eax
    jns short L1245
    neg eax
L1245:
    cmp eax,edx
    jge short L1246
    mov edx,dword [esp+slot_sc]
    mov eax,dword [ebx+0x4]
    mov dword [edx+0x8],eax
    movsx edx,word [esp+slot_i]
    movsx eax,word [ebp+0x18]
    call near callsound_
    mov dword [ebx+0x8],0x00000000
    mov dword [ebx],0x00000000
    movsx eax,word [ebp+0x28]
    mov dword [ebx+0x0c],eax
L1246:
    mov eax,dword [esp+slot_t]
    mov edi,dword [eax]
    test edi,edi
    je short L1247
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    mov edx,dword [esp+slot_sc]
    movsx edi,word [eax+_sprite+0x22]
    mov eax,dword [esp+slot_t]
    mov ebx,dword [edx+0x8]
    mov eax,dword [eax+0x4]
    sub eax,ebx
    mov ebx,eax
    add ebx,ebx
    sbb eax,eax
    cmp eax,ebx
    adc eax,strict byte 0
    imul edi,eax
    add dword [edx+0x8],edi
L1247:
    movsx esi,word [ebp+0x18]
    movsx esi,word [nosplit esi*2+_headspritesect]
L1248:
    test esi,esi
    jl near L1291
    imul eax,esi,strict byte 44
    cmp word [eax+_sprite+0x0e],strict word 0x057d
    jne short L1249
    cmp word [eax+_sprite+0x1e],strict byte 0
    jl short L1249
    movsx eax,word [eax+_sprite+0x22]
    imul eax,strict dword 0x00000552
    cmp byte [eax+_ps+0x51c],0x01
    jne short L1249
    add dword [eax+_ps+0x21c],edi
L1249:
    imul edx,esi,strict byte 44
    cmp word [edx+_sprite+0x24],strict byte 0
    jne short L1250
    cmp word [edx+_sprite+0x1a],strict byte 3
    je short L1250
    lea eax,[esi*8+0x0]
    add eax,esi
    lea eax,[eax*8+0x0]
    sub eax,esi
    mov ebx,dword [edx+_sprite+0x8]
    mov dword [eax+_hittype+0x2b],ebx
    add ebx,edi
    mov dword [edx+_sprite+0x8],ebx
    mov edx,dword [esp+slot_sc]
    mov edx,dword [edx+0x8]
    mov dword [eax+_hittype+0x13],edx
L1250:
    movsx esi,word [nosplit esi*2+_nextspritesect]
    jmp near L1248
L1251:
    mov ax,word [ebp+0x1c]
    and ah,0x07
    cmp ax,strict word 0x0600
    jne near L1258
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    movsx eax,word [eax+_sprite+0x22]
    mov ebx,dword [esp+slot_sc]
    lea edx,[nosplit eax*2+0x0]
    mov esi,dword [ebx+0x8]
    mov eax,dword [ebp+0x8]
    sub eax,esi
    test eax,eax
    jns short L1252
    neg eax
L1252:
    cmp eax,edx
    jge short L1253
    movsx edx,word [esp+slot_i]
    movsx eax,word [ebp+0x18]
    call near callsound_
    mov eax,dword [esp+slot_t]
    mov dword [eax],0x00000000
    mov dword [eax+0x8],edi
    mov edx,dword [esp+slot_t]
    movsx eax,word [ebp+0x28]
    mov dword [edx+0x0c],eax
L1253:
    mov eax,dword [esp+slot_t]
    mov edi,dword [eax]
    test edi,edi
    je short L1254
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    mov edx,dword [esp+slot_sc]
    mov ebx,dword [edx+0x8]
    movsx edi,word [eax+_sprite+0x22]
    mov eax,dword [ebp+0x8]
    sub eax,ebx
    mov ebx,eax
    add ebx,ebx
    sbb eax,eax
    cmp eax,ebx
    adc eax,strict byte 0
    imul edi,eax
    add dword [edx+0x8],edi
L1254:
    movsx eax,word [ebp+0x18]
    movsx esi,word [nosplit eax*2+_headspritesect]
L1255:
    test esi,esi
    jl near L1291
    imul eax,esi,strict byte 44
    cmp word [eax+_sprite+0x0e],strict word 0x057d
    jne short L1256
    cmp word [eax+_sprite+0x1e],strict byte 0
    jl short L1256
    movsx eax,word [eax+_sprite+0x22]
    imul eax,strict dword 0x00000552
    cmp byte [eax+_ps+0x51c],0x01
    jne short L1256
    add dword [eax+_ps+0x21c],edi
L1256:
    imul edx,esi,strict byte 44
    cmp word [edx+_sprite+0x24],strict byte 0
    jne short L1257
    cmp word [edx+_sprite+0x1a],strict byte 3
    je short L1257
    lea eax,[esi*8+0x0]
    add eax,esi
    lea eax,[eax*8+0x0]
    sub eax,esi
    mov ebx,dword [edx+_sprite+0x8]
    mov dword [eax+_hittype+0x2b],ebx
    lea ebp,[ebx+edi]
    mov dword [edx+_sprite+0x8],ebp
    mov edx,dword [esp+slot_sc]
    mov edx,dword [edx+0x8]
    mov dword [eax+_hittype+0x13],edx
L1257:
    movsx esi,word [nosplit esi*2+_nextspritesect]
    jmp near L1255
L1258:
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    movsx eax,word [eax+_sprite+0x22]
    lea edx,[nosplit eax*2+0x0]
    mov ebx,dword [esp+slot_t]
    mov eax,dword [esp+slot_sc]
    mov ecx,dword [ebx+0x4]
    mov eax,dword [eax+0x8]
    sub eax,ecx
    test eax,eax
    jns short L1259
    neg eax
L1259:
    cmp eax,edx
    jge short L1260
    mov dword [ebx],0x00000000
    movsx edx,word [esp+slot_i]
    movsx eax,word [ebp+0x18]
    call near callsound_
    mov dword [ebx+0x8],edi
    movsx eax,word [ebp+0x28]
    mov dword [ebx+0x0c],eax
L1260:
    mov eax,dword [esp+slot_t]
    cmp dword [eax],strict byte 0
    jne short L1261
    xor edi,edi
    jmp short L1262
L1261:
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    mov edx,dword [esp+slot_t]
    mov ebx,dword [edx+0x4]
    movsx edi,word [eax+_sprite+0x22]
    mov eax,dword [ebp+0x8]
    sub eax,ebx
    mov ebx,eax
    add ebx,ebx
    sbb eax,eax
    cmp eax,ebx
    adc eax,strict byte 0
    imul edi,eax
    mov eax,dword [esp+slot_sc]
    sub dword [eax+0x8],edi
L1262:
    movsx eax,word [ebp+0x18]
    movsx esi,word [nosplit eax*2+_headspritesect]
L1263:
    test esi,esi
    jl near L1291
    imul eax,esi,strict byte 44
    cmp word [eax+_sprite+0x0e],strict word 0x057d
    jne short L1264
    cmp word [eax+_sprite+0x1e],strict byte 0
    jl short L1264
    movsx eax,word [eax+_sprite+0x22]
    imul eax,strict dword 0x00000552
    cmp byte [eax+_ps+0x51c],0x01
    jne short L1264
    sub dword [eax+_ps+0x21c],edi
L1264:
    imul edx,esi,strict byte 44
    cmp word [edx+_sprite+0x24],strict byte 0
    jne short L1265
    cmp word [edx+_sprite+0x1a],strict byte 3
    je short L1265
    lea eax,[esi*8+0x0]
    add eax,esi
    lea eax,[eax*8+0x0]
    sub eax,esi
    mov ebx,dword [edx+_sprite+0x8]
    mov dword [eax+_hittype+0x2b],ebx
    sub ebx,edi
    mov dword [edx+_sprite+0x8],ebx
    mov edx,dword [esp+slot_sc]
    mov edx,dword [edx+0x8]
    mov dword [eax+_hittype+0x13],edx
L1265:
    movsx esi,word [nosplit esi*2+_nextspritesect]
    jmp near L1263
L1266:
    mov edi,dword [eax]
    cmp edi,strict byte 1
    jne near L1291
    cmp edi,dword [eax+0x8]
    jne near L1272
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    cmp word [eax+_sprite+0x1c],strict word 0x0600
    je near L1269
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    movsx eax,word [eax+_sprite+0x22]
    lea edx,[nosplit eax*2+0x0]
    mov eax,dword [esp+slot_sc]
    mov ebx,dword [ebp+0x8]
    mov eax,dword [eax+0x4]
    sub eax,ebx
    test eax,eax
    jns short L1267
    neg eax
L1267:
    cmp eax,edx
    jge short L1268
    mov edx,dword [esp+slot_sc]
    mov eax,dword [ebp+0x8]
    mov dword [edx+0x4],eax
    movsx edx,word [esp+slot_i]
    movsx eax,word [ebp+0x18]
    call near callsound_
    mov eax,dword [esp+slot_t]
    mov dword [eax+0x8],0x00000000
    mov dword [eax],0x00000000
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1268:
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    mov ebx,dword [esp+slot_sc]
    movsx edx,word [eax+_sprite+0x22]
    mov eax,dword [ebp+0x8]
    mov ecx,dword [ebx+0x4]
    mov ebx,eax
    sub ebx,ecx
    add ebx,ebx
    sbb eax,eax
    cmp eax,ebx
    adc eax,strict byte 0
    imul eax,edx
    mov edx,dword [esp+slot_sc]
    add dword [edx+0x4],eax
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1269:
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    movsx eax,word [eax+_sprite+0x22]
    lea edx,[nosplit eax*2+0x0]
    mov ebx,dword [esp+slot_t]
    mov eax,dword [esp+slot_sc]
    mov ecx,dword [ebx+0x4]
    mov eax,dword [eax+0x4]
    sub eax,ecx
    test eax,eax
    jns short L1270
    neg eax
L1270:
    cmp eax,edx
    jge short L1271
    mov edx,dword [esp+slot_sc]
    mov eax,dword [ebx+0x4]
    mov dword [edx+0x4],eax
    movsx edx,word [esp+slot_i]
    movsx eax,word [ebp+0x18]
    call near callsound_
    mov dword [ebx+0x8],0x00000000
    mov dword [ebx],0x00000000
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1271:
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    movsx edx,word [eax+_sprite+0x22]
    mov eax,dword [ebx+0x4]
    mov ebx,dword [esp+slot_sc]
    mov esi,dword [ebx+0x4]
    mov ebx,eax
    sub ebx,esi
    add ebx,ebx
    sbb eax,eax
    cmp eax,ebx
    adc eax,strict byte 0
    imul eax,edx
    mov edx,dword [esp+slot_sc]
    add dword [edx+0x4],eax
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1272:
    mov ax,word [ebp+0x1c]
    and ah,0x07
    cmp ax,strict word 0x0600
    jne short L1274
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    movsx eax,word [eax+_sprite+0x22]
    lea edx,[nosplit eax*2+0x0]
    mov eax,dword [esp+slot_sc]
    mov ebx,dword [ebp+0x8]
    mov eax,dword [eax+0x4]
    sub eax,ebx
    test eax,eax
    jns short L1273
    neg eax
L1273:
    cmp eax,edx
    jge near L1268
    mov eax,dword [esp+slot_t]
    mov edi,dword [eax+0x8]
    mov dword [eax],0x00000000
    test edi,edi
    sete al
    mov edx,eax
    mov eax,dword [esp+slot_t]
    and edx,strict dword 0x000000ff
    mov dword [eax+0x8],edx
    movsx edx,word [esp+slot_i]
    movsx eax,word [ebp+0x18]
    call near callsound_
    mov edx,dword [esp+slot_sc]
    mov eax,dword [ebp+0x8]
    mov dword [edx+0x4],eax
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1274:
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    mov ebx,dword [esp+slot_t]
    movsx edx,word [eax+_sprite+0x22]
    mov eax,dword [esp+slot_sc]
    mov ecx,dword [ebx+0x4]
    mov eax,dword [eax+0x4]
    sub eax,ecx
    add edx,edx
    test eax,eax
    jns short L1275
    neg eax
L1275:
    cmp eax,edx
    jge short L1276
    mov edx,dword [ebx+0x8]
    mov dword [ebx],0x00000000
    test edx,edx
    sete al
    mov edx,eax
    and edx,strict dword 0x000000ff
    mov dword [ebx+0x8],edx
    movsx edx,word [esp+slot_i]
    movsx eax,word [ebp+0x18]
    call near callsound_
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1276:
    movsx eax,word [esp+slot_i]
    imul eax,strict byte 44
    movsx edx,word [eax+_sprite+0x22]
    mov eax,dword [ebp+0x8]
    mov esi,dword [ebx+0x4]
    mov ebx,eax
    sub ebx,esi
    add ebx,ebx
    sbb eax,eax
    cmp eax,ebx
    adc eax,strict byte 0
    imul eax,edx
    mov edx,dword [esp+slot_sc]
    sub dword [edx+0x4],eax
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1277:
    cmp byte [_earthquaketime],0x00
    jbe near L1291
    call near krand_
    test al,0x07
    jne near L1291
    mov eax,0x00000005
    push eax
    movsx eax,word [esp+slot_i+4]
    push eax
    mov edx,0x0fffffe00
    call near krand_
    and eax,strict dword 0x000007ff
    sub edx,eax
    push edx
    call near krand_
    xor ah,ah
    and al,0x3f
    add eax,strict dword 0x00000040
    cwde
    push eax
    call near krand_
    and ah,0x07
    cwde
    push eax
    mov eax,0x00000030
    push eax
    push eax
    mov eax,0x0fffffff8
    push eax
    call near krand_
    xor ah,ah
    mov ecx,dword [ebp+0x8]
    and al,0x0f
    mov ebx,dword [ebp+0x4]
    add eax,strict dword 0x00000956
    mov edx,dword [ebp+0x0]
    cwde
    sub ecx,strict dword 0x00000c00
    push eax
    movsx eax,word [ebp+0x18]
    call near EGS_
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1278:
    mov esi,dword [eax]
    test esi,esi
    je near L1291
    cmp esi,strict byte 1
    jne short L1279
    mov eax,ebx
    movsx edx,word [edx+0x26]
    call near shoot_
    jmp short L1280
L1279:
    cmp esi,strict dword 0x00000082
    jne short L1280
    mov dword [eax],0x00000000
L1280:
    mov eax,dword [esp+slot_t]
    inc dword [eax]
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1281:
    mov edx,dword [eax+0x8]
    shl edx,0x05
    add edx,_wall
    mov ax,word [edx+0x0e]
    or al,0x20
    test ax,ax
    je near L1291
    mov bx,word [edx+0x0e]
    xor bh,bh
    and bl,0x0cf
    mov word [edx+0x0e],bx
    mov ah,byte [edx+0x0e]
    or ah,0x10
    mov cx,word [edx+0x0a]
    mov byte [edx+0x0e],ah
    test cx,cx
    jl short L1282
    movsx eax,cx
    shl eax,0x05
    and word [eax+_wall+0x0e],strict word 0x00df
    movsx eax,word [edx+0x0a]
    shl eax,0x05
    or byte [eax+_wall+0x0e],0x10
L1282:
    mov di,word [edx+0x12]
    inc edi
    mov ax,word [edx+0x0a]
    mov word [edx+0x12],di
    test ax,ax
    jl short L1283
    cwde
    shl eax,0x05
    inc word [eax+_wall+0x12]
L1283:
    mov eax,dword [esp+slot_t]
    mov ebx,dword [esp+slot_t]
    mov eax,dword [eax]
    cmp eax,dword [ebx+0x4]
    jl short L1285
    mov cx,word [edx+0x0e]
    xor ch,ch
    and cl,0x0ae
    mov si,word [edx+0x0a]
    mov word [edx+0x0e],cx
    test si,si
    jl short L1284
    movsx eax,si
    shl eax,0x05
    and word [eax+_wall+0x0e],strict word 0x00ae
L1284:
    movsx eax,word [esp+slot_i]
    call near deletesprite_
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1285:
    inc dword [ebx]
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1286:
    mov edx,dword [eax]
    cmp edx,strict byte 80
    jle short L1287
    mov eax,ebx
    call near deletesprite_
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1287:
    lea ecx,[edx+0x1]
    mov edx,dword [esp+slot_sc]
    mov dword [eax],ecx
    mov eax,dword [esp+slot_sc]
    mov esi,dword [edx+0x4]
    mov eax,dword [eax+0x8]
    sub eax,esi
    mov dword [esp+slot_x],eax
    call near krand_
    sar eax,0x08
    cmp eax,strict dword 0x000000bf
    jl near L1291
    mov edx,0x00000762
    mov eax,ebx
    call near spawn_
    mov dword [esp+slot_k],eax
    call near krand_
    mov dl,al
    movsx eax,word [esp+slot_k]
    imul eax,strict byte 44
    and dl,0x07
    add dl,0x02
    mov byte [eax+_sprite+0x15],dl
    mov byte [eax+_sprite+0x14],dl
    call near krand_
    mov edx,eax
    mov edi,dword [esp+slot_x]
    sar edx,0x1f
    idiv edi
    jmp near L1290
L1288:
    mov ecx,dword [eax]
    cmp ecx,strict byte 40
    jle short L1289
    mov eax,ebx
    call near deletesprite_
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1289:
    lea esi,[ecx+0x1]
    mov dword [eax],esi
    mov eax,dword [edx+0x8]
    mov edi,dword [edx+0x4]
    sub eax,edi
    mov dword [esp+slot_x],eax
    call near krand_
    sar eax,0x08
    cmp eax,strict dword 0x000000df
    jl near L1291
    mov edx,0x00000762
    mov eax,ebx
    call near spawn_
    mov dword [esp+slot_k],eax
    call near krand_
    mov dl,al
    movsx eax,word [esp+slot_k]
    imul eax,strict byte 44
    and dl,0x03
    add dl,0x02
    mov byte [eax+_sprite+0x15],dl
    mov byte [eax+_sprite+0x14],dl
    call near krand_
    mov edx,eax
    mov ebp,dword [esp+slot_x]
    sar edx,0x1f
    idiv ebp
L1290:
    movsx ebx,word [esp+slot_k]
    imul ebx,strict byte 44
    mov eax,dword [esp+slot_sc]
    mov eax,dword [eax+0x8]
    sub eax,edx
    mov dword [ebx+_sprite+0x8],eax
    call near krand_
    mov edx,eax
    mov ecx,0x000001ff
    sar edx,0x1f
    idiv ecx
    mov eax,0x00000100
    sub eax,edx
    mov edx,eax
    movsx eax,word [ebx+_sprite+0x1c]
    add eax,edx
    mov word [ebx+_sprite+0x1c],ax
    call near krand_
    mov edx,eax
    xor dh,ah
    movsx eax,word [esp+slot_k]
    imul ebx,eax,strict byte 44
    and dl,0x7f
    mov word [ebx+_sprite+0x20],dx
    mov edx,0x00010001
    call near ssp_
L1291:
    mov eax,dword [esp+slot_nexti]
    jmp near L895
L1292:
    mov ax,word [_headspritestat+0x6]
    jmp near L1295
L1293:
    movsx eax,bx
    imul eax,strict byte 44
    mov ebp,_sprite
    add ebp,eax
    cmp word [ebp+0x26],strict byte 29
    jne short L1294
    movsx esi,word [ebp+0x18]
    lea eax,[esi*4+0x0]
    add eax,esi
    mov edx,_sector
    lea eax,[eax*8+0x0]
    add edx,eax
    mov di,word [edx+0x2]
    mov dword [esp+slot_sc],edx
    cmp di,strict byte 4
    jne short L1294
    movsx eax,word [edx]
    shl eax,0x05
    mov edx,_wall
    add eax,strict byte 64
    add edx,eax
    movsx ebx,word [edx+0x0c]
    lea eax,[ebx*4+0x0]
    add eax,ebx
    mov ecx,dword [eax*8+_sector+0x8]
    mov ebx,dword [edx+0x4]
    mov eax,esi
    mov edx,dword [edx]
    call near alignflorslope_
L1294:
    movsx eax,word [esp+slot_i]
    mov ax,word [nosplit eax*2+_nextspritestat]
L1295:
    mov dword [esp+slot_i],eax
    mov ebx,dword [esp+slot_i]
    test bx,bx
    jge near L1293
    add esp,strict byte 88
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
segment CONST public align=4 use32 class=DATA
L1296: db "Could not find any locators for SE# 6 and 14 with a hitag of %ld.",10,0
