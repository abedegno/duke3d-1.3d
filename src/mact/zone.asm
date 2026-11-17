; SPDX-License-Identifier: GPL-2.0-or-later; complete primary notices in C counterpart/headers.
; Complete symbolic ZONE recovery; readable C/Apogee GPL2-or-later lineage beside it.
; No historical ASM claim. Real private names remain nonPUBLIC.
.386p
.model flat
MEMBLOCK_BYTES equ 24
MEMZONE_BYTES equ 12
NUM_ZONES equ 8
MB_PRETAG equ 0
MB_ZONE_WORD_HIGH equ 2
MB_ZONE equ 4
MB_TAG equ 6
MB_SIZE equ 8
MB_USER equ 12
MB_NEXT equ 16
MB_PREV equ 20
ZONE_SIZE equ 0
ZONE_USED equ 4
ZONE_FREE equ 8
MIN_FRAGMENT equ 64
PURGE_LEVEL equ 100
MEMORY_PRETAG equ 01a2b3c4dh
_TEXT segment para public use32 'CODE'
ZONE_CODE_BEGIN label byte
_TEXT ends
CONST segment dword public use32 'DATA'
CONST ends
CONST2 segment dword public use32 'DATA'
CONST2 ends
_DATA segment dword public use32 'DATA'
_DATA ends
_BSS segment para public use32 'BSS'
_BSS ends
DGROUP group CONST,CONST2,_DATA,_BSS
public Z_FreeZone_,Z_Init_,Z_ShutDownZone_,Z_ShutDown_,Z_GetSize_
public Z_AddFreeBlock_,Z_FreeBlock_,Z_Free_,Z_FreeTags_,Z_PurgeZone_
public Z_FindBlockInFreeList_,Z_FindFreeBlock_,Z_Malloc_,Z_Touch_,Z_Realloc_
public Z_ZoneUsed_,Z_ZoneMaxFree_,Z_ZoneSize_,Z_ChangeTag_,Z_AvailHeap_
public Z_DumpHeap_,Z_CheckHeap_
extrn Error_:near,SafeMalloc_:near,malloc_:near,SafeFree_:near,free_:near
extrn memset_:near,int386x_:near,DBG_DbgString_:near
_TEXT segment para public use32 'CODE'
; Private range-checked8-entry zone lookup; default EAX argument/result.
Z_GetZonePtr_:
push edx
mov edx,eax
test eax,eax
jl get_zone_bad
cmp eax,NUM_ZONES
jl get_zone_load
get_zone_bad:
push offset msg_get_zone_range
call Error_
add esp,4
get_zone_load:
mov eax,dword ptr [_MemoryZone+edx*4]
pop edx
ret
align 4
; Private EAX index / EDX pointer setter.
Z_SetZonePtr_:
push ebx
mov ebx,eax
test eax,eax
jl set_zone_bad
cmp eax,NUM_ZONES
jl set_zone_store
set_zone_bad:
push offset msg_set_zone_range
call Error_
add esp,4
set_zone_store:
mov dword ptr [_MemoryZone+ebx*4],edx
pop ebx
ret
align 4
; Create real two-list sentinels, then one full free block after12-byte header.
Z_ClearZone_:
push ebx
push ecx
mov ecx,eax
mov eax,MEMBLOCK_BYTES
call SafeMalloc_
mov dword ptr [edx+ZONE_USED],eax
mov dword ptr [eax+MB_USER],2
mov dword ptr [eax+MB_PREV],eax
mov dword ptr [eax+MB_NEXT],eax
mov eax,dword ptr [edx+ZONE_USED]
mov dword ptr [eax+MB_SIZE],0
mov eax,dword ptr [edx+ZONE_USED]
mov word ptr [eax+MB_ZONE],cx
mov eax,MEMBLOCK_BYTES
call SafeMalloc_
mov dword ptr [edx+ZONE_FREE],eax
mov dword ptr [eax+MB_USER],2
mov dword ptr [eax+MB_PREV],eax
mov dword ptr [eax+MB_NEXT],eax
mov eax,dword ptr [edx+ZONE_FREE]
mov dword ptr [eax+MB_SIZE],0
mov eax,dword ptr [edx+ZONE_FREE]
mov word ptr [eax+MB_ZONE],cx
lea ebx,[edx+MEMZONE_BYTES]
mov eax,dword ptr [edx+ZONE_FREE]
mov dword ptr [ebx+MB_NEXT],eax
mov eax,dword ptr [eax+MB_PREV]
mov dword ptr [ebx+MB_PREV],eax
mov eax,dword ptr [edx+ZONE_FREE]
mov eax,dword ptr [eax+MB_PREV]
mov dword ptr [eax+MB_NEXT],ebx
mov eax,dword ptr [edx+ZONE_FREE]
mov dword ptr [eax+MB_PREV],ebx
mov dword ptr [ebx+MB_USER],0
mov edx,dword ptr [edx+ZONE_SIZE]
mov word ptr [ebx+MB_TAG],0
sub edx,MEMZONE_BYTES
mov word ptr [ebx+MB_ZONE],cx
mov dword ptr [ebx+MB_SIZE],edx
pop ecx
pop ebx
ret
align 4
; Allocate the real zone owner; retain legacy size/error arithmetic.
Z_AllocateZone_:
push ebx
push ecx
push esi
mov ecx,eax
mov esi,edx
add edx,MEMZONE_BYTES
mov eax,edx
call malloc_
mov ebx,eax
test eax,eax
jne allocate_zone_ready
call Z_AvailHeap_
push eax
push edx
push offset msg_allocate_zone
call Error_
add esp,12
allocate_zone_ready:
mov edx,ebx
mov eax,ecx
mov dword ptr [ebx+ZONE_SIZE],esi
call Z_ClearZone_
mov eax,ebx
pop esi
pop ecx
pop ebx
ret
align 4
Z_GetFreeZone_:
push ebx
push edx
mov ebx,-1
xor edx,edx
find_zone_next:
mov eax,edx
call Z_GetZonePtr_
test eax,eax
jne find_zone_advance
mov ebx,edx
jmp find_zone_done
find_zone_advance:
inc edx
cmp edx,NUM_ZONES
jl find_zone_next
find_zone_done:
cmp ebx,-1
jne find_zone_return
push offset msg_no_free_zone
call Error_
add esp,4
find_zone_return:
mov eax,ebx
pop edx
pop ebx
ret
align 4
Z_FreeZone_ proc near
push ebx
push edx
mov ebx,eax
call Z_GetZonePtr_
mov edx,eax
test eax,eax
jne free_zone_active
push ebx
push offset msg_free_zone_inactive
call Error_
add esp,8
free_zone_active:
mov eax,dword ptr [edx+ZONE_USED]
call SafeFree_
mov eax,dword ptr [edx+ZONE_FREE]
call SafeFree_
mov eax,ebx
call Z_GetZonePtr_
call free_
xor edx,edx
mov eax,ebx
call Z_SetZonePtr_
pop edx
pop ebx
ret
Z_FreeZone_ endp
align 4
Z_Init_ proc near
push ebx
push edx
mov edx,eax
call Z_GetFreeZone_
mov ebx,eax
call Z_AllocateZone_
mov edx,eax
mov eax,ebx
call Z_SetZonePtr_
mov eax,ebx
pop edx
pop ebx
ret
Z_Init_ endp
align 4
Z_ShutDownZone_ proc near
push edx
mov edx,eax
call Z_GetZonePtr_
test eax,eax
je shutdown_zone_done
mov eax,edx
call Z_PurgeZone_
mov eax,edx
call Z_FreeZone_
shutdown_zone_done:
pop edx
ret
Z_ShutDownZone_ endp
align 4
Z_ShutDown_ proc near
push edx
xor edx,edx
shutdown_next:
mov eax,edx
call Z_GetZonePtr_
test eax,eax
je shutdown_advance
mov eax,edx
call Z_PurgeZone_
mov eax,edx
call Z_FreeZone_
shutdown_advance:
inc edx
cmp edx,NUM_ZONES
jl shutdown_next
pop edx
ret
Z_ShutDown_ endp
align 4
Z_GetSize_ proc near
push edx
lea edx,[eax-MEMBLOCK_BYTES]
; Native signed zone extraction is DWORD load at+2 then SAR16.
mov eax,dword ptr [edx+MB_ZONE_WORD_HIGH]
sar eax,16
call Z_GetZonePtr_
test eax,eax
jne get_size_active
mov eax,dword ptr [edx+MB_ZONE_WORD_HIGH]
sar eax,16
push eax
push offset msg_get_size_inactive
call Error_
add esp,8
get_size_active:
mov eax,dword ptr [edx+MB_SIZE]
sub eax,MEMBLOCK_BYTES
pop edx
ret
Z_GetSize_ endp
align 4
; Insert by address and coalesce adjacent real blocks in both directions.
Z_AddFreeBlock_ proc near
push ebx
push ecx
push esi
mov ebx,eax
mov ecx,dword ptr [edx+ZONE_FREE]
mov eax,dword ptr [ecx+MB_NEXT]
cmp eax,ecx
je free_block_insert
free_block_find:
cmp ebx,eax
jbe free_block_insert
mov eax,dword ptr [eax+MB_NEXT]
cmp eax,dword ptr [edx+ZONE_FREE]
jne free_block_find
free_block_insert:
mov edx,dword ptr [eax+MB_PREV]
mov ecx,dword ptr [edx+MB_SIZE]
add ecx,edx
cmp ecx,ebx
jne free_block_link
mov eax,dword ptr [ebx+MB_SIZE]
mov esi,dword ptr [edx+MB_SIZE]
add esi,eax
mov ebx,edx
mov dword ptr [edx+MB_SIZE],esi
jmp free_block_merge_next
free_block_link:
mov dword ptr [ebx+MB_NEXT],eax
mov edx,dword ptr [eax+MB_PREV]
mov dword ptr [ebx+MB_PREV],edx
mov dword ptr [edx+MB_NEXT],ebx
mov dword ptr [eax+MB_PREV],ebx
free_block_merge_next:
mov edx,dword ptr [ebx+MB_SIZE]
mov eax,dword ptr [ebx+MB_NEXT]
add edx,ebx
cmp edx,eax
jne free_block_return
mov edx,dword ptr [eax+MB_SIZE]
add dword ptr [ebx+MB_SIZE],edx
mov ecx,dword ptr [eax+MB_PREV]
mov edx,dword ptr [eax+MB_NEXT]
mov dword ptr [ecx+MB_NEXT],edx
mov ecx,edx
mov edx,dword ptr [eax+MB_PREV]
mov dword ptr [ecx+MB_PREV],edx
mov dword ptr [eax+MB_NEXT],eax
mov dword ptr [eax+MB_PREV],eax
free_block_return:
mov eax,ebx
mov word ptr [ebx+MB_TAG],0
pop esi
pop ecx
pop ebx
ret
Z_AddFreeBlock_ endp
align 4
Z_FreeBlock_ proc near
push ebx
push ecx
push esi
mov ebx,eax
cmp dword ptr [eax+MB_USER],0
jne free_block_allocated
push offset msg_free_freed
call Error_
add esp,4
free_block_allocated:
mov esi,dword ptr [ebx+MB_USER]
cmp esi,256
jbe free_block_clear_owner
mov dword ptr [esi],0
free_block_clear_owner:
mov dword ptr [ebx+MB_USER],0
mov ecx,dword ptr [ebx+MB_PREV]
mov eax,dword ptr [ebx+MB_NEXT]
mov dword ptr [ecx+MB_NEXT],eax
mov ecx,eax
mov eax,dword ptr [ebx+MB_PREV]
mov dword ptr [ecx+MB_PREV],eax
mov dword ptr [ebx+MB_NEXT],ebx
mov eax,ebx
mov dword ptr [ebx+MB_PREV],ebx
call Z_AddFreeBlock_
pop esi
pop ecx
pop ebx
ret
Z_FreeBlock_ endp
align 4
Z_Free_ proc near
push ebx
push edx
lea ebx,[eax-MEMBLOCK_BYTES]
mov eax,dword ptr [ebx+MB_ZONE_WORD_HIGH]
sar eax,16
call Z_GetZonePtr_
mov edx,eax
test eax,eax
jne free_active_zone
mov eax,dword ptr [ebx+MB_ZONE_WORD_HIGH]
sar eax,16
push eax
push offset msg_free_inactive
call Error_
add esp,8
free_active_zone:
mov eax,ebx
call Z_FreeBlock_
pop edx
pop ebx
ret
Z_Free_ endp
align 4
; Free the actual inclusive signed tag interval, saving next before coalescing.
Z_FreeTags_ proc near
push ecx
push esi
push edi
push ebp
mov ebp,edx
mov edi,ebx
call Z_GetZonePtr_
mov ecx,eax
test eax,eax
je free_tags_done
mov eax,dword ptr [eax+ZONE_USED]
mov ebx,dword ptr [eax+MB_NEXT]
cmp ebx,eax
je free_tags_done
free_tags_next:
mov eax,dword ptr [ebx+MB_USER]
mov esi,dword ptr [ebx+MB_NEXT]
test eax,eax
jne free_tags_allocated
push offset msg_free_tags_freed
call Error_
add esp,4
free_tags_allocated:
mov eax,dword ptr [ebx+MB_ZONE]
sar eax,16
cmp eax,ebp
jl free_tags_advance
cmp eax,edi
jg free_tags_advance
mov edx,ecx
mov eax,ebx
call Z_FreeBlock_
free_tags_advance:
mov edx,dword ptr [ecx+ZONE_USED]
mov ebx,esi
cmp esi,edx
jne free_tags_next
free_tags_done:
pop ebp
pop edi
pop esi
pop ecx
ret
Z_FreeTags_ endp
align 4
Z_PurgeZone_ proc near
push ebx
push ecx
push edx
push esi
push edi
mov ebx,eax
call Z_GetZonePtr_
mov ecx,eax
test eax,eax
jne purge_zone_active
push ebx
push offset msg_purge_inactive
call Error_
add esp,8
purge_zone_active:
mov eax,dword ptr [ecx+ZONE_USED]
mov ebx,dword ptr [eax+MB_NEXT]
cmp ebx,eax
je purge_zone_done
purge_zone_next:
mov edi,dword ptr [ebx+MB_USER]
mov esi,dword ptr [ebx+MB_NEXT]
test edi,edi
jne purge_zone_allocated
push offset msg_purge_freed
call Error_
add esp,4
purge_zone_allocated:
mov edx,ecx
mov eax,ebx
call Z_FreeBlock_
mov edx,dword ptr [ecx+ZONE_USED]
mov ebx,esi
cmp esi,edx
jne purge_zone_next
purge_zone_done:
pop edi
pop esi
pop edx
pop ecx
pop ebx
ret
Z_PurgeZone_ endp
align 4
Z_FindBlockInFreeList_ proc near
push ebx
push ecx
push edi
mov ebx,eax
mov ecx,dword ptr [eax+ZONE_FREE]
mov eax,dword ptr [ecx+MB_NEXT]
cmp eax,ecx
je find_block_end
find_block_next:
cmp edx,dword ptr [eax+MB_SIZE]
jle find_block_end
mov eax,dword ptr [eax+MB_NEXT]
cmp eax,dword ptr [ebx+ZONE_FREE]
jne find_block_next
find_block_end:
mov edi,dword ptr [ebx+ZONE_FREE]
cmp eax,edi
jne find_block_done
xor eax,edi
find_block_done:
pop edi
pop ecx
pop ebx
ret
Z_FindBlockInFreeList_ endp
align 4
; First-fit free search followed by real purgeable-owner scan/coalescing.
Z_FindFreeBlock_ proc near
push ebx
push ecx
push esi
push edi
mov ebx,eax
mov esi,edx
mov edi,dword ptr [eax+ZONE_FREE]
mov ecx,eax
mov eax,dword ptr [edi+MB_NEXT]
cmp eax,edi
je find_free_initial_end
find_free_initial_next:
cmp edx,dword ptr [eax+MB_SIZE]
jle find_free_initial_end
mov eax,dword ptr [eax+MB_NEXT]
cmp eax,dword ptr [ecx+ZONE_FREE]
jne find_free_initial_next
find_free_initial_end:
mov edx,dword ptr [ecx+ZONE_FREE]
cmp eax,edx
jne find_free_check
xor eax,edx
find_free_check:
test eax,eax
jne find_free_return
mov edx,dword ptr [ebx+ZONE_USED]
mov eax,dword ptr [edx+MB_NEXT]
cmp eax,edx
je find_free_none
find_free_purge_next:
mov dx,word ptr [eax+MB_TAG]
mov ecx,dword ptr [eax+MB_NEXT]
cmp dx,PURGE_LEVEL
jl find_free_purge_advance
mov edx,ebx
call Z_FreeBlock_
cmp esi,dword ptr [eax+MB_SIZE]
jle find_free_return
find_free_purge_advance:
mov edi,dword ptr [ebx+ZONE_USED]
mov eax,ecx
cmp ecx,edi
jne find_free_purge_next
find_free_none:
xor eax,eax
find_free_return:
pop edi
pop esi
pop ecx
pop ebx
ret
Z_FindFreeBlock_ endp
align 4
; EAX=size,EDX=tag,EBX=zone,ECX=owner under the genuine default4-arg ABI.
; Three genuine DWORD frame homes hold tag,extra and zone. EBP retains owner.
Z_Malloc_ proc near
push esi
push edi
push ebp
sub esp,12
mov esi,eax
mov dword ptr [esp],edx
mov dword ptr [esp+8],ebx
mov ebp,ecx
mov eax,ebx
call Z_GetZonePtr_
mov ebx,eax
test eax,eax
jne malloc_zone_active
mov edx,dword ptr [esp+8]
push edx
push esi
push offset msg_malloc_inactive
call Error_
add esp,12
malloc_zone_active:
add esi,MEMBLOCK_BYTES
mov eax,ebx
mov edx,esi
call Z_FindFreeBlock_
mov edx,eax
test eax,eax
jne malloc_block_found
push esi
push offset msg_malloc_failed
call Error_
add esp,8
malloc_block_found:
mov eax,dword ptr [edx+MB_SIZE]
sub eax,esi
mov dword ptr [esp+4],eax
mov eax,dword ptr [edx+MB_PREV]
mov ecx,dword ptr [edx+MB_NEXT]
mov dword ptr [eax+MB_NEXT],ecx
mov eax,dword ptr [edx+MB_PREV]
mov dword ptr [ecx+MB_PREV],eax
mov dword ptr [edx+MB_NEXT],edx
mov edi,dword ptr [esp+4]
mov dword ptr [edx+MB_PREV],edx
cmp edi,MIN_FRAGMENT
jle malloc_owner
lea eax,[edx+esi]
mov dword ptr [eax+MB_USER],0
mov word ptr [eax+MB_TAG],0
mov dword ptr [eax+MB_SIZE],edi
mov dword ptr [eax+MB_NEXT],ecx
mov edi,dword ptr [esp+8]
mov word ptr [eax+MB_ZONE],di
mov edi,dword ptr [ecx+MB_PREV]
mov dword ptr [eax+MB_PREV],edi
mov dword ptr [edi+MB_NEXT],eax
mov dword ptr [ecx+MB_PREV],eax
mov dword ptr [edx+MB_SIZE],esi
malloc_owner:
test ebp,ebp
je malloc_no_owner
lea eax,[edx+MEMBLOCK_BYTES]
mov dword ptr [edx+MB_USER],ebp
mov dword ptr [ebp],eax
jmp malloc_tag
malloc_no_owner:
cmp dword ptr [esp],PURGE_LEVEL
jl malloc_unowned
push offset msg_malloc_owner_required
call Error_
add esp,4
malloc_unowned:
mov dword ptr [edx+MB_USER],2
malloc_tag:
mov eax,dword ptr [esp]
mov dword ptr [edx+MB_PRETAG],MEMORY_PRETAG
mov word ptr [edx+MB_TAG],ax
mov eax,dword ptr [ebx+ZONE_USED]
mov dword ptr [edx+MB_NEXT],eax
mov eax,dword ptr [eax+MB_PREV]
mov dword ptr [edx+MB_PREV],eax
mov eax,dword ptr [ebx+ZONE_USED]
mov eax,dword ptr [eax+MB_PREV]
mov dword ptr [eax+MB_NEXT],edx
mov eax,dword ptr [ebx+ZONE_USED]
mov dword ptr [eax+MB_PREV],edx
lea eax,[edx+MEMBLOCK_BYTES]
add esp,12
pop ebp
pop edi
pop esi
ret
Z_Malloc_ endp
align 4
; Move an actual allocated block to the used-list tail (LRU touch).
Z_Touch_ proc near
push ebx
push ecx
push edx
lea edx,[eax-MEMBLOCK_BYTES]
mov eax,dword ptr [edx+MB_ZONE_WORD_HIGH]
sar eax,16
call Z_GetZonePtr_
mov ebx,eax
test eax,eax
jne touch_zone_active
mov eax,dword ptr [edx+MB_ZONE_WORD_HIGH]
sar eax,16
push eax
push offset msg_touch_inactive
call Error_
add esp,8
touch_zone_active:
; Preserve LL_Remove's real alias-visible reload/order and next-link temporary.
mov ecx,dword ptr [edx+MB_PREV]
mov eax,dword ptr [edx+MB_NEXT]
mov dword ptr [ecx+MB_NEXT],eax
mov ecx,eax
mov eax,dword ptr [edx+MB_PREV]
mov dword ptr [ecx+MB_PREV],eax
mov dword ptr [edx+MB_NEXT],edx
mov dword ptr [edx+MB_PREV],edx
mov eax,dword ptr [ebx+ZONE_USED]
mov dword ptr [edx+MB_NEXT],eax
mov eax,dword ptr [eax+MB_PREV]
mov dword ptr [edx+MB_PREV],eax
mov eax,dword ptr [ebx+ZONE_USED]
mov eax,dword ptr [eax+MB_PREV]
mov dword ptr [eax+MB_NEXT],edx
mov eax,dword ptr [ebx+ZONE_USED]
mov dword ptr [eax+MB_PREV],edx
pop edx
pop ecx
pop ebx
ret
Z_Touch_ endp
align 4
; Preserve legacy full stored-block-size copy, including its owner interactions.
Z_Realloc_ proc near
push ebx
push ecx
push esi
push edi
push ebp
mov ebp,eax
mov esi,edx
mov edx,dword ptr [eax]
mov ebx,dword ptr [edx-MEMBLOCK_BYTES+MB_ZONE_WORD_HIGH]
sar ebx,16
mov eax,ebx
sub edx,MEMBLOCK_BYTES
call Z_GetZonePtr_
test eax,eax
jne realloc_active
mov eax,dword ptr [edx+MB_ZONE_WORD_HIGH]
sar eax,16
push eax
push offset msg_realloc_inactive
call Error_
add esp,8
realloc_active:
mov edi,dword ptr [edx+MB_SIZE]
mov eax,dword ptr [edx+MB_ZONE]
mov ecx,dword ptr [edx+MB_USER]
sar eax,16
cmp ecx,ebp
je realloc_owner_ready
xor ecx,ecx
realloc_owner_ready:
mov edx,eax
mov eax,esi
call Z_Malloc_
mov ecx,edi
mov esi,dword ptr [ebp]
mov edi,eax
mov edx,eax
push edi
mov eax,ecx
shr ecx,2
repne movsd
mov cl,al
and cl,3
repne movsb
pop edi
mov eax,dword ptr [ebp]
call Z_Free_
mov dword ptr [ebp],edx
pop ebp
pop edi
pop esi
pop ecx
pop ebx
ret
Z_Realloc_ endp
align 4
Z_ZoneUsed_ proc near
push ebx
push ecx
push edx
push esi
mov edx,eax
call Z_GetZonePtr_
mov ebx,eax
test eax,eax
jne zone_used_active
push edx
push offset msg_zone_used_inactive
call Error_
add esp,8
zone_used_active:
mov ecx,dword ptr [ebx+ZONE_USED]
mov eax,dword ptr [ecx+MB_NEXT]
xor edx,edx
cmp eax,ecx
je zone_used_done
zone_used_next:
mov ecx,dword ptr [eax+MB_SIZE]
mov esi,dword ptr [ebx+ZONE_USED]
mov eax,dword ptr [eax+MB_NEXT]
add edx,ecx
cmp eax,esi
jne zone_used_next
zone_used_done:
mov eax,edx
pop esi
pop edx
pop ecx
pop ebx
ret
Z_ZoneUsed_ endp
align 4
Z_ZoneMaxFree_ proc near
push ebx
push ecx
push edx
push esi
mov edx,eax
call Z_GetZonePtr_
mov ebx,eax
test eax,eax
jne zone_max_active
push edx
push offset msg_zone_max_inactive
call Error_
add esp,8
zone_max_active:
mov ecx,dword ptr [ebx+ZONE_FREE]
mov eax,dword ptr [ecx+MB_NEXT]
xor edx,edx
cmp eax,ecx
je zone_max_done
zone_max_next:
mov esi,dword ptr [eax+MB_SIZE]
cmp edx,esi
jge zone_max_advance
mov edx,esi
zone_max_advance:
mov eax,dword ptr [eax+MB_NEXT]
cmp eax,dword ptr [ebx+ZONE_FREE]
jne zone_max_next
zone_max_done:
mov eax,edx
pop esi
pop edx
pop ecx
pop ebx
ret
Z_ZoneMaxFree_ endp
align 4
Z_ZoneSize_ proc near
push ebx
push edx
mov edx,eax
call Z_GetZonePtr_
mov ebx,eax
test eax,eax
jne zone_size_active
push edx
push offset msg_zone_size_inactive
call Error_
add esp,8
zone_size_active:
mov eax,dword ptr [ebx+ZONE_SIZE]
pop edx
pop ebx
ret
Z_ZoneSize_ endp
align 4
Z_ChangeTag_ proc near
push ebx
mov ebx,edx
lea edx,[eax-MEMBLOCK_BYTES]
mov eax,dword ptr [edx+MB_ZONE_WORD_HIGH]
sar eax,16
call Z_GetZonePtr_
test eax,eax
jne change_tag_active
mov eax,dword ptr [edx+MB_ZONE_WORD_HIGH]
sar eax,16
push eax
push offset msg_change_tag_inactive
call Error_
add esp,8
change_tag_active:
mov word ptr [edx+MB_TAG],bx
pop ebx
ret
Z_ChangeTag_ endp
align 4
; Real DPMI service500: union REGS28 + SREGS12, not invented frame padding.
Z_AvailHeap_ proc near
push ebx
push ecx
push edx
sub esp,40
mov ebx,12
lea eax,[esp+28]
xor edx,edx
lea ecx,[esp+28]
call memset_
mov edx,500h
; Preserve compiler's FP_SEG address evaluation followed by selector extraction.
mov eax,offset _MemInfo
mov dword ptr [esp],edx
mov dx,ds
mov ebx,offset _MemInfo
mov eax,31h
mov word ptr [esp+28],dx
mov dword ptr [esp+20],ebx
mov ebx,esp
mov edx,esp
call int386x_
mov eax,dword ptr [_MemInfo]
add esp,40
pop edx
pop ecx
pop ebx
ret
Z_AvailHeap_ endp
align 4
; Inclusive tag diagnostics over real blocks; no invented record/string payload.
Z_DumpHeap_ proc near
push ebx
push ecx
push esi
push edi
push ebp
sub esp,4
mov ecx,eax
mov esi,edx
xor edx,edx
mov dword ptr [esp],edx
dump_zone_next:
mov eax,dword ptr [esp]
call Z_GetZonePtr_
mov edx,eax
mov edi,eax
test eax,eax
jne dump_zone_active
mov edx,dword ptr [esp]
push edx
push offset msg_dump_inactive
jmp dump_zone_print_pair
dump_zone_active:
mov ebp,dword ptr [esp]
push ebp
push offset msg_dump_zone
call DBG_DbgString_
add esp,8
push edx
mov eax,dword ptr [edx+ZONE_SIZE]
push eax
push offset msg_dump_size
call DBG_DbgString_
add esp,12
push esi
push ecx
push offset msg_dump_tags
call DBG_DbgString_
mov eax,dword ptr [edx+ZONE_USED]
xor ebx,ebx
mov edx,dword ptr [eax+MB_NEXT]
add esp,12
cmp edx,eax
je near ptr dump_zone_total
dump_block_next:
mov eax,dword ptr [edx+MB_ZONE]
sar eax,16
cmp eax,ecx
jl dump_block_integrity
cmp eax,esi
jg dump_block_integrity
push eax
mov eax,dword ptr [edx+MB_USER]
push eax
mov ebp,dword ptr [edx+MB_SIZE]
push ebp
push edx
push offset msg_dump_block
call DBG_DbgString_
mov eax,dword ptr [edx+MB_SIZE]
add esp,20
add ebx,eax
dump_block_integrity:
mov eax,dword ptr [edx+MB_SIZE]
mov ebp,dword ptr [edx+MB_NEXT]
add eax,edx
cmp eax,ebp
je dump_back_link
push offset msg_dump_size_link
call DBG_DbgString_
add esp,4
dump_back_link:
mov eax,dword ptr [edx+MB_NEXT]
cmp edx,dword ptr [eax+MB_PREV]
je dump_two_free
push offset msg_dump_back_link
call DBG_DbgString_
add esp,4
dump_two_free:
cmp dword ptr [edx+MB_USER],0
jne dump_block_advance
mov eax,dword ptr [edx+MB_NEXT]
cmp dword ptr [eax+MB_USER],0
jne dump_block_advance
push offset msg_dump_two_free
call DBG_DbgString_
add esp,4
dump_block_advance:
mov edx,dword ptr [edx+MB_NEXT]
cmp edx,dword ptr [edi+ZONE_USED]
jne dump_block_next
dump_zone_total:
push ebx
push offset msg_dump_total
dump_zone_print_pair:
call DBG_DbgString_
add esp,8
mov ebx,dword ptr [esp]
inc ebx
mov dword ptr [esp],ebx
cmp ebx,NUM_ZONES
jl dump_zone_next
add esp,4
pop ebp
pop edi
pop esi
pop ecx
pop ebx
ret
Z_DumpHeap_ endp
align 4
Z_CheckHeap_ proc near
push ebx
push ecx
push edx
push esi
push edi
push ebp
xor ecx,ecx
mov edi,offset msg_check_back_link
xor esi,esi
check_zone_next:
mov eax,ecx
call Z_GetZonePtr_
mov ebx,eax
test eax,eax
je near ptr check_zone_advance
mov eax,dword ptr [eax+ZONE_USED]
mov edx,dword ptr [eax+MB_NEXT]
cmp edx,eax
je near ptr check_zone_advance
check_block_next:
mov eax,dword ptr [edx+MB_SIZE]
mov ebp,dword ptr [edx+MB_NEXT]
add eax,edx
cmp eax,ebp
je check_back_link
push offset msg_check_size_link
call Error_
add esp,4
check_back_link:
mov eax,dword ptr [edx+MB_NEXT]
cmp edx,dword ptr [eax+MB_PREV]
je check_two_free
push edi
call Error_
add esp,4
check_two_free:
cmp esi,dword ptr [edx+MB_USER]
jne check_pretag
mov eax,dword ptr [edx+MB_NEXT]
cmp esi,dword ptr [eax+MB_USER]
jne check_pretag
push offset msg_check_two_free
call Error_
add esp,4
check_pretag:
cmp si,word ptr [edx+MB_TAG]
jge check_block_advance
cmp esi,dword ptr [edx+MB_USER]
jae check_block_advance
cmp dword ptr [edx+MB_PRETAG],MEMORY_PRETAG
je check_block_advance
push offset msg_check_pretag
call Error_
add esp,4
check_block_advance:
mov edx,dword ptr [edx+MB_NEXT]
cmp edx,dword ptr [ebx+ZONE_USED]
jne check_block_next
check_zone_advance:
inc ecx
cmp ecx,NUM_ZONES
jl check_zone_next
pop ebp
pop edi
pop esi
pop edx
pop ecx
pop ebx
ret
Z_CheckHeap_ endp
if2
.errnz (Z_GetZonePtr_-ZONE_CODE_BEGIN-0)
.errnz (Z_SetZonePtr_-ZONE_CODE_BEGIN-36)
.errnz (Z_ClearZone_-ZONE_CODE_BEGIN-72)
.errnz (Z_AllocateZone_-ZONE_CODE_BEGIN-220)
.errnz (Z_GetFreeZone_-ZONE_CODE_BEGIN-280)
endif
; No end ALIGN: this member's final return is the real complete CODE boundary.
_TEXT ends
CONST segment dword public use32 'DATA'
include DIAG.INC
CONST ends
_DATA segment dword public use32 'DATA'
ZONE_DATA_BEGIN label byte
_MemoryZone dd NUM_ZONES dup(0)
if2
.errnz (_MemoryZone-ZONE_DATA_BEGIN)
.errnz ($-_MemoryZone-NUM_ZONES*4)
endif
_DATA ends
_BSS segment para public use32 'BSS'
ZONE_BSS_BEGIN label byte
; Actual DPMI record:9real result fields plus3real reserved DWORDs.
_MemInfo label byte
LargestBlockAvail dd ?
MaxUnlockedPage dd ?
LargestLockablePage dd ?
LinAddrSpace dd ?
NumFreePagesAvail dd ?
NumPhysicalPagesFree dd ?
TotalPhysicalPages dd ?
FreeLinAddrSpace dd ?
SizeOfPageFile dd ?
Reserved dd 3 dup(?)
if2
.errnz (_MemInfo-ZONE_BSS_BEGIN)
.errnz ($-_MemInfo-48)
endif
_BSS ends
end
