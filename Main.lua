--[[
    ╔══════════════════════════════════════════════════╗
    ║           HYPER UI - Complete Framework          ║
    ║              Version: v1.0.0                      ║
    ║         By M4X | EVA | AMAL                      ║
    ║    Repository: github.com/Moahmedmix/Hyper_M4X    ║
    ╚══════════════════════════════════════════════════╝
    
    هذا الملف يحتوي على:
    - نظام الحماية والتحقق من الملفات
    - لوجر متكامل للكونسول
    - تحميل آمن للملفات الخارجية
    - واجهة WindUI الرسمية
    - Skip للملفات اللي فشلت
--]]

-- =============================================
-- LOAD WIND UI
-- =============================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local REPO_URL = "https://raw.githubusercontent.com/Moahmedmix/Hyper_M4X/main/"
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- =============================================
-- LOGGER SYSTEM
-- =============================================
local Logger = { History = {} }
function Logger:Log(icon, msg)
    local text = "[Hyper] [" .. icon .. "] " .. msg
    print(text)
    table.insert(self.History, {Icon = icon, Msg = msg, Time = os.time()})
end
function Logger:Info(msg)  self:Log("i", msg) end
function Logger:Good(msg)  self:Log("OK", msg) end
function Logger:Warn(msg)  self:Log("!!", msg) end
function Logger:Fail(msg)  self:Log("XX", msg) end
function Logger:Skip(msg)  self:Log(">>", msg) end
function Logger:Dead(msg)  self:Log("!!", msg) end
function Logger:Line()     print("[Hyper] ----------------------------------------") end

-- =============================================
-- MODULE LOADER WITH FULL PROTECTION
-- =============================================
local Loaded = {}
local Failed = {}
local Skipped = {}

local function LoadModule(path, required)
    local name = path:match("([^/]+)%.lua$") or path
    local url = REPO_URL .. path
    
    Logger:Info("Loading: " .. name)
    
    -- 1. HTTP Request
    local httpOk, content = pcall(function() return game:HttpGet(url) end)
    if not httpOk then
        local errMsg = tostring(content)
        if required then
            Logger:Dead("NETWORK: " .. name .. " - " .. errMsg)
            table.insert(Failed, {Name = name, Reason = "Network: " .. errMsg})
            return nil
        else
            Logger:Skip("Network: " .. name)
            table.insert(Skipped, {Name = name, Reason = "Network"})
            return nil
        end
    end
    
    -- 2. Syntax Check
    local chunk, syntaxErr = loadstring(content)
    if not chunk then
        if required then
            Logger:Dead("SYNTAX: " .. name .. " - " .. tostring(syntaxErr))
            table.insert(Failed, {Name = name, Reason = "Syntax"})
            return nil
        else
            Logger:Skip("Syntax: " .. name)
            table.insert(Skipped, {Name = name, Reason = "Syntax"})
            return nil
        end
    end
    
    -- 3. Runtime Execution
    local runOk, result = pcall(chunk)
    if not runOk then
        if required then
            Logger:Dead("RUNTIME: " .. name .. " - " .. tostring(result))
            table.insert(Failed, {Name = name, Reason = "Runtime"})
            return nil
        else
            Logger:Skip("Runtime: " .. name)
            table.insert(Skipped, {Name = name, Reason = "Runtime"})
            return nil
        end
    end
    
    Logger:Good("Loaded: " .. name)
    table.insert(Loaded, {Name = name, Module = result})
    return result
end

-- =============================================
-- STARTUP BANNER
-- =============================================
print("")
print("  ==========================================")
print("       HYPER UI - v1.0.0")
print("    By M4X | EVA | AMAL")
print("  ==========================================")
print("")
Logger:Info("Initializing...")
Logger:Info("Player: " .. LocalPlayer.Name)
Logger:Info("Place ID: " .. game.PlaceId)
Logger:Line()

-- =============================================
-- LOAD CORE MODULES (Required)
-- =============================================
Logger:Info("Loading Core Modules...")

local Flags = LoadModule("Core/Flags.lua", true)
local Config = LoadModule("Core/Config.lua", true)

-- Check critical failures
if #Failed > 0 then
    Logger:Dead("CRITICAL FAILURES - Aborting!")
    for _, f in ipairs(Failed) do
        Logger:Dead("  -> " .. f.Name .. ": " .. f.Reason)
    end
    return
end

Logger:Line()

