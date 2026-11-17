"""Exact separate two-file source fork; never patches binaries or native objects."""
from pathlib import Path
def apply(new):
    new = Path(new)
    p = new / 'omf.h'
    a = p.read_bytes()
    needle = b'   uint32_t NewIndex;                    // PUBDEF index if Scope = 1, EXTDEF index if scope = 2\r\n'
    assert a.count(needle) == 1
    a = a.replace(needle, needle + b'   uint32_t ExternalIndex;               // Fork455: independent EXTDEF identity for referenced globals\r\n')
    p.write_bytes(a)
    p = new / 'cof2omf.cpp'
    a = p.read_bytes()
    needle = b'            SymbolBuffer[isym].NewIndex = ++NumExternalSymbols;  // External symbol number\r\n'
    assert a.count(needle) == 1
    a = a.replace(needle, needle + b'            SymbolBuffer[isym].ExternalIndex = SymbolBuffer[isym].NewIndex;\r\n')
    needle = b'         if (Symtab.p->s.SectionNumber > 0) {\r\n            // Local\r\n'
    assert a.count(needle) == 1
    a = a.replace(needle, b'         if (Symtab.p->s.SectionNumber > 0 && Symtab.p->s.StorageClass == COFF_CLASS_EXTERNAL) {\r\n            // Fork455: a defined global still has linker-selected identity.\r\n            // PUBDEF retains section+Value; EXTDEF supplies that full address.\r\n            // Do not add Value again to the relocation displacement.\r\n            if (!SymbolBuffer[isym].ExternalIndex) {\r\n               SymbolBuffer[isym].ExternalIndex = ++NumExternalSymbols;\r\n            }\r\n            NewRel.Scope = S_EXTERNAL;\r\n            NewRel.TargetOffset = 0;\r\n            NewRel.TargetSegment = SymbolBuffer[isym].ExternalIndex;\r\n         }\r\n         else if (Symtab.p->s.SectionNumber > 0) {\r\n            // Local\r\n')
    needle = b'      for (j = 0; j < SymbolBuffer.GetNumEntries(); j++) {\r\n         if (SymbolBuffer[j].Scope == S_EXTERNAL && SymbolBuffer[j].NewIndex == ExtSymNum+1) {\r\n'
    assert a.count(needle) == 1
    a = a.replace(needle, b'      for (uint32_t desired = 1; desired <= NumExternalSymbols; desired++)\r\n      for (j = 0; j < SymbolBuffer.GetNumEntries(); j++) {\r\n         if (SymbolBuffer[j].ExternalIndex == desired) {\r\n')
    p.write_bytes(a)
