#!/usr/bin/env python3
"""
test_annotate_ll.py — structured tests for annotate_ll.py

Run:
    python3 test_annotate_ll.py [-v]
"""

import os
import sys
import tempfile
import textwrap
import unittest

sys.path.insert(0, os.path.dirname(__file__))
from annotate_ll import annotate, arg_types_from_define, infer_type, parse_yaml


# ── infer_type ────────────────────────────────────────────────────────────────

class TestInferType(unittest.TestCase):

    def _t(self, line, expected):
        self.assertEqual(infer_type(line), expected, f'line: {line!r}')

    # pointer-producing ops
    def test_getelementptr(self):
        self._t('  %p = getelementptr inbounds i32, ptr %base, i64 %i', 'ptr')

    def test_alloca(self):
        self._t('  %slot = alloca i32, align 4', 'ptr')

    def test_inttoptr(self):
        self._t('  %p = inttoptr i64 %x to ptr', 'ptr')

    # comparison ops
    def test_icmp(self):
        self._t('  %c = icmp slt i32 %a, %b', 'i1')

    def test_fcmp(self):
        self._t('  %c = fcmp olt float %a, %b', 'i1')

    # load
    def test_load_i32(self):
        self._t('  %v = load i32, ptr %p, align 4', 'i32')

    def test_load_i64(self):
        self._t('  %v = load i64, ptr %p, align 8', 'i64')

    def test_load_volatile(self):
        self._t('  %v = load volatile i8, ptr %p', 'i8')

    def test_load_ptr(self):
        self._t('  %v = load ptr, ptr %p, align 8', 'ptr')

    # conversion ops (result type is after "to")
    def test_sext_to_i64(self):
        self._t('  %x = sext i32 %a to i64', 'i64')

    def test_zext_to_i64(self):
        self._t('  %x = zext i32 %a to i64', 'i64')

    def test_trunc_to_i8(self):
        self._t('  %x = trunc i32 %a to i8', 'i8')

    def test_bitcast_to_ptr(self):
        self._t('  %x = bitcast i64 %a to ptr', 'ptr')

    def test_fptoui_to_i32(self):
        self._t('  %x = fptoui float %a to i32', 'i32')

    # phi
    def test_phi_i32(self):
        self._t('  %v = phi i32 [ %a, %bb1 ], [ %b, %bb2 ]', 'i32')

    def test_phi_i64(self):
        self._t('  %v = phi i64 [ %a, %entry ], [ %b, %loop ]', 'i64')

    def test_phi_ptr(self):
        self._t('  %v = phi ptr [ %p, %entry ], [ %q, %loop ]', 'ptr')

    # arithmetic
    def test_add_i32(self):
        self._t('  %r = add i32 %a, %b', 'i32')

    def test_add_nsw_i64(self):
        self._t('  %r = add nsw i64 %a, %b', 'i64')

    def test_sub_i16(self):
        self._t('  %r = sub i16 %a, %b', 'i16')

    def test_mul_i32(self):
        self._t('  %r = mul nuw i32 %a, 4', 'i32')

    def test_shl_i64(self):
        self._t('  %r = shl i64 %a, 3', 'i64')

    # call
    def test_call_i32(self):
        self._t('  %r = call i32 @foo(i32 %a)', 'i32')

    def test_call_ptr(self):
        self._t('  %r = call ptr @malloc(i64 %n)', 'ptr')

    def test_call_void_is_none(self):
        # void calls have no def — infer_type returns None is acceptable
        # but a void call wouldn't appear as %r = ..., so this is a don't-care
        pass

    # select
    def test_select(self):
        self._t('  %r = select i1 %c, i32 %a, i32 %b', 'i32')

    # unknown
    def test_unknown_returns_none(self):
        self._t('  %r = some_unknown_op i32 %a', None)


# ── arg_types_from_define ─────────────────────────────────────────────────────

