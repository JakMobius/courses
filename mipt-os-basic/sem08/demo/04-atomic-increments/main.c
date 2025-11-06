#include <stdio.h>
#include <pthread.h>
#include <stdatomic.h>
 
_Atomic int atomic_counter;
int counter;
 
void* job(void* argument)
{
    for(int n = 0; n < 1000; ++n) {
        atomic_fetch_add_explicit(&atomic_counter, 1, memory_order_relaxed); // atomic
        counter++; // undefined behavior, in practice some updates missed
    }
    return 0;
}
 
int main(void)
{
    pthread_t threads[10];
    for(int n = 0; n < 10; ++n)
        pthread_create(&threads[n], NULL, job, NULL);
    for(int n = 0; n < 10; ++n)
        pthread_join(threads[n], NULL);
 
    printf("The atomic counter is %u\n", atomic_counter);
    printf("The non-atomic counter is %u\n", counter);
}