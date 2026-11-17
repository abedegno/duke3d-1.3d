"""ROX-only source grammar; no instruction payloads/aliases/storage repairs."""
import re
FIELDS={'SECTION_BYTES':24,'ENTRY_BYTES':36,'SECTION_NAME_BYTES':8,'ENTRY_NAME_BYTES':12,'ROX_PATH_BYTES':128,'SECTION_ENTRIES':8,'SECTION_SUBSECTIONS':12,'SECTION_NEXT':16,'SECTION_PREV':20,'ENTRY_SIZE':20,'ENTRY_DATA':24,'ENTRY_NEXT':28,'ENTRY_PREV':32,'NAME_DWORD1':4}
PUBLICS={'ROX_'+n+'_'for n in ['CreateSection','CreateEntry','FreeEntry','FreeSection','Init','Shutdown','AddSubSection','FindSubSection','AddEntry','FindEntry','FixFilename','ReadEntry','TouchEntry','Get']}
IMPORTS={'Error_','SafeMalloc_','memset_','strncpy_','SafeFree_','strpbrk_','SafeOpenRead_','SafeFileLength_','Z_Malloc_','SafeRead_','SafeClose_','Z_Touch_','Z_ChangeTag_','strtok_'}
PRIVATE={'_ROX_started','_ROX_mainsection','_ROX_delims','_ROX_filename','_ROX_dataname'}
def check(text):
 sec=None;sections=[];pub=set();ext=set();fields={};labels=set();count=0;storage=[]
 for line in text.splitlines():
  line=line.partition('#')[0].strip()
  if not line:continue
  if line.startswith('.section '):sec=line.split(',')[0].split()[1];sections.append(line);continue
  if line.startswith('.globl '):pub.add(line[7:]);continue
  if line.startswith('.extern '):ext.add(line[8:]);continue
  if line.startswith('.equ '):n,v=line[5:].split(',');assert n not in fields;fields[n]=int(v);continue
  if line.endswith(':'):
   n=line[:-1];assert n not in labels;labels.add(n);continue
  if line in ('.intel_syntax noprefix','.code32','.file "ROX.S"'):continue
  if sec=='_TEXT':
   assert not line.startswith('.'),'CODE directive/payload rejected';s=re.sub(r'^\{(?:load|disp8|disp32)\} ','',line);assert s.split()[0]in {'push','pop','mov','cmp','jne','je','jle','jmp','call','add','sub','xor','lea','ret','nop','test','inc','dec','not','shr','and','repne'};count+=1
  elif sec=='CONST':assert line=='.include "ROX_LITERALS.INC"'
  elif sec=='_DATA':assert line in('.long 0','.ascii "\\\\/\\000"');storage.append((sec,line))
  elif sec=='_BSS':assert line=='.skip 128';storage.append((sec,line))
  else:raise AssertionError('unknown source scope')
 assert sections==['.section _TEXT,"xr0"','.section CONST,"dw0"','.section _DATA,"dw0"','.section _BSS,"b0"']
 assert pub==PUBLICS and ext==IMPORTS and fields==FIELDS and count==436
 assert labels==PUBLICS|PRIVATE|{'rox_branch_'+str(n).zfill(2)for n in range(1,36)}
 assert storage==[('_DATA','.long 0'),('_DATA','.long 0'),('_DATA','.ascii "\\\\/\\000"'),('_BSS','.skip 128'),('_BSS','.skip 128')]
 return {'ordinary_CODE_instructions':count,'global_functions':sorted(pub),'real_imports':sorted(ext),'genuine_private_data':sorted(PRIVATE),'source_branch_labels':35,'typed_ABS_constants':fields,'no_CODE_payload_directives':True}
