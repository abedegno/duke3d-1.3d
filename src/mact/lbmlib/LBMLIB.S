# Complete MACT LBM semantic reconstruction; C counterpart and primary headers accompany it.
# Not historical recovered ASM; native unchecked behavior is deliberately retained.
.intel_syntax noprefix
.code32
.file "LBMLIB.S"
.extern memset_
.globl memset_
.extern Error_
.globl Error_
.extern MotoLong_
.globl MotoLong_
.extern MotoShort_
.globl MotoShort_
.globl Align_
.globl LBMRLEDecompress_
.globl MungeBitPlanes_
.globl LoadLBM_
.globl SaveLBM_
.equ FORMID, 0x4d524f46
.equ ILBMID, 0x4d424c49
.equ PBMID, 0x204d4250
.equ BMHDID, 0x44484d42
.equ BODYID, 0x59444f42
.equ CMAPID, 0x50414d43
.equ BPLANESIZE, 128
.equ PALETTE_BYTES, 256*3
.equ BMHD_BYTES, 20
.equ MAX_BITMAP_WIDTH, 320
.equ MAX_BITMAP_HEIGHT, 200
.section _TEXT,"ax",@progbits
.p2align 4

# Align_ -- ordinary C counterpart: authored/lbmlib.c
Align_:
test al, 1
je aligned_count
inc eax
aligned_count:
ret
{load} mov eax, eax

# LBMRLEDecompress_ -- ordinary C counterpart: authored/lbmlib.c
LBMRLEDecompress_:
push ecx
push esi
push edi
push ebp
sub esp, 0x10
mov ebp, eax
mov dword ptr [esp + 8], edx
mov dword ptr [esp], ebx
xor edx, edx
mov dword ptr [esp + 4], edx
rle_next_control:
mov dl, byte ptr [ebp]
inc ebp
mov byte ptr [esp + 0xc], dl
cmp dl, 0x80
jbe rle_literal_or_noop
xor dl, 0xff
add dl, 2
xor ecx, ecx
mov byte ptr [esp + 0xc], dl
mov cl, byte ptr [esp + 0xc]
mov dl, byte ptr [ebp]
mov eax, dword ptr [esp + 8]
mov esi, dword ptr [esp + 8]
and edx, 0xff
inc ebp
mov ebx, ecx
add esi, ecx
call memset_
mov dword ptr [esp + 8], esi
jmp rle_accumulate
rle_literal_or_noop:
jae rle_noop
mov bl, dl
inc bl
xor edx, edx
mov edi, dword ptr [esp + 8]
mov dl, bl
mov esi, ebp
mov ecx, edx
mov byte ptr [esp + 0xc], bl
push edi
mov eax, ecx
shr ecx, 2
repne movsd
{load} mov cl, al
and cl, 3
repne movsb byte ptr es:[edi], byte ptr [esi]
pop edi
lea ebx, [edi + edx]
add ebp, edx
mov dword ptr [esp + 8], ebx
jmp rle_accumulate
rle_noop:
xor dh, dh
mov byte ptr [esp + 0xc], dh
rle_accumulate:
xor edx, edx
mov edi, dword ptr [esp + 4]
mov dl, byte ptr [esp + 0xc]
add edi, edx
mov eax, dword ptr [esp]
mov dword ptr [esp + 4], edi
cmp edi, eax
{disp32} jl rle_next_control
jle rle_return
push offset decompression_width_error
call Error_
add esp, 4
rle_return:
mov eax, ebp
add esp, 0x10
pop ebp
pop edi
pop esi
pop ecx
ret
nop

