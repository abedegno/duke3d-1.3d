# Creative EMBED DATA from typed source and bank assets

This module reconstructs17444 DATA bytes and nine globals. It contains no CODE,
BSS, relocations or imports. The producer is ordinary Watcom1.0 WASM; the separate
full AWE32 caller proof requires Watcom10.0a, matching the accepted AWE32 profile.
No original SDK library/object, HighC installation, reference executable or old
prototype output is needed to **build** EMBED. Complete verification separately
reads the normal reference executable and freshly source-builds the AWE32 caller.

The tracked source graph is `src/pawe32/embed/`: a typed preset/instrument/zone/
generator/sample model, specific symbolic record emitter, measured SF1 amount
conversion and explicit reconstructed millisecond cutoff initializers. Native-
observed named fields/omissions and unused scalar values are documented in
[NOTICE.md](../src/pawe32/embed/NOTICE.md). It does not claim original Creative C,
a recovered historical cutoff formula, a matching historical compiler or a whole
SDK/EXE. No target packed pads or output-offset patches enter the generator.

## Private asset setup

Do not commit the banks or SDK archive. [assets.json](../src/pawe32/embed/assets.json)
pins both exact primary bank artifacts, the one archive/member needed for SF2,
source URLs, sizes, hashes and notice limitations. Setup preserves complete bank
bytes/internal copyright and writes an honest local-input/download receipt. It
reads only that bank member from the ZIP; no SDK objects, installer or license
acceptance is used.

From existing privately retained inputs:

```
python3 -m src.pawe32.embed.assets --destination build/assets/pawe \
  --sbk /private/media/SYNTHGM.SBK --sdk-zip /private/media/adip301.zip
```

Or fetch exactly the pinned public files:

```
python3 -m src.pawe32.embed.assets --destination build/assets/pawe --download
```

A changed bank/archive rejects; setup does not silently repair damaged existing
assets. The independent SBK is from the Creative AWE64 Gold vendor CD mirror;
SF2 is the Creative ADIP3.01 demonstration bank. They are generator inputs, not
compiled SDK output. Notices and original licensing remain in force; this source
recovery does not grant distribution rights in those assets.

## Source-only build and complete proof

Use the project's existing GA/10.0a toolchain setup. Build can run in a standalone
checkout containing only the tracked source/model/probe/helper files and prepared
bank files, without a reference or HighC tree:

```
python3 tools/probe_pawe_embed.py build \
  --home toolchains/watcom-10.0-ga --assets build/assets/pawe \
  --build build/pawe-embed --report build/pawe-embed-build.json
```

For the separate complete native/target proof, use the project's normal reference
and AWE32 source-header trees and its10.0a caller compiler:

```
python3 tools/probe_pawe_embed.py prove \
  --home toolchains/watcom-10.0-ga --peer-home toolchains/watcom-10.0a \
  --assets build/assets/pawe --build build/pawe-embed \
  --report build/pawe-embed-proof.json
```

Every invocation creates a fresh build child while reusing the requested parent.
It snapshots all actual model/source/helper/asset/tool inputs, stages the real
EMBED.ASM filename, emits a readable C counterpart for review, and assembles native
output. The full ignored logical-model trace remains in that child; its hash and
named provenance summary remain in the report. No HighC backend is executed.

The proof checks standard OMF DATA0xa9 (explicit USE32/DWORD alignment), all nine
exact global scopes/offsets, no extra segments/imports/fixups/directives and all
17444 bytes. Seven independently named pad references from a freshly verified
10.0a AWE32 module anchor the DATA contribution. Historical Easy OMF DATA0xa8 and
the original producer metadata remain distinct; no record rewriting is used.
All normal ALIGN4 residue bytes are part of the whole comparison.

The preserved source-reference evidence records the independent HighC typed-C
match and the196608-case actual original-SDK converter observer as reference-only
witnesses. Original objects from those experiments never enter this producer.
The HighC `_mwargstack`/`_mwgoc` problem is avoided naturally by this source backend,
without pruning an EXTDEF or inventing a runtime definition. Other SDK CODE and
state-module limitations remain separate work.

Focused native checks:

```
PAWE_EMBED_ASSETS=$PWD/build/assets/pawe \
WATCOM_HOME=$PWD/toolchains/watcom-10.0-ga \
WATCOM_100A_HOME=$PWD/toolchains/watcom-10.0a \
python3 -m unittest tests.test_pawe_embed
```

Registration/accounting is a separate root integration step after independent
review; no source credit or full-executable completion follows from this branch.
