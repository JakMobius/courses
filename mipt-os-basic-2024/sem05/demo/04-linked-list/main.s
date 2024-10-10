	.section	__TEXT,__text,regular,pure_instructions
	.globl	_print_list
	.globl	_puts
	.p2align	2

_print_list:
	sub sp, sp, 32
	stp x29, x30, [sp, 16]
	mov x29, sp

	str x19, [sp]

	loop:
	mov x19, x0

	ldr x0, [x0, 8]
	bl _puts

	ldr x0, [x19]
	tst x0, x0
	b.ne loop

	ldr x19, [sp]

	ldp x29, x30, [sp, 16]
	add sp, sp, 32
	ret