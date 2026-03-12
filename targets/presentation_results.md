# Protean + Declassiflow Presentation Results

Date: 2026-03-12

This file summarizes the **fixed CT comparison set** after updating the annotated IR to avoid the regressions from the earlier marker-only versions.

## What Changed

- For `fully_declassified: true` targets, the annotated IR now uses the function attribute `"ptex-fully-declassified"="true"` instead of dummy declassify calls.
- For loop-heavy targets, the annotated IR now keeps only the frontier subsets that actually help in CT.
- `CRYPTO_memcmp` is **not** in the main apples-to-apples slide table because the checked-in baseline IR is vectorized while the current frontier-generated annotated IR is scalar. That comparison is misleading unless the baseline is regenerated with matching flags.

## Best Slide Table

Use this table on slides. It contains the current CT-only results that are either improved or at least not worse on the main comparable targets.

| Target | CT baseline PROT | CT annotated PROT | Baseline sanit | Annotated sanit | Result | Note |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| `br_dec32le` | 1 | 0 | 1 | 1 | win | fully-declassified attribute |
| `br_enc32le` | 0 | 0 | 1 | 2 | tie | no PROT to remove |
| `int32_minmax` | 11 | 0 | 1 | 2 | big win | fully-declassified attribute |
| `sodium_compare` | 17 | 9 | 3 | 3 | win | value-frontier only |
| `sodium_memcmp` | 15 | 14 | 4 | 2 | win | pointer-frontier only |
| `sodium_is_zero` | 17 | 17 | 2 | 1 | tie | pointer-frontier only |

Recommended headline sentence:

> With the corrected annotation policy, Declassiflow-guided ProtCC reduces protected instructions from `11 -> 0` on `int32_minmax`, `1 -> 0` on `br_dec32le`, `17 -> 9` on `sodium_compare`, and `15 -> 14` on `sodium_memcmp` in CT mode.

## Targets To Avoid On Slides

- `CRYPTO_memcmp`: the current checked-in baseline IR in `targets/target_crypto_memcmp.ll` is vectorized, while the current annotated IR is based on the scalar frontier-evaluation pipeline. The raw numbers look much better for annotated, but they are not a fair baseline/annotated pair yet.

## CTS Status

CTS is still not slide-safe for the loop-heavy frontier cases. The fully-declassified cases are fixed, but the loop-annotated sodium cases still hit the backend verifier bug.

| Target | CTS baseline PROT | CTS annotated PROT | Status |
| --- | ---: | ---: | --- |
| `br_dec32le` | 1 | 0 | improved |
| `br_enc32le` | 0 | 0 | tie |
| `int32_minmax` | 11 | 0 | improved |
| `sodium_compare` | 17 | crash | backend verifier bug |
| `sodium_memcmp` | 13 | crash | backend verifier bug |
| `sodium_is_zero` | 14 | crash | backend verifier bug |

For tomorrow, the safest deck is: **CT headline table + one sentence that CTS loop-frontier support is still under repair.**

## Updated Annotated Files

These are the current best artifacts in the workspace:

- `targets/target_br_dec32le_annotated.ll`
- `targets/target_br_enc32le_annotated.ll`
- `targets/target_int32_minmax_annotated.ll`
- `targets/target_sodium_compare_annotated.ll`
- `targets/target_sodium_memcmp_annotated.ll`
- `targets/target_sodium_is_zero_annotated.ll`
- `targets/target_crypto_memcmp_annotated.ll`

## Output Excerpts

These are the end outputs from the current CT reruns for the most useful slide cases.

### `br_dec32le`

Baseline `ct`: PROT `1`, sanit `1`.

```asm
0000000000000000 <br_dec32le>:
   0:	48 89 ff             	mov    %rdi,%rdi
   3:	36 8b 07             	ss mov (%rdi),%eax
   6:	c3                   	ret
```

Annotated `ct`: PROT `0`, sanit `1`.

```asm
0000000000000000 <br_dec32le>:
   0:	48 89 ff             	mov    %rdi,%rdi
   3:	8b 07                	mov    (%rdi),%eax
   5:	c3                   	ret
```

### `int32_minmax`

Baseline `ct`: PROT `11`, sanit `1`.

```asm
0000000000000000 <int32_minmax>:
   0:	48 89 f6             	mov    %rsi,%rsi
   3:	36 8b 06             	ss mov (%rsi),%eax
   6:	36 89 c1             	ss mov %eax,%ecx
   9:	36 31 f9             	ss xor %edi,%ecx
   c:	36 89 c2             	ss mov %eax,%edx
   f:	36 29 fa             	ss sub %edi,%edx
  12:	36 41 89 d0          	ss mov %edx,%r8d
  16:	36 41 31 c0          	ss xor %eax,%r8d
  1a:	36 41 21 c8          	ss and %ecx,%r8d
  1e:	36 41 31 d0          	ss xor %edx,%r8d
  22:	36 0f 49 c7          	ss cmovns %edi,%eax
  26:	36 31 c1             	ss xor %eax,%ecx
```

