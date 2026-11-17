"""Closed late ANIM physical source/scope contracts; no target input."""
import ast,re,struct,dataclasses
PUBLICS={'ANIM_DrawFrame_', 'CPlayRunSkipDump_', 'drawframe_', 'findpage_', 'ANIM_NumFrames_', 'loadpage_', 'ANIM_LoadAnim_', 'ANIM_FreeAnim_', 'ANIM_GetPalette_', 'renderframe_', 'CheckAnimStarted_'}
IMPORTS={'SafeMalloc_', 'SafeFree_', 'Error_'}
CONSTANTS={"palette_entry_channels":3}
SECTIONS={'.text': (0, 1, 6, 1), '.data': (0, 1, 3, 1), '.bss': (0, 8, 3, 1), '_TEXT': (1005, 1, 6, 16), 'CONST': (127, 1, 3, 4), 'CONST2': (0, 1, 3, 4), '_DATA': (8, 1, 3, 4), '_BSS': (0, 8, 3, 16)}
PRIMARY_HEADERS={'music.h': '652abb52963232977f72eb3c092a4f12afe6d16fcd18f3a13b5007e1170b9191', 'error.h': 'f93403d8d7f9f7c88efb7e09e49e1861efece6a681dc82cb07eb2584079e2fe4', 'rts.h': '9e1372b2f8c41288d321d26336aa0f550b3dee2d6be5764921ec73baf22c0510', 'angles.h': 'f2beb7ecf775558d7895cfabbd7d14e6e1298f7183a102962557a0d6b58e99eb', '_clrmap.h': '722ee2385bc712fc40f6d50c0eb70163a67f9b34cc8cfa671105310c605d7395', 'rgb.h': '318dbb4f821c40821b164e8b70326fe8ac6a0672a1ed636093d209e4315f514e', 'util_lib.h': 'c6d886338dc5559000ae7dcd244916f39668dbc13c82d6786af984085bb9e9cd', '_wad.h': 'c990184d2d000262689df970feef4287e48f26a5a5e6a8c2af87e77b1169039a', 'control.h': '1085ef79d224534b6a8620e5c71bc169a3f79956d07eaf587e74fcc98af85745', '_util_lb.h': '1edaa54c80df629224615a5498cbe5dd5d4e989b1ebd739eebeecb85dd386f38', 'debug.h': '7a1011ff80eb4c4009a702667e2b1f3b764fc38e6820a486e25545c882569b1d', 'file_lib.h': '955c633ba172e49421c6dfd3f9db25c9423bc17563a98249637f1e4e9d0e70f4', '_zoneold.h': '2aba2bb0ba6e709098afa3a46ba4d0aad7d0c7e808282fc038728279c860e5df', 'rox.h': 'a2f842302f24e8de0865940866dc5d1d9d19f6fe21cc3a00d8dee26cad9e53c3', 'config.h': '0b3717228891980be859244ee94a12c14437ab3015d9a7744fcdc02eb2d4d6e7', 'external.h': 'c29e38f128b0a9bde7e14e48cd122cd2b5664c4d94dad4002885f38883d5052b', 'types.h': 'd00c4f7e2968f4315613558e1fb3a1b86f19a50cfd02b42a028cde436e298cf1', 'fixed.h': '8f903afab1297b723552b4a7fb049b2142abba96316c6880edea75fa318e303c', '_rox.h': '3483bb8b82dc3a5def4981e22356036388e0fe30bf7c7a884ef99a28f37a9608', 'pragmas.h': 'de3b98f625620acd692fa6346f1c959c9b5c1ae1373e036d7e8793de0cbd26da', 'sounds.h': '800db3ae8324200e377572bb19b9c58f9d5dc979d4f61ffb2b2489c6d373691e', 'fx_man.h': '7b6a04669a81a0ca9c352cf3d9631b975ad99e079086aef946e46ea9de69b9f1', 'tokenlib.h': '703a2696f9169ddaa75bcb2a5adc96eee17aa354845d38e0ce3b1423b60a147c', 'dyn.h': 'f7cdf9ee3d2c7e23db44f7938993e24c5edd2ca1fbf23252386fc1f71140a596', '_functio.h': 'e626ab2aadfcb7d0fe30998aef8698dd2ad6009dcd2cf09f000cddb45022bd8b', 'debug4g.h': '02552ba7dd83c6aa4312d4c6209a0140597228e02420c22c8300216bd01de9b9', 'gamerbg.h': 'c9f5f28ff1caa5e3be13745b89606d355acf0d5cc3e6e46a5e5b3e26ad1cd329', 'crc.h': 'e0c7d4de0fadf4cfb3d463c9fca5317fe39932f273dea6cf0e7faf1d94e6c040', 'joystick.h': 'cbf58b5485b65051cad0efb454e568d3a18005839fe3d3fba034bc7109a98c12', 'task_man.h': '20b11da5d7a0a0c21568dd240796cf998213d96682351a6ecdefec6bb5545b72', 'gamedefs.h': '8831a04146a218fe5ae8bb8b11c0f273eb04fdd4f76c4b28499be21c94b62ae6', 'avg.h': '86a35c00c2961ecaa4e02916e23a09f65a318b3e39fe0fa37e80db48745505dd', 'penttime.h': '2f5e4a7f686013908e71332444f046ddc410e76ee506c17755d37e33349252a0', '_animlib.h': 'eac3feb8d14531b8deeedc7bf6f35edd34940a9f16de9a2ee284a852154850a9', 'gifsave.h': 'eff9b45cef6af4de4bca222f3d3a13be05d14e7b52a3d9eebc7e7f01272f532e', '_rts.h': '8047e6407e5a71e5518193cc5a3c58ddbbc090076e342d28fa69dedbc99000ed', 'sndcards.h': '220bb631dda3a38aa23a39a277e1839d38e908f43c40a6b47211d807228fe2b7', 'stream.h': '58367b6ce5e17b71a83556ec3f183571cb4ca935a3484936f3a006e42c6e377e', 'wad.h': '6967d7cb0c985ec2cad5ff7b6658f442460375be57ce89aeb5c2556de5a878dc', 'clrmap.h': '20ff38f9a3e31d0657a75e064ad447900d7e5425bca19f7d297e82cd1600530d', 'interrup.h': 'bcd1abde6a5776e340f4a8c535ecb328929c774db33f8819171abe9bbfbb5f46', 'soundefs.h': 'eec62e9b52e4bdeda92f7c8bc549d1ddd6333f664ef54443f22dca107c40a773', 'mouse.h': '71c3d9f3a5a3ec571b65db921621e77eaf1f5a656a7d17e351e2eceeb30b2aaf', 'lumptype.h': '9c657e0f01df7f615291ef14b836e85394780a1491c56774feab6a1b9480b593', 'timer.h': '9d143947cc46b906570bf13e4a32e14d098395e7626548c8b7997773342a41ba', 'wad2type.h': 'b4733567a5bd51114e87b4d86d30b8891cd1887e1a44faa212e3dc7a31370e65', 'animlib.h': '9c71dc78ea37f4f01de21653cc6a9cdb8b5a07cba778b99f08abb1b5f23ac236', 'common.h': '54d2dba563c4303466b322331f96def1af2ecaef9a55b7f9ba9bee0b598809f9', '_tokenli.h': '1ff814a039e92e254728019035721c39a8e83273191caeec1fd4438961c4d209', 'names.h': '486f9620b54e04aad3b2a7d4ceee65e575961ee6ead047e94a252a46427e7dd2', '_random.h': '079bf446fc9ebc0b910fa61d4f7e918480692ac09d85ca05771b26c2e448560b', 'keyboard.h': 'ff41010dca80c96429847b6da8dad5f120d9e9ed69bc0b889c6dd791c61a790c', '_keyboar.h': '43be8fc2178252b3d5d30daa35ea1698be89966cbc671b8a2f4867b26719314d', 'cdrom.h': 'a43f443069aba04fa56127977a3df3b874d9a8213340741303c695d4d1b5a6fc', '_lbmlib.h': '22562eab64758c823be2c8a17661d05423daf0115c337373640fefc63b8e2f29', 'precise.h': 'fedb77537bc6ce7a101857918da7bd1280c11a85bdb86e9d0c1e93b288d9f8f3', 'wadtype.h': 'fff628bc89af5315e6a3afa0e3013e733977f26cc0334a3fcb6d1de4f611012d', 'linklist.h': '486e1511568358df8b8606908b2466bbf82e352c7e16272ab62c5194f45e5e80', 'intercep.h': '9a73aefa8ac45d8d0e2b16c19e802d2cf92d064c24780a2153ea77265d4f7f36', 'location.h': 'ccae10c47090014e6c5995c081a261e62d8d285bea5fc1ff34b63174e1c51ca8', 'lbmlib.h': '4cbc7102a326a9c3fe5552fd3e843926db2477b7aeb58787fd4bf5d944dae00f', '_zone.h': '7b89d30b388faccb2af277d87607bd573c25b5469ce175cfe2690b015c32d837', 'scriplib.h': 'c1a9a12e5812e4a7a0927007d9c6b2bce9decb0b4af25867bef77170fe12202b', '_filelib.h': 'ee991177706cbb6bc8b6bdaaf138a9540819ca5611641984196ea85f0bb582d5', 'mathutil.h': '699d3654cef10f552ba63fd8b9f4824b04b31f0c2e42a124415d8971bbe50b80', 'vector.h': '81c2a18530872531c3b20eda220ef848b5cd2826299593891a438a796c541cf7', 'timelib.h': '81e571575893135a0df33c8ce1550a4b1d27258905e5114e7455cee843d96c3e', '_control.h': '60842734f18814fec802e1da9b08994a43b889d278d537e87c8f7a623d52e70a', 'duke3d.h': '071e15cf93dd47e5551610c5d44d033511e78d4a048dae3667df23446e62e8ce', 'vid.h': 'bfbf270ce558882182cb03b0db7094b71568aec1dc65fe5f16b118babc29a4db', 'rgame.h': '7e6ba5145189f7b1f75d2d15213478d247151b0b867b730e6bd42657e414dd61', 'funct.h': '46556f9a6ac052297aed17f01959b281fc8556c2ff805b275f69621ae935b017', 'mipmap.h': 'f5ce65da6b66753700ced1f9a680760e536704a03e1b1f6cd1ccdb2ffb6a217d', 'vesa.h': '7faf2706a5ea7f24d28ba8520599aaf93c5cf432365be9928c59076964e60ccd', 'function.h': '340f9fe539642d61a4a5130c12ff1f337bbb2c465b048d3311f3f450f809f530', '_scrplib.h': '4c2742538cef1803fc898fd5d1f5b90dbf32f2e0669555d7f2b548cac1bfad6d', 'develop.h': 'c862210f83facbfa543563d746fa561d9f8d94a251e98a4a470c6bd11e17f861', 'random.h': '92fd3621d2635787fc567ad579be1fb42426e3e31484a2ae8c50642f83f3c2de', 'wad2.h': '577b4b1dbc1d54e6e492720fafaa60b082aa161a00c17f0437818bf1ff4b5ead', 'usrhooks.h': '73308ff7ba86daf29b970dfd5ec88356526745ffa58e90e6a79803606c0811d7', '_debug.h': '4039fe3f12e1746d6ebcd79da2bb98dcc4c64f293d3db2f01a9cde2e62038d1a', 'giflib.h': '65b9fb9915c1e465084775b60c1ad4f3e0774eaf461cb5625170415c645647f5'}
UNUSED=set()
def need(q,msg):
 if not q:raise ValueError("late ANIM "+str(msg))
