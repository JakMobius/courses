#pragma once

#include <stdbool.h>
#include <stdio.h>
#include <unistd.h>
#include <stdatomic.h>
#include <sys/time.h>

extern _Atomic bool wire1;
extern _Atomic bool wire2;

void computer1();
void computer2();
void small_pause(int nanos);
void set_wire1(bool value);
bool read_wire1();
void set_wire2(bool value);
bool read_wire2();