# Complete ordinary-C MACT DOS timer recovery

`time_dos.c` is the reviewed reconstructed implementation, not discovery of the
original MACT file. Full released 3D Realms notices and GPL remain in the C,
three unchanged primary headers and gpl.txt. Headers exactly match released
extras/TYPES.H, TIMER.H and TASK_MAN.H; GPL matches audiolib/gpl.txt. No new
license/redistribution claim is made.

Three real functions and private TimeStarted/ten Timer records naturally emit
228CODE/4DATA/80BSS/16fields under authentic GA /omaxnet /zp4 /5r. Callback
IncrementCounter remains private and increments caller's volatile int32 through
real task.data. Lazy initialization, priority1 scheduling/dispatch, removal,
shutdown and original TimeStarted-not-reset behavior are preserved. There are
no fake fields, new branches, aliases, ASM or target instruction/data arrays.

The source-only producer consumes tracked C/headers/notices and unmodified GA
home, with whole-home hashes before/after, explicit emulator identity and fresh
native child. No SDK/target/caller is read during generation. Original MACT
member and actual accepted normal TASK_MAN caller witness enter only afterward.
Two typed callback self-edge candidates are nominations, followed by complete
unmasked original/source proof. Private identities never become caller anchors.

Task433 and independent review are provenance history, not ignored producer or
observer dependencies. Final member selection/link/layout/full EXE remains a
separate obligation; source credit remains zero pending independent acceptance.