def raw_elf(raw, e, source):
    need(raw[:16] == b'\x7fELF\x01\x01\x01' + bytes(9), 'closed late ANIM raw ELF/schema')
    h = struct.unpack_from('<HHIIIIIHHHHHH', raw, 16)
    need((h[0], h[1], h[2], h[3], h[4], h[6], h[7], h[8], h[9], h[10], h[11], h[12]) == (1, 3, 1, 0, 0, 0, 52, 0, 0, 40, 13, 12), 'closed late ANIM raw ELF/schema')
    need(h[5] + 13 * 40 == len(raw), 'closed late ANIM raw ELF/schema')
    ss = [struct.unpack_from('<IIIIIIIIII', raw, h[5] + 40 * i) for i in range(13)]
    need(ss[0] == (0,) * 10, 'closed late ANIM raw ELF/schema')
    strings = raw[ss[12][4]:ss[12][4] + ss[12][5]]
    names = [strings[s[0]:strings.index(b'\x00', s[0])].decode('ascii') for s in ss]
    need(names == ['', '.text', '.data', '.bss', '_TEXT', '.rel_TEXT', 'CONST', 'CONST2', '_DATA', '_BSS', '.symtab', '.strtab', '.shstrtab'] and names == [s['name'] for s in e['sections']], 'closed late ANIM raw ELF/schema')
    expected = {1: (1, 6, 0, 1, 0), 2: (1, 3, 0, 1, 0), 3: (8, 3, 0, 1, 0), 4: (1, 6, 1005, 16, 0), 5: (9, 64, 376, 4, 8), 6: (1, 3, 127, 4, 0), 7: (1, 3, 0, 4, 0), 8: (1, 3, 8, 4, 0), 9: (8, 3, 0, 16, 0), 10: (2, 0, 896, 4, 16), 11: (3, 0, 784, 1, 0), 12: (3, 0, 78, 1, 0)}
    ranges = [(0, 52), (h[5], len(raw))]
    for i, s in enumerate(ss[1:], 1):
        need((s[1], s[2], s[5], s[8], s[9]) == expected[i] and s[3] == 0, 'closed section schema')
        if i == 5:
            need((s[6], s[7]) == (10, 4), 'closed late ANIM raw ELF/schema')
        elif i == 10:
            need((s[6], s[7]) == (11, 42), 'closed late ANIM raw ELF/schema')
        else:
            need((s[6], s[7]) == (0, 0), 'closed late ANIM raw ELF/schema')
        need(52 <= s[4] <= h[5] and (s[1] == 8 or s[4] + s[5] <= h[5]), 'closed late ANIM raw ELF/schema')
        if s[1] != 8 and s[5]:
            ranges.append((s[4], s[4] + s[5]))
    ranges.sort()
    need(all((a[1] <= b[0] for a, b in zip(ranges, ranges[1:]))), 'closed late ANIM raw ELF/schema')
    need(all((not any(raw[a[1]:b[0]]) for a, b in zip(ranges, ranges[1:]))), 'closed late ANIM raw ELF/schema')
    labels = {t[:-1] for line in source.splitlines() if (t := line.partition('#')[0].strip()).endswith(':')}
    need(len(labels) == 48, 'closed late ANIM raw ELF/schema')
    tab = e['symbols'].get(10, e['symbols'].get('10'))
    need(len(tab) == 56, 'closed late ANIM raw ELF/schema')
    st = raw[ss[11][4]:ss[11][4] + ss[11][5]]
    symbols = []
    for i in range(56):
        n, v, z, info, other, sec = struct.unpack_from('<IIIBBH', raw, ss[10][4] + 16 * i)
        need(n < len(st), 'closed late ANIM raw ELF/schema')
        name = st[n:st.index(b'\x00', n)].decode('ascii')
        a = tab[i]
        need((name, v, z, info >> 4, info & 15, other, sec) == (a['name'], a['value'], a['size'], a['binding'], a['type'], a['other'], a['section']), 'closed late ANIM raw ELF/schema')
        need(z == 0 and info >> 4 in (0, 1) and (info & 15 in (0, 3, 4)) and (other == 0) and (sec != 65522), 'closed late ANIM raw ELF/schema')
        need(info >> 4 == (0 if i < 42 else 1), 'closed late ANIM raw ELF/schema')
        if info & 15 == 4:
            need((name, v, info >> 4, sec) == ('ANIMLIB.S', 0, 0, 65521), 'closed late ANIM raw ELF/schema')
        elif info & 15 == 3:
            need(name == '' and v == 0 and (sec in (4, 6, 8)) and (info >> 4 == 0), 'closed late ANIM raw ELF/schema')
        elif sec == 65521:
            need(name in CONSTANTS and v == CONSTANTS[name] and (info >> 4 == 0), 'closed late ANIM raw ELF/schema')
        elif sec == 0:
            need(i == 0 and (name, v, info) == ('', 0, 0) or (name in IMPORTS and (v, info) == (0, 16)), 'closed late ANIM raw ELF/schema')
        else:
            need(name in labels and sec in (4, 6, 8) and (v < ss[sec][5]) and (info >> 4 == (1 if name in PUBLICS else 0)), 'closed late ANIM raw ELF/schema')
        symbols.append(a)
    need({a['name'] for a in symbols if a['binding'] == 1 and a['section'] > 0} == PUBLICS, 'closed late ANIM raw ELF/schema')
    need({a['name'] for a in symbols if a['binding'] == 1 and a['section'] == 0} == IMPORTS, 'closed late ANIM raw ELF/schema')
    seen = set()
    for i in range(47):
        off, info = struct.unpack_from('<II', raw, ss[5][4] + 8 * i)
        idx, kind = (info >> 8, info & 255)
        need(idx < 56 and kind in (1, 2) and (off + 4 <= 1005) and (symbols[idx]['section'] != 65521), 'closed late ANIM raw ELF/schema')
        need(not seen.intersection(range(off, off + 4)), 'closed late ANIM raw ELF/schema')
        seen.update(range(off, off + 4))
        r = next((r for r in e['relocations'] if r['offset'] == off))
        need((r['source_section'], r['type'], r['symbol']['index']) == (4, kind, idx), 'closed late ANIM raw ELF/schema')
    return {'all13_raw_sections': True, 'all56_raw_symbols': True, 'all47_raw_REL_fields': True, 'all48_real_source_label_identities': True, 'all1_named_ABS_identity': True, 'no_COMMON_weak_TLS_hidden_ABS_relocation': True, 'private_twoDATA_no_export': True}