class TestArgTypes(unittest.TestCase):

    def test_basic(self):
        line = 'define i32 @f(ptr nocapture %0, i32 noundef %1, i32 %2) {'
        result = arg_types_from_define(line)
        self.assertEqual(result.get('%0'), 'ptr')
        self.assertEqual(result.get('%1'), 'i32')
        self.assertEqual(result.get('%2'), 'i32')

    def test_named_args(self):
        line = 'define i64 @g(i64 %val, ptr %buf) {'
        result = arg_types_from_define(line)
        self.assertEqual(result.get('%val'), 'i64')
        self.assertEqual(result.get('%buf'), 'ptr')

    def test_empty_args(self):
        line = 'define void @h() {'
        result = arg_types_from_define(line)
        self.assertEqual(result, {})

    def test_i8_ptr_mix(self):
        line = 'define void @k(i8 %b, ptr %p, i64 %n) {'
        result = arg_types_from_define(line)
        self.assertEqual(result.get('%b'), 'i8')
        self.assertEqual(result.get('%p'), 'ptr')
        self.assertEqual(result.get('%n'), 'i64')


# ── parse_yaml ────────────────────────────────────────────────────────────────

class TestParseYaml(unittest.TestCase):

    def _write(self, content):
        f = tempfile.NamedTemporaryFile('w', suffix='.yaml', delete=False)
        f.write(textwrap.dedent(content))
        f.close()
        self.addCleanup(os.unlink, f.name)
        return f.name

    def test_basic(self):
        path = self._write("""\
            - f:
                - phase_name: knowledge_frontier
                  pass_count: 5
                  state:
                    "%9": ["f::7"]
            """)
        result = parse_yaml(path)
        self.assertIn('f', result)
        self.assertIn('7', result['f'])
        self.assertIn('%9', result['f']['7'])

    def test_multiple_regs_same_block(self):
        path = self._write("""\
            - f:
                - phase_name: knowledge_frontier
                  pass_count: 3
                  state:
                    "%3": ["f::entry"]
                    "%7": ["f::entry"]
            """)
        result = parse_yaml(path)
        block = result['f']['entry']
        self.assertIn('%3', block)
        self.assertIn('%7', block)

    def test_call_label(self):
        path = self._write("""\
            - g:
                - phase_name: knowledge_frontier
                  pass_count: 2
                  state:
                    "%0": ["g::call"]
            """)
        result = parse_yaml(path)
        self.assertIn('call', result['g'])
        self.assertIn('%0', result['g']['call'])

    def test_multiple_functions(self):
        path = self._write("""\
            - f:
                - phase_name: knowledge_frontier
                  pass_count: 1
                  state:
                    "%1": ["f::5"]
            - g:
                - phase_name: knowledge_frontier
                  pass_count: 1
                  state:
                    "%2": ["g::entry"]
            """)
        result = parse_yaml(path)
        self.assertIn('f', result)
        self.assertIn('g', result)
        self.assertIn('%1', result['f']['5'])
        self.assertIn('%2', result['g']['entry'])

    def test_no_knowledge_frontier_returns_empty(self):
        path = self._write("""\
            - f:
                - phase_name: transmit
                  pass_count: 1
                  type: edge-level
                  state:
                    ["f::call", "f::7"]: []
            """)
        result = parse_yaml(path)
        self.assertEqual(result, {})

    def test_uses_first_block_only(self):
        # reg appears in two blocks — only the first should be used
        path = self._write("""\
            - f:
                - phase_name: knowledge_frontier
                  pass_count: 1
                  state:
                    "%5": ["f::7", "f::11"]
            """)
        result = parse_yaml(path)
        self.assertIn('7', result['f'])
        self.assertNotIn('11', result['f'])

    def test_strips_funcname_prefix(self):
        path = self._write("""\
            - myfunc:
                - phase_name: knowledge_frontier
                  pass_count: 1
                  state:
                    "%x": ["myfunc::loopbody"]
            """)
        result = parse_yaml(path)
        self.assertIn('loopbody', result['myfunc'])

    def test_dotted_register_name(self):
        path = self._write("""\
            - f:
                - phase_name: knowledge_frontier
                  pass_count: 1
                  state:
                    "%acc.next": ["f::loop"]
            """)
        result = parse_yaml(path)
        self.assertIn('loop', result['f'])
        self.assertIn('%acc.next', result['f']['loop'])


