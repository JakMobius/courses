#pragma once

#include <stdbool.h>
#include <stdio.h>
#include <unistd.h>
#include <stdatomic.h>
#include <sys/time.h>

extern _Atomic bool wire;

void computer1();
void computer2();
void small_pause(int nanos);
void set_wire(bool value);
bool read_wire();