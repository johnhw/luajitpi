-- get the actual model of Pi we are using
local b1_1=  {name="Model B rev 1.0", model="B1", revision=1, version=1, memory=256}
local b1_2 = {name="Model B rev 1.0 + ECN0001", model="B1", revision=1, version=1, memory=256}
local b1_v2 = {name="Model B rev 2.0", model="B1", revision=2, version=1, memory=256}
local a = {name="Model A", model="A1", version=1, revision=1, memory=256}
local b1_v2_1 = {name="Model B rev 2.0 [512Mb]", model="B1", version=1, revision=2, memory=512}
local bplus = {name="Model B+", model="B+", version=1, revision=1, memory=512}
local compute = {name="Compute Module", model="CM", version=1, revision=1, memory=512}
local aplus = {name="Model A+", model="A+", version=1, revision=1, memory=256}
local b2 = {name="Pi 2 Model B", model="B2", version=2, revision=1, memory=1024}
local zero = {name="Pi Zero", model="P0", version=0, revision=1, memory=512}
local b3 = {name="Pi 3 Model B", model="B3", version=3, revision=1, memory=1024}


rpi_model_table = {
    [0x2] = b1_1,
    [0x3] = b1_2,
    [0x4] = b1_v2,
    [0x5] = b1_v2,
    [0x6] = b1_v2,
    [0x7] = a,
    [0x8] = a,
    [0x9] = a,
    [0xd] = b1_v2_1,
    [0xe] = b1_v2_1,
    [0xf] = b1_v2_1,
    [0x10] = bplus,
    [0x13] = bplus,
    [0x11] = compute,
    [0x12] = aplus,
    [0xa01041] = b2,
    [0xa21041] = b2,
    [0x900092] = zero,
    [0xa02082] = b3,
    [0xa22082] = b3,
}

-- this won't work because atags does not have the revision number
atags.model = rpi_model_table[tonumber(atags.revision)]
