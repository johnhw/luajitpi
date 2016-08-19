#ifndef LDL_H
#define LDL_H
void *dlopen(const char *filename, int flag);
const char *dlerror(void);
void *dlsym(void *handle, const char *symbol);
void dlclose(void *handle);
#define RTLD_DEFAULT NULL
#define RTLD_LAZY       0x001
#define RTLD_NOW        0x002
#define RTLD_GLOBAL     0x100
#define RTLD_LOCAL      0x101
#endif
