# Game code recovery

> Recovery notebook: probe commands below describe historical experiments. Run those commands from the [archived recovery workspace](../../docs/RESEARCH.md), which retains their scripts and fixtures. For the supported release build, use [BUILDING.md](../../docs/BUILDING.md).

The complete `sounds.c` and `config.c` contributions are verified. Remaining
game modules, complete state types/owners, executable linking/binding and
humanization are unfinished.

```sh
make proof-sounds proof-config
```

Both producers use pinned Watcom GA `/4r /s /ort /dAPPVER_EXEDEF=DN3D13G`;
SOUNDS also uses `/zu`. Header staging merges the pinned historical repository's
root and MACT headers, then `../include/` and this directory's `include/`, in
that order. Conflicting reference headers reject. Original reference files
remain unchanged. The upstream reconstruction covers the 1.3D editor and
later games; its selector does not imply a complete 1.3D game reconstruction.

SOUNDS verifies 4,676 CODE bytes (including its 48-byte menu-sound prefix),
26 CONST bytes, one DATA byte, 12 BSS bytes and all 288 relocations. MIDI
independently anchors its memory hooks. Every nonempty segment tail, the
CODE prefix and external player/user member relocations have corruption
rejection tests. Its BSS ends four alignment bytes before RTS. This refines
the previous checkpoint's 16-byte attribution: the later unused timing static
occupied existing alignment space. The shared period pragma header omits it;
all initialized bytes and relocations still match unchanged.

CONFIG verifies 4,962 CODE bytes (including its 16-byte initializer prefix),
2,092 CONST bytes, 340 DATA bytes, 112 BSS bytes and all 629 relocations.
All four contributions end at independently proved ENGINE boundaries. Fourteen
shared sound globals independently anchor its storage. Restorations remove
later aiming/weapon-choice settings, restore the earlier controller default
handling and save-header version/layout, and use the earlier `Environment`
configuration key. Typed string fields retain explicit compiler alignment
residue. A readable four-instruction Watcom inline copy reproduces the original
11-byte setup-name literal copy after reconstructing the string pool. No
instruction payloads are stored in arrays. Tail, prefix, padding and member
relocation mutations reject through the unchanged whole-module gate.

[Sound provenance](../../evidence/game-sound-source-reference.json) and
[CONFIG provenance](../../evidence/game-config-source-reference.json) record
source hashes and modifications. The GPL text remains in [gpl.txt](gpl.txt).

## External state declarations

`include/soundabi.h` now includes readable player and user declarations in
`playdef.h` and `userdef.h`, replacing opaque view gaps. These headers allocate
no storage. Existing sound/configuration proofs retain all initialized bytes,
BSS obligations and relocations.

