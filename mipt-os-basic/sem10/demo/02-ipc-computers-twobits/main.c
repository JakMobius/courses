
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <pthread.h>
#include "transmission.h"

void* thread1_job(void* arg) {
    computer1();
    return NULL;
}

void* thread2_job(void* arg) {
    computer2();
    return NULL;
}

int main() {
    atomic_init(&wire1, false);
    atomic_init(&wire2, false);

    pthread_t thread1, thread2;
    pthread_create(&thread1, NULL, thread1_job, NULL);
    pthread_create(&thread2, NULL, thread2_job, NULL);

    pthread_join(thread1, NULL);
    pthread_join(thread2, NULL);

    return 0;
}