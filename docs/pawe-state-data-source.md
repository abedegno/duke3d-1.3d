# NRPNVAR and MIDIVAR from the actual typed state sources

`tools/probe_pawe_states.py` supplies a source-authoritative standard-WASM backend
for the existing tracked `src/pawe32/nrpnvar.c` and `midivar.c`. Those files,
CTAWEAPI.H and their HighC counterparts/evidence are unchanged. This branch adds
new descriptors/evidence and does not register/account either module in root.

`src/pawe32/state_data.py` recognizes only the actual small declaration subset:
public int/WORD/DWORD literal scalars and the released API types with ordinary
zero initialization. It reads real declaration order/counts from those C files
and opaque char typedef dimensions from the unchanged released header. It does
not invent private fields inside NRPNCHANNEL/SCRATCH/SOUNDFONT/GCHANNEL/
MIDICHANNEL, emit a target DATA segment array, or allocate fake filler objects.
SOUNDPAD has its seven actual named NULL pointer fields. Other declarations,
storage classes and nonzero opaque-state initializers reject explicitly.

Scalar values retain the existing native-observed initializer provenance:
boundaries1234h/5678h, NumG30, BaseAddx620h, DramSize40000h. Numeric sentinel intent
and original Creative source spelling remain unknown. No original SDK implementation
source or new media/license permissions are claimed. Creative/Apogee header notices
and the original HighC blocker evidence remain intact.

The backend emits one readable API-record macro invocation per declared element,
ordinary scalar directives, and normal global alignment: WORD scalars2, int/DWORD/
pointers and initialized API record globals4. This mirrors the measured actual
C counterpart's global-object alignment, not a claim that char has4-byte member
alignment. SCRATCH's real702 bytes are followed by normal alignment before SFont;
no two-byte padding/storage field exists. The primary header is pinned: changing
SCRATCH to704 must reject even if a resulting byte layout could swallow that gap.
A byte gate alone cannot prove declaration authenticity.

Both new modules have standard32-bit OMF DATA0xa9, not historical Easy OMF DATA0xa8.
Real original metadata is not rewritten. Each has one DATA segment/DGROUP, exactly
its genuine public definitions and no CODE/BSS/imports/fixups/extra directives.
The native assembler never emits the HighC `_mwargstack`/`_mwgoc` imports, so their
absence is natural source output, not metadata pruning/dummy definitions. The
old HighC C/native positives and their genuine link blocker remain separate facts.

## Source-only build

No target, SDK, HighC installation, bank assets or old prototype outputs are
needed to build. The project GA toolchain/DOSBox-X is used unchanged:

```
python3 tools/probe_pawe_states.py build --module nrpnvar \
  --home toolchains/watcom-10.0-ga --build build/pawe-states \
  --report build/nrpnvar-source.json
python3 tools/probe_pawe_states.py build --module midivar \
  --home toolchains/watcom-10.0-ga --build build/pawe-states \
  --report build/midivar-source.json
```

Fresh children use the real NRPNVAR.ASM and MIDIVAR.ASM filenames. All actual
C/header/model/contract/provenance/helper/tool/host identities are checked before
and after native generation. Distinct module names avoid generic SOURCE library
collisions. No original object is a producer input.

## Whole native proof and actual consumer

With the project's usual reference executable and AWE32 source-header tree:

```
python3 tools/probe_pawe_states.py prove \
  --home toolchains/watcom-10.0-ga --peer-home toolchains/watcom-10.0a \
  --build build/pawe-states --report build/pawe-state-proof.json
```

A fresh fully verified AWE32 source peer must use the accepted10.0a compiler.
Its actual named boundary/scalar references anchor both1544/2396DATA modules,
including complete marker DWORDs, all13 global scopes and every initialized byte.
The standard parser/verifier is unchanged. Placement comes from caller constraints,
not an arbitrary match search or a reference SDK object.

The same proof links and executes `tests/fixtures/pawe-state-consumer.c` with only
the two fresh source-built objects and stock CLIB. It includes the unchanged API,
checks actual flat32 sizes, all declared zero/default state, boundary objects and
natural Scratch/SFont alignment. It links no SDK or HighC object. Compiler/linker/
runtime/header inputs and the actual staged consumer inputs are retained and
checked; the producer's entire source graph is rechecked after the consumer.

Focused tests:

```
WATCOM_HOME=$PWD/toolchains/watcom-10.0-ga \
WATCOM_100A_HOME=$PWD/toolchains/watcom-10.0a \
python3 -m unittest discover -s tests -p 'test_pawe_states.py' -v
```

Tests include standalone subprocess builds with no reference/SDK/HighC/assets,
reused parents/fresh children, real scalar/pointer-width/alignment/scope native
mutants, source-race/header-identity controls and complete extent/import checks.
No per-byte grid or broad unchanged suite is required. Root integration registers `make proof-pawe-states`; accepted accounting is in
`docs/recovery-progress.md`. Remaining SDK CODE, complete linking/EXE and
humanization remain unfinished.
