
#include <inttypes.h>
#include <unistd.h>
#include <stdlib.h>
#include <time.h>
#include "sort.h"

uint8_t* alignFramebuffer(uint8_t* buffer) {
    if ((uintptr_t)buffer % 4 != 0) {
        buffer += (4 - (uintptr_t)buffer % 4);
    }
    return buffer + 2;
}

void swapUint8(uint8_t* a, uint8_t* b) {
    uint8_t temp = *a;
    *a = *b;
    *b = temp;
}

void swapUint32(uint32_t* a, uint32_t* b) {
    uint32_t temp = *a;
    *a = *b;
    *b = temp;
}

void shuffleArrayUint8(uint8_t* array, size_t size) {
    for (size_t i = size - 1; i > 0; i--) {
        size_t j = rand() % (i + 1);
        swapUint8(&array[i], &array[j]);
    }
}

void shuffleArrayUint32(uint32_t* array, size_t size) {
    for (size_t i = size - 1; i > 0; i--) {
        size_t j = rand() % (i + 1);
        swapUint32(&array[i], &array[j]);
    }
}

int compareUint8(const void* a, const void* b) {

    // Just a little delay
    volatile int i = 0;
    while(i < 1000) i++;

    return (*(uint8_t*)a - *(uint8_t*)b);
}

int compareUint32(const void* a, const void* b) {

    // Just a little delay
    volatile int i = 0;
    while(i < 1000) i++;

    return (*(int32_t*)a - *(int32_t*)b);
}

void bubbleSortUint8(uint8_t* array, size_t size) {
    for (int i = 0; i < size - 1; i++) {
        int swapped = 0;
        for (int j = 0; j < size - i - 1; j++) {
            if (array[j] > array[j + 1]) {
                int tmp = array[j];
                array[j] = array[j + 1];
                array[j + 1] = tmp;
                swapped = 1;
            }
        }
        if (!swapped) break;
    }
}

void bubbleSortUint32(uint32_t* array, size_t size) {
    for (int i = 0; i < size - 1; i++) {
        int swapped = 0;
        for (int j = 0; j < size - i - 1; j++) {
            if (array[j] > array[j + 1]) {
                int tmp = array[j];
                array[j] = array[j + 1];
                array[j + 1] = tmp;
                swapped = 1;
            }
        }
        if (!swapped) break;
    }
}

void shakerSortUint32(uint32_t* array, size_t size) {
    int left = 0;
    int right = size - 1;
    
    while (left < right) {
        int newRight = left;
        for (int i = left; i < right; i++) {
            if (array[i] > array[i + 1]) {
                int tmp = array[i];
                array[i] = array[i + 1];
                array[i + 1] = tmp;
                newRight = i;
            }
        }
        right = newRight;
        
        int newLeft = right;
        for (int i = right; i > left; i--) {
            if (array[i] < array[i - 1]) {
                int tmp = array[i];
                array[i] = array[i - 1];
                array[i - 1] = tmp;
                newLeft = i;
            }
        }
        left = newLeft;
    }
}

void fillArrayUint8(uint8_t* arr, int size) {
    for (int i = 0; i < size; i++) {
        arr[i] = i;
    }
}

void fillArrayUint32(uint32_t* arr, int size) {
    for (int i = 0; i < size; i++) {
        uint8_t grayscale = (i * 255) / size;
        arr[i] = 0
            | grayscale
            | (grayscale << 8)
            | (grayscale << 16)
            | (grayscale << 24)
        ;
    }
}

void* sortMain(void* arg) {
    const int ARRAY_SIZE = 1024 * 1000;
    
    uint8_t buffer[ARRAY_SIZE + 16];
    uint8_t* image = alignFramebuffer(buffer);

    fillArrayUint32((uint32_t*)image, ARRAY_SIZE / 4);

    srand(time(NULL));

    while (1) {
        shuffleArrayUint32((uint32_t*) image, ARRAY_SIZE / 4);
        
        // bubbleSortUint32((uint32_t*) image, ARRAY_SIZE / 4);
        // shakerSortUint32((int*) image, ARRAY_SIZE / 4);
        // qsort(image, ARRAY_SIZE / 4, sizeof(uint32_t), compareUint32);
        sleep(1);
    }
}