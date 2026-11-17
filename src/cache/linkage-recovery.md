# CACHE1D shared count linkage

GAME's cache loop reads the same `cacnum` count that CACHE1D updates. The
released-source `static` declaration therefore leaves that genuine cross-module
consumer undefined. `cacnum` now has external linkage as an ordinary initialized
`long`, at its existing declaration position. The neighboring cache start,
reserved size and age count remain static and retain their order.

The complete native CACHE proof preserves all 5,415 initialized bytes, 49,453
BSS bytes, 332 fixups, segment layouts and public binding values. Only the local
classification of `_cacnum` changes; its target remains object 3, offset 32077.
An independently compiled consumer rejects the private form and links the public
form. All other cache internals retain their measured local scopes.

This repairs source linkage without adding storage, an alias or byte coverage.
The provisional 72-object source-only link resolves this one name and remains
incomplete. Missing source, complete executable layout/identity and later
humanization remain separate work. Original Build attribution and license in
`cache1d.c` and `BUILDLIC.TXT` remain unchanged; inferred source linkage is not a
claim of original historical C spelling.
