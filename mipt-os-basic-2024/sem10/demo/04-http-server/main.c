#include <stdio.h>
#include <unistd.h>
#include <stddef.h>
#include <stdbool.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

void read_socket(int socket) {
    // Читаем всё, что есть в socket и перенаправляем в stdout
    char buffer[1024] = {};
    while(true) {
        int len = read(socket, buffer, sizeof(buffer));
        if (len == 0) break;
        if (len < 0) {
            perror("read");
            close(socket);
            break;
        }
        fwrite(buffer, 1, len, stdout);
        printf("\n");
    }
}

int main() {
    int port = 1234;
    
    // Создание TCP-сокета
    int server_socket = socket(AF_INET, SOCK_STREAM, 0);

    if (server_socket == -1) {
        perror("socket");
        return -1;
    }
    
    // Установка SO_REUSEADDR (опционально)
    // const int enable = 1;
    // if (setsockopt(server_socket, SOL_SOCKET, SO_REUSEADDR, &enable, sizeof(int)) < 0) {
    //     perror("setsockopt(SO_REUSEADDR)");
    //     return -1;
    // }

    // Подключение сокета к адресу 0.0.0.0
    struct sockaddr_in server_address = {};
    server_address.sin_family = AF_INET;
    server_address.sin_addr.s_addr = INADDR_ANY;
    server_address.sin_port = htons(port);

    if (bind(server_socket, (struct sockaddr *) &server_address, sizeof(server_address)) == -1) {
        perror("bind");
        return -1;
    }

    // Подключение сокет к HTTP-порту (80)
    if (listen(server_socket, 64) == -1) {
        perror("listen");
        return -1;
    }

    // Обработка подключений к сокету
    while(true) {
        int connection = accept(server_socket, NULL, NULL);

        if(connection < 0) {
            perror("accept");
            close(server_socket);
            return -1;
        }

        // Отправка сообщения в сокет
        const char* message = 
            "HTTP/1.1 200 OK\r\n"
            "Content-Type: text/html\r\n"
            "\r\n"
            "<h1>Hello, World!</h1>";
        write(connection, message, strlen(message));

        // Закрытие соединение на запись со стороны сервера.
        // Браузер поймёт, что страница загружена и покажет её.
        shutdown(connection, SHUT_WR);

        // Чтение запроса (уже после отправки ответа ¯\_(ツ)_/¯)
        printf("Received request!\n");
        read_socket(connection);

        // Закрытие подключения
        close(connection);
    }
    
    // Закрытие самого сокета (сервера)
    close(server_socket);

    return 0;
}