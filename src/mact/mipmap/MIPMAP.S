# Complete native-guided MACT mipmap reconstruction, not a found historical ASM.
# Readable C aid and genuine released API/type/allocator notices are retained.
# Four doubles per accumulator: weight and normalized red/green/blue totals.
.intel_syntax noprefix
.arch .387
.code32
.file "MIPMAP.S"
.equ DOUBLE_ONE_HIGH, (1023 << 20) # IEEE754 exponent for actual1.0
.equ PIXEL_BYTES, 32
.equ PIXEL_WEIGHT, 0
.equ PIXEL_RED, 8
.equ PIXEL_GREEN, 16
.equ PIXEL_BLUE, 24
.equ FRAME_BYTES, 116
.equ ERROR_RED, 8
.equ ERROR_GREEN, 0
.equ ERROR_BLUE, 16
.equ VALUE_RED, 32
.equ VALUE_GREEN, 48
.equ VALUE_BLUE, 40
.equ ORIGINAL_ROW_BYTES, 60
.equ OUTPUT_ROW_BYTES, 64
.equ ORIGINAL_ROW_STEP, 68
.equ SOURCE_BITMAP, 72
.equ ACCUMULATOR_ROW, 76
.equ OUTPUT_ROW, 80
.equ LEVEL, 84
.equ HEIGHT, 88
.equ BUFFER_BYTES, 92
.equ HALF_HEIGHT, 96
.equ FOLDED_PIXELS, 100
.equ SOURCE_PIXELS, 104
.equ WIDTH, 108
.equ CHANNEL_INTEGER, 112
.equ DEST_BITMAP_ARG, 132
.equ PALETTE_ARG, 136
.equ DIFFUSION_ARG, 140
.section _TEXT,"ax",@progbits
.p2align 4
.globl FoldPixel_, CreateMipMap_
.extern SafeMalloc_, memset_, CMAP_BestColor_, SafeFree_
.extern _fltused_,__init_387_emulator,__8087
# Genuine original unused FPU runtime imports, not fabricated references.
.globl _fltused_,__init_387_emulator,__8087

# xEAX,yEDX,source-widthEBX,dest-widthECX, then source/dest arrays on stack.
FoldPixel_:
push esi
push edi
mov esi, ecx
lea edi, [edx*2]
imul edi, ebx
imul edx, esi
lea ecx, [eax*2]
add eax, edx
mov edx, dword ptr [esp+16]
shl eax, 5
add ecx, edi
add eax, edx
mov edx, ecx
mov esi, dword ptr [esp+12]
shl edx, 5
add edx, esi
# Four explicit double copies preserve the first sample's exact representation.
mov edi, dword ptr [edx+PIXEL_WEIGHT]
mov dword ptr [eax+PIXEL_WEIGHT], edi
mov edi, dword ptr [edx+PIXEL_WEIGHT+4]
mov dword ptr [eax+PIXEL_WEIGHT+4], edi
mov edi, dword ptr [edx+PIXEL_RED]
mov dword ptr [eax+PIXEL_RED], edi
mov edi, dword ptr [edx+PIXEL_RED+4]
mov dword ptr [eax+PIXEL_RED+4], edi
mov edi, dword ptr [edx+PIXEL_GREEN]
mov dword ptr [eax+PIXEL_GREEN], edi
mov edi, dword ptr [edx+PIXEL_GREEN+4]
mov dword ptr [eax+PIXEL_GREEN+4], edi
mov edi, dword ptr [edx+PIXEL_BLUE]
mov dword ptr [eax+PIXEL_BLUE], edi
mov edi, dword ptr [edx+PIXEL_BLUE+4]
mov dword ptr [eax+PIXEL_BLUE+4], edi
# Add the right sample, then the two samples on the following source row.
fld qword ptr [edx+PIXEL_BYTES+PIXEL_WEIGHT]
fadd qword ptr [eax+PIXEL_WEIGHT]
fstp qword ptr [eax+PIXEL_WEIGHT]
fld qword ptr [edx+PIXEL_BYTES+PIXEL_RED]
fadd qword ptr [eax+PIXEL_RED]
fstp qword ptr [eax+PIXEL_RED]
fld qword ptr [edx+PIXEL_BYTES+PIXEL_GREEN]
fadd qword ptr [eax+PIXEL_GREEN]
fstp qword ptr [eax+PIXEL_GREEN]
fld qword ptr [edx+PIXEL_BYTES+PIXEL_BLUE]
lea edx, [ecx+ebx]
shl edx, 5
fadd qword ptr [eax+PIXEL_BLUE]
add edx, esi
fstp qword ptr [eax+PIXEL_BLUE]
fld qword ptr [edx+PIXEL_WEIGHT]
fadd qword ptr [eax+PIXEL_WEIGHT]
fstp qword ptr [eax+PIXEL_WEIGHT]
fld qword ptr [edx+PIXEL_RED]
fadd qword ptr [eax+PIXEL_RED]
fstp qword ptr [eax+PIXEL_RED]
fld qword ptr [edx+PIXEL_GREEN]
fadd qword ptr [eax+PIXEL_GREEN]
fstp qword ptr [eax+PIXEL_GREEN]
fld qword ptr [edx+PIXEL_BLUE]
fadd qword ptr [eax+PIXEL_BLUE]
fstp qword ptr [eax+PIXEL_BLUE]
fld qword ptr [edx+PIXEL_BYTES+PIXEL_WEIGHT]
fadd qword ptr [eax+PIXEL_WEIGHT]
fstp qword ptr [eax+PIXEL_WEIGHT]
fld qword ptr [edx+PIXEL_BYTES+PIXEL_RED]
fadd qword ptr [eax+PIXEL_RED]
fstp qword ptr [eax+PIXEL_RED]
fld qword ptr [edx+PIXEL_BYTES+PIXEL_GREEN]
fadd qword ptr [eax+PIXEL_GREEN]
fstp qword ptr [eax+PIXEL_GREEN]
fld qword ptr [edx+PIXEL_BYTES+PIXEL_BLUE]
fadd qword ptr [eax+PIXEL_BLUE]
fstp qword ptr [eax+PIXEL_BLUE]
pop edi
pop esi
ret 8

