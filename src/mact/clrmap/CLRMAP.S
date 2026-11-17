# Complete CLRMAP semantic reconstruction; readable C/primary notices accompany it.
# This is authored symbolic source, not historical recovered ASM.
# Legacy mutations/ranges and the real typed six-sector CS table are retained.
.intel_syntax noprefix
.code32
.file "CLRMAP.S"
.extern __CHP
.globl __CHP
.extern "IF@DPOW"
.globl "IF@DPOW"
.extern SafeMalloc_
.globl SafeMalloc_
.extern SafeFree_
.globl SafeFree_
.extern _fltused_
.globl _fltused_
.extern __init_387_emulator
.globl __init_387_emulator
.extern __8087
.globl __8087
.globl HSV_TO_RGB_
.globl RGB_TO_HSV_
.globl GetDarkenedColor_
.globl RGB_TO_YIQ_
.globl YIQ_TO_RGB_
.globl RGB_TO_XYZ_
.globl XYZ_TO_RGB_
.globl XYZ_TO_LUV_
.globl LUV_TO_XYZ_
.globl CMAP_BuildYIQPalette_
.globl CMAP_GetBestColor_
.globl CMAP_GetBestColorFast_
.globl CMAP_GetBestYIQColor_
.globl CMAP_BestColor_
.globl CMAP_CreateFloatPalette_
.globl CMAP_CalculateTranslucentMap_
.globl CMAP_CalculateColorMap_
.globl CMAP_CalculateLightMap_
.globl CMAP_BuildColorMap_
.globl CMAP_BuildMonochromeMap_
.globl CMAP_GetIntensity_
.globl CMAP_FindEGAColors_
.globl _egacolor
.include "COLOR_BITS.INC"
.section _TEXT,"ax",@progbits
.p2align 4
hsv_sector_table:
.long hsv_sector_red_yellow,hsv_sector_yellow_green,hsv_sector_green_cyan,hsv_sector_cyan_blue,hsv_sector_blue_magenta,hsv_sector_magenta_red

# HSV_TO_RGB_ -- full ordinary C counterpart retained.
HSV_TO_RGB_:
push ebx
push ecx
push esi
push edi
sub esp, 0x24
mov ebx, eax
fld qword ptr [eax + 8]
fabs
fcomp qword ptr [0 + hsv_achromatic_epsilon]
fnstsw ax
sahf
ja hsv_to_rgb_branch_1
mov eax, dword ptr [ebx + 0x10]
mov dword ptr [edx], eax
mov eax, dword ptr [ebx + 0x14]
mov dword ptr [edx + 4], eax
mov eax, dword ptr [ebx + 0x10]
mov dword ptr [edx + 8], eax
mov eax, dword ptr [ebx + 0x14]
mov dword ptr [edx + 0xc], eax
mov eax, dword ptr [ebx + 0x10]
mov dword ptr [edx + 0x10], eax
mov eax, dword ptr [ebx + 0x14]
{disp32} jmp hsv_to_rgb_branch_2
hsv_to_rgb_branch_1:
mov ecx, dword ptr [ebx + 4]
mov esi, dword ptr [ebx]
cmp ecx, HUE_CIRCLE_BITS_HI
jne hsv_to_rgb_branch_3
test esi, esi
jne hsv_to_rgb_branch_3
mov dword ptr [ebx], 0
mov dword ptr [ebx + 4], 0
hsv_to_rgb_branch_3:
fld qword ptr [ebx]
fmul qword ptr [hsv_sector_scale]
fst qword ptr [ebx]
call __CHP
fist dword ptr [esp + 0x20]
fsubr qword ptr [ebx]
fld1
fsub qword ptr [ebx + 8]
fmul qword ptr [ebx + 0x10]
fstp qword ptr [esp + 0x18]
fld qword ptr [ebx + 8]
fmul st(1)
fld1
fsubrp st(1)
fmul qword ptr [ebx + 0x10]
fstp qword ptr [esp + 8]
fld1
fsubrp st(1)
fmul qword ptr [ebx + 8]
fld1
fsubrp st(1)
fmul qword ptr [ebx + 0x10]
mov edi, dword ptr [esp + 0x20]
fstp qword ptr [esp + 0x10]
cmp edi, 5
{disp32} ja hsv_to_rgb_branch_4
mov eax, edi
jmp dword ptr cs:[eax*4 + hsv_sector_table]
hsv_sector_red_yellow:
mov eax, dword ptr [esp + 0x10]
fld qword ptr [ebx + 0x10]
mov dword ptr [edx + 8], eax
mov eax, dword ptr [esp + 0x14]
mov dword ptr [edx + 0xc], eax
mov eax, dword ptr [esp + 0x18]
mov dword ptr [edx + 0x10], eax
mov eax, dword ptr [esp + 0x1c]
fstp qword ptr [edx]
mov dword ptr [edx + 0x14], eax
add esp, 0x24
pop edi
pop esi
pop ecx
pop ebx
ret
hsv_sector_yellow_green:
mov eax, dword ptr [esp + 8]
mov dword ptr [edx], eax
mov eax, dword ptr [esp + 0xc]
mov dword ptr [edx + 4], eax
mov eax, dword ptr [esp + 0x18]
fld qword ptr [ebx + 0x10]
mov dword ptr [edx + 0x10], eax
mov eax, dword ptr [esp + 0x1c]
fstp qword ptr [edx + 8]
mov dword ptr [edx + 0x14], eax
add esp, 0x24
pop edi
pop esi
pop ecx
pop ebx
ret
hsv_sector_green_cyan:
mov eax, dword ptr [esp + 0x18]
mov dword ptr [edx], eax
mov eax, dword ptr [esp + 0x1c]
mov dword ptr [edx + 4], eax
mov eax, dword ptr [esp + 0x10]
fld qword ptr [ebx + 0x10]
mov dword ptr [edx + 0x10], eax
mov eax, dword ptr [esp + 0x14]
fstp qword ptr [edx + 8]
mov dword ptr [edx + 0x14], eax
add esp, 0x24
pop edi
pop esi
pop ecx
pop ebx
ret
hsv_sector_cyan_blue:
mov eax, dword ptr [esp + 0x18]
mov dword ptr [edx], eax
mov eax, dword ptr [esp + 0x1c]
mov dword ptr [edx + 4], eax
mov eax, dword ptr [esp + 8]
mov dword ptr [edx + 8], eax
mov eax, dword ptr [esp + 0xc]
mov dword ptr [edx + 0xc], eax
mov eax, dword ptr [ebx + 0x10]
mov dword ptr [edx + 0x10], eax
mov eax, dword ptr [ebx + 0x14]
mov dword ptr [edx + 0x14], eax
add esp, 0x24
pop edi
pop esi
pop ecx
pop ebx
ret
hsv_sector_blue_magenta:
mov eax, dword ptr [esp + 0x10]
mov dword ptr [edx], eax
mov eax, dword ptr [esp + 0x14]
mov dword ptr [edx + 4], eax
mov eax, dword ptr [esp + 0x18]
mov dword ptr [edx + 8], eax
mov eax, dword ptr [esp + 0x1c]
mov dword ptr [edx + 0xc], eax
mov eax, dword ptr [ebx + 0x10]
mov dword ptr [edx + 0x10], eax
mov eax, dword ptr [ebx + 0x14]
mov dword ptr [edx + 0x14], eax
add esp, 0x24
pop edi
pop esi
pop ecx
pop ebx
ret
hsv_sector_magenta_red:
mov eax, dword ptr [esp + 0x18]
fld qword ptr [ebx + 0x10]
mov dword ptr [edx + 8], eax
mov eax, dword ptr [esp + 0x1c]
mov dword ptr [edx + 0xc], eax
mov eax, dword ptr [esp + 8]
mov dword ptr [edx + 0x10], eax
mov eax, dword ptr [esp + 0xc]
fstp qword ptr [edx]
hsv_to_rgb_branch_2:
mov dword ptr [edx + 0x14], eax
hsv_to_rgb_branch_4:
add esp, 0x24
pop edi
pop esi
pop ecx
pop ebx
ret