def coff(raw,e):
 need(len(raw)>=340,'COFF header');machine,count,timestamp,sp,nt,opt,flags=struct.unpack_from('<HHIIIHH',raw);need((machine,count,nt,opt,flags)==(332,8,58,0,0),'closed COFF header');start=sp+18*nt;need(start+4<=len(raw),'COFF symbol bounds');size=struct.unpack_from('<I',raw,start)[0];need(size>=4 and start+size==len(raw),'complete COFF strings');strings=raw[start:];used_strings=set(range(4));ranges=[(0,340),(sp,start),(start,len(raw))]
 def name(b):
  if b[:4]==bytes(4):
   i=struct.unpack_from('<I',b,4)[0];need(4<=i<len(strings)and b'\0'in strings[i:],'COFF name bounds');end=strings.index(b'\0',i);used_strings.update(range(i,end+1));return strings[i:end].decode('ascii')
  n=b.split(b'\0',1)[0];need(b==n.ljust(8,b'\0'),'short name padding');return n.decode('ascii')
 sections=[];en={s['name']:s for s in e['sections']};expected_names=list(SECTIONS)
 for i,n in enumerate(expected_names):
  hdr=raw[20+40*i:60+40*i];p,v,z,pos,rp,lp,nr,nl,attr=struct.unpack_from('<IIIIIIHHI',hdr,8);es=en[n];wanted=((0x60000020 if es['flags']&4 else 0xc0000080 if es['type']==8 else 0xc0000040)|({1:1,4:3,16:5}[es['align']]<<20));need((name(hdr[:8]),p,v,z,lp,nl,attr)==(n,0,0,es['size'],0,0,wanted),'all COFF section geometry/flags');rels=[r for r in e['relocations']if e['sections'][r['source_section']]['name']==n];need(nr==len(rels),'all COFF section relocations')
  if z and es['type']!=8:need(340<=pos and pos+z<=sp,'COFF backing');ranges.append((pos,pos+z));data=raw[pos:pos+z]
  else:need(pos==0,'no backed empty/BSS');data=b''
  if nr:need(340<=rp and rp+nr*10<=sp,'COFF relocation bounds');ranges.append((rp,rp+nr*10))
  else:need(rp==0,'empty COFF relocation pointer')
  sections.append({'index':i+1,'name':n,'size':z,'data':data.hex(),'flags':attr,'relocation_pointer':rp,'relocation_count':nr})
 ranges.sort();need(all(a[1]<=b[0]and not any(raw[a[1]:b[0]])for a,b in zip(ranges,ranges[1:])),'COFF overlap/unassigned bytes');symbols=[];i=0
 while i<nt:
  b=raw[sp+18*i:sp+18*(i+1)];value,section,type,cls,aux=struct.unpack_from('<IhHBB',b,8);need(i+aux<nt,'COFF auxiliary bounds');symbols.append({'index':i,'name':name(b[:8]),'value':value,'section':section,'type':type,'class':cls,'aux_count':aux,'aux':raw[sp+18*(i+1):sp+18*(i+1+aux)].hex()});i+=1+aux
 need(len(symbols)==55 and len({s['name']for s in symbols})==55,'all55 distinct COFF primary identities');by={s['name']:s for s in symbols};emap={s['index']:s['name']for s in e['sections']};cmap={s['name']:s['index']for s in sections};esymbols=[s for tab in e['symbols'].values()for s in tab];expected=set()
 for s in esymbols:
  if s['index']==0:continue
  n='.file'if s['type']==4 else emap[s['section']]if s['type']==3 else s['name'];expected.add(n);c=by[n]
  if s['type']==4:need((c['value'],c['section'],c['type'],c['class'],c['aux_count'])==(0,-2,0,103,1)and bytes.fromhex(c['aux'])==b'ANIMLIB.S'.ljust(18,b'\0'),'COFF FILE auxiliary')
  elif s['type']==3:
   es=en[emap[s['section']]];cs=sections[cmap[es['name']]-1];need((c['value'],c['section'],c['type'],c['class'],c['aux_count'])==(0,cs['index'],0,3,1)and bytes.fromhex(c['aux'])==struct.pack('<IHHIhB3s',es['size'],cs['relocation_count'],0,0,0,0,bytes(3)),'COFF section auxiliary')
  else:
   section=0 if s['section']==0 else -1 if s['section']==65521 else cmap[emap[s['section']]];need((c['value'],c['section'],c['type'],c['class'],c['aux_count'])==(s['value'],section,0,2 if s['binding']==1 else 3,0),'qualified COFF symbol/value/scope')
 need(set(by)==expected and used_strings==set(range(len(strings))),'exact COFF identities/all string bytes');idx={s['index']:s for s in symbols};relations=[]
 for sec in sections:
  es=en[sec['name']];data=bytes.fromhex(sec['data']);eb=bytes.fromhex(es['bytes']or'');rs=[r for r in e['relocations']if emap[r['source_section']]==sec['name']];covered={i for r in rs for i in range(r['offset'],r['offset']+4)};need(len(data)==len(eb)and all(a==b for i,(a,b)in enumerate(zip(data,eb))if i not in covered),'all nonfield ELF/COFF bytes')
  for j in range(sec['relocation_count']):
   off,sym,kind=struct.unpack_from('<IIH',raw,sec['relocation_pointer']+j*10);need(sym in idx,'COFF actual symbol index');c=idx[sym];r=next((r for r in rs if r['offset']==off),None);need(r is not None and kind==(20 if r['type']==2 else 6),'COFF field type/offset');s=r['symbol'];target=s['name']if s['name']else emap[s['section']];need(c['name']==target and c['value']==s['value']and c['class']==(2 if s['binding']==1 else 3),'COFF typed target identity');a=int.from_bytes(data[off:off+4],'little');need(a==(r['inline_signed']+(4 if r['type']==2 else 0))&0xffffffff,'ELF/COFF addend plus4');relations.append({'offset':off,'name':target,'type':kind})
 need(len(relations)==47 and {r['offset']for r in relations}=={r['offset']for r in e['relocations']},'all47 distinct COFF field relations');return {'timestamp':timestamp,'sections':sections,'symbols':symbols,'relations':relations,'private37_ABS1_retained':True}

