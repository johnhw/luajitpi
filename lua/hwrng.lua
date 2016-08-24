local hw_rng_base = io_address(0x104000)
local hw_rng_ctrl = hw_rng_base
local hw_rng_ctrl_engage = 0x01
local hw_rng_status = hw_rng_base+0x4
local hw_rng_data = hw_rng_base+0x8

local burn_in = 0x8000

-- burn in
put32(hw_rng_status, burn_in)
put32(hw_rng_ctrl, hw_rng_ctrl_engage)


local function raw_read_rng()
    repeat 
        local wait = bit.rshift(get32(hw_rng_status),24)
    until wait~=0    
    return read32(hw_rng_data)
end

-- entropy pool
local _entropy_pool ffi.new("uint32_t[256]")


local function update_entropy()
    local a = raw_read_rng()
    local a1,a2,a3,a4 = split32(a)
    _entropy_pool[a1] = bit.bxor(raw_read_rng(), _entropy_pool[a1])
    _entropy_pool[a2] = bit.bxor(raw_read_rng(), _entropy_pool[a2])
    _entropy_pool[a3] = bit.bxor(raw_read_rng(), _entropy_pool[a3])
    _entropy_pool[a4] = bit.bxor(raw_read_rng(), _entropy_pool[a4])
end

return {raw=raw_read_rng, update_entropy=update_entropy}