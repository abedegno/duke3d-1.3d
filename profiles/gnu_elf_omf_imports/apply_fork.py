"""Exact separate three-file cumulative source fork455+482; never patches binaries or native objects."""
from pathlib import Path
def apply(new):
    new = Path(new)
    from profiles.gnu_elf_omf_imports.identity import profile,digest
    spec=profile()['converter_fork']
    if not new.is_dir() or {p.name:digest(p) for p in new.iterdir() if p.is_file()} != spec['original_source_files'] or any(not p.is_file() or p.is_symlink() for p in new.iterdir()):
        raise ValueError('exact original42-source set required before source fork')
    p = new / 'omf.h'
    a = p.read_bytes()
    needle = b'   uint32_t NewIndex;                    // PUBDEF index if Scope = 1, EXTDEF index if scope = 2\r\n'
    if a.count(needle) != 1: raise ValueError('source patch context changed')
    a = a.replace(needle, needle + b'   uint32_t ExternalIndex;               // Fork455: independent EXTDEF identity for referenced globals\r\n')
    p.write_bytes(a)
    p = new / 'cof2omf.cpp'
    a = p.read_bytes()
    needle = b'            SymbolBuffer[isym].NewIndex = ++NumExternalSymbols;  // External symbol number\r\n'
    if a.count(needle) != 1: raise ValueError('source patch context changed')
    a = a.replace(needle, needle + b'            SymbolBuffer[isym].ExternalIndex = SymbolBuffer[isym].NewIndex;\r\n')
    needle = b'         if (Symtab.p->s.SectionNumber > 0) {\r\n            // Local\r\n'
    if a.count(needle) != 1: raise ValueError('source patch context changed')
    a = a.replace(needle, b'         if (Symtab.p->s.SectionNumber > 0 && Symtab.p->s.StorageClass == COFF_CLASS_EXTERNAL) {\r\n            // Fork455: a defined global still has linker-selected identity.\r\n            // PUBDEF retains section+Value; EXTDEF supplies that full address.\r\n            // Do not add Value again to the relocation displacement.\r\n            if (!SymbolBuffer[isym].ExternalIndex) {\r\n               SymbolBuffer[isym].ExternalIndex = ++NumExternalSymbols;\r\n            }\r\n            NewRel.Scope = S_EXTERNAL;\r\n            NewRel.TargetOffset = 0;\r\n            NewRel.TargetSegment = SymbolBuffer[isym].ExternalIndex;\r\n         }\r\n         else if (Symtab.p->s.SectionNumber > 0) {\r\n            // Local\r\n')
    needle = b'      for (j = 0; j < SymbolBuffer.GetNumEntries(); j++) {\r\n         if (SymbolBuffer[j].Scope == S_EXTERNAL && SymbolBuffer[j].NewIndex == ExtSymNum+1) {\r\n'
    if a.count(needle) != 1: raise ValueError('source patch context changed')
    a = a.replace(needle, b'      for (uint32_t desired = 1; desired <= NumExternalSymbols; desired++)\r\n      for (j = 0; j < SymbolBuffer.GetNumEntries(); j++) {\r\n         if (SymbolBuffer[j].ExternalIndex == desired) {\r\n')
    p.write_bytes(a)
    p = new / 'elf2cof.cpp'
    a = p.read_bytes()
    needle = b'   // Pointer to new symbol table\r\n'
    # Restrict the unique context to the actual HideUnusedSymbols function.
    start = a.index(b'void CELF2COF<ELFSTRUCTURES>::HideUnusedSymbols()')
    before, tail = a[:start], a[start:]
    if tail.count(needle) != 1: raise ValueError('unused-import source patch context changed')
    addition = b'   // Strip options alone must not erase intentional undefined imports.\r\n   // Preserve the old hiding policy only when a section was actually removed.\r\n   bool sectionsRemoved = false;\r\n   for (uint32_t section = 0; section < this->NSections; section++) {\r\n      if (this->SectionHeaders[section].sh_type == SHT_REMOVE_ME) {\r\n         sectionsRemoved = true;\r\n         break;\r\n      }\r\n   }\r\n   if (!sectionsRemoved) return;\r\n\r\n'
    p.write_bytes(before + tail.replace(needle, addition + needle))
    if {p.name:digest(p) for p in new.iterdir()} != spec['derived_source_files']:
        raise ValueError('derived42-source fork identity')