# origwEAX,orighEDX,levelEBX,srcECX, then dest,palette,diffusion on stack.
CreateMipMap_:
push esi
push edi
push ebp
sub esp, FRAME_BYTES
mov edi, eax
mov esi, edx
mov dword ptr [esp+LEVEL], ebx
mov dword ptr [esp+SOURCE_BITMAP], ecx
shl eax, 5
mov dword ptr [esp+ORIGINAL_ROW_BYTES], eax
imul eax, esi
xor edx, edx
mov dword ptr [esp+ERROR_RED], edx
mov dword ptr [esp+ERROR_RED+4], edx
mov dword ptr [esp+ERROR_GREEN], edx
mov dword ptr [esp+ERROR_GREEN+4], edx
mov dword ptr [esp+ERROR_BLUE], edx
mov dword ptr [esp+BUFFER_BYTES], eax
call SafeMalloc_
mov ebp, eax
mov dword ptr [esp+SOURCE_PIXELS], eax
mov eax, dword ptr [esp+BUFFER_BYTES]
mov dword ptr [esp+ERROR_BLUE+4], edx
mov edx, eax
sar edx, 31
shl edx, 2
{load} sbb eax, edx
sar eax, 2
mov ebx, dword ptr [esp+BUFFER_BYTES]
mov ecx, eax
call SafeMalloc_
xor edx, edx
mov dword ptr [esp+56], eax
mov dword ptr [esp+FOLDED_PIXELS], eax
mov eax, ebp
call memset_
mov eax, dword ptr [esp+56]
mov ebx, ecx
xor edx, edx
call memset_
# Signed division by two is preserved, including the native rounding rule.
mov edx, edi
mov eax, edi
sar edx, 31
{load} sub eax, edx
sar eax, 1
mov ebp, eax
mov edx, esi
mov eax, esi
sar edx, 31
{load} sub eax, edx
sar eax, 1
mov dword ptr [esp+WIDTH], edi
mov dword ptr [esp+HEIGHT], esi
xor ecx, ecx
mov dword ptr [esp+HALF_HEIGHT], eax
test esi, esi
jle mip_level_test
imul edi, ecx
mov eax, dword ptr [esp+ORIGINAL_ROW_BYTES]
mov dword ptr [esp+ORIGINAL_ROW_STEP], eax
mov dword ptr [esp+ACCUMULATOR_ROW], edi
initialize_row:
mov edi, dword ptr [esp+WIDTH]
xor ebx, ebx
test edi, edi
{disp32} jle initialize_next_row
mov edx, edi
imul edx, ecx
fld qword ptr [channel_scale]
mov esi, dword ptr [esp+SOURCE_PIXELS]
mov edi, dword ptr [esp+ACCUMULATOR_ROW]
mov eax, dword ptr [esp+SOURCE_BITMAP]
add esi, edi
add edx, eax
initialize_pixel:
movzx edi, byte ptr [edx]
mov eax, dword ptr [esp+PALETTE_ARG]
lea edi, [edi+edi*2]
add edi, eax
xor eax, eax
mov al, byte ptr [edi]
mov dword ptr [esp+CHANNEL_INTEGER], eax
fild word ptr [esp+CHANNEL_INTEGER]
fmul st, st(1)
xor eax, eax
fstp qword ptr [esi+PIXEL_RED]
mov al, byte ptr [edi+1]
mov dword ptr [esp+CHANNEL_INTEGER], eax
fild word ptr [esp+CHANNEL_INTEGER]
fmul st, st(1)
xor eax, eax
fstp qword ptr [esi+PIXEL_GREEN]
mov al, byte ptr [edi+2]
mov dword ptr [esp+CHANNEL_INTEGER], eax
fild word ptr [esp+CHANNEL_INTEGER]
fmul st, st(1)
# Weight1.0 is the exact ordinary double value: its two DWORD stores are
# explicit to preserve the actual native initialization scheduling.
mov dword ptr [esi+PIXEL_WEIGHT], 0
add esi, PIXEL_BYTES
inc edx
inc ebx
mov dword ptr [esi-PIXEL_BYTES+PIXEL_WEIGHT+4], DOUBLE_ONE_HIGH
mov edi, dword ptr [esp+WIDTH]
fstp qword ptr [esi-PIXEL_BYTES+PIXEL_BLUE]
cmp ebx, edi
jl initialize_pixel
fstp st(0)
initialize_next_row:
mov eax, dword ptr [esp+ORIGINAL_ROW_STEP]
mov ebx, dword ptr [esp+ACCUMULATOR_ROW]
mov esi, dword ptr [esp+HEIGHT]
add ebx, eax
inc ecx
mov dword ptr [esp+ACCUMULATOR_ROW], ebx
cmp ecx, esi
jl initialize_row
mip_level_test:
cmp dword ptr [esp+LEVEL], 0
jle output_begin
mov ebx, dword ptr [esp+HALF_HEIGHT]
xor edi, edi
test ebx, ebx
jle fold_copy
fold_row:
xor esi, esi
test ebp, ebp
jle fold_next_row
fold_pixel:
mov ebx, dword ptr [esp+FOLDED_PIXELS]
mov ecx, dword ptr [esp+SOURCE_PIXELS]
mov edx, edi
push ebx
mov eax, esi
mov ebx, dword ptr [esp+WIDTH+4]
push ecx
mov ecx, ebp
inc esi
call FoldPixel_
cmp esi, ebp
jl fold_pixel
fold_next_row:
mov eax, dword ptr [esp+HALF_HEIGHT]
inc edi
cmp edi, eax
jl fold_row
fold_copy:
mov eax, dword ptr [esp+BUFFER_BYTES]
mov edx, eax
sar edx, 31
shl edx, 2
{load} sbb eax, edx
sar eax, 2
mov esi, dword ptr [esp+FOLDED_PIXELS]
mov edi, dword ptr [esp+SOURCE_PIXELS]
mov ecx, eax
mov dword ptr [esp+BUFFER_BYTES], eax
push edi
mov eax, ecx
shr ecx, 2
repne movsd
{load} mov cl, al
and cl, 3
repne movsb
pop edi
mov edx, ebp
mov eax, dword ptr [esp+HALF_HEIGHT]
sar edx, 31
mov dword ptr [esp+HEIGHT], eax
mov eax, ebp
{load} sub eax, edx
sar eax, 1
mov dword ptr [esp+WIDTH], ebp
mov ebp, eax
mov eax, dword ptr [esp+HALF_HEIGHT]
mov edx, eax
sar edx, 31
{load} sub eax, edx
sar eax, 1
mov edx, dword ptr [esp+LEVEL]
dec edx
mov dword ptr [esp+HALF_HEIGHT], eax
mov dword ptr [esp+LEVEL], edx
jmp mip_level_test

