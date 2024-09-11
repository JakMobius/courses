#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>

#define LOCK_FILE "lockfile.lock"

int main() {
    int lock_fd;
    struct flock lock;

    // Открываем lock-файл
    lock_fd = open(LOCK_FILE, O_CREAT | O_RDWR, 0666);
    if (lock_fd == -1) {
        perror("open");
        exit(EXIT_FAILURE);
    }

    // Настраиваем структуру lock
    lock.l_type = F_WRLCK;    // Блокировка на запись
    lock.l_start = 0;         // Начало блокировки
    lock.l_whence = SEEK_SET; // Относительно начала файла
    lock.l_len = 0;           // Блокировка всего файла

    // Пытаемся захватить lock-файл
    if (fcntl(lock_fd, F_SETLKW, &lock) == -1) {
        perror("fcntl");
        close(lock_fd);
        exit(EXIT_FAILURE);
    }
    
    while(true) {
        char* response = NULL;
        size_t n = 0;
        printf("What to do? >");
        getline((char**) &response, &n, stdin);

        if(strcmp(response, "exit\n") == 0) {
            free(response);
            break;
        } else if(strcmp(response, "hack pentagon\n") == 0) {
            printf("Hacking pentagon\n");
            sleep(3);
            printf("30%\n");
            sleep(3);
            printf("60%\n");
            sleep(3);
            printf("100%\n");
            printf("pentagon hacked\n");
        } else {
            printf("Sorry, didn't understand\n");
        }
        
        free(response);
    }


    // Освобождаем lock-файл
    lock.l_type = F_UNLCK;  // Снимаем блокировку
    if (fcntl(lock_fd, F_SETLKW, &lock) == -1) {
        perror("fcntl");
        close(lock_fd);
        exit(EXIT_FAILURE);
    }

    // Закрываем lock-файл
    close(lock_fd);

    return 0;
}
