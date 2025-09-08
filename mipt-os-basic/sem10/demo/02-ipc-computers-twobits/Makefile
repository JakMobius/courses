.PHONY: run clean

CC_SRC=$(wildcard *.c)

a.out: $(CC_SRC)
	gcc -pthread $(CC_SRC)

run: a.out
	@./a.out; echo Код возврата: $$?

run_renice: a.out
	sudo nice -n -10 ./a.out; echo Код возврата: $$?

clean:
	rm -f a.out