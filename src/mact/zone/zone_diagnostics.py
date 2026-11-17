"""Named diagnostic objects from the readable C counterpart, no native input.

Apogee GPL2-or-later lineage/notices are retained in zone_counterpart.c.
Unused explicit NUL suffixes preserve the established MACT literal convention;
normal4-byte object alignment has no fake padding owner. Equal lexical objects
remain distinct (ZoneUsed and ZoneMaxFree), as in the original C producer.
"""
from pathlib import Path
import re,ast,json
NAMES=['get_zone_range','set_zone_range','allocate_zone','no_free_zone','free_zone_inactive','get_size_inactive','free_freed','free_inactive','free_tags_freed','purge_inactive','purge_freed','malloc_inactive','malloc_failed','malloc_owner_required','touch_inactive','realloc_inactive','zone_used_inactive','zone_max_inactive','zone_size_inactive','change_tag_inactive','dump_inactive','dump_zone','dump_size','dump_tags','dump_block','dump_size_link','dump_back_link','dump_two_free','dump_total','check_size_link','check_back_link','check_two_free','check_pretag']
def generate():
 s=Path(__file__).with_name('zone_counterpart.c').read_text('ascii');l=re.findall(r'\b(?:Error|Dbg)\(\s*("(?:[^"\\]|\\.)*")',s);assert len(l)==len(NAMES)==33
 lines=['; Real named lexical diagnostic objects, C counterpart is the source.'];rows=[];offset=0
 for i,(name,literal)in enumerate(zip(NAMES,l)):
  value=ast.literal_eval(literal).encode('ascii')+b'\0';parts=[];text=''
  for c in value:
   if 32<=c<127:
    assert c!=34;text+=chr(c)
   else:
    if text:parts.append('"'+text+'"');text=''
    assert c in(0,10);parts.append(str(c))
  assert not text
  lines+=['msg_'+name+' db '+','.join(parts)]
  rows.append({'name':'msg_'+name,'offset':offset,'bytes':len(value),'C_literal':literal});offset+=len(value)
  if i<len(NAMES)-1:lines.append('align 4');offset=(offset+3)&~3
 return ('\n'.join(lines)+'\n').encode('ascii'),rows,offset
if __name__=='__main__':
 import sys
 d=Path(sys.argv[1]);d.mkdir(parents=True,exist_ok=True);source,rows,n=generate();(d/'DIAGNOSTICS.INC').write_bytes(source);(d/'diagnostic-fields.json').write_text(json.dumps({'objects':rows,'extent':n},indent=2)+'\n');print(n)
