	.section	__TEXT,__text,regular,pure_instructions
	.globl	_asm_func
    .globl	_print_register
	.intel_syntax

_asm_func:
	mov rdi, 250
	call _print_register

	mov rax, 10
	ret