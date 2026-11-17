# Complete late MACT ANIM symbolic recovery. GPL notices and readable C in C-counterpart/.
# Ordinary instructions; no original historical ASM claim. Real shared epilogue preserved.
# Global self CALLs retain GLOBAL ELF identities: linker selects earlier ANIM definitions.
# Private _anim and _Anim_Started remain local to this late physical contribution.
.intel_syntax noprefix
.code32
.file "ANIMLIB.S"
.section _TEXT,"ax",@progbits
.p2align 4
.globl CheckAnimStarted_
.globl findpage_
.globl loadpage_
.globl CPlayRunSkipDump_
.globl renderframe_
.globl drawframe_
.globl ANIM_LoadAnim_
.globl ANIM_FreeAnim_
.globl ANIM_NumFrames_
.globl ANIM_DrawFrame_
.globl ANIM_GetPalette_
.extern Error_
.extern SafeMalloc_
.extern SafeFree_

# CheckAnimStarted_ -- complete behavior in restored C aid.
CheckAnimStarted_:
cmp dword ptr [_Anim_Started], 0
jne anim_branch_01
push eax
push OFFSET FLAT:anim_not_started
call Error_
add esp, 8
anim_branch_01:
ret 

# findpage_ -- complete behavior in restored C aid.
findpage_:
push ebx
push ecx
push edx
push esi
mov ebx, eax
mov eax, OFFSET FLAT:caller_findpage
call CheckAnimStarted_
xor eax, eax
jmp anim_branch_04
anim_branch_02:
xor ecx, ecx
mov cx, ax
imul ecx, ecx, 6
add edx, ecx
mov si, word ptr [edx + 0x84]
cmp bx, si
jb anim_branch_03
xor ecx, ecx
mov cx, word ptr [edx + 0x86]
mov edx, esi
and edx, 0xffff
add ecx, edx
xor edx, edx
mov dx, bx
cmp ecx, edx
jg anim_branch_05
anim_branch_03:
inc eax
anim_branch_04:
mov edx, dword ptr [_anim]
cmp ax, word ptr [edx + 0xa]
jb anim_branch_02
anim_branch_05:
pop esi
pop edx
pop ecx
pop ebx
ret 

# loadpage_ -- complete behavior in restored C aid.
loadpage_:
push ebx
push ecx
push esi
push edi
push ebp
mov ebx, eax
mov ebp, edx
mov eax, OFFSET FLAT:caller_loadpage
call CheckAnimStarted_
mov eax, dword ptr [_anim]
mov cx, word ptr [eax + 0x684]
mov edx, dword ptr [eax + 0x2068c]
cmp bx, cx
je anim_branch_06
xor ecx, ecx
mov cx, bx
shl ecx, 0x10
add ecx, 0xb00
lea edi, [eax + 0x686]
add edx, ecx
mov ecx, 6
mov esi, edx
mov word ptr [eax + 0x684], bx
push edi
mov eax, ecx
shr ecx, 2
repne movsd dword ptr es:[edi], dword ptr [esi]
{load} mov cl, al
and cl, 3
repne movsb byte ptr es:[edi], byte ptr [esi]
pop edi
mov eax, dword ptr [_anim]
xor edi, edi
xor ecx, ecx
mov di, word ptr [eax + 0x688]
mov cx, word ptr [eax + 0x68a]
add edi, edi
lea esi, [edx + 8]
add ecx, edi
mov edi, ebp
push edi
mov eax, ecx
shr ecx, 2
repne movsd dword ptr es:[edi], dword ptr [esi]
{load} mov cl, al
and cl, 3
repne movsb byte ptr es:[edi], byte ptr [esi]
pop edi
anim_branch_06:
pop ebp
pop edi
pop esi
anim_branch_07:
# Shared stop epilogue: decoder branches here; not a new public/alias.
pop ecx
pop ebx
ret 

