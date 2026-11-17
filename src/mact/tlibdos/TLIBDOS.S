# Reconstructed MACT DOS-clock implementation; readable C and primary notices retained.
# Time values are milliseconds since midnight; midnight wrap is not corrected.
.intel_syntax noprefix
.file "TLIBDOS.S"
.section _TEXT,"ax",@progbits
.p2align 4
.section CONST,"aw",@progbits
.p2align 2
.section CONST2,"aw",@progbits
.p2align 2
.section _DATA,"aw",@progbits
.p2align 2
.section _BSS,"aw",@nobits
.p2align 4
.globl _stoptics,_starttics
_stoptics: .zero 4
_starttics: .zero 4
.section _TEXT
.globl I_Time_,TIMELIB_StartTiming_,TIMELIB_StopTiming_
.extern _dos_gettime_
HOUR_MS = 3600000
TIME_BYTES = 4
# DOS time is four bytes: hour, minute, second, hundredths.
.macro CLOCK_VALUE
 push ebx
 push edx
 sub esp,TIME_BYTES
 mov eax,esp
 call _dos_gettime_
 xor eax,eax
 mov al,byte ptr [esp]
 imul edx,eax,HOUR_MS
 xor ebx,ebx
 mov bl,byte ptr [esp+1]
 # minute * 60000 = ((minute*31)*4+minute)*32*15
 mov eax,ebx
 shl eax,5
 sub eax,ebx
 shl eax,2
 add eax,ebx
 shl eax,5
 mov ebx,eax
 shl eax,4
 sub eax,ebx
 xor ebx,ebx
 mov bl,byte ptr [esp+2]
 add edx,eax
 # second * 1000 = ((second*31)*4+second)*8
 mov eax,ebx
 shl eax,5
 sub eax,ebx
 shl eax,2
 add eax,ebx
 xor ebx,ebx
 shl eax,3
 mov bl,byte ptr [esp+3]
 add edx,eax
 # hundredths * 10; keep the original arithmetic schedule.
 lea eax,[ebx*4]
 add eax,ebx
 add eax,eax
.endm
.macro RETURN_CLOCK
 add esp,TIME_BYTES
 pop edx
 pop ebx
 ret
.endm
I_Time_:
 CLOCK_VALUE
 add eax,edx
 RETURN_CLOCK
 # Native compiler's three-byte inert instruction aligns the next entry.
 {disp8} lea eax,[eax]
TIMELIB_StartTiming_:
 CLOCK_VALUE
 add edx,eax
 mov dword ptr [_starttics],edx
 RETURN_CLOCK
 nop
TIMELIB_StopTiming_:
 CLOCK_VALUE
 add edx,eax
 mov ebx,dword ptr [_starttics]
 mov eax,edx
 mov dword ptr [_stoptics],edx
 sub eax,ebx
 RETURN_CLOCK
