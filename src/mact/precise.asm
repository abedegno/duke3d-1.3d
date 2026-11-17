; Symbolic reconstruction from the pinned MACT386.LIB precise.asm reference.
; Original source authorship/copyright is unresolved; no GPL relicensing.
; control_word is an inferred private name. Clear pending x87 exceptions,
; preserve other control bits, select extended (11) or single (00) precision.
.586
.387
.model flat
_TEXT segment word public use32 'CODE'
_TEXT ends
_DATA segment word public use32 'DATA'
control_word dw 0
_DATA ends
TEXT segment para private use32
public PRECISION_High_, PRECISION_Low_
PRECISION_High_ proc near
 fclex
 fstcw control_word
 and control_word,0fcffh
 or control_word,0300h
 fldcw control_word
 ret
PRECISION_High_ endp
PRECISION_Low_ proc near
 fclex
 fstcw control_word
 and control_word,0fcffh
 fldcw control_word
 ret
PRECISION_Low_ endp
TEXT ends
end
