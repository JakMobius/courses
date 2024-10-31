// Original source: https://github.com/skeeto/lstack

#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include "lstack.h"

int lstack_init(lstack_t *lstack, size_t max_size)
{
    struct lstack_head head_init = {0, NULL};
    atomic_init(&lstack->head, head_init);
    atomic_init(&lstack->size, 0);

    /* Pre-allocate all nodes. */
    lstack->node_buffer = malloc(max_size * sizeof(struct lstack_node));
    if (lstack->node_buffer == NULL)
        return ENOMEM;
    for (size_t i = 0; i < max_size - 1; i++)
        lstack->node_buffer[i].next = lstack->node_buffer + i + 1;
    lstack->node_buffer[max_size - 1].next = NULL;
    struct lstack_head free_init = {0, lstack->node_buffer};
    atomic_init(&lstack->free, free_init);
    return 0;
}

static struct lstack_node *pop(_Atomic struct lstack_head *head)
{
    struct lstack_head next, orig = atomic_load(head);
    while(1) {
        if (orig.node == NULL)
            return NULL;
        next.aba = orig.aba + 1;
        next.node = orig.node->next;
        if(atomic_compare_exchange_weak(head, &orig, next)) {
            break;
        }
        usleep(1);
    }
    return orig.node;
}

static void push(_Atomic struct lstack_head *head, struct lstack_node *node)
{
    struct lstack_head next, orig = atomic_load(head);
    while(1) {
        node->next = orig.node;
        next.aba = orig.aba + 1;
        next.node = node;
        if(atomic_compare_exchange_weak(head, &orig, next)) {
            break;
        }
        usleep(1);
    }
}

int lstack_push(lstack_t *lstack, int value)
{
    struct lstack_node *node = pop(&lstack->free);
    if (node == NULL)
        return ENOMEM;
    node->value = value;
    push(&lstack->head, node);
    atomic_fetch_add(&lstack->size, 1);
    return 0;
}

int lstack_pop(lstack_t *lstack)
{
    struct lstack_node *node = pop(&lstack->head);
    if (node == NULL)
        return -1;
    atomic_fetch_sub(&lstack->size, 1);
    int value = node->value;
    push(&lstack->free, node);
    return value;
}