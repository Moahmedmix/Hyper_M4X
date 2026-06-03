--[[
    ╔══════════════════════════════════════════════════╗
    ║           HYPER UI - Skeletons System            ║
    ║              Version: v1.0.0                      ║
    ║         By M4X | EVA | AMAL                      ║
    ╚══════════════════════════════════════════════════╝
--]]

local Skeletons = {}
Skeletons.__index = Skeletons

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

Skeletons.Objects = {}
Skeletons.Settings = {
    Enabled = false,
    Color = Color3.fromRGB(255, 255, 255),
    Thickness = 1.5,
    TeamCheck = false,
    MaxDistance = 1000,
}

local Bones = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
}

function Skeletons:Init(tab, library, flags)
    local self = setmetatable({}, Skeletons)
    self.Tab = tab
    self.Library = library
    self.Flags = flags

    if flags then
        flags:Create("Skeletons_Enabled", false)
        flags:Create("Skeletons_TeamCheck", false)
        flags:Create("Skeletons_MaxDistance", 1000)
    end

    self:BuildUI()
    self:StartLoop()
    return self
end

function Skeletons:BuildUI()
    if not self.Tab then return end

    local section = self.Tab:Section({ 
        Title = "Skeleton Settings", 
        Icon = "bone",
        Opened = true 
    })

    section:Toggle({
        Title = "Enable Skeletons",
        Description = "Show bone skeletons",
        Value = false,
        Callback = function(state)
            Skeletons.Settings.Enabled = state
            if self.Flags then self.Flags:Set("Skeletons_Enabled", state) end
            if not state then self:ClearAll() end
        end
    })

    section:ColorPicker({
        Title = "Skeleton Color",
        Description = "Choose skeleton color",
        Default = Skeletons.Settings.Color,
        Callback = function(color)
            Skeletons.Settings.Color = color
        end
    })

    section:Slider({
        Title = "Thickness",
        Description = "Line thickness",
        Min = 1, Max = 5, Step = 0.5, Value = 1.5,
        Suffix = "px",
        Callback = function(v) Skeletons.Settings.Thickness = v end
    })

    section:Toggle({
        Title = "Team Check",
        Description = "Ignore teammates",
        Value = false,
        Callback = function(state)
            Skeletons.Settings.TeamCheck = state
            if self.Flags then self.Flags:Set("Skeletons_TeamCheck", state) end
        end
    })

    section:Slider({
        Title = "Max Distance",
        Description = "Maximum render distance",
        Min = 100, Max = 5000, Step = 100, Value = 1000,
        Suffix = " studs",
        Callback = function(v)
            Skeletons.Settings.MaxDistance = v
            if self.Flags then self.Flags:Set("Skeletons_MaxDistance", v) end
        end
    })
end

function Skeletons:StartLoop()
    task.spawn(function()
        while true do
            if Skeletons.Settings.Enabled then self:UpdateSkeletons() end
            task.wait(1 / 30)
        end
    end)
end

function Skeletons:UpdateSkeletons()
    local myTeam = LocalPlayer.Team

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        if Skeletons.Settings.TeamCheck and player.Team == myTeam then
            self:ClearPlayer(player)
            continue
        end
        
        local char = player.Character
        if not char then self:ClearPlayer(player) continue end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then self:ClearPlayer(player) continue end
        
        if (Camera.CFrame.Position - root.Position).Magnitude > Skeletons.Settings.MaxDistance then
            self:ClearPlayer(player)
            continue
        end
        
        self:DrawSkeleton(player, char)
    end
    
    for player, _ in pairs(Skeletons.Objects) do
        if not player.Parent then self:ClearPlayer(player) end
    end
end

function Skeletons:DrawSkeleton(player, char)
    if not Skeletons.Objects[player] then
        Skeletons.Objects[player] = {}
        for i = 1, #Bones do
            Skeletons.Objects[player][i] = Drawing.new("Line")
        end
    end
    
    for i, bone in ipairs(Bones) do
        local part1 = char:FindFirstChild(bone[1])
        local part2 = char:FindFirstChild(bone[2])
        local line = Skeletons.Objects[player][i]
        
        if part1 and part2 then
            local pos1, on1 = Camera:WorldToViewportPoint(part1.Position)
            local pos2, on2 = Camera:WorldToViewportPoint(part2.Position)
            
            if on1 or on2 then
                line.Visible = true
                line.Color = Skeletons.Settings.Color
                line.Thickness = Skeletons.Settings.Thickness
                line.From = Vector2.new(pos1.X, pos1.Y)
                line.To = Vector2.new(pos2.X, pos2.Y)
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end
end

function Skeletons:ClearPlayer(player)
    if Skeletons.Objects[player] then
        for _, line in pairs(Skeletons.Objects[player]) do
            pcall(function() line:Remove() end)
        end
        Skeletons.Objects[player] = nil
    end
end

function Skeletons:ClearAll()
    for player in pairs(Skeletons.Objects) do
        self:ClearPlayer(player)
    end
end

return Skeletons
