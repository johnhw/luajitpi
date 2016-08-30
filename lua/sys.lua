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
]])    

mem = ffi.new("unsigned char *", ffi.cast("unsigned char *", 0x0))
mem32 = {}
_mem32 = ffi.new("unsigned int *", ffi.cast("unsigned int *", 0x0))
local mt_mem32 = {
__index = function(t,addr) return t[bit.rshift(addr,2)] end,
__newindex = function(t,addr,val) t[bit.rshift(addr,2)]=val end
}
setmetatable(mem32, mt_mem32)

-- simple get and put functions
function get32(addr)
    return _mem32[bit.rshift(addr, 2)]
end

function put32(addr, val)
    _mem32[bit.rshift(addr, 2)] = val
end


function set_bit(v, b)
    return bit.bor(v, bit.lshift(1, b))
end

function clear_bit(v, b)
    return bit.band(v, bit.bnot(bit.lshift(1, b)))
end

function get_bit(v, b)
    return bit.rshift(bit.band(v, bit.lshift(1,b)), b)
end
 
ffi.C.enable_mmu()


ffi.cdef(
[[typedef struct vector_table
{
    void (*reset)(void);
    void (*undefined_instruction)(void);
    void (*software_interrupt)(void);
    void (*prefetch_abort)(void);
    void (*data_access)(void);
    void (*unhandled_exception)(void);
    void (*interrupt)(void);
    void (*fast_interrupt)(void);
    
} vector_table;
]])

sys = {}
sys.memmap = memmap
sys.exc_table = ffi.cast("vector_table *", memmap.exc_table)
sys.atags = {}