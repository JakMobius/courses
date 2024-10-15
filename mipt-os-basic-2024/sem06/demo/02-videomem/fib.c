
#include <inttypes.h>
#include <unistd.h>
#include <stdlib.h>
#include <time.h>

void setStackColor(volatile int* ptr, int size, int color) {
    for(int i = 0; i < size; i++) {
        ptr[i] = color;
    }
}

int fibonacci(int n) {
    int stack_size = 8192;
    volatile int stackStuff[stack_size] = {};
    
    if (n <= 1) {
        return n;
    }

    setStackColor(stackStuff, stack_size, 0xFF777777);

    int result = fibonacci(n - 1);

    setStackColor(stackStuff, stack_size, 0xFFFFFFFF);

    result += fibonacci(n - 2);

    setStackColor(stackStuff, stack_size, 0xFF000000);

    return result;
}

void* fibMain(void* arg) {
    while (1) {
        fibonacci(40);
        sleep(1);
    }
}