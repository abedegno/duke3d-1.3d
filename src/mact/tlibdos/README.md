# Reconstructed TLIBDOS clock source

The complete symbolic module preserves all three original public functions and
two original public32-bit BSS counters. It is a readable reconstruction, not a
historical ASM discovery. The mathematical ordinary C counterpart and complete
released TYPES/TIMELIB copyright/GPL notices/text remain beside it. Earlier GA
C326-byte output is a strict register/scheduling negative, not a missing3-byte
tail; no C/name/type/flag grid is part of this package.

DOS time is hour/minute/second/hundredths, four bytes. CLOCK_VALUE is the real
clock operation inlined into all three bodies: hours*3600000 + minutes*60000 +
seconds*1000 + hundredths*10. RETURN_CLOCK restores the real frame/registers.
Time is milliseconds since midnight, and subtraction intentionally does not
correct midnight wrap. I_Time remains a genuine public definition even though
the other bodies inline it. The visible inert LEA/NOP preserve actual compiler
entry tails. No byte payload, alias, private promotion or fake storage exists.

The separate reviewed471 ELF profile retains genuine CODE/BSS PARA16 and empty
CONST/CONST2/DATA DWORD4, all five globals and six fields. Two source-folded ABS
constants and a structural FILE symbol are distinguished from zero private
runtime definitions. All three imports are actually referenced: DOS gettime
and same-name start/stop BSS globals. Converter482 is not used or required.
Original FLAT frame metadata versus source F5 and math387r/emu387 defaults
versus absent GNU comments are explicit differences, not raw object identity.
The original libraries remain future normal link-recipe obligations.

Source production stages only tracked ASM/C aid/headers/notices, checks initial
source/stage pins through source preflight and native steps, then closes raw ELF,
native OMF and all six roles. There is no Python source generation or hash
recapture. Source preflight side effects are rejected before GAS; compiler macro
expansion is part of the actual assembler. Admission/role checks use explicit
ValueError guards and remain active under python -O.

Only afterward do fresh actual source nominations and unchanged whole original/
source gates determine placement; no fixed target anchor or invented caller is
supplied. The accepted full stock gtime386 component independently verifies the
real DOS import. Standalone production needs no SDK/image/caller receipt. Source
credit, complete final link/layout and C humanization remain ROOT-owned.

Use make proof-mact-tlibdos (GNU_ELF_OMF_HOME may select another exact local home)
or tools/probe_mact_tlibdos.py with explicit --build/--report/--source-only.
The public source toolchain setup/build recipe is profiles/gnu_elf_omf/README.md.
