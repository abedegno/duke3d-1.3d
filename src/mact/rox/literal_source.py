"""Typed recovered C literal objects; no native/target reader or byte payload.

Every object retains a terminating NUL and its ordinary4-byte-aligned physical
capacity before the next literal; final object is unrounded. Here all observed
unused suffix characters are NUL. Intent beyond the first NUL remains unknown.
"""
from pathlib import Path
import json,re
B=Path(__file__).parent
def generate():
 rows=json.loads((B/'literals.json').read_text());assert len(rows)==11 and len({r['name']for r in rows})==11;out=['# Real error/name literals; unused NUL suffix capacity explicit.'];locations={};pos=0
 for i,r in enumerate(rows):
  assert set(r)=={'name','text'}and re.fullmatch(r'rox_[a-z_]+',r['name'])and isinstance(r['text'],str)and all(32<=ord(c)<=126 or c in '\n\0'for c in r['text'])
  text=r['text']+'\0';text += '\0'*((-len(text))%4 if i<len(rows)-1 else 0);locations[r['name']]=pos;pos+=len(text);out.append(r['name']+':')
  for j in range(0,len(text),20):out.append('.ascii "'+''.join('\\000'if c=='\0'else'\\n'if c=='\n'else'\\\\'if c=='\\'else'\\"'if c=='"'else c for c in text[j:j+20])+'"')
 return '\n'.join(out)+'\n',locations,pos
if __name__=='__main__':print(generate()[0],end='')
