#include "mem.h"

#define MMUTABLEBASE MEM_MMU_TABLE

//-------------------------------------------------------------------
unsigned int mmu_section ( unsigned int vadd, unsigned int padd, unsigned int flags )
{
    unsigned int ra;
    unsigned int rb;
    unsigned int rc;
    ra=vadd>>20;
    rb=MMUTABLEBASE|(ra<<2);
    rc=(padd&0xFFF00000)|0xC00|flags|2;
    PUT32(rb,rc);
    return(0);
}
//-------------------------------------------------------------------
unsigned int mmu_small ( unsigned int vadd, unsigned int padd, unsigned int flags, unsigned int mmubase )
{
    unsigned int ra;
    unsigned int rb;
    unsigned int rc;

    ra=vadd>>20;
    rb=MMUTABLEBASE|(ra<<2);
    rc=(mmubase&0xFFFFFC00)/*|(domain<<5)*/|1;
    PUT32(rb,rc); //first level descriptor
    ra=(vadd>>12)&0xFF;
    rb=(mmubase&0xFFFFFC00)|(ra<<2);
    rc=(padd&0xFFFFF000)|(0xFF0)|flags|2;
    PUT32(rb,rc); //second level descriptor
    return(0);
}


int enable_mmu(void)
{
    unsigned int ra;
    for(ra=0;;ra+=0x00100000)
    {
        mmu_section(ra,ra,0x0000|8|4);
        if(ra==0xFFF00000) break;
    }
    mmu_section(MEM_GPIO_BASE,MEM_GPIO_BASE,0x0000); //NOT CACHED!
    mmu_section(MEM_GPIO_BASE+0x0200000,MEM_GPIO_BASE+0x0200000,0x0000); //NOT CACHED!
    start_mmu(MMUTABLEBASE,0x00000001|0x1000|0x0004); //[23]=0 subpages enabled = legacy ARMv4,v5 and v6
}