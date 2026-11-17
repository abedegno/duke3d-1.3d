# Readable reconstruction of MACT debug.c behavior; not historical source.
# See debug_counterpart.c for the complete GPL notice and ordinary C aid.
# Default Watcom register ABI except CDECL varargs/printf/Error.
.file "debug.S"
.intel_syntax noprefix
.equ MAXDEBUGSTRING,400
.equ debug_normal,5
.equ debug_max,20
.equ filetype_text,1
.extern printf_
.extern SafeOpenWrite_
.extern SafeWrite_
.extern SafeClose_
.extern memset_
.extern vsprintf_
.extern Error_
.section _TEXT,"xr0"
.globl DBG_ScreenPrint_
DBG_ScreenPrint_:
 push eax
 push OFFSET FLAT:screen_format
 call printf_
 add esp,8
 ret
 nop
.globl DBG_FileStartup_
DBG_FileStartup_:
 push ebx
 push edx
 cmp DWORD PTR [_DBG_FileOutputStarted],0
 jne file_start_done
 mov edx,filetype_text
 mov eax,OFFSET FLAT:debug_filename
 mov ebx,1
 call SafeOpenWrite_
 mov DWORD PTR [_DBG_FileOutputHandle],eax
 mov DWORD PTR [_DBG_FileOutputStarted],ebx
file_start_done:
 pop edx
 pop ebx
 ret
 {disp8} lea eax,[eax]
.globl DBG_FilePrint_
DBG_FilePrint_:
 push ebx
 push ecx
 push edx
 push edi
 mov edx,eax
 mov edi,eax
 {store} sub ecx,ecx
 dec ecx
 xor eax,eax
 repne scasb
 not ecx
 dec ecx
 mov eax,DWORD PTR [_DBG_FileOutputHandle]
 mov ebx,ecx
 call SafeWrite_
 pop edi
 pop edx
 pop ecx
 pop ebx
 ret
 nop
.globl DBG_FileShutdown_
DBG_FileShutdown_:
 push ebx
 cmp DWORD PTR [_DBG_FileOutputStarted],0
 je file_shutdown_done
 mov eax,DWORD PTR [_DBG_FileOutputHandle]
 xor ebx,ebx
 call SafeClose_
 mov DWORD PTR [_DBG_FileOutputStarted],ebx
file_shutdown_done:
 pop ebx
 ret
 {load} mov eax,eax
.globl DBG_CloseDebugOutput_
DBG_CloseDebugOutput_:
 push edx
 mov edx,DWORD PTR [_DBG_OutMode]
 lea eax,[edx*4]
 {store} sub eax,edx
 shl eax,2
 cmp DWORD PTR [_DBG_Out+eax+8],0
 je close_done
 call DWORD PTR [_DBG_Out+eax+8]
close_done:
 pop edx
 ret
.globl DBG_StartDebugOutput_
DBG_StartDebugOutput_:
 push edx
 mov edx,DWORD PTR [_DBG_OutMode]
 lea eax,[edx*4]
 {store} sub eax,edx
 shl eax,2
 cmp DWORD PTR [_DBG_Out+eax],0
 je start_done
 call DWORD PTR [_DBG_Out+eax]
start_done:
 pop edx
 ret
.globl DBG_SetDebugLevel_
DBG_SetDebugLevel_:
 mov DWORD PTR [_DBG_DebugLevel],eax
 ret
 {load} mov eax,eax
.globl DBG_GetDebugLevel_
DBG_GetDebugLevel_:
 mov eax,DWORD PTR [_DBG_DebugLevel]
 ret
 {load} mov eax,eax
.globl DBG_EnableDebugLevel_
DBG_EnableDebugLevel_:
 mov DWORD PTR [_DBG_DebugMask+eax*4],1
 ret
.globl DBG_DisableDebugLevel_
DBG_DisableDebugLevel_:
 push edx
 xor edx,edx
 mov DWORD PTR [_DBG_DebugMask+eax*4],edx
 pop edx
 ret
.globl DBG_DisableAllDebugLevels_
DBG_DisableAllDebugLevels_:
 push ebx
 push edx
 mov ebx,(debug_max+1)*4
 mov eax,OFFSET FLAT:_DBG_DebugMask
 xor edx,edx
 call memset_
 pop edx
 pop ebx
 ret
 {load} mov eax,eax
.globl DBG_SetDebugMode_
DBG_SetDebugMode_:
 mov DWORD PTR [_DBG_DebugMode],eax
 ret
 {load} mov eax,eax
.globl DBG_GetDebugMode_
DBG_GetDebugMode_:
 mov eax,DWORD PTR [_DBG_DebugMode]
 ret
 {load} mov eax,eax
