
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>
#include <stddef.h>
#include <fcntl.h>
#include <limits.h>
#include <linux/audit.h>
#include <linux/filter.h>
#include <linux/seccomp.h>
#include <sys/prctl.h>
#include <sys/socket.h>
#include <sys/syscall.h>

int install_filter() {
	if (prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0)) {
        perror("prctl");
        exit(EXIT_FAILURE);
    }

    struct sock_filter filter[] = {
        BPF_STMT(BPF_LD | BPF_W | BPF_ABS, offsetof(struct seccomp_data, nr)),
        
#if 1
        BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, SYS_execve, 17, 0),
        BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, SYS_exit, 16, 0),
        BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, SYS_exit_group, 15, 0),
        BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, SYS_openat, 14, 0),
        BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, SYS_close, 13, 0),
        BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, SYS_newfstatat, 12, 0),
        BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, SYS_faccessat, 11, 0),
        BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, SYS_munmap, 10, 0),
        BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, SYS_prlimit64, 9, 0),
        BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, SYS_rseq, 8, 0),
        BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, SYS_set_robust_list, 7, 0),
        BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, SYS_set_tid_address, 6, 0),
        BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, SYS_mprotect, 5, 0),
        BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, SYS_mmap, 4, 0),
        BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, SYS_brk, 3, 0),
#endif

        BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, SYS_read, 2, 0),
        BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, SYS_write, 1, 0),

        BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_KILL_PROCESS),
        BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ALLOW)
    };

    struct sock_fprog prog = {
        .len = sizeof(filter) / sizeof(filter[0]),
        .filter = filter,
    };

	if (prctl(PR_SET_SECCOMP, SECCOMP_MODE_FILTER, &prog)) {
		perror("prctl(seccomp)");
		return 1;
	}
	return 0;
}

int main() {
    int pipes[2][2] = {{-1, -1}, {-1, -1}};
    pipe(pipes[0]);
    pipe(pipes[1]);

    int pid = fork();

    if(pid == 0) {
        // Child: execute unsafe code

        close(pipes[0][0]);
        close(pipes[1][1]);

        // dup pipes to STDIN and STDOUT
        dup2(pipes[1][0], STDIN_FILENO);
        dup2(pipes[0][1], STDOUT_FILENO);

        close(pipes[1][0]);
        close(pipes[0][1]);

        install_filter();
        execle("./service", NULL);
    } else {
        // Parent: send the task and read the child response
        close(pipes[0][1]);
        close(pipes[1][0]);

        int request[4] = {1, 2, 3, 4};
        write(pipes[1][1], request, sizeof(request));
        read(pipes[0][0], request, sizeof(request));

        for(int i = 0; i < sizeof(request) / sizeof(*request); i++) {
            printf("[%d] = %d\n", i, request[i]);
        }

        close(pipes[0][0]);
        close(pipes[1][1]);
    }
}