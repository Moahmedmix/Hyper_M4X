--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                    HYPER UI - v1.0.0                         ║
    ║               By M4X | EVA | AMAL                           ║
    ║         Repository: github.com/Moahmedmix/Hyper_M4X          ║
    ║                                                              ║
    ║  Features:                                                   ║
    ║  - Full Protection & Error Handling                          ║
    ║  - Skip failed modules automatically                         ║
    ║  - Detailed console logging system                           ║
    ║  - WindUI official integration                               ║
    ║  - External feature loader with fallbacks                    ║
    ║  - Thread-safe module initialization                         ║
    ║  - Auto-recovery from failures                               ║
    ║  - Key System: MIX-M4X                                       ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

-- =============================================
-- LOAD WIND UI FIRST
-- =============================================
local WindUI = nil
local windOk, windResult = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if windOk and windResult then
    WindUI = windResult
    print("[Hyper] [+] WindUI loaded successfully!")
else
    warn("[Hyper] [X] WindUI failed: " .. tostring(windResult))
    return
end

-- =============================================
-- ENVIRONMENT SETUP
-- =============================================
local Services = {}
local ServicesFailed = {}

local requiredServices = {
    "Players", "TeleportService", "HttpService", "RunService",
    "UserInputService", "TweenService", "CoreGui", "ReplicatedStorage",
    "Workspace", "Lighting", "StarterGui"
}

for _, name in ipairs(requiredServices) do
    local ok, service = pcall(function() return game:GetService(name) end)
    if ok and service then
        Services[name] = service
    else
        table.insert(ServicesFailed, name)
    end
end

local Players = Services.Players
local LocalPlayer = Players and Players.LocalPlayer
local HttpService = Services.HttpService
local TeleportService = Services.TeleportService
local RunService = Services.RunService
local TweenService = Services.TweenService
local UserInputService = Services.UserInputService
local CoreGui = Services.CoreGui

local REPO_URL = "https://raw.githubusercontent.com/Moahmedmix/Hyper_M4X/main/"

-- =============================================
-- KEY SYSTEM
-- =============================================
local VALID_KEYS = {
    "MIX-M4X",
    "MIX-M4X-2024",
    "MIX-M4X-PRO",
    "HYPER-M4X",
    "EVA-M4X",
    "AMAL-M4X",
}

local function CheckKey()
    local savedKey = nil
    if readfile and isfile and isfolder and writefile then
        local folder = "Hyper_M4X"
        if not isfolder(folder) then makefolder(folder) end
        local keyFile = folder .. "/key.txt"
        if isfile(keyFile) then
            savedKey = readfile(keyFile)
            savedKey = savedKey:gsub("%s+", "")
        end
    end
    
    if savedKey then
        for _, validKey in ipairs(VALID_KEYS) do
            if savedKey == validKey then
                return true
            end
        end
    end
    
    return false
end

local function SaveKey(key)
    if writefile and isfolder and makefolder then
        local folder = "Hyper_M4X"
        if not isfolder(folder) then makefolder(folder) end
        writefile(folder .. "/key.txt", key)
    end
end

-- =============================================
-- LOGGER SYSTEM
-- =============================================
local Logger = {
    History = {},
    MaxHistory = 500,
    StartTime = os.clock(),
}

function Logger:GetTimestamp()
    return string.format("%.3f", os.clock() - self.StartTime)
end

function Logger:GetFormattedTime()
    return os.date("%H:%M:%S")
end

function Logger:Log(level, icon, message)
    local timestamp = self:GetTimestamp()
    local formatted = string.format("[%s] [Hyper] [%s] %s", timestamp, icon, message)
    
    if level == "ERROR" or level == "DEAD" then
        warn(formatted)
    else
        print(formatted)
    end
    
    local entry = {
        Level = level,
        Icon = icon,
        Message = message,
        Timestamp = timestamp,
        Time = self:GetFormattedTime(),
        Epoch = os.time(),
    }
    
    table.insert(self.History, entry)
    
    if #self.History > self.MaxHistory then
        table.remove(self.History, 1)
    end
    
    return entry
