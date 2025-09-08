
#include "transmission.h"

#define INTERVAL 1000

void computer2() {
    while(!read_wire());
    small_pause(INTERVAL + INTERVAL / 10);
    
    for(int i = 0;; i++) {
        char c = '\0';

        for(int j = 0; j < __CHAR_BIT__; j++) {
            bool bit = read_wire();
            c |= bit << j;
            small_pause(INTERVAL);
        }

        if(c == '\0') {
            break;
        }

        // printf("%c", c);
        write(STDOUT_FILENO, &c, 1);
    }
}