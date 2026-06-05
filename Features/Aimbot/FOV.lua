--[[
    ╔══════════════════════════════════════════════════╗
    ║           HYPER UI - Aimbot System v3 FINAL       ║
    ║    Silent Aim + FOV + Wall Check + Priority       ║
    ║    Filled Circle + Sides + Full Customization     ║
    ║              By M4X | EVA | AMAL                  ║
    ╚══════════════════════════════════════════════════╝
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
    FOVFilled = false,
    FOVTransparency = 1,
    Prediction = 0,
    VisibleCheck = false,
    WallCheck = false,
    Priority = "Distance",
    AutoShoot = false,
    Shake = false,
    ShakeAmount = 1,
}

local Target = nil
local FOVCircle = nil

function Aimbot:Init(tab, library, flags)
    local self = setmetatable({}, Aimbot)
    self.Tab = tab
    self.Library = library
    self.Flags = flags
    self.Connection = nil

    local ss = Camera.ViewportSize
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Color = Aimbot.Settings.FOVColor
    FOVCircle.Thickness = Aimbot.Settings.FOVThickness
    FOVCircle.NumSides = Aimbot.Settings.FOVNumSides
    FOVCircle.Radius = Aimbot.Settings.FOV
    FOVCircle.Filled = Aimbot.Settings.FOVFilled
    FOVCircle.Transparency = Aimbot.Settings.FOVTransparency
    FOVCircle.Position = Vector2.new(ss.X / 2, ss.Y / 2)
    FOVCircle.ZIndex = 10

    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        local s = Camera.ViewportSize
        FOVCircle.Position = Vector2.new(s.X / 2, s.Y / 2)
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
    mainSec:Toggle({ Title = "Show FOV Circle", Value = true, Callback = function(s) Aimbot.Settings.ShowFOV = s end })
    mainSec:Toggle({ Title = "Auto Shoot", Value = false, Callback = function(s) Aimbot.Settings.AutoShoot = s end })

    -- FOV Circle
    local circleSec = self.Tab:Section({ Title = "FOV Circle", Icon = "circle", Opened = true })
    circleSec:Slider({ Title = "FOV Radius", Step = 5, Value = { Min = 50, Max = 500, Default = 150 }, Callback = function(v) Aimbot.Settings.FOV = v end })
    circleSec:Slider({ Title = "Thickness", Step = 0.5, Value = { Min = 1, Max = 5, Default = 2 }, Callback = function(v) Aimbot.Settings.FOVThickness = v end })
    circleSec:Slider({ Title = "Sides", Step = 8, Value = { Min = 8, Max = 128, Default = 64 }, Callback = function(v) Aimbot.Settings.FOVNumSides = v; FOVCircle.NumSides = v end })
    circleSec:Toggle({ Title = "Filled", Value = false, Callback = function(s) Aimbot.Settings.FOVFilled = s; FOVCircle.Filled = s end })
    circleSec:Slider({ Title = "Transparency", Step = 0.1, Value = { Min = 0, Max = 1, Default = 1 }, Callback = function(v) Aimbot.Settings.FOVTransparency = 1 - v; FOVCircle.Transparency = 1 - v end })

    -- Colors
    local colorSec = self.Tab:Section({ Title = "Colors", Icon = "palette", Opened = true })
    colorSec:Colorpicker({ Title = "Normal Color", Default = Aimbot.Settings.FOVColor, Transparency = 0, Callback = function(c) Aimbot.Settings.FOVColor = c end })
    colorSec:Colorpicker({ Title = "Locked Color", Default = Aimbot.Settings.LockedColor, Transparency = 0, Callback = function(c) Aimbot.Settings.LockedColor = c end })

    -- Aim Settings
    local aimSec = self.Tab:Section({ Title = "Aim Settings", Icon = "target", Opened = true })
    aimSec:Slider({ Title = "Smoothness", Desc = "0 = instant | 1 = slow", Step = 0.01, Value = { Min = 0, Max = 1, Default = 0.1 }, Callback = function(v) Aimbot.Settings.Smoothness = v end })
    aimSec:Slider({ Title = "Prediction", Desc = "Predict movement", Step = 0.01, Value = { Min = 0, Max = 0.5, Default = 0 }, Callback = function(v) Aimbot.Settings.Prediction = v end })
    aimSec:Dropdown({ Title = "Aim Part", Values = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, Value = "Head", Callback = function(v) Aimbot.Settings.AimPart = v end })
    aimSec:Dropdown({ Title = "Priority", Desc = "How to choose target", Values = {"Distance", "Health", "Angle"}, Value = "Distance", Callback = function(v) Aimbot.Settings.Priority = v end })
    aimSec:Toggle({ Title = "Team Check", Value = false, Callback = function(s) Aimbot.Settings.TeamCheck = s end })
    aimSec:Toggle({ Title = "Visible Check", Value = false, Callback = function(s) Aimbot.Settings.VisibleCheck = s end })
    aimSec:Toggle({ Title = "Wall Check", Desc = "Don't aim through walls", Value = false, Callback = function(s) Aimbot.Settings.WallCheck = s end })

    -- Humanizer
    local shakeSec = self.Tab:Section({ Title = "Humanizer", Icon = "radio", Opened = false })
    shakeSec:Toggle({ Title = "Shake", Value = false, Callback = function(s) Aimbot.Settings.Shake = s end })
    shakeSec:Slider({ Title = "Shake Amount", Step = 0.1, Value = { Min = 0.1, Max = 5, Default = 1 }, Callback = function(v) Aimbot.Settings.ShakeAmount = v end })
end

function Aimbot:StartLoop()
    self.Connection = RunService.RenderStepped:Connect(function() self:Update() end)
end

function Aimbot:Update()
    if not Aimbot.Settings.Enabled then FOVCircle.Visible = false return end

    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    if Aimbot.Settings.ShowFOV then
        FOVCircle.Visible = true
        FOVCircle.Radius = Aimbot.Settings.FOV
        FOVCircle.Thickness = Aimbot.Settings.FOVThickness
        FOVCircle.NumSides = Aimbot.Settings.FOVNumSides
        FOVCircle.Filled = Aimbot.Settings.FOVFilled
        FOVCircle.Transparency = 1 - Aimbot.Settings.FOVTransparency
    else
        FOVCircle.Visible = false
    end

    Target = self:GetBestTarget(center)

    if Target then
        FOVCircle.Color = Aimbot.Settings.LockedColor
        self:AimAt(Target)
        if Aimbot.Settings.AutoShoot then self:AutoShoot() end
    else
        FOVCircle.Color = Aimbot.Settings.FOVColor
    end
end

function Aimbot:IsBehindWall(part)
    if not Aimbot.Settings.WallCheck then return false end
    local camPos = Camera.CFrame.Position
    local dir = (part.Position - camPos).Unit * 500
    local ray = Ray.new(camPos, dir)
    local hit = workspace:FindPartOnRay(ray, LocalPlayer.Character)
    return hit and hit.Parent ~= part.Parent
end

function Aimbot:IsVisible(char, part)
    if not Aimbot.Settings.VisibleCheck then return true end
    if Aimbot.Settings.WallCheck and self:IsBehindWall(part) then return false end
    local camPos = Camera.CFrame.Position
    local ray = Ray.new(camPos, (part.Position - camPos).Unit * 500)
    local hit = workspace:FindPartOnRay(ray, LocalPlayer.Character)
    return hit and hit.Parent == char
end

function Aimbot:GetBestTarget(center)
    local targets = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Aimbot.Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end

        local char = player.Character
        if not char then continue end

        local part = char:FindFirstChild(Aimbot.Settings.AimPart) or char:FindFirstChild("Head")
        if not part then continue end

        if not self:IsVisible(char, part) then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        local distToCenter = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if distToCenter > Aimbot.Settings.FOV then continue end

        table.insert(targets, { Player = player, Part = part, DistToCenter = distToCenter })
    end

    if #targets == 0 then return nil end

    if Aimbot.Settings.Priority == "Distance" then
        table.sort(targets, function(a, b) return a.DistToCenter < b.DistToCenter end)
    elseif Aimbot.Settings.Priority == "Health" then
        table.sort(targets, function(a, b)
            local ha = a.Player.Character and a.Player.Character:FindFirstChildOfClass("Humanoid")
            local hb = b.Player.Character and b.Player.Character:FindFirstChildOfClass("Humanoid")
            return (ha and ha.Health or 100) < (hb and hb.Health or 100)
        end)
    elseif Aimbot.Settings.Priority == "Angle" then
        table.sort(targets, function(a, b) return a.DistToCenter < b.DistToCenter end)
    end

    return targets[1].Player
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

    if Aimbot.Settings.Shake then
        targetPos = targetPos + Vector3.new(
            (math.random() - 0.5) * Aimbot.Settings.ShakeAmount * 0.1,
            (math.random() - 0.5) * Aimbot.Settings.ShakeAmount * 0.1,
            (math.random() - 0.5) * Aimbot.Settings.ShakeAmount * 0.1
        )
    end

    local camPos = Camera.CFrame.Position
    local dir = (targetPos - camPos).Unit

    if Aimbot.Settings.Smoothness > 0 then
        local current = Camera.CFrame.LookVector
        dir = current:Lerp(dir, Aimbot.Settings.Smoothness)
    end

    Camera.CFrame = CFrame.new(camPos, camPos + dir)
end

function Aimbot:AutoShoot()
    if not Target then return end
    pcall(function()
        mouse1press()
        task.wait(0.05)
        mouse1release()
    end)
end

function Aimbot:Stop()
    if self.Connection then self.Connection:Disconnect(); self.Connection = nil end
    if FOVCircle then FOVCircle.Visible = false end
end

return Aimbot
