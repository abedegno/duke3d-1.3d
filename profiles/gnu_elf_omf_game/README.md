# GAME metadata profile

This separate opt-in source-built converter profile preserves the existing
GNU/objconv default behavior. It combines the reviewed defined-global and
unused-import forks with two metadata-only options: source-owned group plans,
and rejection-guarded omission of three canonical empty automatic GNU defaults.
It preserves all substantive bytes, symbols and relocation addends. Explicit
source declarations, any names, storage, relocation, meaningful alignment or
group membership prevent default omission. Genuine empty CONST2 remains.

The official pinned archives in profile.json are input to this setup recipe:

```
python3 profiles/gnu_elf_omf_game/setup.py \
  --home toolchains/gnu-elf-omf-game \
  --binutils-archive build/downloads/binutils-2.44.tar.xz \
  --objconv-archive build/downloads/objconv.zip \
  --assembler toolchains/gnu-elf-omf-imports/bin/as-new \
  --compiler /usr/bin/clang++
```

The assembler must have the existing exact unmodified GNU2.44 identity. The
converter is compiled freshly from all 42 retained vendor source/project files
and tracked source patches; its binary identity must be c4083466...da5f1.
The 39 C++-build inputs do not replace or erase the three other vendor files.
Complete home checks include source, notices, patches and setup receipt before
and after use. Dynamic macOS loader/system-library dependencies remain normal
host dependencies, explicitly recorded in profile.json.
