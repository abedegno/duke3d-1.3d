# MACT file library

`../file_lib.c` rebuilds the complete selected MACT file contribution with
Watcom C32 10.0 GA `/omaxnet /zp4 /5r`. Run:

```
python3 tools/probe_mact_file.py
python3 -m unittest tests.test_mact_file -v
```

The producer compiles ordinary C and proves all 1,731 CODE bytes, 406 CONST
bytes, 80 initialized DATA bytes, zero BSS bytes and 70 typed fixups at one
placement per segment. It verifies all 20 function positions and the local
`FileNames` public/external scope. Every prefix, compiler alignment tail,
message byte and initialized pointer byte is included. There are no masks,
instruction payloads, SDK-object outputs or padding objects.

This is reconstructed source, not a claim of historical spelling or original
OMF identity. The retained Apogee GPL notice applies to the ROTT RT_UTIL.C
ancestry. Environment/default path and DOS directory bodies come from that
preserved primary source; file tracking, filetype dispatch, error branches,
0x7fff I/O chunks and extension scans follow the complete original native
member. JFMACT explicitly calls itself creative interpolation and supplies
functional clues only. Exact source ranges, hashes, URLs and modifications
are in `evidence/mact-file-source-reference.json`.

Extra NULs after actual message/path literals preserve measured noninstruction
CONST storage and prevent native compiler source-buffer residue. Their
historical source spelling or intent is unknown. `FileNames[20]={0}` is real
initialized local state; its 80 zero bytes are DATA, not BSS or padding.
Native quirks are preserved: fatal errors are assumed to terminate, tracking
checks only the upper handle bound, the environment routine always appends a
backslash because it inspects the terminating NUL, and SetExtension assumes a
valid extension-bearing input. This task does not modernize these interfaces.

Seven complete fixed stock CRT witnesses are freshly replayed and independently
anchor eight imports. Other callee locations are explicitly labeled selected
original-member call nominations, including the peer utility functions;
they are not independent callee-identity proofs. The standalone producer needs
only tracked sources/descriptors/evidence, the pinned executable and toolchain.
It does not read the MACT SDK archive, ignored research sources or mutable
coverage inventories. The original SDK member is reference evidence only.

The original empty `_BSS` segment has attribute 105; the fresh compiler emits
attribute 169 for that zero-size segment. All nonempty attributes, groups,
scopes and typed fixups agree. The descriptor pins actual source geometry.
There are no BSS bytes to own, but empty-segment alignment semantics and the
final original group ordering remain unproved until full native linking.
A contribution match does not prove full executable identity, historical OMF
identity, linker selection/order or the absence of a possible layout effect.

Repeated builds in the same output directory reproduce the complete contribution
proof. The full OMF object hash can vary: a measured 22-byte COMENT record at
file offset 47 contains the compiler's source timestamp. Its checksum changes
with that timestamp. All parsed segment bytes, symbols and typed fixups remain
identical. No timestamp normalization or object patching is performed.
