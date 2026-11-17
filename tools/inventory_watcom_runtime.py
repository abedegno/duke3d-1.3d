"""Inventory immutable supplied Watcom members; never award rebuilt-source credit.

No object or target payload is emitted. Discovery nominations are replayed through
the complete unmodified native verifier, including non-CODE segments and locals.
"""
import argparse
from dataclasses import asdict
import hashlib
import json
from pathlib import Path
import struct
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(ROOT), str(ROOT/"profiles/watcom/tools")]
from omf32 import Module
from le import LEImage
from tools.infer_bindings import infer_bindings
from tools.verify_module import verify_module, external_anchor_bindings
from tools.prove_module import assert_contributions
from tools.watcom_runtime_105 import (SELECTED_105, MATH_LIBRARY_SHA256,
                                       SELECTION_SHA256, CHAIN_SHA256, SURVEY_SHA256)

TARGET_SHA256 = "a197b6b4097fa39987f4a843141830ff1553eb52b606b51fc67d067560de0cf4"
TARGET_SIZE = 1179131
SOURCE_STATUS = "supplied original stock toolchain component"
DISCOVERY_SHA256 = "601071dc48b62716e8391f23bb60e6acbe53b3c9ffcdf69034427d06bd75ef97"
ADDITIONAL_DISCOVERY_SHA256 = "6028a46ce0e4878ac945cb52e5b04e088f5c26bcc0ef89079d1cf5c4e1ed75fd"
LIBRARIES = {
    'toolchains/watcom-10.0-ga/LIB386/DOS/clib3r.lib': '6f250d0e791ba05c6857d57de1ac5e65b6a5db7cb390a7e8f48035e5a4bd4363',
    'toolchains/watcom-10.0-ga/LIB386/math387r.lib': 'ccc96d4aa29c2c798da9c57a085e02614e88739b46cd1c47609fd39c5c8647c9',
    'toolchains/watcom-10.5/LIB386/DOS/clib3r.lib': '151fc7d895b171145466f77b1624d27952fa631971b0fc33d479e02eda3bbcc8',
    'toolchains/watcom-10.5/LIB386/math387r.lib': MATH_LIBRARY_SHA256,
}

