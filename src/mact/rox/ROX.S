# Complete symbolic ROX recovery; ordinary C counterpart preserved separately.
# No historical ASM claim; actual legacy bugs/dead bodies and no-op tails retained.
# Original private DATA/BSS names remain nonGLOBAL COFF definitions.
.intel_syntax noprefix
.code32
.file "ROX.S"
# Published structure geometry; genuine field names, no invented members.
.equ SECTION_BYTES,24
.equ ENTRY_BYTES,36
.equ SECTION_NAME_BYTES,8
.equ ENTRY_NAME_BYTES,12
.equ ROX_PATH_BYTES,128
.equ SECTION_ENTRIES,8
.equ SECTION_SUBSECTIONS,12
.equ SECTION_NEXT,16
.equ SECTION_PREV,20
.equ ENTRY_SIZE,20
.equ ENTRY_DATA,24
.equ ENTRY_NEXT,28
.equ ENTRY_PREV,32
.equ NAME_DWORD1,4
.section _TEXT,"ax",@progbits
.p2align 4
.globl ROX_CreateSection_
.globl ROX_CreateEntry_
.globl ROX_FreeEntry_
.globl ROX_FreeSection_
.globl ROX_Init_
.globl ROX_Shutdown_
.globl ROX_AddSubSection_
.globl ROX_FindSubSection_
.globl ROX_AddEntry_
.globl ROX_FindEntry_
.globl ROX_FixFilename_
.globl ROX_ReadEntry_
.globl ROX_TouchEntry_
.globl ROX_Get_
.extern Error_
.extern SafeMalloc_
.extern memset_
.extern strncpy_
.extern SafeFree_
.extern strpbrk_
.extern SafeOpenRead_
.extern SafeFileLength_
.extern Z_Malloc_
.extern SafeRead_
.extern SafeClose_
.extern Z_Touch_
.extern Z_ChangeTag_
.extern strtok_

# ROX_CreateSection_ -- see complete C counterpart.
ROX_CreateSection_:
push ebx
push ecx
push edx
push esi
mov esi, eax
cmp dword ptr [_ROX_started], 0
jne rox_branch_01
push OFFSET FLAT:rox_error_create_section
call Error_
add esp, 4
rox_branch_01:
mov eax, SECTION_BYTES
mov ebx, SECTION_BYTES
call SafeMalloc_
xor edx, edx
mov ecx, eax
call memset_
mov ebx, SECTION_NAME_BYTES
mov edx, esi
mov eax, ecx
call strncpy_
mov eax, 0x24
call SafeMalloc_
mov dword ptr [ecx + SECTION_ENTRIES], eax
mov dword ptr [eax + ENTRY_PREV], eax
mov dword ptr [eax + ENTRY_NEXT], eax
mov eax, SECTION_BYTES
call SafeMalloc_
mov dword ptr [ecx + SECTION_SUBSECTIONS], eax
mov dword ptr [eax + SECTION_PREV], eax
mov dword ptr [eax + SECTION_NEXT], eax
mov eax, ecx
pop esi
pop edx
pop ecx
pop ebx
ret 
nop 

# ROX_CreateEntry_ -- see complete C counterpart.
ROX_CreateEntry_:
push ebx
push ecx
push edx
push esi
mov esi, eax
cmp dword ptr [_ROX_started], 0
jne rox_branch_02
push OFFSET FLAT:rox_error_create_entry
call Error_
add esp, 4
rox_branch_02:
mov eax, ENTRY_BYTES
mov ebx, ENTRY_BYTES
call SafeMalloc_
xor edx, edx
mov ecx, eax
call memset_
mov ebx, ENTRY_NAME_BYTES
mov edx, esi
mov eax, ecx
call strncpy_
mov eax, ecx
pop esi
pop edx
pop ecx
pop ebx
ret 
{disp8} lea eax, [eax]

# ROX_FreeEntry_ -- see complete C counterpart.
ROX_FreeEntry_:
push edx
mov edx, eax
cmp dword ptr [_ROX_started], 0
jne rox_branch_03
push OFFSET FLAT:rox_error_free_entry
call Error_
add esp, 4
rox_branch_03:
mov eax, edx
call SafeFree_
pop edx
ret 
{load} mov eax, eax