# CPlayRunSkipDump_ -- complete behavior in restored C aid.
CPlayRunSkipDump_:
push ebx
push ecx
anim_branch_08:
mov bl, byte ptr [eax]
inc eax
test bl, bl
jg anim_branch_09
je anim_branch_10
sub bl, 0x80
je anim_branch_12
movsx ebx, bl
add edx, ebx
jmp anim_branch_08
anim_branch_09:
inc edx
mov bh, byte ptr [eax]
inc eax
mov byte ptr [edx - 1], bh
dec bl
je anim_branch_08
jmp anim_branch_09
anim_branch_10:
inc eax
inc eax
xor bh, bh
mov cl, byte ptr [eax - 1]
mov bl, byte ptr [eax - 2]
anim_branch_11:
inc edx
mov byte ptr [edx - 1], cl
dec bx
je anim_branch_08
jmp anim_branch_11
anim_branch_12:
mov bx, word ptr [eax]
add eax, 2
test bx, bx
jle anim_branch_13
and ebx, 0xffff
add edx, ebx
jmp anim_branch_08
anim_branch_13:
je anim_branch_07
add bh, 0x80
cmp bx, 0x4000
jae anim_branch_15
anim_branch_14:
inc edx
mov cl, byte ptr [eax]
inc eax
mov byte ptr [edx - 1], cl
dec bx
je anim_branch_08
jmp anim_branch_14
anim_branch_15:
inc eax
sub ebx, 0x4000
mov cl, byte ptr [eax - 1]
anim_branch_16:
inc edx
mov byte ptr [edx - 1], cl
dec bx
je anim_branch_08
jmp anim_branch_16
# Preserved real compiler no-op tail instruction, no storage/filler owner.
{load} mov eax, eax

# renderframe_ -- complete behavior in restored C aid.
renderframe_:
push ebx
push ecx
push esi
push edi
mov esi, eax
mov ecx, edx
mov eax, OFFSET FLAT:caller_renderframe
call CheckAnimStarted_
mov eax, dword ptr [_anim]
mov bx, word ptr [eax + 0x686]
xor edx, edx
sub esi, ebx
xor eax, eax
test si, si
jbe anim_branch_18
anim_branch_17:
xor ebx, ebx
mov bx, ax
mov di, word ptr [ecx + ebx*2]
inc eax
add edx, edi
cmp ax, si
jb anim_branch_17
anim_branch_18:
mov eax, dword ptr [_anim]
mov ax, word ptr [eax + 0x688]
and eax, 0xffff
lea ebx, [eax*2]
xor eax, eax
mov ax, dx
add eax, ebx
add eax, ecx
cmp byte ptr [eax + 1], 0
je anim_branch_19
mov dx, word ptr [eax + 2]
xor dh, dh
xor ebx, ebx
and dl, 1
mov bx, dx
xor edx, edx
mov dx, word ptr [eax + 2]
add edx, ebx
add edx, 4
add eax, edx
jmp anim_branch_20
anim_branch_19:
add eax, 4
anim_branch_20:
mov edx, dword ptr [_anim]
add edx, 0x1068c
call CPlayRunSkipDump_
pop edi
pop esi
pop ecx
pop ebx
ret 
# Preserved real compiler no-op tail instruction, no storage/filler owner.
nop 

# drawframe_ -- complete behavior in restored C aid.
drawframe_:
push ebx
push edx
mov ebx, eax
mov eax, OFFSET FLAT:caller_drawframe
call CheckAnimStarted_
mov edx, dword ptr [_anim]
add edx, 0x68c
and ebx, 0xffff
mov eax, ebx
call findpage_
and eax, 0xffff
call loadpage_
mov edx, dword ptr [_anim]
mov eax, ebx
add edx, 0x68c
call renderframe_
pop edx
pop ebx
ret 
# Preserved real compiler no-op tail instruction, no storage/filler owner.
nop 

