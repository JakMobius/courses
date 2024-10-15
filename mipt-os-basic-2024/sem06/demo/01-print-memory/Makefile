.PHONY: run clean

a.out: main.c
	# Осторожно, macOS-specific:
	arch -arch x86_64 gcc -fno-pie main.c 

	@# Для большинства систем:
	@# gcc -fno-pie main.c 

run: a.out
	@./a.out; echo Код возврата: $$?

clean:
	rm -f a.out