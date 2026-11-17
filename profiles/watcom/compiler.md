# Watcom C32: measured observations

Experimental profile; no complete-game rebuild yet.

## Candidate toolchain

Watcom 10.0 GA DOS compiler from preserved distribution tree, archive SHA-256
8e5869e78cda5c42b1fd5aa0675abe52ed03217b4f835bfe4a9dc133d26158aa.
Banner: WATCOM C32 Optimizing Compiler Version 10.0. BINB/wcc386.exe is
536,624 bytes. Pin its hash in the consuming project's toolchain inventory.
Archive source: https://archive.org/download/watcom-c-cpp-compilers-collection/watcom-10.0/discmaster/Sybase%20-%20Watcom%20C%2B%2B%2010.0.zip

This candidate compiles under installed DOSBox-X on arm64 macOS. The runner
requires a successful batch status and a newly created nonempty output
object. Invalid C, missing output and timeouts are covered by integration tests.

## ABI and object evidence

With `/5r /s /otexan`, `int twice(int x) { return x*2; }` is `01 C0 C3`.
Register-argument functions use trailing underscore public names (`twice_`);
an external C data symbol is prefixed (`_clock`). All widths are 32-bit
except explicitly short/char objects. Compiler emits OMF32 SEGDEF32,
LEDATA32, PUBDEF32 and FIXUPP32 records. A global increment uses an absolute
32-bit fixup; forwarding to an external function uses a relative one.

## Evidence required before identifying a revision

Match unrelated real functions and verify symbolic fixup targets; compare
10.0a and other plausible releases. A matching leaf only establishes that a
candidate can produce those bytes. It does not uniquely identify a version,
its libraries or original flags. The initial `/5r /s /otexan` seed came
from the released v1.5 makefile. Subsequent measurements favor
`/4r /s /otexan`: with GA, a three-function timer fragment is 99 bytes and
matches the original including alignment and all ten fixups. `/5r` keeps
the function bodies but aligns them differently. This is evidence for the
timer compilation unit; other files still need independent measurement.

Seven isolated functions from GAME, GAMEDEF and SECTOR match under GA.
Under the initial `/5r` comparison, 10.0a differs on getincangle and ispecial.
This does not establish a uniquely identified whole-game compiler toolchain.

The complete RTS contribution needs `/4r /s /oteir`, rather than the release
makefile's `/otexan`. Enabling loop optimization through `ox` changes its
first function's stack/register allocation and increases its aligned size
by 32 bytes; alias assumptions change two indexed-addressing sequences.
Names of private globals also affect BSS order in measured objects; changing
declaration order alone did not change that order. Do not infer historic
identifier spelling from a successful layout reconstruction.

Constant-string alignment bytes can retain old compiler-buffer contents.
A source using only the same literals can therefore differ in otherwise
unreferenced padding. The project's RTS reconstruction uses explicit named
message fields and tiny padding fields; the whole CONST contribution then
matches deterministically without patching an object or copying instructions.

## Measured audio compiler differences

The project audio makefile seed `/omaxnet /zp4 /5r` matches multiple complete
contributions, but one compiler revision is not sufficient for all measured
modules. GA proves LL_MAN, DPMI, MPU401, PITCH, DMA and SNDSRC. TASK_MAN and
IRQ use 10.5; GA differs in interrupt-handler register allocation/instructions.
BLASTER, AL_MIDI and MIDI also match complete contributions with 10.0a.
AL_MIDI/MIDI retain the released source and add `/zu`, as in their makefile.
SNDSCAPE needs 10.0a: its unchanged parse routine is 180 bytes and matches,
where GA and 10.5 emit a different 184-byte routine. Broad optimization and
character-signedness trials did not solve that difference. Each consuming
module descriptor fixes its contribution extent; evidence records the actual
compiler hash and options. These are working matching builds, not unique
identification of original compiler revisions or one historical build setup.

SNDSCAPE's default-directory literal must remain a literal: Watcom emits
three MOVSD copies for it. Replacing it with a named array changes that code.
Its other strings and measured padding are named data. No object patch or
extracted executable instruction range is used to obtain the match.

## Format references and supported subset

- https://github.com/open-watcom/open-watcom-v2/blob/master/bld/watcom/h/exeflat.h
- https://github.com/open-watcom/open-watcom-v2/blob/master/bld/watcom/h/pcobj.h
- https://openwatcom.org/ftp/devel/docs/omf.pdf (TIS OMF 1.1: Record Format,
  COMENT, FIXUPP and LIDATA)

LE reader supports little-endian LE, ordinary and zero-fill pages, internal
fixups with 8/16-bit object ordinals and 16/32-bit target offsets, source
lists and signed page-crossing offsets. It preserves source types and
rejects unsupported fixup encodings. OMF reader supports compiler-generated
data and public definitions with direct fixups, bounded nested LIDATA,
default libraries, far-call optimization directives and code/data ranges.
Unknown semantic comments fail explicitly. The standard permits zero as an
omitted checksum; otherwise checksums are checked. Large GA objects also
contain zero-filled class-0 padding comments with type 4, accepted only in
that measured form. Threads, communal definitions, fixups following LIDATA
and other unimplemented records fail explicitly.

## Local symbol scope

The OMF reader retains LPUBDEF/LPUBDEF32 names in `publics` for complete local
code/data placement checks and separately marks them in `local_publics`.
LEXTDEF records similarly retain their ordinal indices in `local_externals`.
The complete verifier records their resolved addresses as `local_symbols`;
these bytes and fixups remain fully checked. `external_anchor_bindings` excludes
those names when another module imports physical bindings. It rejects anchor
reports lacking scope metadata, so older reports need replay before this use.
ENGINE's private static `tempbuf` and the game's external `tempbuf` provide the
native regression case: their spelling agrees, but they refer to distinct
storage. No runtime bytes or relocations are skipped by this classification.

## Library object timestamps

Watcom libraries can carry COMENT class0xfe, directive `T`, followed by a
four-byte object timestamp. The primary `pcobj.h` reference above names this
`LDIR_OBJ_TIMESTAMP`. The parser retains the entire payload in `comments`;
this metadata does not alter segment contents, symbols or relocation fields.
The exact fixed-width timestamp comment is also accepted after the end-of-pass
separator. Other comments and definitions remain rejected there; malformed
lengths and unsupported directives still fail. This does not implement Easy
OMF (`80386`), whose segment and fixup semantics require separate support.

Synthetic tests verify timestamp retention and unchanged segment/public/fixup
content on either side of the separator, plus malformed and unrelated-record
rejection. A private library diagnostic now parses27/27 MACT386 and1/4 BUTWCD4
members; the other three fail on separate unsupported linker directives.
Parsing is format support, not a target match or recovered-source credit.
