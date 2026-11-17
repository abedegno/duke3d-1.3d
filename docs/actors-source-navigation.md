# Reading the recovered ACTORS source

All 37 emitted functions have ordinary C counterparts. Start with the C
algorithm and use this index to inspect the actual emitted mnemonic body.
The normal exact-layout mode assembles the complete `ACTORS.S` contribution.
The ordinary C and earlier C/assembly composite modes remain available.

The first 36 functions derive directly from a fresh canonical C build. The
`moveeffectors` body retains named frame homes and the existing symbolic source.
The fixed complete-C witness differs only in 298 stack-home displacement bytes,
a permutation of 14 frame homes; its algorithm remains available in
`actors-fixed-complete-C-counterpart.c.txt`. These observations establish the
current source relationship, with no claim of unique historical C spelling.

One source contribution lets the converter emit the measured record span that
crosses the former C/assembly boundary. The 356-span descriptor contains CODE
coordinates and lengths. Source roles, complete native metadata and field
ownership remain checked by `source_policy.py`, `native_schema.py` and the
closed source model. Keep the two original C-private objects private.

Further compiler-faithful C lowering remains a documented backlog. Any source
or guard change must pass its complete contribution proof and the final bound
executable identity gate. This reading index changes no emitted source.

| Function | Emitted source | C counterpart | Relationship |
| --- | --- | --- | --- |
| `updateinterpolations` | [mnemonics](../src/game/actors_native/ACTORS.S#L198) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L47) | fresh C derivative |
| `setinterpolation` | [mnemonics](../src/game/actors_native/ACTORS.S#L217) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L55) | fresh C derivative |
| `stopinterpolation` | [mnemonics](../src/game/actors_native/ACTORS.S#L245) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L67) | fresh C derivative |
| `dointerpolations` | [mnemonics](../src/game/actors_native/ACTORS.S#L286) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L81) | fresh C derivative |
| `restoreinterpolations` | [mnemonics](../src/game/actors_native/ACTORS.S#L338) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L95) | fresh C derivative |
| `ceilingspace` | [mnemonics](../src/game/actors_native/ACTORS.S#L360) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L102) | fresh C derivative |
| `floorspace` | [mnemonics](../src/game/actors_native/ACTORS.S#L390) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L116) | fresh C derivative |
| `addammo` | [mnemonics](../src/game/actors_native/ACTORS.S#L420) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L130) | fresh C derivative |
| `addweapon` | [mnemonics](../src/game/actors_native/ACTORS.S#L461) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L138) | fresh C derivative |
| `checkavailinven` | [mnemonics](../src/game/actors_native/ACTORS.S#L506) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L196) | fresh C derivative |
| `checkavailweapon` | [mnemonics](../src/game/actors_native/ACTORS.S#L604) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L216) | fresh C derivative |
| `ifsquished` | [mnemonics](../src/game/actors_native/ACTORS.S#L781) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L364) | fresh C derivative |
| `hitradius` | [mnemonics](../src/game/actors_native/ACTORS.S#L875) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L409) | fresh C derivative |
| `movesprite` | [mnemonics](../src/game/actors_native/ACTORS.S#L1524) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L591) | fresh C derivative |
| `ssp` | [mnemonics](../src/game/actors_native/ACTORS.S#L1861) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L676) | fresh C derivative |
| `insertspriteq` | [mnemonics](../src/game/actors_native/ACTORS.S#L1895) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L691) | fresh C derivative |
| `lotsofmoney` | [mnemonics](../src/game/actors_native/ACTORS.S#L1920) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L699) | fresh C derivative |
| `guts` | [mnemonics](../src/game/actors_native/ACTORS.S#L1976) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L709) | fresh C derivative |
| `gutsdir` | [mnemonics](../src/game/actors_native/ACTORS.S#L2067) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L735) | fresh C derivative |
| `setsectinterpolate` | [mnemonics](../src/game/actors_native/ACTORS.S#L2156) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L761) | fresh C derivative |
| `clearsectinterpolate` | [mnemonics](../src/game/actors_native/ACTORS.S#L2214) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L784) | fresh C derivative |
| `ms` | [mnemonics](../src/game/actors_native/ACTORS.S#L2264) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L802) | fresh C derivative |
| `movefta` | [mnemonics](../src/game/actors_native/ACTORS.S#L2348) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L833) | fresh C derivative |
| `ifhitsectors` | [mnemonics](../src/game/actors_native/ACTORS.S#L2619) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L921) | fresh C derivative |
| `ifhitbyweapon` | [mnemonics](../src/game/actors_native/ACTORS.S#L2644) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L935) | fresh C derivative |
| `movecyclers` | [mnemonics](../src/game/actors_native/ACTORS.S#L2883) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L1013) | fresh C derivative |
| `movedummyplayers` | [mnemonics](../src/game/actors_native/ACTORS.S#L2979) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L1050) | fresh C derivative |
| `moveplayers` | [mnemonics](../src/game/actors_native/ACTORS.S#L3104) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L1096) | fresh C derivative |
| `movefx` | [mnemonics](../src/game/actors_native/ACTORS.S#L3355) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L1236) | fresh C derivative |
| `movefallers` | [mnemonics](../src/game/actors_native/ACTORS.S#L3653) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L1359) | fresh C derivative |
| `movestandables` | [mnemonics](../src/game/actors_native/ACTORS.S#L3911) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L1455) | fresh C derivative |
| `bounce` | [mnemonics](../src/game/actors_native/ACTORS.S#L6143) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L2362) | fresh C derivative |
| `moveweapons` | [mnemonics](../src/game/actors_native/ACTORS.S#L6306) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L2401) | fresh C derivative |
| `movetransports` | [mnemonics](../src/game/actors_native/ACTORS.S#L7284) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L2739) | fresh C derivative |
| `moveactors` | [mnemonics](../src/game/actors_native/ACTORS.S#L8130) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L3039) | fresh C derivative |
| `moveexplosions` | [mnemonics](../src/game/actors_native/ACTORS.S#L11417) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L4240) | fresh C derivative |
| `moveeffectors` | [mnemonics](../src/game/actors_native/ACTORS.S#L12689) | [C algorithm](../src/game/actors_native/actors-C-counterpart.c.txt#L4750) | symbolic body; fixed C differs in frame allocation |
