PYTHON ?= python3
WATCOM_HOME ?= $(CURDIR)/toolchains/watcom-10.0-ga
WATCOM_100A_HOME ?= $(CURDIR)/toolchains/watcom-10.0a
WATCOM_100B_HOME ?= $(CURDIR)/toolchains/watcom-10.0b
WATCOM_105_HOME ?= $(CURDIR)/toolchains/watcom-10.5
TASM_HOME ?= $(CURDIR)/toolchains/tasm-3.1
MASM_HOME ?= $(CURDIR)/toolchains/masm-5.10

.PHONY: prepare-profile test inspect proof sibling candidates engine-probe proof-rts proof-animlib proof-ll-man proof-task-man proof-dpmi proof-mpu401 proof-pitch proof-dma proof-sndsrc proof-irq proof-sndscape proof-blaster proof-al-midi proof-midi proof-guswave proof-pas16 proof-cache1d proof-fx-man proof-awe32 proof-music proof-multivoc proof-mv-mix proof-mv-mix16 proof-mvreverb proof-audio-assembly proof-gus proof-gusmidi proof-user proof-gmtimbre proof-engine-asm proof-mmulti proof-sounds proof-config proof-gamedef proof-sector proof-actors proof-player proof-premap proof-debugio proof-menues proof-watcom-rand proof-gf1-mixer proof-gf1-uart proof-gf1-rec proof-gf1-timer proof-gf1-addr proof-gf1-dma1 proof-gf1-error proof-mact-asm proof-mact-crc proof-mact-mathutil proof-mact-random proof-mact-util proof-mact-file proof-mact-rgb proof-gf1-scale proof-gf1-divisor proof-gf1-utils proof-modules

prepare-profile:
	$(PYTHON) tools/prepare_profile.py

test: prepare-profile
	$(PYTHON) -m unittest discover -s tests -v
	WATCOM_HOME="$(WATCOM_HOME)" $(PYTHON) -m unittest discover -s profiles/watcom/tests -v

inspect: prepare-profile
	$(PYTHON) tools/inspect_target.py reference/DUKE3D.EXE

proof: prepare-profile
	$(PYTHON) tools/prove_functions.py --home "$(WATCOM_HOME)"

engine-probe: prepare-profile
	$(PYTHON) tools/probe_engine.py --home "$(WATCOM_105_HOME)"

sibling: prepare-profile
	$(PYTHON) tools/build_sibling.py --home "$(WATCOM_HOME)"

candidates: prepare-profile
	$(PYTHON) -m tools.map_candidates

proof-rts: prepare-profile
	$(PYTHON) tools/prove_rts.py --home "$(WATCOM_HOME)"

proof-animlib: prepare-profile
	$(PYTHON) tools/prove_module.py animlib --home "$(WATCOM_HOME)"

proof-ll-man: prepare-profile
	$(PYTHON) tools/prove_module.py ll_man --home "$(WATCOM_HOME)"

proof-task-man: prepare-profile
	$(PYTHON) tools/prove_module.py task_man --home "$(WATCOM_105_HOME)"

proof-dpmi: prepare-profile
	$(PYTHON) tools/prove_module.py dpmi --home "$(WATCOM_HOME)"

proof-mpu401: prepare-profile
	$(PYTHON) tools/prove_module.py mpu401 --home "$(WATCOM_HOME)"

proof-pitch: prepare-profile
	$(PYTHON) tools/prove_module.py pitch --home "$(WATCOM_HOME)"

proof-dma: prepare-profile
	$(PYTHON) tools/prove_module.py dma --home "$(WATCOM_HOME)"

proof-sndsrc: prepare-profile
	$(PYTHON) tools/prove_module.py sndsrc --home "$(WATCOM_HOME)"

proof-irq: prepare-profile
	$(PYTHON) tools/prove_module.py irq --home "$(WATCOM_105_HOME)"

proof-sndscape: prepare-profile
	$(PYTHON) tools/prove_module.py sndscape --home "$(WATCOM_100A_HOME)"

proof-blaster: prepare-profile
	$(PYTHON) tools/prove_module.py blaster --home "$(WATCOM_100A_HOME)"

proof-al-midi: prepare-profile
	$(PYTHON) tools/prove_module.py al_midi --home "$(WATCOM_100A_HOME)"

