

---
local ffi = require("ffi")
putc = ffi.new("void (*)(unsigned int)", ffi.cast("void (*)(unsigned int)", cfuncs.uart_putc))
putc(65)
putc(66)
putc(67)
putc(10)
putc(13)

--mem = ffi.new("unsigned int *", ffi.cast("unsigned int *", 0x0))
--restart = ffi.new("void (*)(void)", ffi.cast("void (*)(void)", 0x8000))  
--print(mem[800])

---
    

