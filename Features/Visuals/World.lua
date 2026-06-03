--[[
    ╔══════════════════════════════════════════════════╗
    ║           HYPER UI - World Visuals               ║
    ║              Version: v1.0.0                      ║
    ║         By M4X | EVA | AMAL                      ║
    ╚══════════════════════════════════════════════════╝
--]]

local World = {}
World.__index = World

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

World.Settings = {
    FullBright = false,
    NoFog = false,
    NoShadows = false,
    AmbientColor = Color3.fromRGB(255, 255, 255),
    Brightness = 2,
    Time = 12,
    AlwaysDay = false,
    Skybox = "Default",
    RemoveMapEffects = false,
}

local Skyboxes = {
    "Default", "Dark", "Dawn", "Sunset", "Night",
    "Nebula", "Galaxy", "Abyss", "Clear", "Storm",
}

function World:Init(tab, library, flags)
    local self = setmetatable({}, World)
    self.Tab = tab
    self.Library = library
    self.Flags = flags

    if flags then
        flags:Create("World_FullBright", false)
        flags:Create("World_NoFog", false)
        flags:Create("World_NoShadows", false)
        flags:Create("World_AlwaysDay", false)
        flags:Create("World_Brightness", 2)
    end

    -- Save original values for restore
    self.Original = {
        Brightness = Lighting.Brightness,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Time = Lighting.TimeOfDay,
        GlobalShadows = Lighting.GlobalShadows,
    }

    self:BuildUI()
    return self
end

function World:BuildUI()
    if not self.Tab then return end

    local brightSection = self.Tab:Section({ 
        Title = "Brightness", 
        Icon = "sun",
        Opened = true 
    })

    brightSection:Toggle({
        Title = "Full Bright",
        Description = "Maximum brightness everywhere",
        Value = false,
        Callback = function(state)
            World.Settings.FullBright = state
            if self.Flags then self.Flags:Set("World_FullBright", state) end
            self:ApplyBrightness()
        end
    })

    brightSection:Slider({
        Title = "Brightness Level",
        Description = "Adjust world brightness",
        Min = 0, Max = 10, Step = 0.5, Value = 2,
        Suffix = "x",
        Callback = function(value)
            World.Settings.Brightness = value
            if self.Flags then self.Flags:Set("World_Brightness", value) end
            self:ApplyBrightness()
        end
    })

    local fogSection = self.Tab:Section({ 
        Title = "Fog & Atmosphere", 
        Icon = "cloud-fog",
        Opened = true 
    })

    fogSection:Toggle({
        Title = "No Fog",
        Description = "Remove all fog",
        Value = false,
        Callback = function(state)
            World.Settings.NoFog = state
            if self.Flags then self.Flags:Set("World_NoFog", state) end
            self:ApplyFog()
        end
    })

    local shadowSection = self.Tab:Section({ 
        Title = "Shadows", 
        Icon = "sun-dim",
        Opened = true 
    })

    shadowSection:Toggle({
        Title = "No Shadows",
        Description = "Disable all shadows",
        Value = false,
        Callback = function(state)
            World.Settings.NoShadows = state
            if self.Flags then self.Flags:Set("World_NoShadows", state) end
            self:ApplyShadows()
        end
    })

    local timeSection = self.Tab:Section({ 
        Title = "Time", 
        Icon = "clock",
        Opened = true 
    })

    timeSection:Toggle({
        Title = "Always Day",
        Description = "Keep time at 12:00",
        Value = false,
        Callback = function(state)
            World.Settings.AlwaysDay = state
            if self.Flags then self.Flags:Set("World_AlwaysDay", state) end
            self:ApplyTime()
        end
    })

    timeSection:Slider({
        Title = "Time of Day",
        Description = "Set game time (24h)",
        Min = 0, Max = 24, Step = 0.5, Value = 12,
        Suffix = "h",
        Callback = function(value)
            World.Settings.Time = value
            self:ApplyTime()
        end
    })

    local skySection = self.Tab:Section({ 
        Title = "Skybox", 
        Icon = "image",
        Opened = false 
    })

    skySection:Dropdown({
        Title = "Skybox",
        Description = "Change the sky",
        Values = Skyboxes,
        Value = "Default",
        Callback = function(value)
            World.Settings.Skybox = value
            self:ApplySkybox()
        end
    })

    local miscSection = self.Tab:Section({ 
        Title = "Misc", 
        Icon = "more-horizontal",
        Opened = false 
    })

    miscSection:Toggle({
        Title = "Remove Map Effects",
        Description = "Remove blur, color correction, etc",
        Value = false,
        Callback = function(state)
            World.Settings.RemoveMapEffects = state
            self:ApplyEffects()
        end
    })

    local resetSection = self.Tab:Section({ 
        Title = "Reset", 
        Icon = "rotate-ccw",
        Opened = false 
    })

    resetSection:Button({
        Title = "Restore Defaults",
        Description = "Reset all world settings",
        Callback = function() self:RestoreDefaults() end
    })
