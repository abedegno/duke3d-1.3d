# Reading the recovered GAME source

The exact native-layout build compiles 79 functions from `src/game/game.c` and
assembles `spawn` and `checkcommandline` from `src/game/game_fallback.S`.
Their C counterparts remain behind `GAME_ASM_FALLBACKS` guards.

The C retains the released source lineage's types, macros, sprite-list loops,
tile switches and procedural style. `gametext.h` declares 140 private message
arrays with explicit capacities and post-NUL bytes. Their names are inferred.
The fixed message bank and code sections preserve the original layout.

The companion references 17 private arrays through an explicitly declared GAME
source-unit convention. The final OMF object retains their private scope.
`game_private_imports.json` declares those bindings and `game_text_model.json`
describes the authored bank. The producer freshly compiles and assembles the
complete inputs before combining their native relocation records.

`spawn` still has C scheduling and register-lifetime differences. Two branches
in `checkcommandline` share its epilogue. Frame-home names in the assembly
identify recovered compiler storage and carry no historical naming claim.
The full executable comparison remains the final acceptance gate.

| Function | Emitting source | C source | Relationship |
| --- | --- | --- | --- |
| `timerhandler` | [C](../src/game/game.c#L208) | [C](../src/game/game.c#L208) | Compiled from C |
| `inittimer` | [C](../src/game/game.c#L213) | [C](../src/game/game.c#L213) | Compiled from C |
| `uninittimer` | [C](../src/game/game.c#L219) | [C](../src/game/game.c#L219) | Compiled from C |
| `gametext` | [C](../src/game/game.c#L68) | [C](../src/game/game.c#L68) | Compiled from C |
| `gametextpart` | [C](../src/game/game.c#L278) | [C](../src/game/game.c#L278) | Compiled from C |
| `minitext` | [C](../src/game/game.c#L334) | [C](../src/game/game.c#L334) | Compiled from C |
| `gamenumber` | [C](../src/game/game.c#L355) | [C](../src/game/game.c#L355) | Compiled from C |
| `allowtimetocorrecterrorswhenquitting` | [C](../src/game/game.c#L365) | [C](../src/game/game.c#L365) | Compiled from C |
| `getpackets` | [C](../src/game/game.c#L407) | [C](../src/game/game.c#L407) | Compiled from C |
| `faketimerhandler` | [C](../src/game/game.c#L666) | [C](../src/game/game.c#L666) | Compiled from C |
| `checksync` | [C](../src/game/game.c#L958) | [C](../src/game/game.c#L958) | Compiled from C |
| `check_fta_sounds` | [C](../src/game/game.c#L1001) | [C](../src/game/game.c#L1001) | Compiled from C |
| `inventory` | [C](../src/game/game.c#L1059) | [C](../src/game/game.c#L1059) | Compiled from C |
| `badguy` | [C](../src/game/game.c#L1076) | [C](../src/game/game.c#L1076) | Compiled from C |
| `badguypic` | [C](../src/game/game.c#L1116) | [C](../src/game/game.c#L1116) | Compiled from C |
| `myos` | [C](../src/game/game.c#L1158) | [C](../src/game/game.c#L1158) | Compiled from C |
| `myospal` | [C](../src/game/game.c#L1171) | [C](../src/game/game.c#L1171) | Compiled from C |
| `invennum` | [C](../src/game/game.c#L1186) | [C](../src/game/game.c#L1186) | Compiled from C |
| `weaponnum` | [C](../src/game/game.c#L1216) | [C](../src/game/game.c#L1216) | Compiled from C |
| `weaponnum999` | [C](../src/game/game.c#L1244) | [C](../src/game/game.c#L1244) | Compiled from C |
| `weapon_amounts` | [C](../src/game/game.c#L1283) | [C](../src/game/game.c#L1283) | Compiled from C |
| `digitalnumber` | [C](../src/game/game.c#L1393) | [C](../src/game/game.c#L1393) | Compiled from C |
| `displayinventory` | [C](../src/game/game.c#L1435) | [C](../src/game/game.c#L1435) | Compiled from C |
| `displayfragbar` | [C](../src/game/game.c#L1497) | [C](../src/game/game.c#L1497) | Compiled from C |
| `coolgaugetext` | [C](../src/game/game.c#L1519) | [C](../src/game/game.c#L1519) | Compiled from C |
| `tics` | [C](../src/game/game.c#L1860) | [C](../src/game/game.c#L1860) | Compiled from C |
| `caches` | [C](../src/game/game.c#L1876) | [C](../src/game/game.c#L1876) | Compiled from C |
| `coords` | [C](../src/game/game.c#L1900) | [C](../src/game/game.c#L1900) | Compiled from C |
| `operatefta` | [C](../src/game/game.c#L1923) | [C](../src/game/game.c#L1923) | Compiled from C |
| `FTA` | [C](../src/game/game.c#L1957) | [C](../src/game/game.c#L1957) | Compiled from C |
| `showtwoscreens` | [C](../src/game/game.c#L1976) | [C](../src/game/game.c#L1976) | Compiled from C |
| `binscreen` | [C](../src/game/game.c#L1980) | [C](../src/game/game.c#L1980) | Compiled from C |
| `gameexit` | [C](../src/game/game.c#L1994) | [C](../src/game/game.c#L1994) | Compiled from C |
| `strget` | [C](../src/game/game.c#L2052) | [C](../src/game/game.c#L2052) | Compiled from C |
| `displayrest` | [C](../src/game/game.c#L2121) | [C](../src/game/game.c#L2121) | Compiled from C |
| `updatesectorz` | [C](../src/game/game.c#L2352) | [C](../src/game/game.c#L2352) | Compiled from C |
| `view` | [C](../src/game/game.c#L2390) | [C](../src/game/game.c#L2390) | Compiled from C |
| `drawbackground` | [C](../src/game/game.c#L2449) | [C](../src/game/game.c#L2449) | Compiled from C |
| `displayrooms` | [C](../src/game/game.c#L2676) | [C](../src/game/game.c#L2676) | Compiled from C |
| `LocateTheLocator` | [C](../src/game/game.c#L2921) | [C](../src/game/game.c#L2921) | Compiled from C |
| `EGS` | [C](../src/game/game.c#L2935) | [C](../src/game/game.c#L2935) | Compiled from C |
| `wallswitchcheck` | [C](../src/game/game.c#L3014) | [C](../src/game/game.c#L3014) | Compiled from C |
| `spawn` | [assembly](../src/game/game_fallback.S#L144) | [C](../src/game/game.c#L3070) | C counterpart retained |
| `animatesprites` | [C](../src/game/game.c#L4738) | [C](../src/game/game.c#L4738) | Compiled from C |
| `cheats` | [C](../src/game/game.c#L5580) | [C](../src/game/game.c#L5580) | Compiled from C |
| `nonsharedkeys` | [C](../src/game/game.c#L6195) | [C](../src/game/game.c#L6195) | Compiled from C |
| `comlinehelp` | [C](../src/game/game.c#L6638) | [C](../src/game/game.c#L6638) | Compiled from C |
| `checkcommandline` | [assembly](../src/game/game_fallback.S#L5582) | [C](../src/game/game.c#L6662) | C counterpart retained |
| `printstr` | [C](../src/game/game.c#L6926) | [C](../src/game/game.c#L6926) | Compiled from C |
| `Logo` | [C](../src/game/game.c#L6954) | [C](../src/game/game.c#L6954) | Compiled from C |
| `loadtmb` | [C](../src/game/game.c#L7053) | [C](../src/game/game.c#L7053) | Compiled from C |
| `ShutDown` | [C](../src/game/game.c#L7074) | [C](../src/game/game.c#L7074) | Compiled from C |
| `compilecons` | [C](../src/game/game.c#L7098) | [C](../src/game/game.c#L7098) | Compiled from C |
| `Startup` | [C](../src/game/game.c#L7121) | [C](../src/game/game.c#L7121) | Compiled from C |
| `sendscore` | [C](../src/game/game.c#L7195) | [C](../src/game/game.c#L7195) | Compiled from C |
| `getnames` | [C](../src/game/game.c#L7202) | [C](../src/game/game.c#L7202) | Compiled from C |
| `main` | [C](../src/game/game.c#L7243) | [C](../src/game/game.c#L7243) | Compiled from C |
| `opendemoread` | [C](../src/game/game.c#L7487) | [C](../src/game/game.c#L7487) | Compiled from C |
| `opendemowrite` | [C](../src/game/game.c#L7515) | [C](../src/game/game.c#L7515) | Compiled from C |
| `record` | [C](../src/game/game.c#L7546) | [C](../src/game/game.c#L7546) | Compiled from C |
| `closedemowrite` | [C](../src/game/game.c#L7563) | [C](../src/game/game.c#L7563) | Compiled from C |
| `playback` | [C](../src/game/game.c#L7583) | [C](../src/game/game.c#L7583) | Compiled from C |
| `moveloop` | [C](../src/game/game.c#L7715) | [C](../src/game/game.c#L7715) | Compiled from C |
| `fakedomovethingscorrect` | [C](../src/game/game.c#L7734) | [C](../src/game/game.c#L7734) | Compiled from C |
| `fakedomovethings` | [C](../src/game/game.c#L7767) | [C](../src/game/game.c#L7767) | Compiled from C |
| `domovethings` | [C](../src/game/game.c#L8205) | [C](../src/game/game.c#L8205) | Compiled from C |
| `doorders` | [C](../src/game/game.c#L8333) | [C](../src/game/game.c#L8333) | Compiled from C |
| `dobonus` | [C](../src/game/game.c#L8370) | [C](../src/game/game.c#L8370) | Compiled from C |
| `cameratext` | [C](../src/game/game.c#L8887) | [C](../src/game/game.c#L8887) | Compiled from C |
| `vglass` | [C](../src/game/game.c#L8910) | [C](../src/game/game.c#L8910) | Compiled from C |
| `lotsofglass` | [C](../src/game/game.c#L8923) | [C](../src/game/game.c#L8923) | Compiled from C |
| `spriteglass` | [C](../src/game/game.c#L8971) | [C](../src/game/game.c#L8971) | Compiled from C |
| `ceilingglass` | [C](../src/game/game.c#L8984) | [C](../src/game/game.c#L8984) | Compiled from C |
| `lotsofcolourglass` | [C](../src/game/game.c#L9013) | [C](../src/game/game.c#L9013) | Compiled from C |
| `SetupGameButtons` | [C](../src/game/game.c#L9051) | [C](../src/game/game.c#L9051) | Compiled from C |
| `GetTime` | [C](../src/game/game.c#L9115) | [C](../src/game/game.c#L9115) | Compiled from C |
| `CenterCenter` | [C](../src/game/game.c#L9129) | [C](../src/game/game.c#L9129) | Compiled from C |
| `UpperLeft` | [C](../src/game/game.c#L9142) | [C](../src/game/game.c#L9142) | Compiled from C |
| `LowerRight` | [C](../src/game/game.c#L9155) | [C](../src/game/game.c#L9155) | Compiled from C |
| `CenterThrottle` | [C](../src/game/game.c#L9168) | [C](../src/game/game.c#L9168) | Compiled from C |
| `CenterRudder` | [C](../src/game/game.c#L9181) | [C](../src/game/game.c#L9181) | Compiled from C |