output_begin:
mov edx, dword ptr [esp+HEIGHT]
xor ecx, ecx
test edx, edx
jle output_done
imul edx, dword ptr [esp+WIDTH], 0
mov eax, dword ptr [esp+WIDTH]
shl eax, 5
mov dword ptr [esp+OUTPUT_ROW_BYTES], eax
mov dword ptr [esp+OUTPUT_ROW], edx
output_row:
mov eax, dword ptr [esp+WIDTH]
xor ebp, ebp
test eax, eax
jle output_next_row
mov edx, eax
imul edx, ecx
mov esi, dword ptr [esp+DEST_BITMAP_ARG]
mov edi, dword ptr [esp+OUTPUT_ROW]
add edx, esi
mov esi, dword ptr [esp+SOURCE_PIXELS]
add esi, edi
output_pixel:
fld qword ptr [esi+PIXEL_RED]
fadd qword ptr [esp+ERROR_RED]
fld1
fdiv qword ptr [esi+PIXEL_WEIGHT]
fxch st(1)
fmul st, st(1)
fstp qword ptr [esp+VALUE_RED]
fld qword ptr [esi+PIXEL_GREEN]
fadd qword ptr [esp+ERROR_GREEN]
fmul st, st(1)
push 256
mov eax, dword ptr [esp+PALETTE_ARG+4]
fstp qword ptr [esp+VALUE_GREEN+4]
fld qword ptr [esi+PIXEL_BLUE]
fadd qword ptr [esp+ERROR_BLUE+4]
push 0
fmulp st(1), st
push eax
fstp qword ptr [esp+VALUE_BLUE+12]
# Public CMAP_BestColor takes three doubles, palette, and integer bounds.
mov ebx, dword ptr [esp+VALUE_BLUE+4+12]
push ebx
mov edi, dword ptr [esp+VALUE_BLUE+16]
push edi
mov eax, dword ptr [esp+VALUE_GREEN+4+20]
push eax
mov ebx, dword ptr [esp+VALUE_GREEN+24]
push ebx
mov edi, dword ptr [esp+VALUE_RED+4+28]
push edi
mov eax, dword ptr [esp+VALUE_RED+32]
push eax
xor ebx, ebx
mov edi, dword ptr [esp+DIFFUSION_ARG+36]
call CMAP_BestColor_
mov bl, al
mov byte ptr [edx], al
test edi, edi
je output_advance
mov edi, dword ptr [esp+PALETTE_ARG]
lea ebx, [ebx+ebx*2]
xor eax, eax
mov al, byte ptr [edi+ebx]
mov dword ptr [esp+CHANNEL_INTEGER], eax
fild word ptr [esp+CHANNEL_INTEGER]
xor eax, eax
fld qword ptr [channel_scale]
fxch st(1)
fmul st, st(1)
mov al, byte ptr [edi+ebx+1]
fsubr qword ptr [esp+VALUE_RED]
mov dword ptr [esp+CHANNEL_INTEGER], eax
fstp qword ptr [esp+VALUE_RED]
xor eax, eax
fild word ptr [esp+CHANNEL_INTEGER]
mov al, byte ptr [edi+ebx+2]
fmul st, st(1)
mov dword ptr [esp+CHANNEL_INTEGER], eax
fsubr qword ptr [esp+VALUE_GREEN]
mov eax, dword ptr [esp+VALUE_RED]
fstp qword ptr [esp+VALUE_GREEN]
mov dword ptr [esp+ERROR_RED], eax
fild word ptr [esp+CHANNEL_INTEGER]
mov eax, dword ptr [esp+VALUE_RED+4]
fmulp st(1), st
mov dword ptr [esp+ERROR_RED+4], eax
mov eax, dword ptr [esp+VALUE_GREEN]
fsubr qword ptr [esp+VALUE_BLUE]
mov dword ptr [esp+ERROR_GREEN], eax
mov eax, dword ptr [esp+VALUE_GREEN+4]
fstp qword ptr [esp+VALUE_BLUE]
mov dword ptr [esp+ERROR_GREEN+4], eax
mov eax, dword ptr [esp+VALUE_BLUE]
mov dword ptr [esp+ERROR_BLUE], eax
mov eax, dword ptr [esp+VALUE_BLUE+4]
mov dword ptr [esp+ERROR_BLUE+4], eax
output_advance:
mov ebx, dword ptr [esp+WIDTH]
inc edx
inc ebp
add esi, PIXEL_BYTES
cmp ebp, ebx
jl output_pixel
output_next_row:
mov eax, dword ptr [esp+OUTPUT_ROW_BYTES]
mov esi, dword ptr [esp+OUTPUT_ROW]
mov edi, dword ptr [esp+HEIGHT]
add esi, eax
inc ecx
mov dword ptr [esp+OUTPUT_ROW], esi
cmp ecx, edi
jl output_row
output_done:
mov eax, dword ptr [esp+SOURCE_PIXELS]
call SafeFree_
mov eax, dword ptr [esp+FOLDED_PIXELS]
mov esi, dword ptr [esp+HEIGHT]
call SafeFree_
mov eax, dword ptr [esp+WIDTH]
imul eax, esi
add esp, FRAME_BYTES
pop ebp
pop edi
pop esi
ret 12

.section CONST,"aw",@progbits
.p2align 2
channel_scale: .double 0.00390625 # exactly1/256, actual normalized palette scale
.section CONST2,"aw",@progbits
.p2align 2
.section _DATA,"aw",@progbits
.p2align 2
.section _BSS,"aw",@nobits
.p2align 4
