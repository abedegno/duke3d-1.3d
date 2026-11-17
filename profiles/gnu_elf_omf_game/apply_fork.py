"""Apply reviewed source-only metadata forks; no binary or object rewriting."""
from pathlib import Path
import re

def apply_patch(folder,patch):
    folder=Path(folder);lines=Path(patch).read_text().splitlines(True);i=0
    while i<len(lines):
        if not lines[i].startswith('--- a/'):raise ValueError('GAME source patch header')
        name=lines[i][6:].strip();i+=1
        if i>=len(lines)or lines[i].strip()!='+++ b/'+name or Path(name).name!=name:raise ValueError('GAME source patch path')
        i+=1;p=folder/name;old=p.read_text().splitlines(True);out=[];cursor=0
        while i<len(lines)and not lines[i].startswith('--- a/'):
            match=re.fullmatch(r'@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@[^\n]*\n',lines[i])
            if match is None:raise ValueError('GAME source patch hunk')
            start=int(match[1])-1;count=int(match[2]or 1);newcount=int(match[4]or 1);i+=1
            if not cursor<=start<=len(old):raise ValueError('GAME source patch order')
            out+=old[cursor:start];cursor=start;consumed=added=0
            while i<len(lines)and not lines[i].startswith(('@@ ','--- a/')):
                row=lines[i];i+=1
                if row[:1]not in(' ','-','+'):raise ValueError('GAME patch unknown row')
                if row[0]in(' ','-'):
                    if cursor>=len(old)or old[cursor]!=row[1:]:raise ValueError('GAME patch source context')
                    cursor+=1;consumed+=1
                if row[0]in(' ','+'):out.append(row[1:]);added+=1
            if(consumed,added)!=(count,newcount):raise ValueError('GAME source patch extent')
        out+=old[cursor:];p.write_bytes(''.join(out).replace('\n','\r\n').encode())

def apply(folder):
    from profiles.gnu_elf_omf_imports.apply_fork import apply as imported
    from profiles.gnu_elf_omf_game.identity import ROOT,digest,profile
    folder=Path(folder);imported(folder)
    for name in ['source-groups.patch','unused-defaults.patch']:
        patch=ROOT/'profiles/gnu_elf_omf_game'/name
        if digest(patch)!=profile()['metadata_patches'][name]:raise ValueError('GAME changed source metadata patch')
        apply_patch(folder,patch)
    actual={p.name:digest(p)for p in folder.iterdir()if p.is_file()}
    if actual!=profile()['derived_source_files']:raise ValueError('GAME exact42 derived source graph')