The player declaration has the observed 1,362-byte stride, all sound-used
member offsets, and the observed byte palette-lookup offset. Its 11 weapon
slots, 256 weapon records and 13-byte name field are inferred choices fitting
that layout; their complete behavior and original extents are not yet
independently verified. The reset routines distinguish a provisional `level_reset_flag` at 1332 from
`refresh_inventory` at 1344. Other members retain the released ancestor's names.
[Player declaration provenance](https://github.com/abedegno/duke3d-1.3d/blob/e8b2c6788674fa82f74213ccb9afd56ffc4ae3e1/evidence/player-declaration.json)
records these limits.

The user declaration restores the early shoulder-camera byte, 16 player-colour
bytes, and a short multiplayer count near the camera fields; later additions
are removed. Watcom declares 1,598 bytes. Native helpers check the listed
measured offsets, widths and username stride; save/load instruction packets
and complete sound/configuration proofs check the corresponding references.
Other ancestral fields still require the remaining game code to verify them.
[User declaration provenance](https://github.com/abedegno/duke3d-1.3d/blob/e8b2c6788674fa82f74213ccb9afd56ffc4ae3e1/evidence/userdef-declaration.json)
records the checked subset. `player_color` is a readable reconstruction name.

The complete GLOBAL allocation and game behavior remain unfinished. These
declarations establish neither original developer spelling nor recovered
storage ownership, and add no verified BSS/data coverage. Other unused
later-source declarations in the overlay are not a complete v1.3D game header.

## GLOBAL layout investigation

```sh
python3 tools/probe_game_globals.py --build build/global-layout-fresh \
  --report build/global-layout-fresh.json
```

The build directory must be fresh. This compiles a tentative declaration layout
and reports every difference; it is not a recovery proof. The current
[diagnostic](https://github.com/abedegno/duke3d-1.3d/blob/e8b2c6788674fa82f74213ccb9afd56ffc4ae3e1/evidence/global-layout-diagnostic.json) narrows initialized
DATA to 64 bytes, with two unmasked alignment-residue differences. Its BSS
bindings remain inconsistent, so it adds no recovered contribution. Smaller
game-side limits in this experiment are hypotheses. Full global ownership and
state types remain to be established; existing logical external bindings do
not establish their original allocation sizes.

The save/load [instruction observations](https://github.com/abedegno/duke3d-1.3d/blob/e8b2c6788674fa82f74213ccb9afd56ffc4ae3e1/evidence/save-layout-observations.json)
provide stronger constraints than the early size hypotheses:

```sh
python3 tools/inspect_save_layout.py --report build/save-layout-observations.json
```

Two complete MOV/call packet forms expose 51 literal writer records and 48
reader records; 47 pointer/size/count tuples agree between them. Every literal
pointer is checked against its LE loader fixup. Other argument sequences stay
uninterpreted. In particular, the routines transfer 4,096 engine sprites of
44 bytes but 2,048 hit records of 71 bytes, 16 player records of 1,362 bytes,
a 20,000-entry script, 4,096 actor-script pointers and a 64-short sprite queue.
These are explicit transfer arguments, not proof of original macro names,
allocation ownership or the full save/load source. The GLOBAL diagnostic now
keeps the engine limit at 4,096 and gives its tentative hit declaration a
separate 2,048-entry bound. Its prior blanket 2,048-sprite experiment is
superseded; the complete BSS layout remains unverified.

## PREMAP source in progress

```sh
python3 tools/probe_premap.py --build build/premap-fresh \
  --report build/premap-progress.json
```

Use a fresh staging directory. The tracked `premap.c` is an in-progress
reconstruction. Twenty-one explicit function intervals match 11,326 bytes and 728
relocations without masking: mirror rendering, view sizing, spawn selection,
player stat, weapon and inventory resets, sky setup, per-sprite and common
sprite caching, level initialization, new-game setup, timing/input/frag resets,
palette loading, the multiplayer wait handshake, packet-value comparison,
loading screens, level entry, sound loading, sound precaching and the cache traversal. The tile
loads resolve to the independently proved engine `loadtile`.

The [progress report](../../evidence/premap-progress.json) relocates each
CODE interval separately, while requiring one consistent named binding map and
non-CODE segment placement map. Its complete-module check still fails, and mutation tests
reject changed interval tails and engine-call addends. The two other source code
publics, common function order, local data/BSS, referenced string contents,
unrecovered callee/receiver integration and complete behavior remain
unverified. This adds zero completed contributions and is excluded from
`proof-modules`. [Source provenance](../../evidence/premap-source-reference.json)
records the remaining limits and the period-header build profile.

The [Ghidra analysis adapter](../../profiles/watcom/ghidra/README.md) maps loader-relocated
copies and assigns explicit register parameters to selected routines. Its first
draft helped resolve `resetplayerstats`; the corrected C passes the independent
native byte gate. Decompiled output is analysis material, never recovery proof.

The target timing reset includes input, lag and frag clearing that the later
source split into other routines. Restored level entry performs prediction and
FIFO reset work inline and calls the earlier timing reset. The later standalone
`clearfrags`, `clearfifo` and `resetmys` definitions have been removed from this
PREMAP candidate. This does not establish whether those names occur elsewhere
in the target. Only `resetpspritevars` remains unmatched here. The complete 448-byte
`resetprestat` interval clears a fixed 64-entry sprite queue; its 24 relocations
and alignment bytes match.

The terminal level-entry proof uses all 1,390 native bytes, through its final
RET, rather than rounding the extent up to 16 bytes. Two following target zero
bytes remain outside the source CODE claim; linker alignment and whole-file
identity remain unfinished. The proof also checks the zero store to the player
short at offset 728; its retained ancestral name is still inferred.

OMF local symbols remain part of each complete contribution proof but are
excluded from cross-module anchors. In particular, ENGINE's private static
`tempbuf` at object 3 offset 911744 is distinct from the game's external buffer
at 413968. The palette-loading interval checks the latter. Reports used as
cross-module anchors must now include explicit local-scope metadata.

The restored wait routine uses two host readiness phases with timed retries,
a separate client path and Escape cancellation. The packet-9 comparison
routine has no equivalent body in the later ancestor; `compare_network_value`,
`wait_abort` and `received_sync_value` are provisional reconstruction names.
The volatile received-value declaration preserves the observed repeated reads;
it does not establish the original type spelling. Packet handling, caller
integration and allocation ownership remain unfinished. The network operands
also use exported/reference anchors from the complete MMULTI source proof.

Shared-address checks include a regression where two functions individually
match under incompatible global addresses, plus equivalent cases for an
unnamed data segment and distinct named publics in the same owned segment.
All are rejected by the multi-interval gate; compatible controls still pass. Fresh
FX_MAN, MUSIC and GAMEDEF proofs also anchor the restored level-entry audio calls.

## GAMEDEF complete contribution

`make proof-gamedef` compiles `gamedef.c` with Watcom 10.0 GA and verifies
30,834 initialized bytes, 40 BSS bytes and all 2,339 relocations. All 20 public
CODE intervals match, including the interpreter and its preceding switch
tables. The complete gate uses one CODE placement at object1:145840 and checks
all native segments and public bindings. Linking and the complete executable
remain unfinished.

The initialized contribution includes 27,265 CODE bytes, 3,173 string/padding
bytes and a 396-byte keyword-pointer table. Typed text fields make compiler
alignment residue explicit; no target instructions are embedded in data.
The terminal `execute` interval ends at RET173105, excluding subsequent linker
alignment. The complete native BSS range is object3:77760..77800; original
static identifier spelling remains inferred.

The target has 99 keyword pointers, including duplicate `debug` at slot98,
and 26 startup parameters. A 13-character filename limit retains the
independently measured 128-byte array stride. The loading path preserves its
input-end pointer, short line count, unconditional compile diagnostics and
earlier prompt behavior. Movement uses the earlier jump sine index without
the later wrap operation.

The interpreter restores earlier pickup, resizing, debris, weapon-hit,
respawn and player-state behavior. Its weapon-record bound is256, and the
visibility handler retains an unused calculation present in the emitted code.
Register allocation changes across this large function as its control flow
changes; handler-size resemblance alone was never accepted as proof.

See the [complete module proof](../../evidence/gamedef-module.json),
[source provenance](../../evidence/gamedef-source-reference.json) and
[public interval diagnostics](../../evidence/gamedef-progress.json).
The detailed probe also runs the complete gate, using a fresh build directory:

```sh
python3 tools/probe_gamedef.py --build build/gamedef-new --report build/gamedef-new.json
```

## ACTORS C and symbolic effector contribution

The complete [ACTORS composite proof](https://github.com/abedegno/duke3d-1.3d/blob/e8b2c6788674fa82f74213ccb9afd56ffc4ae3e1/evidence/actors-module.json) checks
61,674 CODE bytes, the sole 67-byte locator-error string, six BSS bytes and all
2,812 relocations. It covers every emitted segment and all 37 public functions
at explicit placements. The source consists of readable `actors.c` and the
named mnemonic companion [moveeffectors.asm](moveeffectors.asm).

```sh
python3 tools/probe_actors_composite.py --build build/actors-complete-fresh \
  --report build/actors-complete-fresh.json
```

The build directory must be fresh. This producer uses original Watcom 10.0 GA
with canonical headers/options plus `/dDUKE13D_EFFECTOR_ASM=1`, and NASM 2.16.03
as an **alternate assembler**. The default NASM binary is the workspace-local
`toolchains/support/nasm-2.16.03/nasm`; its supplied host-build identity is
checked. `--nasm /path/to/nasm` permits another host build of exactly 2.16.03,
records its actual binary hash, and retains the official source-archive
identity. NASM is not claimed as the historical Duke assembler. No tool is
downloaded or installed by the proof command.

`DUKE13D_EFFECTOR_ASM` defaults to zero. The default C build retains the complete
readable effector definition, its 18,770-byte native candidate, and the existing
36-function partial proof. Companion mode excludes that definition at source
level; the C compiler emits 42,884 CODE bytes and BSS6. The assembler emits its
whole 18,790-byte CODE segment, consisting of two source-owned LEA alignment
instructions followed by the exact 18,778-byte effector, plus CONST67. No C
output is sliced, discarded or merged. There is one definition of every function
and one owner for each storage contribution.

The previous `moveexplosions` interval remains 4,144 bytes: 4,132 from C plus
12 preceding alignment bytes now explicitly owned by ASM. Its 119 fixups and
complete historical interval remain checked. The original 36 intervals retain
42,864 bytes and 1,889 fixups; the effector adds 18,778 bytes and 923 fixups. The
leading 32-byte C CODE data/alignment prefix also remains verified, including
its compiler-recognized 24-byte data range and inferred alignment-residue byte.

The companion is an **assembly stand-in with a visible humanization backlog**.
Its instructions came from our own freshly compiled recovered C, with ordinary
mnemonics, real symbol relocations, explicit branch/immediate/address widths,
and 22 named stack homes. A complete own-C roundtrip checked every resolved
operand and relocation target before the stack-home mapping. The 727 stack
operands use the certified ESP states and 39 callee contracts; 27 typed views
and the disjoint shared slot remain represented. There are no instruction-byte
arrays, reference instruction payloads, incbin directives or object patches.
Provisional scratch/CFG names are not claimed as original developer identifiers.

[Standalone effector provenance](../../evidence/actors-effector-source.json)
records the source origin, named-home derivation, selector, ownership and tools.
The earlier [C recovery provenance](../../evidence/actors-source-reference.json)
and [default-C partial proof](../../evidence/actors-progress.json) remain
historical checkpoints. Current native bindings derive from independently
verified exports and both newly emitted objects; saved private local names are
not cross-module anchors.

The reviewed whole-object composite gate verifies exact nonoverlap and union,
all initialized bytes/fixups, BSS without file backing, public boundaries and
local scopes. These explicit placements prove source contributions. Historical
linker selection/order, linking the complete game, full-file identity, remaining
modules and readable C equivalence/humanization of the assembly stand-in remain
unfinished.
