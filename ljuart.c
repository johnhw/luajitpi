
#include <stdio.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <string.h>
#include <stdlib.h>
#include "serial.h"
#include "mem.h"

 
void uart_putc ( unsigned int c )
{
    if(c==0x0A) uart_putc(0x0D);
    serial_write(c);
}

unsigned int uart_getc(void)
{
    return serial_read();
}

void enable_cache(void)
{
    start_l1cache();
}

void disable_cache(void)
{
    stop_l1cache();
}

void lsetfieldi (lua_State *L, const char *index, unsigned int value) {
      lua_pushstring(L, index);
      lua_pushnumber(L, value);
      lua_settable(L, -3);
    }
    
/* The boot script run on start up */
extern char _binary_lua_boot_lua_start;
extern char _binary_lua_boot_lua_end;

/* Reference to the zip file of files to be loaded at boot time */
extern char _binary_bootfiles_zip_start;
extern char _binary_bootfiles_zip_end;

/* Lua libraries opened directly */
extern int luaopen_lpeg(lua_State *L);

/* The initial lua state */
lua_State *boot_L;

extern unsigned mem_mmu_table[4096];
extern unsigned int heap_end;
extern void * __kernel_end;

void set_memory_table(void)
{
    lua_newtable(boot_L);
    lsetfieldi(boot_L, "kernel_start", MEM_KERNEL_START);
    lsetfieldi(boot_L, "stack_top", MEM_STACK_PTR);
    lsetfieldi(boot_L, "heap_start", MEM_HEAP_START);
    lsetfieldi(boot_L, "gpio_base", MEM_GPIO_BASE);
    lsetfieldi(boot_L, "mmu_table_ptr", (uint32_t) mem_mmu_table);
    lsetfieldi(boot_L, "mmu_table_size", MEM_MMU_TABLE_SIZE);
    lsetfieldi(boot_L, "heap_ptr", (uint32_t) heap_end);     
    /* Read from the symbol in the linker script */
    lsetfieldi(boot_L, "kernel_end", (uint32_t) __kernel_end);     
   lua_setglobal(boot_L, "memmap");
}    

//------------------------------------------------------------------------
int notmain ( unsigned int earlypc )
{   
    
    uart_putc('*');
    uart_putc('-');
    uart_putc(')');
    uart_putc('\n');
               
    serial_init();
    
    while(1)
    {
        printf("[[ LuaJIT-2.0.4 -- Raspberry Pi -- Bare Metal OS ]]\n");
        printf("\n\n");

        boot_L = luaL_newstate();
        luaL_openlibs(boot_L);
        luaopen_lpeg(boot_L);
        printf("Opened lua...\n");
        set_memory_table();
        
        /* Push the boot code zip file pointer onto the stack */        
        lua_pushnumber(boot_L, (uint32_t)(&_binary_bootfiles_zip_start));
        lua_setglobal(boot_L, "bootzip_ptr");
        lua_pushnumber(boot_L, &_binary_bootfiles_zip_end-&_binary_bootfiles_zip_start);
        lua_setglobal(boot_L, "bootzip_len");
        
        printf("Boot starting...\n");        
        int error = luaL_loadbuffer(boot_L, &_binary_lua_boot_lua_start, (&_binary_lua_boot_lua_end)-(&_binary_lua_boot_lua_start), "boot") || lua_pcall(boot_L,0,0,0);
        if(error)                
        {
            printf("Boot script error: %s\n", lua_tostring(boot_L,-1));
            lua_pop(boot_L,1);                    
        }
        lua_close(boot_L);
    }
   
    // if we get here, something's really gone wrong!
    return 0;
}
