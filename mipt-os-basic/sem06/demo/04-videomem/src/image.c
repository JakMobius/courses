
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include "image.h"
#include "sort.h"

#define PADDING 500

void* imageMain(void* arg) {
    FILE* file = fopen("image.bmp", "r");
    if (file == NULL) {
        printf("Failed to open file!\n");
        exit(1);
    }

    fseek(file, 0, SEEK_END);
    long fileSize = ftell(file);
    fseek(file, 0, SEEK_SET);

    while (1) {
        fseek(file, 0, SEEK_SET);

        uint8_t buffer[fileSize + 16 + PADDING];

        uint8_t* alignedBuffer = alignFramebuffer(buffer);

        fread(alignedBuffer, 1, fileSize, file);

        // spoilers:
        // qsort(alignedBuffer, fileSize, sizeof(uint8_t), compareUint8);
        // qsort(alignedBuffer, fileSize / 4, sizeof(uint32_t), compareUint32);
        // bubbleSortUint8(alignedBuffer, fileSize);
        // bubbleSortUint32(alignedBuffer, fileSize / 4);
        // shakerSortUint32(alignedBuffer, fileSize / 4);
        sleep(1);
    }

    fclose(file);
}