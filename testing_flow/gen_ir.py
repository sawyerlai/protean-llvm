#!/usr/bin/env python3
"""
gen_ir.py — generates random LLVM IR with patterns relevant to PTeX/CTS testing.

Unlike llvm-stress, generates functions with memory loads (secret data), conditional
branches on public indices, loops with accumulators, and stores that prevent trivial
bound-to-leak analysis from marking everything public.

Usage:
    python3 gen_ir.py [seed] [n_functions]

    seed         random seed for reproducibility (default: random)
    n_functions  number of functions to generate (default: 10)
"""
import random
import sys


# ── Arithmetic helpers ────────────────────────────────────────────────────────

BINOPS = ["add", "sub", "mul", "and", "or", "xor", "shl", "lshr"]


def binop(op, lhs, rhs):
    return f"{op} i64 {lhs}, {rhs}"


# ── Pattern generators ────────────────────────────────────────────────────────

def gen_array_access(fname):
    """
    Load one or more values from a secret array at a public index.
    Optionally performs arithmetic on the loaded values before returning/storing.

    Signature: (ptr %arr, i64 %idx, ptr %out) -> i64
    """
    n_loads = random.randint(1, 4)
    do_store = random.random() < 0.5   # store result to %out (not just return)
    ops = random.choices(BINOPS, k=n_loads - 1)

    lines = [
        f"define i64 @{fname}(ptr %arr, i64 %idx, ptr %out) {{",
        "entry:",
    ]

    loaded = []
    for i in range(n_loads):
        offset = f"%off{i}"
        ptr    = f"%ptr{i}"
        val    = f"%val{i}"
        if i == 0:
            lines.append(f"  {offset} = add i64 %idx, 0")
        else:
            lines.append(f"  {offset} = add i64 %idx, {i}")
        lines.append(f"  {ptr} = getelementptr inbounds i64, ptr %arr, i64 {offset}")
        lines.append(f"  {val} = load i64, ptr {ptr}")
        loaded.append(val)

    # Combine loaded values with arithmetic
    acc = loaded[0]
    for i, op in enumerate(ops):
        nxt = f"%acc{i}"
        lines.append(f"  {nxt} = {binop(op, acc, loaded[i + 1])}")
        acc = nxt

    if do_store:
        lines.append(f"  store i64 {acc}, ptr %out")

    lines.append(f"  ret i64 {acc}")
    lines.append("}")
    return "\n".join(lines)


def gen_conditional(fname):
    """
    Branch on a public integer condition; load secret values in each arm.

    Signature: (i64 %cond, ptr %arr_a, ptr %arr_b) -> i64
    """
    extra_ops = random.randint(0, 2)
    ops = random.choices(BINOPS, k=extra_ops)

    lines = [
        f"define i64 @{fname}(i64 %cond, ptr %arr_a, ptr %arr_b) {{",
        "entry:",
        "  %cmp = icmp ne i64 %cond, 0",
        "  br i1 %cmp, label %then, label %else",
        "",
        "then:",
        "  %val_a = load i64, ptr %arr_a",
        "  br label %exit",
        "",
        "else:",
        "  %val_b = load i64, ptr %arr_b",
        "  br label %exit",
        "",
        "exit:",
        "  %result = phi i64 [ %val_a, %then ], [ %val_b, %else ]",
    ]

    acc = "%result"
    for i, op in enumerate(ops):
        nxt = f"%extra{i}"
        # Sawz edit: cap shift constants to 63 — larger values produce poison on i64
        rhs = random.choice(["%cond", str(random.randint(1, 63))])
        lines.append(f"  {nxt} = {binop(op, acc, rhs)}")
        acc = nxt

    lines.append(f"  ret i64 {acc}")
    lines.append("}")
    return "\n".join(lines)


def gen_loop(fname):
    """
    Loop over a secret array with a public bound, accumulating a result.
    Optionally performs extra arithmetic inside the loop body.

    Signature: (ptr %arr, i64 %n) -> i64
    """
    extra_body_ops = random.randint(0, 2)

    lines = [
        f"define i64 @{fname}(ptr %arr, i64 %n) {{",
        "entry:",
        "  br label %loop",
        "",
        "loop:",
        "  %i   = phi i64 [ 0, %entry ], [ %i.next,   %loop ]",
        "  %acc = phi i64 [ 0, %entry ], [ %acc.next, %loop ]",
        "  %ptr = getelementptr inbounds i64, ptr %arr, i64 %i",
        "  %val = load i64, ptr %ptr",
    ]

    acc = "%acc"
    for j in range(extra_body_ops):
        op  = random.choice(BINOPS)
        nxt = f"%body{j}"
        # Sawz edit: cap shift constants to 63
        rhs = random.choice(["%val", "%i", str(random.randint(1, 63))])
        lines.append(f"  {nxt} = {binop(op, acc, rhs)}")
        acc = nxt

    lines += [
        f"  %acc.next = add i64 {acc}, %val",
        "  %i.next   = add i64 %i, 1",
        "  %done     = icmp eq i64 %i.next, %n",
        "  br i1 %done, label %exit, label %loop",
        "",
        "exit:",
        "  ret i64 %acc.next",
        "}",
    ]
    return "\n".join(lines)


def gen_mixed(fname):
    """
    Multiple independent loads with arithmetic; some results stored, some returned.
    Designed to produce values that are NOT all bound-to-leak (only the returned
    value is; the stored intermediate is observed via the store, but dead ops aren't).

    Signature: (ptr %a, ptr %b, i64 %idx, ptr %out) -> i64
    """
    op1 = random.choice(BINOPS)
    op2 = random.choice(BINOPS)

    lines = [
        f"define i64 @{fname}(ptr %a, ptr %b, i64 %idx, ptr %out) {{",
        "entry:",
        "  %pa  = getelementptr inbounds i64, ptr %a, i64 %idx",
        "  %pb  = getelementptr inbounds i64, ptr %b, i64 %idx",
        "  %va  = load i64, ptr %pa",
        "  %vb  = load i64, ptr %pb",
        f"  %r1  = {binop(op1, '%va', '%vb')}",
        f"  %r2  = {binop(op2, '%r1', '%idx')}",
        "  store i64 %r1, ptr %out",   # r1 is stored (observed)
        "  ret i64 %r2",               # r2 is returned (also observed)
        "}",
    ]
    return "\n".join(lines)


# ── Top-level generator ───────────────────────────────────────────────────────

PATTERNS = [gen_array_access, gen_conditional, gen_loop, gen_mixed]


def generate(seed=None, n_functions=10):
    random.seed(seed)
    functions = []
    for i in range(n_functions):
        pattern = random.choice(PATTERNS)
        functions.append(pattern(f"test_{i}"))
    return "\n\n".join(functions) + "\n"


if __name__ == "__main__":
    seed       = int(sys.argv[1]) if len(sys.argv) > 1 else None
    n_funcs    = int(sys.argv[2]) if len(sys.argv) > 2 else 10
    print(generate(seed, n_funcs))
