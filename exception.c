typedef struct vector_table
{
    void (*reset)(void);
    void (*undefined_instruction)(void);
    void (*software_interrupt)(unsigned int);
    void (*prefetch_abort)(void);
    void (*data_access)(void);    
    void (*unhandled_exception)(void);
    void (*interrupt)(void);
    void (*fast_interrupt)(void);
    
} vector_table;

/* We simply dispatch to wherever the table is pointing to */
/* This should be set in Lua */

/* Force GCC to preserve the callee-saved registers */
#define PRESERVE_REGS  asm volatile ( "nop" : : : "r0", "r1", "r2", "r3", "r4", "r5", "r6", "r7", "r8", "r9", "r10", "r11", "r12", "r14");

vector_table arm_exc_table = {0};

void exc_reset(void)
{    
    arm_exc_table.reset();
}

void __attribute__((interrupt("SWI"))) exc_software_interrupt(void)
{
    volatile unsigned int intrp;;
    asm("LDR r0, [lr, #-4]");
    asm("BIC r0, #0xFF000000");
    asm("MOV %0, r0":"=r"(intrp):);
    arm_exc_table.software_interrupt(intrp);
}

void __attribute__((interrupt("ABORT"))) exc_prefetch_abort(void)
{
    PRESERVE_REGS;
    arm_exc_table.prefetch_abort();
    
}

void exc_data_access(void)
{
    PRESERVE_REGS;
    arm_exc_table.data_access();    
}

void __attribute__((interrupt("UNDEF"))) exc_undefined_instruction(void)
{
    PRESERVE_REGS;
    arm_exc_table.undefined_instruction();
}

void exc_unhandled_exception(void)
{
    PRESERVE_REGS;
    arm_exc_table.unhandled_exception();
}

void __attribute__((interrupt("IRQ"))) exc_interrupt(void)
{
    arm_exc_table.interrupt();
}

void __attribute__((interrupt("FIQ"))) exc_fast_interrupt(void)
{
    arm_exc_table.fast_interrupt();
}
