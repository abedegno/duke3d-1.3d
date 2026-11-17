"""Own ordinary sources and native receipts; private test-only origin issuer."""
import hashlib
import json
from pathlib import Path
import re
import tempfile

from runner import assemble_source, compile_source, run_batch
from omf32 import Module
from le import LEImage
from tools.infer_bindings import infer_bindings

FIRST = """.386p
DGROUP group _DATA
_DATA segment dword public use32 'DATA'
public _prefix
_prefix db 8 dup(0)
_DATA ends
end
"""
SECOND = """.386p
DGROUP group _DATA
_DATA segment para public use32 'DATA'
public _aligned_marker
_aligned_marker db 19
_DATA ends
end
"""
MAIN = ('extern unsigned char aligned_marker;\n'
        'int main(void) { return (unsigned long)&aligned_marker & 15; }\n')


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def address(text, name):
    lines = [line for line in text.splitlines()
             if re.search(r'\b' + re.escape(name) + r'\b', line)]
    if len(lines) != 1:
        raise ValueError('ambiguous native witness address')
    match = re.search(r'([0-9A-Fa-f]{4}):([0-9A-Fa-f]{8})', lines[0])
    if not match:
        raise ValueError('missing native witness address')
    return tuple(int(value, 16) for value in match.groups())


def build_fixture(root):
    """Each invocation compiles and links in a new child; retains all receipts."""
    root = Path(root)
    work = Path(tempfile.mkdtemp(prefix='logical-origin-', dir=root/'build'))
    home = root/'toolchains/watcom-10.0-ga'
    asm = root/'toolchains/tasm-3.1'
    compiled = work/'COMPILE'
    compiled.mkdir()
    for name, source in [('FIRST', FIRST), ('SECOND', SECOND),
                         ('PARA', FIRST.replace('segment dword', 'segment para'))]:
        (compiled/(name+'.ASM')).write_text(source)
        assemble_source(asm, compiled/(name+'.ASM'), compiled/(name+'.OBJ'),
                        ['/q', '/t', '/ml', '/j.386p'], producer='tasm')
    (compiled/'MAIN.C').write_text(MAIN)
    compile_source(home, compiled/'MAIN.C', compiled/'MAIN.OBJ', ['/zq', '/s', '/mf'])
    rows = {}
    for case, order, expected in [
            ('A', ['MAIN','FIRST','SECOND'], (4,4,20,4)),
            ('B', ['MAIN','SECOND','FIRST'], (4,8,4,4)),
            ('C', ['FIRST','MAIN','SECOND'], (4,4,20,4)),
            ('D', ['PARA','MAIN','SECOND'], (16,16,32,0))]:
        directory = work/case
        directory.mkdir()
        for name in order:
            (directory/(name+'.OBJ')).write_bytes((compiled/(name+'.OBJ')).read_bytes())
        link = ('system dos4g\noption map=OUT.MAP\noption verbose\n'
                'option nodefaultlibs\nreference _cstart_\nname OUT.EXE\n'
                + ''.join('file '+name+'.OBJ\n' for name in order)
                + 'library D:\\LIB386\\DOS\\clib3r.lib\n'
                'library D:\\LIB386\\math387r.lib\n'
                'library D:\\LIB386\\DOS\\emu387.lib\n')
        (directory/'LINK.LNK').write_text(link)
        batch = ('@echo off\r\nset WATCOM=D:\\\r\n'
                 'set PATH=D:\\BINB;D:\\BIN\r\nwlink @LINK.LNK >LINK.LOG\r\n'
                 'if errorlevel 1 goto failed\r\necho OK>LINKSTAT.TXT\r\n'
                 'OUT.EXE\r\nif errorlevel 16 goto failed\r\n'
                 + ''.join(f'if errorlevel {n} goto exit{n}\r\n' for n in range(15,0,-1))
                 + 'echo 0>EXECSTAT.TXT\r\ngoto end\r\n'
                 + ''.join(f':exit{n}\r\necho {n}>EXECSTAT.TXT\r\ngoto end\r\n'
                           for n in range(1,16))
                 + ':failed\r\necho FAILED>LINKSTAT.TXT\r\n:end\r\n')
        run_batch(home, directory, batch, 30)
        if (directory/'LINKSTAT.TXT').read_text().strip() != 'OK':
            raise ValueError('native fixture link/execution failed')
        text = (directory/'OUT.MAP').read_text()
        segments = text.split('|   Segments   |')[1].split('|   Memory Map   |')[0]
        leader = address(segments, '_DATA')
        prefix = address(text, '_prefix')
        marker = address(text, '_aligned_marker')
        actual = (leader[1], prefix[1], marker[1],
                  int((directory/'EXECSTAT.TXT').read_text().strip()))
        if actual != expected:
            raise ValueError('changed native fixture layout/execution')
        receipts = {p.name:sha(p) for p in directory.iterdir() if p.is_file()}
        rows[case] = dict(directory=directory, order=tuple(order), leader=leader,
                          prefix=prefix, marker=marker, actual=actual, receipts=receipts)
    (work/'receipts.json').write_text(json.dumps(
        {key:{**row, 'directory':str(row['directory'])} for key,row in rows.items()}, indent=2))
    return rows


def issue_fixture_context(row, *, claimed_origin=None):
    """Not a production API: independent MAP, MAIN operand and first definition.

    A supplied negative claim is compared with the measured leader, never used
    as authority. Native artifacts must retain the completed-job receipt.
    """
    from tools.logical_segment_origins import _issue_verified_origin, segment_identity
    work = row['directory']
    if any(sha(work/name) != digest for name,digest in row['receipts'].items()):
        raise ValueError('changed native fixture evidence')
    image = LEImage.parse((work/'OUT.EXE').read_bytes())
    text = (work/'OUT.MAP').read_text()
    segments = text.split('|   Segments   |')[1].split('|   Memory Map   |')[0]
    leader = address(segments, '_DATA')
    marker = address(text, '_aligned_marker')
    main = Module.parse((work/'MAIN.OBJ').read_bytes())
    inferred = infer_bindings(main, image, *address(text, 'main_'))
    if tuple(inferred['symbols']['_aligned_marker']) != marker:
        raise ValueError('native MAIN operand contradicts MAP')
    # Empty MAIN's dword definition really establishes A/B's leader.
    first = Module.parse((work/(row['order'][0]+'.OBJ')).read_bytes())
    first_number = next(n for n,s in enumerate(first.segments,1) if s.name=='_DATA')
    first_alignment = {3:16,5:4}[first._segment(first_number).attributes>>5]
    if leader[1] != first_alignment:
        raise ValueError('first native definition does not establish leader')
    if claimed_origin is not None and claimed_origin != leader:
        raise ValueError('origin claim contradicts native witness')
    second = Module.parse((work/'SECOND.OBJ').read_bytes())
    number = next(n for n,s in enumerate(second.segments,1) if s.name=='_DATA')
    evidence = dict(policy='own-native-MAP-MAIN-first-definition-v1',
                    order=row['order'], leader=leader, marker=marker, execution=row['actual'][3])
    return _issue_verified_origin(image, leader, segment_identity(second,number), evidence)
