--[[
    ╔══════════════════════════════════════════════════╗
    ║           HYPER UI - Settings System              ║
    ║         Full Control Panel                        ║
    ║         By M4X | EVA | AMAL                      ║
    ╚══════════════════════════════════════════════════╝
--]]

local Settings = {}
Settings.__index = Settings

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = game:GetService("Players").LocalPlayer

Settings.Defaults = {
    -- UI Settings
    ToggleKey = "RightShift",
    Transparent = false,
    Resizable = true,
    ScrollBar = true,
    SidebarWidth = 190,
    
    -- ESP Defaults
    ESP_Enabled = false,
    ESP_MaxDist = 3000,
    ESP_TeamCheck = false,
    ESP_Rainbow = false,
    ESP_BoxColor = Color3.fromRGB(255, 255, 255),
    ESP_BoxThick = 2,
    ESP_CornerLen = 22,
    ESP_Name = true,
    ESP_Dist = true,
    ESP_HP = true,
    ESP_Tracer = false,
    ESP_Snap = false,
    
    -- Aimbot Defaults
    Aimbot_Enabled = false,
    Aimbot_FOV = 150,
    Aimbot_Smooth = 0.1,
    Aimbot_AutoShoot = false,
    Aimbot_WallCheck = true,
    Aimbot_TeamCheck = false,
    
    -- Movement Defaults
    Fly_Enabled = false,
    Fly_Speed = 50,
    Speed_Enabled = false,
    Speed_Value = 50,
    Jump_Enabled = false,
    Jump_Power = 100,
    
    -- Fling Defaults
    Fling_Power = 50,
    Fling_AntiVoid = true,
    
    -- Theme
    Theme = "Red Black",
    
    -- Config
    AutoSave = true,
    AutoSaveInterval = 30,
}

Settings.Current = {}

function Settings:Init(tab, library, flags)
    local self = setmetatable({}, Settings)
    self.Tab = tab
    self.Library = library
    self.Flags = flags

    -- Load defaults
    for k, v in pairs(Settings.Defaults) do
        if Settings.Current[k] == nil then
            Settings.Current[k] = v
        end
    end

    -- Register flags
    if flags then
        for k, v in pairs(Settings.Defaults) do
            flags:Create(k, v)
        end
    end

    self:BuildUI()
    return self
end