# RGB_TO_HSV_ -- full ordinary C counterpart retained.
RGB_TO_HSV_:
push ebx
push ecx
sub esp, 0x30
mov ebx, dword ptr [eax]
mov dword ptr [esp + 0x18], ebx
mov ebx, dword ptr [eax + 4]
mov dword ptr [esp + 0x1c], ebx
mov ebx, dword ptr [eax + 8]
mov dword ptr [esp + 0x20], ebx
mov ebx, dword ptr [eax + 0xc]
fld qword ptr [esp + 0x18]
mov dword ptr [esp + 0x24], ebx
mov ebx, dword ptr [eax + 0x10]
mov eax, dword ptr [eax + 0x14]
mov dword ptr [esp + 0x28], ebx
mov dword ptr [esp + 0x2c], eax
fcomp qword ptr [esp + 0x20]
fnstsw ax
sahf
jbe rgb_to_hsv_branch_1
fld qword ptr [esp + 0x18]
fcomp qword ptr [esp + 0x28]
fnstsw ax
sahf
jbe rgb_to_hsv_branch_2
mov eax, dword ptr [esp + 0x18]
mov dword ptr [esp], eax
mov eax, dword ptr [esp + 0x1c]
jmp rgb_to_hsv_branch_3
rgb_to_hsv_branch_1:
fld qword ptr [esp + 0x20]
fcomp qword ptr [esp + 0x28]
fnstsw ax
sahf
jbe rgb_to_hsv_branch_2
mov eax, dword ptr [esp + 0x20]
mov dword ptr [esp], eax
mov eax, dword ptr [esp + 0x24]
jmp rgb_to_hsv_branch_3
rgb_to_hsv_branch_2:
mov eax, dword ptr [esp + 0x2c]
mov dword ptr [esp], ebx
rgb_to_hsv_branch_3:
mov dword ptr [esp + 4], eax
fld qword ptr [esp + 0x18]
fcomp qword ptr [esp + 0x20]
fnstsw ax
sahf
jae rgb_to_hsv_branch_4
fld qword ptr [esp + 0x18]
fcomp qword ptr [esp + 0x28]
fnstsw ax
sahf
jae rgb_to_hsv_branch_5
mov eax, dword ptr [esp + 0x18]
mov dword ptr [esp + 0x10], eax
mov eax, dword ptr [esp + 0x1c]
jmp rgb_to_hsv_branch_6
rgb_to_hsv_branch_4:
fld qword ptr [esp + 0x20]
fcomp qword ptr [esp + 0x28]
fnstsw ax
sahf
jae rgb_to_hsv_branch_5
mov eax, dword ptr [esp + 0x20]
mov dword ptr [esp + 0x10], eax
mov eax, dword ptr [esp + 0x24]
jmp rgb_to_hsv_branch_6
rgb_to_hsv_branch_5:
mov eax, dword ptr [esp + 0x28]
mov dword ptr [esp + 0x10], eax
mov eax, dword ptr [esp + 0x2c]
rgb_to_hsv_branch_6:
mov dword ptr [esp + 0x14], eax
mov eax, dword ptr [esp]
mov dword ptr [edx + 0x10], eax
mov eax, dword ptr [esp + 4]
mov ecx, dword ptr [esp]
mov dword ptr [edx + 0x14], eax
test eax, 0x7fffffff
jne rgb_to_hsv_branch_7
test ecx, ecx
je rgb_to_hsv_branch_8
rgb_to_hsv_branch_7:
fld qword ptr [esp]
fld st(0)
fsub qword ptr [esp + 0x10]
fdivrp st(1)
fstp qword ptr [edx + 8]
jmp rgb_to_hsv_branch_9
rgb_to_hsv_branch_8:
mov dword ptr [edx + 8], 0
mov dword ptr [edx + 0xc], 0
rgb_to_hsv_branch_9:
fld qword ptr [edx + 8]
fabs
fcomp qword ptr [rgb_achromatic_epsilon]
fnstsw ax
sahf
ja rgb_to_hsv_branch_10
mov dword ptr [edx], 0
mov dword ptr [edx + 4], UNDEFINED_HUE_BITS_HI
{disp32} jmp rgb_to_hsv_branch_11
rgb_to_hsv_branch_10:
fld qword ptr [esp]
fld st(0)
fsub qword ptr [esp + 0x10]
fstp qword ptr [esp + 8]
fld qword ptr [esp + 0x18]
fcompp
fnstsw ax
sahf
jne rgb_to_hsv_branch_12
fld qword ptr [esp + 0x20]
fsub qword ptr [esp + 0x28]
fdiv qword ptr [esp + 8]
jmp rgb_to_hsv_branch_13
rgb_to_hsv_branch_12:
fld qword ptr [esp + 0x20]
fcomp qword ptr [esp]
fnstsw ax
sahf
jne rgb_to_hsv_branch_14
fld qword ptr [esp + 0x28]
fsub qword ptr [esp + 0x18]
fdiv qword ptr [esp + 8]
fadd qword ptr [hue_green_sector]
jmp rgb_to_hsv_branch_13
rgb_to_hsv_branch_14:
fld qword ptr [esp + 0x28]
fcomp qword ptr [esp]
fnstsw ax
sahf
jne rgb_to_hsv_branch_15
fld qword ptr [esp + 0x18]
fsub qword ptr [esp + 0x20]
fdiv qword ptr [esp + 8]
fadd qword ptr [hue_blue_sector]
rgb_to_hsv_branch_13:
fstp qword ptr [edx]
rgb_to_hsv_branch_15:
fld qword ptr [edx]
fmul qword ptr [hue_sector_degrees]
fstp qword ptr [edx]
fldz
fcomp qword ptr [edx]
fnstsw ax
sahf
jbe rgb_to_hsv_branch_11
fld qword ptr [edx]
fadd qword ptr [hue_circle_degrees]
fstp qword ptr [edx]
rgb_to_hsv_branch_11:
add esp, 0x30
pop ecx
pop ebx
ret
{disp8} lea eax, [eax]

