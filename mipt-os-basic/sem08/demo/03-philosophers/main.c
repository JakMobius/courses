// Original source: https://learnc.info/c/pthreads_deadlock.html

#include <pthread.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <stdbool.h>
#include <string.h>
#include <assert.h>
#include "philosophers.h"

#define ANSI_GREEN "\x1b[32m"
#define ANSI_RED "\x1b[31m"
#define ANSI_RESET "\x1b[0m"

pthread_mutex_t logic_mutex = PTHREAD_MUTEX_INITIALIZER;

void init_table(table_t *table)
{
    for (size_t i = 0; i < PHT_SIZE; i++)
    {
        pthread_mutex_init(&table->forks[i], NULL);
    }
}

void destroy_table(table_t *table)
{
    for (size_t i = 0; i < PHT_SIZE; i++)
    {
        pthread_mutex_destroy(&table->forks[i]);
    }
}

void random_sleep(philosopher_t *philosopher)
{
    unsigned rand = rand_r(&philosopher->random_state);
    rand_r(&rand);
    rand %= 10;
    for (int i = 0; i < rand; i++)
    {
        sched_yield();
    }
}

unsigned get_philosopher_fork(philosopher_t* philosopher, unsigned fork)
{
    if (fork == LEFT_FORK)
    {
        return philosopher->left_fork;
    }
    else if (fork == RIGHT_FORK)
    {
        return philosopher->right_fork;
    }
    else
    {
        return -1;
    }
}

philosopher_t* get_another_philosopher_holding(philosopher_t *philosopher, unsigned fork_index)
{
    table_t *table = philosopher->table;
    for (philosopher_t *i = table->philosophers; i; i = i->next)
    {
        if (i == philosopher)
        {
            continue;
        }
        if (i->left_fork == fork_index && (i->captured_forks & LEFT_FORK))
        {
            return i;
        }
        if (i->right_fork == fork_index && (i->captured_forks & RIGHT_FORK))
        {
            return i;
        }
    }

    return NULL;
}

const char* get_fork_name(unsigned fork) {
    return fork == LEFT_FORK ? "L" : "R";
}

void check_deadlock(philosopher_t *philosopher, unsigned fork_side)
{
    table_t *table = philosopher->table;
    for (philosopher_t *i = table->philosophers; i; i = i->next)
    {
        if (i->captured_forks != (LEFT_FORK | RIGHT_FORK))
        {
            return;
        }
    }

    fprintf(stderr, ANSI_RED "[DEADLOCK]: Philosophers are mutually locked.\n" ANSI_RESET);



    philosopher_t *i = philosopher;
    do {
        unsigned fork_index = get_philosopher_fork(i, fork_side);
        philosopher_t* holder = get_another_philosopher_holding(i, fork_index);
        assert(holder != NULL);
        unsigned holder_side = holder->left_fork == fork_index ? LEFT_FORK : RIGHT_FORK;
        unsigned holder_another_side = holder_side == LEFT_FORK ? RIGHT_FORK : LEFT_FORK;

        fprintf(stderr, "- P[%d] cannot capture %s fork - he waits for P[%d] to release %s fork\n"
            , i->id, get_fork_name(fork_side), holder->id, get_fork_name(holder_side));
        fprintf(stderr, "- P[%d] cannot release %s fork - he waits for %s fork to be available\n",
            holder->id, get_fork_name(holder_side), get_fork_name(holder_another_side));

        fork_side = holder_another_side;
        
        i = holder;
    } while(i != philosopher);

    exit(EXIT_FAILURE);
}

void capture_fork(philosopher_t *philosopher, unsigned fork)
{
    table_t *table = philosopher->table;
    pthread_mutex_lock(&logic_mutex);
    philosopher->captured_forks |= fork;
    check_deadlock(philosopher, fork);
    pthread_mutex_unlock(&logic_mutex);
}

void capture_left_fork(philosopher_t *philosopher)
{
    table_t *table = philosopher->table;
    capture_fork(philosopher, LEFT_FORK);
    pthread_mutex_lock(&table->forks[philosopher->left_fork]);
}

void capture_right_fork(philosopher_t *philosopher)
{
    table_t *table = philosopher->table;
    capture_fork(philosopher, RIGHT_FORK);
    pthread_mutex_lock(&table->forks[philosopher->right_fork]);
}

void release_left_fork(philosopher_t *philosopher)
{
    pthread_mutex_lock(&logic_mutex);
    table_t *table = philosopher->table;
    philosopher->captured_forks &= ~LEFT_FORK;
    pthread_mutex_unlock(&table->forks[philosopher->left_fork]);
    pthread_mutex_unlock(&logic_mutex);
}

void release_right_fork(philosopher_t *philosopher)
{
    pthread_mutex_lock(&logic_mutex);
    table_t *table = philosopher->table;
    philosopher->captured_forks &= ~RIGHT_FORK;
    pthread_mutex_unlock(&table->forks[philosopher->right_fork]);
    pthread_mutex_unlock(&logic_mutex);
}

void *eat(void *arg)
{
    philosopher_t *philosopher =(philosopher_t *)arg;
    table_t *table = philosopher->table;

    for (int i = 0; i < 100000; i++)
    {
        random_sleep(philosopher);
        start_eating(philosopher);
        random_sleep(philosopher);
        stop_eating(philosopher);
    }

    return NULL;
}

int main()
{
    pthread_t threads[PHT_SIZE] = {};
    philosopher_t philosophers[PHT_SIZE] = {};
    table_t table = {};

    init_table(&table);

    table.philosophers = &philosophers[0];

    for (size_t i = 0; i < PHT_SIZE; i++)
    {
        if (i > 0)
        {
            philosophers[i - 1].next = &philosophers[i];
        }
        philosophers[i].left_fork = i;
        philosophers[i].right_fork = (i + 1) % PHT_SIZE;
        philosophers[i].id = i;
        philosophers[i].table = &table;
    }

    for (size_t i = 0; i < PHT_SIZE; i++)
    {
        pthread_create(&threads[i], NULL, eat, &philosophers[i]);
    }

    for (size_t i = 0; i < PHT_SIZE; i++)
    {
        pthread_join(threads[i], NULL);
    }

    destroy_table(&table);

    printf(ANSI_GREEN "All the philosophers have finished their eternal dinner.\n" ANSI_RESET);

    return EXIT_SUCCESS;
}