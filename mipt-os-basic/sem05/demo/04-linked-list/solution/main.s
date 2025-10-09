	.section	__TEXT,__text,regular,pure_instructions
	.globl	_print_list
	.globl	_puts
	.p2align	2

_print_list:
	sub sp, sp, 16
	stp x29, x30, [sp, -16]!
	mov x29, sp

	mov x1, x0
	loop:
	str x1, [x29, 16]
	ldr x0, [x1, 8]
	bl _puts
	ldr x1, [x29, 16]
	ldr x1, [x1]
	tst x1, x1
	b.ne loop

	ldp x29, x30, [sp], 16
	add sp, sp, 16
	ret