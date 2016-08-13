

---
local ffi = require("ffi")
putc = ffi.new("void (*)(unsigned int)", ffi.cast("void (*)(unsigned int)", cfuncs.uart_putc))
putc(65)
putc(66)
putc(67)
putc(10)
putc(13)

mem = ffi.new("unsigned int *", ffi.cast("unsigned int *", 0x0))
restart = ffi.new("void (*)(void)", ffi.cast("void (*)(void)", 0x8000))  
print(mem[800])

compile_tcc = ffi.new("void *(*)(const char *)", ffi.cast("void *(*)(const char *)", cfuncs.compile_tcc))
delete_tcc = ffi.new("void (*)(void *)", ffi.cast("void (*)(void *)", cfuncs.delete_tcc))
getsymbol_tcc = ffi.new("void *(*)(void *, const char *)", ffi.cast("void *(*)(void *, const char *)", cfuncs.getsymbol_tcc))
  
deadbeef = [[
void set_deadbeef(unsigned int *n)
{
    *n = 0xdeadbeef;
}
]]
  
compiled = compile_tcc(deadbeef)
func = getsymbol_tcc(compiled, "set_deadbeef")
func = ffi.cast("void (*)(unsigned int*)", func)
test = ffi.new("unsigned int [1]", 0)
func(test)
  
print(string.format("%08X", test[0]))

---
    

