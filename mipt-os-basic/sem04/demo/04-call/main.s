	.section	__TEXT,__text,regular,pure_instructions
	.globl	_main
	.globl	_exit
	.intel_syntax

_my_func:
	mov r11, 42
    ret

_main:
	call _my_func

    # macOS-specific:
	mov rax, 0x2000001
	mov rdi, r11
	syscall
	