proof-midi: prepare-profile
	$(PYTHON) tools/prove_module.py midi --home "$(WATCOM_100A_HOME)"

proof-guswave: prepare-profile
	$(PYTHON) tools/prove_module.py guswave --home "$(WATCOM_100A_HOME)"

proof-pas16: prepare-profile
	$(PYTHON) tools/prove_module.py pas16 --home "$(WATCOM_100A_HOME)"

proof-cache1d: prepare-profile
	$(PYTHON) tools/prove_module.py cache1d --home "$(WATCOM_HOME)"

proof-fx-man: prepare-profile
	$(PYTHON) tools/prove_module.py fx_man --home "$(WATCOM_HOME)"

proof-awe32: prepare-profile
	$(PYTHON) tools/prove_module.py awe32 --home "$(WATCOM_100A_HOME)"

proof-music: prepare-profile
	$(PYTHON) tools/prove_module.py music --home "$(WATCOM_100B_HOME)"

proof-multivoc: prepare-profile
	$(PYTHON) tools/prove_module.py multivoc --home "$(WATCOM_100B_HOME)"

proof-mv-mix: prepare-profile
	$(PYTHON) tools/prove_module.py mv_mix --home "$(TASM_HOME)"

proof-mv-mix16: prepare-profile
	$(PYTHON) tools/prove_module.py mv_mix16 --home "$(TASM_HOME)"

proof-mvreverb: prepare-profile
	$(PYTHON) tools/prove_module.py mvreverb --home "$(TASM_HOME)"

proof-audio-assembly: proof-mv-mix proof-mv-mix16 proof-mvreverb

proof-gus: prepare-profile
	$(PYTHON) tools/prove_module.py gus --home "$(WATCOM_100B_HOME)"

proof-gusmidi: prepare-profile
	$(PYTHON) tools/prove_module.py gusmidi --home "$(WATCOM_100B_HOME)"

proof-user: prepare-profile
	$(PYTHON) tools/prove_module.py user --home "$(WATCOM_100B_HOME)"

proof-gmtimbre: prepare-profile
	$(PYTHON) tools/prove_module.py gmtimbre --home "$(WATCOM_HOME)"

proof-engine-asm: prepare-profile
	$(PYTHON) tools/prove_module.py engine_asm --home "$(MASM_HOME)"

proof-mmulti: prepare-profile
	$(PYTHON) tools/prove_module.py mmulti --home "$(WATCOM_105_HOME)"

proof-sounds: prepare-profile
	$(PYTHON) tools/prove_module.py sounds --home "$(WATCOM_HOME)"

proof-config: prepare-profile
	$(PYTHON) tools/prove_module.py config --home "$(WATCOM_HOME)"

proof-gamedef: prepare-profile
	$(PYTHON) tools/prove_module.py gamedef --home "$(WATCOM_HOME)"

proof-sector: prepare-profile
	$(PYTHON) tools/prove_module.py sector --home "$(WATCOM_HOME)"

proof-actors: prepare-profile
	$(PYTHON) tools/prove_module.py actors --home "$(WATCOM_HOME)"

proof-player: prepare-profile
	$(PYTHON) tools/prove_module.py player --home "$(WATCOM_HOME)"

proof-premap: prepare-profile
	$(PYTHON) tools/prove_module.py premap --home "$(WATCOM_HOME)"

proof-debugio: prepare-profile
	$(PYTHON) tools/prove_module.py debugio --home "$(WATCOM_100B_HOME)"

proof-menues: prepare-profile
	$(PYTHON) tools/prove_module.py menues --home "$(WATCOM_HOME)"

proof-watcom-rand: prepare-profile
	$(PYTHON) tools/prove_module.py watcom_rand --home "$(WATCOM_HOME)"

proof-gf1-mixer: prepare-profile
	$(PYTHON) tools/prove_module.py gf1_mixer --home "$(WATCOM_HOME)"

proof-gf1-uart: prepare-profile
	$(PYTHON) tools/prove_module.py gf1_uart --home "$(WATCOM_HOME)"

proof-gf1-rec: prepare-profile
	$(PYTHON) tools/prove_module.py gf1_rec --home "$(WATCOM_HOME)"

proof-gf1-timer: prepare-profile
	$(PYTHON) tools/prove_module.py gf1_timer --home "$(WATCOM_HOME)"