# Immutable member identity and CODE nominations from Task9 discovery, not acceptance.
SELECTED = {
    'toolchains/watcom-10.0-ga/LIB386/DOS/clib3r.lib': [
        {'offset': 16, 'size': 425, 'sha256': 'f3138971eb6cf5df56e845a11f2bde2c8488f4f5e4c4cdb9edef1b0f1004f6d4', 'name': 'amodf386', 'code_offset': 605802, 'expected': {'initialized_bytes': 300, 'zero_fill_bytes': 0, 'verified_fixups': 0}},
        {'offset': 1328, 'size': 188, 'sha256': '294ab28d4742dc141b47f234e4d8342d2e271cfd72e001c4e4e25b5354e4f8b0', 'name': 'fdfs386', 'code_offset': 609716, 'expected': {'initialized_bytes': 76, 'zero_fill_bytes': 0, 'verified_fixups': 0}},
        {'offset': 6048, 'size': 286, 'sha256': 'f7b5ec05fc52045837fa915da088a122f67d580d057c3d7f9b02cce834c0580f', 'name': '__stos', 'code_offset': 589760, 'expected': {'initialized_bytes': 163, 'zero_fill_bytes': 0, 'verified_fixups': 0}},
        {'offset': 9200, 'size': 179, 'sha256': 'a64e8f7edbfa8131cb267a6cbbbb4eb193e2bab123090fc53b7a9f5a4a3b86c6', 'name': 'drive386', 'code_offset': 592118, 'expected': {'initialized_bytes': 40, 'zero_fill_bytes': 0, 'verified_fixups': 0}},
        {'offset': 9392, 'size': 167, 'sha256': 'a4eba5d1440d15d10063de17b8caf4e4c897ee3eb6d63be975dd553a7bf1f7ef', 'name': 'error386', 'code_offset': 597694, 'expected': {'initialized_bytes': 19, 'zero_fill_bytes': 0, 'verified_fixups': 1}},
        {'offset': 9568, 'size': 226, 'sha256': '88761004a6f2dc31148835c166bd931515b409eda9b49cb606cc1025aa2a2ba1', 'name': 'file386', 'code_offset': 589610, 'expected': {'initialized_bytes': 46, 'zero_fill_bytes': 0, 'verified_fixups': 3}},
        {'offset': 10384, 'size': 190, 'sha256': 'd2c3f1687278d9e4e0932dd8fd027e60971eac742de000e35be23744885d8928', 'name': 'gtime386', 'code_offset': 591168, 'expected': {'initialized_bytes': 53, 'zero_fill_bytes': 0, 'verified_fixups': 0}},
        {'offset': 11808, 'size': 203, 'sha256': 'd6dbb5c5cd5484d21fa88fd022a5110e7d7e103351ca0a192c3be372b1689da9', 'name': 'io386', 'code_offset': 589560, 'expected': {'initialized_bytes': 49, 'zero_fill_bytes': 0, 'verified_fixups': 1}},
        {'offset': 23680, 'size': 358, 'sha256': 'fc1356fd7f85b047581bdadf6e940b1b88951ba5791bb5ae2e042fa19d253e25', 'name': 'bits', 'code_offset': 601171, 'expected': {'initialized_bytes': 70, 'zero_fill_bytes': 0, 'verified_fixups': 2}},
        {'offset': 24496, 'size': 273, 'sha256': '5a26e4030eb0870e09c9f8c38d381d5a0ab94ade7e54c5eff1f025f33103948b', 'name': 'cmp386', 'code_offset': 586240, 'expected': {'initialized_bytes': 161, 'zero_fill_bytes': 0, 'verified_fixups': 0}},
        {'offset': 33952, 'size': 258, 'sha256': '2a659a4271e2678d571f071a5b8e6221fd511d1eba5f55d349e8f1dda0136db2', 'name': 'strcpy', 'code_offset': 583173, 'expected': {'initialized_bytes': 31, 'zero_fill_bytes': 0, 'verified_fixups': 0}},
        {'offset': 36048, 'size': 252, 'sha256': 'e448bb540846ff4eaa4c98a6454730e9d9948e133416039e1ee2e95941f07079', 'name': 'strlen', 'code_offset': 583305, 'expected': {'initialized_bytes': 25, 'zero_fill_bytes': 0, 'verified_fixups': 0}},
        {'offset': 36880, 'size': 270, 'sha256': '107ea036545c80e9e17efadaf08cb245e69030fd60e4c5850446124ff41ffb1c', 'name': 'strncmp', 'code_offset': 587989, 'expected': {'initialized_bytes': 41, 'zero_fill_bytes': 0, 'verified_fixups': 0}},
        {'offset': 37152, 'size': 266, 'sha256': '7c33f78e8a90db6b743f11a5b8fbd85143d9df912b11c282f11296ad05dc9e2a', 'name': 'strncpy', 'code_offset': 588106, 'expected': {'initialized_bytes': 37, 'zero_fill_bytes': 0, 'verified_fixups': 0}},
        {'offset': 39920, 'size': 475, 'sha256': '377a44d03d773d8ff2be363e0ab05c68ba54fbae1f658b37d68ac3ec4943e529', 'name': 'strtok', 'code_offset': 589392, 'expected': {'initialized_bytes': 153, 'zero_fill_bytes': 0, 'verified_fixups': 6}},
        {'offset': 41968, 'size': 299, 'sha256': 'f3b2b7edc9950829cccaa93ea5e137b0cdb35a56beed95302e7e84fbc0d8bdb2', 'name': 'chktty', 'code_offset': 596578, 'expected': {'initialized_bytes': 49, 'zero_fill_bytes': 0, 'verified_fixups': 1}},
        {'offset': 47600, 'size': 342, 'sha256': 'f4ff34af354a215a0fbfe8afdaff49b1ea2507746e5be591dbbb9b3bec39a53c', 'name': 'flushall', 'code_offset': 599742, 'expected': {'initialized_bytes': 52, 'zero_fill_bytes': 0, 'verified_fixups': 2}},
        {'offset': 49952, 'size': 449, 'sha256': 'a6d2695db633080ce09f3308e47bebd92f4b186e129454a3ec88ce7e0fd1ed9f', 'name': 'fputc', 'code_offset': 596361, 'expected': {'initialized_bytes': 164, 'zero_fill_bytes': 0, 'verified_fixups': 4}},
        {'offset': 58256, 'size': 289, 'sha256': '7756d44985c4a70079a3d963d98a402f32c4070b7be425341e78074d5aabdb82', 'name': 'iobaddr', 'code_offset': 626189, 'expected': {'initialized_bytes': 31, 'zero_fill_bytes': 0, 'verified_fixups': 1}},
        {'offset': 58560, 'size': 557, 'sha256': '260a1018e48573472daa6245d8631b6ddc2fb48323d3568aabae0e150c34e706', 'name': 'iomode', 'code_offset': 597587, 'expected': {'initialized_bytes': 194, 'zero_fill_bytes': 0, 'verified_fixups': 7}},
        {'offset': 64816, 'size': 270, 'sha256': '709150f6611a93a40951ccdb07a50ebfd2ffeec84eb8590d61263d7a30192736', 'name': 'rewind', 'code_offset': 590513, 'expected': {'initialized_bytes': 23, 'zero_fill_bytes': 0, 'verified_fixups': 1}},
        {'offset': 75200, 'size': 440, 'sha256': '121ab7b4d090826c6fd95fa79b840064939e9b04fd1c92a23d44d2414d5c89a8', 'name': 'cmain386', 'code_offset': 596879, 'expected': {'initialized_bytes': 79, 'zero_fill_bytes': 0, 'verified_fixups': 9}},
        {'offset': 111840, 'size': 157, 'sha256': '82e5427401753689730d72e50e4ca4ac0bad8fd5b82ff61ac44f74eaed9662c1', 'name': 'set386', 'code_offset': 588144, 'expected': {'initialized_bytes': 24, 'zero_fill_bytes': 0, 'verified_fixups': 1}},
        {'offset': 114192, 'size': 277, 'sha256': 'f1ffa6b3ab68a03fcdde53494741c1c7e88de61b113d1e2a54073eaa73724b01', 'name': 'div', 'code_offset': 588530, 'expected': {'initialized_bytes': 56, 'zero_fill_bytes': 0, 'verified_fixups': 0}},
        {'offset': 119472, 'size': 390, 'sha256': '90bc391de63cc53f2e94d507da0233c35dec3d7a09cbf39802676c8d956e6374', 'name': 'rand', 'code_offset': 583791, 'expected': {'initialized_bytes': 62, 'zero_fill_bytes': 0, 'verified_fixups': 3}},
        {'offset': 119872, 'size': 144, 'sha256': '23846f03c10c0229431fe0eaeb6abfc76bc5193fe0422ed9314f4f0b6b80baea', 'name': 'chint386', 'code_offset': 590488, 'expected': {'initialized_bytes': 25, 'zero_fill_bytes': 0, 'verified_fixups': 0}},
        {'offset': 120448, 'size': 335, 'sha256': '741a5cd665c1d9f2c435f706ab44e51d52cadf2282c2e605fcc42cba23f1b11c', 'name': 'enterdb', 'code_offset': 609677, 'expected': {'initialized_bytes': 39, 'zero_fill_bytes': 0, 'verified_fixups': 1}},
        {'offset': 121232, 'size': 229, 'sha256': '2b0d3ef56aa024114acec598762259b3a20a0e30bf9999f2f9792b170cea7ed3', 'name': 'inp', 'code_offset': 589551, 'expected': {'initialized_bytes': 8, 'zero_fill_bytes': 0, 'verified_fixups': 0}},
        {'offset': 121472, 'size': 232, 'sha256': '4f3adce508d0c1ff1bb2e460db1d0425de3da369df91f1ad705d77b1d8adf799', 'name': 'inpw', 'code_offset': 589751, 'expected': {'initialized_bytes': 9, 'zero_fill_bytes': 0, 'verified_fixups': 0}},
        {'offset': 122784, 'size': 1131, 'sha256': 'e4bc3623cb445ba5d11750dd25c06f3630406234c5b94c80d641f4e081cdaad2', 'name': 'intxa386', 'code_offset': 599794, 'expected': {'initialized_bytes': 990, 'zero_fill_bytes': 0, 'verified_fixups': 2}},
        {'offset': 125664, 'size': 246, 'sha256': '67b311ee1e95c9ef3a1518a01d71f017f74333a6953e60359fc858946417d8ee', 'name': 'segread', 'code_offset': 588281, 'expected': {'initialized_bytes': 40, 'zero_fill_bytes': 0, 'verified_fixups': 0}},
        {'offset': 130480, 'size': 569, 'sha256': '302835931d5ae55137f42c159c72976467d72b3e451dcb2dda65f9b8c2fd461d', 'name': 'memalloc', 'code_offset': 597714, 'expected': {'initialized_bytes': 435, 'zero_fill_bytes': 0, 'verified_fixups': 0}},
        {'offset': 137184, 'size': 250, 'sha256': 'de51f91cff67456548f278db57214b863650089f84956a00fd1dd6b58083a13c', 'name': 'nmsize', 'code_offset': 591250, 'expected': {'initialized_bytes': 9, 'zero_fill_bytes': 0, 'verified_fixups': 0}},
        {'offset': 141568, 'size': 321, 'sha256': 'cd5951f21d3863acbef8afe8b701785e06a5de48ebe6e2c4f402e1ad0507dd1f', 'name': 'filelen', 'code_offset': 588856, 'expected': {'initialized_bytes': 61, 'zero_fill_bytes': 0, 'verified_fixups': 3}},
        {'offset': 148112, 'size': 260, 'sha256': '1c5da25cf079eda4b0ebbc474dd91f00feed3ceff78eea6f03b9c793c2b2ad10', 'name': 'tell', 'code_offset': 596862, 'expected': {'initialized_bytes': 17, 'zero_fill_bytes': 0, 'verified_fixups': 1}},
        {'offset': 150336, 'size': 158, 'sha256': 'ce3b9730a8586230ba08cbf1cb4a99f867de1addf5f616b4537ed8b4bd6d77d2', 'name': 'ini87386', 'code_offset': 623308, 'expected': {'initialized_bytes': 39, 'zero_fill_bytes': 0, 'verified_fixups': 0}},
        {'offset': 150768, 'size': 322, 'sha256': 'a9aa6b3e3890321ea2a5e0793529f011ed10488e133ac668f097934b6c4fbd58', 'name': 'accss', 'code_offset': 592025, 'expected': {'initialized_bytes': 59, 'zero_fill_bytes': 0, 'verified_fixups': 1}},
        {'offset': 159312, 'size': 574, 'sha256': '6ef0aa62ab28bd9e43342ff5dbdb858858d81f8b0b5024f1852a780d9968d6fc', 'name': 'setenvp', 'code_offset': 609465, 'expected': {'initialized_bytes': 212, 'zero_fill_bytes': 0, 'verified_fixups': 11}},
        {'offset': 163504, 'size': 468, 'sha256': '2c631b23ecb1b895f3e6cba7b253a3ff4cd00f62061317020aa318f0a0dc3a2b', 'name': 'itoa', 'code_offset': 608548, 'expected': {'initialized_bytes': 138, 'zero_fill_bytes': 0, 'verified_fixups': 2}},
        {'offset': 166752, 'size': 279, 'sha256': 'c83f18993b0808daf6f92c00787257f623ac04d6bbd1274c83c18a5009dca3e1', 'name': 'getch', 'code_offset': 584054, 'expected': {'initialized_bytes': 29, 'zero_fill_bytes': 0, 'verified_fixups': 2}},
        {'offset': 167040, 'size': 280, 'sha256': 'afc4c3cdf63f867186a474b0580a08cabd6a8ae10e51e84b409a2cd6dc3fc65c', 'name': 'gtche', 'code_offset': 609436, 'expected': {'initialized_bytes': 29, 'zero_fill_bytes': 0, 'verified_fixups': 2}},
        {'offset': 171872, 'size': 258, 'sha256': 'b573d65f7d3dd0eeb1243ba2fa4572cb74fa6a05b0db9b4eb6616f81e52b8d46', 'name': 'tolower', 'code_offset': 583886, 'expected': {'initialized_bytes': 14, 'zero_fill_bytes': 0, 'verified_fixups': 0}},
        {'offset': 172144, 'size': 258, 'sha256': 'b029b99bfc418afe78812949c633d4c1b323435433d757418bfcc5646c16187f', 'name': 'toupper', 'code_offset': 583021, 'expected': {'initialized_bytes': 14, 'zero_fill_bytes': 0, 'verified_fixups': 0}},
    ],
    'toolchains/watcom-10.0-ga/LIB386/math387r.lib': [
        {'offset': 8608, 'size': 150, 'sha256': 'ba529dc6f7de18968ea9aa68551822d3c1136dc6e983c540676a1b99cd6a1427', 'name': 'fchop', 'code_offset': 592158, 'expected': {'initialized_bytes': 29, 'zero_fill_bytes': 0, 'verified_fixups': 0}},
        {'offset': 9600, 'size': 348, 'sha256': '9a4c9d4c185af75177a112a2021087cb3dd4f9eb47800cf1c8800b6ab10d7385', 'name': 'frexp', 'code_offset': 626305, 'expected': {'initialized_bytes': 111, 'zero_fill_bytes': 0, 'verified_fixups': 0}},
        {'offset': 16928, 'size': 342, 'sha256': '5bfa535f8c7feed361a15e13b9c2d6d4b4b2df184735e6cc00f25ce53412f0bb', 'name': 'log387', 'code_offset': 625536, 'expected': {'initialized_bytes': 111, 'zero_fill_bytes': 0, 'verified_fixups': 1}},
        {'offset': 17280, 'size': 329, 'sha256': '5ac1a62c1b3cc59de64606c02ffeb19b4583fff257d528f7d48be236c0f0726c', 'name': 'log87e', 'code_offset': 626220, 'expected': {'initialized_bytes': 60, 'zero_fill_bytes': 0, 'verified_fixups': 1}},
        {'offset': 19232, 'size': 163, 'sha256': '69e242d8f454a28547256bcb0f4239271181c988c386e9578498ab494e643a26', 'name': 'modf387', 'code_offset': 626280, 'expected': {'initialized_bytes': 25, 'zero_fill_bytes': 0, 'verified_fixups': 1}},
    ],
}

