
#include "transmission.h"

#define INTERVAL 5000

static bool clock_phase = false;

void clock_wait() {
    while(read_wire2() == clock_phase);
    clock_phase = !clock_phase;
}

void computer2() {

    clock_wait();
    small_pause(INTERVAL / 2);

    for(int i = 0;; i++) {
        char c = '\0';

        for(int j = 0; j < __CHAR_BIT__; j++) {
            bool bit = read_wire1();
            c |= bit << j;
            small_pause(INTERVAL);
        }

        if(c == '\0') {
            break;
        }

        write(STDOUT_FILENO, &c, 1);

        clock_wait();
    }
}