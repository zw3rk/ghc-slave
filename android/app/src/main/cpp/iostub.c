#include <stdio.h>
#include <dlfcn.h>
#include <sys/stat.h>

FILE* (*my_fopen)(const char *filename, const char* mode);
int (*my_fstat)(int fildes, struct stat *buf);
