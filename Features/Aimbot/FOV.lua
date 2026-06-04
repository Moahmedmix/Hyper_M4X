--[[
    ╔══════════════════════════════════════════════════╗
    ║           HYPER UI - Aimbot System               ║
    ║              Version: v1.0.0                      ║
    ║         By M4X | EVA | AMAL                      ║
    ╚══════════════════════════════════════════════════╝

    Features:
    - Silent Aim
    - FOV Circle with full customization
    - Smooth aim control
    - Prediction
    - Team check & Visible check
    - Color pickers for normal & locked states
--]]

local Aimbot = {}
Aimbot.__index = Aimbot

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

Aimbot.Settings = {
    Enabled = false,
    FOV = 150,
    Smoothness = 0.1,
    AimPart = "Head",
    TeamCheck = false,
    ShowFOV = true,
    FOVColor = Color3.fromRGB(255, 255, 255),
    LockedColor = Color3.fromRGB(255, 0, 0),
    FOVThickness = 2,
    FOVNumSides = 64,
    Prediction = 0,
    VisibleCheck = false,
}

local Target = nil
local FOVCircle = nil

function Aimbot:Init(tab, library, flags)
    local self = setmetatable({}, Aimbot)
    self.Tab = tab
    self.Library = library
    self.Flags = flags
    self.Connection = nil
    
    -- Create FOV Circle
    local screenSize = Camera.ViewportSize
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Color = Aimbot.Settings.FOVColor
    FOVCircle.Thickness = Aimbot.Settings.FOVThickness
    FOVCircle.NumSides = Aimbot.Settings.FOVNumSides
    FOVCircle.Radius = Aimbot.Settings.FOV
    FOVCircle.Filled = false
    FOVCircle.Position = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
    FOVCircle.ZIndex = 10

    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        local ss = Camera.ViewportSize
        FOVCircle.Position = Vector2.new(ss.X / 2, ss.Y / 2)
    end)

    self:BuildUI()
    self:StartLoop()
    return self
end

function Aimbot:BuildUI()
    if not self.Tab then return end

    -- Main
    local mainSec = self.Tab:Section({ Title = "Main", Icon = "crosshair", Opened = true })
    mainSec:Toggle({ Title = "Enable Aimbot", Value = false, Callback = function(s) Aimbot.Settings.Enabled = s; if not s and FOVCircle then FOVCircle.Visible = false end end })
    mainSec:Toggle({ Title = "Show Circle", Value = true, Callback = function(s) Aimbot.Settings.ShowFOV = s end })

    -- Circle
    local circleSec = self.Tab:Section({ Title = "Circle Settings", Icon = "circle", Opened = true })
    circleSec:Slider({ Title = "FOV Radius", Step = 5, Value = { Min = 50, Max = 500, Default = 150 }, Callback = function(v) Aimbot.Settings.FOV = v end })
    circleSec:Slider({ Title = "Thickness", Step = 0.5, Value = { Min = 1, Max = 5, Default = 2 }, Callback = function(v) Aimbot.Settings.FOVThickness = v end })

    -- Colors
    local colorSec = self.Tab:Section({ Title = "Colors", Icon = "palette", Opened = true })
    colorSec:Colorpicker({
        Title = "Circle Color",
        Desc = "Normal color",
        Default = Aimbot.Settings.FOVColor,
        Transparency = 0,
        Callback = function(c) Aimbot.Settings.FOVColor = c end
    })
    colorSec:Colorpicker({
        Title = "Lock Color",
        Desc = "Color when locked",
        Default = Aimbot.Settings.LockedColor,
        Transparency = 0,
        Callback = function(c) Aimbot.Settings.LockedColor = c end
    })

    -- Aim
    local aimSec = self.Tab:Section({ Title = "Aim Settings", Icon = "target", Opened = true })
    aimSec:Slider({ Title = "Smoothness", Desc = "0 = instant | 1 = slow", Step = 0.01, Value = { Min = 0, Max = 1, Default = 0.1 }, Callback = function(v) Aimbot.Settings.Smoothness = v end })
    aimSec:Slider({ Title = "Prediction", Desc = "Predict movement", Step = 0.01, Value = { Min = 0, Max = 0.5, Default = 0 }, Callback = function(v) Aimbot.Settings.Prediction = v end })
    aimSec:Dropdown({ Title = "Aim Part", Desc = "Where to aim", Values = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, Value = "Head", Callback = function(v) Aimbot.Settings.AimPart = v end })
    aimSec:Toggle({ Title = "Team Check", Value = false, Callback = function(s) Aimbot.Settings.TeamCheck = s end })
    aimSec:Toggle({ Title = "Visible Check", Value = false, Callback = function(s) Aimbot.Settings.VisibleCheck = s end })
end

function Aimbot:StartLoop()
    self.Connection = RunService.RenderStepped:Connect(function()
        self:Update()
    end)
end

function Aimbot:Update()
    if not Aimbot.Settings.Enabled then
        FOVCircle.Visible = false
        return
    end

    local screenSize = Camera.ViewportSize
    local center = Vector2.new(screenSize.X / 2, screenSize.Y / 2)

    if Aimbot.Settings.ShowFOV then
        FOVCircle.Visible = true
        FOVCircle.Radius = Aimbot.Settings.FOV
        FOVCircle.Thickness = Aimbot.Settings.FOVThickness
        FOVCircle.NumSides = Aimbot.Settings.FOVNumSides
    else
        FOVCircle.Visible = false
    end

    Target = self:GetClosest(center)

    if Target then
        FOVCircle.Color = Aimbot.Settings.LockedColor
        self:AimAt(Target)
    else
        FOVCircle.Color = Aimbot.Settings.FOVColor
    end
end

function Aimbot:IsVisible(player)
    if not Aimbot.Settings.VisibleCheck then return true end
    local char = player.Character
    if not char then return false end
    local part = char:FindFirstChild(Aimbot.Settings.AimPart) or char:FindFirstChild("Head")
    if not part then return false end

    local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 500)
    local hit = workspace:FindPartOnRay(ray, LocalPlayer.Character)
    return hit and hit.Parent == char
end

function Aimbot:GetClosest(center)
    local closest = nil
    local shortest = Aimbot.Settings.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Aimbot.Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end

        local char = player.Character
        if not char then continue end

        local part = char:FindFirstChild(Aimbot.Settings.AimPart) or char:FindFirstChild("Head")
        if not part then continue end

        if not self:IsVisible(player) then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if dist < shortest then
            shortest = dist
            closest = player
        end
    end

    return closest
end

function Aimbot:AimAt(target)
    local char = target.Character
    if not char then return end
    local part = char:FindFirstChild(Aimbot.Settings.AimPart) or char:FindFirstChild("Head")
    if not part then return end

    local targetPos = part.Position

    if Aimbot.Settings.Prediction > 0 then
        local vel = part.Velocity or Vector3.zero
        targetPos = targetPos + vel * Aimbot.Settings.Prediction
    end

    local camPos = Camera.CFrame.Position
    local dir = (targetPos - camPos).Unit

    if Aimbot.Settings.Smoothness > 0 then
        local current = Camera.CFrame.LookVector
        dir = current:Lerp(dir, Aimbot.Settings.Smoothness)
    end

    Camera.CFrame = CFrame.new(camPos, camPos + dir)
end

function Aimbot:Stop()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    if FOVCircle then
        FOVCircle.Visible = false
    end
end

return Aimbot
