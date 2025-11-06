// Original source: https://github.com/skeeto/lstack

#ifndef tstack_H
#define tstack_H

#include <stdlib.h>
#include <stdint.h>
#include <stdatomic.h>
#include <pthread.h>

struct tstack_node
{
    int value;
    struct tstack_node *next;
};

struct tstack_head
{
    struct tstack_node *node;
};

typedef struct
{
    struct tstack_node *node_buffer;
    struct tstack_head head, free;
    pthread_mutex_t mutex;
    size_t size;
} tstack_t;

static inline size_t tstack_size(tstack_t *tstack)
{
    pthread_mutex_lock(&tstack->mutex);
    return tstack->size;
    pthread_mutex_unlock(&tstack->mutex);
}

static inline void tstack_free(tstack_t *tstack)
{
    pthread_mutex_lock(&tstack->mutex);
    free(tstack->node_buffer);
    pthread_mutex_unlock(&tstack->mutex);
    pthread_mutex_destroy(&tstack->mutex);
}

int tstack_init(tstack_t *tstack, size_t max_size);
int tstack_push(tstack_t *tstack, int value);
int tstack_pop(tstack_t *tstack);

#endif