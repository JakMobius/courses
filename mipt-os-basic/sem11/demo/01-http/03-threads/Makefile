.PHONY: run clean

CC_SRC=$(wildcard *.c) $(wildcard ../shared/*.c)

a.out: $(CC_SRC)
	gcc -I../shared $(CC_SRC)

run: a.out
	@./a.out; echo Код возврата: $$?

benchmark: a.out
	../shared/benchmark.sh

clean:
	rm -f a.out