
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include <sys/socket.h>
#include <arpa/inet.h>
#include <netdb.h>

void read_all(int fd) {
    char buffer[1024] = {};
    while (true) {
        int len = read(fd, buffer, sizeof(buffer));
        if (len == 0) break;
        if (len < 0) {
            perror("read");
            break;
        }
    }
}
