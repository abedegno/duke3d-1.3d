# Finite DIGITAL source profile

Uses the existing unmodified pinned GNU2.44/objconv2.57 and Capstone homes. The
shared hardware/NRPN/SBK profiles and default OMF/helper semantics are unchanged.

The exact4997-byte CODE extent uses documented GNU COFF section flag `xr0` and
`-no-pad-sections`. Source CODE is genuinely BYTE-aligned (native SEGDEF41), BSS
DWORD-aligned (169); original PARA requirements are independently checked by the
complete original target gate. No output padding is trimmed or repaired.

Every source line, all4997serialized instruction bytes/7076uninitialized BSS,
all146labels/133private COFF definitions/53ABS constants and13original private
identities are retained. The original234field roles are198actual native fields
plus36real resolved same-module calls, including42private operand edges. Scope,
private availability and section+V math are proved without injecting private
caller anchors or exporting aliases. All unknown header/aux/record semantics
are rejected. BSS has no serialized payload. This is not general COFF support.

Actual no-op instructions are readable mnemonic lines; selector/forward-constant
source contexts are documented in the source lineage. No encoded arrays, ORG,
macro opcode emitter, metadata rewrite or target-reading producer is involved.
