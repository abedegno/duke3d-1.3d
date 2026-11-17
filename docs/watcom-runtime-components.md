# Supplied original Watcom runtime components

The fixed inventory proves133 complete unmodified stock members from the installed
Watcom10.0 GA and10.5 C/math libraries. These are supplied compiler dependencies,
not reconstructed game/SDK output or rebuilt-source credit. Historical final
library/member selection, layout/order and whole-file executable identity remain
unproved. No object, instruction or executable payload is emitted.

The original57 component dictionaries are preserved exactly. The extension adds
74 whole10.5 members from a strict stock survey and two tiny complete members
independently nominated through the actual math-error callback chain. The76 new
members contribute22,766CODE bytes,23,518 initialized bytes,268BSS bytes and566
fixups, with no overlap with current accepted source ranges. No partial carving
was used. Ten-point-six discovery passes are not selected dependencies.

## Immutable inputs and replay

Target: reference/DUKE3D.EXE,1,179,131 bytes, SHA256
`a197b6b4097fa39987f4a843141830ff1553eb52b606b51fc67d067560de0cf4`.

| Supplied original library | Bytes | SHA256 |
| --- | ---: | --- |
| `toolchains/watcom-10.0-ga/LIB386/DOS/clib3r.lib` | 187904 | `6f250d0e791ba05c6857d57de1ac5e65b6a5db7cb390a7e8f48035e5a4bd4363` |
| `toolchains/watcom-10.0-ga/LIB386/math387r.lib` | 40960 | `ccc96d4aa29c2c798da9c57a085e02614e88739b46cd1c47609fd39c5c8647c9` |
| `toolchains/watcom-10.5/LIB386/DOS/clib3r.lib` | 260096 | `151fc7d895b171145466f77b1624d27952fa631971b0fc33d479e02eda3bbcc8` |
| `toolchains/watcom-10.5/LIB386/math387r.lib` | 48640 | `14c1fde264b0488c4df68aa3c8ca5291857216c6ac3a08f16f505f3d746291c0` |

Every immutable archive/member identity, physical extent and checksum is checked.
Fixed specifications in tools/inventory_watcom_runtime.py and
[watcom_runtime_105.py](../tools/watcom_runtime_105.py) nominate whole members;
`infer_bindings`, the complete unchanged `native_gate`/`verify_module`, explicit
measured group frames and scoped anchors then decide acceptance. CODE, non-CODE
storage, BSS, all aliases, locals and every fixup remain checked. Generic parser,
matcher and inference semantics are unchanged; unsupported semantic records remain
errors. No debug projection or acceptance based on a search anchor is used.

```sh
python3 -m unittest tests.test_watcom_runtime_inventory \
  tests.test_watcom_runtime_pointer tests.test_watcom_runtime_extension -v
python3 tools/inventory_watcom_runtime.py \
  --accepted-ranges /Users/jonw/duke3d/build/parallel-integrated-range-audit.json \
  --report build/watcom-runtime-inventory/replay.json
```

The accepted-range audit is diagnostic overlap arithmetic only. The evidence
records its exact path/hash; replay with that same input preserves the complete
old57 dictionaries. The only source overlap is independently source-built RAND:
58CODE and4DATA bytes are always subtracted, even if an audit omits RAND.

Task170 scanned2,212 members in nine unique installed libraries (six duplicate
files excluded), finding357 strict whole-member passes. Fixed identities for74
nonoverlapping10.5 members and the two measured callback dependencies are recorded
with their discovery hashes. The private survey/selection files are not needed
for production replay and confer no acceptance. This inventory does not imply
that10.5 is the unique historical producer or that unselected members pass.

## One finite DATA pointer nomination

The immutable10.5 `_matherr` member has an independently placed global
`__RWD_matherr` at DATA3:73156. Its original `_DATA` segment is exactly4bytes,
with one absolute width4/location9,F5/T2 pointer at0, displacement0 and raw addend0,
targeting the global external `__matherr`. The measured unique native LE type7,
non-alias4byte entry points to CODE1:626184. All four native source bytes must be
file-backed and retain their original pointer field. Wrong kinds/geometry,
ambiguous/missing entries, changed scopes, addends or conflicting bindings reject.
The nomination supplies only the external binding; it awards no callee source
credit and cannot accept the member on its own.

The complete unchanged native gate subsequently proves all295 initialized bytes
and19fixups of `_matherr`. `_Msgs` remains local. The actual imported callback is
a separate supplied `__mtherr` archive member: its complete5CODE bytes/one real JMP
fixup independently bind `matherr_` at CODE1:626416. The complete provided `matherr`
member proves3CODE bytes/zero fixups there. These are real vendor functions from
the pinned archive, not synthesized linker stubs. Provenance and the actual
inferred constraints are retained per component. Full CODE/CONST/tail/callee,
priority, pointer-kind/addend/scope/conflict controls remain strict.

