# Mechanical syntax port of authored WAD.ASM; no original source claim.
.intel_syntax noprefix
.code32
.file "wad.S"
.section _TEXT,"ax",@progbits
.p2align 4
# Task453 readable symbolic WAD reconstruction, not recovered original WAD.C.
# API/types: 3D Realms released WAD.H, WADTYPE.H, _WAD.H, TYPES.H.
# Related ROTT W_WAD.C provides ancestry, not this MACT version's identity.
# See WAD.C for complete readable algorithms and preserved native quirks.
# All data are real strings, pointers and state; ALIGN owns true no-op tails.
.extern SafeMalloc_,SafeOpenRead_,strcmpi_,SafeFileLength_
.extern IntelLong_,ExtractFileBase_,SafeRead_,strncmp_
.extern Error_,lseek_,printf_,SafeRealloc_
.extern SafeMallocSize_,memset_,strncpy_,SafeFree_
.extern CalculateCRC_,toupper_,SafeWrite_,Z_ChangeTag_
.extern Z_Touch_,Z_Malloc_,sprintf_,DefaultExtension_
.extern malloc_,SafeOpenWrite_,SafeClose_

# Actual released member offsets, not surrogate structures.
.equ LUMP_HANDLE,8
.equ LUMP_TYPE,10
.equ LUMP_POSITION,12
.equ LUMP_SIZE,16
.equ LUMP_BYTES,20
.equ FILE_SIZE,4
.equ FILE_TYPE,8
.equ FILE_NAME,12
.equ FILE_BYTES,20
.equ WAD_HANDLE,0
.equ WAD_COUNT,4
.equ WAD_DIRECTORY,8
.equ MAX_LUMPS,4096

