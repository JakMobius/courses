	.section	__TEXT,__text,regular,pure_instructions
	.globl	_pow3
	.p2align	2

_pow3: 
	mov x8, 1
	tst x0, x0
	b.eq exit
	loop:
	add x8, x8, x8, lsl 1
	subs x0, x0, 1
	b.ne loop
	exit:
	mov x0, x8
	ret