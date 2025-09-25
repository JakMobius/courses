
#include <stdio.h>
#include <unistd.h>
#include <sys/fcntl.h>

int main() {
    int fd = open("/", O_RDONLY, 0);
    char buffer[16];
    if(read(fd, buffer, sizeof(buffer)) >= 0) {
    printf("%15s", buffer);
    } else perror("read");
}