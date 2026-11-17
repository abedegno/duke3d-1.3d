# Recovered engine contributions

`engine.c` and the three headers in `include/` reproduce the complete engine
contribution in the registered v1.3D target. They are derived from
[gamesrc-ver-recreation/build](https://github.com/gamesrc-ver-recreation/build)
commit `88ffca1bdb8d93c731f6d02e62ae5119393bc73b`, pinned as the public
`reference/build-reconstructions` submodule. Only line endings are normalized;
upstream copyright, modification notices and restoration annotations remain.
Ken's license is retained in [BUILDLIC.TXT](BUILDLIC.TXT).
[Source provenance](../../evidence/build-source-reference.json) records every
upstream and tracked input hash.

Run from the repository root:

```sh
make engine-probe
```

This compiles tracked C and headers using pinned Watcom 10.5 with
`/4r /s /or /dLIBVER_BUILDREV=19960320`. The revision macro is an upstream
reconstruction selector; it does not establish the original game's build date.
The tested `19960413` selector produces the same verified segments.

The unchanged whole-module verifier checks all nonempty segments without masks:
126,145 CODE bytes, 606 CONST bytes, 460 DATA bytes, 1,061,535 BSS bytes and
6,540 relocations. All 135 complete function intervals also match, including
the 7,975-byte wall renderer. All 268 BSS symbol offsets and the zero state
match. See [the proof report](../../evidence/engine-function-matches.json).
Tests corrupt the tail of every nonempty segment and require rejection.

Before compiling, the command replays the independently pinned April object's
[reference-only proof](../../evidence/historical-engine-object-match.json)
against the target. That object supplies names, extents and bindings; none of
its bytes is copied or linked into reconstructed output. Original objects in
the public reference submodule are also unused in reconstructed output.

The command remains a diagnostic entry point: inspect
`module_verification.verified` for the module result. Tests require it to be
true and all 135 intervals to match. `full_executable_rebuilt` remains false:
this contribution does not prove the remaining game/libraries, original link
layout, DOS extender binding or complete executable identity.

`sqrt.c` remains an isolated 54-byte helper checked by `make proof`, including
both table references. Do not link it alongside `engine.c`, which already
contains that helper. Do not count those overlapping bytes twice.

The previous May-snapshot reconstruction reached 116/135 intervals. The
upstream reconstruction resolves its remaining wall register allocation and
whole-translation-unit return/table placement differences. The prior
[compiler experiment](../../evidence/engine-compiler-probes.json) remains a
negative experiment on its pinned interim input; its replay now explicitly
uses the earlier git revision's source and headers.

## Native engine assembly

`a.asm` reproduces the entire historical assembly contribution: 5,913 CODE
bytes, all 43 publics and all 443 relocations, with no separate data/BSS.
It comes from the same pinned Build source repository's `A_MASM/A.ASM` and
retains original instructions, restoration annotations and license notices.
Only line endings/final blank lines differ. See
[its provenance](../../evidence/engine-assembly-source-reference.json).

The original tool is available in [Microsoft's published DOS build tools](https://github.com/microsoft/MS-DOS/blob/2d04cacc5322951f187bb17e017c12920ac8ebe2/v4.0/src/TOOLS/MASM.EXE).
Download that executable privately as `toolchains/archives/masm-5.10-msdos4.exe`,
then prepare and prove it:

```sh
python3 tools/setup_masm.py \
  --binary toolchains/archives/masm-5.10-msdos4.exe \
  --destination toolchains/masm-5.10 \
  --manifest evidence/masm-5.10.json
make proof-engine-asm
```

Setup validates length, SHA-256 and Git blob SHA-1 before publishing a fresh
private home. It preserves an existing destination and runs no installer.
The native producer uses MASM 5.10 `/MX /DLIBVER_BUILDREV=19960320`. `/MX`
preserves PUBLIC/EXTRN symbol spelling as metadata; instructions are unchanged.
The date-like macro denotes an upstream reconstruction selector, not an
independently established original build date.

Four routine placements and all 17 external bindings are anchored by the
complete C engine proof. Native MASM emits 351 F0/T0 and 92 F2/T2 fixups.
The [TIS OMF specification](https://openwatcom.org/ftp/devel/docs/omf.pdf)
defines F5 using the target index. The verifier therefore accepts F0/T0 or
F2/T2 only when both indices are identical, specifying that same frame.
It still rejects mismatched frames and checks every operand, target LE fixup,
local reference and instruction byte. Native object fixups are never rewritten.

Tests reject code-tail, addend and frame mutations. This contribution is
disjoint from `engine.c`; both remain subject to the unfinished whole-game
link, DOS extender binder, complete-file and humanization gates.
