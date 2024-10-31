#include <stdio.h>
#include <pthread.h>
#include <stdlib.h>
#include <stdbool.h>
#include "lstack.h"

lstack_t shared_stack = {};

void *job(void *argument)
{
    unsigned int rand_state = *((int *)argument);
    for (int n = 0; n < 1000000; ++n)
    {
        int op = rand_r(&rand_state);

        if (op % 2 == 0)
        {
            int num = rand_r(&rand_state);
            lstack_push(&shared_stack, num);
        }
        else
        {
            lstack_pop(&shared_stack);
        }
    }
    return 0;
}

#define THREADS 6

int main(void)
{
    lstack_init(&shared_stack, 4096);

    pthread_t threads[THREADS] = {};
    int args[THREADS] = {};

    for (int n = 0; n < THREADS; ++n)
    {
        args[n] = n;
        pthread_create(&threads[n], NULL, job, args + n);
    }
    for (int n = 0; n < THREADS; ++n)
    {
        pthread_join(threads[n], NULL);
    }
}