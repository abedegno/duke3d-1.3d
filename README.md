# Duke Nukem 3D v1.3D — recovered source

A source-assisted reconstruction of the **registered DOS v1.3D executable**, verified against the complete original file.

| Verification | Result |
| --- | --- |
| Rebuilt file | `DUKE3D.EXE` |
| Size | **1,179,131 bytes** |
| Differing bytes | **0** |
| SHA-256 | `a197b6b4097fa39987f4a843141830ff1553eb52b606b51fc67d067560de0cf4` |
| Source inputs | 121 freshly compiled owned translation units |
| Tested environment | macOS Apple Silicon, Python 3.14, DOSBox-X, pinned historical toolchains |

This is a reconstruction, not a newly discovered original source archive or an official 3D Realms release. It uses the released v1.5 source, historical source reconstructions, native-code analysis, and iterative compilation. Some matching backends use readable named assembly alongside their C counterparts. Original comments, names, and development history are not claimed where the evidence does not establish them.

## What is included

- Recovered game code, Build engine contributions, audio/control interfaces, and supporting source.
- The exact source/link recipe, tool profiles, metadata-only relocation layouts, and verification tools.
- C reading aids, notices, provenance records, and documentation of uncertain declarations.
- A **hash manifest** for vendor-derived source that must be supplied locally.

**Restricted vendor-derived source, compiler binaries/libraries, sound banks, game media, original executables, and the rebuilt executable are not distributed here.** The public checkout needs the local dependencies described below before it can reproduce the complete file. This repository does not grant redistribution rights to those components.

## Build the verified version

```sh
git clone --recurse-submodules https://github.com/abedegno/duke3d-1.3d.git
cd duke3d-1.3d
python3 tools/verify_source_manifest.py

# Import a lawfully supplied, project-specific vendor-source overlay.
python3 tools/import_local_dependencies.py --from /path/to/local-source-overlay

# Install the pinned tools and private assets described in docs/BUILDING.md.
make rebuild VENDOR_PREFIX=/path/to/vendor-prefix.bin
python3 tools/verify_rebuild.py --result build/complete-source-game-residue-preparation.json
```

See **[BUILDING.md](docs/BUILDING.md)** for the complete prerequisites and limits. The dependency overlay contains reconstructed driver sources and metadata; an arbitrary SDK installation is not a substitute. Its files are checked against `verification/local-dependencies.json` before import and are ignored by Git.

The verified route retains the internal option name `--prepare-game-residue`. Seven bytes after existing string terminators are explicitly represented as **unidentified residue**. They do not change the strings' contents or capacities. Their historical declaration and purpose remain unknown. The earlier zero-residue and ordinary-C routes remain available as research history; `make rebuild` selects the exact route.

## Verification and provenance

The match covers **every byte**: code, initialized data, headers, relocation serialization, alignment, and the bound container. There are no comparison masks or post-link patches. The converter's record-layout plans change metadata emitted from fresh ELF/COFF source compilations; they contain no target instruction payloads.

The build links unmodified selected members of original compiler libraries and binds a separately pinned DOS4GW component. Those are declared dependencies, with no recovered-source credit. The production build reads no reference game payload or cached research object. An independent SHA-256 check verifies the resulting file.

- [Portable verification record](verification/rebuild.json)
- [Exact main-workspace build evidence](evidence/root-exact672.json)
- [Source readability and remaining C work](docs/source-readability.md)
- [GAME function index](docs/game-source-navigation.md) · [ACTORS function index](docs/actors-source-navigation.md)
- [Reconstruction methodology](docs/RECONSTRUCTION.md)

CI checks the public source manifest and publication boundaries. It does **not** claim to rebuild the game without the separately supplied dependencies.

## Source tree

| Path | Contents |
| --- | --- |
| `src/game/` | Game logic, matching assembly backends, C counterparts |
| `src/engine/`, `src/cache/`, `src/network/` | Engine and supporting contributions |
| `src/audio/`, `src/mact/` | Audio/control source and interfaces |
| `profiles/`, `candidates/`, `modules/` | Pinned tools, build recipes, matching contracts |
| `tools/`, `tests/` | Build, inspection and verification tooling |
| `evidence/` | Provenance and historical reconstruction records |
| `verification/` | Public snapshot, dependency and executable manifests |

Some component documentation and evidence retain intermediate experiment names and negative results. They are historical records; the verification table above describes the completed exact route.

## Licensing and credits

**[LICENSE.md](LICENSE.md)** inventories the different component terms. Game code retains the original GPL notices and [COPYING](COPYING). The Build engine retains Ken Silverman's separate [BUILDLIC.TXT](src/engine/BUILDLIC.TXT). Other sources retain their own notices. No blanket GPL grant is made over third-party components.

// "Build Engine & Tools" Copyright (c) 1993-1997 Ken Silverman  
// Ken Silverman's official web site: "http://www.advsys.net/ken"  
// See the included license file "BUILDLIC.TXT" for license info.

Credit belongs to 3D Realms/Apogee, Todd Replogle, Matt Saettler, Ken Silverman, Jim Dose, the original library authors, and the maintainers of the historical reconstruction projects referenced by the pinned submodules and component provenance. This recovery builds on their work. Duke Nukem and associated names remain trademarks of their respective owners.

Game assets are required to play and remain under their original terms. No game data is included.
