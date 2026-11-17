# Source-native CODE record layout

This opt-in profile builds the reviewed606 converter from the pinned public
objconv2.57 sources. It preserves the existing defined-global and unused-import
forks and adds explicit source group, automatic-default-section and CODE-record
layout options. The default converter output remains unchanged. It rewrites no
existing object or executable; the layout option accepts fresh ELF32/COFF32
source compilation inputs only, with explicit OMF32 output.

The installed home retains all42 vendor source/project files, notices, original
fork patches and the cumulative metadata patch. The assembler is the existing
pinned GNU2.44 assembler. Build the converter locally:

```sh
python3 profiles/gnu_elf_omf_layouts/setup.py \
  --home toolchains/gnu-elf-omf-layouts \
  --binutils-archive toolchains/archives/binutils-2.44.tar.xz \
  --objconv-archive toolchains/archives/objconv.zip \
  --assembler toolchains/gnu-elf-omf-imports/bin/as-new \
  --compiler /usr/bin/clang++
```

A layout contains only one named `_TEXT` CODE section extent and contiguous
source-relative record spans. For example, a13-byte source fixture may use:

```
OMF_PACKETS_V1
section _TEXT 13
packet 0 5
packet 5 5
packet 10 3
end
```

Use `-fomf32 -wex -packet-plan=path/to/layout.plan` when converting the fresh
source ELF/COFF. These spans are metadata, not instruction/data bytes, target
addresses, relocation permutations or object patches. Every source byte must
be covered exactly once, every real field must stay wholly within one span,
and the native FIXUPP limits must hold. Numeric overflow, signs, unknown or
trailing lines, duplicate options, wrong output formats, archives, old OMF
inputs and field crossings are rejected before publishing an object.

This profile does not admit DATA layouts. Some original compiler data records
contained CODE-section initializer templates; the private606 prerequisite
validated finite source-owned repeated-data extents without consuming original
payload values. Runtime bytes always come from the actual symbolic source.

A tool identity alone does not prove an application's source, typed fields,
private scopes, ABI, bytes or final executable. Consumers must retain their
source/ELF/COFF/native closure and unchanged target gates. Original-object-derived
or reconstructed record boundaries must be documented truthfully; nonunique
boundaries are not recovered historical compiler IR. Existing profiles and the
ordinary C source paths remain available.
