; Symbolic reconstruction from the pinned MACT386.LIB joystick.asm reference.
; Original source authorship/copyright is unresolved; no GPL relicensing.
; Charge game-port RC timers, count selected active axis bits until discharged
; or the 5000-iteration deadline. AND applies the mask; XOR is not equivalent.
; Preserve the observed PUSHF/CLI/STI/POPF sequence and axis register mapping.
.586
.model flat
_TEXT segment word public use32 'CODE'
_TEXT ends
_DATA segment word public use32 'DATA'
public _Joy_x1,_Joy_y1,_Joy_x2,_Joy_y2,_Joy_mask
_Joy_x1 dd 0
_Joy_y1 dd 0
_Joy_x2 dd 0
_Joy_y2 dd 0
_Joy_mask db 0
_DATA ends
TEXT segment para private use32
public JoyStick_Vals_
JoyStick_Vals_ proc near
 pushf
 push ebp
 xor eax,eax
 mov ah,_Joy_mask
 mov edx,201h
 xor ebx,ebx
 xor ecx,ecx
 xor esi,esi
 xor edi,edi
 xor ebp,ebp
 cli
 out dx,al
sample_loop:
 inc edi
 cmp edi,5000
 je sample_done
 in al,dx
 and al,ah
 test al,1
 jz skip_x1
 inc ebx
skip_x1:
 test al,2
 jz skip_y1
 inc ecx
skip_y1:
 test al,4
 jz skip_x2
 inc ebp
skip_x2:
 test al,8
 jz skip_y2
 inc esi
skip_y2:
 test al,0fh
 jnz sample_loop
sample_done:
 sti
 mov _Joy_x1,ebx
 mov _Joy_y1,ecx
 mov _Joy_x2,ebp
 mov _Joy_y2,esi
 pop ebp
 popf
 ret
JoyStick_Vals_ endp
TEXT ends
end
