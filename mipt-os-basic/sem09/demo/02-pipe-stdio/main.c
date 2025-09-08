
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

int main()
{
    int pipefd[2] = {};
    pipe(pipefd);

    if (fork() != 0)
    {                                   // Если мы - процесс-родитель:
        dup2(pipefd[1], STDOUT_FILENO); // - Подключаем STDOUT к началу канала;
        printf("FriendlyMessage\n");   // - Пишем в STDOUT (канал);
        fflush(stdout);
        wait(NULL);                     // - Ждем ребёнка;
    }
    else
    {                                  // Если мы - процесс-ребёнок:
        dup2(pipefd[0], STDIN_FILENO); // - Подключаем STDIN к концу канала;
        char buffer[32] = {};          //
        scanf("%31s", buffer);         // - Читаем STDIN (канал);
        printf("Received %s", buffer); // - "Received Friendly message\n";
    }

    close(pipefd[0]); // Дескрипторы каналов тоже нужно закрывать
    close(pipefd[1]);
}