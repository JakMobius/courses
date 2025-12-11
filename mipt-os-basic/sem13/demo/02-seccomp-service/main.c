
#include <stdio.h>
#include <unistd.h>
#include <linux/seccomp.h>
#include <sys/prctl.h>
#include <fcntl.h>
#include <limits.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <stdint.h>
#include <assert.h>

#define ARM_BL_JUMP_MAX 0x0FFFFFFF
#define ARM_BL_HEADER 0x94000000
#define ARM_BL(distance) 0x94000000 | ((distance & ARM_BL_JUMP_MAX) / 4)

void patch_syscalls(void* function, int length) {
    // Warning: ARM-specific
    uint32_t* instructions = (uint32_t*)function;

    uint64_t syscall_address = (uint64_t)(void*)syscall;

    for(int i = 0; i < length / sizeof(uint32_t); i++) {
        if(instructions[i] == ARM_BL(0)) {
            uint64_t diff = syscall_address - (uint64_t) (instructions + i);
            if(diff > ARM_BL_JUMP_MAX) {
                assert("Cannot jump that far\n");
            }
            instructions[i] = ARM_BL(diff);
        }
    }
}

char* read_function(const char* path, int* length) {
    int file = open(path, O_RDONLY);
    *length = lseek(file, 0, SEEK_END);
    lseek(file, SEEK_SET, 0);

    int pagesize = getpagesize();
    *length = ((*length + pagesize - 1) / pagesize) * pagesize;
    char* result = mmap(NULL, *length, PROT_READ | PROT_WRITE, MAP_ANON | MAP_PRIVATE, -1, 0);
    if(!result) return NULL;
    read(file, result, *length);
    patch_syscalls(result, *length);
    close(file);
    mprotect(result, *length, PROT_READ | PROT_EXEC);
    return result;
}

int main() {
    int sockets[2] = {-1, -1};
    socketpair(AF_UNIX, SOCK_SEQPACKET, 0, sockets);

    int pid = fork();

    if(pid == 0) {
        // Child: execute unsafe code
        close(sockets[1]);

        int length = 0;
        void* function = read_function("service.raw", &length);

        prctl(PR_SET_SECCOMP, SECCOMP_MODE_STRICT);

        void (*service_function)(int) = function;
        service_function(sockets[0]);
        _exit(0);
    } else {
        // Parent: send the task and read the child response

        int request[4] = {1, 2, 3, 4};
        write(sockets[1], request, sizeof(request));
        read(sockets[1], request, sizeof(request));

        for(int i = 0; i < sizeof(request) / sizeof(*request); i++) {
            printf("[%d] = %d\n", i, request[i]);
        }
    }
}