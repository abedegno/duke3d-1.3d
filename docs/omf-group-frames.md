# Explicit OMF group frames in flat LE proofs

`verify_module`, `compare_range` and `match_function` accept an optional
`group_frames` mapping from an OMF GRPDEF index to `(LE object, 0)`.
For example, `group_frames={1:(3,0)}` binds the first source group to the
base of LE object3. This is an explicit placement assertion supplied by the
caller; the verifier does not infer it from the spelling `DGROUP`.

This extends the approved strict Watcom profile. An unbound non-FLAT group
still fails by default. Existing FLAT, identical target-frame and F5 handling
is unchanged. Absolute32 references require their resolved target in the bound
object.
Relative32 references additionally require that object to be the source object
and reject any loader relocation on the relative operand. Every nonempty local
group member
must be placed in that object, and an internal target segment must actually
belong to the source group. Nonzero frame offsets, split or unplaced group
members and unknown/duplicate indices are rejected. Cross-object relative
references remain unsupported.
All operand bytes and every target loader relocation remain checked; no
object record, frame field, instruction or target byte is rewritten.
Module reports record nonempty explicit bindings in `group_frames`.

The [TIS OMF1.1 specification](https://openwatcom.org/ftp/devel/docs/omf.pdf),
FIXUPP section, defines F1 as a group-index frame. The modern
[Open Watcom linker implementation](https://github.com/open-watcom/open-watcom-v2/blob/master/bld/wl/c/obj2supp.c)
also distinguishes group frames from target and FLAT frames; it is corroboration,
not authority for historical native output.

`tests/test_group_frames.py` assembles and links an ordinary pointer initializer
and address-return function with original Watcom10.0 GA WASM/WLINK. The native
map places DGROUP at object2:0, CONST at2:4 and DATA at2:8. Both the CODE and
DATA fixups explicitly use F1 DGROUP. The complete assembler contribution
contains15 initialized bytes and two runtime relocations. The fixture executes
a C comparison of the returned address against the C address expression and
requires a zero exit status. Negative tests retain the original relocation
checks and reject damaged bytes and incorrect group/target assumptions.
This fixture does not execute Duke or establish its link layout.

Private research also replays the unchanged stock `find386` and `math2err`
members with an explicit object3 group frame. All23 math2err DATA pointers
independently constrain its108-byte CONST segment to3:28864. Complete strict
proofs then cover130bytes/four fixups and429bytes/29fixups respectively.
These are unmodified supplied compiler dependencies, with zero rebuilt-source
credit. This helper change alone did not promote either member. The subsequent
[selected runtime extension](watcom-runtime-components.md) verifies them with
explicit bindings; original whole-program member selection remains unproved.
The remaining startup, link, runtime inventory and byte-identical executable
work stays open.

`tests/test_relative_group_frames.py` measures the relative path with original
GA WASM/WCC386/WLINK. An ordinary CGROUP-qualified near CALL to a separate C
callee emits an actual F1 group frame, self-relative location9/width4 fixup.
The linked caller is at object2:20, its operand at22, and the callee at32;
the native displacement is `32-(22+4)=6`, with no loader relocation. The
executable exits zero only when the call returns42. Whole-module proofs cover
all33 initialized bytes and two fixups across the three own C/ASM objects.
Each invocation builds fresh retained child artifacts and snapshots source,
tool and native-output hashes. Test AST and LE corruptions are identified as
adversarial controls, not additional native producer evidence.

For this subset the existing equation remains
`effective=(resolved_offset+OMF_displacement+original_addend) mod 2^32`, then
`relative32=(effective-(operand_offset+4)) mod 2^32`. The common LE object base
cancels because frame, source and resolved target objects are equal. The
membership guard, explicit `(object,0)` binding, width/location checks, complete
byte comparisons and relocation accounting remain active. Raw OMF frame,
thread and displacement metadata are retained; this support neither rewrites
records nor proves any historical compiler identity or complete executable.
