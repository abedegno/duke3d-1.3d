# Alignment-preserving ZONE source producer

This opt-in mode uses the existing tracked symbolic source and existing
ZONE mechanical syntax port. It translates only section declarations to ELF
syntax with explicit original CODE/BSS alignment16 and CONST/DATA alignment4.
All instructions, labels, public/private identities, expressions and runtime
storage remain unchanged. The existing COFF producer remains available.

The source-specific ELF contract comes from the reviewed task505 experiment.
Its checks use explicit exceptions so Python -O cannot remove them.
Production reads no target, original object or ignored experiment file.
This mode alone proves neither historical C recovery nor whole EXE identity.
The parent zone/GPL-2.0.txt notice and existing C counterpart remain applicable.