proof-gf1-addr: prepare-profile
	$(PYTHON) tools/prove_module.py gf1_addr --home "$(WATCOM_HOME)"

proof-gf1-dma1: prepare-profile
	$(PYTHON) tools/prove_module.py gf1_dma1 --home "$(WATCOM_HOME)"

proof-gf1-error: prepare-profile
	$(PYTHON) tools/prove_module.py gf1_error --home "$(WATCOM_HOME)"

proof-mact-asm: prepare-profile
	$(PYTHON) tools/probe_mact_asm.py --build build/mact-asm-proof --report evidence/mact-asm-progress.json

proof-mact-crc: prepare-profile
	$(PYTHON) tools/prove_module.py mact_crc --home "$(WATCOM_HOME)"

proof-mact-mathutil: prepare-profile
	$(PYTHON) tools/prove_module.py mact_mathutil --home "$(WATCOM_HOME)"

proof-mact-random: prepare-profile
	$(PYTHON) tools/prove_module.py mact_random --home "$(WATCOM_HOME)"

proof-mact-util: prepare-profile
	$(PYTHON) tools/prove_module.py mact_util --home "$(WATCOM_HOME)"

proof-mact-file: prepare-profile
	$(PYTHON) tools/prove_module.py mact_file --home "$(WATCOM_HOME)"

proof-mact-rgb: prepare-profile
	$(PYTHON) tools/prove_module.py mact_rgb --home "$(WATCOM_HOME)"

proof-gf1-scale: prepare-profile
	$(PYTHON) tools/prove_module.py gf1_scale --home "$(WATCOM_HOME)"

proof-gf1-divisor: prepare-profile
	$(PYTHON) tools/prove_module.py gf1_divisor --home "$(WATCOM_HOME)"

proof-gf1-utils: prepare-profile
	$(PYTHON) tools/prove_module.py gf1_utils --home "$(WATCOM_HOME)"

proof-modules: proof-rts proof-animlib proof-ll-man proof-task-man proof-dpmi proof-mpu401 proof-pitch proof-dma proof-sndsrc proof-irq proof-sndscape proof-blaster proof-al-midi proof-midi proof-guswave proof-pas16 proof-cache1d proof-fx-man proof-awe32 proof-music proof-multivoc proof-audio-assembly proof-gus proof-gusmidi proof-user proof-gmtimbre proof-engine-asm proof-mmulti proof-sounds proof-config proof-gamedef proof-sector proof-actors proof-player proof-premap proof-debugio proof-menues proof-watcom-rand proof-gf1-mixer proof-gf1-uart proof-gf1-rec proof-gf1-timer proof-gf1-addr proof-gf1-dma1 proof-gf1-error proof-mact-asm proof-mact-crc proof-mact-mathutil proof-mact-random proof-mact-util proof-mact-file proof-mact-rgb proof-gf1-scale proof-gf1-divisor proof-gf1-utils

.PHONY: proof-mact-keyboard
proof-mact-keyboard:
	$(PYTHON) tools/prove_module.py mact_keyboard --home "$(WATCOM_HOME)"

.PHONY: proof-gf1-globals
proof-gf1-globals:
	$(PYTHON) tools/prove_module.py gf1_globals --home "$(WATCOM_HOME)"

proof-modules: proof-mact-keyboard proof-gf1-globals

PAWE_EMBED_ASSETS ?= $(CURDIR)/build/assets/pawe
.PHONY: proof-gf1-init proof-pawe-embed
proof-gf1-init:
	$(foreach module,gf1_wtimer gf1_wdma gf1_wmem gf1_wnote gf1_wvoic gf1_wuart,$(PYTHON) tools/prove_module.py $(module) --home "$(TASM_HOME)" && ) true

proof-pawe-embed:
	$(PYTHON) tools/probe_pawe_embed.py prove --home "$(WATCOM_HOME)" --peer-home "$(WATCOM_100A_HOME)" --assets "$(PAWE_EMBED_ASSETS)" --build "$(CURDIR)/build/pawe-embed-proof" --report "$(CURDIR)/evidence/pawe_embed-module.json"

proof-modules: proof-gf1-init proof-pawe-embed

.PHONY: proof-gf1-sem
proof-gf1-sem:
	$(PYTHON) tools/prove_module.py gf1_sem --home "$(TASM_HOME)"

proof-modules: proof-gf1-sem

