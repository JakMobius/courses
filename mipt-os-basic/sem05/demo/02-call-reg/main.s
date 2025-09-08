	.section	__TEXT,__text,regular,pure_instructions
	.globl	_main
	.globl	_exit
	.p2align	2

_my_func:
	mov x10, 21
	ret

_main:
	# Вызов функции  
	bl _my_func

	# Возвращаем то, что записалось в функции _my_func
	mov     x0, x10
    bl      _exit