# Additional fixed nominations, not scan-based acceptance. Every whole member
# still passes the same native byte/fixup gate, including explicitly placed pools.
ADDITIONAL_SELECTED = {
    'toolchains/watcom-10.0-ga/LIB386/DOS/clib3r.lib': [
        {'offset':9808,'size':339,'sha256':'2d6e61701504be3ec3f863b17aa3d60559abc6195d00ca6e852e9900b5d527d8','name':'find386','code_offset':587502,'group_frames':{1:(3,0)},'expected':{'initialized_bytes':130,'zero_fill_bytes':0,'verified_fixups':4}},
        {'offset':34896,'size':820,'sha256':'1a5cf8e65811c7482a5b4ad7524bd9bede0ec8dc68bc032a41fe2abac6f58d1f','name':'strerror','code_offset':591021,'group_frames':{1:(3,0)},'expected':{'initialized_bytes':408,'zero_fill_bytes':0,'verified_fixups':18}},
        {'offset':40944,'size':332,'sha256':'27313d199a3730415155a2e48821c8c2ca252168c1c0abf31edf72984c06aa8e','name':'vsprintf','code_offset':591044,'expected':{'initialized_bytes':40,'zero_fill_bytes':0,'verified_fixups':2}},
        {'offset':81536,'size':415,'sha256':'41e90a6ed5d2baebf8cafefb2e43ab8e9ed9f1065874c2eb88f3693e6a9861a6','name':'inirt386','code_offset':596958,'group_frames':{1:(3,0)},'expected':{'initialized_bytes':154,'zero_fill_bytes':0,'verified_fixups':4}},
        {'offset':86368,'size':440,'sha256':'a586861497aa565819ceb06e10d740f26190e2b6aaca24f04a1f33193925ef79','name':'stk386','code_offset':590832,'initializer_nomination':'stk386-XI','group_frames':{1:(3,0)},'expected':{'initialized_bytes':98,'zero_fill_bytes':0,'verified_fixups':6}},
    ],
    'toolchains/watcom-10.0-ga/LIB386/math387r.lib': [
        {'offset':8768,'size':338,'sha256':'f24a882bf1dec90932792fe947328defe5f17bb6e89d67e6dcebed14cd6f5509','name':'floor','code_offset':625647,'group_frames':{1:(3,0)},'expected':{'initialized_bytes':68,'zero_fill_bytes':0,'verified_fixups':2}},
        {'offset':17616,'size':964,'sha256':'9ff1a1a08d83bc50db1f134dab38d6066a54c4ff4f521ee804fcd1b116216bfd','name':'math2err','code_offset':623887,'group_frames':{1:(3,0)},'segment_placements':{2:(3,28864)},'expected':{'initialized_bytes':429,'zero_fill_bytes':0,'verified_fixups':29}},
    ],
}
# Task55 finite version research: fixed supplied 10.5 witnesses only. These
# complete members are identical in 10.6; no unique historical version is proved.
ADDITIONAL_SELECTED['toolchains/watcom-10.5/LIB386/DOS/clib3r.lib'] = [
    {'offset':73808,'size':276,'sha256':'b404698a136b3bd5b1df12df8877392b0ab156984297e26559860bf30fbbd873','name':'vprintf','code_offset':591233,'expected':{'initialized_bytes':17,'zero_fill_bytes':0,'verified_fixups':2}},
    {'offset':196400,'size':518,'sha256':'aa52b33f130584f880e8d03e080bf8f1054d75ef26f03c941d448ea5b40799a9','name':'nrealloc','code_offset':591259,'expected':{'initialized_bytes':158,'zero_fill_bytes':0,'verified_fixups':9}},
]
SELECTED['toolchains/watcom-10.5/LIB386/DOS/clib3r.lib'] = []
for library, members in SELECTED_105.items():
    ADDITIONAL_SELECTED.setdefault(library, []).extend(members)