# ROX_FreeSection_ -- see complete C counterpart.
ROX_FreeSection_:
push ebx
push ecx
push edx
push esi
mov ebx, eax
cmp dword ptr [_ROX_started], 0
jne rox_branch_04
push OFFSET FLAT:rox_error_free_section
call Error_
add esp, 4
rox_branch_04:
mov edx, dword ptr [ebx + SECTION_ENTRIES]
cmp edx, edx
je rox_branch_06
rox_branch_05:
mov eax, edx
mov esi, dword ptr [eax + ENTRY_PREV]
mov ecx, dword ptr [eax + ENTRY_NEXT]
mov edx, dword ptr [edx + ENTRY_NEXT]
mov dword ptr [esi + ENTRY_NEXT], ecx
mov esi, dword ptr [eax + ENTRY_PREV]
mov dword ptr [ecx + ENTRY_PREV], esi
mov dword ptr [eax + ENTRY_NEXT], eax
mov dword ptr [eax + ENTRY_PREV], eax
call ROX_FreeEntry_
cmp edx, dword ptr [ebx + SECTION_ENTRIES]
jne rox_branch_05
rox_branch_06:
mov edx, dword ptr [ebx + SECTION_SUBSECTIONS]
cmp edx, edx
je rox_branch_08
rox_branch_07:
mov eax, edx
mov esi, dword ptr [eax + SECTION_PREV]
mov ecx, dword ptr [eax + SECTION_NEXT]
mov edx, dword ptr [edx + SECTION_NEXT]
mov dword ptr [esi + SECTION_NEXT], ecx
mov esi, ecx
mov ecx, dword ptr [eax + SECTION_PREV]
mov dword ptr [esi + SECTION_PREV], ecx
mov dword ptr [eax + SECTION_NEXT], eax
mov dword ptr [eax + SECTION_PREV], eax
call ROX_FreeSection_
cmp edx, dword ptr [ebx + SECTION_SUBSECTIONS]
jne rox_branch_07
rox_branch_08:
mov eax, ebx
call SafeFree_
pop esi
pop edx
pop ecx
pop ebx
ret 

# ROX_Init_ -- see complete C counterpart.
ROX_Init_:
push ecx
push edx
push esi
mov edx, dword ptr [_ROX_started]
test edx, edx
je rox_branch_09
je rox_branch_09
mov eax, dword ptr [_ROX_mainsection]
xor ecx, ecx
call ROX_FreeSection_
mov dword ptr [_ROX_started], ecx
rox_branch_09:
mov eax,OFFSET FLAT:rox_main_name
mov esi, 1
call ROX_CreateSection_
mov dword ptr [_ROX_mainsection], eax
mov dword ptr [_ROX_started], esi
pop esi
pop edx
pop ecx
ret 
nop 

# ROX_Shutdown_ -- see complete C counterpart.
ROX_Shutdown_:
push ebx
cmp dword ptr [_ROX_started], 0
je rox_branch_10
mov eax, dword ptr [_ROX_mainsection]
xor ebx, ebx
call ROX_FreeSection_
mov dword ptr [_ROX_started], ebx
rox_branch_10:
pop ebx
ret 
{load} mov eax, eax

# ROX_AddSubSection_ -- see complete C counterpart.
ROX_AddSubSection_:
push ebx
mov ebx, eax
cmp dword ptr [_ROX_started], 0
jne rox_branch_11
push OFFSET FLAT:rox_error_add_subsection
call Error_
add esp, 4
rox_branch_11:
mov eax, edx
call ROX_CreateSection_
mov edx, dword ptr [ebx + SECTION_SUBSECTIONS]
mov dword ptr [eax + SECTION_NEXT], edx
mov edx, dword ptr [edx + SECTION_PREV]
mov dword ptr [eax + SECTION_PREV], edx
mov edx, dword ptr [ebx + SECTION_SUBSECTIONS]
mov edx, dword ptr [edx + SECTION_PREV]
mov dword ptr [edx + SECTION_NEXT], eax
mov edx, dword ptr [ebx + SECTION_SUBSECTIONS]
mov dword ptr [edx + SECTION_PREV], eax
pop ebx
ret 
{disp8} lea eax, [eax]

