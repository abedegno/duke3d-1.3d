# Separate ELF-to-OMF source toolchain

This profile does not change the existing GNU COFF home. It pins GNU binutils2.44 configured for i386-elf and a separately attributed objconv2.57 source fork. The fork changes only omf.h/cof2omf.cpp: referenced defined GLOBAL symbols retain real same-name EXTDEF+PUBDEF selection. E already includes B+V; no extra V is added. Private/section references remain local. This is a source-level converter change, not an object or instruction patch. Vendor copyright/GPL headers remain in all42 source files; notices/manual and the exact patch are installed with the local tools.

Only source-specific closed ELF schemas may use this profile. ROX admits exact sections, alignment, names/scopes, default visibility, typed R_386_32/PC32 fields, source-folded ABS values and structural FILE/SECTION records. Weak/common/TLS/COMDAT/hidden/unknown relocations/actual ABS relocations are unsupported. Pure tooling identity does not prove an application's source, ABI, target bytes or final link.

Public pinned source archives are the exact URLs/hashes in profile.json. Download those sources with an ordinary HTTP client, preserving names. No accounts, installers, serials, EULA actions, global installs or bundled binary execution are required. Rebuild in ignored local directories:

```sh
ROOT="$PWD"
mkdir -p build/gnu-elf-source
# Extract the exact pinned binutils-2.44.tar.xz under build/gnu-elf-source.
mkdir build/gnu-elf-source/as-build
cd build/gnu-elf-source/as-build
../binutils-2.44/configure --target=i386-elf \
 --prefix="$ROOT/build/gnu-elf-source/local-prefix" \
 --disable-nls --disable-werror --disable-gdb --disable-gdbserver \
 --disable-gprofng --disable-gprof --disable-ld --disable-gold --disable-sim \
 --disable-readline --without-debuginfod --without-zstd --with-system-zlib \
 --disable-shared --enable-static
make -j4 all-gas
cd "$ROOT"
# Read the exact source.zip nested in pinned objconv.zip. Extract its42 flat
# members into build/gnu-elf-source/objconv-source, retaining CRLF bytes.
python3 -c 'from profiles.gnu_elf_omf.apply_fork import apply; apply("build/gnu-elf-source/objconv-source")'
cd build/gnu-elf-source/objconv-source
c++ -O2 -o ../objconv *.cpp
cd "$ROOT"
python3 profiles/gnu_elf_omf/setup.py --home toolchains/gnu-elf-omf \
 --binutils-archive /path/to/binutils-2.44.tar.xz \
 --objconv-archive /path/to/objconv.zip \
 --assembler build/gnu-elf-source/as-build/gas/as-new \
 --converter build/gnu-elf-source/objconv
```

Tasks455/461 independently validated the source build and finite native first-public/odd-extent behavior;462/469 prove actual ROX. Existing exact reviewed binaries may be supplied to setup without repeating unchanged builds. Setup verifies both public archives, all42 original source identities, the separately applied exact two-file derived graph, notices and both binary identities before atomic publication. Home inventories include the complete fork source graph and are checked around native operations. Rebuilding on another compiler/host/path can change native executable hashes; this profile rejects such identities pending review instead of claiming cross-host binary reproducibility. Native host shared-cache dependencies are recorded in profile.json and are not DOS link inputs.

Default home is project-local toolchains/gnu-elf-omf; GNU_ELF_OMF_HOME can select another exact setup home. Source production never reads SDK objects or target bytes. Complete target observation follows production and uses unchanged OMF verification. No runtime/source credit or final executable identity follows from setup.

Capability limit: this reviewed fork preserves referenced defined globals. The
unmodified ELF→COFF HideUnusedSymbols path still drops unreferenced undefined globals. ROX requires
all14 original imports to remain referenced and present, so that limitation is
not exercised here. Modules relying on unused undefined/FPU imports need a
separate explicit linker/import contract or a separately reviewed source fix;
this profile does not manufacture references or silently broaden the fork.
