# Reconstructed MACT Pentium calibration, cycle and elapsed-time API.
# Original notices and readable ordinary C counterpart are retained alongside.
.intel_syntax noprefix
.arch .387
.file "PENTTIME.S"
.section _TEXT,"ax",@progbits
.p2align 4
.section CONST,"aw",@progbits
.p2align 2
calibration_message: .asciz "PENT: machine is operating at %f\n"
calibration_average: .double 0.1
calibration_ticks_per_second: .double 10.0
cycles_to_megahertz: .double 0.000001
calibration_word_scale: .double 4294967296.0
cycle_word_scale: .double 4294967296.0
time_word_scale: .double 4294967296.0
.section CONST2,"aw",@progbits
.p2align 2
.section _DATA,"aw",@progbits
.p2align 2
.section _BSS,"aw",@nobits
.p2align 4
.local _PENT_megahertz,_PENT_timer,_PENT_overhead
_PENT_megahertz: .zero 8
_PENT_timer: .zero 8
_PENT_overhead: .zero 8
.section _TEXT
.globl PENT_Init_,PENT_GetTime_,PENT_StartTimer_,PENT_StopTimer_,PENT_Cycles_,PENT_Time_
.extern PENT_Start_,PENT_Stop_,TIME_AddTimer_,ServiceEvents_,printf_,TIME_RemoveTimer_
.extern _PENT_timeh,_PENT_timel,_fltused_,__init_387_emulator,__8087
# Preserve genuine unused compiler FPU imports as undefined global symbols.
.globl _fltused_,__init_387_emulator,__8087
CALIBRATION_FRAME = 108
SAMPLE_BYTES = 80
CALIBRATION_TOTAL = 96
CALIBRATION_TICKS = 104
CONVERSION_INTEGER = 80
CONVERSION_DOUBLE = 88
PENT_Init_:
 push ebx
 push ecx
 push edx
 push esi
 sub esp,CALIBRATION_FRAME
 xor edx,edx
 mov dword ptr [esp+CALIBRATION_TOTAL],edx
 mov dword ptr [esp+CALIBRATION_TOTAL+4],edx
 mov dword ptr [esp+CALIBRATION_TICKS],edx
 call PENT_Start_
 call PENT_Stop_
 mov eax,OFFSET FLAT:_PENT_timer
 lea edx,[esp+CALIBRATION_TICKS]
 call PENT_GetTime_
 mov eax,100
 call TIME_AddTimer_
 mov ebx,eax
 xor edx,edx
 mov ecx,10
calibration_sample:
 xor esi,esi
 mov dword ptr [esp+CALIBRATION_TICKS],esi
 call PENT_Start_
 cmp ecx,dword ptr [esp+CALIBRATION_TICKS]
 je calibration_sample_done
calibration_wait:
 call ServiceEvents_
 cmp ecx,dword ptr [esp+CALIBRATION_TICKS]
 jne calibration_wait
calibration_sample_done:
 call PENT_Stop_
 mov eax,OFFSET FLAT:_PENT_timer
 add edx,8
 call PENT_GetTime_
 call PENT_Cycles_
 fstp qword ptr [esp+edx-8]
 cmp edx,SAMPLE_BYTES
 jne calibration_sample
 xor eax,eax
 fld qword ptr [esp+CALIBRATION_TOTAL]
calibration_sum:
 add eax,8
 fld st(0)
 fadd qword ptr [esp+eax-8]
 fstp st(1)
 cmp eax,SAMPLE_BYTES
 jne calibration_sum
 fst qword ptr [esp+CALIBRATION_TOTAL]
 fmul qword ptr [calibration_average]
 fmul qword ptr [calibration_ticks_per_second]
 fst qword ptr [esp+CALIBRATION_TOTAL]
 mov eax,dword ptr [esp+CALIBRATION_TOTAL]
 fmul qword ptr [cycles_to_megahertz]
 mov dword ptr [_PENT_megahertz],eax
 mov eax,dword ptr [esp+CALIBRATION_TOTAL+4]
 sub esp,8
 fstp qword ptr [esp]
 push OFFSET FLAT:calibration_message
 mov dword ptr [_PENT_megahertz+4],eax
 call printf_
 add esp,12
 mov eax,ebx
 call TIME_RemoveTimer_
 call PENT_Start_
 call PENT_Stop_
 mov eax,OFFSET FLAT:_PENT_timer
 call PENT_GetTime_
 mov eax,dword ptr [_PENT_timer]
 mov dword ptr [esp+CONVERSION_INTEGER],eax
 xor eax,eax
 mov dword ptr [esp+CONVERSION_INTEGER+4],eax
 fild qword ptr [esp+CONVERSION_INTEGER]
 fmul qword ptr [calibration_word_scale]
 xor edx,edx
 mov eax,dword ptr [_PENT_timer+4]
 mov dword ptr [esp+CONVERSION_INTEGER+4],edx
 mov dword ptr [esp+CONVERSION_INTEGER],eax
 fstp qword ptr [esp+CONVERSION_DOUBLE]
 fild qword ptr [esp+CONVERSION_INTEGER]
 fadd qword ptr [esp+CONVERSION_DOUBLE]
 fsub qword ptr [_PENT_overhead]
 fstp qword ptr [esp+CONVERSION_DOUBLE]
 mov eax,dword ptr [esp+CONVERSION_DOUBLE]
 mov dword ptr [_PENT_overhead],eax
 mov eax,dword ptr [esp+CONVERSION_DOUBLE+4]
 mov dword ptr [_PENT_overhead+4],eax
 add esp,CALIBRATION_FRAME
 pop esi
 pop edx
 pop ecx
 pop ebx
 ret
PENT_GetTime_:
 push edx
 mov edx,dword ptr [_PENT_timeh]
 mov dword ptr [eax],edx
 mov edx,dword ptr [_PENT_timel]
 mov dword ptr [eax+4],edx
 pop edx
 ret
PENT_StartTimer_:
 jmp PENT_Start_
 {disp8} lea eax,[eax]
PENT_StopTimer_:
 call PENT_Stop_
 mov eax,dword ptr [_PENT_timeh]
 mov dword ptr [_PENT_timer],eax
 mov eax,dword ptr [_PENT_timel]
 mov dword ptr [_PENT_timer+4],eax
 ret
 {load} mov eax,eax
# Convert both unsigned halves using genuine zero-extended integer temporaries.
.macro CYCLE_VALUE scale
 push eax
 push edx
 sub esp,16
 mov eax,dword ptr [_PENT_timer]
 xor edx,edx
 mov dword ptr [esp+8],eax
 mov dword ptr [esp+12],edx
 fild qword ptr [esp+8]
 fld st(0)
 fmul qword ptr [\scale]
 mov eax,dword ptr [_PENT_timer+4]
 mov dword ptr [esp+12],edx
 mov dword ptr [esp+8],eax
 fstp st(1)
 fild qword ptr [esp+8]
 faddp st(1),st(0)
 fld st(0)
 fsub qword ptr [_PENT_overhead]
 fstp st(1)
.endm
.macro CYCLE_RETURN
 add esp,16
 pop edx
 pop eax
 ret
.endm
PENT_Cycles_:
 CYCLE_VALUE cycle_word_scale
 CYCLE_RETURN
 {disp8} lea eax,[eax]
PENT_Time_:
 CYCLE_VALUE time_word_scale
 fdiv qword ptr [_PENT_megahertz]
 CYCLE_RETURN
