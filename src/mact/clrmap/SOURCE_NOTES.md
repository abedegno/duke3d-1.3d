# CLRMAP semantic source reconstruction

This is reconstructed source, not recovered historical CLRMAP.C/ASM. Complete
released 3D Realms GPL notices/types/APIs remain unmodified in include/. The
ordinary C body is the single measured GA baseline, kept with its strict
negative rather than presented as byte-identical or portable-x87 equivalence.

Actual legacy behaviors include mutating HSV hue during conversion, the LUV
input-L correction without recomputing prior Y, exclusive-high YIQ filling,
perceptual map parameters ignored despite the richer public API, unclamped
intensity endpoints and two actual leaked float-palette allocations. None is
repaired. HSV's six real switch targets are typed `.long` objects accessed by
the actual CS-qualified indirect jump, not decoded as instructions.

Named binary64 scalar objects follow the actual color arithmetic, including
source/compiler pool repetitions. Matrix and whitepoint coefficients/precision
are recovered scalar observations. EGA DATA is the sixteen named logical color
triples using actual levels0/87/171/255; it is not a packed target-segment blob.
The six meaningful scalar bit views emit named32-bit LO/HI constants: each is
one exact word of its declared binary64 value, so every ELF32 ABS identity is
truthful without relying on overflow/truncation of a64-bit ELF32 symbol. No ABS
relocation exists. CODE has only actual mnemonics and the six typed case words;
DATA byte declarations are actual color components. BSS is the real16 index owner.

Genuine i386 plus387 instructions require the documented `-march=i386+387`
feature. Three real accumulator squares use documented `{store}` direction
selection; no object/instruction patch or opcode directive is used. Quoted
`IF@DPOW` retains its exact runtime symbol name. The three unused original FPU
linker requirements remain genuine GLOBAL/UND declarations; no fake relocation
is introduced. Old converter import stripping remains an explicit preserved negative.
The current private producer explicitly selects separately reviewed482/483
source-fork identity36d4106f; it does not replace the shared455/profile471 tool. Shared tool homes/profiles and generic helpers remain unchanged.

The one-time native transcription/CFG aid is authoring evidence only, never
imported/executed by native production. Actual source builds consume static ASM,
named mathematical model, C/header aid and pinned tools only. SDK, target,
disassembly/native baselines and caller records are observation inputs only.