# Whole immutable emulator: Task348 role audit and actual Task349 F0 native
# witness; the strict whole gate validates every byte and all692 fields.
EMU387_LIBRARY = 'toolchains/watcom-10.0-ga/LIB386/DOS/emu387.lib'
LIBRARIES[EMU387_LIBRARY] = '5b150d1cdca625eb27747b7ac182e36f5a66571e4441ccc19caccc6fbf773b5c'
ADDITIONAL_SELECTED[EMU387_LIBRARY] = [
    {'offset':400,'size':20259,
     'sha256':'532511cba5bca8b9ec8602ab60ed05917b5ba6266393b5c9fcab4b9a060c5b58',
     'name':'emu387','code_offset':610168,'group_frames':{1:(3,0)},
     'dependency_nomination':{'kind':'verified hook387 pointer to emulator public',
                              'symbol':'__int7','value':[1,611168],
                              'source_public_offset':1000},
     'expected':{'initialized_bytes':12960,'zero_fill_bytes':0,'verified_fixups':692}},
]
for library, members in ADDITIONAL_SELECTED.items():
    SELECTED.setdefault(library, []).extend(members)

# Bounded diagnostic representatives; no negative baseline rerun.
BLOCKERS = {
    'toolchains/watcom-10.5/LIB386/math387r.lib': [],
    'toolchains/watcom-10.5/LIB386/DOS/clib3r.lib': [],
    'toolchains/watcom-10.0-ga/LIB386/DOS/clib3r.lib': [
        {'offset': 85152, 'size': 116, 'sha256': '0a183c8eec2ab03238d56b6eb5f9e2a0e2878a55e564c65ad52aab3b7aba3819', 'name': 'seg386', 'code_offset': None},
    ],
    'toolchains/watcom-10.0-ga/LIB386/math387r.lib': [
    ],
}

