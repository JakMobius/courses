
#include <stdio.h>
#include <inttypes.h>

uint64_t asm_func(uint64_t);

void print_register(uint64_t arg) {
    printf("arg = %llu\n", arg);
}

int main() {
    uint64_t return_value = asm_func(10);
    printf("asm_func returned %llu!\n", return_value);

    return 0;
}