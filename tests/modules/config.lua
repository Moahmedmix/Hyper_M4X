--[[
    Extracted Config module from Core/Icons.lua for unit testing.
    This mirrors the Config implementation in Core/Icons.lua.
]]

local Config = {}
Config.__index = Config

Config.Folder = "Hyper_M4X/Configs"
Config.File = "settings.json"
Config.Interval = 30
Config.AutoSaveConn = nil

-- Use injectable JSON encoder/decoder for testing
Config._jsonEncode = nil
Config._jsonDecode = nil

function Config:SetJsonFunctions(encode, decode)
    self._jsonEncode = encode
    self._jsonDecode = decode
end

function Config:Save(flags)
    local data = {}
    if flags then
        for name, flag in pairs(flags) do
            if type(flag) == "table" and flag.Get then
                data[name] = flag:Get()
            end
        end
    end

    local encode = self._jsonEncode or function(d)
        local parts = {}
        for k, v in pairs(d) do
            local val
            if type(v) == "string" then val = '"' .. v .. '"'
            elseif type(v) == "boolean" then val = tostring(v)
            elseif type(v) == "number" then val = tostring(v)
            else val = '""' end
            table.insert(parts, '"' .. k .. '":' .. val)
        end
        return "{" .. table.concat(parts, ",") .. "}"
    end

    local json = encode(data)
    if writefile and isfolder then
        if not isfolder(Config.Folder) then makefolder(Config.Folder) end
        writefile(Config.Folder .. "/" .. Config.File, json)
    end
    return true
end

function Config:Load(flags)
    if not readfile or not isfile then return false end
    local path = Config.Folder .. "/" .. Config.File
    if not isfile(path) then return false end

    local decode = self._jsonDecode or function(json)
        local data = {}
        for k, v in json:gmatch('"([^"]+)":([^,}]+)') do
            if v:match('^".*"$') then
                data[k] = v:sub(2, -2)
            elseif v == "true" then
                data[k] = true
            elseif v == "false" then
                data[k] = false
            else
                data[k] = tonumber(v) or v
            end
        end
        return data
    end

    local content = readfile(path)
    local ok, data = pcall(decode, content)
    if not ok or not data then return false end

    local count = 0
    if flags then
        for name, value in pairs(data) do
            local flag = flags[name]
            if flag and flag.Set then flag:Set(value); count = count + 1 end
        end
    end
    return true, count
end

function Config:Delete()
    local path = Config.Folder .. "/" .. Config.File
    if isfile and isfile(path) then delfile(path); return true end
    return false
end

return Config
