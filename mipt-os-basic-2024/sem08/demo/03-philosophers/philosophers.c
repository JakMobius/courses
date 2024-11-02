#include "philosophers.h"

void start_eating(philosopher_t *philosopher)
{
    if (philosopher->id % 2 == 0) {
        capture_right_fork(philosopher);
        capture_left_fork(philosopher);
    } else {
        // TODO: fix the deadlock
        capture_left_fork(philosopher);
        capture_right_fork(philosopher);
    }
}

void stop_eating(philosopher_t *philosopher)
{
    if (philosopher->id % 2 != 0) {
        release_left_fork(philosopher);
        release_right_fork(philosopher);
    } else {
        release_right_fork(philosopher);
        release_left_fork(philosopher);
    }
}