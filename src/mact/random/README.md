# MACT RNG source contribution

`../random.c` and the private `include/_rt_rand.h` build the complete measured
MACT RNG contribution: 227 CODE bytes, 2052 DATA bytes, four unbacked zero-fill
BSS bytes and all 13 fixups. The six CODE entries, global table and two private
indices have explicit public/scope contracts in `modules/mact_random.json`.

The ordinary C and complete 2048-entry table derive from the preserved official
ROTT source release, with its Apogee GPL notices retained. This is related source,
not original MACT source identity. The measured MACT API names and DOS-time seed
are restored using the actual compiler `dos.h`; no private prototype is supplied.
Byte return width is measured from AL-only native returns. Historical signedness
is inferred from the primary unsigned table; no caller prototype is claimed.
Archive-relative paths, immutable hashes and derivations are recorded in
`evidence/mact-random-source-reference.json`.

The source emits DWORD-aligned BSS (`0xa9`), while the original member requested
paragraph alignment (`0x69`). Both select the independently verified preceding
RGB BSS boundary, `1864256 + 265232 = 2129488`, which is divisible by 16. No
alignment pragma, filler or type change is used. This proves the contribution at
the observed placement, not original OMF identity, RGB source recovery, complete
linker order or full executable identity.

Run from the repository root:

```sh
python3 tools/probe_mact_random.py --build build/mact-random-proof
python3 -m unittest tests.test_mact_random -v
```

The producer uses tracked source/header/descriptor/provenance inputs, the target
as verification reference and the original Watcom GA compiler. It reads no ignored
research directory, extracted archive, SDK object or historical disassembly.
The DOS-time binding is an explicit independently verified stock `gtime386`
dependency, with zero additional source credit. Its pinned proof provenance is
recorded locally; no stock member supplies build output. The standard driver
registration and project-wide range accounting remain controller-owned.
