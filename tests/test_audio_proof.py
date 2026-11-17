from pathlib import Path
import tempfile
import unittest
from tools.prove_module import ROOT, prove


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe').is_file(),
                     'private target and historical compiler required')
class AudioProofTests(unittest.TestCase):
    def test_complete_linked_list_contribution(self):
        with tempfile.TemporaryDirectory() as directory:
            report=prove('ll_man',ROOT/'toolchains/watcom-10.0-ga',Path(directory))
        v=report['verification']
        self.assertIs(v['verified'],True)
        self.assertEqual((v['initialized_bytes'],v['zero_fill_bytes'],v['verified_fixups']),
                         (185,0,6))
        self.assertEqual(v['publics']['LL_AddNode_'],(1,515184))
        self.assertEqual(v['publics']['LL_RemoveNode_'],(1,515224))
        self.assertEqual(v['publics']['LL_LockEnd_'],(1,515316))
        self.assertEqual(v['publics']['LL_UnlockMemory_'],(1,515320))
        self.assertEqual(v['publics']['LL_LockMemory_'],(1,515340))
        self.assertEqual(len(report['constraints']),6)
        self.assertEqual(v['publics']['DPMI_LockMemoryRegion_'],(1,527060))
        self.assertFalse(report['full_executable_rebuilt'])


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.5/BINW/wcc386.exe').is_file(),
                     'private target and historical compiler required')
class TaskProofTests(unittest.TestCase):
    def test_complete_scheduler_contribution(self):
        with tempfile.TemporaryDirectory() as directory:
            report=prove('task_man',ROOT/'toolchains/watcom-10.5',Path(directory))
        v=report['verification']
        self.assertIs(v['verified'],True)
        self.assertEqual((v['initialized_bytes'],v['zero_fill_bytes'],v['verified_fixups']),
                         (1380,42,103))
        self.assertEqual(v['publics']['TS_ServiceSchedule_'],(1,475584))
        self.assertEqual(v['publics']['TS_Dispatch_'],(1,476348))
        self.assertEqual(v['publics']['DPMI_LockMemoryRegion_'],(1,527060))
        self.assertFalse(report['full_executable_rebuilt'])


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe').is_file(),
                     'private target and historical compiler required')
class DPMIProofTests(unittest.TestCase):
    def test_complete_dpmi_contribution(self):
        with tempfile.TemporaryDirectory() as directory:
            report=prove('dpmi',ROOT/'toolchains/watcom-10.0-ga',Path(directory))
        v=report['verification']
        self.assertIs(v['verified'],True)
        self.assertEqual((v['initialized_bytes'],v['zero_fill_bytes'],v['verified_fixups']),
                         (410,40,38))
        self.assertEqual(v['publics']['DPMI_LockMemoryRegion_'],(1,527060))
        self.assertEqual(v['publics']['DPMI_UnlockMemoryRegion_'],(1,527152))
        self.assertEqual(v['publics']['_dpmi_state'],(3,1796164))


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe').is_file(),
                     'private target and historical compiler required')
class UnmodifiedAudioProofTests(unittest.TestCase):
    def test_complete_mpu_and_pitch_contributions(self):
        for name,expected in [('mpu401',(622,0,51)),('pitch',(1488,0,17))]:
            with self.subTest(module=name), tempfile.TemporaryDirectory() as directory:
                report=prove(name,ROOT/'toolchains/watcom-10.0-ga',Path(directory))
                v=report['verification']
                self.assertIs(v['verified'],True)
                self.assertEqual((v['initialized_bytes'],v['zero_fill_bytes'],v['verified_fixups']),
                                 expected)
                self.assertFalse(report['full_executable_rebuilt'])


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe').is_file(),
                     'private target and historical compiler required')
class DMAProofTests(unittest.TestCase):
    def test_complete_dma_contribution_including_port_table(self):
        with tempfile.TemporaryDirectory() as directory:
            report=prove('dma',ROOT/'toolchains/watcom-10.0-ga',Path(directory))
        v=report['verification']
        self.assertIs(v['verified'],True)
        self.assertEqual((v['initialized_bytes'],v['zero_fill_bytes'],v['verified_fixups']),
                         (1035,0,28))
        self.assertEqual(v['publics']['_DMA_PortInfo'],(1,527248))
        self.assertEqual(v['publics']['DMA_ErrorString_'],(1,527520))
        self.assertFalse(report['full_executable_rebuilt'])


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe').is_file(),
                     'private target and historical compiler required')
class SoundSourceProofTests(unittest.TestCase):
    def test_complete_sound_source_contribution_preserves_public_state(self):
        with tempfile.TemporaryDirectory() as directory:
            report=prove('sndsrc',ROOT/'toolchains/watcom-10.0-ga',Path(directory))
        v=report['verification']
        self.assertIs(v['verified'],True)
        self.assertEqual((v['initialized_bytes'],v['zero_fill_bytes'],v['verified_fixups']),
                         (2062,28,201))
        self.assertEqual(v['publics']['_SS_CallBack'],(3,1743060))
        self.assertEqual(v['publics']['_SS_SoundPlaying'],(3,1743068))
        self.assertEqual(tuple(report['private_members']['_SS_Timer']['target']),(3,1743052))
        self.assertEqual(tuple(report['private_members']['_SS_CurrentBuffer']['target']),(3,1743056))
        self.assertFalse(report['full_executable_rebuilt'])


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.5/BINW/wcc386.exe').is_file(),
                     'private target and historical compiler required')
