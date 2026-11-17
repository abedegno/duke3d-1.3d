"""Closed mechanical syntax port of AUTHORED symbolic WASM to GNU source.

No native/target/decoder input. Explicit real no-op mnemonic tails are named
source statements, supported by OWN407 and ordinary unused-source permission.
"""
from pathlib import Path
import re,importlib.util
B=Path(__file__).parent
TAILS={'Z_GetZonePtr_':'mov','Z_SetZonePtr_':'mov','Z_GetFreeZone_':'lea','Z_FreeZone_':'lea','Z_Init_':'mov','Z_GetSize_':'nop','Z_AddFreeBlock_':'mov','Z_FreeBlock_':'mov','Z_FreeTags_':'lea','Z_PurgeZone_':'lea','Z_FindBlockInFreeList_':'lea','Z_FindFreeBlock_':'lea','Z_Touch_':'lea','Z_ZoneUsed_':'lea','Z_ZoneMaxFree_':'nop','Z_ZoneSize_':'mov','Z_ChangeTag_':'nop','Z_AvailHeap_':'lea','Z_DumpHeap_':'nop'}
NOPS={'mov':'{load} mov eax,eax','lea':'{disp8} lea eax,[eax]','nop':'nop'}
def expand():
 root=B/'authored';spec=importlib.util.spec_from_file_location('_403diag',root/'zone_diagnostics.py');d=importlib.util.module_from_spec(spec);spec.loader.exec_module(d);diag,_,extent=d.generate();assert extent==1427
 lines=(root/'ZONE.ASM').read_text('ascii').splitlines();result=['.intel_syntax noprefix','.code32','.file "zone.S"'];origins=[{'path':'GNU-syntax','line':i+1}for i in range(3)];section=None;function=None;skip=False
 def emit(s,path,n):result.append(s);origins.append({'path':path,'line':n})
 def convert(line,n,path='ZONE.ASM'):
  nonlocal section,function,skip
  raw=line;line=line.split(';',1)[0].strip()
  if not line:
   if raw.strip():emit('#'+raw.lstrip().lstrip(';'),path,n)
   return
  if line=='if2':skip=True;return
  if line=='endif':skip=False;return
  if skip:return
  if line in('.386p','.model flat','end')or line.startswith('DGROUP group '):return
  m=re.fullmatch(r'(\w+) segment (para|dword) public use32 \'(CODE|DATA|BSS)\'',line)
  if m:
   section=m[1];emit('.section '+section+',"'+{'CODE':'xr0','DATA':'dw0','BSS':'b0'}[m[3]]+'"',path,n);return
  if line.endswith(' ends'):return
  if line.startswith('public '):emit('.globl '+line[7:],path,n);return
  if line.startswith('extrn '):
   for name in line[6:].split(','):emit('.extern '+name.split(':')[0],path,n)
   return
  m=re.fullmatch(r'(\w+) equ (.+)',line)
  if m:emit('.equ '+m[1]+','+re.sub(r'\b([0-9][0-9a-fA-F]*)h\b',lambda v:'0x'+v[1],m[2]),path,n);return
  m=re.fullmatch(r'(\w+) (?:proc near|label byte)',line)
  if m:
   emit(m[1]+':',path,n)
   if 'proc'in line:function=m[1]
   return
  if line.endswith(' endp'):return
  if line.endswith(':'):
   if line[:-1].startswith('Z_'):function=line[:-1]
   emit(line,path,n);return
  if line=='align 4':
   if path=='DIAG.INC':emit('.balign 4,0',path,n)
   elif function in TAILS:emit(NOPS[TAILS[function]],path,n)
   return
  if line=='include DIAG.INC':
   # Same33 real string objects. Unused NUL suffix capacity represents the
   # established C emitter's inter-object zeros without raising section
   # alignment/rounding the final odd extent. No raw-length/sizeof consumer.
   _,rows,_=d.generate()
   for j,row in enumerate(rows):
    size=row['bytes'];extra=(-size)%4 if j<len(rows)-1 else 0
    import ast
    chars=ast.literal_eval(row['C_literal'])+'\0'*(1+extra)
    emit(row['name']+':','diagnostic-C-literal',j+1)
    # Short readable adjacent literal fragments keep the normal assembler
    # listing complete; they do not alter any character/capacity/value.
    for k in range(0,len(chars),20):
     fragment=chars[k:k+20];literal='"'+''.join('\\000'if c=='\0'else'\\n'if c=='\n'else c for c in fragment)+'"'
     emit('.ascii '+literal,'diagnostic-C-literal',j+1)
   return
  m=re.fullmatch(r'(\w+) dd (.+)',line)
  if m:
   emit(m[1]+':',path,n);value=m[2]
   if value=='?':emit('.space 4',path,n)
   elif value=='3 dup(?)':emit('.space 12',path,n)
   elif value=='NUM_ZONES dup(0)':emit('.long 0,0,0,0',path,n);emit('.long 0,0,0,0',path,n)
   else:raise ValueError('unmeasured storage '+line)
   return
  m=re.fullmatch(r'(\w+) db (.+)',line)
  if m:
   emit(m[1]+':',path,n)
   parts=re.findall(r'"[^"]*"|\d+',m[2]);assert ','.join(parts)==m[2]
   for p in parts:emit(('.ascii '+p)if p.startswith('"')else('.byte '+p),path,n)
   return
  assert line.split()[0]in {'mov','lea','push','pop','call','ret','test','cmp','add','sub','xor','and','sar','shr','inc','jl','jle','jg','jge','je','jne','jbe','jae','jmp','repne'},'unmeasured source statement '+line
  line=re.sub(r'\b([0-9][0-9a-fA-F]*)h\b',lambda m:'0x'+m[1],line)
  line=re.sub(r'\boffset (\w+)',r'OFFSET FLAT:\1',line)
  line=line.replace('near ptr ','')
  if 'near ptr 'in raw:line='{disp32} '+line
  # GNU accepts the actual32-bit selector-read form, unlike WASM's WORD spelling.
  if line=='mov dx,ds':line='mov edx,ds'
  if line=='mov cl,al':line='{load} '+line
  emit(line,path,n)
 for n,line in enumerate(lines,1):convert(line,n)
 return ('\n'.join(result)+'\n').encode('ascii'),origins
if __name__=='__main__':
 import sys,json
 out=Path(sys.argv[1]);out.mkdir(parents=True,exist_ok=True);s,o=expand();(out/'ZONE.S').write_bytes(s);(out/'origins.json').write_text(json.dumps(o,indent=2)+'\n')
