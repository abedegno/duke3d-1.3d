# Source-built GNU2.44 → objconv2.57, closed hardware subset

This profile admits only the two independently reviewed native binaries in
profile.json. It is not general COFF/OMF support or a compiler/ABI waiver.
GNU as is source-built GNU Binutils2.44 (i686-w64-mingw32 COFF); objconv is Agner
Fog source2.57 (bundled manual2.54). Source archive/tool identities are explicit.
Source GPL/tool licenses do not relicense Creative/Vu program materials.
No tool binary, bank/game media or full primary guide is tracked here.

Obtain the exact public archives in profile.json, verify their SHA256 values,
and retain their notices. The primary AWE32PRG.ZIP supplies unchanged
AWE32P10.TXT (Vince Vu/Judge Dredd1995, acknowledgment requested). Public access
is not asserted as unrestricted redistribution permission. Downloading/extracting
these archives needs no account, installer, serializer, key or license action.

A root-relative source-build recipe, using only original source (no patch):

```sh
ROOT="$PWD"
mkdir -p build/gnu-omf-source
# Extract the pinned binutils-2.44.tar.xz below that directory, preserving names.
mkdir build/gnu-omf-source/gas-build
cd build/gnu-omf-source/gas-build
../binutils-2.44/configure --target=i686-w64-mingw32 \
  --prefix="$ROOT/toolchains/gnu-omf-prefix" \
  --disable-nls --disable-werror --disable-gdb --disable-gdbserver \
  --disable-gprofng --disable-gprof --disable-ld --disable-gold --disable-sim \
  --disable-readline --without-debuginfod --without-zstd --with-system-zlib \
  --disable-shared --enable-static
make -j2 all-gas all-binutils
cd "$ROOT"
# Read source.zip from the pinned objconv.zip; extract its exact42 flat files
# to build/gnu-omf-source/objconv-source. No bundled Windows EXE is used.
cd build/gnu-omf-source/objconv-source
# The original build.sh documents this exact build command:
c++ -o ../objconv -O2 *.cpp
cd "$ROOT"
```

Those source/configuration policies were validated in Tasks195/196, with
unmodified source bytes checked against the public archives; no repeat build
of unchanged tools is required. Host compiler/linker/debug paths can affect
native executable hashes; bit reproducibility across hosts/paths is not claimed.
The fixed reviewed profile rejects a different build identity rather than
silently rewriting pins. Any new binary identity needs a separate reviewed
profile update; the source/target checks are never weakened to accommodate it.
Current tool host dependencies are native libSystem/libz/libc++ shared-cache
libraries, recorded in profile.json; these are not DOS program link inputs.

Stage the exact already-reviewed source-built files (including copies from a
validated local source build) into a fresh private tool home:

```sh
python3 profiles/gnu_omf/setup.py --home toolchains/gnu-omf \
  --binutils-archive /path/to/binutils-2.44.tar.xz \
  --objconv-archive /path/to/objconv.zip --primary-archive /path/to/AWE32PRG.ZIP \
  --assembler /path/to/gas/as-new --converter /path/to/objconv
```

setup.py checks source archives, all42 objconv source identities, both native
binary hashes, nested source.zip, the exact primary member and full retained
notices. It performs no tool execution, source change or global installation.
It copies only approved tools/primary/notices and records setup.json. Normal
production reads this tool home alone, never a source-build/research directory.
Wrong/missing/extra/damaged tool-home files reject, including a changed primary
publication. A source build producing a different binary is an explicit profile
mismatch; this setup contains no automatic trust-on-first-use or hash bypass.
