#include "philosophers.h"

void start_eating(philosopher_t *philosopher)
{
    // TODO: fix the deadlock
    capture_left_fork(philosopher);
    capture_right_fork(philosopher);
}

void stop_eating(philosopher_t *philosopher)
{
    release_left_fork(philosopher);
    release_right_fork(philosopher);
}