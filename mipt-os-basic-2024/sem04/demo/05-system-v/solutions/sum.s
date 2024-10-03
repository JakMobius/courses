	.section	__TEXT,__text,regular,pure_instructions
	.globl	_asm_func
    .globl	_print_register
	.intel_syntax

_asm_func:
    # rax = аккумулятор
    # rсx = счетчик

    mov rcx, 10
    mov rax
loop:
    add rax, rcx
    dec rcx
    jnz loop
    
    mov rdi, rax
    call _print_register

    ret