# ── annotate (integration) ────────────────────────────────────────────────────

_PREAMBLE = textwrap.dedent("""\
    ; ModuleID = 'test.c'
    target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
    target triple = "x86_64-unknown-linux-gnu"
    """)

_ATTRS = '\nattributes #0 = { nounwind }\n'


def _make_ll(*body_lines, args='i32 noundef %a, i32 noundef %b', ret='i32',
             fname='f', preamble=_PREAMBLE):
    body = '\n'.join('  ' + l if not l.startswith(';') else l
                     for l in body_lines)
    return (preamble +
            f'\ndefine {ret} @{fname}({args}) {{\n{body}\n}}\n' +
            _ATTRS)


class TestAnnotate(unittest.TestCase):

    # ── declare insertion ─────────────────────────────────────────────────────

    def test_declare_prepended_before_define(self):
        ll = _make_ll('%r = add i32 %a, %b', 'ret i32 %r')
        annots = {'f': {'3': ['%r']}}
        result, _ = annotate(ll, annots)
        lines = result.splitlines()
        decl_i  = next(i for i, l in enumerate(lines) if 'declare' in l and 'markpublic' in l)
        def_i   = next(i for i, l in enumerate(lines) if l.startswith('define'))
        self.assertLess(decl_i, def_i)

    def test_no_declare_when_nothing_annotated(self):
        ll = _make_ll('%r = add i32 %a, %b', 'ret i32 %r')
        annots = {}
        result, _ = annotate(ll, annots)
        self.assertNotIn('markpublic', result)

    # ── type routing ──────────────────────────────────────────────────────────

    def test_i32_suffix(self):
        ll = _make_ll('%r = add i32 %a, %b', 'ret i32 %r')
        annots = {'f': {'3': ['%r']}}
        result, warnings = annotate(ll, annots)
        self.assertIn('markpublic.i32(i32 %r)', result)
        self.assertEqual(warnings, [])

    def test_i64_suffix(self):
        ll = _make_ll('%r = add i64 %a, %b', 'ret i64 %r',
                      args='i64 %a, i64 %b', ret='i64')
        annots = {'f': {'3': ['%r']}}
        result, warnings = annotate(ll, annots)
        self.assertIn('markpublic.i64(i64 %r)', result)

    def test_ptr_suffix(self):
        ll = _make_ll('%p = getelementptr inbounds i32, ptr %base, i64 %i',
                      'ret ptr %p',
                      args='ptr %base, i64 %i', ret='ptr')
        annots = {'f': {'3': ['%p']}}
        result, warnings = annotate(ll, annots)
        self.assertIn('markpublic.p0(ptr %p)', result)
        self.assertNotIn('markpublic.i', result)

    def test_sext_annotated_with_result_type(self):
        ll = _make_ll('%x = sext i32 %a to i64', 'ret i64 %x',
                      args='i32 %a', ret='i64')
        annots = {'f': {'3': ['%x']}}
        result, warnings = annotate(ll, annots)
        self.assertIn('markpublic.i64(i64 %x)', result)
        self.assertEqual(warnings, [])

    def test_zext_annotated_with_result_type(self):
        ll = _make_ll('%x = zext i32 %a to i64', 'ret i64 %x',
                      args='i32 %a', ret='i64')
        annots = {'f': {'3': ['%x']}}
        result, warnings = annotate(ll, annots)
        self.assertIn('markpublic.i64(i64 %x)', result)

    def test_load_i32(self):
        ll = _make_ll('%v = load i32, ptr %a, align 4', 'ret i32 %v',
                      args='ptr %a', ret='i32')
        annots = {'f': {'3': ['%v']}}
        result, _ = annotate(ll, annots)
        self.assertIn('markpublic.i32(i32 %v)', result)

    # ── placement ─────────────────────────────────────────────────────────────

    def test_call_inserted_after_def(self):
        ll = _make_ll('%r = add i32 %a, %b', 'ret i32 %r')
        annots = {'f': {'3': ['%r']}}
        result, _ = annotate(ll, annots)
        lines = result.splitlines()
        def_i  = next(i for i, l in enumerate(lines) if '%r = add' in l)
        call_i = next(i for i, l in enumerate(lines) if 'markpublic' in l and '%r' in l)
        self.assertEqual(call_i, def_i + 1)

    def test_multiple_regs_in_same_block(self):
        ll = _make_ll('%x = add i32 %a, 1', '%y = add i32 %b, 2', 'ret i32 %x')
        annots = {'f': {'3': ['%x', '%y']}}
        result, warnings = annotate(ll, annots)
        self.assertIn('markpublic.i32(i32 %x)', result)
        self.assertIn('markpublic.i32(i32 %y)', result)
        self.assertEqual(warnings, [])

    def test_dotted_register_name(self):
        ll = _make_ll('%i.next = add i64 %i, 1', 'ret i64 %i.next',
                      args='i64 %i', ret='i64')
        annots = {'f': {'3': ['%i.next']}}
        result, warnings = annotate(ll, annots)
        self.assertIn('markpublic.i64(i64 %i.next)', result)
        self.assertEqual(warnings, [])

    # ── ::call (argument) annotations ─────────────────────────────────────────

    def test_call_annotation_after_define_line(self):
        ll = _make_ll('%r = add i32 %a, %b', 'ret i32 %r')
        annots = {'f': {'call': ['%a']}}
        result, warnings = annotate(ll, annots)
        self.assertIn('markpublic.i32(i32 %a)', result)
        self.assertEqual(warnings, [])
        lines = result.splitlines()
        def_i  = next(i for i, l in enumerate(lines) if l.startswith('define'))
        call_i = next(i for i, l in enumerate(lines) if 'markpublic' in l and '%a' in l)
        self.assertEqual(call_i, def_i + 1)

    def test_call_annotation_ptr_arg(self):
        ll = _make_ll('%v = load i32, ptr %a, align 4', 'ret i32 %v',
                      args='ptr %a', ret='i32')
        annots = {'f': {'call': ['%a']}}
        result, warnings = annotate(ll, annots)
        self.assertIn('markpublic.p0(ptr %a)', result)
        self.assertEqual(warnings, [])

    def test_call_annotation_non_arg_body_def(self):
        # ::call regs not in the signature (e.g. GEPs derived from public args)
        # should be found in the function body and annotated after their def.
        ll = textwrap.dedent("""\
            ; test
            define void @f(ptr %base) {
              %p = getelementptr inbounds i32, ptr %base, i64 0
              store i32 0, ptr %p
              ret void
            }
            """)
        annots = {'f': {'call': ['%p']}}
        result, warnings = annotate(ll, annots)
        self.assertIn('markpublic.p0(ptr %p)', result)
        self.assertEqual(warnings, [])
        lines = result.splitlines()
        gep_i  = next(i for i, l in enumerate(lines) if '%p = getelementptr' in l)
        ann_i  = next(i for i, l in enumerate(lines) if 'markpublic' in l and '%p' in l)
        self.assertEqual(ann_i, gep_i + 1)

    def test_call_annotation_with_explicit_entry_label(self):
        # call annotation must land INSIDE the entry block, not before it
        ll = textwrap.dedent("""\
            ; test
            define i32 @f(i32 %a) {
            entry:
              %r = add i32 %a, 1
              ret i32 %r
            }
            """)
        annots = {'f': {'call': ['%a']}}
        result, warnings = annotate(ll, annots)
        self.assertIn('markpublic.i32(i32 %a)', result)
        self.assertEqual(warnings, [])
        lines = result.splitlines()
        entry_i = next(i for i, l in enumerate(lines) if l.strip() == 'entry:')
        call_i  = next(i for i, l in enumerate(lines) if 'markpublic' in l and '%a' in l)
        # annotation must be after the label, not before it
        self.assertGreater(call_i, entry_i)

    # ── warnings ──────────────────────────────────────────────────────────────

    def test_i1_type_warns(self):
        ll = _make_ll('%c = icmp slt i32 %a, %b', 'ret i1 %c', ret='i1')
        annots = {'f': {'3': ['%c']}}
        _, warnings = annotate(ll, annots)
        self.assertTrue(any('i1' in w for w in warnings))
        # no markpublic emitted
        result, _ = annotate(ll, annots)
        self.assertNotIn('markpublic', result)

    def test_missing_reg_warns(self):
        ll = _make_ll('%r = add i32 %a, %b', 'ret i32 %r')
        annots = {'f': {'3': ['%nonexistent']}}
        _, warnings = annotate(ll, annots)
        self.assertTrue(any('%nonexistent' in w for w in warnings))

    def test_call_reg_not_in_signature_warns(self):
        ll = _make_ll('%r = add i32 %a, %b', 'ret i32 %r')
        annots = {'f': {'call': ['%z']}}
        _, warnings = annotate(ll, annots)
        self.assertTrue(any('%z' in w for w in warnings))

    # ── multiple functions ────────────────────────────────────────────────────

    def test_two_functions_annotated_independently(self):
        ll = textwrap.dedent("""\
            ; ModuleID = 'test.c'
            define i32 @f(i32 %a) {
              %r = add i32 %a, 1
              ret i32 %r
            }
            define i64 @g(i64 %x) {
              %s = add i64 %x, 2
              ret i64 %s
            }
            """)
        annots = {
            'f': {'3': ['%r']},
            'g': {'3': ['%s']},
        }
        result, warnings = annotate(ll, annots)
        self.assertIn('markpublic.i32(i32 %r)', result)
        self.assertIn('markpublic.i64(i64 %s)', result)
        self.assertEqual(warnings, [])

    def test_unannotated_function_unchanged(self):
        ll = textwrap.dedent("""\
            ; ModuleID = 'test.c'
            define i32 @f(i32 %a) {
              %r = add i32 %a, 1
              ret i32 %r
            }
            define i64 @g(i64 %x) {
              %s = add i64 %x, 2
              ret i64 %s
            }
            """)
        annots = {'f': {'3': ['%r']}}
        result, _ = annotate(ll, annots)
        # g should not have any annotation
        lines = result.splitlines()
        g_start = next(i for i, l in enumerate(lines) if '@g' in l and l.startswith('define'))
        g_lines = lines[g_start:]
        self.assertFalse(any('markpublic' in l for l in g_lines))

    # ── test2 golden test ─────────────────────────────────────────────────────

    def test_test2_golden(self):
        """Regression: reproduce the test2.ll → annotated_test2.ll transform."""
        test2_ll = textwrap.dedent("""\
            ; ModuleID = 'test2.c'
            source_filename = "test2.c"
            target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
            target triple = "aarch64-unknown-linux-gnu"

            define dso_local i32 @f(ptr nocapture noundef readonly %0, i32 noundef %1, i32 noundef %2) local_unnamed_addr #0 {
              %4 = icmp sgt i32 %2, -1
              %5 = icmp slt i32 %2, %1
              %6 = and i1 %4, %5
              br i1 %6, label %7, label %11

            7:
              %8 = zext i32 %2 to i64
              %9 = getelementptr inbounds i32, ptr %0, i64 %8
              %10 = load i32, ptr %9, align 4
              br label %11

            11:
              %12 = phi i32 [ %10, %7 ], [ 0, %3 ]
              ret i32 %12
            }
            """)
        annots = {'f': {'7': ['%9']}}
        result, warnings = annotate(test2_ll, annots)
        self.assertIn('declare void @llvm.protean.markpublic.p0(ptr)', result)
        self.assertIn('call void @llvm.protean.markpublic.p0(ptr %9)', result)
        self.assertEqual(warnings, [])
        # verify placement: annotation immediately follows the GEP
        lines = result.splitlines()
        gep_i  = next(i for i, l in enumerate(lines) if '%9 = getelementptr' in l)
        ann_i  = next(i for i, l in enumerate(lines) if 'markpublic' in l and '%9' in l)
        self.assertEqual(ann_i, gep_i + 1)


if __name__ == '__main__':
    unittest.main()
