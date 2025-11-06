// Original source: https://github.com/skeeto/lstack

#include <stdlib.h>
#include <errno.h>
#include "tstack.h"

int tstack_init(tstack_t *tstack, size_t max_size)
{
    pthread_mutex_init(&tstack->mutex, NULL);
    struct tstack_head head_init = {NULL};
    tstack->head = head_init;
    tstack->size = 0;

    /* Pre-allocate all nodes. */
    tstack->node_buffer = malloc(max_size * sizeof(struct tstack_node));
    if (tstack->node_buffer == NULL)
        return ENOMEM;
    for (size_t i = 0; i < max_size - 1; i++)
        tstack->node_buffer[i].next = tstack->node_buffer + i + 1;

    tstack->node_buffer[max_size - 1].next = NULL;
    struct tstack_head free_init = {tstack->node_buffer};
    tstack->free = free_init;
    return 0;
}

static struct tstack_node *pop(struct tstack_head *head)
{
    struct tstack_head orig = *head;
    if (head->node == NULL)
        return NULL;
    head->node = head->node->next;
    return orig.node;
}

static void push(struct tstack_head *head, struct tstack_node *node)
{
    node->next = head->node;
    head->node = node;
}

int tstack_push(tstack_t *tstack, int value)
{
    pthread_mutex_lock(&tstack->mutex);
    struct tstack_node *node = pop(&tstack->free);
    if (node == NULL) {
        pthread_mutex_unlock(&tstack->mutex);
        return ENOMEM;
    }
    node->value = value;
    push(&tstack->head, node);
    tstack->size += 1;
    pthread_mutex_unlock(&tstack->mutex);
    return 0;
}

int tstack_pop(tstack_t *tstack)
{
    pthread_mutex_lock(&tstack->mutex);
    struct tstack_node *node = pop(&tstack->head);
    if (node == NULL) {
        pthread_mutex_unlock(&tstack->mutex);
        return -1;
    }
    tstack->size -= 1;
    int value = node->value;
    push(&tstack->free, node);
    pthread_mutex_unlock(&tstack->mutex);
    return value;
}