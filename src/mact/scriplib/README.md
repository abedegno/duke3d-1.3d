# SCRIPLIB source candidate

`../scriplib.c` is a readable reconstruction of the MACT SCRIPLIB native behavior. It is not a claim to have found the original C file. The eight headers here are unchanged copies of the released `dukenukem3d/extras` headers, with their original notices. They establish the actual types, list macros, script/token APIs and constants; no substitute ABI was invented.

Jonathon Fowler's related `jfmact` source at revision `a356c4aa660c5dfbe5ad940ee8a75f3ab7fcd10f` was imported on 2005-11-29. Fowler explicitly calls that work creative interpolation. Its API relationships helped identify roles, but its Parse stub and alternate allocation algorithm do not establish original MACT behavior. The candidate instead implements the complete native parse/load/save, section and entry lists, typed accessors, formatting and cleanup. The source-reference JSON records the separate origins and their limits.

The original GA compiler with `/omaxnet /zp4 /5r` produces one complete module: 4201 CODE bytes, 1411 CONST bytes, four initialized state bytes, 80 BSS bytes and 225 typed fixups. All 38 actual definitions, their offsets and scopes are checked. The two state definitions remain private. There are 36 global CODE names at 34 unique entries: the real `SCRIPT_PutSection` and `SCRIPT_PutRaw` wrappers naturally share entries with `SCRIPT_AddSection` and `SCRIPT_AddEntry` under GA optimization. They are ordinary C calls, not symbol aliases or fabricated compatibility exports.

The final six function corrections follow observed native dataflow. Section traversal uses separate initialization/latch blocks with an explicit equality break; original GA IR snapshots show why this keeps the next-pointer load separate from table loads. Entry counters start after validation but before the lookup call, preserving their actual live registers. Double-string copies use their real pointer differences directly. Save writes in each of three mutually exclusive line-type cases; GA tail-merges those real calls naturally. No name, declaration, type or compiler-option sweep was used to obtain the final match.

Real NUL-terminated diagnostic/format literals contain explicit unused NUL suffixes where the native CONST segment has DWORD zero gaps. No `sizeof` or raw literal-length consumer observes these suffixes; the final `%f` literal retains its three-byte extent. This is the same bounded source treatment used by the recovered MACT keyboard module. There is no padding object or opaque CONST array. The producer checks the entire CONST segment, including gaps and final byte. A native EOL-string mutation retains identical CODE but is rejected by this full CONST check.

Run the scoped producer before generic registration:

```sh
python3 tools/probe_mact_scriplib.py --build build/mact-scriplib-proof --report evidence/mact_scriplib-module.json
python3 -m unittest tests.test_mact_scriplib -v
```

The producer needs only tracked C/headers/contract/provenance, unchanged GA tools and the target executable. It does not read the original MACT archive or private research outputs. Complete original SDK metadata is an analysis witness recorded in the descriptor; the original member never supplies producer instructions or data. Runtime geometry, groups, every typed fixup, all public/private definitions, retained unused float imports and default libraries are mandatory. THEADR, source dependency comments/timestamps and original line-number records are metadata differences, not runtime masks.

The CODE placement is corroborated by the already proved CONFIG call to `SCRIPT_Load`: the scoped producer independently replays its actual E8 rel32 field. The other 19 imported names are fixed native role nominations and addresses, not independent source proof of missing TOKEN or all other callees. No source-only linked functional consumer is claimed while those dependencies remain unrecovered. Source credit awaits independent integration review. Historical spelling, final library selection/link ABI, whole executable identity and remaining humanization are separate unfinished obligations.
