
//-------------------------------------------------------------------------
//-------------------------------------------------------------------------

#include <stdio.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <string.h>
#include <stdlib.h>
#include <libtcc.h>

extern void PUT32 ( unsigned int, unsigned int );
extern unsigned int GET32 ( unsigned int );
extern void dummy ( unsigned int );

#define GPFSEL1 0x20200004
#define GPSET0  0x2020001C
#define GPCLR0  0x20200028
#define GPPUD       0x20200094
#define GPPUDCLK0   0x20200098

#define AUX_ENABLES     0x20215004
#define AUX_MU_IO_REG   0x20215040
#define AUX_MU_IER_REG  0x20215044
#define AUX_MU_IIR_REG  0x20215048
#define AUX_MU_LCR_REG  0x2021504C
#define AUX_MU_MCR_REG  0x20215050
#define AUX_MU_LSR_REG  0x20215054
#define AUX_MU_MSR_REG  0x20215058
#define AUX_MU_SCRATCH  0x2021505C
#define AUX_MU_CNTL_REG 0x20215060
#define AUX_MU_STAT_REG 0x20215064
#define AUX_MU_BAUD_REG 0x20215068

//GPIO14  TXD0 and TXD1
//GPIO15  RXD0 and RXD1
//alt function 5 for uart1
//alt function 0 for uart0

//((250,000,000/115200)/8)-1 = 270
//------------------------------------------------------------------------
void uart_putc ( unsigned int c )
{
    if(c==0x0A) uart_putc(0x0D);
    while(1)
    {
        if(GET32(AUX_MU_LSR_REG)&0x20) break;
    }
    PUT32(AUX_MU_IO_REG,c);
}
//------------------------------------------------------------------------
void hexstrings ( unsigned int d )
{
    //unsigned int ra;
    unsigned int rb;
    unsigned int rc;

    rb=32;
    while(1)
    {
        rb-=4;
        rc=(d>>rb)&0xF;
        if(rc>9) rc+=0x37; else rc+=0x30;
        uart_putc(rc);
        if(rb==0) break;
    }
    uart_putc(0x20);
}

unsigned int uart_getc(void)
{
    while(1)
        {
            if(GET32(AUX_MU_LSR_REG)&0x01) break;
        }
    unsigned int ra=GET32(AUX_MU_IO_REG);
    return ra;
}


//------------------------------------------------------------------------
void hexstring ( unsigned int d )
{
    hexstrings(d);
    uart_putc(0x0D);
    uart_putc(0x0A);
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

/*
void test_tcc(void)
{
    int dood = 0;
    int (*func)(int *);
    static char test [] =
        "int set_dood(int *n)\n"
        "{\n *n = 0x000d00d;"
        "}\n";
        
    TCCState *tcc = tcc_new();
    printf("TCC state created\n");
    
    if(!tcc)
    {
        printf("TCC state not created :(\n");
        return;
    }
    // disable standard libraries
    if(!tcc_set_options(tcc, "-nostdlib"))
    {
        printf("TCC set notstdlib failed :(\n");
        return;
    }

    
    tcc_set_output_type(tcc, TCC_OUTPUT_MEMORY);
    
    if(tcc_compile_string(tcc, test)==-1)
    {
        printf("TCC compile failed :(\n");
        return;
    }
    
    if(tcc_relocate(tcc, TCC_RELOCATE_AUTO)<0)
    {
        printf("TCC relocate failed :(\n");
        return;
    }
    
    func = tcc_get_symbol(tcc, "set_dood");
    if(!func)
    {
        printf("TCC get symbol failed :(\n");
        return;
    }
    
    func(&dood);
    printf("Output should be 0x0000D00D: 0x%08X\n",dood);
    
    tcc_delete(tcc);
    printf("TCC state deleted\n");

}
*/

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

        

#define LUA_REGISTER(X) setfieldi(L, #X, (unsigned int)X)  
#define LUA_REGISTER_SPEC(X,Y) setspec(L, #X, (unsigned int)X, Y)  
  
//------------------------------------------------------------------------
int notmain ( unsigned int earlypc )
{
    unsigned int ra;
    int error;
    
    PUT32(AUX_ENABLES,1);
    PUT32(AUX_MU_IER_REG,0);
    PUT32(AUX_MU_CNTL_REG,0);
    PUT32(AUX_MU_LCR_REG,3);
    PUT32(AUX_MU_MCR_REG,0);
    PUT32(AUX_MU_IER_REG,0);
    PUT32(AUX_MU_IIR_REG,0xC6);
    PUT32(AUX_MU_BAUD_REG,270);

    ra=GET32(GPFSEL1);
    ra&=~(7<<12); //gpio14
    ra|=2<<12;    //alt5
    ra&=~(7<<15); //gpio15
    ra|=2<<15;    //alt5
    PUT32(GPFSEL1,ra);

    PUT32(GPPUD,0);
    for(ra=0;ra<150;ra++) dummy(ra);
    PUT32(GPPUDCLK0,(1<<14)|(1<<15));
    for(ra=0;ra<150;ra++) dummy(ra);
    PUT32(GPPUDCLK0,0);

    PUT32(AUX_MU_CNTL_REG,3);

    hexstring(0x12345678);
    hexstring(earlypc);

    printf("LuaJIT-Pi\n");
    printf("0x%08X\n",earlypc);
    printf("%u\n",earlypc);

    printf("Checking TCC...\n");
    test_tcc();
    
    printf("Complete...\n");
    
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);
    
    /* register c functions */
    lua_newtable(L);
    LUA_REGISTER(uart_getc);
    LUA_REGISTER(uart_putc);
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
     
        error = luaL_loadbuffer(L, codeptr, strlen(codeptr), "line") || lua_pcall(L,0,0,0);
        if(error)                
        {
            printf("%s\n", lua_tostring(L,-1));
            lua_pop(L,1);                    
        }
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