# GetDarkenedColor_ -- full ordinary C counterpart retained.
GetDarkenedColor_:
push ecx
push esi
push ebp
sub esp, 0x44
mov esi, eax
mov ecx, edx
mov edx, esp
call RGB_TO_HSV_
dec ebx
fld qword ptr [esp + 8]
mov dword ptr [esp + 0x40], ebx
fcomp qword ptr [dark_achromatic_epsilon]
fnstsw ax
sahf
{disp32} jb getdarkenedcolor_branch_1
fld1
fsub qword ptr [esp + 8]
fild dword ptr [esp + 0x40]
fld1
fdivrp st(1)
fxch st(1)
fmul st(1)
fstp qword ptr [esp + 0x38]
fmul qword ptr [esp + 0x10]
xor eax, eax
fstp qword ptr [esp + 0x28]
test ecx, ecx
jle getdarkenedcolor_branch_2
fld qword ptr [esp + 0x28]
fld qword ptr [esp + 0x38]
getdarkenedcolor_branch_3:
fld qword ptr [esp + 8]
fadd st(1)
fstp qword ptr [esp + 8]
fld qword ptr [esp + 0x10]
fsub st(2)
inc eax
fstp qword ptr [esp + 0x10]
cmp eax, ecx
jl getdarkenedcolor_branch_3
fstp st(0)
fstp st(0)
getdarkenedcolor_branch_2:
fldz
fcomp qword ptr [esp + 0x10]
fnstsw ax
sahf
jbe getdarkenedcolor_branch_4
xor ebp, ebp
mov dword ptr [esp + 0x10], ebp
mov dword ptr [esp + 0x14], ebp
getdarkenedcolor_branch_4:
fld1
fcomp qword ptr [esp + 8]
fnstsw ax
sahf
jae getdarkenedcolor_branch_5
xor edx, edx
mov ebx, FP_ONE_BITS_HI
mov dword ptr [esp + 8], edx
mov dword ptr [esp + 0xc], ebx
jmp getdarkenedcolor_branch_5
getdarkenedcolor_branch_1:
fild dword ptr [esp + 0x40]
fdivr qword ptr [esp + 0x10]
mov ebx, UNDEFINED_HUE_BITS_HI
xor edx, edx
xor eax, eax
mov dword ptr [esp], edx
mov dword ptr [esp + 4], ebx
fstp qword ptr [esp + 0x30]
test ecx, ecx
jle getdarkenedcolor_branch_6
fld qword ptr [esp + 0x30]
getdarkenedcolor_branch_7:
fld qword ptr [esp + 0x10]
fsub st(1)
inc eax
fstp qword ptr [esp + 0x10]
cmp eax, ecx
jl getdarkenedcolor_branch_7
fstp st(0)
getdarkenedcolor_branch_6:
fldz
fcomp qword ptr [esp + 0x10]
fnstsw ax
sahf
jbe getdarkenedcolor_branch_5
xor ecx, ecx
mov dword ptr [esp + 0x10], ecx
mov dword ptr [esp + 0x14], ecx
getdarkenedcolor_branch_5:
mov eax, esp
mov edx, esi
call HSV_TO_RGB_
add esp, 0x44
pop ebp
pop esi
pop ecx
ret
{disp8} lea eax, [eax]

# RGB_TO_YIQ_ -- full ordinary C counterpart retained.
RGB_TO_YIQ_:
fld qword ptr [eax + 8]
fmul qword ptr [yiq_y_green]
fld qword ptr [eax]
fmul qword ptr [yiq_y_red]
faddp st(1)
fld qword ptr [eax + 0x10]
fmul qword ptr [yiq_y_blue]
faddp st(1)
fstp qword ptr [edx]
fld qword ptr [eax + 8]
fmul qword ptr [yiq_i_green]
fld qword ptr [eax]
fmul qword ptr [yiq_i_red]
fsubrp st(1)
fld qword ptr [eax + 0x10]
fmul qword ptr [yiq_i_blue]
fsubp st(1)
fstp qword ptr [edx + 8]
fld qword ptr [eax + 8]
fmul qword ptr [yiq_q_green]
fld qword ptr [eax]
fmul qword ptr [yiq_q_red]
fsubrp st(1)
fld qword ptr [eax + 0x10]
fmul qword ptr [yiq_q_blue]
faddp st(1)
fstp qword ptr [edx + 0x10]
ret
nop

# YIQ_TO_RGB_ -- full ordinary C counterpart retained.
YIQ_TO_RGB_:
fld qword ptr [eax + 8]
fmul qword ptr [yiq_inverse_r_i]
fadd qword ptr [eax]
fld qword ptr [eax + 0x10]
fmul qword ptr [yiq_inverse_r_q]
faddp st(1)
fstp qword ptr [edx]
fld qword ptr [eax + 8]
fmul qword ptr [yiq_inverse_g_i]
fsubr qword ptr [eax]
fld qword ptr [eax + 0x10]
fmul qword ptr [yiq_inverse_g_q]
fsubp st(1)
fstp qword ptr [edx + 8]
fld qword ptr [eax + 8]
fmul qword ptr [yiq_inverse_b_i]
fsubr qword ptr [eax]
fld qword ptr [eax + 0x10]
fmul qword ptr [yiq_inverse_b_q]
faddp st(1)
fstp qword ptr [edx + 0x10]
ret
nop

# RGB_TO_XYZ_ -- full ordinary C counterpart retained.
RGB_TO_XYZ_:
fld qword ptr [eax + 8]
fmul qword ptr [xyz_x_green]
fld qword ptr [eax]
fmul qword ptr [xyz_x_red]
faddp st(1)
fld qword ptr [eax + 0x10]
fmul qword ptr [xyz_x_blue]
faddp st(1)
fstp qword ptr [edx]
fld qword ptr [eax + 8]
fmul qword ptr [xyz_y_green]
fld qword ptr [eax]
fmul qword ptr [xyz_y_red]
faddp st(1)
fld qword ptr [eax + 0x10]
fmul qword ptr [xyz_y_blue]
faddp st(1)
fstp qword ptr [edx + 8]
fld qword ptr [eax + 8]
fmul qword ptr [xyz_z_green]
fld qword ptr [eax]
fmul qword ptr [xyz_z_red]
faddp st(1)
fld qword ptr [eax + 0x10]
fmul qword ptr [xyz_z_blue_legacy]
faddp st(1)
fstp qword ptr [edx + 0x10]
ret
nop

# XYZ_TO_RGB_ -- full ordinary C counterpart retained.
XYZ_TO_RGB_:
fld qword ptr [eax + 8]
fmul qword ptr [xyz_inverse_r_y]
fld qword ptr [eax]
fmul qword ptr [xyz_inverse_r_x]
fsubrp st(1)
fld qword ptr [eax + 0x10]
fmul qword ptr [xyz_inverse_r_z]
fsubp st(1)
fstp qword ptr [edx]
fld qword ptr [eax + 8]
fmul qword ptr [xyz_inverse_g_y]
fld qword ptr [eax]
fmul qword ptr [xyz_inverse_g_x]
faddp st(1)
fld qword ptr [eax + 0x10]
fmul qword ptr [xyz_inverse_g_z]
faddp st(1)
fstp qword ptr [edx + 8]
fld qword ptr [eax + 8]
fmul qword ptr [xyz_inverse_b_y]
fld qword ptr [eax]
fmul qword ptr [xyz_inverse_b_x]
fsubrp st(1)
fld qword ptr [eax + 0x10]
fmul qword ptr [xyz_inverse_b_z]
faddp st(1)
fstp qword ptr [edx + 0x10]
fldz
fcomp qword ptr [edx]
fnstsw ax
sahf
jbe xyz_to_rgb_branch_1
mov dword ptr [edx], 0
mov dword ptr [edx + 4], 0
xyz_to_rgb_branch_1:
fldz
fcomp qword ptr [edx + 8]
fnstsw ax
sahf
jbe xyz_to_rgb_branch_2
mov dword ptr [edx + 8], 0
mov dword ptr [edx + 0xc], 0
xyz_to_rgb_branch_2:
fldz
fcomp qword ptr [edx + 0x10]
fnstsw ax
sahf
jbe xyz_to_rgb_branch_3
mov dword ptr [edx + 0x10], 0
mov dword ptr [edx + 0x14], 0
xyz_to_rgb_branch_3:
ret
{disp8} lea eax, [eax]

