#include <string.h>
#include <stdlib.h>
#include <libtcc.h>
#include <stdio.h>


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
