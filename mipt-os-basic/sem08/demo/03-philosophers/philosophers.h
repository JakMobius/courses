#pragma once

#include <pthread.h>
#include <stdlib.h>

#define PHT_SIZE 5

enum {
    LEFT_FORK = 1,
    RIGHT_FORK = 2
};

struct table_tag;

typedef struct philosopher_tag
{
    const char *name;
    unsigned id;
    unsigned left_fork;
    unsigned right_fork;
    unsigned random_state;
    unsigned captured_forks;
    struct philosopher_tag* next;
    struct table_tag* table;
} philosopher_t;

typedef struct table_tag
{
    pthread_mutex_t forks[PHT_SIZE];
    philosopher_t* philosophers;
    int waits;
} table_t;

void start_eating(philosopher_t *philosopher);
void stop_eating(philosopher_t *philosopher);
void capture_left_fork(philosopher_t *philosopher);
void capture_right_fork(philosopher_t *philosopher);
void release_left_fork(philosopher_t *philosopher);
void release_right_fork(philosopher_t *philosopher);