BLOCKERS[EMU387_LIBRARY] = []


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def _record(raw, offset, limit):
    if offset + 3 > limit:
        raise ValueError('truncated OMF record header')
    size = 3 + int.from_bytes(raw[offset+1:offset+3], 'little')
    end = offset + size
    if size < 4 or end > limit:
        raise ValueError('OMF record exceeds archive/member boundary')
    checksum = 'omitted' if raw[end-1] == 0 else 'valid'
    if checksum == 'valid' and sum(raw[offset:end]) & 255:
        raise ValueError('bad OMF record checksum')
    return {'offset': offset, 'end': end, 'size': size, 'kind': raw[offset],
            'checksum': checksum, 'sha256': digest(raw[offset:end])}


def read_archive(raw):
    """Strict physical OMF-library framing, without interpreting unknown records.

    LIBHDR/LIBEND are archive containers, not checksummed object records. Members
    run from their page-aligned THEADR through the exact MODEND record. Dictionary
    pages and archive page padding never become target contributions.
    """
    if len(raw) < 16 or raw[0] != 0xf0:
        raise ValueError('missing OMF LIBHDR')
    page = 3 + int.from_bytes(raw[1:3], 'little')
    if page < 16 or page > 32768 or page & (page-1) or page > len(raw):
        raise ValueError('invalid archive page size')
    dictionary, blocks, flags = struct.unpack_from('<IHB', raw, 3)
    if flags not in (0, 1) or any(raw[10:page]):
        raise ValueError('unsupported LIBHDR flags/reserved bytes')
    if (dictionary < page or dictionary % 512 or not blocks or
            dictionary + blocks*512 != len(raw)):
        raise ValueError('invalid archive dictionary boundary/extent')
    members = []; pos = page; padding_bytes = 0
    while pos < dictionary and raw[pos] == 0x80:
        start = pos; records = []
        while True:
            rec = _record(raw, pos, dictionary)
            if records and rec['kind'] == 0x80:
                raise ValueError('nested THEADR before MODEND')
            records.append(rec); pos = rec['end']
            if rec['kind'] in (0x8a, 0x8b):
                break
        first = records[0]
        length = raw[start+3]
        if length == 0 or start+4+length != first['end']-1:
            raise ValueError('invalid member THEADR name')
        name = raw[start+4:start+4+length].decode('latin1')
        aligned = (pos+page-1)//page*page
        if aligned > dictionary or any(raw[pos:aligned]):
            raise ValueError('invalid member archive page padding')
        members.append({'offset': start, 'end': pos, 'size': pos-start,
                        'name': name, 'sha256': digest(raw[start:pos]),
                        'padding_bytes': aligned-pos, 'records': records})
        padding_bytes += aligned-pos; pos = aligned
    if pos+3 > dictionary or raw[pos] != 0xf1:
        raise ValueError('missing archive LIBEND')
    if pos+3+int.from_bytes(raw[pos+1:pos+3], 'little') != dictionary:
        raise ValueError('LIBEND does not end at dictionary')
    if any(raw[pos+3:dictionary]):
        raise ValueError('nonzero LIBEND padding')
    return {'sha256': digest(raw), 'size': len(raw), 'page_size': page,
            'flags': flags, 'dictionary_offset': dictionary,
            'dictionary_bytes': blocks*512,
            'dictionary_sha256': digest(raw[dictionary:]),
            'member_padding_bytes': padding_bytes, 'libend_offset': pos,
            'libend_bytes': dictionary-pos, 'members': members}


def select_member(raw, archive, spec):
    """A member nomination must identify one complete archive member exactly."""
    members = [m for m in archive['members'] if m['offset'] == spec['offset']]
    if len(members) != 1:
        raise ValueError('member offset is not an archive boundary')
    member = members[0]
    if any(member[k] != spec[k] for k in ('size', 'sha256', 'name')):
        raise ValueError('member identity/extent mismatch')
    if digest(raw[member['offset']:member['end']]) != member['sha256']:
        raise ValueError('member identity changed after archive parse')
    return member


def native_gate(module, image, inferred, expected, *, group_frames=None):
    """No projection, masks, metadata exceptions or partial contribution credit."""
    proof = verify_module(module, image, inferred['placements'], inferred['symbols'],
                          group_frames=group_frames)
    assert_contributions(proof, expected)
    # Enforce explicit local scope before exporting any cross-member anchors.
    external_anchor_bindings(proof)
    return proof