.PHONY: proof-pawe-states
proof-pawe-states:
	$(PYTHON) tools/probe_pawe_states.py prove --home "$(WATCOM_HOME)" --peer-home "$(WATCOM_100A_HOME)" --build "$(CURDIR)/build/pawe-states-proof" --report "$(CURDIR)/evidence/pawe-state-native-modules.json"

proof-modules: proof-pawe-states

.PHONY: proof-gf1-isr
proof-gf1-isr:
	$(PYTHON) tools/prove_module.py gf1_isr --home "$(WATCOM_HOME)"

proof-modules: proof-gf1-isr

.PHONY: proof-mact-scriplib
proof-mact-scriplib:
	$(PYTHON) tools/prove_module.py mact_scriplib --home "$(WATCOM_HOME)"

proof-modules: proof-mact-scriplib

.PHONY: proof-mact-tokenlib
proof-mact-tokenlib:
	$(PYTHON) tools/prove_module.py mact_tokenlib --home "$(WATCOM_HOME)"

proof-modules: proof-mact-tokenlib

.PHONY: proof-gf1-wave
proof-gf1-wave: prepare-profile
	$(PYTHON) tools/prove_module.py gf1_wave --home "$(WATCOM_HOME)"

proof-modules: proof-gf1-wave

.PHONY: proof-gf1-mem
proof-gf1-mem: prepare-profile
	$(PYTHON) tools/prove_module.py gf1_mem --home "$(WATCOM_HOME)"

proof-modules: proof-gf1-mem

.PHONY: proof-gf1-voice proof-gf1-wisr
proof-gf1-voice: prepare-profile
	$(PYTHON) tools/prove_module.py gf1_voice --home "$(WATCOM_HOME)"

proof-gf1-wisr: prepare-profile
	$(PYTHON) tools/prove_module.py gf1_wisr --home "$(WATCOM_HOME)"

proof-modules: proof-gf1-voice proof-gf1-wisr

.PHONY: proof-gf1-note1
proof-gf1-note1: prepare-profile
	$(PYTHON) tools/prove_module.py gf1_note1 --home "$(WATCOM_HOME)"

proof-modules: proof-gf1-note1

.PHONY: proof-gf1-patch
proof-gf1-patch: prepare-profile
	$(PYTHON) tools/prove_module.py gf1_patch --home "$(WATCOM_HOME)"

proof-modules: proof-gf1-patch

.PHONY: proof-gf1-pat1
proof-gf1-pat1: prepare-profile
	$(PYTHON) tools/prove_module.py gf1_pat1 --home "$(WATCOM_HOME)"

proof-modules: proof-gf1-pat1

.PHONY: proof-gf1-midi
proof-gf1-midi: prepare-profile
	$(PYTHON) tools/prove_module.py gf1_midi --home "$(WATCOM_HOME)"

proof-modules: proof-gf1-midi

.PHONY: proof-gf1-ainit
proof-gf1-ainit:
	$(PYTHON) tools/prove_module.py gf1_ainit --home "$(TASM_HOME)"

proof-modules: proof-gf1-ainit

.PHONY: proof-gf1-digpause proof-gf1-digpos
proof-gf1-digpause: prepare-profile
	$(PYTHON) tools/prove_module.py gf1_digpause --home "$(WATCOM_HOME)"

proof-gf1-digpos: prepare-profile
	$(PYTHON) tools/prove_module.py gf1_digpos --home "$(WATCOM_HOME)"

proof-modules: proof-gf1-digpause proof-gf1-digpos

.PHONY: proof-gf1-detct
proof-gf1-detct:
	$(PYTHON) tools/prove_module.py gf1_detct --home "$(WATCOM_HOME)"

proof-modules: proof-gf1-detct

GF1_OS_BUILD ?= $(CURDIR)/build/gf1-os-candidate
.PHONY: candidate-gf1-os candidate-gf1-os-observe
candidate-gf1-os:
	$(PYTHON) tools/build_gf1_os_candidate.py --home "$(WATCOM_HOME)" --build "$(GF1_OS_BUILD)"

candidate-gf1-os-observe:
	$(PYTHON) tools/build_gf1_os_candidate.py --home "$(WATCOM_HOME)" --build "$(GF1_OS_BUILD)" --observe

