local _M = {}

function _M.get_bin_location()
    local package = NPL.PackageManager.package_info("rdkafka")
    local install_dir = package.install_dir
    local bin_location = format('%s/%s', install_dir, 'bin/librdkafka.so.1')
    return bin_location
end

return _M
