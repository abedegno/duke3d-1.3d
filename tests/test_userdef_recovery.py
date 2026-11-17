from pathlib import Path
import json
import tempfile
import unittest
from tools.prove_module import ROOT,Module,LEImage
from runner import compile_source

MEASURED={'clipping':5,'show_help':6,'scrollmode':7,'god':0,'eog':3,'over_shoulder_on':8,'user_name':9,'player_color':521,
          'ridecule':537,'savegame':937,'pwlockout':1157,'rtsname':1285,
          'overhead_on':1413,'last_overhead':1414,'showweapons':1415,
          'pause_on':1416,'from_bonus':1418,'camerasprite':1420,'last_camsprite':1422,
          'multimode':1424,'last_level':1426,'secretlevel':1428,
          'screen_tilting':1470,'shadows':1474,'fta_on':1478,'executions':1482,
          'auto_run':1486,'screen_size':1506,'lockout':1510,'crosshair':1514,
          'respawn_monsters':1518,'respawn_items':1522,'respawn_inventory':1526,
          'monsters_off':1534,'brightness':1538,'detail':1562,'player_skill':1578,
          'level_number':1582,'volume_number':1586,'m_marker':1590,'marker':1594}


@unittest.skipUnless((ROOT/'reference/DUKE3D.EXE').is_file() and
                     (ROOT/'toolchains/watcom-10.0-ga/BINB/wcc386.exe').is_file(),
                     'private target and historical compiler required')
class UserDefinitionTests(unittest.TestCase):
    def test_native_user_layout_and_target_transfer_references(self):
        sizes=['sizeof(struct user_defs)','sizeof(((struct user_defs *)0)->user_name)',
               'sizeof(((struct user_defs *)0)->user_name[0])',
               'sizeof(((struct user_defs *)0)->player_color)',
               'sizeof(((struct user_defs *)0)->multimode)']
        with tempfile.TemporaryDirectory() as directory:
            source=Path(directory)/'layout.c';obj=Path(directory)/'layout.obj'
            source.write_text('#include "soundabi.h"\nunsigned long layout[]={'+
                              ','.join(sizes+['offsetof(struct user_defs,'+name+')' for name in MEASURED])+'};\n')
            compile_source(ROOT/'toolchains/watcom-10.0-ga',source,obj,['/4r','/s','/ort'],
                           include_dirs=[ROOT/'src/game/include'])
            module=Module.parse(obj.read_bytes())
        segment,offset=module.publics['_layout'];raw=module.segments[segment-1].data[offset:]
        values=[int.from_bytes(raw[i:i+4],'little') for i in range(0,4*(len(sizes)+len(MEASURED)),4)]
        self.assertEqual(values,[1598,512,32,16,2,*MEASURED.values()])
        self.assertFalse(module.fixups)
        observed=json.loads((ROOT/'evidence/save-layout-observations.json').read_text())
        transfers={r['address']:(r['item_size'],r['count']) for r in observed['constant_pointer_records']}
        for field,size in [('god',1),('eog',1),('from_bonus',2),('last_level',2),
                           ('secretlevel',2),('respawn_monsters',4),('respawn_items',4),
                           ('respawn_inventory',4),('auto_run',4),('crosshair',4),
                           ('monsters_off',4),('volume_number',4),('level_number',4),('player_skill',4)]:
            self.assertEqual(transfers[579668+MEASURED[field]],(size,1))
        image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes());code=image.object_bytes(1)
        # Username addressing shifts by 5, followed by its exact base operand.
        self.assertEqual(code[74644:74652],bytes.fromhex('c1e005055dd80800'))
        fixups={(f.source_object,f.source_offset):f for f in image.read_fixups()}
        for operand,field in [(74648,'user_name'),(249475,'player_color'),
                              (6248,'multimode'),(55505,'over_shoulder_on'),
                              (51139,'showweapons'),(74916,'pause_on')]:
            self.assertEqual(fixups[(1,operand)].target_offset,579668+MEASURED[field])
        self.assertEqual(code[6245:6248],bytes.fromhex('66833d'))

    def test_help_and_scroll_consumers_use_observed_native_bytes(self):
        image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
        refs=[f for f in image.read_fixups() if f.source_object==1 and
              23584<=f.source_offset<25776 and f.target_object==3 and
              f.target_offset in (579674,579675)]
        self.assertEqual({f.target_offset for f in refs},{579674,579675})
        self.assertTrue(all(f.source_type==7 and f.width==4 and not f.alias for f in refs))
