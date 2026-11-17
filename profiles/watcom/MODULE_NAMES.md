# Optional native module identities

Existing runner calls keep SOURCE.C/SOURCE.ASM staging and their original flags.
No descriptor, compiler profile, target binding or default is rewritten.

```python
compile_source(home, source, output, options, module_name='CACHE1D')
assemble_source(tasm_home, source, output, options, source_name='MV_MIX.ASM')
assemble_native(wasm_home, source, output, source_name='PENT.ASM')
```

The C keyword adds the original compiler's documented `/nm=<name>` option. The
ID must be one to eight ASCII identifier characters; a second `/nm` option is
rejected. SOURCE.C staging and its `__FILE__` value remain unchanged. Actual GA
and10.5 native characterizations underpin this interface; it does not claim a
unique historical compiler or historical library-module spelling.

Assembler filenames must be eight-character ASCII identifier basenames with an
ASM extension and are normalized to uppercase. Default SOURCE.ASM remains
unchanged. Actual input filename macros/debug records may change when a caller
opts in; each recovered producer must retain its full runtime proof.

## Native archive integrity

```python
from tools.native_library import build_library
report = build_library(ga_home, whole_object_paths, fresh_directory)
```

This small API packages explicit whole objects with the measured unmodified GA
WLIB3.0. It does not build a source graph or infer source provenance from OMF.
Recovery callers must supply whole authored translation units and retain their
source/header/compiler receipts; original SDK objects and interval extractions
are not substitutes. There is no implicit original SDK or target dependency.

The builder inspects actual THEADR stems, rejects case-insensitive collisions
(including SOURCE.C versus SOURCE.ASM) and duplicate global exports, and keeps
local symbols private. The measured route supports eight-character module IDs
and8.3 filenames. Objects are copied under safe aliases into a new directory.
Every original/staged input and tool is checked before/after native WLIB. Any
native diagnostic rejects. Exact member count/identities and every raw member
byte must equal the original objects, including imports, debug records and
checksums. Metadata-equivalent rewrites are not accepted. Existing directories
are never reused or overwritten.

Receipts preserve native module names, object/member/export hashes, input/tool
identities and the actual library. They explicitly award zero source credit and
make no historical member selection/order or whole-executable claim. Unused
EXTDEFs remain real imports; this API does not prune or resolve them.

## Existing debug-profile effects

With the existing GF1 `/d2` profile, `/nm` can change $$TYPES source/module filename
metadata and an empty unreferenced FAR_DATA segment name. GF1ADDR's measured
SOURCE11_DATA becomes GF1ADDR11_DATA; debugger geometry/hashes can also change.
A no-include own C fixture does not emit that empty segment/filename table, so
these effects depend on the translation unit and included declarations.

These are explicit native metadata deltas, not a general semantic mask. The
existing `without_watcom_debug` policy remains unchanged; full runtime bytes,
all typed fixups, imports, publics/scopes and nonempty segment properties must
still prove. No object metadata is stripped or patched before archiving. Source
consumers and complete native proof reports retain their default route until a
separate reviewed packaging/build caller deliberately opts in.

Task104's diagnostic44-member audio archive retains all519 exports, while native
lazy linking selects37 members and still fails. Its reduction131→126 undefineds
comes from unselected importers, not newly supplied definitions or source
recovery. Actual historical archive order, selection, linker layout, binder and
whole-file identity remain open.