-- =============================================
-- FLAGS SYSTEM (FALLBACK)
-- =============================================
if not Flags then
    Flags = {}
    local FlagStorage = {}
    function Flags:Create(name, default)
        if FlagStorage[name] then return FlagStorage[name] end
        local flag = { Name = name, Value = default, Connections = {} }
        function flag:Get() return self.Value end
        function flag:Set(v)
            local old = self.Value
            self.Value = v
            for _, cb in ipairs(self.Connections) do cb(v, old) end
        end
        function flag:Connect(cb)
            table.insert(self.Connections, cb)
            return { Disconnect = function()
                for i, c in ipairs(self.Connections) do
                    if c == cb then table.remove(self.Connections, i) break end
                end
            end }
        end
        FlagStorage[name] = flag
        return flag
    end
    function Flags:Get(name) return FlagStorage[name] end
    function Flags:Set(name, value) if FlagStorage[name] then FlagStorage[name]:Set(value) end end
    function Flags:Export()
        local data = {}
        for name, flag in pairs(FlagStorage) do data[name] = flag:Get() end
        return data
    end
    function Flags:Import(data)
        for name, value in pairs(data) do Flags:Set(name, value) end
    end
end

-- =============================================
-- CONFIG SYSTEM (FALLBACK)
-- =============================================
-- =============================================
-- CONFIG SYSTEM (FALLBACK)
-- =============================================
if not Config then
    Config = {}
    Config.Folder = "Hyper_Configs"
    Config.File = "HyperSettings"
    function Config:Save()
        local data = Flags:Export()
        local json
        local ok, result = pcall(function() return HttpService:JSONEncode(data) end)
        if ok then json = result else json = "{}" end
        if writefile and type(self.Folder) == "string" and type(self.File) == "string" then
            if not isfolder(self.Folder) then makefolder(self.Folder) end
            writefile(self.Folder .. "/" .. self.File .. ".json", json)
        end
        return json
    end
    function Config:Load()
        if readfile and isfile and type(self.Folder) == "string" and type(self.File) == "string" then
            local path = self.Folder .. "/" .. self.File .. ".json"
            if isfile(path) then
                local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
                if ok then Flags:Import(data) return data end
            end
        end
        return nil
    end
    function Config:Delete()
        if isfile and type(self.Folder) == "string" and type(self.File) == "string" then
            local path = self.Folder .. "/" .. self.File .. ".json"
            if isfile(path) then delfile(path) end
        end
    end
end

-- =============================================
-- CREATE WINDOW USING WIND UI
-- =============================================
local Window = WindUI:CreateWindow({
    Name = "Hyper",
    Subtitle = "v1.0.0",
    Icon = "",
    LoadingTitle = "Hyper UI • Loading...",
    LoadingSubtitle = "By M4X | EVA | AMAL",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Hyper_Configs",
        FileName = "HyperSettings"
    },
    Discord = {
        Enabled = false,
        Invite = ""
    },
    KeySystem = false,
    SaveOnClose = true
})

-- =============================================
-- CREATE TABS
-- =============================================
local HomeTab      = Window:CreateTab("Home",      "home")
local AimbotTab    = Window:CreateTab("Aimbot",    "crosshair")
local VisualsTab   = Window:CreateTab("Visuals",   "eye")
local MovementTab  = Window:CreateTab("Movement",  "zap")
local UtilityTab   = Window:CreateTab("Utility",   "settings")
local ConfigTab    = Window:CreateTab("Config",    "save")

-- =============================================
-- HOME TAB CONTENT
-- =============================================
HomeTab:CreateSection("Welcome")
HomeTab:CreateLabel("Hyper UI Framework v1.0.0")
HomeTab:CreateLabel("By M4X | EVA | AMAL")
HomeTab:CreateLabel("Welcome, " .. LocalPlayer.Name .. "!")

HomeTab:CreateSection("Quick Actions")
HomeTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

HomeTab:CreateButton({
    Name = "Clean Workspace",
    Callback = function()
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Model") and obj ~= LocalPlayer.Character then
                pcall(function() obj:Destroy() end)
            end
        end
        WindUI:Notify({ Title = "Hyper", Content = "Workspace cleaned!", Duration = 2 })
    end
})

HomeTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        Window:Destroy()
    end
})