# XYZ_TO_LUV_ -- full ordinary C counterpart retained.
XYZ_TO_LUV_:
push ebx
sub esp, 0x20
mov ebx, eax
mov eax, dword ptr [eax + 8]
mov dword ptr [esp + 0x18], eax
mov eax, dword ptr [ebx + 0xc]
mov dword ptr [esp + 0x1c], eax
fld qword ptr [esp + 0x18]
fcomp qword ptr [luv_luminance_knee]
fnstsw ax
sahf
jb xyz_to_luv_branch_1
fld qword ptr [luv_cuberoot_exponent]
fld qword ptr [esp + 0x18]
call "IF@DPOW"
fmul qword ptr [luv_luminance_scale]
fadd qword ptr [luv_luminance_offset]
jmp xyz_to_luv_branch_2
xyz_to_luv_branch_1:
fld qword ptr [esp + 0x18]
fmul qword ptr [luv_linear_slope]
xyz_to_luv_branch_2:
fstp qword ptr [edx]
fldz
fcomp qword ptr [edx]
fnstsw ax
sahf
jb xyz_to_luv_branch_3
mov dword ptr [edx], 0
mov dword ptr [edx + 4], 0
mov dword ptr [edx + 8], 0
mov dword ptr [edx + 0xc], 0
mov dword ptr [edx + 0x10], 0
mov dword ptr [edx + 0x14], 0
add esp, 0x20
pop ebx
ret
xyz_to_luv_branch_3:
fld qword ptr [ebx + 8]
fmul qword ptr [luv_denominator_y]
fadd qword ptr [ebx]
fld qword ptr [ebx + 0x10]
fmul qword ptr [luv_denominator_z]
faddp st(1)
fld qword ptr [ebx]
fmul qword ptr [luv_u_numerator]
fld1
fdivrp st(2)
fmul st(1)
fld qword ptr [ebx + 8]
fmul qword ptr [luv_v_numerator]
fmulp st(2)
fld qword ptr [luv_chroma_scale]
fld qword ptr [edx]
fmul st(1)
fxch st(2)
fsub qword ptr [luv_white_u]
fmulp st(2)
fxch st(1)
fstp qword ptr [edx + 8]
fmul qword ptr [edx]
fxch st(1)
fsub qword ptr [luv_white_v]
fmulp st(1)
fstp qword ptr [edx + 0x10]
add esp, 0x20
pop ebx
ret
nop

# LUV_TO_XYZ_ -- full ordinary C counterpart retained.
LUV_TO_XYZ_:
push ebx
push ecx
push esi
sub esp, 0x20
mov ebx, eax
fld qword ptr [eax]
fabs
fcomp qword ptr [luv_inverse_black_epsilon]
fnstsw ax
sahf
ja luv_to_xyz_branch_1
mov dword ptr [edx], 0
mov dword ptr [edx + 4], 0
mov dword ptr [edx + 8], 0
mov dword ptr [edx + 0xc], 0
mov dword ptr [edx + 0x10], 0
mov dword ptr [edx + 0x14], 0
{disp32} jmp luv_to_xyz_branch_2
luv_to_xyz_branch_1:
fld qword ptr [ebx]
fadd qword ptr [luv_inverse_l_offset]
fmul qword ptr [luv_inverse_l_scale]
fld qword ptr [luv_inverse_l_exponent]
fxch st(1)
call "IF@DPOW"
fstp qword ptr [edx + 8]
fld qword ptr [ebx]
fmul qword ptr [luv_inverse_chroma_scale]
fdivr qword ptr [ebx + 0x10]
fadd qword ptr [luv_inverse_white_v]
fst qword ptr [esp + 0x18]
fabs
mov ecx, LUV_WHITE_U_BITS_LO
mov esi, LUV_WHITE_U_BITS_HI
mov dword ptr [esp + 0x10], ecx
mov dword ptr [esp + 0x14], esi
fcomp qword ptr [luv_inverse_v_limit]
fnstsw ax
sahf
jae luv_to_xyz_branch_3
fld qword ptr [ebx + 0x10]
fchs
fdiv qword ptr [luv_inverse_legacy_denominator]
fst qword ptr [ebx]
fmul qword ptr [luv_inverse_chroma_scale]
fdivr qword ptr [ebx + 0x10]
fadd qword ptr [luv_inverse_white_v]
fstp qword ptr [esp + 0x18]
luv_to_xyz_branch_3:
fld qword ptr [ebx]
fmul qword ptr [luv_inverse_chroma_scale]
fdivr qword ptr [ebx + 8]
fadd qword ptr [esp + 0x10]
fld qword ptr [luv_inverse_l_exponent]
fld qword ptr [edx + 8]
fmul st(1)
fld qword ptr [esp + 0x18]
fld st(0)
fmul qword ptr [luv_inverse_z_v_multiplier]
fadd qword ptr [luv_inverse_z_offset]
fmulp st(2)
fld st(3)
fmul qword ptr [luv_inverse_cross_scale]
fmul st(1)
fmul qword ptr [edx + 8]
fxch st(4)
fadd qword ptr [luv_inverse_u_offset]
fmul st(2)
fsubrp st(4)
fld st(0)
fmul qword ptr [luv_inverse_z_divisor]
fdivp st(4)
fxch st(3)
fst qword ptr [edx + 0x10]
fmulp st(2)
fdivrp st(2)
faddp st(1)
fchs
fstp qword ptr [edx]
luv_to_xyz_branch_2:
add esp, 0x20
pop esi
pop ecx
pop ebx
ret
{load} mov eax, eax

# CMAP_BuildYIQPalette_ -- full ordinary C counterpart retained.
CMAP_BuildYIQPalette_:
push esi
push edi
sub esp, 0x20
mov edi, eax
mov esi, edx
mov byte ptr [esp + 0x1c], cl
xor eax, eax
mov al, cl
xor ecx, ecx
mov cl, bl
sub eax, ecx
lea ebx, [eax + 1]
lea eax, [ebx*4]
sub eax, ebx
shl eax, 3
call SafeMalloc_
mov dword ptr [edi], eax
lea eax, [ecx*4]
sub eax, ecx
mov ebx, dword ptr [edi]
lea esi, [edx + eax]
xor eax, eax
mov al, byte ptr [esp + 0x1c]
cmp ecx, eax
jl cmap_buildyiqpalette_branch_1
add esp, 0x20
pop edi
pop esi
ret
cmap_buildyiqpalette_branch_1:
xor eax, eax
mov al, byte ptr [esi]
mov dword ptr [esp + 0x18], eax
fld qword ptr [yiq_palette_byte_scale]
fild word ptr [esp + 0x18]
fmul st(1)
xor eax, eax
fstp qword ptr [esp]
mov al, byte ptr [esi + 1]
mov dword ptr [esp + 0x18], eax
fild word ptr [esp + 0x18]
fmul st(1)
xor eax, eax
fstp qword ptr [esp + 8]
mov al, byte ptr [esi + 2]
mov dword ptr [esp + 0x18], eax
fild word ptr [esp + 0x18]
fmulp st(1)
mov edx, ebx
inc ecx
add esi, 3
add ebx, 0x18
mov eax, esp
fstp qword ptr [esp + 0x10]
call RGB_TO_YIQ_
xor eax, eax
mov al, byte ptr [esp + 0x1c]
cmp ecx, eax
jl cmap_buildyiqpalette_branch_1
add esp, 0x20
pop edi
pop esi
ret

