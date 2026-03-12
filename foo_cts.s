	.text
	.file	"test_foo.c"
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
# %bb.3:
	movq	A@GOTPCREL(%rip), %rcx
	movl	(%rcx,%rax,4), %eax
	retq
.LBB0_1:
	xorl	%eax, %eax
	retq
.Lfunc_end0:
	.size	foo, .Lfunc_end0-foo
	.cfi_endproc
                                        # -- End function
	.ident	"clang version 17.0.6 (https://github.com/StanfordPLArchSec/protean-llvm.git 7599a5138d3c6b1b3e4e4f4ee175c3922bf6a87e)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
