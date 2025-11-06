
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>
#include <time.h>
#include <stdlib.h>
#include <pthread.h>

char MESSAGE[256] = {};

pthread_mutex_t lock;

int thread1() {
	while(true) {
        pthread_mutex_lock(&lock);
        strcpy(MESSAGE, "....................");
        pthread_mutex_unlock(&lock);
    }
}

int thread2() {
    while(true) {
        pthread_mutex_lock(&lock);
        strcpy(MESSAGE, "@@@@@@@@@@@@@@@@@@@@");
        pthread_mutex_unlock(&lock);
    }
}

// int thread1() {
//     while(true) strcpy(MESSAGE, "McDonalds rules!");
// }

// int thread2() {
// 	while(true) strcpy(MESSAGE, "Burger King tastes better!");
// }

int thread3() {
	for(int i = 0; i < 99999; i++) {
        pthread_mutex_lock(&lock);
		puts(MESSAGE);
        pthread_mutex_unlock(&lock);
	}
    return 0;
}

void* thread1_main(void* arg) {thread1(); return NULL;}
void* thread2_main(void* arg) {thread2(); return NULL;}
void* thread3_main(void* arg) {thread3(); return NULL;}

int main() {
    pthread_mutex_init(&lock, NULL);

    pthread_t thr1 = 0;
    pthread_t thr2 = 0;
    pthread_t thr3 = 0;

    pthread_create(&thr1, NULL, thread1_main, NULL);
    pthread_create(&thr2, NULL, thread2_main, NULL);
    pthread_create(&thr3, NULL, thread3_main, NULL);

    pthread_join(thr3, NULL);
    pthread_cancel(thr1);
    pthread_cancel(thr2);

    pthread_mutex_destroy(&lock);
}