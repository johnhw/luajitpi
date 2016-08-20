
//-------------------------------------------------------------------------
//-------------------------------------------------------------------------

#include <stdio.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <string.h>
#include <stdlib.h>
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

/* The boot script run on start up */
extern char _binary_lua_boot_lua_start;
extern char _binary_lua_boot_lua_end;

/* Reference to the zip file of files to be loaded at boot time */
extern char _binary_bootfiles_zip_start;
extern char _binary_bootfiles_zip_end;

/* References to the blocks of text the linker will include */
/* The function table map (readelf -s luajit.elf | grep FUNC) */
extern char _binary_luajit_fmap_start;
extern char _binary_luajit_fmap_end;    


extern int luaopen_lpeg(lua_State *L);

/* Very simple fallback REPL if the boot script somehow doesn't 
   start it's own REPL successfully */
char *fallback_repl = 
"function error(msg)\n"
"   print(msg)\n"
"end\n"
"while true do\n"
"   line = io.read()\n"
"   f,err = loadstring(line)\n"
"   if f then \n"
"       xpcall(f,error)\n"
"   end\n"
"end\n";

lua_State *boot_L;



//------------------------------------------------------------------------
int notmain ( unsigned int earlypc )
{    
    serial_init();

    printf("[[ LuaJIT-2.0.4 -- Raspberry Pi -- Bare Metal OS ]]\n");
    printf("\n\n");

    boot_L = luaL_newstate();
    luaL_openlibs(boot_L);
    luaopen_lpeg(boot_L);
    printf("Lua state opened.\n");
    
    // Push the boot code zip file onto the stack
    
    lua_pushnumber(boot_L, (uint32_t)(&_binary_bootfiles_zip_start));
    lua_setglobal(boot_L, "bootzip_ptr");
    lua_pushnumber(boot_L, &_binary_bootfiles_zip_end-&_binary_bootfiles_zip_start);
    lua_setglobal(boot_L, "bootzip_len");
    /* Push the function table string */
    lua_pushlstring(boot_L, &_binary_luajit_fmap_start, (&_binary_luajit_fmap_end)-(&_binary_luajit_fmap_start));
    lua_setglobal(boot_L, "fmap_string");
    
    
    int error = luaL_loadbuffer(boot_L, &_binary_lua_boot_lua_start, (&_binary_lua_boot_lua_end)-(&_binary_lua_boot_lua_start), "boot") || lua_pcall(boot_L,0,0,0);
    if(error)                
    {
        printf("Boot script error: %s\n", lua_tostring(boot_L,-1));
        lua_pop(boot_L,1);                    
    }
   
    // something went wrong: use the fallback REPL
    error = luaL_loadbuffer(boot_L, fallback_repl, strlen(fallback_repl), "fallback") || lua_pcall(boot_L,0,0,0);
    if(error)                
    {
        printf("Fallback script error: %s\n", lua_tostring(boot_L,-1));
        lua_pop(boot_L,1);                    
    }
    
    // if we get here, something's really gone wrong!
    return 0;
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
