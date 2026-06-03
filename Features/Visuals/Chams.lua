--[[
    ╔══════════════════════════════════════════════════╗
    ║           HYPER UI - Chams System                ║
    ║              Version: v1.0.0                      ║
    ║         By M4X | EVA | AMAL                      ║
    ╚══════════════════════════════════════════════════╝
--]]

local Chams = {}
Chams.__index = Chams

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

Chams.Objects = {}
Chams.Settings = {
    Enabled = false,
    Color = Color3.fromRGB(255, 0, 0),
    Transparency = 0.5,
    Material = "ForceField",
    TeamCheck = false,
    VisibleOnly = false,
}

local Materials = {
    "ForceField", "Plastic", "SmoothPlastic", "Neon",
    "Glass", "Metal", "DiamondPlate", "Foil",
}

function Chams:Init(tab, library, flags)
    local self = setmetatable({}, Chams)
    self.Tab = tab
    self.Library = library
    self.Flags = flags

    if flags then
        flags:Create("Chams_Enabled", false)
        flags:Create("Chams_TeamCheck", false)
        flags:Create("Chams_VisibleOnly", false)
    end

    self:BuildUI()
    self:StartLoop()
    return self
end

function Chams:BuildUI()
    if not self.Tab then return end

    local section = self.Tab:Section({ 
        Title = "Chams Settings", 
        Icon = "shirt",
        Opened = true 
    })

    section:Toggle({
        Title = "Enable Chams",
        Description = "Highlight players through walls",
        Value = false,
        Callback = function(state)
            Chams.Settings.Enabled = state
            if self.Flags then self.Flags:Set("Chams_Enabled", state) end
            if not state then self:ClearAll() end
        end
    })

    section:ColorPicker({
        Title = "Chams Color",
        Description = "Choose highlight color",
        Default = Chams.Settings.Color,
        Callback = function(c) Chams.Settings.Color = c end
    })

    section:Slider({
        Title = "Transparency",
        Description = "Chams transparency",
        Min = 0, Max = 1, Step = 0.1, Value = 0.5,
        Suffix = "",
        Callback = function(v) Chams.Settings.Transparency = v; self:UpdateAll() end
    })

    section:Dropdown({
        Title = "Material",
        Description = "Chams material type",
        Values = Materials,
        Value = "ForceField",
        Callback = function(v) Chams.Settings.Material = v; self:UpdateAll() end
    })

    section:Toggle({
        Title = "Team Check",
        Description = "Ignore teammates",
        Value = false,
        Callback = function(s)
            Chams.Settings.TeamCheck = s
            if self.Flags then self.Flags:Set("Chams_TeamCheck", s) end
        end
    })

    section:Toggle({
        Title = "Visible Only",
        Description = "Only highlight visible players",
        Value = false,
        Callback = function(s)
            Chams.Settings.VisibleOnly = s
            if self.Flags then self.Flags:Set("Chams_VisibleOnly", s) end
        end
    })
end

function Chams:StartLoop()
    task.spawn(function()
        while true do
            if Chams.Settings.Enabled then self:UpdateChams() end
            task.wait(0.5)
        end
    end)
end

function Chams:ApplyChams(player)
    local char = player.Character
    if not char then return end
    
    if not Chams.Objects[player] then
        Chams.Objects[player] = {}
    end
    
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.Transparency < 1 then
            if not Chams.Objects[player][part] then
                local highlight = Instance.new("Highlight")
                highlight.Name = "HyperCham"
                highlight.Parent = part
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.FillTransparency = Chams.Settings.Transparency
                highlight.OutlineTransparency = 0.5
                highlight.FillColor = Chams.Settings.Color
                highlight.OutlineColor = Chams.Settings.Color
                Chams.Objects[player][part] = highlight
            else
                local h = Chams.Objects[player][part]
                h.FillColor = Chams.Settings.Color
                h.OutlineColor = Chams.Settings.Color
                h.FillTransparency = Chams.Settings.Transparency
                if Chams.Settings.VisibleOnly then
                    h.DepthMode = Enum.HighlightDepthMode.Occluded
                else
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end
            end
        end
    end
end

function Chams:UpdateChams()
    local myTeam = LocalPlayer.Team

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Chams.Settings.TeamCheck and player.Team == myTeam then
            self:ClearPlayer(player)
            continue
        end
        self:ApplyChams(player)
    end
    
    for player, _ in pairs(Chams.Objects) do
        if not player.Parent then self:ClearPlayer(player) end
    end
end

function Chams:UpdateAll()
    for _, player in ipairs(Players:GetPlayers()) do
        if Chams.Objects[player] then
            self:ClearPlayer(player)
            self:ApplyChams(player)
        end
    end
end

function Chams:ClearPlayer(player)
    if Chams.Objects[player] then
        for _, highlight in pairs(Chams.Objects[player]) do
            pcall(function() highlight:Destroy() end)
        end
        Chams.Objects[player] = nil
    end
end

function Chams:ClearAll()
    for player in pairs(Chams.Objects) do
        self:ClearPlayer(player)
    end
end

return Chams
