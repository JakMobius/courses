#include <stdio.h>
#include <unistd.h>
#include <stddef.h>
#include <stdbool.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

int main() {
    int port = 80;
    const char* hostname = "google.com";

    struct hostent *host = gethostbyname(hostname);
    if (host == NULL) {
        perror("gethostbyname");
        return -1;
    }

    struct sockaddr_in address = {};
    address.sin_family = AF_INET;
    address.sin_port = htons(port);
    memcpy((char *) &address.sin_addr.s_addr, (char *) host->h_addr, host->h_length);

    // Создаём сокет
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock == -1) {
        perror("socket");
        return -1;
    }

    if (connect(sock, (struct sockaddr *) &address, sizeof(address)) == -1) {
        close(sock);
        perror("connect");
        return -1;
    }

    const char* request = 
        "GET / HTTP/1.1\r\n"
        "\r\n";

    if(write(sock, request, strlen(request)) < 0) {
        perror("write");
        close(sock);
        return -1;
    }

    if(shutdown(sock, SHUT_WR) < 0) {
        perror("write");
        close(sock);
        return -1;
    }

    char buf[1024] = {};

    while(true) {
        int length = read(sock, buf, sizeof(buf));
        if(length == 0) break;
        if (length < 0) {
            perror("read");
            return -1;
        }

        if(write(STDOUT_FILENO, buf, length) < 0) {
            perror("write");
            return -1;
        }
    }

    close(sock);

    return 0;
}