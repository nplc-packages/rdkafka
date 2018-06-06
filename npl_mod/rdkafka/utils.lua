local _M = {}

function _M.concat(...)
    local args = {...}
    return _M.concat_table(args)
end

function _M.concat_table(t)
    local full_path = ""
    for i, v in ipairs(t) do
        v = tostring(v)
        if (i == 1) then
            full_path = v -- do nothing
        else
            if (v:sub(1, 1) ~= "/" and full_path:sub(-1, 1) ~= "/") then
                full_path = full_path .. "/" .. v
            else
                full_path = full_path .. v
            end
        end
    end
    return full_path
end

function _M.get_bin_location()
    local package = NPL.PackageManager.package_info("rdkafka")
    local install_dir = package.install_dir
    local bin_location = _M.concat(install_dir, 'bin/librdkafka.so.1')
    return bin_location
end

return _M
