# Source readability and remaining C reconstruction

The complete build uses authored C, named assembler procedures and explicit
source declarations for initialized data. The matching backends retain their
C counterparts, interfaces, notices and provenance. The source guards and
independent contribution reviews distinguish real initializer or switch-table
data from instructions; executable instructions are emitted as mnemonics.

The [GAME index](game-source-navigation.md) covers all 81 CODE functions and
links each emitted body to its C algorithm. Three bodies—`wallswitchcheck`,
`spawn` and `checkcommandline`—were reconstructed in assembly after the fresh C
derivative. Their compiler-faithful C reconstruction remains open.

The [ACTORS index](actors-source-navigation.md) covers all 37 functions. Thirty-six
are direct derivatives of fresh canonical C. The remaining `moveeffectors`
algorithm also has C source; its exact C lowering differs in frame allocation.
The exact build emits one whole assembly contribution so that a relocation
record can span the former C/assembly boundary. The fixed complete-C witness
and earlier composite build remain available for comparison.

The reconstructed audio and control-library capsules retain C reading aids and
named interfaces alongside their emitting source. Their local README and
lineage files record the relationship to published source and the remaining C
lowering work. For example, the [GF1 DMA/UTILS lineage](lineage/gf1-dma-utils-native.md)
and [DRAM capsule](../src/gf1/dram-elf/README.md) describe their current limits.
Original assembler modules continue to use their original source languages.

Names for inferred frame homes or private objects describe the reconstruction;
they do not establish historical spelling. Explicit unidentified DATA remains
qualified as such. Stock compiler-library members and the supplied DOS4GW prefix
are inventoried build dependencies with no recovered-source credit. Their bytes
and notices are preserved separately from authored game code.

This pass adds navigation and makes those limits visible. It changes no emitting
source or compiler option and does not claim that every function now compiles
from C. Further C lowering can proceed function by function while retaining the
current readable source and complete contribution proof. Each change must also
pass the unmasked whole-executable comparison.

The readable source tree passes the complete optional preparation build:
[Root672 evidence](../evidence/root-exact672.json) records all 121 fresh source
inputs and an exact full-file match. The separate preserved DATA variant has
the same CODE as the indexed source and changes only the seven documented
post-NUL bytes. Their adoption decision remains pending; the old source and
its negative history remain available.
