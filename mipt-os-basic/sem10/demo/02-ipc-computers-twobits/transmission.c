
#include "transmission.h"

_Atomic bool wire1;
_Atomic bool wire2;

void set_wire1(bool value) {
    atomic_store(&wire1, value);
}

bool read_wire1() {
    return atomic_load(&wire1);
}

void set_wire2(bool value) {
    atomic_store(&wire2, value);
}

bool read_wire2() {
    return atomic_load(&wire2);
}

void small_pause(int target_nanos) {
    struct timeval start, now = {};
    gettimeofday(&start, NULL);

    while(true) {
        gettimeofday(&now, NULL);
        int nanos = (now.tv_usec + 1000000 - start.tv_usec) % 1000000;
        if(nanos > target_nanos) {
            break;
        }
    }
}