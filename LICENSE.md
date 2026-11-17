# Component licensing

This is a collection of reconstructed and historical sources with different terms. Existing file notices and the component licences remain authoritative; this file does not relicense them.

| Component | Terms / notice |
| --- | --- |
| Duke Nukem 3D game code and released Apogee audio/control sources | Original GPL notices; generally GPL-2.0-or-later. See `COPYING` and file headers. |
| Build engine and cache contributions | Ken Silverman's Build source licence, retained in `src/engine/BUILDLIC.TXT` and `src/cache/BUILDLIC.TXT`. It includes noncommercial and Internet-distribution conditions. |
| Watcom-derived runtime source | Original Sybase Open Watcom Public License, retained in `src/runtime/license.txt`; headers retain their notices. |
| Exhume and reference submodules | Each upstream project's own terms and notices. A submodule pin grants no additional rights. |
| Verified snapshot helper (`tools/verified_snapshot.py`) | MIT, reused from Exhume; its copyright and full permission notice are retained in the file. |
| New release-maintenance scripts | GPL-2.0-or-later; existing reconstruction tooling retains any notices already present. |
| FORTE/Gravis and Creative vendor-derived source overlay | **Not included in the public repository.** Original notices have restrictions that require separate treatment. A manifest or importer grants no rights. |
| Historical compilers, assemblers, stock runtime libraries and DOS4GW prefix | User-supplied dependencies under their original terms; binaries are not included. |
| Creative/E-mu banks and Duke Nukem game data | User-supplied assets under their original terms; not included. |

The FORTE notice accompanying the local GF1 sources restricts providing the software to others. The Creative material also retains separate notices. Public availability of an upstream archive is not treated as permission to relicense or redistribute it. The local dependency overlay conservatively keeps these source families and their associated reconstruction material outside public Git history.

The overlay is a project-specific source tree, not a generic SDK. Users must obtain it through a channel that permits their use. No automatic licence acceptance, credential use, or installer execution is performed by this repository.

Source reconstruction does not establish unique historical spelling, ownership of third-party work, or new rights in the game. Copyright and trademark notices are preserved.