def nominate_stk_initializer(module, image, inferred):
    """Nominate only the fixed stock XI record; whole verification is required.

    The original pointer refers to CODE+0, not the public __STK at CODE+27.
    Neither its priority/status bytes nor any other constructor are accepted
    from the pointer alone. Original objects and target data remain unchanged.
    """
    code=inferred.get('placements',{}).get(1)
    if (module.name!='stk386' or code!=(1,590832) or
            any(type(n) is not int for n in code)):
        raise ValueError('invalid fixed stack CODE nomination')
    segment=module._segment(4)
    if (segment.name,segment.class_name,segment.size,segment.attributes)!=(
            'XI','DATA',6,73) or len(segment.data)!=6:
        raise ValueError('unexpected stack XI segment geometry')
    pointers=[f for f in module.fixups if f.segment==4]
    if len(pointers)!=1:
        raise ValueError('stack XI requires exactly one original pointer')
    pointer=pointers[0]
    fields=(pointer.offset,pointer.width,pointer.location,pointer.frame_method,
            pointer.target_method,pointer.target,pointer.displacement)
    if (any(type(n) is not int for n in fields) or fields!=(2,4,9,5,0,1,0) or
            pointer.relative is not False or pointer.frame is not None or
            int.from_bytes(segment.data[2:6],'little')!=0):
        raise ValueError('unexpected stack XI pointer geometry/addend')
    edges=[e for e in image.read_fixups() if
           (e.target_object,e.target_offset,e.width,e.source_type,e.alias)==
           (1,590832,4,7,False)]
    if len(edges)!=1:
        raise ValueError('stack XI pointer nomination absent or ambiguous')
    edge=edges[0]
    if edge.source_object!=3 or type(edge.source_offset) is not int:
        raise ValueError('stack XI pointer outside DATA object')
    start=edge.source_offset-pointer.offset
    if start<0 or start+segment.size>image._object(3).size:
        raise ValueError('stack XI pointer outside DATA object')
    value=(3,start)
    if 4 in inferred['placements'] and inferred['placements'][4]!=value:
        raise ValueError('conflicting stack XI nomination')
    return {'kind':'unique stack XI pointer nomination; full native gate required',
            'segment':4,'value':value,
            'edge':{'source_object':3,'source_offset':edge.source_offset,
                    'target_object':1,'target_offset':590832}}


def nominate_matherr_initializer(module, image, inferred):
    """Bind only the measured stock hook; accept nothing without the whole gate.

    CODE independently places __RWD_matherr. Its original initialized DATA
    pointer supplies the otherwise unreferenced __matherr external binding.
    This does not prove the pointed-to function's source or its native body.
    """
    if module.name != '_matherr' or module.format != 'standard-omf':
        raise ValueError('invalid fixed matherr module nomination')
    checks = (
        (inferred.get('placements', {}).get(1), (1, 625264)),
        (inferred.get('placements', {}).get(4), (3, 73156)),
        (inferred.get('symbols', {}).get('__RWD_matherr'), (3, 73156)),
        (module.publics.get('__RWD_matherr'), (4, 0)),
    )
    for actual, expected in checks:
        if (not isinstance(actual, (tuple, list)) or len(actual) != 2 or
                any(type(n) is not int for n in actual) or tuple(actual) != expected):
            raise ValueError('invalid fixed matherr source placement/binding')
    if (not module.externals or module.externals[0] != '__matherr' or
            1 in module.local_externals or '__matherr' in module.publics or
            '__RWD_matherr' in module.local_publics or
            module.groups != [('DGROUP', (2, 3, 4, 5))]):
        raise ValueError('changed matherr pointer owner/external scope/group')
    segment = module._segment(4)
    if ((segment.name, segment.class_name, segment.size, segment.attributes,
         segment.access) != ('_DATA', 'DATA', 4, 169, None) or len(segment.data) != 4):
        raise ValueError('unexpected matherr DATA segment geometry')
    pointers = [f for f in module.fixups if f.segment == 4]
    if len(pointers) != 1:
        raise ValueError('matherr DATA requires exactly one original pointer')
    pointer = pointers[0]
    fields = (pointer.segment, pointer.offset, pointer.width, pointer.location,
              pointer.frame_method, pointer.target_method, pointer.target,
              pointer.displacement)
    if (any(type(n) is not int for n in fields) or fields != (4, 0, 4, 9, 5, 2, 1, 0) or
            pointer.relative is not False or pointer.frame is not None or
            int.from_bytes(segment.data, 'little') != 0):
        raise ValueError('unexpected matherr DATA pointer geometry/addend')
    edges = [e for e in image.read_fixups()
             if (e.source_object, e.source_offset) == (3, 73156)]
    if len(edges) != 1:
        raise ValueError('matherr DATA loader pointer absent or ambiguous')
    edge = edges[0]
    fields = (edge.page, edge.source_object, edge.source_offset, edge.source_type,
              edge.width, edge.target_object, edge.target_offset, edge.target_address)
    if (any(type(n) is not int for n in fields) or
            fields != (173, 3, 73156, 7, 4, 1, 626184, 691720) or edge.alias is not False):
        raise ValueError('unexpected matherr typed native pointer geometry')
    positions = [image.file_offset(3, 73156+i) for i in range(4)]
    if any(p is None for p in positions):
        raise ValueError('matherr native DATA pointer must be entirely file-backed')
    native_field = bytes(image.data[p] for p in positions)
    if int.from_bytes(native_field, 'little') != edge.target_offset:
        raise ValueError('changed matherr native pointer field/addend')
    value = (edge.target_object, edge.target_offset)
    if '__matherr' in inferred['symbols']:
        current = inferred['symbols']['__matherr']
        if (not isinstance(current, (tuple, list)) or len(current) != 2 or
                any(type(n) is not int for n in current) or tuple(current) != value):
            raise ValueError('conflicting matherr external pointer nomination')
    return {'kind':'unique matherr DATA pointer nomination; full native gate required',
            'symbol':'__matherr', 'value':value, 'callee_source_credit':0,
            'edge':{'source_object':edge.source_object, 'source_offset':edge.source_offset,
                    'source_type':edge.source_type, 'width':edge.width,
                    'target_object':edge.target_object, 'target_offset':edge.target_offset,
                    'target_address':edge.target_address, 'alias':edge.alias}}


