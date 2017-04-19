#include <stdio.h>
#include <unistd.h>
#include <stdbool.h>

extern void startSlave(bool verbose, int port, const char * docroot);

void __do(void) {
  startSlave(1, 0, NULL);
}
