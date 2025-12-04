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

sig_atomic_t interrupted = 0;

void sigint_handler(int signo)
{
    interrupted = 1;
}

int main()
{   
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

    int child1 = fork();
    int child2 = fork();

    struct sigaction sa = {0};
    sa.sa_handler = sigint_handler;
    sigaction(SIGINT, &sa, NULL);

    while (!interrupted)
    {
        int connection = accept(server_socket, NULL, NULL);
        if (connection < 0)
        {
            if(errno == EINTR) {
                break;
            }
            perror("accept");
            continue;
        }
        
        FILE* socket = fdopen(connection, "r+");
        setvbuf(socket, NULL, _IONBF, 0);
        handle_request(socket);
        shutdown(connection, SHUT_WR);
        read_all(connection);
        fclose(socket);
    }

    if(child2 != 0) {
        kill(child2, SIGINT);
        waitpid(child2, NULL, 0);

        if(child1 != 0) {
            kill(child1, SIGINT);
            waitpid(child1, NULL, 0);
        }
    }

    close(server_socket);

    return 0;
}