"""Debug metadata must be explicit and unreachable from runtime output."""
import copy
from dataclasses import replace
import importlib
import unittest

from tools.prove_module import Module
from omf32 import Segment,Fixup


def fixture():
    m=Module(name='debug fixture')
    m.segments=[Segment('_TEXT','CODE',8,0x29,bytearray(8)),
                Segment('$$SYMBOLS','DEBSYM',3,0x20,bytearray(b'ABC'),2)]
    m.comments=[(0xaa,b'OS220'),(0xfe,b'D\x01\x03C')]
    m.publics={'entry_':(1,0)}
    m.fixups=[Fixup(2,0,2,1,False,4,None,0,1,0)]
    return m


class ObjectContributionTests(unittest.TestCase):
    def test_explicit_debug_projection_preserves_runtime_and_original(self):
        project=importlib.import_module('tools.object_contributions').without_watcom_debug
        m=fixture();before=copy.deepcopy(m)
        view,excluded=project(m)
        self.assertEqual(m,before)
        self.assertEqual(view.segments[0],m.segments[0])
        self.assertEqual(view.segments[1].size,0)
        self.assertEqual(view.fixups,[])
        self.assertEqual(excluded[0]['bytes'],3)
        self.assertEqual(excluded[0]['fixups'],1)
        self.assertEqual(excluded[0]['name'],'$$SYMBOLS')

    def test_rejects_unknown_metadata_and_runtime_debug_references(self):
        project=importlib.import_module('tools.object_contributions').without_watcom_debug
        variants=[]
        for field,value in [('name','other'),('class_name','DATA'),
                            ('attributes',0x29),('access',None)]:
            m=fixture();setattr(m.segments[1],field,value);variants.append(m)
        m=fixture();m.comments=[];variants.append(m)
        m=fixture();m.publics['bad_']=(2,0);variants.append(m)
        m=fixture();m.groups=[('GROUP',(2,))];variants.append(m)
        runtime=Fixup(1,0,4,9,False,4,None,0,2,0)
        m=fixture();m.fixups.append(runtime);variants.append(m)
        m=fixture();m.fixups.append(replace(runtime,target=1,frame_method=0,frame=2));variants.append(m)
        for number,m in enumerate(variants):
            with self.subTest(variant=number),self.assertRaises(ValueError):
                project(m)
