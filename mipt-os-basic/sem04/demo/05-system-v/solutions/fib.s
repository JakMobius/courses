	.section	__TEXT,__text,regular,pure_instructions
	.globl	_asm_func
    .globl	_print_register
	.intel_syntax

_fib:
    cmp rdi, 2
    je _fib_one
    jae _fib_body
    mov rax, 0
    ret
_fib_one:
    mov rax, 1
    ret
_fib_body:
    dec rdi
    push rdi
    call _fib
    pop rdi
    push rax
    dec rdi
    call _fib
    pop rcx
    add rax, rcx
    ret

_asm_func:
    mov r10, 1
    loop:
    push r10
    mov rdi, r10
    call _fib

    mov rdi, rax
    call _print_register
    pop r10
    inc r10
    cmp r10, 100
    jb loop

    ret