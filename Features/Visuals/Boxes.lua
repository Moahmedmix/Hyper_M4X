local Boxes = {}
Boxes.__index = Boxes

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")

Boxes.Settings = {
    Enabled = false,
    Color = Color3.fromRGB(255, 255, 255),
    Thickness = 1.5,
    TeamCheck = false,
    MaxDistance = 1000,
}

function Boxes:Init(tab, library, flags)
    local self = setmetatable({}, Boxes)
    self.Tab = tab
    self.Library = library
    self.Flags = flags
    self.ScreenGui = nil
    self.Boxes = {}
    self.Connection = nil

    self:BuildUI()
    return self
end

function Boxes:BuildUI()
    if not self.Tab then return end

    local section = self.Tab:Section({ 
        Title = "Boxes Settings", 
        Icon = "square",
        Opened = true 
    })

    section:Toggle({
        Title = "Enable Boxes",
        Description = "Draw 2D boxes around players",
        Value = false,
        Callback = function(state)
            Boxes.Settings.Enabled = state
            if state then self:Start() else self:Stop() end
        end
    })

    section:ColorPicker({
        Title = "Box Color",
        Description = "Choose box outline color",
        Default = Boxes.Settings.Color,
        Callback = function(c) Boxes.Settings.Color = c; self:UpdateColors() end
    })

    section:Slider({
        Title = "Thickness",
        Description = "Box outline thickness",
        Min = 1, Max = 5, Step = 0.5, Value = 1.5,
        Suffix = "px",
        Callback = function(v) Boxes.Settings.Thickness = v end
    })

    section:Toggle({
        Title = "Team Check",
        Description = "Ignore teammates",
        Value = false,
        Callback = function(s) Boxes.Settings.TeamCheck = s end
    })

    section:Slider({
        Title = "Max Distance",
        Description = "Maximum render distance",
        Min = 100, Max = 5000, Step = 100, Value = 1000,
        Suffix = " studs",
        Callback = function(v) Boxes.Settings.MaxDistance = v end
    })
end

function Boxes:Start()
    if self.ScreenGui then self.ScreenGui:Destroy() end
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "Hyper_Boxes"
    self.ScreenGui.Parent = CoreGui
    self.ScreenGui.ResetOnSpawn = false
    self.Boxes = {}
    
    self.Connection = RunService.RenderStepped:Connect(function()
        self:Update()
    end)
end

function Boxes:Stop()
    if self.Connection then self.Connection:Disconnect(); self.Connection = nil end
    if self.ScreenGui then self.ScreenGui:Destroy(); self.ScreenGui = nil end
    self.Boxes = {}
end

function Boxes:Update()
    local myTeam = LocalPlayer.Team
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then self:RemoveBox(player) continue end
        if Boxes.Settings.TeamCheck and player.Team == myTeam then self:RemoveBox(player) continue end
        
        local char = player.Character
        if not char then self:RemoveBox(player) continue end
        
        local head = char:FindFirstChild("Head")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not head or not root then self:RemoveBox(player) continue end
        
        local dist = (Camera.CFrame.Position - root.Position).Magnitude
        if dist > Boxes.Settings.MaxDistance then self:RemoveBox(player) continue end
        
        local headPos, headOn = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local legPos, legOn = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.5, 0))
        
        if not headOn and not legOn then self:RemoveBox(player) continue end
        
        local h = math.abs(headPos.Y - legPos.Y)
        local w = h * 0.65
        local x = headPos.X - w/2
        local y = headPos.Y
        
        if not self.Boxes[player] then
            local box = Instance.new("Frame")
            box.Name = player.Name
            box.Size = UDim2.new(0, w, 0, h)
            box.Position = UDim2.new(0, x, 0, y)
            box.BackgroundTransparency = 1
            box.BorderSizePixel = 0
            box.Parent = self.ScreenGui
            
            local stroke = Instance.new("UIStroke")
            stroke.Name = "Stroke"
            stroke.Color = Boxes.Settings.Color
            stroke.Thickness = Boxes.Settings.Thickness
            stroke.Parent = box
            
            self.Boxes[player] = box
        else
            local box = self.Boxes[player]
            box.Size = UDim2.new(0, w, 0, h)
            box.Position = UDim2.new(0, x, 0, y)
        end
    end
    
    for player, box in pairs(self.Boxes) do
        if not player.Parent then self:RemoveBox(player) end
    end
end

function Boxes:UpdateColors()
    for _, box in pairs(self.Boxes) do
        local stroke = box:FindFirstChild("Stroke")
        if stroke then stroke.Color = Boxes.Settings.Color end
    end
end

function Boxes:RemoveBox(player)
    if self.Boxes[player] then
        self.Boxes[player]:Destroy()
        self.Boxes[player] = nil
    end
end

return Boxes