# MungeBitPlanes_ -- ordinary C counterpart: authored/lbmlib.c
MungeBitPlanes_:
push ecx
push esi
push edi
push ebp
sub esp, 0x10
mov dword ptr [esp], eax
mov dword ptr [esp + 4], edx
mov edi, ebx
xor edx, edx
mov ebp, 8
mov dword ptr [esp + 8], edx
mov dword ptr [esp + 0xc], edx
test eax, eax
jle planar_return
planar_next_pixel:
xor ebx, ebx
xor eax, eax
test edi, edi
jle planar_write_color
mov edx, dword ptr [esp + 8]
planar_next_plane:
mov cl, al
movzx esi, byte ptr [edx + _bitplanes]
add edx, BPLANESIZE
shl esi, cl
inc eax
or ebx, esi
cmp eax, edi
jl planar_next_plane
planar_write_color:
mov eax, dword ptr [esp + 4]
mov byte ptr [eax], bl
lea ebx, [eax + 1]
mov dword ptr [esp + 4], ebx
dec ebp
jne planar_next_position
mov ecx, dword ptr [esp + 8]
inc ecx
mov ebp, 8
mov dword ptr [esp + 8], ecx
planar_next_position:
mov esi, dword ptr [esp + 0xc]
inc esi
mov edx, dword ptr [esp]
mov dword ptr [esp + 0xc], esi
cmp esi, edx
jl planar_next_pixel
planar_return:
add esp, 0x10
pop ebp
pop edi
pop esi
pop ecx
ret
{disp8} lea eax, [eax]

