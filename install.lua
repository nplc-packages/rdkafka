local run = System.os.run

local function fileExists(path)
    local file, err = io.open(path, "rb")
    if file then file:close() end
    return file ~= nil
end

local bin_file_path = '/usr/local/lib/librdkafka.so.1'
local temp_dir = '/root/.nplc/temp'
local rdkafka_dir = '/root/.nplc/temp/rdkafka'
local librdkafka_dir = '/root/.nplc/temp/rdkafka/librdkafka'
local ffi_default_load_dir = '/usr/lib/librdkafka.so.1'

local function make_rdkafka_dir_if_not_exist()
    local make_rdkafka_dir_cmd = format('mkdir -p %s', rdkafka_dir, 0, 1, true, true)
    if not fileExists(rdkafka_dir) then
        run(make_rdkafka_dir_cmd)
    end
end

local function clone_if_not_exist()
    local clone_librdkafka_cmd = format('cd %s && git clone https://github.com/edenhill/librdkafka', rdkafka_dir)
    if not fileExists(librdkafka_dir) then
        run(clone_librdkafka_cmd)
    end
    print('finished cloning librdkafka')
end

local function compile()
    print('compile')
    local compile_cmd = format('cd %s && ./configure && make && sudo make install', librdkafka_dir)
    run(compile_cmd)
    print('finished compiling')
end

local function copy_file()
    print('copy')
    local copy_cmd = format('cp %s %s', bin_file_path, ffi_default_load_dir)
    run(copy_cmd)
end

local function compile_if_not_exist()
    if not fileExists(ffi_default_load_dir) then
        if not fileExists(bin_file_path)then
            make_rdkafka_dir_if_not_exist()
            clone_if_not_exist()
            compile()
        end
        copy_file()
    end
end

compile_if_not_exist()
