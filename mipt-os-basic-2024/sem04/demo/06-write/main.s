	.section	__TEXT,__text,regular,pure_instructions
	.globl	_main
	.globl	_exit
	.intel_syntax


_main:
	push    rbp
    mov     rbp, rsp
	mov     DWORD PTR [rbp-20], edi
    movabs  rax, 6278066737626506568
    mov     QWORD PTR [rbp-13], rax
    movabs  rax, 28266736421117996
    mov     QWORD PTR [rbp-8], rax

	mov rdi, 1
	lea rsi, [rbp - 13]
	mov rdx, 13
	mov rax, 0x2000004
    syscall

	mov rax, 0x2000001
	mov rdi, 42
	syscall
	