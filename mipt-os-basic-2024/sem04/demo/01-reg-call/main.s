	.section	__TEXT,__text,regular,pure_instructions
	.globl	_main
	.globl	_exit
	.intel_syntax

_my_func:
	mov r11, 42
	jmp r10

_main:
    # error: rip can only be used as a base register
	mov r10, rip
    add r10, 11
	jmp _my_func

	# macOS-specific:
	mov rax, 0x2000001
	mov rdi, r11
	syscall
	