; Authored complete MACT VECTOR symbolic reconstruction, not historical ASM.
; Released VECTOR.H/TYPES.H/DEVELOP.H notices and readable C counterpart retained.
; Actual appfloat=double, default Watcom register/stack/struct-return ABI.
; No opcode data, synthetic storage, aliases, private exports or ORG.
.386p
.387
.model flat
_TEXT segment para public use32 'CODE'
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
includelib math387r
includelib emu387
; True native C-runtime metadata imports, including unused FPU requirements.
extrn __get_errno_ptr_:near
extrn _fltused_:byte
extrn __init_387_emulator:near
extrn __8087:word
V_X equ 0
V_Y equ 8
V_Z equ 16
VECTOR_BYTES equ 24
DOUBLE_BYTES equ 8
LENGTH_HOME equ 8
NORM_FRAME equ 16
CROSS_FRAME equ 16
CROSS_FIRST equ 0
CROSS_SECOND equ 8
ROT_FRAME equ 104
ROT_CROSS equ 0
ROT_RESULT equ 24
ROT_AXIS equ 48
ROT_SCALED equ 72
ROT_COS equ 124
ROT_SIN equ 132
_TEXT segment para public use32 'CODE'
public FP_VectorAdd_,FP_VectorSub_,FP_ScaleVector_,FP_VectorLength_
public FP_NormalizeVector_,FP_2x2Det_,FP_CrossProduct_,FP_TripleProduct_
public FP_DecomposeVector_,FP_RotateVAV_
; EAX result,EDX v1,EBX v2; actual sequential alias-visible stores.
FP_VectorAdd_ proc near
 fld qword ptr [edx+V_X]
 fadd qword ptr [ebx+V_X]
 fstp qword ptr [eax+V_X]
 fld qword ptr [edx+V_Y]
 fadd qword ptr [ebx+V_Y]
 fstp qword ptr [eax+V_Y]
 fld qword ptr [edx+V_Z]
 fadd qword ptr [ebx+V_Z]
 fstp qword ptr [eax+V_Z]
 ret
FP_VectorAdd_ endp
align 4
FP_VectorSub_ proc near
 fld qword ptr [edx+V_X]
 fsub qword ptr [ebx+V_X]
 fstp qword ptr [eax+V_X]
 fld qword ptr [edx+V_Y]
 fsub qword ptr [ebx+V_Y]
 fstp qword ptr [eax+V_Y]
 fld qword ptr [edx+V_Z]
 fsub qword ptr [ebx+V_Z]
 fstp qword ptr [eax+V_Z]
 ret
FP_VectorSub_ endp
align 4
; Scalar appfloat remains actual stack QWORD argument with callee cleanup8.
FP_ScaleVector_ proc near
 fld qword ptr [esp+4]
 fld qword ptr [edx+V_X]
 fmul st(0),st(1)
 fstp qword ptr [eax+V_X]
 fld qword ptr [edx+V_Y]
 fmul st(0),st(1)
 fstp qword ptr [eax+V_Y]
 fmul qword ptr [edx+V_Z]
 fstp qword ptr [eax+V_Z]
 ret 8
FP_ScaleVector_ endp
align 4
; Native square-root result is spilled across the genuine unused errno query.
FP_VectorLength_ proc near
 sub esp,DOUBLE_BYTES
 fld qword ptr [eax+V_Y]
 fmul st(0),st(0)
 fld qword ptr [eax+V_X]
 fmul st(0),st(0)
 faddp st(1),st(0)
 fld qword ptr [eax+V_Z]
 fmul st(0),st(0)
 faddp st(1),st(0)
 fsqrt
 fstp qword ptr [esp]
 call __get_errno_ptr_
 fld qword ptr [esp]
 add esp,DOUBLE_BYTES
 ret
FP_VectorLength_ endp
align 4
; Preserve native division-by-zero/nonfinite behavior; no added length guard.
FP_NormalizeVector_ proc near
 push edx
 sub esp,NORM_FRAME
 mov edx,eax
 fld qword ptr [eax+V_Y]
 fmul st(0),st(0)
 fld qword ptr [eax+V_X]
 fmul st(0),st(0)
 faddp st(1),st(0)
 fld qword ptr [eax+V_Z]
 fmul st(0),st(0)
 faddp st(1),st(0)
 fsqrt
 fstp qword ptr [esp+LENGTH_HOME]
 call __get_errno_ptr_
 fld1
 fdiv qword ptr [esp+LENGTH_HOME]
 fld qword ptr [edx+V_X]
 fmul st(0),st(1)
 fstp qword ptr [edx+V_X]
 fld qword ptr [edx+V_Y]
 fmul st(0),st(1)
 fstp qword ptr [edx+V_Y]
 fmul qword ptr [edx+V_Z]
 fstp qword ptr [edx+V_Z]
 add esp,NORM_FRAME
 pop edx
 ret