def native(m,e,c):
 need(len(m.fixups)==47 and not(m.local_publics or m.local_externals),'native fields/scopes');names={s['index']:s['name']for s in e['sections']};mi={s.name:i for i,s in enumerate(m.segments,1)};fields={(f.segment,f.offset):f for f in m.fixups}
 for s in c['sections']:
  ms=m._segment(s['index']);need(ms.name==s['name']and bytes(ms.data)==(bytes(ms.size)if s['name']=='_BSS'else bytes.fromhex(s['data'])),'all COFF/native section bytes')
 for r in e['relocations']:
  f=fields[(mi[names[r['source_section']]],r['offset'])];need((f.width,f.location,f.relative,f.displacement)==(4,9,r['type']==2,0),'native typed field');s=r['symbol'];a=int.from_bytes(m._segment(f.segment).data[f.offset:f.offset+4],'little');need(a==(r['inline_signed']+(4 if r['type']==2 else 0))&0xffffffff,'native PC32 translation')
  if s['binding']==1:need(f.target_method==2 and m.externals[f.target-1]==s['name']and(f.frame_method,f.frame)==(5,None),'actual global E+A')
  else:need(f.target_method==0 and m._segment(f.target).name==names[s['section']]and f.frame_method==1 and m.groups[f.frame-1]==('FLAT',()),'private section+V+A')
 need(UNUSED<=set(m.externals)and not any(m.externals[f.target-1]in UNUSED for f in m.fixups if f.target_method==2),'three unused import obligations')

