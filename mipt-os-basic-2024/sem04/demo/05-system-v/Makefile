
a.out: main.s main.c
	# Осторожно, macOS-specific:
	arch -arch x86_64 gcc main.s main.c

	@# Для большинства систем:
	@# gcc main.s

run: a.out
	@./a.out; echo Код возврата: $$?

clean:
	rm -f ./a.out