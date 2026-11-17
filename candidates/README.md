# Uncredited source/link candidates

These configurations are intentionally outside `modules/` and the complete
prover/Make aggregates. They describe source-built complete runtime objects
whose unused storage still lacks an independent historical target placement.
They grant no accepted coverage. A normal native linker can consume the actual
objects while the strict fixed-target whole verifier continues to reject them.

INIT and INIT2 use `tools/build_gf1_init_candidate.py`. The default is a source-only
build with exact native runtime/scope/fixup contracts; `--observe` adds read-only
original/EXE comparisons after compilation. See
[`gf1init-candidates.md`](../src/gf1/lineage/gf1init-candidates.md) for the complete
reproduction, primary-source lineage, finite metadata differences and hard limits.