.PHONY: proof-mact-vidmsdos
proof-mact-vidmsdos:
	$(PYTHON) -m tools.prove_module mact_vidmsdos --home $(WATCOM_HOME) --build build/mact-vidmsdos-proof --report evidence/mact-vidmsdos-module.json

proof-modules: proof-mact-vidmsdos

CONTROL_BUILD ?= build/mact-control-candidate
CONTROL_REFERENCE_ROOT ?= reference
.PHONY: candidate-mact-control candidate-mact-control-observe
candidate-mact-control:
	$(PYTHON) tools/build_control_candidate.py --home "$(WATCOM_HOME)" --build "$(CONTROL_BUILD)"

candidate-mact-control-observe:
	$(PYTHON) tools/build_control_candidate.py --home "$(WATCOM_HOME)" --build "$(CONTROL_BUILD)" --reference-root "$(CONTROL_REFERENCE_ROOT)" --observe

.PHONY: proof-gf1-dram
proof-gf1-dram:
	$(PYTHON) -m tools.prove_module gf1_dram --home $(WATCOM_HOME) --build build/gf1-dram-proof --report evidence/gf1_dram-module.json

proof-modules: proof-gf1-dram

GNU_OMF_HOME ?= $(CURDIR)/toolchains/gnu-omf
.PHONY: proof-pawe-hardware
proof-pawe-hardware:
	$(PYTHON) tools/prove_module.py pawe_hardware --home "$(GNU_OMF_HOME)"

proof-modules: proof-pawe-hardware

.PHONY: proof-pawe-nrpn
proof-pawe-nrpn:
	$(PYTHON) tools/prove_module.py pawe_nrpn --home "$(GNU_OMF_HOME)"

proof-modules: proof-pawe-nrpn

# Complete symbolic SBKLOAD source; original/target are observer-only.
.PHONY: proof-pawe-sbkload
proof-pawe-sbkload:
	$(PYTHON) tools/prove_module.py pawe_sbkload --home "$(GNU_OMF_HOME)"

proof-modules: proof-pawe-sbkload

.PHONY: proof-pawe-midieng
proof-pawe-midieng:
	$(PYTHON) tools/prove_module.py pawe_midieng --home "$(GNU_OMF_HOME)"

proof-modules: proof-pawe-midieng

.PHONY: proof-mact-zone
proof-mact-zone:
	$(PYTHON) tools/prove_module.py mact_zone --home "$(GNU_OMF_HOME)"

proof-modules: proof-mact-zone
# Complete authored DIGITAL source; original/caller/target are observer-only.
.PHONY: proof-gf1-digital
proof-gf1-digital:
	$(PYTHON) tools/prove_module.py gf1_digital --home "$(GNU_OMF_HOME)"

proof-modules: proof-gf1-digital
# Complete symbolic NOTE owner; retained partial C family remains separate.
.PHONY: proof-gf1-note
proof-gf1-note:
	$(PYTHON) tools/prove_module.py gf1_note --home "$(GNU_OMF_HOME)"

proof-modules: proof-gf1-note

# Complete primary table/initializer; caller and target are observer-only.
.PHONY: proof-gf1-voltab proof-gf1-wdigital
proof-gf1-voltab:
	$(PYTHON) tools/prove_module.py gf1_voltab --home "$(WATCOM_HOME)"

proof-gf1-wdigital:
	$(PYTHON) tools/prove_module.py gf1_wdigital --home "$(TASM_HOME)"

proof-modules: proof-gf1-voltab proof-gf1-wdigital

.PHONY: proof-mact-debug
proof-mact-debug:
	$(PYTHON) tools/prove_module.py mact_debug --home "$(GNU_OMF_HOME)"

proof-modules: proof-mact-debug

# Complete ordinary-C TIME_DOS source; reference observer follows production.
.PHONY: proof-mact-time
proof-mact-time:
	$(PYTHON) tools/prove_module.py mact_time --home "$(WATCOM_HOME)"

proof-modules: proof-mact-time

.PHONY: proof-gf1-sound
proof-gf1-sound:
	$(PYTHON) tools/prove_module.py gf1_sound --home "$(GNU_OMF_HOME)"

proof-modules: proof-gf1-sound

.PHONY: proof-gf1-wsound
proof-gf1-wsound:
	$(PYTHON) tools/prove_module.py gf1_wsound --home "$(TASM_HOME)"

