	.section	__TEXT,__text,regular,pure_instructions
	.globl	_main
	.intel_syntax


_main:
	push rbp
	mov rbp, rsp
	sub rsp, 16

	lea rax, [rbp - 16]
	mov BYTE PTR [rax + 0], 'H'
	mov BYTE PTR [rax + 1], 'e'
	mov BYTE PTR [rax + 2], 'l'
	mov BYTE PTR [rax + 3], 'l'
	mov BYTE PTR [rax + 4], 'o'
	mov BYTE PTR [rax + 5], ','
	mov BYTE PTR [rax + 6], ' '
	mov BYTE PTR [rax + 7], 'w'
	mov BYTE PTR [rax + 8], 'o'
	mov BYTE PTR [rax + 9], 'r'
	mov BYTE PTR [rax + 10], 'l'
	mov BYTE PTR [rax + 11], 'd'
	mov BYTE PTR [rax + 12], '!'
	mov BYTE PTR [rax + 13], '\0'

	mov rdi, 1
	mov rsi, rax
	mov rdx, 13
	# macOS-specific:
	mov rax, 0x2000004
	syscall

	mov rsp, rbp
	pop rbp

	mov rax, 0x2000001
	mov rdi, 42
	syscall
	