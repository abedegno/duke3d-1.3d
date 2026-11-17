# High C DATA contribution profile

This profile builds the two authored PAWE state modules with an unmodified
MetaWare High C/C++3.31 distribution. Actual output identifies **hc2.6c and
dosomf2.10b**, unlike the target's hc2.5k/dosomf2.05b. Supported fixed flags are
`-c -O6 -386`. The target's `-X7` is unsupported by this driver and is not used.
No warning is hidden by substituting another switch.

**Final linking is blocked.** Both outputs retain the real unused EXTDEFs
`_mwargstack` and `_mwgoc`. Native WLINK treats them as undefined symbols even
without relocations; a DATA byte match does not resolve this ABI. This profile
proves complete DATA contributions, not an operational final SDK/game link.
No declarations were pruned and no guessed vendor globals/runtime was added.

## Reproduce the compiler subset

Requirements: Python3, DOSBox-X,7z and mtools `mcopy`. Supply the archive from
[the recorded download endpoint](https://winworldpc.com/download/bc9e1add-fe36-11e9-828b-fa163e9022f0/from/c3ae6ee2-8099-713d-3411-c3a6e280947e),
whose [product page](https://winworldpc.com/product/metaware-high-c-cpp/33x)
describes the damaged media. Archive size8101099 and SHA256:
`ae6fa86c8fb117602f1ef39b2bfca5ebb8790e8b71660dece522f161471674d2`.
No vendor binaries are stored in this repository.

```sh
python3 profiles/highc/setup.py --archive /path/to/metaware-3.31.7z \
  --home toolchains/highc-3.31 --work build/highc-setup
```

The pinned outer archive and all seven disk images are verified before use.
The supplied unmodified decompressor runs only a generated selection script:
all option1 records except the serializer, with an empty Finish section.
Original interactive dialogs, EULA/serial branches and global configuration
steps are absent. Original media/notices remain in the private setup stage.
This is subset extraction, not a claim that an interactive installation ran.
The decompressor changes the DOS working directory; batch status uses absolute
`C:\STATUS.TXT` and successful completion is required.

All384 output files must match the committed manifest, including libraries,
configuration, headers and compiler passes. Missing, damaged, extra or symlinked
files reject. A destination is never overwritten. The known damaged option3
RCPP stream and the bundled replacement Rcpp.zip are **not selected/repaired**;
adding any RCPP replacement to the compiler home rejects the exact file set.
Resource compilation and serialization are unsupported. Public distribution
availability does not grant new licenses; preserve the original notices.

```sh
python3 tools/probe_pawe_data.py pawe_nrpnvar --home toolchains/highc-3.31 \
  --build build/pawe-data --report build/pawe_nrpnvar.json
python3 tools/probe_pawe_data.py pawe_midivar --home toolchains/highc-3.31 \
  --build build/pawe-data --report build/pawe_midivar.json
HIGHC_HOME="$PWD/toolchains/highc-3.31" python3 -m unittest tests.test_pawe_data -v
```

Only tracked source/header/contracts/caller evidence, the target and validated
compiler/host tools are producer inputs. No original SDK or ignored prototype
is needed. Every invocation creates fresh actual output children and retains
NRPNVAR.C/MIDIVAR.C as real DOS filenames. All compiler files and staged/live
source/header/host inputs are checked before/after; helpers/target/contracts
are additionally checked by the complete producer.

Compiler stdout redirection is not a general warning-capture mechanism for
this driver. Actual errorlevel, fresh outputs, fixed supported flags, pinned
inputs and exact native metadata/whole DATA verification are required. An empty
redirected log is recorded without claiming every console message was captured.
The broader original compiler identity, final link and executable remain open.
