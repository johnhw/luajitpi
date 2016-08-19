
//-------------------------------------------------------------------------
//-------------------------------------------------------------------------

#include <stdio.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <string.h>
#include <stdlib.h>
#include <libtcc.h>
#include "serial.h"


void uart_putc ( unsigned int c )
{
    if(c==0x0A) uart_putc(0x0D);
    serial_write(c);
}

unsigned int uart_getc(void)
{
    return serial_read();
}


void *compile_tcc(char *s)
{
    TCCState *tcc = tcc_new();
    
    if(!tcc)
    {
        printf("TCC state not created :(\n");
        return NULL;
    }
    
    // disable standard libraries
    if(!tcc_set_options(tcc, "-nostdlib"))
    {
        printf("TCC set nostdlib failed :(\n");
        return NULL;
    }
    
    tcc_set_output_type(tcc, TCC_OUTPUT_MEMORY);
    
    if(tcc_compile_string(tcc, s)==-1)
    {
        printf("TCC compile failed :(\n");
        return NULL;
    }
    
    if(tcc_relocate(tcc, TCC_RELOCATE_AUTO)<0)
    {
        printf("TCC relocate failed :(\n");
        return NULL;
    }
    
    return (void *) tcc;
 
}

void *getsymbol_tcc(void *tcc, char *symbol)
{
    
    void *func = (void*)(tcc_get_symbol((TCCState *)tcc, symbol));
    if(!func)
    {
        printf("TCC get symbol failed :(\n");
        return NULL;
    }
    return func;
}    

void delete_tcc(void *tcc)
{
    tcc_delete((TCCState *)tcc);
}

extern char _binary_lua_boot_lua_start;
extern char _binary_lua_boot_lua_end;
extern int luaopen_lpeg(lua_State *L);

char *fallback_repl = "print('BOOT ERROR; FALLBACK REPL\n\n'); function error(msg); print(msg); end; while true; line = io.read(); f,err = loadstring(line); if f then xpcall(f,error) end; end;" 


//------------------------------------------------------------------------
int notmain ( unsigned int earlypc )
{    
    serial_init();

    printf("[[ LuaJIT-2.0.4 -- Raspberry Pi -- Bare Metal OS\n");
    printf("\n\n");

    lua_State *L = luaL_newstate();
    luaL_openlibs(L);
    luaopen_lpeg(L);
    printf("Lua state opened.\n");
    
    int error = luaL_loadbuffer(L, &_binary_lua_boot_lua_start, (&_binary_lua_boot_lua_end)-(&_binary_lua_boot_lua_start), "boot") || lua_pcall(L,0,0,0);
    if(error)                
    {
        printf("Boot script error: %s\n", lua_tostring(L,-1));
        lua_pop(L,1);                    
    }
   
   // something went wrong: use the fallback REPL
   int error = luaL_loadbuffer(L, fallback_repl, strlen(fallback_repl), "fallback") || lua_pcall(L,0,0,0);
    
}
//-------------------------------------------------------------------------
//-------------------------------------------------------------------------


//-------------------------------------------------------------------------
//
// Copyright (c) 2012 David Welch dwelch@dwelch.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//-------------------------------------------------------------------------
