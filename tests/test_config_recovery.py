from pathlib import Path
import copy
import json
from dataclasses import replace
import tempfile
import unittest
from tools.prove_module import ROOT,prove,Module,LEImage
from tools.verify_module import verify_module,ModuleError
from runner import compile_source

FIELDS={'ridecule':537,'savegame':937,'pwlockout':1157,'rtsname':1285,
        'camerasprite':1420,'screen_tilting':1470,'shadows':1474,'fta_on':1478,
        'executions':1482,'auto_run':1486,'screen_size':1506,'lockout':1510,
        'crosshair':1514,'brightness':1538,'detail':1562,'m_marker':1590}

@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe').is_file(),
                     'private target and historical compiler required')
class ConfigRecoveryTests(unittest.TestCase):
    def test_complete_config_and_neighbor_boundaries(self):
        with tempfile.TemporaryDirectory() as directory:
            report=prove('config',ROOT/'toolchains/watcom-10.0-ga',Path(directory))
            m=Module.parse((Path(directory)/'config.obj').read_bytes())
        v=report['verification'];image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        self.assertEqual((v['initialized_bytes'],v['zero_fill_bytes'],v['verified_fixups']),
                         (7394,112,629))
        self.assertFalse(report['full_executable_rebuilt'])
        self.assertEqual(v['publics']['_ud'],(3,579668))
        self.assertEqual(v['publics']['CONFIG_ReadSetup_'],(1,290112))
        self.assertEqual(v['publics']['CONFIG_WriteSetup_'],(1,291504))
        for i,s in enumerate(m.segments):
            if not s.size:continue
            damaged=copy.deepcopy(m);damaged.segments[i].data[-1]^=1
            with self.subTest(segment=s.name),self.assertRaises(ModuleError):
                verify_module(damaged,image,report['placements'],v['publics'])
        # The prefix initializer and function-name string padding are covered.
        for segment,offset in [(1,0),(6,13)]:
            damaged=copy.deepcopy(m);damaged.segments[segment-1].data[offset]^=1
            with self.assertRaises(ModuleError):
                verify_module(damaged,image,report['placements'],v['publics'])
        for member in FIELDS.values():
            fixes=[i for i,f in enumerate(m.fixups) if f.target_method==2 and
                   m.externals[f.target-1]=='_ud' and f.displacement+
                   int.from_bytes(m.segments[f.segment-1].data[f.offset:f.offset+4],'little')==member]
            if member==1420:continue # SOUNDS uses the camera member.
            self.assertTrue(fixes,member)
            damaged=copy.deepcopy(m);i=fixes[0]
            damaged.fixups[i]=replace(damaged.fixups[i],displacement=m.fixups[i].displacement+1)
            with self.subTest(member=member),self.assertRaises(ModuleError):
                verify_module(damaged,image,report['placements'],v['publics'])
        bss=next(s for s in v['segments'] if s['symbol']=='_BSS')
        self.assertEqual(bss['target_offset']+bss['compared_bytes'],587744)
        code=next(s for s in v['segments'] if s['symbol']=='_TEXT')
        self.assertEqual(code['target_offset']+code['compared_bytes'],292130)
        data=next(s for s in v['segments'] if s['symbol']=='_DATA')
        self.assertEqual(data['target_offset']+data['compared_bytes'],31604)
        rts=json.loads((ROOT/'evidence/rts-module.json').read_text())['verification']['segments']
        for a in v['segments']:
            for b in rts:
                if a['target_object']==b['target_object']:
                    self.assertFalse(a['target_offset']<b['target_offset']+b['compared_bytes'] and
                                     b['target_offset']<a['target_offset']+a['compared_bytes'])
        const=next(s for s in v['segments'] if s['symbol']=='CONST')
        self.assertEqual(const['target_offset']+const['compared_bytes'],13284)

    def test_measured_user_fields_with_native_compiler(self):
        with tempfile.TemporaryDirectory() as directory:
            source=Path(directory)/'abi.c';obj=Path(directory)/'abi.obj'
            source.write_text('#include "soundabi.h"\nunsigned long layout[]={'+
                              ','.join('offsetof(struct user_defs,'+name+')' for name in FIELDS)+'};\n')
            compile_source(ROOT/'toolchains/watcom-10.0-ga',source,obj,['/4r','/s','/ort'],
                           include_dirs=[ROOT/'src/game/include'])
            m=Module.parse(obj.read_bytes())
        seg,off=m.publics['_layout'];raw=m.segments[seg-1].data[off:]
        self.assertEqual([int.from_bytes(raw[i:i+4],'little') for i in range(0,4*len(FIELDS),4)],list(FIELDS.values()))
        self.assertFalse(m.fixups)
