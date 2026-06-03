local Skeletons = {}
Skeletons.__index = Skeletons

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

Skeletons.Settings = {
    Enabled = false,
    Color = Color3.fromRGB(255, 255, 255),
    Thickness = 0.3,
    TeamCheck = false,
    MaxDistance = 500,
}

local Bones = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
}

function Skeletons:Init(tab, library, flags)
    local self = setmetatable({}, Skeletons)
    self.Tab = tab
    self.Library = library
    self.Flags = flags
    self.Beams = {}
    self.Connection = nil

    self:BuildUI()
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
        Description = "Draw bone skeletons on players",
        Value = false,
        Callback = function(s)
            Skeletons.Settings.Enabled = s
            if s then self:Start() else self:Stop() end
        end
    })

    section:ColorPicker({
        Title = "Skeleton Color",
        Default = Skeletons.Settings.Color,
        Callback = function(c) Skeletons.Settings.Color = c; self:UpdateColors() end
    })

    section:Slider({
        Title = "Thickness", Min = 0.1, Max = 2, Step = 0.1, Value = 0.3,
        Callback = function(v) Skeletons.Settings.Thickness = v; self:UpdateThickness() end
    })

    section:Toggle({
        Title = "Team Check", Value = false,
        Callback = function(s) Skeletons.Settings.TeamCheck = s end
    })

    section:Slider({
        Title = "Max Distance", Min = 100, Max = 5000, Step = 100, Value = 500,
        Suffix = " studs",
        Callback = function(v) Skeletons.Settings.MaxDistance = v end
    })
end

function Skeletons:Start()
    self.Connection = RunService.Heartbeat:Connect(function() self:Update() end)
end

function Skeletons:Stop()
    if self.Connection then self.Connection:Disconnect(); self.Connection = nil end
    self:ClearAll()
end

function Skeletons:Update()
    local myTeam = LocalPlayer.Team
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then self:RemovePlayer(player) continue end
        if Skeletons.Settings.TeamCheck and player.Team == myTeam then self:RemovePlayer(player) continue end
        
        local char = player.Character
        if not char then self:RemovePlayer(player) continue end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then self:RemovePlayer(player) continue end
        if (Camera.CFrame.Position - root.Position).Magnitude > Skeletons.Settings.MaxDistance then self:RemovePlayer(player) continue end
        
        self:CreateBeams(player, char)
    end
    
    for player in pairs(self.Beams) do
        if not player.Parent then self:RemovePlayer(player) end
    end
end

function Skeletons:CreateBeams(player, char)
    if not self.Beams[player] then self.Beams[player] = {} end
    
    local existing = {}
    for _, beam in ipairs(self.Beams[player]) do
        existing[beam.Name] = beam
    end
    
    for i, bone in ipairs(Bones) do
        local part1 = char:FindFirstChild(bone[1])
        local part2 = char:FindFirstChild(bone[2])
        local beamName = bone[1] .. "_" .. bone[2]
        
        if part1 and part2 then
            local beam = existing[beamName]
            if not beam then
                local att0 = Instance.new("Attachment", part1)
                att0.Name = "HyperAtt0_" .. i
                local att1 = Instance.new("Attachment", part2)
                att1.Name = "HyperAtt1_" .. i
                
                beam = Instance.new("Beam")
                beam.Name = beamName
                beam.Attachment0 = att0
                beam.Attachment1 = att1
                beam.Parent = part1
                beam.FaceCamera = true
                
                table.insert(self.Beams[player], beam)
            end
            
            beam.Color = ColorSequence.new(Skeletons.Settings.Color)
            beam.Width0 = Skeletons.Settings.Thickness
            beam.Width1 = Skeletons.Settings.Thickness
            beam.Enabled = true
        end
    end
end

function Skeletons:UpdateColors()
    for _, beams in pairs(self.Beams) do
        for _, beam in ipairs(beams) do
            beam.Color = ColorSequence.new(Skeletons.Settings.Color)
        end
    end
end

function Skeletons:UpdateThickness()
    for _, beams in pairs(self.Beams) do
        for _, beam in ipairs(beams) do
            beam.Width0 = Skeletons.Settings.Thickness
            beam.Width1 = Skeletons.Settings.Thickness
        end
    end
end

function Skeletons:RemovePlayer(player)
    if self.Beams[player] then
        for _, beam in ipairs(self.Beams[player]) do
            pcall(function()
                if beam.Attachment0 then beam.Attachment0:Destroy() end
                if beam.Attachment1 then beam.Attachment1:Destroy() end
                beam:Destroy()
            end)
        end
        self.Beams[player] = nil
    end
end

function Skeletons:ClearAll()
    for player in pairs(self.Beams) do
        self:RemovePlayer(player)
    end
    self.Beams = {}
end

return Skeletons
