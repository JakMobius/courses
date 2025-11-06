
#include <unistd.h>
#include <signal.h>

void handler(int signum) {
    char message[] = "You've pressed Ctrl+C!\n";
    write(STDOUT_FILENO, message, sizeof(message));
}

int main() {
    // Инициализируем sigaction
    struct sigaction act = {};
    act.sa_handler = handler;
    sigemptyset(&act.sa_mask);
    act.sa_flags = 0;

    // Устанавливаем обработчик на SIGINT
    sigaction(SIGINT, &act, NULL);

    while(1) sleep(1);
}