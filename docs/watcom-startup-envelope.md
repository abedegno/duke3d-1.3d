# Supplied startup envelope

`tools/probe_watcom_startup.py` is a separate opt-in observer of the original
Watcom10.5 `cstrt386` contribution. It does not compile sources, change default
OMF parsing/inference/verification, register a runtime component or award source
credit. Its closed metadata profile is `profiles/watcom/startup-profile.json`.
Vendor objects remain unmodified observer inputs, not reconstructed source.

Run from the repository root, with locally installed original toolchain media
and the pinned target:

```
python3 tools/probe_watcom_startup.py --accepted-ranges /path/to/accepted-source-ranges.json --build build/startup-envelope --report build/startup-envelope-proof.json
```

The range input uses the normal `{"ranges": [...]}` ownership-ledger schema.
This profile deliberately pins all371 current accepted ranges, including NRPN,
SBKLOAD, MIDIENGINE, NOTE, DIGITAL, ZONE, DEBUG, TIME_DOS, SOUND, WSOUND, VECTOR, ROX and GF1 data-owner ranges, rather than silently accepting a smaller historical ledger. A future
accepted ledger change requires an explicit reviewed profile update. No source or
bank media are distributed by this addition. Installed original library hashes,
complete member hashes, target identity and every helper/input identity appear in
the fresh receipt. Inputs are checked before/after; publication uses a new child
only after successful verification. The public command writes only its requested
report, not canonical inventories or accounting.

## Obligations and evidence

* Fresh whole EMU12960/0/692 verification supplies an independently accepted
  `__GETDS` edge. The original startup public at TEXT716 gives base1:585500,
  agreeing with the real LE entry. All34 actual typed fields must independently
  agree; source bytes at fixup fields remain included in strict comparison.
* All18 segment declarations, group members,11 global public definitions,
  23 imports, entry metadata, pass state, annotation ranges, record framing,
  scopes and all parsed native metadata are retained exactly. The four emitted
  segments compare complete unmasked TEXT727/DATA8/BEGTEXT16/NULL4:755 bytes.
  FD-marked bytes and final TEXT bytes are included. No trim or masked region.
* DOSSEG's original zero-runtime `seg386` member has an independent exact typed
  envelope. Its nine records include the non-address ABS definition
  `__DOSseg__=1234h`, not a RAM placement. This does not extend the default parser.
  The DOSSEG directive, original `_NULL` class and actual01010100 bytes enforce
  first BEGDATA coordinate3:0. Task382's prose count of eight records was a
  counting error; the unchanged original contains nine.
* Fresh `crwd386` verification accounts its separate65 DATA bytes and one-byte
  CODE return, plus its one pointer fixup. EMU's real FPE-handler anchor and the
  actual LE pointer field derive these placements. These66 bytes are not added
  to startup's755 counter. All four unused startup import declarations remain,
  including the ABS DOSSEG dependency; no fake zero-address imports are supplied.
* `__start_TI`/`__end_TI` and all13 zero-sized segment definitions retain their
  real source coordinates. No independent target address is claimed for those
  unused zero-sized publics. They are excluded from target anchor exports.
  A future actual consumer must supply its own strict binding; source-coordinate
  preservation cannot satisfy such an edge. This does not recover historical
  empty-boundary addresses or final link padding/member selection.

## STACK is a separate storage contract

The exact original STACK/STACK declaration is paragraph-aligned, combine5,
USE32,4096 bytes, and has no initialized-data record or fixup. It is neither
4851 initialized bytes nor renamed BSS. Three actual `_end` fields agree at
3:2132988; paragraph alignment gives2132992. LE SS/ESP and object3 extent both
end at2184192. The separate linked reservation is therefore51200 bytes, with
47104 bytes of linker enlargement beyond the input declaration. This gate
supports only that single measured input and reservation, not arbitrary STACK
combination, extra contributions or arbitrary requested sizes.

Every byte of that reservation must be unbacked, have no loader writes and fit
inside the real object. Both initialized contributions and the entire reservation
must avoid all371 accepted source ranges and all134 freshly replayed supplied
runtime components. The four-byte alignment gap after `_end` is not claimed as
startup payload. Same-DGROUP comparisons retain the default requirement for an
explicit STACK placement; omission still fails. The unbacked runtime call stack's
usable size is not claimed: heap/runtime stack boundary fields remain ordinary
verified startup operations, not additional allocated input storage.

The retained327/374 native witnesses use identical own source and three objects.
Only documented `stack=4096` becomes `stack=50k`; both recorded runs exited42,
CODE is literal-equal, and their MAP/LE reservations agree. Tests observe these
frozen records without assembling, relinking or executing anything. This proves
that the documented policy can produce the measured allocation; it does not
uniquely recover the target's historical linker command/version.

## Focused verification

Tests require original installed media, the range ledger above and portable
copies of existing native observer witnesses. Missing fixtures fail explicitly;
there are no skips or implicit downloads:

```
STARTUP_ACCEPTED_RANGES=/path/to/accepted-source-ranges.json STARTUP_NATIVE_WITNESSES=/path/to/native-witnesses python3 -m unittest tests.test_watcom_startup -v
```

`native-witnesses/{stack4096,stack50k}` each contains the exact pinned MAIN.C,
DOUBLE.C, OWNCALL.ASM, their three OBJ files, OWN.LNK, OWN.MAP, OWN.EXE and
STATUS.TXT from Task327/374. The tests contain their immutable hashes. No original
SDK or target instruction payload becomes a producer input. Controls damage
annotated/tail/NULL/DATA bytes; typed fields, scopes, empty metadata and entry;
STACK extent, combine, backing, top, object, loader writes and overlap; missing
current ranges; helper/profile identity and a real input race before publication.

A positive receipt proves the stated complete emitted contribution plus this
explicit storage policy. It is not generic `verify_module` success, supplied
inventory credit, source reconstruction, complete runtime selection, or a rebuilt
whole executable. The default verifier's CLASSSTACK behavior remains unchanged.
