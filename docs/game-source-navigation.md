# Reading the recovered GAME source

The build emits `src/game/symbolic/GAME.S`. Start with the corresponding C aid
for types and algorithms, then use this index to inspect the actual mnemonic
body. The C aid is not a second linked implementation and is not claimed to
reproduce every instruction with the original compiler.

The 81 entries below are all CODE publics in the closed source model, in emitted
order. `wallswitchcheck`, `spawn` and `checkcommandline` were originally reconstructed in
mnemonics after the fresh C derivative. A fresh strict C audit now verifies 79
of the 81 ordinary C bodies, including `wallswitchcheck` (160 bytes and its
real sprite relocation). The remaining `spawn` scheduling difference also
affects two `checkcommandline` branches into its shared epilogue. Their C text
remains useful, but those two bodies are not admitted as exact C replacements.
All bodies use actual mnemonics and named symbols. CODE data directives are
initializer templates and case-pointer tables, not stored instruction payloads.

Frame-home EQU names describe compiler storage locations; they do not establish
historical local-variable spelling. Follow `game_flow_<function>_*` labels within
a body. Source operand ownership, ELF/COFF/native fields and section coordinates
are guarded by `contract.py`, `coff_contract.py` and `contract-model.json`.
Private symbol spelling and the seven post-NUL residue bytes retain the limits
explained in the source README. This index adds no historical-source credit.

Change the authored source and its corresponding proof deliberately. A changed
source hash is expected to stop the closed producer; refreshing a hash alone is
not a matching proof. Rebuild from source, verify the complete function/data
roles, then compare the complete bound executable without masks. The final
humanization pass remains subject to that full-file gate.

