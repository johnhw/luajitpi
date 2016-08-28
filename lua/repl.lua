local pretty_print = require("pretty_print")

local tpprint = function(f) 
    local toprint = {}
    for k,v in ipairs(f) do
        if k>1 then table.insert(toprint, v) end
    end
    pretty_print.display(toprint) 
end

function pprint(f) pretty_print.display({f}) end 

-- return a char* buffer with a given string
function cstr(str)
   buf = ffi.new("char["..(string.len(str)+1).."]")
   ffi.copy(buf, str)
   return buf
end

-- autocompletion
local completion = require("completion")

local function ln_complete(expr, ln_completions)
   --add the completion
   completion.complete(ffi.string(expr), function (s) ffi.C.linenoiseAddCompletion(ln_completions, cstr(s)) end)
end

ffi.C.linenoiseSetCompletionCallback(ln_complete)

-- get a multiline input
function get_multiline()
    local lines_buffer = {}
    while true do
        line = ffi.string(ffi.C.linenoise("-"))
        if line=='--<' then
            return table.concat(lines_buffer)
        else
           table.insert(lines_buffer, line)
           table.insert(lines_buffer, "\n")
        end
    end
end


function repl()

    
    print("-----------------")
    print("Lua REPL")

    while true do
        line = ffi.string(ffi.C.linenoise(">>>"))
        
        if line=='-->' then
            line = get_multiline()
        end

        -- try wrapping with a return statement
        f, err = loadstring("return "..line)
        if not f then
            f, err = loadstring(line)
        end
        
        -- store the history
        ffi.C.linenoiseHistoryAdd(line)
        
        if f then            
            -- call the function and store the result in _
            xpargs = {xpcall(f, debug.traceback)}
            if xpargs[1]~=nil and table.getn(xpargs)>1 then
                _ = xpargs[2]
                tpprint(xpargs)
            end
        else
            console_error(err)
        end       
    end
end

