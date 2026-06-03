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
    ╚══════════════════════════════════════════════════════════════╝
--]]

-- =============================================
-- LOAD WIND UI FIRST
-- =============================================
-- القديم (غلط):

-- الجديد (صح):
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

print("[Hyper] [+] WindUI loaded successfully!")

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
-- LOGGER SYSTEM (300+ lines of logging)
-- =============================================
local Logger = {
    History = {},
    MaxHistory = 500,
    StartTime = os.clock(),
    ColorMap = {
        INFO  = "white",
        OK    = "green",
        WARN  = "yellow",
        ERROR = "red",
        SKIP  = "orange",
        DEAD  = "darkred",
        DEBUG = "cyan",
        TRACE = "gray",
    }
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
function Logger:Debug(msg)   return self:Log("DEBUG", "?", msg) end
function Logger:Trace(msg)   return self:Log("TRACE", "-", msg) end
function Logger:Blank()      print("") end

function Logger:Separator(char)
    char = char or "─"
    print("[Hyper] " .. string.rep(char, 55))
end

function Logger:DoubleSeparator()
    print("[Hyper] " .. string.rep("═", 55))
end

function Logger:Header(title)
    local len = #title
    local pad = string.rep(" ", 4)
    self:Blank()
    self:DoubleSeparator()
    print("[Hyper] ║" .. pad .. title .. string.rep(" ", 55 - len - #pad - 2) .. "║")
    self:DoubleSeparator()
    self:Blank()
end

function Logger:SubHeader(title)
    self:Separator("-")
    print("[Hyper] │ " .. title)
    self:Separator("-")
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

function Logger:List(items, prefix)
    prefix = prefix or "→"
    for _, item in ipairs(items) do
        print("[Hyper]     " .. prefix .. " " .. tostring(item))
    end
end

function Logger:Summary()
    local counts = { Errors = 0, Skips = 0, Success = 0, Info = 0, Warns = 0 }
    for _, entry in ipairs(self.History) do
        if entry.Level == "ERROR" or entry.Level == "DEAD" then
            counts.Errors = counts.Errors + 1
        elseif entry.Level == "SKIP" then
            counts.Skips = counts.Skips + 1
        elseif entry.Level == "OK" then
            counts.Success = counts.Success + 1
        elseif entry.Level == "WARN" then
            counts.Warns = counts.Warns + 1
        elseif entry.Level == "INFO" then
            counts.Info = counts.Info + 1
        end
    end
    return counts
end

function Logger:PrintSummary()
    local s = self:Summary()
    self:Separator("═")
    print("[Hyper] ║  EXECUTION SUMMARY")
    self:Separator("-")
    print("[Hyper] ║  ✓ Success: " .. s.Success)
    print("[Hyper] ║  ℹ Info:    " .. s.Info)
    print("[Hyper] ║  ⚠ Warns:   " .. s.Warns)
    print("[Hyper] ║  ✗ Errors:  " .. s.Errors)
    print("[Hyper] ║  ⏭ Skips:   " .. s.Skips)
    print("[Hyper] ║  ─ Total:   " .. self:GetTotalEntries())
    self:Separator("═")
    self:Blank()
end

function Logger:GetTotalEntries()
    return #self.History
end

function Logger:GetErrors()
    local errors = {}
    for _, entry in ipairs(self.History) do
        if entry.Level == "ERROR" or entry.Level == "DEAD" then
            table.insert(errors, entry)
        end
    end
    return errors
end

function Logger:GetSkipped()
    local skipped = {}
    for _, entry in ipairs(self.History) do
        if entry.Level == "SKIP" then
            table.insert(skipped, entry)
        end
    end
    return skipped
end

function Logger:ExportToString()
    local lines = {}
    for _, entry in ipairs(self.History) do
        table.insert(lines, string.format("[%s] [%s] %s", entry.Timestamp, entry.Icon, entry.Message))
    end
    return table.concat(lines, "\n")
end

function Logger:Clear()
    self.History = {}
end

function Logger:GetRecent(count)
    count = count or 10
    local start = math.max(1, #self.History - count + 1)
    local recent = {}
    for i = start, #self.History do
        table.insert(recent, self.History[i])
    end
    return recent
end

function Logger:PrintRecent(count)
    local recent = self:GetRecent(count)
    self:SubHeader("Recent Logs (Last " .. #recent .. ")")
    for _, entry in ipairs(recent) do
        print(string.format("[Hyper]   [%s] [%s] %s", entry.Timestamp, entry.Icon, entry.Message))
    end
    self:Separator("-")
end

-- =============================================
-- SAFE CALL SYSTEM
-- =============================================
local SafeCall = {}
SafeCall.__index = SafeCall

function SafeCall:New(context)
    local sc = {
        Context = context or "Unknown",
        ErrorCount = 0,
        SuccessCount = 0,
        CallCount = 0,
    }
    setmetatable(sc, self)
    return sc
end

function SafeCall:Execute(func, ...)
    self.CallCount = self.CallCount + 1
    local args = {...}
    local results = {}
    
    local ok, err = pcall(function()
        results = { func(unpack(args)) }
    end)
    
    if not ok then
        self.ErrorCount = self.ErrorCount + 1
        Logger:Error(string.format("[%s] Failed: %s", self.Context, tostring(err)))
        return false, err
    end
    
    self.SuccessCount = self.SuccessCount + 1
    return true, unpack(results)
end

function SafeCall:Wrap(func)
    local self = self
    return function(...)
        return self:Execute(func, ...)
    end
end

function SafeCall:GetStats()
    return {
        Context = self.Context,
        Calls = self.CallCount,
        Successes = self.SuccessCount,
        Errors = self.ErrorCount,
    }
end

-- =============================================
-- MODULE LOADER SYSTEM
-- =============================================
local ModuleLoader = {
    Loaded = {},
    Failed = {},
    Skipped = {},
    Stats = {
        Total = 0,
        Loaded = 0,
        Failed = 0,
        Skipped = 0,
    },
    MaxRetries = 2,
}

function ModuleLoader:Reset()
    self.Loaded = {}
    self.Failed = {}
    self.Skipped = {}
    self.Stats = { Total = 0, Loaded = 0, Failed = 0, Skipped = 0 }
end

function ModuleLoader:LoadFromURL(url, moduleName, required, retryCount)
    retryCount = retryCount or 0
    self.Stats.Total = self.Stats.Total + 1
    
    Logger:Info("Loading: " .. moduleName .. (required and " [REQUIRED]" or " [OPTIONAL]"))
    
    -- HTTP Request
    local httpOk, content = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not httpOk then
        local errMsg = tostring(content)
        if retryCount < self.MaxRetries then
            Logger:Warn("Retrying " .. moduleName .. " (" .. (retryCount + 1) .. "/" .. self.MaxRetries .. ")")
            task.wait(1)
            return self:LoadFromURL(url, moduleName, required, retryCount + 1)
        end
        
        if required then
            Logger:Dead("NETWORK FAILURE: " .. moduleName .. " - " .. errMsg)
            self.Stats.Failed = self.Stats.Failed + 1
            table.insert(self.Failed, { Name = moduleName, Reason = "Network: " .. errMsg, Required = true })
            return nil
        else
            Logger:Skip("Network: " .. moduleName)
            self.Stats.Skipped = self.Stats.Skipped + 1
            table.insert(self.Skipped, { Name = moduleName, Reason = "Network", Required = false })
            return nil
        end
    end
    
    -- Syntax Check
    local chunk, syntaxErr = loadstring(content)
    if not chunk then
        if required then
            Logger:Dead("SYNTAX FAILURE: " .. moduleName .. " - " .. tostring(syntaxErr))
            self.Stats.Failed = self.Stats.Failed + 1
            table.insert(self.Failed, { Name = moduleName, Reason = "Syntax: " .. tostring(syntaxErr), Required = true })
            return nil
        else
            Logger:Skip("Syntax: " .. moduleName)
            self.Stats.Skipped = self.Stats.Skipped + 1
            table.insert(self.Skipped, { Name = moduleName, Reason = "Syntax", Required = false })
            return nil
        end
    end
    
    -- Runtime Execution
    local runOk, result = pcall(chunk)
    if not runOk then
        if required then
            Logger:Dead("RUNTIME FAILURE: " .. moduleName .. " - " .. tostring(result))
            self.Stats.Failed = self.Stats.Failed + 1
            table.insert(self.Failed, { Name = moduleName, Reason = "Runtime: " .. tostring(result), Required = true })
            return nil
        else
            Logger:Skip("Runtime: " .. moduleName)
            self.Stats.Skipped = self.Stats.Skipped + 1
            table.insert(self.Skipped, { Name = moduleName, Reason = "Runtime", Required = false })
            return nil
        end
    end
    
    Logger:Good("Loaded: " .. moduleName)
    self.Stats.Loaded = self.Stats.Loaded + 1
    table.insert(self.Loaded, { Name = moduleName, Module = result, Required = required })
    return result
end

function ModuleLoader:LoadFromRepo(path, required)
    local name = path:match("([^/]+)%.lua$") or path
    local url = REPO_URL .. path
    return self:LoadFromURL(url, name, required)
end

function ModuleLoader:HasFailures()
    for _, fail in ipairs(self.Failed) do
        if fail.Required then
            return true
        end
    end
    return false
end

function ModuleLoader:PrintReport()
    Logger:SubHeader("Module Loader Report")
    Logger:KeyValue("Total Attempted", self.Stats.Total)
    Logger:KeyValue("Successfully Loaded", self.Stats.Loaded)
    Logger:KeyValue("Failed", self.Stats.Failed)
    Logger:KeyValue("Skipped", self.Stats.Skipped)
    
    if #self.Failed > 0 then
        Logger:Separator("-")
        Logger:Warn("Failed Modules:")
        for _, f in ipairs(self.Failed) do
            Logger:List({f.Name .. " → " .. f.Reason}, "✗")
        end
    end
    
    if #self.Skipped > 0 then
        Logger:Separator("-")
        Logger:Info("Skipped Modules:")
        for _, s in ipairs(self.Skipped) do
            Logger:List({s.Name .. " → " .. s.Reason}, "⏭")
        end
    end
end

-- =============================================
-- FEATURE INITIALIZER
-- =============================================
local FeatureInitializer = {
    Initialized = {},
    Failed = {},
    Skipped = {},
}

function FeatureInitializer:Reset()
    self.Initialized = {}
    self.Failed = {}
    self.Skipped = {}
end

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
})

Logger:SubHeader("Environment Check")

-- Check Player
if LocalPlayer then
    Logger:Good("Player: " .. LocalPlayer.Name)
else
    Logger:Dead("Player not found!")
end

-- Check Place
if Services.Players then
    Logger:Info("Place ID: " .. game.PlaceId)
    Logger:Info("Place Name: " .. (game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown"))
end

-- Check Executor
local executorName = "Unknown"
pcall(function()
    executorName = identifyexecutor and identifyexecutor() or getexecutorname and getexecutorname() or "Unknown"
end)
Logger:Info("Executor: " .. executorName)

-- Check Services
if #ServicesFailed > 0 then
    Logger:Warn("Failed Services:")
    Logger:List(ServicesFailed, "✗")
else
    Logger:Good("All services loaded")
end

Logger:Separator()

-- =============================================
-- FLAGS SYSTEM (FALLBACK)
-- =============================================
local Flags = {}
local FlagStorage = {}

function Flags:Create(name, default)
    if FlagStorage[name] then
        return FlagStorage[name]
    end
    
    local flag = {
        Name = name,
        Value = default,
        Connections = {},
    }
    
    function flag:Get()
        return self.Value
    end
    
    function flag:Set(newValue)
        local old = self.Value
        self.Value = newValue
        for _, cb in ipairs(self.Connections) do
            local ok, _ = pcall(cb, newValue, old)
            if not ok then
                -- Silently ignore callback errors
            end
        end
    end
    
    function flag:Toggle()
        self:Set(not self.Value)
    end
    
    function flag:Connect(callback)
        table.insert(self.Connections, callback)
        return {
            Disconnect = function()
                for i, cb in ipairs(self.Connections) do
                    if cb == callback then
                        table.remove(self.Connections, i)
                        break
                    end
                end
            end
        }
    end
    
    FlagStorage[name] = flag
    return flag
end

function Flags:Get(name)
    return FlagStorage[name]
end

function Flags:Set(name, value)
    local flag = FlagStorage[name]
    if flag then
        flag:Set(value)
    end
end

function Flags:GetValue(name)
    local flag = FlagStorage[name]
    return flag and flag:Get() or nil
end

function Flags:GetAll()
    local data = {}
    for name, flag in pairs(FlagStorage) do
        data[name] = flag:Get()
    end
    return data
end

function Flags:Import(data)
    if type(data) ~= "table" then return end
    for name, value in pairs(data) do
        self:Set(name, value)
    end
end

function Flags:Export()
    return self:GetAll()
end

function Flags:Count()
    local count = 0
    for _ in pairs(FlagStorage) do
        count = count + 1
    end
    return count
end

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
        
        ConfigurationSaving = {
            Enabled = false
        },
        
        Discord = {
            Enabled = false
        },
        
        KeySystem = false,
    })
    windowCreated = true
end)

if not windowCreated then
    Logger:Dead("Failed to create window: " .. tostring(windowError))
    Logger:Dead("Attempting simplified window creation...")
    
    -- Fallback: simplified window
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
        Logger:Good("Simplified window created successfully!")
    end)
end

if not windowCreated or not Window then
    Logger:Dead("CRITICAL: Cannot create window. Aborting.")
    Logger:PrintSummary()
    return
end

Logger:Good("Window created successfully!")

-- =============================================
-- CREATE TABS
-- =============================================
Logger:Info("Creating tabs...")

local Tabs = {}
local tabsCreated = 0
local tabsFailed = 0

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
        tabsCreated = tabsCreated + 1
        Logger:Good("Tab created: " .. tabDef.Name)
    else
        tabsFailed = tabsFailed + 1
        Logger:Skip("Tab failed: " .. tabDef.Name .. " - " .. tostring(tab))
    end
end

Logger:Info(string.format("Tabs: %d created, %d failed", tabsCreated, tabsFailed))

-- =============================================
-- HOME TAB CONTENT
-- =============================================
if Tabs.Home then
    Logger:Info("Building Home tab...")
    
    local homeSection = Tabs.Home:Section({ Title = "Welcome", Icon = "info", Opened = true })
    
    pcall(function()
        Tabs.Home:Label({ Title = "Hyper UI Framework v1.0.0" })
        Tabs.Home:Label({ Title = "By M4X | EVA | AMAL" })
        Tabs.Home:Label({ Title = "Welcome, " .. (LocalPlayer and LocalPlayer.Name or "User") .. "!" })
    end)
    
    local quickSection = Tabs.Home:Section({ Title = "Quick Actions", Icon = "activity" })
    
    pcall(function()
        quickSection:Button({
            Title = "Rejoin Server",
            Description = "Rejoin the current server",
            Icon = "rotate-cw",
            Callback = function()
                if TeleportService and LocalPlayer then
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                end
            end
        })
    end)
    
    pcall(function()
        quickSection:Button({
            Title = "Clean Workspace",
            Description = "Remove all unnecessary objects",
            Icon = "trash-2",
            Callback = function()
                local count = 0
                for _, obj in ipairs(workspace:GetChildren()) do
                    if obj:IsA("Model") and obj ~= LocalPlayer and obj ~= LocalPlayer.Character then
                        pcall(function() obj:Destroy() end)
                        count = count + 1
                    end
                end
                WindUI:Notify({ Title = "Hyper", Description = "Cleaned " .. count .. " objects!", Duration = 3 })
            end
        })
    end)
    
    pcall(function()
        quickSection:Button({
            Title = "Destroy UI",
            Description = "Close and destroy the interface",
            Icon = "x",
            Callback = function()
                pcall(function() Window:Destroy() end)
            end
        })
    end)
    
    local toggleSection = Tabs.Home:Section({ Title = "Toggles", Icon = "toggle-left" })
    
    pcall(function()
        toggleSection:Toggle({
            Title = "Auto Updater",
            Description = "Automatically check for updates",
            Value = true,
            Callback = function(state)
                Flags:Set("AutoUpdater", state)
            end
        })
    end)
    
    pcall(function()
        toggleSection:Toggle({
            Title = "Anti AFK",
            Description = "Prevent being kicked for inactivity",
            Value = false,
            Callback = function(state)
                Flags:Set("AntiAFK", state)
            end
        })
    end)
    
    Logger:Good("Home tab built!")
else
    Logger:Error("Home tab not available, skipping content creation.")
end

-- =============================================
-- LOAD EXTERNAL FEATURE MODULES
-- =============================================
Logger:Separator()
Logger:Info("Loading External Feature Modules...")

local FeatureList = {
    -- Core Systems
    { Path = "Core/Themes.lua",        Tab = "Utility",  Name = "Themes System" },
    { Path = "Core/Settings.lua",     Tab = "Utility",  Name = "UI Settings" },
    
    -- Aimbot Features
    { Path = "Features/Aimbot/Silent.lua",      Tab = "Aimbot",   Name = "Silent Aim" },
    { Path = "Features/Aimbot/FOV.lua",         Tab = "Aimbot",   Name = "FOV Circle" },
    { Path = "Features/Aimbot/Trigger.lua",     Tab = "Aimbot",   Name = "Trigger Bot" },
    { Path = "Features/Aimbot/Prediction.lua",  Tab = "Aimbot",   Name = "Prediction" },
    
    -- Visuals Features
    { Path = "Features/Visuals/ESP.lua",        Tab = "Visuals",  Name = "ESP" },
    { Path = "Features/Visuals/Boxes.lua",      Tab = "Visuals",  Name = "Boxes" },
    { Path = "Features/Visuals/Skeletons.lua",  Tab = "Visuals",  Name = "Skeletons" },
    { Path = "Features/Visuals/Chams.lua",      Tab = "Visuals",  Name = "Chams" },
    { Path = "Features/Visuals/World.lua",      Tab = "Visuals",  Name = "World" },
    
    -- Movement Features
    { Path = "Features/Movement/Speed.lua",     Tab = "Movement", Name = "Speed" },
    { Path = "Features/Movement/Fly.lua",       Tab = "Movement", Name = "Fly" },
    { Path = "Features/Movement/Jump.lua",      Tab = "Movement", Name = "Jump" },
    { Path = "Features/Movement/Teleport.lua",  Tab = "Movement", Name = "Teleport" },
    
    -- Utility Features
    { Path = "Features/Utility/AntiAFK.lua",    Tab = "Utility",  Name = "Anti AFK" },
    { Path = "Features/Utility/AutoFarm.lua",   Tab = "Utility",  Name = "Auto Farm" },
    { Path = "Features/Utility/StreamSniper.lua", Tab = "Utility", Name = "Stream Sniper" },
    { Path = "Features/Utility/WhiteScreen.lua", Tab = "Utility",  Name = "White Screen" },
}


ModuleLoader:Reset()
FeatureInitializer:Reset()

local featureStats = { Loaded = 0, Failed = 0, Skipped = 0, Total = #FeatureList }

for _, feature in ipairs(FeatureList) do
    local module = ModuleLoader:LoadFromRepo(feature.Path, false)
    
    if module then
        local tab = Tabs[feature.Tab]
        if tab then
            local initOk = FeatureInitializer:InitFeature(module, tab, WindUI, Flags, feature.Name)
            if initOk then
                featureStats.Loaded = featureStats.Loaded + 1
            else
                featureStats.Failed = featureStats.Failed + 1
            end
        else
            Logger:Skip("No tab for: " .. feature.Name .. " (Tab: " .. feature.Tab .. " not found)")
            featureStats.Skipped = featureStats.Skipped + 1
        end
    else
        featureStats.Skipped = featureStats.Skipped + 1
    end
end

-- =============================================
-- FINAL REPORT
-- =============================================
Logger:Separator("═")
Logger:Box("Loading Report", {
    "Total Features: " .. featureStats.Total,
    "Successfully Loaded: " .. featureStats.Loaded,
    "Failed: " .. featureStats.Failed,
    "Skipped: " .. featureStats.Skipped,
})

ModuleLoader:PrintReport()

Logger:Info("Total Flags Registered: " .. Flags:Count())

Logger:PrintSummary()

-- =============================================
-- DONE
-- =============================================
pcall(function()
    WindUI:Notify({
        Title = "Hyper UI",
        Description = string.format("Ready! %d/%d features loaded.", featureStats.Loaded, featureStats.Total),
        Duration = 5
    })
end)

Logger:Box("HYPER UI READY", {
    "Version: v1.0.0",
    "By M4X | EVA | AMAL",
    "Features Active: " .. featureStats.Loaded .. "/" .. featureStats.Total,
})

print("")
print("  ╔══════════════════════════════════════════╗")
print("  ║       HYPER UI v1.0.0 - ACTIVE          ║")
print("  ║     By M4X | EVA | AMAL                ║")
print("  ╚══════════════════════════════════════════╝")
print("")

-- =============================================
-- RETURN VALUES
-- =============================================
return {
    Window = Window,
    WindUI = WindUI,
    Flags = Flags,
    Logger = Logger,
    ModuleLoader = ModuleLoader,
    FeatureInitializer = FeatureInitializer,
    Tabs = Tabs,
    Services = Services,
}