HomeTab:CreateSection("Toggles")
HomeTab:CreateToggle({ Name = "Auto Updater", CurrentValue = true, Flag = "AutoUpdater", Callback = function(v) end })
HomeTab:CreateToggle({ Name = "Anti AFK", CurrentValue = false, Flag = "AntiAFK", Callback = function(v) end })

-- =============================================
-- LOAD EXTERNAL FEATURES
-- =============================================
Logger:Line()
Logger:Info("Loading External Features...")

local FeatureList = {
    {"Aimbot/Silent",      "Features/Aimbot/Silent.lua",      AimbotTab},
    {"Aimbot/FOV",         "Features/Aimbot/FOV.lua",         AimbotTab},
    {"Aimbot/Trigger",     "Features/Aimbot/Trigger.lua",     AimbotTab},
    {"Aimbot/Prediction",  "Features/Aimbot/Prediction.lua",  AimbotTab},
    {"Visuals/ESP",        "Features/Visuals/ESP.lua",        VisualsTab},
    {"Visuals/Boxes",      "Features/Visuals/Boxes.lua",      VisualsTab},
    {"Visuals/Skeletons",  "Features/Visuals/Skeletons.lua",  VisualsTab},
    {"Visuals/Chams",      "Features/Visuals/Chams.lua",      VisualsTab},
    {"Visuals/World",      "Features/Visuals/World.lua",      VisualsTab},
    {"Movement/Speed",     "Features/Movement/Speed.lua",     MovementTab},
    {"Movement/Fly",       "Features/Movement/Fly.lua",       MovementTab},
    {"Movement/Jump",      "Features/Movement/Jump.lua",      MovementTab},
    {"Movement/Teleport",  "Features/Movement/Teleport.lua",  MovementTab},
    {"Utility/AntiAFK",    "Features/Utility/AntiAFK.lua",    UtilityTab},
    {"Utility/AutoFarm",   "Features/Utility/AutoFarm.lua",   UtilityTab},
    {"Utility/StreamSniper","Features/Utility/StreamSniper.lua", UtilityTab},
    {"Utility/WhiteScreen","Features/Utility/WhiteScreen.lua", UtilityTab},
}

local loadedCount = 0
local skippedCount = 0

for _, feat in ipairs(FeatureList) do
    local name, path, tab = feat[1], feat[2], feat[3]
    local module = LoadModule(path, false)
    if module then
        if module.Init and type(module.Init) == "function" then
            local ok, err = pcall(function()
                module:Init(tab, WindUI, Flags)
            end)
            if ok then
                loadedCount = loadedCount + 1
            else
                Logger:Fail("Init error in " .. name .. ": " .. tostring(err))
            end
        else
            loadedCount = loadedCount + 1
        end
    else
        skippedCount = skippedCount + 1
    end
end

Logger:Line()
Logger:Info("LOADING COMPLETE")
Logger:Info("---------------------")
Logger:Good("Loaded:  " .. loadedCount .. " features")
if skippedCount > 0 then
    Logger:Skip("Skipped: " .. skippedCount .. " features")
    Logger:Info("Skipped files:")
    for _, s in ipairs(Skipped) do
        Logger:Skip("  -> " .. s.Name)
    end
end
Logger:Info("---------------------")

-- =============================================
-- CONFIG TAB
-- =============================================
ConfigTab:CreateSection("Configuration")
ConfigTab:CreateButton({
    Name = "Save Config",
    Callback = function()
        Config:Save()
        WindUI:Notify({ Title = "Hyper", Content = "Configuration saved!", Duration = 3 })
    end
})
ConfigTab:CreateButton({
    Name = "Load Config",
    Callback = function()
        local data = Config:Load()
        if data then
            WindUI:Notify({ Title = "Hyper", Content = "Configuration loaded!", Duration = 3 })
        else
            WindUI:Notify({ Title = "Hyper", Content = "No config file found!", Duration = 3 })
        end
    end
})
ConfigTab:CreateButton({
    Name = "Delete Config",
    Callback = function()
        Config:Delete()
        WindUI:Notify({ Title = "Hyper", Content = "Configuration deleted!", Duration = 3 })
    end
})

-- =============================================
-- FINALIZE
-- =============================================
Window:LoadConfiguration()
WindUI:Notify({ Title = "Hyper UI", Content = "All modules loaded!", Duration = 5 })

print("")
print("  ==========================================")
print("    HYPER UI v1.0.0 - READY")
print("    By M4X | EVA | AMAL")
print("  ==========================================")
print("")
