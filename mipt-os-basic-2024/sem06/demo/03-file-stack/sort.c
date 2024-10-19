
#include <inttypes.h>
#include <unistd.h>
#include <stdlib.h>
#include <time.h>

typedef uint8_t elt_t;

int compare(const void* a, const void* b) {
    return (*(elt_t*)a - *(elt_t*)b);
}

void* sortMain(void* arg) {
    volatile elt_t buffer[600 * 500 * 4 / sizeof(elt_t)];

    qsort(buffer, sizeof(buffer) / sizeof(elt_t), sizeof(elt_t), compare);
    return NULL;
}