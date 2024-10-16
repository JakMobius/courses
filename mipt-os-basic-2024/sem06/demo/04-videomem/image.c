
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

void* imageMain(void* arg) {
    FILE* file = fopen("image.bmp", "r");
    if (file == NULL) {
        printf("Failed to open file!\n");
        exit(1);
    }

    fseek(file, 0, SEEK_END);
    long fileSize = ftell(file);
    fseek(file, 0, SEEK_SET);

#if 1
    uint8_t buffer[fileSize];
    fread(buffer, 1, fileSize, file);
    fclose(file);

#else
    uint8_t padding[420];

    uint8_t buffer[fileSize + 16];

    // Align the buffer
    uint8_t* alignedBuffer = buffer;
    if ((uintptr_t)alignedBuffer % 4 != 0) {
        alignedBuffer += (4 - (uintptr_t)alignedBuffer % 4);
    }
    alignedBuffer += 2;

    fread(alignedBuffer, 1, fileSize, file);
    fclose(file);
#endif

    while (1) {
        sleep(1);
    }
}