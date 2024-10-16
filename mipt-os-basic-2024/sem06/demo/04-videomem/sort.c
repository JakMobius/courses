
#include <inttypes.h>
#include <unistd.h>
#include <stdlib.h>
#include <time.h>

void swap(uint8_t* a, uint8_t* b) {
    uint8_t temp = *a;
    *a = *b;
    *b = temp;
}

void shuffleArray(uint8_t* array, size_t size) {
    for (size_t i = size - 1; i > 0; i--) {
        size_t j = rand() % (i + 1);
        swap(&array[i], &array[j]);
    }
}

int compare(const void* a, const void* b) {

    // Just a little delay
    volatile int i = 0;
    while(i < 100) i++;

    return (*(uint8_t*)a - *(uint8_t*)b);
}

void* sortMain(void* arg) {
    const int ARRAY_SIZE = 1024 * 1500;
    uint8_t largeStackBuffer[ARRAY_SIZE];

    for (int i = 0; i < ARRAY_SIZE; i++) {
        largeStackBuffer[i] = i;
    }

    srand(time(NULL));

    while (1) {
        shuffleArray(largeStackBuffer, ARRAY_SIZE);
        
        // bubbleSort(largeStackBuffer, ARRAY_SIZE);
        qsort(largeStackBuffer, ARRAY_SIZE, sizeof(uint8_t), compare);
        sleep(1);
    }
}