| Function | Emitted mnemonics | C counterpart | Relationship |
| --- | --- | --- | --- |
| `timerhandler` | [source](../src/game/symbolic/GAME.S#L489) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L205) | C-derived mnemonic body |
| `inittimer` | [source](../src/game/symbolic/GAME.S#L494) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L210) | C-derived mnemonic body |
| `uninittimer` | [source](../src/game/symbolic/GAME.S#L511) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L216) | C-derived mnemonic body |
| `gametext` | [source](../src/game/symbolic/GAME.S#L529) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L224) | C-derived mnemonic body |
| `gametextpart` | [source](../src/game/symbolic/GAME.S#L644) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L275) | C-derived mnemonic body |
| `minitext` | [source](../src/game/symbolic/GAME.S#L782) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L331) | C-derived mnemonic body |
| `gamenumber` | [source](../src/game/symbolic/GAME.S#L845) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L352) | C-derived mnemonic body |
| `allowtimetocorrecterrorswhenquitting` | [source](../src/game/symbolic/GAME.S#L865) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L362) | C-derived mnemonic body |
| `getpackets` | [source](../src/game/symbolic/GAME.S#L918) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L393) | C-derived mnemonic body |
| `faketimerhandler` | [source](../src/game/symbolic/GAME.S#L2202) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L652) | C-derived mnemonic body |
| `checksync` | [source](../src/game/symbolic/GAME.S#L3371) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L944) | C-derived mnemonic body |
| `check_fta_sounds` | [source](../src/game/symbolic/GAME.S#L3473) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L987) | C-derived mnemonic body |
| `inventory` | [source](../src/game/symbolic/GAME.S#L3734) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L1045) | C-derived mnemonic body |
| `badguy` | [source](../src/game/symbolic/GAME.S#L3773) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L1062) | C-derived mnemonic body |
| `badguypic` | [source](../src/game/symbolic/GAME.S#L3929) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L1102) | C-derived mnemonic body |
| `myos` | [source](../src/game/symbolic/GAME.S#L4096) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L1144) | C-derived mnemonic body |
| `myospal` | [source](../src/game/symbolic/GAME.S#L4150) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L1157) | C-derived mnemonic body |
| `invennum` | [source](../src/game/symbolic/GAME.S#L4191) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L1172) | C-derived mnemonic body |
| `weaponnum` | [source](../src/game/symbolic/GAME.S#L4388) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L1202) | C-derived mnemonic body |
| `weaponnum999` | [source](../src/game/symbolic/GAME.S#L4638) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L1230) | C-derived mnemonic body |
| `weapon_amounts` | [source](../src/game/symbolic/GAME.S#L5021) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L1269) | C-derived mnemonic body |
| `digitalnumber` | [source](../src/game/symbolic/GAME.S#L5612) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L1379) | C-derived mnemonic body |
| `displayinventory` | [source](../src/game/symbolic/GAME.S#L5706) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L1421) | C-derived mnemonic body |
| `displayfragbar` | [source](../src/game/symbolic/GAME.S#L6036) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L1483) | C-derived mnemonic body |
| `coolgaugetext` | [source](../src/game/symbolic/GAME.S#L6233) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L1505) | C-derived mnemonic body |
| `tics` | [source](../src/game/symbolic/GAME.S#L7466) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L1846) | C-derived mnemonic body |
| `caches` | [source](../src/game/symbolic/GAME.S#L7513) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L1862) | C-derived mnemonic body |
| `coords` | [source](../src/game/symbolic/GAME.S#L7596) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L1886) | C-derived mnemonic body |
| `operatefta` | [source](../src/game/symbolic/GAME.S#L7720) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L1909) | C-derived mnemonic body |
| `FTA` | [source](../src/game/symbolic/GAME.S#L7823) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L1943) | C-derived mnemonic body |
| `showtwoscreens` | [source](../src/game/symbolic/GAME.S#L7860) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L1962) | C-derived mnemonic body |
| `binscreen` | [source](../src/game/symbolic/GAME.S#L7865) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L1966) | C-derived mnemonic body |
| `gameexit` | [source](../src/game/symbolic/GAME.S#L7888) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L1980) | C-derived mnemonic body |
| `strget` | [source](../src/game/symbolic/GAME.S#L7957) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L2038) | C-derived mnemonic body |
| `displayrest` | [source](../src/game/symbolic/GAME.S#L8113) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L2107) | C-derived mnemonic body |
| `updatesectorz` | [source](../src/game/symbolic/GAME.S#L8708) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L2338) | C-derived mnemonic body |
| `view` | [source](../src/game/symbolic/GAME.S#L8830) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L2376) | C-derived mnemonic body |
| `drawbackground` | [source](../src/game/symbolic/GAME.S#L9093) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L2435) | C-derived mnemonic body |
| `displayrooms` | [source](../src/game/symbolic/GAME.S#L9414) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L2662) | C-derived mnemonic body |
| `LocateTheLocator` | [source](../src/game/symbolic/GAME.S#L10182) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L2907) | C-derived mnemonic body |
| `EGS` | [source](../src/game/symbolic/GAME.S#L10214) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L2921) | C-derived mnemonic body |
| `wallswitchcheck` | [source](../src/game/symbolic/GAME.S#L10348) | [verified C](../src/game/symbolic/game-C-counterpart.c.txt#L3000) | ordinary C verified; whole GAME backend still emits assembly |
| `spawn` | [source](../src/game/symbolic/GAME.S#L10484) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L3055) | reconstructed body; C aid |
| `animatesprites` | [source](../src/game/symbolic/GAME.S#L15882) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L4721) | C-derived mnemonic body |
| `cheats` | [source](../src/game/symbolic/GAME.S#L17876) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L5563) | C-derived mnemonic body |
| `nonsharedkeys` | [source](../src/game/symbolic/GAME.S#L18918) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L6178) | C-derived mnemonic body |
| `comlinehelp` | [source](../src/game/symbolic/GAME.S#L19955) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L6620) | C-derived mnemonic body |
| `checkcommandline` | [source](../src/game/symbolic/GAME.S#L20061) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L6643) | reconstructed body; C aid |
| `printstr` | [source](../src/game/symbolic/GAME.S#L20395) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L6905) | C-derived mnemonic body |
| `Logo` | [source](../src/game/symbolic/GAME.S#L20431) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L6933) | C-derived mnemonic body |
| `loadtmb` | [source](../src/game/symbolic/GAME.S#L20767) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L7032) | C-derived mnemonic body |
| `ShutDown` | [source](../src/game/symbolic/GAME.S#L20795) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L7058) | C-derived mnemonic body |
| `compilecons` | [source](../src/game/symbolic/GAME.S#L20807) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L7082) | C-derived mnemonic body |
| `Startup` | [source](../src/game/symbolic/GAME.S#L20837) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L7105) | C-derived mnemonic body |
| `sendscore` | [source](../src/game/symbolic/GAME.S#L20913) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L7179) | C-derived mnemonic body |
| `getnames` | [source](../src/game/symbolic/GAME.S#L20931) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L7186) | C-derived mnemonic body |
| `main` | [source](../src/game/symbolic/GAME.S#L20992) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L7227) | C-derived mnemonic body |
| `opendemoread` | [source](../src/game/symbolic/GAME.S#L21364) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L7471) | C-derived mnemonic body |
| `opendemowrite` | [source](../src/game/symbolic/GAME.S#L21439) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L7499) | C-derived mnemonic body |
| `record` | [source](../src/game/symbolic/GAME.S#L21521) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L7530) | C-derived mnemonic body |
| `closedemowrite` | [source](../src/game/symbolic/GAME.S#L21616) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L7547) | C-derived mnemonic body |
| `playback` | [source](../src/game/symbolic/GAME.S#L21659) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L7567) | C-derived mnemonic body |
| `moveloop` | [source](../src/game/symbolic/GAME.S#L21997) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L7699) | C-derived mnemonic body |
| `fakedomovethingscorrect` | [source](../src/game/symbolic/GAME.S#L22044) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L7718) | C-derived mnemonic body |
| `fakedomovethings` | [source](../src/game/symbolic/GAME.S#L22126) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L7751) | C-derived mnemonic body |
| `domovethings` | [source](../src/game/symbolic/GAME.S#L23234) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L8189) | C-derived mnemonic body |
| `doorders` | [source](../src/game/symbolic/GAME.S#L23515) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L8317) | C-derived mnemonic body |
| `dobonus` | [source](../src/game/symbolic/GAME.S#L23759) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L8354) | C-derived mnemonic body |
| `cameratext` | [source](../src/game/symbolic/GAME.S#L25227) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L8871) | C-derived mnemonic body |
| `vglass` | [source](../src/game/symbolic/GAME.S#L25392) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L8894) | C-derived mnemonic body |
| `lotsofglass` | [source](../src/game/symbolic/GAME.S#L25472) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L8907) | C-derived mnemonic body |
| `spriteglass` | [source](../src/game/symbolic/GAME.S#L25678) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L8955) | C-derived mnemonic body |
| `ceilingglass` | [source](../src/game/symbolic/GAME.S#L25757) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L8968) | C-derived mnemonic body |
| `lotsofcolourglass` | [source](../src/game/symbolic/GAME.S#L25857) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L8997) | C-derived mnemonic body |
| `SetupGameButtons` | [source](../src/game/symbolic/GAME.S#L26059) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L9035) | C-derived mnemonic body |
| `GetTime` | [source](../src/game/symbolic/GAME.S#L26219) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L9099) | C-derived mnemonic body |
| `CenterCenter` | [source](../src/game/symbolic/GAME.S#L26224) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L9113) | C-derived mnemonic body |
| `UpperLeft` | [source](../src/game/symbolic/GAME.S#L26230) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L9126) | C-derived mnemonic body |
| `LowerRight` | [source](../src/game/symbolic/GAME.S#L26236) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L9139) | C-derived mnemonic body |
| `CenterThrottle` | [source](../src/game/symbolic/GAME.S#L26242) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L9152) | C-derived mnemonic body |
| `CenterRudder` | [source](../src/game/symbolic/GAME.S#L26248) | [C aid](../src/game/symbolic/game-C-counterpart.c.txt#L9165) | C-derived mnemonic body |
