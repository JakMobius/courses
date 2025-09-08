
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

char global_buffer[128] = {};

int main() {
    scanf("%127s", global_buffer);
    
    while(1) {
        sleep(1);
        printf("%016llx: %s\n", (uint64_t)global_buffer, global_buffer);
    }
    
    return 0;
}