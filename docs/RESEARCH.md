# Recovery workspace and release layout

The main branch contains the recovered sources, exact build support, release regressions and retained provenance. The original recovery workspace is preserved on [archive/recovery-workspace-2026-11-17](https://github.com/abedegno/duke3d-1.3d/tree/archive/recovery-workspace-2026-11-17), at immutable commit [`e8b2c67`](https://github.com/abedegno/duke3d-1.3d/tree/e8b2c6788674fa82f74213ccb9afd56ffc4ae3e1). Existing release tags and history are preserved.

## What was separated

The cleanup removes 294 public research files from the main tree: 147 historical/optional evidence files, 16 optional module descriptors, two unused candidate files, 15 recovery tools and 114 associated recovery tests. Their paths and original identities are recorded in [research-archive.json](../verification/research-archive.json). The archive contains the complete original workspace, so experiments and their callers can be used together at their original paths.

This is a conservative separation. Final full-file evidence, source-reference contracts and the dependency closure of release regressions stay on main. Do not treat every remaining JSON file as an old report: several are mandatory producer inputs.

A dependency audit covered all 1,071 original public tracked paths. Python read tracing distinguished explicit producer/contract reads from the builder's broad whole-namespace freshness checks. A disposable copy omitted an even larger 442-file set and freshly rebuilt all 121 owned source inputs to the same complete 1,179,131-byte executable, SHA-256 `a197b6b4097fa39987f4a843141830ff1553eb52b606b51fc67d067560de0cf4`. The smaller 294-file cleanup retains final proof records and useful regression support that an executable build alone does not require.

The experiment does not establish that omitted files are useless for every historical target or configuration. Some tests and observers require the original executable or research fixtures. Use the archive for those workflows; its own original instructions, dependencies and scope qualifications still apply.

## Active build support

- `candidates/` contains the seven active source/link/runtime/layout recipes. The historical directory name does not imply these files are optional.
- `modules/` contains active contribution contracts and retained verification descriptors.
- `evidence/` contains mandatory source-reference identities, final proofs and retained supporting evidence. Negative intermediate records retain their original meaning.
- `tools/` provides production builders, installation, verification and retained observers. Some production APIs retain historical `probe_` names.
- `tests/` retains 13 public regression files for the release route. `make test` selects those explicitly, avoiding discovery of ignored tests supplied in the private overlay.
- `profiles/` retains pinned compiler/converter setup, identities, patches and notices.

Emitting sources, readable C counterparts, alternative source backends and original notices remain in `src/`. The exact route still uses the original active contract paths and producer hashes. No blanket renaming or hash refresh was used to bypass their validation.

## Commands

Plain `make` prints release help. `make rebuild VENDOR_PREFIX=/path/to/prefix` runs the exact route; `make verify-rebuild` checks the entire output file. The old `complete-source-game-residue-preparation` name remains a compatibility alias. `make source-integrity` checks the published source snapshot. See [BUILDING.md](BUILDING.md) for local dependencies.

The many earlier proof/experimental Make targets remain in the archived Makefile. They are not the supported main-branch command interface. `docs/recovery-progress.md` and older evidence describe history, not a substitute current build recipe.

The restricted vendor-source overlay, compiler binaries, sound banks, game data, original executable and rebuilt executable remain excluded. Archiving research grants no new rights. Public snapshot and local-dependency manifests continue to enforce that boundary.