.globl DBG_SetDebugOutputMode_
DBG_SetDebugOutputMode_:
 push ebx
 push edx
 mov edx,eax
 mov ebx,DWORD PTR [_DBG_OutMode]
 lea eax,[ebx*4]
 {store} sub eax,ebx
 shl eax,2
 cmp DWORD PTR [_DBG_Out+eax+8],0
 je change_output_store
 call DWORD PTR [_DBG_Out+eax+8]
change_output_store:
 mov DWORD PTR [_DBG_OutMode],edx
 lea eax,[edx*4]
 {store} sub eax,edx
 shl eax,2
 cmp DWORD PTR [_DBG_Out+eax],0
 je change_output_done
 call DWORD PTR [_DBG_Out+eax]
change_output_done:
 pop edx
 pop ebx
 ret
 {disp8} lea eax,[eax]
.globl DBG_GetDebugOutputMode_
DBG_GetDebugOutputMode_:
 mov eax,DWORD PTR [_DBG_OutMode]
 ret
 {load} mov eax,eax
# Preserve the actual materialized suppression predicate, late length test,
# and legacy empty-string underread. No behavior repair is made here.
.globl DBG_DebugString_
DBG_DebugString_:
 push ebx
 push ecx
 push edx
 push esi
 push edi
 sub esp,MAXDEBUGSTRING+4
 mov edx,DWORD PTR [esp+MAXDEBUGSTRING+28]
 cmp DWORD PTR [_DBG_DebugMode],0
 setne al
 and eax,255
 je debug_mask
 cmp edx,DWORD PTR [_DBG_DebugLevel]
 setle al
 and eax,255
 jmp debug_test
debug_mask:
 mov eax,DWORD PTR [_DBG_DebugMask+edx*4]
debug_test:
 test eax,eax
 jne debug_done
 lea eax,[esp+MAXDEBUGSTRING+36]
 lea ebx,[esp+MAXDEBUGSTRING]
 mov edx,DWORD PTR [esp+MAXDEBUGSTRING+32]
 mov edi,esp
 mov DWORD PTR [esp+MAXDEBUGSTRING],eax
 mov eax,esp
 xor esi,esi
 call vsprintf_
 mov DWORD PTR [esp+MAXDEBUGSTRING],esi
 {store} sub ecx,ecx
 dec ecx
 xor eax,eax
 repne scasb
 not ecx
 dec ecx
 mov edx,ecx
 cmp ecx,MAXDEBUGSTRING
 jl debug_last
 mov eax,esp
 push eax
 push OFFSET FLAT:debug_overflow
 call Error_
 add esp,8
debug_last:
 cmp BYTE PTR [esp+edx-1],10
 je debug_output
 cmp edx,MAXDEBUGSTRING-1
 jne debug_append
 mov eax,esp
 push eax
 push OFFSET FLAT:debug_append_overflow
 call Error_
 add esp,8
debug_append:
 mov BYTE PTR [esp+edx],10
 xor bh,bh
 mov BYTE PTR [esp+edx+1],bh
debug_output:
 mov edx,DWORD PTR [_DBG_OutMode]
 lea eax,[edx*4]
 {store} sub eax,edx
 shl eax,2
 cmp DWORD PTR [_DBG_Out+eax+4],0
 je debug_done
 mov edx,eax
 mov eax,esp
 call DWORD PTR [_DBG_Out+edx+4]
debug_done:
 add esp,MAXDEBUGSTRING+4
 pop edi
 pop esi
 pop edx
 pop ecx
 pop ebx
 ret
 {load} mov eax,eax
.globl DBG_DbgString_
DBG_DbgString_:
 push ebx
 push ecx
 push edx
 push esi
 push edi
 sub esp,MAXDEBUGSTRING+4
 mov ebx,DWORD PTR [_DBG_DebugMode]
 mov eax,debug_normal
 test ebx,ebx
 setne dl
 and edx,255
 je dbg_mask
 cmp eax,DWORD PTR [_DBG_DebugLevel]
 setle al
 and eax,255
 jmp dbg_test
dbg_mask:
 mov eax,DWORD PTR [_DBG_DebugMask+eax*4]
dbg_test:
 test eax,eax
 jne dbg_done
 lea eax,[esp+MAXDEBUGSTRING+32]
 lea ebx,[esp+MAXDEBUGSTRING]
 mov edx,DWORD PTR [esp+MAXDEBUGSTRING+28]
 mov edi,esp
 mov DWORD PTR [esp+MAXDEBUGSTRING],eax
 mov eax,esp
 xor esi,esi
 call vsprintf_
 mov DWORD PTR [esp+MAXDEBUGSTRING],esi
 {store} sub ecx,ecx
 dec ecx
 xor eax,eax
 repne scasb
 not ecx
 dec ecx
 mov edx,ecx
 cmp ecx,MAXDEBUGSTRING
 jl dbg_last
 mov eax,esp
 push eax
 push OFFSET FLAT:dbg_overflow
 call Error_
 add esp,8