# LoadLBM_ -- ordinary C counterpart: authored/lbmlib.c
LoadLBM_:
push esi
push edi
push ebp
sub esp, 0x50
mov dword ptr [esp + 0x14], edx
mov dword ptr [esp + 0x38], ebx
mov dword ptr [esp + 0x3c], ecx
mov dword ptr [esp + 0x48], eax
xor edx, edx
mov ebx, dword ptr [eax]
mov dword ptr [esp + 0x18], edx
cmp ebx, FORMID
je load_form_length
push offset missing_form_error
call Error_
add esp, 4
load_form_length:
mov ecx, dword ptr [esp + 0x48]
add ecx, 4
mov eax, dword ptr [ecx]
mov dword ptr [esp + 0x48], ecx
lea esi, [ecx + 4]
call MotoLong_
mov dword ptr [esp + 0x48], esi
test al, 1
je load_aligned_form_end
inc eax
load_aligned_form_end:
mov edx, dword ptr [esp + 0x48]
add edx, eax
mov eax, dword ptr [esp + 0x48]
mov eax, dword ptr [eax]
mov dword ptr [esp + 0x30], edx
mov dword ptr [esp + 0x44], eax
cmp eax, ILBMID
je load_first_chunk
cmp eax, PBMID
je load_first_chunk
sar eax, 0x18
and eax, 0xff
push eax
mov eax, dword ptr [esp + 0x48]
sar eax, 0x10
and eax, 0xff
push eax
mov eax, dword ptr [esp + 0x4c]
sar eax, 8
and eax, 0xff
push eax
mov eax, dword ptr [esp + 0x50]
and eax, 0xff
push eax
push offset unknown_form_error
call Error_
add esp, 0x14
load_first_chunk:
mov eax, dword ptr [esp + 0x48]
add eax, 4
mov edx, dword ptr [esp + 0x30]
mov dword ptr [esp + 0x48], eax
cmp eax, edx
{disp32} jae load_final_status
load_next_chunk:
mov edi, dword ptr [esp + 0x48]
mov edx, dword ptr [esp + 0x48]
mov eax, dword ptr [edi + 4]
add edi, 4
mov edx, dword ptr [edx]
call MotoLong_
mov dword ptr [esp + 0x48], edi
mov ecx, eax
lea ebp, [edi + 4]
mov dword ptr [esp + 0x1c], eax
mov dword ptr [esp + 0x48], ebp
cmp edx, CMAPID
jb load_check_bitmap_header
{disp32} jbe load_palette
cmp edx, BODYID
{disp32} je load_body
{disp32} jmp load_advance_chunk
load_check_bitmap_header:
cmp edx, BMHDID
{disp32} jne load_advance_chunk
mov ecx, BMHD_BYTES
mov edi, esp
mov esi, ebp
push edi
mov eax, ecx
shr ecx, 2
repne movsd
{load} mov cl, al
and cl, 3
repne movsb byte ptr es:[edi], byte ptr [esi]
pop edi
mov eax, dword ptr [esp - 2]
sar eax, 0x10
call MotoShort_
mov word ptr [esp], ax
mov eax, dword ptr [esp]
sar eax, 0x10
call MotoShort_
mov word ptr [esp + 2], ax
mov eax, dword ptr [esp + 2]
sar eax, 0x10
call MotoShort_
mov word ptr [esp + 4], ax
mov eax, dword ptr [esp + 4]
sar eax, 0x10
call MotoShort_
mov word ptr [esp + 6], ax
mov eax, dword ptr [esp + 0xe]
sar eax, 0x10
call MotoShort_
mov word ptr [esp + 0x10], ax
mov eax, dword ptr [esp + 0x10]
sar eax, 0x10
call MotoShort_
mov word ptr [esp + 0x12], ax
xor eax, eax
mov edx, dword ptr [esp + 0x3c]
mov ax, word ptr [esp]
mov dword ptr [edx], eax
xor eax, eax
mov edx, dword ptr [esp + 0x60]
mov ax, word ptr [esp + 2]
mov dword ptr [edx], eax
cmp word ptr [esp], MAX_BITMAP_WIDTH
ja load_bad_size
cmp ax, MAX_BITMAP_HEIGHT
{disp32} jbe load_advance_chunk
load_bad_size:
mov eax, 1
add esp, 0x50
pop ebp
pop edi
pop esi
ret 4
load_palette:
mov ebx, PALETTE_BYTES
mov eax, dword ptr [esp + 0x38]
mov edi, dword ptr [esp + 0x38]
xor edx, edx
mov esi, ebp
call memset_
push edi
mov eax, ecx
shr ecx, 2
repne movsd
{load} mov cl, al
and cl, 3
repne movsb byte ptr es:[edi], byte ptr [esi]
pop edi
{disp32} jmp load_advance_chunk
load_body:
mov eax, dword ptr [esp + 0x14]
mov dword ptr [esp + 0x24], eax
cmp dword ptr [esp + 0x44], PBMID
{disp32} jne ilbm_body
xor esi, esi
mov dword ptr [esp + 0x20], esi
jmp pbm_row_condition
pbm_dispatch_uncompressed:
test dl, dl
jne pbm_next_row
mov edi, dword ptr [esp + 0x24]
xor ecx, ecx
mov esi, ebp
mov cx, word ptr [esp]
push edi
mov eax, ecx
shr ecx, 2
repne movsd
{load} mov cl, al
and cl, 3
repne movsb byte ptr es:[edi], byte ptr [esi]
pop edi
xor eax, eax
mov ax, word ptr [esp]
test al, 1
je pbm_aligned_width
inc eax
pbm_aligned_width:
add ebp, eax
pbm_next_row:
mov edx, dword ptr [esp + 0x20]
xor eax, eax
mov ebx, dword ptr [esp + 0x24]
mov ax, word ptr [esp]
inc edx
add ebx, eax
mov dword ptr [esp + 0x20], edx
mov dword ptr [esp + 0x24], ebx
pbm_row_condition:
xor eax, eax
mov edi, dword ptr [esp + 0x20]
mov ax, word ptr [esp + 2]
cmp eax, edi
{disp32} jle load_advance_chunk
mov dl, byte ptr [esp + 0xa]
cmp dl, 1
jne pbm_dispatch_uncompressed
mov edx, dword ptr [esp + 0x24]
xor ebx, ebx
mov eax, ebp
mov bx, word ptr [esp]
call LBMRLEDecompress_
mov ebp, eax
jmp pbm_next_row
ilbm_body:
xor eax, eax
mov al, byte ptr [esp + 8]
mov dword ptr [esp + 0x28], eax
cmp byte ptr [esp + 9], 1
jne ilbm_row_size
mov edx, 1
mov ebx, dword ptr [esp + 0x28]
add ebx, edx
mov dword ptr [esp + 0x18], edx
mov dword ptr [esp + 0x28], ebx
ilbm_row_size:
xor edx, edx
mov dx, word ptr [esp]
add edx, 0xf
mov eax, edx
sar edx, 0x1f
shl edx, 4
{load} sbb eax, edx
sar eax, 4
xor ecx, ecx
add eax, eax
mov dword ptr [esp + 0x4c], ecx
mov dword ptr [esp + 0x2c], eax
{disp32} jmp ilbm_row_condition
ilbm_row:
xor esi, esi
mov edi, dword ptr [esp + 0x28]
mov dword ptr [esp + 0x40], esi
test edi, edi
jle ilbm_write_row
mov dword ptr [esp + 0x34], offset _bitplanes
ilbm_plane:
mov bl, byte ptr [esp + 0xa]
cmp bl, 1
jne ilbm_uncompressed
mov ebx, dword ptr [esp + 0x2c]
mov edx, dword ptr [esp + 0x34]
mov eax, ebp
call LBMRLEDecompress_
mov ebp, eax
jmp ilbm_next_plane
ilbm_uncompressed:
test bl, bl
jne ilbm_next_plane
mov ecx, dword ptr [esp + 0x2c]
mov edi, dword ptr [esp + 0x34]
mov esi, ebp
push edi
mov eax, ecx
shr ecx, 2
repne movsd
{load} mov cl, al
and cl, 3
repne movsb byte ptr es:[edi], byte ptr [esi]
pop edi
add ebp, dword ptr [esp + 0x2c]
ilbm_next_plane:
mov eax, dword ptr [esp + 0x34]
mov edx, dword ptr [esp + 0x40]
mov ebx, dword ptr [esp + 0x28]
add eax, BPLANESIZE
inc edx
mov dword ptr [esp + 0x34], eax
mov dword ptr [esp + 0x40], edx
cmp edx, ebx
jl ilbm_plane
ilbm_write_row:
mov edx, dword ptr [esp + 0x24]
xor ebx, ebx
xor eax, eax
mov bl, byte ptr [esp + 8]
mov ax, word ptr [esp]
mov ecx, dword ptr [esp + 0x4c]
call MungeBitPlanes_
xor eax, eax
mov esi, dword ptr [esp + 0x24]
mov ax, word ptr [esp]
inc ecx
add esi, eax
mov dword ptr [esp + 0x4c], ecx
mov dword ptr [esp + 0x24], esi
ilbm_row_condition:
xor eax, eax
mov ecx, dword ptr [esp + 0x4c]
mov ax, word ptr [esp + 2]
cmp eax, ecx
{disp32} jg ilbm_row
load_advance_chunk:
test byte ptr [esp + 0x1c], 1
je load_even_chunk
mov eax, dword ptr [esp + 0x1c]
inc eax
jmp load_chunk_extent
load_even_chunk:
mov eax, dword ptr [esp + 0x1c]
load_chunk_extent:
mov ebx, dword ptr [esp + 0x48]
add ebx, eax
mov ecx, dword ptr [esp + 0x30]
mov dword ptr [esp + 0x48], ebx
cmp ebx, ecx
{disp32} jb load_next_chunk
load_final_status:
cmp dword ptr [esp + 0x18], 0
je load_okay
mov eax, 2
add esp, 0x50
pop ebp
pop edi
pop esi
ret 4
load_okay:
xor eax, eax
add esp, 0x50
pop ebp
pop edi
pop esi
ret 4
{disp8} lea eax, [eax]