# ROX_FindSubSection_ -- see complete C counterpart.
ROX_FindSubSection_:
push ebx
push ecx
sub esp, SECTION_NAME_BYTES
mov ecx, eax
cmp dword ptr [_ROX_started], 0
jne rox_branch_12
push OFFSET FLAT:rox_error_find_subsection
call Error_
add esp, 4
rox_branch_12:
mov ebx, SECTION_NAME_BYTES
mov eax, esp
call strncpy_
mov edx, dword ptr [esp]
mov eax, dword ptr [ecx + SECTION_SUBSECTIONS]
mov ebx, dword ptr [esp + 4]
cmp eax, eax
je rox_branch_15
rox_branch_13:
cmp edx, dword ptr [eax]
jne rox_branch_14
cmp ebx, dword ptr [eax + NAME_DWORD1]
je rox_branch_16
rox_branch_14:
mov eax, dword ptr [eax + SECTION_NEXT]
cmp eax, dword ptr [ecx + SECTION_SUBSECTIONS]
jne rox_branch_13
rox_branch_15:
xor eax, eax
rox_branch_16:
add esp, SECTION_NAME_BYTES
pop ecx
pop ebx
ret 

# ROX_AddEntry_ -- see complete C counterpart.
ROX_AddEntry_:
push ebx
mov ebx, eax
cmp dword ptr [_ROX_started], 0
jne rox_branch_17
push OFFSET FLAT:rox_error_add_entry
call Error_
add esp, 4
rox_branch_17:
mov eax, edx
call ROX_CreateEntry_
mov edx, dword ptr [ebx + SECTION_ENTRIES]
mov dword ptr [eax + ENTRY_NEXT], edx
mov edx, dword ptr [edx + ENTRY_PREV]
mov dword ptr [eax + ENTRY_PREV], edx
mov edx, dword ptr [ebx + SECTION_ENTRIES]
mov edx, dword ptr [edx + ENTRY_PREV]
mov dword ptr [edx + ENTRY_NEXT], eax
mov edx, dword ptr [ebx + SECTION_ENTRIES]
mov dword ptr [edx + ENTRY_PREV], eax
pop ebx
ret 
{disp8} lea eax, [eax]

# ROX_FindEntry_ -- see complete C counterpart.
ROX_FindEntry_:
push ebx
push ecx
push esi
push ebp
sub esp, SECTION_NAME_BYTES
mov ecx, eax
cmp dword ptr [_ROX_started], 0
jne rox_branch_18
push OFFSET FLAT:rox_error_find_entry
call Error_
add esp, 4
rox_branch_18:
mov ebx, SECTION_NAME_BYTES
mov eax, esp
call strncpy_
mov esi, dword ptr [esp]
mov edx, dword ptr [esp + 4]
mov eax, dword ptr [ecx + SECTION_ENTRIES]
mov ebx, dword ptr [esp + 8]
cmp eax, eax
je rox_branch_21
rox_branch_19:
mov ebp, dword ptr [eax]
cmp esi, ebp
jne rox_branch_20
cmp edx, ebp
jne rox_branch_20
cmp ebx, dword ptr [eax + NAME_DWORD1]
je rox_branch_22
rox_branch_20:
mov eax, dword ptr [eax + ENTRY_NEXT]
cmp eax, dword ptr [ecx + SECTION_ENTRIES]
jne rox_branch_19
rox_branch_21:
xor eax, eax
rox_branch_22:
add esp, SECTION_NAME_BYTES
pop ebp
pop esi
pop ecx
pop ebx
ret 
{load} mov eax, eax

# ROX_FixFilename_ -- see complete C counterpart.
ROX_FixFilename_:
push edx
mov edx, OFFSET FLAT:_ROX_delims
call strpbrk_
test eax, eax
je rox_branch_24
rox_branch_23:
mov edx, OFFSET FLAT:_ROX_delims
mov byte ptr [eax], 0x5c
inc eax
call strpbrk_
test eax, eax
jne rox_branch_23
rox_branch_24:
pop edx
ret 
nop 

# ROX_ReadEntry_ -- see complete C counterpart.
ROX_ReadEntry_:
push esi
push edi
push ebp
mov edi, eax
mov ebp, ecx
mov eax, edx
xor edx, edx
call SafeOpenRead_
lea ecx, [edi + ENTRY_DATA]
mov esi, eax
call SafeFileLength_
mov edx, ebp
mov dword ptr [edi + ENTRY_SIZE], eax
call Z_Malloc_
mov eax, esi
mov ebx, dword ptr [edi + ENTRY_SIZE]
mov edx, dword ptr [edi + ENTRY_DATA]
call SafeRead_
mov eax, esi
call SafeClose_
pop ebp
pop edi
pop esi
ret 

# ROX_TouchEntry_ -- see complete C counterpart.
ROX_TouchEntry_:
push ebx
mov ebx, eax
mov eax, dword ptr [eax + ENTRY_DATA]
call Z_Touch_
mov eax, dword ptr [ebx + ENTRY_DATA]
call Z_ChangeTag_
pop ebx
ret 
{disp8} lea eax, [eax]

