local dis = require("dis_arm")

function disas(addr, len, out)
    -- default to printing
    if out==nil then
        out = io.write
    end
    local dmem = ffi.string(ffi.cast("void*",addr), len)
    dis.disass(dmem, addr, out)
end

mem = ffi.new("unsigned char *", ffi.cast("unsigned char *", 0x0))
mem32 = {}
_mem32 = ffi.new("unsigned int *", ffi.cast("unsigned int *", 0x0))
local mt_mem32 = {
__index = function(addr) return _mem32[bit.rshift(addr,4)] end,
__newindex = function(addr,val) _mem32[bit.rshift(addr,4)]=val end
}
setmetatable(mem32, mt_mem32)


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

