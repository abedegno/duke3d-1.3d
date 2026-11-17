# MACT timing, precision and joystick assembly

These three files reconstruct ordinary mnemonic assembly for the `pent.asm`,
`precise.asm` and `joystick.asm` members of the pinned private `MACT386.LIB`.
No original assembly text is supplied by the reconstruction repository. The
original object members are reference inputs only; native WASM generates every
accepted source contribution. [Provenance](../../evidence/mact-asm-source-reference.json)
records the library, member, source, seed and assembler identities.

Original MACT authorship/copyright and the assembly-source license remain
unresolved. These reconstructions are not relabelled GPL and remain private.
No external publication or distribution is authorized by this recovery work.
The inferred private variable names are `previous_high`, `previous_low` and
`control_word`; exported names and offsets come from the original PUBDEFs.

`pent.asm` preserves EAX/EDX around RDTSC. Start records the counter halves;
Stop subtracts the earlier low half with borrow into the high half, then stores
the elapsed halves. `precise.asm` clears pending x87 exceptions and updates
only precision-control bits 8–9: High selects extended precision and Low
selects single precision. `joystick.asm` charges the game-port timers at 201h,
counts selected active axis bits, and stops when they clear or the counter
reaches 5000. Its mask operation is AND. The original register/axis mapping
and interrupt/flags sequence are preserved.

The source retains three original segment definitions: empty `_TEXT` WORD
PUBLIC USE32 class `CODE`; `_DATA` WORD PUBLIC USE32 class `DATA`; and `TEXT`
PARA PRIVATE USE32 with an empty class. Their SEGDEF attributes are 73, 73 and
97. The instruction-bearing `TEXT` occupies LE object 2, which is data flagged.
It must not be reclassified as CODE or counted toward object 1 CODE coverage.
WORD alignment is necessary for the joystick scalar segment at offset 67966.

Run the strict native source route with the pinned Watcom GA DOS toolchain:

```sh
python3 tools/probe_mact_asm.py --build build/mact-asm-native \
  --report evidence/mact-asm-progress.json
python3 -m unittest tests.test_mact_asm_recovery -v
```

The wrapper executes the constant command `wasm.exe SOURCE.ASM -fo=OUT.OBJ`
in a fresh private DOS stage via the existing runner. It checks assembler
identity before and after assembly, input identity, STATUS, nonempty OUT.OBJ
and OMF parseability before publishing output. It captures assembler and error
logs and rejects nonempty error output; it does not require a nonempty assembler
log. RDTSC is
assembled using `.586`, and precision instructions additionally require `.387`.
This is a verified native production path, not identification of the original
assembler. No includes, binary emission, instruction-byte arrays or aliases
supply the code. DD/DW/DB zero declarations express only the actual timing,
precision and axis variables.

The measured descriptor route checks all three source segment names, classes,
attributes and extents plus the exact public set and offsets. It then calls
the unchanged whole-module verifier at one placement per segment, including
all fixups. The original archive is parsed with the existing strict library
reader and its three complete member gates are recorded separately as reference
proofs with zero source credit.

The native gates cover 72 initialized bytes/six fixups for PENT, 63/seven for
PRECISE, and 110/five for JOYSTICK, with no BSS. Together these are 210 actual
instruction bytes in object 2 at [0,56), [64,125), [128,221), and 35 initialized
scalar bytes in object 3 at [67936,67952), [67964,67966), [67966,67983).
The 11 intervening instruction-segment alignment bytes are unowned and excluded.
Every byte and fixup is compared without masks. Tests reject semantic assembly
mutants, altered tails/relocations, omitted exports, geometry/binding changes,
input races, wrong assembler identity and malformed or changed archives.

These are three complete member contributions. They do not complete MACT,
link the game, or establish whole-executable identity.

## Math utilities

`mathutil.c` reconstructs the complete four-function527-byte contribution at
LE object1:566176. It has no initialized non-CODE storage, BSS or relocations.
`make proof-mact-mathutil` uses the ordinary fixed-descriptor native source
route; every byte, function public and local/global scope must agree.

Related primary source is the preserved official Rise of the Triad release:
[release index](https://ftpmirror.infania.net/pub/3drealms/downloads/Downloads.html),
[source archive](https://ftpmirror.infania.net/pub/3drealms/source/rottsource.zip).
The immutable archive/source/header hashes and precise derivations are in
[mact-mathutil-source-reference.json](https://github.com/abedegno/duke3d-1.3d/blob/e8b2c6788674fa82f74213ccb9afd56ffc4ae3e1/evidence/mact-mathutil-source-reference.json).
These files retain their GPL notices; the two private headers are unchanged
ROTT originals. This does not assert that the historical MACT source text was
released or that its original private names have been recovered.

The ordinary two-dimensional approximation restores exact axis-zero returns;
the three-dimensional approximation and octant arctangent derive from related
ROTT algorithms. The high-precision distance scales inputs, assigns each
rounded fixed product, applies the preserved fixed-square-root pragma and
rescales the result. The primary fixed multiply/divide/sqrt pragmas contain
normal mnemonic instructions; no instruction bytes were generated from the
reference binary. Native compiler output supplies the contribution.

Private source experiments are discovery history, not build inputs. The first
related-source body omitted two real axis cases. A combined product expression
also selected a shorter LEA; explicit named C product assignments reproduce the
native scheduling. The production build depends only on tracked source/private
headers and the pinned compiler. Original MACT objects remain reference-only.
Independent review and the combined 204-test project run approved this source
contribution. Whole MACT and the game remain unfinished.

## Keyboard

`keyboard.c` is an ordinary C reconstruction of all thirteen native keyboard
functions, with616 CODE,594 CONST,696 DATA and397 unbacked BSS bytes and171
fixups. `make proof-mact-keyboard` uses the fixed-descriptor route. Every public,
including eight private data/state symbols, retains its measured scope. Original
SDK objects are not build inputs. This route remains subject to independent
review; it does not complete MACT, final linking or executable identity.

The released keyboard/type headers are retained unchanged under `keyboard/`.
ROTT's preserved GPL ISR.C supplies related ASCII maps; the source preserves
its copyright/license notice. Native behavior supplies the queue policy, the
keypad decimal/slash/enter differences, exact logical key labels and startup
message. Explicit additional NULs in real label literals express measured zero
alignment bytes, following the existing MACT convention, without claiming
historical source spelling. The private keypad state's volatile qualification
is inferred from its shared event role and measured native ordering.

The actual label table has109 pointers although the native/public lookup bound
is110. This observed one-past-table condition is documented and preserved;
there is no invented entry or silent boundary repair. Prototype negatives and
provenance are recorded in
[mact-keyboard-source-reference.json](../../evidence/mact-keyboard-source-reference.json).