# ANIM_LoadAnim_ -- complete behavior in restored C aid.
ANIM_LoadAnim_:
push ebx
push ecx
push edx
push esi
push edi
push ebp
mov ebp, dword ptr [_anim]
mov edx, eax
cmp dword ptr [_Anim_Started], 0
jne anim_branch_21
mov eax, 0x20994
mov ecx, 1
call SafeMalloc_
mov ebp, eax
mov dword ptr [_Anim_Started], ecx
anim_branch_21:
mov ecx, 0x80
mov word ptr [ebp + 0x684], 0xffff
lea edi, [ebp + 4]
mov dword ptr [ebp + 0x20990], 0xffffffff
mov esi, edx
mov dword ptr [ebp + 0x2068c], edx
mov dword ptr [_anim], ebp
push edi
mov eax, ecx
shr ecx, 2
repne movsd dword ptr es:[edi], dword ptr [esi]
{load} mov cl, al
and cl, 3
repne movsb byte ptr es:[edi], byte ptr [esi]
pop edi
add edx, 0x100
mov ebp, dword ptr [_anim]
xor eax, eax
mov esi, ebp
anim_branch_22:
xor ebx, ebx
mov edi, edx
mov bx, ax
mov cl, byte ptr [edi]
inc edx
mov byte ptr [esi + ebx + 0x20692], cl
mov ecx, edx
mov cl, byte ptr [ecx]
inc edx
mov byte ptr [esi + ebx + 0x20691], cl
mov ecx, edx
# Three meaningful palette channels; forward absolute context preserves full-width ADD.
.att_syntax prefix
addl $palette_entry_channels, %eax
.intel_syntax noprefix
mov cl, byte ptr [ecx]
add edx, 2
mov byte ptr [esi + ebx + 0x20690], cl
cmp ax, 0x300
jb anim_branch_22
mov ecx, 0x600
lea edi, [ebp + 0x84]
mov esi, edx
mov dword ptr [_anim], ebp
push edi
mov eax, ecx
shr ecx, 2
repne movsd dword ptr es:[edi], dword ptr [esi]
{load} mov cl, al
and cl, 3
repne movsb byte ptr es:[edi], byte ptr [esi]
pop edi
mov ebp, dword ptr [_anim]
pop ebp
pop edi
pop esi
pop edx
pop ecx
pop ebx
ret 
# Preserved real compiler no-op tail instruction, no storage/filler owner.
{disp8} lea eax, [eax]

# ANIM_FreeAnim_ -- complete behavior in restored C aid.
ANIM_FreeAnim_:
push ebx
cmp dword ptr [_Anim_Started], 0
je anim_branch_23
mov eax, dword ptr [_anim]
xor ebx, ebx
call SafeFree_
mov dword ptr [_Anim_Started], ebx
anim_branch_23:
pop ebx
ret 
# Preserved real compiler no-op tail instruction, no storage/filler owner.
{load} mov eax, eax

# ANIM_NumFrames_ -- complete behavior in restored C aid.
ANIM_NumFrames_:
mov eax, OFFSET FLAT:caller_NumFrames
call CheckAnimStarted_
mov eax, dword ptr [_anim]
mov eax, dword ptr [eax + 0xc]
ret 
# Preserved real compiler no-op tail instruction, no storage/filler owner.
nop 

# ANIM_DrawFrame_ -- complete behavior in restored C aid.
ANIM_DrawFrame_:
push ebx
push ecx
push edx
mov ebx, eax
mov eax, OFFSET FLAT:caller_DrawFrame
call CheckAnimStarted_
mov edx, dword ptr [_anim]
mov ecx, dword ptr [edx + 0x20990]
cmp ecx, -1
je anim_branch_25
cmp ebx, ecx
jl anim_branch_25
mov edx, ecx
cmp ecx, ebx
jge anim_branch_27
anim_branch_24:
xor eax, eax
mov ax, dx
inc edx
call drawframe_
cmp edx, ebx
jge anim_branch_27
jmp anim_branch_24
anim_branch_25:
xor edx, edx
test ebx, ebx
jle anim_branch_27
anim_branch_26:
xor eax, eax
mov ax, dx
inc edx
call drawframe_
cmp edx, ebx
jl anim_branch_26
anim_branch_27:
mov eax, dword ptr [_anim]
add eax, 0x1068c
mov dword ptr [eax + 0x10304], ebx
pop edx
pop ecx
pop ebx
ret 

# ANIM_GetPalette_ -- complete behavior in restored C aid.
ANIM_GetPalette_:
mov eax, OFFSET FLAT:caller_GetPalette
call CheckAnimStarted_
mov eax, dword ptr [_anim]
add eax, 0x20690
ret 

.section CONST,"aw",@progbits
.p2align 2
anim_not_started:
.asciz "ANIMLIB_%s: Anim has not been initialized\n"
.balign 4
caller_findpage:
.asciz "findpage"
.balign 4
caller_loadpage:
.asciz "loadpage"
.balign 4
caller_renderframe:
.asciz "renderframe"
.balign 4
caller_drawframe:
.asciz "drawframe"
.balign 4
caller_NumFrames:
.asciz "NumFrames"
.balign 4
caller_DrawFrame:
.asciz "DrawFrame"
.balign 4
caller_GetPalette:
.asciz "GetPalette"

.section CONST2,"aw",@progbits
.p2align 2

.section _DATA,"aw",@progbits
.p2align 2
_anim:
.long 0 # actual private anim_t pointer, NULL
_Anim_Started:
.long 0 # actual private boolean false

.section _BSS,"aw",@nobits
.p2align 4

.equ palette_entry_channels, 3 # released palette[768], three RGB channels per entry
