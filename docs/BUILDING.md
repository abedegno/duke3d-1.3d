# Building the exact registered v1.3D executable

The verified route is source-only before linking declared stock runtime components and binding a pinned vendor prefix. It rebuilds every owned source input on each invocation; it has no production cached-object mode.

## 1. Check out pinned references

Use `git clone --recurse-submodules`, or run `git submodule update --init --recursive`. The reference repositories provide source/header context. Their prebuilt game or SDK objects are not production inputs.

## 2. Supply the local vendor-source overlay

The public repository excludes vendor-derived GF1/FORTE/Gravis and Creative source families and their associated recovery material. The required paths and exact SHA-256 values are in `verification/local-dependencies.json`.

```sh
python3 tools/import_local_dependencies.py --from /path/to/local-source-overlay
```

The source directory must contain the project-specific paths listed in the manifest. The importer validates **all** source bytes before copying, refuses conflicting existing files, and checks the copies. It grants no rights and does not download or accept any licence. Imported files remain ignored by Git.

A stock SDK alone does not contain all reconstructed files in this overlay. Without a lawfully supplied matching overlay, the complete exact build is unavailable. The public game/engine source and integrity checks remain usable independently.

## 3. Prepare tools and assets

The recorded successful environment is macOS on Apple Silicon with Python 3.14 and DOSBox-X. The profiles pin tool identities, including host-specific GNU/objconv binaries. A fresh build on another host may need reviewed profile adaptation; cross-host binary reproducibility is not claimed.

| Dependency | Setup / reference |
| --- | --- |
| Watcom 10.0 GA, 10.0a, 10.0b and 10.5 | `python3 tools/setup_watcom.py --list`; archive hashes and extraction rules are in that tool and `profiles/watcom/`. |
| MASM 5.10 and TASM 3.1 | `tools/setup_masm.py`, `tools/setup_tasm.py` and the corresponding profile documentation. |
| NASM 2.16.03 | Pinned source/tool identity under `toolchains/support/nasm-2.16.03`; component profile documentation records its contract. |
| GNU assembler / objconv variants | `profiles/gnu_omf/`, `profiles/gnu_elf_omf/`, `profiles/gnu_elf_omf_imports/`, `profiles/gnu_elf_omf_game/`, `profiles/gnu_elf_omf_layouts/`. Preserve the exact patches and notices. |
| Capstone | `profiles/capstone/README.md`. |
| Creative/E-mu SBK/SF2 bank inputs | Local overlay's `src/pawe32/embed/assets.json` and `assets.py`; exact assets remain private. |
| DOS4GW vendor prefix | Separate 217,764-byte file, SHA-256 `21d1cda74c1f4e379b5796c8f33a6619dfced9e5b8eef2df642a21b91fc882ff`. |

Compiler archives, tool binaries, banks and the vendor prefix are deliberately absent. Use your own authorised inputs. Open Watcom or a modern compiler is not a drop-in replacement for the byte-matching profiles.

## 4. Rebuild

```sh
make rebuild VENDOR_PREFIX=/path/to/vendor-prefix.bin
```

This delegates to the previously verified command:

```sh
python3 tools/build_complete.py --native-layout --prepare-game-residue \
  --assets build/assets/pawe --vendor-prefix /path/to/vendor-prefix.bin \
  --build build/complete-source-game-residue-preparation \
  --report build/complete-source-game-residue-preparation.json
```

It freshly produces 121 owned link contributions, including ACTORS from a C compile plus its assembly fallback, selects 177 unmodified original compiler-library members and five original libraries, invokes native WLINK, and binds the prefix. The selected recipe and source contracts pin flags, headers, ownership, layout and library order. Seven post-NUL values remain explicitly unidentified DATA; this route changes no logical string content or storage capacity.

## 5. Verify every output byte

```sh
python3 tools/verify_rebuild.py --result build/complete-source-game-residue-preparation.json
# Or check an executable directly:
python3 tools/verify_rebuild.py --file /path/to/DUKE3D.EXE
```

Expected size: **1,179,131 bytes**. Expected SHA-256:

```
a197b6b4097fa39987f4a843141830ff1553eb52b606b51fc67d067560de0cf4
```

The verifier needs no reference executable and applies no masks. It checks the known full-file identity. Obtain the registered game data separately to play; do not commit the data, executables, compiler files or local overlay.

## Release checks and research workflows

Plain `make` shows the supported release commands. `make test` runs the retained public regression files explicitly; provision the local overlay and pinned native tools first. Observer regressions additionally use your original `reference/DUKE3D.EXE` and pinned `build/assets/dos4gw/vendor-prefix.bin`; these are separately supplied test fixtures, not owned-source production inputs. Imported private-overlay tests are not discovered by this command. CI checks publication integrity without those dependencies. Historical proof targets and experiments are preserved in the [recovery archive](RESEARCH.md).

The ACTORS native-layout backend now compiles `src/game/actors.c` with `DUKE13D_EFFECTOR_ASM=1`, assembles `moveeffectors.asm`, and links those fresh contributions semantically before applying source-owned record boundaries. The older whole-assembly backend remains an optional comparison tool; [source readability](source-readability.md) records the remaining C work.