def source(text):
 labels=[];pub=set();imports=set();constants={};sections=[];ops=[];strings=[];zeros=[];current=None;data=[]
 for line in text.splitlines():
  t=line.partition('#')[0].strip()
  if not t:continue
  need(';'not in t and not re.search(r'\b(?:incbin|org|db|dw|dd|dq)\b',t,re.I),'ordinary symbolic source/no opaque payload')
  if re.match(r'^[A-Za-z_][A-Za-z_0-9]*:',t):
   n,t=t.split(':',1);need(n not in labels,'duplicate source definition');labels.append(n);t=t.strip()
   if not t:continue
  if t.startswith('.'):
   if t.startswith('.section '):current=t.split()[1].split(',')[0];sections.append(t)
   elif t.startswith('.globl '):pub.add(t[7:])
   elif t.startswith('.extern '):imports.add(t[8:])
   elif t.startswith('.equ '):n,v=t[5:].split(',',1);need(n not in constants,'duplicate ABS');constants[n]=int(v.strip(),0)
   elif t.startswith('.asciz '):need(current=='CONST','actual error strings only');v=ast.literal_eval(t[7:]);need(type(v)is str and all(ord(c)<128 for c in v),'ordinary terminated diagnostic literal');strings.append(v)
   elif t.startswith('.long '):need(current=='_DATA'and t=='.long 0','real NULL pointer/false DWORD only');data.append(0)
   else:need(t in['.intel_syntax noprefix','.code32','.file "ANIMLIB.S"','.p2align 4','.p2align 2','.balign 4','.att_syntax prefix'],'closed source directives')
  else:need(current=='_TEXT','CODE instructions only');ops.append(t)
 need(pub==PUBLICS and imports==IMPORTS,'all genuine public/provider declarations');need(len(labels)==48 and len(set(labels))==48 and constants==CONSTANTS,'all48 real definitions/one ABS');need(sections==['.section _TEXT,"ax",@progbits','.section CONST,"aw",@progbits','.section CONST2,"aw",@progbits','.section _DATA,"aw",@progbits','.section _BSS,"aw",@nobits']and data==[0,0]and len(strings)==8 and len(ops)==355,'full section/string/state/instruction owners');return {'lines':text.splitlines(),'labels':labels,'instructions':len(ops),'strings':strings,'DATA':data}
