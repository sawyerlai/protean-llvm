#!/usr/bin/env python3
"""
annotate_ll.py — annotates LLVM IR with @llvm.protean.markpublic calls
based on a Declassiflow knowledge_frontier YAML output.

Usage:
    python3 annotate_ll.py declassiflow_<name>.yaml <input.ll> <output.ll>

For each function, reads the knowledge_frontier phase and determines which
registers are public at which block. Inserts a markpublic intrinsic call
immediately after each register's SSA definition. Handles:
  - Numeric block labels ("7:", "11:")
  - "::call" entries (function arguments, annotated after the define line)
  - Multiple functions per file
  - Type inference from definition instructions
"""
import re
import sys



# ── Type inference ────────────────────────────────────────────────────────────

# Opcodes where "to TYPE" at the end gives the result type
_CONV_TO = {
    'trunc', 'sext', 'zext', 'bitcast',
    'fptrunc', 'fpext', 'fptoui', 'fptosi',
    'uitofp', 'sitofp', 'ptrtoint', 'addrspacecast',
}

# Arithmetic/bitwise opcodes where the first TYPE token is the result type
_ARITH = {
    'add', 'sub', 'mul', 'udiv', 'sdiv', 'urem', 'srem',
    'and', 'or', 'xor', 'shl', 'lshr', 'ashr',
    'fadd', 'fsub', 'fmul', 'fdiv', 'frem', 'fneg',
}

_TYPE_RE = re.compile(r'\b(ptr|i\d+|float|double|half|bfloat)\b')


def infer_type(def_line):
    """
    Infer the result type of an SSA definition line.
    Returns a type string (e.g. 'i32', 'ptr') or None on failure.
    """
    stripped = def_line.strip()
    # Must look like  %name = opcode ...
    m = re.match(r'%[\w.]+\s*=\s*(\S+)\s*(.*)', stripped, re.DOTALL)
    if not m:
        return None

    opcode = m.group(1)
    rest   = m.group(2)

    # getelementptr / alloca / inttoptr → ptr
    if opcode in ('getelementptr', 'alloca', 'inttoptr'):
        return 'ptr'

    # icmp / fcmp → i1
    if opcode in ('icmp', 'fcmp'):
        return 'i1'

    # Conversion ops: result type is the token after "to"
    if opcode in _CONV_TO:
        m2 = re.search(r'\bto\s+(ptr|i\d+|float|double|half|bfloat)\b', rest)
        return m2.group(1) if m2 else None

    # phi TYPE [ ...
    if opcode == 'phi':
        m2 = _TYPE_RE.search(rest)
        return m2.group(1) if m2 else None

    # load [volatile] TYPE, ptr ...
    if opcode == 'load':
        rest2 = rest.lstrip()
        if rest2.startswith('volatile'):
            rest2 = rest2[len('volatile'):].lstrip()
        m2 = _TYPE_RE.match(rest2)
        return m2.group(1) if m2 else None

    # call / invoke / tail call — result type precedes @funcname or %reg
    if opcode in ('call', 'invoke', 'tail'):
        m2 = re.search(r'\b(ptr|i\d+|float|double|void)\s+(?:@|%)', rest)
        return m2.group(1) if m2 else None

    # Arithmetic / bitwise: skip flag words (nuw, nsw, exact, fast…), take first type
    if opcode in _ARITH:
        for tok in rest.split():
            if _TYPE_RE.fullmatch(tok):
                return tok
        return None

    # select i1 %c, TYPE %a, TYPE %b → TYPE of the true-value operand
    if opcode == 'select':
        toks = rest.split()
        # format: i1 %cond, TYPE %true, TYPE %false
        for i, tok in enumerate(toks):
            if tok.startswith('%') and i >= 2:
                # type should be the token before this %reg
                return toks[i - 1] if i > 0 else None
        return None

    return None


def arg_types_from_define(define_line):
    """
    Parse a 'define ... @func(TYPE [attrs] %name, ...) ...' line.
    Returns {reg_name: type_str}.
    """
    m = re.search(r'\(([^)]*)\)', define_line)
    if not m:
        return {}

    result = {}
    for segment in m.group(1).split(','):
        # Last %name in segment is the register; type token(s) precede it
        names = re.findall(r'%\w+', segment)
        if not names:
            continue
        reg = names[-1]
        before = segment[:segment.rfind(reg)]
        types  = _TYPE_RE.findall(before)
        if types:
            result[reg] = types[-1]
    return result


# ── YAML parsing ──────────────────────────────────────────────────────────────