FP_NormalizeVector_ endp
align 4
; Four appfloat arguments remain QWORD stack slots, returning ST0, RET32.
FP_2x2Det_ proc near
 fld qword ptr [esp+4]
 fmul qword ptr [esp+28]
 fld qword ptr [esp+20]
 fmul qword ptr [esp+12]
 fsubp st(1),st(0)
 ret 32
FP_2x2Det_ endp
align 4
; Preserve determinant argument copies and rounding/alias-visible store order.
FP_CrossProduct_ proc near
 push ecx
 sub esp,CROSS_FRAME
 mov ecx,eax
 mov eax,dword ptr [edx+V_Y]
 mov dword ptr [esp+CROSS_FIRST],eax
 mov eax,dword ptr [edx+V_Y+4]
 fld qword ptr [ebx+V_Z]
 mov dword ptr [esp+CROSS_FIRST+4],eax
 mov eax,dword ptr [edx+V_Z]
 fmul qword ptr [esp+CROSS_FIRST]
 mov dword ptr [esp+CROSS_SECOND],eax
 mov eax,dword ptr [edx+V_Z+4]
 mov dword ptr [esp+CROSS_SECOND+4],eax
 mov eax,dword ptr [ebx+V_Y]
 mov dword ptr [esp+CROSS_FIRST],eax
 mov eax,dword ptr [ebx+V_Y+4]
 mov dword ptr [esp+CROSS_FIRST+4],eax
 fld qword ptr [esp+CROSS_FIRST]
 fmul qword ptr [esp+CROSS_SECOND]
 fsubp st(1),st(0)
 fstp qword ptr [ecx+V_X]
 mov eax,dword ptr [edx+V_X]
 mov dword ptr [esp+CROSS_FIRST],eax
 mov eax,dword ptr [edx+V_X+4]
 fld qword ptr [ebx+V_Z]
 mov dword ptr [esp+CROSS_FIRST+4],eax
 mov eax,dword ptr [edx+V_Z]
 fmul qword ptr [esp+CROSS_FIRST]
 mov dword ptr [esp+CROSS_SECOND],eax
 mov eax,dword ptr [edx+V_Z+4]
 mov dword ptr [esp+CROSS_SECOND+4],eax
 mov eax,dword ptr [ebx+V_X]
 mov dword ptr [esp+CROSS_FIRST],eax
 mov eax,dword ptr [ebx+V_X+4]
 mov dword ptr [esp+CROSS_FIRST+4],eax
 fld qword ptr [esp+CROSS_FIRST]
 fmul qword ptr [esp+CROSS_SECOND]
 fsubp st(1),st(0)
 fchs
 fstp qword ptr [ecx+V_Y]
 mov eax,dword ptr [edx+V_X]
 mov dword ptr [esp+CROSS_FIRST],eax
 mov eax,dword ptr [edx+V_X+4]
 fld qword ptr [ebx+V_Y]
 mov dword ptr [esp+CROSS_FIRST+4],eax
 mov eax,dword ptr [edx+V_Y]
 fmul qword ptr [esp+CROSS_FIRST]
 mov dword ptr [esp+CROSS_FIRST],eax
 mov eax,dword ptr [edx+V_Y+4]
 mov dword ptr [esp+CROSS_FIRST+4],eax
 mov eax,dword ptr [ebx+V_X]
 mov dword ptr [esp+CROSS_SECOND],eax
 mov eax,dword ptr [ebx+V_X+4]
 mov dword ptr [esp+CROSS_SECOND+4],eax
 fld qword ptr [esp+CROSS_SECOND]
 fmul qword ptr [esp+CROSS_FIRST]
 fsubp st(1),st(0)
 fstp qword ptr [ecx+V_Z]
 add esp,CROSS_FRAME
 pop ecx
 ret
FP_CrossProduct_ endp
align 4
; a dot (b cross c), retaining actual same-TU call and stack local vector.
FP_TripleProduct_ proc near
 push ecx
 sub esp,VECTOR_BYTES
 mov ecx,eax
 mov eax,esp
 call FP_CrossProduct_
 fld qword ptr [ecx+V_Y]
 fmul qword ptr [esp+V_Y]
 fld qword ptr [ecx+V_X]
 fmul qword ptr [esp+V_X]
 faddp st(1),st(0)
 fld qword ptr [ecx+V_Z]
 fmul qword ptr [esp+V_Z]
 faddp st(1),st(0)
 add esp,VECTOR_BYTES
 pop ecx
 ret
