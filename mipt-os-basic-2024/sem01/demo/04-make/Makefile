
a.out: main.o lib1.o lib2.o
	gcc main.o lib1.o lib2.o -o a.out

main.o: main.c
	gcc -c main.c -o main.o

lib1.o: lib1.c lib1.h
	gcc -c lib1.c -o lib1.o

lib2.o: lib2.c lib2.h
	gcc -c lib2.c -o lib2.o

clean:
	rm -rf *.o a.out
