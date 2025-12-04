
#include "transmission.h"

_Atomic bool wire;

void set_wire(bool value) {
    atomic_store(&wire, value);
}

bool read_wire() {
    return atomic_load(&wire);
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