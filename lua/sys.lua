function io_address(addr)
    return memmap.gpio_base + addr
end 

function split32(a)
    local a1 = bit.rshift(bit.band(a,0xff), 0)
    local a2 = bit.rshift(bit.band(a,0xff), 8)    
    local a3 = bit.rshift(bit.band(a,0xff), 16)
    local a4 = bit.rshift(bit.band(a,0xff), 24)
    return a1,a2,a3,a4
end
    
ffi.cdef([[
void enable_mmu(void);
void disble_cache(void);
void enable_cache(void);
]])    

ffi.C.enable_mmu()
ffi.C.enable_cache()