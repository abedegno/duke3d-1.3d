# Source readability and remaining C reconstruction

The exact build uses ordinary historical/derived C, named assembly procedures
and explicit declarations for initialized data. Original notices and inferred
names remain qualified. Matching the executable does not establish unique
historical spelling or make every emitting body C.

## ACTORS now emits its matching C directly

The exact native-layout route freshly compiles the first **36 ACTORS functions
from `src/game/actors.c` with Watcom GA**. It assembles only `moveeffectors` from
its named NASM source. The source-native OMF linker conserves all contributed
bytes, BSS, typed relocation expressions, public/private scope and compiler
metadata. The existing complete-C-owned record plan changes record boundaries
only, including the span across the two source contributions.

The [ACTORS index](actors-source-navigation.md) links to the actual emitting C
and the fallback. The older whole `ACTORS.S` backend remains available for
comparison. All 37 algorithms have C counterparts. The fixed complete-C witness
still differs in 298 stack-home displacement bytes across 14 frame homes in
`moveeffectors`; tested declaration, expression and harmless discarded-view
changes did not produce an exact replacement. None was admitted merely because
it improved a partial score.

## GAME emits 79 functions from C

The exact native-layout route compiles **79 GAME functions** from
`src/game/game.c` with the pinned Watcom GA flags and `GAME_ASM_FALLBACKS`.
The named assembly companion supplies `spawn` and `checkcommandline`, including
their switch tables and shared epilogue branches. Their C counterparts remain
in the source for further recovery.

The source-native OMF linker conserves all 89,280 initialized bytes, 4,160 BSS
bytes and 5,020 typed relocation fields from the C and assembly contributions.
A separate native assembly object supplies the six genuine public BSS tail
owners in 15 bytes. Native record layout then changes packet boundaries.

The 140 private message arrays have explicit capacities and post-NUL values.
Their names are inferred. Seventeen assembly imports use the declared GAME
source-unit convention and resolve to actual C private definitions. The final
object retains private scope. The nine-byte `PLAYING ` copy uses an explicit
Watcom-specific structure view to preserve the original copy instructions.

`spawn` retains C scheduling and register-lifetime differences. Two
`checkcommandline` branches share its epilogue. The [GAME index](game-source-navigation.md)
links directly to the emitting C and assembly source.

## Other components and limits

Ordinary game C largely retains the released 1.5 lineage's names, types, macros,
sprite-list loops, tile switches and procedural style. Reconstruction changes
restore 1.3D behavior and compiler constraints rather than modernize that style.
The audio and control libraries have their own authors' idioms. Reconstructed
capsules retain C reading aids where emitting source is still assembly;
original assembler modules remain assembly. See the [GF1 lineage](lineage/gf1-dma-utils-native.md).

Inferred frame-home/private-object names do not establish historical spelling.
Explicit unidentified DATA remains qualified. The current exact route includes
the documented seven post-NUL bytes; older receipts retain their then-pending
adoption wording. Stock runtime members and the DOS4GW prefix are separately
supplied components with zero recovered-source credit.

Further C lowering must preserve complete source contributions and every typed
role, then pass the unmasked whole-executable comparison. No instruction blobs,
object/image byte patches, fabricated private exports or arbitrary frame-home
permutation lists are used as a substitute for C recovery.
