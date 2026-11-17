# Opt-in source-native record layouts

These 22 files declare only CODE-section extent and contiguous LEDATA spans.
They contain no instruction bytes, target addresses, relocation order or loader
values. The normal source producer runs first. `tools/build_native_layout.py`
then converts that same newly produced ELF/COFF with the separately pinned
`gnu_elf_omf_layouts` home. An old OMF object is never converter input.

The ordinary source build remains the default. `--native-layout` selects these
layouts, the complete single ACTORS source compiland (replacing O001/O002), and
the reviewed DRAM ELF backend. This yields 121 owned objects, 177 supplied stock
objects, one declared DATA object and five supplied libraries. Stock runtime and
vendor binding bytes receive no recovered-source credit.

The common contract compares every parsed native property literally with the
fresh default object, including all section bytes, typed fields, public/private
coordinates, imports, groups and libraries. Only the packet-relative low ten
LOCAT bits may change. Each field must fit wholly inside its declared span.
Live source receipts, copied plans, the complete converter home and outputs are
checked through receipt publication. Invalid builds do not publish a receipt.

## Provenance and limits

The catalog records each plan's exact hash and development evidence origin.
Most layouts were transcribed from original native record boundaries during
Task624; HARDWARE and DRAM retain the corresponding Tasks615/636 observations.
IRQ and DMA derive from fresh source-compiler metadata. GAME's Task619 plan is a
nonunique source-owned reconstruction of emission boundaries; no claim is made
that it recovers the historical compiler's internal flush decisions. These
observations authored the tracked metadata; the build reads none of the
research objects, reports or target executable.

IRQ requires the reviewed directive-only NASM ELF form: five actual section
declarations change, all instruction/data/label statements remain identical,
and genuine DGROUP/FLAT declarations accompany conversion. The finite projection
checks its complete 102 relocation roles plus one resolved private call, all
private coordinates and all nonfield bytes. The NASM default remains available.
DRAM's separately guarded source backend provides its genuine full ELF roles.
All source-specific default guards remain in force before common conversion.

A whole-file claim additionally requires the actual ordered WLINK and pinned
vendor-prefix binding. Seven GAME CONST bytes remain source zeros pending
explicit preservation authorization; this option makes no target identity or
new source-coverage claim.