## Verified supplied contribution accounting

| Native member set | Members | CODE | DATA | BSS | Fixups |
| --- | ---: | ---: | ---: | ---: | ---: |
| `toolchains/watcom-10.0-ga/LIB386/DOS/clib3r.lib` | 48 | 4479 | 516 | 0 | 101 |
| `toolchains/watcom-10.0-ga/LIB386/math387r.lib` | 7 | 625 | 208 | 0 | 34 |
| `toolchains/watcom-10.5/LIB386/DOS/clib3r.lib` | 66 | 19693 | 530 | 268 | 504 |
| `toolchains/watcom-10.5/LIB386/math387r.lib` | 12 | 3248 | 222 | 0 | 73 |
| All selected members | 133 | 28045 | 1476 | 268 | 712 |
| Already source-built RAND overlap | 1 | 58 | 4 | 0 | 3 |
| Additional supplied extent after overlap | 132 | 27987 | 1472 | 268 | 709 |

**Rebuilt-source bytes added:0. Complete source contributions added:0.**
The accepted source contribution count and source CODE coverage do not
increase. These are target-object contributions, not EXE file coverage.

Each report preserves source_status='supplied original stock toolchain component',
rebuilt_source_credit0, complete native metadata, physical member/record hashes,
all placements/constraints/scopes and source-overlap diagnostics. The old rejected
seg386 representative remains a zero-credit diagnostic. No supplied SDK/game
prebuilt object is permitted through this runtime boundary.

A separate controlled Task172 diagnostic links the same84 retained source-built
objects with the original10.5 stock runtime libraries. Its83 unresolved names are
unchanged, with none added/resolved and no EXE. This supports dependency/ABI
compatibility only; it is not proof of historical library choice or final layout.

## Complete selected member extents

All intervals are decimal and half-open. Member extents stop at MODEND, excluding
page padding/dictionary. Full record/checksum/metadata and target ranges are in
[evidence/watcom-runtime-components.json](../evidence/watcom-runtime-components.json).

### toolchains/watcom-10.0-ga/LIB386/DOS/clib3r.lib

| Member | Archive offset:size | CODE nomination | Initialized | BSS | Fixups |
| --- | --- | ---: | ---: | ---: | ---: |
| `amodf386` | 16:425 | 605802 | 300 | 0 | 0 |
| `fdfs386` | 1328:188 | 609716 | 76 | 0 | 0 |
| `__stos` | 6048:286 | 589760 | 163 | 0 | 0 |
| `drive386` | 9200:179 | 592118 | 40 | 0 | 0 |
| `error386` | 9392:167 | 597694 | 19 | 0 | 1 |
| `file386` | 9568:226 | 589610 | 46 | 0 | 3 |
| `gtime386` | 10384:190 | 591168 | 53 | 0 | 0 |
| `io386` | 11808:203 | 589560 | 49 | 0 | 1 |
| `bits` | 23680:358 | 601171 | 70 | 0 | 2 |
| `cmp386` | 24496:273 | 586240 | 161 | 0 | 0 |
| `strcpy` | 33952:258 | 583173 | 31 | 0 | 0 |
| `strlen` | 36048:252 | 583305 | 25 | 0 | 0 |
| `strncmp` | 36880:270 | 587989 | 41 | 0 | 0 |
| `strncpy` | 37152:266 | 588106 | 37 | 0 | 0 |
| `strtok` | 39920:475 | 589392 | 153 | 0 | 6 |
| `chktty` | 41968:299 | 596578 | 49 | 0 | 1 |
| `flushall` | 47600:342 | 599742 | 52 | 0 | 2 |
| `fputc` | 49952:449 | 596361 | 164 | 0 | 4 |
| `iobaddr` | 58256:289 | 626189 | 31 | 0 | 1 |
| `iomode` | 58560:557 | 597587 | 194 | 0 | 7 |
| `rewind` | 64816:270 | 590513 | 23 | 0 | 1 |
| `cmain386` | 75200:440 | 596879 | 79 | 0 | 9 |
| `set386` | 111840:157 | 588144 | 24 | 0 | 1 |
| `div` | 114192:277 | 588530 | 56 | 0 | 0 |
| `rand` | 119472:390 | 583791 | 62 | 0 | 3 |
| `chint386` | 119872:144 | 590488 | 25 | 0 | 0 |
| `enterdb` | 120448:335 | 609677 | 39 | 0 | 1 |
| `inp` | 121232:229 | 589551 | 8 | 0 | 0 |
| `inpw` | 121472:232 | 589751 | 9 | 0 | 0 |
| `intxa386` | 122784:1131 | 599794 | 990 | 0 | 2 |
| `segread` | 125664:246 | 588281 | 40 | 0 | 0 |
| `memalloc` | 130480:569 | 597714 | 435 | 0 | 0 |
| `nmsize` | 137184:250 | 591250 | 9 | 0 | 0 |
| `filelen` | 141568:321 | 588856 | 61 | 0 | 3 |
| `tell` | 148112:260 | 596862 | 17 | 0 | 1 |
| `ini87386` | 150336:158 | 623308 | 39 | 0 | 0 |
| `accss` | 150768:322 | 592025 | 59 | 0 | 1 |
| `setenvp` | 159312:574 | 609465 | 212 | 0 | 11 |
| `itoa` | 163504:468 | 608548 | 138 | 0 | 2 |
| `getch` | 166752:279 | 584054 | 29 | 0 | 2 |
| `gtche` | 167040:280 | 609436 | 29 | 0 | 2 |
| `tolower` | 171872:258 | 583886 | 14 | 0 | 0 |
| `toupper` | 172144:258 | 583021 | 14 | 0 | 0 |
| `find386` | 9808:339 | 587502 | 130 | 0 | 4 |
| `strerror` | 34896:820 | 591021 | 408 | 0 | 18 |
| `vsprintf` | 40944:332 | 591044 | 40 | 0 | 2 |
| `inirt386` | 81536:415 | 596958 | 154 | 0 | 4 |
| `stk386` | 86368:440 | 590832 | 98 | 0 | 6 |

