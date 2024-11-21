#include <stdio.h>
#include <unistd.h>
#include <stddef.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <errno.h>
#include <sys/wait.h>
#include "request-handler.h"
#include "utils.h"

#define CONN_QUEUE_LEN 4096

void sigchild_handler() {
    while (waitpid(-1, NULL, WNOHANG) > 0);   
}

int main()
{
    sigaction(SIGCHLD, &(struct sigaction){.sa_handler = sigchild_handler}, NULL);

    // Игнорирование сигнала SIGPIPE, чтобы избежать
    // завершения процесса при записи в закрытый сокет
    signal(SIGPIPE, SIG_IGN);

    int port = 1234;

    // Создание TCP-сокета
    int server_socket = socket(AF_INET, SOCK_STREAM, 0);

    if (server_socket == -1)
    {
        perror("socket");
        return -1;
    }

    // Установка SO_REUSEADDR (опционально)
    if (setsockopt(server_socket, SOL_SOCKET, SO_REUSEADDR, &(int){1}, sizeof(int)) < 0)
    {
        perror("setsockopt(SO_REUSEADDR)");
        return -1;
    }

    // Подключение сокета к адресу 0.0.0.0
    struct sockaddr_in server_address = {};
    server_address.sin_family = AF_INET;
    server_address.sin_addr.s_addr = INADDR_ANY;
    server_address.sin_port = htons(port);

    if (bind(server_socket, (struct sockaddr *)&server_address, sizeof(server_address)) == -1)
    {
        perror("bind");
        return -1;
    }

    // Подключение сокет к HTTP-порту (80)
    if (listen(server_socket, CONN_QUEUE_LEN) == -1)
    {
        perror("listen");
        return -1;
    }

    while (true)
    {
        int connection = accept(server_socket, NULL, NULL);
        
        if(connection < 0) {
            if(errno == EINTR) {
                continue;
            }
            perror("accept");
            continue;
        }

        int pid = fork();

        if (pid < 0)
        {
            perror("fork");
            close(server_socket);
            return -1;
        }

        if (pid == 0)
        {
            FILE* socket = fdopen(connection, "r+");
            handle_request(socket);
            shutdown(connection, SHUT_WR);
            read_all(connection);
            fclose(socket);
            exit(0);
        }
        close(connection);
    }

    close(server_socket);

    return 0;
}