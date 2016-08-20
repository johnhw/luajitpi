

function repl()
    print("-----------------")
    print("Lua REPL")

    while true do
        line = ffi.string(ffi.C.linenoise(">>>"))
        f, err = loadstring(line)
        ffi.C.linenoiseHistoryAdd(line)
        if f then            
            xpcall(f, console_error)
        else
            console_error(err)
        end       
    end
end