end

function Logger:Info(msg)    return self:Log("INFO",  "i", msg) end
function Logger:Good(msg)    return self:Log("OK",    "+", msg) end
function Logger:Warn(msg)    return self:Log("WARN",  "!", msg) end
function Logger:Error(msg)   return self:Log("ERROR", "x", msg) end
function Logger:Skip(msg)    return self:Log("SKIP",  ">", msg) end
function Logger:Dead(msg)    return self:Log("DEAD",  "X", msg) end
function Logger:Blank()      print("") end

function Logger:Separator(char)
    char = char or "─"
    print("[Hyper] " .. string.rep(char, 55))
end

function Logger:DoubleSeparator()
    print("[Hyper] " .. string.rep("═", 55))
end

function Logger:Header(title)
    self:Blank()
    self:DoubleSeparator()
    print("[Hyper] ║" .. string.rep(" ", 4) .. title)
    self:DoubleSeparator()
    self:Blank()
end

function Logger:Box(title, lines)
    self:Blank()
    self:Separator("═")
    print("[Hyper] ║  " .. title)
    self:Separator("═")
    if lines then
        for _, line in ipairs(lines) do
            print("[Hyper] ║    " .. line)
        end
        self:Separator("═")
    end
    self:Blank()
end

function Logger:KeyValue(key, value)
    print("[Hyper]   " .. key .. ": " .. tostring(value))
end

function Logger:PrintSummary()
    local counts = { Errors = 0, Skips = 0, Success = 0, Info = 0 }
    for _, entry in ipairs(self.History) do
        if entry.Level == "ERROR" or entry.Level == "DEAD" then counts.Errors = counts.Errors + 1
        elseif entry.Level == "SKIP" then counts.Skips = counts.Skips + 1
        elseif entry.Level == "OK" then counts.Success = counts.Success + 1
        elseif entry.Level == "INFO" then counts.Info = counts.Info + 1 end
    end
    self:Separator("═")
    print("[Hyper] ║  EXECUTION SUMMARY")
    self:Separator("-")
    print("[Hyper] ║  + Success: " .. counts.Success)
    print("[Hyper] ║  i Info:    " .. counts.Info)
    print("[Hyper] ║  x Errors:  " .. counts.Errors)
    print("[Hyper] ║  > Skips:   " .. counts.Skips)
    self:Separator("═")
    self:Blank()
end

-- =============================================
-- MODULE LOADER SYSTEM
-- =============================================
local ModuleLoader = {
    Loaded = {},
    Failed = {},
    Skipped = {},
    Stats = { Total = 0, Loaded = 0, Failed = 0, Skipped = 0 },
    MaxRetries = 2,
}

