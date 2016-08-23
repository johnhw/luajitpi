print("Memory access test, should dump first 256 bytes of ram")

dump(0x8000, 0x100)


deadbeef = [[
void set_deadbeef(unsigned int *n)
{
    *n = 0xdeadbeef;
}
]]


print("Testing TCC from LuaJIT...")
print(deadbeef)


print("Compiling...")  
compiled = ffi.C.compile_tcc(deadbeef)
func = ffi.C.getsymbol_tcc(compiled, "set_deadbeef")
func = ffi.cast("void (*)(unsigned int*)", func)
test = ffi.new("unsigned int [1]", 0)
func(test)

print("Output should be DEADBEEF")
print(string.format("%08X", test[0]))

