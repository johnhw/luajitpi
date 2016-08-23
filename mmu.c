#include "mem.h"

volatile __attribute__ ((aligned (0x4000))) unsigned mem_mmu_table[MEM_MMU_TABLE_SIZE];

/* Code from https://www.raspberrypi.org/forums/viewtopic.php?t=65922&p=491887 */
void enable_mmu (void)
{
  

  unsigned base;
  for (base = 0; base < 512; base++)
  {
    // outer and inner write back, write allocate, shareable
    mem_mmu_table[base] = base << 20 | 0x1140E;
  }
  for (; base < 4096; base++)
  {
    // shared device, never execute
    mem_mmu_table[base] = base << 20 | 0x10416;
  }

  // restrict cache size to 16K (no page coloring)
  unsigned auxctrl;
  asm volatile ("mrc p15, 0, %0, c1, c0,  1" : "=r" (auxctrl));
  auxctrl |= 1 << 6;
  asm volatile ("mcr p15, 0, %0, c1, c0,  1" :: "r" (auxctrl));

  // set domain 0 to client
  asm volatile ("mcr p15, 0, %0, c3, c0, 0" :: "r" (1));

  // always use TTBR0
  asm volatile ("mcr p15, 0, %0, c2, c0, 2" :: "r" (0));

  // set TTBR0 (page table walk inner cacheable, outer non-cacheable, shareable memory)
  asm volatile ("mcr p15, 0, %0, c2, c0, 0" :: "r" (3 | (unsigned) &mem_mmu_table));

  // invalidate data cache and flush prefetch buffer
  asm volatile ("mcr p15, 0, %0, c7, c5,  4" :: "r" (0) : "memory");
  asm volatile ("mcr p15, 0, %0, c7, c6,  0" :: "r" (0) : "memory");

  // enable MMU, L1 cache and instruction cache, L2 cache, write buffer,
  //   branch prediction and extended page table on
  unsigned mode;
  asm volatile ("mrc p15,0,%0,c1,c0,0" : "=r" (mode));
  mode |= 0x0480180D;
  asm volatile ("mcr p15,0,%0,c1,c0,0" :: "r" (mode) : "memory");
}