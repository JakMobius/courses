

#include <unistd.h>
#include <stdio.h>

int main(int sock) {
    int input[4] = {};

    read(STDIN_FILENO, input, sizeof(input));

    for(int i = 0; i < sizeof(input) / sizeof(*input); i++) {
        input[i] *= 2;
    }

    write(STDOUT_FILENO, input, sizeof(input));
}
