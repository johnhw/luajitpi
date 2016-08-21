local zip_list = bootzip:list()

function zip_require(pac)
    -- package already loaded
    if package.loaded[pac]~=nil then
        return package.loaded[pac]
    end
    
    -- load the package from the zip file
    if package.preload[pac]==nil then
        for k,v in ipairs(zip_list) do
            local fname = v.filename
            -- replace . with / to make subpackage loading work right
            local fpac = string.gsub(pac, "%.", "/")
            if string.find(fname, "/"..fpac.."%.lua$") then
                package.loaded[pac] = run_bootzip(fname)  
                -- remember even packages that don't return anything
                if package.loaded[pac]==nil then
                    package.loaded[pac] = true
                end
                return package.loaded[pac]
            end
        end
    else
        -- in the preload table
        return package.preload[pac]()
    end
    print("Package "..pac.." not found")
    return nil
end

require = zip_require