function Settings:BuildUI()
    if not self.Tab then return end

    -- ============ UI SETTINGS ============
    local uiSec = self.Tab:Section({ Title = "UI Settings", Icon = "settings", Opened = true })
    
    uiSec:Dropdown({ Title = "Toggle Key", Values = {"RightShift", "LeftShift", "RightControl", "LeftControl", "Insert", "Home", "End"}, Value = "RightShift", Callback = function(v)
        Settings.Current.ToggleKey = v
        if self.Flags then self.Flags:Set("ToggleKey", v) end
    end })
    
    uiSec:Toggle({ Title = "Transparent", Value = false, Callback = function(v)
        Settings.Current.Transparent = v
        if self.Flags then self.Flags:Set("Transparent", v) end
        self.Library:Notify({ Title = "Settings", Description = "Refresh UI to apply!", Duration = 2 })
    end })
    
    uiSec:Toggle({ Title = "Resizable", Value = true, Callback = function(v)
        Settings.Current.Resizable = v
        if self.Flags then self.Flags:Set("Resizable", v) end
    end })
    
    uiSec:Toggle({ Title = "Scroll Bar", Value = true, Callback = function(v)
        Settings.Current.ScrollBar = v
        if self.Flags then self.Flags:Set("ScrollBar", v) end
    end })
    
    uiSec:Slider({ Title = "Sidebar Width", Step = 5, Value = { Min = 150, Max = 300, Default = 190 }, Callback = function(v)
        Settings.Current.SidebarWidth = v
        if self.Flags then self.Flags:Set("SidebarWidth", v) end
    end })

    -- ============ ESP DEFAULTS ============
    local espSec = self.Tab:Section({ Title = "ESP Defaults", Icon = "eye", Opened = true })
    
    espSec:Toggle({ Title = "ESP Enabled", Value = false, Callback = function(v)
        Settings.Current.ESP_Enabled = v
        if self.Flags then self.Flags:Set("ESP_Enabled", v) end
    end })
    
    espSec:Slider({ Title = "Max Distance", Step = 100, Value = { Min = 100, Max = 10000, Default = 3000 }, Callback = function(v)
        Settings.Current.ESP_MaxDist = v
        if self.Flags then self.Flags:Set("ESP_MaxDist", v) end
    end })
    
    espSec:Toggle({ Title = "Team Check", Value = false, Callback = function(v)
        Settings.Current.ESP_TeamCheck = v
        if self.Flags then self.Flags:Set("ESP_TeamCheck", v) end
    end })
    
    espSec:Toggle({ Title = "Rainbow Mode", Value = false, Callback = function(v)
        Settings.Current.ESP_Rainbow = v
        if self.Flags then self.Flags:Set("ESP_Rainbow", v) end
    end })
    
    espSec:Colorpicker({ Title = "Box Color", Default = Settings.Current.ESP_BoxColor or Color3.fromRGB(255,255,255), Transparency = 0, Callback = function(v)
        Settings.Current.ESP_BoxColor = v
        if self.Flags then self.Flags:Set("ESP_BoxColor", v) end
    end })
    
    espSec:Slider({ Title = "Box Thickness", Step = 0.5, Value = { Min = 1, Max = 6, Default = 2 }, Callback = function(v)
        Settings.Current.ESP_BoxThick = v
        if self.Flags then self.Flags:Set("ESP_BoxThick", v) end
    end })
    
    espSec:Toggle({ Title = "Show Name", Value = true, Callback = function(v)
        Settings.Current.ESP_Name = v
        if self.Flags then self.Flags:Set("ESP_Name", v) end
    end })
    
    espSec:Toggle({ Title = "Show Distance", Value = true, Callback = function(v)
        Settings.Current.ESP_Dist = v
        if self.Flags then self.Flags:Set("ESP_Dist", v) end
    end })
    
    espSec:Toggle({ Title = "Show HP Bar", Value = true, Callback = function(v)
        Settings.Current.ESP_HP = v
        if self.Flags then self.Flags:Set("ESP_HP", v) end
    end })

    -- ============ AIMBOT DEFAULTS ============
    local aimSec = self.Tab:Section({ Title = "Aimbot Defaults", Icon = "crosshair", Opened = true })
    
    aimSec:Toggle({ Title = "Aimbot Enabled", Value = false, Callback = function(v)
        Settings.Current.Aimbot_Enabled = v
        if self.Flags then self.Flags:Set("Aimbot_Enabled", v) end
    end })
    
    aimSec:Slider({ Title = "FOV", Step = 5, Value = { Min = 50, Max = 500, Default = 150 }, Callback = function(v)
        Settings.Current.Aimbot_FOV = v
        if self.Flags then self.Flags:Set("Aimbot_FOV", v) end
    end })
    
    aimSec:Slider({ Title = "Smoothness", Step = 0.01, Value = { Min = 0, Max = 1, Default = 0.1 }, Callback = function(v)
        Settings.Current.Aimbot_Smooth = v
        if self.Flags then self.Flags:Set("Aimbot_Smooth", v) end
    end })
    
    aimSec:Toggle({ Title = "Auto Shoot", Value = false, Callback = function(v)
        Settings.Current.Aimbot_AutoShoot = v
        if self.Flags then self.Flags:Set("Aimbot_AutoShoot", v) end
    end })
    
    aimSec:Toggle({ Title = "Wall Check", Value = true, Callback = function(v)
        Settings.Current.Aimbot_WallCheck = v
        if self.Flags then self.Flags:Set("Aimbot_WallCheck", v) end
    end })

    -- ============ MOVEMENT DEFAULTS ============
    local movSec = self.Tab:Section({ Title = "Movement Defaults", Icon = "zap", Opened = true })
    
    movSec:Toggle({ Title = "Fly Enabled", Value = false, Callback = function(v)
        Settings.Current.Fly_Enabled = v
        if self.Flags then self.Flags:Set("Fly_Enabled", v) end
    end })
    
    movSec:Slider({ Title = "Fly Speed", Step = 1, Value = { Min = 10, Max = 500, Default = 50 }, Callback = function(v)
        Settings.Current.Fly_Speed = v
        if self.Flags then self.Flags:Set("Fly_Speed", v) end
    end })
    
    movSec:Toggle({ Title = "Speed Enabled", Value = false, Callback = function(v)
        Settings.Current.Speed_Enabled = v
        if self.Flags then self.Flags:Set("Speed_Enabled", v) end
    end })
    
    movSec:Slider({ Title = "Speed Value", Step = 1, Value = { Min = 16, Max = 500, Default = 50 }, Callback = function(v)
        Settings.Current.Speed_Value = v
        if self.Flags then self.Flags:Set("Speed_Value", v) end
    end })
    
    movSec:Toggle({ Title = "Jump Enabled", Value = false, Callback = function(v)
        Settings.Current.Jump_Enabled = v
        if self.Flags then self.Flags:Set("Jump_Enabled", v) end
    end })
    
    movSec:Slider({ Title = "Jump Power", Step = 1, Value = { Min = 10, Max = 500, Default = 100 }, Callback = function(v)
        Settings.Current.Jump_Power = v
        if self.Flags then self.Flags:Set("Jump_Power", v) end
    end })

    -- ============ CONFIG ============
    local cfgSec = self.Tab:Section({ Title = "Config", Icon = "save", Opened = true })
    
    cfgSec:Toggle({ Title = "Auto Save", Value = true, Callback = function(v)
        Settings.Current.AutoSave = v
        if self.Flags then self.Flags:Set("AutoSave", v) end
    end })
    
    cfgSec:Slider({ Title = "Auto Save Interval", Step = 5, Value = { Min = 10, Max = 120, Default = 30 }, Callback = function(v)
        Settings.Current.AutoSaveInterval = v
        if self.Flags then self.Flags:Set("AutoSaveInterval", v) end
    end })

    -- ============ RESET ============
    local resetSec = self.Tab:Section({ Title = "Reset", Icon = "rotate-ccw", Opened = true })
    
    resetSec:Button({ Title = "Reset All Settings", Callback = function()
        for k, v in pairs(Settings.Defaults) do
            Settings.Current[k] = v
            if self.Flags then self.Flags:Set(k, v) end
        end
        self.Library:Notify({ Title = "Settings", Description = "All settings reset to default!", Duration = 3 })
    end })

    resetSec:Button({ Title = "Delete Config File", Callback = function()
        if isfile then
            local path = "Hyper_M4X/Configs/settings.json"
            if isfile(path) then
                delfile(path)
                self.Library:Notify({ Title = "Settings", Description = "Config file deleted!", Duration = 3 })
            else
                self.Library:Notify({ Title = "Settings", Description = "No config file found!", Duration = 3 })
            end
        end
    end })
end

function Settings:Get(key)
    return Settings.Current[key] or Settings.Defaults[key]
end

function Settings:Set(key, value)
    Settings.Current[key] = value
end

function Settings:GetAll()
    local all = {}
    for k, v in pairs(Settings.Defaults) do
        all[k] = Settings.Current[k] or v
    end
    return all
end

return Settings