# CMAP_GetBestColor_ -- full ordinary C counterpart retained.
CMAP_GetBestColor_:
push esi
push edi
push ebp
sub esp, 0x44
mov esi, eax
mov ebp, edx
mov edi, ecx
mov eax, ebx
mov ecx, DISTORTION_BOUND_BITS_HI
lea edx, [ebx*4]
mov dword ptr [esp + 0x3c], ecx
sub edx, ebx
mov ecx, eax
xor ebx, ebx
add edx, ebp
mov dword ptr [esp + 0x38], ebx
mov ebx, eax
cmp eax, edi
{disp32} jg cmap_getbestcolor_branch_1
cmap_getbestcolor_branch_3:
xor eax, eax
mov al, byte ptr [edx]
mov dword ptr [esp + 0x40], eax
fild word ptr [esp + 0x40]
xor eax, eax
fld qword ptr [best_color_byte_scale]
fxch st(1)
fmul st(1)
mov al, byte ptr [edx + 1]
mov dword ptr [esp + 0x40], eax
fstp qword ptr [esp]
fild word ptr [esp + 0x40]
xor eax, eax
fmul st(1)
mov al, byte ptr [edx + 2]
mov dword ptr [esp + 0x40], eax
fstp qword ptr [esp + 8]
fild word ptr [esp + 0x40]
fmulp st(1)
fstp qword ptr [esp + 0x10]
fld qword ptr [esi]
fsub qword ptr [esp]
fld qword ptr [esi + 8]
fsub qword ptr [esp + 8]
fld qword ptr [esi + 0x10]
fsub qword ptr [esp + 0x10]
fld st(2)
fmulp st(3)
fld st(1)
fmulp st(2)
fxch st(1)
faddp st(2)
{store} fmul st(0), st(0)
faddp st(1)
fst qword ptr [esp + 0x30]
fcomp qword ptr [esp + 0x38]
fnstsw ax
sahf
jae cmap_getbestcolor_branch_2
mov eax, dword ptr [esp + 0x30]
mov dword ptr [esp + 0x38], eax
mov eax, dword ptr [esp + 0x34]
mov ecx, ebx
mov dword ptr [esp + 0x3c], eax
cmap_getbestcolor_branch_2:
inc ebx
add edx, 3
cmp ebx, edi
{disp32} jle cmap_getbestcolor_branch_3
cmap_getbestcolor_branch_1:
mov al, cl
add esp, 0x44
pop ebp
pop edi
pop esi
ret
{load} mov eax, eax

# CMAP_GetBestColorFast_ -- full ordinary C counterpart retained.
CMAP_GetBestColorFast_:
push esi
push edi
sub esp, 0x28
mov esi, eax
mov edi, ecx
mov eax, ebx
xor ebx, ebx
mov ecx, DISTORTION_BOUND_BITS_HI
mov dword ptr [esp + 0x18], ebx
mov dword ptr [esp + 0x1c], ecx
mov ecx, eax
mov ebx, eax
cmp eax, edi
jg cmap_getbestcolorfast_branch_1
cmap_getbestcolorfast_branch_3:
fld qword ptr [esi]
fsub qword ptr [edx]
fld qword ptr [esi + 8]
fsub qword ptr [edx + 8]
fld qword ptr [esi + 0x10]
fsub qword ptr [edx + 0x10]
fld st(2)
fmulp st(3)
fld st(1)
fmulp st(2)
fxch st(1)
faddp st(2)
{store} fmul st(0), st(0)
faddp st(1)
fst qword ptr [esp + 0x20]
fcomp qword ptr [esp + 0x18]
fnstsw ax
sahf
jae cmap_getbestcolorfast_branch_2
mov eax, dword ptr [esp + 0x20]
mov dword ptr [esp + 0x18], eax
mov eax, dword ptr [esp + 0x24]
mov ecx, ebx
mov dword ptr [esp + 0x1c], eax
cmap_getbestcolorfast_branch_2:
inc ebx
add edx, 0x18
cmp ebx, edi
jle cmap_getbestcolorfast_branch_3
cmap_getbestcolorfast_branch_1:
mov al, cl
add esp, 0x28
pop edi
pop esi
ret
{disp8} lea eax, [eax]

# CMAP_GetBestYIQColor_ -- full ordinary C counterpart retained.
CMAP_GetBestYIQColor_:
push esi
push edi
sub esp, 0x28
mov esi, eax
mov edi, ecx
mov eax, ebx
xor ebx, ebx
mov ecx, DISTORTION_BOUND_BITS_HI
mov dword ptr [esp + 0x18], ebx
mov dword ptr [esp + 0x1c], ecx
mov ecx, eax
mov ebx, eax
cmp eax, edi
jg cmap_getbestyiqcolor_branch_1
cmap_getbestyiqcolor_branch_3:
fld qword ptr [esi]
fsub qword ptr [edx]
fld qword ptr [esi + 8]
fsub qword ptr [edx + 8]
fld qword ptr [esi + 0x10]
fsub qword ptr [edx + 0x10]
fld st(2)
fmulp st(3)
fld st(1)
fmulp st(2)
fxch st(1)
faddp st(2)
{store} fmul st(0), st(0)
faddp st(1)
fst qword ptr [esp + 0x20]
fcomp qword ptr [esp + 0x18]
fnstsw ax
sahf
jae cmap_getbestyiqcolor_branch_2
mov eax, dword ptr [esp + 0x20]
mov dword ptr [esp + 0x18], eax
mov eax, dword ptr [esp + 0x24]
mov ecx, ebx
mov dword ptr [esp + 0x1c], eax
cmap_getbestyiqcolor_branch_2:
inc ebx
add edx, 0x18
cmp ebx, edi
jle cmap_getbestyiqcolor_branch_3
cmap_getbestyiqcolor_branch_1:
mov al, cl
add esp, 0x28
pop edi
pop esi
ret
{disp8} lea eax, [eax]

# CMAP_BestColor_ -- full ordinary C counterpart retained.
CMAP_BestColor_:
push ebx
push ecx
push edx
sub esp, 0x18
mov eax, dword ptr [esp + 0x28]
mov dword ptr [esp], eax
mov eax, dword ptr [esp + 0x2c]
mov dword ptr [esp + 4], eax
mov eax, dword ptr [esp + 0x30]
mov dword ptr [esp + 8], eax
mov eax, dword ptr [esp + 0x34]
mov ecx, dword ptr [esp + 0x48]
mov dword ptr [esp + 0xc], eax
mov eax, dword ptr [esp + 0x38]
mov ebx, dword ptr [esp + 0x44]
mov dword ptr [esp + 0x10], eax
mov eax, dword ptr [esp + 0x3c]
mov edx, dword ptr [esp + 0x40]
mov dword ptr [esp + 0x14], eax
mov eax, esp
call CMAP_GetBestColor_
add esp, 0x18
pop edx
pop ecx
pop ebx
ret 0x24
{disp8} lea eax, [eax]

# CMAP_CreateFloatPalette_ -- full ordinary C counterpart retained.
CMAP_CreateFloatPalette_:
push ebx
push ecx
sub esp, 4
mov ecx, eax
mov ebx, edx
mov eax, 0x1800
call SafeMalloc_
xor edx, edx
mov dword ptr [ecx], eax
fld qword ptr [float_palette_byte_scale]
cmap_createfloatpalette_branch_1:
xor eax, eax
mov al, byte ptr [ebx]
mov dword ptr [esp], eax
fild word ptr [esp]
fmul st(1)
mov eax, dword ptr [ecx]
fstp qword ptr [edx + eax]
xor eax, eax
mov al, byte ptr [ebx + 1]
mov dword ptr [esp], eax
fild word ptr [esp]
fmul st(1)
mov eax, dword ptr [ecx]
fstp qword ptr [edx + eax + 8]
xor eax, eax
mov al, byte ptr [ebx + 2]
mov dword ptr [esp], eax
fild word ptr [esp]
fmul st(1)
add edx, 0x18
mov eax, dword ptr [ecx]
add ebx, 3
fstp qword ptr [edx + eax - 8]
cmp edx, 0x1800
jne cmap_createfloatpalette_branch_1
fstp st(0)
add esp, 4
pop ecx
pop ebx
ret
{load} mov eax, eax

