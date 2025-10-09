.PHONY: run clean

a.out: main.s main.c
	gcc main.s main.c

run: a.out
	@./a.out; echo Код возврата: $$?

clean:
	rm -f a.out