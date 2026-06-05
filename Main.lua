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
-- HOME TAB CONTENT
-- =============================================
-- =============================================
-- HOME TAB (PROFESSIONAL INTRO UI - WIND UI)
-- =============================================
if Tabs.Home then

    local introSection = Tabs.Home:Section({
        Title = "Hyper v1.0.0",
        Icon = "sparkles",
        Opened = true
    })

    introSection:Label({
        Title = "Welcome to Hyper",
        Description = "A clean, optimized UI framework built for performance and simplicity."
    })

    introSection:Label({
        Title = "Script Name: Hyper v1.0.0",
    })

    introSection:Label({
        Title = "By: M4X • EVA • AMAL",
    })

    introSection:Label({
        Title = "User: " .. (LocalPlayer and LocalPlayer.Name or "Unknown"),
    })


    local actions = Tabs.Home:Section({
        Title = "Quick Panel",
        Icon = "bolt"
    })

    actions:Button({
        Title = "Rejoin Server",
        Description = "Reconnect to the current session",
        Callback = function()
            if TeleportService and LocalPlayer then
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end
        end
    })

    actions:Button({
        Title = "Clear Workspace",
        Description = "Remove unnecessary objects safely",
        Callback = function()
            local removed = 0

            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:IsA("Model") and obj ~= LocalPlayer.Character then
                    pcall(function()
if Tabs.Home then

    local introSection = Tabs.Home:Section({
        Title = "Hyper v1.0.0",
        Icon = "sparkles",
        Opened = true
    })

    introSection:Label({
        Title = "Welcome to Hyper"
    })

    introSection:Label({
        Title = "By: M4X • EVA • AMAL"
    })

    introSection:Label({
        Title = "User: " .. (LocalPlayer and LocalPlayer.Name or "Unknown")
    })

    local actions = Tabs.Home:Section({
        Title = "Quick Panel",
        Icon = "bolt"
    })

    actions:Button({
        Title = "Rejoin Server",
        Callback = function()
            if TeleportService and LocalPlayer then
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end
        end
    })

    actions:Button({
        Title = "Clear Workspace",
        Callback = function()
            local removed = 0
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:IsA("Model") then
                    pcall(function()
                        obj:Destroy()
                        removed += 1
                    end)
                end
            end
        end
    })

    local profile = Tabs.Home:Section({
        Title = "Profile Card",
        Icon = "user",
        Opened = true
    })

    local function getPing()
        local ok, result = pcall(function()
            return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
        end)

        if ok and result then
            return math.floor(result) .. " ms"
        end

        return "N/A"
    end

    profile:Label({
        Title = "👤 " .. (LocalPlayer and LocalPlayer.Name or "Unknown")
    })

    profile:Label({
        Title = "📶 Ping: " .. getPing()
    })

    profile:Button({
        Title = "Copy Username",
        Callback = function()
            if setclipboard and LocalPlayer then
                setclipboard(LocalPlayer.Name)
            end
        end
    })

end

Logger:Good("Hyper UI Home loaded successfully!")
-- =============================================
-- LOAD EXTERNAL FEATURE MODULES
-- =============================================
Logger:Separator()
Logger:Info("Loading External Feature Modules...")

local FeatureList = {
    -- Core Systems
    { Path = "Core/Themes.lua",        Tab = "Utility",  Name = "Themes System" },
    { Path = "Core/Settings.lua",      Tab = "Utility",  Name = "UI Settings" },
    
    -- Aimbot Features
    { Path = "Features/Aimbot/Silent.lua",      Tab = "Aimbot",   Name = "Silent Aim" },
    { Path = "Features/Aimbot/FOV.lua",         Tab = "Aimbot",   Name = "FOV Circle" },
    { Path = "Features/Aimbot/Trigger.lua",     Tab = "Aimbot",   Name = "Trigger Bot" },
    { Path = "Features/Aimbot/Prediction.lua",  Tab = "Aimbot",   Name = "Prediction" },
    
    -- Visuals Features
    { Path = "Features/Visuals/ESP.lua",        Tab = "Visuals",  Name = "ESP" },
    
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

ModuleLoader.Stats = { Total = 0, Loaded = 0, Failed = 0, Skipped = 0 }
ModuleLoader.Loaded = {}
ModuleLoader.Failed = {}
ModuleLoader.Skipped = {}

FeatureInitializer.Initialized = {}
FeatureInitializer.Failed = {}
FeatureInitializer.Skipped = {}

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
            Logger:Skip("No tab: " .. feature.Name)
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
