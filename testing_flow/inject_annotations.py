#!/usr/bin/env python3
"""
inject_annotations.py — randomly injects @llvm.protean.markpublic calls into LLVM IR.

Usage:
    python3 inject_annotations.py <input.ll> [fraction] [seed]

    fraction  probability of annotating each eligible value (default: 0.3)
    seed      integer seed for reproducibility (default: random)

Output: annotated IR written to stdout.

Eligible values: i64-typed defs that are not phi nodes, terminators, or void calls.
Phi-defined values are buffered and injected after the last phi in their block,
since LLVM requires all phis to precede non-phi instructions.
"""
import re
import random
import sys


DECLARES = {
    'i64': 'declare void @llvm.protean.markpublic.i64(i64)',
    'i32': 'declare void @llvm.protean.markpublic.i32(i32)',
    'i16': 'declare void @llvm.protean.markpublic.i16(i16)',
    'i8':  'declare void @llvm.protean.markpublic.i8(i8)',
}

# Patterns
RE_DEFINE     = re.compile(r'^define\s+')
RE_TERMINATOR = re.compile(r'^\s+(ret|br|switch|indirectbr|invoke|resume|unreachable)\b')
# matches ANY phi instruction regardless of type (ptr, float, i1, etc.)
# Used to suppress flushing of buffered int-phi annotations when a non-int phi
# (e.g. "phi ptr") appears mid-group — without this, markpublic calls land
# between phi instructions and fail the IR verifier.
RE_ANY_PHI    = re.compile(r'^\s+%\w+\s*=\s*phi\b')
# Opcodes to skip:
#   ptr-returning:   getelementptr, alloca, inttoptr
#   i1-returning:    icmp, fcmp
#   conversion ops:  trunc/sext/zext/bitcast — result type is after "to", not before,
#                    so the generic type-position regex picks the wrong type
# skip ops that never produce an annotatable integer result.
# Conversion ops (trunc/sext/zext/bitcast/fptoui/fptosi) are NOT listed here —
# they're handled by RE_INT_CONV below, which reads the result type from "to TYPE".
RE_SKIP_OPS   = re.compile(
    r'\b(getelementptr|alloca|inttoptr|icmp|fcmp'
    r'|fptrunc|fpext|uitofp|sitofp)\b'
)

# matches integer-producing "to TYPE" conversion instructions.
# Result type is the token after "to", not the first type in the instruction.
RE_INT_CONV = re.compile(
    r'^\s+(%\w+)\s*=\s*(?:trunc|sext|zext|bitcast|fptoui|fptosi)\b.*\bto\s+(i64|i32|i16|i8)\b'
)

def _phi_re(ty):
    return re.compile(rf'^\s+(%\w+)\s*=\s*phi\s+{ty}\b')

def _def_re(ty):
    return re.compile(rf'^\s+(%\w+)\s*=\s*(?!phi\b)(?:\w+\s+)*{ty}[\s,]')

INT_TYPES = ['i64', 'i32', 'i16', 'i8']


def inject(src, frac=0.3, seed=None):
    random.seed(seed)
    lines = src.splitlines()
    out = []

    # Track which declares are needed and not yet present
    needed = {ty: (DECLARES[ty] not in src) for ty in INT_TYPES}
    pending_phi_annots = []

    for line in lines:
        # Inject missing declares before the first function definition
        if RE_DEFINE.match(line):
            for ty, needed_ in needed.items():
                if needed_:
                    out.append(DECLARES[ty])
                    needed[ty] = False

        # Flush buffered phi annotations on first non-phi non-blank line
        is_phi = None
        for ty in INT_TYPES:
            m = _phi_re(ty).match(line)
            if m:
                is_phi = (m, ty)
                break

        # Without RE_ANY_PHI, a "phi ptr" line would trigger a flush and inject
        # markpublic calls between phi instructions, failing the IR verifier.
        if pending_phi_annots and not RE_ANY_PHI.match(line) and line.strip():
            out.extend(pending_phi_annots)
            pending_phi_annots = []

        out.append(line)

        # Buffer phi-defined annotations
        if is_phi:
            m, ty = is_phi
            if random.random() < frac:
                val = m.group(1)
                pending_phi_annots.append(
                    f'  call void @llvm.protean.markpublic.{ty}({ty} {val})')
            continue

        # Skip terminators
        if RE_TERMINATOR.match(line):
            continue

        # handle conversion ops (trunc/sext/zext/bitcast/fptoui/fptosi)
        # whose result type is after "to", not the first type token.
        m_conv = RE_INT_CONV.match(line)
        if m_conv:
            if random.random() < frac:
                val, ty = m_conv.group(1), m_conv.group(2)
                out.append(
                    f'  call void @llvm.protean.markpublic.{ty}({ty} {val})')
            continue  # always skip generic check for these lines

        # Annotate integer-typed defs; skip ptr/i1/float-returning opcodes
        if not RE_SKIP_OPS.search(line):
            for ty in INT_TYPES:
                m = _def_re(ty).match(line)
                if m and random.random() < frac:
                    val = m.group(1)
                    out.append(
                        f'  call void @llvm.protean.markpublic.{ty}({ty} {val})')
                    break  # only annotate once per line

    return '\n'.join(out)


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(f'Usage: {sys.argv[0]} <input.ll> [fraction] [seed]', file=sys.stderr)
        sys.exit(1)

    src = open(sys.argv[1]).read()
    frac = float(sys.argv[2]) if len(sys.argv) > 2 else 0.3
    seed = int(sys.argv[3]) if len(sys.argv) > 3 else None

    print(inject(src, frac, seed))
