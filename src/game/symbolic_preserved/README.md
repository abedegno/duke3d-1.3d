# Prepared optional GAME CONST preservation

This capsule is a draft option. The permission question is unanswered. It is
not selected by any normal build recipe, and preparing or testing it does not
approve adoption. The default `src/game/symbolic/GAME.S` and every existing
negative/default route remain unchanged.

The complete readable source is the current reviewed symbolic GAME source
(c194be76eaa39cea4750e19035df47a306b478f139b0028380988ee5b7c7a86d), with
only seven values inside four existing `.ascii` capacities changed. Instructions,
labels, fields, object sizes, public/private identities, groups and BSS ownership
are unchanged. Staging uses the normal GAME.S/GAME.ELF/GAME.OBJ and groups layout;
the authored option has this separate path and its own closed model/guard.

| Existing qualified local label | CONST start | Capacity | First NUL | Prepared residue offsets/values |
| --- | ---: | ---: | ---: | --- |
| game_text_getpackets_0 | 0 | 48 | 46 | 47:16 |
| game_text_getpackets_48 | 48 | 48 | 44 | 93:86, 94:7 |
| game_text_getpackets_96 | 96 | 4 | 1 | 98:3, 99:216 |
| game_text_checksync_100 | 100 | 36 | 33 | 134:160, 135:86 |

First-NUL offsets are relative to the literal. All bytes through and including
that terminator, all capacities and every other byte remain unchanged. These
seven values are unidentified post-NUL residue observed in the original image;
no runtime meaning, historical declaration, spelling or allocator intent is
inferred. They belong to the existing literal capacities; no new storage owner,
padding object, alias or exported symbol is introduced. The readable C
counterpart preserves the ordinary runtime strings and remains an aid rather
than a claim of historical C byte identity.

`tools/build_game_symbolic_preserved.py` is an explicit source-only entry point.
It uses the existing pinned GNU/decoder/GA profiles, full source operand and
native/COFF guards, six real tail owners, and an independently pinned complete
4274-byte CONST hash. It reads no target, SDK object or ignored research input.
Original 3D Realms/Matt Saettler notices and the full GPL text remain in the
unchanged shared C counterpart and normal symbolic notices staged with this
option. No existing producer/helper/model is modified.

A separate observer can test full module bytes after source production. Its
positive byte comparison is not publication/adoption approval, complete source
credit or an executable-build claim. The fixed normal recipe remains on the
seven-zero version until the permission decision and independent review.
