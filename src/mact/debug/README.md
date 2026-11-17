# Complete MACT DEBUG reconstruction

This is authored readable symbolic source, with a complete ordinary C aid. It
is not recovered historical C. The primary released DEBUG.H/_DEBUG.H API,
output_t, types, constants, and GPL notices are preserved whole. The unrelated
released RBG DEBUG.C is explicitly excluded; the bounded local/JFMact/ROTT and
public search did not supply the MACT implementation.

The original twenty CODE functions are all public, including four output
helpers. Eight genuine state objects are private: level, mode, 21-element
DWORD mask, Started, output mode, FileStarted, four output_t triples, and a BSS
file handle. The four callback addresses refer to the actual public helpers,
never aliases. GNU folds these to CODE-section+offset relocations; the private
states/labels remain qualified true COFF C_STAT definitions. No target-private
name becomes an anchor or runtime export.

Native suppression differs from the apparent header intent: mode zero uses
mask[level] as the suppression predicate; nonzero suppresses level<=DebugLevel.
The ordinary C aid preserves that value rule. Symbolic source additionally
preserves boolean materialization, exact partial-register/stack schedule,
ES/DF string scanning and the original register ABI. The two formatting APIs
are CDECL; printf/Error are CDECL while the other calls use Watcom register
parameters. The 404-byte frame is a 400-byte buffer plus va_list slot.

Legacy limits are retained, not repaired: vsprintf precedes the length check;
Error is called for length>=400 and for length399 when appending newline;
empty strings read one byte before the buffer; indices/callback modes are
unchecked. Callback fields are re-read in the native schedule. Thus the C aid
is not a safe modern API implementation and has no general language-level
proof for invalid caller inputs.

Initialized data is named logical state and four output_t records, not packed
payload: default level5, remaining scalars zero, 21 zero masks, actual four
handler pointers and null remaining slots. Six real lexical string objects
are emitted, with normal4-byte literal alignment for the first two. The four
identical overflow messages belong to distinct call sites. Source lines split
long literals only so GNU's default listing limit retains every byte for the
closed source/listing audit; neither output object nor semantic value changes.

The whole original has79 fixups; source-native has76. The three missing native
records are resolved calls to public DBG_CloseDebugOutput_ (twice) and
DBG_StartDebugOutput_ (once). scope_roles.py checks every original target equation,
all76 native fields, these three exact named CALL targets, and all eight
original private state identities/coordinates/reference roles. No raw LPUB
record identity is claimed or required; scope is proven via true nonPUBLIC
source definitions and the complete source/COFF/native identity receipt.

Humanization backlog: practical all-C exact compilation remains negative only
for the two formatter bodies (228/220 versus240/240 bytes);18 other full
function intervals and complete data geometry match the original. Symbolic
source retains explicit ordinary no-op tails and native boolean/vararg
scheduling. No decoder-output instruction generator, opcode arrays, ORG,
custom object writer, record repair or target-driven converter is used.

Normal route: symbolic source with complete ordinary C aid; source credit0 in capsule. Primary released repository videogamepreservation/dukenukem3d, commit ef609159bd352985a0c63734a11241d86c873fe5. See tracked source-reference evidence for exact whole-header lineage and baseline negative. No original payload is a producer input.