# CMAP_CalculateTranslucentMap_ -- full ordinary C counterpart retained.
CMAP_CalculateTranslucentMap_:
push esi
push edi
push ebp
sub esp, 0x3c
mov dword ptr [esp + 0x30], eax
mov dword ptr [esp + 0x2c], eax
lea eax, [esp + 0x34]
call CMAP_CreateFloatPalette_
xor eax, eax
mov al, bl
xor edx, edx
mov dword ptr [esp + 0x38], eax
mov dl, cl
fild word ptr [esp + 0x38]
fmul qword ptr [translucent_weight_scale]
lea eax, [edx*4]
mov edi, dword ptr [esp + 0x34]
mov dword ptr [esp + 0x28], edx
sub eax, edx
fstp qword ptr [esp + 0x18]
fld1
shl eax, 3
fsub qword ptr [esp + 0x18]
add edi, eax
fstp qword ptr [esp + 0x20]
{disp32} jmp cmap_calculatetranslucentmap_branch_1
cmap_calculatetranslucentmap_branch_3:
mov esi, dword ptr [esp + 0x34]
xor ebp, ebp
cmap_calculatetranslucentmap_branch_2:
xor ebx, ebx
mov bl, byte ptr [esp + 0x50]
imul edx, ebx, 0x18
fld qword ptr [esp + 0x20]
fmul qword ptr [esi]
fld qword ptr [esp + 0x18]
fmul qword ptr [edi]
faddp st(1)
fstp qword ptr [esp]
fld qword ptr [esp + 0x20]
fmul qword ptr [esi + 8]
fld qword ptr [esp + 0x18]
fmul qword ptr [edi + 8]
faddp st(1)
fstp qword ptr [esp + 8]
fld qword ptr [esp + 0x20]
fmul qword ptr [esi + 0x10]
fld qword ptr [esp + 0x18]
fmul qword ptr [edi + 0x10]
xor ecx, ecx
mov eax, dword ptr [esp + 0x34]
mov cl, byte ptr [esp + 0x54]
add edx, eax
faddp st(1)
mov eax, esp
fstp qword ptr [esp + 0x10]
call CMAP_GetBestColorFast_
mov edx, dword ptr [esp + 0x30]
inc edx
add esi, 0x18
inc ebp
mov byte ptr [edx - 1], al
mov dword ptr [esp + 0x30], edx
cmp ebp, 0x100
jl cmap_calculatetranslucentmap_branch_2
mov ebx, dword ptr [esp + 0x28]
inc ebx
add edi, 0x18
mov dword ptr [esp + 0x28], ebx
cmap_calculatetranslucentmap_branch_1:
xor eax, eax
mov edx, dword ptr [esp + 0x28]
mov al, byte ptr [esp + 0x4c]
cmp eax, edx
{disp32} jge cmap_calculatetranslucentmap_branch_3
mov eax, dword ptr [esp + 0x34]
mov ecx, dword ptr [esp + 0x2c]
call SafeFree_
mov eax, dword ptr [esp + 0x30]
sub eax, ecx
add esp, 0x3c
pop ebp
pop edi
pop esi
ret 0xc
nop

# CMAP_CalculateColorMap_ -- full ordinary C counterpart retained.
CMAP_CalculateColorMap_:
push esi
push edi
push ebp
sub esp, 0x58
mov dword ptr [esp + 0x4c], eax
mov byte ptr [esp + 0x54], bl
mov ebp, ecx
lea eax, [esp + 0x38]
call CMAP_CreateFloatPalette_
cmp dword ptr [esp + 0x7c], 1
jne cmap_calculatecolormap_branch_1
xor eax, eax
mov esi, 0xffffffff
mov al, bl
mov dword ptr [esp + 0x40], esi
mov dword ptr [esp + 0x48], eax
jmp cmap_calculatecolormap_branch_2
cmap_calculatecolormap_branch_1:
mov ebx, 1
mov dword ptr [esp + 0x48], ebx
mov dword ptr [esp + 0x40], ebx
cmap_calculatecolormap_branch_2:
xor edi, edi
mov dword ptr [esp + 0x44], edi
{disp32} jmp cmap_calculatecolormap_branch_3
cmap_calculatecolormap_branch_6:
movzx edi, byte ptr [esp + 0x6c]
imul esi, edi, 0x18
add esi, dword ptr [esp + 0x38]
{disp32} jmp cmap_calculatecolormap_branch_4
cmap_calculatecolormap_branch_5:
xor eax, eax
fld qword ptr [ebp]
mov al, byte ptr [esp + 0x68]
fsub qword ptr [esi]
mov dword ptr [esp + 0x50], eax
fild word ptr [esp + 0x50]
fld st(1)
fmul st(1)
fld qword ptr [colormap_weight_scale]
fxch st(1)
fmul st(1)
fstp st(3)
fld qword ptr [ebp + 8]
fsub qword ptr [esi + 8]
fld st(0)
fmul st(3)
fmul st(2)
fstp st(1)
fld qword ptr [ebp + 0x10]
fsub qword ptr [esi + 0x10]
xor ebx, ebx
fmul st(3), st(0)
mov bl, byte ptr [esp + 0x54]
mov edx, dword ptr [esp + 0x48]
mov eax, ebx
fxch st(3)
fmulp st(2)
sub eax, edx
dec ebx
mov dword ptr [esp + 0x3c], eax
fxch st(1)
fstp st(2)
fild dword ptr [esp + 0x3c]
fxch st(3)
fmul st(3)
mov dword ptr [esp + 0x3c], ebx
fild dword ptr [esp + 0x3c]
fld1
fdivrp st(1)
xor ebx, ebx
mov bl, byte ptr [esp + 0x74]
imul edx, ebx, 0x18
fxch st(1)
fmul st(1)
fadd qword ptr [esi]
fstp qword ptr [esp]
fxch st(1)
fmul st(3)
fmul st(1)
fadd qword ptr [esi + 8]
fstp qword ptr [esp + 8]
fxch st(1)
fmulp st(2)
fmulp st(1)
xor ecx, ecx
mov eax, dword ptr [esp + 0x38]
mov cl, byte ptr [esp + 0x78]
add edx, eax
fadd qword ptr [esi + 0x10]
mov eax, esp
fstp qword ptr [esp + 0x10]
call CMAP_GetBestColorFast_
mov edx, dword ptr [esp + 0x4c]
inc edx
inc edi
add esi, 0x18
mov byte ptr [edx - 1], al
mov dword ptr [esp + 0x4c], edx
cmap_calculatecolormap_branch_4:
xor eax, eax
mov al, byte ptr [esp + 0x70]
cmp edi, eax
{disp32} jle cmap_calculatecolormap_branch_5
mov eax, dword ptr [esp + 0x40]
mov ecx, dword ptr [esp + 0x48]
mov esi, dword ptr [esp + 0x44]
add ecx, eax
inc esi
mov dword ptr [esp + 0x48], ecx
mov dword ptr [esp + 0x44], esi
cmap_calculatecolormap_branch_3:
xor eax, eax
mov edx, dword ptr [esp + 0x44]
mov al, byte ptr [esp + 0x54]
cmp eax, edx
{disp32} jg cmap_calculatecolormap_branch_6
add esp, 0x58
pop ebp
pop edi
pop esi
ret 0x18
nop