function ModuleLoader:LoadFromURL(url, moduleName, required, retryCount)
    retryCount = retryCount or 0
    self.Stats.Total = self.Stats.Total + 1
    
    Logger:Info("Loading: " .. moduleName .. (required and " [REQUIRED]" or " [OPTIONAL]"))
    
    local httpOk, content = pcall(function() return game:HttpGet(url) end)
    
    if not httpOk then
        if retryCount < self.MaxRetries then
            Logger:Warn("Retrying " .. moduleName .. " (" .. (retryCount + 1) .. "/" .. self.MaxRetries .. ")")
            task.wait(1)
            return self:LoadFromURL(url, moduleName, required, retryCount + 1)
        end
        
        if required then
            Logger:Dead("NETWORK FAILURE: " .. moduleName)
            self.Stats.Failed = self.Stats.Failed + 1
            table.insert(self.Failed, { Name = moduleName, Reason = "Network" })
            return nil
        else
            Logger:Skip("Network: " .. moduleName)
            self.Stats.Skipped = self.Stats.Skipped + 1
            table.insert(self.Skipped, { Name = moduleName, Reason = "Network" })
            return nil
        end
    end
    
    local chunk, syntaxErr = loadstring(content)
    if not chunk then
        if required then
            Logger:Dead("SYNTAX FAILURE: " .. moduleName)
            self.Stats.Failed = self.Stats.Failed + 1
            table.insert(self.Failed, { Name = moduleName, Reason = "Syntax" })
            return nil
        else
            Logger:Skip("Syntax: " .. moduleName)
            self.Stats.Skipped = self.Stats.Skipped + 1
            table.insert(self.Skipped, { Name = moduleName, Reason = "Syntax" })
            return nil
        end
    end
    
    local runOk, result = pcall(chunk)
    if not runOk then
        if required then
            Logger:Dead("RUNTIME FAILURE: " .. moduleName)
            self.Stats.Failed = self.Stats.Failed + 1
            table.insert(self.Failed, { Name = moduleName, Reason = "Runtime" })
            return nil
        else
            Logger:Skip("Runtime: " .. moduleName)
            self.Stats.Skipped = self.Stats.Skipped + 1
            table.insert(self.Skipped, { Name = moduleName, Reason = "Runtime" })
            return nil
        end
    end
    
    Logger:Good("Loaded: " .. moduleName)
    self.Stats.Loaded = self.Stats.Loaded + 1
    table.insert(self.Loaded, { Name = moduleName, Module = result })
    return result
end

function ModuleLoader:LoadFromRepo(path, required)
    local name = path:match("([^/]+)%.lua$") or path
    local url = REPO_URL .. path
    return self:LoadFromURL(url, name, required)
end

-- =============================================
-- FEATURE INITIALIZER
-- =============================================
local FeatureInitializer = {
    Initialized = {},
    Failed = {},
    Skipped = {},
}

function FeatureInitializer:InitFeature(module, tab, library, flags, name)
    if not module then
        table.insert(self.Skipped, { Name = name, Reason = "Module is nil" })
        return false
    end
    
    if not module.Init or type(module.Init) ~= "function" then
        table.insert(self.Skipped, { Name = name, Reason = "No Init function" })
        Logger:Skip("No Init: " .. name)
        return false
    end
    
    Logger:Info("Initializing: " .. name)
    
    local ok, err = pcall(function()
        module:Init(tab, library, flags)
    end)
    
    if not ok then
        Logger:Error("Init failed: " .. name .. " - " .. tostring(err))
        table.insert(self.Failed, { Name = name, Reason = tostring(err) })
        return false
    end
    
    Logger:Good("Initialized: " .. name)
    table.insert(self.Initialized, { Name = name, Module = module })
    return true
end

-- =============================================
-- STARTUP BANNER
-- =============================================
Logger:Header("HYPER UI v1.0.0")
Logger:Box("System Information", {
    "Framework: Hyper UI v1.0.0",
    "Authors: M4X | EVA | AMAL",
    "UI Library: WindUI",
    "Repository: github.com/Moahmedmix/Hyper_M4X",
    "Key System: MIX-M4X",
})

if LocalPlayer then
    Logger:Good("Player: " .. LocalPlayer.Name)
else
    Logger:Dead("Player not found!")
end

Logger:Info("Place ID: " .. game.PlaceId)
Logger:Info("Executor: " .. (pcall(function() return identifyexecutor() end) and identifyexecutor() or "Unknown"))

if #ServicesFailed > 0 then
    Logger:Warn("Failed Services: " .. table.concat(ServicesFailed, ", "))
else
    Logger:Good("All services loaded")
end

Logger:Separator()

-- =============================================
-- FLAGS SYSTEM
-- =============================================
local Flags = {}
local FlagStorage = {}

function Flags:Create(name, default)
    if FlagStorage[name] then return FlagStorage[name] end
    
    local flag = {
        Name = name,
        Value = default,
        Connections = {},
    }
    
    function flag:Get() return self.Value end
    function flag:Set(newValue)
        local old = self.Value
        self.Value = newValue
        for _, cb in ipairs(self.Connections) do
            pcall(cb, newValue, old)
        end
    end
    function flag:Toggle() self:Set(not self.Value) end
    function flag:Connect(callback)
        table.insert(self.Connections, callback)
        return { Disconnect = function()
            for i, cb in ipairs(self.Connections) do
                if cb == callback then table.remove(self.Connections, i) break end
            end
        end }
    end
    
    FlagStorage[name] = flag
    return flag