def parse_yaml(path):
    """
    Returns {func_name: {block_label: [regs]}} using the knowledge_frontier phase.
    block_label is the raw label string (e.g. '7', 'call', 'entry').
    Only the FIRST block per register is used.

    Parses only the knowledge_frontier sections with regex to avoid PyYAML's
    inability to handle list-keyed mappings present in other phases.
    """
    with open(path) as f:
        text = f.read()

    result = {}

    # Split into per-function blocks. Each starts with "- funcname:" at indent 0.
    func_blocks = re.split(r'\n(?=- \w+:)', text)

    for block in func_blocks:
        # Extract function name from "- funcname:"
        m_func = re.match(r'-\s+(\w+):', block)
        if not m_func:
            continue
        func_name = m_func.group(1)

        # Locate the knowledge_frontier phase section
        m_kf = re.search(
            r'phase_name:\s*knowledge_frontier.*?(?=\n\s+-\s+phase_name:|\Z)',
            block, re.DOTALL
        )
        if not m_kf:
            continue
        kf_text = m_kf.group(0)

        # Extract state section: lines after "state:" until next top-level key
        m_state = re.search(r'state:\s*\n((?:\s+"[^"]+":.*(?:\n|$))*)', kf_text)
        if not m_state:
            continue

        # Parse each line: '  "%9": ["f::7", "f::11"]'
        block_to_regs = {}
        for line in m_state.group(1).splitlines():
            m_entry = re.match(r'\s+"(%[\w.]+)":\s*\[([^\]]*)\]', line)
            if not m_entry:
                continue
            reg    = m_entry.group(1)
            blocks = re.findall(r'"([^"]+)"', m_entry.group(2))
            if not blocks:
                continue
            # Use the first block; strip "funcname::" prefix
            raw   = blocks[0]
            label = raw.split('::', 1)[1] if '::' in raw else raw
            block_to_regs.setdefault(label, []).append(reg)

        if block_to_regs:
            result[func_name] = block_to_regs

    return result


# ── Intrinsic helpers ─────────────────────────────────────────────────────────

# Map from type string to intrinsic suffix and argument spelling
_TYPE_TO_SUFFIX = {
    'i64':    ('i64',  'i64'),
    'i32':    ('i32',  'i32'),
    'i16':    ('i16',  'i16'),
    'i8':     ('i8',   'i8'),
    'ptr':    ('p0',   'ptr'),
}

_SUFFIX_ORDER = ['i64', 'i32', 'i16', 'i8', 'p0']


def make_call(ty, reg):
    """Return the markpublic call string for a given type and register."""
    entry = _TYPE_TO_SUFFIX.get(ty)
    if entry is None:
        return None
    suffix, arg_ty = entry
    return f'  call void @llvm.protean.markpublic.{suffix}({arg_ty} {reg})'


def make_declare(suffix):
    if suffix == 'p0':
        return 'declare void @llvm.protean.markpublic.p0(ptr)'
    return f'declare void @llvm.protean.markpublic.{suffix}({suffix})'


# ── Main annotation logic ─────────────────────────────────────────────────────

