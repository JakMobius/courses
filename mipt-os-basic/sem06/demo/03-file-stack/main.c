
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <pthread.h>
#include <limits.h>

#define FILEMODE S_IRWXU | S_IRGRP | S_IROTH

void copy(const char* source, const char* destination) {
    // Copy contents of source to file
    int sourceFile = open(source, O_RDONLY, 0644);
    int destinationFile = open(destination, O_WRONLY | O_CREAT, 0644);

    if (sourceFile < 0) {
        perror("open(source)");
        exit(EXIT_FAILURE);
    }

    if (destinationFile < 0) {
        perror("open(destination)");
        exit(EXIT_FAILURE);
    }

    long fileSize = lseek(sourceFile, 0, SEEK_END);
    lseek(sourceFile, 0, SEEK_SET);
    
    uint8_t* buffer = calloc(fileSize, 1);
    read(sourceFile, buffer, fileSize);
    write(destinationFile, buffer, fileSize);
    free(buffer);

    close(sourceFile);
    close(destinationFile);
}

void* imageMain(void* arg);
void* sortMain(void* arg);
void* fibMain(void* arg);
void* threadMain(void* arg);

void createThread(uint64_t stackPtr, uint64_t stackSize) {
    pthread_t thread = 0;
    pthread_attr_t tattr = {};

    uint64_t ptrAlign = getpagesize();
    uint64_t sizeAlign = getpagesize();

    int res = 0;

    if(stackPtr % ptrAlign) {
        stackSize -= (ptrAlign - stackPtr % ptrAlign);
        stackPtr += (ptrAlign - stackPtr % ptrAlign);
    }
    stackSize -= stackSize % sizeAlign;

    if(PTHREAD_STACK_MIN > stackSize) {
        fprintf(stderr, "Image is too small\b");
        exit(EXIT_FAILURE);
    }

    // memset((void*)stackPtr, 0, stackSize);
    // return;

    printf("Stack: ptr = 0x%llx, size = 0x%llx\n", stackPtr, stackSize);

    if((res = pthread_attr_init(&tattr)) != 0) {
        fprintf(stderr, "pthread_attr_init: %s\n", strerror(res));
        exit(EXIT_FAILURE);
    }

    if((res = pthread_attr_setstack(&tattr, (void*)stackPtr, stackSize)) != 0) {
        fprintf(stderr, "pthread_attr_setstack: %s\n", strerror(res));
        exit(EXIT_FAILURE);
    }

    if((res = pthread_create(&thread, &tattr, threadMain, NULL)) != 0) {
        fprintf(stderr, "pthread_create: %s\n", strerror(res));
        exit(EXIT_FAILURE);
    }
    
    int status = 0;

    if((res = pthread_join(thread, (void*) &status)) != 0) {
        fprintf(stderr, "pthread_join: %s\n", strerror(res));
        exit(EXIT_FAILURE);
    }

    if((res = pthread_attr_destroy(&tattr)) != 0) {
        fprintf(stderr, "pthread_attr_destroy: %s\n", strerror(res));
        exit(EXIT_FAILURE);
    }
}

int main(int argc,char *argv[])
{
    const char* original = "image.bmp";
    const char* mappedFile = "buffer-image.bmp";

    copy(original, mappedFile);

    int fd = -1, ret = 0;

    if ((fd = open(mappedFile, O_RDWR | O_CREAT, FILEMODE)) < 0) {
        perror("open");
        return EXIT_FAILURE;
    }

    long fileSize = lseek(fd, 0, SEEK_END);
    lseek(fd, 0, SEEK_SET);

    void* addr = NULL;

    if ((addr = mmap(NULL, fileSize, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0)) == MAP_FAILED) {
        perror("mmap");
        return EXIT_FAILURE;
    }

    createThread((uint64_t) addr + 0xF00, fileSize - 0xFFF);
    
    if((msync(addr, fileSize, MS_SYNC)) < 0) {
        perror("msync");
        return EXIT_FAILURE;
    }

    if (munmap(addr, fileSize) == -1) {
        perror("munmap");
        return EXIT_FAILURE;
    }

    if (close(fd)) {
        perror("close");
        return EXIT_FAILURE;
    }

    return 0;
}

void* threadMain(void* arg) {
    return fibMain(arg);
    // return sortMain(arg);
}