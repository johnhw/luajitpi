-->
local hw_rng_base = io_address(0x104000)
local hw_rng_ctrl = hw_rng_base
local hw_rng_ctrl_engage = 0x01
local hw_rng_status = hw_rng_base+0x4
local hw_rng_data = hw_rng_base+0x8

local burn_in = 0x8000
--<
-- burn in
put32(hw_rng_status, burn_in)
put32(hw_rng_ctrl, hw_rng_ctrl_engage)


local function raw_read_rng()
    repeat 
        local wait = bit.rshift(get32(hw_rng_status),24)
    until wait~=0    
    return get32(hw_rng_data)
end



return {raw=raw_read_rng}