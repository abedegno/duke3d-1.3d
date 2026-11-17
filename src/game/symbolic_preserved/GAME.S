# SPDX-License-Identifier: GPL-2.0-or-later
# Whole readable GAME backend, private target-stage reconstruction.
# Derived from the source-built OWN-C backend plus native-observed valueflow.
# Full original 3D Realms/Matt Saettler notices remain in unchanged C counterpart.
# Humanization and normal source-grade admission remain unfinished.
.intel_syntax noprefix
.code32
.file "GAME.S"
.allow_index_reg
.equ VICTORY1, 3260
.local _frameval
.globl _recbuf
.globl _endingpal
.globl _titlepal
.globl _waterpal
.globl _drealms
.globl _slimepal
.globl _nonsharedtimer
.globl _recfilep
.globl _rtsptr
.globl _totalreccnt
.globl _tempwallptr
.globl _cameradist
.globl _cameraclock
.globl _eightytwofifty
.local _inferred_serial_alignment
.globl _CommandSoundToggleOff
.globl _CommandMusicToggleOff
.globl _confilename
.globl _groupfilename
.globl _boardfilename
.globl _debug_on
.globl _actor_tog
.globl _memorycheckoveride
.globl _frecfilep
.local _todd
.local _inferred_copyright_alignment
.globl _TimerPtr
.local _framecnt
.globl _inputloc
.local _inferred_inputloc_alignment
.local _oyrepeat
.globl timerhandler_
.globl inittimer_
.globl uninittimer_
.globl gametext_
.globl gametextpart_
.globl minitext_
.globl gamenumber_
.globl allowtimetocorrecterrorswhenquitting_
.globl getpackets_
.globl faketimerhandler_
.globl checksync_
.globl check_fta_sounds_
.globl inventory_
.globl badguy_
.globl badguypic_
.globl myos_
.globl myospal_
.globl invennum_
.globl weaponnum_
.globl weaponnum999_
.globl weapon_amounts_
.globl digitalnumber_
.globl displayinventory_
.globl displayfragbar_
.globl coolgaugetext_
.globl tics_
.globl caches_
.globl coords_
.globl operatefta_
.globl FTA_
.globl showtwoscreens_
.globl binscreen_
.globl gameexit_
.globl strget_
.globl displayrest_
.globl updatesectorz_
.globl view_
.globl drawbackground_
.globl displayrooms_
.globl LocateTheLocator_
.globl EGS_
.globl wallswitchcheck_
.globl spawn_
.globl animatesprites_
.globl cheats_
.globl nonsharedkeys_
.globl comlinehelp_
.globl checkcommandline_
.globl printstr_
.globl Logo_
.globl loadtmb_
.globl ShutDown_
.globl compilecons_
.globl Startup_
.globl sendscore_
.globl getnames_
.globl main_
.globl opendemoread_
.globl opendemowrite_
.globl record_
.globl closedemowrite_
.globl playback_
.globl moveloop_
.globl fakedomovethingscorrect_
.globl fakedomovethings_
.globl domovethings_
.globl doorders_
.globl dobonus_
.globl cameratext_
.globl vglass_
.globl lotsofglass_
.globl spriteglass_
.globl ceilingglass_
.globl lotsofcolourglass_
.globl SetupGameButtons_
.globl GetTime_
.globl CenterCenter_
.globl UpperLeft_
.globl LowerRight_
.globl CenterThrottle_
.globl CenterRudder_
.globl _cheatquotes
.globl _which_demo
.globl _in_menu
.local _dmval
.extern CONFIG_GetSetupFilename_
.extern CONFIG_ReadSetup_
.extern CONFIG_WriteSetup_
.extern CONTROL_CenterJoystick_
.extern CONTROL_ClearButton_
.extern CONTROL_DefineFlag_
.extern CONTROL_GetInput_
.extern CONTROL_Shutdown_
.extern CONTROL_Startup_
.extern FX_PlayVOC3D_
.extern FX_PlayWAV3D_
.extern FX_SetReverb_
.extern FX_StopAllSounds_
.extern FindDistance2D_
.extern KB_FlushKeyBoardQueue_
.extern KB_FlushKeyboardQueue_
.extern KB_Getch_
.extern KB_KeyWaiting_
.extern KB_Shutdown_
.extern KB_Startup_
.extern MUSIC_RegisterTimbreBank_
.extern MUSIC_StopSong_
.extern MusicShutdown_
.extern MusicStartup_
.extern RTS_GetSound_
.extern RTS_Init_
.extern RTS_NumSounds_
.extern RegisterShutdownFunction_
.extern SafeFileExists_
.extern SoundShutdown_
.extern SoundStartup_
.extern TS_Dispatch_
.extern TS_ScheduleTask_
.extern TS_Shutdown_
.extern TS_Terminate_
.extern Z_AvailHeap_
.extern _CONTROL_ButtonState1
.extern _CONTROL_ButtonState2
.extern _CONTROL_JoystickEnabled
.extern _ControllerType
.extern _FXDevice
.extern _KB_KeyDown
.extern _MusicDevice
.extern _MusicToggle
.extern _ScreenHeight
.extern _ScreenMode
.extern _ScreenWidth
.extern _Sound
.extern _SoundToggle
.extern _VoiceToggle
.globl __argc # actual unreferenced Watcom startup dependency, not a definition
.extern __argc
.extern _actorscrptr
.extern _avgavel
.extern _avgbits
.extern _avgfvel
.extern _avghorz
.extern _avgsvel
.extern _buf
.extern _bufferjitter
.extern _cacleng
.extern _cacnum
.extern _camerashitable
.extern _camsprite
.extern _cheatbuf
.extern _cheatbuflen
.extern _connecthead
.extern _connectpoint2
.globl _cstart_ # actual unreferenced Watcom startup dependency, not a definition
.extern _cstart_
.extern _current_menu
.extern _designertime
.extern _display_mirror
.extern _dukefriction
.extern _earthquaketime
.extern _env_music_fn
.extern _everyothertime
.extern _fakemovefifoplc
.extern _frags
.extern _fta_quotes
.extern _global_random
.extern _gotpic
.extern _groupfile
.extern _headspritestat
.extern _hittype
.extern _impact_damage
.extern _inputfifo
.extern _label
.extern _labelcode
.extern _lastsavedpos
.extern _lastvisinc
.extern _level_names
.extern _loadfromgrouponly
.extern _loc
.extern _lockclock
.extern _lockptr
.extern _lumplockbyte
.extern _max_ammo_amount
.extern _max_player_health
.extern _mirrorcnt
.extern _mirrorsector
.extern _mirrorwall
.extern _movefifoend
.extern _movefifoplc
.extern _movefifosendplc
.extern _movesperpacket
.extern _msx
.extern _msy
.extern _music_fn
.extern _music_select
.extern _myang
.extern _myangbak
.extern _myconnectindex
.extern _mycursectnum
.extern _myhardlanding
.extern _myhoriz
.extern _myhorizbak
.extern _myhorizoff
.extern _myjumpingcounter
.extern _myjumpingtoggle
.extern _mymaxlag
.extern _mymembuf
.extern _myminlag
.extern _myname
.extern _myonground
.extern _myreturntocenter
.extern _myx
.extern _myxbak
.extern _myxvel
.extern _myy
.extern _myybak
.extern _myyvel
.extern _myz
.extern _myzbak
.extern _myzvel
.extern _networkmode
.extern _nextspritestat
.extern _numlumps
.extern _numplayers
.extern _numsectors
.extern _omyang
.extern _omyhoriz
.extern _omyhorizoff
.extern _omyx
.extern _omyy
.extern _omyz
.extern _otherminlag
.extern _ototalclock
.extern _packbuf
.extern _palette
.extern _partime
.extern _picanm
.extern _playerquitflag
.extern _playerreadyflag
.extern _playerswhenstarted
.extern _probey
.extern _ps
.extern _pub
.extern _pus
.extern _randomseed
.extern _ready2send
.extern _received_quote
.extern _received_quote_time
.extern _recsync
.extern _restorepalette
.extern _rtsplaying
.extern _sbar
.extern _screencapt
.extern _screenpeek
.extern _sector
.extern _show2dsector
.extern _show2dsprite
.extern _show2dwall
.extern _show_shareware
.extern _sintable
.extern _sprite
.extern _spritesortcnt
.extern _startdmost
.extern _startumost
.extern _sync
.extern _syncstat
.extern _syncstate
.extern _syncval
.extern _syncvalhead
.extern _syncvaltail
.extern _syncvaltottail
.extern _tempbuf
.extern _tilesizx
.extern _tilesizy
.extern _totalclock
.extern _tsprite
.extern _typebuf
.extern _ud
.extern _visibility
.extern _volume_names
.extern _wait_abort
.extern _wall
.extern _walock
.extern _waloff
.extern _windowx1
.extern _windowx2
.extern _windowy1
.extern _windowy2
.extern _xdim
.extern _ydim
.extern _yxaspect
.extern abs_
.extern addammo_
.extern allocache_
.extern animatecamsprite_
.extern animatewalls_
.extern atol_
.extern ceilingspace_
.extern changespritestat_
.extern cheatkeys_
.extern checksectors_
.extern clearsoundlocks_
.extern clearview_
.extern clipmove_
.extern cmenu_
.extern completemirror_
.extern deletesprite_
.extern dfwrite_
.extern displaymasks_
.extern displayweapon_
.extern doanimations_
.extern dointerpolations_
.extern drawmapview_
.extern drawmasks_
.extern drawoverheadmap_
.extern drawrooms_
.extern enterlevel_
.extern exit_
.extern fclose_
.extern floorspace_
.extern flushperms_
.extern fopen_
.extern fseek_
.extern fwrite_
.extern genericmultifunction_
.extern genspriteremaps_
.extern getangle_
.extern getceilzofslope_
.extern getch_
.extern getflorzofslope_
.extern getglobalz_
.extern getincangle_
.extern getinput_
.extern getoutputcirclesize_
.extern getpacket_
.extern getzrange_
.extern getzsofslope_
.extern hitscan_
.extern initengine_
.extern initgroupfile_
.extern initmultiplayers_
.extern insertsprite_
.extern insertspriteq_
.extern inside_
.extern intomenusounds_
.extern kclose_
.extern kdfread_
.extern kfilelength_
.extern kopen4load_
.extern krand_
.extern kread_
.extern labs_
.extern ldist_
.extern loadefs_
.extern loadpics_
.extern ltoa_
.extern makeitfall_
.extern memcpy_
.extern menus_
.extern menutext_
.extern moveactors_
.extern movecyclers_
.extern movedummyplayers_
.extern moveeffectors_
.extern moveexplosions_
.extern movefallers_
.extern movefta_
.extern movefx_
.extern moveplayers_
.extern movestandables_
.extern movetransports_
.extern moveweapons_
.extern newgame_
.extern nextpage_
.extern nextsectorneighborz_
.extern operateforcefields_
.extern operatesectors_
.extern palto_
.extern pan3dsound_
.extern playanm_
.extern playmusic_
.extern preparemirror_
.extern printext256_
.extern printf_
.extern processinput_
.extern pushmove_
.extern puts_
.extern quickkill_
.extern rand_
.extern readsavenames_
.extern resetinventory_
.extern resetweapons_
.extern restoreinterpolations_
.extern rotatesprite_
.extern savetemp_
.extern screencapture_
.extern sendlogon_
.extern sendpacket_
.extern setaspect_
.extern setbrightness_
.extern setgamemode_
.extern setinterpolation_
.extern setsectinterpolate_
.extern setsprite_
.extern setview_
.extern setviewback_
.extern setviewtotile_
.extern sound_
.extern sprintf_
.extern spritesound_
.extern ssp_
.extern strcat_
.extern strcpy_
.extern strlen_
.extern tolower_
.extern toupper_
.extern uninitengine_
.extern uninitgroupfile_
.extern uninitmultiplayers_
.extern unlink_
.extern updateinterpolations_
.extern updatesector_
.extern vscrn_
.extern waitforeverybody_
.section _TEXT,"ax",@progbits
.p2align 4
game_invennum_dabuf_initializer:
    .zero 80 # genuine local dabuf[80]={0} initializer
game_weaponnum_dabuf_initializer:
    .zero 80 # genuine local dabuf[80]={0} initializer
game_weaponnum999_dabuf_initializer:
    .zero 80 # genuine local dabuf[80]={0} initializer
game_bonus_breathe:
    .long 0, 30, VICTORY1+1, 176, 59
    .long 30, 60, VICTORY1+2, 176, 59
    .long 60, 90, VICTORY1+1, 176, 59
    .long 90, 120, 0, 176, 59
game_bonus_bossmove:
    .long 0, 120, VICTORY1+3, 86, 59
    .long 220, 260, VICTORY1+4, 86, 59
    .long 260, 290, VICTORY1+5, 86, 59
    .long 290, 320, VICTORY1+6, 86, 59
    .long 320, 350, VICTORY1+7, 86, 59
    .long 350, 380, VICTORY1+8, 86, 59
    {disp32} lea eax, dword ptr [eax]
    {load} mov edx, edx
timerhandler_:
    mov eax, dword ptr [_totalclock]
    inc dword ptr [_totalclock]
    ret
    {disp8} lea eax, dword ptr [eax + eiz*1]
inittimer_:
    push ebx
    push ecx
    push edx
    mov ebx, 1
    mov edx, 0x78
    mov eax, OFFSET FLAT:timerhandler_
    {store} xor ecx, ecx
    call TS_ScheduleTask_
    mov dword ptr [_TimerPtr], eax
    call TS_Dispatch_
    pop edx
    pop ecx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp8} lea edx, dword ptr [edx]
uninittimer_:
    push ebx
    push edx
    mov edx, dword ptr [_TimerPtr]
    test edx, edx
    je game_flow_uninittimer_531
    {store} mov eax, edx
    call TS_Terminate_
game_flow_uninittimer_531:
    {store} xor ebx, ebx
    mov dword ptr [_TimerPtr], ebx
    call TS_Shutdown_
    pop edx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
    nop
gametext_:
    push esi
    push edi
    push ebp
    sub esp, 8
    {store} mov ebp, eax
    mov dword ptr [esp], edx
    {store} mov esi, ebx
    mov byte ptr [esp + 4], cl
    .att_syntax prefix
    cmpl $game_math_gametext_577,%eax
    .intel_syntax noprefix
    sete dl
    {store} xor eax, eax
    test dl, dl
    je game_flow_gametext_677
game_flow_gametext_591:
    mov dl, byte ptr [esi]
    test dl, dl
    je game_flow_gametext_665
    cmp dl, 0x20
    jne game_flow_gametext_610
    .att_syntax prefix
    addl $game_math_gametext_602,%eax
    .intel_syntax noprefix
    inc esi
    jmp game_flow_gametext_591
game_flow_gametext_610:
    movzx di, dl
    add edi, 0xae5
    cmp di, 0xb06
    jl game_flow_gametext_665
    cmp di, 0xb63
    jg game_flow_gametext_665
    cmp dl, 0x30
    jb game_flow_gametext_651
    cmp dl, 0x39
    ja game_flow_gametext_651
    .att_syntax prefix
    addl $game_math_gametext_644,%eax
    .intel_syntax noprefix
    jmp game_flow_gametext_662
game_flow_gametext_651:
    movsx edx, di
    add ax, word ptr [edx*2 + _tilesizx]
game_flow_gametext_662:
    inc esi
    jmp game_flow_gametext_591
game_flow_gametext_665:
    cwde
    mov ebp, 0xa0
    sar eax, 1
    {store} mov esi, ebx
    {store} sub ebp, eax
game_flow_gametext_677:
    mov al, byte ptr [esi]
    test al, al
    {disp32} je game_flow_gametext_814
    cmp al, 0x20
    jne game_flow_gametext_697
    add ebp, 5
    inc esi
    jmp game_flow_gametext_677
game_flow_gametext_697:
    movzx di, al
    add edi, 0xae5
    cmp di, 0xb06
    jl game_flow_gametext_814
    cmp di, 0xb63
    jg game_flow_gametext_814
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0x1a
    mov edx, dword ptr [esp + 20]
    {store} xor eax, eax
    push 0
    mov al, byte ptr [esp + 28]
    mov ebx, 0x10000
    push eax
    movsx eax, di
    {store} xor ecx, ecx
    push eax
    {store} mov eax, ebp
    shl edx, 0x10
    shl eax, 0x10
    call rotatesprite_
    mov dl, byte ptr [esi]
    cmp dl, 0x30
    jb game_flow_gametext_795
    cmp dl, 0x39
    ja game_flow_gametext_795
    add ebp, 8
    jmp game_flow_gametext_808
game_flow_gametext_795:
    movsx eax, di
    movsx eax, word ptr [eax*2 + _tilesizx]
    {store} add ebp, eax
game_flow_gametext_808:
    inc esi
    {disp32} jmp game_flow_gametext_677
game_flow_gametext_814:
    {store} mov eax, ebp
    add esp, 8
    pop ebp
    pop edi
    pop esi
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp8} lea edx, dword ptr [edx]
gametextpart_:
    push esi
    push edi
    push ebp
    sub esp, 0x10
    {store} mov edi, eax
    mov dword ptr [esp], edx
    mov byte ptr [esp + 12], cl
    {store} mov eax, ebx
    cmp edi, 0xa0
    sete cl
    {store} xor edx, edx
    {store} xor esi, esi
    test cl, cl
    je game_flow_gametextpart_948
game_flow_gametextpart_866:
    cmp byte ptr [eax], 0
    je game_flow_gametextpart_932
    cmp si, word ptr [esp + 32]
    je game_flow_gametextpart_932
    mov ch, byte ptr [eax]
    lea edi, dword ptr [eax + 1]
    cmp ch, 0x20
    jne game_flow_gametextpart_895
    add edx, 5
    {store} mov eax, edi
    jmp game_flow_gametextpart_866
game_flow_gametextpart_895:
    {store} mov al, ch
    xor ah, ah
    .att_syntax prefix
    addl $game_math_gametextpart_899,%eax
    .intel_syntax noprefix
    .att_syntax prefix
    cmpw $game_math_gametextpart_904,%ax
    .intel_syntax noprefix
    jl game_flow_gametextpart_932
    .att_syntax prefix
    cmpw $game_math_gametextpart_910,%ax
    .intel_syntax noprefix
    jg game_flow_gametextpart_932
    cwde
    inc esi
    mov cx, word ptr [eax*2 + _tilesizx]
    {store} mov eax, edi
    {store} add edx, ecx
    jmp game_flow_gametextpart_866
game_flow_gametextpart_932:
    movsx edi, dx
    mov edx, 0xa0
    sar edi, 1
    {store} sub edx, edi
    {store} mov eax, ebx
    {store} mov edi, edx
game_flow_gametextpart_948:
    {store} xor esi, esi
game_flow_gametextpart_950:
    cmp byte ptr [eax], 0
    {disp32} je game_flow_gametextpart_1139
    lea edx, dword ptr [eax + 1]
    mov dword ptr [esp + 8], edx
    mov dh, byte ptr [eax]
    cmp dh, 0x20
    jne game_flow_gametextpart_982
    mov eax, dword ptr [esp + 8]
    add edi, 5
    jmp game_flow_gametextpart_950
game_flow_gametextpart_982:
    {store} mov al, dh
    xor ah, ah
    .att_syntax prefix
    addl $game_math_gametextpart_986,%eax
    .intel_syntax noprefix
    .att_syntax prefix
    cmpw $game_math_gametextpart_991,%ax
    .intel_syntax noprefix
    {disp32} jl game_flow_gametextpart_1139
    .att_syntax prefix
    cmpw $game_math_gametextpart_1001,%ax
    .intel_syntax noprefix
    {disp32} jg game_flow_gametextpart_1139
    mov edx, dword ptr [esp]
    mov ecx, dword ptr [_xdim]
    mov ebx, dword ptr [_ydim]
    {store} mov ebp, edi
    dec ecx
    dec ebx
    shl ebp, 0x10
    shl edx, 0x10
    cmp si, word ptr [esp + 32]
    jne game_flow_gametextpart_1078
    push ebx
    push ecx
    push 0
    push 0
    push 0x1a
    {store} xor ebx, ebx
    push 1
    mov bl, byte ptr [esp + 36]
    push ebx
    cwde
    {store} xor ecx, ecx
    push eax
    mov ebx, 0x10000
    {store} mov eax, ebp
    call rotatesprite_
    jmp game_flow_gametextpart_1139
game_flow_gametextpart_1078:
    push ebx
    push ecx
    push 0
    push 0
    push 0x1a
    {store} xor ebx, ebx
    push 0
    mov bl, byte ptr [esp + 36]
    cwde
    push ebx
    mov dword ptr [esp + 32], eax
    {store} xor ecx, ecx
    push eax
    mov ebx, 0x10000
    {store} mov eax, ebp
    call rotatesprite_
    mov eax, dword ptr [esp + 4]
    movsx eax, word ptr [eax*2 + _tilesizx]
    inc esi
    {store} add edi, eax
    mov eax, dword ptr [esp + 8]
    {disp32} jmp game_flow_gametextpart_950
game_flow_gametextpart_1139:
    {store} mov eax, edi
    add esp, 0x10
    pop ebp
    pop edi
    pop esi
    ret 4
    {load} mov eax, eax
minitext_:
    push esi
    push edi
    push ebp
    sub esp, 4
    {store} mov esi, eax
    {store} mov ebp, edx
    mov byte ptr [esp], cl
game_flow_minitext_1165:
    cmp byte ptr [ebx], 0
    je game_flow_minitext_1274
    {store} xor eax, eax
    mov al, byte ptr [ebx]
    lea edi, dword ptr [ebx + 1]
    call toupper_
    mov byte ptr [ebx], al
    cmp al, 0x20
    jne game_flow_minitext_1195
    add esi, 5
    {store} mov ebx, edi
    jmp game_flow_minitext_1165
game_flow_minitext_1195:
    {store} xor eax, eax
    mov al, byte ptr [ebx]
    {store} mov edx, eax
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    {store} xor eax, eax
    push 0
    mov al, byte ptr [esp + 36]
    push eax
    {store} xor eax, eax
    mov al, byte ptr [esp + 20]
    push eax
    {store} xor ecx, ecx
    add edx, 0xbdf
    push 0
    movsx eax, dx
    mov ebx, 0x10000
    push eax
    {store} mov edx, ebp
    {store} mov eax, esi
    shl edx, 0x10
    shl eax, 0x10
    call rotatesprite_
    add esi, 4
    {store} mov ebx, edi
    jmp game_flow_minitext_1165
game_flow_minitext_1274:
    {store} mov eax, esi
    add esp, 4
    pop ebp
    pop edi
    pop esi
    ret 4
    {disp32} lea eax, dword ptr [eax]
    {disp8} lea edx, dword ptr [edx]
    {load} mov ebx, ebx
gamenumber_:
    push esi
    push edi
    sub esp, 0xc
    {store} mov esi, eax
    {store} mov edi, edx
    {store} mov eax, ebx
    mov ebx, 0xa
    {store} mov edx, esp
    call ltoa_
    {store} mov ebx, esp
    and ecx, 0xff
    {store} mov edx, edi
    {store} mov eax, esi
    call gametext_
    add esp, 0xc
    pop edi
    pop esi
    ret
    {load} mov eax, eax
allowtimetocorrecterrorswhenquitting_:
    push ebx
    push ecx
    push edx
    push esi
    xor ah, ah
    {store} xor esi, esi
    mov byte ptr [_ready2send], ah
    cmp esi, 8
    jl game_flow_allowtimetocorrecterrorswhenquitting_1368
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_allowtimetocorrecterrorswhenquitting_1368:
    mov ecx, dword ptr [_totalclock]
game_flow_allowtimetocorrecterrorswhenquitting_1374:
    lea eax, dword ptr [ecx + 4]
    cmp eax, dword ptr [_totalclock]
    jle game_flow_allowtimetocorrecterrorswhenquitting_1392
    call getpackets_
    jmp game_flow_allowtimetocorrecterrorswhenquitting_1374
game_flow_allowtimetocorrecterrorswhenquitting_1392:
    cmp byte ptr [_KB_KeyDown + 0x1], 0
    jne game_flow_allowtimetocorrecterrorswhenquitting_1464
    mov dh, 0x7f
    movsx ecx, word ptr [_connecthead]
    mov byte ptr [_packbuf], dh
    jmp game_flow_allowtimetocorrecterrorswhenquitting_1454
game_flow_allowtimetocorrecterrorswhenquitting_1418:
    movsx eax, word ptr [_myconnectindex]
    {store} cmp ecx, eax
    je game_flow_allowtimetocorrecterrorswhenquitting_1446
    mov ebx, 1
    mov edx, OFFSET FLAT:_packbuf
    {store} mov eax, ecx
    call sendpacket_
game_flow_allowtimetocorrecterrorswhenquitting_1446:
    movsx ecx, word ptr [ecx*2 + _connectpoint2]
game_flow_allowtimetocorrecterrorswhenquitting_1454:
    test ecx, ecx
    jge game_flow_allowtimetocorrecterrorswhenquitting_1418
    inc esi
    cmp esi, 8
    jl game_flow_allowtimetocorrecterrorswhenquitting_1368
game_flow_allowtimetocorrecterrorswhenquitting_1464:
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp8} lea eax, dword ptr [eax]
getpackets_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    sub esp, 0x20
    cmp word ptr [_numplayers], 2
    {disp32} jl game_flow_getpackets_5590
game_flow_getpackets_1495:
    mov edx, OFFSET FLAT:_packbuf
    lea eax, dword ptr [esp + 28]
    call getpacket_
    {store} mov ebx, eax
    mov dword ptr [esp + 24], eax
    test ax, ax
    {disp32} jle game_flow_getpackets_5590
    mov al, byte ptr [_packbuf]
    cmp al, 7
    jb game_flow_getpackets_1587
    {disp32} jbe game_flow_getpackets_4064
    cmp al, 0x11
    jb game_flow_getpackets_1569
    {disp32} jbe game_flow_getpackets_4567
    cmp al, 0xfa
    jb game_flow_getpackets_1495
    {disp32} jbe game_flow_getpackets_5517
    cmp al, 0xff
    {disp32} je game_flow_getpackets_5575
    jmp game_flow_getpackets_1495
game_flow_getpackets_1569:
    cmp al, 8
    {disp32} jbe game_flow_getpackets_4216
    cmp al, 0x10
    {disp32} je game_flow_getpackets_4535
    jmp game_flow_getpackets_1495
game_flow_getpackets_1587:
    cmp al, 4
    jb game_flow_getpackets_1610
    {disp32} jbe game_flow_getpackets_3675
    cmp al, 5
    {disp32} jbe game_flow_getpackets_3753
    {disp32} jmp game_flow_getpackets_3992
game_flow_getpackets_1610:
    test al, al
    jbe game_flow_getpackets_1627
    cmp al, 1
    {disp32} je game_flow_getpackets_2824
    {disp32} jmp game_flow_getpackets_1495
game_flow_getpackets_1627:
    movsx eax, word ptr [esp + 28]
    mov bh, byte ptr [eax*4 + _movefifoend]
    mov ebp, 1
    test bh, 0x1f
    jne game_flow_getpackets_1711
    movsx eax, word ptr [_connecthead]
    movsx edx, word ptr [eax*2 + _connectpoint2]
    jmp game_flow_getpackets_1707
game_flow_getpackets_1666:
    cmp byte ptr [edx + _playerquitflag], 0
    je game_flow_getpackets_1699
    movsx eax, word ptr [_myconnectindex]
    {store} cmp edx, eax
    jne game_flow_getpackets_1698
    movsx eax, byte ptr [ebp + _packbuf]
    mov dword ptr [_otherminlag], eax
game_flow_getpackets_1698:
    inc ebp
game_flow_getpackets_1699:
    movsx edx, word ptr [edx*2 + _connectpoint2]
game_flow_getpackets_1707:
    test edx, edx
    jge game_flow_getpackets_1666
game_flow_getpackets_1711:
    movsx ebx, word ptr [_connecthead]
    mov ecx, dword ptr [ebx*4 + _movefifoend]
    dec ecx
    and ecx, 0xff
    {disp32} lea eax, dword ptr [ecx*4]
    mov edx, dword ptr [ebx*4 + _movefifoend]
    {store} add eax, ecx
    mov ecx, OFFSET FLAT:_inputfifo
    shl eax, 5
    and edx, 0xff
    {store} add ecx, eax
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov edx, OFFSET FLAT:_inputfifo
    shl eax, 5
    mov dword ptr [esp + 16], ebp
    {store} add edx, eax
    mov dword ptr [esp + 8], ecx
    mov dword ptr [esp + 20], edx
    {store} mov edx, ebx
    test edx, edx
    jge game_flow_getpackets_1813
    movsx edx, word ptr [_connecthead]
    {disp32} jmp game_flow_getpackets_2496
game_flow_getpackets_1813:
    {store} xor eax, eax
    mov al, byte ptr [edx + _playerquitflag]
    movsx edx, word ptr [edx*2 + _connectpoint2]
    {store} add ebp, eax
    test edx, edx
    jge game_flow_getpackets_1813
    movsx edx, word ptr [_connecthead]
    {disp32} jmp game_flow_getpackets_2496
game_flow_getpackets_1847:
    cmp byte ptr [edx + _playerquitflag], 0
    {disp32} je game_flow_getpackets_2488
    mov ebx, dword ptr [esp + 16]
    {store} xor eax, eax
    mov al, byte ptr [ebx + _packbuf]
    inc ebx
    mov dword ptr [esp + 12], eax
    movsx eax, word ptr [_myconnectindex]
    mov dword ptr [esp + 16], ebx
    {store} cmp edx, eax
    jne game_flow_getpackets_1996
    mov eax, dword ptr [esp + 12]
    and eax, 1
    {disp32} lea ebx, dword ptr [eax*2]
    mov eax, dword ptr [esp + 12]
    and eax, 2
    {store} add ebx, eax
    mov eax, dword ptr [esp + 12]
    and eax, 4
    sar eax, 2
    {store} add ebx, eax
    mov eax, dword ptr [esp + 12]
    and eax, 8
    sar eax, 3
    {store} add ebx, eax
    mov eax, dword ptr [esp + 12]
    and eax, 0x10
    sar eax, 4
    {store} add eax, ebx
    mov ebx, dword ptr [esp + 12]
    and ebx, 0x20
    sar ebx, 5
    {store} add ebx, eax
    mov eax, dword ptr [esp + 12]
    and eax, 0x40
    sar eax, 6
    {store} add ebx, eax
    mov eax, dword ptr [esp + 12]
    and eax, 0x80
    sar eax, 7
    {store} add eax, ebx
    {store} add ebp, eax
    {disp32} jmp game_flow_getpackets_2488
game_flow_getpackets_1996:
    {disp32} lea eax, dword ptr [edx*4]
    mov ebx, dword ptr [esp + 20]
    {store} add eax, edx
    mov esi, dword ptr [esp + 8]
    {store} add eax, eax
    mov ecx, 0xa
    {store} add ebx, eax
    {store} add esi, eax
    {store} mov edi, ebx
    mov dword ptr [esp + 4], ebx
    cmp ecx, 4
    jae game_flow_getpackets_2048
    test cl, 1
    je game_flow_getpackets_2041
    movsb byte ptr es:[edi], byte ptr [esi]
game_flow_getpackets_2041:
    shr ecx, 1
    rep
    movsw word ptr es:[edi], word ptr [esi]
    jmp game_flow_getpackets_2091
game_flow_getpackets_2048:
    test edi, 1
    je game_flow_getpackets_2058
    movsb byte ptr es:[edi], byte ptr [esi]
    dec ecx
game_flow_getpackets_2058:
    test edi, 2
    je game_flow_getpackets_2071
    movsw word ptr es:[edi], word ptr [esi]
    sub ecx, 2
game_flow_getpackets_2071:
    {store} mov ebx, ecx
    shr ecx, 2
    rep movsd dword ptr es:[edi], dword ptr [esi]
    test bl, 2
    je game_flow_getpackets_2085
    movsw word ptr es:[edi], word ptr [esi]
game_flow_getpackets_2085:
    test bl, 1
    je game_flow_getpackets_2091
    movsb byte ptr es:[edi], byte ptr [esi]
game_flow_getpackets_2091:
    test byte ptr [esp + 12], 1
    je game_flow_getpackets_2132
    {store} xor eax, eax
    mov al, byte ptr [ebp + _packbuf + 0x1]
    {store} mov ebx, eax
    {store} xor eax, eax
    shl ebx, 8
    mov al, byte ptr [ebp + _packbuf]
    {store} add eax, ebx
    mov ebx, dword ptr [esp + 4]
    add ebp, 2
    mov word ptr [ebx + 2], ax
game_flow_getpackets_2132:
    test byte ptr [esp + 12], 2
    je game_flow_getpackets_2188
    {store} xor eax, eax
    mov al, byte ptr [ebp + _packbuf + 0x1]
    {store} mov ebx, eax
    {store} xor eax, eax
    mov al, byte ptr [ebp + _packbuf]
    {store} mov ecx, eax
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov esi, dword ptr [esp + 20]
    {store} add eax, eax
    shl ebx, 8
    {store} add eax, esi
    {store} add ecx, ebx
    add ebp, 2
    mov word ptr [eax + 4], cx
game_flow_getpackets_2188:
    test byte ptr [esp + 12], 4
    je game_flow_getpackets_2223
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov ebx, dword ptr [esp + 20]
    {store} add eax, eax
    {store} mov ecx, ebp
    {store} add ebx, eax
    mov al, byte ptr [ecx + _packbuf]
    inc ebp
    mov byte ptr [ebx], al
game_flow_getpackets_2223:
    test byte ptr [esp + 12], 8
    je game_flow_getpackets_2268
    {store} mov ebx, edx
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov edi, dword ptr [esp + 20]
    {store} add eax, eax
    {store} add eax, edi
    {store} xor ebx, edx
    mov ecx, dword ptr [eax + 6]
    mov bl, byte ptr [ebp + _packbuf]
    xor cl, cl
    {store} or ebx, ecx
    inc ebp
    mov dword ptr [eax + 6], ebx
game_flow_getpackets_2268:
    test byte ptr [esp + 12], 0x10
    je game_flow_getpackets_2314
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov ebx, dword ptr [esp + 20]
    {store} add eax, eax
    {store} xor ecx, ecx
    {store} add eax, ebx
    mov cl, byte ptr [ebp + _packbuf]
    mov ebx, dword ptr [eax + 6]
    shl ecx, 8
    xor bh, bh
    {store} or ebx, ecx
    inc ebp
    mov dword ptr [eax + 6], ebx
game_flow_getpackets_2314:
    test byte ptr [esp + 12], 0x20
    je game_flow_getpackets_2364
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov ecx, dword ptr [esp + 20]
    {store} add eax, eax
    {store} add eax, ecx
    {store} xor ecx, ecx
    mov ebx, dword ptr [eax + 6]
    mov cl, byte ptr [ebp + _packbuf]
    and ebx, 0xff00ffff
    shl ecx, 0x10
    {store} or ebx, ecx
    inc ebp
    mov dword ptr [eax + 6], ebx
game_flow_getpackets_2364:
    test byte ptr [esp + 12], 0x40
    je game_flow_getpackets_2414
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov esi, dword ptr [esp + 20]
    {store} add eax, eax
    {store} xor ecx, ecx
    {store} add eax, esi
    mov cl, byte ptr [ebp + _packbuf]
    mov ebx, dword ptr [eax + 6]
    shl ecx, 0x18
    and ebx, 0xffffff
    {store} or ebx, ecx
    inc ebp
    mov dword ptr [eax + 6], ebx
game_flow_getpackets_2414:
    test byte ptr [esp + 12], 0x80
    je game_flow_getpackets_2450
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov ebx, dword ptr [esp + 20]
    {store} add eax, eax
    {store} mov ecx, ebp
    {store} add ebx, eax
    mov al, byte ptr [ecx + _packbuf]
    inc ebp
    mov byte ptr [ebx + 1], al
game_flow_getpackets_2450:
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov edi, dword ptr [esp + 20]
    {store} add eax, eax
    {store} add eax, edi
    test byte ptr [eax + 9], 4
    je game_flow_getpackets_2481
    xor ch, ch
    mov byte ptr [edx + _playerquitflag], ch
game_flow_getpackets_2481:
    inc dword ptr [edx*4 + _movefifoend]
game_flow_getpackets_2488:
    movsx edx, word ptr [edx*2 + _connectpoint2]
game_flow_getpackets_2496:
    test edx, edx
    {disp32} jge game_flow_getpackets_1847
game_flow_getpackets_2504:
    movsx eax, word ptr [esp + 24]
    {store} cmp ebp, eax
    je game_flow_getpackets_2587
    movsx edx, word ptr [_connecthead]
    movsx eax, word ptr [_myconnectindex]
    jmp game_flow_getpackets_2580
game_flow_getpackets_2529:
    {store} cmp edx, eax
    je game_flow_getpackets_2572
    mov esi, dword ptr [edx*4 + _syncvalhead]
    {store} mov ebx, edx
    and esi, 0xff
    shl ebx, 8
    {store} add esi, ebx
    mov bl, byte ptr [ebp + _packbuf]
    mov byte ptr [esi + _syncval], bl
    inc dword ptr [edx*4 + _syncvalhead]
game_flow_getpackets_2572:
    movsx edx, word ptr [edx*2 + _connectpoint2]
game_flow_getpackets_2580:
    test edx, edx
    jge game_flow_getpackets_2529
    inc ebp
    jmp game_flow_getpackets_2504
game_flow_getpackets_2587:
    movsx edx, word ptr [_connecthead]
    {disp32} jmp game_flow_getpackets_2790
game_flow_getpackets_2599:
    movsx eax, word ptr [_myconnectindex]
    {store} cmp edx, eax
    {disp32} je game_flow_getpackets_2782
    mov ebp, 1
    {disp32} jmp game_flow_getpackets_2767
game_flow_getpackets_2624:
    {disp32} lea eax, dword ptr [edx*4]
    mov ebx, dword ptr [eax + _movefifoend]
    and ebx, 0xff
    mov dword ptr [esp], eax
    {disp32} lea eax, dword ptr [ebx*4]
    {store} add eax, ebx
    mov edi, OFFSET FLAT:_inputfifo
    shl eax, 5
    {store} add edi, eax
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov esi, dword ptr [esp + 20]
    {store} add eax, eax
    mov ecx, 0xa
    {store} add edi, eax
    {store} add esi, eax
    cmp ecx, 4
    jae game_flow_getpackets_2707
    test cl, 1
    je game_flow_getpackets_2700
    movsb byte ptr es:[edi], byte ptr [esi]
game_flow_getpackets_2700:
    shr ecx, 1
    rep
    movsw word ptr es:[edi], word ptr [esi]
    jmp game_flow_getpackets_2750
game_flow_getpackets_2707:
    test edi, 1
    je game_flow_getpackets_2717
    movsb byte ptr es:[edi], byte ptr [esi]
    dec ecx
game_flow_getpackets_2717:
    test edi, 2
    je game_flow_getpackets_2730
    movsw word ptr es:[edi], word ptr [esi]
    sub ecx, 2
game_flow_getpackets_2730:
    {store} mov ebx, ecx
    shr ecx, 2
    rep movsd dword ptr es:[edi], dword ptr [esi]
    test bl, 2
    je game_flow_getpackets_2744
    movsw word ptr es:[edi], word ptr [esi]
game_flow_getpackets_2744:
    test bl, 1
    je game_flow_getpackets_2750
    movsb byte ptr es:[edi], byte ptr [esi]
game_flow_getpackets_2750:
    mov eax, dword ptr [esp]
    mov esi, dword ptr [eax + _movefifoend]
    inc esi
    inc ebp
    mov dword ptr [eax + _movefifoend], esi
game_flow_getpackets_2767:
    {store} xor eax, eax
    mov al, byte ptr [_movesperpacket]
    {store} cmp ebp, eax
    {disp32} jl game_flow_getpackets_2624
game_flow_getpackets_2782:
    movsx edx, word ptr [edx*2 + _connectpoint2]
game_flow_getpackets_2790:
    test edx, edx
    {disp32} jge game_flow_getpackets_2599
    {store} xor eax, eax
    mov ecx, dword ptr [_movefifosendplc]
    mov al, byte ptr [_movesperpacket]
    {store} add ecx, eax
    mov dword ptr [_movefifosendplc], ecx
    {disp32} jmp game_flow_getpackets_1495
game_flow_getpackets_2824:
    movsx ecx, word ptr [esp + 28]
    mov edx, dword ptr [ecx*4 + _movefifoend]
    {store} xor eax, eax
    dec edx
    mov al, byte ptr [_packbuf + 0x1]
    and edx, 0xff
    mov dword ptr [esp + 16], eax
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov edx, OFFSET FLAT:_inputfifo
    shl eax, 5
    {store} add edx, eax
    mov dword ptr [esp + 8], edx
    mov edx, dword ptr [ecx*4 + _movefifoend]
    and edx, 0xff
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov edx, OFFSET FLAT:_inputfifo
    shl eax, 5
    {store} add edx, eax
    {disp32} lea eax, dword ptr [ecx*4]
    mov esi, dword ptr [esp + 8]
    {store} add eax, ecx
    mov dword ptr [esp + 20], edx
    {store} add eax, eax
    mov ecx, 0xa
    lea edi, dword ptr [edx + eax]
    {store} add esi, eax
    cmp ecx, 4
    jae game_flow_getpackets_2956
    test cl, 1
    je game_flow_getpackets_2949
    movsb byte ptr es:[edi], byte ptr [esi]
game_flow_getpackets_2949:
    shr ecx, 1
    rep
    movsw word ptr es:[edi], word ptr [esi]
    jmp game_flow_getpackets_2999
game_flow_getpackets_2956:
    test edi, 1
    je game_flow_getpackets_2966
    movsb byte ptr es:[edi], byte ptr [esi]
    dec ecx
game_flow_getpackets_2966:
    test edi, 2
    je game_flow_getpackets_2979
    movsw word ptr es:[edi], word ptr [esi]
    sub ecx, 2
game_flow_getpackets_2979:
    {store} mov ebx, ecx
    shr ecx, 2
    rep movsd dword ptr es:[edi], dword ptr [esi]
    test bl, 2
    je game_flow_getpackets_2993
    movsw word ptr es:[edi], word ptr [esi]
game_flow_getpackets_2993:
    test bl, 1
    je game_flow_getpackets_2999
    movsb byte ptr es:[edi], byte ptr [esi]
game_flow_getpackets_2999:
    mov bh, byte ptr [esp + 16]
    mov ebp, 2
    test bh, 1
    je game_flow_getpackets_3064
    {store} xor ebx, ebx
    {store} xor eax, eax
    mov bl, byte ptr [_packbuf + 0x3]
    mov al, byte ptr [_packbuf + 0x2]
    shl ebx, 8
    movsx edx, word ptr [esp + 28]
    {store} add ebx, eax
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov ecx, dword ptr [esp + 20]
    {store} add eax, eax
    {store} add eax, ecx
    mov ebp, 4
    mov word ptr [eax + 2], bx
game_flow_getpackets_3064:
    test byte ptr [esp + 16], 2
    je game_flow_getpackets_3121
    {store} xor eax, eax
    {store} xor ebx, ebx
    mov al, byte ptr [ebp + _packbuf + 0x1]
    mov bl, byte ptr [ebp + _packbuf]
    shl eax, 8
    movsx edx, word ptr [esp + 28]
    {store} add ebx, eax
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov esi, dword ptr [esp + 20]
    {store} add eax, eax
    {store} add eax, esi
    add ebp, 2
    mov word ptr [eax + 4], bx
game_flow_getpackets_3121:
    test byte ptr [esp + 16], 4
    je game_flow_getpackets_3161
    movsx edx, word ptr [esp + 28]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov edx, dword ptr [esp + 20]
    {store} add eax, eax
    {store} mov ebx, ebp
    {store} add edx, eax
    mov al, byte ptr [ebx + _packbuf]
    inc ebp
    mov byte ptr [edx], al
game_flow_getpackets_3161:
    test byte ptr [esp + 16], 8
    je game_flow_getpackets_3209
    movsx edx, word ptr [esp + 28]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov edi, dword ptr [esp + 20]
    {store} add eax, eax
    {store} add eax, edi
    {store} xor edx, edx
    mov ebx, dword ptr [eax + 6]
    mov dl, byte ptr [ebp + _packbuf]
    xor bl, bl
    {store} or edx, ebx
    inc ebp
    mov dword ptr [eax + 6], edx
game_flow_getpackets_3209:
    test byte ptr [esp + 16], 0x10
    je game_flow_getpackets_3260
    movsx edx, word ptr [esp + 28]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov edx, dword ptr [esp + 20]
    {store} add eax, eax
    {store} add eax, edx
    {store} xor edx, edx
    mov ebx, dword ptr [eax + 6]
    mov dl, byte ptr [ebp + _packbuf]
    xor bh, bh
    shl edx, 8
    {store} or edx, ebx
    inc ebp
    mov dword ptr [eax + 6], edx
game_flow_getpackets_3260:
    test byte ptr [esp + 16], 0x20
    je game_flow_getpackets_3315
    movsx edx, word ptr [esp + 28]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov ebx, dword ptr [esp + 20]
    {store} add eax, eax
    {store} xor edx, edx
    {store} add eax, ebx
    mov dl, byte ptr [ebp + _packbuf]
    mov ebx, dword ptr [eax + 6]
    shl edx, 0x10
    and ebx, 0xff00ffff
    {store} or edx, ebx
    inc ebp
    mov dword ptr [eax + 6], edx
game_flow_getpackets_3315:
    test byte ptr [esp + 16], 0x40
    je game_flow_getpackets_3370
    movsx edx, word ptr [esp + 28]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov ecx, dword ptr [esp + 20]
    {store} add eax, eax
    {store} xor edx, edx
    {store} add eax, ecx
    mov dl, byte ptr [ebp + _packbuf]
    mov ebx, dword ptr [eax + 6]
    shl edx, 0x18
    and ebx, 0xffffff
    {store} or edx, ebx
    inc ebp
    mov dword ptr [eax + 6], edx
game_flow_getpackets_3370:
    test byte ptr [esp + 16], 0x80
    je game_flow_getpackets_3411
    movsx edx, word ptr [esp + 28]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov edx, dword ptr [esp + 20]
    {store} add eax, eax
    {store} mov ebx, ebp
    {store} add edx, eax
    mov al, byte ptr [ebx + _packbuf]
    inc ebp
    mov byte ptr [edx + 1], al
game_flow_getpackets_3411:
    movsx eax, word ptr [esp + 28]
    inc dword ptr [eax*4 + _movefifoend]
game_flow_getpackets_3423:
    movsx eax, word ptr [esp + 24]
    {store} cmp ebp, eax
    je game_flow_getpackets_3491
    movsx edx, word ptr [esp + 28]
    {store} mov ebx, ebp
    {disp32} lea eax, dword ptr [edx*4]
    inc ebp
    shl edx, 8
    mov esi, dword ptr [eax + _syncvalhead]
    mov edi, dword ptr [eax + _syncvalhead]
    and esi, 0xff
    inc edi
    {store} add esi, edx
    mov dl, byte ptr [ebx + _packbuf]
    mov dword ptr [eax + _syncvalhead], edi
    mov byte ptr [esi + _syncval], dl
    jmp game_flow_getpackets_3423
game_flow_getpackets_3491:
    mov edx, 1
    {store} xor eax, eax
    mov al, byte ptr [_movesperpacket]
    {store} cmp edx, eax
    jl game_flow_getpackets_3512
    {disp32} jmp game_flow_getpackets_1495
game_flow_getpackets_3512:
    movsx ebx, word ptr [esp + 28]
    mov esi, dword ptr [ebx*4 + _movefifoend]
    and esi, 0xff
    {disp32} lea eax, dword ptr [esi*4]
    {store} add eax, esi
    mov edi, OFFSET FLAT:_inputfifo
    shl eax, 5
    {store} add edi, eax
    {disp32} lea eax, dword ptr [ebx*4]
    {store} add eax, ebx
    mov ecx, 0xa
    {store} add eax, eax
    mov esi, dword ptr [esp + 20]
    {store} add edi, eax
    {store} add esi, eax
    cmp ecx, 4
    jae game_flow_getpackets_3591
    test cl, 1
    je game_flow_getpackets_3584
    movsb byte ptr es:[edi], byte ptr [esi]
game_flow_getpackets_3584:
    shr ecx, 1
    rep
    movsw word ptr es:[edi], word ptr [esi]
    jmp game_flow_getpackets_3634
game_flow_getpackets_3591:
    test edi, 1
    je game_flow_getpackets_3601
    movsb byte ptr es:[edi], byte ptr [esi]
    dec ecx
game_flow_getpackets_3601:
    test edi, 2
    je game_flow_getpackets_3614
    movsw word ptr es:[edi], word ptr [esi]
    sub ecx, 2
game_flow_getpackets_3614:
    {store} mov ebx, ecx
    shr ecx, 2
    rep movsd dword ptr es:[edi], dword ptr [esi]
    test bl, 2
    je game_flow_getpackets_3628
    movsw word ptr es:[edi], word ptr [esi]
game_flow_getpackets_3628:
    test bl, 1
    je game_flow_getpackets_3634
    movsb byte ptr es:[edi], byte ptr [esi]
game_flow_getpackets_3634:
    movsx eax, word ptr [esp + 28]
    mov ebp, dword ptr [eax*4 + _movefifoend]
    inc ebp
    inc edx
    mov dword ptr [eax*4 + _movefifoend], ebp
    {store} xor eax, eax
    mov al, byte ptr [_movesperpacket]
    {store} cmp edx, eax
    {disp32} jl game_flow_getpackets_3512
    {disp32} jmp game_flow_getpackets_1495
game_flow_getpackets_3675:
    mov edx, OFFSET FLAT:_packbuf + 0x1
    mov eax, OFFSET FLAT:_recbuf
    mov esi, 0xa0
    call strcpy_
    movsx eax, bx
    mov word ptr [_received_quote_time], si
    xor dl, dl
    mov ebx, OFFSET FLAT:_recbuf
    mov byte ptr [eax + _recbuf + 0xffffffff], dl
    mov eax, 0xf3
    mov dh, 1
    mov dword ptr [_received_quote], ebx
    call sound_
    mov byte ptr [_pus], dh
    mov byte ptr [_pub], dh
    {disp32} jmp game_flow_getpackets_1495
game_flow_getpackets_3753:
    {store} xor eax, eax
    mov al, byte ptr [_packbuf + 0x1]
    mov dword ptr [_ud + 0x62e], eax
    mov dword ptr [_ud + 0x622], eax
    {store} xor eax, eax
    mov al, byte ptr [_packbuf + 0x2]
    mov dword ptr [_ud + 0x632], eax
    mov dword ptr [_ud + 0x626], eax
    {store} xor eax, eax
    mov al, byte ptr [_packbuf + 0x3]
    mov dword ptr [_ud + 0x62a], eax
    mov dword ptr [_ud + 0x61e], eax
    {store} xor eax, eax
    mov al, byte ptr [_packbuf + 0x4]
    mov dword ptr [_ud + 0x5fe], eax
    mov dword ptr [_ud + 0x616], eax
    {store} xor eax, eax
    mov al, byte ptr [_packbuf + 0x5]
    mov dword ptr [_ud + 0x5ee], eax
    mov dword ptr [_ud + 0x60a], eax
    {store} xor eax, eax
    mov al, byte ptr [_packbuf + 0x6]
    mov dword ptr [_ud + 0x5f2], eax
    mov dword ptr [_ud + 0x606], eax
    {store} xor eax, eax
    mov al, byte ptr [_packbuf + 0x7]
    mov dword ptr [_ud + 0x5f6], eax
    mov dword ptr [_ud + 0x60e], eax
    {store} xor eax, eax
    mov al, byte ptr [_packbuf + 0x8]
    mov dword ptr [_ud + 0x5da], eax
    {store} xor eax, eax
    mov al, byte ptr [_packbuf + 0x9]
    movsx edx, word ptr [_connecthead]
    mov dword ptr [_ud + 0x63a], eax
    mov dword ptr [_ud + 0x636], eax
    jmp game_flow_getpackets_3935
game_flow_getpackets_3910:
    movsx ebx, dx
    {store} mov eax, ebx
    call resetweapons_
    {store} mov eax, ebx
    call resetinventory_
    movsx edx, word ptr [edx*2 + _connectpoint2]
game_flow_getpackets_3935:
    test edx, edx
    jge game_flow_getpackets_3910
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    mov bl, byte ptr [_ud + 0x62a]
    mov dl, byte ptr [_ud + 0x62e]
    mov al, byte ptr [_ud + 0x632]
    call newgame_
    mov eax, dword ptr [_ud + 0x5da]
    mov dword ptr [_ud + 0x5de], eax
    mov eax, 4
    call enterlevel_
    {disp32} jmp game_flow_getpackets_1495
game_flow_getpackets_3992:
    cmp byte ptr [_packbuf + 0x1], 0x67
    je game_flow_getpackets_4011
    mov eax, OFFSET FLAT:game_text_getpackets_0
    call gameexit_
game_flow_getpackets_4011:
    mov edx, 2
    jmp game_flow_getpackets_4034
game_flow_getpackets_4018:
    movsx eax, word ptr [esp + 28]
    inc edx
    shl eax, 5
    mov byte ptr [edx + eax + _ud + 0x6], cl
game_flow_getpackets_4034:
    mov cl, byte ptr [edx + _packbuf]
    test cl, cl
    jne game_flow_getpackets_4018
    movsx eax, word ptr [esp + 28]
    shl eax, 5
    mov byte ptr [edx + eax + _ud + 0x7], cl
    {disp32} jmp game_flow_getpackets_1495
game_flow_getpackets_4064:
    cmp dword ptr [_ud + 0x5e6], 1
    {disp32} je game_flow_getpackets_1495
    call RTS_NumSounds_
    test eax, eax
    jle game_flow_getpackets_4099
    cmp dword ptr [_SoundToggle], 0
    {disp32} je game_flow_getpackets_1495
game_flow_getpackets_4099:
    cmp dword ptr [_ud + 0x5e6], 1
    {disp32} je game_flow_getpackets_1495
    cmp dword ptr [_FXDevice], 0xd
    {disp32} je game_flow_getpackets_1495
    {store} xor eax, eax
    mov al, byte ptr [_packbuf + 0x1]
    dec eax
    call RTS_GetSound_
    mov dword ptr [_rtsptr], eax
    cmp byte ptr [eax], 0x43
    jne game_flow_getpackets_4177
    {store} xor edx, edx
    mov dl, byte ptr [_packbuf + 0x1]
    neg edx
    push edx
    {store} xor ecx, ecx
    push 0xff
    {store} xor ebx, ebx
    {store} xor edx, edx
    call FX_PlayVOC3D_
    jmp game_flow_getpackets_4204
game_flow_getpackets_4177:
    {store} xor edx, edx
    mov dl, byte ptr [_packbuf + 0x1]
    neg edx
    push edx
    {store} xor ecx, ecx
    push 0xff
    {store} xor ebx, ebx
    {store} xor edx, edx
    call FX_PlayWAV3D_
game_flow_getpackets_4204:
    mov byte ptr [_rtsplaying], 7
    {disp32} jmp game_flow_getpackets_1495
game_flow_getpackets_4216:
    {store} xor eax, eax
    mov al, byte ptr [_packbuf + 0x1]
    mov dword ptr [_ud + 0x62e], eax
    mov dword ptr [_ud + 0x622], eax
    {store} xor eax, eax
    mov al, byte ptr [_packbuf + 0x2]
    mov dword ptr [_ud + 0x632], eax
    mov dword ptr [_ud + 0x626], eax
    {store} xor eax, eax
    mov al, byte ptr [_packbuf + 0x3]
    mov dword ptr [_ud + 0x62a], eax
    mov dword ptr [_ud + 0x61e], eax
    {store} xor eax, eax
    mov al, byte ptr [_packbuf + 0x4]
    mov dword ptr [_ud + 0x5fe], eax
    mov dword ptr [_ud + 0x616], eax
    {store} xor eax, eax
    mov al, byte ptr [_packbuf + 0x5]
    mov dword ptr [_ud + 0x5ee], eax
    mov dword ptr [_ud + 0x60a], eax
    {store} xor eax, eax
    mov al, byte ptr [_packbuf + 0x6]
    mov dword ptr [_ud + 0x5f2], eax
    mov dword ptr [_ud + 0x606], eax
    {store} xor eax, eax
    mov al, byte ptr [_packbuf + 0x7]
    mov dword ptr [_ud + 0x5f6], eax
    mov dword ptr [_ud + 0x60e], eax
    {store} xor eax, eax
    mov edi, OFFSET FLAT:_boardfilename
    mov al, byte ptr [_packbuf + 0x8]
    mov esi, OFFSET FLAT:_packbuf + 0xa
    mov dword ptr [_ud + 0x5de], eax
    mov dword ptr [_ud + 0x5da], eax
    {store} xor eax, eax
    movsx edx, bx
    mov al, byte ptr [_packbuf + 0x9]
    lea ecx, dword ptr [edx + -10]
    mov dword ptr [_ud + 0x63a], eax
    mov dword ptr [_ud + 0x636], eax
    cmp ecx, 4
    jae game_flow_getpackets_4403
    test cl, 1
    je game_flow_getpackets_4396
    movsb byte ptr es:[edi], byte ptr [esi]
game_flow_getpackets_4396:
    shr ecx, 1
    rep
    movsw word ptr es:[edi], word ptr [esi]
    jmp game_flow_getpackets_4446
game_flow_getpackets_4403:
    test edi, 1
    je game_flow_getpackets_4413
    movsb byte ptr es:[edi], byte ptr [esi]
    dec ecx
game_flow_getpackets_4413:
    test edi, 2
    je game_flow_getpackets_4426
    movsw word ptr es:[edi], word ptr [esi]
    sub ecx, 2
game_flow_getpackets_4426:
    {store} mov ebx, ecx
    shr ecx, 2
    rep movsd dword ptr es:[edi], dword ptr [esi]
    test bl, 2
    je game_flow_getpackets_4440
    movsw word ptr es:[edi], word ptr [esi]
game_flow_getpackets_4440:
    test bl, 1
    je game_flow_getpackets_4446
    movsb byte ptr es:[edi], byte ptr [esi]
game_flow_getpackets_4446:
    xor bl, bl
    mov byte ptr [edx + _boardfilename + 0xfffffff6], bl
    movsx edx, word ptr [_connecthead]
    jmp game_flow_getpackets_4488
game_flow_getpackets_4463:
    movsx ebx, dx
    {store} mov eax, ebx
    call resetweapons_
    {store} mov eax, ebx
    call resetinventory_
    movsx edx, word ptr [edx*2 + _connectpoint2]
game_flow_getpackets_4488:
    test edx, edx
    jge game_flow_getpackets_4463
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    mov bl, byte ptr [_ud + 0x62a]
    mov dl, byte ptr [_ud + 0x62e]
    mov al, byte ptr [_ud + 0x632]
    call newgame_
    mov eax, 4
    call enterlevel_
    {disp32} jmp game_flow_getpackets_1495
game_flow_getpackets_4535:
    {store} xor edx, edx
    movsx eax, word ptr [esp + 28]
    mov dword ptr [_fakemovefifoplc], edx
    mov dword ptr [_movefifosendplc], edx
    mov dword ptr [_movefifoplc], edx
    mov dword ptr [eax*4 + _movefifoend], edx
game_flow_getpackets_4567:
    movsx eax, word ptr [esp + 28]
    mov dl, byte ptr [eax*4 + _movefifoend]
    mov ebp, 1
    test dl, 0x1f
    jne game_flow_getpackets_4654
    mov eax, dword ptr [esp + 28]
    mov cx, word ptr [_connecthead]
    {store} cmp ax, cx
    jne game_flow_getpackets_4654
    movsx eax, cx
    movsx edx, word ptr [eax*2 + _connectpoint2]
    jmp game_flow_getpackets_4650
game_flow_getpackets_4618:
    movsx eax, word ptr [_myconnectindex]
    {store} cmp edx, eax
    jne game_flow_getpackets_4641
    movsx eax, byte ptr [ebp + _packbuf]
    mov dword ptr [_otherminlag], eax
game_flow_getpackets_4641:
    inc ebp
    movsx edx, word ptr [edx*2 + _connectpoint2]
game_flow_getpackets_4650:
    test edx, edx
    jge game_flow_getpackets_4618
game_flow_getpackets_4654:
    movsx ecx, word ptr [esp + 28]
    mov ebx, dword ptr [ecx*4 + _movefifoend]
    dec ebx
    and ebx, 0xff
    {disp32} lea eax, dword ptr [ebx*4]
    mov edx, dword ptr [ecx*4 + _movefifoend]
    {store} add eax, ebx
    mov ebx, OFFSET FLAT:_inputfifo
    shl eax, 5
    and edx, 0xff
    {store} add ebx, eax
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov edx, OFFSET FLAT:_inputfifo
    shl eax, 5
    {store} add edx, eax
    {disp32} lea eax, dword ptr [ecx*4]
    mov dword ptr [esp + 8], ebx
    {store} add eax, ecx
    mov dword ptr [esp + 20], edx
    {store} add eax, eax
    mov ecx, 0xa
    lea edi, dword ptr [edx + eax]
    lea esi, dword ptr [ebx + eax]
    cmp ecx, 4
    jae game_flow_getpackets_4772
    test cl, 1
    je game_flow_getpackets_4765
    movsb byte ptr es:[edi], byte ptr [esi]
game_flow_getpackets_4765:
    shr ecx, 1
    rep
    movsw word ptr es:[edi], word ptr [esi]
    jmp game_flow_getpackets_4815
game_flow_getpackets_4772:
    test edi, 1
    je game_flow_getpackets_4782
    movsb byte ptr es:[edi], byte ptr [esi]
    dec ecx
game_flow_getpackets_4782:
    test edi, 2
    je game_flow_getpackets_4795
    movsw word ptr es:[edi], word ptr [esi]
    sub ecx, 2
game_flow_getpackets_4795:
    {store} mov ebx, ecx
    shr ecx, 2
    rep movsd dword ptr es:[edi], dword ptr [esi]
    test bl, 2
    je game_flow_getpackets_4809
    movsw word ptr es:[edi], word ptr [esi]
game_flow_getpackets_4809:
    test bl, 1
    je game_flow_getpackets_4815
    movsb byte ptr es:[edi], byte ptr [esi]
game_flow_getpackets_4815:
    {store} xor eax, eax
    mov al, byte ptr [ebp + _packbuf]
    mov dword ptr [esp + 16], eax
    mov cl, byte ptr [esp + 16]
    inc ebp
    test cl, 1
    je game_flow_getpackets_4889
    {store} xor eax, eax
    {store} xor edx, edx
    mov al, byte ptr [ebp + _packbuf + 0x1]
    mov dl, byte ptr [ebp + _packbuf]
    shl eax, 8
    {store} mov ebx, edx
    movsx edx, word ptr [esp + 28]
    {store} add ebx, eax
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov edi, dword ptr [esp + 20]
    {store} add eax, eax
    {store} add eax, edi
    add ebp, 2
    mov word ptr [eax + 2], bx
game_flow_getpackets_4889:
    test byte ptr [esp + 16], 2
    je game_flow_getpackets_4948
    {store} xor eax, eax
    {store} xor edx, edx
    mov al, byte ptr [ebp + _packbuf + 0x1]
    mov dl, byte ptr [ebp + _packbuf]
    shl eax, 8
    {store} mov ebx, edx
    movsx edx, word ptr [esp + 28]
    {store} add ebx, eax
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov edx, dword ptr [esp + 20]
    {store} add eax, eax
    {store} add eax, edx
    add ebp, 2
    mov word ptr [eax + 4], bx
game_flow_getpackets_4948:
    test byte ptr [esp + 16], 4
    je game_flow_getpackets_4988
    movsx edx, word ptr [esp + 28]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov edx, dword ptr [esp + 20]
    {store} add eax, eax
    {store} mov ebx, ebp
    {store} add edx, eax
    mov al, byte ptr [ebx + _packbuf]
    inc ebp
    mov byte ptr [edx], al
game_flow_getpackets_4988:
    test byte ptr [esp + 16], 8
    je game_flow_getpackets_5036
    movsx edx, word ptr [esp + 28]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov ebx, dword ptr [esp + 20]
    {store} add eax, eax
    {store} add eax, ebx
    {store} xor edx, edx
    mov ebx, dword ptr [eax + 6]
    mov dl, byte ptr [ebp + _packbuf]
    xor bl, bl
    {store} or edx, ebx
    inc ebp
    mov dword ptr [eax + 6], edx
game_flow_getpackets_5036:
    test byte ptr [esp + 16], 0x10
    je game_flow_getpackets_5087
    movsx edx, word ptr [esp + 28]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov ecx, dword ptr [esp + 20]
    {store} add eax, eax
    {store} xor edx, edx
    {store} add eax, ecx
    mov dl, byte ptr [ebp + _packbuf]
    mov ebx, dword ptr [eax + 6]
    shl edx, 8
    xor bh, bh
    {store} or edx, ebx
    inc ebp
    mov dword ptr [eax + 6], edx
game_flow_getpackets_5087:
    test byte ptr [esp + 16], 0x20
    je game_flow_getpackets_5142
    movsx edx, word ptr [esp + 28]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov esi, dword ptr [esp + 20]
    {store} add eax, eax
    {store} xor edx, edx
    {store} add eax, esi
    mov dl, byte ptr [ebp + _packbuf]
    mov ebx, dword ptr [eax + 6]
    shl edx, 0x10
    and ebx, 0xff00ffff
    {store} or edx, ebx
    inc ebp
    mov dword ptr [eax + 6], edx
game_flow_getpackets_5142:
    test byte ptr [esp + 16], 0x40
    je game_flow_getpackets_5197
    movsx edx, word ptr [esp + 28]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov edi, dword ptr [esp + 20]
    {store} add eax, eax
    {store} xor edx, edx
    {store} add eax, edi
    mov dl, byte ptr [ebp + _packbuf]
    mov ebx, dword ptr [eax + 6]
    shl edx, 0x18
    and ebx, 0xffffff
    {store} or edx, ebx
    inc ebp
    mov dword ptr [eax + 6], edx
game_flow_getpackets_5197:
    test byte ptr [esp + 16], 0x80
    je game_flow_getpackets_5238
    movsx edx, word ptr [esp + 28]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov edx, dword ptr [esp + 20]
    {store} add eax, eax
    {store} mov ebx, ebp
    {store} add edx, eax
    mov al, byte ptr [ebx + _packbuf]
    inc ebp
    mov byte ptr [edx + 1], al
game_flow_getpackets_5238:
    movsx eax, word ptr [esp + 28]
    mov edx, 1
    add dword ptr [eax*4 + _movefifoend], edx
    {disp32} jmp game_flow_getpackets_5403
game_flow_getpackets_5260:
    movsx ebx, word ptr [esp + 28]
    mov esi, dword ptr [ebx*4 + _movefifoend]
    and esi, 0xff
    {disp32} lea eax, dword ptr [esi*4]
    {store} add eax, esi
    mov edi, OFFSET FLAT:_inputfifo
    shl eax, 5
    {store} add edi, eax
    {disp32} lea eax, dword ptr [ebx*4]
    {store} add eax, ebx
    mov ecx, 0xa
    {store} add eax, eax
    mov esi, dword ptr [esp + 20]
    {store} add edi, eax
    {store} add esi, eax
    cmp ecx, 4
    jae game_flow_getpackets_5339
    test cl, 1
    je game_flow_getpackets_5332
    movsb byte ptr es:[edi], byte ptr [esi]
game_flow_getpackets_5332:
    shr ecx, 1
    rep
    movsw word ptr es:[edi], word ptr [esi]
    jmp game_flow_getpackets_5382
game_flow_getpackets_5339:
    test edi, 1
    je game_flow_getpackets_5349
    movsb byte ptr es:[edi], byte ptr [esi]
    dec ecx
game_flow_getpackets_5349:
    test edi, 2
    je game_flow_getpackets_5362
    movsw word ptr es:[edi], word ptr [esi]
    sub ecx, 2
game_flow_getpackets_5362:
    {store} mov ebx, ecx
    shr ecx, 2
    rep movsd dword ptr es:[edi], dword ptr [esi]
    test bl, 2
    je game_flow_getpackets_5376
    movsw word ptr es:[edi], word ptr [esi]
game_flow_getpackets_5376:
    test bl, 1
    je game_flow_getpackets_5382
    movsb byte ptr es:[edi], byte ptr [esi]
game_flow_getpackets_5382:
    movsx eax, word ptr [esp + 28]
    mov ecx, dword ptr [eax*4 + _movefifoend]
    inc ecx
    inc edx
    mov dword ptr [eax*4 + _movefifoend], ecx
game_flow_getpackets_5403:
    {store} xor eax, eax
    mov al, byte ptr [_movesperpacket]
    {store} cmp edx, eax
    {disp32} jl game_flow_getpackets_5260
    movsx eax, word ptr [esp + 24]
    {store} cmp ebp, eax
    jle game_flow_getpackets_5445
    {store} mov edx, ebp
    {store} sub edx, eax
    push edx
    push OFFSET FLAT:game_text_getpackets_48
    call printf_
    add esp, 8
game_flow_getpackets_5445:
    movsx eax, word ptr [esp + 24]
    {store} cmp ebp, eax
    {disp32} je game_flow_getpackets_1495
    movsx edx, word ptr [esp + 28]
    {disp32} lea eax, dword ptr [edx*4]
    mov ebx, dword ptr [eax + _syncvalhead]
    shl edx, 8
    and ebx, 0xff
    {store} mov esi, ebp
    {store} add ebx, edx
    mov dl, byte ptr [esi + _packbuf]
    mov esi, dword ptr [eax + _syncvalhead]
    inc ebp
    inc esi
    mov byte ptr [ebx + _syncval], dl
    mov dword ptr [eax + _syncvalhead], esi
    jmp game_flow_getpackets_5445
game_flow_getpackets_5517:
    movsx eax, word ptr [esp + 28]
    mov dl, byte ptr [_packbuf + 0x1]
    mov bx, word ptr [_connecthead]
    mov byte ptr [eax + _playerreadyflag], dl
    cmp bx, word ptr [esp + 28]
    {disp32} jne game_flow_getpackets_1495
    mov edx, OFFSET FLAT:_packbuf
    movsx eax, bx
    mov ebx, 2
    call sendpacket_
    {disp32} jmp game_flow_getpackets_1495
game_flow_getpackets_5575:
    mov eax, OFFSET FLAT:game_text_getpackets_96
    call gameexit_
    {disp32} jmp game_flow_getpackets_1495
game_flow_getpackets_5590:
    add esp, 0x20
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
faketimerhandler_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    sub esp, 0x24
    mov eax, dword ptr [_ototalclock]
    add eax, 4
    cmp eax, dword ptr [_totalclock]
    {disp32} jg game_flow_faketimerhandler_6030
    cmp byte ptr [_ready2send], 0
    {disp32} je game_flow_faketimerhandler_6030
    mov dword ptr [_ototalclock], eax
    call getpackets_
    call getoutputcirclesize_
    cmp eax, 0x10
    {disp32} jge game_flow_faketimerhandler_6030
    movsx esi, word ptr [_connecthead]
    jmp game_flow_faketimerhandler_5721
game_flow_faketimerhandler_5675:
    movsx eax, word ptr [_myconnectindex]
    {store} cmp esi, eax
    je game_flow_faketimerhandler_5713
    mov eax, dword ptr [eax*4 + _movefifoend]
    mov ebx, dword ptr [esi*4 + _movefifoend]
    sub eax, 0xc8
    {store} cmp eax, ebx
    {disp32} jg game_flow_faketimerhandler_6030
game_flow_faketimerhandler_5713:
    movsx esi, word ptr [esi*2 + _connectpoint2]
game_flow_faketimerhandler_5721:
    test esi, esi
    jge game_flow_faketimerhandler_5675
    movsx eax, word ptr [_myconnectindex]
    call getinput_
    movsx eax, word ptr [_loc + 0x2]
    mov ebx, dword ptr [_avgfvel]
    mov ecx, dword ptr [_avgsvel]
    mov esi, dword ptr [_avgavel]
    mov edi, dword ptr [_avghorz]
    mov ebp, dword ptr [_avgbits]
    {store} add ebx, eax
    movsx eax, word ptr [_loc + 0x4]
    mov dword ptr [_avgfvel], ebx
    {store} add ecx, eax
    movsx eax, byte ptr [_loc]
    mov dword ptr [_avgsvel], ecx
    {store} add esi, eax
    {store} xor ecx, ecx
    movsx eax, byte ptr [_loc + 0x1]
    mov cl, byte ptr [_movesperpacket]
    {store} add edi, eax
    mov eax, dword ptr [_loc + 0x6]
    mov dword ptr [_avgavel], esi
    {store} or ebp, eax
    movsx eax, word ptr [_myconnectindex]
    mov dword ptr [_avghorz], edi
    {disp32} lea edx, dword ptr [eax*4]
    lea edi, dword ptr [ecx + -1]
    {disp32} lea esi, dword ptr [eax*4]
    mov dword ptr [_avgbits], ebp
    {store} add esi, eax
    mov eax, dword ptr [edx + _movefifoend]
    {store} add esi, esi
    test edi, eax
    {disp32} je game_flow_faketimerhandler_6040
    {store} mov ebx, eax
    and ebx, 0xff
    {disp32} lea eax, dword ptr [ebx*4]
    {store} add eax, ebx
    mov edx, dword ptr [edx + _movefifoend]
    shl eax, 5
    dec edx
    add eax, OFFSET FLAT:_inputfifo
    and edx, 0xff
    lea edi, dword ptr [eax + esi]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    shl eax, 5
    add eax, OFFSET FLAT:_inputfifo
    mov ecx, 0xa
    {store} add esi, eax
    cmp ecx, 4
    jae game_flow_faketimerhandler_5973
    test cl, 1
    je game_flow_faketimerhandler_5966
    movsb byte ptr es:[edi], byte ptr [esi]
game_flow_faketimerhandler_5966:
    shr ecx, 1
    rep
    movsw word ptr es:[edi], word ptr [esi]
    jmp game_flow_faketimerhandler_6016
game_flow_faketimerhandler_5973:
    test edi, 1
    je game_flow_faketimerhandler_5983
    movsb byte ptr es:[edi], byte ptr [esi]
    dec ecx
game_flow_faketimerhandler_5983:
    test edi, 2
    je game_flow_faketimerhandler_5996
    movsw word ptr es:[edi], word ptr [esi]
    sub ecx, 2
game_flow_faketimerhandler_5996:
    {store} mov ebx, ecx
    shr ecx, 2
    rep movsd dword ptr es:[edi], dword ptr [esi]
    test bl, 2
    je game_flow_faketimerhandler_6010
    movsw word ptr es:[edi], word ptr [esi]
game_flow_faketimerhandler_6010:
    test bl, 1
    je game_flow_faketimerhandler_6016
    movsb byte ptr es:[edi], byte ptr [esi]
game_flow_faketimerhandler_6016:
    movsx eax, word ptr [_myconnectindex]
    inc dword ptr [eax*4 + _movefifoend]
game_flow_faketimerhandler_6030:
    add esp, 0x24
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_faketimerhandler_6040:
    {store} mov edx, eax
    and edx, 0xff
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    shl eax, 5
    add eax, OFFSET FLAT:_inputfifo
    {store} mov edx, ebx
    lea edi, dword ptr [eax + esi]
    sar edx, 0x1f
    {store} mov eax, ebx
    idiv ecx
    mov word ptr [edi + 2], ax
    mov eax, dword ptr [_avgsvel]
    {store} xor ebx, ebx
    {store} mov edx, eax
    mov bl, byte ptr [_movesperpacket]
    sar edx, 0x1f
    idiv ebx
    mov word ptr [edi + 4], ax
    mov eax, dword ptr [_avgavel]
    {store} xor ebx, ebx
    {store} mov edx, eax
    mov bl, byte ptr [_movesperpacket]
    sar edx, 0x1f
    idiv ebx
    mov byte ptr [edi], al
    mov eax, dword ptr [_avghorz]
    {store} xor ebx, ebx
    {store} mov edx, eax
    mov bl, byte ptr [_movesperpacket]
    sar edx, 0x1f
    idiv ebx
    mov byte ptr [edi + 1], al
    mov eax, dword ptr [_avgbits]
    mov dword ptr [edi + 6], eax
    {store} xor edx, edx
    movsx eax, word ptr [_myconnectindex]
    mov dword ptr [_avgbits], edx
    mov dword ptr [_avghorz], edx
    mov dword ptr [_avgavel], edx
    mov dword ptr [_avgsvel], edx
    mov ebp, dword ptr [eax*4 + _movefifoend]
    mov dword ptr [_avgfvel], edx
    inc ebp
    mov dx, word ptr [_numplayers]
    mov dword ptr [eax*4 + _movefifoend], ebp
    cmp dx, 2
    {disp32} jge game_flow_faketimerhandler_6421
    cmp word ptr [_ud + 0x590], 1
    {disp32} jle game_flow_faketimerhandler_6030
    movsx esi, word ptr [_connecthead]
    test esi, esi
    jge game_flow_faketimerhandler_6264
    add esp, 0x24
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_faketimerhandler_6264:
    movsx eax, word ptr [_myconnectindex]
    {store} cmp esi, eax
    je game_flow_faketimerhandler_6395
    mov ebx, dword ptr [esi*4 + _movefifoend]
    and ebx, 0xff
    {disp32} lea eax, dword ptr [ebx*4]
    {store} add eax, ebx
    mov edi, OFFSET FLAT:_inputfifo
    shl eax, 5
    {store} add edi, eax
    {disp32} lea eax, dword ptr [esi*4]
    {store} add eax, esi
    {store} add eax, eax
    mov ecx, 0xa
    {store} add edi, eax
    {store} xor eax, eax
    cmp ecx, 4
    jae game_flow_faketimerhandler_6345
    test cl, 1
    je game_flow_faketimerhandler_6338
    stosb byte ptr es:[edi], al
game_flow_faketimerhandler_6338:
    shr ecx, 1
    rep
    stosw word ptr es:[edi], ax
    jmp game_flow_faketimerhandler_6388
game_flow_faketimerhandler_6345:
    test edi, 1
    je game_flow_faketimerhandler_6355
    stosb byte ptr es:[edi], al
    dec ecx
game_flow_faketimerhandler_6355:
    test edi, 2
    je game_flow_faketimerhandler_6368
    stosw word ptr es:[edi], ax
    sub ecx, 2
game_flow_faketimerhandler_6368:
    {store} mov ebx, ecx
    shr ecx, 2
    rep stosd dword ptr es:[edi], eax
    test bl, 2
    je game_flow_faketimerhandler_6382
    stosw word ptr es:[edi], ax
game_flow_faketimerhandler_6382:
    test bl, 1
    je game_flow_faketimerhandler_6388
    stosb byte ptr es:[edi], al
game_flow_faketimerhandler_6388:
    inc dword ptr [esi*4 + _movefifoend]
game_flow_faketimerhandler_6395:
    movsx esi, word ptr [esi*2 + _connectpoint2]
    test esi, esi
    {disp32} jge game_flow_faketimerhandler_6264
    add esp, 0x24
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_faketimerhandler_6421:
    movsx esi, word ptr [_connecthead]
    jmp game_flow_faketimerhandler_6512
game_flow_faketimerhandler_6430:
    movsx eax, word ptr [_myconnectindex]
    {store} cmp esi, eax
    je game_flow_faketimerhandler_6504
    mov eax, dword ptr [eax*4 + _movefifoend]
    {disp32} lea edx, dword ptr [esi*4]
    dec eax
    mov ebp, dword ptr [edx + _movefifoend]
    mov ebx, dword ptr [edx + _myminlag]
    {store} sub eax, ebp
    {store} cmp eax, ebx
    jle game_flow_faketimerhandler_6478
    {store} mov edx, ebx
    jmp game_flow_faketimerhandler_6480
game_flow_faketimerhandler_6478:
    {store} mov edx, eax
game_flow_faketimerhandler_6480:
    mov ecx, dword ptr [_mymaxlag]
    mov dword ptr [esi*4 + _myminlag], edx
    {store} cmp eax, ecx
    jge game_flow_faketimerhandler_6499
    {store} mov eax, ecx
game_flow_faketimerhandler_6499:
    mov dword ptr [_mymaxlag], eax
game_flow_faketimerhandler_6504:
    movsx esi, word ptr [esi*2 + _connectpoint2]
game_flow_faketimerhandler_6512:
    test esi, esi
    jge game_flow_faketimerhandler_6430
    movsx eax, word ptr [_myconnectindex]
    mov eax, dword ptr [eax*4 + _movefifoend]
    dec eax
    test al, 0x1f
    jne game_flow_faketimerhandler_6600
    mov esi, dword ptr [_mymaxlag]
    mov ecx, dword ptr [_bufferjitter]
    {store} xor edi, edi
    {store} sub esi, ecx
    mov dword ptr [_mymaxlag], edi
    test esi, esi
    jle game_flow_faketimerhandler_6578
    lea eax, dword ptr [esi + 3]
    sar eax, 2
    lea edx, dword ptr [ecx + eax]
    mov dword ptr [_bufferjitter], edx
    jmp game_flow_faketimerhandler_6600
game_flow_faketimerhandler_6578:
    jge game_flow_faketimerhandler_6600
    mov eax, 1
    {store} sub eax, esi
    {store} mov ebp, ecx
    sar eax, 2
    {store} sub ebp, eax
    mov dword ptr [_bufferjitter], ebp
game_flow_faketimerhandler_6600:
    cmp byte ptr [_networkmode], 1
    {disp32} jne game_flow_faketimerhandler_7565
    movsx eax, word ptr [_myconnectindex]
    mov bl, 0x11
    mov eax, dword ptr [eax*4 + _movefifoend]
    mov byte ptr [_packbuf], bl
    dec eax
    jne game_flow_faketimerhandler_6645
    mov byte ptr [_packbuf], 0x10
game_flow_faketimerhandler_6645:
    movsx eax, word ptr [_myconnectindex]
    mov ecx, 1
    mov eax, dword ptr [eax*4 + _movefifoend]
    {store} sub eax, ecx
    test al, 0x1f
    {disp32} jne game_flow_faketimerhandler_6962
    mov ax, word ptr [_myconnectindex]
    mov si, word ptr [_connecthead]
    {store} cmp ax, si
    {disp32} je game_flow_faketimerhandler_6809
    movsx eax, si
    mov esi, dword ptr [eax*4 + _myminlag]
    mov eax, dword ptr [_otherminlag]
    {store} sub esi, eax
    {store} mov eax, esi
    test eax, eax
    jns game_flow_faketimerhandler_6721
    neg eax
game_flow_faketimerhandler_6721:
    cmp eax, 8
    jle game_flow_faketimerhandler_6730
    sar esi, 1
    jmp game_flow_faketimerhandler_6759
game_flow_faketimerhandler_6730:
    {store} mov eax, esi
    test eax, eax
    jns game_flow_faketimerhandler_6738
    neg eax
game_flow_faketimerhandler_6738:
    cmp eax, 2
    jle game_flow_faketimerhandler_6757
    {store} mov ebx, esi
    {store} add ebx, ebx
    {store} sbb eax, eax
    {store} cmp eax, ebx
    adc al, 0
    {store} mov esi, eax
    jmp game_flow_faketimerhandler_6759
game_flow_faketimerhandler_6757:
    {store} xor esi, esi
game_flow_faketimerhandler_6759:
    {disp32} lea eax, dword ptr [esi*4]
    sub dword ptr [_totalclock], eax
    movsx eax, word ptr [_connecthead]
    mov edi, dword ptr [_otherminlag]
    mov ebx, dword ptr [eax*4 + _myminlag]
    {store} add edi, esi
    {store} sub ebx, esi
    mov dword ptr [_otherminlag], edi
    mov dword ptr [eax*4 + _myminlag], ebx
game_flow_faketimerhandler_6809:
    mov ax, word ptr [_myconnectindex]
    mov di, word ptr [_connecthead]
    {store} cmp ax, di
    {disp32} jne game_flow_faketimerhandler_6929
    movsx esi, di
    movsx esi, word ptr [esi*2 + _connectpoint2]
    jmp game_flow_faketimerhandler_6925
game_flow_faketimerhandler_6844:
    {disp32} lea eax, dword ptr [esi*4]
    mov ebp, dword ptr [eax + _myminlag]
    cmp ebp, -128
    jle game_flow_faketimerhandler_6866
    {store} mov eax, ebp
    jmp game_flow_faketimerhandler_6871
game_flow_faketimerhandler_6866:
    mov eax, 0xffffff80
game_flow_faketimerhandler_6871:
    cmp eax, 0x7f
    jge game_flow_faketimerhandler_6905
    {disp32} lea eax, dword ptr [esi*4]
    mov edx, dword ptr [eax + _myminlag]
    cmp edx, -128
    jle game_flow_faketimerhandler_6898
    {store} mov eax, edx
    jmp game_flow_faketimerhandler_6910
game_flow_faketimerhandler_6898:
    mov eax, 0xffffff80
    jmp game_flow_faketimerhandler_6910
game_flow_faketimerhandler_6905:
    mov eax, 0x7f
game_flow_faketimerhandler_6910:
    inc ecx
    movsx esi, word ptr [esi*2 + _connectpoint2]
    mov byte ptr [ecx + _packbuf + 0xffffffff], al
game_flow_faketimerhandler_6925:
    test esi, esi
    jge game_flow_faketimerhandler_6844
game_flow_faketimerhandler_6929:
    mov ebx, 0x7fffffff
    movsx esi, word ptr [_connecthead]
    jmp game_flow_faketimerhandler_6958
game_flow_faketimerhandler_6943:
    mov dword ptr [esi*4 + _myminlag], ebx
    movsx esi, word ptr [esi*2 + _connectpoint2]
game_flow_faketimerhandler_6958:
    test esi, esi
    jge game_flow_faketimerhandler_6943
game_flow_faketimerhandler_6962:
    movsx esi, word ptr [_myconnectindex]
    mov edx, dword ptr [esi*4 + _movefifoend]
    mov ebp, OFFSET FLAT:_inputfifo
    sub edx, 2
    {disp32} lea edi, dword ptr [esi*4]
    and edx, 0xff
    mov ebx, dword ptr [esi*4 + _movefifoend]
    {disp32} lea eax, dword ptr [edx*4]
    dec ebx
    {store} add eax, edx
    {store} add edi, esi
    shl eax, 5
    and ebx, 0xff
    {store} add ebp, eax
    {disp32} lea eax, dword ptr [ebx*4]
    {store} add edi, edi
    {store} add eax, ebx
    lea edx, dword ptr [edi + ebp]
    shl eax, 5
    xor bl, bl
    add eax, OFFSET FLAT:_inputfifo
    mov byte ptr [ecx + _packbuf], bl
    {store} add edi, eax
    mov si, word ptr [edx + 2]
    {store} mov eax, ecx
    mov bx, word ptr [edi + 2]
    inc ecx
    {store} cmp bx, si
    je game_flow_faketimerhandler_7123
    mov bl, byte ptr [edi + 2]
    mov byte ptr [ecx + _packbuf], bl
    movsx ebx, word ptr [edi + 2]
    sar ebx, 8
    mov dword ptr [esp + 32], ebx
    mov bl, byte ptr [esp + 32]
    mov byte ptr [ecx + _packbuf + 0x1], bl
    mov bh, byte ptr [eax + _packbuf]
    add ecx, 2
    or bh, 1
    mov byte ptr [eax + _packbuf], bh
game_flow_faketimerhandler_7123:
    mov bx, word ptr [edi + 4]
    cmp bx, word ptr [edx + 4]
    je game_flow_faketimerhandler_7181
    mov bl, byte ptr [edi + 4]
    mov byte ptr [ecx + _packbuf], bl
    movsx ebx, word ptr [edi + 4]
    sar ebx, 8
    mov dword ptr [esp + 32], ebx
    mov bl, byte ptr [esp + 32]
    mov byte ptr [ecx + _packbuf + 0x1], bl
    mov bl, byte ptr [eax + _packbuf]
    add ecx, 2
    or bl, 2
    mov byte ptr [eax + _packbuf], bl
game_flow_faketimerhandler_7181:
    mov bl, byte ptr [edi]
    cmp bl, byte ptr [edx]
    je game_flow_faketimerhandler_7209
    mov byte ptr [ecx + _packbuf], bl
    mov bl, byte ptr [eax + _packbuf]
    or bl, 4
    inc ecx
    mov byte ptr [eax + _packbuf], bl
game_flow_faketimerhandler_7209:
    mov ebx, dword ptr [edi + 6]
    xor ebx, dword ptr [edx + 6]
    test bl, 0xff
    je game_flow_faketimerhandler_7245
    mov bl, byte ptr [edi + 6]
    mov byte ptr [ecx + _packbuf], bl
    mov bh, byte ptr [eax + _packbuf]
    or bh, 8
    inc ecx
    mov byte ptr [eax + _packbuf], bh
game_flow_faketimerhandler_7245:
    mov ebx, dword ptr [edi + 6]
    xor ebx, dword ptr [edx + 6]
    test bh, 0xff
    je game_flow_faketimerhandler_7298
    mov ebx, dword ptr [edi + 6]
    shr ebx, 8
    and ebx, 0xff
    mov dword ptr [esp + 32], ebx
    mov bl, byte ptr [esp + 32]
    mov byte ptr [ecx + _packbuf], bl
    mov bl, byte ptr [eax + _packbuf]
    or bl, 0x10
    inc ecx
    mov byte ptr [eax + _packbuf], bl
game_flow_faketimerhandler_7298:
    mov ebx, dword ptr [edi + 6]
    xor ebx, dword ptr [edx + 6]
    test ebx, 0xff0000
    je game_flow_faketimerhandler_7354
    mov ebx, dword ptr [edi + 6]
    shr ebx, 0x10
    and ebx, 0xff
    mov dword ptr [esp + 32], ebx
    mov bl, byte ptr [esp + 32]
    mov byte ptr [ecx + _packbuf], bl
    mov bh, byte ptr [eax + _packbuf]
    or bh, 0x20
    inc ecx
    mov byte ptr [eax + _packbuf], bh
game_flow_faketimerhandler_7354:
    mov ebx, dword ptr [edi + 6]
    xor ebx, dword ptr [edx + 6]
    test ebx, 0xff000000
    je game_flow_faketimerhandler_7410
    mov ebx, dword ptr [edi + 6]
    shr ebx, 0x18
    and ebx, 0xff
    mov dword ptr [esp + 32], ebx
    mov bl, byte ptr [esp + 32]
    mov byte ptr [ecx + _packbuf], bl
    mov bl, byte ptr [eax + _packbuf]
    or bl, 0x40
    inc ecx
    mov byte ptr [eax + _packbuf], bl
game_flow_faketimerhandler_7410:
    mov bl, byte ptr [edi + 1]
    cmp bl, byte ptr [edx + 1]
    je game_flow_faketimerhandler_7440
    mov byte ptr [ecx + _packbuf], bl
    mov dl, byte ptr [eax + _packbuf]
    or dl, 0x80
    inc ecx
    mov byte ptr [eax + _packbuf], dl
game_flow_faketimerhandler_7440:
    movsx esi, word ptr [_myconnectindex]
    mov edx, dword ptr [_syncvaltail]
    cmp edx, dword ptr [esi*4 + _syncvalhead]
    je game_flow_faketimerhandler_7497
    {store} mov eax, edx
    shl esi, 8
    and eax, 0xff
    inc ecx
    lea ebx, dword ptr [edx + 1]
    mov al, byte ptr [esi + eax + _syncval]
    mov dword ptr [_syncvaltail], ebx
    mov byte ptr [ecx + _packbuf + 0xffffffff], al
    jmp game_flow_faketimerhandler_7440
game_flow_faketimerhandler_7497:
    movsx esi, word ptr [_connecthead]
    test esi, esi
    jge game_flow_faketimerhandler_7518
    add esp, 0x24
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_faketimerhandler_7518:
    movsx eax, word ptr [_myconnectindex]
    {store} cmp esi, eax
    je game_flow_faketimerhandler_7543
    mov edx, OFFSET FLAT:_packbuf
    {store} mov ebx, ecx
    {store} mov eax, esi
    call sendpacket_
game_flow_faketimerhandler_7543:
    movsx esi, word ptr [esi*2 + _connectpoint2]
    test esi, esi
    jge game_flow_faketimerhandler_7518
    add esp, 0x24
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_faketimerhandler_7565:
    mov ax, word ptr [_myconnectindex]
    mov cx, word ptr [_connecthead]
    {store} cmp ax, cx
    {disp32} je game_flow_faketimerhandler_8258
    cwde
    mov eax, dword ptr [eax*4 + _movefifoend]
    dec eax
    test al, 0x1f
    {disp32} jne game_flow_faketimerhandler_7746
    movsx esi, cx
    mov ebx, dword ptr [_otherminlag]
    mov esi, dword ptr [esi*4 + _myminlag]
    {store} sub esi, ebx
    {store} mov eax, esi
    test eax, eax
    jns game_flow_faketimerhandler_7630
    neg eax
game_flow_faketimerhandler_7630:
    cmp eax, 8
    jle game_flow_faketimerhandler_7639
    sar esi, 1
    jmp game_flow_faketimerhandler_7668
game_flow_faketimerhandler_7639:
    {store} mov eax, esi
    test eax, eax
    jns game_flow_faketimerhandler_7647
    neg eax
game_flow_faketimerhandler_7647:
    cmp eax, 2
    jle game_flow_faketimerhandler_7666
    {store} mov ebx, esi
    {store} add ebx, ebx
    {store} sbb eax, eax
    {store} cmp eax, ebx
    adc al, 0
    {store} mov esi, eax
    jmp game_flow_faketimerhandler_7668
game_flow_faketimerhandler_7666:
    {store} xor esi, esi
game_flow_faketimerhandler_7668:
    {disp32} lea eax, dword ptr [esi*4]
    sub dword ptr [_totalclock], eax
    mov ebp, dword ptr [_otherminlag]
    movsx edx, word ptr [_connecthead]
    {store} add ebp, esi
    mov edi, dword ptr [edx*4 + _myminlag]
    mov dword ptr [_otherminlag], ebp
    {store} sub edi, esi
    mov ebp, 0x7fffffff
    {store} mov esi, edx
    mov dword ptr [edx*4 + _myminlag], edi
    jmp game_flow_faketimerhandler_7742
game_flow_faketimerhandler_7727:
    mov dword ptr [esi*4 + _myminlag], ebp
    movsx esi, word ptr [esi*2 + _connectpoint2]
game_flow_faketimerhandler_7742:
    test esi, esi
    jge game_flow_faketimerhandler_7727
game_flow_faketimerhandler_7746:
    mov ch, 1
    mov ebp, OFFSET FLAT:_inputfifo
    movsx ebx, word ptr [_myconnectindex]
    xor al, al
    mov byte ptr [_packbuf], ch
    mov edx, dword ptr [ebx*4 + _movefifoend]
    mov ecx, 2
    mov byte ptr [_packbuf + 0x1], al
    {store} sub edx, ecx
    {disp32} lea edi, dword ptr [ebx*4]
    and edx, 0xff
    {store} add edi, ebx
    {disp32} lea eax, dword ptr [edx*4]
    mov ebx, dword ptr [ebx*4 + _movefifoend]
    {store} add eax, edx
    dec ebx
    shl eax, 5
    and ebx, 0xff
    {store} add ebp, eax
    {disp32} lea eax, dword ptr [ebx*4]
    {store} add eax, ebx
    shl eax, 5
    {store} add edi, edi
    add eax, OFFSET FLAT:_inputfifo
    lea edx, dword ptr [edi + ebp]
    {store} add edi, eax
    mov bx, word ptr [edx + 2]
    cmp bx, word ptr [edi + 2]
    je game_flow_faketimerhandler_7897
    mov al, byte ptr [edi + 2]
    mov byte ptr [_packbuf + 0x2], al
    movsx eax, word ptr [edi + 2]
    sar eax, 8
    mov byte ptr [_packbuf + 0x3], al
    mov ah, 1
    mov ecx, 4
    mov byte ptr [_packbuf + 0x1], ah
game_flow_faketimerhandler_7897:
    mov ax, word ptr [edi + 4]
    cmp ax, word ptr [edx + 4]
    je game_flow_faketimerhandler_7947
    mov al, byte ptr [edi + 4]
    mov byte ptr [ecx + _packbuf], al
    movsx eax, word ptr [edi + 4]
    sar eax, 8
    mov byte ptr [ecx + _packbuf + 0x1], al
    mov bl, byte ptr [_packbuf + 0x1]
    add ecx, 2
    or bl, 2
    mov byte ptr [_packbuf + 0x1], bl
game_flow_faketimerhandler_7947:
    mov al, byte ptr [edi]
    cmp al, byte ptr [edx]
    je game_flow_faketimerhandler_7972
    mov byte ptr [ecx + _packbuf], al
    mov al, byte ptr [_packbuf + 0x1]
    or al, 4
    inc ecx
    mov byte ptr [_packbuf + 0x1], al
game_flow_faketimerhandler_7972:
    mov eax, dword ptr [edi + 6]
    xor eax, dword ptr [edx + 6]
    test al, 0xff
    je game_flow_faketimerhandler_8007
    mov al, byte ptr [edi + 6]
    mov byte ptr [ecx + _packbuf], al
    mov ah, byte ptr [_packbuf + 0x1]
    or ah, 8
    inc ecx
    mov byte ptr [_packbuf + 0x1], ah
game_flow_faketimerhandler_8007:
    mov eax, dword ptr [edi + 6]
    xor eax, dword ptr [edx + 6]
    test ah, 0xff
    je game_flow_faketimerhandler_8051
    mov eax, dword ptr [edi + 6]
    shr eax, 8
    and eax, 0xff
    mov byte ptr [ecx + _packbuf], al
    mov bl, byte ptr [_packbuf + 0x1]
    or bl, 0x10
    inc ecx
    mov byte ptr [_packbuf + 0x1], bl
game_flow_faketimerhandler_8051:
    mov eax, dword ptr [edi + 6]
    xor eax, dword ptr [edx + 6]
    test eax, 0xff0000
    je game_flow_faketimerhandler_8097
    mov eax, dword ptr [edi + 6]
    shr eax, 0x10
    and eax, 0xff
    mov byte ptr [ecx + _packbuf], al
    mov bh, byte ptr [_packbuf + 0x1]
    or bh, 0x20
    inc ecx
    mov byte ptr [_packbuf + 0x1], bh
game_flow_faketimerhandler_8097:
    mov eax, dword ptr [edi + 6]
    xor eax, dword ptr [edx + 6]
    test eax, 0xff000000
    je game_flow_faketimerhandler_8140
    mov eax, dword ptr [edi + 6]
    shr eax, 0x18
    and eax, 0xff
    mov byte ptr [ecx + _packbuf], al
    mov al, byte ptr [_packbuf + 0x1]
    or al, 0x40
    inc ecx
    mov byte ptr [_packbuf + 0x1], al
game_flow_faketimerhandler_8140:
    mov al, byte ptr [edi + 1]
    cmp al, byte ptr [edx + 1]
    je game_flow_faketimerhandler_8170
    mov byte ptr [ecx + _packbuf], al
    mov dl, byte ptr [_packbuf + 0x1]
    or dl, 0x80
    inc ecx
    mov byte ptr [_packbuf + 0x1], dl
game_flow_faketimerhandler_8170:
    movsx eax, word ptr [_myconnectindex]
    mov esi, dword ptr [_syncvaltail]
    cmp esi, dword ptr [eax*4 + _syncvalhead]
    je game_flow_faketimerhandler_8229
    {store} mov edx, eax
    {store} mov eax, esi
    inc ecx
    and eax, 0xff
    shl edx, 8
    lea edi, dword ptr [esi + 1]
    mov al, byte ptr [edx + eax + _syncval]
    mov dword ptr [_syncvaltail], edi
    mov byte ptr [ecx + _packbuf + 0xffffffff], al
    jmp game_flow_faketimerhandler_8170
game_flow_faketimerhandler_8229:
    mov edx, OFFSET FLAT:_packbuf
    movsx eax, word ptr [_connecthead]
    {store} mov ebx, ecx
    call sendpacket_
    add esp, 0x24
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_faketimerhandler_8258:
    mov edi, dword ptr [_movefifosendplc]
    movsx esi, cx
    jmp game_flow_faketimerhandler_8350
game_flow_faketimerhandler_8269:
    cmp edi, dword ptr [esi*4 + _movefifoend]
    jl game_flow_faketimerhandler_8342
    mov cl, 0x7f
    movsx eax, word ptr [_connecthead]
    mov byte ptr [_packbuf], cl
    movsx esi, word ptr [eax*2 + _connectpoint2]
    jmp game_flow_faketimerhandler_8328
game_flow_faketimerhandler_8303:
    mov ebx, 1
    mov edx, OFFSET FLAT:_packbuf
    {store} mov eax, esi
    call sendpacket_
    movsx esi, word ptr [esi*2 + _connectpoint2]
game_flow_faketimerhandler_8328:
    test esi, esi
    jge game_flow_faketimerhandler_8303
    add esp, 0x24
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_faketimerhandler_8342:
    movsx esi, word ptr [esi*2 + _connectpoint2]
game_flow_faketimerhandler_8350:
    test esi, esi
    jge game_flow_faketimerhandler_8269
    movsx esi, word ptr [_connecthead]
    mov edi, dword ptr [_movefifosendplc]
    jmp game_flow_faketimerhandler_8399
game_flow_faketimerhandler_8369:
    cmp byte ptr [esi + _playerquitflag], 0
    je game_flow_faketimerhandler_8391
    cmp edi, dword ptr [esi*4 + _movefifoend]
    {disp32} jge game_flow_faketimerhandler_6030
game_flow_faketimerhandler_8391:
    movsx esi, word ptr [esi*2 + _connectpoint2]
game_flow_faketimerhandler_8399:
    test esi, esi
    jge game_flow_faketimerhandler_8369
    mov edx, dword ptr [_movefifosendplc]
    dec edx
    and edx, 0xff
    mov edi, OFFSET FLAT:_inputfifo
    {disp32} lea eax, dword ptr [edx*4]
    mov ebx, dword ptr [_movefifosendplc]
    {store} add eax, edx
    mov edx, OFFSET FLAT:_inputfifo
    shl eax, 5
    and ebx, 0xff
    {store} add edx, eax
    {disp32} lea eax, dword ptr [ebx*4]
    mov ecx, 1
    {store} add eax, ebx
    xor bl, bl
    shl eax, 5
    mov byte ptr [_packbuf], bl
    mov bh, byte ptr [_movefifosendplc]
    {store} add edi, eax
    test bh, 0x1f
    {disp32} jne game_flow_faketimerhandler_8630
    movsx esi, word ptr [_connecthead]
    jmp game_flow_faketimerhandler_8585
game_flow_faketimerhandler_8503:
    cmp byte ptr [esi + _playerquitflag], 0
    je game_flow_faketimerhandler_8585
    {disp32} lea eax, dword ptr [esi*4]
    mov ebp, dword ptr [eax + _myminlag]
    cmp ebp, -128
    jle game_flow_faketimerhandler_8534
    {store} mov eax, ebp
    jmp game_flow_faketimerhandler_8539
game_flow_faketimerhandler_8534:
    mov eax, 0xffffff80
game_flow_faketimerhandler_8539:
    cmp eax, 0x7f
    jge game_flow_faketimerhandler_8573
    {disp32} lea eax, dword ptr [esi*4]
    mov ebx, dword ptr [eax + _myminlag]
    cmp ebx, -128
    jle game_flow_faketimerhandler_8566
    {store} mov eax, ebx
    jmp game_flow_faketimerhandler_8578
game_flow_faketimerhandler_8566:
    mov eax, 0xffffff80
    jmp game_flow_faketimerhandler_8578
game_flow_faketimerhandler_8573:
    mov eax, 0x7f
game_flow_faketimerhandler_8578:
    inc ecx
    mov byte ptr [ecx + _packbuf + 0xffffffff], al
game_flow_faketimerhandler_8585:
    movsx esi, word ptr [esi*2 + _connectpoint2]
    test esi, esi
    jge game_flow_faketimerhandler_8503
    mov ebp, 0x7fffffff
    movsx esi, word ptr [_connecthead]
    jmp game_flow_faketimerhandler_8626
game_flow_faketimerhandler_8611:
    mov dword ptr [esi*4 + _myminlag], ebp
    movsx esi, word ptr [esi*2 + _connectpoint2]
game_flow_faketimerhandler_8626:
    test esi, esi
    jge game_flow_faketimerhandler_8611
game_flow_faketimerhandler_8630:
    movsx esi, word ptr [_connecthead]
    {store} mov eax, ecx
    test esi, esi
    jge game_flow_faketimerhandler_8655
    movsx esi, word ptr [_connecthead]
    {disp32} jmp game_flow_faketimerhandler_9376
game_flow_faketimerhandler_8655:
    {store} xor ebx, ebx
    mov bl, byte ptr [esi + _playerquitflag]
    movsx esi, word ptr [esi*2 + _connectpoint2]
    {store} add ecx, ebx
    test esi, esi
    jge game_flow_faketimerhandler_8655
    movsx esi, word ptr [_connecthead]
    {disp32} jmp game_flow_faketimerhandler_9376
game_flow_faketimerhandler_8689:
    cmp byte ptr [esi + _playerquitflag], 0
    {disp32} je game_flow_faketimerhandler_9368
    xor bh, bh
    mov byte ptr [eax + _packbuf], bh
    {disp32} lea ebx, dword ptr [esi*4]
    {store} add ebx, esi
    {store} add ebx, ebx
    lea ebp, dword ptr [edi + ebx]
    mov dword ptr [esp + 28], ebp
    lea ebp, dword ptr [edx + ebx]
    mov ebx, dword ptr [esp + 28]
    mov bx, word ptr [ebx + 2]
    cmp bx, word ptr [ebp + 2]
    je game_flow_faketimerhandler_8801
    mov ebx, dword ptr [esp + 28]
    mov bl, byte ptr [ebx + 2]
    mov byte ptr [ecx + _packbuf], bl
    mov ebx, dword ptr [esp + 28]
    movsx ebx, word ptr [ebx + 2]
    sar ebx, 8
    mov dword ptr [esp + 32], ebx
    mov bl, byte ptr [esp + 32]
    mov byte ptr [ecx + _packbuf + 0x1], bl
    mov bl, byte ptr [eax + _packbuf]
    add ecx, 2
    or bl, 1
    mov byte ptr [eax + _packbuf], bl
game_flow_faketimerhandler_8801:
    {disp32} lea ebx, dword ptr [esi*4]
    {store} add ebx, esi
    {store} add ebx, ebx
    lea ebp, dword ptr [edi + ebx]
    mov dword ptr [esp], ebp
    lea ebp, dword ptr [edx + ebx]
    mov ebx, dword ptr [esp]
    mov bx, word ptr [ebx + 4]
    cmp bx, word ptr [ebp + 4]
    je game_flow_faketimerhandler_8880
    mov ebx, dword ptr [esp]
    mov bl, byte ptr [ebx + 4]
    mov byte ptr [ecx + _packbuf], bl
    mov ebx, dword ptr [esp]
    movsx ebx, word ptr [ebx + 4]
    sar ebx, 8
    mov byte ptr [ecx + _packbuf + 0x1], bl
    mov bh, byte ptr [eax + _packbuf]
    add ecx, 2
    or bh, 2
    mov byte ptr [eax + _packbuf], bh
game_flow_faketimerhandler_8880:
    {disp32} lea ebx, dword ptr [esi*4]
    {store} add ebx, esi
    {store} add ebx, ebx
    lea ebp, dword ptr [edi + ebx]
    mov dword ptr [esp + 16], ebp
    lea ebp, dword ptr [edx + ebx]
    mov ebx, dword ptr [esp + 16]
    mov bl, byte ptr [ebx]
    {disp8} mov bh, byte ptr [ebp]
    cmp bl, bh
    je game_flow_faketimerhandler_8942
    mov ebx, dword ptr [esp + 16]
    mov bl, byte ptr [ebx]
    mov byte ptr [ecx + _packbuf], bl
    mov bl, byte ptr [eax + _packbuf]
    or bl, 4
    inc ecx
    mov byte ptr [eax + _packbuf], bl
game_flow_faketimerhandler_8942:
    {disp32} lea ebx, dword ptr [esi*4]
    {store} add ebx, esi
    {store} add ebx, ebx
    lea ebp, dword ptr [edi + ebx]
    mov dword ptr [esp + 24], ebp
    lea ebp, dword ptr [edx + ebx]
    mov ebx, dword ptr [esp + 24]
    mov ebx, dword ptr [ebx + 6]
    mov dword ptr [esp + 32], ebx
    mov ebx, dword ptr [ebp + 6]
    mov ebp, dword ptr [esp + 32]
    {store} xor ebp, ebx
    {store} mov ebx, ebp
    test bl, 0xff
    je game_flow_faketimerhandler_9019
    mov ebx, dword ptr [esp + 24]
    mov bl, byte ptr [ebx + 6]
    mov byte ptr [ecx + _packbuf], bl
    mov bh, byte ptr [eax + _packbuf]
    or bh, 8
    inc ecx
    mov byte ptr [eax + _packbuf], bh
game_flow_faketimerhandler_9019:
    {disp32} lea ebx, dword ptr [esi*4]
    {store} add ebx, esi
    {store} add ebx, ebx
    lea ebp, dword ptr [edi + ebx]
    mov dword ptr [esp + 8], ebp
    lea ebp, dword ptr [edx + ebx]
    mov ebx, dword ptr [esp + 8]
    mov ebx, dword ptr [ebx + 6]
    mov dword ptr [esp + 32], ebx
    mov ebx, dword ptr [ebp + 6]
    mov ebp, dword ptr [esp + 32]
    {store} xor ebp, ebx
    {store} mov ebx, ebp
    test bh, 0xff
    je game_flow_faketimerhandler_9113
    mov ebx, dword ptr [esp + 8]
    mov ebx, dword ptr [ebx + 6]
    shr ebx, 8
    and ebx, 0xff
    mov dword ptr [esp + 32], ebx
    mov bl, byte ptr [esp + 32]
    mov byte ptr [ecx + _packbuf], bl
    mov bl, byte ptr [eax + _packbuf]
    or bl, 0x10
    inc ecx
    mov byte ptr [eax + _packbuf], bl
game_flow_faketimerhandler_9113:
    {disp32} lea ebx, dword ptr [esi*4]
    {store} add ebx, esi
    {store} add ebx, ebx
    lea ebp, dword ptr [edi + ebx]
    mov dword ptr [esp + 4], ebp
    lea ebp, dword ptr [edx + ebx]
    mov ebx, dword ptr [esp + 4]
    mov ebx, dword ptr [ebx + 6]
    mov dword ptr [esp + 32], ebx
    mov ebx, dword ptr [ebp + 6]
    mov ebp, dword ptr [esp + 32]
    {store} xor ebp, ebx
    test ebp, 0xff0000
    je game_flow_faketimerhandler_9208
    mov ebx, dword ptr [esp + 4]
    mov ebx, dword ptr [ebx + 6]
    shr ebx, 0x10
    and ebx, 0xff
    mov dword ptr [esp + 32], ebx
    mov bl, byte ptr [esp + 32]
    mov byte ptr [ecx + _packbuf], bl
    mov bh, byte ptr [eax + _packbuf]
    or bh, 0x20
    inc ecx
    mov byte ptr [eax + _packbuf], bh
game_flow_faketimerhandler_9208:
    {disp32} lea ebx, dword ptr [esi*4]
    {store} add ebx, esi
    {store} add ebx, ebx
    lea ebp, dword ptr [edi + ebx]
    mov dword ptr [esp + 20], ebp
    lea ebp, dword ptr [edx + ebx]
    mov ebx, dword ptr [esp + 20]
    mov ebx, dword ptr [ebx + 6]
    mov dword ptr [esp + 32], ebx
    mov ebx, dword ptr [ebp + 6]
    mov ebp, dword ptr [esp + 32]
    {store} xor ebp, ebx
    test ebp, 0xff000000
    je game_flow_faketimerhandler_9303
    mov ebx, dword ptr [esp + 20]
    mov ebx, dword ptr [ebx + 6]
    shr ebx, 0x18
    and ebx, 0xff
    mov dword ptr [esp + 32], ebx
    mov bl, byte ptr [esp + 32]
    mov byte ptr [ecx + _packbuf], bl
    mov bl, byte ptr [eax + _packbuf]
    or bl, 0x40
    inc ecx
    mov byte ptr [eax + _packbuf], bl
game_flow_faketimerhandler_9303:
    {disp32} lea ebx, dword ptr [esi*4]
    {store} add ebx, esi
    {store} add ebx, ebx
    lea ebp, dword ptr [edi + ebx]
    mov dword ptr [esp + 12], ebp
    lea ebp, dword ptr [edx + ebx]
    mov ebx, dword ptr [esp + 12]
    mov bl, byte ptr [ebx + 1]
    mov bh, byte ptr [ebp + 1]
    cmp bl, bh
    je game_flow_faketimerhandler_9367
    mov ebx, dword ptr [esp + 12]
    mov bl, byte ptr [ebx + 1]
    mov byte ptr [ecx + _packbuf], bl
    mov bl, byte ptr [eax + _packbuf]
    or bl, 0x80
    inc ecx
    mov byte ptr [eax + _packbuf], bl
game_flow_faketimerhandler_9367:
    inc eax
game_flow_faketimerhandler_9368:
    movsx esi, word ptr [esi*2 + _connectpoint2]
game_flow_faketimerhandler_9376:
    test esi, esi
    {disp32} jge game_flow_faketimerhandler_8689
game_flow_faketimerhandler_9384:
    movsx esi, word ptr [_myconnectindex]
    mov edx, dword ptr [_syncvaltail]
    cmp edx, dword ptr [esi*4 + _syncvalhead]
    je game_flow_faketimerhandler_9441
    {store} mov eax, edx
    shl esi, 8
    and eax, 0xff
    inc ecx
    lea ebx, dword ptr [edx + 1]
    mov al, byte ptr [esi + eax + _syncval]
    mov dword ptr [_syncvaltail], ebx
    mov byte ptr [ecx + _packbuf + 0xffffffff], al
    jmp game_flow_faketimerhandler_9384
game_flow_faketimerhandler_9441:
    movsx eax, word ptr [_connecthead]
    movsx esi, word ptr [eax*2 + _connectpoint2]
    jmp game_flow_faketimerhandler_9513
game_flow_faketimerhandler_9458:
    cmp byte ptr [esi + _playerquitflag], 0
    je game_flow_faketimerhandler_9505
    mov edx, OFFSET FLAT:_packbuf
    {store} mov ebx, ecx
    {store} mov eax, esi
    call sendpacket_
    {disp32} lea eax, dword ptr [esi*4]
    {store} add eax, esi
    test byte ptr [edi + eax*2 + 9], 4
    je game_flow_faketimerhandler_9505
    xor dh, dh
    mov byte ptr [esi + _playerquitflag], dh
game_flow_faketimerhandler_9505:
    movsx esi, word ptr [esi*2 + _connectpoint2]
game_flow_faketimerhandler_9513:
    test esi, esi
    jge game_flow_faketimerhandler_9458
    {store} xor eax, eax
    mov ecx, dword ptr [_movefifosendplc]
    mov al, byte ptr [_movesperpacket]
    {store} add ecx, eax
    mov dword ptr [_movefifosendplc], ecx
    movsx esi, word ptr [_connecthead]
    mov edi, dword ptr [_movefifosendplc]
    {disp32} jmp game_flow_faketimerhandler_8399
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
checksync_:
    push ebx
    push ecx
    push edx
    push esi
    movsx eax, word ptr [_connecthead]
    mov ebx, dword ptr [_syncvaltottail]
    jmp game_flow_checksync_9604
game_flow_checksync_9587:
    cmp ebx, dword ptr [eax*4 + _syncvalhead]
    je game_flow_checksync_9608
    movsx eax, word ptr [eax*2 + _connectpoint2]
game_flow_checksync_9604:
    test eax, eax
    jge game_flow_checksync_9587
game_flow_checksync_9608:
    test eax, eax
    {disp32} jge game_flow_checksync_9742
    xor ah, ah
    mov byte ptr [_syncstat], ah
game_flow_checksync_9624:
    movsx eax, word ptr [_connecthead]
    jmp game_flow_checksync_9684
game_flow_checksync_9633:
    movsx ecx, word ptr [_connecthead]
    mov edx, dword ptr [_syncvaltottail]
    {store} mov ebx, eax
    shl ecx, 8
    and edx, 0xff
    shl ebx, 8
    {store} add ecx, edx
    mov dl, byte ptr [edx + ebx + _syncval]
    cmp dl, byte ptr [ecx + _syncval]
    je game_flow_checksync_9684
    mov byte ptr [_syncstat], 1
game_flow_checksync_9684:
    movsx eax, word ptr [eax*2 + _connectpoint2]
    test eax, eax
    jge game_flow_checksync_9633
    inc dword ptr [_syncvaltottail]
    movsx eax, word ptr [_connecthead]
    mov esi, dword ptr [_syncvaltottail]
    jmp game_flow_checksync_9734
game_flow_checksync_9717:
    cmp esi, dword ptr [eax*4 + _syncvalhead]
    je game_flow_checksync_9738
    movsx eax, word ptr [eax*2 + _connectpoint2]
game_flow_checksync_9734:
    test eax, eax
    jge game_flow_checksync_9717
game_flow_checksync_9738:
    test eax, eax
    jl game_flow_checksync_9624
game_flow_checksync_9742:
    movsx eax, word ptr [_connecthead]
    cmp word ptr [eax*2 + _connectpoint2], 0
    jge game_flow_checksync_9768
    xor bh, bh
    mov byte ptr [_syncstat], bh
game_flow_checksync_9768:
    cmp byte ptr [_syncstat], 0
    je game_flow_checksync_9835
    push 0
    mov ebx, 0x1f
    mov edx, 0x82
    push OFFSET FLAT:game_text_checksync_100
    mov eax, 4
    {store} xor ecx, ecx
    call printext256_
    push 0
    mov ebx, 0x1f
    mov edx, 0x8a
    push OFFSET FLAT:game_text_checksync_136
    mov eax, 4
    {store} xor ecx, ecx
    call printext256_
game_flow_checksync_9835:
    cmp byte ptr [_syncstate], 0
    je game_flow_checksync_9902
    push 0
    mov ebx, 0x1f
    mov edx, 0xa0
    push OFFSET FLAT:game_text_checksync_172
    mov eax, 4
    {store} xor ecx, ecx
    call printext256_
    push 0
    mov ebx, 0x1f
    mov edx, 0x8a
    push OFFSET FLAT:game_text_checksync_196
    mov eax, 4
    {store} xor ecx, ecx
    call printext256_
game_flow_checksync_9902:
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
    nop
check_fta_sounds_:
    push ebx
    push ecx
    push edx
    {store} mov edx, eax
    movsx ebx, ax
    imul ecx, ebx, 0x2c
    cmp word ptr [ecx + _sprite + 0x2a], 0
    {disp32} jle game_flow_check_fta_sounds_10475
    mov ax, word ptr [ecx + _sprite + 0xe]
    .att_syntax prefix
    cmpw $game_math_check_fta_sounds_9952,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_check_fta_sounds_10108
    {disp32} jbe game_flow_check_fta_sounds_10274
    .att_syntax prefix
    cmpw $game_math_check_fta_sounds_9968,%ax
    .intel_syntax noprefix
    jb game_flow_check_fta_sounds_10052
    {disp32} jbe game_flow_check_fta_sounds_10257
    .att_syntax prefix
    cmpw $game_math_check_fta_sounds_9980,%ax
    .intel_syntax noprefix
    jb game_flow_check_fta_sounds_10022
    {disp32} jbe game_flow_check_fta_sounds_10375
    .att_syntax prefix
    cmpw $game_math_check_fta_sounds_9992,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_check_fta_sounds_10475
    {disp32} jbe game_flow_check_fta_sounds_10389
    .att_syntax prefix
    cmpw $game_math_check_fta_sounds_10008,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_check_fta_sounds_10426
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_check_fta_sounds_10022:
    .att_syntax prefix
    cmpw $game_math_check_fta_sounds_10022,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_check_fta_sounds_10475
    {disp32} jbe game_flow_check_fta_sounds_10463
    .att_syntax prefix
    cmpw $game_math_check_fta_sounds_10038,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_check_fta_sounds_10342
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_check_fta_sounds_10052:
    .att_syntax prefix
    cmpw $game_math_check_fta_sounds_10052,%ax
    .intel_syntax noprefix
    jb game_flow_check_fta_sounds_10094
    {disp32} jbe game_flow_check_fta_sounds_10257
    .att_syntax prefix
    cmpw $game_math_check_fta_sounds_10064,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_check_fta_sounds_10475
    {disp32} jbe game_flow_check_fta_sounds_10257
    .att_syntax prefix
    cmpw $game_math_check_fta_sounds_10080,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_check_fta_sounds_10257
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_check_fta_sounds_10094:
    .att_syntax prefix
    cmpw $game_math_check_fta_sounds_10094,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_check_fta_sounds_10274
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_check_fta_sounds_10108:
    .att_syntax prefix
    cmpw $game_math_check_fta_sounds_10108,%ax
    .intel_syntax noprefix
    jb game_flow_check_fta_sounds_10190
    {disp32} jbe game_flow_check_fta_sounds_10240
    .att_syntax prefix
    cmpw $game_math_check_fta_sounds_10120,%ax
    .intel_syntax noprefix
    jb game_flow_check_fta_sounds_10166
    {disp32} jbe game_flow_check_fta_sounds_10308
    .att_syntax prefix
    cmpw $game_math_check_fta_sounds_10132,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_check_fta_sounds_10475
    .att_syntax prefix
    cmpw $game_math_check_fta_sounds_10142,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_check_fta_sounds_10325
    .att_syntax prefix
    cmpw $game_math_check_fta_sounds_10152,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_check_fta_sounds_10291
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_check_fta_sounds_10166:
    .att_syntax prefix
    cmpw $game_math_check_fta_sounds_10166,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_check_fta_sounds_10475
    .att_syntax prefix
    cmpw $game_math_check_fta_sounds_10176,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_check_fta_sounds_10358
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_check_fta_sounds_10190:
    .att_syntax prefix
    cmpw $game_math_check_fta_sounds_10190,%ax
    .intel_syntax noprefix
    jb game_flow_check_fta_sounds_10220
    jbe game_flow_check_fta_sounds_10240
    .att_syntax prefix
    cmpw $game_math_check_fta_sounds_10198,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_check_fta_sounds_10475
    jbe game_flow_check_fta_sounds_10240
    .att_syntax prefix
    cmpw $game_math_check_fta_sounds_10210,%ax
    .intel_syntax noprefix
    je game_flow_check_fta_sounds_10240
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_check_fta_sounds_10220:
    .att_syntax prefix
    cmpw $game_math_check_fta_sounds_10220,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_check_fta_sounds_10475
    .att_syntax prefix
    cmpw $game_math_check_fta_sounds_10230,%ax
    .intel_syntax noprefix
    {disp32} ja game_flow_check_fta_sounds_10475
game_flow_check_fta_sounds_10240:
    mov eax, 0x6f
    movsx edx, dx
    call spritesound_
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_check_fta_sounds_10257:
    mov eax, 0x75
    movsx edx, dx
    call spritesound_
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_check_fta_sounds_10274:
    mov eax, 0x79
    movsx edx, dx
    call spritesound_
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_check_fta_sounds_10291:
    mov eax, 0x7e
    movsx edx, dx
    call spritesound_
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_check_fta_sounds_10308:
    mov eax, 0x83
    movsx edx, dx
    call spritesound_
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_check_fta_sounds_10325:
    mov eax, 0x88
    movsx edx, dx
    call spritesound_
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_check_fta_sounds_10342:
    mov eax, 0x92
    {store} mov edx, ebx
    call spritesound_
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_check_fta_sounds_10358:
    mov eax, 0x8d
    movsx edx, dx
    call spritesound_
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_check_fta_sounds_10375:
    mov eax, 0x61
    call sound_
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_check_fta_sounds_10389:
    cmp byte ptr [ecx + _sprite + 0x11], 1
    jne game_flow_check_fta_sounds_10412
    mov eax, 0x66
    call sound_
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_check_fta_sounds_10412:
    mov eax, 0x126
    call sound_
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_check_fta_sounds_10426:
    cmp byte ptr [ecx + _sprite + 0x11], 1
    jne game_flow_check_fta_sounds_10449
    mov eax, 0x97
    call sound_
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_check_fta_sounds_10449:
    mov eax, 0x11c
    call sound_
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_check_fta_sounds_10463:
    mov eax, 0x1a
    {store} mov edx, ebx
    call spritesound_
game_flow_check_fta_sounds_10475:
    pop edx
    pop ecx
    pop ebx
    ret
    nop
inventory_:
    mov ax, word ptr [eax + 14]
    .att_syntax prefix
    cmpw $game_math_inventory_10484,%ax
    .intel_syntax noprefix
    jb game_flow_inventory_10509
    jbe game_flow_inventory_10529
    .att_syntax prefix
    cmpw $game_math_inventory_10492,%ax
    .intel_syntax noprefix
    jb game_flow_inventory_10535
    jbe game_flow_inventory_10529
    .att_syntax prefix
    cmpw $game_math_inventory_10500,%ax
    .intel_syntax noprefix
    je game_flow_inventory_10529
    {store} xor eax, eax
    ret
game_flow_inventory_10509:
    .att_syntax prefix
    cmpw $game_math_inventory_10509,%ax
    .intel_syntax noprefix
    jb game_flow_inventory_10535
    jbe game_flow_inventory_10529
    .att_syntax prefix
    cmpw $game_math_inventory_10517,%ax
    .intel_syntax noprefix
    jb game_flow_inventory_10535
    .att_syntax prefix
    cmpw $game_math_inventory_10523,%ax
    .intel_syntax noprefix
    ja game_flow_inventory_10535
game_flow_inventory_10529:
    mov eax, 1
    ret
game_flow_inventory_10535:
    {store} xor eax, eax
    ret
    {disp32} lea eax, dword ptr [eax]
badguy_:
    mov ax, word ptr [eax + 14]
    .att_syntax prefix
    cmpw $game_math_badguy_10548,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_badguy_10729
    {disp32} jbe game_flow_badguy_10844
    .att_syntax prefix
    cmpw $game_math_badguy_10564,%ax
    .intel_syntax noprefix
    jb game_flow_badguy_10655
    {disp32} jbe game_flow_badguy_10844
    .att_syntax prefix
    cmpw $game_math_badguy_10576,%ax
    .intel_syntax noprefix
    jb game_flow_badguy_10626
    {disp32} jbe game_flow_badguy_10844
    .att_syntax prefix
    cmpw $game_math_badguy_10588,%ax
    .intel_syntax noprefix
    jb game_flow_badguy_10613
    {disp32} jbe game_flow_badguy_10844
    .att_syntax prefix
    cmpw $game_math_badguy_10600,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_badguy_10844
    {store} xor eax, eax
    ret
game_flow_badguy_10613:
    .att_syntax prefix
    cmpw $game_math_badguy_10613,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_badguy_10844
    {store} xor eax, eax
    ret
game_flow_badguy_10626:
    .att_syntax prefix
    cmpw $game_math_badguy_10626,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_badguy_10850
    {disp32} jbe game_flow_badguy_10844
    .att_syntax prefix
    cmpw $game_math_badguy_10642,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_badguy_10844
    {store} xor eax, eax
    ret
game_flow_badguy_10655:
    .att_syntax prefix
    cmpw $game_math_badguy_10655,%ax
    .intel_syntax noprefix
    jb game_flow_badguy_10696
    {disp32} jbe game_flow_badguy_10844
    .att_syntax prefix
    cmpw $game_math_badguy_10667,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_badguy_10850
    {disp32} jbe game_flow_badguy_10844
    .att_syntax prefix
    cmpw $game_math_badguy_10683,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_badguy_10844
    {store} xor eax, eax
    ret
game_flow_badguy_10696:
    .att_syntax prefix
    cmpw $game_math_badguy_10696,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_badguy_10850
    .att_syntax prefix
    cmpw $game_math_badguy_10706,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_badguy_10844
    .att_syntax prefix
    cmpw $game_math_badguy_10716,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_badguy_10844
    {store} xor eax, eax
    ret
game_flow_badguy_10729:
    .att_syntax prefix
    cmpw $game_math_badguy_10729,%ax
    .intel_syntax noprefix
    jb game_flow_badguy_10801
    {disp32} jbe game_flow_badguy_10844
    .att_syntax prefix
    cmpw $game_math_badguy_10741,%ax
    .intel_syntax noprefix
    jb game_flow_badguy_10784
    {disp32} jbe game_flow_badguy_10844
    .att_syntax prefix
    cmpw $game_math_badguy_10753,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_badguy_10850
    {disp32} jbe game_flow_badguy_10844
    .att_syntax prefix
    cmpw $game_math_badguy_10769,%ax
    .intel_syntax noprefix
    jb game_flow_badguy_10850
    .att_syntax prefix
    cmpw $game_math_badguy_10775,%ax
    .intel_syntax noprefix
    jbe game_flow_badguy_10844
    {store} xor eax, eax
    ret
game_flow_badguy_10784:
    .att_syntax prefix
    cmpw $game_math_badguy_10784,%ax
    .intel_syntax noprefix
    jb game_flow_badguy_10850
    jbe game_flow_badguy_10844
    .att_syntax prefix
    cmpw $game_math_badguy_10792,%ax
    .intel_syntax noprefix
    je game_flow_badguy_10844
    {store} xor eax, eax
    ret
game_flow_badguy_10801:
    .att_syntax prefix
    cmpw $game_math_badguy_10801,%ax
    .intel_syntax noprefix
    jb game_flow_badguy_10830
    jbe game_flow_badguy_10844
    .att_syntax prefix
    cmpw $game_math_badguy_10809,%ax
    .intel_syntax noprefix
    jb game_flow_badguy_10850
    .att_syntax prefix
    cmpw $game_math_badguy_10815,%ax
    .intel_syntax noprefix
    jbe game_flow_badguy_10844
    .att_syntax prefix
    cmpw $game_math_badguy_10821,%ax
    .intel_syntax noprefix
    je game_flow_badguy_10844
    {store} xor eax, eax
    ret
game_flow_badguy_10830:
    .att_syntax prefix
    cmpw $game_math_badguy_10830,%ax
    .intel_syntax noprefix
    jb game_flow_badguy_10850
    jbe game_flow_badguy_10844
    .att_syntax prefix
    cmpw $game_math_badguy_10838,%ax
    .intel_syntax noprefix
    jne game_flow_badguy_10850
game_flow_badguy_10844:
    mov eax, 1
    ret
game_flow_badguy_10850:
    {store} xor eax, eax
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp8} lea edx, dword ptr [edx]
    {load} mov ebx, ebx
badguypic_:
    push edx
    {store} mov edx, eax
    .att_syntax prefix
    cmpw $game_math_badguypic_10867,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_badguypic_11053
    {disp32} jbe game_flow_badguypic_11175
    .att_syntax prefix
    cmpw $game_math_badguypic_10883,%ax
    .intel_syntax noprefix
    jb game_flow_badguypic_10977
    {disp32} jbe game_flow_badguypic_11175
    .att_syntax prefix
    cmpw $game_math_badguypic_10895,%ax
    .intel_syntax noprefix
    jb game_flow_badguypic_10947
    {disp32} jbe game_flow_badguypic_11175
    .att_syntax prefix
    cmpw $game_math_badguypic_10907,%ax
    .intel_syntax noprefix
    jb game_flow_badguypic_10933
    {disp32} jbe game_flow_badguypic_11175
    .att_syntax prefix
    cmpw $game_math_badguypic_10919,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_badguypic_11175
    {store} xor eax, eax
    pop edx
    ret
game_flow_badguypic_10933:
    .att_syntax prefix
    cmpw $game_math_badguypic_10933,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_badguypic_11175
    {store} xor eax, eax
    pop edx
    ret
game_flow_badguypic_10947:
    .att_syntax prefix
    cmpw $game_math_badguypic_10947,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_badguypic_11182
    {disp32} jbe game_flow_badguypic_11175
    .att_syntax prefix
    cmpw $game_math_badguypic_10963,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_badguypic_11175
    {store} xor eax, eax
    pop edx
    ret
game_flow_badguypic_10977:
    .att_syntax prefix
    cmpw $game_math_badguypic_10977,%ax
    .intel_syntax noprefix
    jb game_flow_badguypic_11019
    {disp32} jbe game_flow_badguypic_11175
    .att_syntax prefix
    cmpw $game_math_badguypic_10989,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_badguypic_11182
    {disp32} jbe game_flow_badguypic_11175
    .att_syntax prefix
    cmpw $game_math_badguypic_11005,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_badguypic_11175
    {store} xor eax, eax
    pop edx
    ret
game_flow_badguypic_11019:
    .att_syntax prefix
    cmpw $game_math_badguypic_11019,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_badguypic_11182
    .att_syntax prefix
    cmpw $game_math_badguypic_11029,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_badguypic_11175
    .att_syntax prefix
    cmpw $game_math_badguypic_11039,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_badguypic_11175
    {store} xor eax, eax
    pop edx
    ret
game_flow_badguypic_11053:
    .att_syntax prefix
    cmpw $game_math_badguypic_11053,%ax
    .intel_syntax noprefix
    jb game_flow_badguypic_11131
    {disp32} jbe game_flow_badguypic_11175
    .att_syntax prefix
    cmpw $game_math_badguypic_11065,%ax
    .intel_syntax noprefix
    jb game_flow_badguypic_11113
    {disp32} jbe game_flow_badguypic_11175
    .att_syntax prefix
    cmpw $game_math_badguypic_11077,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_badguypic_11182
    {disp32} jbe game_flow_badguypic_11175
    .att_syntax prefix
    cmpw $game_math_badguypic_11093,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_badguypic_11182
    .att_syntax prefix
    cmpw $game_math_badguypic_11103,%ax
    .intel_syntax noprefix
    jbe game_flow_badguypic_11175
    {store} xor eax, eax
    pop edx
    ret
game_flow_badguypic_11113:
    .att_syntax prefix
    cmpw $game_math_badguypic_11113,%ax
    .intel_syntax noprefix
    jb game_flow_badguypic_11182
    jbe game_flow_badguypic_11175
    .att_syntax prefix
    cmpw $game_math_badguypic_11121,%ax
    .intel_syntax noprefix
    je game_flow_badguypic_11175
    {store} xor eax, eax
    pop edx
    ret
game_flow_badguypic_11131:
    .att_syntax prefix
    cmpw $game_math_badguypic_11131,%ax
    .intel_syntax noprefix
    jb game_flow_badguypic_11161
    jbe game_flow_badguypic_11175
    .att_syntax prefix
    cmpw $game_math_badguypic_11139,%ax
    .intel_syntax noprefix
    jb game_flow_badguypic_11182
    .att_syntax prefix
    cmpw $game_math_badguypic_11145,%ax
    .intel_syntax noprefix
    jbe game_flow_badguypic_11175
    .att_syntax prefix
    cmpw $game_math_badguypic_11151,%ax
    .intel_syntax noprefix
    je game_flow_badguypic_11175
    {store} xor eax, eax
    pop edx
    ret
game_flow_badguypic_11161:
    .att_syntax prefix
    cmpw $game_math_badguypic_11161,%ax
    .intel_syntax noprefix
    jb game_flow_badguypic_11182
    jbe game_flow_badguypic_11175
    .att_syntax prefix
    cmpw $game_math_badguypic_11169,%ax
    .intel_syntax noprefix
    jne game_flow_badguypic_11182
game_flow_badguypic_11175:
    mov eax, 1
    pop edx
    ret
game_flow_badguypic_11182:
    {store} xor eax, eax
    pop edx
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
    {load} mov eax, eax
myos_:
    push esi
    push edi
    push ebp
    sub esp, 4
    {store} mov esi, eax
    {store} mov edi, edx
    mov byte ptr [esp], cl
    test byte ptr [esp + 20], 4
    je game_flow_myos_11227
    mov edx, 0x400
    jmp game_flow_myos_11229
game_flow_myos_11227:
    {store} xor edx, edx
game_flow_myos_11229:
    movsx eax, word ptr [_screenpeek]
    imul eax, eax, 0x552
    movsx ecx, word ptr [eax + _ps + 0x286]
    {disp32} lea eax, dword ptr [ecx*4]
    mov ebp, dword ptr [_windowy2]
    {store} add eax, ecx
    push ebp
    mov cl, byte ptr [eax*8 + _sector + 0x1d]
    mov eax, dword ptr [_windowx2]
    push eax
    mov ebp, dword ptr [_windowy1]
    push ebp
    mov eax, dword ptr [_windowx1]
    push eax
    mov al, byte ptr [esp + 36]
    or al, 2
    and eax, 0xff
    push eax
    {store} xor eax, eax
    {store} mov al, cl
    push eax
    movsx ecx, dx
    movsx eax, byte ptr [esp + 24]
    {store} mov edx, edi
    push eax
    movsx eax, bx
    shl edx, 0x10
    push eax
    {store} mov eax, esi
    mov ebx, 0x10000
    shl eax, 0x10
    call rotatesprite_
    add esp, 4
    pop ebp
    pop edi
    pop esi
    ret 4
    {disp32} lea eax, dword ptr [eax]
    {disp8} lea edx, dword ptr [edx + eiz*1]
myospal_:
    push esi
    push edi
    push ebp
    test byte ptr [esp + 16], 4
    je game_flow_myospal_11377
    mov esi, 0x400
    jmp game_flow_myospal_11379
game_flow_myospal_11377:
    {store} xor esi, esi
game_flow_myospal_11379:
    mov edi, dword ptr [_windowy2]
    mov ch, byte ptr [esp + 16]
    push edi
    mov ebp, dword ptr [_windowx2]
    mov edi, dword ptr [_windowy1]
    push ebp
    shl edx, 0x10
    push edi
    mov ebp, dword ptr [_windowx1]
    or ch, 2
    push ebp
    movzx edi, ch
    push edi
    movzx edi, byte ptr [esp + 40]
    movsx ecx, cl
    push edi
    shl eax, 0x10
    push ecx
    movsx ecx, bx
    mov ebx, 0x10000
    push ecx
    movsx ecx, si
    call rotatesprite_
    pop ebp
    pop edi
    pop esi
    ret 8
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
    {disp8} lea eax, dword ptr [eax]
invennum_:
    push esi
    push edi
    push ebp
    sub esp, 0x64
    mov dword ptr [esp + 80], edx
    {store} mov dl, cl
    {store} mov ebp, eax
    mov dh, byte ptr [esp + 116]
    mov ecx, 0x14
    {store} xor eax, eax
    {store} mov edi, esp
    {store} mov al, bl
    mov esi, OFFSET FLAT:game_invennum_dabuf_initializer
    push eax
    rep movsd dword ptr es:[edi], dword ptr [esi]
    push OFFSET FLAT:game_text_invennum_232
    lea eax, dword ptr [esp + 8]
    {store} mov esi, ebp
    push eax
    shl esi, 0x10
    call sprintf_
    mov ecx, dword ptr [_ydim]
    {store} mov eax, ebp
    add esp, 0xc
    add eax, 4
    dec ecx
    mov dword ptr [esp + 96], esi
    mov dword ptr [esp + 84], eax
    mov esi, dword ptr [esp + 80]
    mov edi, dword ptr [esp + 84]
    mov eax, dword ptr [_xdim]
    shl esi, 0x10
    dec eax
    shl edi, 0x10
    cmp bl, 0x63
    {disp32} jbe game_flow_invennum_11769
    push ecx
    push eax
    {store} xor eax, eax
    push 0
    {store} mov al, dh
    push 0
    mov dword ptr [esp + 104], eax
    push eax
    {store} xor eax, eax
    {store} mov al, dl
    push 0
    mov dword ptr [esp + 116], eax
    push eax
    {store} xor eax, eax
    mov al, byte ptr [esp + 28]
    mov ebx, 0x10000
    .att_syntax prefix
    addl $game_math_invennum_11618,%eax
    .intel_syntax noprefix
    {store} xor ecx, ecx
    push eax
    lea eax, dword ptr [ebp + -4]
    {store} mov edx, esi
    shl eax, 0x10
    call rotatesprite_
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    mov ebx, dword ptr [esp + 104]
    push ebx
    mov ecx, dword ptr [esp + 112]
    {store} xor eax, eax
    push 0
    {store} mov edx, esi
    mov al, byte ptr [esp + 25]
    push ecx
    .att_syntax prefix
    addl $game_math_invennum_11677,%eax
    .intel_syntax noprefix
    mov ebx, 0x10000
    push eax
    {store} xor ecx, ecx
    mov eax, dword ptr [esp + 128]
    call rotatesprite_
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    mov ebp, dword ptr [esp + 104]
    push ebp
    push 0
    mov eax, dword ptr [esp + 116]
    push eax
    {store} xor eax, eax
    mov al, byte ptr [esp + 30]
    mov ebx, 0x10000
    .att_syntax prefix
    addl $game_math_invennum_11743,%eax
    .intel_syntax noprefix
    {store} mov edx, esi
    push eax
    {store} xor ecx, ecx
    {store} mov eax, edi
    call rotatesprite_
    add esp, 0x64
    pop ebp
    pop edi
    pop esi
    ret 4
game_flow_invennum_11769:
    cmp bl, 9
    jbe game_flow_invennum_11891
    push ecx
    push eax
    push 0
    {store} xor eax, eax
    push 0
    {store} mov al, dh
    push eax
    mov ebx, 0x10000
    mov dword ptr [esp + 112], eax
    push 0
    {store} xor eax, eax
    movzx ebp, dl
    mov al, byte ptr [esp + 24]
    push ebp
    .att_syntax prefix
    addl $game_math_invennum_11806,%eax
    .intel_syntax noprefix
    {store} xor ecx, ecx
    push eax
    {store} mov edx, esi
    mov eax, dword ptr [esp + 128]
    call rotatesprite_
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    mov ecx, dword ptr [esp + 108]
    push ecx
    {store} xor eax, eax
    push 0
    mov ebx, 0x10000
    mov al, byte ptr [esp + 25]
    push ebp
    .att_syntax prefix
    addl $game_math_invennum_11865,%eax
    .intel_syntax noprefix
    {store} mov edx, esi
    push eax
    {store} xor ecx, ecx
    {store} mov eax, edi
    call rotatesprite_
    add esp, 0x64
    pop ebp
    pop edi
    pop esi
    ret 4
game_flow_invennum_11891:
    push ecx
    push eax
    push 0
    {store} xor eax, eax
    push 0
    {store} mov al, dh
    push eax
    {store} xor eax, eax
    push 0
    {store} mov al, dl
    push eax
    {store} xor eax, eax
    mov al, byte ptr [esp + 28]
    mov ebx, 0x10000
    .att_syntax prefix
    addl $game_math_invennum_11920,%eax
    .intel_syntax noprefix
    {store} xor ecx, ecx
    push eax
    {store} mov edx, esi
    {store} mov eax, edi
    call rotatesprite_
    add esp, 0x64
    pop ebp
    pop edi
    pop esi
    ret 4
    {disp32} lea eax, dword ptr [eax]
weaponnum_:
    push esi
    push edi
    push ebp
    sub esp, 0x5c
    {store} mov ebp, edx
    mov dword ptr [esp + 84], ebx
    mov dword ptr [esp + 88], ecx
    mov ecx, 0x14
    {store} mov edi, esp
    mov esi, OFFSET FLAT:game_weaponnum_dabuf_initializer
    rep movsd dword ptr es:[edi], dword ptr [esi]
    mov edx, dword ptr [_ydim]
    dec edx
    push edx
    mov edx, dword ptr [_xdim]
    dec edx
    push edx
    cwde
    push 0
    .att_syntax prefix
    addl $game_math_weaponnum_12001,%eax
    .intel_syntax noprefix
    push 0
    movzx edi, byte ptr [esp + 128]
    push 0x8a
    {store} mov esi, ebx
    {store} xor ecx, ecx
    push 7
    lea edx, dword ptr [edi + -10]
    mov ebx, 0x10000
    push edx
    shl esi, 0x10
    push eax
    lea eax, dword ptr [ebp + -7]
    {store} mov edx, esi
    shl eax, 0x10
    call rotatesprite_
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0x8a
    push 0
    mov ebx, 0x10000
    {store} mov edx, esi
    push edi
    {store} xor ecx, ecx
    lea eax, dword ptr [ebp + -3]
    push 0xbcc
    shl eax, 0x10
    call rotatesprite_
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0x8a
    push 0
    mov ebx, 0x10000
    {store} mov edx, esi
    push edi
    {store} xor ecx, ecx
    lea eax, dword ptr [ebp + 9]
    push 0xbcd
    shl eax, 0x10
    call rotatesprite_
    cmp dword ptr [esp + 88], 0x63
    jle game_flow_weaponnum_12170
    mov dword ptr [esp + 88], 0x63
game_flow_weaponnum_12170:
    cmp dword ptr [esp + 108], 0x63
    jle game_flow_weaponnum_12185
    mov dword ptr [esp + 108], 0x63
game_flow_weaponnum_12185:
    mov edi, dword ptr [esp + 88]
    push edi
    push OFFSET FLAT:game_text_invennum_232
    lea eax, dword ptr [esp + 8]
    push eax
    lea edi, dword ptr [ebp + 4]
    call sprintf_
    shl edi, 0x10
    mov eax, dword ptr [_xdim]
    add esp, 0xc
    mov edx, dword ptr [_ydim]
    mov esi, dword ptr [esp + 84]
    mov ebx, dword ptr [esp + 88]
    dec eax
    dec edx
    shl esi, 0x10
    cmp ebx, 9
    jle game_flow_weaponnum_12354
    push edx
    push eax
    push 0
    push 0
    {store} xor eax, eax
    push 0x8a
    mov al, byte ptr [esp + 132]
    push 0
    mov dword ptr [esp + 104], eax
    push eax
    {store} xor eax, eax
    mov al, byte ptr [esp + 28]
    mov ebx, 0x10000
    .att_syntax prefix
    addl $game_math_weaponnum_12281,%eax
    .intel_syntax noprefix
    {store} xor ecx, ecx
    push eax
    {store} mov eax, ebp
    {store} mov edx, esi
    shl eax, 0x10
    call rotatesprite_
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0x8a
    push 0
    mov eax, dword ptr [esp + 104]
    push eax
    {store} xor eax, eax
    mov al, byte ptr [esp + 29]
    mov ebx, 0x10000
    .att_syntax prefix
    addl $game_math_weaponnum_12342,%eax
    .intel_syntax noprefix
    {store} mov edx, esi
    push eax
    {store} xor ecx, ecx
    jmp game_flow_weaponnum_12398
game_flow_weaponnum_12354:
    push edx
    push eax
    push 0
    push 0
    push 0x8a
    {store} xor eax, eax
    push 0
    mov al, byte ptr [esp + 136]
    push eax
    {store} xor eax, eax
    mov al, byte ptr [esp + 28]
    mov ebx, 0x10000
    .att_syntax prefix
    addl $game_math_weaponnum_12388,%eax
    .intel_syntax noprefix
    {store} xor ecx, ecx
    push eax
    {store} mov edx, esi
game_flow_weaponnum_12398:
    {store} mov eax, edi
    call rotatesprite_
    mov edx, dword ptr [esp + 108]
    push edx
    push OFFSET FLAT:game_text_invennum_232
    lea eax, dword ptr [esp + 8]
    push eax
    call sprintf_
    mov ebx, dword ptr [_xdim]
    mov edx, dword ptr [_ydim]
    add esp, 0xc
    lea eax, dword ptr [ebp + 13]
    mov esi, dword ptr [esp + 84]
    mov ecx, dword ptr [esp + 108]
    dec ebx
    dec edx
    shl eax, 0x10
    shl esi, 0x10
    cmp ecx, 9
    jle game_flow_weaponnum_12568
    push edx
    push ebx
    push 0
    push 0
    push 0x8a
    {store} xor edx, edx
    push 0
    movzx edi, byte ptr [esp + 136]
    mov dl, byte ptr [esp + 24]
    push edi
    add edx, 0xb92
    {store} xor ecx, ecx
    push edx
    mov ebx, 0x10000
    {store} mov edx, esi
    call rotatesprite_
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0x8a
    {store} xor eax, eax
    push 0
    mov ebx, 0x10000
    mov al, byte ptr [esp + 25]
    push edi
    .att_syntax prefix
    addl $game_math_weaponnum_12550,%eax
    .intel_syntax noprefix
    {store} mov edx, esi
    push eax
    lea eax, dword ptr [ebp + 17]
    {store} xor ecx, ecx
    shl eax, 0x10
    jmp game_flow_weaponnum_12613
game_flow_weaponnum_12568:
    push edx
    push ebx
    push 0
    push 0
    push 0x8a
    {store} xor edx, edx
    push 0
    mov dl, byte ptr [esp + 136]
    push edx
    {store} xor edx, edx
    mov dl, byte ptr [esp + 28]
    add edx, 0xb92
    {store} xor ecx, ecx
    push edx
    mov ebx, 0x10000
    {store} mov edx, esi
game_flow_weaponnum_12613:
    call rotatesprite_
    add esp, 0x5c
    pop ebp
    pop edi
    pop esi
    ret 8
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
    nop
weaponnum999_:
    push esi
    push edi
    push ebp
    sub esp, 0x68
    {store} mov ebp, edx
    mov dword ptr [esp + 88], ebx
    mov dword ptr [esp + 96], ecx
    mov ecx, 0x14
    {store} mov edi, esp
    mov esi, OFFSET FLAT:game_weaponnum999_dabuf_initializer
    rep movsd dword ptr es:[edi], dword ptr [esi]
    mov edx, dword ptr [_ydim]
    dec edx
    push edx
    mov edx, dword ptr [_xdim]
    dec edx
    push edx
    push 0
    push 0
    push 0x8a
    movzx edi, byte ptr [esp + 144]
    push 7
    lea edx, dword ptr [edi + -10]
    push edx
    and eax, 0xff
    {store} mov esi, ebx
    {store} xor ecx, ecx
    mov ebx, 0x10000
    .att_syntax prefix
    addl $game_math_weaponnum999_12723,%eax
    .intel_syntax noprefix
    shl esi, 0x10
    push eax
    lea eax, dword ptr [ebp + -7]
    {store} mov edx, esi
    shl eax, 0x10
    call rotatesprite_
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0x8a
    push 0
    mov ebx, 0x10000
    {store} mov edx, esi
    push edi
    {store} xor ecx, ecx
    lea eax, dword ptr [ebp + -4]
    push 0xbcc
    shl eax, 0x10
    call rotatesprite_
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0x8a
    push 0
    mov ebx, 0x10000
    {store} mov edx, esi
    push edi
    {store} xor ecx, ecx
    lea eax, dword ptr [ebp + 13]
    push 0xbcd
    shl eax, 0x10
    call rotatesprite_
    mov edx, dword ptr [esp + 96]
    push edx
    push OFFSET FLAT:game_text_invennum_232
    lea eax, dword ptr [esp + 8]
    lea ebx, dword ptr [ebp + 8]
    push eax
    shl ebx, 0x10
    call sprintf_
    {store} mov eax, ebp
    add esp, 0xc
    add eax, 4
    mov edx, dword ptr [_ydim]
    mov dword ptr [esp + 80], eax
    mov dword ptr [esp + 100], ebx
    mov ebx, dword ptr [esp + 80]
    dec edx
    shl ebx, 0x10
    mov eax, dword ptr [_xdim]
    mov dword ptr [esp + 92], ebx
    mov ebx, dword ptr [esp + 96]
    dec eax
    cmp ebx, 0x63
    {disp32} jle game_flow_weaponnum999_13079
    push edx
    push eax
    push 0
    push 0
    push 0x8a
    {store} xor eax, eax
    push 0
    mov ebx, 0x10000
    mov al, byte ptr [esp + 24]
    push edi
    .att_syntax prefix
    addl $game_math_weaponnum999_12951,%eax
    .intel_syntax noprefix
    {store} xor ecx, ecx
    push eax
    {store} mov eax, ebp
    {store} mov edx, esi
    shl eax, 0x10
    call rotatesprite_
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0x8a
    {store} xor eax, eax
    push 0
    mov ebx, 0x10000
    mov al, byte ptr [esp + 25]
    push edi
    .att_syntax prefix
    addl $game_math_weaponnum999_13008,%eax
    .intel_syntax noprefix
    {store} mov edx, esi
    push eax
    {store} xor ecx, ecx
    mov eax, dword ptr [esp + 124]
    call rotatesprite_
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0x8a
    {store} xor eax, eax
    push 0
    mov ebx, 0x10000
    mov al, byte ptr [esp + 26]
    push edi
    .att_syntax prefix
    addl $game_math_weaponnum999_13064,%eax
    .intel_syntax noprefix
    {store} mov edx, esi
    push eax
    {store} xor ecx, ecx
    {disp32} jmp game_flow_weaponnum999_13212
game_flow_weaponnum999_13079:
    cmp ebx, 9
    jle game_flow_weaponnum999_13177
    push edx
    push eax
    push 0
    push 0
    push 0x8a
    {store} xor eax, eax
    push 0
    mov ebx, 0x10000
    mov al, byte ptr [esp + 24]
    push edi
    .att_syntax prefix
    addl $game_math_weaponnum999_13109,%eax
    .intel_syntax noprefix
    {store} xor ecx, ecx
    push eax
    {store} mov edx, esi
    mov eax, dword ptr [esp + 124]
    call rotatesprite_
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0x8a
    {store} xor eax, eax
    push 0
    mov ebx, 0x10000
    mov al, byte ptr [esp + 25]
    push edi
    .att_syntax prefix
    addl $game_math_weaponnum999_13165,%eax
    .intel_syntax noprefix
    {store} mov edx, esi
    push eax
    {store} xor ecx, ecx
    jmp game_flow_weaponnum999_13212
game_flow_weaponnum999_13177:
    push edx
    push eax
    push 0
    push 0
    push 0x8a
    {store} xor eax, eax
    push 0
    mov ebx, 0x10000
    mov al, byte ptr [esp + 24]
    push edi
    .att_syntax prefix
    addl $game_math_weaponnum999_13202,%eax
    .intel_syntax noprefix
    {store} xor ecx, ecx
    push eax
    {store} mov edx, esi
game_flow_weaponnum999_13212:
    mov eax, dword ptr [esp + 132]
    call rotatesprite_
    mov esi, dword ptr [esp + 120]
    push esi
    push OFFSET FLAT:game_text_invennum_232
    lea eax, dword ptr [esp + 8]
    lea edi, dword ptr [ebp + 25]
    push eax
    shl edi, 0x10
    call sprintf_
    mov ebx, dword ptr [_xdim]
    mov edx, dword ptr [_ydim]
    add esp, 0xc
    lea eax, dword ptr [ebp + 21]
    mov esi, dword ptr [esp + 88]
    lea ecx, dword ptr [ebp + 17]
    dec ebx
    dec edx
    {store} mov ebp, eax
    shl esi, 0x10
    shl ebp, 0x10
    {store} mov eax, ecx
    mov ecx, dword ptr [esp + 120]
    shl eax, 0x10
    cmp ecx, 0x63
    {disp32} jle game_flow_weaponnum999_13482
    push edx
    push ebx
    push 0
    push 0
    {store} xor edx, edx
    push 0x8a
    mov dl, byte ptr [esp + 144]
    push 0
    mov dword ptr [esp + 108], edx
    push edx
    {store} xor edx, edx
    mov dl, byte ptr [esp + 28]
    add edx, 0xb92
    {store} xor ecx, ecx
    push edx
    mov ebx, 0x10000
    {store} mov edx, esi
    call rotatesprite_
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0x8a
    mov ebx, dword ptr [esp + 104]
    {store} xor eax, eax
    push 0
    {store} mov edx, esi
    mov al, byte ptr [esp + 25]
    push ebx
    .att_syntax prefix
    addl $game_math_weaponnum999_13395,%eax
    .intel_syntax noprefix
    {store} xor ecx, ecx
    push eax
    mov ebx, 0x10000
    {store} mov eax, ebp
    call rotatesprite_
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0x8a
    mov ecx, dword ptr [esp + 104]
    {store} xor eax, eax
    push 0
    mov ebx, 0x10000
    mov al, byte ptr [esp + 26]
    push ecx
    .att_syntax prefix
    addl $game_math_weaponnum999_13456,%eax
    .intel_syntax noprefix
    {store} mov edx, esi
    push eax
    {store} xor ecx, ecx
    {store} mov eax, edi
    call rotatesprite_
    add esp, 0x68
    pop ebp
    pop edi
    pop esi
    ret 8
game_flow_weaponnum999_13482:
    cmp ecx, 9
    jle game_flow_weaponnum999_13587
    push edx
    push ebx
    push 0
    push 0
    push 0x8a
    {store} xor edx, edx
    push 0
    movzx edi, byte ptr [esp + 148]
    mov dl, byte ptr [esp + 24]
    push edi
    add edx, 0xb92
    {store} xor ecx, ecx
    push edx
    mov ebx, 0x10000
    {store} mov edx, esi
    call rotatesprite_
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0x8a
    {store} xor eax, eax
    push 0
    mov ebx, 0x10000
    mov al, byte ptr [esp + 25]
    push edi
    .att_syntax prefix
    addl $game_math_weaponnum999_13573,%eax
    .intel_syntax noprefix
    {store} mov edx, esi
    push eax
    {store} xor ecx, ecx
    {store} mov eax, ebp
    jmp game_flow_weaponnum999_13633
game_flow_weaponnum999_13587:
    push edx
    push ebx
    push 0
    push 0
    push 0x8a
    {store} xor eax, eax
    push 0
    mov al, byte ptr [esp + 148]
    push eax
    {store} xor eax, eax
    mov al, byte ptr [esp + 28]
    {store} xor ecx, ecx
    .att_syntax prefix
    addl $game_math_weaponnum999_13618,%eax
    .intel_syntax noprefix
    {store} mov edx, esi
    push eax
    mov ebx, 0x10000
    {store} mov eax, edi
game_flow_weaponnum999_13633:
    call rotatesprite_
    add esp, 0x68
    pop ebp
    pop edi
    pop esi
    ret 8
    nop
weapon_amounts_:
    push esi
    push edi
    push ebp
    sub esp, 8
    {store} mov esi, eax
    {store} mov edi, edx
    {store} mov ebp, ebx
    mov dword ptr [esp + 4], ecx
    movsx eax, word ptr [eax + 680]
    mov dword ptr [esp], eax
    test byte ptr [esp + 4], 4
    {disp32} je game_flow_weapon_amounts_13860
    cmp ecx, -1
    je game_flow_weapon_amounts_13809
    mov ecx, 0xc8
    mov eax, 0xb8
    mov ebx, dword ptr [_ydim]
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0x6c
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0xc8
    push eax
    mov ebx, dword ptr [_ydim]
    mov eax, 0xb2
    imul ebx
    idiv ecx
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0x60
    imul ebx
    idiv ecx
    push eax
    push 0xda
    push 0
    push 4
    mov ebx, 0x10000
    mov edx, 0xa60000
    push 0x99e
    {store} xor ecx, ecx
    {store} xor eax, eax
    call rotatesprite_
game_flow_weapon_amounts_13809:
    cmp dword ptr [esp], 1
    sete al
    mov ah, 0x14
    mul ah
    mov ah, 0xc
    sub ah, al
    {store} mov al, ah
    mov ecx, dword ptr [_max_ammo_amount + 0x4]
    and eax, 0xff
    {store} mov ebx, ebp
    push eax
    {store} mov edx, edi
    mov eax, 1
    push ecx
    movsx ecx, word ptr [esi + 654]
    call weaponnum999_
game_flow_weapon_amounts_13860:
    test byte ptr [esp + 4], 8
    {disp32} je game_flow_weapon_amounts_14068
    cmp dword ptr [esp + 4], -1
    je game_flow_weapon_amounts_13997
    mov ecx, 0xc8
    mov eax, 0xbe
    mov ebx, dword ptr [_ydim]
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0x6c
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0xc8
    push eax
    mov ebx, dword ptr [_ydim]
    mov eax, 0xb8
    imul ebx
    idiv ecx
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0x60
    imul ebx
    idiv ecx
    push eax
    push 0xda
    push 0
    push 4
    mov ebx, 0x10000
    mov edx, 0xa60000
    push 0x99e
    {store} xor ecx, ecx
    {store} xor eax, eax
    call rotatesprite_
game_flow_weapon_amounts_13997:
    cmp byte ptr [esi + 1335], 0
    sete al
    mov ah, 9
    mul ah
    {store} mov dl, al
    mov ebx, dword ptr [esp]
    add dl, 0xc
    cmp ebx, 2
    sete al
    mov ah, 0x12
    mul ah
    sub dl, al
    {store} mov al, dl
    mov ecx, dword ptr [_max_ammo_amount + 0x8]
    and eax, 0xff
    lea ebx, dword ptr [ebp + 6]
    push eax
    {store} mov edx, edi
    mov eax, 2
    push ecx
    movsx ecx, word ptr [esi + 656]
    call weaponnum999_
game_flow_weapon_amounts_14068:
    test byte ptr [esp + 4], 0x10
    {disp32} je game_flow_weapon_amounts_14276
    cmp dword ptr [esp + 4], -1
    je game_flow_weapon_amounts_14205
    mov ecx, 0xc8
    mov eax, 0xc4
    mov ebx, dword ptr [_ydim]
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0x6c
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0xc8
    push eax
    mov ebx, dword ptr [_ydim]
    mov eax, 0xbe
    imul ebx
    idiv ecx
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0x60
    imul ebx
    idiv ecx
    push eax
    push 0xda
    push 0
    push 4
    mov ebx, 0x10000
    mov edx, 0xa60000
    push 0x99e
    {store} xor ecx, ecx
    {store} xor eax, eax
    call rotatesprite_
game_flow_weapon_amounts_14205:
    cmp byte ptr [esi + 1336], 0
    sete al
    mov ah, 9
    mul ah
    {store} mov dl, al
    mov ebx, dword ptr [esp]
    add dl, 0xc
    cmp ebx, 3
    sete al
    mov ah, 0x12
    mul ah
    sub dl, al
    {store} mov al, dl
    mov ecx, dword ptr [_max_ammo_amount + 0xc]
    and eax, 0xff
    lea ebx, dword ptr [ebp + 12]
    push eax
    {store} mov edx, edi
    mov eax, 3
    push ecx
    movsx ecx, word ptr [esi + 658]
    call weaponnum999_
game_flow_weapon_amounts_14276:
    test byte ptr [esp + 4], 0x20
    {disp32} je game_flow_weapon_amounts_14484
    cmp dword ptr [esp + 4], -1
    je game_flow_weapon_amounts_14413
    mov ecx, 0xc8
    mov eax, 0xb8
    mov ebx, dword ptr [_ydim]
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0x8f
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0xc8
    push eax
    mov ebx, dword ptr [_ydim]
    mov eax, 0xb2
    imul ebx
    idiv ecx
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0x87
    imul ebx
    idiv ecx
    push eax
    push 0xda
    push 0
    push 4
    mov ebx, 0x10000
    mov edx, 0xa60000
    push 0x99e
    {store} xor ecx, ecx
    {store} xor eax, eax
    call rotatesprite_
game_flow_weapon_amounts_14413:
    cmp byte ptr [esi + 1337], 0
    sete al
    mov ah, 9
    mul ah
    {store} mov dl, al
    mov ebx, dword ptr [esp]
    add dl, 0xc
    cmp ebx, 4
    sete al
    mov ah, 0x13
    mul ah
    sub dl, al
    {store} mov al, dl
    mov ecx, dword ptr [_max_ammo_amount + 0x10]
    and eax, 0xff
    lea edx, dword ptr [edi + 39]
    push eax
    {store} mov ebx, ebp
    mov eax, 4
    push ecx
    movsx ecx, word ptr [esi + 660]
    call weaponnum_
game_flow_weapon_amounts_14484:
    test byte ptr [esp + 4], 0x40
    {disp32} je game_flow_weapon_amounts_14715
    cmp dword ptr [esp + 4], -1
    je game_flow_weapon_amounts_14621
    mov ecx, 0xc8
    mov eax, 0xbe
    mov ebx, dword ptr [_ydim]
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0x8f
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0xc8
    push eax
    mov ebx, dword ptr [_ydim]
    mov eax, 0xb8
    imul ebx
    idiv ecx
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0x87
    imul ebx
    idiv ecx
    push eax
    push 0xda
    push 0
    push 4
    mov ebx, 0x10000
    mov edx, 0xa60000
    push 0x99e
    {store} xor ecx, ecx
    {store} xor eax, eax
    call rotatesprite_
game_flow_weapon_amounts_14621:
    cmp word ptr [esi + 662], 0
    sete al
    cmp byte ptr [esi + 1338], 0
    sete ah
    or al, ah
    mov ah, 9
    mul ah
    {store} mov dl, al
    mov ebx, dword ptr [esp]
    add dl, 0xc
    cmp ebx, 5
    je game_flow_weapon_amounts_14666
    cmp ebx, 0xa
    jne game_flow_weapon_amounts_14670
game_flow_weapon_amounts_14666:
    mov al, 1
    jmp game_flow_weapon_amounts_14672
game_flow_weapon_amounts_14670:
    xor al, al
game_flow_weapon_amounts_14672:
    mov ah, 0x13
    mul ah
    sub dl, al
    {store} mov al, dl
    and eax, 0xff
    lea ebx, dword ptr [ebp + 6]
    push eax
    mov eax, dword ptr [_max_ammo_amount + 0x14]
    lea edx, dword ptr [edi + 39]
    push eax
    movsx ecx, word ptr [esi + 662]
    mov eax, 5
    call weaponnum_
game_flow_weapon_amounts_14715:
    test byte ptr [esp + 4], 0x80
    {disp32} je game_flow_weapon_amounts_14924
    cmp dword ptr [esp + 4], -1
    je game_flow_weapon_amounts_14852
    mov ecx, 0xc8
    mov eax, 0xc4
    mov ebx, dword ptr [_ydim]
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0x8f
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0xc8
    push eax
    mov ebx, dword ptr [_ydim]
    mov eax, 0xbe
    imul ebx
    idiv ecx
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0x87
    imul ebx
    idiv ecx
    push eax
    push 0xda
    push 0
    push 4
    mov ebx, 0x10000
    mov edx, 0xa60000
    push 0x99e
    {store} xor ecx, ecx
    {store} xor eax, eax
    call rotatesprite_
game_flow_weapon_amounts_14852:
    cmp byte ptr [esi + 1339], 0
    sete al
    mov ah, 9
    mul ah
    {store} mov dl, al
    mov ebx, dword ptr [esp]
    add dl, 0xc
    cmp ebx, 6
    sete al
    mov ah, 0x12
    mul ah
    sub dl, al
    {store} mov al, dl
    mov ecx, dword ptr [_max_ammo_amount + 0x18]
    and eax, 0xff
    lea ebx, dword ptr [ebp + 12]
    push eax
    lea edx, dword ptr [edi + 39]
    mov eax, 6
    push ecx
    movsx ecx, word ptr [esi + 664]
    call weaponnum_
game_flow_weapon_amounts_14924:
    test byte ptr [esp + 5], 1
    {disp32} je game_flow_weapon_amounts_15132
    cmp dword ptr [esp + 4], -1
    je game_flow_weapon_amounts_15061
    mov ecx, 0xc8
    mov eax, 0xb8
    mov ebx, dword ptr [_ydim]
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0xae
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0xc8
    push eax
    mov ebx, dword ptr [_ydim]
    mov eax, 0xb2
    imul ebx
    idiv ecx
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0xa6
    imul ebx
    idiv ecx
    push eax
    push 0xda
    push 0
    push 4
    mov ebx, 0x10000
    mov edx, 0xa60000
    push 0x99e
    {store} xor ecx, ecx
    {store} xor eax, eax
    call rotatesprite_
game_flow_weapon_amounts_15061:
    cmp byte ptr [esi + 1340], 0
    sete al
    mov ah, 9
    mul ah
    {store} mov dl, al
    mov ebx, dword ptr [esp]
    add dl, 0xc
    cmp ebx, 7
    sete al
    mov ah, 0x12
    mul ah
    sub dl, al
    {store} mov al, dl
    mov ecx, dword ptr [_max_ammo_amount + 0x1c]
    and eax, 0xff
    lea edx, dword ptr [edi + 70]
    push eax
    {store} mov ebx, ebp
    mov eax, 7
    push ecx
    movsx ecx, word ptr [esi + 666]
    call weaponnum_
game_flow_weapon_amounts_15132:
    test byte ptr [esp + 5], 2
    {disp32} je game_flow_weapon_amounts_15341
    cmp dword ptr [esp + 4], -1
    je game_flow_weapon_amounts_15269
    mov ecx, 0xc8
    mov eax, 0xbe
    mov ebx, dword ptr [_ydim]
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0xae
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0xc8
    push eax
    mov ebx, dword ptr [_ydim]
    mov eax, 0xb8
    imul ebx
    idiv ecx
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0xa6
    imul ebx
    idiv ecx
    push eax
    push 0xda
    push 0
    push 4
    mov ebx, 0x10000
    mov edx, 0xa60000
    push 0x99e
    {store} xor ecx, ecx
    {store} xor eax, eax
    call rotatesprite_
game_flow_weapon_amounts_15269:
    cmp byte ptr [esi + 1341], 0
    sete al
    mov ah, 9
    mul ah
    {store} mov dl, al
    mov ebx, dword ptr [esp]
    add dl, 0xc
    cmp ebx, 8
    sete al
    mov ah, 0x12
    mul ah
    sub dl, al
    {store} mov al, dl
    mov ecx, dword ptr [_max_ammo_amount + 0x20]
    and eax, 0xff
    lea ebx, dword ptr [ebp + 6]
    push eax
    lea edx, dword ptr [edi + 70]
    mov eax, 8
    push ecx
    movsx ecx, word ptr [esi + 668]
    call weaponnum_
game_flow_weapon_amounts_15341:
    test byte ptr [esp + 6], 1
    {disp32} je game_flow_weapon_amounts_15550
    cmp dword ptr [esp + 4], -1
    je game_flow_weapon_amounts_15478
    mov ecx, 0xc8
    mov eax, 0xc4
    mov ebx, dword ptr [_ydim]
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0xae
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0xc8
    push eax
    mov ebx, dword ptr [_ydim]
    mov eax, 0xbe
    imul ebx
    idiv ecx
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0xa6
    imul ebx
    idiv ecx
    push eax
    push 0xda
    push 0
    push 4
    mov ebx, 0x10000
    mov edx, 0xa60000
    push 0x99e
    {store} xor ecx, ecx
    {store} xor eax, eax
    call rotatesprite_
game_flow_weapon_amounts_15478:
    cmp byte ptr [esi + 1342], 0
    sete al
    mov ah, 9
    mul ah
    {store} mov dl, al
    mov ebx, dword ptr [esp]
    add dl, 0xc
    cmp ebx, 9
    sete al
    mov ah, 0x12
    mul ah
    sub dl, al
    {store} mov al, dl
    mov ecx, dword ptr [_max_ammo_amount + 0x24]
    and eax, 0xff
    lea ebx, dword ptr [ebp + 12]
    push eax
    lea edx, dword ptr [edi + 70]
    mov eax, 0xffffffff
    push ecx
    movsx ecx, word ptr [esi + 670]
    call weaponnum_
game_flow_weapon_amounts_15550:
    add esp, 8
    pop ebp
    pop edi
    pop esi
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp8} lea edx, dword ptr [edx]
    {load} mov ebx, ebx
digitalnumber_:
    push esi
    push edi
    push ebp
    sub esp, 0x1c
    {store} mov ebp, eax
    mov dword ptr [esp + 12], edx
    mov byte ptr [esp + 24], cl
    {store} mov eax, ebx
    mov ebx, 0xa
    {store} mov edx, esp
    call ltoa_
    {store} mov eax, esp
    {store} xor edi, edi
    call strlen_
    mov dword ptr [esp + 20], eax
    {store} xor esi, esi
    mov edx, dword ptr [esp + 20]
    jmp game_flow_digitalnumber_15645
game_flow_digitalnumber_15619:
    movsx eax, si
    mov al, byte ptr [esp + eax]
    xor ah, ah
    .att_syntax prefix
    addl $game_math_digitalnumber_15627,%eax
    .intel_syntax noprefix
    cwde
    mov ax, word ptr [eax*2 + _tilesizx]
    inc eax
    inc esi
    {store} add edi, eax
game_flow_digitalnumber_15645:
    {store} cmp si, dx
    jl game_flow_digitalnumber_15619
    movsx eax, di
    sar eax, 1
    {store} sub ebp, eax
    {store} xor esi, esi
    {store} mov eax, ebp
    {store} xor edi, edi
    mov dword ptr [esp + 16], eax
    cmp si, word ptr [esp + 20]
    jl game_flow_digitalnumber_15683
    add esp, 0x1c
    pop ebp
    pop edi
    pop esi
    ret 4
game_flow_digitalnumber_15683:
    movsx eax, si
    mov al, byte ptr [esp + eax]
    xor ah, ah
    {store} mov edx, eax
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    movsx ebx, di
    {store} xor ecx, ecx
    push 0
    add edx, 0x978
    {store} xor eax, eax
    push 0
    mov al, byte ptr [esp + 60]
    movsx ebp, dx
    push eax
    mov edx, dword ptr [esp + 32]
    {store} xor eax, eax
    push 0
    mov al, byte ptr [esp + 48]
    shl edx, 0x10
    push eax
    movsx eax, word ptr [esp + 44]
    push ebp
    {store} add eax, ebx
    mov ebx, 0x10000
    shl eax, 0x10
    call rotatesprite_
    mov ax, word ptr [ebp*2 + _tilesizx]
    inc eax
    inc esi
    {store} add edi, eax
    cmp si, word ptr [esp + 20]
    jl game_flow_digitalnumber_15683
    add esp, 0x1c
    pop ebp
    pop edi
    pop esi
    ret 4
    {disp32} lea eax, dword ptr [eax]
    {disp8} lea edx, dword ptr [edx]
    {load} mov ebx, ebx
displayinventory_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    sub esp, 8
    {store} mov ebp, eax
    {store} xor edx, edx
    mov bx, word ptr [eax + 1276]
    mov dword ptr [esp + 4], edx
    test bx, bx
    setg al
    xor ah, ah
    shl eax, 3
    mov word ptr [esp], ax
    test byte ptr [esp], 8
    je game_flow_displayinventory_15862
    mov ecx, 1
    mov dword ptr [esp + 4], ecx
game_flow_displayinventory_15862:
    cmp word ptr [ebp + 1274], 0
    setg al
    xor ah, ah
    mov edi, dword ptr [esp]
    shl eax, 5
    {store} or edi, eax
    mov word ptr [esp], di
    test byte ptr [esp], 0x20
    je game_flow_displayinventory_15897
    inc dword ptr [esp + 4]
game_flow_displayinventory_15897:
    cmp word ptr [ebp + 1278], 0
    setg al
    xor ah, ah
    mov ebx, dword ptr [esp]
    {store} add eax, eax
    {store} or ebx, eax
    mov word ptr [esp], bx
    test byte ptr [esp], 2
    je game_flow_displayinventory_15931
    inc dword ptr [esp + 4]
game_flow_displayinventory_15931:
    cmp word ptr [ebp + 688], 0
    setg al
    xor ah, ah
    mov edi, dword ptr [esp]
    shl eax, 2
    {store} or edi, eax
    mov word ptr [esp], di
    test byte ptr [esp], 4
    je game_flow_displayinventory_15966
    inc dword ptr [esp + 4]
game_flow_displayinventory_15966:
    cmp word ptr [ebp + 718], 0
    setg al
    {store} xor edx, edx
    {store} mov dl, al
    movsx eax, word ptr [esp]
    {store} or eax, edx
    mov word ptr [esp], ax
    test byte ptr [esp], 1
    je game_flow_displayinventory_16001
    inc dword ptr [esp + 4]
game_flow_displayinventory_16001:
    cmp word ptr [ebp + 744], 0
    setg al
    xor ah, ah
    mov esi, dword ptr [esp]
    shl eax, 4
    {store} or esi, eax
    mov word ptr [esp], si
    test byte ptr [esp], 0x10
    je game_flow_displayinventory_16036
    inc dword ptr [esp + 4]
game_flow_displayinventory_16036:
    cmp word ptr [ebp + 1296], 0
    setg al
    xor ah, ah
    mov ebx, dword ptr [esp]
    shl eax, 6
    {store} or ebx, eax
    mov word ptr [esp], bx
    test byte ptr [esp], 0x40
    je game_flow_displayinventory_16071
    inc dword ptr [esp + 4]
game_flow_displayinventory_16071:
    imul esi, dword ptr [esp + 4], 0xb
    mov eax, 0xa0
    {store} sub eax, esi
    {store} mov esi, eax
    {store} xor eax, eax
    mov edx, dword ptr [_ud + 0x5e2]
    mov dword ptr [esp + 4], eax
    cmp edx, 4
    jle game_flow_displayinventory_16140
    mov dx, word ptr [_ud + 0x590]
    mov edi, 0xa0
    cmp dx, 1
    jle game_flow_displayinventory_16125
    mov edi, 0x9c
game_flow_displayinventory_16125:
    cmp word ptr [_ud + 0x590], 4
    jle game_flow_displayinventory_16145
    sub edi, 4
    jmp game_flow_displayinventory_16145
game_flow_displayinventory_16140:
    mov edi, 0xb4
game_flow_displayinventory_16145:
    cmp dword ptr [_ud + 0x5e2], 4
    jne game_flow_displayinventory_16157
    add esi, 0x38
game_flow_displayinventory_16157:
    mov ecx, dword ptr [esp + 4]
    cmp cx, 9
    {disp32} jg game_flow_displayinventory_16794
    mov eax, 1
    movsx ecx, cx
    movsx edx, word ptr [esp]
    shl eax, cl
    test edx, eax
    {disp32} je game_flow_displayinventory_16785
    {store} and eax, edx
    cmp eax, 8
    jb game_flow_displayinventory_16245
    {disp32} jbe game_flow_displayinventory_16462
    cmp eax, 0x20
    jb game_flow_displayinventory_16231
    {disp32} jbe game_flow_displayinventory_16577
    cmp eax, 0x40
    {disp32} je game_flow_displayinventory_16633
    {disp32} jmp game_flow_displayinventory_16696
game_flow_displayinventory_16231:
    cmp eax, 0x10
    {disp32} je game_flow_displayinventory_16521
    {disp32} jmp game_flow_displayinventory_16696
game_flow_displayinventory_16245:
    cmp eax, 2
    jb game_flow_displayinventory_16266
    jbe game_flow_displayinventory_16334
    cmp eax, 4
    {disp32} je game_flow_displayinventory_16397
    {disp32} jmp game_flow_displayinventory_16696
game_flow_displayinventory_16266:
    cmp eax, 1
    {disp32} jne game_flow_displayinventory_16696
    mov ecx, dword ptr [_windowy2]
    push ecx
    mov eax, dword ptr [_windowx2]
    push eax
    mov edx, dword ptr [_windowy1]
    push edx
    mov ebx, dword ptr [_windowx1]
    push ebx
    {store} xor ecx, ecx
    push 0x12
    movsx eax, si
    push 0
    movsx edx, di
    push 0
    shl eax, 0x10
    mov ebx, 0x10000
    push 0x99c
    {disp32} jmp game_flow_displayinventory_16688
game_flow_displayinventory_16334:
    mov ecx, dword ptr [_windowy2]
    push ecx
    mov eax, dword ptr [_windowx2]
    push eax
    mov edx, dword ptr [_windowy1]
    push edx
    mov ebx, dword ptr [_windowx1]
    {store} xor ecx, ecx
    push ebx
    movsx eax, si
    push 0x12
    movsx edx, di
    push 0
    inc eax
    mov ebx, 0x10000
    push 0
    shl edx, 0x10
    push 0x9a5
    shl eax, 0x10
    {disp32} jmp game_flow_displayinventory_16691
game_flow_displayinventory_16397:
    mov ecx, dword ptr [_windowy2]
    push ecx
    mov eax, dword ptr [_windowx2]
    push eax
    mov edx, dword ptr [_windowy1]
    push edx
    mov ebx, dword ptr [_windowx1]
    {store} xor ecx, ecx
    push ebx
    movsx eax, si
    push 0x12
    movsx edx, di
    push 0
    add eax, 2
    mov ebx, 0x10000
    push 0
    shl edx, 0x10
    push 0x9a6
    shl eax, 0x10
    {disp32} jmp game_flow_displayinventory_16691
game_flow_displayinventory_16462:
    mov ecx, dword ptr [_windowy2]
    push ecx
    mov eax, dword ptr [_windowx2]
    push eax
    mov edx, dword ptr [_windowy1]
    push edx
    mov ebx, dword ptr [_windowx1]
    push ebx
    {store} xor ecx, ecx
    push 0x12
    movsx eax, si
    push 0
    movsx edx, di
    push 0
    shl eax, 0x10
    mov ebx, 0x10000
    push 0x9a3
    {disp32} jmp game_flow_displayinventory_16688
game_flow_displayinventory_16521:
    mov ecx, dword ptr [_windowy2]
    push ecx
    mov eax, dword ptr [_windowx2]
    push eax
    mov edx, dword ptr [_windowy1]
    push edx
    mov ebx, dword ptr [_windowx1]
    push ebx
    {store} xor ecx, ecx
    push 0x12
    movsx eax, si
    push 0
    movsx edx, di
    push 0
    shl eax, 0x10
    mov ebx, 0x10000
    push 0x99d
    jmp game_flow_displayinventory_16688
game_flow_displayinventory_16577:
    mov ecx, dword ptr [_windowy2]
    push ecx
    mov eax, dword ptr [_windowx2]
    push eax
    mov edx, dword ptr [_windowy1]
    push edx
    mov ebx, dword ptr [_windowx1]
    push ebx
    {store} xor ecx, ecx
    push 0x12
    movsx eax, si
    push 0
    movsx edx, di
    push 0
    shl eax, 0x10
    mov ebx, 0x10000
    push 0x9a4
    jmp game_flow_displayinventory_16688
game_flow_displayinventory_16633:
    mov ecx, dword ptr [_windowy2]
    push ecx
    mov eax, dword ptr [_windowx2]
    push eax
    mov edx, dword ptr [_windowy1]
    push edx
    mov ebx, dword ptr [_windowx1]
    {store} xor ecx, ecx
    push ebx
    movsx eax, si
    push 0x12
    movsx edx, di
    push 0
    shl eax, 0x10
    push 0
    mov ebx, 0x10000
    dec edx
    push 0x99f
game_flow_displayinventory_16688:
    shl edx, 0x10
game_flow_displayinventory_16691:
    call rotatesprite_
game_flow_displayinventory_16696:
    movsx edx, word ptr [esp + 4]
    {store} xor eax, eax
    inc edx
    mov al, byte ptr [ebp + 1322]
    add esi, 0x16
    {store} cmp eax, edx
    jne game_flow_displayinventory_16785
    mov ecx, dword ptr [_windowy2]
    push ecx
    mov eax, dword ptr [_windowx2]
    push eax
    mov edx, dword ptr [_windowy1]
    push edx
    mov ebx, dword ptr [_windowx1]
    mov ecx, 0x400
    push ebx
    movsx eax, si
    push 0x12
    movsx edx, di
    sub eax, 2
    push 0
    mov ebx, 0x10000
    add edx, 0x13
    push -32
    shl eax, 0x10
    push 0x14
    shl edx, 0x10
    call rotatesprite_
game_flow_displayinventory_16785:
    inc dword ptr [esp + 4]
    {disp32} jmp game_flow_displayinventory_16157
game_flow_displayinventory_16794:
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
displayfragbar_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    sub esp, 8
    mov ax, word ptr [_connecthead]
    {store} xor esi, esi
    jmp game_flow_displayfragbar_16855
game_flow_displayfragbar_16835:
    {store} cmp si, dx
    jge game_flow_displayfragbar_16842
    {store} mov esi, edx
game_flow_displayfragbar_16842:
    movsx eax, word ptr [esp + 4]
    mov ax, word ptr [eax*2 + _connectpoint2]
game_flow_displayfragbar_16855:
    mov word ptr [esp + 4], ax
    mov edx, dword ptr [esp + 4]
    test dx, dx
    jge game_flow_displayfragbar_16835
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0xda
    push 0
    push 0
    mov ebx, 0x10040
    {store} xor ecx, ecx
    push 0x9a1
    {store} xor edx, edx
    {store} xor eax, eax
    call rotatesprite_
    cmp si, 4
    jl game_flow_displayfragbar_16977
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0xda
    push 0
    push 0
    mov ebx, 0x10040
    mov edx, 0x80000
    push 0x9a1
    {store} xor ecx, ecx
    mov eax, 0x13f
    call rotatesprite_
game_flow_displayfragbar_16977:
    cmp si, 8
    jl game_flow_displayfragbar_17037
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0xda
    push 0
    push 0
    mov ebx, 0x10040
    mov edx, 0x100000
    push 0x9a1
    {store} xor ecx, ecx
    mov eax, 0x13f
    call rotatesprite_
game_flow_displayfragbar_17037:
    cmp si, 0xc
    jl game_flow_displayfragbar_17097
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0xda
    push 0
    push 0
    mov ebx, 0x10040
    mov edx, 0x180000
    push 0x9a1
    {store} xor ecx, ecx
    mov eax, 0x13f
    call rotatesprite_
game_flow_displayfragbar_17097:
    mov ax, word ptr [_connecthead]
    {disp32} jmp game_flow_displayfragbar_17270
game_flow_displayfragbar_17108:
    mov al, byte ptr [esp + 4]
    and al, 7
    add al, 9
    movzx edi, al
    {store} mov eax, ecx
    xor ah, ch
    and al, 0x1c
    movsx esi, ax
    {store} mov eax, ecx
    push 0x9a
    xor ah, ch
    movsx ebp, cx
    and al, 3
    {store} mov ebx, ebp
    movsx edx, ax
    shl ebx, 5
    {disp32} lea eax, dword ptr [edx*8]
    add ebx, OFFSET FLAT:_ud + 0x9
    {store} add eax, edx
    {store} add esi, esi
    {disp32} lea eax, dword ptr [eax*8]
    add esi, 2
    {store} add eax, edx
    {store} mov ecx, edi
    mov dword ptr [esp + 4], eax
    {store} mov edx, esi
    add eax, 0x15
    call minitext_
    imul eax, ebp, 0x552
    movsx edx, word ptr [eax + _ps + 0x2a4]
    movsx eax, word ptr [eax + _ps + 0x2a6]
    {store} sub edx, eax
    push edx
    push OFFSET FLAT:game_text_displayfragbar_236
    push OFFSET FLAT:_tempbuf
    call sprintf_
    add esp, 0xc
    mov ebx, OFFSET FLAT:_tempbuf
    {store} mov ecx, edi
    push 0x9a
    mov eax, dword ptr [esp + 4]
    {store} mov edx, esi
    add eax, 0x43
    call minitext_
    mov ax, word ptr [ebp*2 + _connectpoint2]
game_flow_displayfragbar_17270:
    mov word ptr [esp + 4], ax
    mov ecx, dword ptr [esp + 4]
    test cx, cx
    {disp32} jge game_flow_displayfragbar_17108
    add esp, 8
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {load} mov eax, eax
game_switch_coolgaugetext_17300:
    # Real compiler switch table: 28 named private destinations
    .long game_flow_coolgaugetext_18047
    .long game_flow_coolgaugetext_18056
    .long game_flow_coolgaugetext_18065
    .long game_flow_coolgaugetext_18074
    .long game_flow_coolgaugetext_18083
    .long game_flow_coolgaugetext_18092
    .long game_flow_coolgaugetext_18101
game_switch_view_17328: # actual interior typed table view
    .long game_flow_coolgaugetext_18260
    .long game_flow_coolgaugetext_18272
    .long game_flow_coolgaugetext_18290
    .long game_flow_coolgaugetext_18327
    .long game_flow_coolgaugetext_18356
    .long game_flow_coolgaugetext_18391
    .long game_flow_coolgaugetext_18406
game_switch_view_17356: # actual interior typed table view
    .long game_flow_coolgaugetext_20958
    .long game_flow_coolgaugetext_20967
    .long game_flow_coolgaugetext_20976
    .long game_flow_coolgaugetext_20985
    .long game_flow_coolgaugetext_20994
    .long game_flow_coolgaugetext_21003
    .long game_flow_coolgaugetext_21012
game_switch_view_17384: # actual interior typed table view
    .long game_flow_coolgaugetext_21356
    .long game_flow_coolgaugetext_21365
    .long game_flow_coolgaugetext_21380
    .long game_flow_coolgaugetext_21404
    .long game_flow_coolgaugetext_21419
    .long game_flow_coolgaugetext_21440
    .long game_flow_coolgaugetext_21455
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
coolgaugetext_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    {store} mov ebp, esp
    sub esp, 0x18
    {store} mov edx, eax
    cwde
    imul eax, eax, 0x552
    mov esi, OFFSET FLAT:_ps
    {store} add esi, eax
    cmp dword ptr [esi + 556], 0
    jle game_flow_coolgaugetext_17467
    {store} mov eax, esi
    call displayinventory_
game_flow_coolgaugetext_17467:
    movsx eax, dx
    imul eax, eax, 0x552
    test byte ptr [eax + _ps + 0x516], 1
    je game_flow_coolgaugetext_17511
    mov ecx, dword ptr [_current_menu]
    cmp ecx, 0x190
    jl game_flow_coolgaugetext_17511
    cmp ecx, 0x195
    {disp32} jle game_flow_coolgaugetext_21502
game_flow_coolgaugetext_17511:
    mov ebx, dword ptr [_ud + 0x5e2]
    cmp ebx, 4
    {disp32} jl game_flow_coolgaugetext_21502
    cmp word ptr [_ud + 0x590], 1
    {disp32} jle game_flow_coolgaugetext_17697
    cmp dword ptr [_ud + 0x5de], 1
    {disp32} je game_flow_coolgaugetext_17697
    cmp byte ptr [_pus], 0
    je game_flow_coolgaugetext_17569
    call displayfragbar_
    jmp game_flow_coolgaugetext_17635
game_flow_coolgaugetext_17569:
    movsx eax, word ptr [_connecthead]
    jmp game_flow_coolgaugetext_17625
game_flow_coolgaugetext_17578:
    {store} mov eax, edx
    imul edx, edx, 0x552
    {store} add eax, eax
    mov cx, word ptr [eax + _sbar]
    cmp cx, word ptr [edx + _ps + 0x2a4]
    je game_flow_coolgaugetext_17618
    call displayfragbar_
    movsx eax, word ptr [_connecthead]
    jmp game_flow_coolgaugetext_17687
game_flow_coolgaugetext_17618:
    movsx eax, word ptr [eax + _connectpoint2]
game_flow_coolgaugetext_17625:
    mov dword ptr [ebp + -8], eax
    mov edx, dword ptr [ebp + -8]
    test edx, edx
    jge game_flow_coolgaugetext_17578
game_flow_coolgaugetext_17635:
    movsx eax, word ptr [_connecthead]
    jmp game_flow_coolgaugetext_17687
game_flow_coolgaugetext_17644:
    movsx eax, word ptr [_myconnectindex]
    {store} cmp eax, edi
    je game_flow_coolgaugetext_17676
    imul eax, edi, 0x552
    mov ax, word ptr [eax + _ps + 0x2a4]
    mov word ptr [edi*2 + _sbar], ax
game_flow_coolgaugetext_17676:
    mov eax, dword ptr [ebp + -8]
    movsx eax, word ptr [eax*2 + _connectpoint2]
game_flow_coolgaugetext_17687:
    mov dword ptr [ebp + -8], eax
    mov edi, dword ptr [ebp + -8]
    test edi, edi
    jge game_flow_coolgaugetext_17644
game_flow_coolgaugetext_17697:
    cmp ebx, 4
    {disp32} jne game_flow_coolgaugetext_18592
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0x1a
    push 0x15
    push 0
    mov ebx, 0x10000
    mov edx, 0xac0000
    push 0x1e
    {store} xor ecx, ecx
    mov eax, 0x50000
    call rotatesprite_
    cmp byte ptr [esi + 1322], 0
    je game_flow_coolgaugetext_17811
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0x1a
    push 0x15
    push 0
    mov ebx, 0x10000
    mov edx, 0xaa0000
    push 0x21
    {store} xor ecx, ecx
    mov eax, 0x450000
    call rotatesprite_
game_flow_coolgaugetext_17811:
    movsx eax, word ptr [esi + 724]
    imul eax, eax, 0x2c
    cmp byte ptr [eax + _sprite + 0x11], 1
    jne game_flow_coolgaugetext_17864
    cmp word ptr [esi + 650], 2
    jge game_flow_coolgaugetext_17864
    push 0x1a
    mov ecx, 0xf0
    mov ebx, 1
    mov edx, 0xb7
    mov eax, 0x14
    jmp game_flow_coolgaugetext_17888
game_flow_coolgaugetext_17864:
    push 0x1a
    mov ecx, 0xf0
    mov edx, 0xb7
    mov eax, 0x14
    movsx ebx, word ptr [esi + 650]
game_flow_coolgaugetext_17888:
    call digitalnumber_
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0x1a
    push 0x15
    push 0
    mov ebx, 0x10000
    mov edx, 0xac0000
    push 0x1f
    {store} xor ecx, ecx
    mov eax, 0x250000
    call rotatesprite_
    mov dx, word ptr [esi + 680]
    cmp dx, 0xa
    jne game_flow_coolgaugetext_17963
    mov dword ptr [ebp + -8], 5
    jmp game_flow_coolgaugetext_17969
game_flow_coolgaugetext_17963:
    movsx eax, dx
    mov dword ptr [ebp + -8], eax
game_flow_coolgaugetext_17969:
    push 0x1a
    mov eax, dword ptr [ebp + -8]
    mov ecx, 0xf0
    mov edx, 0xb7
    movsx ebx, word ptr [esi + eax*2 + 652]
    mov eax, 0x35
    call digitalnumber_
    xor bl, bl
    mov byte ptr [ebp + -4], bl
    mov bh, byte ptr [esi + 1322]
    mov edi, 0x9e
    test bh, bh
    {disp32} je game_flow_coolgaugetext_21502
    {store} mov al, bh
    dec al
    cmp al, 6
    ja game_flow_coolgaugetext_18110
    and eax, 0xff
    jmp dword ptr cs:[eax*4 + game_switch_coolgaugetext_17300]
game_flow_coolgaugetext_18047:
    mov dword ptr [ebp + -8], 0x99c
    jmp game_flow_coolgaugetext_18117
game_flow_coolgaugetext_18056:
    mov dword ptr [ebp + -8], 0x9a5
    jmp game_flow_coolgaugetext_18117
game_flow_coolgaugetext_18065:
    mov dword ptr [ebp + -8], 0x9a6
    jmp game_flow_coolgaugetext_18117
game_flow_coolgaugetext_18074:
    mov dword ptr [ebp + -8], 0x9a3
    jmp game_flow_coolgaugetext_18117
game_flow_coolgaugetext_18083:
    mov dword ptr [ebp + -8], 0x99d
    jmp game_flow_coolgaugetext_18117
game_flow_coolgaugetext_18092:
    mov dword ptr [ebp + -8], 0x9a4
    jmp game_flow_coolgaugetext_18117
game_flow_coolgaugetext_18101:
    mov dword ptr [ebp + -8], 0x99f
    jmp game_flow_coolgaugetext_18117
game_flow_coolgaugetext_18110:
    mov dword ptr [ebp + -8], 0xffffffff
game_flow_coolgaugetext_18117:
    cmp dword ptr [ebp + -8], 0
    jl game_flow_coolgaugetext_18185
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    {store} xor eax, eax
    push 0
    mov al, byte ptr [ebp + -4]
    push 0
    add eax, 0x1a
    push eax
    mov edx, dword ptr [ebp + -8]
    push 0
    mov ebx, 0x10000
    mov eax, 0xe7
    push 0
    {store} xor ecx, ecx
    {store} sub eax, edi
    push edx
    shl eax, 0x10
    mov edx, 0xb30000
    call rotatesprite_
game_flow_coolgaugetext_18185:
    mov al, byte ptr [ebp + -4]
    add al, 0x1a
    mov ecx, 6
    and eax, 0xff
    mov ebx, OFFSET FLAT:game_text_coolgaugetext_240
    push eax
    mov eax, 0x106
    mov edx, 0xbe
    {store} sub eax, edi
    call minitext_
    mov al, byte ptr [esi + 1322]
    mov ebx, 0x80000000
    dec al
    mov dword ptr [ebp + -16], ebx
    cmp al, 6
    {disp32} ja game_flow_coolgaugetext_18418
    and eax, 0xff
    jmp dword ptr cs:[eax*4 + game_switch_view_17328]
game_flow_coolgaugetext_18260:
    movsx eax, word ptr [esi + 718]
    {disp32} jmp game_flow_coolgaugetext_18415
game_flow_coolgaugetext_18272:
    movsx eax, word ptr [esi + 1278]
    add eax, 3
    sar eax, 2
    {disp32} jmp game_flow_coolgaugetext_18415
game_flow_coolgaugetext_18290:
    movsx edx, word ptr [esi + 688]
    add edx, 0xf
    mov ebx, 0x18
    {store} mov eax, edx
    sar edx, 0x1f
    idiv ebx
    mov dword ptr [ebp + -8], eax
    movsx eax, word ptr [esi + 1282]
    mov dword ptr [ebp + -16], eax
    jmp game_flow_coolgaugetext_18418
game_flow_coolgaugetext_18327:
    movsx eax, word ptr [esi + 1276]
    add eax, 0xf
    sar eax, 4
    mov dword ptr [ebp + -8], eax
    {store} xor eax, eax
    mov al, byte ptr [esi + 1324]
    mov dword ptr [ebp + -16], eax
    jmp game_flow_coolgaugetext_18418
game_flow_coolgaugetext_18356:
    movsx edx, word ptr [esi + 744]
    mov ebx, 0xc
    {store} mov eax, edx
    sar edx, 0x1f
    idiv ebx
    mov dword ptr [ebp + -8], eax
    {store} xor eax, eax
    mov al, byte ptr [esi + 1329]
    mov dword ptr [ebp + -16], eax
    jmp game_flow_coolgaugetext_18418
game_flow_coolgaugetext_18391:
    movsx eax, word ptr [esi + 1274]
    add eax, 0x3f
    sar eax, 6
    jmp game_flow_coolgaugetext_18415
game_flow_coolgaugetext_18406:
    movsx eax, word ptr [esi + 1296]
    sar eax, 1
game_flow_coolgaugetext_18415:
    mov dword ptr [ebp + -8], eax
game_flow_coolgaugetext_18418:
    mov al, byte ptr [ebp + -4]
    add al, 0xa
    mov edx, 0xc2
    and eax, 0xff
    {store} xor ebx, ebx
    push eax
    mov eax, 0xfe
    {store} xor ecx, ecx
    {store} sub eax, edi
    mov bl, byte ptr [ebp + -8]
    mov dword ptr [ebp + -24], eax
    call invennum_
    mov al, byte ptr [ebp + -4]
    mov ecx, dword ptr [ebp + -16]
    add al, 0x1a
    test ecx, ecx
    jle game_flow_coolgaugetext_18495
    mov ebx, OFFSET FLAT:game_text_coolgaugetext_244
    and eax, 0xff
    mov edx, 0xb4
    push eax
    mov eax, 0x102
    {store} xor ecx, ecx
    {store} sub eax, edi
    jmp game_flow_coolgaugetext_18527
game_flow_coolgaugetext_18495:
    cmp ecx, 0x80000000
    je game_flow_coolgaugetext_18532
    mov ecx, 2
    and eax, 0xff
    mov ebx, OFFSET FLAT:game_text_coolgaugetext_248
    push eax
    mov edx, 0xb4
    mov eax, dword ptr [ebp + -24]
game_flow_coolgaugetext_18527:
    call minitext_
game_flow_coolgaugetext_18532:
    cmp byte ptr [esi + 1322], 6
    {disp32} jb game_flow_coolgaugetext_21502
    mov al, byte ptr [ebp + -4]
    add al, 0x1a
    mov ecx, 2
    and eax, 0xff
    mov ebx, OFFSET FLAT:game_text_coolgaugetext_252
    push eax
    mov eax, 0xf9
    mov edx, 0xb4
    {store} sub eax, edi
    call minitext_
    {store} mov esp, ebp
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_coolgaugetext_18592:
    cmp byte ptr [_pus], 0
    je game_flow_coolgaugetext_18619
    xor bh, bh
    mov eax, 0xffffffff
    mov byte ptr [_pus], bh
    mov dword ptr [ebp + -12], eax
    jmp game_flow_coolgaugetext_18624
game_flow_coolgaugetext_18619:
    {store} xor edi, edi
    mov dword ptr [ebp + -12], edi
game_flow_coolgaugetext_18624:
    movsx eax, word ptr [_myconnectindex]
    {store} add eax, eax
    mov di, word ptr [esi + 676]
    cmp di, word ptr [eax + _sbar]
    je game_flow_coolgaugetext_18665
    mov cl, byte ptr [ebp + -11]
    or cl, 0x80
    mov word ptr [eax + _sbar], di
    mov byte ptr [ebp + -11], cl
game_flow_coolgaugetext_18665:
    mov ax, word ptr [_sbar + 0x20]
    mov dx, word ptr [esi + 714]
    {store} cmp ax, dx
    je game_flow_coolgaugetext_18699
    mov ch, byte ptr [ebp + -11]
    or ch, 0x40
    mov word ptr [_sbar + 0x20], dx
    mov byte ptr [ebp + -11], ch
game_flow_coolgaugetext_18699:
    mov ax, word ptr [_sbar + 0x22]
    mov bx, word ptr [esi + 650]
    {store} cmp ax, bx
    je game_flow_coolgaugetext_18732
    mov al, byte ptr [ebp + -12]
    or al, 1
    mov word ptr [_sbar + 0x22], bx
    mov byte ptr [ebp + -12], al
game_flow_coolgaugetext_18732:
    mov ax, word ptr [_sbar + 0x24]
    mov cx, word ptr [esi + 1280]
    {store} cmp ax, cx
    je game_flow_coolgaugetext_18766
    mov ah, byte ptr [ebp + -12]
    or ah, 2
    mov word ptr [_sbar + 0x24], cx
    mov byte ptr [ebp + -12], ah
game_flow_coolgaugetext_18766:
    mov ax, word ptr [_sbar + 0x26]
    mov di, word ptr [esi + 680]
    {store} cmp ax, di
    je game_flow_coolgaugetext_18803
    mov edx, dword ptr [ebp + -12]
    or edx, 0x107fc
    mov word ptr [_sbar + 0x26], di
    mov dword ptr [ebp + -12], edx
game_flow_coolgaugetext_18803:
    mov dword ptr [ebp + -8], 1
    {disp32} jmp game_flow_coolgaugetext_18960
game_flow_coolgaugetext_18815:
    lea eax, dword ptr [ebx + ebx]
    lea edx, dword ptr [esi + eax]
    mov bx, word ptr [eax + _sbar + 0x28]
    mov cx, word ptr [edx + 652]
    {store} cmp bx, cx
    je game_flow_coolgaugetext_18887
    mov ebx, dword ptr [ebp + -8]
    mov word ptr [eax + _sbar + 0x28], cx
    cmp ebx, 9
    jge game_flow_coolgaugetext_18880
    mov cl, byte ptr [ebp + -8]
    mov eax, 2
    shl eax, cl
    mov edi, dword ptr [ebp + -12]
    .att_syntax prefix
    addl $game_math_coolgaugetext_18868,%eax
    .intel_syntax noprefix
    {store} or edi, eax
    mov dword ptr [ebp + -12], edi
    jmp game_flow_coolgaugetext_18887
game_flow_coolgaugetext_18880:
    or dword ptr [ebp + -12], 0x10400
game_flow_coolgaugetext_18887:
    mov eax, dword ptr [ebp + -8]
    mov edx, dword ptr [ebp + -8]
    {store} add eax, esi
    mov dl, byte ptr [edx + _sbar + 0x40]
    mov cl, byte ptr [eax + 1333]
    cmp dl, cl
    je game_flow_coolgaugetext_18957
    mov edx, dword ptr [ebp + -8]
    mov byte ptr [edx + _sbar + 0x40], cl
    cmp edx, 9
    jge game_flow_coolgaugetext_18950
    mov cl, byte ptr [ebp + -8]
    mov eax, 2
    shl eax, cl
    mov ebx, dword ptr [ebp + -12]
    .att_syntax prefix
    addl $game_math_coolgaugetext_18938,%eax
    .intel_syntax noprefix
    {store} or ebx, eax
    mov dword ptr [ebp + -12], ebx
    jmp game_flow_coolgaugetext_18957
game_flow_coolgaugetext_18950:
    or dword ptr [ebp + -12], 0x10400
game_flow_coolgaugetext_18957:
    inc dword ptr [ebp + -8]
game_flow_coolgaugetext_18960:
    mov ebx, dword ptr [ebp + -8]
    cmp ebx, 0xa
    {disp32} jl game_flow_coolgaugetext_18815
    mov al, byte ptr [_sbar + 0x4b]
    mov ch, byte ptr [esi + 1322]
    cmp al, ch
    je game_flow_coolgaugetext_19001
    mov al, byte ptr [ebp + -11]
    or al, 0x38
    mov byte ptr [_sbar + 0x4b], ch
    mov byte ptr [ebp + -11], al
game_flow_coolgaugetext_19001:
    mov ax, word ptr [_sbar + 0x3e]
    mov bx, word ptr [esi + 1282]
    {store} cmp ax, bx
    je game_flow_coolgaugetext_19035
    mov ah, byte ptr [ebp + -11]
    or ah, 0x30
    mov word ptr [_sbar + 0x3e], bx
    mov byte ptr [ebp + -11], ah
game_flow_coolgaugetext_19035:
    mov al, byte ptr [_sbar + 0x4c]
    mov dl, byte ptr [esi + 1324]
    cmp al, dl
    je game_flow_coolgaugetext_19060
    mov byte ptr [_sbar + 0x4c], dl
    or byte ptr [ebp + -11], 0x30
game_flow_coolgaugetext_19060:
    mov al, byte ptr [_sbar + 0x4d]
    mov bl, byte ptr [esi + 1329]
    cmp al, bl
    je game_flow_coolgaugetext_19085
    mov byte ptr [_sbar + 0x4d], bl
    or byte ptr [ebp + -11], 0x30
game_flow_coolgaugetext_19085:
    mov ax, word ptr [_sbar + 0x4e]
    mov cx, word ptr [esi + 718]
    {store} cmp ax, cx
    je game_flow_coolgaugetext_19114
    mov word ptr [_sbar + 0x4e], cx
    or byte ptr [ebp + -11], 0x20
game_flow_coolgaugetext_19114:
    mov ax, word ptr [_sbar + 0x50]
    mov di, word ptr [esi + 1278]
    {store} cmp ax, di
    je game_flow_coolgaugetext_19148
    mov ch, byte ptr [ebp + -11]
    or ch, 0x20
    mov word ptr [_sbar + 0x50], di
    mov byte ptr [ebp + -11], ch
game_flow_coolgaugetext_19148:
    mov ax, word ptr [_sbar + 0x52]
    mov dx, word ptr [esi + 688]
    {store} cmp ax, dx
    je game_flow_coolgaugetext_19181
    mov al, byte ptr [ebp + -11]
    or al, 0x20
    mov word ptr [_sbar + 0x52], dx
    mov byte ptr [ebp + -11], al
game_flow_coolgaugetext_19181:
    mov ax, word ptr [_sbar + 0x54]
    mov bx, word ptr [esi + 1276]
    {store} cmp ax, bx
    je game_flow_coolgaugetext_19215
    mov ah, byte ptr [ebp + -11]
    or ah, 0x20
    mov word ptr [_sbar + 0x54], bx
    mov byte ptr [ebp + -11], ah
game_flow_coolgaugetext_19215:
    mov ax, word ptr [_sbar + 0x56]
    mov cx, word ptr [esi + 744]
    {store} cmp ax, cx
    je game_flow_coolgaugetext_19249
    mov dl, byte ptr [ebp + -11]
    or dl, 0x20
    mov word ptr [_sbar + 0x56], cx
    mov byte ptr [ebp + -11], dl
game_flow_coolgaugetext_19249:
    mov ax, word ptr [_sbar + 0x58]
    mov di, word ptr [esi + 1274]
    {store} cmp ax, di
    je game_flow_coolgaugetext_19283
    mov dh, byte ptr [ebp + -11]
    or dh, 0x20
    mov word ptr [_sbar + 0x58], di
    mov byte ptr [ebp + -11], dh
game_flow_coolgaugetext_19283:
    mov ax, word ptr [_sbar + 0x5a]
    mov dx, word ptr [esi + 1296]
    {store} cmp ax, dx
    je game_flow_coolgaugetext_19317
    mov bl, byte ptr [ebp + -11]
    or bl, 0x20
    mov word ptr [_sbar + 0x5a], dx
    mov byte ptr [ebp + -11], bl
game_flow_coolgaugetext_19317:
    mov ecx, dword ptr [ebp + -12]
    test ecx, ecx
    {disp32} je game_flow_coolgaugetext_21502
    cmp ecx, -1
    {disp32} jne game_flow_coolgaugetext_19517
    mov ecx, 0xc8
    mov ebx, dword ptr [_ydim]
    {store} mov eax, ecx
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    {store} mov eax, ecx
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0xc8
    push eax
    mov ebx, dword ptr [_ydim]
    {store} xor eax, eax
    imul ebx
    idiv ecx
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    {store} xor eax, eax
    imul ebx
    idiv ecx
    push eax
    push 0xda
    push 0
    push 4
    mov ebx, 0x10000
    mov edx, 0xa60000
    push 0x99e
    {store} xor ecx, ecx
    {store} xor eax, eax
    call rotatesprite_
    cmp word ptr [_ud + 0x590], 1
    jle game_flow_coolgaugetext_19517
    cmp dword ptr [_ud + 0x5de], 1
    je game_flow_coolgaugetext_19517
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0x9a
    push 0
    push 0
    mov ebx, 0x10000
    mov edx, 0xad0000
    push 0x99a
    {store} xor ecx, ecx
    mov eax, 0x1150000
    call rotatesprite_
game_flow_coolgaugetext_19517:
    cmp word ptr [_ud + 0x590], 1
    {disp32} jle game_flow_coolgaugetext_19731
    cmp dword ptr [_ud + 0x5de], 1
    {disp32} je game_flow_coolgaugetext_19731
    test byte ptr [ebp + -11], 0x80
    {disp32} je game_flow_coolgaugetext_20055
    cmp dword ptr [ebp + -12], -1
    je game_flow_coolgaugetext_19679
    mov ecx, 0xc8
    mov eax, 0xc1
    mov ebx, dword ptr [_ydim]
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0x12b
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0xc8
    push eax
    mov ebx, dword ptr [_ydim]
    mov eax, 0xb7
    imul ebx
    idiv ecx
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0x114
    imul ebx
    idiv ecx
    push eax
    push 0xda
    push 0
    push 4
    mov ebx, 0x10000
    mov edx, 0xa60000
    push 0x99e
    {store} xor ecx, ecx
    {store} xor eax, eax
    call rotatesprite_
game_flow_coolgaugetext_19679:
    movsx ebx, word ptr [esi + 676]
    movsx eax, word ptr [esi + 678]
    push 0x9a
    {store} sub ebx, eax
    mov ecx, 0xf0
    test ebx, ebx
    jg game_flow_coolgaugetext_19711
    {store} xor ebx, ebx
game_flow_coolgaugetext_19711:
    mov edx, 0xb7
    mov eax, 0x11f
    call digitalnumber_
    {disp32} jmp game_flow_coolgaugetext_20055
game_flow_coolgaugetext_19731:
    test byte ptr [ebp + -11], 0x40
    {disp32} je game_flow_coolgaugetext_20055
    cmp dword ptr [ebp + -12], -1
    je game_flow_coolgaugetext_19866
    mov ecx, 0xc8
    mov eax, 0xc2
    mov ebx, dword ptr [_ydim]
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0x12b
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0xc8
    push eax
    mov ebx, dword ptr [_ydim]
    mov eax, 0xb6
    imul ebx
    idiv ecx
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0x113
    imul ebx
    idiv ecx
    push eax
    push 0xda
    push 0
    push 4
    mov ebx, 0x10000
    mov edx, 0xa60000
    push 0x99e
    {store} xor ecx, ecx
    {store} xor eax, eax
    call rotatesprite_
game_flow_coolgaugetext_19866:
    test byte ptr [esi + 714], 4
    je game_flow_coolgaugetext_19929
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0x9a
    push 0x17
    push 0
    mov ebx, 0x10000
    mov edx, 0xb60000
    push 0x9a7
    {store} xor ecx, ecx
    mov eax, 0x1130000
    call rotatesprite_
game_flow_coolgaugetext_19929:
    test byte ptr [esi + 714], 2
    je game_flow_coolgaugetext_19992
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0x9a
    push 0x15
    push 0
    mov ebx, 0x10000
    mov edx, 0xb60000
    push 0x9a7
    {store} xor ecx, ecx
    mov eax, 0x1200000
    call rotatesprite_
game_flow_coolgaugetext_19992:
    test byte ptr [esi + 714], 1
    je game_flow_coolgaugetext_20055
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0x9a
    push 0
    push 0
    mov ebx, 0x10000
    mov edx, 0xbd0000
    push 0x9a7
    {store} xor ecx, ecx
    mov eax, 0x1190000
    call rotatesprite_
game_flow_coolgaugetext_20055:
    mov edi, dword ptr [ebp + -12]
    test edi, 0x103fc
    je game_flow_coolgaugetext_20085
    mov ebx, 0xb6
    mov edx, 0x60
    {store} mov ecx, edi
    {store} mov eax, esi
    call weapon_amounts_
game_flow_coolgaugetext_20085:
    test byte ptr [ebp + -12], 1
    {disp32} je game_flow_coolgaugetext_20308
    cmp dword ptr [ebp + -12], -1
    je game_flow_coolgaugetext_20220
    mov ecx, 0xc8
    mov eax, 0xc1
    mov ebx, dword ptr [_ydim]
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0x2b
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0xc8
    push eax
    mov ebx, dword ptr [_ydim]
    mov eax, 0xb7
    imul ebx
    idiv ecx
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0x14
    imul ebx
    idiv ecx
    push eax
    push 0xda
    push 0
    push 4
    mov ebx, 0x10000
    mov edx, 0xa60000
    push 0x99e
    {store} xor ecx, ecx
    {store} xor eax, eax
    call rotatesprite_
game_flow_coolgaugetext_20220:
    movsx eax, word ptr [esi + 724]
    imul eax, eax, 0x2c
    cmp byte ptr [eax + _sprite + 0x11], 1
    jne game_flow_coolgaugetext_20276
    cmp word ptr [esi + 650], 2
    jge game_flow_coolgaugetext_20276
    push 0x9a
    mov ecx, 0xf0
    mov ebx, 1
    mov edx, 0xb7
    mov eax, 0x20
    jmp game_flow_coolgaugetext_20303
game_flow_coolgaugetext_20276:
    push 0x9a
    mov ecx, 0xf0
    mov edx, 0xb7
    mov eax, 0x20
    movsx ebx, word ptr [esi + 650]
game_flow_coolgaugetext_20303:
    call digitalnumber_
game_flow_coolgaugetext_20308:
    test byte ptr [ebp + -12], 2
    {disp32} je game_flow_coolgaugetext_20475
    cmp dword ptr [ebp + -12], -1
    je game_flow_coolgaugetext_20443
    mov ecx, 0xc8
    mov eax, 0xc1
    mov ebx, dword ptr [_ydim]
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0x4b
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0xc8
    push eax
    mov ebx, dword ptr [_ydim]
    mov eax, 0xb7
    imul ebx
    idiv ecx
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0x34
    imul ebx
    idiv ecx
    push eax
    push 0xda
    push 0
    push 4
    mov ebx, 0x10000
    mov edx, 0xa60000
    push 0x99e
    {store} xor ecx, ecx
    {store} xor eax, eax
    call rotatesprite_
game_flow_coolgaugetext_20443:
    push 0x9a
    mov ecx, 0xf0
    mov edx, 0xb7
    mov eax, 0x40
    movsx ebx, word ptr [esi + 1280]
    call digitalnumber_
game_flow_coolgaugetext_20475:
    test byte ptr [ebp + -11], 4
    {disp32} je game_flow_coolgaugetext_20677
    cmp dword ptr [ebp + -12], -1
    je game_flow_coolgaugetext_20610
    mov ecx, 0xc8
    mov eax, 0xc1
    mov ebx, dword ptr [_ydim]
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0xdb
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0xc8
    push eax
    mov ebx, dword ptr [_ydim]
    mov eax, 0xb7
    imul ebx
    idiv ecx
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0xc4
    imul ebx
    idiv ecx
    push eax
    push 0xda
    push 0
    push 4
    mov ebx, 0x10000
    mov edx, 0xa60000
    push 0x99e
    {store} xor ecx, ecx
    {store} xor eax, eax
    call rotatesprite_
game_flow_coolgaugetext_20610:
    mov ax, word ptr [esi + 680]
    test ax, ax
    je game_flow_coolgaugetext_20677
    .att_syntax prefix
    cmpw $game_math_coolgaugetext_20622,%ax
    .intel_syntax noprefix
    jne game_flow_coolgaugetext_20637
    mov dword ptr [ebp + -8], 5
    jmp game_flow_coolgaugetext_20641
game_flow_coolgaugetext_20637:
    cwde
    mov dword ptr [ebp + -8], eax
game_flow_coolgaugetext_20641:
    push 0x9a
    mov eax, dword ptr [ebp + -8]
    mov ecx, 0xf0
    mov edx, 0xb7
    movsx ebx, word ptr [esi + eax*2 + 652]
    mov eax, 0xd0
    call digitalnumber_
game_flow_coolgaugetext_20677:
    mov cl, byte ptr [ebp + -11]
    test cl, 0x38
    {disp32} je game_flow_coolgaugetext_21502
    cmp dword ptr [ebp + -12], -1
    {disp32} je game_flow_coolgaugetext_20906
    test cl, 0x18
    je game_flow_coolgaugetext_20787
    mov ecx, 0xc8
    mov eax, 0xc5
    mov ebx, dword ptr [_ydim]
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0x109
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0xc8
    push eax
    mov ebx, dword ptr [_ydim]
    mov eax, 0xb3
    imul ebx
    idiv ecx
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0xe7
    jmp game_flow_coolgaugetext_20868
game_flow_coolgaugetext_20787:
    mov ecx, 0xc8
    mov eax, 0xc3
    mov ebx, dword ptr [_ydim]
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0x105
    imul ebx
    idiv ecx
    dec eax
    mov ecx, 0xc8
    push eax
    mov ebx, dword ptr [_ydim]
    mov eax, 0xbe
    imul ebx
    idiv ecx
    mov ecx, 0x140
    push eax
    mov ebx, dword ptr [_xdim]
    mov eax, 0xfa
game_flow_coolgaugetext_20868:
    imul ebx
    idiv ecx
    push eax
    push 0xda
    push 0
    push 4
    mov ebx, 0x10000
    mov edx, 0xa60000
    push 0x99e
    {store} xor ecx, ecx
    {store} xor eax, eax
    call rotatesprite_
game_flow_coolgaugetext_20906:
    mov al, byte ptr [esi + 1322]
    test al, al
    {disp32} je game_flow_coolgaugetext_21502
    mov ah, 0x80
    mov dl, byte ptr [ebp + -11]
    {store} xor edi, edi
    mov byte ptr [ebp + -4], ah
    test dl, 0x18
    {disp32} je game_flow_coolgaugetext_21162
    dec al
    cmp al, 6
    ja game_flow_coolgaugetext_21019
    and eax, 0xff
    jmp dword ptr cs:[eax*4 + game_switch_view_17356]
game_flow_coolgaugetext_20958:
    mov dword ptr [ebp + -8], 0x99c
    jmp game_flow_coolgaugetext_21019
game_flow_coolgaugetext_20967:
    mov dword ptr [ebp + -8], 0x9a5
    jmp game_flow_coolgaugetext_21019
game_flow_coolgaugetext_20976:
    mov dword ptr [ebp + -8], 0x9a6
    jmp game_flow_coolgaugetext_21019
game_flow_coolgaugetext_20985:
    mov dword ptr [ebp + -8], 0x9a3
    jmp game_flow_coolgaugetext_21019
game_flow_coolgaugetext_20994:
    mov dword ptr [ebp + -8], 0x99d
    jmp game_flow_coolgaugetext_21019
game_flow_coolgaugetext_21003:
    mov dword ptr [ebp + -8], 0x9a4
    jmp game_flow_coolgaugetext_21019
game_flow_coolgaugetext_21012:
    mov dword ptr [ebp + -8], 0x99f
game_flow_coolgaugetext_21019:
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    {store} xor eax, eax
    push 0
    mov al, byte ptr [ebp + -4]
    push 0
    add eax, 0x1a
    push eax
    mov ecx, dword ptr [ebp + -8]
    push 0
    mov ebx, 0x10000
    mov eax, 0xe7
    push 0
    mov edx, 0xb30000
    {store} sub eax, edi
    push ecx
    shl eax, 0x10
    {store} xor ecx, ecx
    call rotatesprite_
    mov al, byte ptr [ebp + -4]
    add al, 0x1a
    mov ecx, 6
    and eax, 0xff
    mov ebx, OFFSET FLAT:game_text_coolgaugetext_240
    mov dword ptr [ebp + -20], eax
    push eax
    mov eax, 0x106
    mov edx, 0xbe
    {store} sub eax, edi
    call minitext_
    cmp byte ptr [esi + 1322], 6
    jb game_flow_coolgaugetext_21162
    mov edx, dword ptr [ebp + -20]
    mov eax, 0xf9
    mov ecx, 2
    mov ebx, OFFSET FLAT:game_text_coolgaugetext_252
    push edx
    {store} sub eax, edi
    mov edx, 0xb4
    call minitext_
game_flow_coolgaugetext_21162:
    test byte ptr [ebp + -11], 0x18
    {disp32} je game_flow_coolgaugetext_21317
    mov al, byte ptr [esi + 1322]
    cmp al, 4
    jb game_flow_coolgaugetext_21190
    jbe game_flow_coolgaugetext_21206
    cmp al, 5
    je game_flow_coolgaugetext_21219
    jmp game_flow_coolgaugetext_21232
game_flow_coolgaugetext_21190:
    cmp al, 3
    jne game_flow_coolgaugetext_21232
    movsx eax, word ptr [esi + 1282]
    mov dword ptr [ebp + -16], eax
    jmp game_flow_coolgaugetext_21239
game_flow_coolgaugetext_21206:
    {store} xor eax, eax
    mov al, byte ptr [esi + 1324]
    mov dword ptr [ebp + -16], eax
    jmp game_flow_coolgaugetext_21239
game_flow_coolgaugetext_21219:
    {store} xor eax, eax
    mov al, byte ptr [esi + 1329]
    mov dword ptr [ebp + -16], eax
    jmp game_flow_coolgaugetext_21239
game_flow_coolgaugetext_21232:
    mov dword ptr [ebp + -16], 0x80000000
game_flow_coolgaugetext_21239:
    mov al, byte ptr [ebp + -4]
    mov ecx, dword ptr [ebp + -16]
    add al, 0x1a
    test ecx, ecx
    jle game_flow_coolgaugetext_21276
    mov ebx, OFFSET FLAT:game_text_coolgaugetext_244
    and eax, 0xff
    mov edx, 0xb4
    push eax
    mov eax, 0x102
    {store} xor ecx, ecx
    jmp game_flow_coolgaugetext_21310
game_flow_coolgaugetext_21276:
    cmp ecx, 0x80000000
    je game_flow_coolgaugetext_21317
    mov ecx, 2
    and eax, 0xff
    mov ebx, OFFSET FLAT:game_text_coolgaugetext_248
    push eax
    mov eax, 0xfe
    mov edx, 0xb4
game_flow_coolgaugetext_21310:
    {store} sub eax, edi
    call minitext_
game_flow_coolgaugetext_21317:
    test byte ptr [ebp + -11], 0x20
    {disp32} je game_flow_coolgaugetext_21502
    mov al, byte ptr [esi + 1322]
    dec al
    cmp al, 6
    {disp32} ja game_flow_coolgaugetext_21467
    and eax, 0xff
    jmp dword ptr cs:[eax*4 + game_switch_view_17384]
game_flow_coolgaugetext_21356:
    movsx eax, word ptr [esi + 718]
    jmp game_flow_coolgaugetext_21464
game_flow_coolgaugetext_21365:
    movsx eax, word ptr [esi + 1278]
    add eax, 3
    sar eax, 2
    jmp game_flow_coolgaugetext_21464
game_flow_coolgaugetext_21380:
    movsx edx, word ptr [esi + 688]
    add edx, 0xf
    mov ebx, 0x18
    {store} mov eax, edx
    sar edx, 0x1f
    idiv ebx
    jmp game_flow_coolgaugetext_21464
game_flow_coolgaugetext_21404:
    movsx eax, word ptr [esi + 1276]
    add eax, 0xf
    sar eax, 4
    jmp game_flow_coolgaugetext_21464
game_flow_coolgaugetext_21419:
    movsx edx, word ptr [esi + 744]
    mov ebx, 0xc
    {store} mov eax, edx
    sar edx, 0x1f
    idiv ebx
    jmp game_flow_coolgaugetext_21464
game_flow_coolgaugetext_21440:
    movsx eax, word ptr [esi + 1274]
    add eax, 0x3f
    sar eax, 6
    jmp game_flow_coolgaugetext_21464
game_flow_coolgaugetext_21455:
    movsx eax, word ptr [esi + 1296]
    sar eax, 1
game_flow_coolgaugetext_21464:
    mov dword ptr [ebp + -8], eax
game_flow_coolgaugetext_21467:
    mov al, byte ptr [ebp + -4]
    add al, 0xa
    mov edx, 0xc2
    and eax, 0xff
    {store} xor ebx, ebx
    {store} xor ecx, ecx
    push eax
    mov eax, 0xfe
    mov bl, byte ptr [ebp + -8]
    {store} sub eax, edi
    call invennum_
game_flow_coolgaugetext_21502:
    {store} mov esp, ebp
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp8} lea edx, dword ptr [edx]
tics_:
    push ebx
    push ecx
    push edx
    push esi
    sub esp, 0xc
    mov esi, dword ptr [_totalclock]
    mov eax, dword ptr [_framecnt]
    {disp32} lea eax, dword ptr [eax*4]
    mov edx, dword ptr [eax + _frameval]
    {store} cmp esi, edx
    je game_flow_tics_21635
    {store} mov ebx, esi
    mov eax, 0x1e00
    {store} sub ebx, edx
    {store} mov edx, eax
    sar edx, 0x1f
    idiv ebx
    push eax
    push OFFSET FLAT:game_text_invennum_232
    lea eax, dword ptr [esp + 8]
    push eax
    call sprintf_
    add esp, 0xc
    mov ecx, 0xffffffeb
    push 1
    lea eax, dword ptr [esp + 4]
    mov ebx, 0x1f
    push eax
    mov edx, dword ptr [_windowy1]
    mov eax, dword ptr [_windowx1]
    call printext256_
    mov eax, dword ptr [_framecnt]
    mov dword ptr [eax*4 + _frameval], esi
game_flow_tics_21635:
    mov eax, dword ptr [_framecnt]
    inc eax
    and eax, 0x3f
    mov dword ptr [_framecnt], eax
    add esp, 0xc
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    nop
caches_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    sub esp, 4
    {store} xor edi, edi
    {store} xor esi, esi
    jmp game_flow_caches_21765
game_flow_caches_21678:
    {disp32} lea ebx, dword ptr [eax*4]
    mov edx, dword ptr [ebx + _lockptr]
    mov cl, byte ptr [edx]
    cmp cl, 0xc8
    jb game_flow_caches_21764
    {store} mov dl, cl
    and edx, 0xff
    push edx
    mov ecx, dword ptr [ebx + _cacleng]
    push ecx
    push eax
    push OFFSET FLAT:game_text_caches_260
    push OFFSET FLAT:_tempbuf
    call sprintf_
    add esp, 0x14
    mov ebx, 0x1f
    push 1
    movsx edx, di
    mov ecx, 0xffffffff
    push OFFSET FLAT:_tempbuf
    {store} xor eax, eax
    mov edi, dword ptr [esp + 8]
    call printext256_
game_flow_caches_21764:
    inc esi
game_flow_caches_21765:
    {store} mov edx, edi
    add edx, 6
    movsx eax, si
    mov dword ptr [esp], edx
    cmp eax, dword ptr [_cacnum]
    jl game_flow_caches_21678
    mov esi, 1
    mov edi, dword ptr [esp]
    cmp si, 0xb
    jl game_flow_caches_21807
    add esp, 4
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_caches_21807:
    movsx eax, si
    cmp byte ptr [eax + _lumplockbyte], 0xc8
    jb game_flow_caches_21868
    push eax
    push OFFSET FLAT:game_text_caches_292
    push OFFSET FLAT:_tempbuf
    call sprintf_
    add esp, 0xc
    mov ecx, 0xffffffff
    mov ebx, 0x1f
    push 1
    movsx edx, di
    push OFFSET FLAT:_tempbuf
    {store} xor eax, eax
    add edi, 6
    call printext256_
game_flow_caches_21868:
    inc esi
    cmp si, 0xb
    jl game_flow_caches_21807
    add esp, 4
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp8} lea eax, dword ptr [eax + eiz*1]
coords_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    mov dx, word ptr [_ud + 0x590]
    {store} xor esi, esi
    cmp dx, 1
    jle game_flow_coords_21922
    cmp dx, 5
    jge game_flow_coords_21922
    mov esi, 8
    jmp game_flow_coords_21937
game_flow_coords_21922:
    cmp word ptr [_ud + 0x590], 4
    jle game_flow_coords_21937
    mov esi, 0x10
game_flow_coords_21937:
    movsx edi, ax
    imul edi, edi, 0x552
    mov edx, dword ptr [edi + _ps + 0x214]
    push edx
    push OFFSET FLAT:game_text_coords_308
    push OFFSET FLAT:_tempbuf
    call sprintf_
    add esp, 0xc
    mov ecx, 0xffffffff
    mov ebx, 0x1f
    push 1
    movsx esi, si
    push OFFSET FLAT:_tempbuf
    {store} mov edx, esi
    mov eax, 0x112
    call printext256_
    mov ebx, dword ptr [edi + _ps + 0x218]
    push ebx
    push OFFSET FLAT:game_text_coords_316
    push OFFSET FLAT:_tempbuf
    call sprintf_
    add esp, 0xc
    push 1
    mov ecx, 0xffffffff
    lea edx, dword ptr [esi + 7]
    push OFFSET FLAT:_tempbuf
    mov ebx, 0x1f
    mov eax, 0x112
    call printext256_
    mov ecx, dword ptr [edi + _ps + 0x21c]
    push ecx
    push OFFSET FLAT:game_text_coords_324
    push OFFSET FLAT:_tempbuf
    call sprintf_
    add esp, 0xc
    push 1
    mov ebx, 0x1f
    lea edx, dword ptr [esi + 14]
    push OFFSET FLAT:_tempbuf
    mov ecx, 0xffffffff
    mov eax, 0x112
    call printext256_
    movsx edx, word ptr [edi + _ps + 0x280]
    push edx
    push OFFSET FLAT:game_text_coords_332
    push OFFSET FLAT:_tempbuf
    call sprintf_
    add esp, 0xc
    push 1
    mov ecx, 0xffffffff
    mov ebx, 0x1f
    push OFFSET FLAT:_tempbuf
    mov eax, 0x112
    lea edx, dword ptr [esi + 21]
    call printext256_
    mov ebp, dword ptr [edi + _ps + 0x254]
    push ebp
    push OFFSET FLAT:game_text_coords_340
    push OFFSET FLAT:_tempbuf
    call sprintf_
    add esp, 0xc
    push 1
    mov ecx, 0xffffffff
    mov ebx, 0x1f
    push OFFSET FLAT:_tempbuf
    lea edx, dword ptr [esi + 28]
    mov eax, 0x112
    call printext256_
    {store} xor edx, edx
    mov dl, byte ptr [edi + _ps + 0x51c]
    push edx
    push OFFSET FLAT:game_text_coords_348
    push OFFSET FLAT:_tempbuf
    call sprintf_
    add esp, 0xc
    push 1
    mov ecx, 0xffffffff
    mov ebx, 0x1f
    push OFFSET FLAT:_tempbuf
    lea edx, dword ptr [esi + 35]
    mov eax, 0x112
    call printext256_
    movsx edx, word ptr [edi + _ps + 0x50a]
    push edx
    push OFFSET FLAT:game_text_coords_356
    push OFFSET FLAT:_tempbuf
    call sprintf_
    add esp, 0xc
    push 1
    mov ecx, 0xffffffff
    mov ebx, 0x1f
    push OFFSET FLAT:_tempbuf
    lea edx, dword ptr [esi + 43]
    mov eax, 0x112
    call printext256_
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    {load} mov edx, edx
operatefta_:
    push ebx
    push ecx
    push edx
    push esi
    cmp word ptr [_received_quote_time], 0
    jle game_flow_operatefta_22429
    cmp dword ptr [_ud + 0x5e2], 0
    jle game_flow_operatefta_22382
    mov edx, 0x9f
    jmp game_flow_operatefta_22387
game_flow_operatefta_22382:
    mov edx, 0xc0
game_flow_operatefta_22387:
    mov eax, 0xa0
    mov ebx, dword ptr [_received_quote]
    {store} xor ecx, ecx
    call gametext_
    cmp word ptr [_received_quote_time], 1
    jne game_flow_operatefta_22429
    mov ah, 1
    mov byte ptr [_pub], ah
    mov byte ptr [_pus], ah
game_flow_operatefta_22429:
    movsx edx, word ptr [_screenpeek]
    imul edx, edx, 0x552
    mov dx, word ptr [edx + _ps + 0x2c0]
    cmp dx, 1
    {disp32} jle game_flow_operatefta_22676
    cmp dword ptr [_ud + 0x5de], 1
    {disp32} je game_flow_operatefta_22576
    cmp dword ptr [_ud + 0x5e2], 0
    {disp32} jle game_flow_operatefta_22576
    cmp word ptr [_ud + 0x590], 1
    jle game_flow_operatefta_22576
    mov ebx, 8
    mov ax, word ptr [_connecthead]
    {store} xor edx, edx
    jmp game_flow_operatefta_22526
game_flow_operatefta_22510:
    {store} cmp ax, dx
    jle game_flow_operatefta_22517
    {store} mov edx, eax
game_flow_operatefta_22517:
    cwde
    mov ax, word ptr [eax*2 + _connectpoint2]
game_flow_operatefta_22526:
    test ax, ax
    jge game_flow_operatefta_22510
    cmp dx, 4
    jl game_flow_operatefta_22548
    cmp dx, 8
    jg game_flow_operatefta_22548
    add ebx, 8
    jmp game_flow_operatefta_22578
game_flow_operatefta_22548:
    cmp dx, 8
    jle game_flow_operatefta_22565
    cmp dx, 0xc
    jg game_flow_operatefta_22565
    add ebx, 0x10
    jmp game_flow_operatefta_22578
game_flow_operatefta_22565:
    cmp dx, 0xc
    jle game_flow_operatefta_22578
    add ebx, 0x18
    jmp game_flow_operatefta_22578
game_flow_operatefta_22576:
    {store} xor ebx, ebx
game_flow_operatefta_22578:
    movsx eax, word ptr [_screenpeek]
    imul eax, eax, 0x552
    mov si, word ptr [eax + _ps + 0x2c2]
    cmp si, 0x73
    je game_flow_operatefta_22610
    cmp si, 0x74
    jne game_flow_operatefta_22631
game_flow_operatefta_22610:
    cmp dword ptr [_ud + 0x5e2], 0
    jle game_flow_operatefta_22626
    mov ebx, 0x96
    jmp game_flow_operatefta_22631
game_flow_operatefta_22626:
    mov ebx, 0xc0
game_flow_operatefta_22631:
    movsx eax, word ptr [_screenpeek]
    imul eax, eax, 0x552
    movsx eax, word ptr [eax + _ps + 0x2c2]
    shl eax, 6
    movsx edx, bx
    add eax, OFFSET FLAT:_fta_quotes
    {store} xor ecx, ecx
    {store} mov ebx, eax
    mov eax, 0xa0
    call gametext_
game_flow_operatefta_22676:
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    nop
FTA_:
    push ebx
    push ecx
    push edi
    cmp dword ptr [_ud + 0x5c6], 1
    jne game_flow_FTA_22783
    cmp word ptr [edx + 704], 0
    jle game_flow_FTA_22741
    .att_syntax prefix
    cmpw $game_math_FTA_22710,%ax
    .intel_syntax noprefix
    je game_flow_FTA_22741
    .att_syntax prefix
    cmpw $game_math_FTA_22716,%ax
    .intel_syntax noprefix
    je game_flow_FTA_22741
    mov cx, word ptr [edx + 706]
    cmp cx, 0x73
    je game_flow_FTA_22783
    cmp cx, 0x74
    je game_flow_FTA_22783
game_flow_FTA_22741:
    mov di, word ptr [edx + 706]
    mov word ptr [edx + 704], 0x64
    {store} cmp ax, di
    je game_flow_FTA_22783
    mov bl, 1
    mov byte ptr [_pub], bl
    mov byte ptr [_pus], bl
    mov word ptr [edx + 706], ax
game_flow_FTA_22783:
    pop edi
    pop ecx
    pop ebx
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
    {load} mov eax, eax
showtwoscreens_:
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
    {disp8} lea eax, dword ptr [eax]
binscreen_:
    push ebx
    push ecx
    push edx
    {store} xor edx, edx
    mov eax, OFFSET FLAT:game_text_binscreen_364
    mov dl, byte ptr [_loadfromgrouponly]
    call kopen4load_
    {store} mov ecx, eax
    cmp eax, -1
    je game_flow_binscreen_22866
    mov ebx, 0xfa0
    mov edx, 0xb8000
    call kread_
    {store} mov eax, ecx
    call kclose_
game_flow_binscreen_22866:
    pop edx
    pop ecx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp8} lea edx, dword ptr [edx + eiz*1]
gameexit_:
    push ecx
    push edx
    {store} mov edx, eax
    cmp byte ptr [eax], 0
    je game_flow_gameexit_22912
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov dword ptr [eax + _ps + 0x541], OFFSET FLAT:_palette
game_flow_gameexit_22912:
    cmp word ptr [_numplayers], 1
    jle game_flow_gameexit_22932
    call allowtimetocorrecterrorswhenquitting_
    call uninitmultiplayers_
game_flow_gameexit_22932:
    mov ecx, dword ptr [_ud + 0x5fa]
    cmp ecx, 1
    jne game_flow_gameexit_22950
    call closedemowrite_
    jmp game_flow_gameexit_22965
game_flow_gameexit_22950:
    cmp ecx, 2
    jne game_flow_gameexit_22965
    mov eax, dword ptr [_frecfilep]
    call fclose_
game_flow_gameexit_22965:
    cmp byte ptr [_playerswhenstarted], 1
    jbe game_flow_gameexit_23003
    cmp dword ptr [_ud + 0x5de], 1
    je game_flow_gameexit_23003
    cmp byte ptr [edx], 0x20
    jne game_flow_gameexit_23003
    mov eax, 1
    call dobonus_
    call setgamemode_
game_flow_gameexit_23003:
    cmp byte ptr [edx], 0
    call ShutDown_
    cmp byte ptr [edx], 0
    je game_flow_gameexit_23074
    mov eax, 3
    int 0x10
    call binscreen_
    cmp byte ptr [edx], 0x20
    jne game_flow_gameexit_23042
    mov ah, byte ptr [edx + 1]
    test ah, ah
    jne game_flow_gameexit_23042
    mov byte ptr [edx], ah
game_flow_gameexit_23042:
    push OFFSET FLAT:game_text_gameexit_376
    call printf_
    add esp, 4
    push edx
    push OFFSET FLAT:game_text_gameexit_400
    push OFFSET FLAT:game_text_gameexit_404
    call printf_
    add esp, 0xc
game_flow_gameexit_23074:
    call uninitgroupfile_
    mov eax, OFFSET FLAT:game_text_gameexit_412
    call unlink_
    {store} xor eax, eax
    call exit_
    pop edx
    pop ecx
    ret
    {disp8} lea eax, dword ptr [eax]
    {load} mov ecx, ecx
strget_:
    push esi
    push edi
    sub esp, 0x2c
    {store} mov esi, eax
    {store} mov edi, edx
game_flow_strget_23113:
    call KB_KeyWaiting_
    test eax, eax
    {disp32} je game_flow_strget_23338
    {store} xor edx, edx
    call KB_Getch_
    {store} mov dl, al
    test dx, dx
    jne game_flow_strget_23163
    call KB_Getch_
    xor ah, ah
    .att_syntax prefix
    cmpw $game_math_strget_23147,%ax
    .intel_syntax noprefix
    jne game_flow_strget_23113
    mov eax, 1
    {disp32} jmp game_flow_strget_23557
game_flow_strget_23163:
    cmp dx, 8
    jne game_flow_strget_23199
    mov ax, word ptr [_inputloc]
    test ax, ax
    jle game_flow_strget_23113
    {store} mov edx, eax
    dec edx
    movsx eax, dx
    mov word ptr [_inputloc], dx
    mov byte ptr [ebx + eax], 0
    jmp game_flow_strget_23113
game_flow_strget_23199:
    cmp dx, 0xd
    jne game_flow_strget_23234
    xor dl, al
    mov byte ptr [_KB_KeyDown + 0x1c], dl
    xor dh, dh
    mov byte ptr [_KB_KeyDown + 0x68], dh
    mov eax, 1
    add esp, 0x2c
    pop edi
    pop esi
    ret 4
game_flow_strget_23234:
    cmp dx, 0x1b
    jne game_flow_strget_23261
    xor ah, ah
    mov byte ptr [_KB_KeyDown + 0x1], ah
    mov eax, 0xffffffff
    add esp, 0x2c
    pop edi
    pop esi
    ret 4
game_flow_strget_23261:
    cmp dx, 0x20
    {disp32} jl game_flow_strget_23113
    cmp cx, word ptr [_inputloc]
    {disp32} jle game_flow_strget_23113
    cmp dx, 0x7f
    {disp32} jge game_flow_strget_23113
    movsx eax, dx
    call toupper_
    {store} mov edx, eax
    movsx eax, word ptr [_inputloc]
    mov byte ptr [ebx + eax], dl
    movsx eax, word ptr [_inputloc]
    mov byte ptr [ebx + eax + 1], 0
    inc word ptr [_inputloc]
    {disp32} jmp game_flow_strget_23113
game_flow_strget_23338:
    mov edx, dword ptr [esp + 56]
    cmp dx, 0x3e7
    {disp32} je game_flow_strget_23555
    cmp dx, 0x3e6
    jne game_flow_strget_23416
    xor dl, dl
    jmp game_flow_strget_23375
game_flow_strget_23364:
    {store} xor eax, eax
    {store} mov al, dl
    mov bh, 0x2a
    inc dl
    mov byte ptr [esp + eax], bh
game_flow_strget_23375:
    {store} xor eax, eax
    mov bx, word ptr [_inputloc]
    {store} mov al, dl
    {store} cmp ax, bx
    jl game_flow_strget_23364
    {store} xor eax, eax
    {store} xor ecx, ecx
    xor bl, bl
    mov cl, byte ptr [esp + 56]
    {store} mov al, dl
    movsx edx, di
    mov byte ptr [esp + eax], bl
    {store} mov ebx, esp
    movsx eax, si
    jmp game_flow_strget_23428
game_flow_strget_23416:
    movsx edx, di
    {store} xor ecx, ecx
    movsx eax, si
    mov cl, byte ptr [esp + 56]
game_flow_strget_23428:
    call gametext_
    {store} mov esi, eax
    mov eax, dword ptr [_totalclock]
    shl eax, 4
    and eax, 0x7ff
    movsx eax, word ptr [eax*2 + _sintable]
    mov edx, 4
    sar eax, 0xb
    {store} sub edx, eax
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    mov word ptr [esp + 68], dx
    push 0
    movsx eax, dx
    push 0xa
    mov edx, dword ptr [_totalclock]
    mov ebx, 7
    push 0
    sar edx, 3
    push eax
    {store} mov eax, edx
    sar edx, 0x1f
    idiv ebx
    {store} xor ecx, ecx
    mov ebx, 0x8000
    add edx, 0xafd
    movsx eax, si
    push edx
    movsx edx, di
    add eax, 8
    add edx, 4
    shl eax, 0x10
    shl edx, 0x10
    call rotatesprite_
game_flow_strget_23555:
    {store} xor eax, eax
game_flow_strget_23557:
    add esp, 0x2c
    pop edi
    pop esi
    ret 4
    {disp8} lea eax, dword ptr [eax]
displayrest_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    sub esp, 8
    {store} mov ebp, eax
    movsx edi, word ptr [_screenpeek]
    imul edi, edi, 0x552
    add edi, OFFSET FLAT:_ps
    mov edx, dword ptr [edi + 628]
    test edx, edx
    jle game_flow_displayrest_23659
    mov ebx, dword ptr [edi + 528]
    test ebx, ebx
    jne game_flow_displayrest_23659
    {store} mov ecx, edx
    mov bl, byte ptr [edi + 1358]
    {store} xor eax, eax
    or cl, 0x80
    {store} xor edx, edx
    mov al, byte ptr [edi + 1356]
    mov dl, byte ptr [edi + 1357]
    call palto_
    mov byte ptr [_restorepalette], 1
    jmp game_flow_displayrest_23729
game_flow_displayrest_23659:
    cmp byte ptr [_restorepalette], 0
    je game_flow_displayrest_23697
    mov eax, dword ptr [_ud + 0x602]
    mov edx, dword ptr [edi + 1345]
    sar eax, 2
    call setbrightness_
    xor dl, dl
    mov byte ptr [_restorepalette], dl
    jmp game_flow_displayrest_23729
game_flow_displayrest_23697:
    mov ecx, dword ptr [edi + 528]
    test ecx, ecx
    jle game_flow_displayrest_23729
    mov edx, 0x40
    sar ecx, 1
    {store} xor ebx, ebx
    {store} xor eax, eax
    add ecx, 0x80
    call palto_
game_flow_displayrest_23729:
    mov bl, byte ptr [_ud + 0x6]
    test bl, bl
    {disp32} je game_flow_displayrest_23910
    {store} mov al, bl
    cmp bl, 1
    jb game_flow_displayrest_23830
    mov ebx, dword ptr [_xdim]
    mov edx, dword ptr [_ydim]
    dec ebx
    dec edx
    cmp al, 1
    jbe game_flow_displayrest_23774
    cmp al, 2
    je game_flow_displayrest_23797
    jmp game_flow_displayrest_23830
game_flow_displayrest_23774:
    push edx
    push ebx
    push 0
    push 0
    push 0x5a
    push 0
    push 0
    {store} xor ecx, ecx
    {store} xor eax, eax
    push 0xcd0
    jmp game_flow_displayrest_23818
game_flow_displayrest_23797:
    push edx
    push ebx
    push 0
    push 0
    push 0x5a
    push 0
    push 0
    {store} xor ecx, ecx
    {store} xor eax, eax
    push 0x98d
game_flow_displayrest_23818:
    {store} xor edx, edx
    mov ebx, 0x10000
    call rotatesprite_
game_flow_displayrest_23830:
    cmp byte ptr [_KB_KeyDown + 0x1], 0
    {disp32} je game_flow_displayrest_25745
    xor al, al
    mov byte ptr [_KB_KeyDown + 0x1], al
    mov dx, word ptr [_ud + 0x590]
    mov byte ptr [_ud + 0x6], al
    cmp dx, 2
    jge game_flow_displayrest_23895
    cmp dword ptr [_ud + 0x5fa], 2
    je game_flow_displayrest_23895
    mov dl, 1
    mov eax, dword ptr [_ototalclock]
    mov byte ptr [_ready2send], dl
    mov dword ptr [_totalclock], eax
game_flow_displayrest_23895:
    call vscrn_
    add esp, 8
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_displayrest_23910:
    movsx ebx, word ptr [edi + 646]
    mov dl, 1
    {store} mov cl, bl
    {store} mov eax, ebx
    and cl, 7
    sar eax, 3
    shl dl, cl
    or byte ptr [eax + _show2dsector], dl
    {disp32} lea eax, dword ptr [ebx*4]
    {store} add eax, ebx
    movsx edx, word ptr [eax*8 + _sector]
    shl edx, 5
    movsx esi, word ptr [eax*8 + _sector + 0x2]
    add edx, OFFSET FLAT:_wall
    jmp game_flow_displayrest_24068
game_flow_displayrest_23973:
    movsx ebx, word ptr [edx + 12]
    test ebx, ebx
    jl game_flow_displayrest_24064
    test byte ptr [edx + 14], 0x71
    jne game_flow_displayrest_24064
    movsx eax, word ptr [edx + 10]
    shl eax, 5
    test byte ptr [eax + _wall + 0xe], 0x71
    jne game_flow_displayrest_24064
    {disp32} lea eax, dword ptr [ebx*4]
    {store} add eax, ebx
    {disp32} lea eax, dword ptr [eax*8]
    cmp word ptr [eax + _sector + 0x22], 0x7fff
    je game_flow_displayrest_24064
    mov ecx, dword ptr [eax + _sector + 0x4]
    cmp ecx, dword ptr [eax + _sector + 0x8]
    jge game_flow_displayrest_24064
    {store} mov eax, ebx
    {store} mov cl, bl
    mov bl, 1
    and cl, 7
    sar eax, 3
    shl bl, cl
    or byte ptr [eax + _show2dsector], bl
game_flow_displayrest_24064:
    dec esi
    add edx, 0x20
game_flow_displayrest_24068:
    test esi, esi
    jg game_flow_displayrest_23973
    movsx eax, word ptr [_ud + 0x58c]
    cmp eax, -1
    {disp32} jne game_flow_displayrest_24801
    cmp byte ptr [_ud + 0x585], 2
    je game_flow_displayrest_24153
    mov bx, word ptr [edi + 690]
    test bx, bx
    jl game_flow_displayrest_24119
    movsx eax, bx
    call cameratext_
    jmp game_flow_displayrest_24153
game_flow_displayrest_24119:
    movsx eax, word ptr [_screenpeek]
    call displayweapon_
    cmp word ptr [edi + 728], 0
    jne game_flow_displayrest_24153
    movsx eax, word ptr [_screenpeek]
    call displaymasks_
game_flow_displayrest_24153:
    cmp byte ptr [_ud + 0x585], 0
    {disp32} jbe game_flow_displayrest_24801
    test ebp, ebp
    jle game_flow_displayrest_24174
    {store} mov eax, ebp
    jmp game_flow_displayrest_24176
game_flow_displayrest_24174:
    {store} xor eax, eax
game_flow_displayrest_24176:
    .att_syntax prefix
    cmpl $game_math_displayrest_24176,%eax
    .intel_syntax noprefix
    jge game_flow_displayrest_24195
    test ebp, ebp
    jle game_flow_displayrest_24191
    {store} mov ecx, ebp
    jmp game_flow_displayrest_24200
game_flow_displayrest_24191:
    {store} xor ecx, ecx
    jmp game_flow_displayrest_24200
game_flow_displayrest_24195:
    mov ecx, 0x10000
game_flow_displayrest_24200:
    {store} mov eax, ecx
    call dointerpolations_
    mov bh, byte ptr [_ud + 0x7]
    {store} mov ebp, ecx
    test bh, bh
    {disp32} jne game_flow_displayrest_24517
    movsx eax, word ptr [edi + 690]
    cmp eax, -1
    {disp32} jne game_flow_displayrest_24489
    mov ax, word ptr [_screenpeek]
    cmp ax, word ptr [_myconnectindex]
    {disp32} jne game_flow_displayrest_24382
    cmp word ptr [_numplayers], 1
    jle game_flow_displayrest_24382
    mov eax, dword ptr [_myx]
    mov esi, dword ptr [_omyx]
    {store} mov ebx, ecx
    {store} sub eax, esi
    imul ebx
    shrd eax, edx, 0x10
    mov esi, dword ptr [_omyx]
    mov ebp, dword ptr [_omyy]
    {store} add esi, eax
    mov eax, dword ptr [_myy]
    {store} sub eax, ebp
    imul ebx
    shrd eax, edx, 0x10
    mov edx, dword ptr [_omyy]
    {store} add edx, eax
    movsx eax, word ptr [_myang]
    mov dword ptr [esp + 4], edx
    movsx edx, word ptr [_omyang]
    .att_syntax prefix
    addl $game_math_displayrest_24342,%eax
    .intel_syntax noprefix
    {store} sub eax, edx
    and eax, 0x7ff
    sub eax, 0x400
    imul ebx
    shrd eax, edx, 0x10
    movsx edx, word ptr [_omyang]
    {store} add edx, eax
    mov dword ptr [esp], edx
    {disp32} jmp game_flow_displayrest_24634
game_flow_displayrest_24382:
    mov eax, dword ptr [edi + 532]
    sub eax, dword ptr [edi + 568]
    {store} mov ebx, ebp
    imul ebx
    shrd eax, edx, 0x10
    mov esi, dword ptr [edi + 568]
    mov ecx, dword ptr [edi + 572]
    {store} add esi, eax
    mov eax, dword ptr [edi + 536]
    {store} sub eax, ecx
    imul ebx
    shrd eax, edx, 0x10
    mov edx, dword ptr [edi + 572]
    {store} add edx, eax
    movsx eax, word ptr [edi + 640]
    movsx ecx, word ptr [edi + 642]
    .att_syntax prefix
    addl $game_math_displayrest_24452,%eax
    .intel_syntax noprefix
    {store} sub eax, ecx
    and eax, 0x7ff
    sub eax, 0x400
    mov dword ptr [esp + 4], edx
    imul ebx
    shrd eax, edx, 0x10
    {store} add ecx, eax
    mov dword ptr [esp], ecx
    {disp32} jmp game_flow_displayrest_24634
game_flow_displayrest_24489:
    mov eax, dword ptr [edi + 572]
    mov dword ptr [esp + 4], eax
    movsx eax, word ptr [edi + 642]
    mov esi, dword ptr [edi + 568]
    mov dword ptr [esp], eax
    jmp game_flow_displayrest_24634
game_flow_displayrest_24517:
    mov eax, dword ptr [_ud + 0x5a6]
    mov ebp, dword ptr [_ud + 0x5b2]
    sar eax, 3
    {store} add ebp, eax
    mov eax, 0xa00
    {store} sub eax, ebp
    and eax, 0x7ff
    mov ebx, dword ptr [_ud + 0x5a2]
    movsx eax, word ptr [eax*2 + _sintable]
    imul eax, ebx
    mov ecx, dword ptr [_ud + 0x5aa]
    sar eax, 0xe
    {store} add ecx, eax
    mov eax, 0x400
    {store} sub eax, ebp
    and eax, 0x7ff
    movsx eax, word ptr [eax*2 + _sintable]
    imul eax, ebx
    mov edx, dword ptr [_ud + 0x5ae]
    mov dword ptr [_ud + 0x5b2], ebp
    mov dword ptr [esp], ebp
    sar eax, 0xe
    mov dword ptr [_ud + 0x5aa], ecx
    {store} add edx, eax
    {store} mov esi, ecx
    mov dword ptr [_ud + 0x5ae], edx
    mov dword ptr [esp + 4], edx
game_flow_displayrest_24634:
    cmp byte ptr [_ud + 0x585], 2
    jne game_flow_displayrest_24666
    mov ecx, dword ptr [esp]
    {store} xor eax, eax
    mov edx, dword ptr [esp + 4]
    call clearview_
    {store} mov eax, esi
    mov ebx, dword ptr [edi]
    call drawmapview_
game_flow_displayrest_24666:
    movsx ecx, word ptr [esp]
    mov edx, dword ptr [esp + 4]
    {store} mov eax, esi
    mov ebx, dword ptr [edi]
    call drawoverheadmap_
    call restoreinterpolations_
    cmp byte ptr [_ud + 0x585], 2
    jne game_flow_displayrest_24801
    cmp dword ptr [_ud + 0x5e2], 0
    jle game_flow_displayrest_24713
    mov esi, 0x93
    jmp game_flow_displayrest_24718
game_flow_displayrest_24713:
    mov esi, 0xb6
game_flow_displayrest_24718:
    mov edx, dword ptr [_ud + 0x632]
    push 0x1a
    {store} mov eax, edx
    mov ebx, OFFSET FLAT:_volume_names
    shl eax, 5
    {store} xor ecx, ecx
    {store} add eax, edx
    lea edx, dword ptr [esi + 6]
    {store} add ebx, eax
    mov eax, 1
    call minitext_
    imul eax, dword ptr [_ud + 0x632], 0xb
    mov edx, dword ptr [_ud + 0x62e]
    {store} add edx, eax
    push 0x1a
    {store} mov eax, edx
    mov ebx, OFFSET FLAT:_level_names
    shl eax, 5
    {store} xor ecx, ecx
    {store} add eax, edx
    lea edx, dword ptr [esi + 12]
    {store} add ebx, eax
    mov eax, 1
    call minitext_
game_flow_displayrest_24801:
    movsx eax, word ptr [_screenpeek]
    call coolgaugetext_
    call operatefta_
    cmp byte ptr [_KB_KeyDown + 0x1], 0
    {disp32} je game_flow_displayrest_25176
    cmp byte ptr [_ud + 0x585], 0
    {disp32} jne game_flow_displayrest_25176
    cmp byte ptr [_ud + 0x6], 0
    {disp32} jne game_flow_displayrest_25176
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    movsx edx, word ptr [eax + _ps + 0x2b2]
    cmp edx, -1
    {disp32} jne game_flow_displayrest_25176
    mov dl, byte ptr [eax + _ps + 0x516]
    and dl, 1
    cmp dl, 1
    jne game_flow_displayrest_24989
    cmp dword ptr [_current_menu], 0x33
    jge game_flow_displayrest_24989
    xor dl, dl
    mov byte ptr [_KB_KeyDown + 0x1], dl
    mov dh, byte ptr [eax + _ps + 0x516]
    and dh, 0xfe
    mov bx, word ptr [_ud + 0x590]
    mov byte ptr [eax + _ps + 0x516], dh
    cmp bx, 2
    jge game_flow_displayrest_24972
    cmp dword ptr [_ud + 0x5fa], 2
    je game_flow_displayrest_24972
    mov bl, 1
    mov eax, dword ptr [_ototalclock]
    mov byte ptr [_ready2send], bl
    mov dword ptr [_totalclock], eax
game_flow_displayrest_24972:
    mov byte ptr [_walock + 0xffd], 0xc7
    call vscrn_
    {disp32} jmp game_flow_displayrest_25176
game_flow_displayrest_24989:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov dl, byte ptr [eax + _ps + 0x516]
    and dl, 1
    cmp dl, 1
    {disp32} je game_flow_displayrest_25176
    movsx edx, word ptr [eax + _ps + 0x2b2]
    cmp edx, -1
    {disp32} jne game_flow_displayrest_25176
    test byte ptr [eax + _ps + 0x516], 0x10
    {disp32} jne game_flow_displayrest_25176
    xor bl, bl
    mov byte ptr [_KB_KeyDown + 0x1], bl
    call FX_StopAllSounds_
    call clearsoundlocks_
    call intomenusounds_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov bh, byte ptr [eax + _ps + 0x516]
    or bh, 1
    mov dx, word ptr [_ud + 0x590]
    mov byte ptr [eax + _ps + 0x516], bh
    cmp dx, 2
    jge game_flow_displayrest_25128
    cmp dword ptr [_ud + 0x5fa], 2
    je game_flow_displayrest_25128
    mov byte ptr [_ready2send], bl
game_flow_displayrest_25128:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    test byte ptr [eax + _ps + 0x516], 4
    je game_flow_displayrest_25157
    mov eax, 0x32
    jmp game_flow_displayrest_25159
game_flow_displayrest_25157:
    {store} xor eax, eax
game_flow_displayrest_25159:
    call cmenu_
    mov ax, word ptr [_myconnectindex]
    mov word ptr [_screenpeek], ax
game_flow_displayrest_25176:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    movsx edx, word ptr [eax + _ps + 0x2b2]
    cmp edx, -1
    jne game_flow_displayrest_25308
    cmp byte ptr [_ud + 0x585], 0
    jne game_flow_displayrest_25308
    cmp dword ptr [_ud + 0x5ea], 0
    je game_flow_displayrest_25308
    movsx edx, word ptr [_ud + 0x58c]
    cmp edx, -1
    jne game_flow_displayrest_25308
    mov ebp, dword ptr [_windowy2]
    push ebp
    mov edx, dword ptr [_windowx2]
    push edx
    mov ebx, dword ptr [_windowy1]
    mov ecx, dword ptr [_windowx1]
    push ebx
    movsx eax, word ptr [eax + _ps + 0x288]
    push ecx
    sar eax, 1
    mov edx, 0xa0
    push 3
    {store} sub edx, eax
    push 0
    mov ebx, 0x10000
    {store} mov eax, edx
    push 0
    {store} xor ecx, ecx
    mov edx, 0x640000
    push 0x9db
    shl eax, 0x10
    call rotatesprite_
game_flow_displayrest_25308:
    call menus_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    test byte ptr [eax + _ps + 0x516], 0x10
    {disp32} je game_flow_displayrest_25654
    cmp dword ptr [_ud + 0x5e2], 0
    jle game_flow_displayrest_25367
    push 1
    mov ecx, 0x1e
    mov ebx, OFFSET FLAT:_typebuf
    mov edx, 0x8d
    jmp game_flow_displayrest_25384
game_flow_displayrest_25367:
    push 1
    mov ecx, 0x1e
    mov ebx, OFFSET FLAT:_typebuf
    mov edx, 0xab
game_flow_displayrest_25384:
    mov eax, 0xa0
    call strget_
    .att_syntax prefix
    cmpw $game_math_displayrest_25394,%ax
    .intel_syntax noprefix
    {disp32} jne game_flow_displayrest_25619
    xor dh, dh
    mov byte ptr [_KB_KeyDown + 0x1c], dh
    movsx eax, word ptr [_myconnectindex]
    mov byte ptr [_tempbuf + 0x1], dh
    mov byte ptr [_recbuf], dh
    mov edx, OFFSET FLAT:_ud + 0x9
    shl eax, 5
    mov bl, 4
    {store} add edx, eax
    mov eax, OFFSET FLAT:_recbuf
    mov byte ptr [_tempbuf], bl
    call strcat_
    mov edx, OFFSET FLAT:game_text_displayrest_424
    mov eax, OFFSET FLAT:_recbuf
    mov edi, OFFSET FLAT:_recbuf
    call strcat_
    mov edx, OFFSET FLAT:_typebuf
    mov eax, OFFSET FLAT:_recbuf
    xor bh, bh
    call strcat_
    mov eax, OFFSET FLAT:_recbuf
    mov edx, OFFSET FLAT:_recbuf
    call strlen_
    {store} mov esi, eax
    mov byte ptr [eax + _recbuf], bh
    mov eax, OFFSET FLAT:_tempbuf + 0x1
    mov ecx, 0xa0
    call strcat_
    mov dword ptr [_received_quote], edi
    mov word ptr [_received_quote_time], cx
    mov cx, word ptr [_connecthead]
    jmp game_flow_displayrest_25592
game_flow_displayrest_25556:
    cmp cx, word ptr [_myconnectindex]
    je game_flow_displayrest_25581
    mov edx, OFFSET FLAT:_tempbuf
    lea ebx, dword ptr [esi + 1]
    movsx eax, cx
    call sendpacket_
game_flow_displayrest_25581:
    movsx ecx, cx
    mov cx, word ptr [ecx*2 + _connectpoint2]
game_flow_displayrest_25592:
    test cx, cx
    jge game_flow_displayrest_25556
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    and byte ptr [eax + _ps + 0x516], 0xef
    jmp game_flow_displayrest_25654
game_flow_displayrest_25619:
    cwde
    cmp eax, -1
    jne game_flow_displayrest_25647
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    and byte ptr [eax + _ps + 0x516], 0xef
    jmp game_flow_displayrest_25654
game_flow_displayrest_25647:
    mov byte ptr [_pub], 1
game_flow_displayrest_25654:
    cmp word ptr [_ud + 0x588], 1
    jne game_flow_displayrest_25710
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    test byte ptr [eax + _ps + 0x516], 1
    jne game_flow_displayrest_25710
    push OFFSET FLAT:game_text_displayrest_428
    mov edx, 0x64
    mov eax, 0xa0
    {store} xor ecx, ecx
    {store} xor ebx, ebx
    call menutext_
game_flow_displayrest_25710:
    cmp dword ptr [_ud + 0x5d2], 0
    je game_flow_displayrest_25731
    movsx eax, word ptr [_screenpeek]
    call coords_
game_flow_displayrest_25731:
    cmp dword ptr [_ud + 0x5d6], 0
    je game_flow_displayrest_25745
    call tics_
game_flow_displayrest_25745:
    add esp, 8
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp8} lea eax, dword ptr [eax]
    {load} mov ecx, ecx
updatesectorz_:
    push esi
    push edi
    push ebp
    sub esp, 0x18
    {store} mov ebp, eax
    {store} mov edi, edx
    mov dword ptr [esp + 20], ebx
    mov dword ptr [esp + 8], ecx
    {store} mov eax, esp
    {store} mov ebx, edx
    push eax
    {store} mov edx, ebp
    movsx eax, word ptr [ecx]
    lea ecx, dword ptr [esp + 8]
    call getzsofslope_
    mov eax, dword ptr [esp + 20]
    cmp eax, dword ptr [esp + 4]
    jl game_flow_updatesectorz_25836
    cmp eax, dword ptr [esp]
    jg game_flow_updatesectorz_25836
    mov ebx, dword ptr [esp + 8]
    {store} mov edx, edi
    {store} mov eax, ebp
    movsx ebx, word ptr [ebx]
    call inside_
    test eax, eax
    {disp32} jne game_flow_updatesectorz_26028
game_flow_updatesectorz_25836:
    mov eax, dword ptr [esp + 8]
    mov dx, word ptr [eax]
    test dx, dx
    {disp32} jl game_flow_updatesectorz_26007
    cmp dx, word ptr [_numsectors]
    {disp32} jge game_flow_updatesectorz_26007
    movsx ebx, dx
    {disp32} lea eax, dword ptr [ebx*4]
    {store} add eax, ebx
    movsx ebx, word ptr [eax*8 + _sector]
    mov ecx, OFFSET FLAT:_wall
    shl ebx, 5
    movsx eax, word ptr [eax*8 + _sector + 0x2]
    {store} add ecx, ebx
    mov dword ptr [esp + 16], eax
    mov dword ptr [esp + 12], ecx
game_flow_updatesectorz_25911:
    mov esi, dword ptr [esp + 12]
    movsx esi, word ptr [esi + 12]
    test esi, esi
    jl game_flow_updatesectorz_25985
    {store} mov eax, esp
    lea ecx, dword ptr [esp + 4]
    {store} mov ebx, edi
    push eax
    {store} mov edx, ebp
    {store} mov eax, esi
    call getzsofslope_
    mov eax, dword ptr [esp + 20]
    cmp eax, dword ptr [esp + 4]
    jl game_flow_updatesectorz_25985
    cmp eax, dword ptr [esp]
    jg game_flow_updatesectorz_25985
    movsx ebx, si
    {store} mov edx, edi
    {store} mov eax, ebp
    call inside_
    cmp eax, 1
    jne game_flow_updatesectorz_25985
    mov eax, dword ptr [esp + 8]
    mov word ptr [eax], si
    {disp32} jmp game_flow_updatesectorz_26028
game_flow_updatesectorz_25985:
    mov ebx, dword ptr [esp + 12]
    add ebx, 0x20
    mov ecx, dword ptr [esp + 16]
    mov dword ptr [esp + 12], ebx
    dec ecx
    mov dword ptr [esp + 16], ecx
    jne game_flow_updatesectorz_25911
game_flow_updatesectorz_26007:
    movsx esi, word ptr [_numsectors]
game_flow_updatesectorz_26014:
    dec esi
    test esi, esi
    jge game_flow_updatesectorz_26035
    mov eax, dword ptr [esp + 8]
    mov word ptr [eax], 0xffff
game_flow_updatesectorz_26028:
    add esp, 0x18
    pop ebp
    pop edi
    pop esi
    ret
game_flow_updatesectorz_26035:
    {store} mov eax, esp
    lea ecx, dword ptr [esp + 4]
    {store} mov ebx, edi
    push eax
    {store} mov edx, ebp
    {store} mov eax, esi
    call getzsofslope_
    mov eax, dword ptr [esp + 20]
    cmp eax, dword ptr [esp + 4]
    jl game_flow_updatesectorz_26014
    cmp eax, dword ptr [esp]
    jg game_flow_updatesectorz_26014
    movsx ebx, si
    {store} mov edx, edi
    {store} mov eax, ebp
    call inside_
    cmp eax, 1
    jne game_flow_updatesectorz_26014
    mov eax, dword ptr [esp + 8]
    mov word ptr [eax], si
    add esp, 0x18
    pop ebp
    pop edi
    pop esi
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
    nop
view_:
    push esi
    push edi
    push ebp
    sub esp, 0x34
    mov dword ptr [esp + 32], edx
    mov dword ptr [esp + 28], ebx
    mov dword ptr [esp + 24], ecx
    movsx eax, word ptr [eax + 724]
    imul eax, eax, 0x2c
    movsx edx, word ptr [esp + 72]
    lea ebx, dword ptr [edx + 1536]
    add edx, 0x400
    and edx, 0x7ff
    movsx esi, word ptr [edx*2 + _sintable]
    movsx edx, word ptr [esp + 76]
    shl edx, 7
    sub edx, 0x3200
    mov dword ptr [esp + 20], edx
    mov edx, OFFSET FLAT:_sprite
    {store} add edx, eax
    and ebx, 0x7ff
    mov ax, word ptr [edx + 12]
    movsx edi, word ptr [ebx*2 + _sintable]
    mov dword ptr [esp + 44], eax
    and eax, 0xfffffefe
    mov dword ptr [esp + 16], edx
    mov word ptr [edx + 12], ax
    mov edx, dword ptr [esp + 28]
    mov eax, dword ptr [esp + 32]
    mov ebx, dword ptr [ecx]
    mov ecx, dword ptr [esp + 68]
    mov edx, dword ptr [edx]
    mov eax, dword ptr [eax]
    call updatesectorz_
    push 0x1000040
    lea eax, dword ptr [esp + 4]
    push eax
    lea eax, dword ptr [esp + 12]
    push eax
    lea eax, dword ptr [esp + 20]
    push eax
    lea eax, dword ptr [esp + 56]
    sar edi, 4
    push eax
    lea eax, dword ptr [esp + 56]
    sar esi, 4
    push eax
    lea eax, dword ptr [esp + 72]
    mov edx, dword ptr [esp + 44]
    push eax
    mov ecx, dword ptr [esp + 96]
    mov ebx, dword ptr [esp + 52]
    push edx
    movsx ecx, word ptr [ecx]
    mov ebx, dword ptr [ebx]
    push esi
    mov eax, dword ptr [esp + 68]
    mov edx, dword ptr [esp + 64]
    push edi
    mov eax, dword ptr [eax]
    mov edx, dword ptr [edx]
    call hitscan_
    mov eax, dword ptr [esp + 68]
    cmp word ptr [eax], 0
    {disp32} jl game_flow_view_26849
    mov eax, dword ptr [esp + 32]
    mov ebx, dword ptr [eax]
    mov eax, dword ptr [esp + 28]
    mov ecx, dword ptr [esp + 8]
    mov edx, dword ptr [eax]
    {store} mov eax, edi
    mov ebp, dword ptr [esp + 4]
    test eax, eax
    jns game_flow_view_26374
    neg eax
game_flow_view_26374:
    {store} sub ebp, edx
    {store} mov edx, eax
    {store} mov eax, esi
    {store} sub ecx, ebx
    test eax, eax
    jns game_flow_view_26388
    neg eax
game_flow_view_26388:
    {store} add edx, eax
    {store} mov eax, ecx
    mov dword ptr [esp + 12], edx
    test eax, eax
    jns game_flow_view_26402
    neg eax
game_flow_view_26402:
    {store} mov edx, eax
    {store} mov eax, ebp
    mov ebx, dword ptr [esp + 12]
    test eax, eax
    jns game_flow_view_26416
    neg eax
game_flow_view_26416:
    {store} add eax, edx
    {store} cmp eax, ebx
    {disp32} jge game_flow_view_26693
    mov edx, dword ptr [esp + 68]
    mov eax, dword ptr [esp + 48]
    mov word ptr [edx], ax
    mov ebx, dword ptr [esp + 36]
    test bx, bx
    {disp32} jl game_flow_view_26589
    movsx eax, bx
    shl eax, 5
    movsx edx, word ptr [eax + _wall + 0x8]
    shl edx, 5
    mov ebx, dword ptr [edx + _wall + 0x4]
    sub ebx, dword ptr [eax + _wall + 0x4]
    mov dword ptr [esp + 12], ebx
    mov ebx, dword ptr [edx + _wall]
    mov edx, dword ptr [eax + _wall]
    {store} mov eax, ebx
    {store} sub eax, edx
    mov edx, dword ptr [esp + 12]
    call getangle_
    cwde
    lea edx, dword ptr [eax + 1536]
    movsx eax, word ptr [eax*2 + _sintable]
    imul eax, edi
    and edx, 0x7ff
    movsx edx, word ptr [edx*2 + _sintable]
    imul edx, esi
    lea ebx, dword ptr [eax + edx]
    {store} mov eax, edi
    test eax, eax
    jns game_flow_view_26553
    neg eax
game_flow_view_26553:
    {store} mov edx, eax
    {store} mov eax, esi
    test eax, eax
    jns game_flow_view_26563
    neg eax
game_flow_view_26563:
    {store} cmp edx, eax
    jle game_flow_view_26579
    {store} mov eax, edi
    imul ebx
    shrd eax, edx, 0x1c
    {store} sub ecx, eax
    jmp game_flow_view_26635
game_flow_view_26579:
    {store} mov eax, esi
    imul ebx
    shrd eax, edx, 0x1c
    jmp game_flow_view_26633
game_flow_view_26589:
    cmp word ptr [esp + 40], 0
    jge game_flow_view_26635
    {store} mov eax, edi
    test eax, eax
    jns game_flow_view_26605
    neg eax
game_flow_view_26605:
    {store} mov edx, eax
    {store} mov eax, esi
    test eax, eax
    jns game_flow_view_26615
    neg eax
game_flow_view_26615:
    {store} cmp edx, eax
    jle game_flow_view_26628
    {store} mov eax, edi
    sar eax, 5
    {store} sub ecx, eax
    jmp game_flow_view_26635
game_flow_view_26628:
    {store} mov eax, esi
    sar eax, 5
game_flow_view_26633:
    {store} sub ebp, eax
game_flow_view_26635:
    {store} mov eax, edi
    test eax, eax
    jns game_flow_view_26643
    neg eax
game_flow_view_26643:
    {store} mov edx, eax
    {store} mov eax, esi
    test eax, eax
    jns game_flow_view_26653
    neg eax
game_flow_view_26653:
    {store} cmp edx, eax
    jle game_flow_view_26663
    {store} mov ebx, edi
    {store} mov eax, ecx
    jmp game_flow_view_26667
game_flow_view_26663:
    {store} mov ebx, esi
    {store} mov eax, ebp
game_flow_view_26667:
    {store} mov edx, eax
    sar edx, 0x10
    shl eax, 0x10
    idiv ebx
    {store} mov ebx, eax
    cmp ebx, dword ptr [_cameradist]
    jge game_flow_view_26693
    mov dword ptr [_cameradist], ebx
game_flow_view_26693:
    mov ebx, dword ptr [_cameradist]
    {store} mov eax, edi
    imul ebx
    shrd eax, edx, 0x10
    mov edx, dword ptr [esp + 32]
    add dword ptr [edx], eax
    {store} mov eax, esi
    mov ebx, dword ptr [_cameradist]
    imul ebx
    shrd eax, edx, 0x10
    mov edx, dword ptr [esp + 28]
    add dword ptr [edx], eax
    mov eax, dword ptr [esp + 20]
    mov ebx, dword ptr [_cameradist]
    imul ebx
    shrd eax, edx, 0x10
    mov edx, dword ptr [esp + 24]
    add dword ptr [edx], eax
    mov ebx, dword ptr [_totalclock]
    mov ecx, dword ptr [_cameraclock]
    {store} sub ebx, ecx
    mov esi, dword ptr [_cameradist]
    shl ebx, 0xa
    {store} add ebx, esi
    cmp ebx, 0x10000
    jge game_flow_view_26802
    mov eax, dword ptr [_totalclock]
    {store} sub eax, ecx
    shl eax, 0xa
    {store} add eax, esi
    jmp game_flow_view_26807
game_flow_view_26802:
    mov eax, 0x10000
game_flow_view_26807:
    mov dword ptr [_cameradist], eax
    mov eax, dword ptr [_totalclock]
    mov ebx, dword ptr [esp + 24]
    mov edx, dword ptr [esp + 28]
    mov ecx, dword ptr [esp + 68]
    mov dword ptr [_cameraclock], eax
    mov eax, dword ptr [esp + 32]
    mov ebx, dword ptr [ebx]
    mov edx, dword ptr [edx]
    mov eax, dword ptr [eax]
    call updatesectorz_
game_flow_view_26849:
    mov edx, dword ptr [esp + 16]
    mov eax, dword ptr [esp + 44]
    mov word ptr [edx + 12], ax
    add esp, 0x34
    pop ebp
    pop edi
    pop esi
    ret 0xc
    {disp32} lea eax, dword ptr [eax]
    {disp8} lea edx, dword ptr [edx + eiz*1]
drawbackground_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    sub esp, 0x18
    call flushperms_
    mov eax, dword ptr [_ud + 0x626]
    cmp eax, 1
    jb game_flow_drawbackground_26909
    jbe game_flow_drawbackground_26909
    cmp eax, 2
game_flow_drawbackground_26909:
    mov dword ptr [esp + 20], 0x475
    mov ebp, dword ptr [_ydim]
    {store} xor edx, edx
    mov ah, byte ptr [_ready2send]
    mov dword ptr [esp + 16], edx
    test ah, ah
    jne game_flow_drawbackground_26952
    cmp dword ptr [_ud + 0x5fa], 2
    {disp32} jne game_flow_drawbackground_27069
game_flow_drawbackground_26952:
    cmp dword ptr [_ud + 0x5de], 1
    je game_flow_drawbackground_27039
    cmp word ptr [_ud + 0x590], 1
    jle game_flow_drawbackground_27000
    mov ecx, 0xc8
    mov ebx, 8
    mov eax, dword ptr [_ydim]
    mov esi, dword ptr [esp + 16]
    imul ebx
    idiv ecx
    {store} add esi, eax
    mov dword ptr [esp + 16], esi
game_flow_drawbackground_27000:
    cmp word ptr [_ud + 0x590], 4
    jle game_flow_drawbackground_27039
    mov ecx, 0xc8
    mov ebx, 8
    mov eax, dword ptr [_ydim]
    mov edi, dword ptr [esp + 16]
    imul ebx
    idiv ecx
    {store} add edi, eax
    mov dword ptr [esp + 16], edi
game_flow_drawbackground_27039:
    cmp dword ptr [_ud + 0x5e2], 8
    jl game_flow_drawbackground_27069
    mov ecx, 0xc8
    mov ebx, 0xa6
    mov eax, dword ptr [_ydim]
    imul ebx
    idiv ecx
    {store} mov ebp, eax
game_flow_drawbackground_27069:
    mov edi, dword ptr [esp + 16]
    jmp game_flow_drawbackground_27153
game_flow_drawbackground_27075:
    {store} xor esi, esi
    jmp game_flow_drawbackground_27137
game_flow_drawbackground_27079:
    lea eax, dword ptr [ebp + -1]
    push eax
    lea eax, dword ptr [ebx + -1]
    push eax
    mov ecx, dword ptr [esp + 24]
    push ecx
    push 0
    push 0xd8
    {store} mov edx, edi
    push 0
    shl edx, 0x10
    push 8
    movsx eax, word ptr [esp + 48]
    mov ebx, 0x10000
    push eax
    {store} mov eax, esi
    {store} xor ecx, ecx
    shl eax, 0x10
    call rotatesprite_
    add esi, 0x80
game_flow_drawbackground_27137:
    mov ebx, dword ptr [_xdim]
    {store} cmp esi, ebx
    jl game_flow_drawbackground_27079
    add edi, 0x80
game_flow_drawbackground_27153:
    {store} cmp edi, ebp
    jl game_flow_drawbackground_27075
    cmp dword ptr [_ud + 0x5e2], 8
    {disp32} jle game_flow_drawbackground_27811
    mov ebx, dword ptr [_ud + 0x5de]
    {store} xor edi, edi
    cmp ebx, 1
    je game_flow_drawbackground_27211
    cmp word ptr [_ud + 0x590], 1
    jle game_flow_drawbackground_27198
    mov edi, 8
game_flow_drawbackground_27198:
    cmp word ptr [_ud + 0x590], 4
    jle game_flow_drawbackground_27211
    add edi, 8
game_flow_drawbackground_27211:
    mov eax, dword ptr [_windowx1]
    sub eax, 4
    test eax, eax
    jg game_flow_drawbackground_27225
    {store} xor eax, eax
game_flow_drawbackground_27225:
    mov dword ptr [esp + 8], eax
    mov eax, dword ptr [_windowy1]
    sub eax, 4
    {store} cmp eax, edi
    jg game_flow_drawbackground_27243
    {store} mov eax, edi
game_flow_drawbackground_27243:
    mov edx, dword ptr [_xdim]
    mov dword ptr [esp + 16], eax
    mov eax, dword ptr [_windowx2]
    dec edx
    add eax, 4
    {store} cmp eax, edx
    jl game_flow_drawbackground_27268
    {store} mov eax, edx
game_flow_drawbackground_27268:
    mov ecx, 0xc8
    mov ebx, 0xa6
    mov dword ptr [esp + 12], eax
    mov eax, dword ptr [_ydim]
    imul ebx
    idiv ecx
    {store} mov edx, eax
    mov eax, dword ptr [_windowy2]
    dec edx
    add eax, 4
    {store} cmp eax, edx
    jge game_flow_drawbackground_27310
    {store} mov ebp, eax
    jmp game_flow_drawbackground_27322
game_flow_drawbackground_27310:
    mov eax, dword ptr [_ydim]
    imul ebx
    idiv ecx
    lea ebp, dword ptr [eax + -1]
game_flow_drawbackground_27322:
    mov edi, dword ptr [esp + 16]
    mov esi, dword ptr [esp + 16]
    add edi, 4
    jmp game_flow_drawbackground_27438
game_flow_drawbackground_27335:
    push ebp
    mov ecx, dword ptr [esp + 16]
    push ecx
    push esi
    mov eax, dword ptr [esp + 20]
    push eax
    push 0xd8
    push 0
    mov ebx, 0x10000
    {store} mov edx, edi
    push 0
    shl edx, 0x10
    {store} xor ecx, ecx
    push 0xcb2
    shl eax, 0x10
    call rotatesprite_
    push ebp
    mov edx, dword ptr [esp + 16]
    push edx
    push esi
    mov ecx, dword ptr [esp + 20]
    push ecx
    add edi, 0x40
    push 0xd8
    mov eax, dword ptr [esp + 32]
    mov ebx, 0x10000
    push 0
    inc eax
    {store} mov edx, edi
    push 0
    shl eax, 0x10
    push 0xcb2
    shl edx, 0x10
    mov ecx, 0x400
    call rotatesprite_
game_flow_drawbackground_27438:
    lea eax, dword ptr [ebp + -4]
    {store} cmp edi, eax
    jl game_flow_drawbackground_27335
    mov esi, dword ptr [esp + 8]
    add esi, 4
    jmp game_flow_drawbackground_27569
game_flow_drawbackground_27454:
    push ebp
    mov eax, dword ptr [esp + 16]
    push eax
    mov edx, dword ptr [esp + 24]
    push edx
    mov ebx, dword ptr [esp + 20]
    push ebx
    push 0xd8
    mov ecx, 0x200
    push 0
    lea eax, dword ptr [esi + 64]
    mov edx, dword ptr [esp + 28]
    push 0
    mov dword ptr [esp + 28], eax
    mov ebx, 0x10000
    push 0xcb2
    shl eax, 0x10
    call rotatesprite_
    push ebp
    mov ecx, dword ptr [esp + 16]
    push ecx
    mov eax, dword ptr [esp + 24]
    push eax
    mov edx, dword ptr [esp + 20]
    push edx
    push 0xd8
    mov ebx, 0x10000
    push 0
    mov ecx, 0x600
    {store} mov eax, esi
    push 0
    shl eax, 0x10
    push 0xcb2
    {store} mov edx, edi
    mov esi, dword ptr [esp + 32]
    call rotatesprite_
game_flow_drawbackground_27569:
    mov eax, dword ptr [esp + 12]
    mov edx, dword ptr [esp + 16]
    lea edi, dword ptr [ebp + 1]
    sub eax, 4
    shl edx, 0x10
    shl edi, 0x10
    mov dword ptr [esp + 4], edx
    {store} cmp esi, eax
    {disp32} jl game_flow_drawbackground_27454
    push ebp
    mov esi, dword ptr [esp + 16]
    push esi
    mov eax, dword ptr [esp + 24]
    push eax
    mov edx, dword ptr [esp + 20]
    push edx
    push 0xd8
    mov ebx, 0x10000
    push 0
    {store} xor ecx, ecx
    {store} mov eax, edx
    push 0
    shl eax, 0x10
    push 0xcb3
    mov edx, dword ptr [esp + 36]
    mov dword ptr [esp + 32], eax
    call rotatesprite_
    push ebp
    push esi
    mov ecx, dword ptr [esp + 24]
    push ecx
    {store} mov ebx, esi
    mov esi, dword ptr [esp + 20]
    push esi
    push 0xd8
    mov edx, dword ptr [esp + 24]
    {store} mov esi, ebx
    push 0
    mov ecx, 0x200
    inc esi
    push 0
    shl esi, 0x10
    push 0xcb3
    mov ebx, 0x10000
    {store} mov eax, esi
    call rotatesprite_
    push ebp
    mov eax, dword ptr [esp + 16]
    push eax
    mov edx, dword ptr [esp + 24]
    push edx
    mov ebx, dword ptr [esp + 20]
    push ebx
    push 0xd8
    push 0
    push 0
    mov ecx, 0x400
    {store} mov eax, esi
    push 0xcb3
    {store} mov edx, edi
    mov ebx, 0x10000
    call rotatesprite_
    push ebp
    mov ecx, dword ptr [esp + 16]
    push ecx
    mov esi, dword ptr [esp + 24]
    push esi
    mov ebp, dword ptr [esp + 20]
    push ebp
    push 0xd8
    push 0
    push 0
    mov ebx, 0x10000
    mov eax, dword ptr [esp + 28]
    push 0xcb3
    {store} mov edx, edi
    mov ecx, 0x600
    call rotatesprite_
game_flow_drawbackground_27811:
    add esp, 0x18
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp8} lea eax, dword ptr [eax]
displayrooms_:
    push ebx
    push ecx
    push esi
    push edi
    push ebp
    sub esp, 0x38
    {store} mov edi, eax
    mov dword ptr [esp + 32], edx
    cwde
    imul eax, eax, 0x552
    mov ebp, OFFSET FLAT:_ps
    {store} add ebp, eax
    cmp byte ptr [_screencapt], 0
    jne game_flow_displayrooms_27896
    test byte ptr [ebp + 1302], 1
    je game_flow_displayrooms_27896
    mov eax, dword ptr [_current_menu]
    {store} mov edx, eax
    mov ebx, 0x64
    sar edx, 0x1f
    idiv ebx
    cmp eax, 3
    {disp32} je game_flow_displayrooms_30558
game_flow_displayrooms_27896:
    cmp byte ptr [_pub], 0
    jbe game_flow_displayrooms_27927
    cmp dword ptr [_ud + 0x5e2], 8
    jle game_flow_displayrooms_27919
    call drawbackground_
game_flow_displayrooms_27919:
    xor bl, bl
    mov byte ptr [_pub], bl
game_flow_displayrooms_27927:
    cmp byte ptr [_ud + 0x585], 2
    {disp32} je game_flow_displayrooms_30558
    cmp byte ptr [_ud + 0x6], 0
    {disp32} jne game_flow_displayrooms_30558
    movsx eax, word ptr [ebp + 646]
    cmp eax, -1
    {disp32} je game_flow_displayrooms_30558
    mov ebx, dword ptr [esp + 32]
    test ebx, ebx
    jle game_flow_displayrooms_27981
    {store} mov eax, ebx
    jmp game_flow_displayrooms_27983
game_flow_displayrooms_27981:
    {store} xor eax, eax
game_flow_displayrooms_27983:
    .att_syntax prefix
    cmpl $game_math_displayrooms_27983,%eax
    .intel_syntax noprefix
    jge game_flow_displayrooms_28006
    mov ecx, dword ptr [esp + 32]
    test ecx, ecx
    jle game_flow_displayrooms_28002
    {store} mov eax, ecx
    jmp game_flow_displayrooms_28011
game_flow_displayrooms_28002:
    {store} xor eax, eax
    jmp game_flow_displayrooms_28011
game_flow_displayrooms_28006:
    mov eax, 0x10000
game_flow_displayrooms_28011:
    mov dword ptr [esp + 32], eax
    mov eax, dword ptr [ebp + 616]
    mov dx, word ptr [_ud + 0x588]
    mov dword ptr [_visibility], eax
    test dx, dx
    jne game_flow_displayrooms_28059
    movsx eax, di
    imul eax, eax, 0x552
    movsx eax, word ptr [eax + _ps + 0x2d2]
    cmp eax, -1
    jle game_flow_displayrooms_28067
game_flow_displayrooms_28059:
    mov dword ptr [esp + 32], 0x10000
game_flow_displayrooms_28067:
    mov ax, word ptr [ebp + 646]
    mov dword ptr [esp + 40], eax
    test ax, ax
    {disp32} jl game_flow_displayrooms_30558
    .att_syntax prefix
    cmpw $game_math_displayrooms_28087,%ax
    .intel_syntax noprefix
    {disp32} jge game_flow_displayrooms_30558
    mov eax, dword ptr [esp + 32]
    call dointerpolations_
    call animatecamsprite_
    mov si, word ptr [_ud + 0x58c]
    test si, si
    {disp32} jl game_flow_displayrooms_28306
    movsx eax, si
    imul eax, eax, 0x2c
    mov esi, OFFSET FLAT:_sprite
    {store} add esi, eax
    mov cx, word ptr [esi + 34]
    test cx, cx
    jge game_flow_displayrooms_28157
    mov word ptr [esi + 34], 0xff9c
    jmp game_flow_displayrooms_28170
game_flow_displayrooms_28157:
    cmp cx, 0xc7
    jle game_flow_displayrooms_28170
    mov word ptr [esi + 34], 0x12c
game_flow_displayrooms_28170:
    movsx edx, word ptr [_ud + 0x58c]
    {disp32} lea ecx, dword ptr [edx*8]
    {store} add ecx, edx
    {disp32} lea ecx, dword ptr [ecx*8]
    movsx eax, word ptr [esi + 28]
    {store} sub ecx, edx
    .att_syntax prefix
    addl $game_math_displayrooms_28199,%eax
    .intel_syntax noprefix
    movsx edx, word ptr [ecx + _hittype + 0xb]
    {store} sub eax, edx
    and eax, 0x7ff
    mov ebx, dword ptr [esp + 32]
    sub eax, 0x400
    imul ebx
    shrd eax, edx, 0x10
    mov dx, word ptr [ecx + _hittype + 0xb]
    mov ebx, dword ptr [esi + 8]
    {store} add edx, eax
    sub ebx, 0x400
    mov dword ptr [esp + 48], edx
    movsx eax, word ptr [esi + 24]
    movsx edi, dx
    push eax
    movsx eax, word ptr [esi + 34]
    {store} mov ecx, edi
    push eax
    mov edx, dword ptr [esi + 4]
    mov eax, dword ptr [esi]
    call drawrooms_
    mov ecx, dword ptr [esp + 32]
    {store} mov ebx, edi
    mov edx, dword ptr [esi + 4]
    mov eax, dword ptr [esi]
    call animatesprites_
    call drawmasks_
    {disp32} jmp game_flow_displayrooms_30477
game_flow_displayrooms_28306:
    movsx eax, word ptr [ebp + 724]
    imul eax, eax, 0x2c
    {store} xor ebx, ebx
    mov bl, byte ptr [eax + _sprite + 0x15]
    mov eax, 1
    add ebx, 0x1c
    {store} mov edx, eax
    sar edx, 0xa
    shl eax, 0x16
    idiv ebx
    cmp eax, dword ptr [_oyrepeat]
    je game_flow_displayrooms_28366
    mov edx, dword ptr [_yxaspect]
    mov dword ptr [_oyrepeat], eax
    call setaspect_
game_flow_displayrooms_28366:
    cmp byte ptr [_screencapt], 0
    je game_flow_displayrooms_28438
    mov ah, 0xff
    mov esi, dword ptr [_waloff + 0x3ff4]
    mov byte ptr [_walock + 0xffd], ah
    test esi, esi
    jne game_flow_displayrooms_28413
    mov ebx, OFFSET FLAT:_walock + 0xffd
    mov edx, 0x3e80
    mov eax, OFFSET FLAT:_waloff + 0x3ff4
    call allocache_
game_flow_displayrooms_28413:
    mov ebx, 0xa0
    mov edx, 0x64
    mov eax, 0xffd
    call setviewtotile_
    {disp32} jmp game_flow_displayrooms_28759
game_flow_displayrooms_28438:
    cmp dword ptr [_ud + 0x5be], 0
    je game_flow_displayrooms_28457
    cmp word ptr [ebp + 1268], 0
    jne game_flow_displayrooms_28470
game_flow_displayrooms_28457:
    cmp dword ptr [_ud + 0x61a], 0
    {disp32} jne game_flow_displayrooms_28759
game_flow_displayrooms_28470:
    cmp dword ptr [_ud + 0x5be], 0
    je game_flow_displayrooms_28492
    mov ax, word ptr [ebp + 1268]
    mov dword ptr [esp + 44], eax
    jmp game_flow_displayrooms_28498
game_flow_displayrooms_28492:
    {store} xor edx, edx
    mov dword ptr [esp + 44], edx
game_flow_displayrooms_28498:
    mov byte ptr [_walock + 0xffe], 0xff
    cmp dword ptr [_waloff + 0x3ff8], 0
    jne game_flow_displayrooms_28534
    mov ebx, OFFSET FLAT:_walock + 0xffe
    mov edx, 0x19000
    mov eax, OFFSET FLAT:_waloff + 0x3ff8
    call allocache_
game_flow_displayrooms_28534:
    mov edx, 1
    sub edx, dword ptr [_ud + 0x61a]
    mov eax, 0x140
    {store} mov cl, dl
    mov ebx, dword ptr [esp + 44]
    sar eax, cl
    test bx, 0x3ff
    jne game_flow_displayrooms_28581
    mov edx, 0xc8
    {store} mov ebx, eax
    mov eax, 0xffe
    sar edx, cl
    jmp game_flow_displayrooms_28590
game_flow_displayrooms_28581:
    {store} mov ebx, eax
    {store} mov edx, eax
    mov eax, 0xffe
game_flow_displayrooms_28590:
    call setviewtotile_
    mov eax, dword ptr [esp + 44]
    and ah, 3
    .att_syntax prefix
    cmpw $game_math_displayrooms_28602,%ax
    .intel_syntax noprefix
    jne game_flow_displayrooms_28685
    mov eax, 1
    sub eax, dword ptr [_ud + 0x61a]
    mov ebx, 0x3c
    {store} mov cl, al
    mov esi, 0x104
    sar ebx, cl
    sar esi, cl
    dec ebx
    jmp game_flow_displayrooms_28681
game_flow_displayrooms_28638:
    mov eax, 1
    lea edx, dword ptr [ebx + esi]
    mov word ptr [ebx*2 + _startumost], ax
    mov word ptr [edx*2 + _startumost], ax
    {store} xor eax, eax
    mov word ptr [ebx*2 + _startdmost], ax
    dec ebx
    mov word ptr [edx*2 + _startdmost], ax
game_flow_displayrooms_28681:
    test ebx, ebx
    jge game_flow_displayrooms_28638
game_flow_displayrooms_28685:
    mov eax, dword ptr [esp + 44]
    and ah, 1
    movsx ebx, ax
    cmp ebx, 0x100
    jle game_flow_displayrooms_28712
    mov eax, 0x200
    {store} sub eax, ebx
    {store} mov ebx, eax
game_flow_displayrooms_28712:
    movsx eax, word ptr [ebx*2 + _sintable + 0x400]
    movsx edx, word ptr [ebx*2 + _sintable]
    {disp32} lea ecx, dword ptr [eax*8]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    {store} add eax, ecx
    mov edx, dword ptr [_yxaspect]
    sar eax, 1
    call setaspect_
game_flow_displayrooms_28759:
    cmp di, word ptr [_myconnectindex]
    {disp32} jne game_flow_displayrooms_29012
    cmp word ptr [_numplayers], 1
    {disp32} jle game_flow_displayrooms_29012
    mov eax, dword ptr [_myx]
    sub eax, dword ptr [_omyx]
    mov ebx, dword ptr [esp + 32]
    imul ebx
    shrd eax, edx, 0x10
    mov edx, dword ptr [_omyx]
    mov ecx, dword ptr [_omyy]
    {store} add edx, eax
    mov eax, dword ptr [_myy]
    {store} sub eax, ecx
    mov dword ptr [esp + 24], edx
    imul ebx
    shrd eax, edx, 0x10
    mov edx, dword ptr [_omyy]
    mov esi, dword ptr [_omyz]
    {store} add edx, eax
    mov eax, dword ptr [_myz]
    {store} sub eax, esi
    mov dword ptr [esp + 20], edx
    imul ebx
    shrd eax, edx, 0x10
    mov edx, dword ptr [_omyz]
    {store} add edx, eax
    movsx eax, word ptr [_myang]
    mov dword ptr [esp + 16], edx
    movsx edx, word ptr [_omyang]
    .att_syntax prefix
    addl $game_math_displayrooms_28895,%eax
    .intel_syntax noprefix
    {store} sub eax, edx
    and eax, 0x7ff
    sub eax, 0x400
    imul ebx
    shrd eax, edx, 0x10
    mov dx, word ptr [_omyang]
    {store} add edx, eax
    movsx eax, word ptr [_myhorizoff]
    mov dword ptr [esp + 48], edx
    movsx edx, word ptr [_myhoriz]
    {store} add eax, edx
    movsx edx, word ptr [_omyhoriz]
    mov cx, word ptr [_omyhoriz]
    {store} sub eax, edx
    mov bx, word ptr [_omyhorizoff]
    {store} mov edx, eax
    movsx eax, bx
    {store} add ecx, ebx
    {store} sub edx, eax
    mov ebx, dword ptr [esp + 32]
    {store} mov eax, edx
    imul ebx
    shrd eax, edx, 0x10
    {store} add ecx, eax
    mov ax, word ptr [_mycursectnum]
    mov dword ptr [esp + 52], ecx
    mov dword ptr [esp + 40], eax
    {disp32} jmp game_flow_displayrooms_29222
game_flow_displayrooms_29012:
    mov eax, dword ptr [ebp + 532]
    mov edi, dword ptr [ebp + 568]
    mov ebx, dword ptr [esp + 32]
    {store} sub eax, edi
    imul ebx
    shrd eax, edx, 0x10
    mov edx, dword ptr [ebp + 568]
    {store} add edx, eax
    mov dword ptr [esp + 24], edx
    mov eax, dword ptr [ebp + 536]
    sub eax, dword ptr [ebp + 572]
    imul ebx
    shrd eax, edx, 0x10
    mov edx, dword ptr [ebp + 572]
    {store} add edx, eax
    mov dword ptr [esp + 20], edx
    mov eax, dword ptr [ebp + 540]
    sub eax, dword ptr [ebp + 576]
    mov ebx, dword ptr [esp + 32]
    imul ebx
    shrd eax, edx, 0x10
    mov edx, dword ptr [ebp + 576]
    {store} add edx, eax
    mov dword ptr [esp + 16], edx
    movsx edx, word ptr [ebp + 640]
    movsx eax, word ptr [ebp + 642]
    add edx, 0x400
    {store} sub edx, eax
    {store} mov eax, edx
    and eax, 0x7ff
    sub eax, 0x400
    imul ebx
    shrd eax, edx, 0x10
    mov dx, word ptr [ebp + 642]
    mov cx, word ptr [ebp + 548]
    mov esi, dword ptr [ebp + 544]
    {store} add edx, eax
    mov edi, dword ptr [ebp + 548]
    mov dword ptr [esp + 48], edx
    movsx eax, word ptr [ebp + 686]
    mov dx, word ptr [ebp + 552]
    {store} add eax, esi
    {store} add ecx, edx
    {store} sub eax, edi
    sub eax, dword ptr [ebp + 552]
    imul ebx
    shrd eax, edx, 0x10
    {store} add ecx, eax
    mov dword ptr [esp + 52], ecx
game_flow_displayrooms_29222:
    mov ecx, dword ptr [esp + 48]
    add cx, word ptr [ebp + 648]
    mov si, word ptr [ebp + 690]
    mov dword ptr [esp + 48], ecx
    test si, si
    jl game_flow_displayrooms_29349
    mov ax, word ptr [ebp + 640]
    add ax, word ptr [ebp + 648]
    mov bx, word ptr [ebp + 686]
    mov dword ptr [esp + 48], eax
    mov ax, word ptr [ebp + 544]
    {store} add eax, ebx
    mov dword ptr [esp + 52], eax
    mov eax, dword ptr [ebp + 532]
    mov dword ptr [esp + 24], eax
    mov eax, dword ptr [ebp + 536]
    mov dword ptr [esp + 20], eax
    mov eax, dword ptr [ebp + 540]
    mov dword ptr [esp + 16], eax
    movsx eax, word ptr [ebp + 690]
    imul eax, eax, 0x2c
    mov ecx, 0x10000
    mov ax, word ptr [eax + _sprite + 0x18]
    mov dword ptr [esp + 32], ecx
    mov dword ptr [esp + 40], eax
    jmp game_flow_displayrooms_29437
game_flow_displayrooms_29349:
    cmp word ptr [ebp + 728], 0
    jne game_flow_displayrooms_29403
    mov eax, dword ptr [ebp + 580]
    mov edi, dword ptr [ebp + 584]
    mov ebx, dword ptr [esp + 32]
    {store} sub eax, edi
    imul ebx
    shrd eax, edx, 0x10
    mov edx, dword ptr [ebp + 584]
    mov ebx, dword ptr [esp + 16]
    {store} add eax, edx
    {store} add ebx, eax
    mov dword ptr [esp + 16], ebx
    jmp game_flow_displayrooms_29437
game_flow_displayrooms_29403:
    movsx eax, word ptr [esp + 52]
    push eax
    movsx eax, cx
    lea ebx, dword ptr [esp + 24]
    push eax
    lea eax, dword ptr [esp + 48]
    lea edx, dword ptr [esp + 32]
    push eax
    lea ecx, dword ptr [esp + 28]
    {store} mov eax, ebp
    call view_
game_flow_displayrooms_29437:
    movsx edx, word ptr [ebp + 724]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov eax, dword ptr [eax + _hittype + 0x17]
    mov dword ptr [esp + 8], eax
    movsx edx, word ptr [ebp + 724]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov eax, dword ptr [eax + _hittype + 0x13]
    mov dl, byte ptr [_earthquaketime]
    mov dword ptr [esp + 12], eax
    test dl, dl
    jbe game_flow_displayrooms_29588
    mov dh, byte ptr [ebp + 1308]
    cmp dh, 1
    jne game_flow_displayrooms_29588
    {store} mov al, dl
    and al, dh
    and eax, 0xff
    mov edx, 0x100
    shl eax, 9
    mov esi, dword ptr [esp + 16]
    {store} sub edx, eax
    {store} add esi, edx
    mov al, byte ptr [_earthquaketime]
    mov dword ptr [esp + 16], esi
    and al, 2
    mov edx, 2
    xor ah, ah
    {store} sub edx, eax
    {store} mov eax, edx
    mov ecx, dword ptr [esp + 48]
    shl eax, 2
    {store} add ecx, eax
    mov dword ptr [esp + 48], ecx
game_flow_displayrooms_29588:
    movsx eax, word ptr [ebp + 724]
    imul eax, eax, 0x2c
    cmp byte ptr [eax + _sprite + 0x11], 1
    jne game_flow_displayrooms_29615
    sub dword ptr [esp + 16], 0x1200
game_flow_displayrooms_29615:
    mov si, word ptr [ebp + 690]
    test si, si
    jl game_flow_displayrooms_29652
    movsx eax, si
    imul eax, eax, 0x2c
    movsx ax, byte ptr [eax + _sprite + 0x10]
    .att_syntax prefix
    addl $game_math_displayrooms_29641,%eax
    .intel_syntax noprefix
    mov dword ptr [esp + 52], eax
    jmp game_flow_displayrooms_29719
game_flow_displayrooms_29652:
    cmp byte ptr [ebp + 1325], 0
    jne game_flow_displayrooms_29719
    mov eax, dword ptr [ebp + 608]
    mov edx, dword ptr [esp + 16]
    .att_syntax prefix
    addl $game_math_displayrooms_29671,%eax
    .intel_syntax noprefix
    {store} cmp eax, edx
    jle game_flow_displayrooms_29691
    mov eax, dword ptr [esp + 8]
    .att_syntax prefix
    addl $game_math_displayrooms_29684,%eax
    .intel_syntax noprefix
    jmp game_flow_displayrooms_29715
game_flow_displayrooms_29691:
    mov eax, dword ptr [ebp + 604]
    sub eax, 0x400
    {store} cmp eax, edx
    jge game_flow_displayrooms_29719
    mov eax, dword ptr [esp + 12]
    sub eax, 0x400
game_flow_displayrooms_29715:
    mov dword ptr [esp + 16], eax
game_flow_displayrooms_29719:
    mov edi, dword ptr [esp + 40]
    test di, di
    jl game_flow_displayrooms_29795
    lea eax, dword ptr [esp + 12]
    lea ecx, dword ptr [esp + 8]
    mov ebx, dword ptr [esp + 20]
    mov edx, dword ptr [esp + 24]
    push eax
    movsx eax, di
    call getzsofslope_
    mov eax, dword ptr [esp + 8]
    mov ecx, dword ptr [esp + 16]
    .att_syntax prefix
    addl $game_math_displayrooms_29761,%eax
    .intel_syntax noprefix
    {store} cmp eax, ecx
    jle game_flow_displayrooms_29774
    mov dword ptr [esp + 16], eax
game_flow_displayrooms_29774:
    mov eax, dword ptr [esp + 12]
    mov esi, dword ptr [esp + 16]
    sub eax, 0x400
    {store} cmp eax, esi
    jge game_flow_displayrooms_29795
    mov dword ptr [esp + 16], eax
game_flow_displayrooms_29795:
    mov eax, dword ptr [esp + 52]
    .att_syntax prefix
    cmpw $game_math_displayrooms_29799,%ax
    .intel_syntax noprefix
    jle game_flow_displayrooms_29815
    mov dword ptr [esp + 52], 0x12b
    jmp game_flow_displayrooms_29829
game_flow_displayrooms_29815:
    cwde
    cmp eax, -99
    jge game_flow_displayrooms_29829
    mov dword ptr [esp + 52], 0xffffff9d
game_flow_displayrooms_29829:
    mov al, byte ptr [_gotpic + 0x46]
    and al, 1
    test al, al
    {disp32} jbe game_flow_displayrooms_30153
    mov edi, 0x7fffffff
    {store} xor ebx, ebx
    {store} xor edx, edx
    mov dword ptr [esp + 36], edi
    jmp game_flow_displayrooms_29937
game_flow_displayrooms_29859:
    movsx ecx, dx
    movsx eax, word ptr [ecx*2 + _mirrorwall]
    shl eax, 5
    mov esi, dword ptr [esp + 24]
    mov eax, dword ptr [eax + _wall]
    {store} sub eax, esi
    test eax, eax
    jns game_flow_displayrooms_29891
    neg eax
game_flow_displayrooms_29891:
    {store} mov esi, eax
    movsx eax, word ptr [ecx*2 + _mirrorwall]
    shl eax, 5
    mov edi, dword ptr [esp + 20]
    mov eax, dword ptr [eax + _wall + 0x4]
    {store} sub eax, edi
    test eax, eax
    jns game_flow_displayrooms_29922
    neg eax
game_flow_displayrooms_29922:
    {store} add esi, eax
    cmp esi, dword ptr [esp + 36]
    jge game_flow_displayrooms_29936
    mov dword ptr [esp + 36], esi
    {store} mov ebx, ecx
game_flow_displayrooms_29936:
    inc edx
game_flow_displayrooms_29937:
    cmp dx, word ptr [_mirrorcnt]
    jl game_flow_displayrooms_29859
    {disp32} lea edi, dword ptr [ebx*2]
    movsx eax, word ptr [edi + _mirrorwall]
    {store} mov edx, eax
    shl edx, 5
    cmp word ptr [edx + _wall + 0x12], 0x230
    {disp32} jne game_flow_displayrooms_30146
    lea edx, dword ptr [esp + 44]
    push edx
    lea edx, dword ptr [esp + 4]
    push edx
    lea edx, dword ptr [esp + 12]
    push edx
    movsx edx, word ptr [edi + _mirrorsector]
    push edx
    movsx ecx, word ptr [esp + 64]
    mov ebx, dword ptr [esp + 32]
    push eax
    movsx eax, word ptr [esp + 72]
    mov edx, dword ptr [esp + 40]
    push eax
    mov dword ptr [esp + 52], eax
    mov eax, dword ptr [esp + 48]
    call preparemirror_
    mov esi, dword ptr [_visibility]
    {store} mov eax, esi
    {store} mov edx, esi
    sar eax, 1
    sar edx, 2
    {store} add eax, edx
    mov dword ptr [_visibility], eax
    movsx eax, word ptr [edi + _mirrorsector]
    movsx ecx, word ptr [esp + 44]
    push eax
    mov edx, dword ptr [esp + 32]
    mov ebx, dword ptr [esp + 20]
    push edx
    mov eax, dword ptr [esp + 12]
    mov edx, dword ptr [esp + 8]
    call drawrooms_
    mov cl, 1
    movsx ebx, word ptr [esp + 44]
    mov edx, dword ptr [esp]
    mov eax, dword ptr [esp + 4]
    mov byte ptr [_display_mirror], cl
    mov ecx, dword ptr [esp + 32]
    call animatesprites_
    xor ch, ch
    mov byte ptr [_display_mirror], ch
    call drawmasks_
    call completemirror_
    mov dword ptr [_visibility], esi
game_flow_displayrooms_30146:
    and byte ptr [_gotpic + 0x46], 0xfe
game_flow_displayrooms_30153:
    movsx eax, word ptr [esp + 40]
    movsx esi, word ptr [esp + 48]
    mov ebx, dword ptr [esp + 16]
    push eax
    movsx eax, word ptr [esp + 56]
    mov edx, dword ptr [esp + 24]
    push eax
    {store} mov ecx, esi
    mov eax, dword ptr [esp + 32]
    call drawrooms_
    mov ecx, dword ptr [esp + 32]
    mov edx, dword ptr [esp + 20]
    mov eax, dword ptr [esp + 24]
    {store} mov ebx, esi
    call animatesprites_
    call drawmasks_
    cmp byte ptr [_screencapt], 1
    jne game_flow_displayrooms_30248
    call setviewback_
    mov dh, 0xbe
    xor bl, bl
    mov byte ptr [_walock + 0xffd], dh
    mov byte ptr [_screencapt], bl
    {disp32} jmp game_flow_displayrooms_30477
game_flow_displayrooms_30248:
    cmp dword ptr [_ud + 0x5be], 0
    je game_flow_displayrooms_30267
    cmp word ptr [ebp + 1268], 0
    jne game_flow_displayrooms_30280
game_flow_displayrooms_30267:
    cmp dword ptr [_ud + 0x61a], 0
    {disp32} jne game_flow_displayrooms_30477
game_flow_displayrooms_30280:
    cmp dword ptr [_ud + 0x5be], 0
    je game_flow_displayrooms_30298
    mov ax, word ptr [ebp + 1268]
    jmp game_flow_displayrooms_30300
game_flow_displayrooms_30298:
    {store} xor eax, eax
game_flow_displayrooms_30300:
    mov dword ptr [esp + 44], eax
    call setviewback_
    mov eax, dword ptr [esp + 44]
    mov esi, dword ptr [_picanm + 0x3ff8]
    and ah, 1
    and esi, 0xff0000ff
    movsx ebx, ax
    mov dword ptr [_picanm + 0x3ff8], esi
    cmp ebx, 0x100
    jle game_flow_displayrooms_30354
    mov eax, 0x200
    {store} sub eax, ebx
    {store} mov ebx, eax
game_flow_displayrooms_30354:
    movsx eax, word ptr [ebx*2 + _sintable + 0x400]
    movsx edx, word ptr [ebx*2 + _sintable]
    {disp32} lea ecx, dword ptr [eax*8]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov edi, dword ptr [_ud + 0x61a]
    lea ebx, dword ptr [ecx + eax]
    mov eax, 1
    {store} sub eax, edi
    jne game_flow_displayrooms_30406
    sar ebx, 1
game_flow_displayrooms_30406:
    mov eax, dword ptr [_windowy2]
    push eax
    mov edx, dword ptr [_windowx2]
    push edx
    mov ecx, dword ptr [_windowy1]
    push ecx
    mov esi, dword ptr [_windowx1]
    push esi
    push 0x46
    push 0
    mov eax, 0xa00000
    push 0
    movsx ecx, word ptr [esp + 72]
    push 0xffe
    mov edx, 0x640000
    add ecx, 0x200
    call rotatesprite_
    mov byte ptr [_walock + 0xffe], 0xc7
game_flow_displayrooms_30477:
    call restoreinterpolations_
    mov eax, dword ptr [_totalclock]
    cmp eax, dword ptr [_lastvisinc]
    jge game_flow_displayrooms_30547
    mov edx, dword ptr [_ud + 0x596]
    mov eax, dword ptr [ebp + 616]
    {store} sub eax, edx
    test eax, eax
    jns game_flow_displayrooms_30515
    neg eax
game_flow_displayrooms_30515:
    cmp eax, 8
    jle game_flow_displayrooms_30558
    mov eax, dword ptr [_ud + 0x596]
    mov ebx, dword ptr [ebp + 616]
    {store} sub eax, ebx
    sar eax, 2
    lea ecx, dword ptr [ebx + eax]
    mov dword ptr [ebp + 616], ecx
    jmp game_flow_displayrooms_30558
game_flow_displayrooms_30547:
    mov eax, dword ptr [_ud + 0x596]
    mov dword ptr [ebp + 616], eax
game_flow_displayrooms_30558:
    add esp, 0x38
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp8} lea edx, dword ptr [edx]
LocateTheLocator_:
    push ebx
    push ecx
    {store} mov ecx, eax
    mov ax, word ptr [_headspritestat + 0xe]
game_flow_LocateTheLocator_30586:
    test ax, ax
    jl game_flow_LocateTheLocator_30640
    movsx ebx, dx
    cmp ebx, -1
    je game_flow_LocateTheLocator_30614
    movsx ebx, ax
    imul ebx, ebx, 0x2c
    cmp dx, word ptr [ebx + _sprite + 0x18]
    jne game_flow_LocateTheLocator_30629
game_flow_LocateTheLocator_30614:
    movsx ebx, ax
    imul ebx, ebx, 0x2c
    cmp cx, word ptr [ebx + _sprite + 0x26]
    je game_flow_LocateTheLocator_30645
game_flow_LocateTheLocator_30629:
    cwde
    mov ax, word ptr [eax*2 + _nextspritestat]
    jmp game_flow_LocateTheLocator_30586
game_flow_LocateTheLocator_30640:
    mov eax, 0xffffffff
game_flow_LocateTheLocator_30645:
    pop ecx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    {load} mov edx, edx
EGS_:
    push esi
    push edi
    sub esp, 4
    {store} mov esi, edx
    movsx edx, byte ptr [esp + 48]
    cwde
    call insertsprite_
    movsx edi, ax
    mov word ptr [esp], ax
    {disp32} lea eax, dword ptr [edi*8]
    {store} add eax, edi
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edi
    imul edx, edi, 0x2c
    mov dword ptr [eax + _hittype + 0x23], esi
    mov dword ptr [eax + _hittype + 0x27], ebx
    add edx, OFFSET FLAT:_sprite
    mov dword ptr [eax + _hittype + 0x2b], ecx
    mov dword ptr [edx + 4], ebx
    mov ebx, dword ptr [esp + 16]
    mov word ptr [edx + 14], bx
    mov bl, byte ptr [esp + 20]
    mov byte ptr [edx + 16], bl
    mov bl, byte ptr [esp + 24]
    mov byte ptr [edx + 20], bl
    mov bl, byte ptr [esp + 28]
    mov byte ptr [edx + 21], bl
    mov ebx, dword ptr [esp + 32]
    mov word ptr [edx + 28], bx
    mov ebx, dword ptr [esp + 36]
    mov word ptr [edx + 32], bx
    mov ebx, dword ptr [esp + 40]
    mov word ptr [edx + 36], bx
    mov ebx, dword ptr [esp + 44]
    mov dword ptr [edx], esi
    movsx esi, bx
    mov word ptr [edx + 30], bx
    imul ebx, esi, 0x2c
    mov word ptr [edx + 12], 0
    mov byte ptr [edx + 17], 0
    mov byte ptr [edx + 22], 0
    mov byte ptr [edx + 23], 0
    mov word ptr [edx + 34], 0
    mov byte ptr [edx + 18], 0
    mov word ptr [edx + 38], 0
    mov dword ptr [edx + 8], ecx
    mov ecx, 0xffffffff
    mov byte ptr [edx + 17], 0
    mov word ptr [eax + _hittype + 0xd], cx
    mov bx, word ptr [ebx + _sprite + 0xe]
    mov word ptr [eax + _hittype + 0x1], bx
    {store} xor ebx, ebx
    mov dword ptr [eax + _hittype + 0x1b], ebx
    mov dword ptr [eax + _hittype + 0x1f], ebx
    {store} xor ebx, ebx
    mov word ptr [eax + _hittype + 0x11], bx
    mov ebx, dword ptr [esp + 44]
    mov word ptr [eax + _hittype + 0x7], bx
    xor bl, bl
    mov byte ptr [eax + _hittype], bl
    xor bh, bh
    {store} xor edi, edi
    mov word ptr [eax + _hittype + 0x9], bx
    {disp32} lea ebx, dword ptr [esi*8]
    mov word ptr [eax + _hittype + 0x5], cx
    {store} add ebx, esi
    mov word ptr [eax + _hittype + 0xf], di
    {disp32} lea ebx, dword ptr [ebx*8]
    {store} xor ecx, ecx
    {store} sub ebx, esi
    mov word ptr [eax + _hittype + 0xb], cx
    mov ecx, dword ptr [ebx + _hittype + 0x13]
    mov dword ptr [eax + _hittype + 0x13], ecx
    mov ebx, dword ptr [ebx + _hittype + 0x17]
    {store} xor esi, esi
    mov dword ptr [eax + _hittype + 0x17], ebx
    mov dword ptr [eax + _hittype + 0x43], esi
    movsx ebx, word ptr [esp + 16]
    mov dword ptr [eax + _hittype + 0x3b], esi
    {disp32} lea ebx, dword ptr [ebx*4]
    mov dword ptr [eax + _hittype + 0x37], esi
    mov edi, dword ptr [ebx + _actorscrptr]
    mov dword ptr [eax + _hittype + 0x2f], esi
    test edi, edi
    je game_flow_EGS_31072
    mov cx, word ptr [edi]
    mov word ptr [edx + 42], cx
    mov ebx, dword ptr [ebx + _actorscrptr]
    mov ecx, dword ptr [ebx + 4]
    mov dword ptr [eax + _hittype + 0x3f], ecx
    mov ecx, dword ptr [ebx + 8]
    mov dword ptr [eax + _hittype + 0x33], ecx
    mov ax, word ptr [ebx + 12]
    mov word ptr [edx + 40], ax
    jmp game_flow_EGS_31096
game_flow_EGS_31072:
    mov dword ptr [eax + _hittype + 0x3f], esi
    mov dword ptr [eax + _hittype + 0x33], esi
    mov word ptr [edx + 42], 0
    mov word ptr [edx + 40], 0
game_flow_EGS_31096:
    movsx eax, word ptr [esp]
    imul edx, eax, 0x2c
    movsx ebx, word ptr [edx + _sprite + 0x18]
    mov dx, word ptr [edx + _sprite + 0x18]
    sar ebx, 3
    xor dh, dh
    movzx esi, byte ptr [ebx + _show2dsector]
    and dl, 7
    mov ebx, 1
    movsx ecx, dx
    shl ebx, cl
    mov cl, byte ptr [esp]
    mov dl, 1
    and cl, 7
    sar eax, 3
    shl dl, cl
    test esi, ebx
    je game_flow_EGS_31167
    or byte ptr [eax + _show2dsprite], dl
    jmp game_flow_EGS_31175
game_flow_EGS_31167:
    not dl
    and byte ptr [eax + _show2dsprite], dl
game_flow_EGS_31175:
    mov eax, dword ptr [esp]
    add esp, 4
    pop edi
    pop esi
    ret 0x24
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
    {load} mov eax, eax
wallswitchcheck_:
    cwde
    imul eax, eax, 0x2c
    mov ax, word ptr [eax + _sprite + 0xe]
    .att_syntax prefix
    cmpw $game_math_wallswitchcheck_31211,%ax
    .intel_syntax noprefix
    jb game_flow_wallswitchcheck_31309
    .att_syntax prefix
    cmpw $game_math_wallswitchcheck_31217,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_wallswitchcheck_31354
    .att_syntax prefix
    cmpw $game_math_wallswitchcheck_31227,%ax
    .intel_syntax noprefix
    jb game_flow_wallswitchcheck_31282
    .att_syntax prefix
    cmpw $game_math_wallswitchcheck_31233,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_wallswitchcheck_31354
    .att_syntax prefix
    cmpw $game_math_wallswitchcheck_31243,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_wallswitchcheck_31357
    .att_syntax prefix
    cmpw $game_math_wallswitchcheck_31253,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_wallswitchcheck_31354
    .att_syntax prefix
    cmpw $game_math_wallswitchcheck_31263,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_wallswitchcheck_31357
    .att_syntax prefix
    cmpw $game_math_wallswitchcheck_31273,%ax
    .intel_syntax noprefix
    jbe game_flow_wallswitchcheck_31354
    xor al, al
    ret
game_flow_wallswitchcheck_31282:
    .att_syntax prefix
    cmpw $game_math_wallswitchcheck_31282,%ax
    .intel_syntax noprefix
    jb game_flow_wallswitchcheck_31357
    .att_syntax prefix
    cmpw $game_math_wallswitchcheck_31288,%ax
    .intel_syntax noprefix
    jbe game_flow_wallswitchcheck_31354
    .att_syntax prefix
    cmpw $game_math_wallswitchcheck_31294,%ax
    .intel_syntax noprefix
    jb game_flow_wallswitchcheck_31357
    .att_syntax prefix
    cmpw $game_math_wallswitchcheck_31300,%ax
    .intel_syntax noprefix
    jbe game_flow_wallswitchcheck_31354
    xor al, al
    ret
game_flow_wallswitchcheck_31309:
    .att_syntax prefix
    cmpw $game_math_wallswitchcheck_31309,%ax
    .intel_syntax noprefix
    jb game_flow_wallswitchcheck_31348
    .att_syntax prefix
    cmpw $game_math_wallswitchcheck_31315,%ax
    .intel_syntax noprefix
    jbe game_flow_wallswitchcheck_31354
    .att_syntax prefix
    cmpw $game_math_wallswitchcheck_31321,%ax
    .intel_syntax noprefix
    jb game_flow_wallswitchcheck_31357
    .att_syntax prefix
    cmpw $game_math_wallswitchcheck_31327,%ax
    .intel_syntax noprefix
    jbe game_flow_wallswitchcheck_31354
    .att_syntax prefix
    cmpw $game_math_wallswitchcheck_31333,%ax
    .intel_syntax noprefix
    jb game_flow_wallswitchcheck_31357
    .att_syntax prefix
    cmpw $game_math_wallswitchcheck_31339,%ax
    .intel_syntax noprefix
    jbe game_flow_wallswitchcheck_31354
    xor al, al
    ret
game_flow_wallswitchcheck_31348:
    .att_syntax prefix
    cmpw $game_math_wallswitchcheck_31348,%ax
    .intel_syntax noprefix
    jne game_flow_wallswitchcheck_31357
game_flow_wallswitchcheck_31354:
    mov al, 1
    ret
game_flow_wallswitchcheck_31357:
    xor al, al
    ret
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
game_switch_animatesprites_47648:
    # Real compiler switch table: 17 named private destinations
    .long game_flow_animatesprites_51318
    .long game_flow_animatesprites_51329
    .long game_flow_animatesprites_51340
    .long game_flow_animatesprites_51351
    .long game_flow_animatesprites_51362
    .long game_flow_animatesprites_51391
    .long game_flow_animatesprites_51413
    .long game_flow_animatesprites_51380
    .long game_flow_animatesprites_51402
    .long game_flow_animatesprites_51362
game_switch_view_47688: # actual interior typed table view
    .long game_flow_animatesprites_52375
    .long game_flow_animatesprites_52409
    .long game_flow_animatesprites_52409
    .long game_flow_animatesprites_52498
    .long game_flow_animatesprites_52689
    .long game_flow_animatesprites_52574
    .long game_flow_animatesprites_52654
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
animatesprites_:
    push esi
    push edi
    push ebp
    sub esp, 0x2c
    mov dword ptr [esp + 8], eax
    mov dword ptr [esp + 12], edx
    mov dword ptr [esp + 36], ebx
    mov dword ptr [esp + 16], ecx
    {store} xor edx, edx
    mov dword ptr [esp + 32], edx
    {disp32} jmp game_flow_animatesprites_48317
game_flow_animatesprites_47761:
    imul eax, eax, 0x2c
    mov ecx, OFFSET FLAT:_tsprite
    {store} add ecx, eax
    mov di, word ptr [ecx + 30]
    movsx eax, di
    imul eax, eax, 0x2c
    mov esi, OFFSET FLAT:_sprite
    mov dx, word ptr [ecx + 14]
    {store} add esi, eax
    cmp dx, 0x3ef
    {disp32} jb game_flow_animatesprites_48017
    cmp dx, 0x3f1
    {disp32} jbe game_flow_animatesprites_48313
    cmp dx, 0x942
    jb game_flow_animatesprites_47877
    cmp dx, 0x949
    {disp32} jbe game_flow_animatesprites_47972
    cmp dx, 0xc80
    jb game_flow_animatesprites_47861
    {disp32} jbe game_flow_animatesprites_48153
    cmp dx, 0xc8a
    {disp32} je game_flow_animatesprites_48153
    {disp32} jmp game_flow_animatesprites_47928
game_flow_animatesprites_47861:
    cmp dx, 0xc76
    {disp32} je game_flow_animatesprites_48153
    {disp32} jmp game_flow_animatesprites_47928
game_flow_animatesprites_47877:
    cmp dx, 0x4ca
    jb game_flow_animatesprites_47917
    {disp32} jbe game_flow_animatesprites_48124
    cmp dx, 0x8f8
    {disp32} jb game_flow_animatesprites_47928
    cmp dx, 0x8fb
    {disp32} jbe game_flow_animatesprites_48255
    {disp32} jmp game_flow_animatesprites_47928
game_flow_animatesprites_47917:
    cmp dx, 0x416
    {disp32} je game_flow_animatesprites_48313
game_flow_animatesprites_47928:
    test byte ptr [ecx + 12], 0x10
    {disp32} jne game_flow_animatesprites_48313
    {store} mov eax, ecx
    call badguy_
    test ax, ax
    je game_flow_animatesprites_47961
    cmp word ptr [ecx + 42], 0
    {disp32} jg game_flow_animatesprites_48313
game_flow_animatesprites_47961:
    cmp word ptr [ecx + 26], 0xa
game_flow_animatesprites_47966:
    {disp32} je game_flow_animatesprites_48313
game_flow_animatesprites_47972:
    movsx edx, word ptr [ecx + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    test byte ptr [eax + _sector + 0xc], 1
    {disp32} je game_flow_animatesprites_48280
    movsx ebx, byte ptr [eax + _sector + 0x14]
    {disp32} jmp game_flow_animatesprites_48287
game_flow_animatesprites_48017:
    cmp dx, 0x2a8
    jb game_flow_animatesprites_48076
    {disp32} jbe game_flow_animatesprites_48181
    cmp dx, 0x39d
    jb game_flow_animatesprites_48064
    cmp dx, 0x39e
    {disp32} jbe game_flow_animatesprites_48313
    cmp dx, 0x3b8
    {disp32} je game_flow_animatesprites_48274
    {disp32} jmp game_flow_animatesprites_47928
game_flow_animatesprites_48064:
    cmp dx, 0x388
    je game_flow_animatesprites_48133
    {disp32} jmp game_flow_animatesprites_47928
game_flow_animatesprites_48076:
    cmp dx, 0x226
    jb game_flow_animatesprites_48108
    jbe game_flow_animatesprites_48124
    cmp dx, 0x2a0
    {disp32} jb game_flow_animatesprites_47928
    cmp dx, 0x2a2
    jbe game_flow_animatesprites_48124
    {disp32} jmp game_flow_animatesprites_47928
game_flow_animatesprites_48108:
    cmp dx, 0x222
    {disp32} jb game_flow_animatesprites_47928
    {disp32} jmp game_flow_animatesprites_48274
game_flow_animatesprites_48124:
    cmp byte ptr [ecx + 16], 0x7f
    {disp32} jmp game_flow_animatesprites_47966
game_flow_animatesprites_48133:
    mov ah, byte ptr [ecx + 12]
    mov word ptr [ecx + 14], 1
    or ah, 0x30
    mov byte ptr [ecx + 12], ah
    {disp32} jmp game_flow_animatesprites_47972
game_flow_animatesprites_48153:
    cmp dword ptr [_ud + 0x63a], 0
    {disp32} jne game_flow_animatesprites_48313
    mov byte ptr [ecx + 21], 0
    mov al, byte ptr [ecx + 21]
    mov byte ptr [ecx + 20], al
    {disp32} jmp game_flow_animatesprites_48313
game_flow_animatesprites_48181:
    movsx eax, word ptr [ecx + 28]
    movsx edx, word ptr [esp + 36]
    .att_syntax prefix
    addl $game_math_animatesprites_48190,%eax
    .intel_syntax noprefix
    {store} sub eax, edx
    and eax, 0x7ff
    sar eax, 8
    and eax, 7
    {store} mov edx, eax
    .att_syntax prefix
    cmpw $game_math_animatesprites_48210,%ax
    .intel_syntax noprefix
    jle game_flow_animatesprites_48236
    mov eax, 8
    mov bh, byte ptr [ecx + 12]
    {store} sub eax, edx
    or bh, 4
    {store} mov edx, eax
    mov byte ptr [ecx + 12], bh
    jmp game_flow_animatesprites_48240
game_flow_animatesprites_48236:
    and byte ptr [ecx + 12], 0xfb
game_flow_animatesprites_48240:
    mov ax, word ptr [esi + 14]
    {store} add eax, edx
    mov word ptr [ecx + 14], ax
    {disp32} jmp game_flow_animatesprites_47972
game_flow_animatesprites_48255:
    cmp dword ptr [_ud + 0x5e6], 0
    je game_flow_animatesprites_48274
    mov byte ptr [ecx + 21], 0
    mov al, byte ptr [ecx + 21]
    mov byte ptr [ecx + 20], al
game_flow_animatesprites_48274:
    mov byte ptr [ecx + 16], 0x10
    jmp game_flow_animatesprites_48313
game_flow_animatesprites_48280:
    movsx ebx, byte ptr [eax + _sector + 0x1c]
game_flow_animatesprites_48287:
    cmp ebx, -127
    jge game_flow_animatesprites_48297
    mov ebx, 0xffffff81
game_flow_animatesprites_48297:
    cmp ebx, 0x80
    jle game_flow_animatesprites_48310
    mov ebx, 0x7f
game_flow_animatesprites_48310:
    mov byte ptr [ecx + 16], bl
game_flow_animatesprites_48313:
    inc dword ptr [esp + 32]
game_flow_animatesprites_48317:
    movsx eax, word ptr [esp + 32]
    cmp eax, dword ptr [_spritesortcnt]
    {disp32} jl game_flow_animatesprites_47761
    {store} xor ebx, ebx
    mov dword ptr [esp + 32], ebx
    {disp32} jmp game_flow_animatesprites_54477
game_flow_animatesprites_48345:
    imul eax, eax, 0x2c
    mov ecx, OFFSET FLAT:_tsprite
    {store} add ecx, eax
    mov di, word ptr [ecx + 30]
    movsx eax, di
    imul eax, eax, 0x2c
    mov esi, OFFSET FLAT:_sprite
    {store} add esi, eax
    mov ax, word ptr [esi + 14]
    .att_syntax prefix
    cmpw $game_math_animatesprites_48376,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_animatesprites_48605
    {disp32} jbe game_flow_animatesprites_48815
    .att_syntax prefix
    cmpw $game_math_animatesprites_48392,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_animatesprites_48521
    .att_syntax prefix
    cmpw $game_math_animatesprites_48402,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_animatesprites_48815
    .att_syntax prefix
    cmpw $game_math_animatesprites_48412,%ax
    .intel_syntax noprefix
    jb game_flow_animatesprites_48480
    {disp32} jbe game_flow_animatesprites_48815
    .att_syntax prefix
    cmpw $game_math_animatesprites_48424,%ax
    .intel_syntax noprefix
    jb game_flow_animatesprites_48455
    .att_syntax prefix
    cmpw $game_math_animatesprites_48430,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_animatesprites_48815
    .att_syntax prefix
    cmpw $game_math_animatesprites_48440,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_animatesprites_48815
    {disp32} jmp game_flow_animatesprites_48828
game_flow_animatesprites_48455:
    .att_syntax prefix
    cmpw $game_math_animatesprites_48455,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_animatesprites_48828
    .att_syntax prefix
    cmpw $game_math_animatesprites_48465,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_animatesprites_48815
    {disp32} jmp game_flow_animatesprites_48828
game_flow_animatesprites_48480:
    .att_syntax prefix
    cmpw $game_math_animatesprites_48480,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_animatesprites_48828
    {disp32} jbe game_flow_animatesprites_48815
    .att_syntax prefix
    cmpw $game_math_animatesprites_48496,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_animatesprites_48828
    .att_syntax prefix
    cmpw $game_math_animatesprites_48506,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_animatesprites_48815
    {disp32} jmp game_flow_animatesprites_48828
game_flow_animatesprites_48521:
    .att_syntax prefix
    cmpw $game_math_animatesprites_48521,%ax
    .intel_syntax noprefix
    jb game_flow_animatesprites_48574
    {disp32} jbe game_flow_animatesprites_48815
    .att_syntax prefix
    cmpw $game_math_animatesprites_48533,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_animatesprites_48828
    {disp32} jbe game_flow_animatesprites_48815
    .att_syntax prefix
    cmpw $game_math_animatesprites_48549,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_animatesprites_48828
    .att_syntax prefix
    cmpw $game_math_animatesprites_48559,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_animatesprites_48815
    {disp32} jmp game_flow_animatesprites_48828
game_flow_animatesprites_48574:
    .att_syntax prefix
    cmpw $game_math_animatesprites_48574,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_animatesprites_48828
    {disp32} jbe game_flow_animatesprites_48815
    .att_syntax prefix
    cmpw $game_math_animatesprites_48590,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_animatesprites_48815
    {disp32} jmp game_flow_animatesprites_48828
game_flow_animatesprites_48605:
    .att_syntax prefix
    cmpw $game_math_animatesprites_48605,%ax
    .intel_syntax noprefix
    jb game_flow_animatesprites_48710
    .att_syntax prefix
    cmpw $game_math_animatesprites_48611,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_animatesprites_48815
    .att_syntax prefix
    cmpw $game_math_animatesprites_48621,%ax
    .intel_syntax noprefix
    jb game_flow_animatesprites_48679
    .att_syntax prefix
    cmpw $game_math_animatesprites_48627,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_animatesprites_48815
    .att_syntax prefix
    cmpw $game_math_animatesprites_48637,%ax
    .intel_syntax noprefix
    jb game_flow_animatesprites_48664
    {disp32} jbe game_flow_animatesprites_48815
    .att_syntax prefix
    cmpw $game_math_animatesprites_48649,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_animatesprites_48815
    {disp32} jmp game_flow_animatesprites_48828
game_flow_animatesprites_48664:
    .att_syntax prefix
    cmpw $game_math_animatesprites_48664,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_animatesprites_48815
    {disp32} jmp game_flow_animatesprites_48828
game_flow_animatesprites_48679:
    .att_syntax prefix
    cmpw $game_math_animatesprites_48679,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_animatesprites_48828
    {disp32} jbe game_flow_animatesprites_48815
    .att_syntax prefix
    cmpw $game_math_animatesprites_48695,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_animatesprites_48815
    {disp32} jmp game_flow_animatesprites_48828
game_flow_animatesprites_48710:
    .att_syntax prefix
    cmpw $game_math_animatesprites_48710,%ax
    .intel_syntax noprefix
    jb game_flow_animatesprites_48742
    {disp32} jbe game_flow_animatesprites_48815
    .att_syntax prefix
    cmpw $game_math_animatesprites_48722,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_animatesprites_48828
    jbe game_flow_animatesprites_48815
    .att_syntax prefix
    cmpw $game_math_animatesprites_48734,%ax
    .intel_syntax noprefix
    je game_flow_animatesprites_48815
    jmp game_flow_animatesprites_48828
game_flow_animatesprites_48742:
    .att_syntax prefix
    cmpw $game_math_animatesprites_48742,%ax
    .intel_syntax noprefix
    jb game_flow_animatesprites_48828
    jbe game_flow_animatesprites_48758
    .att_syntax prefix
    cmpw $game_math_animatesprites_48750,%ax
    .intel_syntax noprefix
    je game_flow_animatesprites_48815
    jmp game_flow_animatesprites_48828
game_flow_animatesprites_48758:
    cmp word ptr [ecx + 38], 0x1b
    jne game_flow_animatesprites_48803
    cmp dword ptr [_ud + 0x5fa], 1
    jne game_flow_animatesprites_48803
    mov eax, dword ptr [_totalclock]
    sar eax, 3
    mov dh, byte ptr [ecx + 12]
    and eax, 1
    or dh, 0x80
    add eax, 0xb
    mov byte ptr [ecx + 12], dh
    mov word ptr [ecx + 14], ax
    jmp game_flow_animatesprites_48828
game_flow_animatesprites_48803:
    mov byte ptr [ecx + 21], 0
    mov al, byte ptr [ecx + 21]
    mov byte ptr [ecx + 20], al
    jmp game_flow_animatesprites_48828
game_flow_animatesprites_48815:
    cmp dword ptr [_ud + 0x5e6], 0
    {disp32} jne game_flow_animatesprites_54463
game_flow_animatesprites_48828:
    cmp word ptr [ecx + 26], 0x63
    {disp32} je game_flow_animatesprites_54473
    cmp word ptr [esi + 26], 1
    {disp32} je game_flow_animatesprites_49031
    cmp word ptr [esi + 14], 0x57d
    {disp32} jne game_flow_animatesprites_49031
    movsx eax, word ptr [esi + 34]
    imul eax, eax, 0x552
    movsx edx, word ptr [eax + _ps + 0x2b2]
    cmp edx, -1
    {disp32} jne game_flow_animatesprites_49031
    cmp word ptr [esi + 30], 0
    {disp32} jl game_flow_animatesprites_49031
    mov ebp, 0x10000
    mov edx, dword ptr [eax + _ps + 0x214]
    mov ebx, dword ptr [eax + _ps + 0x238]
    mov eax, dword ptr [esp + 16]
    {store} sub edx, ebx
    {store} sub ebp, eax
    {store} mov ebx, edx
    {store} mov eax, ebp
    imul ebx
    shrd eax, edx, 0x10
    sub dword ptr [ecx], eax
    movsx edx, word ptr [esi + 34]
    imul edx, edx, 0x552
    mov eax, dword ptr [edx + _ps + 0x218]
    mov ebx, dword ptr [edx + _ps + 0x23c]
    {store} sub eax, ebx
    {store} mov ebx, eax
    {store} mov eax, ebp
    imul ebx
    shrd eax, edx, 0x10
    sub dword ptr [ecx + 4], eax
    movsx ebp, word ptr [esi + 34]
    imul ebp, ebp, 0x552
    mov ebx, dword ptr [ebp + _ps + 0x21c]
    mov edx, dword ptr [ebp + _ps + 0x240]
    mov eax, dword ptr [esp + 16]
    {store} sub ebx, edx
    imul ebx
    shrd eax, edx, 0x10
    {store} mov edx, eax
    mov eax, dword ptr [ebp + _ps + 0x240]
    {store} add eax, edx
    lea ebx, dword ptr [eax + 10240]
    mov dword ptr [ecx + 8], ebx
    {disp32} jmp game_flow_animatesprites_49198
game_flow_animatesprites_49031:
    cmp word ptr [esi + 26], 0
    jne game_flow_animatesprites_49046
    cmp word ptr [esi + 14], 0x4c5
    jne game_flow_animatesprites_49080
game_flow_animatesprites_49046:
    mov bx, word ptr [esi + 26]
    cmp bx, 0xa
    je game_flow_animatesprites_49080
    cmp bx, 6
    je game_flow_animatesprites_49080
    cmp bx, 4
    je game_flow_animatesprites_49080
    cmp bx, 5
    je game_flow_animatesprites_49080
    cmp bx, 1
    jne game_flow_animatesprites_49198
game_flow_animatesprites_49080:
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov dword ptr [esp + 20], eax
    mov edx, dword ptr [esp + 20]
    mov ebp, 0x10000
    mov eax, dword ptr [esi]
    mov ebx, dword ptr [edx + _hittype + 0x23]
    mov edx, dword ptr [esp + 16]
    {store} sub eax, ebx
    {store} sub ebp, edx
    {store} mov ebx, eax
    {store} mov eax, ebp
    imul ebx
    shrd eax, edx, 0x10
    sub dword ptr [ecx], eax
    mov edx, dword ptr [esp + 20]
    mov eax, dword ptr [esi + 4]
    mov ebx, dword ptr [edx + _hittype + 0x27]
    {store} sub eax, ebx
    {store} mov ebx, eax
    {store} mov eax, ebp
    imul ebx
    shrd eax, edx, 0x10
    sub dword ptr [ecx + 4], eax
    mov edx, dword ptr [esp + 20]
    mov eax, dword ptr [esi + 8]
    mov ebx, dword ptr [edx + _hittype + 0x2b]
    {store} sub eax, ebx
    {store} mov ebx, eax
    {store} mov eax, ebp
    imul ebx
    shrd eax, edx, 0x10
    sub dword ptr [ecx + 8], eax
game_flow_animatesprites_49198:
    mov ax, word ptr [esi + 24]
    movsx edx, di
    mov dword ptr [esp + 28], eax
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov edx, dword ptr [eax + _hittype + 0x33]
    mov ebp, dword ptr [eax + _hittype + 0x3f]
    mov dword ptr [esp], edx
    mov edx, dword ptr [eax + _hittype + 0x3b]
    mov ax, word ptr [esi + 14]
    mov dword ptr [esp + 4], edx
    .att_syntax prefix
    cmpw $game_math_animatesprites_49256,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_animatesprites_49650
    {disp32} jbe game_flow_animatesprites_52179
    .att_syntax prefix
    cmpw $game_math_animatesprites_49272,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_animatesprites_49522
    {disp32} jbe game_flow_animatesprites_50179
    .att_syntax prefix
    cmpw $game_math_animatesprites_49288,%ax
    .intel_syntax noprefix
    jb game_flow_animatesprites_49358
    {disp32} jbe game_flow_animatesprites_52192
    .att_syntax prefix
    cmpw $game_math_animatesprites_49300,%ax
    .intel_syntax noprefix
    jb game_flow_animatesprites_49343
    {disp32} jbe game_flow_animatesprites_54473
    .att_syntax prefix
    cmpw $game_math_animatesprites_49312,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_animatesprites_49421
    {disp32} jbe game_flow_animatesprites_49968
    .att_syntax prefix
    cmpw $game_math_animatesprites_49328,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_animatesprites_50551
    {disp32} jmp game_flow_animatesprites_49421
game_flow_animatesprites_49343:
    .att_syntax prefix
    cmpw $game_math_animatesprites_49343,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_animatesprites_52192
    {disp32} jmp game_flow_animatesprites_49421
game_flow_animatesprites_49358:
    .att_syntax prefix
    cmpw $game_math_animatesprites_49358,%ax
    .intel_syntax noprefix
    jb game_flow_animatesprites_49401
    {disp32} jbe game_flow_animatesprites_52192
    .att_syntax prefix
    cmpw $game_math_animatesprites_49370,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_animatesprites_49421
    {disp32} jbe game_flow_animatesprites_52192
    .att_syntax prefix
    cmpw $game_math_animatesprites_49386,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_animatesprites_52192
    {disp32} jmp game_flow_animatesprites_49421
game_flow_animatesprites_49401:
    .att_syntax prefix
    cmpw $game_math_animatesprites_49401,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_animatesprites_49421
    .att_syntax prefix
    cmpw $game_math_animatesprites_49411,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_animatesprites_52192
game_flow_animatesprites_49421:
    movsx edx, word ptr [esp + 28]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    mov dl, byte ptr [eax + _sector + 0x1d]
    test dl, dl
    je game_flow_animatesprites_49455
    mov byte ptr [ecx + 17], dl
game_flow_animatesprites_49455:
    movsx eax, word ptr [esi + 14]
    cmp dword ptr [eax*4 + _actorscrptr], 0
    {disp32} je game_flow_animatesprites_52811
    mov ax, word ptr [ecx + 12]
    xor ah, ah
    and al, 0x30
    .att_syntax prefix
    cmpw $game_math_animatesprites_49481,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_animatesprites_52811
    test ebp, ebp
    {disp32} je game_flow_animatesprites_52798
    mov ebx, dword ptr [ebp + 8]
    lea eax, dword ptr [ebx + -2]
    cmp eax, 6
    {disp32} ja game_flow_animatesprites_52689
    jmp dword ptr cs:[eax*4 + game_switch_view_47688]
game_flow_animatesprites_49522:
    .att_syntax prefix
    cmpw $game_math_animatesprites_49522,%ax
    .intel_syntax noprefix
    jb game_flow_animatesprites_49592
    {disp32} jbe game_flow_animatesprites_52179
    .att_syntax prefix
    cmpw $game_math_animatesprites_49534,%ax
    .intel_syntax noprefix
    jb game_flow_animatesprites_49577
    {disp32} jbe game_flow_animatesprites_52179
    .att_syntax prefix
    cmpw $game_math_animatesprites_49546,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_animatesprites_49421
    {disp32} jbe game_flow_animatesprites_50179
    .att_syntax prefix
    cmpw $game_math_animatesprites_49562,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_animatesprites_52179
    {disp32} jmp game_flow_animatesprites_49421
game_flow_animatesprites_49577:
    .att_syntax prefix
    cmpw $game_math_animatesprites_49577,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_animatesprites_52179
    {disp32} jmp game_flow_animatesprites_49421
game_flow_animatesprites_49592:
    .att_syntax prefix
    cmpw $game_math_animatesprites_49592,%ax
    .intel_syntax noprefix
    jb game_flow_animatesprites_49635
    {disp32} jbe game_flow_animatesprites_52179
    .att_syntax prefix
    cmpw $game_math_animatesprites_49604,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_animatesprites_49421
    {disp32} jbe game_flow_animatesprites_52179
    .att_syntax prefix
    cmpw $game_math_animatesprites_49620,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_animatesprites_52179
    {disp32} jmp game_flow_animatesprites_49421
game_flow_animatesprites_49635:
    .att_syntax prefix
    cmpw $game_math_animatesprites_49635,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_animatesprites_52179
    {disp32} jmp game_flow_animatesprites_49421
game_flow_animatesprites_49650:
    .att_syntax prefix
    cmpw $game_math_animatesprites_49650,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_animatesprites_49794
    {disp32} jbe game_flow_animatesprites_50810
    .att_syntax prefix
    cmpw $game_math_animatesprites_49666,%ax
    .intel_syntax noprefix
    jb game_flow_animatesprites_49736
    {disp32} jbe game_flow_animatesprites_50526
    .att_syntax prefix
    cmpw $game_math_animatesprites_49678,%ax
    .intel_syntax noprefix
    jb game_flow_animatesprites_49721
    {disp32} jbe game_flow_animatesprites_52179
    .att_syntax prefix
    cmpw $game_math_animatesprites_49690,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_animatesprites_49421
    {disp32} jbe game_flow_animatesprites_52179
    .att_syntax prefix
    cmpw $game_math_animatesprites_49706,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_animatesprites_50651
    {disp32} jmp game_flow_animatesprites_49421
game_flow_animatesprites_49721:
    .att_syntax prefix
    cmpw $game_math_animatesprites_49721,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_animatesprites_52179
    {disp32} jmp game_flow_animatesprites_49421
game_flow_animatesprites_49736:
    .att_syntax prefix
    cmpw $game_math_animatesprites_49736,%ax
    .intel_syntax noprefix
    jb game_flow_animatesprites_49779
    {disp32} jbe game_flow_animatesprites_52179
    .att_syntax prefix
    cmpw $game_math_animatesprites_49748,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_animatesprites_49421
    {disp32} jbe game_flow_animatesprites_52179
    .att_syntax prefix
    cmpw $game_math_animatesprites_49764,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_animatesprites_52179
    {disp32} jmp game_flow_animatesprites_49421
game_flow_animatesprites_49779:
    .att_syntax prefix
    cmpw $game_math_animatesprites_49779,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_animatesprites_49928
    {disp32} jmp game_flow_animatesprites_49421
game_flow_animatesprites_49794:
    .att_syntax prefix
    cmpw $game_math_animatesprites_49794,%ax
    .intel_syntax noprefix
    jb game_flow_animatesprites_49870
    {disp32} jbe game_flow_animatesprites_49940
    .att_syntax prefix
    cmpw $game_math_animatesprites_49806,%ax
    .intel_syntax noprefix
    jb game_flow_animatesprites_49855
    .att_syntax prefix
    cmpw $game_math_animatesprites_49812,%ax
    .intel_syntax noprefix
    {disp32} jbe game_flow_animatesprites_49940
    .att_syntax prefix
    cmpw $game_math_animatesprites_49822,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_animatesprites_49421
    jbe game_flow_animatesprites_49940
    .att_syntax prefix
    cmpw $game_math_animatesprites_49834,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_animatesprites_49421
    .att_syntax prefix
    cmpw $game_math_animatesprites_49844,%ax
    .intel_syntax noprefix
    jbe game_flow_animatesprites_49940
    {disp32} jmp game_flow_animatesprites_49421
game_flow_animatesprites_49855:
    .att_syntax prefix
    cmpw $game_math_animatesprites_49855,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_animatesprites_52337
    {disp32} jmp game_flow_animatesprites_49421
game_flow_animatesprites_49870:
    .att_syntax prefix
    cmpw $game_math_animatesprites_49870,%ax
    .intel_syntax noprefix
    jb game_flow_animatesprites_49913
    {disp32} jbe game_flow_animatesprites_50377
    .att_syntax prefix
    cmpw $game_math_animatesprites_49882,%ax
    .intel_syntax noprefix
    {disp32} jb game_flow_animatesprites_49421
    {disp32} jbe game_flow_animatesprites_50421
    .att_syntax prefix
    cmpw $game_math_animatesprites_49898,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_animatesprites_50421
    {disp32} jmp game_flow_animatesprites_49421
game_flow_animatesprites_49913:
    .att_syntax prefix
    cmpw $game_math_animatesprites_49913,%ax
    .intel_syntax noprefix
    {disp32} je game_flow_animatesprites_50389
    {disp32} jmp game_flow_animatesprites_49421
game_flow_animatesprites_49928:
    add dword ptr [ecx + 8], 0x1800
    {disp32} jmp game_flow_animatesprites_49455
game_flow_animatesprites_49940:
    cmp dword ptr [_ud + 0x5e6], 0
    {disp32} je game_flow_animatesprites_49455
    cmp byte ptr [esi + 17], 2
    {disp32} jne game_flow_animatesprites_49455
    {disp32} jmp game_flow_animatesprites_54463
game_flow_animatesprites_49968:
    cmp word ptr [ecx + 26], 5
    {disp32} jne game_flow_animatesprites_54473
    movsx ebx, word ptr [esi + 30]
    imul ebx, ebx, 0x2c
    movsx edx, word ptr [_screenpeek]
    imul edx, edx, 0x552
    mov ebp, dword ptr [ebx + _sprite + 0x4]
    mov edi, dword ptr [edx + _ps + 0x218]
    mov eax, dword ptr [ebx + _sprite]
    {store} sub ebp, edi
    mov ebx, dword ptr [edx + _ps + 0x214]
    {store} mov edx, ebp
    {store} sub eax, ebx
    call getangle_
    movsx ebp, word ptr [esi + 30]
    imul ebp, ebp, 0x2c
    {store} mov ebx, eax
    mov edi, dword ptr [ecx + 4]
    mov edx, dword ptr [ebp + _sprite + 0x4]
    mov eax, dword ptr [ebp + _sprite]
    mov ebp, dword ptr [ecx]
    {store} sub edx, edi
    {store} sub eax, ebp
    call getangle_
    movsx edx, ax
    movsx eax, bx
    call getincangle_
    cwde
    test eax, eax
    jns game_flow_animatesprites_50087
    neg eax
game_flow_animatesprites_50087:
    .att_syntax prefix
    cmpl $game_math_animatesprites_50087,%eax
    .intel_syntax noprefix
    {disp32} jle game_flow_animatesprites_54473
    movsx eax, word ptr [esi + 30]
    imul eax, eax, 0x2c
    {store} mov edx, ecx
    add eax, OFFSET FLAT:_sprite
    call ldist_
    {store} mov ebx, eax
    movsx eax, word ptr [esi + 30]
    imul eax, eax, 0x2c
    mov edx, OFFSET FLAT:_sprite
    {store} add edx, eax
    movsx eax, word ptr [_screenpeek]
    imul eax, eax, 0x552
    movsx eax, word ptr [eax + _ps + 0x2d4]
    imul eax, eax, 0x2c
    add eax, OFFSET FLAT:_sprite
    call ldist_
    {store} cmp ebx, eax
    {disp32} jge game_flow_animatesprites_54473
    {disp32} jmp game_flow_animatesprites_54463
game_flow_animatesprites_50179:
    movsx eax, word ptr [esi + 30]
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 0x1a], 0xa
    {disp32} jne game_flow_animatesprites_49455
    cmp byte ptr [_display_mirror], 0
    jne game_flow_animatesprites_50257
    mov bx, word ptr [_screenpeek]
    cmp bx, word ptr [eax + _sprite + 0x22]
    jne game_flow_animatesprites_50257
    movsx eax, word ptr [eax + _sprite + 0x22]
    imul eax, eax, 0x552
    cmp word ptr [eax + _ps + 0x2d8], 0
    jne game_flow_animatesprites_50257
    mov byte ptr [ecx + 20], 0
    {disp32} jmp game_flow_animatesprites_49455
game_flow_animatesprites_50257:
    mov edx, dword ptr [esp + 12]
    mov eax, dword ptr [ecx + 4]
    mov ebx, dword ptr [ecx]
    {store} sub edx, eax
    mov eax, dword ptr [esp + 8]
    {store} sub eax, ebx
    call getangle_
    mov word ptr [ecx + 28], ax
    movsx eax, word ptr [esi + 30]
    imul eax, eax, 0x2c
    mov eax, dword ptr [eax + _sprite]
    mov dword ptr [ecx], eax
    movsx eax, word ptr [esi + 30]
    imul eax, eax, 0x2c
    mov eax, dword ptr [eax + _sprite + 0x4]
    mov dword ptr [ecx + 4], eax
    movsx eax, word ptr [ecx + 28]
    .att_syntax prefix
    addl $game_math_animatesprites_50318,%eax
    .intel_syntax noprefix
    and eax, 0x7ff
    movsx eax, word ptr [eax*2 + _sintable]
    mov edx, dword ptr [ecx]
    sar eax, 0xa
    {store} add edx, eax
    mov ax, word ptr [ecx + 28]
    and ah, 7
    cwde
    mov dword ptr [ecx], edx
    movsx eax, word ptr [eax*2 + _sintable]
    mov ebx, dword ptr [ecx + 4]
    sar eax, 0xa
    {store} add ebx, eax
    mov dword ptr [ecx + 4], ebx
    {disp32} jmp game_flow_animatesprites_49455
game_flow_animatesprites_50377:
    sub dword ptr [ecx + 8], 0x400
    {disp32} jmp game_flow_animatesprites_49455
game_flow_animatesprites_50389:
    mov eax, dword ptr [_totalclock]
    shl eax, 4
    and eax, 0x7ff
    movsx eax, word ptr [eax*2 + _sintable]
    sar eax, 0xa
    mov byte ptr [ecx + 16], al
    {disp32} jmp game_flow_animatesprites_54473
game_flow_animatesprites_50421:
    cmp word ptr [_camsprite], 0
    {disp32} jl game_flow_animatesprites_49455
    movsx eax, di
    imul eax, eax, 0x2c
    movsx edx, word ptr [eax + _sprite + 0x1e]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    cmp dword ptr [eax + _hittype + 0x2f], 1
    {disp32} jne game_flow_animatesprites_49455
    mov word ptr [ecx + 14], 0x15f
    call rand_
    mov dx, word ptr [ecx + 12]
    mov bh, byte ptr [ecx + 20]
    xor ah, ah
    add bh, 8
    and al, 0xc
    mov byte ptr [ecx + 20], bh
    {store} or edx, eax
    mov al, byte ptr [ecx + 21]
    mov word ptr [ecx + 12], dx
    add al, 8
    mov byte ptr [ecx + 21], al
    {disp32} jmp game_flow_animatesprites_49455
game_flow_animatesprites_50526:
    mov eax, dword ptr [_totalclock]
    sar eax, 4
    and eax, 3
    .att_syntax prefix
    addl $game_math_animatesprites_50537,%eax
    .intel_syntax noprefix
    mov word ptr [ecx + 14], ax
    {disp32} jmp game_flow_animatesprites_49455
game_flow_animatesprites_50551:
    mov eax, dword ptr [esp + 12]
    mov edx, dword ptr [esi + 4]
    mov ebx, dword ptr [esp + 8]
    {store} sub edx, eax
    mov eax, dword ptr [esi]
    {store} sub eax, ebx
    call getangle_
    movsx edx, word ptr [esi + 28]
    cwde
    add edx, 0xc80
    {store} sub edx, eax
    and edx, 0x7ff
    mov ebx, 0xaa
    {store} mov eax, edx
    sar edx, 0x1f
    idiv ebx
    {store} mov edx, eax
    .att_syntax prefix
    cmpw $game_math_animatesprites_50606,%ax
    .intel_syntax noprefix
    jle game_flow_animatesprites_50632
    mov eax, 0xc
    mov bh, byte ptr [ecx + 12]
    {store} sub eax, edx
    or bh, 4
    {store} mov edx, eax
    mov byte ptr [ecx + 12], bh
    jmp game_flow_animatesprites_50636
game_flow_animatesprites_50632:
    and byte ptr [ecx + 12], 0xfb
game_flow_animatesprites_50636:
    add edx, 0xa2d
    mov word ptr [ecx + 14], dx
    {disp32} jmp game_flow_animatesprites_49455
game_flow_animatesprites_50651:
    mov eax, dword ptr [esp + 12]
    mov edx, dword ptr [esi + 4]
    mov ebx, dword ptr [esp + 8]
    {store} sub edx, eax
    mov eax, dword ptr [esi]
    {store} sub eax, ebx
    call getangle_
    {store} mov edx, eax
    movsx eax, di
    mov dword ptr [esp + 20], eax
    mov ebx, dword ptr [esp + 20]
    {disp32} lea eax, dword ptr [eax*8]
    {store} add eax, ebx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ebx
    cmp dword ptr [eax + _hittype + 0x2f], 4
    movsx eax, word ptr [esi + 28]
    movsx edx, dx
    .att_syntax prefix
    addl $game_math_animatesprites_50718,%eax
    .intel_syntax noprefix
    {store} sub eax, edx
    {store} mov edx, eax
    and edx, 0x7ff
    mov ebx, 0xaa
    {store} mov eax, edx
    sar edx, 0x1f
    idiv ebx
    {store} mov edx, eax
    cmp dx, 6
    jle game_flow_animatesprites_50773
    mov eax, 0xc
    mov bh, byte ptr [ecx + 12]
    {store} sub eax, edx
    or bh, 4
    {store} mov edx, eax
    mov byte ptr [ecx + 12], bh
    jmp game_flow_animatesprites_50777
game_flow_animatesprites_50773:
    and byte ptr [ecx + 12], 0xfb
game_flow_animatesprites_50777:
    mov eax, dword ptr [esp + 4]
    test eax, eax
    jns game_flow_animatesprites_50787
    neg eax
game_flow_animatesprites_50787:
    cmp eax, 0x40
    jle game_flow_animatesprites_50795
    add edx, 7
game_flow_animatesprites_50795:
    add edx, 0x7a8
    mov word ptr [ecx + 14], dx
    {disp32} jmp game_flow_animatesprites_49455
game_flow_animatesprites_50810:
    mov ax, word ptr [esi + 34]
    mov bl, byte ptr [ecx + 17]
    mov dword ptr [esp + 24], eax
    cmp bl, 1
    jne game_flow_animatesprites_50833
    sub dword ptr [ecx + 8], 0x1200
game_flow_animatesprites_50833:
    movsx eax, word ptr [esp + 24]
    imul eax, eax, 0x552
    cmp word ptr [eax + _ps + 0x2d8], 0
    {disp32} jle game_flow_animatesprites_51072
    cmp word ptr [eax + _ps + 0x2b2], 0
    {disp32} jge game_flow_animatesprites_51072
    or byte ptr [ecx + 12], 2
    mov ax, word ptr [_screenpeek]
    cmp ax, word ptr [_myconnectindex]
    {disp32} jne game_flow_animatesprites_51072
    cmp word ptr [_numplayers], 2
    {disp32} jl game_flow_animatesprites_51072
    mov eax, dword ptr [_myx]
    mov edx, dword ptr [_omyx]
    mov ebx, dword ptr [esp + 16]
    {store} sub eax, edx
    imul ebx
    shrd eax, edx, 0x10
    {store} mov edx, eax
    mov eax, dword ptr [_omyx]
    {store} add eax, edx
    mov dword ptr [ecx], eax
    mov eax, dword ptr [_myy]
    sub eax, dword ptr [_omyy]
    mov ebx, dword ptr [esp + 16]
    imul ebx
    shrd eax, edx, 0x10
    {store} mov edx, eax
    mov eax, dword ptr [_omyy]
    {store} add eax, edx
    mov dword ptr [ecx + 4], eax
    mov eax, dword ptr [_myz]
    sub eax, dword ptr [_omyz]
    imul ebx
    shrd eax, edx, 0x10
    add eax, dword ptr [_omyz]
    .att_syntax prefix
    addl $game_math_animatesprites_50999,%eax
    .intel_syntax noprefix
    mov dword ptr [ecx + 8], eax
    movsx eax, word ptr [_myang]
    movsx edx, word ptr [_omyang]
    .att_syntax prefix
    addl $game_math_animatesprites_51021,%eax
    .intel_syntax noprefix
    {store} sub eax, edx
    and eax, 0x7ff
    mov ebx, dword ptr [esp + 16]
    sub eax, 0x400
    imul ebx
    shrd eax, edx, 0x10
    {store} mov edx, eax
    mov ax, word ptr [_omyang]
    {store} add eax, edx
    mov word ptr [ecx + 28], ax
    mov ax, word ptr [_mycursectnum]
    mov word ptr [ecx + 24], ax
game_flow_animatesprites_51072:
    cmp byte ptr [_display_mirror], 1
    je game_flow_animatesprites_51107
    mov edx, dword ptr [esp + 24]
    cmp dx, word ptr [_screenpeek]
    jne game_flow_animatesprites_51107
    movsx eax, word ptr [esi + 30]
    cmp eax, -1
    {disp32} jne game_flow_animatesprites_51562
game_flow_animatesprites_51107:
    cmp word ptr [_ud + 0x590], 1
    {disp32} jle game_flow_animatesprites_51562
    cmp byte ptr [_ud + 0x587], 0
    {disp32} je game_flow_animatesprites_51562
    movsx eax, word ptr [esp + 24]
    imul eax, eax, 0x552
    movsx edx, word ptr [eax + _ps + 0x2d4]
    imul edx, edx, 0x2c
    cmp word ptr [edx + _sprite + 0x2a], 0
    {disp32} jle game_flow_animatesprites_51562
    cmp word ptr [eax + _ps + 0x2a8], 0
    {disp32} jle game_flow_animatesprites_51562
    imul eax, dword ptr [_spritesortcnt], 0x2c
    mov ebx, 0x2c
    add eax, OFFSET FLAT:_tsprite
    {store} mov edx, ecx
    call memcpy_
    imul eax, dword ptr [_spritesortcnt], 0x2c
    mov ebx, 0x63
    {store} xor edx, edx
    mov word ptr [eax + _tsprite + 0x1a], bx
    mov dl, byte ptr [ecx + 21]
    sar edx, 3
    mov byte ptr [eax + _tsprite + 0x15], dl
    cmp byte ptr [ecx + 21], 4
    jae game_flow_animatesprites_51250
    mov byte ptr [ecx + 21], 4
game_flow_animatesprites_51250:
    imul eax, dword ptr [_spritesortcnt], 0x2c
    mov dl, byte ptr [ecx + 16]
    mov byte ptr [eax + _tsprite + 0x10], dl
    {store} xor edx, edx
    mov word ptr [eax + _tsprite + 0xc], dx
    movsx edx, word ptr [esp + 24]
    imul edx, edx, 0x552
    mov dx, word ptr [edx + _ps + 0x2a8]
    dec edx
    cmp dx, 9
    {disp32} ja game_flow_animatesprites_51422
    and edx, 0xffff
    jmp dword ptr cs:[edx*4 + game_switch_animatesprites_47648]
game_flow_animatesprites_51318:
    mov word ptr [eax + _tsprite + 0xe], 0x15
    jmp game_flow_animatesprites_51422
game_flow_animatesprites_51329:
    mov word ptr [eax + _tsprite + 0xe], 0x1c
    jmp game_flow_animatesprites_51422
game_flow_animatesprites_51340:
    mov word ptr [eax + _tsprite + 0xe], 0x16
    jmp game_flow_animatesprites_51422
game_flow_animatesprites_51351:
    mov word ptr [eax + _tsprite + 0xe], 0x17
    jmp game_flow_animatesprites_51422
game_flow_animatesprites_51362:
    imul eax, dword ptr [_spritesortcnt], 0x2c
    mov word ptr [eax + _tsprite + 0xe], 0x1a
    jmp game_flow_animatesprites_51422
game_flow_animatesprites_51380:
    mov word ptr [eax + _tsprite + 0xe], 0x1b
    jmp game_flow_animatesprites_51422
game_flow_animatesprites_51391:
    mov word ptr [eax + _tsprite + 0xe], 0x19
    jmp game_flow_animatesprites_51422
game_flow_animatesprites_51402:
    mov word ptr [eax + _tsprite + 0xe], 0x18
    jmp game_flow_animatesprites_51422
game_flow_animatesprites_51413:
    mov word ptr [eax + _tsprite + 0xe], 0x1d
game_flow_animatesprites_51422:
    imul eax, dword ptr [_spritesortcnt], 0x2c
    cmp word ptr [esi + 30], 0
    jl game_flow_animatesprites_51461
    movsx edx, word ptr [esp + 24]
    imul edx, edx, 0x552
    mov edx, dword ptr [edx + _ps + 0x21c]
    sub edx, 0xc00
    jmp game_flow_animatesprites_51470
game_flow_animatesprites_51461:
    mov edx, dword ptr [esi + 8]
    sub edx, 0x3300
game_flow_animatesprites_51470:
    mov dword ptr [eax + _tsprite + 0x8], edx
    movsx eax, word ptr [esp + 24]
    imul edx, eax, 0x552
    imul eax, dword ptr [_spritesortcnt], 0x2c
    cmp word ptr [edx + _ps + 0x2a8], 5
    jne game_flow_animatesprites_51520
    mov bh, 0xa
    mov byte ptr [eax + _tsprite + 0x14], bh
    mov byte ptr [eax + _tsprite + 0x15], bh
    jmp game_flow_animatesprites_51534
game_flow_animatesprites_51520:
    mov dh, 0x10
    mov byte ptr [eax + _tsprite + 0x14], dh
    mov byte ptr [eax + _tsprite + 0x15], dh
game_flow_animatesprites_51534:
    imul eax, dword ptr [_spritesortcnt], 0x2c
    mov ebx, dword ptr [_spritesortcnt]
    inc ebx
    xor dh, dh
    mov dword ptr [_spritesortcnt], ebx
    mov byte ptr [eax + _tsprite + 0x11], dh
game_flow_animatesprites_51562:
    movsx eax, word ptr [esi + 30]
    cmp eax, -1
    {disp32} jne game_flow_animatesprites_51849
    movsx eax, word ptr [esi + 28]
    movsx edx, word ptr [esp + 36]
    .att_syntax prefix
    addl $game_math_animatesprites_51584,%eax
    .intel_syntax noprefix
    {store} sub eax, edx
    and eax, 0x7ff
    sar eax, 8
    and eax, 7
    {store} mov edx, eax
    .att_syntax prefix
    cmpw $game_math_animatesprites_51604,%ax
    .intel_syntax noprefix
    jle game_flow_animatesprites_51630
    mov eax, 8
    mov bh, byte ptr [ecx + 12]
    {store} sub eax, edx
    or bh, 4
    {store} mov edx, eax
    mov byte ptr [ecx + 12], bh
    jmp game_flow_animatesprites_51634
game_flow_animatesprites_51630:
    and byte ptr [ecx + 12], 0xfb
game_flow_animatesprites_51634:
    movsx eax, word ptr [ecx + 24]
    mov dword ptr [esp + 20], eax
    mov ebx, dword ptr [esp + 20]
    {disp32} lea eax, dword ptr [eax*4]
    {store} add eax, ebx
    cmp word ptr [eax*8 + _sector + 0x22], 2
    jne game_flow_animatesprites_51674
    add edx, 0x186
    jmp game_flow_animatesprites_51722
game_flow_animatesprites_51674:
    movsx eax, di
    mov dword ptr [esp + 20], eax
    mov ebx, dword ptr [esp + 20]
    {disp32} lea eax, dword ptr [eax*8]
    {store} add eax, ebx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ebx
    mov eax, dword ptr [eax + _hittype + 0x13]
    sub eax, dword ptr [esi + 8]
    .att_syntax prefix
    cmpl $game_math_animatesprites_51712,%eax
    .intel_syntax noprefix
    jle game_flow_animatesprites_51722
    add edx, 0x3c
game_flow_animatesprites_51722:
    add word ptr [ecx + 14], dx
    movsx eax, word ptr [esp + 24]
    imul eax, eax, 0x552
    mov al, byte ptr [eax + _ps + 0x548]
    mov byte ptr [ecx + 17], al
game_flow_animatesprites_51746:
    movsx edx, word ptr [esp + 28]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    mov dl, byte ptr [eax + _sector + 0x1d]
    test dl, dl
    je game_flow_animatesprites_51780
    mov byte ptr [ecx + 17], dl
game_flow_animatesprites_51780:
    movsx eax, word ptr [esi + 30]
    cmp eax, -1
    {disp32} je game_flow_animatesprites_54473
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov edx, dword ptr [ecx + 8]
    mov ebx, dword ptr [eax + _hittype + 0x13]
    {store} cmp edx, ebx
    {disp32} jle game_flow_animatesprites_49455
    cmp byte ptr [ecx + 20], 0x20
    {disp32} jae game_flow_animatesprites_49455
    mov dword ptr [ecx + 8], ebx
    {disp32} jmp game_flow_animatesprites_49455
game_flow_animatesprites_51849:
    movsx ebx, word ptr [esp + 24]
    imul ebx, ebx, 0x552
    movsx eax, word ptr [ebx + _ps + 0x2d2]
    cmp eax, -1
    {disp32} jne game_flow_animatesprites_52005
    movsx edx, word ptr [esi + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov ax, word ptr [eax*8 + _sector + 0x22]
    and ah, 7
    .att_syntax prefix
    cmpw $game_math_animatesprites_51900,%ax
    .intel_syntax noprefix
    je game_flow_animatesprites_52005
    movsx edx, word ptr [ebx + _ps + 0x2d4]
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    {store} mov edx, eax
    mov eax, dword ptr [esi + 8]
    sub eax, dword ptr [edx + _hittype + 0x13]
    lea ebx, dword ptr [eax + 768]
    cmp ebx, 0x400
    jle game_flow_animatesprites_52001
    cmp byte ptr [esi + 21], 0x20
    jbe game_flow_animatesprites_52001
    cmp word ptr [esi + 42], 0
    jle game_flow_animatesprites_52001
    {store} xor eax, eax
    mov al, byte ptr [esi + 21]
    {store} mov edx, ebx
    {disp32} lea eax, dword ptr [eax*4]
    sar edx, 0x1f
    mov dword ptr [esp + 20], eax
    {store} mov eax, ebx
    idiv dword ptr [esp + 20]
    mov byte ptr [esi + 23], al
    jmp game_flow_animatesprites_52005
game_flow_animatesprites_52001:
    mov byte ptr [esi + 23], 0
game_flow_animatesprites_52005:
    movsx eax, word ptr [esp + 24]
    imul eax, eax, 0x552
    movsx eax, word ptr [eax + _ps + 0x2b2]
    cmp eax, -1
    jle game_flow_animatesprites_52048
    mov eax, dword ptr [_actorscrptr + 0x15f4]
    {store} xor edx, edx
    mov ebp, dword ptr [eax + 4]
    mov eax, dword ptr [eax + 8]
    mov dword ptr [esp + 4], edx
    mov dword ptr [esp], eax
game_flow_animatesprites_52048:
    movsx eax, word ptr [_ud + 0x58c]
    cmp eax, -1
    {disp32} jne game_flow_animatesprites_51746
    movsx eax, word ptr [esp + 24]
    imul eax, eax, 0x552
    movsx edx, word ptr [eax + _ps + 0x2b2]
    cmp edx, -1
    {disp32} jne game_flow_animatesprites_51746
    cmp word ptr [esi + 30], 0
    {disp32} jl game_flow_animatesprites_51746
    cmp byte ptr [_display_mirror], 0
    {disp32} jne game_flow_animatesprites_51746
    cmp word ptr [eax + _ps + 0x2d8], 0
    {disp32} jne game_flow_animatesprites_51746
    mov ax, word ptr [_ud + 0x590]
    .att_syntax prefix
    cmpw $game_math_animatesprites_52135,%ax
    .intel_syntax noprefix
    jl game_flow_animatesprites_52168
    .att_syntax prefix
    cmpw $game_math_animatesprites_52141,%ax
    .intel_syntax noprefix
    {disp32} jle game_flow_animatesprites_51746
    mov eax, dword ptr [esp + 24]
    cmp ax, word ptr [_screenpeek]
    {disp32} jne game_flow_animatesprites_51746
game_flow_animatesprites_52168:
    mov word ptr [ecx + 30], 0xffff
    {disp32} jmp game_flow_animatesprites_54463
game_flow_animatesprites_52179:
    cmp dword ptr [_ud + 0x5e6], 0
    {disp32} jne game_flow_animatesprites_54463
game_flow_animatesprites_52192:
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    cmp word ptr [eax + _hittype + 0x1], 0xd48
    jne game_flow_animatesprites_52247
    cmp word ptr [ecx + 14], 0x960
    jne game_flow_animatesprites_52247
    mov dx, word ptr [esi + 34]
    test dx, dx
    jl game_flow_animatesprites_52247
    mov word ptr [ecx + 14], dx
    jmp game_flow_animatesprites_52285
game_flow_animatesprites_52247:
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov bx, word ptr [ecx + 14]
    mov ax, word ptr [eax + _hittype + 0x2f]
    {store} add ebx, eax
    mov word ptr [ecx + 14], bx
game_flow_animatesprites_52285:
    movsx edx, word ptr [esp + 28]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov dl, byte ptr [ecx + 16]
    sub dl, 6
    {disp32} lea eax, dword ptr [eax*8]
    mov byte ptr [ecx + 16], dl
    mov dh, byte ptr [eax + _sector + 0x1d]
    test dh, dh
    {disp32} je game_flow_animatesprites_49455
    mov byte ptr [ecx + 17], dh
    {disp32} jmp game_flow_animatesprites_49455
game_flow_animatesprites_52337:
    movsx edx, word ptr [ecx + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    cmp word ptr [eax*8 + _sector + 0x18], 0xc8
    {disp32} jne game_flow_animatesprites_49421
    mov byte ptr [ecx + 17], 7
    {disp32} jmp game_flow_animatesprites_49455
game_flow_animatesprites_52375:
    movsx eax, word ptr [esi + 28]
    movsx edx, word ptr [esp + 36]
    .att_syntax prefix
    addl $game_math_animatesprites_52384,%eax
    .intel_syntax noprefix
    {store} sub eax, edx
    and eax, 0x7ff
    sar eax, 8
    and eax, 1
    {store} mov edx, eax
    {disp32} jmp game_flow_animatesprites_52691
game_flow_animatesprites_52409:
    movsx eax, word ptr [esi + 28]
    movsx edx, word ptr [esp + 36]
    .att_syntax prefix
    addl $game_math_animatesprites_52418,%eax
    .intel_syntax noprefix
    {store} sub eax, edx
    {store} mov edx, eax
    mov eax, 0xc0
    and edx, 0x7ff
    mov dword ptr [esp + 20], eax
    {store} mov eax, edx
    sar edx, 0x1f
    idiv dword ptr [esp + 20]
    {store} mov edx, eax
    mov dword ptr [esp + 20], 5
    {store} mov eax, edx
    sar edx, 0x1f
    idiv dword ptr [esp + 20]
    cmp dx, 2
    {disp32} jle game_flow_animatesprites_52683
    or byte ptr [ecx + 12], 4
    mov eax, 4
    {store} sub eax, edx
    {store} mov edx, eax
    {disp32} jmp game_flow_animatesprites_52691
game_flow_animatesprites_52498:
    mov eax, dword ptr [esp + 12]
    mov edx, dword ptr [esi + 4]
    {store} sub edx, eax
    mov eax, dword ptr [esi]
    sub eax, dword ptr [esp + 8]
    call getangle_
    movsx edx, word ptr [esi + 28]
    add edx, 0xc80
    cwde
    {store} sub edx, eax
    {store} mov eax, edx
    and eax, 0x7ff
    sar eax, 8
    and eax, 7
    {store} mov edx, eax
    .att_syntax prefix
    cmpw $game_math_animatesprites_52546,%ax
    .intel_syntax noprefix
    {disp32} jle game_flow_animatesprites_52683
    mov eax, 8
    {store} sub eax, edx
    {store} mov edx, eax
    or byte ptr [ecx + 12], 4
    {disp32} jmp game_flow_animatesprites_52691
game_flow_animatesprites_52574:
    mov eax, dword ptr [esp + 12]
    mov edx, dword ptr [esi + 4]
    {store} sub edx, eax
    mov eax, dword ptr [esi]
    sub eax, dword ptr [esp + 8]
    call getangle_
    movsx edx, word ptr [esi + 28]
    add edx, 0xc80
    cwde
    {store} sub edx, eax
    mov eax, 0xaa
    and edx, 0x7ff
    mov dword ptr [esp + 20], eax
    {store} mov eax, edx
    sar edx, 0x1f
    idiv dword ptr [esp + 20]
    {store} mov edx, eax
    .att_syntax prefix
    cmpw $game_math_animatesprites_52633,%ax
    .intel_syntax noprefix
    jle game_flow_animatesprites_52683
    mov eax, 0xc
    {store} sub eax, edx
    {store} mov edx, eax
    or byte ptr [ecx + 12], 4
    jmp game_flow_animatesprites_52691
game_flow_animatesprites_52654:
    movsx eax, word ptr [esi + 28]
    movsx edx, word ptr [esp + 36]
    .att_syntax prefix
    addl $game_math_animatesprites_52663,%eax
    .intel_syntax noprefix
    {store} sub eax, edx
    and eax, 0x7ff
    sar eax, 8
    and eax, 7
    {store} mov edx, eax
game_flow_animatesprites_52683:
    and byte ptr [ecx + 12], 0xfb
    jmp game_flow_animatesprites_52691
game_flow_animatesprites_52689:
    {store} xor edx, edx
game_flow_animatesprites_52691:
    {disp8} mov ax, word ptr [ebp]
    {store} add eax, edx
    mov dword ptr [esp + 40], eax
    mov eax, dword ptr [esp + 4]
    imul eax, ebx
    add eax, dword ptr [esp + 40]
    add word ptr [ecx + 14], ax
    test ebx, ebx
    jle game_flow_animatesprites_52754
game_flow_animatesprites_52720:
    movsx eax, word ptr [ecx + 14]
    cmp word ptr [eax*2 + _tilesizx], 0
    jne game_flow_animatesprites_52754
    mov ax, word ptr [ecx + 14]
    test ax, ax
    jle game_flow_animatesprites_52754
    {store} mov edx, eax
    {store} sub edx, ebx
    mov word ptr [ecx + 14], dx
    jmp game_flow_animatesprites_52720
game_flow_animatesprites_52754:
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    cmp word ptr [eax + _hittype + 0xf], 0
    jl game_flow_animatesprites_52811
    mov dx, word ptr [ecx + 14]
    mov word ptr [eax + _hittype + 0xf], dx
    jmp game_flow_animatesprites_52811
game_flow_animatesprites_52798:
    cmp byte ptr [_display_mirror], 1
    jne game_flow_animatesprites_52811
    or byte ptr [ecx + 12], 4
game_flow_animatesprites_52811:
    cmp word ptr [esi + 26], 0xd
    je game_flow_animatesprites_52853
    {store} mov eax, esi
    call badguy_
    test ax, ax
    jne game_flow_animatesprites_52853
    cmp word ptr [esi + 14], 0x57d
    {disp32} jne game_flow_animatesprites_53278
    cmp word ptr [esi + 30], 0
    {disp32} jl game_flow_animatesprites_53278
game_flow_animatesprites_52853:
    test byte ptr [esi + 12], 0x30
    {disp32} jne game_flow_animatesprites_53278
    cmp word ptr [ecx + 26], 0x63
    {disp32} je game_flow_animatesprites_53278
    mov dx, word ptr [esi + 14]
    cmp dx, 0x762
    {disp32} je game_flow_animatesprites_53278
    cmp dx, 0x3d3
    {disp32} je game_flow_animatesprites_53278
    cmp dx, 0x227
    {disp32} je game_flow_animatesprites_53278
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov bx, word ptr [eax + _hittype + 0xf]
    {store} mov edx, eax
    test bx, bx
    jge game_flow_animatesprites_52961
    {store} mov eax, ebx
    inc eax
    mov word ptr [edx + _hittype + 0xf], ax
    {disp32} jmp game_flow_animatesprites_54473
game_flow_animatesprites_52961:
    cmp dword ptr [_ud + 0x5c2], 0
    {disp32} je game_flow_animatesprites_53238
    cmp dword ptr [_spritesortcnt], 0x3fe
    {disp32} jge game_flow_animatesprites_53238
    movsx ebx, word ptr [esp + 28]
    {disp32} lea eax, dword ptr [ebx*4]
    {store} add eax, ebx
    mov ax, word ptr [eax*8 + _sector + 0x22]
    xor ah, ah
    .att_syntax prefix
    cmpw $game_math_animatesprites_53014,%ax
    .intel_syntax noprefix
    jg game_flow_animatesprites_53052
    mov ax, word ptr [esi + 26]
    .att_syntax prefix
    cmpw $game_math_animatesprites_53024,%ax
    .intel_syntax noprefix
    je game_flow_animatesprites_53052
    .att_syntax prefix
    cmpw $game_math_animatesprites_53030,%ax
    .intel_syntax noprefix
    je game_flow_animatesprites_53052
    mov ax, word ptr [esi + 14]
    .att_syntax prefix
    cmpw $game_math_animatesprites_53040,%ax
    .intel_syntax noprefix
    je game_flow_animatesprites_53052
    .att_syntax prefix
    cmpw $game_math_animatesprites_53046,%ax
    .intel_syntax noprefix
    jne game_flow_animatesprites_53075
game_flow_animatesprites_53052:
    movsx edx, word ptr [esp + 28]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov ebp, dword ptr [eax*8 + _sector + 0x8]
    jmp game_flow_animatesprites_53081
game_flow_animatesprites_53075:
    mov ebp, dword ptr [edx + _hittype + 0x13]
game_flow_animatesprites_53081:
    mov eax, dword ptr [esi + 8]
    {store} sub eax, ebp
    .att_syntax prefix
    cmpl $game_math_animatesprites_53086,%eax
    .intel_syntax noprefix
    {disp32} jge game_flow_animatesprites_53238
    movsx eax, word ptr [_screenpeek]
    imul eax, eax, 0x552
    cmp ebp, dword ptr [eax + _ps + 0x21c]
    jle game_flow_animatesprites_53238
    imul eax, dword ptr [_spritesortcnt], 0x2c
    {store} mov edx, ecx
    mov ebx, 0x2c
    add eax, OFFSET FLAT:_tsprite
    call memcpy_
    imul eax, dword ptr [_spritesortcnt], 0x2c
    mov word ptr [eax + _tsprite + 0x1a], 0x63
    {store} xor edx, edx
    mov dl, byte ptr [ecx + 21]
    sar edx, 3
    mov byte ptr [eax + _tsprite + 0x15], dl
    cmp byte ptr [ecx + 21], 4
    jae game_flow_animatesprites_53182
    mov byte ptr [ecx + 21], 4
game_flow_animatesprites_53182:
    imul eax, dword ptr [_spritesortcnt], 0x2c
    mov byte ptr [eax + _tsprite + 0x10], 0x7f
    mov bl, byte ptr [eax + _tsprite + 0xc]
    mov dword ptr [eax + _tsprite + 0x8], ebp
    mov ebp, dword ptr [_spritesortcnt]
    or bl, 2
    inc ebp
    mov byte ptr [eax + _tsprite + 0xc], bl
    mov bh, 4
    mov dword ptr [_spritesortcnt], ebp
    mov byte ptr [eax + _tsprite + 0x11], bh
game_flow_animatesprites_53238:
    movsx eax, word ptr [_screenpeek]
    imul eax, eax, 0x552
    cmp word ptr [eax + _ps + 0x2e8], 0
    jle game_flow_animatesprites_53278
    cmp byte ptr [eax + _ps + 0x531], 0
    je game_flow_animatesprites_53278
    mov byte ptr [ecx + 17], 6
    mov byte ptr [ecx + 16], 0
game_flow_animatesprites_53278:
    mov dx, word ptr [esi + 14]
    cmp dx, 0x678
    {disp32} jb game_flow_animatesprites_53480
    {disp32} jbe game_flow_animatesprites_53678
    cmp dx, 0x9e5
    jb game_flow_animatesprites_53391
    {disp32} jbe game_flow_animatesprites_53999
    cmp dx, 0xa07
    jb game_flow_animatesprites_53358
    {disp32} jbe game_flow_animatesprites_53629
    cmp dx, 0xa2d
    {disp32} jb game_flow_animatesprites_54406
    {disp32} jbe game_flow_animatesprites_53678
    cmp dx, 0xf9f
    {disp32} je game_flow_animatesprites_54127
    {disp32} jmp game_flow_animatesprites_54406
game_flow_animatesprites_53358:
    cmp dx, 0x9e7
    {disp32} jb game_flow_animatesprites_54406
    {disp32} jbe game_flow_animatesprites_54037
    cmp dx, 0x9e8
    {disp32} je game_flow_animatesprites_53678
    {disp32} jmp game_flow_animatesprites_54406
game_flow_animatesprites_53391:
    cmp dx, 0x8de
    jb game_flow_animatesprites_53447
    cmp dx, 0x8df
    {disp32} jbe game_flow_animatesprites_53738
    cmp dx, 0x906
    {disp32} jb game_flow_animatesprites_54406
    cmp dx, 0x907
    {disp32} jbe game_flow_animatesprites_53738
    cmp dx, 0x91d
    {disp32} je game_flow_animatesprites_53678
    {disp32} jmp game_flow_animatesprites_54406
game_flow_animatesprites_53447:
    cmp dx, 0x762
    {disp32} jb game_flow_animatesprites_54406
    {disp32} jbe game_flow_animatesprites_53678
    cmp dx, 0x8ab
    {disp32} je game_flow_animatesprites_53678
    {disp32} jmp game_flow_animatesprites_54406
game_flow_animatesprites_53480:
    cmp dx, 0x550
    jb game_flow_animatesprites_53572
    {disp32} jbe game_flow_animatesprites_53798
    cmp dx, 0x659
    jb game_flow_animatesprites_53539
    {disp32} jbe game_flow_animatesprites_53678
    cmp dx, 0x669
    {disp32} jb game_flow_animatesprites_54406
    {disp32} jbe game_flow_animatesprites_53678
    cmp dx, 0x66e
    {disp32} je game_flow_animatesprites_53678
    {disp32} jmp game_flow_animatesprites_54406
game_flow_animatesprites_53539:
    cmp dx, 0x564
    {disp32} jb game_flow_animatesprites_54406
    {disp32} jbe game_flow_animatesprites_53943
    cmp dx, 0x58c
    {disp32} je game_flow_animatesprites_53817
    {disp32} jmp game_flow_animatesprites_54406
game_flow_animatesprites_53572:
    cmp dx, 0x242
    jb game_flow_animatesprites_53618
    {disp32} jbe game_flow_animatesprites_53958
    cmp dx, 0x26d
    {disp32} jb game_flow_animatesprites_54406
    {disp32} jbe game_flow_animatesprites_54342
    cmp dx, 0x4f3
    {disp32} je game_flow_animatesprites_54342
    {disp32} jmp game_flow_animatesprites_54406
game_flow_animatesprites_53618:
    cmp dx, 0x64
    je game_flow_animatesprites_53678
    {disp32} jmp game_flow_animatesprites_54406
game_flow_animatesprites_53629:
    movsx edx, word ptr [ecx + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    cmp word ptr [eax*8 + _sector + 0x22], 2
    jne game_flow_animatesprites_53657
    mov byte ptr [ecx + 17], 8
game_flow_animatesprites_53657:
    movsx eax, word ptr [esi + 30]
    imul eax, eax, 0x2c
    mov eax, dword ptr [eax + _sprite + 0x8]
    sub eax, 0x300
    mov dword ptr [ecx + 8], eax
game_flow_animatesprites_53678:
    cmp word ptr [ecx + 14], 0x762
    jne game_flow_animatesprites_53729
    movsx eax, word ptr [_screenpeek]
    imul eax, eax, 0x552
    mov dword ptr [eax + _ps + 0x268], 0xffffff81
    mov eax, dword ptr [_totalclock]
    add eax, 0x20
    mov dword ptr [_lastvisinc], eax
    mov byte ptr [_restorepalette], 1
game_flow_animatesprites_53729:
    mov byte ptr [ecx + 16], 0x81
    {disp32} jmp game_flow_animatesprites_54406
game_flow_animatesprites_53738:
    movsx eax, word ptr [esi + 30]
    imul eax, eax, 0x2c
    mov bx, word ptr [eax + _sprite + 0xe]
    cmp bx, 0x38c
    je game_flow_animatesprites_53789
    cmp bx, 0x38e
    je game_flow_animatesprites_53789
    movsx edx, word ptr [ecx + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov eax, dword ptr [eax*8 + _sector + 0x8]
    mov dword ptr [ecx + 8], eax
game_flow_animatesprites_53789:
    mov byte ptr [ecx + 16], 0x81
    {disp32} jmp game_flow_animatesprites_54406
game_flow_animatesprites_53798:
    mov byte ptr [ecx + 16], 0x81
    movsx edx, byte ptr [esi + 16]
    movsx eax, word ptr [ecx + 14]
    sar edx, 1
    {disp32} jmp game_flow_animatesprites_54400
game_flow_animatesprites_53817:
    movsx eax, word ptr [ecx + 28]
    movsx edx, word ptr [esp + 36]
    .att_syntax prefix
    addl $game_math_animatesprites_53826,%eax
    .intel_syntax noprefix
    {store} sub eax, edx
    and eax, 0x7ff
    sar eax, 8
    and eax, 7
    {store} mov edx, eax
    .att_syntax prefix
    cmpw $game_math_animatesprites_53846,%ax
    .intel_syntax noprefix
    jle game_flow_animatesprites_53872
    mov eax, 8
    mov bl, byte ptr [ecx + 12]
    {store} sub eax, edx
    or bl, 4
    {store} mov edx, eax
    mov byte ptr [ecx + 12], bl
    jmp game_flow_animatesprites_53876
game_flow_animatesprites_53872:
    and byte ptr [ecx + 12], 0xfb
game_flow_animatesprites_53876:
    movsx ebx, di
    {disp32} lea eax, dword ptr [ebx*8]
    {store} add eax, ebx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ebx
    cmp dword ptr [eax + _hittype + 0x2f], 4
    setl al
    xor ah, ah
    imul eax, eax, 5
    add dx, word ptr [esi + 14]
    {store} add edx, eax
    mov word ptr [ecx + 14], dx
    movsx eax, word ptr [esi + 30]
    imul eax, eax, 0x2c
    mov al, byte ptr [eax + _sprite + 0x10]
    mov byte ptr [ecx + 16], al
    {disp32} jmp game_flow_animatesprites_54406
game_flow_animatesprites_53943:
    mov eax, 0x564
    mov esi, dword ptr [esp]
    {store} add eax, esi
    {disp32} jmp game_flow_animatesprites_54402
game_flow_animatesprites_53958:
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    {store} mov edx, eax
    mov ax, word ptr [esi + 14]
    mov bx, word ptr [edx + _hittype + 0x37]
    {store} add eax, ebx
    {disp32} jmp game_flow_animatesprites_54402
game_flow_animatesprites_53999:
    movsx ebx, di
    {disp32} lea eax, dword ptr [ebx*8]
    {store} add eax, ebx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ebx
    mov ax, word ptr [eax + _hittype + 0x2f]
    xor ah, ah
    and al, 1
    {store} add edx, eax
    mov word ptr [ecx + 14], dx
game_flow_animatesprites_54037:
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    mov bl, byte ptr [ecx + 12]
    {disp32} lea eax, dword ptr [eax*8]
    or bl, 0xc
    {store} sub eax, edx
    mov byte ptr [ecx + 12], bl
    cmp dword ptr [eax + _hittype + 0x2f], 1
    jle game_flow_animatesprites_54084
    {store} mov bh, bl
    and bh, 0xfb
    mov byte ptr [ecx + 12], bh
game_flow_animatesprites_54084:
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    cmp dword ptr [eax + _hittype + 0x2f], 2
    {disp32} jle game_flow_animatesprites_54406
    and byte ptr [ecx + 12], 0xf3
    {disp32} jmp game_flow_animatesprites_54406
game_flow_animatesprites_54127:
    mov ax, word ptr [esi + 30]
    test ax, ax
    {disp32} jl game_flow_animatesprites_54406
    cwde
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 0x1a], 0x400
    {disp32} jge game_flow_animatesprites_54406
    cmp word ptr [eax + _sprite + 0xe], 0x57d
    jne game_flow_animatesprites_54218
    movsx edx, word ptr [_ud + 0x58c]
    cmp edx, -1
    jne game_flow_animatesprites_54218
    mov dx, word ptr [_screenpeek]
    cmp dx, word ptr [eax + _sprite + 0x22]
    jne game_flow_animatesprites_54218
    cmp byte ptr [_display_mirror], 0
    jne game_flow_animatesprites_54218
    mov word ptr [ecx + 30], 0xffff
    {disp32} jmp game_flow_animatesprites_54406
game_flow_animatesprites_54218:
    movsx edx, word ptr [esi + 30]
    imul eax, edx, 0x2c
    movsx eax, word ptr [eax + _sprite + 0xc]
    test ah, 0x80
    {disp32} jne game_flow_animatesprites_54406
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov ax, word ptr [eax + _hittype + 0xf]
    mov word ptr [ecx + 14], ax
    movsx eax, word ptr [esi + 30]
    imul eax, eax, 0x2c
    mov al, byte ptr [eax + _sprite + 0x11]
    mov byte ptr [ecx + 17], al
    movsx eax, word ptr [esi + 30]
    imul eax, eax, 0x2c
    mov al, byte ptr [eax + _sprite + 0x10]
    mov byte ptr [ecx + 16], al
    movsx eax, word ptr [esi + 30]
    imul eax, eax, 0x2c
    mov ax, word ptr [eax + _sprite + 0x1c]
    mov word ptr [ecx + 28], ax
    movsx eax, word ptr [esi + 30]
    imul eax, eax, 0x2c
    mov ax, word ptr [eax + _sprite + 0xc]
    or al, 2
    mov word ptr [ecx + 12], ax
    jmp game_flow_animatesprites_54406
game_flow_animatesprites_54342:
    movsx eax, word ptr [ecx + 28]
    movsx edx, word ptr [esp + 36]
    .att_syntax prefix
    addl $game_math_animatesprites_54351,%eax
    .intel_syntax noprefix
    {store} sub eax, edx
    and eax, 0x7ff
    sar eax, 8
    and eax, 7
    {store} mov edx, eax
    .att_syntax prefix
    cmpw $game_math_animatesprites_54371,%ax
    .intel_syntax noprefix
    jle game_flow_animatesprites_54392
    mov eax, 8
    {store} sub eax, edx
    {store} mov edx, eax
    or byte ptr [ecx + 12], 4
    jmp game_flow_animatesprites_54396
game_flow_animatesprites_54392:
    and byte ptr [ecx + 12], 0xfb
game_flow_animatesprites_54396:
    mov ax, word ptr [esi + 14]
game_flow_animatesprites_54400:
    {store} add eax, edx
game_flow_animatesprites_54402:
    mov word ptr [ecx + 14], ax
game_flow_animatesprites_54406:
    movsx edx, di
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov dx, word ptr [ecx + 14]
    mov word ptr [eax + _hittype + 0xf], dx
    movsx edx, word ptr [ecx + 24]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    cmp word ptr [eax*8 + _sector + 0x18], 0x230
    jne game_flow_animatesprites_54473
game_flow_animatesprites_54463:
    mov byte ptr [ecx + 21], 0
    mov al, byte ptr [ecx + 21]
    mov byte ptr [ecx + 20], al
game_flow_animatesprites_54473:
    inc dword ptr [esp + 32]
game_flow_animatesprites_54477:
    movsx eax, word ptr [esp + 32]
    cmp eax, dword ptr [_spritesortcnt]
    {disp32} jl game_flow_animatesprites_48345
    add esp, 0x2c
    pop ebp
    pop edi
    pop esi
    ret
    {disp8} lea eax, dword ptr [eax]
game_switch_cheats_54504:
    # Real compiler switch table: 25 named private destinations
    .long game_flow_cheats_55674
    .long game_flow_cheats_56021
    .long game_flow_cheats_56326
    .long game_flow_cheats_56788
    .long game_flow_cheats_56843
    .long game_flow_cheats_56974
    .long game_flow_cheats_57041
    .long game_flow_cheats_57252
    .long game_flow_cheats_57305
    .long game_flow_cheats_57751
    .long game_flow_cheats_56326
    .long game_flow_cheats_57808
    .long game_flow_cheats_57881
    .long game_flow_cheats_57959
    .long game_flow_cheats_58017
    .long game_flow_cheats_55562
    .long game_flow_cheats_57684
    .long game_flow_cheats_57482
    .long game_flow_cheats_55674
    .long game_flow_cheats_55606
    .long game_flow_cheats_55485
    .long game_flow_cheats_55028
    .long game_flow_cheats_55189
    .long game_flow_cheats_55363
    .long game_flow_cheats_55438
    {disp8} lea eax, dword ptr [eax + eiz*1]
cheats_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    sub esp, 4
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov dl, byte ptr [eax + _ps + 0x516]
    test dl, 0x10
    {disp32} jne game_flow_cheats_58253
    test dl, 1
    {disp32} jne game_flow_cheats_58253
    mov dx, word ptr [eax + _ps + 0x2e0]
    cmp dx, 1
    {disp32} jne game_flow_cheats_58059
game_flow_cheats_54671:
    call KB_KeyWaiting_
    test eax, eax
    {disp32} je game_flow_cheats_58253
    {store} xor edx, edx
    call KB_Getch_
    {store} mov dl, al
    mov word ptr [esp], dx
    and eax, 0xff
    call tolower_
    mov word ptr [esp], ax
    .att_syntax prefix
    cmpw $game_math_cheats_54711,%ax
    .intel_syntax noprefix
    jl game_flow_cheats_54723
    .att_syntax prefix
    cmpw $game_math_cheats_54717,%ax
    .intel_syntax noprefix
    jle game_flow_cheats_54765
game_flow_cheats_54723:
    mov esi, dword ptr [esp]
    cmp si, 0x30
    jl game_flow_cheats_54738
    cmp si, 0x39
    jle game_flow_cheats_54765
game_flow_cheats_54738:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    {store} xor edx, edx
    mov word ptr [eax + _ps + 0x2e0], dx
    {disp32} jmp game_flow_cheats_58253
game_flow_cheats_54765:
    mov al, byte ptr [_cheatbuflen]
    {store} xor edx, edx
    {store} mov dl, al
    mov ah, byte ptr [esp]
    mov byte ptr [edx + _cheatbuf], ah
    inc al
    mov byte ptr [_cheatbuflen], al
    {store} xor eax, eax
    mov al, byte ptr [_cheatbuflen]
    xor dl, dl
    mov byte ptr [eax + _cheatbuf], dl
    cmp al, 0xb
    jbe game_flow_cheats_54841
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    {store} xor ebx, ebx
    mov word ptr [eax + _ps + 0x2e0], bx
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cheats_54841:
    mov edi, dword ptr [esp]
    {store} xor esi, esi
    {disp32} jmp game_flow_cheats_54967
game_flow_cheats_54851:
    {store} xor ecx, ecx
    jmp game_flow_cheats_54954
game_flow_cheats_54855:
    movsx edx, si
    {disp32} lea eax, dword ptr [edx*8]
    {store} sub eax, edx
    movsx edx, cx
    {store} add eax, eax
    {store} add eax, edx
    mov dl, byte ptr [edx + _cheatbuf]
    mov bl, byte ptr [eax + _cheatquotes]
    cmp dl, bl
    je game_flow_cheats_54907
    cmp bl, 0x23
    jne game_flow_cheats_54966
    cmp di, 0x30
    jl game_flow_cheats_54966
    cmp di, 0x39
    jg game_flow_cheats_54966
game_flow_cheats_54907:
    movsx edx, si
    {disp32} lea eax, dword ptr [edx*8]
    {store} sub eax, edx
    lea edx, dword ptr [eax + eax]
    movsx eax, cx
    mov bl, byte ptr [edx + eax + _cheatquotes + 0x1]
    test bl, bl
    je game_flow_cheats_55005
    {store} xor edx, edx
    mov dl, byte ptr [_cheatbuflen]
    dec edx
    {store} cmp eax, edx
    {disp32} je game_flow_cheats_58253
    inc ecx
game_flow_cheats_54954:
    {store} xor eax, eax
    mov al, byte ptr [_cheatbuflen]
    {store} cmp cx, ax
    jl game_flow_cheats_54855
game_flow_cheats_54966:
    inc esi
game_flow_cheats_54967:
    cmp si, 0x19
    jl game_flow_cheats_54851
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    {store} xor ecx, ecx
    mov word ptr [eax + _ps + 0x2e0], cx
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cheats_55005:
    cmp si, 0x18
    {disp32} ja game_flow_cheats_54671
    {store} xor eax, eax
    {store} mov ax, si
    jmp dword ptr cs:[eax*4 + game_switch_cheats_54504]
game_flow_cheats_55028:
    mov esi, 1
    {store} xor ecx, ecx
    jmp game_flow_cheats_55070
game_flow_cheats_55037:
    movsx edx, word ptr [_myconnectindex]
    imul edx, edx, 0x552
    movsx ebx, word ptr [eax*4 + _max_ammo_amount]
    add edx, OFFSET FLAT:_ps
    inc esi
    call addammo_
game_flow_cheats_55070:
    mov eax, 0xb
    movsx edx, cx
    {store} sub eax, edx
    {store} mov edx, eax
    movsx eax, si
    {store} cmp eax, edx
    jl game_flow_cheats_55037
    mov esi, 1
    mov bl, 1
    jmp game_flow_cheats_55119
game_flow_cheats_55098:
    movsx edx, word ptr [_myconnectindex]
    imul edx, edx, 0x552
    inc esi
    mov byte ptr [edx + eax + _ps + 0x535], bl
game_flow_cheats_55119:
    mov edx, 0xb
    movsx eax, cx
    {store} sub edx, eax
    movsx eax, si
    {store} cmp eax, edx
    jl game_flow_cheats_55098
    call KB_FlushKeyBoardQueue_
    movsx edx, word ptr [_myconnectindex]
    imul edx, edx, 0x552
    {store} xor edi, edi
    mov eax, 0x77
    mov word ptr [edx + _ps + 0x2e0], di
    add edx, OFFSET FLAT:_ps
    call FTA_
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cheats_55189:
    call KB_FlushKeyBoardQueue_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    {store} xor esi, esi
    mov edi, 0x190
    mov word ptr [eax + _ps + 0x2e0], si
    mov edx, 0x4b0
    mov word ptr [eax + _ps + 0x4fe], di
    mov ebx, 0xc8
    mov word ptr [eax + _ps + 0x2e8], dx
    mov ecx, 0x64
    mov word ptr [eax + _ps + 0x510], bx
    mov word ptr [eax + _ps + 0x500], cx
    mov esi, 0x1900
    mov edx, 0x640
    mov word ptr [eax + _ps + 0x4fa], si
    mov word ptr [eax + _ps + 0x4fc], dx
    mov dx, word ptr [_max_player_health]
    mov edi, 0x960
    mov word ptr [eax + _ps + 0x2ce], dx
    mov edx, OFFSET FLAT:_ps
    mov word ptr [eax + _ps + 0x2b0], di
    {store} add edx, eax
    mov eax, 0x78
    call FTA_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    {store} xor ebx, ebx
    mov word ptr [eax + _ps + 0x2e0], bx
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cheats_55363:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov word ptr [eax + _ps + 0x2ca], 7
    call KB_FlushKeyBoardQueue_
    movsx edx, word ptr [_myconnectindex]
    imul edx, edx, 0x552
    {store} xor ecx, ecx
    mov eax, 0x79
    mov word ptr [edx + _ps + 0x2e0], cx
    add edx, OFFSET FLAT:_ps
    call FTA_
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cheats_55438:
    mov al, 1
    mov bh, byte ptr [_debug_on]
    sub al, bh
    mov byte ptr [_debug_on], al
    call KB_FlushKeyBoardQueue_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    {store} xor edx, edx
    mov word ptr [eax + _ps + 0x2e0], dx
    {disp32} jmp game_flow_cheats_54671
game_flow_cheats_55485:
    mov al, 1
    mov cl, byte ptr [_ud + 0x8]
    sub al, cl
    mov byte ptr [_ud + 0x8], al
    call KB_FlushKeyBoardQueue_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov edx, OFFSET FLAT:_ps
    {store} xor ecx, ecx
    {store} add edx, eax
    mov word ptr [eax + _ps + 0x2e0], cx
    {store} xor eax, eax
    mov al, byte ptr [_ud + 0x8]
    .att_syntax prefix
    addl $game_math_cheats_55541,%eax
    .intel_syntax noprefix
    cwde
    call FTA_
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cheats_55562:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov byte ptr [eax + _ps + 0x516], 8
    {store} xor edx, edx
    mov word ptr [eax + _ps + 0x2e0], dx
    call KB_FlushKeyBoardQueue_
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cheats_55606:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov edx, OFFSET FLAT:_ps
    {store} add edx, eax
    mov eax, 0x4f
    call FTA_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    {store} xor esi, esi
    mov word ptr [eax + _ps + 0x2e0], si
    mov byte ptr [_KB_KeyDown + 0x31], bl
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cheats_55674:
    mov al, 1
    mov cl, byte ptr [_ud]
    sub al, cl
    mov byte ptr [_ud], al
    {disp32} je game_flow_cheats_55844
    movsx ecx, word ptr [_myconnectindex]
    imul ecx, ecx, 0x552
    movsx ebx, word ptr [ecx + _ps + 0x2d4]
    imul edx, ebx, 0x2c
    mov ah, 1
    mov byte ptr [_pus], ah
    mov byte ptr [_pub], ah
    {disp32} lea eax, dword ptr [ebx*8]
    {store} add eax, ebx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ebx
    {store} xor ebp, ebp
    mov dword ptr [eax + _hittype + 0x2f], ebp
    mov dword ptr [eax + _hittype + 0x33], ebp
    mov dword ptr [eax + _hittype + 0x37], ebp
    mov edi, 0x101
    mov dword ptr [eax + _hittype + 0x3b], ebp
    mov word ptr [edx + _sprite + 0xc], di
    mov dword ptr [eax + _hittype + 0x3f], ebp
    {store} xor ebx, ebx
    mov dword ptr [eax + _hittype + 0x43], ebp
    {store} xor eax, eax
    mov word ptr [edx + _sprite + 0x26], bx
    mov word ptr [edx + _sprite + 0x28], ax
    mov al, byte ptr [ecx + _ps + 0x548]
    mov byte ptr [edx + _sprite + 0x11], al
    mov edx, OFFSET FLAT:_ps
    mov eax, 0x11
    {store} add edx, ecx
    jmp game_flow_cheats_55931
game_flow_cheats_55844:
    movsx edx, word ptr [_myconnectindex]
    imul edx, edx, 0x552
    movsx ebx, word ptr [edx + _ps + 0x2d4]
    imul ecx, ebx, 0x2c
    mov ax, word ptr [_max_player_health]
    mov word ptr [ecx + _sprite + 0x2a], ax
    {disp32} lea eax, dword ptr [ebx*8]
    {store} add eax, ebx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, ebx
    mov word ptr [eax + _hittype + 0x5], 0xffff
    mov ax, word ptr [_max_player_health]
    mov word ptr [edx + _ps + 0x28a], ax
    mov eax, 0x12
    add edx, OFFSET FLAT:_ps
game_flow_cheats_55931:
    call FTA_
    movsx ebx, word ptr [_myconnectindex]
    imul ebx, ebx, 0x552
    movsx edx, word ptr [ebx + _ps + 0x2d4]
    imul ecx, edx, 0x2c
    mov ax, word ptr [_max_player_health]
    mov word ptr [ecx + _sprite + 0x2a], ax
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} xor ecx, ecx
    {store} sub eax, edx
    mov word ptr [ebx + _ps + 0x2e0], cx
    mov word ptr [eax + _hittype + 0x5], cx
    call KB_FlushKeyBoardQueue_
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cheats_56021:
    mov esi, 1
    {store} xor ecx, ecx
    jmp game_flow_cheats_56063
game_flow_cheats_56030:
    movsx edx, word ptr [_myconnectindex]
    imul edx, edx, 0x552
    movsx ebx, word ptr [eax*4 + _max_ammo_amount]
    add edx, OFFSET FLAT:_ps
    inc esi
    call addammo_
game_flow_cheats_56063:
    mov edx, 0xb
    movsx eax, cx
    {store} sub edx, eax
    movsx eax, si
    {store} cmp eax, edx
    jl game_flow_cheats_56030
    mov esi, 1
    mov bh, 1
    jmp game_flow_cheats_56110
game_flow_cheats_56089:
    movsx edx, word ptr [_myconnectindex]
    imul edx, edx, 0x552
    inc esi
    mov byte ptr [edx + eax + _ps + 0x535], bh
game_flow_cheats_56110:
    mov eax, 0xb
    movsx edx, cx
    {store} sub eax, edx
    {store} mov edx, eax
    movsx eax, si
    {store} cmp eax, edx
    jl game_flow_cheats_56089
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov esi, 0x190
    mov edi, 0x4b0
    mov word ptr [eax + _ps + 0x4fe], si
    mov edx, 0xc8
    mov word ptr [eax + _ps + 0x2e8], di
    mov ebx, 0x64
    mov word ptr [eax + _ps + 0x510], dx
    mov ecx, 0x1900
    mov word ptr [eax + _ps + 0x500], bx
    mov word ptr [eax + _ps + 0x4fa], cx
    mov esi, 0x960
    mov dx, word ptr [_max_player_health]
    mov word ptr [eax + _ps + 0x2b0], si
    mov word ptr [eax + _ps + 0x2ce], dx
    mov edx, 7
    mov edi, 0x640
    mov word ptr [eax + _ps + 0x2ca], dx
    mov edx, OFFSET FLAT:_ps
    mov word ptr [eax + _ps + 0x4fc], di
    {store} add edx, eax
    mov eax, 5
    call FTA_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    {store} xor ebx, ebx
    mov word ptr [eax + _ps + 0x2e0], bx
    call KB_FlushKeyBoardQueue_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov byte ptr [eax + _ps + 0x52a], 1
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cheats_56326:
    cmp si, 2
    {disp32} jne game_flow_cheats_56533
    {store} xor edx, edx
    mov dl, byte ptr [_cheatbuf + 0x7]
    sub edx, 0x30
    imul edx, edx, 0xa
    {store} xor ebx, ebx
    mov bl, byte ptr [_cheatbuf + 0x8]
    {store} xor eax, eax
    sub ebx, 0x30
    mov al, byte ptr [_cheatbuf + 0x6]
    {store} add edx, ebx
    sub eax, 0x31
    dec edx
    {store} cmp ax, si
    jle game_flow_cheats_56416
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    {store} xor ecx, ecx
    mov word ptr [eax + _ps + 0x2e0], cx
    call KB_FlushKeyBoardQueue_
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cheats_56416:
    test ax, ax
    jne game_flow_cheats_56464
    cmp dx, 5
    jle game_flow_cheats_56507
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    {store} xor ebx, ebx
    mov word ptr [eax + _ps + 0x2e0], bx
    call KB_FlushKeyBoardQueue_
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cheats_56464:
    cmp dx, 0xb
    jl game_flow_cheats_56507
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    {store} xor esi, esi
    mov word ptr [eax + _ps + 0x2e0], si
    call KB_FlushKeyBoardQueue_
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cheats_56507:
    cwde
    mov dword ptr [_ud + 0x632], eax
    mov dword ptr [_ud + 0x626], eax
    movsx eax, dx
    mov dword ptr [_ud + 0x62e], eax
    mov dword ptr [_ud + 0x622], eax
    jmp game_flow_cheats_56553
game_flow_cheats_56533:
    {store} xor eax, eax
    mov al, byte ptr [_cheatbuf + 0x5]
    sub eax, 0x31
    mov dword ptr [_ud + 0x62a], eax
    mov dword ptr [_ud + 0x61e], eax
game_flow_cheats_56553:
    cmp word ptr [_numplayers], 1
    {disp32} jle game_flow_cheats_56731
    mov ax, word ptr [_myconnectindex]
    mov dx, word ptr [_connecthead]
    {store} cmp ax, dx
    {disp32} jne game_flow_cheats_56731
    mov al, byte ptr [_ud + 0x622]
    mov byte ptr [_tempbuf + 0x1], al
    mov al, byte ptr [_ud + 0x626]
    mov byte ptr [_tempbuf + 0x2], al
    mov al, byte ptr [_ud + 0x61e]
    mov byte ptr [_tempbuf + 0x3], al
    mov al, byte ptr [_ud + 0x616]
    mov byte ptr [_tempbuf + 0x4], al
    mov al, byte ptr [_ud + 0x60a]
    mov byte ptr [_tempbuf + 0x5], al
    mov al, byte ptr [_ud + 0x606]
    mov byte ptr [_tempbuf + 0x6], al
    mov al, byte ptr [_ud + 0x60e]
    mov bh, 5
    mov byte ptr [_tempbuf + 0x7], al
    mov al, byte ptr [_ud + 0x5da]
    mov byte ptr [_tempbuf], bh
    mov byte ptr [_tempbuf + 0x8], al
    mov al, byte ptr [_ud + 0x636]
    {store} mov ebx, edx
    mov byte ptr [_tempbuf + 0x9], al
    test bx, bx
    jge game_flow_cheats_56696
    jmp game_flow_cheats_56751
game_flow_cheats_56696:
    mov edx, OFFSET FLAT:_tempbuf
    movsx ecx, bx
    mov ebx, 0xa
    {store} mov eax, ecx
    call sendpacket_
    mov bx, word ptr [ecx*2 + _connectpoint2]
    test bx, bx
    jge game_flow_cheats_56696
    jmp game_flow_cheats_56751
game_flow_cheats_56731:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    or byte ptr [eax + _ps + 0x516], 0x20
game_flow_cheats_56751:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    {store} xor ecx, ecx
    mov word ptr [eax + _ps + 0x2e0], cx
    call KB_FlushKeyBoardQueue_
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cheats_56788:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    {store} xor ecx, ecx
    mov edi, dword ptr [_ud + 0x5d2]
    mov word ptr [eax + _ps + 0x2e0], cx
    mov eax, 1
    {store} sub eax, edi
    mov dword ptr [_ud + 0x5d2], eax
    call KB_FlushKeyBoardQueue_
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cheats_56843:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    cmp word ptr [eax + _ps + 0x2d8], 0
    je game_flow_cheats_56877
    {store} xor edx, edx
    mov word ptr [eax + _ps + 0x2d8], dx
    jmp game_flow_cheats_56907
game_flow_cheats_56877:
    {store} xor esi, esi
    mov edi, 1
    mov dword ptr [_cameradist], esi
    mov word ptr [eax + _ps + 0x2d8], di
    mov eax, dword ptr [_totalclock]
    mov dword ptr [_cameraclock], eax
game_flow_cheats_56907:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov edx, OFFSET FLAT:_ps
    {store} add edx, eax
    mov eax, 0x16
    call FTA_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    {store} xor ebx, ebx
    mov word ptr [eax + _ps + 0x2e0], bx
    call KB_FlushKeyBoardQueue_
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cheats_56974:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov edx, OFFSET FLAT:_ps
    {store} add edx, eax
    mov eax, 0x15
    call FTA_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    {store} xor ecx, ecx
    mov word ptr [eax + _ps + 0x2e0], cx
    call KB_FlushKeyBoardQueue_
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cheats_57041:
    mov bx, word ptr [_numsectors]
    jmp game_flow_cheats_57150
game_flow_cheats_57050:
    movsx edx, bx
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    mov cx, word ptr [eax + _sector + 0x22]
    movsx edx, cx
    cmp edx, -1
    je game_flow_cheats_57150
    cmp cx, 0x7fff
    je game_flow_cheats_57150
    {store} mov esi, ecx
    and esi, 0x7fff
    cmp si, 2
    jle game_flow_cheats_57150
    test dx, 0xbfff
    je game_flow_cheats_57122
    and ch, 0xbf
    mov word ptr [eax + _sector + 0x22], cx
game_flow_cheats_57122:
    movsx edx, word ptr [_myconnectindex]
    imul edx, edx, 0x552
    movsx eax, bx
    movsx edx, word ptr [edx + _ps + 0x2d4]
    call operatesectors_
game_flow_cheats_57150:
    dec ebx
    test bx, bx
    jge game_flow_cheats_57050
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov edx, 0xffffffff
    movsx eax, word ptr [eax + _ps + 0x2d4]
    call operateforcefields_
    movsx edx, word ptr [_myconnectindex]
    imul edx, edx, 0x552
    mov eax, 0x64
    add edx, OFFSET FLAT:_ps
    call FTA_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    {store} xor ebx, ebx
    mov word ptr [eax + _ps + 0x2e0], bx
    call KB_FlushKeyBoardQueue_
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cheats_57252:
    mov al, 1
    mov dl, byte ptr [_ud + 0x2]
    sub al, dl
    mov byte ptr [_ud + 0x2], al
    mov byte ptr [_KB_KeyDown + 0x31], bl
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    xor bh, bh
    mov word ptr [eax + _ps + 0x2e0], bx
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cheats_57305:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov ecx, 0x190
    mov esi, 0x4b0
    mov word ptr [eax + _ps + 0x4fe], cx
    mov edi, 0xc8
    mov word ptr [eax + _ps + 0x2e8], si
    mov edx, 0x64
    mov word ptr [eax + _ps + 0x510], di
    mov ebx, 0x1900
    mov word ptr [eax + _ps + 0x500], dx
    mov word ptr [eax + _ps + 0x4fa], bx
    mov ecx, 0x960
    mov esi, 0x640
    mov word ptr [eax + _ps + 0x2b0], cx
    mov dx, word ptr [_max_player_health]
    mov word ptr [eax + _ps + 0x4fc], si
    mov edi, 7
    mov word ptr [eax + _ps + 0x2ce], dx
    mov edx, OFFSET FLAT:_ps
    mov word ptr [eax + _ps + 0x2ca], di
    {store} add edx, eax
    mov eax, 5
    call FTA_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    {store} xor edx, edx
    mov word ptr [eax + _ps + 0x2e0], dx
    call KB_FlushKeyBoardQueue_
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cheats_57482:
    mov al, 1
    mov ah, byte ptr [_ud + 0x4]
    sub al, ah
    mov byte ptr [_ud + 0x4], al
    je game_flow_cheats_57572
    mov dl, 0xff
    xor bh, bh
    jmp game_flow_cheats_57515
game_flow_cheats_57505:
    movsx eax, bx
    inc ebx
    mov byte ptr [eax + _show2dsector], dl
game_flow_cheats_57515:
    cmp bx, 0x80
    jl game_flow_cheats_57505
    mov dh, 0xff
    {store} xor ebx, ebx
    jmp game_flow_cheats_57538
game_flow_cheats_57528:
    movsx eax, bx
    inc ebx
    mov byte ptr [eax + _show2dwall], dh
game_flow_cheats_57538:
    cmp bx, 0x400
    jl game_flow_cheats_57528
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov edx, OFFSET FLAT:_ps
    {store} add edx, eax
    mov eax, 0x6f
    jmp game_flow_cheats_57642
game_flow_cheats_57572:
    xor bh, bh
    jmp game_flow_cheats_57588
game_flow_cheats_57576:
    movsx eax, bx
    xor cl, cl
    inc ebx
    mov byte ptr [eax + _show2dsector], cl
game_flow_cheats_57588:
    cmp bx, 0x80
    jl game_flow_cheats_57576
    {store} xor ebx, ebx
    jmp game_flow_cheats_57611
game_flow_cheats_57599:
    movsx eax, bx
    xor ch, ch
    inc ebx
    mov byte ptr [eax + _show2dwall], ch
game_flow_cheats_57611:
    cmp bx, 0x400
    jl game_flow_cheats_57599
    movsx edx, word ptr [_myconnectindex]
    imul edx, edx, 0x552
    mov eax, 1
    add edx, OFFSET FLAT:_ps
game_flow_cheats_57642:
    call FTA_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    {store} xor edx, edx
    mov word ptr [eax + _ps + 0x2e0], dx
    call KB_FlushKeyBoardQueue_
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cheats_57684:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov edx, OFFSET FLAT:_ps
    {store} add edx, eax
    mov eax, 0x63
    call FTA_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    {store} xor edi, edi
    mov word ptr [eax + _ps + 0x2e0], di
    call KB_FlushKeyBoardQueue_
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cheats_57751:
    cmp dword ptr [_ud + 0x5d6], 0
    sete al
    and eax, 0xff
    mov dword ptr [_ud + 0x5d6], eax
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    xor bh, bh
    mov word ptr [eax + _ps + 0x2e0], bx
    call KB_FlushKeyBoardQueue_
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cheats_57808:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov edx, OFFSET FLAT:_ps
    {store} add edx, eax
    mov eax, 0x69
    call FTA_
    mov byte ptr [_KB_KeyDown + 0x23], bl
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    {store} xor edx, edx
    mov word ptr [eax + _ps + 0x2e0], dx
    call KB_FlushKeyBoardQueue_
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cheats_57881:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov ecx, 0x18f
    mov esi, 0x4b0
    mov edx, OFFSET FLAT:_ps
    mov word ptr [eax + _ps + 0x4fe], cx
    {store} xor edi, edi
    mov word ptr [eax + _ps + 0x2e8], si
    {store} add edx, eax
    mov word ptr [eax + _ps + 0x2e0], di
    mov eax, 0x25
    call FTA_
    call KB_FlushKeyBoardQueue_
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cheats_57959:
    cmp byte ptr [_actor_tog], 3
    jne game_flow_cheats_57974
    mov byte ptr [_actor_tog], bl
game_flow_cheats_57974:
    movsx eax, word ptr [_screenpeek]
    imul eax, eax, 0x552
    {store} xor ebx, ebx
    mov word ptr [eax + _ps + 0x2e0], bx
    inc byte ptr [_actor_tog]
    call KB_FlushKeyBoardQueue_
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cheats_58017:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov byte ptr [_ud + 0x3], 5
    or byte ptr [eax + _ps + 0x516], 8
    call KB_FlushKeyBoardQueue_
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cheats_58059:
    cmp byte ptr [_KB_KeyDown + 0x20], 0
    je game_flow_cheats_58101
    test dx, dx
    jl game_flow_cheats_58101
    cmp word ptr [_numplayers], 2
    jge game_flow_cheats_58101
    cmp dword ptr [_ud + 0x5fa], 0
    jne game_flow_cheats_58101
    mov word ptr [eax + _ps + 0x2e0], 0xffff
game_flow_cheats_58101:
    cmp byte ptr [_KB_KeyDown + 0x31], 0
    {disp32} je game_flow_cheats_58253
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    movsx edx, word ptr [eax + _ps + 0x2e0]
    cmp edx, -1
    jne game_flow_cheats_58220
    cmp dword ptr [_ud + 0x62a], 4
    jne game_flow_cheats_58189
    mov edx, OFFSET FLAT:_ps
    {store} add edx, eax
    mov eax, 0x16
    call FTA_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    {store} xor ecx, ecx
    mov word ptr [eax + _ps + 0x2e0], cx
    jmp game_flow_cheats_58205
game_flow_cheats_58189:
    mov word ptr [eax + _ps + 0x2e0], 1
    xor al, al
    mov byte ptr [_cheatbuflen], al
game_flow_cheats_58205:
    call KB_FlushKeyboardQueue_
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cheats_58220:
    cmp word ptr [eax + _ps + 0x2e0], 0
    je game_flow_cheats_58253
    {store} xor edx, edx
    xor cl, cl
    mov word ptr [eax + _ps + 0x2e0], dx
    mov byte ptr [_KB_KeyDown + 0x20], cl
    mov byte ptr [_KB_KeyDown + 0x31], cl
game_flow_cheats_58253:
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp8} lea edx, dword ptr [edx]
nonsharedkeys_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    sub esp, 0x1c
    cmp dword ptr [_ud + 0x5fa], 2
    jne game_flow_nonsharedkeys_58297
    {store} mov eax, esp
    call CONTROL_GetInput_
game_flow_nonsharedkeys_58297:
    cmp byte ptr [_KB_KeyDown + 0x58], 0
    je game_flow_nonsharedkeys_58356
    xor dl, dl
    mov byte ptr [_KB_KeyDown + 0x58], dl
    mov eax, OFFSET FLAT:game_text_nonsharedkeys_596
    {store} xor edx, edx
    call screencapture_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov edx, OFFSET FLAT:_ps
    {store} add edx, eax
    mov eax, 0x67
    call FTA_
game_flow_nonsharedkeys_58356:
    cmp byte ptr [_KB_KeyDown + 0x65], 0
    jne game_flow_nonsharedkeys_58381
    cmp byte ptr [_KB_KeyDown + 0x38], 0
    jne game_flow_nonsharedkeys_58381
    mov eax, 1
    jmp game_flow_nonsharedkeys_58383
game_flow_nonsharedkeys_58381:
    {store} xor eax, eax
game_flow_nonsharedkeys_58383:
    test eax, eax
    {disp32} je game_flow_nonsharedkeys_58506
    cmp byte ptr [_ud + 0x585], 0
    jne game_flow_nonsharedkeys_58506
    mov eax, dword ptr [_CONTROL_ButtonState2]
    shr eax, 8
    test al, 1
    je game_flow_nonsharedkeys_58453
    mov eax, 0x28
    call CONTROL_ClearButton_
    cmp dword ptr [_ud + 0x5e2], 0
    jle game_flow_nonsharedkeys_58441
    mov eax, 0x9e
    call sound_
game_flow_nonsharedkeys_58441:
    sub dword ptr [_ud + 0x5e2], 4
    call vscrn_
game_flow_nonsharedkeys_58453:
    mov eax, dword ptr [_CONTROL_ButtonState2]
    shr eax, 7
    test al, 1
    je game_flow_nonsharedkeys_58506
    mov eax, 0x27
    call CONTROL_ClearButton_
    cmp dword ptr [_ud + 0x5e2], 0x40
    jge game_flow_nonsharedkeys_58494
    mov eax, 0x9e
    call sound_
game_flow_nonsharedkeys_58494:
    add dword ptr [_ud + 0x5e2], 4
    call vscrn_
game_flow_nonsharedkeys_58506:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    cmp word ptr [eax + _ps + 0x2e0], 1
    {disp32} je game_flow_nonsharedkeys_62344
    test byte ptr [eax + _ps + 0x516], 0x11
    {disp32} jne game_flow_nonsharedkeys_62344
    mov eax, dword ptr [_CONTROL_ButtonState2]
    shr eax, 0xd
    test al, 1
    je game_flow_nonsharedkeys_58632
    cmp dword ptr [_ud + 0x5de], 1
    je game_flow_nonsharedkeys_58576
    cmp dword ptr [_ud + 0x5fa], 0
    je game_flow_nonsharedkeys_58632
game_flow_nonsharedkeys_58576:
    mov eax, 0x2d
    call CONTROL_ClearButton_
    movsx eax, word ptr [_screenpeek]
    mov ax, word ptr [eax*2 + _connectpoint2]
    mov word ptr [_screenpeek], ax
    cwde
    cmp eax, -1
    jne game_flow_nonsharedkeys_58625
    mov ax, word ptr [_connecthead]
    mov word ptr [_screenpeek], ax
game_flow_nonsharedkeys_58625:
    mov byte ptr [_restorepalette], 1
game_flow_nonsharedkeys_58632:
    cmp word ptr [_ud + 0x590], 1
    jle game_flow_nonsharedkeys_58721
    mov eax, dword ptr [_CONTROL_ButtonState2]
    shr eax, 0xb
    test al, 1
    je game_flow_nonsharedkeys_58721
    mov eax, 0x2b
    call CONTROL_ClearButton_
    mov al, 1
    mov ah, byte ptr [_ud + 0x587]
    sub al, ah
    mov byte ptr [_ud + 0x587], al
    movsx eax, word ptr [_screenpeek]
    imul eax, eax, 0x552
    mov edx, OFFSET FLAT:_ps
    {store} add edx, eax
    {store} xor eax, eax
    mov ebx, 0x52
    mov al, byte ptr [_ud + 0x587]
    {store} sub ebx, eax
    movsx eax, bx
    call FTA_
game_flow_nonsharedkeys_58721:
    mov eax, dword ptr [_CONTROL_ButtonState2]
    shr eax, 0xf
    test al, 1
    je game_flow_nonsharedkeys_58801
    mov eax, 0x2f
    call CONTROL_ClearButton_
    mov eax, 1
    mov edx, dword ptr [_ud + 0x5ea]
    {store} sub eax, edx
    mov dword ptr [_ud + 0x5ea], eax
    movsx eax, word ptr [_screenpeek]
    imul eax, eax, 0x552
    mov edx, OFFSET FLAT:_ps
    mov cx, word ptr [_ud + 0x5ea]
    {store} add edx, eax
    mov eax, 0x15
    {store} sub eax, ecx
    cwde
    call FTA_
game_flow_nonsharedkeys_58801:
    cmp byte ptr [_ud + 0x585], 0
    {disp32} je game_flow_nonsharedkeys_58939
    mov eax, dword ptr [_CONTROL_ButtonState2]
    shr eax, 0xc
    test al, 1
    je game_flow_nonsharedkeys_58939
    mov eax, 0x2c
    call CONTROL_ClearButton_
    mov al, 1
    mov dh, byte ptr [_ud + 0x7]
    sub al, dh
    mov byte ptr [_ud + 0x7], al
    je game_flow_nonsharedkeys_58902
    movsx eax, word ptr [_screenpeek]
    imul eax, eax, 0x552
    mov edx, dword ptr [eax + _ps + 0x238]
    mov dword ptr [_ud + 0x5aa], edx
    mov edx, dword ptr [eax + _ps + 0x23c]
    movsx eax, word ptr [eax + _ps + 0x282]
    mov dword ptr [_ud + 0x5ae], edx
    mov dword ptr [_ud + 0x5b2], eax
game_flow_nonsharedkeys_58902:
    movsx edx, word ptr [_myconnectindex]
    imul edx, edx, 0x552
    {store} xor eax, eax
    mov al, byte ptr [_ud + 0x7]
    .att_syntax prefix
    addl $game_math_nonsharedkeys_58922,%eax
    .intel_syntax noprefix
    cwde
    add edx, OFFSET FLAT:_ps
    call FTA_
game_flow_nonsharedkeys_58939:
    cmp byte ptr [_KB_KeyDown + 0x36], 0
    jne game_flow_nonsharedkeys_58979
    cmp byte ptr [_KB_KeyDown + 0x2a], 0
    jne game_flow_nonsharedkeys_58979
    cmp byte ptr [_KB_KeyDown + 0x65], 0
    jne game_flow_nonsharedkeys_58979
    cmp byte ptr [_KB_KeyDown + 0x38], 0
    {disp32} je game_flow_nonsharedkeys_59882
game_flow_nonsharedkeys_58979:
    {store} xor esi, esi
    mov word ptr [esp + 24], si
    cmp byte ptr [_KB_KeyDown + 0x3b], 0
    je game_flow_nonsharedkeys_59010
    xor dl, dl
    mov byte ptr [_KB_KeyDown + 0x3b], dl
    mov word ptr [esp + 24], 1
game_flow_nonsharedkeys_59010:
    cmp byte ptr [_KB_KeyDown + 0x3c], 0
    je game_flow_nonsharedkeys_59034
    xor bl, bl
    mov byte ptr [_KB_KeyDown + 0x3c], bl
    mov word ptr [esp + 24], 2
game_flow_nonsharedkeys_59034:
    cmp byte ptr [_KB_KeyDown + 0x3d], 0
    je game_flow_nonsharedkeys_59058
    xor cl, cl
    mov byte ptr [_KB_KeyDown + 0x3d], cl
    mov word ptr [esp + 24], 3
game_flow_nonsharedkeys_59058:
    cmp byte ptr [_KB_KeyDown + 0x3e], 0
    je game_flow_nonsharedkeys_59081
    xor al, al
    mov byte ptr [_KB_KeyDown + 0x3e], al
    mov word ptr [esp + 24], 4
game_flow_nonsharedkeys_59081:
    cmp byte ptr [_KB_KeyDown + 0x3f], 0
    je game_flow_nonsharedkeys_59105
    xor dl, dl
    mov byte ptr [_KB_KeyDown + 0x3f], dl
    mov word ptr [esp + 24], 5
game_flow_nonsharedkeys_59105:
    cmp byte ptr [_KB_KeyDown + 0x40], 0
    je game_flow_nonsharedkeys_59129
    xor bl, bl
    mov byte ptr [_KB_KeyDown + 0x40], bl
    mov word ptr [esp + 24], 6
game_flow_nonsharedkeys_59129:
    cmp byte ptr [_KB_KeyDown + 0x41], 0
    je game_flow_nonsharedkeys_59153
    xor cl, cl
    mov byte ptr [_KB_KeyDown + 0x41], cl
    mov word ptr [esp + 24], 7
game_flow_nonsharedkeys_59153:
    cmp byte ptr [_KB_KeyDown + 0x42], 0
    je game_flow_nonsharedkeys_59176
    xor al, al
    mov byte ptr [_KB_KeyDown + 0x42], al
    mov word ptr [esp + 24], 8
game_flow_nonsharedkeys_59176:
    cmp byte ptr [_KB_KeyDown + 0x43], 0
    je game_flow_nonsharedkeys_59200
    xor dl, dl
    mov byte ptr [_KB_KeyDown + 0x43], dl
    mov word ptr [esp + 24], 9
game_flow_nonsharedkeys_59200:
    cmp byte ptr [_KB_KeyDown + 0x44], 0
    je game_flow_nonsharedkeys_59224
    xor bl, bl
    mov byte ptr [_KB_KeyDown + 0x44], bl
    mov word ptr [esp + 24], 0xa
game_flow_nonsharedkeys_59224:
    cmp word ptr [esp + 24], 0
    {disp32} je game_flow_nonsharedkeys_59882
    cmp byte ptr [_KB_KeyDown + 0x36], 0
    jne game_flow_nonsharedkeys_59258
    cmp byte ptr [_KB_KeyDown + 0x2a], 0
    {disp32} je game_flow_nonsharedkeys_59633
game_flow_nonsharedkeys_59258:
    cmp word ptr [esp + 24], 5
    {disp32} jne game_flow_nonsharedkeys_59453
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    cmp word ptr [eax + _ps + 0x2c0], 0
    {disp32} jle game_flow_nonsharedkeys_59453
    cmp word ptr [eax + _ps + 0x2c2], 0x1a
    {disp32} jne game_flow_nonsharedkeys_59453
    mov dh, byte ptr [_music_select]
    inc dh
    mov byte ptr [_music_select], dh
    cmp dh, 0x21
    jne game_flow_nonsharedkeys_59338
    xor bh, bh
    mov byte ptr [_music_select], bh
game_flow_nonsharedkeys_59338:
    {store} xor eax, eax
    mov al, byte ptr [_music_select]
    imul eax, eax, 0xd
    mov edx, OFFSET FLAT:_music_fn
    mov edi, OFFSET FLAT:_tempbuf
    mov esi, OFFSET FLAT:game_text_nonsharedkeys_612
    {store} add edx, eax
    mov eax, OFFSET FLAT:_tempbuf
    movsd dword ptr es:[edi], dword ptr [esi]
    movsd dword ptr es:[edi], dword ptr [esi]
    movsb byte ptr es:[edi], byte ptr [esi]
    call strcat_
    {store} xor eax, eax
    mov al, byte ptr [_music_select]
    imul eax, eax, 0xd
    add eax, OFFSET FLAT:_music_fn
    mov edx, OFFSET FLAT:_tempbuf
    call playmusic_
    mov eax, OFFSET FLAT:_fta_quotes + 0x680
    call strcpy_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov edx, OFFSET FLAT:_ps
    {store} add edx, eax
    mov eax, 0x1a
    call FTA_
    add esp, 0x1c
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_nonsharedkeys_59453:
    movsx eax, word ptr [esp + 24]
    lea edx, dword ptr [eax + -1]
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov edx, OFFSET FLAT:_ud + 0x219
    {disp32} lea eax, dword ptr [eax*8]
    {store} add edx, eax
    mov edi, 0xb4
    mov dword ptr [_received_quote], edx
    mov ah, 4
    mov ebx, dword ptr [_received_quote]
    mov byte ptr [_tempbuf], ah
    xor dl, dl
    mov eax, OFFSET FLAT:_tempbuf + 0x1
    mov byte ptr [_tempbuf + 0x1], dl
    {store} mov edx, ebx
    mov word ptr [_received_quote_time], di
    call strcat_
    {store} mov eax, ebx
    call strlen_
    inc eax
    mov word ptr [esp + 24], ax
    cmp word ptr [_ud + 0x590], 1
    jle game_flow_nonsharedkeys_59611
    mov cx, word ptr [_connecthead]
    jmp game_flow_nonsharedkeys_59606
game_flow_nonsharedkeys_59568:
    cmp cx, word ptr [_myconnectindex]
    je game_flow_nonsharedkeys_59595
    movsx ebx, word ptr [esp + 24]
    mov edx, OFFSET FLAT:_tempbuf
    movsx eax, cx
    call sendpacket_
game_flow_nonsharedkeys_59595:
    movsx ecx, cx
    mov cx, word ptr [ecx*2 + _connectpoint2]
game_flow_nonsharedkeys_59606:
    test cx, cx
    jge game_flow_nonsharedkeys_59568
game_flow_nonsharedkeys_59611:
    mov al, 1
    mov byte ptr [_pus], al
    mov byte ptr [_pub], al
    add esp, 0x1c
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_nonsharedkeys_59633:
    cmp dword ptr [_ud + 0x5e6], 0
    {disp32} jne game_flow_nonsharedkeys_59882
    cmp byte ptr [_KB_KeyDown + 0x65], 0
    jne game_flow_nonsharedkeys_59668
    cmp byte ptr [_KB_KeyDown + 0x38], 0
    {disp32} je game_flow_nonsharedkeys_59882
game_flow_nonsharedkeys_59668:
    call RTS_NumSounds_
    test eax, eax
    {disp32} jle game_flow_nonsharedkeys_59882
    cmp byte ptr [_rtsplaying], 0
    {disp32} jne game_flow_nonsharedkeys_59882
    cmp dword ptr [_VoiceToggle], 0
    {disp32} je game_flow_nonsharedkeys_59882
    movsx ebx, word ptr [esp + 24]
    lea eax, dword ptr [ebx + -1]
    call RTS_GetSound_
    mov dword ptr [_rtsptr], eax
    cmp byte ptr [eax], 0x43
    jne game_flow_nonsharedkeys_59751
    neg ebx
    push ebx
    {store} xor ecx, ecx
    push 0xff
    {store} xor edx, edx
    {store} xor ebx, ebx
    call FX_PlayVOC3D_
    jmp game_flow_nonsharedkeys_59770
game_flow_nonsharedkeys_59751:
    neg ebx
    push ebx
    {store} xor ecx, ecx
    push 0xff
    {store} xor edx, edx
    {store} xor ebx, ebx
    call FX_PlayWAV3D_
game_flow_nonsharedkeys_59770:
    mov ch, 7
    mov dx, word ptr [_ud + 0x590]
    mov byte ptr [_rtsplaying], ch
    cmp dx, 1
    jle game_flow_nonsharedkeys_59858
    mov al, byte ptr [esp + 24]
    mov byte ptr [_tempbuf], ch
    mov cx, word ptr [_connecthead]
    mov byte ptr [_tempbuf + 0x1], al
    jmp game_flow_nonsharedkeys_59853
game_flow_nonsharedkeys_59815:
    cmp cx, word ptr [_myconnectindex]
    je game_flow_nonsharedkeys_59842
    mov ebx, 2
    mov edx, OFFSET FLAT:_tempbuf
    movsx eax, cx
    call sendpacket_
game_flow_nonsharedkeys_59842:
    movsx eax, cx
    mov cx, word ptr [eax*2 + _connectpoint2]
game_flow_nonsharedkeys_59853:
    test cx, cx
    jge game_flow_nonsharedkeys_59815
game_flow_nonsharedkeys_59858:
    mov cl, 1
    mov byte ptr [_pus], cl
    mov byte ptr [_pub], cl
    add esp, 0x1c
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_nonsharedkeys_59882:
    cmp byte ptr [_KB_KeyDown + 0x65], 0
    jne game_flow_nonsharedkeys_59907
    cmp byte ptr [_KB_KeyDown + 0x38], 0
    jne game_flow_nonsharedkeys_59907
    mov eax, 1
    jmp game_flow_nonsharedkeys_59909
game_flow_nonsharedkeys_59907:
    {store} xor eax, eax
game_flow_nonsharedkeys_59909:
    test eax, eax
    {disp32} je game_flow_nonsharedkeys_61895
    cmp byte ptr [_KB_KeyDown + 0x36], 0
    jne game_flow_nonsharedkeys_59942
    cmp byte ptr [_KB_KeyDown + 0x2a], 0
    jne game_flow_nonsharedkeys_59942
    mov eax, 1
    jmp game_flow_nonsharedkeys_59944
game_flow_nonsharedkeys_59942:
    {store} xor eax, eax
game_flow_nonsharedkeys_59944:
    test eax, eax
    {disp32} je game_flow_nonsharedkeys_61895
    cmp word ptr [_ud + 0x590], 1
    jle game_flow_nonsharedkeys_60034
    mov eax, dword ptr [_CONTROL_ButtonState2]
    shr eax, 5
    test al, 1
    je game_flow_nonsharedkeys_60034
    call KB_FlushKeyboardQueue_
    mov eax, 0x25
    call CONTROL_ClearButton_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov cl, byte ptr [eax + _ps + 0x516]
    or cl, 0x10
    {store} xor edi, edi
    mov byte ptr [eax + _ps + 0x516], cl
    xor ch, ch
    mov word ptr [_inputloc], di
    mov byte ptr [_typebuf], ch
game_flow_nonsharedkeys_60034:
    cmp byte ptr [_KB_KeyDown + 0x3b], 0
    jne game_flow_nonsharedkeys_60087
    cmp byte ptr [_ud + 0x6], 0
    {disp32} je game_flow_nonsharedkeys_60234
    cmp byte ptr [_KB_KeyDown + 0x39], 0
    jne game_flow_nonsharedkeys_60087
    cmp byte ptr [_KB_KeyDown + 0x1c], 0
    jne game_flow_nonsharedkeys_60087
    cmp byte ptr [_KB_KeyDown + 0x68], 0
    {disp32} je game_flow_nonsharedkeys_60234
game_flow_nonsharedkeys_60087:
    xor bh, bh
    mov byte ptr [_KB_KeyDown + 0x3b], bh
    mov byte ptr [_KB_KeyDown + 0x39], bh
    mov byte ptr [_KB_KeyDown + 0x68], bh
    mov byte ptr [_KB_KeyDown + 0x1c], bh
    mov ah, byte ptr [_ud + 0x6]
    inc ah
    mov byte ptr [_ud + 0x6], ah
    cmp ah, 2
    jbe game_flow_nonsharedkeys_60174
    mov dx, word ptr [_ud + 0x590]
    mov byte ptr [_ud + 0x6], bh
    cmp dx, 2
    jge game_flow_nonsharedkeys_60167
    cmp dword ptr [_ud + 0x5fa], 2
    je game_flow_nonsharedkeys_60167
    mov byte ptr [_ready2send], 1
game_flow_nonsharedkeys_60167:
    call vscrn_
    jmp game_flow_nonsharedkeys_60234
game_flow_nonsharedkeys_60174:
    mov ecx, dword ptr [_ydim]
    mov ebx, dword ptr [_xdim]
    {store} xor edx, edx
    {store} xor eax, eax
    dec ecx
    dec ebx
    call setview_
    cmp word ptr [_ud + 0x590], 2
    jge game_flow_nonsharedkeys_60234
    cmp dword ptr [_ud + 0x5fa], 2
    je game_flow_nonsharedkeys_60234
    xor dh, dh
    mov eax, dword ptr [_ototalclock]
    mov byte ptr [_ready2send], dh
    mov dword ptr [_totalclock], eax
game_flow_nonsharedkeys_60234:
    cmp word ptr [_ud + 0x590], 2
    {disp32} jge game_flow_nonsharedkeys_60613
    cmp byte ptr [_KB_KeyDown + 0x3c], 0
    {disp32} je game_flow_nonsharedkeys_60494
    xor ch, ch
    mov byte ptr [_KB_KeyDown + 0x3c], ch
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    movsx edx, word ptr [eax + _ps + 0x2d4]
    imul edx, edx, 0x2c
    cmp word ptr [edx + _sprite + 0x2a], 0
    jg game_flow_nonsharedkeys_60329
    mov edx, OFFSET FLAT:_ps
    {store} add edx, eax
    mov eax, 0x76
    call FTA_
    add esp, 0x1c
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_nonsharedkeys_60329:
    mov eax, 0x15e
    call cmenu_
    mov al, 1
    mov edx, 0x10000
    mov byte ptr [_screencapt], al
    movsx eax, word ptr [_myconnectindex]
    mov ebx, 0x3e80
    call displayrooms_
    mov eax, OFFSET FLAT:game_text_gameexit_412
    mov edx, dword ptr [_waloff + 0x3ff4]
    call savetemp_
    xor ah, ah
    {store} xor edx, edx
    mov byte ptr [_screencapt], ah
    call FX_StopAllSounds_
    call clearsoundlocks_
    mov ecx, dword ptr [_ydim]
    mov ebx, dword ptr [_xdim]
    {store} xor eax, eax
    dec ecx
    dec ebx
    call setview_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov dl, byte ptr [eax + _ps + 0x516]
    or dl, 1
    mov ebp, dword ptr [_ud + 0x5fa]
    mov byte ptr [eax + _ps + 0x516], dl
    cmp ebp, 2
    je game_flow_nonsharedkeys_60482
    xor dh, dh
    mov eax, dword ptr [_ototalclock]
    mov byte ptr [_ready2send], dh
    mov dword ptr [_totalclock], eax
game_flow_nonsharedkeys_60482:
    mov ax, word ptr [_myconnectindex]
    mov word ptr [_screenpeek], ax
game_flow_nonsharedkeys_60494:
    cmp byte ptr [_KB_KeyDown + 0x3d], 0
    je game_flow_nonsharedkeys_60613
    xor bh, bh
    mov byte ptr [_KB_KeyDown + 0x3d], bh
    mov eax, 0x12c
    call cmenu_
    call FX_StopAllSounds_
    call clearsoundlocks_
    {store} xor edx, edx
    mov ecx, dword ptr [_ydim]
    mov ebx, dword ptr [_xdim]
    {store} xor eax, eax
    dec ecx
    dec ebx
    call setview_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    or byte ptr [eax + _ps + 0x516], 1
    cmp dword ptr [_ud + 0x5fa], 2
    je game_flow_nonsharedkeys_60601
    xor ch, ch
    mov eax, dword ptr [_ototalclock]
    mov byte ptr [_ready2send], ch
    mov dword ptr [_totalclock], eax
game_flow_nonsharedkeys_60601:
    mov ax, word ptr [_myconnectindex]
    mov word ptr [_screenpeek], ax
game_flow_nonsharedkeys_60613:
    cmp byte ptr [_KB_KeyDown + 0x3e], 0
    je game_flow_nonsharedkeys_60727
    cmp dword ptr [_FXDevice], 0xd
    je game_flow_nonsharedkeys_60727
    xor ah, ah
    mov byte ptr [_KB_KeyDown + 0x3e], ah
    call FX_StopAllSounds_
    call clearsoundlocks_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov dl, byte ptr [eax + _ps + 0x516]
    or dl, 1
    mov si, word ptr [_ud + 0x590]
    mov byte ptr [eax + _ps + 0x516], dl
    cmp si, 2
    jge game_flow_nonsharedkeys_60717
    cmp dword ptr [_ud + 0x5fa], 2
    je game_flow_nonsharedkeys_60717
    xor dh, dh
    mov eax, dword ptr [_ototalclock]
    mov byte ptr [_ready2send], dh
    mov dword ptr [_totalclock], eax
game_flow_nonsharedkeys_60717:
    mov eax, 0x2bc
    call cmenu_
game_flow_nonsharedkeys_60727:
    cmp byte ptr [_KB_KeyDown + 0x40], 0
    {disp32} je game_flow_nonsharedkeys_61067
    cmp word ptr [_ud + 0x590], 2
    {disp32} jge game_flow_nonsharedkeys_61067
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    test byte ptr [eax + _ps + 0x516], 4
    {disp32} je game_flow_nonsharedkeys_61067
    xor cl, cl
    mov byte ptr [_KB_KeyDown + 0x40], cl
    call KB_FlushKeyboardQueue_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    movsx edx, word ptr [eax + _ps + 0x2d4]
    imul edx, edx, 0x2c
    cmp word ptr [edx + _sprite + 0x2a], 0
    jg game_flow_nonsharedkeys_60853
    mov edx, OFFSET FLAT:_ps
    {store} add edx, eax
    mov eax, 0x76
    call FTA_
    add esp, 0x1c
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_nonsharedkeys_60853:
    mov eax, 0x15e
    mov ch, 1
    mov edx, 0x10000
    mov ebx, 0x3e80
    call cmenu_
    movsx eax, word ptr [_myconnectindex]
    mov byte ptr [_screencapt], ch
    call displayrooms_
    mov eax, OFFSET FLAT:game_text_gameexit_412
    mov edx, dword ptr [_waloff + 0x3ff4]
    call savetemp_
    mov byte ptr [_screencapt], cl
    mov cx, word ptr [_lastsavedpos]
    test cx, cx
    jl game_flow_nonsharedkeys_60966
    movsx eax, cx
    imul eax, eax, 0x16
    add eax, OFFSET FLAT:_ud + 0x3a9
    call strlen_
    mov word ptr [_inputloc], ax
    mov ax, word ptr [_lastsavedpos]
    .att_syntax prefix
    addl $game_math_nonsharedkeys_60955,%eax
    .intel_syntax noprefix
    cwde
    call cmenu_
game_flow_nonsharedkeys_60966:
    call FX_StopAllSounds_
    call clearsoundlocks_
    mov ecx, dword ptr [_ydim]
    mov ebx, dword ptr [_xdim]
    {store} xor edx, edx
    {store} xor eax, eax
    dec ecx
    dec ebx
    call setview_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov dl, byte ptr [eax + _ps + 0x516]
    or dl, 1
    mov si, word ptr [_ud + 0x590]
    mov byte ptr [eax + _ps + 0x516], dl
    cmp si, 2
    jge game_flow_nonsharedkeys_61067
    cmp dword ptr [_ud + 0x5fa], 2
    je game_flow_nonsharedkeys_61067
    xor dh, dh
    mov eax, dword ptr [_ototalclock]
    mov byte ptr [_ready2send], dh
    mov dword ptr [_totalclock], eax
game_flow_nonsharedkeys_61067:
    cmp byte ptr [_KB_KeyDown + 0x41], 0
    je game_flow_nonsharedkeys_61186
    xor bh, bh
    mov byte ptr [_KB_KeyDown + 0x41], bh
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    cmp word ptr [eax + _ps + 0x2d8], 0
    je game_flow_nonsharedkeys_61118
    xor bl, bl
    mov word ptr [eax + _ps + 0x2d8], bx
    jmp game_flow_nonsharedkeys_61148
game_flow_nonsharedkeys_61118:
    {store} xor esi, esi
    mov edx, 1
    mov dword ptr [_cameradist], esi
    mov word ptr [eax + _ps + 0x2d8], dx
    mov eax, dword ptr [_totalclock]
    mov dword ptr [_cameraclock], eax
game_flow_nonsharedkeys_61148:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov edx, OFFSET FLAT:_ps
    {store} add edx, eax
    mov ax, word ptr [eax + _ps + 0x2d8]
    .att_syntax prefix
    addl $game_math_nonsharedkeys_61175,%eax
    .intel_syntax noprefix
    cwde
    call FTA_
game_flow_nonsharedkeys_61186:
    cmp byte ptr [_KB_KeyDown + 0x3f], 0
    je game_flow_nonsharedkeys_61290
    xor ch, ch
    mov byte ptr [_KB_KeyDown + 0x3f], ch
    {store} xor eax, eax
    mov al, byte ptr [_music_select]
    imul eax, eax, 0xd
    mov edx, OFFSET FLAT:_music_fn
    {store} add edx, eax
    mov eax, OFFSET FLAT:_tempbuf
    call strcpy_
    mov edx, OFFSET FLAT:game_text_nonsharedkeys_624
    mov eax, OFFSET FLAT:_tempbuf
    call strcat_
    mov edx, OFFSET FLAT:_tempbuf
    mov eax, OFFSET FLAT:_fta_quotes + 0x680
    call strcpy_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov edx, OFFSET FLAT:_ps
    {store} add edx, eax
    mov eax, 0x1a
    call FTA_
game_flow_nonsharedkeys_61290:
    cmp byte ptr [_KB_KeyDown + 0x42], 0
    je game_flow_nonsharedkeys_61409
    xor ah, ah
    mov byte ptr [_KB_KeyDown + 0x42], ah
    cmp dword ptr [_ud + 0x5c6], 0
    sete al
    and eax, 0xff
    mov dword ptr [_ud + 0x5c6], eax
    je game_flow_nonsharedkeys_61361
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov edx, OFFSET FLAT:_ps
    {store} add edx, eax
    mov eax, 0x17
    call FTA_
    jmp game_flow_nonsharedkeys_61409
game_flow_nonsharedkeys_61361:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov edx, OFFSET FLAT:_ps
    mov ebp, 1
    {store} add edx, eax
    mov eax, 0x18
    mov dword ptr [_ud + 0x5c6], ebp
    call FTA_
    {store} xor eax, eax
    mov dword ptr [_ud + 0x5c6], eax
game_flow_nonsharedkeys_61409:
    cmp byte ptr [_KB_KeyDown + 0x43], 0
    {disp32} je game_flow_nonsharedkeys_61575
    cmp word ptr [_ud + 0x590], 2
    {disp32} jge game_flow_nonsharedkeys_61575
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    test byte ptr [eax + _ps + 0x516], 4
    {disp32} je game_flow_nonsharedkeys_61575
    xor bl, bl
    mov byte ptr [_KB_KeyDown + 0x43], bl
    cmp word ptr [_lastsavedpos], 0
    jl game_flow_nonsharedkeys_61487
    mov eax, 0x3a99
    jmp game_flow_nonsharedkeys_61492
game_flow_nonsharedkeys_61487:
    mov eax, 0x61a8
game_flow_nonsharedkeys_61492:
    call cmenu_
    call FX_StopAllSounds_
    call clearsoundlocks_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov bh, byte ptr [eax + _ps + 0x516]
    or bh, 1
    mov di, word ptr [_ud + 0x590]
    mov byte ptr [eax + _ps + 0x516], bh
    cmp di, 2
    jge game_flow_nonsharedkeys_61575
    cmp dword ptr [_ud + 0x5fa], 2
    je game_flow_nonsharedkeys_61575
    xor cl, cl
    mov eax, dword ptr [_ototalclock]
    mov byte ptr [_ready2send], cl
    mov dword ptr [_totalclock], eax
game_flow_nonsharedkeys_61575:
    cmp byte ptr [_KB_KeyDown + 0x44], 0
    je game_flow_nonsharedkeys_61668
    xor al, al
    mov byte ptr [_KB_KeyDown + 0x44], al
    mov eax, 0x1f4
    call cmenu_
    call FX_StopAllSounds_
    call clearsoundlocks_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    or byte ptr [eax + _ps + 0x516], 1
    cmp word ptr [_ud + 0x590], 2
    jge game_flow_nonsharedkeys_61668
    cmp dword ptr [_ud + 0x5fa], 2
    je game_flow_nonsharedkeys_61668
    xor dh, dh
    mov eax, dword ptr [_ototalclock]
    mov byte ptr [_ready2send], dh
    mov dword ptr [_totalclock], eax
game_flow_nonsharedkeys_61668:
    cmp byte ptr [_ud + 0x585], 0
    {disp32} je game_flow_nonsharedkeys_61895
    mov ecx, dword ptr [_totalclock]
    mov esi, dword ptr [_nonsharedtimer]
    {store} sub ecx, esi
    mov eax, dword ptr [_CONTROL_ButtonState2]
    lea edi, dword ptr [esi + ecx]
    shr eax, 8
    mov dword ptr [_nonsharedtimer], edi
    test al, 1
    je game_flow_nonsharedkeys_61768
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov ebp, dword ptr [eax + _ps]
    lea esi, dword ptr [eax + _ps]
    cmp ebp, 0x100
    jle game_flow_nonsharedkeys_61753
    {store} mov ebx, ebp
    jmp game_flow_nonsharedkeys_61758
game_flow_nonsharedkeys_61753:
    mov ebx, 0x100
game_flow_nonsharedkeys_61758:
    {store} mov eax, ecx
    imul ebx
    shrd eax, edx, 6
    add dword ptr [esi], eax
game_flow_nonsharedkeys_61768:
    mov eax, dword ptr [_CONTROL_ButtonState2]
    shr eax, 7
    test al, 1
    je game_flow_nonsharedkeys_61828
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov ebx, dword ptr [eax + _ps]
    lea esi, dword ptr [eax + _ps]
    cmp ebx, 0x100
    jg game_flow_nonsharedkeys_61818
    mov ebx, 0x100
game_flow_nonsharedkeys_61818:
    {store} mov eax, ecx
    imul ebx
    shrd eax, edx, 6
    sub dword ptr [esi], eax
game_flow_nonsharedkeys_61828:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    cmp dword ptr [eax + _ps], 0x800
    jle game_flow_nonsharedkeys_61863
    mov dword ptr [eax + _ps], 0x800
game_flow_nonsharedkeys_61863:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    cmp dword ptr [eax + _ps], 0x30
    jge game_flow_nonsharedkeys_61895
    mov dword ptr [eax + _ps], 0x30
game_flow_nonsharedkeys_61895:
    cmp byte ptr [_KB_KeyDown + 0x1], 0
    je game_flow_nonsharedkeys_61973
    mov cl, byte ptr [_ud + 0x585]
    test cl, cl
    je game_flow_nonsharedkeys_61973
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    movsx eax, word ptr [eax + _ps + 0x2b2]
    cmp eax, -1
    jne game_flow_nonsharedkeys_61973
    xor ch, ch
    mov byte ptr [_KB_KeyDown + 0x1], ch
    {store} mov al, cl
    mov byte ptr [_ud + 0x586], cl
    xor al, cl
    mov byte ptr [_ud + 0x7], ch
    mov byte ptr [_ud + 0x585], al
    call vscrn_
game_flow_nonsharedkeys_61973:
    mov eax, dword ptr [_CONTROL_ButtonState1]
    shr eax, 8
    test al, 1
    je game_flow_nonsharedkeys_62049
    mov eax, 8
    call CONTROL_ClearButton_
    movsx edx, word ptr [_myconnectindex]
    imul edx, edx, 0x552
    mov eax, 1
    mov ebx, dword ptr [_ud + 0x5ce]
    {store} sub eax, ebx
    mov dword ptr [_ud + 0x5ce], eax
    mov ax, word ptr [_ud + 0x5ce]
    .att_syntax prefix
    addl $game_math_nonsharedkeys_62032,%eax
    .intel_syntax noprefix
    cwde
    add edx, OFFSET FLAT:_ps
    call FTA_
game_flow_nonsharedkeys_62049:
    mov eax, dword ptr [_CONTROL_ButtonState2]
    shr eax, 6
    test al, 1
    je game_flow_nonsharedkeys_62152
    mov eax, 0x26
    call CONTROL_ClearButton_
    mov al, byte ptr [_ud + 0x586]
    cmp al, byte ptr [_ud + 0x585]
    je game_flow_nonsharedkeys_62103
    test al, al
    je game_flow_nonsharedkeys_62103
    xor ch, ch
    mov byte ptr [_ud + 0x585], al
    mov byte ptr [_ud + 0x586], ch
    jmp game_flow_nonsharedkeys_62140
game_flow_nonsharedkeys_62103:
    mov bl, byte ptr [_ud + 0x585]
    inc bl
    mov byte ptr [_ud + 0x585], bl
    cmp bl, 3
    jne game_flow_nonsharedkeys_62130
    xor cl, cl
    mov byte ptr [_ud + 0x585], cl
game_flow_nonsharedkeys_62130:
    mov al, byte ptr [_ud + 0x585]
    mov byte ptr [_ud + 0x586], al
game_flow_nonsharedkeys_62140:
    mov byte ptr [_restorepalette], 1
    call vscrn_
game_flow_nonsharedkeys_62152:
    cmp byte ptr [_KB_KeyDown + 0x57], 0
    {disp32} je game_flow_nonsharedkeys_62344
    xor dl, dl
    mov byte ptr [_KB_KeyDown + 0x57], dl
    cmp byte ptr [_KB_KeyDown + 0x36], 0
    jne game_flow_nonsharedkeys_62191
    cmp byte ptr [_KB_KeyDown + 0x2a], 0
    je game_flow_nonsharedkeys_62200
game_flow_nonsharedkeys_62191:
    sub dword ptr [_ud + 0x602], 4
    jmp game_flow_nonsharedkeys_62207
game_flow_nonsharedkeys_62200:
    add dword ptr [_ud + 0x602], 4
game_flow_nonsharedkeys_62207:
    mov edi, dword ptr [_ud + 0x602]
    cmp edi, 0x1c
    jle game_flow_nonsharedkeys_62228
    {store} xor edx, edx
    mov dword ptr [_ud + 0x602], edx
    jmp game_flow_nonsharedkeys_62242
game_flow_nonsharedkeys_62228:
    test edi, edi
    jge game_flow_nonsharedkeys_62242
    mov dword ptr [_ud + 0x602], 0x1c
game_flow_nonsharedkeys_62242:
    movsx edx, word ptr [_myconnectindex]
    imul edx, edx, 0x552
    mov eax, dword ptr [_ud + 0x602]
    sar eax, 2
    mov edx, dword ptr [edx + _ps + 0x541]
    call setbrightness_
    mov eax, dword ptr [_ud + 0x602]
    mov ebx, dword ptr [_ud + 0x602]
    sar eax, 2
    cmp ebx, 0x14
    jge game_flow_nonsharedkeys_62311
    movsx edx, word ptr [_myconnectindex]
    imul edx, edx, 0x552
    add eax, 0x1d
    jmp game_flow_nonsharedkeys_62332
game_flow_nonsharedkeys_62311:
    cmp ebx, 0x28
    jge game_flow_nonsharedkeys_62344
    movsx edx, word ptr [_myconnectindex]
    imul edx, edx, 0x552
    add eax, 0x5b
game_flow_nonsharedkeys_62332:
    cwde
    add edx, OFFSET FLAT:_ps
    call FTA_
game_flow_nonsharedkeys_62344:
    add esp, 0x1c
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
    {load} mov eax, eax
comlinehelp_:
    push edx
    mov edx, dword ptr [eax]
    push edx
    push OFFSET FLAT:game_text_comlinehelp_652
    call printf_
    add esp, 8
    mov eax, OFFSET FLAT:game_text_comlinehelp_688
    call puts_
    mov eax, OFFSET FLAT:game_text_comlinehelp_720
    call puts_
    mov eax, OFFSET FLAT:game_text_comlinehelp_748
    call puts_
    mov eax, OFFSET FLAT:game_text_comlinehelp_776
    call puts_
    mov eax, OFFSET FLAT:game_text_comlinehelp_804
    call puts_
    mov eax, OFFSET FLAT:game_text_comlinehelp_832
    call puts_
    mov eax, OFFSET FLAT:game_text_comlinehelp_860
    call puts_
    mov eax, OFFSET FLAT:game_text_comlinehelp_884
    call puts_
    mov eax, OFFSET FLAT:game_text_comlinehelp_908
    call puts_
    mov eax, OFFSET FLAT:game_text_comlinehelp_980
    call puts_
    mov eax, OFFSET FLAT:game_text_comlinehelp_1060
    call puts_
    mov eax, OFFSET FLAT:game_text_comlinehelp_1096
    call puts_
    mov eax, OFFSET FLAT:game_text_comlinehelp_1140
    call puts_
    mov eax, OFFSET FLAT:game_text_comlinehelp_1192
    call puts_
    mov eax, OFFSET FLAT:game_text_comlinehelp_1240
    call puts_
    mov eax, OFFSET FLAT:game_text_comlinehelp_1288
    call puts_
    mov eax, OFFSET FLAT:game_text_comlinehelp_1340
    call puts_
    mov eax, OFFSET FLAT:game_text_comlinehelp_1392
    call puts_
    pop edx
    ret
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
printstr_:
    push esi
    push edi
    sub esp, 4
    {store} mov esi, ebx
    mov byte ptr [esp], cl
    imul edx, edx, 0x50
    {store} add edx, eax
    {store} xor ebx, ebx
    {store} add edx, edx
game_flow_printstr_63891:
    movsx eax, bx
    {store} add eax, esi
    mov cl, byte ptr [eax]
    test cl, cl
    je game_flow_printstr_63941
    movzx edi, byte ptr [esp]
    {store} mov al, cl
    shl edi, 8
    and eax, 0xff
    {store} add eax, edi
    movsx edi, dx
    mov ecx, 1
    add edi, 0xb8000
    inc ebx
    rep
    stosw word ptr es:[edi], ax
    add edx, 2
    jmp game_flow_printstr_63891
game_flow_printstr_63941:
    add esp, 4
    pop edi
    pop esi
    ret
    {disp8} lea eax, dword ptr [eax]
    {load} mov ecx, ecx
Logo_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    call KB_FlushKeyboardQueue_
    mov ecx, dword ptr [_ydim]
    mov ebx, dword ptr [_xdim]
    {store} xor edx, edx
    {store} xor eax, eax
    dec ecx
    dec ebx
    call setview_
    {store} xor eax, eax
    mov ecx, 0x3f
    call clearview_
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    {store} xor edi, edi
    call palto_
    call flushperms_
    call nextpage_
    call MUSIC_StopSong_
    call KB_KeyWaiting_
    test eax, eax
    jne game_flow_Logo_64071
    mov edx, 5
    mov eax, OFFSET FLAT:game_text_Logo_1708
    mov ecx, 0x3f
    call playanm_
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    call palto_
    call KB_FlushKeyboardQueue_
game_flow_Logo_64071:
    {store} xor eax, eax
    call clearview_
    call nextpage_
    mov eax, OFFSET FLAT:_env_music_fn
    {store} xor esi, esi
    call playmusic_
    jmp game_flow_Logo_64114
game_flow_Logo_64097:
    movsx ecx, si
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    call palto_
    add esi, 7
game_flow_Logo_64114:
    cmp si, 0x40
    jl game_flow_Logo_64097
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov edx, OFFSET FLAT:_drealms
    mov ecx, 0x3f
    {store} xor ebx, ebx
    mov dword ptr [eax + _ps + 0x541], edx
    {store} xor edx, edx
    {store} xor eax, eax
    call palto_
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0x5a
    push 0
    mov ebx, 0x10000
    push 0
    {store} xor ecx, ecx
    {store} xor edx, edx
    push 0x9bc
    {store} xor eax, eax
    mov esi, 0x3f
    call rotatesprite_
    call nextpage_
    jmp game_flow_Logo_64234
game_flow_Logo_64217:
    movsx ecx, si
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    call palto_
    sub esi, 7
game_flow_Logo_64234:
    test si, si
    jg game_flow_Logo_64217
    {store} xor ebx, ebx
    mov dword ptr [_totalclock], ebx
game_flow_Logo_64247:
    cmp dword ptr [_totalclock], 0x348
    jge game_flow_Logo_64268
    call KB_KeyWaiting_
    test eax, eax
    je game_flow_Logo_64247
game_flow_Logo_64268:
    {store} xor esi, esi
    jmp game_flow_Logo_64289
game_flow_Logo_64272:
    movsx ecx, si
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    call palto_
    add esi, 7
game_flow_Logo_64289:
    cmp si, 0x40
    jl game_flow_Logo_64272
    {store} xor eax, eax
    call clearview_
    call nextpage_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov dword ptr [eax + _ps + 0x541], OFFSET FLAT:_titlepal
    call flushperms_
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0x5a
    push 0
    mov ebx, 0x10000
    push 0
    {store} xor ecx, ecx
    {store} xor edx, edx
    push 0x9bd
    {store} xor eax, eax
    mov esi, 0x3f
    call rotatesprite_
    call KB_FlushKeyboardQueue_
    call nextpage_
    jmp game_flow_Logo_64414
game_flow_Logo_64397:
    movsx ecx, si
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    call palto_
    sub esi, 7
game_flow_Logo_64414:
    test si, si
    jg game_flow_Logo_64397
    {store} xor ebp, ebp
    mov dword ptr [_totalclock], ebp
game_flow_Logo_64427:
    cmp dword ptr [_totalclock], 0x3d4
    {disp32} jge game_flow_Logo_64908
    call KB_KeyWaiting_
    test eax, eax
    {disp32} jne game_flow_Logo_64908
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0x5a
    push 0
    push 0
    mov ebx, 0x10000
    {store} xor ecx, ecx
    push 0x9bd
    {store} xor edx, edx
    {store} xor eax, eax
    call rotatesprite_
    cmp dword ptr [_totalclock], 0x78
    jle game_flow_Logo_64597
    cmp dword ptr [_totalclock], 0xb4
    jge game_flow_Logo_64597
    test di, di
    jne game_flow_Logo_64542
    mov eax, 0xe
    mov edi, 1
    call sound_
game_flow_Logo_64542:
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0xa
    mov ebx, dword ptr [_totalclock]
    push 0
    mov edx, 0x680000
    mov eax, 0xa00000
    push 0
    sub ebx, 0x78
    {store} xor ecx, ecx
    push 0x9c1
    shl ebx, 0xa
    jmp game_flow_Logo_64655
game_flow_Logo_64597:
    cmp dword ptr [_totalclock], 0xb4
    jl game_flow_Logo_64660
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0xa
    push 0
    push 0
    mov ebx, 0xf000
    mov edx, 0x680000
    push 0x9c1
    {store} xor ecx, ecx
    mov eax, 0xa00000
game_flow_Logo_64655:
    call rotatesprite_
game_flow_Logo_64660:
    cmp dword ptr [_totalclock], 0xdc
    {disp32} jle game_flow_Logo_64835
    cmp dword ptr [_totalclock], 0xfa
    {disp32} jge game_flow_Logo_64835
    cmp di, 1
    jne game_flow_Logo_64713
    mov eax, 0xe
    mov edi, 2
    call sound_
game_flow_Logo_64713:
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0xa
    push 0
    push 0
    mov ebx, 0xf000
    mov edx, 0x680000
    push 0x9c1
    {store} xor ecx, ecx
    mov eax, 0xa00000
    call rotatesprite_
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0xa
    mov ebx, dword ptr [_totalclock]
    push 0
    mov edx, 0x810000
    mov eax, 0xa00000
    push 0
    sub ebx, 0xdc
    {store} xor ecx, ecx
    push 0x9c2
    shl ebx, 0xb
    call rotatesprite_
    call nextpage_
    {disp32} jmp game_flow_Logo_64427
game_flow_Logo_64835:
    cmp dword ptr [_totalclock], 0xfa
    jl game_flow_Logo_64898
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0xa
    push 0
    push 0
    mov ebx, 0xf000
    mov edx, 0x810000
    push 0x9c2
    {store} xor ecx, ecx
    mov eax, 0xa00000
    call rotatesprite_
game_flow_Logo_64898:
    call nextpage_
    {disp32} jmp game_flow_Logo_64427
game_flow_Logo_64908:
    call flushperms_
    {store} xor eax, eax
    call clearview_
    call nextpage_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov dword ptr [eax + _ps + 0x541], OFFSET FLAT:_palette
    mov eax, 0xd5
    call sound_
    cmp word ptr [_numplayers], 1
    jle game_flow_Logo_65005
    {store} xor ecx, ecx
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    call palto_
    push OFFSET FLAT:game_text_Logo_1720
    mov edx, 0x64
    mov eax, 0xa0
    {store} xor ecx, ecx
    {store} xor ebx, ebx
    call menutext_
game_flow_Logo_65005:
    {store} xor eax, eax
    call clearview_
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp8} lea eax, dword ptr [eax]
    {load} mov ecx, ecx
loadtmb_:
    push ebx
    push ecx
    push edx
    sub esp, 0x1f40
    {store} xor edx, edx
    mov eax, OFFSET FLAT:game_text_loadtmb_1744
    mov dl, byte ptr [_loadfromgrouponly]
    call kopen4load_
    {store} mov ecx, eax
    cmp eax, -1
    je game_flow_loadtmb_65088
    call kfilelength_
    {store} mov edx, esp
    {store} mov ebx, eax
    {store} mov eax, ecx
    call kread_
    {store} mov eax, esp
    call MUSIC_RegisterTimbreBank_
    {store} mov eax, ecx
    call kclose_
game_flow_loadtmb_65088:
    add esp, 0x1f40
    pop edx
    pop ecx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
ShutDown_:
    # Actual native lifetime order: CONTROL closes before the keyboard.
    call CONTROL_Shutdown_
    call KB_Shutdown_
    call SoundShutdown_
    call MusicShutdown_
    call uninittimer_
    call uninitengine_
    {disp32} jmp CONFIG_WriteSetup_
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
    nop
compilecons_:
    push ebx
    push ecx
    push edx
    mov edx, OFFSET FLAT:_hittype
    mov ebx, OFFSET FLAT:_sector
    mov ecx, OFFSET FLAT:_sprite
    mov eax, OFFSET FLAT:_confilename
    mov dword ptr [_label], edx
    mov dword ptr [_labelcode], ebx
    {store} mov edx, ecx
    mov dword ptr [_mymembuf], ecx
    call loadefs_
    cmp byte ptr [_loadfromgrouponly], 0
    je game_flow_compilecons_65248
    push OFFSET FLAT:_groupfilename
    push OFFSET FLAT:_confilename
    push OFFSET FLAT:game_text_compilecons_1760
    call printf_
    add esp, 0xc
    mov eax, OFFSET FLAT:_confilename
    mov edx, dword ptr [_mymembuf]
    call loadefs_
game_flow_compilecons_65248:
    pop edx
    pop ecx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
Startup_:
    push ebx
    push edx
    push esi
    call KB_Startup_
    call compilecons_
    call CONFIG_GetSetupFilename_
    call CONFIG_ReadSetup_
    cmp dword ptr [_CommandSoundToggleOff], 0
    je game_flow_Startup_65304
    {store} xor ebx, ebx
    mov dword ptr [_SoundToggle], ebx
game_flow_Startup_65304:
    cmp dword ptr [_CommandMusicToggleOff], 0
    je game_flow_Startup_65321
    {store} xor esi, esi
    mov dword ptr [_MusicToggle], esi
game_flow_Startup_65321:
    mov ebx, 0x78
    {store} xor eax, eax
    mov edx, OFFSET FLAT:GetTime_
    mov al, byte ptr [_ControllerType]
    call CONTROL_Startup_
    mov ebx, dword ptr [_ScreenHeight]
    mov edx, dword ptr [_ScreenWidth]
    mov eax, dword ptr [_ScreenMode]
    call initengine_
    call inittimer_
    mov eax, OFFSET FLAT:game_text_Startup_1784
    call puts_
    {store} xor edx, edx
    mov eax, OFFSET FLAT:game_text_Startup_1804
    {store} xor ebx, ebx
    call loadpics_
    call readsavenames_
    mov word ptr [_tilesizy + 0x460], dx
    mov word ptr [_tilesizx + 0x460], dx
    {store} xor eax, eax
    {store} xor edx, edx
    call initmultiplayers_
    cmp word ptr [_numplayers], 1
    jle game_flow_Startup_65442
    mov eax, OFFSET FLAT:game_text_Startup_1820
    call puts_
game_flow_Startup_65442:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov dword ptr [eax + _ps + 0x541], OFFSET FLAT:_palette
    call SetupGameButtons_
    cmp byte ptr [_networkmode], 0xff
    jne game_flow_Startup_65515
    mov si, word ptr [_numplayers]
    cmp si, 1
    jle game_flow_Startup_65507
    cmp si, 4
    jg game_flow_Startup_65507
    mov byte ptr [_networkmode], 1
    jmp game_flow_Startup_65515
game_flow_Startup_65507:
    xor dl, dl
    mov byte ptr [_networkmode], dl
game_flow_Startup_65515:
    mov eax, OFFSET FLAT:game_text_Startup_1848
    call puts_
    call MusicStartup_
    mov eax, OFFSET FLAT:game_text_Startup_1872
    call puts_
    call SoundStartup_
    call loadtmb_
    pop esi
    pop edx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
    {load} mov eax, eax
sendscore_:
    push ebx
    push ecx
    push edx
    {store} mov edx, eax
    cmp word ptr [_numplayers], 1
    jle game_flow_sendscore_65606
    call strlen_
    lea ebx, dword ptr [eax + 1]
    mov ecx, 5
    mov eax, 0xffffffff
    call genericmultifunction_
game_flow_sendscore_65606:
    pop edx
    pop ecx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
getnames_:
    push ebx
    push ecx
    push edx
    push esi
    mov ah, 6
    mov dl, 0x67
    {store} xor esi, esi
    mov byte ptr [_buf], ah
    mov byte ptr [_buf + 0x1], dl
    jmp game_flow_getnames_65686
game_flow_getnames_65640:
    {store} xor eax, eax
    {store} mov al, bl
    call toupper_
    movsx ebx, word ptr [_myconnectindex]
    shl ebx, 5
    mov byte ptr [edx + ebx + _ud + 0x9], al
    {store} xor eax, eax
    mov al, byte ptr [edx + _myname]
    inc esi
    call toupper_
    mov byte ptr [edx + _buf + 0x2], al
game_flow_getnames_65686:
    movsx edx, si
    mov bl, byte ptr [edx + _myname]
    test bl, bl
    jne game_flow_getnames_65640
    cmp word ptr [_numplayers], 1
    jle game_flow_getnames_65790
    mov eax, OFFSET FLAT:game_text_getnames_1896
    xor bh, bh
    add esi, 3
    mov byte ptr [edx + _buf + 0x2], bh
    call puts_
    call waitforeverybody_
    mov cx, word ptr [_connecthead]
    jmp game_flow_getnames_65780
game_flow_getnames_65744:
    cmp cx, word ptr [_myconnectindex]
    je game_flow_getnames_65769
    mov edx, OFFSET FLAT:_buf
    movsx ebx, si
    movsx eax, cx
    call sendpacket_
game_flow_getnames_65769:
    movsx ecx, cx
    mov cx, word ptr [ecx*2 + _connectpoint2]
game_flow_getnames_65780:
    test cx, cx
    jge game_flow_getnames_65744
    call getpackets_
game_flow_getnames_65790:
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
    nop
main_:
    push ebx
    push ecx
    push esi
    push edi
    push ebp
    {store} mov edi, eax
    {store} mov esi, edx
    mov ah, 0x54
    mov ecx, 0x4f
    mov ebx, OFFSET FLAT:game_text_main_1928
    mov byte ptr [_todd], ah
    mov eax, 3
    {store} xor edx, edx
    int 0x10
    {store} xor eax, eax
    call printstr_
    mov ecx, 0x4f
    mov ebx, OFFSET FLAT:game_text_main_2012
    mov eax, 0x18
    {store} xor edx, edx
    call printstr_
    call Z_AvailHeap_
    .att_syntax prefix
    cmpl $game_math_main_65878,%eax
    .intel_syntax noprefix
    jge game_flow_main_65922
    mov eax, OFFSET FLAT:game_text_main_2048
    call puts_
    mov eax, OFFSET FLAT:game_text_main_2108
    call puts_
    mov eax, OFFSET FLAT:game_text_main_2164
    call puts_
    {store} xor eax, eax
    call exit_
game_flow_main_65922:
    mov edx, 1
    push OFFSET FLAT:game_text_gameexit_400
    mov word ptr [_ud + 0x590], dx
    call printf_
    add esp, 4
    {store} mov edx, esi
    {store} mov eax, edi
    call checkcommandline_
    cmp byte ptr [_movesperpacket], 4
    {disp32} jne game_flow_main_66104
    mov eax, OFFSET FLAT:game_text_main_2188
    call puts_
    mov eax, OFFSET FLAT:game_text_main_2248
    call puts_
    mov eax, OFFSET FLAT:game_text_main_2316
    call puts_
    mov eax, OFFSET FLAT:game_text_main_2324
    call puts_
    mov eax, OFFSET FLAT:game_text_main_2384
    call puts_
    mov eax, OFFSET FLAT:game_text_main_2448
    call puts_
    mov eax, OFFSET FLAT:game_text_main_2500
    call puts_
    mov eax, OFFSET FLAT:game_text_main_2564
    call puts_
    mov eax, OFFSET FLAT:game_text_main_2600
    call puts_
    mov eax, OFFSET FLAT:game_text_main_2664
    call puts_
    mov eax, OFFSET FLAT:game_text_main_2688
    call puts_
    mov eax, OFFSET FLAT:game_text_main_2756
    call puts_
    mov eax, OFFSET FLAT:game_text_main_2816
    call puts_
    call getch_
game_flow_main_66104:
    mov eax, OFFSET FLAT:_groupfilename
    call initgroupfile_
    mov dword ptr [_groupfile], eax
    cmp eax, -1
    jne game_flow_main_66147
    push OFFSET FLAT:_groupfilename
    push OFFSET FLAT:game_text_main_2844
    call printf_
    add esp, 8
    {disp32} jmp game_flow_main_67285
game_flow_main_66147:
    mov eax, OFFSET FLAT:ShutDown_
    call RegisterShutdownFunction_
    push OFFSET FLAT:_groupfilename
    push OFFSET FLAT:game_text_main_2880
    call printf_
    add esp, 8
    call Startup_
    cmp byte ptr [_eightytwofifty], 0
    je game_flow_main_66278
    cmp word ptr [_numplayers], 1
    jle game_flow_main_66278
    mov eax, OFFSET FLAT:game_text_main_2896
    call puts_
    mov eax, OFFSET FLAT:game_text_main_2972
    call puts_
    mov eax, OFFSET FLAT:game_text_main_3004
    call puts_
    mov eax, OFFSET FLAT:game_text_main_3080
    call puts_
    mov eax, OFFSET FLAT:game_text_main_3156
    call puts_
    mov eax, OFFSET FLAT:game_text_main_3232
    call puts_
    mov eax, OFFSET FLAT:game_text_main_3288
    call puts_
game_flow_main_66269:
    call KB_KeyWaiting_
    test eax, eax
    je game_flow_main_66269
game_flow_main_66278:
    mov cx, word ptr [_numplayers]
    cmp cx, 1
    jle game_flow_main_66305
    mov word ptr [_ud + 0x590], cx
    call sendlogon_
    jmp game_flow_main_66341
game_flow_main_66305:
    cmp byte ptr [_boardfilename], 0
    je game_flow_main_66341
    {store} xor ebx, ebx
    mov edx, 7
    mov dword ptr [_ud + 0x626], ebx
    mov bh, 1
    mov dword ptr [_ud + 0x622], edx
    mov byte ptr [_ud + 0x1], bh
game_flow_main_66341:
    call getnames_
    cmp word ptr [_ud + 0x590], 1
    jle game_flow_main_66395
    mov al, byte ptr [_ud + 0x590]
    mov cl, byte ptr [_ud + 0x1]
    mov byte ptr [_playerswhenstarted], al
    test cl, cl
    jne game_flow_main_66395
    mov ecx, 1
    {store} xor esi, esi
    mov dword ptr [_ud + 0x616], ecx
    mov dword ptr [_ud + 0x61e], esi
game_flow_main_66395:
    mov edi, 0xffffffff
    mov eax, OFFSET FLAT:_ud + 0x505
    mov word ptr [_ud + 0x592], di
    call RTS_Init_
    cmp dword ptr [_numlumps], 0
    je game_flow_main_66444
    push OFFSET FLAT:_ud + 0x505
    push OFFSET FLAT:game_text_main_3364
    call printf_
    add esp, 8
game_flow_main_66444:
    cmp dword ptr [_CONTROL_JoystickEnabled], 0
    je game_flow_main_66483
    push OFFSET FLAT:CenterRudder_
    mov ecx, OFFSET FLAT:CenterThrottle_
    mov ebx, OFFSET FLAT:LowerRight_
    mov edx, OFFSET FLAT:UpperLeft_
    mov eax, OFFSET FLAT:CenterCenter_
    call CONTROL_CenterJoystick_
game_flow_main_66483:
    mov eax, OFFSET FLAT:game_text_main_3384
    call puts_
    call setgamemode_
    test eax, eax
    jge game_flow_main_66543
    mov eax, dword ptr [_ydim]
    push eax
    mov edx, dword ptr [_xdim]
    push edx
    push OFFSET FLAT:game_text_main_3412
    push OFFSET FLAT:_tempbuf
    call sprintf_
    add esp, 0x10
    mov eax, OFFSET FLAT:_tempbuf
    call gameexit_
game_flow_main_66543:
    call genspriteremaps_
    movsx edx, word ptr [_myconnectindex]
    imul edx, edx, 0x552
    mov eax, dword ptr [_ud + 0x602]
    sar eax, 2
    mov edx, dword ptr [edx + _ps + 0x541]
    call setbrightness_
    cmp byte ptr [_KB_KeyDown + 0x1], 0
    je game_flow_main_66599
    mov eax, OFFSET FLAT:game_text_getpackets_96
    call gameexit_
game_flow_main_66599:
    call FX_StopAllSounds_
    call clearsoundlocks_
    cmp byte ptr [_ud + 0x1], 0
    jne game_flow_main_66625
    call Logo_
    jmp game_flow_main_66663
game_flow_main_66625:
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    mov bl, byte ptr [_ud + 0x61e]
    mov dl, byte ptr [_ud + 0x622]
    mov al, byte ptr [_ud + 0x626]
    call newgame_
    mov eax, 4
    call enterlevel_
game_flow_main_66663:
    cmp byte ptr [_ud + 0x1], 0
    jne game_flow_main_66681
    call playback_
    test eax, eax
    jne game_flow_main_66599
game_flow_main_66681:
    xor dl, dl
    mov byte ptr [_ud + 0x1], dl
    cmp byte ptr [_wait_abort], 0
    jne game_flow_main_66599
game_flow_main_66698:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    test byte ptr [eax + _ps + 0x516], 0x80
    {disp32} jne game_flow_main_67275
    cmp dword ptr [_ud + 0x5fa], 2
    je game_flow_main_66764
    cmp word ptr [_ud + 0x590], 1
    jg game_flow_main_66764
    cmp byte ptr [_ud + 0x6], 0
    jne game_flow_main_66791
    mov al, byte ptr [eax + _ps + 0x516]
    and al, 1
    cmp al, 1
    je game_flow_main_66791
game_flow_main_66764:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    test byte ptr [eax + _ps + 0x516], 4
    je game_flow_main_66791
    call moveloop_
game_flow_main_66791:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov ch, byte ptr [eax + _ps + 0x516]
    test ch, 8
    jne game_flow_main_66824
    test ch, 0x20
    {disp32} je game_flow_main_67036
game_flow_main_66824:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    test byte ptr [eax + _ps + 0x516], 8
    {disp32} je game_flow_main_66972
    xor dh, dh
    mov byte ptr [_ready2send], dh
    {store} xor edx, edx
    mov ebx, dword ptr [_ud + 0x5e2]
    mov dword ptr [_ud + 0x5e2], edx
    call vscrn_
    {store} xor eax, eax
    mov dword ptr [_ud + 0x5e2], ebx
    call dobonus_
    cmp byte ptr [_ud + 0x3], 0
    je game_flow_main_66972
    xor bh, bh
    mov si, word ptr [_ud + 0x590]
    mov byte ptr [_ud + 0x3], bh
    cmp si, 2
    jge game_flow_main_66960
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov byte ptr [eax + _ps + 0x516], 1
    {store} xor eax, eax
    call cmenu_
    {store} xor eax, eax
    mov word ptr [_probey], ax
    {disp32} jmp game_flow_main_66599
game_flow_main_66960:
    mov dword ptr [_ud + 0x622], edx
    mov dword ptr [_ud + 0x62e], edx
game_flow_main_66972:
    cmp word ptr [_numplayers], 1
    jle game_flow_main_67002
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov byte ptr [eax + _ps + 0x516], 4
game_flow_main_67002:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov al, byte ptr [eax + _ps + 0x516]
    and eax, 0xff
    call enterlevel_
    {disp32} jmp game_flow_main_66698
game_flow_main_67036:
    call cheats_
    call nonsharedkeys_
    cmp byte ptr [_ud + 0x6], 0
    jne game_flow_main_67087
    cmp word ptr [_ud + 0x590], 2
    jge game_flow_main_67087
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    test byte ptr [eax + _ps + 0x516], 1
    je game_flow_main_67106
game_flow_main_67087:
    cmp word ptr [_ud + 0x590], 1
    jg game_flow_main_67106
    cmp dword ptr [_ud + 0x5fa], 2
    jne game_flow_main_67194
game_flow_main_67106:
    mov eax, dword ptr [_totalclock]
    mov esi, dword ptr [_ototalclock]
    {store} sub eax, esi
    shl eax, 0xe
    test eax, eax
    jle game_flow_main_67139
    mov ebx, dword ptr [_totalclock]
    {store} sub ebx, esi
    shl ebx, 0xe
    jmp game_flow_main_67141
game_flow_main_67139:
    {store} xor ebx, ebx
game_flow_main_67141:
    cmp ebx, 0x10000
    jge game_flow_main_67187
    mov ebx, dword ptr [_totalclock]
    mov ebp, dword ptr [_ototalclock]
    {store} sub ebx, ebp
    shl ebx, 0xe
    test ebx, ebx
    jle game_flow_main_67183
    mov ebx, dword ptr [_totalclock]
    {store} sub ebx, ebp
    shl ebx, 0xe
    jmp game_flow_main_67199
game_flow_main_67183:
    {store} xor ebx, ebx
    jmp game_flow_main_67199
game_flow_main_67187:
    mov ebx, 0x10000
    jmp game_flow_main_67199
game_flow_main_67194:
    mov ebx, 0x10000
game_flow_main_67199:
    movsx eax, word ptr [_screenpeek]
    {store} mov edx, ebx
    call displayrooms_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    test byte ptr [eax + _ps + 0x516], 2
    {disp32} jne game_flow_main_66599
    {store} mov eax, ebx
    call displayrest_
    cmp byte ptr [_debug_on], 0
    je game_flow_main_67260
    call caches_
game_flow_main_67260:
    call checksync_
    call nextpage_
    {disp32} jmp game_flow_main_66698
game_flow_main_67275:
    mov eax, OFFSET FLAT:game_text_getpackets_96
    call gameexit_
game_flow_main_67285:
    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
    {disp8} lea eax, dword ptr [eax]
    {load} mov ecx, ecx
opendemoread_:
    push ebx
    push edx
    mov ebx, OFFSET FLAT:game_text_opendemoread_3464
    cmp al, 0xa
    jne game_flow_opendemoread_67316
    mov byte ptr [game_literal_view_3468], 0x78
    jmp game_flow_opendemoread_67323
game_flow_opendemoread_67316:
    add al, 0x30
    mov byte ptr [game_literal_view_3468], al
game_flow_opendemoread_67323:
    {store} xor edx, edx
    {store} mov eax, ebx
    mov dl, byte ptr [_loadfromgrouponly]
    call kopen4load_
    mov dword ptr [_recfilep], eax
    cmp eax, -1
    jne game_flow_opendemoread_67353
    xor al, al
    pop edx
    pop ebx
    ret
game_flow_opendemoread_67353:
    mov ebx, 4
    mov edx, OFFSET FLAT:_ud + 0x5b6
    call kread_
    mov ebx, 1
    mov edx, OFFSET FLAT:_ud + 0x632
    mov eax, dword ptr [_recfilep]
    call kread_
    mov ebx, 1
    mov edx, OFFSET FLAT:_ud + 0x62e
    mov eax, dword ptr [_recfilep]
    call kread_
    mov ebx, 1
    mov edx, OFFSET FLAT:_ud + 0x62a
    mov eax, dword ptr [_recfilep]
    call kread_
    mov ebx, 1
    mov edx, OFFSET FLAT:_ud + 0x5da
    mov eax, dword ptr [_recfilep]
    call kread_
    mov ebx, 2
    mov edx, OFFSET FLAT:_ud + 0x590
    mov eax, dword ptr [_recfilep]
    call kread_
    mov ebx, 2
    mov edx, OFFSET FLAT:_ud + 0x616
    mov eax, dword ptr [_recfilep]
    call kread_
    mov ebx, 4
    mov edx, OFFSET FLAT:_ud + 0x60a
    mov eax, dword ptr [_recfilep]
    call kread_
    mov ebx, 4
    mov edx, OFFSET FLAT:_ud + 0x606
    mov eax, dword ptr [_recfilep]
    call kread_
    mov ebx, 4
    mov edx, OFFSET FLAT:_ud + 0x60e
    mov eax, dword ptr [_recfilep]
    call kread_
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    mov bl, byte ptr [_ud + 0x62a]
    mov dl, byte ptr [_ud + 0x62e]
    mov al, byte ptr [_ud + 0x632]
    call newgame_
    mov al, 1
    pop edx
    pop ebx
    ret
    {disp8} lea eax, dword ptr [eax]
opendemowrite_:
    push ebx
    push ecx
    push edx
    sub esp, 4
    mov ecx, OFFSET FLAT:game_text_opendemowrite_3476
    {store} xor edx, edx
    mov ebx, dword ptr [_ud + 0x5fa]
    mov dword ptr [esp], edx
    cmp ebx, 2
    jne game_flow_opendemowrite_67621
    mov eax, dword ptr [_frecfilep]
    call kclose_
game_flow_opendemowrite_67621:
    mov edx, OFFSET FLAT:game_text_opendemowrite_3488
    {store} mov eax, ecx
    call fopen_
    mov dword ptr [_frecfilep], eax
    cmp eax, -1
    {disp32} je game_flow_opendemowrite_67902
    mov ebx, 1
    mov edx, 4
    {store} mov ecx, eax
    {store} mov eax, esp
    call fwrite_
    mov ebx, 1
    mov eax, OFFSET FLAT:_ud + 0x632
    mov ecx, dword ptr [_frecfilep]
    {store} mov edx, ebx
    call fwrite_
    mov ebx, 1
    mov eax, OFFSET FLAT:_ud + 0x62e
    mov ecx, dword ptr [_frecfilep]
    {store} mov edx, ebx
    call fwrite_
    mov ebx, 1
    mov eax, OFFSET FLAT:_ud + 0x62a
    mov ecx, dword ptr [_frecfilep]
    {store} mov edx, ebx
    call fwrite_
    mov ebx, 1
    mov eax, OFFSET FLAT:_ud + 0x5da
    mov ecx, dword ptr [_frecfilep]
    {store} mov edx, ebx
    call fwrite_
    mov ebx, 1
    mov edx, 2
    mov eax, OFFSET FLAT:_ud + 0x590
    mov ecx, dword ptr [_frecfilep]
    call fwrite_
    mov ebx, 1
    mov edx, 2
    mov eax, OFFSET FLAT:_ud + 0x616
    mov ecx, dword ptr [_frecfilep]
    call fwrite_
    mov ebx, 1
    mov edx, 4
    mov eax, OFFSET FLAT:_ud + 0x60a
    mov ecx, dword ptr [_frecfilep]
    call fwrite_
    mov ebx, 1
    mov edx, 4
    mov eax, OFFSET FLAT:_ud + 0x606
    mov ecx, dword ptr [_frecfilep]
    call fwrite_
    mov ebx, 1
    mov edx, 4
    mov eax, OFFSET FLAT:_ud + 0x60e
    mov ecx, dword ptr [_frecfilep]
    call fwrite_
    {store} xor ecx, ecx
    mov dword ptr [_totalreccnt], ecx
    mov dword ptr [_ud + 0x5b6], ecx
game_flow_opendemowrite_67902:
    add esp, 4
    pop edx
    pop ecx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp8} lea edx, dword ptr [edx]
    {load} mov ebx, ebx
record_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    sub esp, 4
    mov ax, word ptr [_connecthead]
    {disp32} jmp game_flow_record_68154
game_flow_record_67939:
    mov ebx, dword ptr [_ud + 0x5b6]
    {disp32} lea eax, dword ptr [ebx*4]
    {store} add eax, ebx
    mov edi, OFFSET FLAT:_recsync
    {store} add eax, eax
    movsx ebx, dx
    {store} add edi, eax
    {disp32} lea eax, dword ptr [ebx*4]
    {store} add eax, ebx
    mov esi, OFFSET FLAT:_sync
    {store} add eax, eax
    mov ecx, 0xa
    {store} add esi, eax
    cmp ecx, 4
    jae game_flow_record_68007
    test cl, 1
    je game_flow_record_68000
    movsb byte ptr es:[edi], byte ptr [esi]
game_flow_record_68000:
    shr ecx, 1
    rep
    movsw word ptr es:[edi], word ptr [esi]
    jmp game_flow_record_68050
game_flow_record_68007:
    test edi, 1
    je game_flow_record_68017
    movsb byte ptr es:[edi], byte ptr [esi]
    dec ecx
game_flow_record_68017:
    test edi, 2
    je game_flow_record_68030
    movsw word ptr es:[edi], word ptr [esi]
    sub ecx, 2
game_flow_record_68030:
    {store} mov ebx, ecx
    shr ecx, 2
    rep movsd dword ptr es:[edi], dword ptr [esi]
    test bl, 2
    je game_flow_record_68044
    movsw word ptr es:[edi], word ptr [esi]
game_flow_record_68044:
    test bl, 1
    je game_flow_record_68050
    movsb byte ptr es:[edi], byte ptr [esi]
game_flow_record_68050:
    mov edx, dword ptr [_ud + 0x5b6]
    mov ebx, dword ptr [_totalreccnt]
    inc edx
    inc ebx
    mov dword ptr [_ud + 0x5b6], edx
    mov dword ptr [_totalreccnt], ebx
    cmp edx, 0x9d8
    jl game_flow_record_68142
    movsx ebx, word ptr [_ud + 0x590]
    {store} mov eax, edx
    sar edx, 0x1f
    idiv ebx
    movsx esi, word ptr [_ud + 0x590]
    mov ecx, dword ptr [_frecfilep]
    {disp32} lea edx, dword ptr [esi*4]
    {store} mov ebx, eax
    {store} add edx, esi
    mov eax, OFFSET FLAT:_recsync
    {store} add edx, edx
    {store} xor esi, esi
    call dfwrite_
    mov dword ptr [_ud + 0x5b6], esi
game_flow_record_68142:
    movsx eax, word ptr [esp]
    mov ax, word ptr [eax*2 + _connectpoint2]
game_flow_record_68154:
    mov dword ptr [esp], eax
    mov edx, dword ptr [esp]
    test dx, dx
    {disp32} jge game_flow_record_67939
    add esp, 4
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
    {load} mov eax, eax
closedemowrite_:
    push ebx
    push ecx
    push edx
    cmp dword ptr [_ud + 0x5fa], 1
    {disp32} jne game_flow_closedemowrite_68336
    cmp dword ptr [_ud + 0x5b6], 0
    jle game_flow_closedemowrite_68272
    mov eax, dword ptr [_ud + 0x5b6]
    {store} mov edx, eax
    movsx ebx, word ptr [_ud + 0x590]
    sar edx, 0x1f
    idiv ebx
    movsx edx, word ptr [_ud + 0x590]
    {store} mov ebx, eax
    {disp32} lea eax, dword ptr [edx*4]
    mov ecx, dword ptr [_frecfilep]
    {store} add edx, eax
    mov eax, OFFSET FLAT:_recsync
    {store} add edx, edx
    call dfwrite_
game_flow_closedemowrite_68272:
    mov eax, dword ptr [_frecfilep]
    {store} xor ebx, ebx
    {store} xor edx, edx
    call fseek_
    mov ebx, 1
    mov edx, 4
    mov eax, OFFSET FLAT:_totalreccnt
    mov ecx, dword ptr [_frecfilep]
    call fwrite_
    {store} xor ecx, ecx
    mov eax, dword ptr [_frecfilep]
    mov dword ptr [_ud + 0x612], ecx
    mov dword ptr [_ud + 0x5fa], ecx
    call fclose_
game_flow_closedemowrite_68336:
    pop edx
    pop ecx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
playback_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    sub esp, 8
    xor ah, ah
    mov byte ptr [esp + 4], ah
game_flow_playback_68367:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov dl, 1
    mov al, byte ptr [eax + _ps + 0x516]
    mov byte ptr [_pub], dl
    and al, 1
    mov byte ptr [_pus], dl
    mov byte ptr [_in_menu], al
    call flushperms_
    cmp word ptr [_numplayers], 2
    jge game_flow_playback_68438
    {store} xor eax, eax
    mov al, byte ptr [_which_demo]
    call opendemoread_
    mov byte ptr [esp + 4], al
game_flow_playback_68438:
    cmp byte ptr [esp + 4], 0
    {disp32} jne game_flow_playback_68568
    cmp byte ptr [_which_demo], 1
    jbe game_flow_playback_68467
    mov byte ptr [_which_demo], 1
    jmp game_flow_playback_68367
game_flow_playback_68467:
    {store} xor esi, esi
    jmp game_flow_playback_68487
game_flow_playback_68471:
    {store} mov ecx, esi
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    call palto_
    add esi, 7
game_flow_playback_68487:
    cmp esi, 0x3f
    jl game_flow_playback_68471
    call drawbackground_
    call menus_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov ebx, OFFSET FLAT:_palette
    mov esi, 0x3f
    mov dword ptr [eax + _ps + 0x541], ebx
    call nextpage_
    jmp game_flow_playback_68554
game_flow_playback_68538:
    {store} mov ecx, esi
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    call palto_
    sub esi, 7
game_flow_playback_68554:
    test esi, esi
    jg game_flow_playback_68538
    {store} xor ecx, ecx
    mov dword ptr [_ud + 0x5b6], ecx
    jmp game_flow_playback_68615
game_flow_playback_68568:
    mov bh, byte ptr [_which_demo]
    mov edx, 2
    inc bh
    mov dword ptr [_ud + 0x5fa], edx
    mov byte ptr [_which_demo], bh
    cmp bh, 0xa
    jne game_flow_playback_68605
    mov byte ptr [_which_demo], 1
game_flow_playback_68605:
    mov eax, 2
    call enterlevel_
game_flow_playback_68615:
    cmp byte ptr [esp + 4], 0
    je game_flow_playback_68650
    cmp byte ptr [_in_menu], 0
    jne game_flow_playback_68650
    call KB_KeyWaiting_
    test eax, eax
    jne game_flow_playback_68650
    cmp word ptr [_ud + 0x590], 1
    jle game_flow_playback_68680
game_flow_playback_68650:
    call FX_StopAllSounds_
    call clearsoundlocks_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    or byte ptr [eax + _ps + 0x516], 1
game_flow_playback_68680:
    xor bh, bh
    {store} xor esi, esi
    mov byte ptr [_ready2send], bh
    mov dword ptr [esp], esi
    call KB_FlushKeyboardQueue_
game_flow_playback_68698:
    cmp dword ptr [_ud + 0x5b6], 0
    jg game_flow_playback_68718
    cmp byte ptr [esp + 4], 0
    {disp32} jne game_flow_playback_69388
game_flow_playback_68718:
    cmp byte ptr [esp + 4], 0
    {disp32} je game_flow_playback_69059
game_flow_playback_68729:
    mov eax, dword ptr [_lockclock]
    add eax, 4
    cmp eax, dword ptr [_totalclock]
    {disp32} jg game_flow_playback_69059
    mov eax, dword ptr [esp]
    test eax, eax
    je game_flow_playback_68763
    .att_syntax prefix
    cmpl $game_math_playback_68756,%eax
    .intel_syntax noprefix
    jl game_flow_playback_68841
game_flow_playback_68763:
    {store} xor ebx, ebx
    mov ecx, dword ptr [_ud + 0x5b6]
    mov dword ptr [esp], ebx
    cmp ecx, 0x9d8
    jge game_flow_playback_68786
    {store} mov edx, ecx
    jmp game_flow_playback_68791
game_flow_playback_68786:
    mov edx, 0x9d8
game_flow_playback_68791:
    movsx ebx, word ptr [_ud + 0x590]
    {store} mov eax, edx
    sar edx, 0x1f
    idiv ebx
    movsx edx, word ptr [_ud + 0x590]
    {store} mov ebx, eax
    {disp32} lea eax, dword ptr [edx*4]
    mov ecx, dword ptr [_recfilep]
    {store} add edx, eax
    mov eax, OFFSET FLAT:_recsync
    {store} add edx, edx
    call kdfread_
game_flow_playback_68841:
    movsx edx, word ptr [_connecthead]
    test edx, edx
    jge game_flow_playback_68862
    call domovethings_
    {disp32} jmp game_flow_playback_68729
game_flow_playback_68862:
    {disp32} lea ebp, dword ptr [edx*4]
    mov ebx, dword ptr [ebp + _movefifoend]
    and ebx, 0xff
    {disp32} lea eax, dword ptr [ebx*4]
    {store} add eax, ebx
    mov edi, OFFSET FLAT:_inputfifo
    shl eax, 5
    {store} add edi, eax
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    {store} add eax, eax
    mov ebx, dword ptr [esp]
    {store} add edi, eax
    {disp32} lea eax, dword ptr [ebx*4]
    {store} add eax, ebx
    mov esi, OFFSET FLAT:_recsync
    {store} add eax, eax
    mov ecx, 0xa
    {store} add esi, eax
    cmp ecx, 4
    jae game_flow_playback_68957
    test cl, 1
    je game_flow_playback_68950
    movsb byte ptr es:[edi], byte ptr [esi]
game_flow_playback_68950:
    shr ecx, 1
    rep
    movsw word ptr es:[edi], word ptr [esi]
    jmp game_flow_playback_69000
game_flow_playback_68957:
    test edi, 1
    je game_flow_playback_68967
    movsb byte ptr es:[edi], byte ptr [esi]
    dec ecx
game_flow_playback_68967:
    test edi, 2
    je game_flow_playback_68980
    movsw word ptr es:[edi], word ptr [esi]
    sub ecx, 2
game_flow_playback_68980:
    {store} mov ebx, ecx
    shr ecx, 2
    rep movsd dword ptr es:[edi], dword ptr [esi]
    test bl, 2
    je game_flow_playback_68994
    movsw word ptr es:[edi], word ptr [esi]
game_flow_playback_68994:
    test bl, 1
    je game_flow_playback_69000
    movsb byte ptr es:[edi], byte ptr [esi]
game_flow_playback_69000:
    mov esi, dword ptr [ebp + _movefifoend]
    mov edi, dword ptr [esp]
    inc esi
    movsx edx, word ptr [edx*2 + _connectpoint2]
    mov dword ptr [ebp + _movefifoend], esi
    mov ebp, dword ptr [_ud + 0x5b6]
    inc edi
    dec ebp
    mov dword ptr [esp], edi
    mov dword ptr [_ud + 0x5b6], ebp
    test edx, edx
    {disp32} jge game_flow_playback_68862
    call domovethings_
    {disp32} jmp game_flow_playback_68729
game_flow_playback_69059:
    cmp byte ptr [esp + 4], 0
    jne game_flow_playback_69076
    call drawbackground_
    {disp32} jmp game_flow_playback_69191
game_flow_playback_69076:
    call nonsharedkeys_
    mov eax, dword ptr [_totalclock]
    mov edx, dword ptr [_lockclock]
    {store} sub eax, edx
    shl eax, 0xe
    test eax, eax
    jle game_flow_playback_69113
    mov eax, dword ptr [_totalclock]
    {store} sub eax, edx
    shl eax, 0xe
    jmp game_flow_playback_69115
game_flow_playback_69113:
    {store} xor eax, eax
game_flow_playback_69115:
    .att_syntax prefix
    cmpl $game_math_playback_69115,%eax
    .intel_syntax noprefix
    jge game_flow_playback_69160
    mov eax, dword ptr [_totalclock]
    mov ecx, dword ptr [_lockclock]
    {store} sub eax, ecx
    shl eax, 0xe
    test eax, eax
    jle game_flow_playback_69154
    mov eax, dword ptr [_totalclock]
    {store} sub eax, ecx
    shl eax, 0xe
    jmp game_flow_playback_69156
game_flow_playback_69154:
    {store} xor eax, eax
game_flow_playback_69156:
    {store} mov ebx, eax
    jmp game_flow_playback_69165
game_flow_playback_69160:
    mov ebx, 0x10000
game_flow_playback_69165:
    movsx eax, word ptr [_screenpeek]
    {store} mov edx, ebx
    call displayrooms_
    {store} mov eax, ebx
    call displayrest_
    call getpackets_
game_flow_playback_69191:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov dl, byte ptr [eax + _ps + 0x516]
    test dl, 8
    je game_flow_playback_69224
    test dl, 1
    {disp32} jne game_flow_playback_68367
game_flow_playback_69224:
    cmp byte ptr [_KB_KeyDown + 0x1], 0
    je game_flow_playback_69283
    xor bh, bh
    mov byte ptr [_KB_KeyDown + 0x1], bh
    call FX_StopAllSounds_
    call clearsoundlocks_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    or byte ptr [eax + _ps + 0x516], 1
    {store} xor eax, eax
    call cmenu_
    call intomenusounds_
game_flow_playback_69283:
    call menus_
    mov ax, word ptr [_ud + 0x58e]
    mov cx, word ptr [_ud + 0x58c]
    {store} cmp ax, cx
    je game_flow_playback_69328
    mov word ptr [_ud + 0x58e], cx
    mov eax, dword ptr [_totalclock]
    .att_syntax prefix
    addl $game_math_playback_69318,%eax
    .intel_syntax noprefix
    mov dword ptr [_ud + 0x59e], eax
game_flow_playback_69328:
    call nextpage_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov ch, byte ptr [eax + _ps + 0x516]
    cmp ch, 0x80
    je game_flow_playback_69366
    cmp ch, 4
    {disp32} jne game_flow_playback_68698
game_flow_playback_69366:
    mov eax, dword ptr [_recfilep]
    call kclose_
    {store} xor eax, eax
    add esp, 8
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_playback_69388:
    mov eax, dword ptr [_recfilep]
    call kclose_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    test byte ptr [eax + _ps + 0x516], 1
    {disp32} jne game_flow_playback_68367
    mov eax, 1
    add esp, 8
    pop ebp
game_flow_playback_69433:
    pop edi
game_flow_playback_69434:
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    nop
moveloop_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    cmp word ptr [_numplayers], 1
    jle game_flow_moveloop_69489
game_flow_moveloop_69455:
    movsx eax, word ptr [_myconnectindex]
    {disp32} lea edx, dword ptr [eax*4]
    mov eax, dword ptr [_fakemovefifoplc]
    cmp eax, dword ptr [edx + _movefifoend]
    jge game_flow_moveloop_69489
    call fakedomovethings_
    jmp game_flow_moveloop_69455
game_flow_moveloop_69489:
    call getpackets_
    cmp word ptr [_numplayers], 2
    jge game_flow_moveloop_69512
    {store} xor ecx, ecx
    mov dword ptr [_bufferjitter], ecx
game_flow_moveloop_69512:
    movsx eax, word ptr [_myconnectindex]
    mov esi, dword ptr [_movefifoplc]
    mov eax, dword ptr [eax*4 + _movefifoend]
    mov edi, dword ptr [_bufferjitter]
    {store} sub eax, esi
    {store} cmp eax, edi
    jle game_flow_playback_69433
    movsx eax, word ptr [_connecthead]
    mov ebx, dword ptr [_movefifoplc]
    jmp game_flow_moveloop_69576
game_flow_moveloop_69559:
    cmp ebx, dword ptr [eax*4 + _movefifoend]
    je game_flow_moveloop_69580
    movsx eax, word ptr [eax*2 + _connectpoint2]
game_flow_moveloop_69576:
    test eax, eax
    jge game_flow_moveloop_69559
game_flow_moveloop_69580:
    test eax, eax
    {disp32} jge game_flow_playback_69433
    call domovethings_
    jmp game_flow_moveloop_69512
    {disp8} lea eax, dword ptr [eax]
    {load} mov ecx, ecx
fakedomovethingscorrect_:
    push ebx
    push ecx
    push edx
    push esi
    cmp word ptr [_numplayers], 2
    {disp32} jl game_flow_playback_69434
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov ebx, dword ptr [_movefifoplc]
    dec ebx
    and ebx, 0xff
    {disp32} lea edx, dword ptr [ebx*4]
    add eax, OFFSET FLAT:_ps
    mov esi, dword ptr [edx + _myxbak]
    cmp esi, dword ptr [eax + 532]
    jne game_flow_fakedomovethingscorrect_69733
    mov ecx, dword ptr [eax + 536]
    cmp ecx, dword ptr [edx + _myybak]
    jne game_flow_fakedomovethingscorrect_69733
    mov ecx, dword ptr [eax + 540]
    cmp ecx, dword ptr [edx + _myzbak]
    jne game_flow_fakedomovethingscorrect_69733
    mov ecx, dword ptr [eax + 544]
    cmp ecx, dword ptr [edx + _myhorizbak]
    jne game_flow_fakedomovethingscorrect_69733
    mov dx, word ptr [eax + 640]
    cmp dx, word ptr [ebx*2 + _myangbak]
    {disp32} je game_flow_playback_69434
game_flow_fakedomovethingscorrect_69733:
    mov edx, dword ptr [eax + 532]
    mov dword ptr [_myx], edx
    mov edx, dword ptr [eax + 568]
    mov dword ptr [_omyx], edx
    mov edx, dword ptr [eax + 588]
    mov dword ptr [_myxvel], edx
    mov edx, dword ptr [eax + 536]
    mov dword ptr [_myy], edx
    mov edx, dword ptr [eax + 572]
    mov dword ptr [_omyy], edx
    mov edx, dword ptr [eax + 592]
    mov dword ptr [_myyvel], edx
    mov edx, dword ptr [eax + 540]
    mov dword ptr [_myz], edx
    mov edx, dword ptr [eax + 576]
    mov dword ptr [_omyz], edx
    mov edx, dword ptr [eax + 596]
    mov dword ptr [_myzvel], edx
    mov dx, word ptr [eax + 640]
    mov word ptr [_myang], dx
    mov dx, word ptr [eax + 642]
    mov word ptr [_omyang], dx
    mov dx, word ptr [eax + 646]
    mov word ptr [_mycursectnum], dx
    mov dx, word ptr [eax + 544]
    mov word ptr [_myhoriz], dx
    mov dx, word ptr [eax + 548]
    mov word ptr [_omyhoriz], dx
    mov dx, word ptr [eax + 686]
    mov word ptr [_myhorizoff], dx
    mov dx, word ptr [eax + 552]
    mov word ptr [_omyhorizoff], dx
    mov dx, word ptr [eax + 696]
    mov word ptr [_myjumpingcounter], dx
    mov dl, byte ptr [eax + 1306]
    mov byte ptr [_myjumpingtoggle], dl
    mov dl, byte ptr [eax + 1308]
    mov byte ptr [_myonground], dl
    mov dl, byte ptr [eax + 1353]
    mov byte ptr [_myhardlanding], dl
    mov al, byte ptr [eax + 1361]
    mov byte ptr [_myreturntocenter], al
    mov eax, dword ptr [_movefifoplc]
    mov dword ptr [_fakemovefifoplc], eax
game_flow_fakedomovethingscorrect_70010:
    movsx edx, word ptr [_myconnectindex]
    mov eax, dword ptr [_fakemovefifoplc]
    cmp eax, dword ptr [edx*4 + _movefifoend]
    {disp32} jge game_flow_playback_69434
    call fakedomovethings_
    jmp game_flow_fakedomovethingscorrect_70010
    {disp32} lea eax, dword ptr [eax]
fakedomovethings_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    sub esp, 0x48
    mov eax, dword ptr [_fakemovefifoplc]
    and eax, 0xff
    {disp32} lea ebx, dword ptr [eax*4]
    {store} add ebx, eax
    mov ebp, OFFSET FLAT:_inputfifo
    shl ebx, 5
    movsx eax, word ptr [_myconnectindex]
    {store} add ebp, ebx
    {disp32} lea ebx, dword ptr [eax*4]
    {store} add ebx, eax
    imul eax, eax, 0x552
    mov esi, OFFSET FLAT:_ps
    {store} add esi, eax
    movsx eax, word ptr [esi + 724]
    imul eax, eax, 0x2c
    mov dx, word ptr [eax + _sprite + 0xc]
    {store} add ebx, ebx
    mov dword ptr [esp + 52], edx
    and edx, 0xfffffefe
    {store} add ebp, ebx
    mov word ptr [eax + _sprite + 0xc], dx
    mov eax, dword ptr [ebp + 6]
    mov dword ptr [esp + 48], eax
    mov ax, word ptr [_mycursectnum]
    mov dword ptr [esp + 60], eax
    cwde
    {disp32} lea ebx, dword ptr [eax*4]
    {store} add ebx, eax
    xor ah, ah
    mov byte ptr [esp + 68], ah
    movsx eax, word ptr [esi + 724]
    imul eax, eax, 0x2c
    mov dl, byte ptr [eax + _sprite + 0x15]
    mov di, word ptr [ebx*8 + _sector + 0x22]
    cmp dl, 0x20
    setb al
    mov dh, byte ptr [_ud + 0x8]
    mov byte ptr [esp + 64], al
    test dh, dh
    jne game_flow_fakedomovethings_70294
    movsx eax, word ptr [esp + 60]
    {disp32} lea ebx, dword ptr [eax*4]
    {store} add ebx, eax
    cmp word ptr [ebx*8 + _sector + 0x18], 0x230
    je game_flow_fakedomovethings_70272
    mov ebx, dword ptr [esp + 60]
    test bx, bx
    jl game_flow_fakedomovethings_70272
    cmp bx, 0x400
    jl game_flow_fakedomovethings_70294
game_flow_fakedomovethings_70272:
    mov eax, dword ptr [_omyx]
    mov dword ptr [_myx], eax
    mov eax, dword ptr [_omyy]
    mov dword ptr [_myy], eax
    jmp game_flow_fakedomovethings_70314
game_flow_fakedomovethings_70294:
    mov eax, dword ptr [_myx]
    mov dword ptr [_omyx], eax
    mov eax, dword ptr [_myy]
    mov dword ptr [_omyy], eax
game_flow_fakedomovethings_70314:
    mov ax, word ptr [_myhoriz]
    mov word ptr [_omyhoriz], ax
    mov ax, word ptr [_myhorizoff]
    mov word ptr [_omyhorizoff], ax
    mov eax, dword ptr [_myz]
    push 0x10001
    mov dword ptr [_omyz], eax
    mov ax, word ptr [_myang]
    push 0xa3
    mov word ptr [_omyang], ax
    lea eax, dword ptr [esp + 8]
    push eax
    lea eax, dword ptr [esp + 24]
    push eax
    lea eax, dword ptr [esp + 20]
    push eax
    lea eax, dword ptr [esp + 28]
    push eax
    movsx eax, word ptr [esp + 84]
    mov ebx, dword ptr [_myz]
    mov dword ptr [esp + 40], eax
    mov edx, dword ptr [_myy]
    mov ecx, dword ptr [esp + 40]
    mov eax, dword ptr [_myx]
    call getzrange_
    mov eax, dword ptr [esp + 16]
    mov ebx, dword ptr [_myy]
    mov edx, dword ptr [_myx]
    call getflorzofslope_
    mov edx, dword ptr [esp]
    and edx, 0xc000
    mov dword ptr [esp + 44], eax
    cmp edx, 0x4000
    jne game_flow_fakedomovethings_70498
    cmp di, 1
    jne game_flow_fakedomovethings_70498
    mov edx, dword ptr [_myz]
    {store} sub edx, eax
    {store} mov eax, edx
    test eax, eax
    jns game_flow_fakedomovethings_70489
    neg eax
game_flow_fakedomovethings_70489:
    .att_syntax prefix
    cmpl $game_math_fakedomovethings_70489,%eax
    .intel_syntax noprefix
    jle game_flow_fakedomovethings_70498
    {store} xor edi, edi
game_flow_fakedomovethings_70498:
    cmp byte ptr [esi + 1332], 0
    {disp32} jne game_flow_fakedomovethings_70757
    cmp byte ptr [_myonground], 0
    {disp32} je game_flow_fakedomovethings_70757
    cmp di, 2
    {disp32} je game_flow_fakedomovethings_70757
    movsx eax, word ptr [esp + 60]
    mov dword ptr [esp + 36], eax
    {disp32} lea ebx, dword ptr [eax*4]
    {store} add ebx, eax
    test byte ptr [ebx*8 + _sector + 0xe], 2
    {disp32} je game_flow_fakedomovethings_70757
    movsx eax, word ptr [_myang]
    .att_syntax prefix
    addl $game_math_fakedomovethings_70573,%eax
    .intel_syntax noprefix
    and eax, 0x7ff
    movsx eax, word ptr [eax*2 + _sintable]
    mov ecx, dword ptr [_myx]
    sar eax, 5
    {store} add ecx, eax
    mov ax, word ptr [_myang]
    and ah, 7
    cwde
    movsx eax, word ptr [eax*2 + _sintable]
    mov edx, dword ptr [_myy]
    sar eax, 5
    {store} add edx, eax
    mov eax, dword ptr [esp + 60]
    lea ebx, dword ptr [esp + 56]
    mov dword ptr [esp + 56], eax
    {store} mov eax, ecx
    mov dword ptr [esp + 28], edx
    call updatesector_
    cmp word ptr [esp + 56], 0
    jl game_flow_fakedomovethings_70757
    mov ebx, dword ptr [esp + 28]
    mov eax, dword ptr [esp + 36]
    {store} mov edx, ecx
    call getflorzofslope_
    mov dword ptr [esp + 40], eax
    mov eax, dword ptr [esp + 44]
    sub eax, dword ptr [esp + 40]
    mov edx, dword ptr [esp + 56]
    mov dword ptr [esp + 32], eax
    cmp dx, word ptr [esp + 60]
    je game_flow_fakedomovethings_70735
    mov ebx, dword ptr [esp + 28]
    movsx eax, dx
    {store} mov edx, ecx
    call getflorzofslope_
    sub eax, dword ptr [esp + 40]
    test eax, eax
    jns game_flow_fakedomovethings_70728
    neg eax
game_flow_fakedomovethings_70728:
    .att_syntax prefix
    cmpl $game_math_fakedomovethings_70728,%eax
    .intel_syntax noprefix
    jg game_flow_fakedomovethings_70757
game_flow_fakedomovethings_70735:
    mov ebx, 0xa0
    mov eax, dword ptr [esp + 32]
    imul ebx
    shrd eax, edx, 0x10
    add word ptr [_myhorizoff], ax
game_flow_fakedomovethings_70757:
    mov ax, word ptr [_myhorizoff]
    test ax, ax
    jle game_flow_fakedomovethings_70779
    cwde
    {store} mov edx, eax
    sar edx, 3
    inc edx
    {store} sub eax, edx
    jmp game_flow_fakedomovethings_70792
game_flow_fakedomovethings_70779:
    jge game_flow_fakedomovethings_70798
    cwde
    {store} mov edx, eax
    neg edx
    sar edx, 3
    inc edx
    {store} add eax, edx
game_flow_fakedomovethings_70792:
    mov word ptr [_myhorizoff], ax
game_flow_fakedomovethings_70798:
    mov ecx, dword ptr [esp + 4]
    test ecx, ecx
    jl game_flow_fakedomovethings_70886
    {store} mov eax, ecx
    and eax, 0xc000
    .att_syntax prefix
    cmpl $game_math_fakedomovethings_70813,%eax
    .intel_syntax noprefix
    jne game_flow_fakedomovethings_70886
    {store} mov eax, ecx
    and eax, 0xfff
    mov dword ptr [esp + 4], eax
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 0x1a], 1
    jne game_flow_fakedomovethings_70886
    cmp word ptr [eax + _sprite + 0x2a], 0
    jl game_flow_fakedomovethings_70886
    movsx eax, word ptr [esp + 60]
    {store} xor ebx, ebx
    mov edx, dword ptr [_myx]
    mov dword ptr [esp + 4], ebx
    mov ebx, dword ptr [_myy]
    call getceilzofslope_
    mov dword ptr [esp + 8], eax
game_flow_fakedomovethings_70886:
    mov ecx, dword ptr [esp]
    test ecx, ecx
    {disp32} jl game_flow_fakedomovethings_71130
    {store} mov eax, ecx
    and eax, 0xc000
    .att_syntax prefix
    cmpl $game_math_fakedomovethings_70904,%eax
    .intel_syntax noprefix
    {disp32} jne game_flow_fakedomovethings_71130
    {store} mov eax, ecx
    and eax, 0xfff
    mov dword ptr [esp + 44], eax
    imul eax, eax, 0x2c
    mov ax, word ptr [eax + _sprite + 0xc]
    xor ah, ah
    and al, 0x21
    .att_syntax prefix
    cmpw $game_math_fakedomovethings_70940,%ax
    .intel_syntax noprefix
    jne game_flow_fakedomovethings_70954
    mov ch, 1
    {store} xor edi, edi
    mov byte ptr [esp + 68], ch
game_flow_fakedomovethings_70954:
    imul ebx, dword ptr [esp + 44], 0x2c
    mov eax, OFFSET FLAT:_sprite
    {store} add eax, ebx
    call badguy_
    test ax, ax
    {disp32} je game_flow_fakedomovethings_71130
    cmp byte ptr [ebx + _sprite + 0x14], 0x18
    {disp32} jbe game_flow_fakedomovethings_71130
    movsx eax, word ptr [esi + 724]
    imul eax, eax, 0x2c
    mov edx, dword ptr [ebx + _sprite + 0x8]
    mov eax, dword ptr [eax + _sprite + 0x8]
    {store} sub eax, edx
    test eax, eax
    jns game_flow_fakedomovethings_71023
    neg eax
game_flow_fakedomovethings_71023:
    .att_syntax prefix
    cmpl $game_math_fakedomovethings_71023,%eax
    .intel_syntax noprefix
    jge game_flow_fakedomovethings_71130
    mov ecx, dword ptr [_myy]
    mov edx, dword ptr [ebx + _sprite + 0x4]
    mov eax, dword ptr [ebx + _sprite]
    mov ebx, dword ptr [_myx]
    {store} sub edx, ecx
    {store} sub eax, ebx
    call getangle_
    lea edx, dword ptr [eax + 512]
    and edx, 0x7ff
    mov ecx, dword ptr [_myxvel]
    and eax, 0x7ff
    movsx edx, word ptr [edx*2 + _sintable]
    movsx eax, word ptr [eax*2 + _sintable]
    shl edx, 6
    shl eax, 6
    {store} sub ecx, edx
    mov edx, dword ptr [_myyvel]
    {store} sub edx, eax
    mov dword ptr [_myxvel], ecx
    mov dword ptr [_myyvel], edx
game_flow_fakedomovethings_71130:
    movsx eax, word ptr [esi + 724]
    imul eax, eax, 0x2c
    cmp word ptr [eax + _sprite + 0x2a], 0
    {disp32} jg game_flow_fakedomovethings_71344
    cmp di, 2
    jne game_flow_fakedomovethings_71252
    cmp byte ptr [esi + 1303], 0
    jne game_flow_fakedomovethings_71203
    mov edi, dword ptr [esp + 12]
    mov eax, dword ptr [_myz]
    {store} sub eax, edi
    test eax, eax
    jns game_flow_fakedomovethings_71186
    neg eax
game_flow_fakedomovethings_71186:
    .att_syntax prefix
    cmpl $game_math_fakedomovethings_71186,%eax
    .intel_syntax noprefix
    jle game_flow_fakedomovethings_71203
    add dword ptr [_myz], 0x15c
game_flow_fakedomovethings_71203:
    push 0x10001
    push 0x400
    push 0x400
    push 0xa4
    push 0
    mov ecx, OFFSET FLAT:_mycursectnum
    mov ebx, OFFSET FLAT:_myz
    push 0
    mov edx, OFFSET FLAT:_myy
    mov eax, OFFSET FLAT:_myx
    call clipmove_
game_flow_fakedomovethings_71252:
    mov ebx, OFFSET FLAT:_mycursectnum
    mov edx, dword ptr [_myy]
    mov eax, dword ptr [_myx]
    call updatesector_
    push 0x10001
    push 0x1400
    mov ecx, OFFSET FLAT:_mycursectnum
    push 0x400
    mov ebx, OFFSET FLAT:_myz
    mov edx, OFFSET FLAT:_myy
    push 0x80
    mov eax, OFFSET FLAT:_myx
    {store} xor edi, edi
    call pushmove_
    mov ecx, 0x64
    mov word ptr [_myhorizoff], di
    mov word ptr [_myhoriz], cx
    {disp32} jmp game_flow_fakedomovethings_73942
game_flow_fakedomovethings_71344:
    mov bx, word ptr [esi + 722]
    mov ecx, 4
    test bx, bx
    {disp32} jge game_flow_fakedomovethings_73329
    cmp word ptr [esi + 734], 0
    jge game_flow_fakedomovethings_71384
    add word ptr [_myang], 0x80
game_flow_fakedomovethings_71384:
    mov ebx, 0x28
    cmp di, 2
    {disp32} jne game_flow_fakedomovethings_71708
    {store} xor eax, eax
    mov word ptr [_myjumpingcounter], ax
    mov ah, byte ptr [esp + 48]
    test ah, 1
    je game_flow_fakedomovethings_71478
    cmp dword ptr [_myzvel], 0
    jle game_flow_fakedomovethings_71433
    {store} xor edx, edx
    mov dword ptr [_myzvel], edx
game_flow_fakedomovethings_71433:
    mov ebx, dword ptr [_myzvel]
    sub ebx, 0x15c
    mov dword ptr [_myzvel], ebx
    cmp ebx, 0xfffffa00
    {disp32} jge game_flow_fakedomovethings_71599
    mov dword ptr [_myzvel], 0xfffffa00
    {disp32} jmp game_flow_fakedomovethings_71599
game_flow_fakedomovethings_71478:
    test ah, 2
    je game_flow_fakedomovethings_71534
    cmp dword ptr [_myzvel], 0
    jge game_flow_fakedomovethings_71500
    {store} xor ebx, ebx
    mov dword ptr [_myzvel], ebx
game_flow_fakedomovethings_71500:
    mov eax, dword ptr [_myzvel]
    .att_syntax prefix
    addl $game_math_fakedomovethings_71505,%eax
    .intel_syntax noprefix
    mov dword ptr [_myzvel], eax
    .att_syntax prefix
    cmpl $game_math_fakedomovethings_71515,%eax
    .intel_syntax noprefix
    jle game_flow_fakedomovethings_71599
    mov dword ptr [_myzvel], 0x600
    jmp game_flow_fakedomovethings_71599
game_flow_fakedomovethings_71534:
    mov ebx, dword ptr [_myzvel]
    test ebx, ebx
    jge game_flow_fakedomovethings_71567
    lea eax, dword ptr [ebx + 256]
    mov dword ptr [_myzvel], eax
    test eax, eax
    jle game_flow_fakedomovethings_71567
    {store} xor ebx, ebx
    mov dword ptr [_myzvel], ebx
game_flow_fakedomovethings_71567:
    mov eax, dword ptr [_myzvel]
    test eax, eax
    jle game_flow_fakedomovethings_71599
    lea edx, dword ptr [eax + -256]
    mov dword ptr [_myzvel], edx
    test edx, edx
    jge game_flow_fakedomovethings_71599
    {store} xor eax, eax
    mov dword ptr [_myzvel], eax
game_flow_fakedomovethings_71599:
    mov ebx, dword ptr [_myzvel]
    cmp ebx, 0x800
    jle game_flow_fakedomovethings_71622
    {store} mov eax, ebx
    sar eax, 1
    mov dword ptr [_myzvel], eax
game_flow_fakedomovethings_71622:
    mov eax, dword ptr [_myzvel]
    mov edx, dword ptr [_myz]
    {store} add edx, eax
    mov eax, dword ptr [esp + 12]
    sub eax, 0xf00
    mov dword ptr [_myz], edx
    {store} cmp eax, edx
    jge game_flow_fakedomovethings_71667
    {store} sub eax, edx
    sar eax, 1
    lea ebx, dword ptr [edx + eax]
    mov dword ptr [_myz], ebx
game_flow_fakedomovethings_71667:
    mov eax, dword ptr [esp + 8]
    mov edx, dword ptr [_myz]
    .att_syntax prefix
    addl $game_math_fakedomovethings_71677,%eax
    .intel_syntax noprefix
    {store} cmp eax, edx
    {disp32} jle game_flow_fakedomovethings_72717
    {store} xor ebx, ebx
    mov dword ptr [_myz], eax
    mov dword ptr [_myzvel], ebx
    {disp32} jmp game_flow_fakedomovethings_72717
game_flow_fakedomovethings_71708:
    cmp byte ptr [esi + 1324], 0
    {disp32} je game_flow_fakedomovethings_71934
    xor al, al
    {store} xor ebx, ebx
    mov byte ptr [_myonground], al
    xor ah, ah
    mov word ptr [_myjumpingcounter], bx
    mov byte ptr [_myhardlanding], ah
    mov dl, byte ptr [esi + 1324]
    cmp dl, 0xb
    jae game_flow_fakedomovethings_71777
    {store} xor eax, eax
    {store} mov al, dl
    mov ebx, dword ptr [_myz]
    shl eax, 7
    {store} sub ebx, eax
    mov dword ptr [_myz], ebx
game_flow_fakedomovethings_71777:
    cmp byte ptr [esp + 64], 0
    je game_flow_fakedomovethings_71794
    mov dword ptr [esp + 44], 0x200
    jmp game_flow_fakedomovethings_71802
game_flow_fakedomovethings_71794:
    mov dword ptr [esp + 44], 0x800
game_flow_fakedomovethings_71802:
    test byte ptr [esp + 48], 1
    je game_flow_fakedomovethings_71819
    mov eax, dword ptr [esp + 44]
    sub dword ptr [_myz], eax
game_flow_fakedomovethings_71819:
    test byte ptr [esp + 48], 2
    je game_flow_fakedomovethings_71836
    mov eax, dword ptr [esp + 44]
    add dword ptr [_myz], eax
game_flow_fakedomovethings_71836:
    cmp byte ptr [esp + 64], 0
    jne game_flow_fakedomovethings_71861
    test di, di
    je game_flow_fakedomovethings_71854
    cmp di, 2
    jne game_flow_fakedomovethings_71861
game_flow_fakedomovethings_71854:
    mov ebx, 0x20
    jmp game_flow_fakedomovethings_71866
game_flow_fakedomovethings_71861:
    mov ebx, 0x10
game_flow_fakedomovethings_71866:
    {store} mov eax, ebx
    mov edx, dword ptr [esp + 12]
    shl eax, 8
    {store} sub edx, eax
    mov ebx, dword ptr [_myz]
    {store} mov eax, edx
    {store} cmp edx, ebx
    jge game_flow_fakedomovethings_71901
    {store} sub eax, ebx
    sar eax, 1
    {store} add ebx, eax
    mov dword ptr [_myz], ebx
game_flow_fakedomovethings_71901:
    mov eax, dword ptr [esp + 8]
    mov edx, dword ptr [_myz]
    .att_syntax prefix
    addl $game_math_fakedomovethings_71911,%eax
    .intel_syntax noprefix
    {store} cmp eax, edx
    {disp32} jle game_flow_fakedomovethings_72717
    mov dword ptr [_myz], eax
    {disp32} jmp game_flow_fakedomovethings_72717
game_flow_fakedomovethings_71934:
    cmp di, 2
    {disp32} je game_flow_fakedomovethings_72717
    cmp di, 1
    jne game_flow_fakedomovethings_71978
    cmp byte ptr [esi + 1325], 0
    jne game_flow_fakedomovethings_71978
    cmp byte ptr [esp + 64], 0
    jne game_flow_fakedomovethings_71973
    mov ebx, 0x22
    jmp game_flow_fakedomovethings_71978
game_flow_fakedomovethings_71973:
    mov ebx, 0xc
game_flow_fakedomovethings_71978:
    {store} mov eax, ebx
    shl eax, 8
    mov dword ptr [esp + 24], eax
    mov eax, dword ptr [esp + 12]
    sub eax, dword ptr [esp + 24]
    cmp eax, dword ptr [_myz]
    {disp32} jle game_flow_fakedomovethings_72166
    movsx edx, word ptr [esp + 60]
    {store} mov eax, edx
    call floorspace_
    mov dword ptr [esp + 16], eax
    {store} mov eax, edx
    call ceilingspace_
    mov dword ptr [esp + 20], eax
    mov eax, dword ptr [esp + 16]
    or eax, dword ptr [esp + 20]
    {disp32} jne game_flow_fakedomovethings_72166
    test byte ptr [esp + 48], 3
    jne game_flow_fakedomovethings_72117
    cmp byte ptr [_myonground], 0
    je game_flow_fakedomovethings_72117
    {disp32} lea ebx, dword ptr [edx*4]
    {store} add ebx, edx
    test byte ptr [ebx*8 + _sector + 0xe], 2
    je game_flow_fakedomovethings_72117
    mov eax, dword ptr [esp + 12]
    sub eax, dword ptr [esp + 24]
    mov ebx, dword ptr [_myz]
    lea edx, dword ptr [eax + -4096]
    {store} cmp edx, ebx
    jg game_flow_fakedomovethings_72117
    mov dword ptr [_myz], eax
    {disp32} jmp game_flow_fakedomovethings_72485
game_flow_fakedomovethings_72117:
    xor ah, ah
    mov byte ptr [_myonground], ah
    mov eax, dword ptr [_myzvel]
    .att_syntax prefix
    addl $game_math_fakedomovethings_72130,%eax
    .intel_syntax noprefix
    mov dword ptr [_myzvel], eax
    .att_syntax prefix
    cmpl $game_math_fakedomovethings_72140,%eax
    .intel_syntax noprefix
    {disp32} jl game_flow_fakedomovethings_72485
    mov dword ptr [_myzvel], 0x1800
    {disp32} jmp game_flow_fakedomovethings_72485
game_flow_fakedomovethings_72166:
    cmp di, 1
    je game_flow_fakedomovethings_72211
    cmp di, 2
    je game_flow_fakedomovethings_72211
    cmp byte ptr [_myonground], 0
    jne game_flow_fakedomovethings_72211
    mov edx, dword ptr [_myzvel]
    cmp edx, 0xc00
    jle game_flow_fakedomovethings_72211
    {store} mov eax, edx
    sar eax, 0xa
    mov byte ptr [_myhardlanding], al
game_flow_fakedomovethings_72211:
    mov byte ptr [_myonground], 1
    cmp ebx, 0x28
    jne game_flow_fakedomovethings_72304
    mov eax, dword ptr [esp + 12]
    shl ebx, 8
    {store} sub eax, ebx
    mov edx, dword ptr [_myz]
    {store} mov ebx, eax
    {store} sub ebx, edx
    sar ebx, 1
    {store} mov eax, ebx
    test eax, eax
    jns game_flow_fakedomovethings_72252
    neg eax
game_flow_fakedomovethings_72252:
    .att_syntax prefix
    cmpl $game_math_fakedomovethings_72252,%eax
    .intel_syntax noprefix
    jge game_flow_fakedomovethings_72261
    {store} xor ebx, ebx
game_flow_fakedomovethings_72261:
    mov eax, dword ptr [_myz]
    mov edx, dword ptr [_myzvel]
    {store} add eax, ebx
    sub edx, 0x300
    mov dword ptr [_myz], eax
    mov dword ptr [_myzvel], edx
    test edx, edx
    jge game_flow_fakedomovethings_72381
    {store} xor eax, eax
    mov dword ptr [_myzvel], eax
    jmp game_flow_fakedomovethings_72381
game_flow_fakedomovethings_72304:
    cmp word ptr [_myjumpingcounter], 0
    jne game_flow_fakedomovethings_72381
    mov eax, dword ptr [esp + 12]
    shl ebx, 7
    {store} sub eax, ebx
    mov ebx, dword ptr [_myz]
    {store} sub eax, ebx
    sar eax, 1
    lea edx, dword ptr [ebx + eax]
    mov dword ptr [_myz], edx
    cmp byte ptr [esi + 1303], 0
    jne game_flow_fakedomovethings_72381
    mov eax, dword ptr [esp + 12]
    mov ebx, dword ptr [_myz]
    sub eax, 0x1000
    {store} cmp eax, ebx
    jge game_flow_fakedomovethings_72381
    mov dword ptr [_myz], eax
    sar dword ptr [_myzvel], 1
game_flow_fakedomovethings_72381:
    test byte ptr [esp + 48], 2
    je game_flow_fakedomovethings_72398
    add dword ptr [_myz], 0xb00
game_flow_fakedomovethings_72398:
    test byte ptr [esp + 48], 1
    jne game_flow_fakedomovethings_72424
    cmp byte ptr [_myjumpingtoggle], 1
    jne game_flow_fakedomovethings_72424
    xor dh, dh
    mov byte ptr [_myjumpingtoggle], dh
    jmp game_flow_fakedomovethings_72485
game_flow_fakedomovethings_72424:
    test byte ptr [esp + 48], 1
    je game_flow_fakedomovethings_72485
    cmp byte ptr [_myjumpingtoggle], 0
    jne game_flow_fakedomovethings_72485
    cmp word ptr [_myjumpingcounter], 0
    jne game_flow_fakedomovethings_72485
    mov eax, dword ptr [esp + 12]
    sub eax, dword ptr [esp + 8]
    .att_syntax prefix
    cmpl $game_math_fakedomovethings_72458,%eax
    .intel_syntax noprefix
    jle game_flow_fakedomovethings_72485
    mov ebx, 1
    mov dl, 1
    mov word ptr [_myjumpingcounter], bx
    mov byte ptr [_myjumpingtoggle], dl
game_flow_fakedomovethings_72485:
    cmp word ptr [_myjumpingcounter], 0
    {disp32} je game_flow_fakedomovethings_72660
    test byte ptr [esp + 48], 1
    jne game_flow_fakedomovethings_72523
    cmp byte ptr [_myjumpingtoggle], 1
    jne game_flow_fakedomovethings_72523
    xor bl, bl
    mov byte ptr [_myjumpingtoggle], bl
game_flow_fakedomovethings_72523:
    mov dx, word ptr [_myjumpingcounter]
    cmp dx, 0x500
    jge game_flow_fakedomovethings_72644
    cmp di, 1
    jne game_flow_fakedomovethings_72571
    cmp dx, 0x300
    jle game_flow_fakedomovethings_72571
    {store} xor ebx, ebx
    mov word ptr [_myjumpingcounter], bx
    mov dword ptr [_myzvel], 0xfffffe00
    jmp game_flow_fakedomovethings_72660
game_flow_fakedomovethings_72571:
    movsx eax, word ptr [_myjumpingcounter]
    .att_syntax prefix
    addl $game_math_fakedomovethings_72578,%eax
    .intel_syntax noprefix
    and eax, 0x7ff
    movsx edx, word ptr [eax*2 + _sintable]
    mov ebx, 0xc
    {store} mov eax, edx
    sar edx, 0x1f
    idiv ebx
    sub dword ptr [_myzvel], eax
    mov dx, word ptr [_myjumpingcounter]
    xor bh, bh
    add edx, 0xb4
    mov byte ptr [_myonground], bh
    mov word ptr [_myjumpingcounter], dx
    jmp game_flow_fakedomovethings_72660
game_flow_fakedomovethings_72644:
    {store} xor ebx, ebx
    {store} xor eax, eax
    mov word ptr [_myjumpingcounter], bx
    mov dword ptr [_myzvel], eax
game_flow_fakedomovethings_72660:
    mov eax, dword ptr [_myzvel]
    mov edx, dword ptr [_myz]
    {store} add edx, eax
    mov eax, dword ptr [esp + 8]
    .att_syntax prefix
    addl $game_math_fakedomovethings_72677,%eax
    .intel_syntax noprefix
    mov dword ptr [_myz], edx
    {store} cmp eax, edx
    jle game_flow_fakedomovethings_72717
    {store} xor edx, edx
    mov word ptr [_myjumpingcounter], dx
    mov edx, 0x80
    mov dword ptr [_myz], eax
    mov dword ptr [_myzvel], edx
game_flow_fakedomovethings_72717:
    cmp word ptr [esi + 732], 0
    jne game_flow_fakedomovethings_72795
    cmp word ptr [esi + 1290], 2
    jg game_flow_fakedomovethings_72795
    cmp byte ptr [_myhardlanding], 0
    jne game_flow_fakedomovethings_72795
    cmp word ptr [esi + 702], 0
    jg game_flow_fakedomovethings_72795
    cmp word ptr [esi + 700], 0
    jg game_flow_fakedomovethings_72795
    cmp word ptr [esi + 680], 8
    jne game_flow_fakedomovethings_72811
    mov ax, word ptr [esi + 712]
    .att_syntax prefix
    cmpw $game_math_fakedomovethings_72783,%ax
    .intel_syntax noprefix
    jle game_flow_fakedomovethings_72811
    .att_syntax prefix
    cmpw $game_math_fakedomovethings_72789,%ax
    .intel_syntax noprefix
    jge game_flow_fakedomovethings_72811
game_flow_fakedomovethings_72795:
    {store} xor ecx, ecx
    mov dword ptr [_myxvel], ecx
    mov dword ptr [_myyvel], ecx
    jmp game_flow_fakedomovethings_72895
game_flow_fakedomovethings_72811:
    {disp8} mov bl, byte ptr [ebp]
    test bl, bl
    je game_flow_fakedomovethings_72895
    movsx edx, bl
    {store} add edx, edx
    cmp di, 2
    jne game_flow_fakedomovethings_72867
    {store} mov eax, edx
    sar eax, 3
    {store} mov ebx, ecx
    {store} sub edx, eax
    {store} add ebx, ebx
    {store} sbb eax, eax
    {store} cmp eax, ebx
    adc eax, 0
    imul edx, eax
    movsx eax, word ptr [_myang]
    {store} add eax, edx
    mov word ptr [_myang], ax
    jmp game_flow_fakedomovethings_72888
game_flow_fakedomovethings_72867:
    {store} mov ebx, ecx
    {store} add ebx, ebx
    {store} sbb eax, eax
    {store} cmp eax, ebx
    adc eax, 0
    imul eax, edx
    add word ptr [_myang], ax
game_flow_fakedomovethings_72888:
    and byte ptr [_myang + 0x1], 7
game_flow_fakedomovethings_72895:
    cmp dword ptr [_myxvel], 0
    jne game_flow_fakedomovethings_72931
    cmp dword ptr [_myyvel], 0
    jne game_flow_fakedomovethings_72931
    cmp word ptr [ebp + 2], 0
    jne game_flow_fakedomovethings_72931
    cmp word ptr [ebp + 4], 0
    {disp32} je game_flow_fakedomovethings_73329
game_flow_fakedomovethings_72931:
    mov bx, word ptr [esi + 1278]
    test bx, bx
    jle game_flow_fakedomovethings_72952
    cmp bx, 0x190
    jge game_flow_fakedomovethings_72952
    {store} add ecx, ecx
game_flow_fakedomovethings_72952:
    movsx eax, word ptr [ebp + 2]
    imul eax, ecx
    mov edx, dword ptr [_myxvel]
    shl eax, 6
    {store} add edx, eax
    mov dword ptr [_myxvel], edx
    movsx eax, word ptr [ebp + 4]
    imul eax, ecx
    mov ebx, dword ptr [_myyvel]
    shl eax, 6
    {store} add ebx, eax
    mov dword ptr [_myyvel], ebx
    cmp word ptr [esi + 680], 0
    jne game_flow_fakedomovethings_73029
    cmp word ptr [esi + 712], 0xa
    jle game_flow_fakedomovethings_73029
    cmp byte ptr [_myonground], 0
    jne game_flow_fakedomovethings_73045
game_flow_fakedomovethings_73029:
    cmp byte ptr [_myonground], 0
    je game_flow_fakedomovethings_73092
    test byte ptr [esp + 48], 2
    je game_flow_fakedomovethings_73092
game_flow_fakedomovethings_73045:
    mov ebx, dword ptr [_dukefriction]
    mov eax, dword ptr [_myxvel]
    sub ebx, 0x2000
    imul ebx
    shrd eax, edx, 0x10
    mov ebx, dword ptr [_dukefriction]
    mov dword ptr [_myxvel], eax
    mov eax, dword ptr [_myyvel]
    sub ebx, 0x2000
    jmp game_flow_fakedomovethings_73178
game_flow_fakedomovethings_73092:
    cmp di, 2
    jne game_flow_fakedomovethings_73145
    mov ebx, dword ptr [_dukefriction]
    mov eax, dword ptr [_myxvel]
    sub ebx, 0x1400
    imul ebx
    shrd eax, edx, 0x10
    mov ebx, dword ptr [_dukefriction]
    mov dword ptr [_myxvel], eax
    mov eax, dword ptr [_myyvel]
    sub ebx, 0x1400
    jmp game_flow_fakedomovethings_73178
game_flow_fakedomovethings_73145:
    mov ebx, dword ptr [_dukefriction]
    mov eax, dword ptr [_myxvel]
    imul ebx
    shrd eax, edx, 0x10
    mov ebx, dword ptr [_dukefriction]
    mov dword ptr [_myxvel], eax
    mov eax, dword ptr [_myyvel]
game_flow_fakedomovethings_73178:
    imul ebx
    shrd eax, edx, 0x10
    mov dword ptr [_myyvel], eax
    mov eax, dword ptr [_myxvel]
    call abs_
    .att_syntax prefix
    cmpl $game_math_fakedomovethings_73199,%eax
    .intel_syntax noprefix
    jge game_flow_fakedomovethings_73237
    mov eax, dword ptr [_myyvel]
    call abs_
    .att_syntax prefix
    cmpl $game_math_fakedomovethings_73216,%eax
    .intel_syntax noprefix
    jge game_flow_fakedomovethings_73237
    {store} xor ecx, ecx
    mov dword ptr [_myyvel], ecx
    mov dword ptr [_myxvel], ecx
game_flow_fakedomovethings_73237:
    cmp byte ptr [esp + 64], 0
    je game_flow_fakedomovethings_73329
    mov ebx, dword ptr [_dukefriction]
    mov eax, dword ptr [_dukefriction]
    sar ebx, 1
    {store} sub eax, ebx
    {store} mov ebx, eax
    mov eax, dword ptr [_dukefriction]
    sar eax, 2
    {store} add ebx, eax
    mov eax, dword ptr [_myxvel]
    imul ebx
    shrd eax, edx, 0x10
    mov edx, dword ptr [_dukefriction]
    mov dword ptr [_myxvel], eax
    mov eax, dword ptr [_dukefriction]
    mov ebx, dword ptr [_dukefriction]
    sar eax, 1
    sar ebx, 2
    {store} sub edx, eax
    mov eax, dword ptr [_myyvel]
    {store} add ebx, edx
    imul ebx
    shrd eax, edx, 0x10
    mov dword ptr [_myyvel], eax
game_flow_fakedomovethings_73329:
    cmp di, 1
    je game_flow_fakedomovethings_73342
    cmp byte ptr [esp + 68], 1
    jne game_flow_fakedomovethings_73349
game_flow_fakedomovethings_73342:
    mov ebx, 0x400
    jmp game_flow_fakedomovethings_73354
game_flow_fakedomovethings_73349:
    mov ebx, 0x1400
game_flow_fakedomovethings_73354:
    push 0x10001
    push ebx
    push 0x400
    push 0xa4
    mov edx, dword ptr [_myyvel]
    mov ecx, OFFSET FLAT:_mycursectnum
    push edx
    mov ebx, dword ptr [_myxvel]
    mov eax, OFFSET FLAT:_myx
    push ebx
    mov edx, OFFSET FLAT:_myy
    mov ebx, OFFSET FLAT:_myz
    call clipmove_
    push 0x10001
    push 0x400
    push 0x400
    mov ecx, OFFSET FLAT:_mycursectnum
    mov ebx, OFFSET FLAT:_myz
    push 0xa4
    mov edx, OFFSET FLAT:_myy
    mov eax, OFFSET FLAT:_myx
    call pushmove_
    cmp byte ptr [esi + 1324], 0
    jne game_flow_fakedomovethings_73492
    cmp di, 1
    je game_flow_fakedomovethings_73492
    cmp di, 2
    je game_flow_fakedomovethings_73492
    cmp byte ptr [esp + 64], 0
    je game_flow_fakedomovethings_73492
    add dword ptr [_myz], 0x1e00
game_flow_fakedomovethings_73492:
    test byte ptr [esp + 50], 4
    jne game_flow_fakedomovethings_73508
    cmp byte ptr [_myhardlanding], 0
    je game_flow_fakedomovethings_73515
game_flow_fakedomovethings_73508:
    mov byte ptr [_myreturntocenter], 9
game_flow_fakedomovethings_73515:
    mov ax, word ptr [_myhoriz]
    mov dl, byte ptr [esp + 49]
    .att_syntax prefix
    addl $game_math_fakedomovethings_73525,%eax
    .intel_syntax noprefix
    test dl, 0x20
    je game_flow_fakedomovethings_73568
    mov byte ptr [_myreturntocenter], 9
    test byte ptr [esp + 48], 0x20
    je game_flow_fakedomovethings_73555
    mov word ptr [_myhoriz], ax
game_flow_fakedomovethings_73555:
    add word ptr [_myhoriz], 6
    {disp32} jmp game_flow_fakedomovethings_73665
game_flow_fakedomovethings_73568:
    mov dx, word ptr [_myhoriz]
    mov bl, byte ptr [esp + 49]
    sub edx, 6
    test bl, 0x40
    je game_flow_fakedomovethings_73610
    mov byte ptr [_myreturntocenter], 9
    test byte ptr [esp + 48], 0x20
    je game_flow_fakedomovethings_73657
    mov word ptr [_myhoriz], dx
    jmp game_flow_fakedomovethings_73657
game_flow_fakedomovethings_73610:
    mov bh, byte ptr [esp + 48]
    test bh, 8
    je game_flow_fakedomovethings_73640
    test bh, 0x20
    je game_flow_fakedomovethings_73630
    mov word ptr [_myhoriz], ax
game_flow_fakedomovethings_73630:
    add word ptr [_myhoriz], 6
    jmp game_flow_fakedomovethings_73665
game_flow_fakedomovethings_73640:
    test bh, 0x10
    je game_flow_fakedomovethings_73665
    test bh, 0x20
    je game_flow_fakedomovethings_73657
    mov word ptr [_myhoriz], dx
game_flow_fakedomovethings_73657:
    sub word ptr [_myhoriz], 6
game_flow_fakedomovethings_73665:
    cmp byte ptr [_myreturntocenter], 0
    jbe game_flow_fakedomovethings_73731
    mov ah, byte ptr [esp + 49]
    test ah, 0x20
    jne game_flow_fakedomovethings_73731
    test ah, 0x40
    jne game_flow_fakedomovethings_73731
    movsx ebx, word ptr [_myhoriz]
    mov ecx, 3
    {store} mov edx, ebx
    {store} mov eax, ebx
    sar edx, 0x1f
    idiv ecx
    dec byte ptr [_myreturntocenter]
    mov edx, 0x21
    {store} sub edx, eax
    {store} add ebx, edx
    mov word ptr [_myhoriz], bx
game_flow_fakedomovethings_73731:
    cmp byte ptr [esi + 1332], 0
    je game_flow_fakedomovethings_73763
    movsx edx, byte ptr [ebp + 1]
    movsx eax, word ptr [_myhoriz]
    sar edx, 1
    {store} add eax, edx
    mov word ptr [_myhoriz], ax
    jmp game_flow_fakedomovethings_73822
game_flow_fakedomovethings_73763:
    mov bx, word ptr [_myhoriz]
    cmp bx, 0x5f
    jle game_flow_fakedomovethings_73791
    cmp bx, 0x69
    jge game_flow_fakedomovethings_73791
    mov word ptr [_myhoriz], 0x64
game_flow_fakedomovethings_73791:
    movsx eax, word ptr [_myhorizoff]
    cmp eax, -5
    jle game_flow_fakedomovethings_73822
    cmp word ptr [_myhorizoff], 5
    jge game_flow_fakedomovethings_73822
    {store} xor edx, edx
    mov word ptr [_myhorizoff], dx
game_flow_fakedomovethings_73822:
    mov bh, byte ptr [_myhardlanding]
    test bh, bh
    jbe game_flow_fakedomovethings_73865
    {store} mov cl, bh
    {store} xor eax, eax
    dec cl
    {store} mov al, cl
    mov bx, word ptr [_myhoriz]
    shl eax, 4
    {store} sub ebx, eax
    mov byte ptr [_myhardlanding], cl
    mov word ptr [_myhoriz], bx
game_flow_fakedomovethings_73865:
    mov cx, word ptr [_myhoriz]
    cmp cx, 0x12b
    jle game_flow_fakedomovethings_73890
    mov word ptr [_myhoriz], 0x12b
    jmp game_flow_fakedomovethings_73907
game_flow_fakedomovethings_73890:
    movsx eax, cx
    cmp eax, -99
    jge game_flow_fakedomovethings_73907
    mov word ptr [_myhoriz], 0xff9d
game_flow_fakedomovethings_73907:
    cmp word ptr [esi + 700], 0
    jle game_flow_fakedomovethings_73942
    mov bx, word ptr [_myhoriz]
    mov ch, 9
    sub ebx, 0x30
    mov byte ptr [_myreturntocenter], ch
    mov word ptr [_myhoriz], bx
game_flow_fakedomovethings_73942:
    mov eax, dword ptr [_fakemovefifoplc]
    and eax, 0xff
    {disp32} lea edx, dword ptr [eax*4]
    mov ebx, dword ptr [_myx]
    mov dword ptr [edx + _myxbak], ebx
    mov ebx, dword ptr [_myy]
    mov dword ptr [edx + _myybak], ebx
    mov ebx, dword ptr [_myz]
    mov dword ptr [edx + _myzbak], ebx
    {disp32} lea ebx, dword ptr [eax*2]
    mov ax, word ptr [_myang]
    mov word ptr [ebx + _myangbak], ax
    movsx eax, word ptr [_myhoriz]
    mov dword ptr [edx + _myhorizbak], eax
    inc dword ptr [_fakemovefifoplc]
    movsx eax, word ptr [esi + 724]
    imul eax, eax, 0x2c
    mov edx, dword ptr [esp + 52]
    mov word ptr [eax + _sprite + 0xc], dx
    add esp, 0x48
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
domovethings_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    mov word ptr [_ud + 0x58c], 0xffff
    mov edx, dword ptr [_lockclock]
    add edx, 4
    mov ah, byte ptr [_earthquaketime]
    mov dword ptr [_lockclock], edx
    test ah, ah
    jbe game_flow_domovethings_74130
    {store} mov dl, ah
    dec dl
    mov byte ptr [_earthquaketime], dl
game_flow_domovethings_74130:
    mov bx, word ptr [_received_quote_time]
    test bx, bx
    jle game_flow_domovethings_74152
    {store} mov ecx, ebx
    dec ecx
    mov word ptr [_received_quote_time], cx
game_flow_domovethings_74152:
    mov dh, byte ptr [_rtsplaying]
    test dh, dh
    jbe game_flow_domovethings_74172
    {store} mov bl, dh
    dec bl
    mov byte ptr [_rtsplaying], bl
game_flow_domovethings_74172:
    mov ebx, dword ptr [_show_shareware]
    test ebx, ebx
    jle game_flow_domovethings_74209
    lea ecx, dword ptr [ebx + -1]
    mov dword ptr [_show_shareware], ecx
    test ecx, ecx
    jne game_flow_domovethings_74209
    mov bh, 1
    mov byte ptr [_pus], bh
    mov byte ptr [_pub], bh
game_flow_domovethings_74209:
    mov al, byte ptr [_everyothertime]
    inc al
    mov cx, word ptr [_connecthead]
    mov byte ptr [_everyothertime], al
    {disp32} jmp game_flow_domovethings_74361
game_flow_domovethings_74233:
    mov edi, OFFSET FLAT:_sync
    mov ebx, dword ptr [_movefifoplc]
    mov esi, OFFSET FLAT:_inputfifo
    and ebx, 0xff
    movsx edx, cx
    {disp32} lea eax, dword ptr [ebx*4]
    {disp32} lea ecx, dword ptr [edx*4]
    {store} add eax, ebx
    {store} add ecx, edx
    shl eax, 5
    {store} add ecx, ecx
    {store} add esi, eax
    {store} add edi, ecx
    {store} add esi, ecx
    mov ecx, 0xa
    cmp ecx, 4
    jae game_flow_domovethings_74310
    test cl, 1
    je game_flow_domovethings_74303
    movsb byte ptr es:[edi], byte ptr [esi]
game_flow_domovethings_74303:
    shr ecx, 1
    rep
    movsw word ptr es:[edi], word ptr [esi]
    jmp game_flow_domovethings_74353
game_flow_domovethings_74310:
    test edi, 1
    je game_flow_domovethings_74320
    movsb byte ptr es:[edi], byte ptr [esi]
    dec ecx
game_flow_domovethings_74320:
    test edi, 2
    je game_flow_domovethings_74333
    movsw word ptr es:[edi], word ptr [esi]
    sub ecx, 2
game_flow_domovethings_74333:
    {store} mov ebx, ecx
    shr ecx, 2
    rep movsd dword ptr es:[edi], dword ptr [esi]
    test bl, 2
    je game_flow_domovethings_74347
    movsw word ptr es:[edi], word ptr [esi]
game_flow_domovethings_74347:
    test bl, 1
    je game_flow_domovethings_74353
    movsb byte ptr es:[edi], byte ptr [esi]
game_flow_domovethings_74353:
    mov cx, word ptr [edx*2 + _connectpoint2]
game_flow_domovethings_74361:
    test cx, cx
    {disp32} jge game_flow_domovethings_74233
    mov edi, dword ptr [_movefifoplc]
    mov esi, 0xffffffff
    inc edi
    mov ebp, OFFSET FLAT:_buf
    mov dword ptr [_movefifoplc], edi
    call updateinterpolations_
    mov cx, word ptr [_connecthead]
    {disp32} jmp game_flow_domovethings_74732
game_flow_domovethings_74410:
    movsx edx, cx
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    test byte ptr [eax*2 + _sync + 0x9], 4
    jne game_flow_domovethings_74439
    {store} mov esi, ecx
    {disp32} jmp game_flow_domovethings_74721
game_flow_domovethings_74439:
    cmp cx, word ptr [_myconnectindex]
    jne game_flow_domovethings_74458
    mov eax, OFFSET FLAT:game_text_getpackets_96
    call gameexit_
game_flow_domovethings_74458:
    mov ax, word ptr [_screenpeek]
    {store} cmp cx, ax
    jne game_flow_domovethings_74501
    cwde
    mov ax, word ptr [eax*2 + _connectpoint2]
    mov word ptr [_screenpeek], ax
    test ax, ax
    jge game_flow_domovethings_74501
    mov ax, word ptr [_connecthead]
    mov word ptr [_screenpeek], ax
game_flow_domovethings_74501:
    mov bx, word ptr [_connecthead]
    {store} cmp cx, bx
    jne game_flow_domovethings_74532
    movsx eax, bx
    mov ax, word ptr [eax*2 + _connectpoint2]
    mov word ptr [_connecthead], ax
    jmp game_flow_domovethings_74554
game_flow_domovethings_74532:
    movsx eax, cx
    movsx edx, si
    mov ax, word ptr [eax*2 + _connectpoint2]
    mov word ptr [edx*2 + _connectpoint2], ax
game_flow_domovethings_74554:
    mov di, word ptr [_numplayers]
    mov ax, word ptr [_ud + 0x590]
    dec edi
    dec eax
    mov word ptr [_numplayers], di
    mov word ptr [_ud + 0x590], ax
    cmp di, 2
    jge game_flow_domovethings_74598
    mov eax, 0xb1
    call sound_
game_flow_domovethings_74598:
    mov dh, 1
    mov byte ptr [_pub], dh
    mov byte ptr [_pus], dh
    movsx edx, cx
    call vscrn_
    {store} mov eax, edx
    imul edx, edx, 0x552
    shl eax, 5
    add eax, OFFSET FLAT:_ud + 0x9
    push eax
    push OFFSET FLAT:game_text_domovethings_3492
    push OFFSET FLAT:_buf
    call sprintf_
    mov eax, OFFSET FLAT:_ps
    add esp, 0xc
    {store} add eax, edx
    call quickkill_
    movsx eax, word ptr [edx + _ps + 0x2d4]
    mov ebx, 0xa0
    call deletesprite_
    mov dword ptr [_received_quote], ebp
    mov word ptr [_received_quote_time], bx
    test si, si
    jge game_flow_domovethings_74721
    cmp byte ptr [_networkmode], 0
    jne game_flow_domovethings_74721
    mov eax, OFFSET FLAT:game_text_domovethings_3508
    call gameexit_
game_flow_domovethings_74721:
    movsx ecx, cx
    mov cx, word ptr [ecx*2 + _connectpoint2]
game_flow_domovethings_74732:
    test cx, cx
    {disp32} jge game_flow_domovethings_74410
    cmp word ptr [_numplayers], 2
    {disp32} jl game_flow_domovethings_74883
    mov eax, dword ptr [_movefifoplc]
    and eax, 7
    cmp eax, 7
    jne game_flow_domovethings_74883
    mov dh, byte ptr [_randomseed]
    mov cx, word ptr [_connecthead]
    jmp game_flow_domovethings_74836
game_flow_domovethings_74783:
    movsx ebx, cx
    imul eax, ebx, 0x552
    mov dl, byte ptr [eax + _ps + 0x214]
    add dl, byte ptr [eax + _ps + 0x218]
    add dl, byte ptr [eax + _ps + 0x21c]
    mov cl, byte ptr [eax + _ps + 0x280]
    mov al, byte ptr [eax + _ps + 0x220]
    add dl, cl
    add al, dl
    mov cx, word ptr [ebx*2 + _connectpoint2]
    add dh, al
game_flow_domovethings_74836:
    test cx, cx
    jge game_flow_domovethings_74783
    movsx ebx, word ptr [_myconnectindex]
    {disp32} lea eax, dword ptr [ebx*4]
    mov ecx, dword ptr [eax + _syncvalhead]
    shl ebx, 8
    and ecx, 0xff
    mov byte ptr [ecx + ebx + _syncval], dh
    inc dword ptr [eax + _syncvalhead]
game_flow_domovethings_74883:
    cmp dword ptr [_ud + 0x5fa], 1
    jne game_flow_domovethings_74897
    call record_
game_flow_domovethings_74897:
    cmp word ptr [_ud + 0x588], 0
    jne game_flow_domovethings_74923
    call krand_
    mov word ptr [_global_random], ax
    call movedummyplayers_
game_flow_domovethings_74923:
    mov cx, word ptr [_connecthead]
    jmp game_flow_domovethings_74977
game_flow_domovethings_74932:
    movsx edx, cx
    {store} mov eax, edx
    call cheatkeys_
    cmp word ptr [_ud + 0x588], 0
    jne game_flow_domovethings_74966
    {store} mov eax, edx
    call processinput_
    {store} mov eax, edx
    call checksectors_
game_flow_domovethings_74966:
    movsx eax, cx
    mov cx, word ptr [eax*2 + _connectpoint2]
game_flow_domovethings_74977:
    test cx, cx
    jge game_flow_domovethings_74932
    cmp word ptr [_ud + 0x588], 0
    jne game_flow_domovethings_75047
    call movefta_
    call moveweapons_
    call movetransports_
    call moveplayers_
    call movefallers_
    call moveexplosions_
    call moveactors_
    call moveeffectors_
    call movestandables_
    call doanimations_
    call movefx_
game_flow_domovethings_75047:
    call fakedomovethingscorrect_
    test byte ptr [_everyothertime], 1
    jne game_flow_domovethings_75076
    call animatewalls_
    call movecyclers_
    call pan3dsound_
game_flow_domovethings_75076:
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp8} lea eax, dword ptr [eax]
    {load} mov ecx, ecx
doorders_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    mov ecx, dword ptr [_ydim]
    mov ebx, dword ptr [_xdim]
    {store} xor edx, edx
    {store} xor eax, eax
    dec ecx
    dec ebx
    {store} xor esi, esi
    call setview_
    jmp game_flow_doorders_75138
game_flow_doorders_75121:
    movsx ecx, si
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    call palto_
    add esi, 7
game_flow_doorders_75138:
    cmp si, 0x3f
    jl game_flow_doorders_75121
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov edx, OFFSET FLAT:_palette
    {store} xor ebx, ebx
    mov dword ptr [eax + _ps + 0x541], edx
    mov dword ptr [_totalclock], ebx
    call KB_FlushKeyboardQueue_
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push ebx
    push ebx
    push 0x5a
    push ebx
    {store} xor ecx, ecx
    push ebx
    {store} xor edx, edx
    {store} xor eax, eax
    push 0xcc6
    mov ebx, 0x10000
    mov esi, 0x3f
    call rotatesprite_
    call nextpage_
    jmp game_flow_doorders_75251
game_flow_doorders_75234:
    movsx ecx, si
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    call palto_
    sub esi, 7
game_flow_doorders_75251:
    test si, si
    jg game_flow_doorders_75234
    {store} xor ecx, ecx
    mov dword ptr [_totalclock], ecx
game_flow_doorders_75264:
    call KB_KeyWaiting_
    test eax, eax
    je game_flow_doorders_75264
    {store} xor esi, esi
    jmp game_flow_doorders_75294
game_flow_doorders_75277:
    movsx ecx, si
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    call palto_
    add esi, 7
game_flow_doorders_75294:
    cmp si, 0x3f
    jl game_flow_doorders_75277
    {store} xor esi, esi
    mov dword ptr [_totalclock], esi
    call KB_FlushKeyboardQueue_
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push esi
    push esi
    push 0x5a
    push esi
    mov ebx, 0x10000
    push esi
    {store} xor ecx, ecx
    {store} xor edx, edx
    push 0xcc7
    {store} xor eax, eax
    mov esi, 0x3f
    call rotatesprite_
    call nextpage_
    jmp game_flow_doorders_75383
game_flow_doorders_75366:
    movsx ecx, si
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    call palto_
    sub esi, 7
game_flow_doorders_75383:
    test si, si
    jg game_flow_doorders_75366
    {store} xor edi, edi
    mov dword ptr [_totalclock], edi
game_flow_doorders_75396:
    call KB_KeyWaiting_
    test eax, eax
    je game_flow_doorders_75396
    {store} xor esi, esi
    jmp game_flow_doorders_75426
game_flow_doorders_75409:
    movsx ecx, si
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    call palto_
    add esi, 7
game_flow_doorders_75426:
    cmp si, 0x3f
    jl game_flow_doorders_75409
    {store} xor ebp, ebp
    mov dword ptr [_totalclock], ebp
    call KB_FlushKeyboardQueue_
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push ebp
    push ebp
    push 0x5a
    push ebp
    mov ebx, 0x10000
    push ebp
    {store} xor ecx, ecx
    {store} xor edx, edx
    push 0xcc8
    {store} xor eax, eax
    mov esi, 0x3f
    call rotatesprite_
    call nextpage_
    jmp game_flow_doorders_75515
game_flow_doorders_75498:
    movsx ecx, si
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    call palto_
    sub esi, 7
game_flow_doorders_75515:
    test si, si
    jg game_flow_doorders_75498
    {store} xor eax, eax
    mov dword ptr [_totalclock], eax
game_flow_doorders_75527:
    call KB_KeyWaiting_
    test eax, eax
    je game_flow_doorders_75527
    {store} xor esi, esi
    jmp game_flow_doorders_75557
game_flow_doorders_75540:
    movsx ecx, si
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    call palto_
    add esi, 7
game_flow_doorders_75557:
    cmp si, 0x3f
    jl game_flow_doorders_75540
    {store} xor edx, edx
    mov dword ptr [_totalclock], edx
    call KB_FlushKeyboardQueue_
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push edx
    push edx
    push 0x5a
    push edx
    push edx
    mov ebx, 0x10000
    {store} xor ecx, ecx
    push 0xcc9
    {store} xor eax, eax
    mov esi, 0x3f
    call rotatesprite_
    call nextpage_
    jmp game_flow_doorders_75644
game_flow_doorders_75627:
    movsx ecx, si
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    call palto_
    sub esi, 7
game_flow_doorders_75644:
    test si, si
    jg game_flow_doorders_75627
    {store} xor ebx, ebx
    mov dword ptr [_totalclock], ebx
game_flow_doorders_75657:
    call KB_KeyWaiting_
    test eax, eax
    je game_flow_doorders_75657
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp8} lea eax, dword ptr [eax]
game_switch_dobonus_75676:
    # Real compiler switch table: 10 named private destinations
    .long game_flow_dobonus_79237
    .long game_flow_dobonus_79306
    .long game_flow_dobonus_79356
    .long game_flow_dobonus_79356
    .long game_flow_dobonus_79306
    .long game_flow_dobonus_79306
game_switch_view_75700: # actual interior typed table view
    .long game_flow_dobonus_79275
    .long game_flow_dobonus_79282
    .long game_flow_dobonus_79289
    .long game_flow_dobonus_79296
    {disp32} lea eax, dword ptr [eax]
    {disp32} lea edx, dword ptr [edx]
dobonus_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    sub esp, 0xdc
    mov byte ptr [esp + 216], al
    mov ecx, 0x14
    lea edi, dword ptr [esp + 120]
    mov esi, OFFSET FLAT:game_bonus_breathe
    rep movsd dword ptr es:[edi], dword ptr [esi]
    mov ecx, 0x1e
    {store} mov edi, esp
    mov esi, OFFSET FLAT:game_bonus_bossmove
    rep movsd dword ptr es:[edi], dword ptr [esi]
    {store} xor edi, edi
    {store} xor esi, esi
    jmp game_flow_dobonus_75798
game_flow_dobonus_75783:
    movsx ecx, si
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    call palto_
    inc esi
game_flow_dobonus_75798:
    cmp si, 0x40
    jl game_flow_dobonus_75783
    mov ecx, dword ptr [_ydim]
    mov ebx, dword ptr [_xdim]
    {store} xor edx, edx
    {store} xor eax, eax
    dec ecx
    dec ebx
    call setview_
    {store} xor eax, eax
    call clearview_
    call nextpage_
    call flushperms_
    call FX_StopAllSounds_
    call clearsoundlocks_
    {store} xor eax, eax
    call FX_SetReverb_
    cmp byte ptr [esp + 216], 0
    {disp32} jne game_flow_dobonus_77556
    cmp word ptr [_numplayers], 2
    {disp32} jge game_flow_dobonus_77556
    cmp byte ptr [_ud + 0x3], 0
    {disp32} je game_flow_dobonus_77556
    cmp word ptr [_ud + 0x58a], 0
    {disp32} jne game_flow_dobonus_77556
    mov eax, dword ptr [_ud + 0x632]
    cmp eax, 1
    jb game_flow_dobonus_75946
    {disp32} jbe game_flow_dobonus_76892
    cmp eax, 2
    {disp32} je game_flow_dobonus_77161
    {disp32} jmp game_flow_dobonus_77556
game_flow_dobonus_75946:
    test eax, eax
    {disp32} jne game_flow_dobonus_77556
    mov ecx, dword ptr [_ud + 0x5e6]
    test ecx, ecx
    {disp32} jne game_flow_dobonus_76708
    call clearview_
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push ecx
    push ecx
    push 0xda
    push ecx
    push ecx
    mov ebx, 0x10000
    push 0xcbc
    mov edx, 0x320000
    {store} xor eax, eax
    call rotatesprite_
    call nextpage_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov dword ptr [eax + _ps + 0x541], OFFSET FLAT:_endingpal
    mov esi, 0x3f
    jmp game_flow_dobonus_76068
game_flow_dobonus_76053:
    movsx ecx, si
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    call palto_
    dec esi
game_flow_dobonus_76068:
    test si, si
    jge game_flow_dobonus_76053
    {store} xor ebx, ebx
    call KB_FlushKeyboardQueue_
    mov dword ptr [_totalclock], ebx
game_flow_dobonus_76086:
    {store} xor eax, eax
    call clearview_
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0xda
    push 0
    push 0
    mov ebx, 0x10000
    mov edx, 0x320000
    push 0xcbc
    {store} xor ecx, ecx
    {store} xor eax, eax
    call rotatesprite_
    cmp dword ptr [_totalclock], 0x186
    {disp32} jle game_flow_dobonus_76369
    cmp dword ptr [_totalclock], 0x30c
    {disp32} jge game_flow_dobonus_76369
    {store} xor esi, esi
    {disp32} jmp game_flow_dobonus_76359
game_flow_dobonus_76183:
    movsx ebp, si
    {disp32} lea ebp, dword ptr [ebp*4]
    cmp dword ptr [esp + ebp + 8], 0
    {disp32} je game_flow_dobonus_76356
    mov ebx, 0x186
    mov eax, dword ptr [_totalclock]
    mov edx, dword ptr [_totalclock]
    sar edx, 0x1f
    idiv ebx
    cmp edx, dword ptr [esp + ebp]
    {disp32} jle game_flow_dobonus_76356
    mov ebx, 0x186
    mov eax, dword ptr [_totalclock]
    mov edx, dword ptr [_totalclock]
    sar edx, 0x1f
    idiv ebx
    cmp edx, dword ptr [esp + ebp + 4]
    jg game_flow_dobonus_76356
    cmp si, 0xa
    jne game_flow_dobonus_76295
    cmp di, 1
    jne game_flow_dobonus_76295
    mov eax, 0x6d
    call sound_
    mov eax, 0x45
    {store} add edi, edi
    call sound_
game_flow_dobonus_76295:
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    mov ebx, 0x10000
    {store} xor ecx, ecx
    push 0xda
    movsx eax, si
    push 0
    mov ebp, dword ptr [esp + eax*4 + 32]
    mov edx, dword ptr [esp + eax*4 + 40]
    push 0
    shl edx, 0x10
    mov eax, dword ptr [esp + eax*4 + 40]
    push ebp
    shl eax, 0x10
    call rotatesprite_
game_flow_dobonus_76356:
    add esi, 5
game_flow_dobonus_76359:
    cmp si, 0x23
    {disp32} jl game_flow_dobonus_76183
game_flow_dobonus_76369:
    cmp dword ptr [_totalclock], 0x1c2
    jl game_flow_dobonus_76397
    cmp dword ptr [_totalclock], 0x2ee
    {disp32} jl game_flow_dobonus_76690
game_flow_dobonus_76397:
    cmp dword ptr [_totalclock], 0x2ee
    jl game_flow_dobonus_76492
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0xda
    push 0
    push 0
    mov ebx, 0x10000
    mov edx, 0x3b0000
    push 0xcc4
    {store} xor ecx, ecx
    mov eax, 0x560000
    call rotatesprite_
    cmp dword ptr [_totalclock], 0x2ee
    jl game_flow_dobonus_76492
    cmp di, 2
    jne game_flow_dobonus_76492
    mov eax, 0x38
    call sound_
    inc edi
game_flow_dobonus_76492:
    {store} xor esi, esi
    {disp32} jmp game_flow_dobonus_76680
game_flow_dobonus_76499:
    movsx ebp, si
    {disp32} lea ebp, dword ptr [ebp*4]
    cmp dword ptr [esp + ebp + 128], 0
    {disp32} je game_flow_dobonus_76677
    mov ebx, 0x78
    mov eax, dword ptr [_totalclock]
    mov edx, dword ptr [_totalclock]
    sar edx, 0x1f
    idiv ebx
    cmp edx, dword ptr [esp + ebp + 120]
    {disp32} jle game_flow_dobonus_76677
    mov ebx, 0x78
    mov eax, dword ptr [_totalclock]
    mov edx, dword ptr [_totalclock]
    sar edx, 0x1f
    idiv ebx
    cmp edx, dword ptr [esp + ebp + 124]
    jg game_flow_dobonus_76677
    cmp si, 5
    jne game_flow_dobonus_76607
    test di, di
    jne game_flow_dobonus_76607
    mov eax, 0xe6
    mov edi, 1
    call sound_
game_flow_dobonus_76607:
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    mov ebx, 0x10000
    {store} xor ecx, ecx
    push 0xda
    movsx eax, si
    push 0
    mov ebp, dword ptr [esp + eax*4 + 152]
    mov edx, dword ptr [esp + eax*4 + 160]
    push 0
    shl edx, 0x10
    mov eax, dword ptr [esp + eax*4 + 160]
    push ebp
    shl eax, 0x10
    call rotatesprite_
game_flow_dobonus_76677:
    add esi, 5
game_flow_dobonus_76680:
    cmp si, 0x14
    {disp32} jl game_flow_dobonus_76499
game_flow_dobonus_76690:
    call nextpage_
    call KB_KeyWaiting_
    test eax, eax
    {disp32} je game_flow_dobonus_76086
game_flow_dobonus_76708:
    {store} xor esi, esi
    jmp game_flow_dobonus_76727
game_flow_dobonus_76712:
    movsx ecx, si
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    call palto_
    inc esi
game_flow_dobonus_76727:
    cmp si, 0x40
    jl game_flow_dobonus_76712
    call KB_FlushKeyboardQueue_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov dword ptr [eax + _ps + 0x541], OFFSET FLAT:_palette
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0x5a
    push 0
    mov ebx, 0x10000
    push 0
    {store} xor ecx, ecx
    {store} xor edx, edx
    push 0xcdc
    {store} xor eax, eax
    mov esi, 0x3f
    call rotatesprite_
    call nextpage_
    jmp game_flow_dobonus_76833
game_flow_dobonus_76818:
    movsx ecx, si
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    call palto_
    dec esi
game_flow_dobonus_76833:
    test si, si
    jg game_flow_dobonus_76818
game_flow_dobonus_76838:
    call KB_KeyWaiting_
    test eax, eax
    je game_flow_dobonus_76838
    {store} xor esi, esi
    jmp game_flow_dobonus_76866
game_flow_dobonus_76851:
    movsx ecx, si
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    call palto_
    inc esi
game_flow_dobonus_76866:
    cmp si, 0x40
    jl game_flow_dobonus_76851
    call MUSIC_StopSong_
    call FX_StopAllSounds_
    call clearsoundlocks_
    {disp32} jmp game_flow_dobonus_77556
game_flow_dobonus_76892:
    call MUSIC_StopSong_
    {store} xor eax, eax
    call clearview_
    call nextpage_
    cmp dword ptr [_ud + 0x5e6], 0
    jne game_flow_dobonus_76950
    mov edx, 1
    mov eax, OFFSET FLAT:game_text_dobonus_3676
    call playanm_
    call KB_FlushKeyBoardQueue_
    {store} xor eax, eax
    call clearview_
    call nextpage_
game_flow_dobonus_76950:
    mov eax, 0xe
    call sound_
    {store} xor esi, esi
    jmp game_flow_dobonus_76979
game_flow_dobonus_76964:
    movsx ecx, si
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    call palto_
    inc esi
game_flow_dobonus_76979:
    cmp si, 0x40
    jl game_flow_dobonus_76964
    mov ecx, dword ptr [_ydim]
    mov ebx, dword ptr [_xdim]
    {store} xor edx, edx
    {store} xor eax, eax
    dec ecx
    dec ebx
    call setview_
    call KB_FlushKeyboardQueue_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov dword ptr [eax + _ps + 0x541], OFFSET FLAT:_palette
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0x5a
    push 0
    mov ebx, 0x10000
    push 0
    {store} xor ecx, ecx
    {store} xor edx, edx
    push 0xcdd
    {store} xor eax, eax
    mov esi, 0x3f
    call rotatesprite_
    call nextpage_
    jmp game_flow_dobonus_77108
game_flow_dobonus_77093:
    movsx ecx, si
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    call palto_
    dec esi
game_flow_dobonus_77108:
    test si, si
    jg game_flow_dobonus_77093
game_flow_dobonus_77113:
    call KB_KeyWaiting_
    test eax, eax
    je game_flow_dobonus_77113
    {store} xor esi, esi
    cmp si, 0x40
    jl game_flow_dobonus_77135
    {disp32} jmp game_flow_dobonus_77556
game_flow_dobonus_77135:
    movsx ecx, si
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    call palto_
    inc esi
    cmp si, 0x40
    jl game_flow_dobonus_77135
    {disp32} jmp game_flow_dobonus_77556
game_flow_dobonus_77161:
    call MUSIC_StopSong_
    {store} xor eax, eax
    call clearview_
    call nextpage_
    cmp dword ptr [_ud + 0x5e6], 0
    jne game_flow_dobonus_77285
    mov esi, 0x3f
    jmp game_flow_dobonus_77209
game_flow_dobonus_77194:
    movsx ecx, si
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    call palto_
    dec esi
game_flow_dobonus_77209:
    test si, si
    jge game_flow_dobonus_77194
    mov edx, 2
    mov eax, OFFSET FLAT:game_text_dobonus_3688
    call playanm_
    call KB_FlushKeyBoardQueue_
    mov eax, dword ptr [_totalclock]
    .att_syntax prefix
    addl $game_math_dobonus_77239,%eax
    .intel_syntax noprefix
    mov dword ptr [_ototalclock], eax
    mov edi, dword ptr [_ototalclock]
game_flow_dobonus_77255:
    cmp edi, dword ptr [_totalclock]
    jg game_flow_dobonus_77255
    {store} xor eax, eax
    call clearview_
    call nextpage_
    call FX_StopAllSounds_
    call clearsoundlocks_
game_flow_dobonus_77285:
    mov edx, 3
    mov eax, OFFSET FLAT:game_text_dobonus_3700
    call playanm_
    cmp dword ptr [_ud + 0x5e6], 0
    {disp32} jne game_flow_dobonus_77461
    call KB_KeyWaiting_
    test eax, eax
    {disp32} jne game_flow_dobonus_77461
    mov eax, 0x121
    call sound_
game_flow_dobonus_77336:
    cmp byte ptr [_Sound + 0xeb1], 0xc8
    jae game_flow_dobonus_77336
    call KB_KeyWaiting_
    test eax, eax
    {disp32} jne game_flow_dobonus_77475
    mov eax, 0x122
    call sound_
game_flow_dobonus_77368:
    cmp byte ptr [_Sound + 0xebe], 0xc8
    jae game_flow_dobonus_77368
    call KB_KeyWaiting_
    test eax, eax
    jne game_flow_dobonus_77475
    mov eax, 0x123
    call sound_
game_flow_dobonus_77396:
    cmp byte ptr [_Sound + 0xecb], 0xc8
    jae game_flow_dobonus_77396
    call KB_KeyWaiting_
    test eax, eax
    jne game_flow_dobonus_77475
    mov eax, 0x124
    call sound_
game_flow_dobonus_77424:
    cmp byte ptr [_Sound + 0xed8], 0xc8
    jae game_flow_dobonus_77424
    call KB_KeyWaiting_
    test eax, eax
    jne game_flow_dobonus_77475
    mov eax, 0x125
    call sound_
game_flow_dobonus_77452:
    cmp byte ptr [_Sound + 0xee5], 0xc8
    jae game_flow_dobonus_77452
game_flow_dobonus_77461:
    call KB_FlushKeyBoardQueue_
game_flow_dobonus_77466:
    call KB_KeyWaiting_
    test eax, eax
    je game_flow_dobonus_77466
game_flow_dobonus_77475:
    call FX_StopAllSounds_
    call clearsoundlocks_
    call KB_FlushKeyBoardQueue_
    {store} xor eax, eax
    call clearview_
    call nextpage_
    mov eax, 0x120
    mov edx, 4
    call sound_
    mov eax, OFFSET FLAT:game_text_dobonus_3712
    call playanm_
    call KB_FlushKeyBoardQueue_
game_flow_dobonus_77532:
    call KB_KeyWaiting_
    test eax, eax
    je game_flow_dobonus_77532
    call FX_StopAllSounds_
    call clearsoundlocks_
    call KB_FlushKeyBoardQueue_
game_flow_dobonus_77556:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov ebx, OFFSET FLAT:_palette
    {store} xor ecx, ecx
    mov dword ptr [eax + _ps + 0x541], ebx
    call KB_FlushKeyboardQueue_
    mov dword ptr [_totalclock], ecx
    call MUSIC_StopSong_
    call FX_StopAllSounds_
    call clearsoundlocks_
    cmp byte ptr [_playerswhenstarted], 1
    {disp32} jbe game_flow_dobonus_78797
    cmp dword ptr [_ud + 0x5de], 1
    {disp32} je game_flow_dobonus_78797
    cmp dword ptr [_MusicToggle], 0
    je game_flow_dobonus_77662
    cmp dword ptr [_MusicDevice], 0xd
    je game_flow_dobonus_77662
    mov eax, 0xf9
    call sound_
game_flow_dobonus_77662:
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0xda
    push 0
    push 0x10
    mov ebx, 0x10000
    {store} xor ecx, ecx
    push 0x998
    {store} xor edx, edx
    {store} xor eax, eax
    call rotatesprite_
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0xa
    push 0
    push 0
    mov ebx, 0x10000
    mov edx, 0x200000
    push 0x9c3
    {store} xor ecx, ecx
    mov eax, 0xa00000
    call rotatesprite_
    mov ebx, OFFSET FLAT:game_text_dobonus_3728
    mov edx, 0x3a
    mov eax, 0xa0
    {store} xor ecx, ecx
    call gametext_
    imul edx, dword ptr [_ud + 0x632], 0xb
    movsx eax, word ptr [_ud + 0x592]
    {store} add edx, eax
    dec edx
    {store} mov eax, edx
    mov ebx, OFFSET FLAT:_level_names
    shl eax, 5
    {store} xor ecx, ecx
    {store} add eax, edx
    mov edx, 0x44
    {store} add ebx, eax
    mov eax, 0xa0
    call gametext_
    mov ebx, OFFSET FLAT:game_text_dobonus_3748
    mov edx, 0xa5
    mov eax, 0xa0
    {store} xor ecx, ecx
    {store} xor esi, esi
    call gametext_
    push 0x9a
    mov ecx, 8
    mov ebx, OFFSET FLAT:game_text_dobonus_3776
    mov edx, 0x50
    mov eax, 0x17
    {store} xor ebp, ebp
    call minitext_
    jmp game_flow_dobonus_77959
game_flow_dobonus_77889:
    lea edi, dword ptr [ebp + 1]
    push edi
    push OFFSET FLAT:game_text_dobonus_3832
    push OFFSET FLAT:_tempbuf
    mov ecx, 3
    call sprintf_
    {disp32} lea eax, dword ptr [ebp*4]
    add esp, 0xc
    {store} sub eax, ebp
    mov ebx, OFFSET FLAT:_tempbuf
    {disp32} lea eax, dword ptr [eax*8]
    push 0x9a
    {store} sub eax, ebp
    mov edx, 0x50
    add eax, 0x5c
    call minitext_
    {store} mov ebp, edi
game_flow_dobonus_77959:
    {store} xor eax, eax
    mov al, byte ptr [_playerswhenstarted]
    {store} cmp ebp, eax
    jl game_flow_dobonus_77889
    {store} xor ebp, ebp
    {disp32} jmp game_flow_dobonus_78476
game_flow_dobonus_77977:
    lea eax, dword ptr [ebp + 1]
    push eax
    push OFFSET FLAT:game_text_invennum_232
    mov ebx, OFFSET FLAT:_tempbuf
    {store} xor edx, edx
    push OFFSET FLAT:_tempbuf
    movsx edi, si
    mov dword ptr [esp + 220], edx
    call sprintf_
    add esp, 0xc
    {store} xor ecx, ecx
    add edi, 0x5a
    push 0x9a
    {store} mov edx, edi
    mov eax, 0x1e
    call minitext_
    imul ecx, ebp, 0x552
    push 0x9a
    mov cl, byte ptr [ecx + _ps + 0x548]
    mov eax, 0x26
    {store} mov ebx, ebp
    and ecx, 0xff
    shl ebx, 5
    {store} mov edx, edi
    add ebx, OFFSET FLAT:_ud + 0x9
    {store} xor edi, edi
    call minitext_
    {disp32} jmp game_flow_dobonus_78400
game_flow_dobonus_78091:
    {disp32} lea eax, dword ptr [edi*4]
    {store} sub eax, edi
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edi
    add eax, 0x5c
    mov dword ptr [esp + 204], eax
    {store} cmp ebp, edi
    jne game_flow_dobonus_78227
    imul eax, edi, 0x552
    mov dword ptr [esp + 200], eax
    movsx eax, word ptr [eax + _ps + 0x2a6]
    push eax
    push OFFSET FLAT:game_text_dobonus_3832
    push OFFSET FLAT:_tempbuf
    mov ecx, 2
    mov ebx, OFFSET FLAT:_tempbuf
    call sprintf_
    add esp, 0xc
    movsx edx, si
    push 0x9a
    add edx, 0x5a
    mov eax, dword ptr [esp + 208]
    call minitext_
    mov eax, dword ptr [esp + 200]
    mov edx, dword ptr [esp + 208]
    movsx eax, word ptr [eax + _ps + 0x2a6]
    {store} sub edx, eax
    mov dword ptr [esp + 208], edx
    jmp game_flow_dobonus_78334
game_flow_dobonus_78227:
    {store} mov edx, ebp
    {disp32} lea eax, dword ptr [edi*2]
    shl edx, 5
    {store} add edx, eax
    movsx eax, word ptr [edx + _frags]
    push eax
    push OFFSET FLAT:game_text_dobonus_3832
    mov ebx, OFFSET FLAT:_tempbuf
    push OFFSET FLAT:_tempbuf
    {store} xor ecx, ecx
    mov dword ptr [esp + 212], edx
    call sprintf_
    add esp, 0xc
    movsx edx, si
    push 0x9a
    add edx, 0x5a
    mov eax, dword ptr [esp + 208]
    call minitext_
    mov eax, dword ptr [esp + 200]
    mov ecx, dword ptr [esp + 208]
    movsx eax, word ptr [eax + _frags]
    {store} add ecx, eax
    mov dword ptr [esp + 208], ecx
game_flow_dobonus_78334:
    mov ax, word ptr [_myconnectindex]
    cmp ax, word ptr [_connecthead]
    jne game_flow_dobonus_78399
    {store} mov eax, ebp
    shl eax, 5
    movsx eax, word ptr [eax + edi*2 + _frags]
    push eax
    lea eax, dword ptr [edi + 1]
    push eax
    lea eax, dword ptr [ebp + 1]
    push eax
    push OFFSET FLAT:game_text_dobonus_3840
    push OFFSET FLAT:_tempbuf
    call sprintf_
    add esp, 0x14
    mov eax, OFFSET FLAT:_tempbuf
    call sendscore_
game_flow_dobonus_78399:
    inc edi
game_flow_dobonus_78400:
    {store} xor eax, eax
    mov al, byte ptr [_playerswhenstarted]
    {store} cmp edi, eax
    {disp32} jl game_flow_dobonus_78091
    mov ebx, dword ptr [esp + 208]
    push ebx
    push OFFSET FLAT:game_text_dobonus_3832
    mov ecx, 2
    push OFFSET FLAT:_tempbuf
    movsx edx, si
    inc ebp
    call sprintf_
    add esp, 0xc
    add edx, 0x5a
    mov ebx, OFFSET FLAT:_tempbuf
    push 0x9a
    mov eax, 0x11d
    add esi, 7
    call minitext_
game_flow_dobonus_78476:
    {store} xor eax, eax
    mov al, byte ptr [_playerswhenstarted]
    {store} cmp ebp, eax
    {disp32} jl game_flow_dobonus_77977
    {store} xor edi, edi
    {disp32} jmp game_flow_dobonus_78617
game_flow_dobonus_78498:
    {store} xor eax, eax
    {store} xor ebp, ebp
    jmp game_flow_dobonus_78539
game_flow_dobonus_78504:
    {store} cmp ebp, edi
    jne game_flow_dobonus_78523
    imul edx, edi, 0x552
    movsx edx, word ptr [edx + _ps + 0x2a6]
    {store} add eax, edx
game_flow_dobonus_78523:
    {store} mov edx, ebp
    shl edx, 5
    movsx edx, word ptr [edx + edi*2 + _frags]
    inc ebp
    {store} add eax, edx
game_flow_dobonus_78539:
    {store} xor edx, edx
    mov dl, byte ptr [_playerswhenstarted]
    {store} cmp ebp, edx
    jl game_flow_dobonus_78504
    push eax
    push OFFSET FLAT:game_text_dobonus_3832
    push OFFSET FLAT:_tempbuf
    mov ecx, 2
    call sprintf_
    {disp32} lea eax, dword ptr [edi*4]
    add esp, 0xc
    {store} sub eax, edi
    mov ebx, OFFSET FLAT:_tempbuf
    {disp32} lea eax, dword ptr [eax*8]
    push 0x9a
    {store} sub eax, edi
    mov edx, 0x98
    add eax, 0x5c
    call minitext_
    inc edi
game_flow_dobonus_78617:
    {store} xor eax, eax
    mov al, byte ptr [_playerswhenstarted]
    {store} cmp edi, eax
    {disp32} jl game_flow_dobonus_78498
    push 0x9a
    mov ecx, 8
    mov ebx, OFFSET FLAT:game_text_dobonus_3868
    mov edx, 0x98
    mov eax, 0x2d
    call minitext_
    call nextpage_
    {store} xor esi, esi
    jmp game_flow_dobonus_78695
game_flow_dobonus_78671:
    mov eax, 0x3f
    movsx ecx, si
    {store} xor ebx, ebx
    {store} sub eax, ecx
    {store} xor edx, edx
    {store} mov ecx, eax
    {store} xor eax, eax
    inc esi
    call palto_
game_flow_dobonus_78695:
    cmp si, 0x40
    jl game_flow_dobonus_78671
    call KB_FlushKeyboardQueue_
game_flow_dobonus_78706:
    call KB_KeyWaiting_
    test eax, eax
    je game_flow_dobonus_78706
    cmp byte ptr [_KB_KeyDown + 0x58], 0
    je game_flow_dobonus_78744
    xor dl, dl
    mov byte ptr [_KB_KeyDown + 0x58], dl
    mov eax, OFFSET FLAT:game_text_nonsharedkeys_596
    {store} xor edx, edx
    call screencapture_
game_flow_dobonus_78744:
    cmp byte ptr [esp + 216], 0
    {disp32} jne game_flow_dobonus_80923
    cmp word ptr [_ud + 0x590], 1
    {disp32} jg game_flow_dobonus_80923
    {store} xor esi, esi
    jmp game_flow_dobonus_78791
game_flow_dobonus_78776:
    movsx ecx, si
    {store} xor ebx, ebx
    {store} xor edx, edx
    {store} xor eax, eax
    call palto_
    inc esi
game_flow_dobonus_78791:
    cmp si, 0x40
    jl game_flow_dobonus_78776
game_flow_dobonus_78797:
    cmp byte ptr [esp + 216], 0
    {disp32} jne game_flow_dobonus_80923
    cmp word ptr [_ud + 0x590], 1
    {disp32} jg game_flow_dobonus_80923
    cmp dword ptr [_MusicToggle], 0
    je game_flow_dobonus_78853
    cmp dword ptr [_MusicDevice], 0xd
    je game_flow_dobonus_78853
    mov eax, 0xf9
    call sound_
game_flow_dobonus_78853:
    mov ax, word ptr [_ud + 0x632]
    xor ah, ah
    and al, 1
    imul eax, eax, 5
    mov dword ptr [esp + 212], eax
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0xda
    mov ebx, 0x10000
    push 0
    movsx eax, word ptr [esp + 236]
    push 0
    .att_syntax prefix
    addl $game_math_dobonus_78913,%eax
    .intel_syntax noprefix
    {store} xor ecx, ecx
    push eax
    {store} xor edx, edx
    {store} xor eax, eax
    call rotatesprite_
    imul edx, dword ptr [_ud + 0x632], 0xb
    movsx eax, word ptr [_ud + 0x592]
    {store} add eax, edx
    lea edx, dword ptr [eax + -1]
    {store} mov eax, edx
    shl eax, 5
    {store} add eax, edx
    {store} xor ecx, ecx
    add eax, OFFSET FLAT:_level_names
    {store} xor ebx, ebx
    push eax
    mov edx, 0xb
    mov eax, 0xa0
    call menutext_
    push OFFSET FLAT:game_text_dobonus_3876
    mov edx, 0x1b
    mov eax, 0xa0
    {store} xor ecx, ecx
    {store} xor ebx, ebx
    call menutext_
    mov ecx, 0x10
    mov ebx, OFFSET FLAT:game_text_dobonus_3748
    mov edx, 0xc0
    mov eax, 0xa0
    {store} xor esi, esi
    call gametext_
    call nextpage_
    call KB_FlushKeyboardQueue_
    jmp game_flow_dobonus_79068
game_flow_dobonus_79044:
    mov eax, 0x3f
    movsx ecx, si
    {store} xor ebx, ebx
    {store} sub eax, ecx
    {store} xor edx, edx
    {store} mov ecx, eax
    {store} xor eax, eax
    inc esi
    call palto_
game_flow_dobonus_79068:
    cmp si, 0x40
    jl game_flow_dobonus_79044
    {store} xor edi, edi
    {store} xor ebp, ebp
    mov dword ptr [_totalclock], ebp
game_flow_dobonus_79084:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    test byte ptr [eax + _ps + 0x516], 8
    {disp32} je game_flow_dobonus_80923
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0xda
    mov ebx, 0x10000
    push 0
    movsx eax, word ptr [esp + 236]
    push 0
    .att_syntax prefix
    addl $game_math_dobonus_79150,%eax
    .intel_syntax noprefix
    {store} xor ecx, ecx
    push eax
    {store} xor edx, edx
    {store} xor eax, eax
    call rotatesprite_
    cmp dword ptr [_totalclock], 0x3b9aca00
    {disp32} jle game_flow_dobonus_79424
    cmp dword ptr [_totalclock], 0x3b9acb40
    {disp32} jge game_flow_dobonus_79424
    mov edx, dword ptr [_totalclock]
    sar edx, 4
    mov ebx, 0xf
    {store} mov eax, edx
    sar edx, 0x1f
    idiv ebx
    cmp edx, 5
    {disp32} ja game_flow_dobonus_79580
    jmp dword ptr cs:[edx*4 + game_switch_dobonus_75676]
game_flow_dobonus_79237:
    cmp di, 6
    jne game_flow_dobonus_79306
    mov eax, 0xa9
    call sound_
    call rand_
    and eax, 3
    inc edi
    cmp eax, 3
    ja game_flow_dobonus_79306
    jmp dword ptr cs:[eax*4 + game_switch_view_75700]
game_flow_dobonus_79275:
    mov eax, 0xc3
    jmp game_flow_dobonus_79301
game_flow_dobonus_79282:
    mov eax, 0xc4
    jmp game_flow_dobonus_79301
game_flow_dobonus_79289:
    mov eax, 0xc5
    jmp game_flow_dobonus_79301
game_flow_dobonus_79296:
    mov eax, 0xc7
game_flow_dobonus_79301:
    call sound_
game_flow_dobonus_79306:
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0xda
    mov ebx, 0x10000
    push 0
    movsx eax, word ptr [esp + 236]
    push 0
    .att_syntax prefix
    addl $game_math_dobonus_79346,%eax
    .intel_syntax noprefix
    {disp32} jmp game_flow_dobonus_79562
game_flow_dobonus_79356:
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0xda
    mov ebx, 0x10000
    push 0
    movsx eax, word ptr [esp + 236]
    push 0
    .att_syntax prefix
    addl $game_math_dobonus_79396,%eax
    .intel_syntax noprefix
    mov edx, 0x1f0000
    push eax
    {store} xor ecx, ecx
    mov eax, 0xc70000
    call rotatesprite_
    {disp32} jmp game_flow_dobonus_79580
game_flow_dobonus_79424:
    cmp dword ptr [_totalclock], 0x2878
    {disp32} jg game_flow_dobonus_80923
    mov eax, dword ptr [_totalclock]
    sar eax, 5
    and eax, 3
    cmp eax, 2
    jb game_flow_dobonus_79465
    jbe game_flow_dobonus_79517
    cmp eax, 3
    je game_flow_dobonus_79470
    jmp game_flow_dobonus_79580
game_flow_dobonus_79465:
    cmp eax, 1
    jne game_flow_dobonus_79580
game_flow_dobonus_79470:
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0xda
    mov ebx, 0x10000
    push 0
    movsx eax, word ptr [esp + 236]
    push 0
    .att_syntax prefix
    addl $game_math_dobonus_79510,%eax
    .intel_syntax noprefix
    jmp game_flow_dobonus_79562
game_flow_dobonus_79517:
    mov eax, dword ptr [_ydim]
    dec eax
    push eax
    mov eax, dword ptr [_xdim]
    dec eax
    push eax
    push 0
    push 0
    push 0xda
    mov ebx, 0x10000
    push 0
    movsx eax, word ptr [esp + 236]
    push 0
    .att_syntax prefix
    addl $game_math_dobonus_79557,%eax
    .intel_syntax noprefix
game_flow_dobonus_79562:
    mov edx, 0x1f0000
    push eax
    {store} xor ecx, ecx
    mov eax, 0xc70000
    call rotatesprite_
game_flow_dobonus_79580:
    imul edx, dword ptr [_ud + 0x632], 0xb
    movsx eax, word ptr [_ud + 0x592]
    {store} add eax, edx
    lea edx, dword ptr [eax + -1]
    {store} mov eax, edx
    shl eax, 5
    {store} add eax, edx
    {store} xor ebx, ebx
    add eax, OFFSET FLAT:_level_names
    {store} xor ecx, ecx
    push eax
    mov edx, 0xb
    mov eax, 0xa0
    call menutext_
    push OFFSET FLAT:game_text_dobonus_3876
    mov edx, 0x1b
    mov eax, 0xa0
    {store} xor ecx, ecx
    {store} xor ebx, ebx
    call menutext_
    mov ecx, 0x10
    mov ebx, OFFSET FLAT:game_text_dobonus_3748
    mov edx, 0xc0
    mov eax, 0xa0
    call gametext_
    cmp dword ptr [_totalclock], 0xb4
    {disp32} jle game_flow_dobonus_80171
    mov ebx, OFFSET FLAT:game_text_dobonus_3888
    mov edx, 0x44
    mov eax, 0xa
    {store} xor ecx, ecx
    call gametext_
    mov ebx, OFFSET FLAT:game_text_dobonus_3900
    mov edx, 0x4e
    mov eax, 0xa
    {store} xor ecx, ecx
    call gametext_
    mov ebx, OFFSET FLAT:game_text_dobonus_3912
    mov edx, 0x57
    mov eax, 0xa
    {store} xor ecx, ecx
    call gametext_
    test di, di
    jne game_flow_dobonus_79772
    mov edi, 1
game_flow_dobonus_79772:
    cmp dword ptr [_totalclock], 0xf0
    {disp32} jle game_flow_dobonus_80171
    cmp di, 1
    jne game_flow_dobonus_79806
    mov eax, 0xe
    call sound_
    {store} add edi, edi
game_flow_dobonus_79806:
    movsx ebx, word ptr [_myconnectindex]
    imul ebx, ebx, 0x552
    mov eax, dword ptr [ebx + _ps + 0x264]
    {store} mov edx, eax
    mov ecx, 0x1a
    sar edx, 0x1f
    idiv ecx
    {store} mov edx, eax
    mov ecx, 0x3c
    sar edx, 0x1f
    idiv ecx
    mov eax, dword ptr [ebx + _ps + 0x264]
    push edx
    {store} mov edx, eax
    mov ecx, 0x618
    sar edx, 0x1f
    idiv ecx
    {store} mov edx, eax
    mov ebx, 0x3c
    sar edx, 0x1f
    idiv ebx
    push edx
    push OFFSET FLAT:game_text_dobonus_3932
    push OFFSET FLAT:_tempbuf
    {store} xor ecx, ecx
    mov ebx, OFFSET FLAT:_tempbuf
    call sprintf_
    add esp, 0x10
    mov edx, 0x45
    mov eax, 0x97
    call gametext_
    imul edx, dword ptr [_ud + 0x632], 0xb
    movsx eax, word ptr [_ud + 0x592]
    {store} add eax, edx
    {disp32} lea ebx, dword ptr [eax*4]
    mov eax, dword ptr [ebx + _partime + 0xfffffffc]
    {store} mov edx, eax
    mov ecx, 0x1a
    sar edx, 0x1f
    idiv ecx
    {store} mov edx, eax
    mov ecx, 0x3c
    sar edx, 0x1f
    idiv ecx
    mov eax, dword ptr [ebx + _partime + 0xfffffffc]
    push edx
    {store} mov edx, eax
    mov ecx, 0x618
    sar edx, 0x1f
    idiv ecx
    {store} mov edx, eax
    mov ebx, 0x3c
    sar edx, 0x1f
    idiv ebx
    push edx
    push OFFSET FLAT:game_text_dobonus_3932
    push OFFSET FLAT:_tempbuf
    {store} xor ecx, ecx
    mov ebx, OFFSET FLAT:_tempbuf
    call sprintf_
    add esp, 0x10
    mov edx, 0x4e
    mov eax, 0x97
    call gametext_
    imul eax, dword ptr [_ud + 0x632], 0xb
    movsx edx, word ptr [_ud + 0x592]
    {store} add eax, edx
    {disp32} lea ebx, dword ptr [eax*4]
    mov eax, dword ptr [ebx + _designertime + 0xfffffffc]
    {store} mov edx, eax
    mov ecx, 0x1a
    sar edx, 0x1f
    idiv ecx
    {store} mov edx, eax
    mov ecx, 0x3c
    sar edx, 0x1f
    idiv ecx
    mov eax, dword ptr [ebx + _designertime + 0xfffffffc]
    push edx
    {store} mov edx, eax
    mov ecx, 0x618
    sar edx, 0x1f
    idiv ecx
    {store} mov edx, eax
    mov ebx, 0x3c
    sar edx, 0x1f
    idiv ebx
    push edx
    push OFFSET FLAT:game_text_dobonus_3932
    push OFFSET FLAT:_tempbuf
    {store} xor ecx, ecx
    mov ebx, OFFSET FLAT:_tempbuf
    call sprintf_
    add esp, 0x10
    mov edx, 0x57
    mov eax, 0x97
    call gametext_
game_flow_dobonus_80171:
    cmp dword ptr [_totalclock], 0x168
    {disp32} jle game_flow_dobonus_80477
    mov ebx, OFFSET FLAT:game_text_dobonus_3944
    mov edx, 0x67
    mov eax, 0xa
    {store} xor ecx, ecx
    call gametext_
    mov ebx, OFFSET FLAT:game_text_dobonus_3960
    mov edx, 0x70
    mov eax, 0xa
    {store} xor ecx, ecx
    call gametext_
    cmp di, 2
    jne game_flow_dobonus_80248
    mov eax, 0xf4
    inc edi
    call sound_
game_flow_dobonus_80248:
    cmp dword ptr [_totalclock], 0x1a4
    {disp32} jle game_flow_dobonus_80477
    cmp di, 3
    jne game_flow_dobonus_80281
    mov eax, 0xe
    inc edi
    call sound_
game_flow_dobonus_80281:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov al, byte ptr [eax + _ps + 0x550]
    and eax, 0xff
    push eax
    push OFFSET FLAT:game_text_dobonus_3976
    push OFFSET FLAT:_tempbuf
    mov ebx, OFFSET FLAT:_tempbuf
    mov edx, 0x66
    call sprintf_
    add esp, 0xc
    {store} xor ecx, ecx
    mov eax, 0x96
    call gametext_
    cmp dword ptr [_ud + 0x62a], 3
    jle game_flow_dobonus_80392
    push OFFSET FLAT:game_text_dobonus_3984
    push OFFSET FLAT:_tempbuf
    mov ebx, OFFSET FLAT:_tempbuf
    mov edx, 0x70
    call sprintf_
    add esp, 8
    {store} xor ecx, ecx
    mov eax, 0x96
    jmp game_flow_dobonus_80472
game_flow_dobonus_80392:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    {store} xor edx, edx
    mov dl, byte ptr [eax + _ps + 0x54f]
    mov al, byte ptr [eax + _ps + 0x550]
    and eax, 0xff
    {store} sub edx, eax
    {store} mov eax, edx
    test edx, edx
    jge game_flow_dobonus_80436
    push 0
    jmp game_flow_dobonus_80437
game_flow_dobonus_80436:
    push edx
game_flow_dobonus_80437:
    push OFFSET FLAT:game_text_dobonus_3976
    push OFFSET FLAT:_tempbuf
    call sprintf_
    add esp, 0xc
    mov ebx, OFFSET FLAT:_tempbuf
    mov edx, 0x70
    mov eax, 0x96
    {store} xor ecx, ecx
game_flow_dobonus_80472:
    call gametext_
game_flow_dobonus_80477:
    cmp dword ptr [_totalclock], 0x21c
    {disp32} jle game_flow_dobonus_80781
    mov ebx, OFFSET FLAT:game_text_dobonus_3988
    mov edx, 0x81
    mov eax, 0xa
    {store} xor ecx, ecx
    call gametext_
    mov ebx, OFFSET FLAT:game_text_dobonus_4004
    mov edx, 0x8b
    mov eax, 0xa
    {store} xor ecx, ecx
    call gametext_
    cmp di, 4
    jne game_flow_dobonus_80544
    inc edi
game_flow_dobonus_80544:
    cmp dword ptr [_totalclock], 0x258
    {disp32} jle game_flow_dobonus_80781
    cmp di, 5
    jne game_flow_dobonus_80577
    mov eax, 0xe
    inc edi
    call sound_
game_flow_dobonus_80577:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov al, byte ptr [eax + _ps + 0x54b]
    and eax, 0xff
    push eax
    push OFFSET FLAT:game_text_dobonus_3976
    push OFFSET FLAT:_tempbuf
    mov ebx, OFFSET FLAT:_tempbuf
    mov edx, 0x81
    call sprintf_
    add esp, 0xc
    {store} xor ecx, ecx
    mov eax, 0x96
    call gametext_
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    mov cl, byte ptr [eax + _ps + 0x54b]
    test cl, cl
    jbe game_flow_dobonus_80706
    {store} xor edx, edx
    {store} mov dl, cl
    imul edx, edx, 0x64
    {store} xor ebx, ebx
    mov bl, byte ptr [eax + _ps + 0x54a]
    {store} mov eax, edx
    sar edx, 0x1f
    idiv ebx
    push eax
    push OFFSET FLAT:game_text_dobonus_4020
    push OFFSET FLAT:_tempbuf
    call sprintf_
    add esp, 0xc
game_flow_dobonus_80706:
    movsx eax, word ptr [_myconnectindex]
    imul eax, eax, 0x552
    {store} xor edx, edx
    mov dl, byte ptr [eax + _ps + 0x54a]
    mov al, byte ptr [eax + _ps + 0x54b]
    and eax, 0xff
    {store} sub edx, eax
    push edx
    push OFFSET FLAT:game_text_dobonus_3976
    push OFFSET FLAT:_tempbuf
    mov ebx, OFFSET FLAT:_tempbuf
    {store} xor ecx, ecx
    call sprintf_
    add esp, 0xc
    mov edx, 0x8b
    mov eax, 0x96
    call gametext_
game_flow_dobonus_80781:
    cmp dword ptr [_totalclock], 0x2800
    jle game_flow_dobonus_80815
    cmp dword ptr [_totalclock], 0x5000
    jge game_flow_dobonus_80815
    mov dword ptr [_totalclock], 0x400
game_flow_dobonus_80815:
    call KB_KeyWaiting_
    test eax, eax
    je game_flow_dobonus_80913
    cmp dword ptr [_totalclock], 0x78
    jle game_flow_dobonus_80913
    cmp byte ptr [_KB_KeyDown + 0x58], 0
    je game_flow_dobonus_80861
    xor al, al
    mov byte ptr [_KB_KeyDown + 0x58], al
    mov eax, OFFSET FLAT:game_text_nonsharedkeys_596
    {store} xor edx, edx
    call screencapture_
game_flow_dobonus_80861:
    cmp dword ptr [_totalclock], 0x30c
    jge game_flow_dobonus_80891
    mov ebx, 0x30c
    call KB_FlushKeyboardQueue_
    mov dword ptr [_totalclock], ebx
    jmp game_flow_dobonus_80913
game_flow_dobonus_80891:
    cmp dword ptr [_totalclock], 0x3b9aca00
    jge game_flow_dobonus_80913
    mov dword ptr [_totalclock], 0x3b9aca00
game_flow_dobonus_80913:
    call nextpage_
    {disp32} jmp game_flow_dobonus_79084
game_flow_dobonus_80923:
    add esp, 0xdc
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
    {disp32} lea eax, dword ptr [eax]
    {load} mov edx, edx
cameratext_:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    sub esp, 4
    movsx edx, ax
    {disp32} lea eax, dword ptr [edx*8]
    {store} add eax, edx
    {disp32} lea eax, dword ptr [eax*8]
    {store} sub eax, edx
    mov edx, dword ptr [eax + _hittype + 0x2f]
    test edx, edx
    {disp32} jne game_flow_cameratext_81321
    mov ebx, dword ptr [_windowy2]
    push ebx
    mov ecx, dword ptr [_windowx2]
    push ecx
    mov esi, dword ptr [_windowy1]
    push esi
    mov edi, dword ptr [_windowx1]
    push edi
    push 2
    push edx
    push edx
    mov eax, 0x180000
    mov ebx, 0x10000
    push 0x9b2
    {store} xor ecx, ecx
    mov edx, 0x210000
    call rotatesprite_
    mov ebp, dword ptr [_windowy2]
    push ebp
    mov eax, dword ptr [_windowx2]
    push eax
    mov edx, dword ptr [_windowy1]
    push edx
    mov ebx, dword ptr [_windowx1]
    push ebx
    push 2
    push 0
    push 0
    {store} xor ecx, ecx
    mov eax, 0x1260000
    push 0x9b3
    mov edx, 0x220000
    mov ebx, 0x10000
    call rotatesprite_
    mov ecx, dword ptr [_windowy2]
    push ecx
    mov esi, dword ptr [_windowx2]
    push esi
    mov edi, dword ptr [_windowy1]
    push edi
    mov ebp, dword ptr [_windowx1]
    push ebp
    push 6
    push 0
    push 0
    mov ebx, 0x10000
    mov edx, 0xa30000
    push 0x9b3
    mov eax, 0x160000
    mov ecx, 0x200
    call rotatesprite_
    mov eax, dword ptr [_windowy2]
    push eax
    mov edx, dword ptr [_windowx2]
    push edx
    mov ebx, dword ptr [_windowy1]
    push ebx
    mov ecx, dword ptr [_windowx1]
    push ecx
    push 2
    push 0
    push 0
    mov eax, 0x12c0000
    mov edx, 0xa30000
    push 0x9b3
    mov ebx, 0x10000
    mov ecx, 0x200
    call rotatesprite_
    mov esi, dword ptr [_totalclock]
    test si, 0x10
    {disp32} je game_flow_cameratext_81431
    mov edi, dword ptr [_windowy2]
    push edi
    mov ebp, dword ptr [_windowx2]
    push ebp
    mov eax, dword ptr [_windowy1]
    push eax
    mov edx, dword ptr [_windowx1]
    push edx
    push 2
    push 0
    push 0
    mov ebx, 0x10000
    {store} xor ecx, ecx
    push 0x9b4
    mov eax, 0x2e0000
    mov edx, 0x200000
    call rotatesprite_
    add esp, 4
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
game_flow_cameratext_81321:
    mov al, byte ptr [_totalclock]
    add al, al
    and al, 0x30
    {store} xor edi, edi
    mov byte ptr [esp], al
    jmp game_flow_cameratext_81423
game_flow_cameratext_81337:
    {store} xor esi, esi
    jmp game_flow_cameratext_81412
game_flow_cameratext_81341:
    mov ebx, dword ptr [_windowy2]
    push ebx
    mov ecx, dword ptr [_windowx2]
    push ecx
    mov ebp, dword ptr [_windowy1]
    push ebp
    mov eax, dword ptr [_windowx1]
    push eax
    {store} xor eax, eax
    mov al, byte ptr [esp + 16]
    add eax, 2
    push eax
    {store} mov edx, esi
    push 0
    shl edx, 0x10
    mov ebx, 0x10000
    push 0
    {store} xor ecx, ecx
    {store} mov eax, edi
    push 0x15f
    shl eax, 0x10
    add esi, 0x40
    call rotatesprite_
game_flow_cameratext_81412:
    cmp esi, 0xc8
    jl game_flow_cameratext_81341
    add edi, 0x40
game_flow_cameratext_81423:
    cmp edi, 0x18a
    jl game_flow_cameratext_81337
game_flow_cameratext_81431:
    add esp, 4
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
vglass_:
    push esi
    push edi
    push ebp
    sub esp, 0x10
    {store} mov ebp, eax
    mov dword ptr [esp], edx
    mov dword ptr [esp + 8], ebx
    movsx eax, cx
    shl eax, 5
    mov ax, word ptr [eax + _wall + 0xc]
    movsx edx, ax
    mov dword ptr [esp + 12], eax
    cmp edx, -1
    {disp32} je game_flow_vglass_81676
    {disp32} lea esi, dword ptr [edx*4]
    {store} add esi, edx
    {disp32} lea esi, dword ptr [esi*8]
    mov edx, dword ptr [esi + _sector + 0x8]
    sub edx, dword ptr [esi + _sector + 0x4]
    movsx ebx, word ptr [esp + 32]
    {store} mov eax, edx
    sar edx, 0x1f
    idiv ebx
    mov esi, dword ptr [esi + _sector + 0x4]
    mov dword ptr [esp + 4], eax
    jmp game_flow_vglass_81653
game_flow_vglass_81552:
    push 5
    push -1
    push 0
    call krand_
    xor ah, ah
    and al, 0x1f
    .att_syntax prefix
    addl $game_math_vglass_81567,%eax
    .intel_syntax noprefix
    cwde
    mov edx, dword ptr [esp + 20]
    push eax
    add edx, 0x80
    call krand_
    xor ah, ah
    {store} sub edx, eax
    movsx eax, dx
    push eax
    push 0x24
    push 0x24
    push -32
    call krand_
    {store} mov edx, eax
    mov ebx, 3
    sar edx, 0x1f
    idiv ebx
    {store} and edx, esi
    add edx, 0x407
    {store} mov ecx, esi
    movsx eax, dx
    mov ebx, dword ptr [esp + 32]
    push eax
    {store} mov edx, ebp
    {store} mov eax, edi
    mov edi, dword ptr [esp + 40]
    call EGS_
    {store} add esi, edi
game_flow_vglass_81653:
    movsx edi, word ptr [esp + 12]
    {disp32} lea eax, dword ptr [edi*4]
    {store} add eax, edi
    cmp esi, dword ptr [eax*8 + _sector + 0x8]
    jl game_flow_vglass_81552
game_flow_vglass_81676:
    add esp, 0x10
    pop ebp
    pop edi
    pop esi
    ret 4
    {disp32} lea eax, dword ptr [eax]
    {disp8} lea edx, dword ptr [edx]
    {load} mov ebx, ebx
lotsofglass_:
    push ecx
    push esi
    push edi
    push ebp
    sub esp, 0x14
    mov dword ptr [esp + 16], eax
    mov dword ptr [esp + 12], 0xffffffff
    test dx, dx
    {disp32} jge game_flow_lotsofglass_81893
    movsx esi, bx
    dec esi
    test esi, esi
    jge game_flow_lotsofglass_81737
    {disp32} jmp game_flow_lotsofglass_82294
game_flow_lotsofglass_81737:
    movsx edi, word ptr [esp + 16]
    imul ecx, edi, 0x2c
    mov dx, word ptr [ecx + _sprite + 0x1c]
    call krand_
    sub edx, 0x100
    and ah, 1
    push 5
    {store} add eax, edx
    push edi
    add ah, 4
    mov ebx, 0x400
    {store} mov edx, eax
    call krand_
    and eax, 0x3ff
    {store} sub ebx, eax
    push ebx
    call krand_
    xor ah, ah
    and al, 0x3f
    .att_syntax prefix
    addl $game_math_lotsofglass_81803,%eax
    .intel_syntax noprefix
    cwde
    push eax
    movsx eax, dx
    mov ebx, 3
    push eax
    {store} mov edx, esi
    {store} mov eax, esi
    sar edx, 0x1f
    idiv ebx
    push 0x24
    push 0x24
    movsx edi, word ptr [ecx + _sprite + 0x18]
    lea eax, dword ptr [edx + 1031]
    push -32
    cwde
    mov ebx, dword ptr [ecx + _sprite + 0x4]
    push eax
    mov eax, dword ptr [ecx + _sprite + 0x8]
    mov edx, dword ptr [ecx + _sprite]
    {store} mov ecx, eax
    {store} mov eax, edi
    dec esi
    call EGS_
    test esi, esi
    {disp32} jge game_flow_lotsofglass_81737
    add esp, 0x14
    pop ebp
    pop edi
    pop esi
    pop ecx
    ret
game_flow_lotsofglass_81893:
    movsx eax, dx
    shl eax, 5
    mov ebp, dword ptr [eax + _wall]
    mov edi, dword ptr [eax + _wall + 0x4]
    movsx eax, word ptr [eax + _wall + 0x8]
    movsx ecx, bx
    shl eax, 5
    lea esi, dword ptr [ecx + 1]
    mov edx, dword ptr [eax + _wall]
    mov eax, dword ptr [eax + _wall + 0x4]
    {store} sub edx, ebp
    {store} sub eax, edi
    mov dword ptr [esp + 4], edx
    {store} mov ebx, eax
    mov dword ptr [esp + 8], eax
    {store} add ebx, ebx
    {store} sbb eax, eax
    {store} cmp eax, ebx
    adc al, 0
    {store} mov ebx, edx
    {store} sub ebp, eax
    {store} add ebx, ebx
    {store} sbb eax, eax
    {store} cmp eax, ebx
    adc al, 0
    {store} add edi, eax
    {store} mov eax, edx
    sar edx, 0x1f
    idiv esi
    mov dword ptr [esp + 4], eax
    mov eax, dword ptr [esp + 8]
    {store} mov edx, eax
    sar edx, 0x1f
    idiv esi
    mov dword ptr [esp + 8], eax
    {store} mov esi, ecx
    test esi, esi
    jg game_flow_lotsofglass_82015
    add esp, 0x14
    pop ebp
    pop edi
    pop esi
    pop ecx
    ret
game_flow_lotsofglass_82015:
    mov edx, dword ptr [esp + 4]
    mov ebx, dword ptr [esp + 8]
    {store} add ebp, edx
    {store} add edi, ebx
    lea ebx, dword ptr [esp + 12]
    {store} mov edx, edi
    {store} mov eax, ebp
    call updatesector_
    mov eax, dword ptr [esp + 12]
    test ax, ax
    {disp32} jl game_flow_lotsofglass_82285
    movsx edx, ax
    call krand_
    {disp32} lea ecx, dword ptr [edx*4]
    movsx ebx, word ptr [esp + 12]
    {store} add ecx, edx
    {store} mov edx, eax
    {disp32} lea eax, dword ptr [ebx*4]
    {store} add ebx, eax
    {disp32} lea ebx, dword ptr [ebx*8]
    mov eax, dword ptr [ebx + _sector + 0x4]
    sub eax, dword ptr [ebx + _sector + 0x8]
    {disp32} lea ecx, dword ptr [ecx*8]
    test eax, eax
    jns game_flow_lotsofglass_82118
    neg eax
game_flow_lotsofglass_82118:
    mov ecx, dword ptr [ecx + _sector + 0x8]
    {store} and eax, edx
    {store} sub ecx, eax
    cmp ecx, 0xffffe000
    jl game_flow_lotsofglass_82144
    cmp ecx, 0x2000
    jle game_flow_lotsofglass_82176
game_flow_lotsofglass_82144:
    movsx eax, word ptr [esp + 16]
    imul eax, eax, 0x2c
    mov ecx, dword ptr [eax + _sprite + 0x8]
    call krand_
    sub ecx, 0x2000
    and eax, 0x3fff
    {store} add ecx, eax
game_flow_lotsofglass_82176:
    movsx eax, word ptr [esp + 16]
    imul ebx, eax, 0x2c
    push 5
    push eax
    mov dx, word ptr [ebx + _sprite + 0x1c]
    call krand_
    and eax, 0x3ff
    neg eax
    push eax
    call krand_
    xor ah, ah
    and al, 0x3f
    .att_syntax prefix
    addl $game_math_lotsofglass_82216,%eax
    .intel_syntax noprefix
    cwde
    sub edx, 0x400
    push eax
    movsx eax, dx
    push eax
    {store} mov edx, esi
    mov eax, 3
    sar edx, 0x1f
    mov dword ptr [esp + 20], eax
    {store} mov eax, esi
    idiv dword ptr [esp + 20]
    push 0x24
    push 0x24
    add edx, 0x407
    push -32
    movsx eax, dx
    push eax
    {store} mov edx, ebp
    movsx eax, word ptr [ebx + _sprite + 0x18]
    {store} mov ebx, edi
    call EGS_
game_flow_lotsofglass_82285:
    dec esi
    test esi, esi
    {disp32} jg game_flow_lotsofglass_82015
game_flow_lotsofglass_82294:
    add esp, 0x14
    pop ebp
    pop edi
    pop esi
    pop ecx
    ret
    {load} mov eax, eax
spriteglass_:
    push ebx
    push ecx
    push esi
    push edi
    sub esp, 4
    mov dword ptr [esp], eax
    movsx esi, dx
    test esi, esi
    jg game_flow_spriteglass_82329
    add esp, 4
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
game_flow_spriteglass_82329:
    movsx edx, word ptr [esp]
    imul edi, edx, 0x2c
    call krand_
    {store} mov ebx, eax
    call krand_
    {store} mov ecx, eax
    and ecx, 0x10
    push 5
    shl ecx, 8
    mov eax, dword ptr [edi + _sprite + 0x8]
    push edx
    {store} sub eax, ecx
    mov edx, 0xfffffe00
    {store} mov ecx, eax
    call krand_
    and eax, 0x7ff
    {store} sub edx, eax
    push edx
    call krand_
    xor ah, ah
    and al, 0x3f
    .att_syntax prefix
    addl $game_math_spriteglass_82396,%eax
    .intel_syntax noprefix
    cwde
    and ebx, 0x7ff
    push eax
    movsx eax, bx
    push eax
    push 0x24
    push 0x24
    {store} mov edx, esi
    call krand_
    and al, 0xf
    sar edx, 0x1f
    movsx eax, al
    mov ebx, 3
    push eax
    {store} mov eax, esi
    idiv ebx
    lea eax, dword ptr [edx + 1031]
    mov ebx, dword ptr [edi + _sprite + 0x4]
    cwde
    mov edx, dword ptr [edi + _sprite]
    push eax
    movsx eax, word ptr [edi + _sprite + 0x18]
    call EGS_
    cwde
    imul edx, eax, 0x2c
    mov al, byte ptr [edi + _sprite + 0x11]
    dec esi
    mov byte ptr [edx + _sprite + 0x11], al
    test esi, esi
    {disp32} jg game_flow_spriteglass_82329
    add esp, 4
    pop edi
    pop esi
    pop ecx
    pop ebx
    ret
    {disp8} lea eax, dword ptr [eax]
    {load} mov ecx, ecx
ceilingglass_:
    push ecx
    push esi
    push edi
    push ebp
    sub esp, 0x20
    mov dword ptr [esp + 20], eax
    mov dword ptr [esp + 24], edx
    mov dword ptr [esp + 12], ebx
    movsx edx, dx
    {disp32} lea eax, dword ptr [edx*4]
    {store} add eax, edx
    mov dx, word ptr [eax*8 + _sector]
    mov ax, word ptr [eax*8 + _sector + 0x2]
    {store} add eax, edx
    mov dword ptr [esp + 28], edx
    mov dword ptr [esp + 16], eax
    {disp32} jmp game_flow_ceilingglass_82788
game_flow_ceilingglass_82574:
    shl ebx, 5
    mov ebp, dword ptr [ebx + _wall]
    mov edx, dword ptr [ebx + _wall + 0x20]
    movsx esi, word ptr [esp + 12]
    {store} sub edx, ebp
    lea ecx, dword ptr [esi + 1]
    {store} mov eax, edx
    sar edx, 0x1f
    idiv ecx
    mov edi, dword ptr [ebx + _wall + 0x4]
    mov edx, dword ptr [ebx + _wall + 0x24]
    {store} sub edx, edi
    mov dword ptr [esp + 8], eax
    {store} mov eax, edx
    sar edx, 0x1f
    idiv ecx
    mov dword ptr [esp + 4], eax
    {disp32} jmp game_flow_ceilingglass_82776
game_flow_ceilingglass_82640:
    call krand_
    mov edx, dword ptr [esp + 8]
    mov ebx, dword ptr [esp + 4]
    and ah, 7
    {store} add edi, ebx
    {store} mov ebx, eax
    movsx eax, word ptr [esp + 24]
    {store} add ebp, edx
    mov dword ptr [esp], eax
    {store} mov edx, eax
    {disp32} lea eax, dword ptr [eax*4]
    {store} add edx, eax
    call krand_
    and eax, 0xf
    {disp32} lea edx, dword ptr [edx*8]
    shl eax, 8
    mov ecx, dword ptr [edx + _sector + 0x4]
    push 5
    {store} add ecx, eax
    movsx eax, word ptr [esp + 24]
    push eax
    push 0
    call krand_
    xor ah, ah
    and al, 0x1f
    {store} mov edx, esi
    cwde
    sar edx, 0x1f
    push eax
    movsx eax, bx
    mov ebx, 3
    push eax
    {store} mov eax, esi
    idiv ebx
    push 0x24
    push 0x24
    add edx, 0x407
    push -32
    movsx eax, dx
    {store} mov ebx, edi
    push eax
    {store} mov edx, ebp
    mov eax, dword ptr [esp + 36]
    dec esi
    call EGS_
game_flow_ceilingglass_82776:
    test esi, esi
    {disp32} jg game_flow_ceilingglass_82640
    inc dword ptr [esp + 28]
game_flow_ceilingglass_82788:
    movsx eax, word ptr [esp + 16]
    movsx ebx, word ptr [esp + 28]
    dec eax
    {store} cmp ebx, eax
    {disp32} jl game_flow_ceilingglass_82574
    add esp, 0x20
    pop ebp
    pop edi
    pop esi
    pop ecx
    ret
    nop
lotsofcolourglass_:
    push ecx
    push esi
    push edi
    push ebp
    sub esp, 0x14
    mov dword ptr [esp + 16], eax
    {store} mov eax, ebx
    mov dword ptr [esp + 12], 0xffffffff
    test dx, dx
    {disp32} jge game_flow_lotsofcolourglass_83037
    movsx esi, ax
    dec esi
    test esi, esi
    jge game_flow_lotsofcolourglass_82859
    {disp32} jmp game_flow_lotsofcolourglass_83413
game_flow_lotsofcolourglass_82859:
    call krand_
    push 5
    movsx ecx, word ptr [esp + 20]
    and ah, 7
    push ecx
    mov ebx, 0x400
    {store} mov edx, eax
    call krand_
    and eax, 0x7ff
    {store} sub ebx, eax
    push ebx
    call krand_
    xor ah, ah
    and al, 0x3f
    .att_syntax prefix
    addl $game_math_lotsofcolourglass_82904,%eax
    .intel_syntax noprefix
    cwde
    push eax
    movsx eax, dx
    mov ebx, 3
    push eax
    {store} mov edx, esi
    {store} mov eax, esi
    sar edx, 0x1f
    idiv ebx
    imul ecx, ecx, 0x2c
    push 0x24
    push 0x24
    add edx, 0x407
    push -32
    movsx eax, dx
    push eax
    call krand_
    and eax, 0x3f00
    mov edx, dword ptr [ecx + _sprite + 0x8]
    mov ebx, dword ptr [ecx + _sprite + 0x4]
    {store} sub edx, eax
    movsx edi, word ptr [ecx + _sprite + 0x18]
    {store} mov eax, edx
    mov edx, dword ptr [ecx + _sprite]
    {store} mov ecx, eax
    {store} mov eax, edi
    call EGS_
    {store} mov edx, eax
    call krand_
    {store} mov bl, al
    movsx eax, dx
    imul eax, eax, 0x2c
    and bl, 0xf
    dec esi
    mov byte ptr [eax + _sprite + 0x11], bl
    test esi, esi
    {disp32} jge game_flow_lotsofcolourglass_82859
    add esp, 0x14
    pop ebp
    pop edi
    pop esi
    pop ecx
    ret
game_flow_lotsofcolourglass_83037:
    movsx ebx, ax
    movsx eax, dx
    shl eax, 5
    movsx ecx, word ptr [eax + _wall + 0x8]
    shl ecx, 5
    mov ebp, dword ptr [eax + _wall]
    mov edx, dword ptr [ecx + _wall]
    lea esi, dword ptr [ebx + 1]
    {store} sub edx, ebp
    mov edi, dword ptr [eax + _wall + 0x4]
    {store} mov eax, edx
    sar edx, 0x1f
    idiv esi
    mov edx, dword ptr [ecx + _wall + 0x4]
    {store} sub edx, edi
    mov dword ptr [esp], eax
    {store} mov eax, edx
    sar edx, 0x1f
    idiv esi
    mov dword ptr [esp + 8], eax
    {store} mov esi, ebx
    test esi, esi
    jg game_flow_lotsofcolourglass_83122
    add esp, 0x14
    pop ebp
    pop edi
    pop esi
    pop ecx
    ret
game_flow_lotsofcolourglass_83122:
    mov edx, dword ptr [esp]
    mov ebx, dword ptr [esp + 8]
    {store} add ebp, edx
    {store} add edi, ebx
    lea ebx, dword ptr [esp + 12]
    {store} mov edx, edi
    {store} mov eax, ebp
    call updatesector_
    movsx edx, word ptr [esp + 12]
    call krand_
    {disp32} lea ecx, dword ptr [edx*4]
    movsx ebx, word ptr [esp + 12]
    {store} add ecx, edx
    {store} mov edx, eax
    {disp32} lea eax, dword ptr [ebx*4]
    {store} add ebx, eax
    {disp32} lea ebx, dword ptr [ebx*8]
    mov eax, dword ptr [ebx + _sector + 0x4]
    sub eax, dword ptr [ebx + _sector + 0x8]
    {disp32} lea ecx, dword ptr [ecx*8]
    test eax, eax
    jns game_flow_lotsofcolourglass_83213
    neg eax
game_flow_lotsofcolourglass_83213:
    mov ecx, dword ptr [ecx + _sector + 0x8]
    {store} and eax, edx
    {store} sub ecx, eax
    cmp ecx, 0xffffe000
    jl game_flow_lotsofcolourglass_83239
    cmp ecx, 0x2000
    jle game_flow_lotsofcolourglass_83271
game_flow_lotsofcolourglass_83239:
    movsx eax, word ptr [esp + 16]
    imul eax, eax, 0x2c
    mov ecx, dword ptr [eax + _sprite + 0x8]
    call krand_
    sub ecx, 0x2000
    and eax, 0x3fff
    {store} add ecx, eax
game_flow_lotsofcolourglass_83271:
    movsx eax, word ptr [esp + 16]
    imul ebx, eax, 0x2c
    push 5
    push eax
    mov dx, word ptr [ebx + _sprite + 0x1c]
    call krand_
    and eax, 0x7ff
    neg eax
    push eax
    call krand_
    xor ah, ah
    and al, 0x3f
    .att_syntax prefix
    addl $game_math_lotsofcolourglass_83311,%eax
    .intel_syntax noprefix
    cwde
    sub edx, 0x400
    push eax
    movsx eax, dx
    push eax
    {store} mov edx, esi
    mov eax, 3
    sar edx, 0x1f
    mov dword ptr [esp + 24], eax
    {store} mov eax, esi
    idiv dword ptr [esp + 24]
    push 0x24
    push 0x24
    add edx, 0x407
    push -32
    movsx eax, dx
    push eax
    {store} mov edx, ebp
    movsx eax, word ptr [ebx + _sprite + 0x18]
    {store} mov ebx, edi
    call EGS_
    {store} mov edx, eax
    call krand_
    {store} mov bl, al
    movsx eax, dx
    imul eax, eax, 0x2c
    and bl, 7
    dec esi
    mov byte ptr [eax + _sprite + 0x11], bl
    test esi, esi
    {disp32} jg game_flow_lotsofcolourglass_83122
game_flow_lotsofcolourglass_83413:
    add esp, 0x14
    pop ebp
    pop edi
    pop esi
    pop ecx
    ret
    {disp8} lea eax, dword ptr [eax]
SetupGameButtons_:
    push edx
    {store} xor edx, edx
    {store} xor eax, eax
    call CONTROL_DefineFlag_
    mov eax, 1
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 2
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 3
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 4
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 5
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 6
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 7
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 8
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 9
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0xa
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0xb
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0xc
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0xd
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0xe
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0xf
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x10
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x11
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x12
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x13
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x14
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x15
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x16
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x17
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x18
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x19
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x1a
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x1b
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x1c
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x1d
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x1e
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x1f
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x20
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x21
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x22
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x23
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x24
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x25
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x26
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x27
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x28
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x29
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x2a
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x2b
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x2c
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x2d
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x2e
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x2f
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x30
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x31
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x32
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    mov eax, 0x33
    {store} xor edx, edx
    call CONTROL_DefineFlag_
    pop edx
    ret
GetTime_:
    mov eax, dword ptr [_totalclock]
    ret
    {disp32} lea eax, dword ptr [eax]
    {disp8} lea edx, dword ptr [edx + eiz*1]
CenterCenter_:
    push OFFSET FLAT:game_text_CenterCenter_4028
    call printf_
    add esp, 4
    ret
    {load} mov eax, eax
UpperLeft_:
    push OFFSET FLAT:game_text_UpperLeft_4068
    call printf_
    add esp, 4
    ret
    {load} mov eax, eax
LowerRight_:
    push OFFSET FLAT:game_text_LowerRight_4124
    call printf_
    add esp, 4
    ret
    {load} mov eax, eax
CenterThrottle_:
    push OFFSET FLAT:game_text_CenterThrottle_4180
    call printf_
    add esp, 4
    ret
    {load} mov eax, eax
CenterRudder_:
    push OFFSET FLAT:game_text_CenterRudder_4228
    call printf_
    add esp, 4
    ret
.section CONST,"aw",@progbits
.p2align 2
game_text_getpackets_0:
    .ascii "\nYou cannot play Duke with different versions.\000\020"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_getpackets_48:
    .ascii "INVALID GAME PACKET!!! (%ld too many bytes)\n\000V\007\000"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_getpackets_96:
    .ascii " \000\003\330"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_checksync_100:
    .ascii "Out Of Sync - Please restart game\000\240V"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_checksync_136:
    .ascii "RUN DN3DHELP.EXE for information.\000\000\000"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_checksync_172:
    .ascii "Missed Network packet!\000i"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_checksync_196:
    .ascii "RUN DN3DHELP.EXE for information.\000ME"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_invennum_232:
    .ascii "%ld\000"
game_text_displayfragbar_236:
    .ascii "%d\000!"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_coolgaugetext_240:
    .ascii "%\000 ("
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_coolgaugetext_244:
    .ascii "ON\000 "
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_coolgaugetext_248:
    .ascii "OFF\000"
game_text_coolgaugetext_252:
    .ascii "AUTO\000byt"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_caches_260:
    .ascii "Locked- %ld: Leng:%ld, Lock:%ld\000"
game_text_caches_292:
    .ascii "RTS Locked %ld:\000"
game_text_coords_308:
    .ascii "X= %ld\000D"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_coords_316:
    .ascii "Y= %ld\000E"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_coords_324:
    .ascii "Z= %ld\000f"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_coords_332:
    .ascii "A= %ld\000n"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_coords_340:
    .ascii "ZV= %ld\000"
game_text_coords_348:
    .ascii "OG= %ld\000"
game_text_coords_356:
    .ascii "TH= %ld\000"
game_text_binscreen_364:
    .ascii "duke3d.bin\000 "
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_gameexit_376:
    .ascii "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\000a"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_gameexit_400:
    .ascii "\n\000on"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_gameexit_404:
    .ascii "%s%s\000ld\000"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_gameexit_412:
    .ascii "duke3d.tmp\000 "
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_displayrest_424:
    .ascii ": \000\000"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_displayrest_428:
    .ascii "GAME PAUSED\000"
game_text_spawn_440:
    .ascii "Found lonely Sector Effector (lotag 0) at (%ld,%ld)\n\000= %"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_spawn_496:
    .ascii "Too many moving sectors at (%ld,%ld).\n\000="
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_spawn_536:
    .ascii "Subway found no zero'd sectors with locators\nat (%ld,%ld).\n\000"
game_text_nonsharedkeys_596:
    .ascii "duke0000.pcx\000 PA"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_nonsharedkeys_612:
    .ascii "PLAYING \000d l"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_nonsharedkeys_624:
    .ascii ".  USE SHIFT-F5 TO CHANGE.\000g"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_comlinehelp_652:
    .ascii "Command line help.  %s [/flags...]\n\000"
game_text_comlinehelp_688:
    .ascii "    ?, /?    This help message\000."
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_comlinehelp_720:
    .ascii "    /l##     Level  (1-11)\000e"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_comlinehelp_748:
    .ascii "    /v#      Volume (1-3)\000d,"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_comlinehelp_776:
    .ascii "    /s#      Skill  (1-4)\000YI"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_comlinehelp_804:
    .ascii "    /r       Record demo\000 CH"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_comlinehelp_832:
    .ascii "    /m       No monsters\000  %"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_comlinehelp_860:
    .ascii "    /ns      No sound\000\000\000"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_comlinehelp_884:
    .ascii "    /nm      No music\000ev"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_comlinehelp_908:
    .ascii "    /t#      Respawn, 0 = Monsters, 1 = Items, 2 = Inventory, x = All\000  "
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_comlinehelp_980:
    .ascii "    /c#      MP mode, 0 = DukeMatch(spawn), 1 = Coop, 2 = Dukematch(no spawn)\000\000\000"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_comlinehelp_1060:
    .ascii "    /q#      Fake MP (2-8 players)\000 "
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_comlinehelp_1096:
    .ascii "    /i#      Network mode (1/0) (MP only)\000en"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_comlinehelp_1140:
    .ascii "    /f#      Send fewer packets (1, 2, 4) (MP only)\000"
game_text_comlinehelp_1192:
    .ascii "    /g<file> Group <file> (default DUKE3D.GRP)\000\000"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_comlinehelp_1240:
    .ascii "    /x<file> Compile <file> (default GAME.CON)\000 "
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_comlinehelp_1288:
    .ascii "    -8250    Passed from SETUP.EXE and COMMIT.EXE\000fe"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_comlinehelp_1340:
    .ascii "    -net     Passed from SETUP.EXE and COMMIT.EXE\000 <"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_comlinehelp_1392:
    .ascii "    /j       Display version with exit\000e"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_checkcommandline_1432:
    .ascii "Could not find con file '%s'.\n\000C"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_checkcommandline_1464:
    .ascii "Using con file: '%s'\n\000ed"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_checkcommandline_1488:
    .ascii "Sound off.\000."
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_checkcommandline_1500:
    .ascii "Music off.\000M"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_checkcommandline_1512:
    .ascii "Network Mode %ld\n\000  "
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_checkcommandline_1532:
    .ascii "Dukematch (spawn).\000."
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_checkcommandline_1552:
    .ascii "Cooperative play.\000\000 "
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_checkcommandline_1572:
    .ascii "Dukematch (no spawn).\000\000\000"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_checkcommandline_1596:
    .ascii "Respawn on.\000"
game_text_checkcommandline_1608:
    .ascii "Monsters off.\000co"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_checkcommandline_1624:
    .ascii "Fake multi Mode.\000ing"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_checkcommandline_1644:
    .ascii "Demorec mode on.\000edS"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_checkcommandline_1664:
    .ascii "1.3D\000off"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_checkcommandline_1672:
    .ascii "Duke Nukem 3D (FULL VERSION) v%s\n\000 D"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_Logo_1708:
    .ascii "logo.anm\000(sp"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_Logo_1720:
    .ascii "WAITING FOR PLAYERS...\000."
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_loadtmb_1744:
    .ascii "d3dtimbr.tmb\000(no"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_compilecons_1760:
    .ascii "  * Compiling %s in %s\n\000"
game_text_Startup_1784:
    .ascii "Loading art header.\000"
game_text_Startup_1804:
    .ascii "tiles000.art\000ult"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_Startup_1820:
    .ascii "Multiplayer initialized.\000n.\000"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_Startup_1848:
    .ascii "Checking music inits.\0003D"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_Startup_1872:
    .ascii "Checking sound inits.\000Dl"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_getnames_1896:
    .ascii "Searching for other players.\000S.."
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_main_1928:
    .ascii "                                                                                \000tia"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_main_2012:
    .ascii "Duke Nukem 3D Full Version v1.3D\000DCh"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_main_2048:
    .ascii "\n\nYou don't have enough free memory to run Duke Nukem 3D.\000  "
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_main_2108:
    .ascii "The DOS MEM command should report 6,800K (or 6.8 megs)\000 "
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_main_2164:
    .ascii "'Total memory free'.\000   "
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_main_2188:
    .ascii "\nDuke Nukem 3D has been licensed exclusively to TEN (Total\000o"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_main_2248:
    .ascii "Entertainment Network) for wide-area networked (WAN) multiplayer\000\000\000\000"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_main_2316:
    .ascii "games.\n\000"
game_text_main_2324:
    .ascii "The multiplayer code within Duke Nukem 3D has been highly\000ha"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_main_2384:
    .ascii "customized to run best on TEN, where you'll experience fast and\000"
game_text_main_2448:
    .ascii "stable performance, plus other special benefits.\n\000\000\000"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_main_2500:
    .ascii "We do not authorize or recommend the use of Duke Nukem 3D with\000l"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_main_2564:
    .ascii "gaming services other than TEN.\n\000, w"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_main_2600:
    .ascii "Duke Nukem 3D is protected by United States copyright law and\000 s"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_main_2664:
    .ascii "international treaty.\n\000\000"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_main_2688:
    .ascii "For the best online multiplayer gaming experience, please call TEN\000i"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_main_2756:
    .ascii "at 800-8040-TEN, or visit TEN's Web Site at www.ten.net.\n\000 b"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_main_2816:
    .ascii "Press any key to continue.\n\000"
game_text_main_2844:
    .ascii "Could not find group file '%s'.\n\000the"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_main_2880:
    .ascii "Using: '%s'.\n\000ul"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_main_2896:
    .ascii "\n=========================================================================\000s"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_main_2972:
    .ascii "WARNING: 8250 UART detected.\000Pre"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_main_3004:
    .ascii "Music is being disabled and lower quality sound is being set.  We apologize\000"
game_text_main_3080:
    .ascii "for this, but it is necessary to maintain high frame rates while trying to\000="
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_main_3156:
    .ascii "play the game on an 8250.  We suggest upgrading to a 16550 or better UART\000\000\000"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_main_3232:
    .ascii "for maximum performance.  Press any key to continue.\000mai"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_main_3288:
    .ascii "=========================================================================\n\000s"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_main_3364:
    .ascii "Using .RTS file:%s\n\000"
game_text_main_3384:
    .ascii "Loading palette/lookups.\000\000\000\000"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_main_3412:
    .ascii "\nVESA driver for ( %ld * %ld ) not found/supported.\000"
game_text_opendemoread_3464:
    .ascii "demo"
game_literal_view_3468:
    .ascii "_.dmo\000=="
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_opendemowrite_3476:
    .ascii "demo1.dmo\000=="
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_opendemowrite_3488:
    .ascii "wb\000="
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_domovethings_3492:
    .ascii "%s is history!\000="
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_domovethings_3508:
    .ascii " \nThe 'MASTER/First player' just quit the game.  All\nplayers are returned from the game. This only happens in 5-8\nplayer mode as a different network scheme is used.\000==w"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_dobonus_3676:
    .ascii "cineov2.anm\000"
game_text_dobonus_3688:
    .ascii "cineov3.anm\000"
game_text_dobonus_3700:
    .ascii "RADLOGO.ANM\000"
game_text_dobonus_3712:
    .ascii "DUKETEAM.ANM\000st "
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_dobonus_3728:
    .ascii "MULTIPLAYER TOTALS\000\n"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_dobonus_3748:
    .ascii "PRESS ANY KEY TO CONTINUE\000\000\000"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_dobonus_3776:
    .ascii "   NAME                                           KILLS\000"
game_text_dobonus_3832:
    .ascii "%-4ld\000me"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_dobonus_3840:
    .ascii "stats %ld killed %ld %ld\n\000in"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_dobonus_3868:
    .ascii "DEATHS\000m"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_dobonus_3876:
    .ascii "COMPLETED\000NM"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_dobonus_3888:
    .ascii "Your Time:\000N"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_dobonus_3900:
    .ascii "Par time:\000PL"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_dobonus_3912:
    .ascii "3D Realms' Time:\000S A"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_dobonus_3932:
    .ascii "%02ld:%02ld\000"
game_text_dobonus_3944:
    .ascii "Enemies Killed:\000"
game_text_dobonus_3960:
    .ascii "Enemies Left:\000  "
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_dobonus_3976:
    .ascii "%-3ld\000  "
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_dobonus_3984:
    .ascii "N/A\000"
game_text_dobonus_3988:
    .ascii "Secrets Found:\000 "
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_dobonus_4004:
    .ascii "Secrets Missed:\000"
game_text_dobonus_4020:
    .ascii "%-3ld%\000t"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_CenterCenter_4028:
    .ascii "Center the joystick and press a button\n\000"
game_text_UpperLeft_4068:
    .ascii "Move joystick to upper-left corner and press a button\n\0000"
    # Existing own-C post-NUL literal capacity, not a new padding object
game_text_LowerRight_4124:
    .ascii "Move joystick to lower-right corner and press a button\n\000"
game_text_CenterThrottle_4180:
    .ascii "Center the throttle control and press a button\n\000"
game_text_CenterRudder_4228:
    .ascii "Center the rudder control and press a button\n\000"
.section CONST2,"aw",@progbits
.p2align 2
.section _DATA,"aw",@progbits
.p2align 2
_cameradist:
    .long 0
_cameraclock:
    .long 0
_eightytwofifty:
    .byte 0
_inferred_serial_alignment:
    .byte 0x2d, 0x7, 0x0 # retained existing inferred DATA residue object
_CommandSoundToggleOff:
    .long 0
_CommandMusicToggleOff:
    .long 0
_confilename:
    .ascii "GAME.CON\000"
    .zero 119 # declared C array capacity
_groupfilename:
    .ascii "DUKE3D.GRP\000"
    .zero 117 # declared C array capacity
_boardfilename:
    .ascii "\000"
    .zero 127 # declared C array capacity
_debug_on:
    .byte 0
_actor_tog:
    .byte 0
_memorycheckoveride:
    .byte 0
    .p2align 2 # natural DWORD alignment before the following frecfilep pointer
_frecfilep:
    .long -1
_todd:
    .ascii "Duke Nukem 3D(tm) Copyright 1990, 1996 Todd Replogle and 3D Realms Entertainment\000"
_inferred_copyright_alignment:
    .byte 0x68, 0xa, 0x3 # retained existing inferred DATA residue object
_TimerPtr:
    .long 0
_framecnt:
    .long 0
_inputloc:
    .short 0
_inferred_inputloc_alignment:
    .byte 0x0, 0x60 # retained existing inferred DATA residue object
_oyrepeat:
    .long -1
_cheatquotes:
    .ascii "cornholio\000"
    .zero 4 # cheat row0 declared capacity14
    .ascii "stuff\000"
    .zero 8 # cheat row1 declared capacity14
    .ascii "scotty###\000"
    .zero 4 # cheat row2 declared capacity14
    .ascii "coords\000"
    .zero 7 # cheat row3 declared capacity14
    .ascii "view\000"
    .zero 9 # cheat row4 declared capacity14
    .ascii "<RESERVED>\000"
    .zero 3 # cheat row5 declared capacity14
    .ascii "unlock\000"
    .zero 7 # cheat row6 declared capacity14
    .ascii "cashman\000"
    .zero 6 # cheat row7 declared capacity14
    .ascii "items\000"
    .zero 8 # cheat row8 declared capacity14
    .ascii "rate\000"
    .zero 9 # cheat row9 declared capacity14
    .ascii "skill#\000"
    .zero 7 # cheat row10 declared capacity14
    .ascii "beta\000"
    .zero 9 # cheat row11 declared capacity14
    .ascii "hyper\000"
    .zero 8 # cheat row12 declared capacity14
    .ascii "monsters\000"
    .zero 5 # cheat row13 declared capacity14
    .ascii "<RESERVED>\000"
    .zero 3 # cheat row14 declared capacity14
    .ascii "<RESERVED>\000"
    .zero 3 # cheat row15 declared capacity14
    .ascii "todd\000"
    .zero 9 # cheat row16 declared capacity14
    .ascii "showmap\000"
    .zero 6 # cheat row17 declared capacity14
    .ascii "kroz\000"
    .zero 9 # cheat row18 declared capacity14
    .ascii "allen\000"
    .zero 8 # cheat row19 declared capacity14
    .ascii "clip\000"
    .zero 9 # cheat row20 declared capacity14
    .ascii "weapons\000"
    .zero 6 # cheat row21 declared capacity14
    .ascii "inventory\000"
    .zero 4 # cheat row22 declared capacity14
    .ascii "keys\000"
    .zero 9 # cheat row23 declared capacity14
    .ascii "debug\000"
    .zero 8 # cheat row24 declared capacity14
_which_demo:
    .byte 1
_in_menu:
    .byte 0
.section _BSS,"aw",@nobits
.p2align 4
_frameval:
    .zero 256 # existing real C object extent
_recbuf:
    .zero 40 # existing real C object extent
_endingpal:
    .zero 768 # existing real C object extent
_titlepal:
    .zero 768 # existing real C object extent
_waterpal:
    .zero 768 # existing real C object extent
_drealms:
    .zero 768 # existing real C object extent
_slimepal:
    .zero 768 # existing real C object extent
_nonsharedtimer:
    .zero 4 # existing real C object extent
_recfilep:
    .zero 4 # existing real C object extent
_rtsptr:
    .zero 4 # existing real C object extent
_totalreccnt:
    .zero 4 # existing real C object extent
_tempwallptr:
    .zero 4 # existing real C object extent
_dmval:
    .zero 4 # existing real C object extent
# Actual typed mathematical immediates; forward definitions retain full immediate context
.equ game_math_gametext_577, 160
.equ game_math_gametext_602, 5
.equ game_math_gametext_644, 8
.equ game_math_gametextpart_899, 2789
.equ game_math_gametextpart_904, 2822
.equ game_math_gametextpart_910, 2915
.equ game_math_gametextpart_986, 2789
.equ game_math_gametextpart_991, 2822
.equ game_math_gametextpart_1001, 2915
.equ game_math_check_fta_sounds_9952, 2000
.equ game_math_check_fta_sounds_9968, 2165
.equ game_math_check_fta_sounds_9980, 2630
.equ game_math_check_fta_sounds_9992, 2710
.equ game_math_check_fta_sounds_10008, 2760
.equ game_math_check_fta_sounds_10022, 2370
.equ game_math_check_fta_sounds_10038, 2420
.equ game_math_check_fta_sounds_10052, 2120
.equ game_math_check_fta_sounds_10064, 2150
.equ game_math_check_fta_sounds_10080, 2160
.equ game_math_check_fta_sounds_10094, 2045
.equ game_math_check_fta_sounds_10108, 1744
.equ game_math_check_fta_sounds_10120, 1880
.equ game_math_check_fta_sounds_10132, 1920
.equ game_math_check_fta_sounds_10142, 1921
.equ game_math_check_fta_sounds_10152, 1960
.equ game_math_check_fta_sounds_10166, 1820
.equ game_math_check_fta_sounds_10176, 1821
.equ game_math_check_fta_sounds_10190, 1715
.equ game_math_check_fta_sounds_10198, 1725
.equ game_math_check_fta_sounds_10210, 1741
.equ game_math_check_fta_sounds_10220, 1680
.equ game_math_check_fta_sounds_10230, 1681
.equ game_math_inventory_10484, 59
.equ game_math_inventory_10492, 61
.equ game_math_inventory_10500, 1348
.equ game_math_inventory_10509, 53
.equ game_math_inventory_10517, 55
.equ game_math_inventory_10523, 57
.equ game_math_badguy_10548, 1960
.equ game_math_badguy_10564, 2165
.equ game_math_badguy_10576, 2420
.equ game_math_badguy_10588, 2710
.equ game_math_badguy_10600, 2760
.equ game_math_badguy_10613, 2630
.equ game_math_badguy_10626, 2360
.equ game_math_badguy_10642, 2370
.equ game_math_badguy_10655, 2120
.equ game_math_badguy_10667, 2150
.equ game_math_badguy_10683, 2160
.equ game_math_badguy_10696, 2000
.equ game_math_badguy_10706, 2001
.equ game_math_badguy_10716, 2045
.equ game_math_badguy_10729, 1725
.equ game_math_badguy_10741, 1820
.equ game_math_badguy_10753, 1880
.equ game_math_badguy_10769, 1920
.equ game_math_badguy_10775, 1921
.equ game_math_badguy_10784, 1741
.equ game_math_badguy_10792, 1744
.equ game_math_badguy_10801, 1550
.equ game_math_badguy_10809, 1680
.equ game_math_badguy_10815, 1682
.equ game_math_badguy_10821, 1715
.equ game_math_badguy_10830, 675
.equ game_math_badguy_10838, 1267
.equ game_math_badguypic_10867, 1960
.equ game_math_badguypic_10883, 2165
.equ game_math_badguypic_10895, 2420
.equ game_math_badguypic_10907, 2710
.equ game_math_badguypic_10919, 2760
.equ game_math_badguypic_10933, 2630
.equ game_math_badguypic_10947, 2360
.equ game_math_badguypic_10963, 2370
.equ game_math_badguypic_10977, 2120
.equ game_math_badguypic_10989, 2150
.equ game_math_badguypic_11005, 2160
.equ game_math_badguypic_11019, 2000
.equ game_math_badguypic_11029, 2001
.equ game_math_badguypic_11039, 2045
.equ game_math_badguypic_11053, 1725
.equ game_math_badguypic_11065, 1820
.equ game_math_badguypic_11077, 1880
.equ game_math_badguypic_11093, 1920
.equ game_math_badguypic_11103, 1921
.equ game_math_badguypic_11113, 1741
.equ game_math_badguypic_11121, 1744
.equ game_math_badguypic_11131, 1550
.equ game_math_badguypic_11139, 1680
.equ game_math_badguypic_11145, 1682
.equ game_math_badguypic_11151, 1715
.equ game_math_badguypic_11161, 675
.equ game_math_badguypic_11169, 1267
.equ game_math_invennum_11618, 2962
.equ game_math_invennum_11677, 2962
.equ game_math_invennum_11743, 2962
.equ game_math_invennum_11806, 2962
.equ game_math_invennum_11865, 2962
.equ game_math_invennum_11920, 2962
.equ game_math_weaponnum_12001, 3011
.equ game_math_weaponnum_12281, 2962
.equ game_math_weaponnum_12342, 2962
.equ game_math_weaponnum_12388, 2962
.equ game_math_weaponnum_12550, 2962
.equ game_math_weaponnum999_12723, 3011
.equ game_math_weaponnum999_12951, 2962
.equ game_math_weaponnum999_13008, 2962
.equ game_math_weaponnum999_13064, 2962
.equ game_math_weaponnum999_13109, 2962
.equ game_math_weaponnum999_13165, 2962
.equ game_math_weaponnum999_13202, 2962
.equ game_math_weaponnum999_13395, 2962
.equ game_math_weaponnum999_13456, 2962
.equ game_math_weaponnum999_13573, 2962
.equ game_math_weaponnum999_13618, 2962
.equ game_math_digitalnumber_15627, 2424
.equ game_math_coolgaugetext_18868, 1024
.equ game_math_coolgaugetext_18938, 1024
.equ game_math_coolgaugetext_20622, 10
.equ game_math_FTA_22710, 115
.equ game_math_FTA_22716, 116
.equ game_math_strget_23147, 104
.equ game_math_displayrest_24176, 65536
.equ game_math_displayrest_24342, 1024
.equ game_math_displayrest_24452, 1024
.equ game_math_displayrest_25394, 1
.equ game_math_displayrooms_27983, 65536
.equ game_math_displayrooms_28087, 1024
.equ game_math_displayrooms_28199, 1024
.equ game_math_displayrooms_28602, 512
.equ game_math_displayrooms_28895, 1024
.equ game_math_displayrooms_29641, 100
.equ game_math_displayrooms_29671, 1024
.equ game_math_displayrooms_29684, 1024
.equ game_math_displayrooms_29761, 1024
.equ game_math_displayrooms_29799, 299
.equ game_math_wallswitchcheck_31211, 712
.equ game_math_wallswitchcheck_31217, 713
.equ game_math_wallswitchcheck_31227, 1122
.equ game_math_wallswitchcheck_31233, 1123
.equ game_math_wallswitchcheck_31243, 1142
.equ game_math_wallswitchcheck_31253, 1143
.equ game_math_wallswitchcheck_31263, 1155
.equ game_math_wallswitchcheck_31273, 1156
.equ game_math_wallswitchcheck_31282, 860
.equ game_math_wallswitchcheck_31288, 865
.equ game_math_wallswitchcheck_31294, 1111
.equ game_math_wallswitchcheck_31300, 1112
.equ game_math_wallswitchcheck_31309, 132
.equ game_math_wallswitchcheck_31315, 141
.equ game_math_wallswitchcheck_31321, 146
.equ game_math_wallswitchcheck_31327, 149
.equ game_math_wallswitchcheck_31333, 162
.equ game_math_wallswitchcheck_31339, 170
.equ game_math_wallswitchcheck_31348, 130
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
.equ game_math_spawn_39745, 2
.equ game_math_spawn_39751, 1
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
.equ game_math_animatesprites_48190, 3200
.equ game_math_animatesprites_48210, 4
.equ game_math_animatesprites_48376, 1298
.equ game_math_animatesprites_48392, 1334
.equ game_math_animatesprites_48402, 1336
.equ game_math_animatesprites_48412, 1395
.equ game_math_animatesprites_48424, 2307
.equ game_math_animatesprites_48430, 2308
.equ game_math_animatesprites_48440, 3450
.equ game_math_animatesprites_48455, 2300
.equ game_math_animatesprites_48465, 2305
.equ game_math_animatesprites_48480, 1347
.equ game_math_animatesprites_48496, 1358
.equ game_math_animatesprites_48506, 1359
.equ game_math_animatesprites_48521, 1317
.equ game_math_animatesprites_48533, 1321
.equ game_math_animatesprites_48549, 1323
.equ game_math_animatesprites_48559, 1325
.equ game_math_animatesprites_48574, 1306
.equ game_math_animatesprites_48590, 1312
.equ game_math_animatesprites_48605, 768
.equ game_math_animatesprites_48611, 769
.equ game_math_animatesprites_48621, 963
.equ game_math_animatesprites_48627, 965
.equ game_math_animatesprites_48637, 1289
.equ game_math_animatesprites_48649, 1294
.equ game_math_animatesprites_48664, 1280
.equ game_math_animatesprites_48679, 774
.equ game_math_animatesprites_48695, 779
.equ game_math_animatesprites_48710, 577
.equ game_math_animatesprites_48722, 603
.equ game_math_animatesprites_48734, 753
.equ game_math_animatesprites_48742, 1
.equ game_math_animatesprites_48750, 568
.equ game_math_animatesprites_49256, 2201
.equ game_math_animatesprites_49272, 2310
.equ game_math_animatesprites_49288, 2412
.equ game_math_animatesprites_49300, 2566
.equ game_math_animatesprites_49312, 2590
.equ game_math_animatesprites_49328, 2605
.equ game_math_animatesprites_49343, 2416
.equ game_math_animatesprites_49358, 2400
.equ game_math_animatesprites_49370, 2404
.equ game_math_animatesprites_49386, 2408
.equ game_math_animatesprites_49401, 2390
.equ game_math_animatesprites_49411, 2397
.equ game_math_animatesprites_49481, 48
.equ game_math_animatesprites_49522, 2255
.equ game_math_animatesprites_49534, 2265
.equ game_math_animatesprites_49546, 2270
.equ game_math_animatesprites_49562, 2286
.equ game_math_animatesprites_49577, 2260
.equ game_math_animatesprites_49592, 2209
.equ game_math_animatesprites_49604, 2245
.equ game_math_animatesprites_49620, 2250
.equ game_math_animatesprites_49635, 2205
.equ game_math_animatesprites_49650, 1405
.equ game_math_animatesprites_49666, 1646
.equ game_math_animatesprites_49678, 1772
.equ game_math_animatesprites_49690, 1776
.equ game_math_animatesprites_49706, 1960
.equ game_math_animatesprites_49721, 1768
.equ game_math_animatesprites_49736, 1520
.equ game_math_animatesprites_49748, 1528
.equ game_math_animatesprites_49764, 1536
.equ game_math_animatesprites_49779, 1518
.equ game_math_animatesprites_49794, 550
.equ game_math_animatesprites_49806, 672
.equ game_math_animatesprites_49812, 674
.equ game_math_animatesprites_49822, 1226
.equ game_math_animatesprites_49834, 1233
.equ game_math_animatesprites_49844, 1234
.equ game_math_animatesprites_49855, 661
.equ game_math_animatesprites_49870, 100
.equ game_math_animatesprites_49882, 499
.equ game_math_animatesprites_49898, 502
.equ game_math_animatesprites_49913, 46
.equ game_math_animatesprites_50087, 512
.equ game_math_animatesprites_50318, 512
.equ game_math_animatesprites_50537, 1646
.equ game_math_animatesprites_50606, 6
.equ game_math_animatesprites_50718, 3200
.equ game_math_animatesprites_50999, 10240
.equ game_math_animatesprites_51021, 1024
.equ game_math_animatesprites_51584, 3200
.equ game_math_animatesprites_51604, 4
.equ game_math_animatesprites_51712, 16384
.equ game_math_animatesprites_51900, 1
.equ game_math_animatesprites_52135, 2
.equ game_math_animatesprites_52141, 1
.equ game_math_animatesprites_52384, 3200
.equ game_math_animatesprites_52418, 3200
.equ game_math_animatesprites_52546, 4
.equ game_math_animatesprites_52633, 6
.equ game_math_animatesprites_52663, 3200
.equ game_math_animatesprites_53014, 2
.equ game_math_animatesprites_53024, 4
.equ game_math_animatesprites_53030, 5
.equ game_math_animatesprites_53040, 1880
.equ game_math_animatesprites_53046, 1920
.equ game_math_animatesprites_53086, 2048
.equ game_math_animatesprites_53826, 3200
.equ game_math_animatesprites_53846, 4
.equ game_math_animatesprites_54351, 3200
.equ game_math_animatesprites_54371, 4
.equ game_math_cheats_54711, 97
.equ game_math_cheats_54717, 122
.equ game_math_cheats_55541, 112
.equ game_math_nonsharedkeys_58922, 83
.equ game_math_nonsharedkeys_60955, 360
.equ game_math_nonsharedkeys_61175, 109
.equ game_math_nonsharedkeys_62032, 85
.equ game_math_main_65878, 2800000
.equ game_math_playback_68756, 2520
.equ game_math_playback_69115, 65536
.equ game_math_playback_69318, 240
.equ game_math_fakedomovethings_70489, 13824
.equ game_math_fakedomovethings_70573, 512
.equ game_math_fakedomovethings_70728, 1024
.equ game_math_fakedomovethings_70813, 49152
.equ game_math_fakedomovethings_70904, 49152
.equ game_math_fakedomovethings_70940, 33
.equ game_math_fakedomovethings_71023, 21504
.equ game_math_fakedomovethings_71186, 4864
.equ game_math_fakedomovethings_71505, 348
.equ game_math_fakedomovethings_71515, 1536
.equ game_math_fakedomovethings_71677, 1024
.equ game_math_fakedomovethings_71911, 4608
.equ game_math_fakedomovethings_72130, 256
.equ game_math_fakedomovethings_72140, 6144
.equ game_math_fakedomovethings_72252, 256
.equ game_math_fakedomovethings_72458, 14336
.equ game_math_fakedomovethings_72578, 1920
.equ game_math_fakedomovethings_72677, 1024
.equ game_math_fakedomovethings_72783, 1
.equ game_math_fakedomovethings_72789, 4
.equ game_math_fakedomovethings_73199, 2048
.equ game_math_fakedomovethings_73216, 2048
.equ game_math_fakedomovethings_73525, 6
.equ game_math_dobonus_77239, 200
.equ game_math_dobonus_78913, 3240
.equ game_math_dobonus_79150, 3240
.equ game_math_dobonus_79346, 3243
.equ game_math_dobonus_79396, 3244
.equ game_math_dobonus_79510, 3241
.equ game_math_dobonus_79557, 3242
.equ game_math_vglass_81567, 16
.equ game_math_lotsofglass_81803, 32
.equ game_math_lotsofglass_82216, 32
.equ game_math_spriteglass_82396, 32
.equ game_math_lotsofcolourglass_82904, 32
.equ game_math_lotsofcolourglass_83311, 32