def annotate(ll_src, annotations):
    """
    annotations: {func_name: {block_label: [regs]}}
    Returns the annotated IR as a string.
    """
    lines       = ll_src.splitlines()
    # insertions[i] = list of lines to insert AFTER line i
    insertions  = {}
    used_suffixes = set()
    warnings    = []

    def warn(msg):
        warnings.append(f'WARN: {msg}')

    def record_insert(line_idx, ty, reg, context):
        call = make_call(ty, reg)
        if call is None:
            warn(f'unsupported type {ty!r} for {reg} in {context} — skipping')
            return
        insertions.setdefault(line_idx, []).append(call)
        used_suffixes.add(_TYPE_TO_SUFFIX[ty][0])

    i = 0
    while i < len(lines):
        line = lines[i]

        # ── Detect function definition ────────────────────────────────────
        m_def = re.match(r'define\b.*@(\w+)\s*\(', line)
        if not m_def:
            i += 1
            continue

        func_name     = m_def.group(1)
        define_line_i = i
        func_annots   = annotations.get(func_name, {})

        if not func_annots:
            # Skip to closing brace
            while i < len(lines) and lines[i].strip() != '}':
                i += 1
            i += 1
            continue

        arg_types = arg_types_from_define(line)

        # ── Handle ::call annotations (function arguments) ────────────────
        # Sawz edit: if the first body line is an explicit block label (e.g. "entry:"),
        # insert after it so the call lands inside that block, not before it.
        call_insert_i = define_line_i
        peek = define_line_i + 1
        while peek < len(lines) and not lines[peek].strip():
            peek += 1
        if peek < len(lines) and re.match(r'^(\w+):\s*(?:;.*)?$', lines[peek]):
            call_insert_i = peek

        # Sawz edit: collect ::call regs not in the signature so the body-walker
        # can find and annotate them (e.g. GEPs derived from public args).
        call_body_regs = []
        for reg in func_annots.get('call', []):
            ty = arg_types.get(reg)
            if ty is None:
                call_body_regs.append(reg)
            elif ty == 'i1':
                warn(f'{reg} in {func_name}::call has type i1 — cannot annotate')
            else:
                record_insert(call_insert_i, ty, reg, f'{func_name}::call')

        # ── Build set of (block_label, reg) pairs still to find ───────────
        # {block_label: set(regs)} — we remove each reg once its def is found
        remaining = {
            lbl: set(regs)
            for lbl, regs in func_annots.items()
            if lbl != 'call'
        }
        # Sawz edit: non-arg ::call regs are defined in the body — let the
        # walker find their def and annotate them there.
        if call_body_regs:
            remaining['call'] = set(call_body_regs)

        # ── Walk the function body ────────────────────────────────────────
        i += 1
        current_block = None  # None = unnamed entry block

        while i < len(lines):
            line = lines[i]
            stripped = line.strip()

            if stripped == '}':
                i += 1
                break

            # Block label line: "7:" or "entry:" (label at column 0, ends with colon)
            m_lbl = re.match(r'^(\w+):\s*(?:;.*)?$', line)
            if m_lbl:
                current_block = m_lbl.group(1)
                i += 1
                continue

            # SSA definition line: "  %N = ..."
            m_reg = re.match(r'\s+(%[\w.]+)\s*=', line)
            if m_reg:
                reg = m_reg.group(1)

                # Check every block that wants this register
                # (usually just one, but handles duplicates gracefully)
                for blk_label, regs in list(remaining.items()):
                    if reg in regs:
                        ty = infer_type(stripped)
                        ctx = f'{func_name}::{blk_label}'
                        if ty is None:
                            warn(f'cannot infer type of {reg} defined at line {i+1} for {ctx}')
                        elif ty == 'i1':
                            warn(f'{reg} in {ctx} has type i1 — cannot annotate')
                        else:
                            record_insert(i, ty, reg, ctx)
                        remaining[blk_label].discard(reg)

            i += 1

        # Warn about any registers we never found a def for
        for blk_label, regs in remaining.items():
            for reg in regs:
                warn(f'{reg} listed public at {func_name}::{blk_label} but no SSA def found in function body')

    # ── Apply insertions (bottom-up to preserve indices) ─────────────────
    out_lines = list(lines)
    for idx in sorted(insertions.keys(), reverse=True):
        for call_line in reversed(insertions[idx]):
            out_lines.insert(idx + 1, call_line)

    # ── Prepend declarations before the first 'define' ────────────────────
    first_def_i = next(
        (j for j, l in enumerate(out_lines) if re.match(r'^define\b', l)), None
    )
    if first_def_i is not None and used_suffixes:
        decls = [make_declare(s) for s in _SUFFIX_ORDER if s in used_suffixes]
        # Any suffix not in the canonical order (shouldn't happen but be safe)
        for s in sorted(used_suffixes - set(_SUFFIX_ORDER)):
            decls.append(make_declare(s))
        decls.append('')  # blank line separator
        for decl in reversed(decls):
            out_lines.insert(first_def_i, decl)

    return '\n'.join(out_lines), warnings


# ── Entry point ───────────────────────────────────────────────────────────────

if __name__ == '__main__':
    if len(sys.argv) != 4:
        sys.exit(f'Usage: {sys.argv[0]} declassiflow_<name>.yaml <input.ll> <output.ll>')

    yaml_path, ll_path, out_path = sys.argv[1], sys.argv[2], sys.argv[3]

    annots = parse_yaml(yaml_path)
    if not annots:
        sys.exit('ERROR: no knowledge_frontier data found in YAML')

    with open(ll_path) as f:
        ll_src = f.read()

    result, warnings = annotate(ll_src, annots)

    for w in warnings:
        print(w, file=sys.stderr)

    with open(out_path, 'w') as f:
        f.write(result)

    print(f'Written: {out_path}')
    if warnings:
        print(f'{len(warnings)} warning(s) — see stderr')
