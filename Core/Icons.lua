--[[
    ╔══════════════════════════════════════════════════╗
    ║           HYPER UI - Config System               ║
    ║         Save & Load All Settings                  ║
    ║         By M4X | EVA | AMAL                      ║
    ╚══════════════════════════════════════════════════╝
--]]

local Config = {}
Config.__index = Config

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

Config.Folder = "Hyper_M4X/Configs"
Config.File = "settings.json"
Config.AutoSaveInterval = 30 -- seconds

-- Save all flags to file
function Config:Save(flags, extraData)
    local data = {}
    
    -- Save flags
    if flags then
        for name, flag in pairs(flags) do
            if type(flag) == "table" and flag.Get then
                data[name] = flag:Get()
            end
        end
    end
    
    -- Save extra data (ESP settings, Aimbot settings, etc.)
    if extraData then
        data._extra = extraData
    end
    
    -- Convert to JSON
    local json = "{}"
    pcall(function()
        json = HttpService:JSONEncode(data)
    end)
    
    -- Write to file
    if writefile and isfolder then
        if not isfolder(Config.Folder) then
            pcall(function() makefolder(Config.Folder) end)
        end
        pcall(function()
            writefile(Config.Folder .. "/" .. Config.File, json)
        end)
    end
    
    print("[Config] Saved " .. #json .. " bytes")
    return json
end

-- Load all flags from file
function Config:Load(flags, extraCallback)
    local data = nil
    
    -- Read from file
    if readfile and isfile then
        local path = Config.Folder .. "/" .. Config.File
        if isfile(path) then
            local content = readfile(path)
            pcall(function()
                data = HttpService:JSONDecode(content)
            end)
        end
    end
    
    if not data then
        print("[Config] No saved config found")
        return false
    end
    
    -- Load flags
    local loadedCount = 0
    if flags then
        for name, value in pairs(data) do
            if name ~= "_extra" then
                local flag = flags[name]
                if flag and flag.Set then
                    flag:Set(value)
                    loadedCount = loadedCount + 1
                end
            end
        end
    end
    
    -- Load extra data
    if extraCallback and data._extra then
        extraCallback(data._extra)
    end
    
    print("[Config] Loaded " .. loadedCount .. " flags")
    return true
end

-- Delete config file
function Config:Delete()
    if isfile then
        local path = Config.Folder .. "/" .. Config.File
        if isfile(path) then
            delfile(path)
            print("[Config] Deleted")
            return true
        end
    end
    return false
end

-- Auto save
function Config:StartAutoSave(flags, getExtraData)
    Config.AutoSaveConn = RunService.Heartbeat:Connect(function()
        if tick() % Config.AutoSaveInterval < 0.016 then
            local extra = nil
            if getExtraData then extra = getExtraData() end
            Config:Save(flags, extra)
        end
    end)
end

function Config:StopAutoSave()
    if Config.AutoSaveConn then
        Config.AutoSaveConn:Disconnect()
        Config.AutoSaveConn = nil
    end
end

function Config:Init(tab, library, flags)
    local self = setmetatable({}, Config)
    self.Tab = tab
    self.Library = library
    self.Flags = flags
    
    -- Register flag
    if flags then
        flags:Create("ConfigAutoSave", true)
    end
    
    local Sec = tab:Section({ Title = "Configuration", Icon = "save", Opened = true })
    
    Sec:Button({ Title = "Save Config", Description = "Save all settings now", Callback = function()
        Config:Save(flags)
        library:Notify({ Title = "Config", Description = "Settings saved!", Duration = 3 })
    end })
    
    Sec:Button({ Title = "Load Config", Description = "Load saved settings", Callback = function()
        if Config:Load(flags) then
            library:Notify({ Title = "Config", Description = "Settings loaded!", Duration = 3 })
        else
            library:Notify({ Title = "Config", Description = "No saved config found!", Duration = 3 })
        end
    end })
    
    Sec:Button({ Title = "Delete Config", Description = "Reset all settings", Callback = function()
        Config:Delete()
        library:Notify({ Title = "Config", Description = "Config deleted!", Duration = 3 })
    end })
    
    Sec:Toggle({ Title = "Auto Save", Description = "Auto save every " .. Config.AutoSaveInterval .. "s", Value = true, Callback = function(s)
        if s then
            Config:StartAutoSave(flags)
        else
            Config:StopAutoSave()
        end
    end })
    
    return self
end

return Config
