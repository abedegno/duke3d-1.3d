# Contributing

Preserve original notices and distinguish reconstructed behaviour from historical source claims. Public contributions must not include the local vendor overlay, compiler binaries/libraries, banks, game media, target executables or generated build artifacts.

For a change to emitting source, compiler options, layout, or the build recipe:

1. Explain the source/provenance and behaviour being changed.
2. Run the relevant component tests and full source contribution checks.
3. Rebuild with the declared dependencies and verify the entire executable using `tools/verify_rebuild.py`.
4. Record the resulting size, SHA-256 and the tested tool identities.

Do not update a hash merely to silence a failed source contract. Matching proofs must still cover bytes, typed relocation roles, public/private scope and declared storage. The full target comparison remains unmasked. Never introduce instruction byte arrays, fake exported aliases, executable patches or cached research objects as source.

Documentation changes do not require a full historical compiler rebuild. Update the public snapshot manifest deliberately when its included files change. CI checks that manifest and publication boundaries; the complete game build needs separately supplied inputs.

Further C lowering is welcome when it preserves the byte identity gate and remains readable. Keep the matching named assembly and C aids available until the replacement is proved.
