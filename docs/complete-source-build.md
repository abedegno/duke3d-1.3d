# Complete present-source build and vendor binding

`tools/build_complete.py` is the portable source/link recipe. It compiles all
122 owned translation-unit/capsule objects and the explicitly approved DATA96,
prepares 177 unmodified stock compiler members plus five original libraries,
runs the pinned native WLINK, and binds the pinned supplied DOS4GW prefix.
No development object, receipt, helper or source under an ignored research
build directory is an installed production dependency. The target game image
and SDK/game objects are not source/link inputs. Stock runtime and vendor
components remain supplied, separately attributed, with zero source credit.

Initialize the repository's pinned source submodules and install the normal
compiler/assembler/converter/decoder tool homes using the existing profiles.
The explicit recipe is `candidates/complete_source.json`; it records every
source node, actual producer API or source/header/options vector, declared
home and exact FILE/library order. Custom source nodes delegate their fixed
source/header/profile contracts to the named existing source-only APIs. Their
full native receipts are retained under the new build child. Tool homes belong
under `toolchains/`; no machine-specific absolute home is embedded in the
recipe. The normal GAME metadata profile is set up using
`profiles/gnu_elf_omf_game/README.md`; old GAME C and other modes remain available.

Creative's SYNTHGM.SBK/SF2 assets are normal pinned vendor bank inputs. Prepare
them using `python3 -m src.pawe32.embed.assets` with the authentic local inputs
or its explicit download option. `src/pawe32/embed/assets.json` gives exact
hashes, original URLs, selected bank ZIP member, notices and rights. This setup
extracts no compiled SDK members and executes no vendor installer.

Supply the separately pinned 217764-byte DOS4GW vendor prefix. Its SHA256 is
`21d1cda74c1f4e379b5796c8f33a6619dfced9e5b8eef2df642a21b91fc882ff`.
The prefix-only production binder validates its MZ/BW frame chain and hash; it
reads no reference game payload. The existing reference-aware binder API is
unchanged. Vendor and bank media retain their original rights and notices.

One normal command, after those declared dependencies are installed:

```sh
python3 tools/build_complete.py \
  --assets build/assets/pawe \
  --vendor-prefix /path/to/pinned/vendor-prefix.bin \
  --build build/complete-source --report build/complete-source.json
```

`make complete-source VENDOR_PREFIX=/path/to/pinned/vendor-prefix.bin` invokes
the same recipe. `python3 -O` is supported: mandatory checks use exceptions.
Every invocation creates a fresh child, compiles all source objects, publishes
raw logs/receipts, and never reuses a previous build's objects. Inputs and
copied link objects/libraries are hashed before/after tools. The header stage
is checked against live hashes captured before copying. No source object or
executable is rewritten after production.

The recipe retains the real GAME main→six-public-tail attachment, physical
late TASK_MAN/ANIM owners and native first-wins selection. The exact 17
known duplicate definitions are checked from real native PUBLIC scope and
native warnings; no broad duplicate-suppression option or symbol alias is
introduced. FILE order includes interspersed supplied stock and owned nodes;
do not sort it or replace it with archive scanning.

The current reproducible native candidate SHA is
`5903772b3bba5998d04fded6c3d1da3be799c6e68108bc518efaef15e87974c3`.
This includes the causally measured metadata-only FILE-order corrections:
ENGINE ASM O012 immediately follows ENGINE C O073, and unchanged stock D005
immediately precedes R080. Raw record pages152/173 now match; all loaded bytes,
objects and27384 complete loader fields remain literal the original source
baseline16778. The old-order full normal/O source builds and separate new-order
native normal/O links are retained; a final cold build with later packet-policy
integration remains a separate checkpoint.
The recipe stops on a differing native result and preserves its actual map/log.
It does not compare against or copy a target executable during production.
Seven GAME post-NUL CONST zeros and raw fixup serialization remain known
whole-target differences; their authorization/profile work is separate. This
command adds no accepted source coverage and makes no target-file identity
claim. The retained readable C counterparts are aids, not duplicate link nodes.

The optional `make complete-source-native-layout VENDOR_PREFIX=...` command uses
reviewed source-owned CODE record spans with the separate
`gnu_elf_omf_layouts` profile. Set up that profile using its normal setup command
first. It builds the complete ACTORS compiland as one object, so this mode has
121 owned objects and 299 explicit FILE inputs followed by five libraries.
The default command and its 122-object recipe remain unchanged. Both modes
retain the seven GAME CONST zeros and report `whole_target_match: false`.
See [the layout contract](../src/native_layout/README.md) for provenance,
source-only boundaries and finite metadata differences.

### Optional GAME-residue preparation (not adopted)

`--prepare-game-residue` is a separate preparation-only switch and requires
`--native-layout`. It selects the isolated tracked
`src/game/symbolic_preserved/GAME.S` producer for the real main/tail pair; its
seven unidentified post-NUL CONST bytes remain explicitly preparation data.
The existing default and `--native-layout` commands retain their zero bytes
and their existing reproducible hashes. No approval is inferred from building
or comparing this optional artifact.

```sh
python3 tools/build_complete.py --native-layout --prepare-game-residue \
  --assets build/assets/pawe \
  --vendor-prefix /path/to/pinned/vendor-prefix.bin \
  --build build/complete-source-game-residue-preparation \
  --report build/complete-source-game-residue-preparation.json
```

The equivalent Make target is `complete-source-game-residue-preparation`.
Like the other routes, every invocation compiles121 fresh owned source nodes
and binds only the separately pinned vendor prefix. It reads no target game
image during production and reuses no prior source objects. This selected
recipe declares native SHA
`a5fd6a00453c9f923b6c453a91be2401bfafad3ce55ee6ff741727f2346be88a`.
Its result and declared recipe say `preparation_only: true` and
`adoption_approved: false`; `whole_target_match` remains false because this is
not an adoption decision. Only this mode has `known_negative: null`. Actual
full target-file identity belongs to a separate external observer after the
build, rather than target access or a permission claim by the producer.
The optional mode adds no source credit and does not replace either existing
mode or its retained negative history.
