"""Five reviewed ordinary-C audio layouts, source-only native and exact scope guards."""
from pathlib import Path
import unittest
ROOT=Path(__file__).resolve().parents[1]
class Availability(unittest.TestCase):
 def test_named_source_first_audio_capsule_exists(self):
  self.assertTrue((ROOT/'tools/probe_audio_layout.py').is_file(),'source-first five-audio capsule missing')

import copy,json,shutil,sys,tempfile,subprocess,hashlib
from unittest.mock import patch
from tools import probe_audio_layout as c,prove_module as driver
from le import LEImage
from omf32 import Module
from tools.infer_bindings import infer_bindings
from tools.verify_module import verify_module
class NativeAudio(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  cls.work=Path(tempfile.mkdtemp(prefix='audio-layout-tests-',dir=ROOT/'build'));cls.reports={n:c.probe(n,ROOT/'toolchains'/c.HOMES[n],cls.work/n)for n in c.NAMES};cls.image=LEImage.parse((ROOT/'reference/DUKE3D.EXE').read_bytes())
 def project(self,name):
  d=self.work/name;d.mkdir();e=json.loads((ROOT/c.PROVENANCE).read_text());names={c.PROVENANCE,*e['sources_sha256'],*e['descriptors_sha256'],*e['headers_sha256'],*e['producer_tools_sha256'],*e['observer_tools_sha256'],*e['notice_files_sha256'],'tools/preserve.py','tools/object_contributions.py'}
  for p in (ROOT/'profiles/watcom/tools').glob('*.py'):names.add(str(p.relative_to(ROOT)))
  for n in names:p=d/n;p.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/n,p)
  return d
 def test_complete_five_whole_native_source_inventories(self):
  for n,r in self.reports.items():
   with self.subTest(n=n):
    self.assertTrue(r['verification']['verified']);self.assertTrue(r['source_build']['source_only']);self.assertFalse(r['source_build']['original_or_target_read_during_production']);self.assertEqual(r['source_credit'],0)
    m=Module.parse(Path(r['source_build']['object']).read_bytes());s=json.loads((ROOT/f'modules/{n}.json').read_text());c.check_native(m,s)
 def test_real_public_and_private_scope_changes_are_not_byte_proofs(self):
  for n,owner,make_private in [('irq','_irq_state',False),('blaster','_BLASTER_Version',True),('sndsrc','_ss_messages',False)]:
   r=self.reports[n];m=Module.parse(Path(r['source_build']['object']).read_bytes());s=json.loads((ROOT/f'modules/{n}.json').read_text())
   if make_private:m.local_publics.add(owner)
   else:m.local_publics.remove(owner)
   b=infer_bindings(m,self.image,1,s['code_offset'],known_symbols=s['symbol_anchors']);self.assertTrue(verify_module(m,self.image,b['placements'],b['symbols'])['verified'])
   with self.assertRaisesRegex(ValueError,'public/private'):c.check_native(m,s)
 def test_actual_C_static_scope_controls_reject_before_observation(self):
  for n,old,new in [('irq','static struct {\n   union REGS Regs;','struct {\n   union REGS Regs;'),('blaster','int BLASTER_Version;','static int BLASTER_Version;'),('sndsrc','static struct {\n   char ok[17];','struct {\n   char ok[17];')]:
   d=self.project('scope-'+n);p=d/f'src/audio/{n}.c';text=p.read_text();self.assertEqual(text.count(old),1);p.write_text(text.replace(old,new));q=d/c.PROVENANCE;e=json.loads(q.read_text());e['sources_sha256'][f'src/audio/{n}.c']=c.digest(p);q.write_text(json.dumps(e))
   with patch.object(c,'ROOT',d),self.assertRaisesRegex(ValueError,'public/private'):c.build_source(n,ROOT/'toolchains'/c.HOMES[n],d/'output')
   self.assertFalse(list((d/'output').rglob('source-build.json')))
 def test_standalone_Python_O_source_only_without_archive_or_target(self):
  d=self.project('standalone');r=subprocess.run([sys.executable,'-O',str(d/'tools/probe_audio_layout.py'),'irq','--home',str(ROOT/'toolchains/watcom-10.5'),'--build',str(d/'output'),'--report',str(d/'source.json'),'--source-only'],capture_output=True,text=True);self.assertEqual(r.returncode,0,r.stderr);self.assertFalse((d/'reference').exists());self.assertTrue(json.loads((d/'source.json').read_text())['source_only'])
 def test_actual_CONST_field_source_control_reaches_target_gate(self):
  d=self.project('directory');n='sndscape';p=d/'src/audio/sndscape.c';text=p.read_text();old='\\\\SNDSCAPE.INI';self.assertEqual(text.count(old),1);p.write_text(text.replace(old,'\\\\SNDSCAPE.INJ'));q=d/c.PROVENANCE;e=json.loads(q.read_text());e['sources_sha256']['src/audio/sndscape.c']=c.digest(p);q.write_text(json.dumps(e))
  with patch.object(c,'ROOT',d):r=c.build_source(n,ROOT/'toolchains/watcom-10.0a',d/'output')
  m=Module.parse(Path(r['object']).read_bytes());s=json.loads((ROOT/'modules/sndscape.json').read_text());b=infer_bindings(m,self.image,1,s['code_offset'],known_symbols=s['symbol_anchors'])
  with self.assertRaisesRegex(ValueError,'CONST.*1172'):verify_module(m,self.image,b['placements'],b['symbols'])
 def test_typed_role_public_offset_and_full_byte_controls(self):
  for n in c.NAMES:
   r=self.reports[n];base=Module.parse(Path(r['source_build']['object']).read_bytes());s=json.loads((ROOT/f'modules/{n}.json').read_text());m=copy.deepcopy(base);m._segment(1).data[-1]^=1;b=infer_bindings(m,self.image,1,s['code_offset'],known_symbols=s['symbol_anchors'])
   with self.assertRaises(ValueError):verify_module(m,self.image,b['placements'],b['symbols'])
   m=copy.deepcopy(base);name=next(x for x,v in m.publics.items()if v[0]==5);seg,off=m.publics[name];m.publics[name]=(seg,off+1)
   with self.assertRaisesRegex(ValueError,'public/private'):c.check_native(m,s)
 def test_missing_notice_source_and_header_identity_reject_before_native(self):
  for label in ['notice','source','header']:
   d=self.project('identity-'+label);e=json.loads((d/c.PROVENANCE).read_text());n=c.NOTICE if label=='notice'else next(iter(e['sources_sha256']if label=='source'else e['headers_sha256']));p=d/n;p.write_bytes(p.read_bytes()+b'\n/* changed input */\n')
   with patch.object(c,'ROOT',d),patch.object(c,'compile_source')as run,self.assertRaises(ValueError):c.build_source('irq',ROOT/'toolchains/watcom-10.5',d/'output')
   run.assert_not_called();self.assertFalse((d/'output').exists())
 def test_complete_home_extra_file_race_rejects_before_publication(self):
  d=self.project('home-race');home=d/'home';shutil.copytree((ROOT/'toolchains/watcom-10.0-ga').resolve(),home);actual=c.compile_source
  def race(*a,**kw):actual(*a,**kw);(home/'unexpected').write_text('outside closed home')
  with patch.object(c,'ROOT',d),patch.object(c,'compile_source',side_effect=race),self.assertRaisesRegex(ValueError,'compiler home'):c.build_source('sndsrc',home,d/'output')
  self.assertFalse(list((d/'output').rglob('source-build.json')))
 def test_live_and_staged_identity_races_reject_before_publication(self):
  for stage in [False,True]:
   d=self.project('race-'+str(stage));actual=c.compile_source
   def race(home,source,*a,**kw):actual(home,source,*a,**kw);p=source if stage else d/'src/audio/irq.c';p.write_bytes(p.read_bytes()+b'\n/* raced */\n')
   with patch.object(c,'ROOT',d),patch.object(c,'compile_source',side_effect=race),self.assertRaisesRegex(ValueError,'identity changed'):c.build_source('irq',ROOT/'toolchains/watcom-10.5',d/'output')
   self.assertFalse(list((d/'output').rglob('source-build.json')))
 def test_extra_staged_header_is_rejected_before_publication(self):
  d=self.project('stage-file-set');actual=c.compile_source
  def race(*a,**kw):actual(*a,**kw);(kw['include_dirs'][0]/'unused_extra.h').write_text('outside closed stage')
  with patch.object(c,'ROOT',d),patch.object(c,'compile_source',side_effect=race),self.assertRaisesRegex(ValueError,'staged file set'):c.build_source('irq',ROOT/'toolchains/watcom-10.5',d/'output')
  self.assertFalse(list((d/'output').rglob('source-build.json')))

 def test_missing_notice_pin_and_file_reject_before_native(self):
  for notice in c.NOTICES:
   d=self.project('notice-omit-'+Path(notice).name);p=d/c.PROVENANCE;e=json.loads(p.read_text());del e['notice_files_sha256'][notice];p.write_text(json.dumps(e));(d/notice).unlink()
   with patch.object(c,'ROOT',d),patch.object(c,'compile_source')as run,self.assertRaisesRegex(ValueError,'closed notice_files'):c.build_source('irq',ROOT/'toolchains/watcom-10.5',d/'output')
   run.assert_not_called();self.assertFalse((d/'output').exists())

 def test_loaded_policy_identity_rejects_before_output(self):
  d=self.project('loaded-policy')
  with patch.object(c,'ROOT',d),patch.dict(c._LOADED,{'tools/probe_audio_layout.py':'0'*64}),patch.object(c,'compile_source')as run,self.assertRaisesRegex(ValueError,'loaded producer identity'):c.build_source('irq',ROOT/'toolchains/watcom-10.5',d/'output')
  run.assert_not_called();self.assertFalse((d/'output').exists())
 def test_copied_C_and_notice_must_equal_live_expected_pins_before_native(self):
  for selected in ['irq.c','layout-README.md','gpl.txt']:
   d=self.project('copy-integrity-'+selected);actual=c.shutil.copyfile
   def race(src,dst,*args,**kw):
    result=actual(src,dst,*args,**kw)
    if Path(dst).name==selected and Path(dst).parent.name=='source-only':Path(dst).write_bytes(Path(dst).read_bytes()+b'\n/* destination-only mutation */\n')
    return result
   with patch.object(c,'ROOT',d),patch.object(c.shutil,'copyfile',side_effect=race),patch.object(c,'compile_source',wraps=c.compile_source)as run,self.assertRaisesRegex(ValueError,'pre-copy expected stage'):c.build_source('irq',ROOT/'toolchains/watcom-10.5',d/'output')
   run.assert_not_called();self.assertFalse(list((d/'output').rglob('source-build.json')))
 def test_observer_rejects_forged_staged_live_identity_before_target(self):
  original=self.reports['irq']['source_build'];d=self.work/'forged-receipt';shutil.copytree(Path(original['native_build_directory']),d);r=copy.deepcopy(original);old=Path(original['native_build_directory'])
  r['native_build_directory']=str(d);r['object']=str(d/'irq.obj');r['staged_sha256']={str(d/Path(k).relative_to(old)):v for k,v in r['staged_sha256'].items()};r['outputs_sha256']={str(d/Path(k).relative_to(old)):v for k,v in r['outputs_sha256'].items()};p=d/'source-only/irq.c';p.write_bytes(p.read_bytes()+b'\n/* forged staged/live mismatch */\n');r['staged_sha256'][str(p)]=c.digest(p)
  with patch.object(c,'digest',wraps=c.digest)as digest,self.assertRaisesRegex(ValueError,'pre-copy expected stage'):c.observe(r)
  self.assertFalse(any(Path(call.args[0]).name in ['DUKE3D.EXE','AUDIO_WF.LIB']for call in digest.call_args_list))