end

function World:ApplyBrightness()
    if World.Settings.FullBright then
        Lighting.Brightness = 5
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = World.Settings.Brightness
        Lighting.Ambient = self.Original.Ambient
        Lighting.OutdoorAmbient = self.Original.OutdoorAmbient
    end
end

function World:ApplyFog()
    if World.Settings.NoFog then
        Lighting.FogEnd = 100000
        Lighting.FogStart = 100000
    else
        Lighting.FogEnd = self.Original.FogEnd
        Lighting.FogStart = self.Original.FogStart
    end
end

function World:ApplyShadows()
    Lighting.GlobalShadows = not World.Settings.NoShadows
end

function World:ApplyTime()
    if World.Settings.AlwaysDay then
        Lighting.TimeOfDay = "12:00:00"
        Lighting.ClockTime = 12
    else
        local t = World.Settings.Time
        Lighting.ClockTime = t
        Lighting.TimeOfDay = string.format("%02d:%02d:00", math.floor(t), math.floor((t % 1) * 60))
    end
end

function World:ApplySkybox()
    -- Skybox changing depends on game, basic implementation
    pcall(function()
        local sky = Lighting:FindFirstChildOfClass("Sky")
        if sky then
            sky.SkyboxBk = "rbxassetid://sky/" .. World.Settings.Skybox
            sky.SkyboxDn = "rbxassetid://sky/" .. World.Settings.Skybox
            sky.SkyboxFt = "rbxassetid://sky/" .. World.Settings.Skybox
            sky.SkyboxLf = "rbxassetid://sky/" .. World.Settings.Skybox
            sky.SkyboxRt = "rbxassetid://sky/" .. World.Settings.Skybox
            sky.SkyboxUp = "rbxassetid://sky/" .. World.Settings.Skybox
        end
    end)
end

function World:ApplyEffects()
    if World.Settings.RemoveMapEffects then
        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") 
                or obj:IsA("SunRaysEffect") or obj:IsA("BloomEffect") then
                obj.Enabled = false
            end
        end
    end
end

function World:RestoreDefaults()
    Lighting.Brightness = self.Original.Brightness
    Lighting.FogEnd = self.Original.FogEnd
    Lighting.FogStart = self.Original.FogStart
    Lighting.Ambient = self.Original.Ambient
    Lighting.OutdoorAmbient = self.Original.OutdoorAmbient
    Lighting.TimeOfDay = self.Original.Time
    Lighting.GlobalShadows = self.Original.GlobalShadows
    
    World.Settings.FullBright = false
    World.Settings.NoFog = false
    World.Settings.NoShadows = false
    World.Settings.AlwaysDay = false
    
    if self.Library then
        self.Library:Notify({ 
            Title = "World", 
            Description = "Settings restored to default!", 
            Duration = 3 
        })
    end
end

return World
