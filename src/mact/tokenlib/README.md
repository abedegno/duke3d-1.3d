# TOKENLIB source candidate

`../tokenlib.c` is a readable reconstruction of the complete MACT native TOKENLIB behavior, not discovered original C. These six headers are unchanged copies of released `dukenukem3d/extras` files, with notices retained. `_tokenli.h` supplies the real148-byte record,20-pointer table and parsing constants; `tokenlib.h` supplies the API and128-byte global token buffer.

Source-first research inspected the pinned2005 `jonof/jfmact` source and current primary repository listing, released Duke headers, and related released ROTT SCRIPLIB. The inspected jfmact source has no TOKENLIB implementation. ROTT supplies related parser context, with a different global-state ABI; it is not original MACT source. The reconstruction preserves the native handle-based algorithms and behavior instead of substituting that implementation. Both released3D Realms and related Apogee GPL provenance remain explicit. Bounded searches do not prove no original source exists elsewhere.

The first grounded full C hypothesis compiled under original GA10.0 `/omaxnet /zp4 /5r` with zero diagnostics and matched all20 complete native intervals. No source/profile/type/name/declaration grid was needed. The whole module is2110CODE +919CONST +4DATA +208BSS bytes with131 typed fixups. All23 actual definitions/scopes match:20 global CODE routines, public `token[128]`, private20-pointer `tokenfiles`, private initialized flag. The complete native metadata also retains unused float imports and default libraries. Only module name/comments/line-number records differ from the original member.

Availability scans use a local cursor. Normal Get skips both comment markers and handles UnGet replay; GetLine excludes the newline, while GetRaw zeroes the real token buffer and copies the line plus newline. LinesInFile snapshots/restores the148-byte record, not global token contents. Parse owns a real copy, and Free releases it. Native boundary/error ordering remains as observed, including its unusual end-of-buffer behavior. This recovery does not silently add safety changes.

Real NUL-terminated diagnostic literals contain explicit unused NUL suffixes for native DWORD zero gaps. No sizeof/raw literal-length consumer observes them. The final47-byte logical literal keeps its native terminal extent. There is no opaque CONST/padding object. Complete CONST bytes, gaps and tail are mandatory; a changed message retains identical CODE but fails the whole CONST gate.

```sh
python3 tools/probe_mact_tokenlib.py --build build/mact-tokenlib-proof --report evidence/mact_tokenlib-module.json
python3 -m unittest tests.test_mact_tokenlib -v
```

The scoped producer reads only tracked source/headers/contract/provenance, unmodified compiler and target. It does not read SDK archives or private research objects to create output. A fixed SCRIPLIB relative-call witness corroborates CODE placement, with frozen caller provenance and its review status stated rather than a recursive mutable-evidence dependency. All eight used outside call roles are fixed native nominations; this is not new whole-source proof of their callees.

Tests require complete bytes/geometry/scopes/fixups, native semantic and call-role mutants, storage boundaries, a separate source-only staged CLI and actual input-race rejection. The native functional consumer links fresh whole TOKENLIB + existing complete recovered MACT FILE/UTIL + stock compiler runtime. It tests copying, comments/crossline, replay, numeric access, line/cursor restoration, raw/normal lines, slot reuse and the real file load path. An independent source client naming the actual private table must fail WLINK. No SDK object or substitute SDK definition is linked.

Source credit awaits independent integration review. Historical original C/local spelling, final library selection/link ABI, complete executable identity and remaining humanization are not claimed. Generic driver/Makefile/accounting integration stays controller-owned.
