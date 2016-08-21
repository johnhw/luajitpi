/* Memory map:
    0x000000      reserverd
    0x008000      kernel
    0x200000      stack ptr
    0x210000      mmu table
    0x220000      heap starts
*/

#ifndef MEM_H
#define MEM_H
#include <stdint.h>


typedef unsigned char u8;
typedef unsigned int u32;

#define MEM_RESERVED            0x000000  
#define MEM_KERNEL_START        0x008000 
#define MEM_STACK_PTR           0x200000
#define MEM_MMU_TABLE           0x210000 
#define MEM_HEAP_START          0x220000     
#define MEM_GPIO_BASE           0x20000000
#define MEM_MMU_TABLE_SIZE      0x8000 

/* Declare ARM assembly-language helper functions */
extern void PUT_32(u32 addr, u32 data);
extern u32 GET_32(u32 addr);
extern void NO_OP();
extern void SPIN(u32 count);
extern void BRANCH_TO(u32 addr);

extern void memory_barrier(void);
extern void start_l1cache(void);
extern void stop_l1cache(void);
extern void start_mmu(unsigned int a, unsigned int b);

#endif