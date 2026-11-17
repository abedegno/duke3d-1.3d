# Pinned source-object audit decoder

This profile stages the public Capstone5.0.6 Python distribution for macOS11
arm64, including its native library, headers, full package, metadata and license.
All65real distribution files are pinned in files.json. No binary is tracked.
The package was independently retained during Task99; Task370 froze its exact
identity. This is an inspection dependency, not an assembler or SDK input.

The public distribution is available as the `capstone==5.0.6` arm64 wheel from
the [Capstone5.0.6 PyPI release](https://pypi.org/project/capstone/5.0.6/).
The receipt identifies complete installed files rather than claiming an unheld
wheel/archive hash or a fresh source build. A different host distribution needs
separate review; no platform/version fallback is permitted. Unpack/install into
a private directory only, then use the closed staging command:

```
python3 profiles/capstone/setup.py --distribution <private-distribution> \
  --home toolchains/capstone
```

The source directory can contain other packages; setup copies exactly the65
pinned files. The resulting home rejects changed, missing, extra or symlinked
files. Bytecode writing is disabled before imports. A foreign already-imported
Capstone module is rejected. LIBCAPSTONE_PATH is rejected, and the actual loaded
native library plus every imported package submodule must belong to that home. Full before/after producer snapshots include every
staged decoder file and setup receipt. LICENSE.TXT remains in the staged home.
