
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

int main() {
    int pipefd[2] = {};
    pipe(pipefd);

    if(fork() != 0) {
        // Если мы - процесс-родитель, то кричим в трубу
        write(pipefd[1], "Friendly message\n", 18);
        wait(NULL);
    } else {
        // Если мы - процесс-ребёнок, то слушаем трубу:
        char buffer[32] = {};
        read(pipefd[0], buffer, 31);
        printf("Received %s", buffer); // "Received Friendly message\n"
    }

    close(pipefd[0]); // Дескрипторы каналов тоже нужно закрывать
    close(pipefd[1]);
}