proof-modules: proof-gf1-wsound

.PHONY: proof-mact-vector
proof-mact-vector:
	$(PYTHON) tools/prove_module.py mact_vector --home "$(WATCOM_HOME)"

proof-modules: proof-mact-vector

.PHONY: proof-game game-source-only
proof-game:
	$(PYTHON) tools/probe_game.py --home "$(WATCOM_HOME)" --build build/game-compound-proof --report evidence/game-progress.json

game-source-only:
	$(PYTHON) tools/build_game_compound.py --home "$(WATCOM_HOME)" --build build/game-compound-source --report build/game-compound-source.json

GNU_ELF_OMF_HOME ?= toolchains/gnu-elf-omf

.PHONY: proof-mact-rox
proof-mact-rox:
	$(PYTHON) tools/prove_module.py mact_rox --home "$(GNU_ELF_OMF_HOME)"

proof-modules: proof-mact-rox

.PHONY: proof-mact-taskman-late
proof-mact-taskman-late:
	$(PYTHON) tools/probe_mact_taskman_late.py --home toolchains/watcom-10.5 --build build/mact-taskman-late-proof --report evidence/mact-taskman-late-module.json


.PHONY: proof-mact-tlibdos
proof-mact-tlibdos:
	$(PYTHON) tools/prove_module.py mact_tlibdos --home "$(GNU_ELF_OMF_HOME)"

proof-modules: proof-mact-tlibdos


.PHONY: proof-mact-wad
proof-mact-wad:
	$(PYTHON) tools/prove_module.py mact_wad --home "$(GNU_ELF_OMF_HOME)"

proof-modules: proof-mact-wad


GNU_ELF_IMPORTS_HOME ?= toolchains/gnu-elf-omf-imports
.PHONY: proof-mact-penttime
proof-mact-penttime:
	$(PYTHON) tools/prove_module.py mact_penttime --home "$(GNU_ELF_IMPORTS_HOME)"

proof-modules: proof-mact-penttime


.PHONY: proof-mact-mipmap
proof-mact-mipmap:
	$(PYTHON) tools/prove_module.py mact_mipmap --home "$(GNU_ELF_IMPORTS_HOME)"

proof-modules: proof-mact-mipmap

.PHONY: proof-mact-clrmap
proof-mact-clrmap:
	$(PYTHON) tools/prove_module.py mact_clrmap --home "$(GNU_ELF_IMPORTS_HOME)"

proof-modules: proof-mact-clrmap


.PHONY: proof-mact-lbmlib
proof-mact-lbmlib:
	$(PYTHON) tools/prove_module.py mact_lbmlib --home "$(GNU_ELF_IMPORTS_HOME)"

proof-modules: proof-mact-lbmlib

.PHONY: proof-mact-anim-late
proof-mact-anim-late:
	$(PYTHON) tools/probe_mact_anim_late.py --elf-home "$(GNU_ELF_OMF_HOME)" --watcom-home "$(WATCOM_HOME)" --build build/mact-anim-late-proof --report evidence/mact-anim-late-module.json

proof-modules: proof-mact-anim-late

.PHONY: proof-mact-control
proof-mact-control:
	$(PYTHON) tools/prove_module.py mact_control --home "$(GNU_ELF_OMF_HOME)"

proof-modules: proof-mact-control

.PHONY: proof-gf1-dma proof-gf1-utils-native
proof-gf1-dma:
	$(PYTHON) tools/prove_module.py gf1_dma --home "$(GNU_ELF_IMPORTS_HOME)"
proof-gf1-utils-native:
	$(PYTHON) tools/prove_module.py gf1_utils_native --home "$(GNU_ELF_OMF_HOME)"
proof-modules: proof-gf1-dma proof-gf1-utils-native

.PHONY: proof-gf1-os-preserved source-gf1-os-preserved
proof-gf1-os-preserved:
	$(PYTHON) tools/build_gf1_os_preserved.py --home "$(WATCOM_HOME)" --build build/gf1-os-preserved-proof --report evidence/gf1_os_preserved-module.json
source-gf1-os-preserved:
	$(PYTHON) tools/build_gf1_os_preserved.py --source-only --home "$(WATCOM_HOME)" --build build/gf1-os-preserved-source --report build/gf1-os-preserved-source.json

