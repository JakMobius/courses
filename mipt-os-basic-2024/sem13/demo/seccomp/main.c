
# include <stdio.h>
# include <unistd.h>
# include <linux/seccomp.h>
# include <sys/prctl.h>
# include <fcntl.h>

int main() {
    prctl(PR_SET_SECCOMP, SECCOMP_MODE_STRICT);

    char message1[] = "[ write() ] Try to write to STDOUT!\n";
    write(STDOUT_FILENO, message1, sizeof(message1));

    // char message2[] = "[ prctl() ] Try to disable seccomp!\n";
    // write(STDOUT_FILENO, message2, sizeof(message2));
    // prctl(PR_SET_SECCOMP, SECCOMP_MODE_DISABLED);

    // char message3[] = "[ open()  ] Try to open a file!\n";
    // write(STDOUT_FILENO, message3, sizeof(message3));
    // int file = open("Makefile", O_RDONLY);
    // char buffer[1024] = {};
    // int len = read(file, buffer, sizeof(buffer) - 1);
    // write(STDOUT_FILENO, buffer, len);
}