# VIDMSDOS authored source recovery and humanization backlog

This is authored recovery, not historical Apogee/MACT source identity. Production
source is the exact frozen Task340 candidate, SHA256
f4a1eec6b5a3cf1295bbc1a7536618312ef4be4d1a4ab3cd5eae65e406b8613e.
The unchanged C-only Task185 counterpart is retained as
`vidmsdos-c-only.c.txt`, SHA256
98416c5940ce0595c990f55cf42a65fe182d94a0ac82191688376a81d6add7da.
It is a real negative: its IRQ uses EAX for the prefix-clear store rather than
ESI; displacement, instruction length and tail alignment differ. Task189's
compiler observations did not establish an identity-preserving C correction.

Five headers are unchanged `dukenukem3d/extras` published interfaces from
videogamepreservation/dukenukem3d commit
ef609159bd352985a0c63734a11241d86c873fe5, with full 3D Realms educational/GPL
notices and original bytes. Task185 removed the unnecessary MOUSE.H include,
absent in the original native dependency list; all mouse definitions already
supply their full signatures. The genuine unused header remains staged unchanged.
This header-graph correction restored every measured BSS role, without reordering
or inventing variables. Exact BSS is display_buffer[64000], vid_flushall DWORD,
PauseCount DWORD, ExtendedKeyFlag DWORD, then the released 36-byte viddef_t.

Apogee ROTT `rott/rott/ISR.C`, source archive SHA256
45eafa693c3085c56b6ccd072f5a1fb5ba1986877a21e4506d4741b1bdd44729,
provides keyboard controller handshake, E0 filtering, vector and BIOS queue
precedent. Its GPL-2.0-or-later copyright/license notice is retained in the C
file. Native observations recover typed PS/2 Pause values, named scan mappings,
mode13h operations and real API behavior. These are readable semantic fields,
not packed target payloads. JFMact mouse code explicitly says original MACT
source was unavailable; later portable glue is not substituted for DOS behavior.

Three symbolic compiler primitives remain visible humanization work:

* CopyVGAFrame: real 32000-word transfer (320*200/sizeof(word)), with readable C
  loop counterpart; actual named source/destination parameters and truthful
  EDI/ESI/ECX clobbers. Released Ken PRAGMAS.H is the aux/string-operation precedent.
* FillVGAFrame: real replicated-byte VGA word fill with readable C counterpart
  and truthful EDI/EAX/ECX clobbers.
* ClearExtendedKeyPrefix: exactly one volatile DWORD zero store to the genuine
  private ExtendedKeyFlag. Symbolic XOR ESI,ESI / MOV [ExtendedKeyFlag],ESI declares
  modify exact ESI. The interrupt prologue/epilogue saves/restores ESI. No new
  runtime helper, import, export or storage is emitted. The readable counterpart
  is ExtendedKeyFlag=false. Ordinary C remains a known byte-identity negative.

These are disclosed source operations, not historical C claims, opaque encoded
instructions, register-forcing C declarations, payload arrays or fake barriers.
Further humanization must preserve full identity. The approved source permits
symbolic assembly with readable C counterparts while that work remains open.

Original MACT386.LIB SHA256
957cea0ffb125220dd156c74b61fed8328c3a54852cad3d892cf47bebab8f8db,
member33792:37718 (3926 bytes), SHA256
970a2ccd6c58f051780089b549aa6ec34dc6adbc7f7dd3e242181969e68f472e,
is reference-only; no original OBJ/LIB is needed for production. Independent
accepted KEYBOARD/RGB caller roles established CODE553424 and the six recorded
caller anchors. All 29 definitions, eight private scopes,16 EXTDEF entries and
local indices,54 raw typed relocations and complete segment storage are checked.
Only a freshly issued closed origin context can justify the target's PUBLIC
DATA coordinate; no numerical origin override or metadata omission is accepted.

The worker's dispatcher changes a closed origin-factory input. ROOT owns the
reviewed administrative pin refresh after integration; isolated worker tests
use an actual fresh context issued in-process by unchanged ROOT policy. They
never serialize or forge capability authority. This is not a production pin
exception: after integration the normal Make route must replay its own factory.

Complete EXE identity, final linker/binder reproduction and humanization remain
unfinished. No parent audit, percentage, link count or source credit is updated
by this proposal.
