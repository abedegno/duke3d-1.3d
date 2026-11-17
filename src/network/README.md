# Recovered MMULTI contribution

`mmulti.c` comes from the pinned historical Build reconstruction at
`88ffca1bdb8d93c731f6d02e62ae5119393bc73b`. Ken's copyright/modification
notices and restoration annotations remain; the license is retained in
[BUILDLIC.TXT](../engine/BUILDLIC.TXT). [Provenance](../../evidence/mmulti-source-reference.json)
records source hashes, the selector and the single restored export.

```sh
make proof-mmulti
```

Pinned Watcom 10.5 `/4r /s /or /dLIBVER_BUILDREV=19960320` reproduces the
complete contribution: 2,227 CODE bytes, four CONST bytes, six DATA bytes,
34,510 BSS bytes and all 165 relocations. All 34 named code/state positions
match the independently rechecked historical object. The revision macro is
an upstream reconstruction selector, not a verified original build date.

The earlier object exports an empty `setsocket` function. The upstream
conditional omitted that export for this selector. Restoring the empty C
function adds its public alias to the existing return at CODE+500; every
instruction/data byte and every fixup remains identical. This preserves the
historical interface without adding a byte-encoded assembly stub.

The historical April object is a [reference-only proof](../../evidence/historical-mmulti-object-match.json).
It supplies checked metadata and is never copied or linked into reconstructed
output. The source producer compiles tracked C and pinned public headers.
Tests reject every nonempty segment-tail change and relocation-addend change;
when the private reference is present, they replay its identity/proof and
require the source's full public map to equal it.

The complete executable, original linking/binding and humanization remain
unfinished. [Clean-checkout evidence](https://github.com/abedegno/duke3d-1.3d/blob/e8b2c6788674fa82f74213ccb9afd56ffc4ae3e1/evidence/contribution-clean-replay.json)
separately records all 30 prior contributions at commit `ea405c5`; it does not
claim a replay of this later contribution or full executable identity.
