print("Testing Lua...")
print("---")

print("Opening the ffi interface...")
ffi = require("ffi")
ffi.load("default")
print("Serial output test; should print ABC...")

function cdef(ctype, fn)
    return ffi.new(ctype, ffi.cast(ctype, fn))
end



ffi.cdef([[
void uart_putc(unsigned int);
unsigned int uart_getc(void);
]])

putc = ffi.C.uart_putc

putc(65)
putc(66)
putc(67)
putc(10)
putc(13)


function getline()
    c = nil
    str = {}
    while c~=10 do
        c = getc()
        table.insert(str, string.char(c))
        putc(c)
    end
    return table.concat(str)
end

--print("Testing getline()...")
--print("Got: ", getline())


print("Memory access test, should dump first 256 bytes of ram")
mem = ffi.new("unsigned char *", ffi.cast("unsigned char *", 0x0))

function dump(offset, len)
    -- force 16 byte alignment
    local i = 0
    local off =  bit.band(offset, bit.bnot(15))
    while i<len do
        local s = ""
        for j = 0,15 do
            s = s..string.format("%02X ", mem[i+j+off])
        end
        
        local ascii = ""
        for j = 0,15 do
            local m = mem[i+j+off]
            if m>=32 and m<127 then
                ascii = ascii .. string.char(m)
            end
        end

        print(string.format("%08X",i+offset).."  |"..s.."|"..ascii)   
        i = i + 16
    end
end

dump(0x8000, 0x100)


deadbeef = [[
void set_deadbeef(unsigned int *n)
{
    *n = 0xdeadbeef;
}
]]


print("Testing TCC from LuaJIT...")
print(deadbeef)


ffi.cdef([[
void *compile_tcc(const char *str);
void delete_tcc(void *tcc);
void *getsymbol_tcc(void *tcc, const char *str);
]])



print("Compiling...")  
compiled = ffi.C.compile_tcc(deadbeef)
func = ffi.C.getsymbol_tcc(compiled, "set_deadbeef")
func = ffi.cast("void (*)(unsigned int*)", func)
test = ffi.new("unsigned int [1]", 0)
func(test)

print("Output should be DEADBEEF")
print(string.format("%08X", test[0]))
