
#include <stdio.h>
#include <inttypes.h>

uint64_t asm_func();

void print_register(uint64_t reg) {
    printf("rdi = %llu\n", reg);
}

int main() {
    uint64_t return_value = asm_func();
    printf("asm_func returned %llu!", return_value);
}