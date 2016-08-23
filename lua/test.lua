print("Testing Lua...")
print("---")

print("Opening the ffi interface...")
ffi = require("ffi")
ffi.load("default")
print("Serial output test; should print ABC...")


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


