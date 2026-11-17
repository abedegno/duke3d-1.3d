"""IRQ source-only production must reject untracked NASM environment options."""
from pathlib import Path
import os,sys,tempfile,subprocess,unittest
from unittest.mock import patch
ROOT=Path(__file__).resolve().parents[1]
class AmbientNASM(unittest.TestCase):
 def test_all_admission_entries_reject_before_native_or_receipt_reads(self):
  from tools import probe_irq_symbolic as p
  for value in ('-P/outside-stage.inc','-DUNTRACKED=1',' '):
   for name,call in [('producer',lambda:p.build_source()),('observer',lambda:p.observe({})),('receipt',lambda:p.validate_receipt({},None,None,None))]:
    with self.subTest(value=value,entry=name),patch.dict(os.environ,{'NASMENV':value}),patch.object(p.subprocess,'run')as run,patch.object(p,'read_provenance')as read,patch.object(p,'sha')as sha:
     with self.assertRaisesRegex(ValueError,'NASMENV'):call()
     run.assert_not_called();read.assert_not_called();sha.assert_not_called()
 def test_clean_native_receipt_then_environment_change_rejects_early(self):
  from tools import probe_irq_symbolic as p
  from omf32 import Module
  with tempfile.TemporaryDirectory(prefix='irq-clean-env-',dir=ROOT/'build')as tmp:
   modules=[]
   for value in (None,''):
    with patch.dict(os.environ):
     if value is None:os.environ.pop('NASMENV',None)
     else:os.environ['NASMENV']=value
     r=p.build_source(build=Path(tmp)/('unset'if value is None else'empty'))
     e,spec,pins=p.read_provenance(observer=True);p.validate_receipt(r,e,spec,pins)
     m=Module.parse(Path(r['object']).read_bytes());modules.append(p.encode({k:v for k,v in vars(m).items()if k!='name'}))
    for call in (lambda:p.observe(r),lambda:p.validate_receipt(r,e,spec,pins)):
     with patch.dict(os.environ,{'NASMENV':'-P/outside-stage.inc'}),patch.object(p.subprocess,'run')as run,patch.object(p,'sha')as sha:
      with self.assertRaisesRegex(ValueError,'NASMENV'):call()
      run.assert_not_called();sha.assert_not_called()
   self.assertEqual(modules[0],modules[1])
 def test_actual_external_preinclude_error_is_rejected_before_assembler(self):
  with tempfile.TemporaryDirectory(prefix='irq-env-',dir=ROOT/'build')as tmp:
   d=Path(tmp);outside=d/'outside-stage.inc';outside.write_text('%error TASK599_EXTERNAL_INCLUDE_EXECUTED\n')
   env=dict(os.environ,NASMENV='-P'+str(outside))
   r=subprocess.run([sys.executable,str(ROOT/'tools/probe_irq_symbolic.py'),'--build',str(d/'native'),'--report',str(d/'receipt.json'),'--source-only'],env=env,capture_output=True,text=True)
   self.assertNotEqual(r.returncode,0)
   logs='\n'.join(q.read_text()for q in d.rglob('IRQ.LOG'))
   self.assertIn('NASMENV',r.stderr)
   self.assertNotIn('TASK599_EXTERNAL_INCLUDE_EXECUTED',logs+r.stderr)
   self.assertFalse((d/'native').exists());self.assertFalse((d/'receipt.json').exists())
if __name__=='__main__':unittest.main()