dbg_last:
 cmp BYTE PTR [esp+edx-1],10
 je dbg_output
 cmp edx,MAXDEBUGSTRING-1
 jne dbg_append
 mov eax,esp
 push eax
 push OFFSET FLAT:dbg_append_overflow
 call Error_
 add esp,8
dbg_append:
 mov BYTE PTR [esp+edx],10
 xor bh,bh
 mov BYTE PTR [esp+edx+1],bh
dbg_output:
 mov edx,DWORD PTR [_DBG_OutMode]
 lea eax,[edx*4]
 {store} sub eax,edx
 shl eax,2
 cmp DWORD PTR [_DBG_Out+eax+4],0
 je dbg_done
 mov edx,eax
 mov eax,esp
 call DWORD PTR [_DBG_Out+edx+4]
dbg_done:
 add esp,MAXDEBUGSTRING+4
 pop edi
 pop esi
 pop edx
 pop ecx
 pop ebx
 ret
 {load} mov eax,eax
.globl DBG_Shutdown_
DBG_Shutdown_:
 push ebx
 push ecx
 push edx
 cmp DWORD PTR [_DBG_Started],0
 je shutdown_done
 mov edx,DWORD PTR [_DBG_OutMode]
 lea eax,[edx*4]
 {store} sub eax,edx
 shl eax,2
 xor ebx,ebx
 mov ecx,DWORD PTR [_DBG_Out+eax+8]
 mov DWORD PTR [_DBG_Started],ebx
 test ecx,ecx
 je shutdown_done
 call DWORD PTR [_DBG_Out+eax+8]
shutdown_done:
 pop edx
 pop ecx
 pop ebx
 ret
 {load} mov eax,eax
.globl DBG_Startup_
DBG_Startup_:
 push ecx
 push esi
 push ebp
 mov esi,eax
 mov ecx,ebx
 mov ebx,DWORD PTR [_DBG_Started]
 test ebx,ebx
 je startup_configure
 je startup_configure
 xor ebp,ebp
 mov DWORD PTR [_DBG_Started],ebp
 call DBG_CloseDebugOutput_
startup_configure:
 mov eax,1
 mov ebx,(debug_max+1)*4
 mov DWORD PTR [_DBG_DebugLevel],edx
 mov DWORD PTR [_DBG_Started],eax
 xor edx,edx
 mov eax,OFFSET FLAT:_DBG_DebugMask
 call memset_
 mov DWORD PTR [_DBG_DebugMode],esi
 call DBG_CloseDebugOutput_
 mov DWORD PTR [_DBG_OutMode],ecx
 call DBG_StartDebugOutput_
 pop ebp
 pop esi
 pop ecx
 ret
 nop
.globl DBG_RegisterOutputFunction_
DBG_RegisterOutputFunction_:
 push esi
 mov esi,edx
 mov edx,eax
 shl eax,2
 {store} sub eax,edx
 mov DWORD PTR [_DBG_Out+eax*4],esi
 mov DWORD PTR [_DBG_Out+eax*4+4],ebx
 mov DWORD PTR [_DBG_Out+eax*4+8],ecx
 pop esi
 ret
.section CONST,"dw0"
screen_format:
 .asciz "%s"
 .balign 4,0
debug_filename:
 .asciz "debug.txt"
 .balign 4,0
debug_overflow:
 .ascii "Debug: debug string "
 .asciz "length exceeded %s\n"
debug_append_overflow:
 .ascii "Debug: debug string "
 .asciz "length exceeded %s\n"
dbg_overflow:
 .ascii "Debug: debug string "
 .asciz "length exceeded %s\n"
dbg_append_overflow:
 .ascii "Debug: debug string "
 .asciz "length exceeded %s\n"
.section CONST2,"dw0"
.section _DATA,"dw0"
_DBG_DebugLevel:
 .long debug_normal
_DBG_DebugMode:
 .long 0
_DBG_DebugMask:
 .long 0,0,0
 .long 0,0,0
 .long 0,0,0
 .long 0,0,0
 .long 0,0,0
 .long 0,0,0
 .long 0,0,0
_DBG_Started:
 .long 0
_DBG_OutMode:
 .long 0
_DBG_FileOutputStarted:
 .long 0
_DBG_Out:
 .long 0,DBG_ScreenPrint_,0
 .long DBG_FileStartup_,DBG_FilePrint_,DBG_FileShutdown_
 .long 0,0,0
 .long 0,0,0
.section _BSS,"b0"
_DBG_FileOutputHandle:
 .space 4
