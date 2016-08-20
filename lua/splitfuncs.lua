
test_str = [[
---!init.lua
print("Compiling...")  
compiled = ffi.C.compile_tcc(deadbeef)
func = ffi.C.getsymbol_tcc(compiled, "set_deadbeef")
func = ffi.cast("void (*)(unsigned int*)", func)
---!test.lua
test = ffi.new("unsigned int [1]", 0)
func(test)
---!print.lua
print("Output should be DEADBEEF")
print(string.format("%08X", test[0]))
]]

function split_funcs(s) 
    funcs = {}
    block = 1
    repeat 
        _start, block_start = string.find(s, "---![^%s]+", block)
        block_end, send = string.find(s, "---![^%s]+", block_start)
        label = string.sub(s, _start+4, block_start)
        if block_end ~= nil then
            block = block_end - 1
        else
            block = nil
        end
        text_block = string.sub(s, block_start+1, block)
        funcs[label] = text_block
    until(block_end==nil)
   return funcs
end

function run_funcs(s, debugging)
    funcs = split_funcs(s)
    for k,v in pairs(funcs) do
        if debugging then
            print("---!"..k)
        end
        fn,err = loadstring(v)
        if fn==nil then
            print("Error in "..k.." "..err)
        else
            function lerror(err)
                print("Error in "..k.." "..err)
            end
            xpcall(fn, lerror)
        end
    end
end

run_funcs(test_str, true)