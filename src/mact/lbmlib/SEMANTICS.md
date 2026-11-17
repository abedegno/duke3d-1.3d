# MACT memory-to-memory LBM reconstruction

This is a readable semantic reconstruction, not a recovered historical body. The
released 3D Realms extras TYPES.H, LBMLIB.H, _LBMLIB.H and UTIL_LIB.H are copied
unchanged with their complete notices. No exact implementation was found in the
local released sources or the bounded exact-symbol GitHub search. Related
ValveSoftware/halflife utils/common/lbmlib.c has different filename/file-I/O APIs
and incomplete planar functions; it was inspected only as related IFF history,
and its body is not copied here.

The C counterpart implements every actual function and memory owner. One real
Watcom 10.5 compile is retained, with /omaxnet /zp4 /5r: CODE1787 instead of1797,
CONST126 and BSS1152 and33fixups. Only Align is a whole-byte positive; equal-size
Munge/Load bodies also retain actual stack/register differences. There is no
claim the C produces the final bytes. The symbolic counterpart expresses the
same native register/stack schedule and compiler no-op tails. This scheduling is
an explicit C-humanization backlog, not an original-source claim.

The five definitions are Align, LBMRLEDecompress, MungeBitPlanes, LoadLBM,
SaveLBM. Real static bitplanes[9][128] is the only private storage owner; the
ninth row is the ILBM stencil plane. The whole CODE is604 instructions, with no
embedded byte or jump table. Its IFF switch is ordinary comparisons. The three
named CONST objects are actual diagnostic strings, aligned at0,52,92, with total
extent126; no packed target-data array is used. No initialized DATA exists.

IFF ownership: FORM length is big-endian and rounded even. ILBM/PBM form types,
BMHD20-byte header, CMAP and BODY tags come from the released private header.
BMHD w/h/x/y/pageWidth/pageHeight pass through the real MotoShort ABI. CMAP
zeros768 bytes then copies the declared chunk length. PBM rows decode ByteRun1
or copy raw width bytes and advance by even width. ILBM uses a word-aligned row
size ((w+15)/16)*2, reads nPlanes plus an optional mask row, then returns stencil
status2 after decoding. Width>320 or height>200 returns1; ordinary success is0.
Unknown compressed modes do not advance row input. Native code is unchecked for
malformed sizes, missing BMHD, excessive planes or too-small buffers; this
reconstruction does not silently add guards or correct these behaviors.

Important measured quirks are preserved:
* MungeBitPlanes ORs each entire plane byte shifted by plane number and emits its
  low byte; its eight-pixel counter changes source-byte position but never masks
  an individual bit. This is the actual code, not the intended generic ILBM rule.
* SaveLBM calls MotoShort even for byte-sized nPlanes/xAspect/yAspect. The low
  result byte is stored; conventional byte-swap semantics produce zero there.
* Save writes raw width*height PBM pixels with final even chunk padding, whereas
  raw PBM reading advances each row by even width. Odd-width round trips are not
  repaired. The ordinary C counterpart deliberately retains these quirks.
* ByteRun1 control0x80 is a no-op; >0x80 repeats a following byte (control^255)+2
  times; <0x80 copies control+1 bytes. Only output exceeding the requested row
  width calls the actual Error provider. A no-op-only stream has no added limit.

GNU ELF alignment is genuine PARA CODE1797/BSS1152 and DWORD CONST126, with
-no-pad-sections preserving the odd CODE extent. Every branch has a named CFG
identity, every private string/state label remains nonPUBLIC, and all11 ABS
constants remain genuine named source identities. Four external providers are
memset_, Error_, MotoLong_, MotoShort_. Three actual public-self references
(two LBMRLEDecompress and one MungeBitPlanes) remain genuine native fields.
Original7 EXTDEF entries additionally encode two self definitions and private
bitplanes; native anonymous section+V lowering is fieldwise audited, never an
anchor or exported alias. Original math387r/emu387 default-library COMENTs are
retained as original metadata in the observer; GNU emits none. Any later normal
package must state this honestly and keep required runtime providers explicit.

The one-time author_once.py transcription/CFG aid is authoring evidence only.
It is never imported by produce.py. Source-only production reads static ASM,
this C counterpart, primary headers/notices and pinned tools, then the original
archive/target are opened only by the separate observer. No instruction bytes,
ORG, target-derived producer input, object patch, scope promotion or byte mask
is part of production. C-only exact scheduling remains unfinished.
