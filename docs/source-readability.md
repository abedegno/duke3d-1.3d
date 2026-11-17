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

## GAME remains a whole assembly backend with verified C counterparts

A fresh full-translation-unit audit found **79 of 81 ordinary GAME C bodies
exact**, covering 65,742 bytes including trailing compiler fill and 4,194 typed
fixups. These are per-function contribution results, not proof that the whole
C object has the target's complete data layout or relocation serialization.

`wallswitchcheck` matches from both standalone and full-TU C: all 160 body bytes
and its real sprite relocation. Its following 37-entry switch table belongs to
`spawn`; treating that table as part of `wallswitchcheck` caused an earlier
misclassification. `ShutDown` also matches the actual provider exports; the old
partial role packet had the CONTROL/keyboard identities swapped. The source
already called them in the correct order, so no speculative source edit was made.

The two remaining nonexact bodies are `spawn` and `checkcommandline`. `spawn`
retains instruction scheduling/register-lifetime differences. Two branches in
`checkcommandline` share its epilogue and therefore depend on the `spawn` fix;
changing that function in isolation is not justified. Their ordinary C remains
available alongside the named mnemonic bodies. The [GAME index](game-source-navigation.md)
links algorithms and the current whole assembly backend.

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