# CMAP_CalculateLightMap_ -- full ordinary C counterpart retained.
CMAP_CalculateLightMap_:
push esi
push edi
push ebp
sub esp, 0x7c
mov ebp, eax
mov byte ptr [esp + 0x78], bl
mov bl, byte ptr [esp + 0x8c]
xor eax, eax
mov al, cl
mov dword ptr [esp + 0x74], eax
xor eax, eax
fild word ptr [esp + 0x74]
mov al, bl
fstp qword ptr [esp + 0x50]
mov dword ptr [esp + 0x74], eax
mov eax, dword ptr [esp + 0x50]
mov dword ptr [esp + 0x60], eax
mov eax, dword ptr [esp + 0x54]
mov dword ptr [esp + 0x64], eax
xor eax, eax
mov al, byte ptr [esp + 0x78]
dec eax
mov dword ptr [esp + 0x6c], eax
fild dword ptr [esp + 0x6c]
fild word ptr [esp + 0x74]
fsub qword ptr [esp + 0x50]
fdivrp st(1)
lea eax, [esp + 0x68]
fstp qword ptr [esp + 0x48]
call CMAP_CreateFloatPalette_
xor edx, edx
mov dword ptr [esp + 0x70], edx
{disp32} jmp cmap_calculatelightmap_branch_1
cmap_calculatelightmap_branch_5:
movzx edi, byte ptr [esp + 0x90]
imul esi, edi, 0x18
add esi, dword ptr [esp + 0x68]
{disp32} jmp cmap_calculatelightmap_branch_2
cmap_calculatelightmap_branch_4:
lea edx, [esp + 0x30]
mov eax, esi
call RGB_TO_XYZ_
lea edx, [esp + 0x18]
lea eax, [esp + 0x30]
call XYZ_TO_LUV_
fld qword ptr [esp + 0x18]
fmul qword ptr [esp + 0x60]
fmul qword ptr [lightmap_percent_scale]
fst qword ptr [esp + 0x18]
fcomp qword ptr [lightmap_max_lightness]
fnstsw ax
sahf
jbe cmap_calculatelightmap_branch_3
xor eax, eax
mov edx, LIGHTNESS_MAX_BITS_HI
mov dword ptr [esp + 0x18], eax
mov dword ptr [esp + 0x1c], edx
cmap_calculatelightmap_branch_3:
lea edx, [esp + 0x30]
lea eax, [esp + 0x18]
call LUV_TO_XYZ_
xor ebx, ebx
mov edx, esp
lea eax, [esp + 0x30]
mov bl, byte ptr [esp + 0x98]
call XYZ_TO_RGB_
imul edx, ebx, 0x18
inc edi
inc ebp
xor ecx, ecx
mov eax, dword ptr [esp + 0x68]
mov cl, byte ptr [esp + 0x9c]
add edx, eax
mov eax, esp
add esi, 0x18
call CMAP_GetBestColorFast_
mov byte ptr [ebp - 1], al
cmap_calculatelightmap_branch_2:
xor eax, eax
mov al, byte ptr [esp + 0x94]
cmp edi, eax
{disp32} jle cmap_calculatelightmap_branch_4
fld qword ptr [esp + 0x60]
mov esi, dword ptr [esp + 0x70]
fadd qword ptr [esp + 0x48]
inc esi
fstp qword ptr [esp + 0x60]
mov dword ptr [esp + 0x70], esi
cmap_calculatelightmap_branch_1:
xor eax, eax
mov ebx, dword ptr [esp + 0x70]
mov al, byte ptr [esp + 0x78]
cmp eax, ebx
{disp32} jg cmap_calculatelightmap_branch_5
add esp, 0x7c
pop ebp
pop edi
pop esi
ret 0x14
nop

# CMAP_BuildColorMap_ -- full ordinary C counterpart retained.
CMAP_BuildColorMap_:
push esi
push edi
push ebp
mov esi, eax
xor ecx, ecx
movzx edi, byte ptr [esp + 0x24]
mov cl, byte ptr [esp + 0x20]
mov eax, edi
sub eax, ecx
and ebx, 0xff
inc eax
imul eax, ebx
mov ebp, dword ptr [esp + 0x30]
call SafeMalloc_
mov dword ptr [esi], eax
cmp ebp, 1
jne cmap_buildcolormap_branch_1
xor eax, eax
mov al, byte ptr [esp + 0x2c]
push eax
xor eax, eax
mov al, byte ptr [esp + 0x2c]
push eax
push edi
xor eax, eax
push ecx
mov al, byte ptr [esp + 0x24]
xor ecx, ecx
push eax
mov cl, byte ptr [esp + 0x24]
jmp cmap_buildcolormap_branch_2
cmap_buildcolormap_branch_1:
xor eax, eax
mov al, byte ptr [esp + 0x2c]
push eax
xor eax, eax
mov al, byte ptr [esp + 0x2c]
push eax
push edi
xor eax, eax
push ecx
mov al, byte ptr [esp + 0x20]
xor ecx, ecx
push eax
mov cl, byte ptr [esp + 0x28]
cmap_buildcolormap_branch_2:
mov eax, dword ptr [esi]
call CMAP_CalculateLightMap_
pop ebp
pop edi
pop esi
ret 0x24
nop

# CMAP_BuildMonochromeMap_ -- full ordinary C counterpart retained.
CMAP_BuildMonochromeMap_:
push esi
push edi
push ebp
sub esp, 0x68
mov dword ptr [esp + 0x54], eax
mov ebp, edx
mov byte ptr [esp + 0x64], bl
mov byte ptr [esp + 0x60], cl
xor eax, eax
xor ebx, ebx
mov al, byte ptr [esp + 0x80]
mov bl, byte ptr [esp + 0x7c]
mov ecx, dword ptr [esp + 0x54]
sub eax, ebx
mov edi, ebx
inc eax
lea esi, [ebx*4]
call SafeMalloc_
sub esi, ebx
mov dword ptr [ecx], eax
add esi, edx
{disp32} jmp cmap_buildmonochromemap_branch_1
cmap_buildmonochromemap_branch_2:
xor eax, eax
mov ebx, edi
mov al, byte ptr [esp + 0x7c]
sub ebx, eax
mov eax, ebx
mov ebx, dword ptr [esp + 0x54]
mov ebx, dword ptr [ebx]
add ebx, eax
xor eax, eax
mov al, byte ptr [esi]
mov dword ptr [esp + 0x58], eax
xor eax, eax
mov al, byte ptr [esi + 1]
fild word ptr [esp + 0x58]
mov dword ptr [esp + 0x5c], eax
xor eax, eax
fstp qword ptr [esp + 0x20]
mov al, byte ptr [esi + 2]
fild word ptr [esp + 0x5c]
mov dword ptr [esp + 0x58], eax
fstp qword ptr [esp + 0x18]
fild word ptr [esp + 0x58]
fstp qword ptr [esp + 0x48]
fld qword ptr [monochrome_byte_scale]
fld qword ptr [esp + 0x20]
fmul st(1)
fld qword ptr [esp + 0x18]
fmul st(2)
fld qword ptr [esp + 0x48]
fmulp st(3)
xor eax, eax
fxch st(1)
fmul qword ptr [monochrome_luma_red]
mov al, byte ptr [esp + 0x64]
fxch st(1)
fmul qword ptr [monochrome_luma_green]
mov dword ptr [esp + 0x58], eax
xor eax, eax
faddp st(1)
mov al, byte ptr [esp + 0x60]
fxch st(1)
fmul qword ptr [monochrome_luma_blue]
mov dword ptr [esp + 0x5c], eax
faddp st(1)
xor eax, eax
fild word ptr [esp + 0x58]
fmul st(1)
mov al, byte ptr [esp + 0x78]
fstp qword ptr [esp + 0x20]
fild word ptr [esp + 0x5c]
fmul st(1)
mov dword ptr [esp + 0x5c], eax
fstp qword ptr [esp + 0x18]
fild word ptr [esp + 0x5c]
fmulp st(1)
mov edx, ebp
mov eax, dword ptr [esp + 0x20]
xor ecx, ecx
mov dword ptr [esp], eax
mov eax, dword ptr [esp + 0x24]
mov cl, byte ptr [esp + 0x88]
mov dword ptr [esp + 4], eax
mov eax, dword ptr [esp + 0x18]
mov dword ptr [esp + 0x50], ebx
mov dword ptr [esp + 8], eax
mov eax, dword ptr [esp + 0x1c]
fstp qword ptr [esp + 0x48]
mov dword ptr [esp + 0xc], eax
mov eax, dword ptr [esp + 0x48]
xor ebx, ebx
mov dword ptr [esp + 0x10], eax
mov eax, dword ptr [esp + 0x4c]
mov bl, byte ptr [esp + 0x84]
mov dword ptr [esp + 0x14], eax
mov eax, esp
call CMAP_GetBestColor_
mov ebx, dword ptr [esp + 0x50]
add esi, 3
inc edi
mov byte ptr [ebx], al
cmap_buildmonochromemap_branch_1:
xor eax, eax
mov al, byte ptr [esp + 0x80]
cmp edi, eax
{disp32} jle cmap_buildmonochromemap_branch_2
add esp, 0x68
pop ebp
pop edi
pop esi
ret 0x14
nop

