; Genuine public GAME BSS tail. No private owner or padding is introduced.
; All objects retain their actual public names and byte storage types.
.386p
.model flat
_BSS segment byte public use32 'BSS'
public _cheatbuf,_everyothertime,_cheatbuflen
public _playerswhenstarted,_restorepalette,_screencapt
_cheatbuf db 10 dup (?)
_everyothertime db ?
_cheatbuflen db ?
_playerswhenstarted db ?
_restorepalette db ?
_screencapt db ?
_BSS ends
DGROUP group _BSS
end
