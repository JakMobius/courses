	.section	__TEXT,__text,regular,pure_instructions
	.globl	_main
	.globl	_exit
	.p2align	2

_my_func:
	mov x10, 17

	# Выход из функции
	ldr x30, [sp], 16
	br x30

_main:
	# Вызов функции  
	adr x30, 12
	str x30, [sp, -16]!
	b _my_func

	# Возвращаем то, что записалось в функции _my_func
	mov     x0, x10
    bl      _exit
