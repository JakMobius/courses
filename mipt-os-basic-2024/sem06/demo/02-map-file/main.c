
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

int main(int argc,char *argv[])
{
    const char* original = "image.bmp";
    const char* mappedFile = "copied-image.bmp";

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

    for(int i = 0xF00; i < fileSize - 0xF00; i += 4) {
        int* pixel = ((int*)addr) + (i / 4);
        *pixel = -*pixel;
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