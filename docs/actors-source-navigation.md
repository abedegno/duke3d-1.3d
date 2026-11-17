# Reading the recovered ACTORS source

The exact build now compiles the first **36 functions directly from
`src/game/actors.c` with Watcom GA**. Only `moveeffectors` uses the named NASM
fallback. All 37 algorithms have ordinary C counterparts.

The two fresh compiler/assembler contributions are linked semantically into one
OMF module. Source bytes, typed relocation expressions, private scope, compiler
libraries and metadata are conserved. The existing 356-span source-owned plan
then changes record boundaries only, including a record across the former
C/assembly boundary. The complete executable still passes the literal file gate.

The fixed complete-C `moveeffectors` witness differs in 298 stack-home
displacement bytes across 14 frame homes; its algorithm remains available in
`actors-fixed-complete-C-counterpart.c.txt`. No matching C replacement has been
admitted for that body. Inferred frame names do not establish historical names.

The older whole `ACTORS.S` backend remains available for comparison. Its C
counterparts and original notices remain unchanged. Further lowering must pass
complete contribution checks and the final byte-identical rebuild gate.

| Function | Emitted source | C counterpart | Relationship |
| --- | --- | --- | --- |
| `updateinterpolations` | [emitting C](../src/game/actors.c#L47) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L47) | direct Watcom C emission |
| `setinterpolation` | [emitting C](../src/game/actors.c#L55) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L55) | direct Watcom C emission |
| `stopinterpolation` | [emitting C](../src/game/actors.c#L67) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L67) | direct Watcom C emission |
| `dointerpolations` | [emitting C](../src/game/actors.c#L81) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L81) | direct Watcom C emission |
| `restoreinterpolations` | [emitting C](../src/game/actors.c#L95) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L95) | direct Watcom C emission |
| `ceilingspace` | [emitting C](../src/game/actors.c#L102) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L102) | direct Watcom C emission |
| `floorspace` | [emitting C](../src/game/actors.c#L116) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L116) | direct Watcom C emission |
| `addammo` | [emitting C](../src/game/actors.c#L130) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L130) | direct Watcom C emission |
| `addweapon` | [emitting C](../src/game/actors.c#L138) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L138) | direct Watcom C emission |
| `checkavailinven` | [emitting C](../src/game/actors.c#L196) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L196) | direct Watcom C emission |
| `checkavailweapon` | [emitting C](../src/game/actors.c#L216) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L216) | direct Watcom C emission |
| `ifsquished` | [emitting C](../src/game/actors.c#L364) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L364) | direct Watcom C emission |
| `hitradius` | [emitting C](../src/game/actors.c#L409) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L409) | direct Watcom C emission |
| `movesprite` | [emitting C](../src/game/actors.c#L591) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L591) | direct Watcom C emission |
| `ssp` | [emitting C](../src/game/actors.c#L676) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L676) | direct Watcom C emission |
| `insertspriteq` | [emitting C](../src/game/actors.c#L691) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L691) | direct Watcom C emission |
| `lotsofmoney` | [emitting C](../src/game/actors.c#L699) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L699) | direct Watcom C emission |
| `guts` | [emitting C](../src/game/actors.c#L709) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L709) | direct Watcom C emission |
| `gutsdir` | [emitting C](../src/game/actors.c#L735) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L735) | direct Watcom C emission |
| `setsectinterpolate` | [emitting C](../src/game/actors.c#L761) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L761) | direct Watcom C emission |
| `clearsectinterpolate` | [emitting C](../src/game/actors.c#L784) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L784) | direct Watcom C emission |
| `ms` | [emitting C](../src/game/actors.c#L802) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L802) | direct Watcom C emission |
| `movefta` | [emitting C](../src/game/actors.c#L833) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L833) | direct Watcom C emission |
| `ifhitsectors` | [emitting C](../src/game/actors.c#L921) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L921) | direct Watcom C emission |
| `ifhitbyweapon` | [emitting C](../src/game/actors.c#L935) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L935) | direct Watcom C emission |
| `movecyclers` | [emitting C](../src/game/actors.c#L1013) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L1013) | direct Watcom C emission |
| `movedummyplayers` | [emitting C](../src/game/actors.c#L1050) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L1050) | direct Watcom C emission |
| `moveplayers` | [emitting C](../src/game/actors.c#L1096) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L1096) | direct Watcom C emission |
| `movefx` | [emitting C](../src/game/actors.c#L1236) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L1236) | direct Watcom C emission |
| `movefallers` | [emitting C](../src/game/actors.c#L1359) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L1359) | direct Watcom C emission |
| `movestandables` | [emitting C](../src/game/actors.c#L1455) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L1455) | direct Watcom C emission |
| `bounce` | [emitting C](../src/game/actors.c#L2362) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L2362) | direct Watcom C emission |
| `moveweapons` | [emitting C](../src/game/actors.c#L2401) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L2401) | direct Watcom C emission |
| `movetransports` | [emitting C](../src/game/actors.c#L2739) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L2739) | direct Watcom C emission |
| `moveactors` | [emitting C](../src/game/actors.c#L3039) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L3039) | direct Watcom C emission |
| `moveexplosions` | [emitting C](../src/game/actors.c#L4240) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L4240) | direct Watcom C emission |
| `moveeffectors` | [NASM fallback](../src/game/moveeffectors.asm#L162) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L4750) | named assembly fallback; C frame allocation remains nonexact |
