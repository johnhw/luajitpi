-- cd
-- ls
-- cp
-- mv
-- rm
-- grep
-- more
-- pwd
-- rmdir
-- mkdir
-- set
-- $ interpolation
-- zip
-- unzip
-- upload
-- dload
-- cat

local _pwd='/'

function sh_pwd()
    return pwd
end

function sh_ls()
    ls(_pwd)
end

function sh_cat(file)
    local f_ = io.open(_pwd..file)
    local all = f_.read('*all')
    print(all)
end

function 