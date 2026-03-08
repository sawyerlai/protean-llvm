	.text
	.file	"protean_ex.c"
	.globl	foo                             # -- Begin function foo
	.p2align	4, 0x90
	.type	foo,@function
foo:                                    # @foo
	.cfi_startproc
# %bb.0:
	movq	%rdi, %rdi
	movl	(%rdi), %eax
	testl	%eax, %eax
	js	.LBB0_1
# %bb.2:
	movq	%rax, %rax
	movl	A(,%rax,4), %eax
	retq
.LBB0_1:
	xorl	%eax, %eax
	retq
.Lfunc_end0:
	.size	foo, .Lfunc_end0-foo
	.cfi_endproc
                                        # -- End function
	.section	.rodata.cst16,"aM",@progbits,16
	.p2align	4, 0x0                          # -- Begin function main
.LCPI1_0:
	.long	0                               # 0x0
	.long	2                               # 0x2
	.long	4                               # 0x4
	.long	6                               # 0x6
.LCPI1_1:
	.long	8                               # 0x8
	.long	10                              # 0xa
	.long	12                              # 0xc
	.long	14                              # 0xe
.LCPI1_2:
	.long	16                              # 0x10
	.long	18                              # 0x12
	.long	20                              # 0x14
	.long	22                              # 0x16
.LCPI1_3:
	.long	24                              # 0x18
	.long	26                              # 0x1a
	.long	28                              # 0x1c
	.long	30                              # 0x1e
	.text
	.globl	main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movaps	.LCPI1_0(%rip), %xmm0           # xmm0 = [0,2,4,6]
	movaps	%xmm0, A(%rip)
	movaps	.LCPI1_1(%rip), %xmm0           # xmm0 = [8,10,12,14]
	movaps	%xmm0, A+16(%rip)
	movaps	.LCPI1_2(%rip), %xmm0           # xmm0 = [16,18,20,22]
	movaps	%xmm0, A+32(%rip)
	movaps	.LCPI1_3(%rip), %xmm0           # xmm0 = [24,26,28,30]
	movaps	%xmm0, A+48(%rip)
	movl	$.L.str, %edi
	movl	$5, %esi
	movl	$10, %edx
	xorl	%eax, %eax
	callq	printf@PLT
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
	.cfi_endproc
                                        # -- End function
	.type	A,@object                       # @A
	.local	A
	.comm	A,64,16
	.type	.L.str,@object                  # @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.asciz	"foo(%d) = %d\n"
	.size	.L.str, 14

	.ident	"clang version 17.0.6 (https://github.com/StanfordPLArchSec/protean-llvm.git 7599a5138d3c6b1b3e4e4f4ee175c3922bf6a87e)"
	.section	".note.GNU-stack","",@progbits
