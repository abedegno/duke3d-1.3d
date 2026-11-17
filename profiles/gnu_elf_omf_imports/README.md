# Separate ELF profile preserving unused imports

This opt-in tool profile leaves profiles/gnu_elf_omf, its tool home and all existing module routes unchanged. It pins the same source-built GNU binutils2.44 i386-elf assembler and a separately attributed objconv2.57 cumulative source fork. All42 original source identities and all42 derived identities are fixed in profile.json. Exactly three files change: omf.h/cof2omf.cpp retain genuine defined GLOBAL references as same-name EXTDEF+PUBDEF; elf2cof.cpp preserves intentional unreferenced undefined GLOBAL declarations when no section was actually removed. All original copyright/license headers remain verbatim. Both exact source patches and vendor instructions/manual are installed with the local tools. This is source-level conversion, never an object/instruction patch.

The actual-section-removal check follows the existing ELF conversion lifecycle: MakeSectionsIndex tags a removed debug/exception section SHT_REMOVE_ME, and that internal tag persists until HideUnusedSymbols. With no tag, hiding returns without erasing genuine imports. When a section was removed, the prior broad hiding behavior remains unchanged. That case is measured for compatibility, not offered as a safe application-admission mode.

This is a tool identity/setup profile, not a generic application-admission guard. Each caller must additionally enforce its own closed ELF32 little-endian i386 ET_REL schema: exact source/section/symbol/aux/relocation roles and storage, no debug/exception stripping, weak/COMMON/TLS/COMDAT/hidden/nondefault visibility, unknown or ABS relocations, or preexisting internal SHT_REMOVE_ME types. Do not infer support for arbitrary ELF32/64, MachO, archives or other vendor converter capabilities. Genuine unused undefined GLOBAL imports are intentionally retained with zero references and become real downstream linker obligations. No fake source reference, export/alias, output rewrite or guessed provider is permitted. Private references retain actual local section+V meaning; E already supplies B+V for real defined GLOBALs.

Exact public source archive URLs/hashes are in profile.json. Download them as source archives using an ordinary HTTP client. No account, license acceptance, installer/serial action, global installation or bundled executable is required. A root-relative full source-build recipe follows. It rebuilds from the archives, not from installed SDK outputs or research directories:

```sh
TASK_ROOT="$PWD"
# Place exact pinned source archives in build/downloads first.
mkdir -p build/elf-imports-source
python3 - <<'PYARCHIVES'
from pathlib import Path
import hashlib
from profiles.gnu_elf_omf_imports.identity import profile
s=profile()['source_archives']
for name,key in [('binutils-2.44.tar.xz','binutils'),('objconv.zip','objconv')]:
 if hashlib.sha256((Path('build/downloads')/name).read_bytes()).hexdigest()!=s[key]['sha256']:raise ValueError('source archive identity')
PYARCHIVES
cd build/elf-imports-source
tar -xf ../downloads/binutils-2.44.tar.xz
mkdir as-build
cd as-build
../binutils-2.44/configure --target=i386-elf \
 --prefix="$TASK_ROOT/build/elf-imports-source/local-prefix" \
 --disable-nls --disable-werror --disable-gdb --disable-gdbserver \
 --disable-gprofng --disable-gprof --disable-ld --disable-gold --disable-sim \
 --disable-readline --without-debuginfod --without-zstd --with-system-zlib \
 --disable-shared --enable-static
make -j4 all-gas
cd "$TASK_ROOT"
python3 - <<'PY'
from pathlib import Path
import io,zipfile,hashlib
from profiles.gnu_elf_omf_imports.identity import profile
from profiles.gnu_elf_omf_imports.apply_fork import apply
s=profile();p=Path('build/downloads/objconv.zip')
if hashlib.sha256(p.read_bytes()).hexdigest()!=s['source_archives']['objconv']['sha256']:raise ValueError('archive')
with zipfile.ZipFile(p)as z:data=z.read('source.zip')
if hashlib.sha256(data).hexdigest()!=s['source_archives']['objconv']['source_zip_sha256']:raise ValueError('nested source')
d=Path('build/elf-imports-source/objconv-source');d.mkdir()
with zipfile.ZipFile(io.BytesIO(data))as z:
 expected=s['converter_fork']['original_source_files']
 if set(z.namelist())!=set(expected)or len(z.namelist())!=len(expected):raise ValueError('source set')
 for n,h in expected.items():
  b=z.read(n)
  if Path(n).name!=n or hashlib.sha256(b).hexdigest()!=h:raise ValueError('source identity')
  (d/n).write_bytes(b)
apply(d)
PY
cd build/elf-imports-source/objconv-source
c++ -O2 -o ../objconv *.cpp
cd "$TASK_ROOT"
python3 profiles/gnu_elf_omf_imports/setup.py \
 --home toolchains/gnu-elf-omf-imports \
 --binutils-archive build/downloads/binutils-2.44.tar.xz \
 --objconv-archive build/downloads/objconv.zip \
 --assembler build/elf-imports-source/as-build/gas/as-new \
 --converter build/elf-imports-source/objconv
```

Existing exact reviewed source-built binaries may be supplied to setup without repeating an unchanged build. Setup validates source archives/nested source, exact42-source graph, three-file transformation, both binary hashes and notices before atomic publication to a fresh home. It rechecks all archive/tool/recipe inputs before publication; an interrupted/failed stage is removed. No installed shared home is overwritten. checked_home rejects extra/missing files, changed sources/patches/notices/binaries, symlinks and changed setup provenance, and returns every file identity for producer pre/post checks. Downstream producers must also bind their own source/staged input and native-output freshness around native calls. A different host/compiler/path may change executable identities; the profile rejects those pending separate review instead of promising universal native binary reproducibility. Host shared-cache dependencies are recorded separately from DOS libraries.

Focused native tests (no skipped test cases) require both exact old and new homes, the unchanged GA DOS tool home and the two source archives:

```sh
TASK506_BINUTILS_ARCHIVE="$PWD/build/downloads/binutils-2.44.tar.xz" \
TASK506_OBJCONV_ARCHIVE="$PWD/build/downloads/objconv.zip" \
python3 -m unittest tests.test_gnu_elf_imports -v
```

GNU_ELF_IMPORTS_HOME, GNU_ELF_OMF_HOME and WATCOM_HOME may select alternate exact homes. Tests show the old converter losing unused_, the new converter preserving it without any extra relocation, actual WLINK failing without its real provider, and success when the real provider is supplied. These are link-resolution checks; the no-start/no-stack observer images are not executed or claimed runtime42 proofs. Debug/exception-removal outputs retain old native bytes with equal output filenames. Tests also check archive/tool damage, full home notice/source/extra-file damage, non-original/reapplied source patches and a staging input race with no publication. Actual PENTTIME, ROX and WAD validations are separately retained in the Task506 research report; this profile does not add or switch their normal modules or manufacture runtime credit.
