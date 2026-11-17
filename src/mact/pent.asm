; Symbolic reconstruction from the pinned MACT386.LIB pent.asm reference.
; Original source authorship/copyright is unresolved; no GPL relicensing.
; previous_high/previous_low are inferred private names. RDTSC snapshots
; EDX:EAX; Stop subtracts with borrow and publishes the elapsed halves.
.586
.model flat
_TEXT segment word public use32 'CODE'
_TEXT ends
_DATA segment word public use32 'DATA'
previous_high dd 0
previous_low dd 0
public _PENT_timeh, _PENT_timel
_PENT_timeh dd 0
_PENT_timel dd 0
_DATA ends
TEXT segment para private use32
public PENT_Start_, PENT_Stop_
PENT_Start_ proc near
 push eax
 push edx
 xor eax,eax
 xor edx,edx
 rdtsc
 mov previous_high,edx
 mov previous_low,eax
 pop edx
 pop eax
 ret
PENT_Start_ endp
PENT_Stop_ proc near
 push eax
 push edx
 xor eax,eax
 xor edx,edx
 rdtsc
 sub eax,previous_low
 sbb edx,previous_high
 mov _PENT_timeh,edx
 mov _PENT_timel,eax
 pop edx
 pop eax
 ret
PENT_Stop_ endp
TEXT ends
end
