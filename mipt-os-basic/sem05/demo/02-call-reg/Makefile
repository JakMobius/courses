.PHONY: run clean

a.out: main.s
	gcc main.s

run: a.out
	@./a.out; echo Код возврата: $$?

clean:
	rm -f a.out