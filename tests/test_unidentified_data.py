"""Reproducible source-only production of the user-authorized DATA fragment."""
from pathlib import Path
from unittest.mock import patch
import copy,json,shutil,subprocess,sys,tempfile,unittest
ROOT=Path(__file__).resolve().parents[1]
if (ROOT/'tools/build_unidentified_data.py').is_file():
    from tools import build_unidentified_data as builder
else:
    builder=None
class Availability(unittest.TestCase):
    def test_source_only_normal_route_exists(self):
        self.assertIsNotNone(builder,'missing source-only DATA preservation route')
@unittest.skipIf(builder is None,'route not implemented')
class Native(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.work=Path(tempfile.mkdtemp(prefix='data96-tests-',dir=ROOT/'build'))
        cls.home=ROOT/'toolchains/gnu-elf-omf'
        cls.result=builder.build(cls.work/'native',cls.home)
        cls.proof=builder.observe(cls.result)
    def project(self,name):
        root=self.work/name;root.mkdir()
        for rel in [builder.SPEC,builder.SOURCE,builder.NOTICE,*builder.HELPERS]:
            dest=root/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/rel,dest)
        return root
    def repin_source(self,root):
        p=root/builder.SPEC;s=json.loads(p.read_text());s['source_sha256']=builder.sha(root/builder.SOURCE);p.write_text(json.dumps(s))
    def test_complete_literal_fragment_and_zero_code_or_symbols(self):
        p=self.proof['verification'];self.assertEqual((p['initialized_bytes'],p['zero_fill_bytes'],p['verified_fixups']),(96,0,0))
        self.assertEqual(p['publics'],{});self.assertEqual(p['local_symbols'],{})
        self.assertEqual(self.proof['historical_source_credit'],0);self.assertEqual(self.proof['complete_module_credit'],0)
        self.assertEqual(self.proof['known_incoming_loader_fields'],[])
        self.assertEqual(self.result['object_sha256'],'de7bb98f3eab9c2974c73c98c0e65e03fff96fa0b50aa8d7ed16631a84516b33')
    def test_standalone_source_only_optimized_without_reference(self):
        root=self.project('standalone')
        p=subprocess.run([sys.executable,'-O',str(root/'tools/build_unidentified_data.py'),'--source-only','--home',str(self.home),'--build',str(root/'native'),'--report',str(root/'result.json')],capture_output=True,text=True)
        self.assertEqual(p.returncode,0,p.stderr);self.assertFalse((root/'reference').exists())
        self.assertTrue(json.loads((root/'result.json').read_text())['source_only'])
    def test_actual_source_byte_change_reaches_whole_target_rejection(self):
        root=self.project('byte-control');p=root/builder.SOURCE;text=p.read_text();self.assertEqual(text.count('0x09'),1);p.write_text(text.replace('0x09','0x08'));self.repin_source(root)
        with patch.object(builder,'ROOT',root):
            result=builder.build(root/'native',self.home)
            with self.assertRaisesRegex(ValueError,'_DATA: differing bytes at \\[0\\]'):builder.observe(result,ROOT/'reference/DUKE3D.EXE')
    def test_instruction_or_external_file_directive_rejected_before_native(self):
        for label,line in [('instruction','nop'),('external','.incbin "DUKE3D.EXE"')]:
            root=self.project(label);p=root/builder.SOURCE;p.write_text(p.read_text()+'\n'+line+'\n');self.repin_source(root)
            with patch.object(builder,'ROOT',root),patch.object(builder.subprocess,'run')as native:
                with self.assertRaisesRegex(ValueError,'source directive'):builder.build(root/'native',self.home)
                native.assert_not_called()
    def test_pre_copy_and_post_build_stage_mutation_reject(self):
        root=self.project('copy-race');real=builder.shutil.copyfile
        def race(src,dst,*a,**kw):
            result=real(src,dst,*a,**kw)
            if Path(dst).name=='UNIDENT.S':Path(dst).write_bytes(Path(dst).read_bytes()+b'\n/* changed stage */\n')
            return result
        with patch.object(builder,'ROOT',root),patch.object(builder.shutil,'copyfile',side_effect=race):
            with self.assertRaisesRegex(ValueError,'stage'):builder.build(root/'native',self.home)
        result=copy.deepcopy(self.result);stage=Path(result['native_build_directory'])/'source-only/NOTICE.md';old=stage.read_bytes()
        try:
            stage.write_bytes(old+b'changed')
            with self.assertRaisesRegex(ValueError,'stage'):builder.validate(result)
        finally:stage.write_bytes(old)
    def test_native_inventory_and_complete_receipts_reject(self):
        from omf32 import Module
        from profiles.gnu_elf_omf.elf32 import elf
        r=self.result;w=Path(r['native_build_directory']);m=Module.parse(Path(r['object']).read_bytes());e=elf(w/'UNIDENT.ELF');source=builder.parse_source((ROOT/builder.SOURCE).read_text())
        for kind in ['public','code','class','fixup-import']:
            mutant=copy.deepcopy(m)
            if kind=='public':mutant.publics['invented']=(4,0)
            elif kind=='code':mutant.segments[0].size=1;mutant.segments[0].data=bytearray([0x90])
            elif kind=='class':mutant.segments[3].class_name='CODE'
            else:mutant.externals.append('invented')
            with self.subTest(kind=kind),self.assertRaises(ValueError):builder.check_native(mutant,e,source,builder.read_spec()[0])
        for field in ['inputs_sha256','staged_sha256','outputs_sha256']:
            mutant=copy.deepcopy(r);mutant[field].pop(next(iter(mutant[field])))
            with self.subTest(field=field),self.assertRaisesRegex(ValueError,'receipt'):builder.validate(mutant)
    def test_required_notice_cannot_be_omitted(self):
        root=self.project('missing-notice');(root/builder.NOTICE).unlink()
        with patch.object(builder,'ROOT',root),patch.object(builder.subprocess,'run')as native:
            with self.assertRaises(ValueError):builder.build(root/'native',self.home)
            native.assert_not_called()
if __name__=='__main__':unittest.main()