def elf(raw,e,logical,listing):
 out=raw_elf(raw,e,'\n'.join(logical['lines']));symbols=[s for tab in e['symbols'].values()for s in tab];defs={s['name']:s for s in symbols if s['type']==0 and 0<s['section']<65520};need(set(defs)==set(logical['labels'])and len(defs)==48,'all distinct qualified source identities');need({s['name']:s['value']for s in symbols if s['type']==0 and s['section']==65521}==CONSTANTS and sum(s['type']==0 and s['section']==65521 for s in symbols)==1,'all1 real ABS');need(sum(s['type']==4 for s in symbols)==1 and sum(s['type']==3 for s in symbols)==2,'actual FILE/section identities')
 h=struct.unpack_from('<HHIIIIIHHHHHH',raw,16);ss=[struct.unpack_from('<IIIIIIIIII',raw,h[5]+40*i)for i in range(13)]
 for idx,offsets in[(11,[struct.unpack_from('<I',raw,ss[10][4]+16*i)[0]for i in range(56)]),(12,[s[0]for s in ss])]:
  pool=raw[ss[idx][4]:ss[idx][4]+ss[idx][5]];used=set()
  for off in offsets:need(off<len(pool)and b'\0'in pool[off:],'string bounds');used.update(range(off,pool.index(b'\0',off)+1))
  need(used==set(range(len(pool))),'all actual string bytes')
 rows={};pages=0
 for line in listing.splitlines():
  if not line.strip():continue
  if line.startswith('GAS LISTING '):
   z=re.fullmatch(r'GAS LISTING (.+?)\s+page ([1-9][0-9]*)\s*',line);need(z and z[1].endswith('/ANIMLIB.S')and int(z[2])==pages+1,'listing page');pages+=1;continue
  if '\t'in line:
   lead,text=line.split('\t',1);a=lead.split();need(len(a)in(1,3)and a[0].isdigit(),'listing row');n=int(a[0]);need(n not in rows and 1<=n<=len(logical['lines'])and text.rstrip()==logical['lines'][n-1].rstrip(),'every exact source line');rows[n]={'offset':int(a[1],16)if len(a)==3 else None,'data':bytes.fromhex(a[2])if len(a)==3 else b'','source':text.partition('#')[0].strip()}
  else:
   a=line.split();need(len(a)==2 and int(a[0])in rows,'listing continuation');rows[int(a[0])]['data']+=bytes.fromhex(a[1])
 need(set(rows)==set(range(1,len(logical['lines'])+1)),'all source rows');en={s['name']:s for s in e['sections']};lc={n:0 for n in['_TEXT','CONST','CONST2','_DATA','_BSS']};current=None;definitions=set();instructions=0
 for row in rows.values():
  t=row['source'];data=row['data']
  if t.startswith('.section '):current=t.split()[1].split(',')[0]
  if t.endswith(':'):
   name=t[:-1];need(name in defs and(defs[name]['section'],defs[name]['value'])==(en[current]['index'],lc[current]),'qualified private/public source coordinate');definitions.add(name)
  if data:
   need(current in lc and row['offset']==lc[current],'listing section coordinate')
   if t.startswith('.asciz '):full=ast.literal_eval(t[7:]).encode('ascii')+b'\0';need(data==full[:len(data)]and len(data)==min(20,len(full)),'source diagnostic literal');data=full
   elif t.startswith('.long '):need(current=='_DATA'and data==bytes(4),'real private NULL/false DWORD')
   elif t.startswith(('.p2align ','.balign ')):need(not any(data)and current=='CONST'and len(data)==(-lc[current])%4,'natural string alignment')
   if current=='_BSS':need(not any(data),'BSS is uninitialized real storage')
   else:need(data==bytes.fromhex(en[current]['bytes'])[lc[current]:lc[current]+len(data)],'all source/listing/native bytes')
   lc[current]+=len(data);instructions+=current=='_TEXT'
 need(lc=={'_TEXT':1005,'CONST':127,'CONST2':0,'_DATA':8,'_BSS':0}and instructions==355 and definitions==set(defs),'all bytes/355rows/48definitions owned');out.update({'all355_instruction_rows':True,'all48_source_coordinates':True,'all_eight_strings_and_natural_alignment':True});return out

