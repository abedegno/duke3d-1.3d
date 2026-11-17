# Late MACT TASK_MAN ordinary-C source

This is the later physical TASK_MAN contribution in MACT386.LIB, not the
separate earlier audio TASK_MAN owner. The ordinary C is the exact reviewed
Task475/489 reconstruction from released Apogee/James Dose source and authentic
extras APIs. Original older MACT C spelling is not claimed found. The original
GPL notice remains in task_man.c and the released GPL text is retained here.

The native version has no later LOCKMEMORY/USRHOOKS branch and directly uses
SafeMalloc/SafeFree. It services an eligible task once per interrupt, preserving
the earlier commented `if` behavior rather than the later repeated `while`.
The actually used Startup status variable remains declared. Exact released
interrupt flag pragmas remain inlined, as established by native source context.

The five live released extras headers are explicit source inputs. Watcom10.5
compiler identity1b97a68f… and the fixed /omaxnet /zp4 /5r profile produce all
1171CODE+20DATA+42BSS and82fields. Task is32bytes; the real six-byte old far
handler naturally follows at BSS36, with compiler-owned allocation padding.
There is no invented field, aggregate, gap owner, alias or ASM companion.

Six actual late global definitions remain global; all13 real private names
remain source-local LPUB/LEXT identities. The late public TS_InInterrupt has a
physical DATA definition while its two actual references select the earlier
audio global. The default whole verifier must continue rejecting that public
conflict. A separate module-specific physical/selected-reference ledger verifies
all complete source/original bytes and fields without changing generic rules.
This normal source capsule claims zero accepted credit until controller review;
it does not prove whole executable layout or historical source identity.