class IRQProofTests(unittest.TestCase):
    def test_complete_irq_contribution_with_aligned_state_groups(self):
        with tempfile.TemporaryDirectory() as directory:
            report=prove('irq',ROOT/'toolchains/watcom-10.5',Path(directory))
        v=report['verification']
        self.assertIs(v['verified'],True)
        self.assertEqual((v['initialized_bytes'],v['zero_fill_bytes'],v['verified_fixups']),
                         (1016,54,103))
        self.assertEqual(v['publics']['IRQ_SetVector_'],(1,515592))
        self.assertEqual(tuple(report['private_members']['_IRQ_CallBackOffset']['target']),(3,1780718))
        self.assertEqual(tuple(report['private_members']['_IRQ_CallBackSegment']['target']),(3,1780724))
        self.assertFalse(report['full_executable_rebuilt'])


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0a/BINB/wcc386.exe').is_file(),
                     'private target and historical compiler required')
class SoundScapeProofTests(unittest.TestCase):
    def test_complete_soundscape_including_parser_and_state(self):
        with tempfile.TemporaryDirectory() as directory:
            report=prove('sndscape',ROOT/'toolchains/watcom-10.0a',Path(directory))
        v=report['verification']
        self.assertIs(v['verified'],True)
        self.assertEqual((v['initialized_bytes'],v['zero_fill_bytes'],v['verified_fixups']),
                         (6539,92,445))
        self.assertEqual(v['publics']['parse_'],(1,481048))
        self.assertEqual(v['publics']['SOUNDSCAPE_FindCard_'],(1,481228))
        self.assertEqual(v['publics']['_SOUNDSCAPE_CallBack'],(3,1743152))
        self.assertEqual(v['publics']['_SOUNDSCAPE_SoundPlaying'],(3,1743160))
        self.assertFalse(report['full_executable_rebuilt'])


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0a/BINB/wcc386.exe').is_file(),
                     'private target and historical compiler required')
class BlasterProofTests(unittest.TestCase):
    def test_complete_blaster_contribution_preserves_external_state(self):
        with tempfile.TemporaryDirectory() as directory:
            report=prove('blaster',ROOT/'toolchains/watcom-10.0a',Path(directory))
        v=report['verification']
        self.assertIs(v['verified'],True)
        self.assertEqual((v['initialized_bytes'],v['zero_fill_bytes'],v['verified_fixups']),
                         (7791,86,565))
        self.assertEqual(v['publics']['_BLASTER_Version'],(3,1796216))
        self.assertEqual(v['publics']['_BLASTER_DMAChannel'],(3,1796280))
        self.assertEqual(v['publics']['_BLASTER_OldInt'],(3,1796286))
        self.assertFalse(report['full_executable_rebuilt'])


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0a/BINB/wcc386.exe').is_file(),
                     'private target and historical compiler required')
class MidiProofTests(unittest.TestCase):
    def test_complete_unmodified_midi_contributions(self):
        for name,expected in [('al_midi',(7780,2688,406)),('midi',(9115,252,650))]:
            with self.subTest(module=name), tempfile.TemporaryDirectory() as directory:
                report=prove(name,ROOT/'toolchains/watcom-10.0a',Path(directory))
                v=report['verification']
                self.assertIs(v['verified'],True)
                self.assertEqual((v['initialized_bytes'],v['zero_fill_bytes'],v['verified_fixups']),
                                 expected)
                self.assertFalse(report['full_executable_rebuilt'])


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0a/BINB/wcc386.exe').is_file(),
                     'private target and historical compiler required')
class GusWaveProofTests(unittest.TestCase):
    def test_complete_guswave_contribution_including_voice_state(self):
        with tempfile.TemporaryDirectory() as directory:
            report=prove('guswave',ROOT/'toolchains/watcom-10.0a',Path(directory))
        v=report['verification']
        self.assertIs(v['verified'],True)
        self.assertEqual((v['initialized_bytes'],v['zero_fill_bytes'],v['verified_fixups']),
                         (7943,488,295))
        self.assertEqual(v['publics']['_GUSWAVE_PanTable'],(1,516336))
        self.assertFalse(report['full_executable_rebuilt'])


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0a/BINB/wcc386.exe').is_file(),
                     'private target and historical compiler required')
class Pas16ProofTests(unittest.TestCase):
    def test_complete_pas16_contribution_preserves_public_state(self):
        with tempfile.TemporaryDirectory() as directory:
            report=prove('pas16',ROOT/'toolchains/watcom-10.0a',Path(directory))
        v=report['verification']
        self.assertIs(v['verified'],True)
        self.assertEqual((v['initialized_bytes'],v['zero_fill_bytes'],v['verified_fixups']),
                         (6716,104,489))
        self.assertEqual(v['publics']['_PAS_CallBack'],(3,1743260))
        self.assertEqual(v['publics']['_PAS_DMAChannel'],(3,1743272))
        self.assertEqual(v['publics']['_PAS_OldInt'],(3,1743280))
        self.assertFalse(report['full_executable_rebuilt'])
