
#include "transmission.h"

#define INTERVAL 5000

void computer1() {
    // char* message = "Hello, World!\n";
    char* message = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

    sleep(1);
    
    set_wire(true);
    small_pause(INTERVAL);

    for(int i = 0;; i++) {
        char c = message[i];

        for(int j = 0; j < __CHAR_BIT__; j++) {
            bool bit = c & (1 << j);
            set_wire(bit);
            small_pause(INTERVAL);
        }

        if(c == '\0') {
            break;
        }
    }
}