.section CONST,"aw",@progbits
.p2align 2
const_origin:
lt_unknown:
.ascii "unknown\000"
lt_pic:
.ascii "pic\000"
lt_lpic:
.ascii "lpic\000\000\000\000"
lt_post:
.ascii "post\000\000\000\000"
lt_post_raw:
.ascii "post_raw\000\000\000\000"
lt_raw:
.ascii "raw\000"
lt_patch255:
.ascii "patch255\000\000\000\000"
lt_patch:
.ascii "patch\000\000\000"
lt_palette:
.ascii "palette\000"
lt_patch255_all:
.ascii "patch255_all\000\000\000\000"
lt_patch_all:
.ascii "patch_all\000\000\000"
lt_mipmap:
.ascii "mipmap\000\000"
lt_font:
.ascii "font\000\000\000\000"
lt_colorfont:
.ascii "color_font\000\000"
lt_intensity:
.ascii "intensity_font\000\000"
lt_sound:
.ascii "sound\000\000\000"
lt_label:
.ascii "<LABEL>\000"
lt_colormap:
.ascii "colormap\000\000\000\000"
lt_transmap:
.ascii "transmap\000\000\000\000"
lt_tileset:
.ascii "tileset\000"
lt_model:
.ascii "model\000\000\000"
lt_frame:
.ascii "frame\000\000\000"
extension_wad:
.ascii "wad\000"
ident_iwad:
.ascii "IWAD\000\000\000\000"
err_iwad:
.ascii "Wad file %s doesn't have IWAD id\n\000\000\000"
msg_adding:
.ascii "    Adding %s.\n\000"
err_no_files:
.ascii "WAD_InitFiles: no files found\000\000\000"
msg_started:
.ascii "Wad: Wad Manager Started NUMLUMPS=%ld\n\000\000"
err_name:
.ascii "WAD_GetNumForName: %s not found!\000\000\000\000"
err_length:
.ascii "WAD_LumpLength: %ld >= numlumps\000"
err_number_name:
.ascii "WAD_GetNameForNum: %ld >= numlumps\000\000"
err_number_type:
.ascii "WAD_GetTypeForNum: %ld >= numlumps\000\000"
err_read:
.ascii "WAD_ReadLump: %ld >= numlumps\000\000\000"
err_write:
.ascii "WAD_WriteLump: %ld >= numlumps\000\000"
err_cache:
.ascii "WAD_CacheLumpNum: %ld >= numlumps\000\000\000"
fmt_decimal:
.ascii "%ld\000"
err_decimal:
.ascii "WAD_CacheLumpDec : Combined length of '%s' and '%s' > %d.\n\000\000"
fmt_hexadecimal:
.ascii "%lx\000"
err_hexadecimal:
.ascii "WAD_CacheLumpHex : Combined length of '%s' and '%s' > %d.\n\000\000"
extension_dot:
.ascii ".\000\000\000"
err_already_open:
.ascii "OpenWadFile: Wad file already open\n\000"
msg_newline:
.ascii "\n\000\000\000"
msg_filename:
.ascii "WAD file    : %s\n\000\000\000"
msg_column_name:
.ascii "lump name\000\000\000"
fmt_character:
.ascii "%c\000\000"
msg_column_type:
.ascii " size   lumptype\n\000\000\000"
msg_rule_name:
.ascii "---- \000\000\000"
msg_rule_type:
.ascii " ------ --------\n\000\000\000"
err_too_many:
.ascii "Too many lumps grabbed for %s!\000\000"
fmt_lump:
.ascii "%4ld %s %6ld %s\n\000\000\000\000"
err_not_open:
.ascii "CloseWadFile: Wad file not open\n\000\000\000\000"
msg_total:
.ascii "Total Lumps in file: %ld\n\000"
.if (.-const_origin)-954 != 0
.error "true source coordinate assertion"
.endif
.section CONST2,"aw",@progbits
.p2align 2
.section _DATA,"aw",@progbits
.p2align 2
data_origin:
_numlumps:
.long 0
_lumpcache:
.long 0
_lumpinfo:
.long 0
_wadfileopened:
.long 0
_lumptypenames:
.long lt_unknown,lt_pic,lt_lpic,lt_post
.long lt_post_raw,lt_raw,lt_patch255,lt_patch
.long lt_palette,lt_patch255_all,lt_patch_all,lt_mipmap
.long lt_font,lt_colorfont,lt_intensity,lt_sound
.long lt_label,lt_colormap,lt_transmap,lt_tileset
.long lt_model,lt_frame
.if (_numlumps-data_origin)-0 != 0
.error "true source coordinate assertion"
.endif
.if (_lumpcache-data_origin)-4 != 0
.error "true source coordinate assertion"
.endif
.if (_lumpinfo-data_origin)-8 != 0
.error "true source coordinate assertion"
.endif
.if (_wadfileopened-data_origin)-12 != 0
.error "true source coordinate assertion"
.endif
.if (_lumptypenames-data_origin)-16 != 0
.error "true source coordinate assertion"
.endif
.if (.-data_origin)-104 != 0
.error "true source coordinate assertion"
.endif
.section _BSS,"aw",@nobits
.p2align 4
bss_origin:
_wadfilename:
.skip 128
_table_p:
.skip 4
_table:
.skip 4
_wadhandle:
.skip 4
.if (_wadfilename-bss_origin)-0 != 0
.error "true source coordinate assertion"
.endif
.if (_table_p-bss_origin)-128 != 0
.error "true source coordinate assertion"
.endif
.if (_table-bss_origin)-132 != 0
.error "true source coordinate assertion"
.endif
.if (_wadhandle-bss_origin)-136 != 0
.error "true source coordinate assertion"
.endif
.if (.-bss_origin)-140 != 0
.error "true source coordinate assertion"
.endif
.section _TEXT,"ax",@progbits
.p2align 4
.globl WAD_ReadHeader_,WAD_AddFile_,WAD_InitFile_,WAD_GetWADCRC_
.globl WAD_InitMultipleFiles_,WAD_NumLumps_,WAD_CheckNumForName_
.globl WAD_GetNumForName_,WAD_LumpLength_,WAD_GetNameForNum_
.globl WAD_GetTypeForNum_,WAD_GetTypeForName_,WAD_GetLumpNumsOfType_
.globl WAD_CountType_,WAD_ReadLump_,WAD_WriteLump_,WAD_CacheLumpName_
.globl WAD_CacheLumpNum_,WAD_CacheLumpDec_,WAD_CacheLumpHex_
.globl WAD_LumptypeToString_,WAD_ShootWAD_,WAD_OpenWadFile_
.globl WAD_WriteWadTable_,WAD_WriteWadLump_,WAD_CloseWadFile_
code_origin:
WAD_ReadHeader_:
push ebx
push ecx
push edx
push esi
push edi
push ebp
sub esp,112
mov esi,eax
mov eax,12
call SafeMalloc_
xor edx,edx
mov ebx,eax
mov ebp,eax
mov eax,esi
mov edi,esi
call SafeOpenRead_
mov [ebx+WAD_HANDLE],eax
sub ecx,ecx
dec ecx
xor eax,eax
repne scasb
not ecx
dec ecx
lea eax,[esi+ecx]
mov edx,OFFSET FLAT:extension_wad
sub eax,3
call strcmpi_
test eax,eax
je header_archive
mov eax,FILE_BYTES
call SafeMalloc_
mov [ebx+WAD_DIRECTORY],eax
mov dword ptr[eax],0
mov eax,[ebx+WAD_HANDLE]
call SafeFileLength_
call IntelLong_
mov edx,[ebx+WAD_DIRECTORY]
mov [edx+FILE_SIZE],eax
mov eax,[ebx+WAD_DIRECTORY]
mov dword ptr[eax+FILE_TYPE],0
mov edi,esp
mov dword ptr[ebx+WAD_COUNT],1
# strcpy local basename; preserves exact read/write stepping.
push edi
header_copy_name:
mov al,[esi]
mov [edi],al
cmp al,0
je header_copied
mov al,[esi+1]
add esi,2
mov [edi+1],al
add edi,2
cmp al,0
jne header_copy_name
header_copied:
pop edi
mov edx,[ebx+WAD_DIRECTORY]
mov eax,esp
add edx,FILE_NAME
call ExtractFileBase_
jmp header_done
header_archive:
lea edx,[esp+100]
mov eax,[ebx+WAD_HANDLE]
mov ebx,12
call SafeRead_
mov ebx,4
mov edx,OFFSET FLAT:ident_iwad
lea eax,[esp+100]
call strncmp_
test eax,eax
je header_valid
push esi
push OFFSET FLAT:err_iwad
call Error_
add esp,8
header_valid:
mov eax,[esp+104]
call IntelLong_
mov [esp+104],eax
mov eax,[esp+108]
call IntelLong_
mov edx,[esp+104]
lea esi,[edx*4]
add esi,edx
shl esi,2
mov [esp+108],eax
mov eax,esi
call SafeMalloc_
mov [ebp+WAD_DIRECTORY],eax
mov eax,[esp+104]
mov [ebp+WAD_COUNT],eax
xor ebx,ebx
mov edx,[esp+108]
mov eax,[ebp+WAD_HANDLE]
call lseek_
mov ebx,esi
mov edx,[ebp+WAD_DIRECTORY]
mov eax,[ebp+WAD_HANDLE]
call SafeRead_
header_done:
mov eax,ebp
add esp,112
pop ebp
pop edi
pop esi
pop edx
pop ecx
pop ebx
ret
# real compiler no-op tail
nop
# Two genuine released entry names coalesced by canonical C optimizer.
WAD_AddFile_:
WAD_InitFile_:
push ebx
push ecx
push edx
push esi
push edi
push ebp
mov edx,eax
call WAD_ReadHeader_
push edx
push OFFSET FLAT:msg_adding
mov ebx,eax
mov ecx,eax
call printf_
mov edx,[_numlumps]
add edx,[ebx+WAD_COUNT]
lea eax,[edx*4]
add esp,8
add eax,edx
mov ebx,[_lumpinfo]
shl eax,2
test ebx,ebx
jne add_resize_info
call SafeMalloc_
mov [_lumpinfo],eax
jmp add_info_ready
add_resize_info:
mov edx,eax
mov eax,OFFSET FLAT:_lumpinfo
call SafeRealloc_
add_info_ready:
mov esi,[_numlumps]
mov eax,[ecx+WAD_COUNT]
add eax,esi
mov edi,[_lumpcache]
lea ebx,[eax*4]
test edi,edi
jne add_resize_cache
mov eax,ebx
call SafeMalloc_
xor edx,edx
mov [_lumpcache],eax
jmp add_clear_cache
add_resize_cache:
mov eax,edi
call SafeMallocSize_
mov edx,ebx
mov esi,eax
mov eax,OFFSET FLAT:_lumpcache
call SafeRealloc_
sub ebx,esi
mov eax,[_lumpcache]
xor edx,edx
add eax,esi
add_clear_cache:
call memset_
mov edx,[_numlumps]
lea eax,[edx*4]
mov esi,[_lumpinfo]
add eax,edx
mov ebp,[ecx+WAD_COUNT]
shl eax,2
xor edi,edi
add esi,eax
test ebp,ebp
jle add_directory_done
add_directory:
mov ax,[ecx+WAD_HANDLE]
mov [esi+LUMP_HANDLE],ax
mov eax,[ecx+WAD_DIRECTORY]
mov eax,[eax]
call IntelLong_
mov [esi+LUMP_POSITION],eax
mov eax,[ecx+WAD_DIRECTORY]
mov eax,[eax+FILE_SIZE]
call IntelLong_
mov [esi+LUMP_SIZE],eax
mov eax,[ecx+WAD_DIRECTORY]
mov eax,[eax+FILE_TYPE]
call IntelLong_
mov [esi+LUMP_TYPE],ax
mov ebx,8
mov edx,[ecx+WAD_DIRECTORY]
mov eax,esi
add edx,FILE_NAME
inc edi
call strncpy_
mov eax,[ecx+WAD_DIRECTORY]
add esi,LUMP_BYTES
add eax,FILE_BYTES
mov edx,[ecx+WAD_COUNT]
mov [ecx+WAD_DIRECTORY],eax
cmp edi,edx
jl add_directory
add_directory_done:
mov ebx,[_numlumps]
add ebx,[ecx+WAD_COUNT]
mov eax,ecx
mov [_numlumps],ebx
call SafeFree_
pop ebp
pop edi
pop esi
pop edx
pop ecx
pop ebx
ret
# real compiler no-op tail
{load} mov eax,eax
WAD_GetWADCRC_:
push edx
mov edx,[_numlumps]
lea eax,[edx*4]
add edx,eax
mov eax,[_lumpinfo]
shl edx,2
call CalculateCRC_
pop edx
ret
# real compiler no-op tail
nop
WAD_InitMultipleFiles_:
push ebx
push ecx
push edx
push esi
push ebp
mov edx,eax
xor ebx,ebx
mov ecx,[eax]
mov [_numlumps],ebx
test ecx,ecx
je init_all_loaded
init_next_file:
mov eax,[edx]
call WAD_AddFile_
mov esi,[edx+4]
add edx,4
test esi,esi
jne init_next_file
init_all_loaded:
cmp dword ptr[_numlumps],0
jne init_have_lumps
push OFFSET FLAT:err_no_files
call Error_
add esp,4
init_have_lumps:
mov ebp,[_numlumps]
push ebp
push OFFSET FLAT:msg_started
call printf_
add esp,8
pop ebp
pop esi
pop edx
pop ecx
pop ebx
ret
# real compiler no-op tail
{load} mov eax,eax
WAD_NumLumps_:
mov eax,[_numlumps]
ret
# real compiler no-op tail
{load} mov eax,eax
WAD_CheckNumForName_:
push ebx
push ecx
push edx
push esi
sub esp,12
mov ecx,eax
mov ebx,9
mov eax,esp
xor edx,edx
call memset_
mov ebx,8
mov eax,esp
mov edx,ecx
call strncpy_
mov ah,[esp]
xor edx,edx
test ah,ah
je check_name_ready
check_upper:
cmp edx,9
jge check_name_ready
xor eax,eax
mov al,[esp+edx]
call toupper_
mov [esp+edx],al
mov bl,[esp+edx+1]
inc edx
test bl,bl
jne check_upper
check_name_ready:
mov edx,[_numlumps]
lea eax,[edx*4]
mov ecx,[esp]
add eax,edx
mov esi,[_lumpinfo]
shl eax,2
mov ebx,[esp+4]
add eax,esi
mov edx,esi
cmp esi,eax
jae check_not_found
check_lump:
cmp ecx,[edx]
jne check_next
cmp ebx,[edx+4]
jne check_next
sub edx,[_lumpinfo]
mov ebx,LUMP_BYTES
mov eax,edx
sar edx,31
idiv ebx
jmp check_leave
check_next:
add edx,LUMP_BYTES
cmp edx,eax
jb check_lump
check_not_found:
mov eax,-1
check_leave:
add esp,12
pop esi
pop edx
pop ecx
pop ebx
ret
# real compiler no-op tail
{disp8} lea eax,[eax]
WAD_GetNumForName_:
push ebx
push edx
mov edx,eax
call WAD_CheckNumForName_
mov ebx,eax
cmp eax,-1
jne get_name_found
push edx
push OFFSET FLAT:err_name
call Error_
add esp,8
get_name_found:
mov eax,ebx
pop edx
pop ebx
ret
# real compiler no-op tail
nop
WAD_LumpLength_:
push edx
mov edx,eax
cmp eax,[_numlumps]
jb length_valid
push eax
push OFFSET FLAT:err_length
call Error_
add esp,8
length_valid:
lea eax,[edx*4]
add edx,eax
mov eax,[_lumpinfo]
shl edx,2
mov eax,[edx+eax+LUMP_SIZE]
pop edx
ret
# naturally aligned; no instruction
WAD_GetNameForNum_:
push edx
mov edx,eax
cmp eax,[_numlumps]
jb number_name_valid
push eax
push OFFSET FLAT:err_number_name
call Error_
add esp,8
number_name_valid:
lea eax,[edx*4]
add eax,edx
mov edx,[_lumpinfo]
shl eax,2
add eax,edx
pop edx
ret
# real compiler no-op tail
nop
WAD_GetTypeForNum_:
push edx
mov edx,eax
cmp eax,[_numlumps]
jb number_type_valid
push eax
push OFFSET FLAT:err_number_type
call Error_
add esp,8
number_type_valid:
lea eax,[edx*4]
add edx,eax
mov eax,[_lumpinfo]
shl edx,2
# Signed packed 16-bit type: actual native DWORD view + SAR.
mov eax,[edx+eax+LUMP_HANDLE]
sar eax,16
pop edx
ret
# real compiler no-op tail
nop
WAD_GetTypeForName_:
push edx
call WAD_GetNumForName_
mov edx,eax
shl eax,2
add eax,edx
mov edx,[_lumpinfo]
mov eax,[edx+eax*4+LUMP_HANDLE]
sar eax,16
pop edx
ret
# naturally aligned; no instruction
WAD_GetLumpNumsOfType_:
push ebx
push ecx
push esi
push edi
push ebp
sub esp,4
mov esi,eax
mov ebp,edx
mov ebx,[_numlumps]
mov edi,eax
lea eax,[ebx*4]
add eax,ebx
mov ebx,[_lumpinfo]
shl eax,2
lea ecx,[ebx+eax]
xor edx,edx
mov eax,ebx
cmp ebx,ecx
jae types_counted
count_types:
mov ebx,[eax+LUMP_HANDLE]
sar ebx,16
cmp ebx,edi
jne count_types_next
inc edx
count_types_next:
add eax,LUMP_BYTES
cmp eax,ecx
jb count_types
types_counted:
mov [esp],edx
lea eax,[edx*4]
add eax,4
call SafeMalloc_
mov ecx,[_numlumps]
mov edx,eax
mov [ebp],eax
lea eax,[ecx*4]
add eax,ecx
mov ecx,[_lumpinfo]
shl eax,2
lea edi,[ecx+eax]
xor ebx,ebx
mov eax,ecx
cmp ecx,edi
jae types_filled
fill_types:
mov ecx,[eax+LUMP_HANDLE]
sar ecx,16
cmp ecx,esi
jne fill_types_next
add edx,4
mov [edx-4],ebx
fill_types_next:
add eax,LUMP_BYTES
inc ebx
cmp eax,edi
jb fill_types
types_filled:
mov eax,[esp]
mov dword ptr[edx],-1
add esp,4
pop ebp
pop edi
pop esi
pop ecx
pop ebx
ret
# real compiler no-op tail
nop
WAD_CountType_:
push ebx
push ecx
push edx
push esi
mov esi,eax
mov ebx,[_numlumps]
lea eax,[ebx*4]
add eax,ebx
mov ebx,[_lumpinfo]
shl eax,2
lea ecx,[ebx+eax]
xor edx,edx
mov eax,ebx
cmp ebx,ecx
jae count_done
count_one_type:
mov ebx,[eax+LUMP_HANDLE]
sar ebx,16
cmp ebx,esi
jne count_one_next
inc edx
count_one_next:
add eax,LUMP_BYTES
cmp eax,ecx
jb count_one_type
count_done:
mov eax,edx
pop esi
pop edx
pop ecx
pop ebx
ret
# real compiler no-op tail
{load} mov eax,eax
WAD_ReadLump_:
push ebx
push ecx
push esi
mov ecx,eax
mov esi,edx
cmp eax,[_numlumps]
jb read_valid
push eax
push OFFSET FLAT:err_read
call Error_
add esp,8
read_valid:
lea eax,[ecx*4]
add eax,ecx
mov ecx,[_lumpinfo]
shl eax,2
add ecx,eax
xor ebx,ebx
mov eax,[ecx+6]
mov edx,[ecx+LUMP_POSITION]
sar eax,16
call lseek_
mov edx,esi
mov eax,[ecx+6]
mov ebx,[ecx+LUMP_SIZE]
sar eax,16
call SafeRead_
pop esi
pop ecx
pop ebx
ret
# real compiler no-op tail
{disp8} lea eax,[eax]
WAD_WriteLump_:
push ebx
push ecx
push esi
mov ecx,eax
mov esi,edx
cmp eax,[_numlumps]
jb write_valid
push eax
push OFFSET FLAT:err_write
call Error_
add esp,8
write_valid:
lea eax,[ecx*4]
add eax,ecx
mov ecx,[_lumpinfo]
shl eax,2
add ecx,eax
xor ebx,ebx
mov eax,[ecx+6]
mov edx,[ecx+LUMP_POSITION]
sar eax,16
call lseek_
mov edx,esi
mov eax,[ecx+6]
mov ebx,[ecx+LUMP_SIZE]
sar eax,16
call SafeWrite_
pop esi
pop ecx
pop ebx
ret
# Genuine cache-hit block before the public cache entry, no separate export.
cache_hit:
mov eax,ecx
call Z_ChangeTag_
mov eax,[_lumpcache]
mov eax,[edi+eax]
call Z_Touch_
mov eax,[_lumpcache]
mov eax,[eax+esi*4]
add esp,4
pop ebp
pop edi
pop esi
pop ecx
ret
# real compiler no-op tail
{disp8} lea eax,[eax]
WAD_CacheLumpName_:
call WAD_GetNumForName_
# real compiler no-op tail
{disp8} lea eax,[eax]
# Real fallthrough entry preserves EDX zone / EBX tag.
WAD_CacheLumpNum_:
push ecx
push esi
push edi
push ebp
sub esp,4
mov esi,eax
mov ebp,edx
mov edx,ebx
cmp eax,[_numlumps]
jb cache_valid
push eax
push OFFSET FLAT:err_cache
call Error_
add esp,8
cache_valid:
mov eax,esi
call WAD_LumpLength_
mov [esp],eax
lea edi,[esi*4]
mov eax,[_lumpcache]
add eax,edi
mov ecx,[eax]
test ecx,ecx
jne cache_hit
mov ecx,eax
mov ebx,ebp
mov eax,[esp]
call Z_Malloc_
mov edx,[_lumpcache]
mov eax,esi
mov edx,[edx+edi]
call WAD_ReadLump_
mov eax,[_lumpcache]
mov eax,[eax+esi*4]
add esp,4
pop ebp
pop edi
pop esi
pop ecx
ret
# real compiler no-op tail
{disp8} lea eax,[eax]
WAD_CacheLumpDec_:
push esi
push edi
push ebp
sub esp,20
mov ebp,edx
mov edx,ebx
mov ebx,ecx
lea edi,[esp+12]
mov esi,eax
push edi
decimal_copy_base:
mov al,[esi]
mov [edi],al
cmp al,0
je decimal_base_ready
mov al,[esi+1]
add esi,2
mov [edi+1],al
add edi,2
cmp al,0
jne decimal_copy_base
decimal_base_ready:
pop edi
push ebp
push OFFSET FLAT:fmt_decimal
lea eax,[esp+8]
push eax
call sprintf_
add esp,12
mov edi,esp
sub ecx,ecx
dec ecx
xor eax,eax
repne scasb
not ecx
dec ecx
lea edi,[esp+12]
mov esi,ecx
sub ecx,ecx
dec ecx
xor eax,eax
repne scasb
not ecx
dec ecx
add ecx,esi
cmp ecx,8
jbe decimal_length_valid
push 8
lea eax,[esp+4]
push eax
lea eax,[esp+20]
push eax
push OFFSET FLAT:err_decimal
call Error_
add esp,16
decimal_length_valid:
mov esi,esp
lea edi,[esp+12]
push edi
{load} sub ecx,ecx
dec ecx
mov al,0
repne scasb
dec edi
decimal_append:
mov al,[esi]
mov [edi],al
cmp al,0
je decimal_name_ready
mov al,[esi+1]
add esi,2
mov [edi+1],al
add edi,2
cmp al,0
jne decimal_append
decimal_name_ready:
pop edi
lea eax,[esp+12]
call WAD_GetNumForName_
call WAD_CacheLumpNum_
add esp,20
pop ebp
pop edi
pop esi
ret
# naturally aligned; no instruction
WAD_CacheLumpHex_:
push esi
push edi
push ebp
sub esp,20
mov ebp,edx
mov edx,ebx
mov ebx,ecx
lea edi,[esp+12]
mov esi,eax
push edi
hex_copy_base:
mov al,[esi]
mov [edi],al
cmp al,0
je hex_base_ready
mov al,[esi+1]
add esi,2
mov [edi+1],al
add edi,2
cmp al,0
jne hex_copy_base
hex_base_ready:
pop edi
push ebp
push OFFSET FLAT:fmt_hexadecimal
lea eax,[esp+8]
push eax
call sprintf_
add esp,12
mov edi,esp
sub ecx,ecx
dec ecx
xor eax,eax
repne scasb
not ecx
dec ecx
lea edi,[esp+12]
mov esi,ecx
sub ecx,ecx
dec ecx
xor eax,eax
repne scasb
not ecx
dec ecx
add ecx,esi
cmp ecx,8
jbe hex_length_valid
push 8
lea eax,[esp+4]
push eax
lea eax,[esp+20]
push eax
push OFFSET FLAT:err_hexadecimal
call Error_
add esp,16
hex_length_valid:
mov esi,esp
lea edi,[esp+12]
push edi
{load} sub ecx,ecx
dec ecx
mov al,0
repne scasb
dec edi
hex_append:
mov al,[esi]
mov [edi],al
cmp al,0
je hex_name_ready
mov al,[esi+1]
add esi,2
mov [edi+1],al
add edi,2
cmp al,0
jne hex_append
hex_name_ready:
pop edi
lea eax,[esp+12]
call WAD_GetNumForName_
call WAD_CacheLumpNum_
add esp,20
pop ebp
pop edi
pop esi
ret
# naturally aligned; no instruction
WAD_LumptypeToString_:
mov eax,[_lumptypenames+eax*4]
ret
# naturally aligned; no instruction
WAD_ShootWAD_:
push ebx
push ecx
push esi
push edi
push ebp
sub esp,1052
mov [esp+1048],edx
mov edi,esp
mov esi,eax
lea edx,[esp+1028]
push edi
shoot_filename_copy:
mov al,[esi]
mov [edi],al
cmp al,0
je shoot_filename_ready
mov al,[esi+1]
add esi,2
mov [edi+1],al
add edi,2
cmp al,0
jne shoot_filename_copy
shoot_filename_ready:
pop edi
mov esi,OFFSET FLAT:extension_wad
mov ax,word ptr[extension_dot]
lea edi,[esp+1028]
mov [esp+1028],ax
push edi
{load} sub ecx,ecx
dec ecx
mov al,0
repne scasb
dec edi
shoot_extension_append:
mov al,[esi]
mov [edi],al
cmp al,0
je shoot_extension_ready
mov al,[esi+1]
add esi,2
mov [edi+1],al
add edi,2
cmp al,0
jne shoot_extension_append
shoot_extension_ready:
pop edi
mov eax,esp
call DefaultExtension_
mov eax,0x80000
call SafeMalloc_
mov edi,eax
mov eax,esp
xor ebp,ebp
call WAD_ReadHeader_
mov edx,[eax+WAD_COUNT]
mov esi,eax
test edx,edx
jle shoot_lumps_done
shoot_lump:
mov edx,[esi+WAD_DIRECTORY]
mov eax,[esi+WAD_HANDLE]
xor ebx,ebx
mov edx,[edx]
call lseek_
mov ebx,[esi+WAD_DIRECTORY]
mov edx,edi
mov eax,[esi+WAD_HANDLE]
mov ebx,[ebx+FILE_SIZE]
call SafeRead_
mov ebx,[esp+1048]
mov eax,[esi+WAD_DIRECTORY]
push ebx
mov ecx,[eax+FILE_TYPE]
lea ebx,[eax+FILE_NAME]
mov edx,[eax+FILE_SIZE]
mov eax,edi
call WAD_WriteWadLump_
mov ecx,[esi+WAD_DIRECTORY]
inc ebp
add ecx,FILE_BYTES
mov eax,[esi+WAD_COUNT]
mov [esi+WAD_DIRECTORY],ecx
cmp ebp,eax
jl shoot_lump
shoot_lumps_done:
mov eax,esi
call SafeFree_
mov eax,edi
call SafeFree_
add esp,1052
pop ebp
pop edi
pop esi
pop ecx
pop ebx
ret
# real compiler no-op tail
nop
WAD_OpenWadFile_:
push ebx
push ecx
push esi
push edi
push ebp
sub esp,1048
mov esi,eax
mov ebp,edx
cmp dword ptr[_wadfileopened],0
je open_not_open
push OFFSET FLAT:err_already_open
call Error_
add esp,4
open_not_open:
mov ebx,1
mov eax,MAX_LUMPS*FILE_BYTES
mov edi,esp
lea edx,[esp+1028]
mov [_wadfileopened],ebx
call malloc_
mov [_table_p],eax
mov [_table],eax
push edi
open_copy_filename:
mov al,[esi]
mov [edi],al
cmp al,0
je open_filename_ready
mov al,[esi+1]
add esi,2
mov [edi+1],al
add edi,2
cmp al,0
jne open_copy_filename
open_filename_ready:
pop edi
xor ebx,ebx
mov esi,OFFSET FLAT:extension_wad
mov ax,word ptr[extension_dot]
lea edi,[esp+1028]
mov [esp+1028],ax
push edi
{load} sub ecx,ecx
dec ecx
mov al,0
repne scasb
dec edi
open_extension_append:
mov al,[esi]
mov [edi],al
cmp al,0
je open_extension_ready
mov al,[esi+1]
add esi,2
mov [edi+1],al
add edi,2
cmp al,0
jne open_extension_append
open_extension_ready:
pop edi
mov eax,esp
mov esi,esp
call DefaultExtension_
mov eax,esp
xor edx,edx
mov edi,OFFSET FLAT:_wadfilename
call SafeOpenWrite_
mov edx,12
mov [_wadhandle],eax
push edi
open_save_filename:
mov al,[esi]
mov [edi],al
cmp al,0
je open_filename_saved
mov al,[esi+1]
add esi,2
mov [edi+1],al
add edi,2
cmp al,0
jne open_save_filename
open_filename_saved:
pop edi
mov eax,[_wadhandle]
call lseek_
test ebp,ebp
jne open_done
push OFFSET FLAT:msg_newline
call printf_
add esp,4
mov eax,esp
push eax
push OFFSET FLAT:msg_filename
call printf_
add esp,8
push OFFSET FLAT:msg_newline
call printf_
add esp,4
push OFFSET FLAT:msg_column_name
xor edx,edx
call printf_
add esp,4
open_spaces:
push 32
push OFFSET FLAT:fmt_character
inc edx
call printf_
add esp,8
cmp edx,4
jl open_spaces
push OFFSET FLAT:msg_column_type
call printf_
add esp,4
push OFFSET FLAT:msg_rule_name
xor edx,edx
call printf_
add esp,4
open_dashes:
push 45
push OFFSET FLAT:fmt_character
inc edx
call printf_
add esp,8
cmp edx,8
jl open_dashes
push OFFSET FLAT:msg_rule_type
call printf_
add esp,4
open_done:
add esp,1048
pop ebp
pop edi
pop esi
pop ecx
pop ebx
ret
# real compiler no-op tail
{load} mov eax,eax
WAD_WriteWadTable_:
push ebx
push ecx
push edx
push esi
sub esp,12
mov ebx,1
mov eax,[_wadhandle]
xor edx,edx
call lseek_
mov edx,[_table_p]
mov ebx,[_table]
mov esi,FILE_BYTES
sub edx,ebx
mov ecx,eax
mov eax,edx
sar edx,31
idiv esi
lea ebx,[eax*4]
mov edx,[_table]
add ebx,eax
mov eax,[_wadhandle]
shl ebx,2
call SafeWrite_
mov eax,[_wadhandle]
xor ebx,ebx
xor edx,edx
call lseek_
mov edx,[_table_p]
sub edx,[_table]
mov esi,FILE_BYTES
mov eax,edx
sar edx,31
idiv esi
mov ebx,4
call IntelLong_
mov [esp+4],eax
mov eax,ecx
mov edx,OFFSET FLAT:ident_iwad
call IntelLong_
mov [esp+8],eax
mov eax,esp
call strncpy_
mov ebx,12
mov edx,esp
mov eax,[_wadhandle]
call SafeWrite_
add esp,12
pop esi
pop edx
pop ecx
pop ebx
ret
# naturally aligned; no instruction
WAD_WriteWadLump_:
push esi
push edi
push ebp
sub esp,20
mov ebp,eax
mov esi,edx
mov edi,ebx
mov edx,[_table_p]
sub edx,[_table]
mov ebx,FILE_BYTES
mov eax,edx
sar edx,31
idiv ebx
cmp eax,MAX_LUMPS
jne write_lump_room
push OFFSET FLAT:_wadfilename
push OFFSET FLAT:err_too_many
call Error_
add esp,8
write_lump_room:
mov ebx,1
mov eax,[_wadhandle]
xor edx,edx
call lseek_
call IntelLong_
mov edx,[_table_p]
mov [edx],eax
mov eax,esi
call IntelLong_
mov edx,eax
mov eax,[_table_p]
mov [eax+FILE_SIZE],edx
mov ebx,8
mov [eax+FILE_TYPE],ecx
add eax,FILE_NAME
mov edx,edi
mov ecx,[esp+36]
call strncpy_
test ecx,ecx
jne write_lump_quiet
mov ebx,20
mov eax,esp
xor edx,edx
call memset_
mov ebx,8
xor ah,ah
mov edx,edi
mov [esp+8],ah
mov eax,esp
call strncpy_
mov eax,7
mov bh,32
xor edx,edx
write_lump_trailing_spaces:
cmp dl,[esp+eax]
jne write_lump_print
dec eax
mov [esp+eax+1],bh
test eax,eax
jge write_lump_trailing_spaces
write_lump_print:
mov edx,[_table_p]
mov eax,[edx+FILE_TYPE]
mov edi,[_lumptypenames+eax*4]
push edi
mov eax,[edx+FILE_SIZE]
mov ebx,[_table]
push eax
sub edx,ebx
lea eax,[esp+8]
mov ebx,FILE_BYTES
push eax
mov eax,edx
sar edx,31
idiv ebx
push eax
push OFFSET FLAT:fmt_lump
call printf_
add esp,20
write_lump_quiet:
add dword ptr[_table_p],FILE_BYTES
test esi,esi
jle write_lump_done
mov eax,[_wadhandle]
mov ebx,esi
mov edx,ebp
call SafeWrite_
write_lump_done:
add esp,20
pop ebp
pop edi
pop esi
ret 4
# real compiler no-op tail
{disp8} lea eax,[eax]
WAD_CloseWadFile_:
push ebx
push ecx
push edx
push edi
mov edx,eax
cmp dword ptr[_wadfileopened],0
jne close_is_open
push OFFSET FLAT:err_not_open
call Error_
add esp,4
close_is_open:
xor ecx,ecx
mov [_wadfileopened],ecx
call WAD_WriteWadTable_
mov eax,[_wadhandle]
call SafeClose_
mov eax,[_table]
call SafeFree_
test edx,edx
jne close_quiet
mov edx,[_table_p]
sub edx,[_table]
mov ebx,FILE_BYTES
mov eax,edx
sar edx,31
idiv ebx
push eax
push OFFSET FLAT:msg_total
call printf_
add esp,8
close_quiet:
xor edi,edi
mov [_table_p],edi
mov [_table],edi
pop edi
pop edx
pop ecx
pop ebx
ret
