# MACT utilities reconstruction

`../util_lib.c` is one source-built reconstruction of the selected MACT utility
member. It preserves the ROTT source copyright and GPL version 2-or-later notice.
The ROTT primary release supplies six numeric/endian bodies plus heap-sort state
and bodies; `hsort` is renamed to the measured `HeapSort` export. Shutdown,
error, argument and memory wrappers are reconstructed from native roles. This
is not a claim of original MACT source spelling or historical source identity.
The later JFMACT file describes its implementation as creative interpolation
and serves only as a related-role reference.

The fixed Watcom 10.0 GA profile is `/omaxnet /zp4 /5r`. The unchanged whole
module gate checks 961 CODE bytes (including the four-byte stack-initializer
prefix and every public tail), 138 CONST, eight DATA, 28 unbacked BSS and all
61 relocations at one placement per segment. All 20 public definitions and six
actual local scopes are retained. The initialized error guard and three private
heap-loop static integers have storage even without public names.

Four real message literals contain extra NUL terminators. These express exactly
eight measured zero alignment bytes in CONST: offsets 2, 3, 23, 57, 58, 59, 94,
95. The original member and target independently establish those bytes. The
compiler otherwise emits source-buffer residue there. The first terminators,
message text, behavior and addresses remain intact; original spelling and
intent of those trailing bytes are unresolved. No instruction payload, fake
ABI fields, assembly or comparison masks are used.

Run `make proof-mact-util` or
`python3 tools/probe_mact_util.py --build build/mact-util-proof` and
`python3 -m unittest tests.test_mact_util -v`. The standalone producer uses only
tracked recovered source/metadata, the pinned target and compiler, original
stock CRT references, and accepted peer proofs. It never reads an extracted
MACT object, original SDK archive, ignored research source or another checkout.
The fixed `evidence/mact-util-crt-anchors.json` witness retains only five
complete native component records. It is independent of changing source-coverage
bookkeeping; the standalone test intentionally has no diagnostic stock inventory.
Stock `strtok`, `cmain386`, `nmsize`, `vprintf` and `nrealloc` members are
independently replayed in full;
accepted ENGINE, MMULTI and GAMEDEF proof records supply other caller anchors.
The earlier GA-only `vprintf`/`realloc` trials failed; full supplied 10.5
members now verify both callees. Their bytes are also identical in 10.6, so
the pinned 10.5 replay is not proof of unique historical compiler/linker
selection. All twelve imports are independently constrained. Supplied CRT
bytes add no recovered-source credit. All fixed call targets have negative
relocation controls.

Tests include real native source mutants, every fixup, all private scopes,
all public tails, all eight CONST residue bytes, initialized and BSS storage,
actual host C behavior, and a fresh isolated producer run without the SDK.
Host checks exercise only representable arithmetic values; they do not replace
the historical compiler's width-sensitive native proof. Historical `CheckParm`
retains its 128-byte unbounded copy and narrow argument counter, and the heap
sort retains static state. This recovery does not alter those behaviors.

The source-provenance manifest records primary-source hashes and license
lineage. Complete executable linking/binding and byte identity remain unfinished.
