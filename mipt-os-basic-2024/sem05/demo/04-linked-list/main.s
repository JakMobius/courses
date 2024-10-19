	.section	__TEXT,__text,regular,pure_instructions
	.globl	_print_list
	.globl	_puts
	.p2align	2

_print_list:
	sub sp, sp, 32
	stp x29, x30, [sp, 16]
	mov x29, sp

	//# <ваш_код>

	ldr x0, [x0, 8]
	bl _puts
	
	//# </ваш_код>

	ldp x29, x30, [sp, 16]
	add sp, sp, 32
	ret