def coverage_totals(ranges, accepted):
    """Subtract the union of diagnostic source overlaps, with no source credit."""
    for rows in (ranges, accepted):
        for r in rows:
            if (r['object'] < 1 or not 0 <= r['start'] < r['end'] or
                    ('size' in r and r['size'] != r['end']-r['start'])):
                raise ValueError('invalid diagnostic coverage extent')
    for n, r in enumerate(ranges):
        if any(r['object'] == old['object'] and r['start'] < old['end'] and
               old['start'] < r['end'] for old in ranges[:n]):
            raise ValueError('overlapping verified supplied components')
    initialized = zero = code = overlap_init = overlap_zero = overlap_code = 0
    intersections = []
    for r in ranges:
        length = r['end']-r['start']; bss = r['class'].upper() == 'BSS'
        if bss: zero += length
        else: initialized += length
        if r['class'].upper() == 'CODE': code += length
        clips = []
        for old in accepted:
            if old['object'] != r['object']: continue
            start, end = max(r['start'], old['start']), min(r['end'], old['end'])
            if start < end:
                clips.append((start, end))
                intersections.append({'owner': old['owner'], 'object': r['object'],
                                      'start': start, 'end': end, 'bytes': end-start,
                                      'component': r.get('component')})
        union = []; count = 0
        for start, end in sorted(clips):
            if union and start <= union[-1][1]: union[-1][1] = max(end, union[-1][1])
            else: union.append([start, end])
        count = sum(end-start for start, end in union)
        if bss: overlap_zero += count
        else: overlap_init += count
        if r['class'].upper() == 'CODE': overlap_code += count
    return {'initialized_bytes': initialized, 'zero_fill_bytes': zero, 'code_bytes': code,
            'overlap_initialized_bytes': overlap_init, 'overlap_zero_fill_bytes': overlap_zero,
            'overlap_code_bytes': overlap_code,
            'additional_supplied_initialized_bytes': initialized-overlap_init,
            'additional_supplied_zero_fill_bytes': zero-overlap_zero,
            'additional_supplied_code_bytes': code-overlap_code,
            'rebuilt_source_bytes_added': 0, 'complete_source_contributions_added': 0,
            'overlaps': intersections}


def _metadata(module):
    return {'segments': [{'number': n, 'name': s.name, 'class': s.class_name,
                          'size': s.size, 'attributes': s.attributes, 'access': s.access}
                         for n, s in enumerate(module.segments, 1)],
            'publics': module.publics, 'local_publics': sorted(module.local_publics),
            'externals': module.externals,
            'local_externals': sorted(module.local_externals), 'groups': module.groups,
            'comments': [{'class': k, 'payload_hex': p.hex()} for k, p in module.comments],
            'options_scope': 'observed producer/model metadata only; original command line not recovered',
            'options_metadata': [{'class': k, 'payload_hex': p.hex(),
                                  'ascii': p.decode('latin1')}
                                 for k, p in module.comments if k in (0, 0x9b, 0xfe)],
            'code_data_ranges': module.code_data_ranges,
            'fixups': [asdict(f) for f in module.fixups]}


