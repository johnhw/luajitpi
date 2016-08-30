
#include <stdio.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <string.h>
#include <stdlib.h>
#include "mem.h"
#include "miniz/miniz.c"
#include "rboot/uart.h"

void lsetfieldi (lua_State *L, const char *index, unsigned int value) {
      lua_pushstring(L, index);
      lua_pushnumber(L, value);
      lua_settable(L, -3);
    }
    
/* Reference to the zip file of files to be loaded at boot time */
extern char _binary_bootfiles_zip_start;
extern char _binary_bootfiles_zip_end;

/* The initial lua state */
lua_State *boot_L;

extern unsigned mem_mmu_table[4096];
extern unsigned int heap_end;
extern void * __kernel_end;
extern struct vector_table arm_exc_table;

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
    lsetfieldi(boot_L, "exc_table", (uint32_t) &arm_exc_table);
    /* Read from the symbol in the linker script */
    lsetfieldi(boot_L, "kernel_end", (uint32_t) __kernel_end);     
    lua_setglobal(boot_L, "memmap");
    
}    

//------------------------------------------------------------------------
int notmain ( unsigned int earlypc )
{   
   
    uart_init();
    
    while(1)
    {
        printf("[[ LuaJIT-2.0.4 -- Raspberry Pi -- Bare Metal OS ]]\n");
        printf("\n\n");

        boot_L = luaL_newstate();
        luaL_openlibs(boot_L);
       
        printf("Opened Lua...\n");
        set_memory_table();
        
        mz_zip_archive bootzip = {0};
        size_t boot_size = 0;
        
        /* Unzip the boot.lua file that will run the rest of the boot process */
        mz_zip_reader_init_mem(&bootzip, (void*)&_binary_bootfiles_zip_start, (size_t)(&_binary_bootfiles_zip_end-&_binary_bootfiles_zip_start), 0);
        char *boot_lua = mz_zip_reader_extract_file_to_heap(&bootzip, "lua/boot.lua", &boot_size, 0);        
        printf("Extracted boot.lua [%d bytes]...\n", boot_size);   
        
        /* Push the boot code zip file pointer onto the stack */        
        lua_pushnumber(boot_L, (uint32_t)&bootzip);
        lua_setglobal(boot_L, "_bootzip");
        
        printf("Booting...\n");
        /* Run the boot script */
        int error = luaL_loadbuffer(boot_L, boot_lua, boot_size, "boot") || lua_pcall(boot_L,0,0,0);
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