# SaveLBM_ -- ordinary C counterpart: authored/lbmlib.c
SaveLBM_:
push esi
push edi
push ebp
sub esp, 0x2c
mov dword ptr [esp + 0x14], eax
mov dword ptr [esp + 0x18], ebx
mov dword ptr [esp + 0x20], ecx
mov dword ptr [esp + 0x1c], edx
lea ebp, [edx + 1]
mov byte ptr [edx], 0x46
mov byte ptr [ebp], 0x4f
inc ebp
mov byte ptr [ebp], 0x52
inc ebp
mov byte ptr [ebp], 0x4d
inc ebp
mov dword ptr [esp + 0x28], ebp
add ebp, 4
mov byte ptr [ebp], 0x50
inc ebp
mov byte ptr [ebp], 0x42
inc ebp
mov byte ptr [ebp], 0x4d
inc ebp
mov byte ptr [ebp], 0x20
inc ebp
mov byte ptr [ebp], 0x42
inc ebp
mov byte ptr [ebp], 0x4d
inc ebp
mov ebx, BMHD_BYTES
mov byte ptr [ebp], 0x48
inc ebp
mov eax, esp
xor edx, edx
mov byte ptr [ebp], 0x44
call memset_
mov edx, dword ptr [esp + 0x1e]
mov ebx, dword ptr [esp + 0x3a]
sar edx, 0x10
inc ebp
mov eax, edx
sar ebx, 0x10
call MotoShort_
mov word ptr [esp], ax
mov eax, ebx
mov dword ptr [esp + 0x24], ebp
call MotoShort_
mov word ptr [esp + 2], ax
mov eax, 8
add ebp, 4
call MotoShort_
mov byte ptr [esp + 8], al
mov eax, 5
mov ecx, BMHD_BYTES
mov esi, esp
call MotoShort_
mov byte ptr [esp + 0xe], al
mov eax, 6
mov edi, ebp
call MotoShort_
mov byte ptr [esp + 0xf], al
mov eax, edx
add ebp, 0x14
call MotoShort_
mov word ptr [esp + 0x10], ax
mov edx, ebp
mov eax, ebx
mov ebx, dword ptr [esp + 0x24]
call MotoShort_
sub edx, ebx
mov word ptr [esp + 0x12], ax
sub edx, 4
push edi
mov eax, ecx
shr ecx, 2
repne movsd
{load} mov cl, al
and cl, 3
repne movsb byte ptr es:[edi], byte ptr [esi]
pop edi
mov eax, edx
call MotoLong_
mov dword ptr [ebx], eax
test dl, 1
je save_palette_chunk
mov byte ptr [ebp], 0
inc ebp
save_palette_chunk:
mov byte ptr [ebp], 0x43
inc ebp
mov byte ptr [ebp], 0x4d
inc ebp
mov byte ptr [ebp], 0x41
inc ebp
mov byte ptr [ebp], 0x50
inc ebp
mov ebx, ebp
add ebp, 4
mov edi, ebp
add ebp, 0x300
mov edx, ebp
mov ecx, PALETTE_BYTES
sub edx, ebx
mov esi, dword ptr [esp + 0x18]
sub edx, 4
push edi
mov eax, ecx
shr ecx, 2
repne movsd
{load} mov cl, al
and cl, 3
repne movsb byte ptr es:[edi], byte ptr [esi]
pop edi
mov eax, edx
call MotoLong_
mov dword ptr [ebx], eax
test dl, 1
je save_body_chunk
mov byte ptr [ebp], 0
inc ebp
save_body_chunk:
mov edx, dword ptr [esp + 0x20]
imul edx, dword ptr [esp + 0x3c]
mov byte ptr [ebp], 0x42
inc ebp
mov byte ptr [ebp], 0x4f
inc ebp
mov byte ptr [ebp], 0x44
inc ebp
mov byte ptr [ebp], 0x59
inc ebp
mov ebx, ebp
add ebp, 4
mov edi, ebp
add ebp, edx
mov ecx, edx
mov edx, ebp
sub edx, ebx
mov esi, dword ptr [esp + 0x14]
sub edx, 4
push edi
mov eax, ecx
shr ecx, 2
repne movsd
{load} mov cl, al
and cl, 3
repne movsb byte ptr es:[edi], byte ptr [esi]
pop edi
mov eax, edx
call MotoLong_
mov dword ptr [ebx], eax
test dl, 1
je save_form_length
mov byte ptr [ebp], 0
inc ebp
save_form_length:
mov esi, dword ptr [esp + 0x28]
mov edx, ebp
sub edx, esi
sub edx, 4
mov eax, edx
call MotoLong_
mov dword ptr [esi], eax
test dl, 1
je save_return
mov byte ptr [ebp], 0
inc ebp
save_return:
mov edi, dword ptr [esp + 0x1c]
mov eax, ebp
sub eax, edi
add esp, 0x2c
pop ebp
pop edi
pop esi
ret 4
.section CONST,"aw",@progbits
.p2align 2
decompression_width_error:
.asciz "LBMRLEDecompress: Decompression exceeded width!\n"
.p2align 2
missing_form_error:
.asciz "LoadLBM: No FORM ID at start of file!\n"
.p2align 2
unknown_form_error:
.asciz "Unrecognized form type: %c%c%c%c\n"
.section CONST2,"aw",@progbits
.p2align 2
.section _DATA,"aw",@progbits
.p2align 2
.section _BSS,"aw",@nobits
.p2align 4
_bitplanes:
.zero 9*BPLANESIZE # real reusable planar rows plus optional mask row