# CMAP_GetIntensity_ -- full ordinary C counterpart retained.
CMAP_GetIntensity_:
push esi
push edi
sub esp, 0x54
mov byte ptr [esp + 0x50], dl
xor edx, edx
mov dl, al
lea eax, [edx*4]
sub eax, edx
lea edx, [ebx + eax]
xor eax, eax
mov al, byte ptr [edx]
mov dword ptr [esp + 0x34], eax
xor eax, eax
mov al, byte ptr [edx + 1]
mov dword ptr [esp + 0x30], eax
xor eax, eax
mov al, byte ptr [edx + 2]
xor edx, edx
mov dl, byte ptr [esp + 0x50]
mov dword ptr [esp + 0x44], eax
lea eax, [edx*4]
sub eax, edx
lea edx, [ebx + eax]
xor eax, eax
mov al, byte ptr [edx]
mov dword ptr [esp + 0x38], eax
xor eax, eax
mov esi, DISTORTION_BOUND_BITS_HI
mov al, byte ptr [edx + 1]
mov dword ptr [esp + 0x2c], esi
mov dword ptr [esp + 0x40], eax
xor eax, eax
xor ebx, ebx
mov al, byte ptr [edx + 2]
mov dword ptr [esp + 0x28], ebx
mov dword ptr [esp + 0x48], eax
xor edx, edx
test ecx, ecx
{disp32} jle cmap_getintensity_branch_1
lea eax, [ecx - 1]
mov dword ptr [esp + 0x3c], eax
mov dword ptr [esp + 0x4c], ecx
cmap_getintensity_branch_3:
fild dword ptr [esp + 0x4c]
fild dword ptr [esp + 0x34]
fmul st(1)
fild dword ptr [esp + 0x3c]
fld1
fdivrp st(1)
fxch st(1)
fmul st(1)
fild dword ptr [esp + 0x30]
fmul st(3)
fmul st(2)
fild dword ptr [esp + 0x44]
fmulp st(4)
fxch st(3)
fmulp st(2)
fild dword ptr [esp + 0x38]
fsubrp st(1)
fmul st(0)
fild dword ptr [esp + 0x40]
fsubrp st(3)
fxch st(2)
fmul st(0)
faddp st(2)
fild dword ptr [esp + 0x48]
fsubrp st(1)
fmul st(0)
faddp st(1)
fst qword ptr [esp + 0x20]
fcomp qword ptr [esp + 0x28]
fnstsw ax
sahf
jae cmap_getintensity_branch_2
mov eax, dword ptr [esp + 0x20]
mov dword ptr [esp + 0x28], eax
mov eax, dword ptr [esp + 0x24]
mov ebx, edx
mov dword ptr [esp + 0x2c], eax
cmap_getintensity_branch_2:
mov edi, dword ptr [esp + 0x4c]
dec edi
inc edx
mov dword ptr [esp + 0x4c], edi
cmp edx, ecx
jl cmap_getintensity_branch_3
cmap_getintensity_branch_1:
mov al, bl
add esp, 0x54
pop edi
pop esi
ret
{load} mov eax, eax

# CMAP_FindEGAColors_ -- full ordinary C counterpart retained.
CMAP_FindEGAColors_:
push ebx
push ecx
push edx
sub esp, 4
mov ecx, eax
xor ebx, ebx
xor edx, edx
cmap_findegacolors_branch_1:
xor eax, eax
push 0xff
mov al, byte ptr [edx + _egargb + 2]
push 0
mov dword ptr [esp + 8], eax
push ecx
fild word ptr [esp + 0xc]
fmul qword ptr [ega_byte_scale]
sub esp, 8
xor eax, eax
fstp qword ptr [esp]
mov al, byte ptr [edx + _egargb + 1]
mov dword ptr [esp + 0x14], eax
fild word ptr [esp + 0x14]
fmul qword ptr [ega_byte_scale]
sub esp, 8
xor eax, eax
fstp qword ptr [esp]
mov al, byte ptr [edx + _egargb]
mov dword ptr [esp + 0x1c], eax
fild word ptr [esp + 0x1c]
fmul qword ptr [ega_byte_scale]
sub esp, 8
inc ebx
fstp qword ptr [esp]
add edx, 3
call CMAP_BestColor_
mov byte ptr [ebx + _egacolor - 1], al
cmp ebx, 0x10
jl cmap_findegacolors_branch_1
add esp, 4
pop edx
pop ecx
pop ebx
ret

.section CONST,"aw",@progbits
.p2align 2
.include "COLOR_CONSTANTS.INC"
.section CONST2,"aw",@progbits
.p2align 2
.section _DATA,"aw",@progbits
.p2align 2
.equ EGA_DARK,87
.equ EGA_MID,171
.equ EGA_FULL,255
_egargb:
.byte 0,0,0 # black
.byte 0,0,EGA_FULL # blue
.byte 0,EGA_FULL,0 # green
.byte 0,EGA_FULL,EGA_FULL # cyan
.byte EGA_FULL,0,0 # red
.byte EGA_FULL,0,EGA_FULL # magenta
.byte EGA_MID,EGA_DARK,0 # brown
.byte EGA_MID,EGA_MID,EGA_MID # light_gray
.byte EGA_DARK,EGA_DARK,EGA_DARK # dark_gray
.byte EGA_DARK,EGA_DARK,EGA_FULL # bright_blue
.byte EGA_DARK,EGA_FULL,EGA_DARK # bright_green
.byte EGA_DARK,EGA_FULL,EGA_FULL # bright_cyan
.byte EGA_FULL,EGA_DARK,EGA_DARK # bright_red
.byte EGA_FULL,EGA_DARK,EGA_FULL # bright_magenta
.byte EGA_FULL,EGA_FULL,EGA_DARK # yellow
.byte EGA_FULL,EGA_FULL,EGA_FULL # white
.section _BSS,"aw",@nobits
.p2align 4
_egacolor:
.zero 16 # sixteen actual global palette indices
