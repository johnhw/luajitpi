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
      lua_gettable(L, -2);  /* get background[key] */
      if (!lua_isnumber(L, -1))
        return 0;
      result = (unsigned int)lua_tonumber(L, -1);
      lua_pop(L, 1);  /* remove number */
      return result;
}

void lsetfieldi (lua_State *L, const char *index, unsigned int value) {
      lua_pushstring(L, index);
      lua_pushnumber(L, value);
      lua_settable(L, -3);
    }
    
/* References to the blocks of text the linker will include */
/* The function table map (readelf -s luajit.elf | grep FUNC) */
extern char _binary_luajit_fmap_start;
extern char _binary_luajit_fmap_end;    

/* The Lua that parses the function table and writes the sym_table object */
extern char _binary_create_sym_lua_start;
extern char _binary_create_sym_lua_end;    

static lua_State *static_L = NULL;

void *dlopen(const char *filename, int flag)
{
    /* NB: flags are ignored */
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);
    last_error = NULL;
    
    /* Push the function table string */
    lua_pushlstring(L, &_binary_luajit_fmap_start, (&_binary_luajit_fmap_end)-(&_binary_luajit_fmap_start));
    lua_setglobal(L, "fmap_string");
    
            
    int error = luaL_loadbuffer(L, &_binary_create_sym_lua_start, (&_binary_create_sym_lua_end)-(&_binary_create_sym_lua_start), "create_sym_table") || lua_pcall(L,0,0,0);
    if(error)                
    {
        last_error = lua_tostring(L,-1);        
        lua_pop(L,1);                    
        return NULL;
    }    
    static_L = L;
    return (void *)L;
}

const char *dlerror(void)
{    
    return last_error;
}

void *dlsym(void *handle, const char *symbol)
{
    if(handle==RTLD_DEFAULT)
    {
        handle = static_L;
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
    lua_State *L = (lua_State *)handle;
    lua_close(L);
    static_L = NULL;   
}