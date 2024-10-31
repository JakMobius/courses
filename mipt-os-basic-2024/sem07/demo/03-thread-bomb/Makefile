.PHONY: run clean

CC_SRC=$(wildcard *.c)

a.out: $(CC_SRC)
	gcc $(CC_SRC) -pthread

run: a.out
	@./a.out; echo Код возврата: $$?

clean:
	rm -f a.out