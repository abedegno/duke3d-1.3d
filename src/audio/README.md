# Audio source recovery

The C and assembly files reproduce individually checked contributions to the
registered Duke v1.3D executable. They do not yet constitute a complete sound
library or a whole executable. Sources retain their original notices and
historical reconstruction annotations. The GPL text is in [gpl.txt](gpl.txt).

## Historical mixer and reverb assembly

`mv_mix.asm`, `mv_mix16.asm` and `mvreverb.asm` come from the pinned
[historical audio reconstruction](https://github.com/gamesrc-ver-recreation/audiolib)
at `c363124d376d373441a21b3304eb44d32c0a69f7`. Attribution comments and whitespace
are the only changes. [Provenance](../../evidence/audio-assembly-source-reference.json)
records source/license hashes and selector scope.

Prepare Turbo Assembler 3.1 from the preserved Borland C++ 3.1 media archive
(download identity and source link are in [the tool manifest](../../evidence/tasm-3.1.json)):

```sh
python3 tools/setup_tasm.py \
  --archive toolchains/archives/borland-cpp-3.1.7z \
  --destination toolchains/tasm-3.1 \
  --manifest evidence/tasm-3.1.json
make proof-audio-assembly
```

An existing destination is preserved and rejected; use a fresh destination
for a setup replay. Setup checks the outer archive, both split-package parts
and both executable hashes. It extracts files without running the installer.

The producer runs TASM in an isolated DOSBox-X directory and publishes only a
successful, nonempty object. The selected options are
`/t /p /mx /w2 /dLIBVER_ASSREV=19960116`. The macro selects upstream AL_11,
not a verified original build date. The historical makefile's `/zi` debug
option is omitted; all executable contribution bytes and relocations remain
checked. Other unsupported debug encodings are still rejected by the parser.

Complete module proofs cover 901 bytes/56 relocations for MV_MIX,
971 bytes/57 relocations for MV_MIX16 and 151 bytes/2 relocations for MVREVERB.
Each has four code publics and no nonempty data/BSS segment. Local references
used by self-modifying mixer instructions are resolved and checked too.
Tests corrupt code tails and relocation addends and require rejection.

The parser retains translator/format/pass metadata and rejects unsupported
payloads and definitions appearing after a linker pass separator. It does
not discard unknown semantics to obtain a match. Original prebuilt objects
and libraries never supply recovered source bytes.

## GUS and GUSMIDI

`make proof-gus proof-gusmidi` compiles the historical AL_11 C with pinned
Watcom 10.0b `/zq /w4 /d2 /dLIBVER_ASSREV=19960116`. The historical makefile
uses `/d2` even in production for these modules. Removing it changes generated
runtime code; it remains part of the reproducible input.

The complete runtime proofs cover GUS's 1,057 initialized/16 BSS bytes and
65 relocations, plus GUSMIDI's 2,227 initialized/14,928 BSS bytes and 125
relocations. Independent GUSWAVE and MUSIC references anchor the placements.
Source/header/license ancestry is recorded in
[gus-source-reference.json](../../evidence/gus-source-reference.json).

The parser retains validated line-number records and measured Watcom debug
segment extensions. An explicit descriptor requests a loadable view; the
original parsed object remains intact. Only the documented native Watcom
`$$SYMBOLS`/`DEBSYM` and `$$TYPES`/`DEBTYP` combinations with their measured
attributes/format markers qualify. Runtime public, group, directive, target
or frame references into those segments cause rejection.

Reports inventory and hash the excluded debugger segments. GUS excludes
1,499 debug bytes/eight debug fixups; GUSMIDI excludes 2,764/11. These do not
enter runtime source coverage. The unchanged byte verifier still requires
all nonempty segments of its input; tests show that the raw debug objects
fail that gate, while every projected runtime byte and fixup is checked.
This separation does not establish complete executable or linker identity.

## Command-line helpers and instrument table

`make proof-user proof-gmtimbre` proves USER's two command-line helpers
(195 bytes/nine relocations, Watcom 10.0b) and the complete 256-entry
General MIDI instrument table (3,328 DATA bytes, Watcom GA).
Both use `/omaxnet /zp4 /5r /dLIBVER_ASSREV=19960116`.
[Source provenance](../../evidence/audio-tables-source-reference.json) records
unchanged historical function/table content, added attribution and whitespace.

MUSIC and MPU401 independently anchor USER's routines. AL_MIDI anchors the
instrument table at LE object 3 offset 64,456. The table is compiled from
typed C initializers; no reference payload bytes become source. An explicit
data-only proof accepts no code or relocations and requires independently
anchored placement of every nonempty DATA/BSS segment. The same strict module
verifier then compares every byte and public placement. Tests reject missing,
conflicting and unknown anchors, extra unbound segments and tail corruption.
