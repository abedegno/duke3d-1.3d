# Watcom RAND runtime source

`rand.c` and `include/randnext.h` are byte-for-byte copies from the initial
Open Watcom V1 source revision
`6b9cb4438959d845a2b4dd4bf19f7908ecd608e9` in
<https://github.com/open-watcom/owp4v1copy>. Their original Sybase notices
remain intact. `license.txt` is the Sybase Open Watcom Public License 1.0,
copied unchanged from revision `52a4ed130e644761f6d1427e40dda4edf099adbf`.
These files retain that license; they are not relabeled as GPL source.

The native source proof uses Watcom C32 10.0 GA with `/3r /s /os`.
`modules/watcom_rand.json` stages only `include/` into a fresh private header
directory through the existing generic module driver:

```sh
python3 tools/prove_module.py watcom_rand
```

The complete contribution is 58 CODE bytes at LE object 1 offset 583791 and
four initialized DATA bytes at object 3 offset 71832. CONST, CONST2, and BSS
are empty. All three fixups and all four native public/local entries are
verified. `initrandnext_` and `_next` retain local scope; only `rand_` and
`srand_` are external anchors. The claim ends at CODE offset 583849 and DATA
offset 71836 (exclusive), with no adjacent padding or member bytes claimed.

## Narrow DOS configuration

The unmodified full primary `variety.h` and `rtdata.h` were tried first with
the historical compiler. They require `_comdef.h` and `errorno.h`, absent
from that compiler's header set, and produce seven errors. The newer
`_comdef.mh` is a header-generator template containing `:segment` and
`:include` directives, not a C header to substitute unchanged. Therefore
the two tracked headers are explicitly modified RAND-only subsets with
the original license notices and dated modification notes. They are not
general replacements for the Open Watcom header tree.

The complete mapping uses the initial revision's original line numbers:

| Tracked interface | Primary definition and branch |
| --- | --- |
| Empty `_WCRTLINK` | `bld/hdr/watcom/_comdef.mh` 111–115, the non-`__SW_BR` branch. `bld/lib_misc/h/variety.h` 174–245 overrides linkage only for WARP/NT, so DOS retains it. |
| `_INITRANDNEXT(p)` | Complete unchanged `bld/clib/math/h/randnext.h` 34. The unused argument tokens, including `RETURN_ARG`, are discarded by this original empty macro. |
| Real static `next = 1` and `_RANDNEXT next` | Complete unchanged `randnext.h` 56–59, selected when OS2, NT, NETWARE, and PENPOINT are absent. |
| `_RWD_randnext _RANDNEXT` | `bld/lib_misc/h/rtdata.h` 192, in its non-PENPOINT branch. No replacement struct, external storage declaration, or ABI is introduced. |
| Target/model selection | Original `variety.h` 49–54 and 130–145. The subset requires compiler-defined `__DOS__`, `__386__`, and `__FLAT__`. |
| `NULL` | Historical compiler `H/stdio.h` 19–25; its unchanged real declaration is used by `rand.c`. |

The subset additionally rejects multithreaded/shared-runtime switches,
other OS selectors, and DLL build selectors. Its include guards are the
original guards. Unused memory, IO, thread, exception, and data aliases are
omitted; `_HUGEDATA` and `_WCDATA` are not used or synthesized for RAND.
The exact upstream files, mapped line ranges, staged headers, compiler,
standard header, descriptor, source, license, target, and fresh object
hashes are recorded in `evidence/watcom_rand-source-reference.json` and
`evidence/watcom_rand-module.json`.

The native tests change algorithm/seed behavior, initializer/state/linkage
configuration, CODE tails, call fixups, public bindings, scope metadata,
and complete extents. Each must be rejected. They also compile invalid
target/model configurations and require the explicit configuration guard.

The historical `clib3r.lib` RAND member is reference evidence only. No
library payload or target bytes are used to produce the rebuilt module.
The later primary source emits the exact historical contributions, but
this does not establish the original 1994/1996 source spelling, comments,
build paths, or full build settings. The complete executable still needs
other modules and linker/binder reproduction.