### toolchains/watcom-10.0-ga/LIB386/math387r.lib

| Member | Archive offset:size | CODE nomination | Initialized | BSS | Fixups |
| --- | --- | ---: | ---: | ---: | ---: |
| `fchop` | 8608:150 | 592158 | 29 | 0 | 0 |
| `frexp` | 9600:348 | 626305 | 111 | 0 | 0 |
| `log387` | 16928:342 | 625536 | 111 | 0 | 1 |
| `log87e` | 17280:329 | 626220 | 60 | 0 | 1 |
| `modf387` | 19232:163 | 626280 | 25 | 0 | 1 |
| `floor` | 8768:338 | 625647 | 68 | 0 | 2 |
| `math2err` | 17616:964 | 623887 | 429 | 0 | 29 |

### toolchains/watcom-10.5/LIB386/DOS/clib3r.lib

| Member | Archive offset:size | CODE nomination | Initialized | BSS | Fixups |
| --- | --- | ---: | ---: | ---: | ---: |
| `vprintf` | 73808:276 | 591233 | 17 | 0 | 2 |
| `nrealloc` | 196400:518 | 591259 | 158 | 0 | 9 |
| `dosret` | 7232:514 | 596114 | 144 | 0 | 4 |
| `d_getvec` | 8704:305 | 589701 | 50 | 0 | 1 |
| `d_setvec` | 9264:300 | 589656 | 45 | 0 | 1 |
| `intd386` | 11472:326 | 609358 | 78 | 0 | 1 |
| `clock` | 15856:505 | 599600 | 142 | 4 | 6 |
| `strchr` | 24400:243 | 588261 | 20 | 0 | 0 |
| `sprintf` | 33184:353 | 583238 | 67 | 0 | 2 |
| `sscanf` | 33552:475 | 590904 | 117 | 0 | 4 |
| `strcat` | 34032:274 | 583733 | 51 | 0 | 0 |
| `stricmp` | 36336:325 | 588168 | 71 | 0 | 0 |
| `strnicmp` | 38048:326 | 601234 | 83 | 0 | 0 |
| `strpbrk` | 38640:335 | 591094 | 74 | 0 | 2 |
| `strstr` | 40112:422 | 590641 | 190 | 0 | 0 |
| `efgfmt` | 41904:701 | 609792 | 360 | 0 | 3 |
| `fread` | 42608:810 | 588917 | 475 | 0 | 6 |
| `scnf` | 43424:4292 | 601351 | 3129 | 0 | 62 |
| `allocfp` | 47728:681 | 595532 | 253 | 0 | 16 |
| `fclose` | 48960:859 | 583330 | 323 | 0 | 15 |
| `fgetc` | 51296:763 | 600815 | 356 | 0 | 8 |
| `fgets` | 52608:346 | 590536 | 105 | 0 | 1 |
| `flush` | 52960:510 | 595791 | 217 | 0 | 3 |
| `fopen` | 53824:1303 | 584083 | 642 | 0 | 22 |
| `fprtf` | 55424:476 | 592546 | 144 | 0 | 5 |
| `fputs` | 56624:394 | 596238 | 123 | 0 | 3 |
| `fseek` | 57568:689 | 585173 | 318 | 0 | 9 |
| `ftell` | 58544:288 | 596008 | 48 | 0 | 1 |
| `fwrite` | 58832:814 | 584725 | 448 | 0 | 7 |
| `initfile` | 62112:545 | 608704 | 167 | 0 | 11 |
| `ioalloc` | 62672:382 | 596627 | 119 | 0 | 2 |
| `printf` | 65264:291 | 583204 | 34 | 0 | 2 |
| `prtf` | 65568:3721 | 592690 | 2841 | 0 | 20 |
| `puts` | 70048:312 | 583900 | 45 | 0 | 4 |
| `initargv` | 74096:881 | 597112 | 436 | 0 | 16 |
| `ioexit` | 74992:480 | 608823 | 105 | 0 | 6 |
| `atexit` | 77616:497 | 588375 | 115 | 132 | 8 |
| `chk8087` | 78128:630 | 605103 | 138 | 0 | 14 |
| `hook387` | 83504:755 | 623006 | 319 | 128 | 8 |
| `seterrno` | 87424:431 | 596526 | 52 | 0 | 3 |
| `fmemcpy` | 110720:266 | 588490 | 40 | 0 | 0 |
| `memcpy` | 112672:260 | 583849 | 37 | 0 | 0 |
| `min` | 121168:225 | 588848 | 8 | 0 | 0 |
| `int386` | 180656:288 | 588346 | 29 | 0 | 2 |
| `intx386` | 181168:274 | 588321 | 25 | 0 | 1 |
| `outp` | 182592:229 | 589541 | 10 | 0 | 0 |
| `outpw` | 182832:232 | 588586 | 11 | 0 | 0 |
| `nfree` | 185104:550 | 587859 | 130 | 4 | 9 |
| `grownear` | 186464:2493 | 598149 | 1448 | 0 | 49 |
| `nexpand` | 192448:1047 | 605241 | 560 | 0 | 13 |
| `nmalloc` | 195136:764 | 587632 | 239 | 0 | 12 |
| `sbrk386` | 196928:818 | 608955 | 403 | 0 | 16 |
| `open` | 198192:1075 | 586401 | 626 | 0 | 12 |
| `_clse` | 200400:320 | 596056 | 53 | 0 | 2 |
| `lseek` | 204032:331 | 588039 | 67 | 0 | 1 |
| `qread` | 205376:284 | 600784 | 31 | 0 | 1 |
| `qwrit` | 205664:403 | 596746 | 116 | 0 | 3 |
| `read` | 206080:562 | 588597 | 251 | 0 | 4 |
| `unlnk` | 208208:285 | 583653 | 33 | 0 | 1 |
| `write` | 208496:832 | 587027 | 469 | 0 | 8 |
| `chipd32` | 209328:2742 | 606728 | 2104 | 0 | 71 |
| `getenv` | 220464:357 | 589923 | 97 | 0 | 2 |
| `isatt` | 221472:261 | 597548 | 39 | 0 | 0 |
| `chdir` | 225600:284 | 592084 | 33 | 0 | 1 |
| `ltoa` | 229504:466 | 583035 | 138 | 0 | 2 |
| `strtol` | 229984:1078 | 590020 | 607 | 0 | 7 |