def headers(directory):
 from pathlib import Path
 import hashlib
 directory=Path(directory);actual={str(p.relative_to(directory)):hashlib.sha256(p.read_bytes()).hexdigest()for p in directory.rglob('*')if p.is_file()};need(actual==PRIMARY_HEADERS,'exact retained prepared C-aid header graph')
def roles(original,m,e):
 need(original.local_publics=={'_anim','_Anim_Started'}and len(original.local_externals)==2 and not(m.local_publics or m.local_externals),'true two private DATA identities');names={s.name:i for i,s in enumerate(m.segments,1)};need({n:(original._segment(sn).name,off)for n,(sn,off)in original.publics.items()if n not in original.local_publics}=={n:(m._segment(sn).name,off)for n,(sn,off)in m.publics.items()},'all11 physical global coordinates');need(set(original.externals)-original.local_publics==set(m.externals),'all real provider/self EXTDEF names');need(len(original.fixups)==len(m.fixups)==47,'all47 typed roles');nf={f.offset:f for f in m.fixups};ef={r['offset']:r for r in e['relocations']};symbols={s['name']:s for t in e['symbols'].values()for s in t if s['name']};private=0;globalself=0;rows=[]
 for name,off in [('_anim',0),('_Anim_Started',4)]:need((symbols[name]['binding'],symbols[name]['section'],symbols[name]['value'])==(0,8,off),'private source coordinate')
 for f in original.fixups:
  g=nf[f.offset];r=ef[f.offset];need((g.segment,g.width,g.location,g.relative,g.displacement)==(4,4,9,f.relative,0),'native typed field');old=int.from_bytes(original._segment(f.segment).data[f.offset:f.offset+4],'little')+f.displacement;add=int.from_bytes(m._segment(4).data[g.offset:g.offset+4],'little');name=original.externals[f.target-1]if f.target_method==2 else 'CONST'
  if name in original.local_publics:
   need(g.target_method==0 and m._segment(g.target).name=='_DATA'and g.frame_method==1 and r['symbol']['binding']==0 and r['symbol']['section']==8,'qualified private section/value');need(add+r['symbol']['value']==old+original.publics[name][1],'private value counted once');private+=1
  elif f.target_method==2:need(g.target_method==2 and m.externals[g.target-1]==name and g.frame_method==5 and r['symbol']['name']==name and r['symbol']['binding']==1 and add==old,'selected global E+A');globalself+=name in m.publics
  else:need(f.target_method==g.target_method==0 and m._segment(g.target).name==original._segment(f.target).name=='CONST'and old==add,'real literal section role')
  rows.append({'name':name,'original':dataclasses.asdict(f),'native':dataclasses.asdict(g),'ELF':r})
 need(private==23 and globalself==13,'all23 private13selectedself roles');need(bytes(original._segment(2).data)==bytes(m._segment(5).data)and bytes(original._segment(4).data)==bytes(m._segment(7).data),'all CONST/DATA bytes literal');return {'roles':rows,'private_references':private,'selected_self_calls':globalself}
