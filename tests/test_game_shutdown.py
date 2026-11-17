"""GAME shutdown uses independently owned KB/CONTROL exports in target order."""
from pathlib import Path
import json,tempfile,unittest
ROOT=Path(__file__).resolve().parents[1]
class GameShutdownNative(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  from tools import build_game_compound as c
  from tools import probe_game as p
  from omf32 import Module
  from le import LEImage
  from tools.verify_module import external_anchor_bindings
  cls.c=c;cls.p=p;cls.work=Path(tempfile.mkdtemp(prefix='game-shutdown-',dir=ROOT/'build'))
  cls.receipt=c.build_source(ROOT/'toolchains/watcom-10.0-ga',cls.work/'native');cls.module=Module.parse(Path(cls.receipt['C_object']).read_bytes());cls.image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
  cls.known,cls.hashes,_=p.independent_anchors(cls.module,cls.work/'anchors')
  cls.providers={}
  for filename,name in [('mact_keyboard-module.json','KB_Shutdown_'),('mact_control-module.json','CONTROL_Shutdown_')]:
   report=json.loads((ROOT/'evidence'/filename).read_text());cls.providers[name]=tuple(external_anchor_bindings(report['verification'])[name])
 def test_complete_48_bytes_seven_fields_use_real_provider_targets(self):
  from tools.probe_premap import check_source_interval
  self.assertEqual(self.providers,{'KB_Shutdown_':(1,569064),'CONTROL_Shutdown_':(1,577248)})
  known=dict(self.known);known.update(self.providers)
  row=check_source_interval(self.module,self.image,'ShutDown_',65120,48,known)
  self.assertTrue(row['comparison']['match']);self.assertEqual(row['comparison']['verified_fixups'],7)
  for name,value in self.providers.items():self.assertEqual(tuple(row['bindings'][name]),value)
 def test_production_observer_nominates_both_real_provider_exports(self):
  for name,value in self.providers.items():self.assertEqual(self.known.get(name),value)
  for filename in ('mact_keyboard-module.json','mact_control-module.json'):
   self.assertEqual(self.hashes.get('evidence/'+filename),self.c.digest(ROOT/'evidence'/filename))
 def test_prior_REAL_C_order_is_negative_under_provider_bindings(self):
  from tools.probe_premap import check_source_interval
  from omf32 import Module
  old=b'    CONTROL_Shutdown();\n    KB_Shutdown();';new=b'    KB_Shutdown();\n    CONTROL_Shutdown();';text=(ROOT/self.c.SOURCE).read_bytes();self.assertEqual(text.count(old),1)
  d=self.work/'prior-source-order';d.mkdir();source=d/'prior.c';source.write_bytes(text.replace(old,new));self.c.compile_source(ROOT/'toolchains/watcom-10.0-ga',source,d/'game.obj',self.c.OPTIONS,45,include_dirs=[Path(self.receipt['native_build_directory'])/'include']);self.c.check_diagnostics(d/'game.log');bad=Module.parse((d/'game.obj').read_bytes());known=dict(self.known);known.update(self.providers)
  with self.assertRaises(ValueError):check_source_interval(bad,self.image,'ShutDown_',65120,48,known)
if __name__=='__main__':unittest.main()
