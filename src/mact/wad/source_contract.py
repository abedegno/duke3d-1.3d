"""Readable WAD source grammar, no payload directives/aliases/extra storage."""
import re
def need(c,m):
 if not c:raise ValueError('WAD '+m)
def check(text):
 section=None;sections=[];pubs=set();imports=set();labels=set();constants={};instructions=0;storage=[]
 for line in text.splitlines():
  t=line.partition('#')[0].strip()
  if not t:continue
  need(';'not in t,'multiple statements/payload')
  if t.startswith('.section '):section=t.split()[1].split(',')[0];sections.append(t);continue
  if t.startswith('.globl '):pubs.update(t[7:].split(','));continue
  if t.startswith('.extern '):imports.update(t[8:].split(','));continue
  if t.startswith('.equ '):n,v=t[5:].split(',');need(n not in constants,'duplicate constant');constants[n]=int(v);continue
  if t.endswith(':'):need(t[:-1]not in labels,'duplicate label');labels.add(t[:-1]);continue
  if t in ['.intel_syntax noprefix','.code32','.file "wad.S"','.p2align 4','.p2align 2','.endif']:continue
  if t.startswith('.if '):need('!= 0'in t,'real coordinate assertion');continue
  if t=='.error "true source coordinate assertion"':continue
  if section=='_TEXT':
   need(not t.startswith('.'),'CODE payload');operation=re.sub(r'^\{(?:load|disp8|disp32)\} ','',t).split()[0];need(operation in OPS,'ordinary instruction');instructions+=1
  elif section in ['CONST','CONST2']:need(t.startswith('.ascii "')and t.endswith('"'),'real string');storage.append((section,t))
  elif section=='_DATA':need(t.startswith('.long '),'real pointers/state');storage.append((section,t))
  elif section=='_BSS':need(t in ['.skip 128','.skip 4'],'real BSS');storage.append((section,t))
  else:raise ValueError('unknown source section')
 need(len(pubs)==26 and len(imports)==27 and len(labels)==161 and len(constants)==13 and instructions==1157,'complete source identities/instructions');need([s.split(',')[0]for s in sections]==['.section _TEXT','.section CONST','.section CONST2','.section _DATA','.section _BSS','.section _TEXT'],'section ownership');need([t for sec,t in storage if sec=='_BSS']==['.skip 128','.skip 4','.skip 4','.skip 4'],'four actual BSS owners');return {'instructions':instructions,'publics':sorted(pubs),'imports':sorted(imports),'labels':sorted(labels),'ABS':constants,'runtime_private_owners':9}
OPS={'mov', 'nop', 'jne', 'not', 'test', 'sub', 'add', 'jmp', 'jge', 'pop', 'lea', 'inc', 'jb', 'jbe', 'shl', 'call', 'jl', 'jle', 'ret', 'dec', 'je', 'jae', 'repne', 'push', 'idiv', 'cmp', 'sar', 'xor'}
