	.section	__TEXT,__text,regular,pure_instructions
	.globl	_main
	.globl	_exit
	.intel_syntax


_main:
	push    rbp
    mov     rbp, rsp

	mov rax, 0x2000001
	mov rdi, 42
	syscall
	