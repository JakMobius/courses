

#include <sys/syscall.h>

static long syscall(int id, ...);
static void write(int fd, void* buf, int size);
static void read(int fd, void* buf, int size);

void entry(int sock) {
    int input[4] = {};

    read(sock, input, sizeof(input));

    for(int i = 0; i < sizeof(input) / sizeof(*input); i++) {
        input[i] = i * 2;
    }

    write(sock, input, sizeof(input));
}

void write(int fd, void* buf, int size) {
    syscall(SYS_write, fd, buf, size);
}

void read(int fd, void* buf, int size) {
    syscall(SYS_read, fd, buf, size);
}