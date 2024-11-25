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
#include <sys/epoll.h>
#include "request-handler.h"
#include "utils.h"

#define CONN_QUEUE_LEN 4096
#define MAX_EVENTS 10

sig_atomic_t interrupted = 0;

void sigint_handler(int signo)
{
    interrupted = 1;
}

int main()
{
    signal(SIGPIPE, SIG_IGN);
    int port = 1234;

    int server_socket = socket(AF_INET, SOCK_STREAM, 0);
    if (server_socket == -1)
    {
        perror("socket");
        return -1;
    }

    if (setsockopt(server_socket, SOL_SOCKET, SO_REUSEADDR, &(int){1}, sizeof(int)) < 0)
    {
        perror("setsockopt(SO_REUSEADDR)");
        return -1;
    }

    struct sockaddr_in server_address = {};
    server_address.sin_family = AF_INET;
    server_address.sin_addr.s_addr = INADDR_ANY;
    server_address.sin_port = htons(port);

    if (bind(server_socket, (struct sockaddr *)&server_address, sizeof(server_address)) == -1)
    {
        perror("bind");
        return -1;
    }

    if (listen(server_socket, CONN_QUEUE_LEN) == -1)
    {
        perror("listen");
        return -1;
    }

    struct sigaction sa = {0};
    sa.sa_handler = sigint_handler;
    sigaction(SIGINT, &sa, NULL);

    int epoll_fd = epoll_create1(0);
    if (epoll_fd == -1)
    {
        perror("epoll_create1");
        return -1;
    }

    struct epoll_event event;
    event.events = EPOLLIN;
    event.data.fd = server_socket;

    if (epoll_ctl(epoll_fd, EPOLL_CTL_ADD, server_socket, &event) == -1)
    {
        perror("epoll_ctl");
        return -1;
    }

    struct epoll_event events[MAX_EVENTS];

    while (!interrupted)
    {
        int n = epoll_wait(epoll_fd, events, MAX_EVENTS, -1);
        if (n == -1)
        {
            if (errno == EINTR)
                break;
            perror("epoll_wait");
            continue;
        }

        for (int i = 0; i < n; i++)
        {
            if (events[i].data.fd == server_socket)
            {
                int connection = accept(server_socket, NULL, NULL);
                if (connection == -1)
                {
                    perror("accept");
                    continue;
                }

                event.events = EPOLLIN | EPOLLET;
                event.data.fd = connection;
                if (epoll_ctl(epoll_fd, EPOLL_CTL_ADD, connection, &event) == -1)
                {
                    perror("epoll_ctl");
                    close(connection);
                    continue;
                }
            }
            else
            {
                int connection = events[i].data.fd;
                int duplicate = dup(connection);
                FILE *socket = fdopen(duplicate, "r+");
                setvbuf(socket, NULL, _IONBF, 0);
                if (!handle_request(socket))
                {
                    if (epoll_ctl(epoll_fd, EPOLL_CTL_DEL, connection, &event) == -1)
                    {
                        perror("epoll_ctl");
                        close(connection);
                        continue;
                    }

                    shutdown(connection, SHUT_WR);
                    close(connection);
                }
                fclose(socket);
            }
        }
    }

    close(server_socket);
    close(epoll_fd);

    return 0;
}