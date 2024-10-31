
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>
#include <time.h>
#include <stdlib.h>
#include <pthread.h>

char MESSAGE[256] = {};

int thread1() {
	while(true) strcpy(MESSAGE, "....................");
}

int thread2() {
    while(true) strcpy(MESSAGE, "@@@@@@@@@@@@@@@@@@@@");
}

// int thread1() {
//     while(true) strcpy(MESSAGE, "McDonalds rules!");
// }

// int thread2() {
// 	while(true) strcpy(MESSAGE, "Burger King tastes better!");
// }

int thread3() {
	for(int i = 0; i < 99999; i++) {
		puts(MESSAGE);
	}
    return 0;
}

void* thread1_main(void* arg) {thread1(); return NULL;}
void* thread2_main(void* arg) {thread2(); return NULL;}
void* thread3_main(void* arg) {thread3(); return NULL;}

int main() {
    pthread_t thr1 = 0;
    pthread_t thr2 = 0;
    pthread_t thr3 = 0;

    pthread_create(&thr1, NULL, thread1_main, NULL);
    pthread_create(&thr2, NULL, thread2_main, NULL);
    pthread_create(&thr3, NULL, thread3_main, NULL);

    pthread_join(thr3, NULL);
    pthread_cancel(thr1);
    pthread_cancel(thr2);
}