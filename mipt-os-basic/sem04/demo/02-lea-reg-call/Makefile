.PHONY: run clean

a.out: main.s
	# Осторожно, macOS-specific:
	arch -arch x86_64 gcc main.s

	@# Для большинства систем:
	@# gcc main.s

run: a.out
	@./a.out; echo Код возврата: $$?

clean:
	rm -f ./a.out