from pathlib import Path
import json
import tempfile
import unittest
from tools.prove_module import ROOT,Module,LEImage
from runner import compile_source


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe').is_file(),
                     'private target and historical compiler required')
class PlayerDeclarationTests(unittest.TestCase):
    def test_native_player_extent_arrays_and_observed_tail_reference(self):
        fields=['sizeof(struct player_struct)',
                'sizeof(((struct player_struct *)0)->ammo_amount)',
                'sizeof(((struct player_struct *)0)->gotweapon)',
                'sizeof(((struct player_struct *)0)->weaprecs)',
                'sizeof(((struct player_struct *)0)->name)',
                *['offsetof(struct player_struct,'+name+')' for name in
                  ['oposx','ang','cursectnum','look_ang','timebeforeexit','gm','palookup',
                   'holoduke_amount','kickback_pic','firstaid_amount','inven_icon',
                   'jetpack_on','holster_weapon','level_reset_flag','refresh_inventory','palette','over_shoulder_on']]]
        with tempfile.TemporaryDirectory() as directory:
            source=Path(directory)/'layout.c';obj=Path(directory)/'layout.obj'
            source.write_text('#include "soundabi.h"\nunsigned long layout[]={'+','.join(fields)+'};\n')
            compile_source(ROOT/'toolchains/watcom-10.0-ga',source,obj,['/4r','/s','/ort'],
                           include_dirs=[ROOT/'src/game/include'])
            module=Module.parse(obj.read_bytes())
        segment,offset=module.publics['_layout'];data=module.segments[segment-1].data[offset:]
        self.assertEqual([int.from_bytes(data[i:i+4],'little') for i in range(0,4*len(fields),4)],
                         [1362,22,11,512,13,568,640,646,648,748,1302,1352,
                          688,712,718,1322,1324,1330,1332,1344,1345,728])
        self.assertFalse(module.fixups)
        report=json.loads((ROOT/'evidence/save-layout-observations.json').read_text())
        for records in [report['constant_pointer_records'],report['reader']['constant_pointer_records']]:
            player=next(r for r in records if r['address']==376112)
            self.assertEqual((player['item_size'],player['count']),(1362,16))
        image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        fixups={(f.source_object,f.source_offset):f for f in image.read_fixups()}
        # PREMAP copies the saved player colour into this byte field.
        self.assertEqual(fixups[(1,249458)].target_offset,376112+1352)
        # Restored level entry clears the retained short slot at offset728.
        # Its original semantic role/name remains an inference.
        self.assertEqual(fixups[(1,253616)].target_offset,376112+728)