.PHONY: source-unidentified-data proof-unidentified-data
source-unidentified-data:
	$(PYTHON) tools/build_unidentified_data.py --source-only --home "$(GNU_ELF_OMF_HOME)" --build build/unidentified-data --report build/unidentified-data-source.json
proof-unidentified-data:
	$(PYTHON) tools/build_unidentified_data.py --home "$(GNU_ELF_OMF_HOME)" --build build/unidentified-data --report build/unidentified-data-proof.json

# IRQ's normal NASM backend retains a separately compiled genuine C reference.
.PHONY: irq-symbolic-source-only proof-irq-c-reference
irq-symbolic-source-only:
	$(PYTHON) tools/probe_irq_symbolic.py --home "$(WATCOM_105_HOME)" --build build/irq-symbolic-source --report build/irq-symbolic-source.json --source-only

.PHONY: source-gf1-note-elf
source-gf1-note-elf:
	$(PYTHON) tools/build_gf1_note_elf.py --home "$(GNU_ELF_OMF_HOME)" --build build/gf1-note-elf-source --report build/gf1-note-elf-source.json

.PHONY: source-gf1-digital-elf source-gf1-sound-elf
source-gf1-digital-elf:
	$(PYTHON) tools/build_gf1_digital_elf.py --home "$(GNU_ELF_OMF_HOME)" --build build/gf1-digital-elf-source --report build/gf1-digital-elf-source.json
source-gf1-sound-elf:
	$(PYTHON) tools/build_gf1_sound_elf.py --home "$(GNU_ELF_OMF_HOME)" --build build/gf1-sound-elf-source --report build/gf1-sound-elf-source.json

.PHONY: source-mact-zone-elf source-mact-debug-elf
source-mact-zone-elf:
	$(PYTHON) tools/build_mact_zone_elf.py --home "$(GNU_ELF_OMF_HOME)" --build build/mact-zone-elf-source --report build/mact-zone-elf-source.json
source-mact-debug-elf:
	$(PYTHON) tools/build_mact_debug_elf.py --home "$(GNU_ELF_OMF_HOME)" --build build/mact-debug-elf-source --report build/mact-debug-elf-source.json

.PHONY: prepare-stock-runtime
prepare-stock-runtime:
	$(PYTHON) tools/prepare_stock_runtime.py --build build/stock-runtime --report build/stock-runtime-inputs.json

proof-irq-c-reference:
	$(PYTHON) tools/probe_audio_layout.py irq --home "$(WATCOM_105_HOME)" --build build/irq-c-reference --report build/irq-c-reference.json

GAME_GNU_HOME ?= toolchains/gnu-elf-omf-game
CAPSTONE_HOME ?= toolchains/capstone

.PHONY: game-symbolic-source-only
game-symbolic-source-only:
	$(PYTHON) tools/build_game_symbolic.py --home "$(GAME_GNU_HOME)" --decoder-home "$(CAPSTONE_HOME)" --watcom-home "$(WATCOM_HOME)" --build build/game-symbolic-source --report build/game-symbolic-source.json

PAWE_ASSETS ?= build/assets/pawe

.PHONY: complete-source
complete-source:
	$(PYTHON) tools/build_complete.py --assets "$(PAWE_ASSETS)" --vendor-prefix "$(VENDOR_PREFIX)" --build build/complete-source --report build/complete-source.json

.PHONY: complete-source-native-layout
complete-source-native-layout:
	$(PYTHON) tools/build_complete.py --native-layout --assets "$(PAWE_ASSETS)" --vendor-prefix "$(VENDOR_PREFIX)" --build build/complete-source-native-layout --report build/complete-source-native-layout.json

.PHONY: complete-source-game-residue-preparation
complete-source-game-residue-preparation:
	$(PYTHON) tools/build_complete.py --native-layout --prepare-game-residue --assets "$(PAWE_ASSETS)" --vendor-prefix "$(VENDOR_PREFIX)" --build build/complete-source-game-residue-preparation --report build/complete-source-game-residue-preparation.json

# Release entry points; original diagnostic and matching routes remain available.
.PHONY: rebuild source-integrity verify-rebuild
rebuild: complete-source-game-residue-preparation
source-integrity:
	$(PYTHON) tools/verify_source_manifest.py
verify-rebuild:
	$(PYTHON) tools/verify_rebuild.py --result build/complete-source-game-residue-preparation.json
