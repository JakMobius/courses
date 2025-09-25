#include <sys/fcntl.h>
#include <dirent.h>
#include <stdio.h>


int main() {
    int fd = open("/", O_RDONLY, 0);
    struct dirent ent = {};
    while(getdents64(fd, &ent, sizeof(ent)) > 0) {
        printf("%s\n", ent.d_name);
#ifdef __APPLE__
        lseek(fd, ent.d_seekoff, SEEK_SET);
#else
        lseek(fd, ent.d_off, SEEK_SET);
#endif
    }
}