end

function Flags:Get(name) return FlagStorage[name] end
function Flags:Set(name, value) if FlagStorage[name] then FlagStorage[name]:Set(value) end end
function Flags:GetValue(name) return FlagStorage[name] and FlagStorage[name]:Get() or nil end
function Flags:Count()
    local count = 0
    for _ in pairs(FlagStorage) do count = count + 1 end
    return count
end

-- =============================================
-- KEY CHECK BEFORE WINDOW
-- =============================================
local keyValid = CheckKey()

if not keyValid then
    -- Show key input dialog
    local KeyWindow = WindUI:CreateWindow({
        Title = "Hyper - Key System",
        Author = "M4X | EVA | AMAL",
        Folder = "Hyper_Key",
        Icon = "key",
        Theme = "Dark",
        KeySystem = false,
    })
    
    local KeyTab = KeyWindow:Tab({ Title = "Key", Icon = "key" })
    local KeySec = KeyTab:Section({ Title = "Enter Key", Icon = "lock", Opened = true })
    
    KeySec:Textbox({
        Title = "Key",
        Description = "Enter your key (MIX-M4X)",
        Placeholder = "MIX-M4X",
        Callback = function(text)
            text = text:gsub("%s+", "")
            for _, validKey in ipairs(VALID_KEYS) do
                if text == validKey then
                    SaveKey(text)
                    WindUI:Notify({ Title = "Key System", Description = "Key Accepted! Restarting...", Duration = 3 })
                    task.wait(1)
                    loadstring(game:HttpGet(REPO_URL .. "Main.lua"))()
                    return
                end
            end
            WindUI:Notify({ Title = "Key System", Description = "Invalid Key!", Duration = 3 })
        end
    })
    
    KeySec:Button({
        Title = "Get Key",
        Description = "Join Discord for key",
        Callback = function()
            pcall(function() setclipboard("MIX-M4X") end)
            WindUI:Notify({ Title = "Key System", Description = "Key copied! Default: MIX-M4X", Duration = 5 })
        end
    })
    
    KeySec:Label({ Title = " " })
    KeySec:Label({ Title = "Default Key: MIX-M4X" })
    
    return
end

Logger:Good("Key verified: " .. (CheckKey() and "Valid" or "Invalid"))

-- =============================================
-- CREATE HYPER WINDOW
-- =============================================
Logger:Info("Creating Hyper UI Window...")

local Window = nil
local windowCreated = false

local windowSuccess, windowError = pcall(function()
    Window = WindUI:CreateWindow({
        Title = "Hyper",
        Author = "M4X | EVA | AMAL",
        Folder = "Hyper_M4X",
        Icon = "zap",
        Theme = "Dark",
        Size = UDim2.fromOffset(650, 480),
        MinSize = Vector2.new(500, 350),
        Resizable = true,
        SideBarWidth = 190,
        ToggleKey = Enum.KeyCode.RightShift,
        Transparent = false,
        ScrollBarEnabled = true,
        ConfigurationSaving = { Enabled = false },
        Discord = { Enabled = false },
        KeySystem = false,
    })
    windowCreated = true
end)

if not windowCreated then
    Logger:Dead("Failed to create window: " .. tostring(windowError))
    Logger:Dead("Attempting simplified window...")
    
    pcall(function()
        Window = WindUI:CreateWindow({
            Title = "Hyper",
            Author = "M4X | EVA | AMAL",
            Folder = "Hyper_M4X",
            Icon = "zap",
            Theme = "Dark",
            ConfigurationSaving = { Enabled = false },
            Discord = { Enabled = false },
            KeySystem = false,
        })
        windowCreated = true
        Logger:Good("Simplified window created!")
    end)
