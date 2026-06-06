local Config = {}
Config.__index = Config

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

Config.Folder = "Hyper_M4X/Configs"
Config.File = "settings.json"
Config.Interval = 30
Config.AutoSaveConn = nil

function Config:Save(flags)
    local data = {}
    if flags then
        for name, flag in pairs(flags) do
            if type(flag) == "table" and flag.Get then
                data[name] = flag:Get()
            end
        end
    end
    local json = HttpService:JSONEncode(data)
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
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
    if not ok or not data then return false end
    local count = 0
    if flags then
        for name, value in pairs(data) do
            local flag = flags[name]
            if flag and flag.Set then flag:Set(value) count = count + 1 end
        end
    end
    return true, count
end

function Config:Delete()
    local path = Config.Folder .. "/" .. Config.File
    if isfile and isfile(path) then delfile(path) return true end
    return false
end

function Config:StartAutoSave(flags)
    if Config.AutoSaveConn then Config.AutoSaveConn:Disconnect() end
    Config.AutoSaveConn = RunService.Heartbeat:Connect(function()
        if tick() % Config.Interval < 0.016 then
            Config:Save(flags)
        end
    end)
end

function Config:StopAutoSave()
    if Config.AutoSaveConn then Config.AutoSaveConn:Disconnect() Config.AutoSaveConn = nil end
end

function Config:Init(tab, library, flags)
    local self = setmetatable({}, Config)
    self.Tab = tab
    self.Library = library
    self.Flags = flags

    local Sec = tab:Section({ Title = "Config", Icon = "save", Opened = true })
    
    Sec:Button({ Title = "Save", Callback = function()
        Config:Save(flags)
        library:Notify({ Title = "Config", Description = "Saved!", Duration = 2 })
    end })
    
    Sec:Button({ Title = "Load", Callback = function()
        local ok, count = Config:Load(flags)
        if ok then library:Notify({ Title = "Config", Description = "Loaded " .. (count or 0) .. " settings!", Duration = 3 })
        else library:Notify({ Title = "Config", Description = "No saved config!", Duration = 2 }) end
    end })
    
    Sec:Button({ Title = "Delete", Callback = function()
        if Config:Delete() then library:Notify({ Title = "Config", Description = "Deleted!", Duration = 2 })
        else library:Notify({ Title = "Config", Description = "No file to delete!", Duration = 2 }) end
    end })
    
    Sec:Toggle({ Title = "Auto Save", Value = true, Callback = function(v)
        if v then Config:StartAutoSave(flags) else Config:StopAutoSave() end
    end })

    return self
end

return Config