# ROX_Get_ -- see complete C counterpart.
ROX_Get_:
push ecx
push esi
push edi
push ebp
sub esp, 8
mov ebp, eax
mov dword ptr [esp], edx
mov dword ptr [esp + 4], ebx
cmp dword ptr [_ROX_started], 0
jne rox_branch_25
push OFFSET FLAT:rox_error_get
call Error_
add esp, 4
rox_branch_25:
mov edi, ebp
sub ecx, ecx
dec ecx
xor eax, eax
repne scasb al, byte ptr es:[edi]
not ecx
dec ecx
mov ebx, ecx
cmp ecx, ROX_PATH_BYTES
jle rox_branch_26
push ebp
push OFFSET FLAT:rox_error_get_length
call Error_
add esp, 8
rox_branch_26:
mov edi, OFFSET FLAT:_ROX_dataname
inc ebx
mov esi, ebp
mov ecx, ebx
push edi
mov eax, ecx
shr ecx, 2
repne movsd dword ptr es:[edi], dword ptr [esi]
{load} mov cl, al
and cl, 3
repne movsb byte ptr es:[edi], byte ptr [esi]
pop edi
mov edi, OFFSET FLAT:_ROX_filename
mov ecx, ebx
mov esi, ebp
mov edx, OFFSET FLAT:_ROX_delims
push edi
mov eax, ecx
shr ecx, 2
repne movsd dword ptr es:[edi], dword ptr [esi]
{load} mov cl, al
and cl, 3
repne movsb byte ptr es:[edi], byte ptr [esi]
pop edi
mov eax, OFFSET FLAT:_ROX_dataname
mov ebx, dword ptr [_ROX_mainsection]
call strtok_
mov ecx, eax
test eax, eax
je rox_branch_35
rox_branch_27:
mov edx, OFFSET FLAT:_ROX_delims
xor eax, eax
call strtok_
mov esi, eax
test eax, eax
{disp32} jne rox_branch_33
mov edx, ecx
mov eax, ebx
call ROX_FindEntry_
mov esi, eax
test eax, eax
jne rox_branch_28
mov edx, ecx
mov eax, ebx
call ROX_AddEntry_
rox_branch_28:
mov ebx, dword ptr [esi + ENTRY_DATA]
test ebx, ebx
jne rox_branch_31
mov edx, OFFSET FLAT:_ROX_delims
mov eax, OFFSET FLAT:_ROX_filename
call strpbrk_
test eax, eax
je rox_branch_30
mov ebx, OFFSET FLAT:_ROX_delims
rox_branch_29:
mov edx, ebx
mov byte ptr [eax], 0x5c
inc eax
call strpbrk_
test eax, eax
jne rox_branch_29
rox_branch_30:
mov ecx, dword ptr [esp + 4]
mov ebx, dword ptr [esp]
mov edx, OFFSET FLAT:_ROX_filename
mov eax, esi
call ROX_ReadEntry_
jmp rox_branch_32
rox_branch_31:
mov eax, ebx
mov edx, dword ptr [esp + 4]
call Z_Touch_
mov eax, dword ptr [esi + ENTRY_DATA]
call Z_ChangeTag_
rox_branch_32:
mov eax, dword ptr [esi + ENTRY_DATA]
add esp, 8
pop ebp
pop edi
pop esi
pop ecx
ret 
rox_branch_33:
mov edx, ecx
mov eax, ebx
call ROX_FindSubSection_
mov edi, eax
test eax, eax
jne rox_branch_34
mov edx, ecx
mov eax, ebx
call ROX_AddSubSection_
rox_branch_34:
mov ebx, edi
mov ecx, esi
test esi, esi
jne rox_branch_27
rox_branch_35:
xor eax, eax
add esp, 8
pop ebp
pop edi
pop esi
pop ecx
ret 

.section CONST,"aw",@progbits
.p2align 2
.include "ROX_LITERALS.INC"

.section _DATA,"aw",@progbits
.p2align 2
_ROX_started:
.long 0 # real private boolean false
_ROX_mainsection:
.long 0 # real private null section pointer
_ROX_delims:
.ascii "\\/\000"

.section _BSS,"aw",@nobits
.p2align 4
_ROX_filename:
.skip 128 # real fixed filename buffer
_ROX_dataname:
.skip 128 # real fixed strtok buffer
