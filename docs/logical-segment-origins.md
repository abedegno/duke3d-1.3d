# Issued PUBLIC DATA origins

Default `verify_module` behavior and proof dictionaries are unchanged. Watcom's
PUBLIC combination can align a contribution relative to a logical segment
leader rather than the executable object's absolute base. Native TASM/WLINK
fixtures demonstrate this with executed return values4/4/4/0, including an empty
leading DATA definition. See the approved
[implementation plan](superpowers/plans/2026-11-16-public-segment-origins.md).
The default and exact empty tuple/list paths do not import the optional origin
module, so existing standalone producer dependency graphs remain sufficient.
Other falsy values, including false, zero, empty mappings and strings, reject.

The optional API is:

```python
from tools.prove_logical_data_origin import replay_target_data_origin
from tools.verify_module import verify_module

context = replay_target_data_origin(home=compiler_home, build=receipt_parent)
proof = verify_module(module, image, placements, symbols,
                      logical_origins=(context,), group_frames=frames)
```

There is no origin, proof-label or target override. Each factory call validates
the fixed source/header/tool/helper/target/link-manifest input identities,
recompiles GAME in a new child, and replays the complete448-byte CODE prefix,
48-byte inittimer interval/4fixups and864-byte DATA projection. TimerPtr's actual
operand and source offset derive DATA3:29560. The complete supplied10.5 matherr
member independently verifies295 initialized bytes/19fixups; its CONST2 ends
at that boundary. The released manifest names GAME first. This is a candidate
logical DATA layout coordinate, not a complete historical link-order claim.
The immutable input manifest includes exact header file sets, including unused
headers which could change native frontend context. Pin updates require review.

Inputs and the actual emulator identity are rechecked after replay. Generated
source, staged headers, unmodified OBJ/log, semantic witness and per-run producer
hash receipts remain in that child. The context's stable fingerprint binds the
input identities, policy and semantic witness results; timestamped raw native
objects are per-run receipts. A subsequent replay detects disk source changes.
Consumption checks the actual target bytes in memory and does not read files.

Contexts are opaque immutable identity tokens registered in the issuing Python
process. JSON reports, equal-looking objects, copies, deserialization and direct
construction cannot authorize verification. A context is reusable, but must
match exactly one nonempty segment in each invocation. Duplicate, extraneous or
ambiguous contexts reject. This is an internal correctness contract, not a
sandbox against arbitrary Python replacing private functions or registries.

Only standard OMF, use32 PUBLIC combine2 initialized DATA is supported, with
exact raw name/class and one unambiguous named group membership. PRIVATE,
COMMON, other PUBLIC encodings, BSS, CODE and Easy OMF cannot use the context.
The context and contribution must share a bounded LE object; its origin must
precede the contribution. Only the alignment equation becomes
`(contribution_start - issued_origin) % alignment == 0`. Unmatched segments use
the original absolute equation. No SEGDEF or LE metadata is changed.

DGROUP frame origins remain separate and explicitly validated. Every byte,
fixup, loader entry, public binding, overlap, range and BSS obligation still
passes the original verifier. Expected source export scope remains the
producer's responsibility. No VID/GF1 production producer uses this path yet,
and this feature awards zero source credit. Existing source CODE/BSS/IRQ
failures remain open; whole executable reconstruction is unachieved.

Run the focused native tests with:

```sh
python3 -m unittest tests.test_logical_segment_origins -v
```

The fixture issuer is private test code, independent of the target factory.
It validates retained native MAP/OBJ/EXE receipts, MAIN's actual marker operand,
the first definition and execution before issuing an own-fixture context.
Wrong same-phase origins are compared to that measured witness and rejected.

ROOT integration after TOKENLIB registration refreshes only the closed
`tools/prove_module.py` input digest and the manifest identity. Fresh native
replay preserves all semantic witnesses and issues fingerprint
`55b5d1b07dbf314ddcd0576c0deb67cd2c7e1c4d3a424f1474e74e880dd7d8a6`.
The 85-test integration suite passes, including existing standalone SCRIPLIB
and TOKENLIB producer graphs. All 133 supplied-runtime component dictionaries
and totals remain unchanged. This verifier correction adds zero source credit.

GF1WAVE registration refreshes the same single helper pin. The new factory
fingerprint is `8c05446e00d2a7b207162d3a3aa504a38e87732a28da4d487bd833ea95470f34`;
all seven semantic witness dictionaries remain exact. The 19 focused native
origin tests pass after that refresh. Neither registration changes the origin.

MEM registration and its raw-inventory helper refresh the same single closed
prove_module input pin. Fresh factory fingerprint:
`7ad735afcfacd1f3d4f580b6a11e94f63d423e59e479a9a6b2795a2caf863613`.
All seven semantic witnesses remain exact and the 19 focused tests pass. The
memory producer itself uses the original strict gate without an origin context.
