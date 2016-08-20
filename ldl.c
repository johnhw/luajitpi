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

static char error_bad_symtable[] = "Bad symbol table: sym_table not found.";
static char error_bad_symbol[] = "Symbol not found in sym_table.";
static char error_not_open[] = "No library open.";

unsigned int lgetfield (lua_State *L, const char *key) {
      int result;
      lua_pushstring(L, key);
      lua_gettable(L, -2);  
      if (!lua_isnumber(L, -1))
        return 0;
      result = (unsigned int)lua_tonumber(L, -1);
      lua_pop(L, 1);  
      return result;
}

void lsetfieldi (lua_State *L, const char *index, unsigned int value) {
      lua_pushstring(L, index);
      lua_pushnumber(L, value);
      lua_settable(L, -3);
    }
    

extern lua_State *boot_L;

void *dlopen(const char *filename, int flag)
{
    /* NB: flags are ignored */
    last_error = NULL;
    return (void *)boot_L;
}

const char *dlerror(void)
{    
    return last_error;
}

void *dlsym(void *handle, const char *symbol)
{
    if(handle==RTLD_DEFAULT)
    {
        handle = boot_L;
    }
    
    lua_State *L = (lua_State *)handle;
    
    if(!L)
    {
        last_error = error_not_open;
        return NULL;
    }
    lua_getglobal(L, "sym_table");
    if(!lua_istable(L, -1))
    {
        last_error = error_bad_symtable;
        return NULL;
    }
    
    unsigned int addr = lgetfield(L, symbol);
    if(!addr)
    {
        last_error = error_bad_symbol;
        return NULL;
    }
    
    return (void *)addr;    
}

void dlclose(void *handle)
{
}
