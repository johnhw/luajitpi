dynasm = require("dynasm")

local gencode, actions = dynasm.loadstring([[
local ffi  = require('ffi')
local dasm = require('dasm')

|.arch arm
|.actionlist actions

local function gencode(Dst)
   |  mov r0, #0
end

return gencode, actions
]])