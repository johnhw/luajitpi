/* Copyright (C) 2013 by John Cronin <jncronin@tysos.org>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:

 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

 
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include "multiboot.h"
#include <string.h>

#include <libtcc.h>


struct multiboot_arm_functions *fns;


void uart_putc ( unsigned int c )
{
    
    if(c==0x0A) uart_putc(0x0D);
    uart_putc(c);
}

unsigned int uart_getc(void)
{
    return fns->uart_getc();
}

char codebuf[8192];
char linebuf[256];
char *lineptr = linebuf;
int linepos = 0;
int linelen = 0;

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

void test_tcc(void)
{
    int dood = 0;
    int (*func)(int *);
    static char test [] =
        "int set_dood(int *n)\n"
        "{\n *n = 0x000d00d;"
        "}\n";
        
    TCCState *tcc = compile_tcc(test);
    
    func = getsymbol_tcc(tcc, "set_dood");
    
    func(&dood);
    printf("Output should be 0x0000D00D: 0x%08X\n",dood);
    
    delete_tcc(tcc);
}

/*
 * Single-character "cooked" input (unbuffered)
 */
static int
_getch()
{
    int c;

    c = uart_getc();
    if (c == '\r') {
        c = '\n';
    }
    return c;
}

/*
 * Traditional single-character input (buffered)
 */
int
getch()
{
    char* editline();

    while (linepos >= linelen) {
        editline();
    }
    return linebuf[linepos++];
}

/*
 * Get single line of edited input
 */
char*
editline()
{
    int c;

    linelen = 0;  // reset write position
    while (linelen < (sizeof(linebuf) - 1)) {
        c = _getch();
        if (c == '\b') {
            if (--linelen < 0) {
                linelen = 0;
                continue;  // no echo
            }
        } else {
            linebuf[linelen++] = c;
        }
        uart_putc(c);  // echo input
        if (c == '\n') {
            break;  // end-of-line
        }
    }
    linebuf[linelen] = '\0';  // ensure NUL termination
    linepos = 0;  // reset read position
    return linebuf;
}

void setfieldi (lua_State *L, const char *index, unsigned int value) {
      lua_pushstring(L, index);
      lua_pushnumber(L, value);
      lua_settable(L, -3);
    }
    

void setfields (lua_State *L, const char *index, const char* value) {
      lua_pushstring(L, index);
      lua_pushstring(L, value);
      lua_settable(L, -3);
    }

void setspec(lua_State *L, const char *index, unsigned int value, const char *spec) {
      lua_pushstring(L, index);
      lua_newtable(L);
      setfieldi(L, "ptr", value);
      setfields(L, "spec", spec);
      lua_settable(L, -3);
    }
    
int lua_execute(lua_State *L, char *s)
{
    int error = luaL_loadbuffer(L, s, strlen(s), "line") || lua_pcall(L,0,0,0);
    if(error)                
    {
        printf("%s\n", lua_tostring(L,-1));
        lua_pop(L,1);                    
    }
    return error;
}


void test_lua(lua_State *L)
{
    lua_execute(L, "print('Hello from Lua')");
}
        
#define LUA_REGISTER(X) setfieldi(L, #X, (unsigned int)X)  
#define LUA_REGISTER_SPEC(X,Y) setspec(L, #X, (unsigned int)X, Y)  
  
//------------------------------------------------------------------------
int notmain ( unsigned int earlypc )
{
    //unsigned int ra;
  
    printf("----\n");
    printf("LuaJIT-Pi\n");
    printf("0x%08X\n",earlypc);
    
    printf("Checking TCC...\n");
    test_tcc();
    
    printf("Complete.\n");
    
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);
    
    printf("Testing Lua...\n");
    test_lua(L);
    printf("Complete.\n");
    
    /* register c functions */
    lua_newtable(L);
    LUA_REGISTER(uart_getc);
    LUA_REGISTER(uart_putc);
    LUA_REGISTER(compile_tcc);
    LUA_REGISTER(getsymbol_tcc);
    LUA_REGISTER(delete_tcc);
    
    lua_setglobal(L, "cfuncs");
    
    /* register c functions, with their typespec */
    lua_newtable(L);
    LUA_REGISTER_SPEC(uart_getc, "unsigned int uart_getc(void)");
    LUA_REGISTER_SPEC(uart_putc, "void uart_putc(unsigned int)");
    lua_setglobal(L, "cfunc_specs");
    
    char *codeptr = codebuf;
    *codeptr='\0';
           
    while(1)
    {
        char *line = editline();
        if(line[0]=='-' && line[1]=='-' && line[2]=='-')
        {
            lua_execute(L, codebuf);
            codeptr = codebuf;
            *codeptr='\0';
        }
        else
        {
            strcat(codeptr, line);
        }        
    }
    return(0);
}



void kmain(uint32_t magic, multiboot_header_t *mbd, uint32_t m_type,
		struct multiboot_arm_functions *funcs)
{
	funcs->clear();
	funcs->printf("Welcome to the test kernel\n");
	funcs->printf("Multiboot magic: %x\n", magic);
	funcs->printf("Running on machine type: %x\n", m_type);
	fns = funcs;
    notmain(0);
}

