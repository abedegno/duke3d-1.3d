"""Closed exact authored ACTORS source identities and fully consumed operands.
No alternate syntax/semantic-equivalence admission; new source requires review.
"""
from pathlib import Path
import json,re,hashlib,ast
POLICY_SHA256='c3b90dd702a3ff576798ed32ae6750ad2810880f95c630b432e1da3049ceb0e6'
def check(source,policy):
 source=Path(source);policy=Path(policy);sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
 policy_raw=policy.read_bytes()
 if hashlib.sha256(policy_raw).hexdigest()!=POLICY_SHA256:raise ValueError('changed authored source policy')
 p=json.loads(policy_raw);expected=p['source_files_sha256']
 if{q.name for q in source.iterdir()}!=set(expected):raise ValueError('closed source input set')
 raws={n:(source/n).read_bytes()for n in expected}
 if any(hashlib.sha256(raws[n]).hexdigest()!=h for n,h in expected.items()):raise ValueError('source differs from reviewed source identity')
 model=json.loads(raws['source-model.json']);text=raws['ACTORS.S'].decode();labels=re.findall(r'^(\w+):',text,re.M);equs=re.findall(r'^\.equ (\w+), (-?\d+)$',text,re.M);names=set(labels)|{n for n,v in equs}|set(model['imports']);regs={'eax','ebx','ecx','edx','esi','edi','ebp','esp','ax','bx','cx','dx','si','di','bp','sp','al','ah','bl','bh','cl','ch','dl','dh','es','ds','ss','cs','fs','gs','eiz'};scalars={n for n,v in equs};globals=re.findall(r'^\.globl (\w+)$',text,re.M);locals=re.findall(r'^\.local (\w+)$',text,re.M)
 if len(labels)!=len(set(labels))or len(globals)!=38 or set(locals)!={'_radius_status_record','_dmval'}:raise ValueError('complete declaration identities/scopes')
 if len(model['fields'])!=2812 or len(model['instructions'])!=15470:raise ValueError('whole source semantic inventory')
 count=0;memcount=0
 for raw in text.splitlines():
  line=raw.split('#',1)[0].strip()
  if not line or line.endswith(':')or line.startswith('.'):continue
  t=re.fullmatch(r'(?:\{(?:load|store|disp8|disp32)\}\s+)?([a-z][a-z0-9]*(?:\s+(?:movsb|movsw|movsd|stosb|stosw|stosd|scasb|scasw|scasd))?)(?:\s+(.*))?',line)
  if t is None:raise ValueError('unconsumed instruction grammar '+line)
  count+=1;operand=t[2]or'';parts=[];at=0;depth=0
  for i,ch in enumerate(operand):
   if ch=='[':depth+=1
   elif ch==']':depth-=1
   elif ch==','and depth==0:parts.append(operand[at:i].strip());at=i+1
   if depth not in(0,1):raise ValueError('nested/unbalanced memory syntax')
  if depth:raise ValueError('unclosed memory syntax')
  if operand:parts.append(operand[at:].strip())
  for op in parts:
   if not op:raise ValueError('empty actual operand')
   if '['in op or']'in op:
    z=re.fullmatch(r'(?:byte|word|dword|fword|qword|tbyte|xmmword) ptr (?:[cdefgs]s:)?\[([^\[\]]+)\]',op)
    if z is None:raise ValueError('entire memory operand must be consumed')
    expr=z[1];memcount+=1
    node=ast.parse(expr,mode='eval')
    for n in ast.walk(node):
     if not isinstance(n,(ast.Expression,ast.BinOp,ast.Add,ast.Sub,ast.Mult,ast.UnaryOp,ast.USub,ast.UAdd,ast.Name,ast.Load,ast.Constant)):raise ValueError('closed memory arithmetic')
    ids=re.findall(r'\b[A-Za-z_]\w*\b',expr);owners=[n for n in ids if n not in regs|scalars]
    if len(owners)>1 or any(n not in names|regs for n in ids):raise ValueError('competing/repeated/unowned memory identity')
 if count!=15470:raise ValueError('whole mnemonic instruction count')
 return {'closed_source_files':expected,'instruction_count':count,'fully_consumed_memory_operands':memcount,'global_definitions':38,'C_private_definitions':2,'immutable_reviewed_source_identity':True}
