.PHONY: all run clean
all: main service

main: main.c
	gcc -g main.c -o main

service: service.c
	gcc -O3 service.c -c -o service.o
	objcopy -O binary -j .text service.o service.raw

run: main service
	./main

clean:
	rm -f *.o *.raw main service