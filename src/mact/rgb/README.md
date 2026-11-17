# MACT RGB contributions

`../rgb.c` is the complete readable reconstruction. Default compilation keeps
all five functions (743 CODE bytes); its final 323-byte table builder still has
19 register-allocation differences. `DUKE13D_RGB_TABLE_ASM=1` excludes only that
last definition and builds the exact first 420 bytes in ordinary C. Setting the
selector to zero retains the complete readable C counterpart.

`../rgb_make_table.asm` is a visible symbolic assembly stand-in for only the last
323 bytes. It comes from an own-C mnemonic roundtrip proved byte-exact before
four disjoint live-register role refinements (19 instruction operand changes).
Named stack homes retain palette, lookup base, counters and signed-short call
arguments. It exports the existing builder and imports only four existing
globals. All six original file-private C symbols remain in native C scope;
none crosses the object boundary. The failed Task61 whole-ASM roundtrip remains
an unmodified negative: NASM selects a different self-move encoding at +378,
inside the C-owned interval. No trimming or padding waiver was applied.

This is inferred source, not recovered historical spelling or original ASM.
The GPL-released ROTT `RT_UTIL.C` is the algorithmic relative for BestColor,
FindEGAColors and the EGA colors. Its copyright and GPL notice are retained in
`rgb.c` and referenced in the companion. The lookup is a real 64×64×64 byte
array; EGA storage holds 16 bytes; three real 256-int squared-distance tables
use weights 213/715/72 divided by 1000. The observed unsafe signed-difference
indexing is deliberately preserved. Host checks use only representable,
in-bounds differences, including the complete builder with a zero palette.

From the repository root:

```
python3 tools/probe_mact_rgb.py --home toolchains/watcom-10.0-ga \
  --build build/mact-rgb65 --report evidence/mact_rgb-module.json
python3 -m unittest tests.test_mact_rgb
```

The build argument is a reusable parent; every invocation creates a fresh,
retained child directory containing the actual C/ASM objects and compiler logs.
Inputs are tracked project files, target `reference/DUKE3D.EXE`, pinned GA
compiler/DOSBox-X, and NASM 2.16.03. `--nasm` supplies an explicit alternative
2.16.03 build; the default workspace binary additionally has a fixed SHA-256.
The NASM archive URL/hash and actual binary/version are reported. No ignored
research extraction or original SDK output is required. Original SDK metadata
was a research reference for names, scopes and callee nomination; it is not read
by the standalone producer. `VID_GetPalette` is a target typed-call nomination,
not an independently rebuilt or verified callee implementation.

Unchanged `verify_composite` verifies both complete native objects: 795
initialized bytes (743 CODE + 52 DATA), 265232 unbacked BSS bytes and 23 typed
fixups, an exact disjoint union, six unique global exports and actual private
C scope. `codeScopepublics=5` includes the private weight builder. Explicit
native contracts reject extent, scope, relocation and graph changes; all data,
storage, backing and function tails are checked. Before/after hashes cover
actual source, descriptor, provenance, target, helper and tool inputs.

Actual source BSS attributes are 169 (DWORD), original OMF attributes 105
(PARA). The observed offset 1864256 satisfies both. This is neither an alignment
waiver nor proof of historical OMF identity or final linker ordering. The
complete byte-identical executable, remaining source recovery, historical
link/binding and humanization remain unfinished. Humanization must eventually
replace the stand-in or explain required allocation choices under the complete
identity gate; inferred names and provenance remain visible in the backlog.
