# Measured DOS/4GW binding boundary

The private v1.3D executable contains a separable 217,764-byte vendor component
before its inner MZ/LE program. The approved recovery design permits this vendor
runtime as a supplied build dependency. It earns no recovered-source credit.
[evidence/dos4gw-runtime.json](../evidence/dos4gw-runtime.json) records every
reused range and its identity; no vendor or game binary payload is tracked.

The outer MZ load image ends at 62,580. Two BW headers identify `VMM.EXP`
(62,580–123,076) and `4GWPRO.EXP` (123,076–217,764). Their forward chain points
exactly to the inner program. The complete component SHA-256 is
`21d1cda74c1f4e379b5796c8f33a6619dfced9e5b8eef2df642a21b91fc882ff`.
This identifies the preserved bytes, rather than a unique original vendor
release or binder command.

The [Open Watcom header](https://github.com/open-watcom/open-watcom-v2/blob/master/bld/watcom/h/exe16m.h)
corroborates the BW field layout. Both original MAKEPM2072 headers use
`whole_pages * 512 + remaining_bytes` for their measured extent. The
[modern writer](https://github.com/open-watcom/open-watcom-v2/blob/master/bld/wl/c/load16m.c)
uses a different page-count convention. The tool supports only the pinned old
container; it is not a general DOS/16M reader or writer.

An ordinary `int main(void) { return 0; }` fixture compiled and linked with
preserved Watcom GA/WLINK naturally reproduces the entire target inner MZ stub:
10,648 bytes, SHA-256
`3d1278454dbb867e17b383b65571031b232bb924393a49d116d7220080b54091`.
The tool prepends only the vendor component to a supplied unbound program.
Every program byte remains intact. Reparsed LE objects, fixups, entry and stack
are checked after the origin moves to 217,764. The native toy fixture produces
233,729 bytes and does not match the game executable. No generated executable
is run by the tool or tests.

```sh
python3 tools/bind_dos4gw.py \
  --reference reference/DUKE3D.EXE \
  --program build/program.exe \
  --output build/bound.exe \
  --report build/bound-report.json
```

All four paths must identify distinct files, including through symlinks or hard
links. The reference must retain its pinned complete identity. The supplied
program must be a valid unbound MZ/LE image with the independently reproduced
stub. Unknown vendor bytes, malformed/truncated chains, changed stubs and
already-bound inputs are rejected.

The report compares the entire output with the reference, including length,
SHA-256 and every byte, with no masks. It explicitly leaves source rebuild and
whole-executable recovery unverified: accepting a program input does not prove
how that input was produced. The complete game build, final layout and runtime
behavior still require their own evidence.
