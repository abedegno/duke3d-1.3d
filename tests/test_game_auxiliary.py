"""Complete timbre-loader and joystick prompt intervals under common GAME anchors."""
import copy
import json
from pathlib import Path
import tempfile
import unittest
from tools.probe_game import ROOT, FUNCTIONS, probe
from tools.probe_premap import check_intervals, OPTIONS
from tools.prove_module import prepare_headers
from tools.infer_bindings import BindingError
from tools.verify_module import ModuleError
from omf32 import Module
from le import LEImage
from runner import compile_source

DEFINITIONS={'loadtmb_':(65040,80),'CenterCenter_':(84080,16),
 'UpperLeft_':(84096,16),'LowerRight_':(84112,16),
 'CenterThrottle_':(84128,16),'CenterRudder_':(84144,14)}
HOME=ROOT/'toolchains/watcom-10.0-ga'

@unittest.skipUnless((HOME/'BINB/wcc386.exe').is_file(),'private historical compiler required')
class GameAuxiliaryTests(unittest.TestCase):
 def test_complete_intervals_keep_common_code_and_storage_placements(self):
  self.assertTrue(set(DEFINITIONS)<=set(FUNCTIONS),'six complete auxiliary intervals are not registered')
  with tempfile.TemporaryDirectory() as td:
   build=Path(td)/'native';r=probe(HOME,build);build=Path(r['source_build']['native_build_directory']);rows={f['symbol']:f for f in r['functions']}
   self.assertEqual(len(rows),78)
   self.assertEqual(sum(f['size']for f in rows.values()),66094)
   self.assertEqual(sum(f['comparison']['verified_fixups']for f in rows.values()),4314)
   for n,(offset,size)in DEFINITIONS.items():
    with self.subTest(symbol=n):
     row=rows[n];self.assertTrue(row['comparison']['match']);self.assertEqual((row['target_offset'],row['size']),(offset,size));self.assertEqual(tuple(row['placements'][1]),(1,16))
   self.assertEqual(tuple(rows['loadtmb_']['bindings']['_loadfromgrouponly']),(3,582928))
   self.assertFalse(r['full_module_gate']['verified'])
   image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes());module=Module.parse((build/'game.obj').read_bytes())
   known={n:tuple(v)for f in rows.values()for n,v in f['bindings'].items()}
   source=(ROOT/'src/game/game.c').read_bytes();old=b'kopen4load("d3dtimbr.tmb",loadfromgrouponly)';self.assertIn(old,source)
   changed=Path(td)/'wrong_archive_scope.c';changed.write_bytes(source.replace(old,b'kopen4load("d3dtimbr.tmb",0)',1));obj=Path(td)/'wrong_archive_scope.obj'
   compile_source(HOME,changed,obj,OPTIONS,30,include_dirs=[build/'include'])
   from tools.probe_game import check_native_diagnostics
   check_native_diagnostics(obj.with_suffix('.log'))
   with self.assertRaises((ValueError,BindingError,ModuleError)):
    check_intervals(Module.parse(obj.read_bytes()),image,{'loadtmb_':DEFINITIONS['loadtmb_']},known)
   for n in DEFINITIONS:
    damaged=copy.deepcopy(module);seg,start=damaged.publics[n];damaged.segments[seg-1].data[start+DEFINITIONS[n][1]-1]^=1
    with self.subTest(tail=n),self.assertRaises((ValueError,BindingError,ModuleError)):
     check_intervals(damaged,image,{n:DEFINITIONS[n]},known)

if __name__=='__main__':unittest.main()
