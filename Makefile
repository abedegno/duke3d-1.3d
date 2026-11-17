PYTHON ?= python3
PAWE_ASSETS ?= build/assets/pawe
VENDOR_PREFIX ?=
RESULT ?= build/complete-source-game-residue-preparation.json

.DEFAULT_GOAL := help
.PHONY: help rebuild source-integrity verify-rebuild test complete-source-game-residue-preparation

help:
	@echo 'Duke Nukem 3D v1.3D recovered source'
	@echo '  make source-integrity                     Check the public source snapshot'
	@echo '  make rebuild VENDOR_PREFIX=/path/prefix   Build the byte-identical executable'
	@echo '  make verify-rebuild                      Verify the complete rebuilt file'
	@echo '  make test                                Run release regressions (local dependencies required)'
	@echo 'See docs/BUILDING.md for pinned dependencies; docs/RESEARCH.md for archived recovery work.'

rebuild:
	@test -n "$(VENDOR_PREFIX)" || { echo 'Set VENDOR_PREFIX to the separately supplied DOS4GW prefix; see docs/BUILDING.md.' >&2; exit 1; }
	$(PYTHON) tools/build_complete.py --native-layout --prepare-game-residue --assets "$(PAWE_ASSETS)" --vendor-prefix "$(VENDOR_PREFIX)" --build build/complete-source-game-residue-preparation --report "$(RESULT)"

source-integrity:
	$(PYTHON) tools/verify_source_manifest.py

verify-rebuild:
	$(PYTHON) tools/verify_rebuild.py --result "$(RESULT)"

test:
	PYTHONDONTWRITEBYTECODE=1 $(PYTHON) tools/test_release.py

# Compatibility alias for the original documented exact route.
complete-source-game-residue-preparation: rebuild
