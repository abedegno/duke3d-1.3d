"""Observer-only existing whole-source and supplied-stock callee role receipts."""
from pathlib import Path
import sys,json,hashlib
R=Path(__file__).resolve().parents[1];sys.path[:0]=[str(R),str(R/'profiles/watcom/tools')]
from omf32 import Module
from tools.verify_module import verify_module,external_anchor_bindings
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def verify_callees(image,expected):
 result={};pins={};all_={}
 for n,needed in [('mact_util',['Error_','SafeMalloc_','SafeFree_']),('mact_file',['SafeOpenRead_','SafeFileLength_','SafeRead_','SafeClose_']),('mact_zone',['Z_Malloc_','Z_Touch_','Z_ChangeTag_'])]:
  p=R/'evidence'/(n+'-module.json');r=json.loads(p.read_text());d=R/'modules'/(n+'.json');spec=json.loads(d.read_text());source=R/r['source'];assert h(source)==r['source_sha256']and h(d)==r['descriptor_sha256'];assert r['target_sha256']=='a197b6b4097fa39987f4a843141830ff1553eb52b606b51fc67d067560de0cf4'
  lineage=R/spec.get('source_reference_evidence',r.get('source_reference_evidence',''))
  assert lineage.is_file() and h(lineage)==r['source_reference_sha256'];pins[str(lineage)]=h(lineage)
  if n in ('mact_util','mact_file'):
   producer=R/'tools'/('probe_'+n+'.py');assert h(producer)==r['source_producer_sha256'] and r['options']==spec['options'];pins[str(producer)]=h(producer)
   home=R/'toolchains/watcom-10.0-ga';compiler=home/'BINB/wcc386.exe';assert h(compiler)==r['compiler_sha256'];pins[str(compiler)]=h(compiler)
   for header,value in r['compiler_headers_sha256'].items():
    q=home/'H'/header;assert h(q)==value;pins[str(q)]=h(q)
  else:
   from tools.probe_mact_zone import read_provenance
   ze,zs,zpins=read_provenance();assert zs==spec;pins.update(zpins)
   for q,value in {**ze['tracked_sources_sha256'],**ze['producer_tools_sha256'],**ze['notice_files_sha256']}.items():assert h(R/q)==value;pins[str(R/q)]=value
  proof=r['verification'];assert proof['verified']and all(proof[k]==v for k,v in spec['expected'].items());a=external_anchor_bindings(proof);selected={k:a[k]for k in needed};assert all(tuple(selected[k])==tuple(expected[k])for k in selected);all_.update(selected);result[n]={'receipt_sha256':h(p),'actual_source_sha256':h(source),'descriptor_sha256':h(d),'whole_counts':spec['expected'],'named_callees':selected};pins.update({str(q):h(q)for q in [p,d,source]})
 p=R/'evidence/watcom-runtime-components.json';runtime=json.loads(p.read_text());pins[str(p)]=h(p)
 for stem,name in [('set386','memset_'),('strncpy','strncpy_'),('strpbrk','strpbrk_'),('strtok','strtok_')]:
  c=next(c for c in runtime['components']if c['name']==stem);lib=R/c['library'];raw=lib.read_bytes()[c['offset']:c['end']];assert len(raw)==c['size']and hashlib.sha256(raw).hexdigest()==c['sha256'];m=Module.parse(raw);proof=verify_module(m,image,{int(k):v for k,v in c['placements'].items()},c['verification']['publics'],group_frames={int(k):v for k,v in c['verification']['group_frames'].items()}if'group_frames'in c['verification']else None);actual=json.loads(json.dumps(proof));assert actual==c['verification'],(stem,{k:(actual.get(k),c['verification'].get(k))for k in set(actual)|set(c['verification'])if actual.get(k)!=c['verification'].get(k)});assert name in m.publics and name not in m.local_publics;assert tuple(proof['publics'][name])==tuple(expected[name]);all_[name]=proof['publics'][name];result[stem]={'supplied_original_stock_only':True,'source_credit':0,'verification':proof,'named_callee':{name:all_[name]}};pins[str(lib)]=h(lib)
 assert set(all_)==set(expected)
 return result,pins
