-- initialise the SD card access
ffi.C.libfs_init()

-- return a table of directory entries
-- each entry has name, size and isdir attributes
function ls_dir(dirpath)
    dir = ffi.C.mb_opendir(dirpath)
    dirent = ffi.C.mb_readdir(dir)
    dirs = {}
    while dirent~=ffi.NULL do
        table.insert(dirs, {name=ffi.string(dirent.name), size=dirent.byte_size, isdir=dirent.is_dir})
        dirent = dirent.next
    end
    ffi.C.mb_closedir(dir)
    return dirs
end

function lpad(str, len, char)
    if char == nil then char = ' ' end
    return str .. string.rep(char, len - #str)
end

function ls(dirpath)
 dirs = ls_dir(dirpath)
 for k,v in ipairs(dirs) do
    if v.isdir==0 then
       dirtype = ""
    else
       dirtype = "<DIR>"
    end
    print(lpad(v.name,20), "    ", lpad(tostring(v.size),12), "    ", lpad(dirtype,8))
 end
end
