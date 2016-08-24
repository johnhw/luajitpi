#include "ldl.h"

#include <stdio.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <string.h>
#include <stdlib.h>

/* Simple stubs for emulating dynamic library support.
   This enables the use of ffi.open() in LuaJIT.
   
   Uses LuaJIT itself to store and manage the symbol map lookup.
   
*/   

static char *last_error;
static char error_bad_symbol[] = "Symbol not found in sym_table.";

typedef struct ldl_sym 
{
    unsigned int addr;
    char *sym;
} ldl_sym;

extern const ldl_sym _all_symbols [];

static char *dummy="none";    
void *dlopen(const char *filename, int flag)
{
    /* NB: flags are ignored */
    last_error = NULL;
    /* can't return null */
    return (void*)dummy;
}

const char *dlerror(void)
{    
    return last_error;
}

void *dlsym(void *handle, const char *symbol)
{
    char *sym;
    unsigned int addr;
    int i=0;
    do
    {
        addr = _all_symbols[i].addr;
        sym = _all_symbols[i].sym;
        if(!strcmp(sym, symbol))        
        {
            return (void *)addr;    
        }
        i++;
    } while(sym!=NULL);
    /* no match in the symbol table */
    last_error = error_bad_symbol;
    return NULL;
}

void dlclose(void *handle)
{
}
