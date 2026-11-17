# Opt-in Watcom startup records

`profiles/watcom/tools/omf32.py` provides `parse_startup(data)`. It returns a
`StartupModule` envelope with the ordinary `module`, exact raw records,
annotations and a separate logical `entry`. Ordinary `Module.parse(data)` keeps
its previous subset, AST and Fixup schema and still rejects these startup inputs.

The measured profile permits only standard-OMF post-pass flags80/classFD/lowercase
`s` annotations on defined USE32 CODE, uint16 end-exclusive bounds and exact
payload exhaustion. A range closes pending data association; persistent frame
and target threads survive. It never excludes annotated bytes from verification.
Entry support is only final8A/C1/50, explicit segment, uint16 displacement inside
USE32 CODE. No synthetic fixup, inferred placement or entry/data prohibition is
introduced. Other legal but unmeasured OMF entry forms remain unsupported.

This reader does not prove complete startup ownership, zero-sized boundaries,
NULL or STACK placement/backing/combine/allocation. A4096-byte STACK declaration
and a larger linker allocation are separate obligations. No stack is dropped,
renamed BSS or treated as initialized payload. Source and supplied-runtime credit
remain unchanged. Raw335 execution1012 and the separate327 C/CRT execution42 are
distinct historical observations.

## Focused tests and observer fixtures

The eight focused tests require the authentic GA/10.5 libraries at their usual
`toolchains/` locations and a caller-supplied observer-fixture directory. Set
`OMF_STARTUP_FIXTURES`; its default is `build/startup-reader-fixtures`. Missing or
changed files fail with a concrete error, rather than silently skipping coverage.
The directory can live anywhere; no machine-specific research path appears in
the test. Files are private test observers, never source-producer inputs:

- `own335.obj` and `own335.exe`: the original authored DWORD20/22 + `END own_entry`
  fixture from Task335 (entry10; recorded DOS/4GW1012).
- `own327.exe`: the existing authored C/CRT native fixture from Task327 (entry92,
  recorded42), not a replacement success claim for the raw-entry fixture.
- `stock105-inventory.json`: Task339's independent full raw-member metadata
  observation, used to cross-check all native segments/publics/imports/fixups.

Exact SHA256 values are pinned in `tests/test_startup_reader.py`; a supplied
fixture is accepted only at that identity. Obtain these files from the retained
335/327/339 artifact packages and copy them under the fixed names above. Do not
check in copyrighted runtime/media or regenerate a different fixture and waive
its pin. The libraries' complete member identities are additionally checked.
No installer, account, serialization or EULA action is part of test setup.

```
OMF_STARTUP_FIXTURES=/path/to/fixtures python3 -m unittest tests.test_startup_reader -v
TASK353_NATIVE_FIXTURE=/path/to/retained349-native \
 PYTHONPATH=.:tests:profiles/watcom/tools:profiles/watcom/tests \
 python3 -m unittest test_easy_omf test_dosseg_metadata test_group_frames \
 test_relative_group_frames test_source_code_frames test_infer_bindings test_data_bindings -v
PYTHONPATH=.:tests:profiles/watcom/tools python3 -m unittest tests.test_logical_segment_origins -v
```

The opt-in parser itself has no fixture/file-system dependency; it consumes the
provided immutable bytes. Existing source producers continue using default
parsing. A parser identity migration must explicitly rebind active producer and
closed-origin pins, preserve historical outputs, replay affected normal sources,
and retain literal supplied-runtime components and contribution dictionaries.
The current migration baseline has134 supplied components; older133 reports
remain historical.
