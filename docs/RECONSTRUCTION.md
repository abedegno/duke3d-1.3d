# Reconstruction notes

The target is the registered DOS v1.3D `DUKE3D.EXE`, not the v1.5 Atomic Edition executable. The released v1.5 source and pinned historical reconstructions supplied names, interfaces and algorithms. Iterative compilation and native executable analysis established earlier-version behaviour, compiler choices, exact library contributions and layout.

The final comparison covers the complete bound executable. Its three loaded objects, relocation records, page boundaries, entry/stack values, headers, alignment and container bytes reproduce the target. The source-built converter emits declared record spans from fresh source compilation outputs; no generated instruction or executable patch supplies the match.

Many modules compile from ordinary C or historical assembly. Matching symbolic backends retain named procedures, operand ownership, true public/private scope, C counterparts where available, and complete field contracts. These are maintainable reconstruction sources, not a claim to uniquely recover the original C spelling. Further compiler-faithful C lowering is documented as optional work.

The readable-source pass includes indexes for all 81 GAME functions and all 37 ACTORS functions. Existing default producers and negative experiments are retained for comparison. The release's `make rebuild` target selects the verified exact route.

Unidentified initialized data is explicit: a 96-byte region, a two-byte GF1 pair, and seven bytes after existing string terminators. Historical declarations or meanings are not fabricated. These values add no historical-source credit merely by matching.

Stock compiler-library members and the supplied DOS4GW prefix retain their identity as dependencies. They are not presented as newly recovered game source. Original notices remain in their component files. Vendor-derived source with unresolved redistribution restrictions is separated into a local-only overlay.

The evidence directory preserves intermediate research records. Paths, experiment names and historical incomplete statuses in those records describe their original checkpoint. The release-level identity and public snapshot are recorded separately under `verification/`.
