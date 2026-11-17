# Complete contributions from multiple source objects

`tools/verify_composite.py` verifies complete, unmodified emitted OMF objects
against explicit target placements. It calls the existing single-object gate
for every producer, including every initialized segment, BSS obligation and
relocation. It neither joins object payloads nor discards compiler output.

The caller supplies independent external bindings and a fixed range contract:
`(LE object, offset, size, initialized-or-BSS)`. The gate requires the exact
emitted union to equal that contract. It rejects overlapping producers,
missing or extra ranges, incorrect storage kinds, unplaced segments,
conflicting anchors and duplicate global exports. Actual producer publics
resolve cross-object calls and pointers. Local symbols remain private to
their producer; ambiguous local/global external spellings reject because
the underlying matcher resolves names rather than separate external indices.

The tests include an original Watcom C/assembly fixture that is compiled,
linked and executed. Its two original objects prove 34 initialized bytes and
four relocations together, excluding the linker's one alignment byte. Tail
damage rejects. Separate adversarial fixtures cover private-anchor leakage,
same-spelling local/global references, gaps, overlap and relocation damage.
An independent review reproduced additional malformed cases through actual
OMF parsing. No parser, matcher or single-object gate was relaxed.

The private ACTORS split also passes: C emits 42,884 CODE bytes and six BSS
bytes; the symbolic companion emits 18,790 CODE bytes and its sole 67-byte
constant. The companion owns twelve preceding alignment bytes as two real
LEA instructions, followed by the 18,778-byte effector. The combined proof
checks 61,741 initialized bytes, six BSS bytes and all 2,812 fixups, with
37 distinct function entries. The assembly derives from our recovered C and
uses named stack homes; it is an explicit stand-in awaiting humanization.
Independent review approved this private source experiment. Production
integration and source coverage promotion remain pending.

These are contribution and placement proofs. They do not establish historical
linker selection/order, a runnable game, complete executable identity or
completion of the subsequent source humanization pass.

The reviewed gate checkpoint passed all 192 project tests (710.074 seconds),
with all 365 frozen source/helper/test/evidence inputs unchanged. This run
predates production ACTORS integration and adds no source coverage.

The standard `actors` module route creates a fresh native subdirectory for each
invocation under its reusable build directory, and reports that artifact path.
Both complete original objects remain available. Repeating `make proof-actors`
does not reuse old output or require removal of the build tree. The lower-level
custom producer retains its explicit fresh-directory input contract.
