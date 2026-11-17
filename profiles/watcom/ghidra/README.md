# Duke 1.3D analysis aid

This is a narrowly scoped Ghidra adapter, not a complete Watcom compiler
specification or an Exhume generic verification backend. Ghidra drafts help
interpret unmatched routines. Only the native compiler/OMF/LE comparisons
establish recovered bytes and relocations.

Tested with Ghidra 12.1.4 and Java 21 on macOS arm64. From the repository root:

```sh
python3 tools/export_ghidra_image.py --output build/ghidra-objects
mkdir -p build/ghidra-work/home build/ghidra-work/cache build/ghidra-work/tmp \
  build/ghidra-work/projects build/ghidra-work/drafts
export JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home
export JAVA_TOOL_OPTIONS="-Duser.home=$PWD/build/ghidra-work/home -Dapplication.cachedir=$PWD/build/ghidra-work/cache -Dapplication.tempdir=$PWD/build/ghidra-work/tmp -Djava.io.tmpdir=$PWD/build/ghidra-work/tmp"
/opt/homebrew/opt/ghidra/libexec/support/analyzeHeadless \
  build/ghidra-work/projects Duke13 \
  -import build/ghidra-objects/object1.bin \
  -loader BinaryLoader -loader-baseAddr 0x10000 \
  -processor x86:LE:32:default -cspec windows -noanalysis \
  -scriptPath profiles/watcom/ghidra \
  -postScript DukeDraft.java "$PWD/build/ghidra-objects" "$PWD/build/ghidra-work/drafts" \
  -log build/ghidra-work/headless.log -scriptlog build/ghidra-work/script.log
```

Use fresh export and project names on subsequent runs. Adjust installed tool
paths for other hosts. These commands keep preferences, caches and temporary
files inside the build directory. The script imports the other two LE objects
at their recorded bases with their original permissions; gaps stay unmapped.
The exporter requires the pinned target SHA-256, copies zero-filled LE storage,
and applies all 27,363 unique loader fixups to the copies. Type 7 becomes the
absolute virtual target address; type 8 becomes the PC-relative displacement.
Duplicate page-boundary records must agree; overlapping operands are rejected.
Original executable bytes and all byte-proof inputs stay unchanged.

The Windows compiler spec is only a language bootstrap. The script overrides
the selected routines with custom Watcom register parameter storage: `snum` in
AX and the `setpal` player pointer in EAX, with a void result and zero stack
purge. It does not model the full Watcom register allocation/clobber convention
or signatures of unseeded callees. Extend explicit signatures when analyzing
other routines; do not trust default Windows argument inference.

`resetplayerstats` is exported as draft C under `build/`. The neutral labels,
inferred types and compiler-generated expressions are analysis hints. They
neither establish original source spelling nor add matching coverage. This
first draft exposed the OR condition for the early player reset flag and the
weapon-to-firing-tile lookup; corrected readable C then passed the separate
816-byte/14-relocation native interval proof.