Annotated `ct`: PROT `0`, sanit `2`.

```asm
0000000000000000 <int32_minmax>:
   0:	89 ff                	mov    %edi,%edi
   2:	48 89 f6             	mov    %rsi,%rsi
   5:	8b 06                	mov    (%rsi),%eax
   7:	89 c1                	mov    %eax,%ecx
   9:	31 f9                	xor    %edi,%ecx
   b:	89 c2                	mov    %eax,%edx
   d:	29 fa                	sub    %edi,%edx
   f:	41 89 d0             	mov    %edx,%r8d
  12:	41 31 c0             	xor    %eax,%r8d
  15:	41 21 c8             	and    %ecx,%r8d
  18:	41 31 d0             	xor    %edx,%r8d
  1b:	0f 49 c7             	cmovns %edi,%eax
```

### `sodium_compare`

Baseline `ct`: PROT `17`, sanit `3`.

```asm
0000000000000000 <sodium_compare>:
   0:	c6 44 24 ff 00       	movb   $0x0,-0x1(%rsp)
   5:	c6 44 24 fe 01       	movb   $0x1,-0x2(%rsp)
   a:	48 85 d2             	test   %rdx,%rdx
   d:	74 4a                	je     59 <sodium_compare+0x59>
  20:	36 0f b6 44 17 ff    	ss movzbl -0x1(%rdi,%rdx,1),%eax
  26:	36 0f b6 4c 16 ff    	ss movzbl -0x1(%rsi,%rdx,1),%ecx
  2c:	36 41 89 c8          	ss mov %ecx,%r8d
  30:	36 41 29 c0          	ss sub %eax,%r8d
```

Annotated `ct`: PROT `9`, sanit `3`.

```asm
0000000000000000 <sodium_compare>:
   0:	50                   	push   %rax
   1:	c6 44 24 07 00       	movb   $0x0,0x7(%rsp)
   6:	c6 44 24 06 01       	movb   $0x1,0x6(%rsp)
   b:	48 85 d2             	test   %rdx,%rdx
   e:	74 44                	je     54 <sodium_compare+0x54>
  20:	44 0f b6 44 11 ff    	movzbl -0x1(%rcx,%rdx,1),%r8d
  26:	44 0f b6 4c 16 ff    	movzbl -0x1(%rsi,%rdx,1),%r9d
  2c:	44 89 c8             	mov    %r9d,%eax
  2f:	44 29 c0             	sub    %r8d,%eax
```

### `sodium_memcmp`

Baseline `ct`: PROT `15`, sanit `4`.

```asm
0000000000000000 <sodium_memcmp>:
   0:	c6 44 24 ff 00       	movb   $0x0,-0x1(%rsp)
   5:	48 85 d2             	test   %rdx,%rdx
   8:	74 6c                	je     76 <sodium_memcmp+0x76>
  14:	48 89 ff             	mov    %rdi,%rdi
  17:	48 89 f6             	mov    %rsi,%rsi
  1a:	36 48 89 d1          	ss mov %rdx,%rcx
  1e:	36 48 83 e1 fe       	ss and $0xfffffffffffffffe,%rcx
```

Annotated `ct`: PROT `14`, sanit `2`.

```asm
0000000000000000 <sodium_memcmp>:
   0:	55                   	push   %rbp
   1:	53                   	push   %rbx
   2:	50                   	push   %rax
   3:	c6 44 24 07 00       	movb   $0x0,0x7(%rsp)
   8:	48 85 d2             	test   %rdx,%rdx
   b:	74 72                	je     7f <sodium_memcmp+0x7f>
  1d:	36 48 89 d3          	ss mov %rdx,%rbx
```

### `sodium_is_zero`

Baseline `ct`: PROT `17`, sanit `2`.

Annotated `ct`: PROT `17`, sanit `1`.

Interpretation: no PROT reduction yet, but the reduced annotation set no longer regresses CT PROT count.

## Bottom Line

The bad CT regressions are fixed on the main slide-worthy targets:

- `int32_minmax` is now back to the expected strong positive result.
- `br_dec32le` is now a clean small positive result.
- `sodium_compare` remains the strongest loop-based positive.
- `sodium_memcmp` is now slightly positive instead of flat/worse.
- `sodium_is_zero` is neutral instead of worse.

What is still not fixed:

- Non-empty loop-frontier annotations still crash in `cts` for the sodium cases.
- `CRYPTO_memcmp` still needs a regenerated apples-to-apples scalar baseline before it should be shown in the main comparison table.
