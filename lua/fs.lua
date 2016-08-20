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

-- function readbuf(F)
    -- bytes_read = mb_fread(F.buffer, F.buf_len, 1, f.FILE)
    -- F.buf_left = bytes
    -- F.buf_read = 0
    -- if bytes~=F.buf_len then
        -- F.eof = true
    -- end
-- end


-- function readall(F)
   -- file_contents = {}
   -- while not F.eof do
        -- readbuf(F) 
        -- table.insert(file_contents, ffi.string(F.buf, F.buf_len))
   -- end
   -- return table.concat(file_contents)
-- end

-- function readline(F, buf)
   
   -- bytes = mb_fread(buf, 512, 1, F)
   -- table.insert(file_contents, ffi.string(buf, bytes))
   -- while bytes==buf_len do
        -- bytes = mb_fread(buf, buf_len, 1, fptr)
        -- table.insert(file_contents, ffi.string(buf, bytes))
   -- end
   -- return table.concat(file_contents)
-- end

-- function readbytes(F, bytes)
   -- file_contents = {}
   
   -- while bytes>F.buf_left do
        -- readbuf(F)
        -- bytes = bytes - F.buf_len
   -- end
   
   -- if bytes<buf_left then
        -- buf_left = buf_left - bytes
        -- buf_read = buf_read + bytes
   -- else        
        -- readbuf(F)
        
   -- return ffi.string(buf, bytes)
-- end


-- function openfile(path)
    -- fptr = ffi.C.mb_fopen(path, 'r')
    -- file = {
        -- FILE=fptr,
        -- buf_len = 1024,
        -- buf_left = 0,
        -- buf_read = 0,
        -- eof = false,
        -- buffer = ffi.new('char[1024]'),
        -- close = function (F) ffi.C.mb_fclose(F) end,
        -- write = function(F,w) ffi.C_mb_fwrite(w, 1, len(w), F) end,
        -- read = function(F,w,bytes) 
            -- if bytes=="*all" then
                -- return readall(F)
            -- else if bytes=="*line" or bytes==nil then
                -- return readline(F)
            -- else 
                -- return readbytes(F)
        -- end  
    -- end        
    -- }
    -- return file
-- end

