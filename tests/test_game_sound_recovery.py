from pathlib import Path
import copy
from dataclasses import replace
import json
import tempfile
import unittest

from tools.prove_module import ROOT,prove,Module,LEImage
from tools.verify_module import verify_module,ModuleError
from runner import compile_source


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe').is_file(),
                     'private target and historical compiler required')
class GameSoundRecoveryTests(unittest.TestCase):
    def test_complete_sound_contribution_and_external_abi_relocations(self):
        with tempfile.TemporaryDirectory() as directory:
            report=prove('sounds',ROOT/'toolchains/watcom-10.0-ga',Path(directory))
            m=Module.parse((Path(directory)/'sounds.obj').read_bytes())
        v=report['verification']
        self.assertEqual((v['initialized_bytes'],v['zero_fill_bytes'],
                          v['verified_fixups']),(4703,12,288))
        self.assertEqual(v['publics']['USRHOOKS_GetMem_'],(1,282240))
        self.assertEqual(v['publics']['TestCallBack_'],(1,285856))
        self.assertEqual(v['publics']['_ps'],(3,376112))
        self.assertEqual(v['publics']['_ud'],(3,579668))
        self.assertFalse(report['full_executable_rebuilt'])
        image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        for index,s in enumerate(m.segments):
            if not s.size:
                continue
            damaged=copy.deepcopy(m);damaged.segments[index].data[-1]^=1
            with self.subTest(segment=s.name),self.assertRaises(ModuleError):
                verify_module(damaged,image,report['placements'],v['publics'])
        # The prefix holds the menu-sound table, outside any named function.
        damaged=copy.deepcopy(m);damaged.segments[0].data[0]^=1
        with self.assertRaises(ModuleError):
            verify_module(damaged,image,report['placements'],v['publics'])
        for symbol,member in [('_ps',1302),('_ud',1510)]:
            index=next(i for i,f in enumerate(m.fixups) if f.target_method==2 and
                       m.externals[f.target-1]==symbol and f.displacement+
                       int.from_bytes(m.segments[f.segment-1].data[f.offset:f.offset+f.width],'little')==member)
            damaged=copy.deepcopy(m)
            damaged.fixups[index]=replace(damaged.fixups[index],
                                          displacement=m.fixups[index].displacement+1)
            with self.subTest(state=symbol),self.assertRaises(ModuleError):
                verify_module(damaged,image,report['placements'],v['publics'])
        rts=json.loads((ROOT/'evidence/rts-module.json').read_text())['verification']['segments']
        for a in v['segments']:
            for b in rts:
                if a['target_object']==b['target_object']:
                    self.assertFalse(a['target_offset']<b['target_offset']+b['compared_bytes'] and
                                     b['target_offset']<a['target_offset']+a['compared_bytes'])
        bss=next(s for s in v['segments'] if s['symbol']=='_BSS')
        next_bss=next(s for s in rts if s['symbol']=='_BSS')
        self.assertEqual(bss['target_offset']+bss['compared_bytes']+4,next_bss['target_offset'])
        self.assertEqual((bss['target_offset']+bss['compared_bytes']+15)//16*16,next_bss['target_offset'])

    def test_sound_used_state_offsets_with_real_compiler(self):
        fields=['sizeof(struct player_struct)',
                *['offsetof(struct player_struct,'+name+')' for name in
                  ['oposx','oposy','oposz','ang','cursectnum','look_ang','timebeforeexit','gm']],
                'offsetof(struct user_defs,camerasprite)','offsetof(struct user_defs,lockout)']
        with tempfile.TemporaryDirectory() as directory:
            source=Path(directory)/'abi.c';obj=Path(directory)/'abi.obj'
            source.write_text('#include "soundabi.h"\nunsigned long layout[] = {'+
                              ','.join(fields)+'};\n')
            compile_source(ROOT/'toolchains/watcom-10.0-ga',source,obj,['/4r','/s','/ort'],
                           include_dirs=[ROOT/'src/game/include'])
            m=Module.parse(obj.read_bytes())
        segment,offset=m.publics['_layout'];data=m.segments[segment-1].data[offset:]
        self.assertEqual([int.from_bytes(data[i:i+4],'little') for i in range(0,len(fields)*4,4)],
                         [1362,568,572,576,640,646,648,748,1302,1420,1510])
        self.assertFalse(m.fixups)