end

if not windowCreated or not Window then
    Logger:Dead("CRITICAL: Cannot create window. Aborting.")
    return
end

Logger:Good("Window created successfully!")

-- =============================================
-- CREATE TABS
-- =============================================
Logger:Info("Creating tabs...")

local Tabs = {}

local tabDefinitions = {
    { Name = "Home",     Icon = "home" },
    { Name = "Aimbot",   Icon = "crosshair" },
    { Name = "Visuals",  Icon = "eye" },
    { Name = "Movement", Icon = "zap" },
    { Name = "Utility",  Icon = "settings" },
}

for _, tabDef in ipairs(tabDefinitions) do
    local ok, tab = pcall(function()
        return Window:Tab({ Title = tabDef.Name, Icon = tabDef.Icon })
    end)
    
    if ok and tab then
        Tabs[tabDef.Name] = tab
        Logger:Good("Tab created: " .. tabDef.Name)
    else
        Logger:Skip("Tab failed: " .. tabDef.Name)
    end
end

-- =============================================
-- HOME TAB - Professional
-- =============================================
if Tabs.Home then
    -- Info Section
    local infoSec = Tabs.Home:Section({ Title = "Information", Icon = "info", Opened = true })
    infoSec:Button({ Title = "Hyper UI Framework v1.0.0", Description = "Advanced Roblox Utility", Callback = function() end })
    infoSec:Button({ Title = "By M4X | EVA | AMAL", Description = "Development Team", Callback = function() end })
    infoSec:Button({ Title = "Key: MIX-M4X", Description = "Premium Access", Callback = function() end })
    infoSec:Button({ Title = "Welcome, " .. (LocalPlayer and LocalPlayer.Name or "User") .. "!", Description = "Player: " .. (LocalPlayer and LocalPlayer.DisplayName or "Unknown"), Callback = function() end })

    -- Quick Actions
    local quickSec = Tabs.Home:Section({ Title = "Quick Actions", Icon = "zap", Opened = true })
    quickSec:Button({ Title = "Rejoin Server", Description = "Rejoin the current server", Callback = function()
        if TeleportService and LocalPlayer then TeleportService:Teleport(game.PlaceId, LocalPlayer) end
    end })
    quickSec:Button({ Title = "Clean Workspace", Description = "Remove unnecessary objects", Callback = function()
        local count = 0
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Model") and obj ~= LocalPlayer and obj ~= LocalPlayer.Character then
                pcall(function() obj:Destroy() end) count = count + 1
            end
        end
        WindUI:Notify({ Title = "Hyper", Description = "Cleaned " .. count .. " objects!", Duration = 3 })
    end })
    quickSec:Button({ Title = "Copy Discord Invite", Description = "Join our community", Callback = function()
        pcall(function() setclipboard("discord.gg/hyper") end)
        WindUI:Notify({ Title = "Hyper", Description = "Discord copied!", Duration = 3 })
    end })
    quickSec:Button({ Title = "Refresh UI", Description = "Reload the interface", Callback = function()
        loadstring(game:HttpGet(REPO_URL .. "Main.lua"))()
    end })
    quickSec:Button({ Title = "Destroy UI", Description = "Close Hyper UI", Callback = function()
        pcall(function() Window:Destroy() end)
    end })

    -- Toggles
    local toggleSec = Tabs.Home:Section({ Title = "Toggles", Icon = "toggle-left", Opened = true })
    toggleSec:Toggle({ Title = "Auto Updater", Description = "Check for updates automatically", Value = true, Callback = function(s) Flags:Set("AutoUpdater", s) end })
    toggleSec:Toggle({ Title = "Anti AFK", Description = "Prevent being kicked for inactivity", Value = false, Callback = function(s) Flags:Set("AntiAFK", s) end })
    toggleSec:Toggle({ Title = "White Screen", Description = "Toggle white screen mode", Value = false, Callback = function(s) Flags:Set("WhiteScreen", s) end })

    -- Stats
    local sta