FP_TripleProduct_ endp
align 4
; EAX input,EDX unit output,EBX length output; real output-alias ordering.
FP_DecomposeVector_ proc near
 push ecx
 sub esp,NORM_FRAME
 mov ecx,eax
 fld qword ptr [eax+V_Y]
 fmul st(0),st(0)
 fld qword ptr [eax+V_X]
 fmul st(0),st(0)
 faddp st(1),st(0)
 fld qword ptr [eax+V_Z]
 fmul st(0),st(0)
 faddp st(1),st(0)
 fsqrt
 fstp qword ptr [esp+LENGTH_HOME]
 call __get_errno_ptr_
 mov eax,dword ptr [esp+LENGTH_HOME]
 mov dword ptr [ebx],eax
 mov eax,dword ptr [esp+LENGTH_HOME+4]
 mov dword ptr [ebx+4],eax
 fld1
 fdiv qword ptr [ebx]
 fld qword ptr [ecx+V_X]
 fmul st(0),st(1)
 fstp qword ptr [edx+V_X]
 fld qword ptr [ecx+V_Y]
 fmul st(0),st(1)
 fstp qword ptr [edx+V_Y]
 fmul qword ptr [ecx+V_Z]
 fstp qword ptr [edx+V_Z]
 add esp,NORM_FRAME
 pop ecx
 ret
FP_DecomposeVector_ endp
align 4
; Rodrigues rotation: cos*v + sin*(axis cross v) + axis*(axis dot v)*(1-cos).
; ESI hidden structure result is genuine released Watcom return ABI, not new.
FP_RotateVAV_ proc near
 push ebx
 push ecx
 push edi
 push ebp
 sub esp,ROT_FRAME
 mov ebp,esi
 mov ecx,edx
 mov esi,eax
 fld qword ptr [eax+V_X]
 fmul qword ptr [esp+ROT_COS]
 fstp qword ptr [esp+ROT_SCALED+V_X]
 fld qword ptr [eax+V_Y]
 fmul qword ptr [esp+ROT_COS]
 fstp qword ptr [esp+ROT_SCALED+V_Y]
 fld qword ptr [eax+V_Z]
 fmul qword ptr [esp+ROT_COS]
 mov ebx,eax
 mov eax,esp
 fstp qword ptr [esp+ROT_SCALED+V_Z]
 call FP_CrossProduct_
 fld qword ptr [esp+ROT_SIN]
 fld qword ptr [esp+ROT_CROSS+V_X]
 fmul st(0),st(1)
 fstp qword ptr [esp+ROT_CROSS+V_X]
 fld qword ptr [esp+ROT_CROSS+V_Y]
 fmul st(0),st(1)
 fstp qword ptr [esp+ROT_CROSS+V_Y]
 fmul qword ptr [esp+ROT_CROSS+V_Z]
 fstp qword ptr [esp+ROT_CROSS+V_Z]
 fld qword ptr [ecx+V_Y]
 fmul qword ptr [esi+V_Y]
 fld qword ptr [ecx+V_X]
 fmul qword ptr [esi+V_X]
 faddp st(1),st(0)
 fld qword ptr [ecx+V_Z]
 fmul qword ptr [esi+V_Z]
 faddp st(1),st(0)
 fld1
 fsub qword ptr [esp+ROT_COS]
 fmulp st(1),st(0)
 fld qword ptr [ecx+V_X]
 fmul st(0),st(1)
 fstp qword ptr [esp+ROT_AXIS+V_X]
 fld qword ptr [ecx+V_Y]
 fmul st(0),st(1)
 fstp qword ptr [esp+ROT_AXIS+V_Y]
 fmul qword ptr [ecx+V_Z]
 fstp qword ptr [esp+ROT_AXIS+V_Z]
 fld qword ptr [esp+ROT_SCALED+V_X]
 fadd qword ptr [esp+ROT_CROSS+V_X]
 fadd qword ptr [esp+ROT_AXIS+V_X]
 fstp qword ptr [esp+ROT_RESULT+V_X]
 fld qword ptr [esp+ROT_SCALED+V_Y]
 fadd qword ptr [esp+ROT_CROSS+V_Y]
 fadd qword ptr [esp+ROT_AXIS+V_Y]
 mov edi,ebp
 fstp qword ptr [esp+ROT_RESULT+V_Y]
 fld qword ptr [esp+ROT_SCALED+V_Z]
 fadd qword ptr [esp+ROT_CROSS+V_Z]
 lea esi,[esp+ROT_RESULT]
 fadd qword ptr [esp+ROT_AXIS+V_Z]
 mov ecx,6
 fstp qword ptr [esp+ROT_RESULT+V_Z]
 rep movsd
 mov eax,ebp
 add esp,ROT_FRAME
 pop ebp
 pop edi
 pop ecx
 pop ebx
 ret 16
FP_RotateVAV_ endp
_TEXT ends
end
