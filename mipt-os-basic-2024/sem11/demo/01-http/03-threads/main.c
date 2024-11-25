#include <stdio.h>
#include <unistd.h>
#include <stdbool.h>
#include <signal.h>
#include <pthread.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include "request-handler.h"
#include "utils.h"

#define CONN_QUEUE_LEN 4096

void* thread_job(void* arg) {
    int connection = (int)(int64_t)arg;

    FILE* socket = fdopen(connection, "r+");
    setvbuf(socket, NULL, _IONBF, 0);
    if(!socket) {
        perror("fdopen");
        close(connection);
        return NULL;
    }

    handle_request(socket);
    shutdown(connection, SHUT_WR);
    read_all(connection);
    fclose(socket);
    return 0;
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

    while (true)
    {
        int connection = accept(server_socket, NULL, NULL);

        if(connection < 0) {
            perror("accept");
            close(server_socket);
            return -1;
        }

        pthread_t thread;
        if(pthread_create(&thread, NULL, thread_job, (void*)(int64_t)connection) < 0) {
            perror("pthread_create");
            close(connection);
            continue;
        }
        pthread_detach(thread);
    }

    close(server_socket);

    return 0;
}