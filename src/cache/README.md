# Recovered CACHE1D contribution

The C and pragma definitions derive from `BUILDBAK/CACHE1D.C` and
`BUILDBAK/PRAGMAS.H` in the historical Build collection pinned by
[evidence/historical-build.json](../../evidence/historical-build.json).
Original archive SHA-256:
`08666b77e36f3033a6f3f3b2bf1c43fa655923705cac8d97df0249ce4a2891bd`.
Ken's license is preserved in [BUILDLIC.TXT](BUILDLIC.TXT).

Changes from that snapshot:

- CACHE1D references the engine's shared `cachesize` word at LE object 3,
  offset 31681. A separately retained four-byte initialized slot at 32073
  has no references in this module and is named `reserved_cache_size`.
  This expresses measured bindings/layout, not an asserted historical cause.
- `cacleng` and `lockptr` have external linkage for GAME's measured cache
  display references at object3:1682304/1665920. Removing only their two
  `static` qualifiers preserves the entire native byte/fixup projection and
  allows a separately compiled consumer to link with original WLINK. Other
  cache internals, including `handptr` and `dmval`, remain local. This restores
  a source linkage model; original symbol spelling remains inferred and the
  complete game link is still unfinished.
- The pragma include is renamed `kpragma.h` to isolate it from unrelated
  headers and satisfy the DOS compiler's short filename requirements.
- Required modification notices are present in the C and header.
- Line endings and trailing whitespace are normalized. Routine and pragma
  instruction tokens are preserved.

`make proof-cache1d` compiles these tracked inputs with GA `/4r /s /or` and
verifies every contribution, including unused pragma-header BSS state.
The historical engine object supplies a corroborating shared-word binding;
it remains a prebuilt mapping reference, not recovered engine source.
