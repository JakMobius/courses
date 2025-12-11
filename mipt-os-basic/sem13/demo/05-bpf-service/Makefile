.PHONY: all run clean
all: main service

main: main.c
	gcc -g main.c -o main

service: service.c
	gcc service.c -o service

run: main service
	./main

clean:
	rm -f *.o *.raw main service