def inventory(target, libraries, accepted_audit):
    if len(target) != TARGET_SIZE or digest(target) != TARGET_SHA256:
        raise ValueError('target identity mismatch')
    if set(libraries) != set(LIBRARIES):
        raise ValueError('stock library identity set mismatch')
    # Validate every immutable input before any native acceptance.
    for name, expected in LIBRARIES.items():
        if digest(libraries[name]) != expected:
            raise ValueError('library identity mismatch: '+name)
    image = LEImage.parse(target)
    components = []; blockers = []; archives = []; ranges = []; anchors = {}
    for library, raw in libraries.items():
        archive = read_archive(raw)
        archives.append({'path': library, **{k: v for k, v in archive.items() if k != 'members'},
                         'member_count': len(archive['members']),
                         'selected_verified_member_count': len(SELECTED[library])})
        for spec in SELECTED[library]:
            member = select_member(raw, archive, spec)
            module = Module.parse(raw[member['offset']:member['end']])
            inferred = infer_bindings(module, image, 1, spec['code_offset'])
            if 'initializer_nomination' in spec:
                if spec['initializer_nomination']!='stk386-XI' or spec['name']!='stk386':
                    raise ValueError('unsupported stock initializer nomination')
                nomination=nominate_stk_initializer(module,image,inferred)
                inferred['placements'][nomination['segment']]=nomination['value']
                inferred['constraints'].append(nomination)
            if 'external_pointer_nomination' in spec:
                if (spec['external_pointer_nomination'] != '_matherr-DATA' or
                        spec['name'] != '_matherr' or
                        library != 'toolchains/watcom-10.5/LIB386/math387r.lib'):
                    raise ValueError('unsupported stock external pointer nomination')
                nomination = nominate_matherr_initializer(module, image, inferred)
                inferred['symbols'][nomination['symbol']] = nomination['value']
                inferred['constraints'].append(nomination)
            for number, value in spec.get('segment_placements', {}).items():
                segment = module._segment(number)
                if not segment.size or segment.class_name.upper() == 'CODE':
                    raise ValueError('explicit stock nomination requires nonempty non-CODE segment')
                value = tuple(value)
                if number in inferred['placements'] and inferred['placements'][number] != value:
                    raise ValueError('conflicting explicit stock segment nomination')
                inferred['placements'][number] = value
                inferred['constraints'].append({'kind':'explicit segment nomination; native gate required',
                                                'segment':number,'value':value})
            proof = native_gate(module, image, inferred, spec['expected'],
                                group_frames=spec.get('group_frames'))
            exported = external_anchor_bindings(proof)
            for name, value in exported.items():
                if name in anchors and anchors[name] != value:
                    raise ValueError('conflicting scoped stock-member anchor: '+name)
                anchors[name] = value
            component_ranges = []
            for n, seg in enumerate(module.segments, 1):
                if not seg.size: continue
                obj, start = inferred['placements'][n]
                row = {'component': module.name, 'segment': n, 'class': seg.class_name,
                       'object': obj, 'start': start, 'end': start+seg.size}
                component_ranges.append(row); ranges.append(row)
            components.append({**member, 'library': library, 'source_status': SOURCE_STATUS,
                               'rebuilt_source_credit': 0,
                               'discovery': {'historical_native_gate': 'reported verified; untrusted discovery',
                                             'code_nomination': [1, spec['code_offset']],
                                             'location_scan_is_proof': False},
                               'metadata': _metadata(module),
                               'placements': inferred['placements'],
                               'constraints': inferred['constraints'], 'expected': spec['expected'],
                               'verification': proof, 'external_anchor_bindings': exported,
                               'target_ranges': component_ranges})
            if spec in ADDITIONAL_SELECTED[library]:
                components[-1]['discovery']['origin'] = 'additional fixed stock-member nominations'
            if 'dependency_nomination' in spec:
                components[-1]['discovery']['dependency_nomination'] = spec['dependency_nomination']
        for spec in BLOCKERS[library]:
            member = select_member(raw, archive, spec)
            diagnostic = {**member, 'library': library,
                          'status': 'rejected diagnostic; zero supplied/source credit',
                          'code_nomination': [1, spec['code_offset']],
                          'location_scan_is_proof': False}
            try:
                module = Module.parse(raw[member['offset']:member['end']])
                diagnostic['metadata'] = _metadata(module)
                inferred = infer_bindings(module, image, 1, spec['code_offset'])
                diagnostic['inferred'] = inferred
                # A newly passing representative is a changed assumption, not an
                # automatic promotion without a fixed complete-contribution contract.
                verify_module(module, image, inferred['placements'], inferred['symbols'])
            except ValueError as error:
                diagnostic['native_error'] = str(error)
            else:
                raise ValueError('diagnostic blocker unexpectedly passed complete gate')
            # Small raw OMF metadata only: never serialize LEDATA/object payload.
            diagnostic['raw_metadata_records'] = [
                {**r, 'payload_hex': raw[r['offset']+3:r['end']-1].hex()}
                for r in member['records'] if r['kind'] in (0x88, 0x9c, 0x9d)]
            blockers.append(diagnostic)
    # RAND has an independently source-built native proof at this frozen baseline.
    # Always exclude it, even if an older/missing range audit omits its owner.
    rand_path = ROOT/'evidence/watcom_rand-module.json'
    rand_raw = rand_path.read_bytes()
    if digest(rand_raw) != 'bc934304b9e55469bbe6452e3fad7df9ac321170887cf6c630981da0c62a85d9':
        raise ValueError('rebuilt RAND evidence identity mismatch')
    rand_ranges = [{'owner': 'watcom_rand-module.json', 'object': 1,
                    'start': 583791, 'end': 583849, 'size': 58},
                   {'owner': 'watcom_rand-module.json', 'object': 3,
                    'start': 71832, 'end': 71836, 'size': 4}]
    accepted = list(accepted_audit['ranges'])
    for row in rand_ranges:
        if row not in accepted: accepted.append(row)
    totals = coverage_totals(ranges, accepted)
    for component in components:
        component['coverage_accounting'] = coverage_totals(component['target_ranges'], accepted)
    totals.update(verified_members=len(components),
                  verified_fixups=sum(c['verification']['verified_fixups'] for c in components))
    return {'kind': 'selected supplied original stock toolchain member inventory',
            'target': {'path': 'reference/DUKE3D.EXE', 'sha256': digest(target), 'size': len(target)},
            'scope': 'whole-member native contributions; original final-link selection/order remains unproved',
            'native_verification_inputs': {
                name: digest((ROOT/name).read_bytes()) for name in (
                    'tools/inventory_watcom_runtime.py', 'tools/infer_bindings.py',
                    'tools/verify_module.py', 'tools/match_function.py',
                    'tools/prove_module.py', 'profiles/watcom/tools/omf32.py',
                    'profiles/watcom/tools/le.py', 'tools/watcom_runtime_105.py')},
            'producer_scope': 'unmodified supplied archive members; no native compilation required or performed',
            'payload_emitted': False,

            'discovery': {'path': 'build/runtime-survey/library-survey.json',
                          'sha256': DISCOVERY_SHA256, 'used_as': 'nominations only; not acceptance'},
            'additional_discovery': {'path':'build/runtime-group-frame/stock-survey.json',
                                     'sha256':ADDITIONAL_DISCOVERY_SHA256,
                                     'used_as':'six fixed nominations only; not acceptance'},
            'fixed_105_extension_discovery': {
                'survey_sha256':SURVEY_SHA256,
                'selected_74_sha256':SELECTION_SHA256,
                'typed_matherr_chain_sha256':CHAIN_SHA256,
                'used_as':'76 fixed whole10.5 nominations only; not acceptance',
                'other_versions':'10.6 discoveries are not selected',
                'source_credit':0},
            'rebuilt_rand_evidence': {'path': 'evidence/watcom_rand-module.json',
                                      'sha256': digest(rand_raw),
                                      'diagnostic_source_overlap_ranges': rand_ranges},
            'libraries': archives, 'components': components, 'blockers': blockers,
            'totals': totals, 'accepted_range_input_scope': 'diagnostic overlap arithmetic only',
            'full_executable_rebuilt': False,
            'unresolved': ['unselected members have no current native acceptance',
                           'unsupported frame/comment records and missing non-CODE placements',
                           'candidate-only and modified/mismatching runtime bodies',
                           'startup/binder boundaries, member selection/order, full link and whole-file identity']}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--accepted-ranges', type=Path, required=True,
                        help='diagnostic integrated range audit; never an acceptance input')
    parser.add_argument('--report', type=Path, default=ROOT/'evidence/watcom-runtime-components.json')
    args = parser.parse_args()
    audit_raw = args.accepted_ranges.read_bytes()
    report = inventory((ROOT/'reference/DUKE3D.EXE').read_bytes(),
                       {name: (ROOT/name).read_bytes() for name in LIBRARIES},
                       json.loads(audit_raw))
    report['accepted_range_input'] = {'path': str(args.accepted_ranges), 'sha256': digest(audit_raw)}
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(report['totals'], sort_keys=True))


if __name__ == '__main__':
    main()