### toolchains/watcom-10.5/LIB386/math387r.lib

| Member | Archive offset:size | CODE nomination | Initialized | BSS | Fixups |
| --- | --- | ---: | ---: | ---: | ---: |
| `leadzero` | 16:330 | 624239 | 65 | 0 | 1 |
| `cvt` | 2240:824 | 625707 | 477 | 0 | 6 |
| `pow387` | 5728:566 | 592188 | 358 | 0 | 4 |
| `strtod` | 6592:838 | 591526 | 499 | 0 | 7 |
| `ftos` | 15856:1559 | 624296 | 972 | 0 | 13 |
| `math87e` | 23952:390 | 624116 | 123 | 0 | 1 |
| `nan_inf` | 24592:404 | 625389 | 154 | 0 | 2 |
| `pow87e` | 25008:402 | 606452 | 137 | 0 | 1 |
| `scale` | 26528:829 | 606102 | 382 | 0 | 18 |
| `_matherr` | 31472:859 | 625264 | 295 | 0 | 19 |
| `__mtherr` | 10480:143 | 626184 | 5 | 0 | 1 |
| `matherr` | 24352:228 | 626416 | 3 | 0 | 0 |

## Reproducible supplied runtime preparation

`make prepare-stock-runtime` reads the tracked selection in
`candidates/stock_runtime_inputs.json` and the declared original Watcom GA/10.5
libraries. It extracts177 complete, checksummed members without modification
and supplies the five original libraries used by WLINK. All182 output files
match the current complete native link inputs byte-for-byte (Root630).

This command reads no target executable or game/SDK object. Archive/member
boundaries, names, sizes, hashes and the full library identities are checked
before output publication. The outputs are supplied compiler runtime
dependencies, not recovered game source. Some members are identical across
compiler libraries; selecting one reproducible exact-byte candidate does not
establish historical compiler-version ownership. The declared DOS/4GW vendor
component remains a separate binding dependency.
