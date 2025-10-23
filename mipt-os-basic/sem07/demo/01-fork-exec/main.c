 
 #include <unistd.h>
 #include <sys/wait.h>
 
int main() {
    if (fork() == 0) {
        execl("/bin/bash", NULL);
    } else {

        

        wait(NULL);
    }
    return 0;
}