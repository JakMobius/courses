
#include <unistd.h>
#include <signal.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <sys/signalfd.h>

int main() {
    sigset_t mask = {};
    sigemptyset(&mask);
    sigaddset(&mask, SIGINT);

    sigprocmask(SIG_BLOCK, &mask, NULL);

    int sfd = signalfd(-1, &mask, 0);

    while (true) {
      struct signalfd_siginfo fdsi = {};
      ssize_t s = read(sfd, &fdsi, sizeof(fdsi));
      if (s != sizeof(fdsi)) return -1;

      if (fdsi.ssi_signo == SIGINT) printf("Got SIGINT\n");
    }
  }