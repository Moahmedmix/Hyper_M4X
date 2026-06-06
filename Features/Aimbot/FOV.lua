--[[
    ╔══════════════════════════════════════════════════╗
    ║           HYPER UI - Aimbot System v2             ║
    ║         Mobile Optimized | No Input Change         ║
    ║              By M4X | EVA | AMAL                  ║
    ╚══════════════════════════════════════════════════╝

    Features:
    - Silent Aim
    - FOV Circle with full customization
    - Smooth aim control
    - Prediction
    - Team check & Visible check
    - Wall check (Raycast)
    - Auto Shoot (Mobile Safe - Tool Fire Method)
    - Priority System
    - Shake Humanizer
    - FOV Circle Fill + Transparency
    - Skeleton Aim (aims at bone instead of part)
--]]

local Aimbot = {}
Aimbot.__index = Aimbot

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

Aimbot.Settings = {
    -- Main
    Enabled = false,
    ShowFOV = true,
    AutoShoot = false,
    ShootDelay = 0.1,
    TriggerBot = false,
    TriggerKey = Enum.KeyCode.E,

    -- FOV Circle
    FOV = 150,
    FOVColor = Color3.fromRGB(255, 255, 255),
    LockedColor = Color3.fromRGB(255, 0, 0),
    FOVThickness = 2,
    FOVNumSides = 64,
    FOVFilled = false,
    FOVFillColor = Color3.fromRGB(255, 255, 255),
    FOVFillTransparency = 0.9,

    -- Aim Settings
    Smoothness = 0.1,
    AimPart = "Head",
    Prediction = 0,
    Priority = "Distance",
    TeamCheck = false,
    VisibleCheck = false,
    WallCheck = true,

    -- Humanizer
    Shake = false,
    ShakeAmount = 1,
    SmoothRandom = false,
    SmoothRandomRange = 0.05,

    -- Skeleton Aim
    SkeletonAim = false,
    SkeletonBone = "Head",
}

local Target = nil
local FOVCircle = nil
local LastShot = 0
local SmoothRandomOffset = 0

-- =============================================
-- SKELETON BONES
-- =============================================
local SkeletonBones = {
    "Head", "UpperTorso", "LowerTorso",
    "LeftUpperArm", "LeftLowerArm", "LeftHand",
    "RightUpperArm", "RightLowerArm", "RightHand",
    "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
    "RightUpperLeg", "RightLowerLeg", "RightFoot",
}

function Aimbot:Init(tab, library, flags)
    local self = setmetatable({}, Aimbot)
    self.Tab = tab
    self.Library = library
    self.Flags = flags
    self.Connection = nil
    self.TriggerConn = nil
    self._triggerPressed = false

    -- Create FOV Circle
    local ss = Camera.ViewportSize
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Color = Aimbot.Settings.FOVColor
    FOVCircle.Thickness = Aimbot.Settings.FOVThickness
    FOVCircle.NumSides = Aimbot.Settings.FOVNumSides
    FOVCircle.Radius = Aimbot.Settings.FOV
    FOVCircle.Filled = Aimbot.Settings.FOVFilled
    FOVCircle.Position = Vector2.new(ss.X / 2, ss.Y / 2)
    FOVCircle.ZIndex = 10

    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        local s = Camera.ViewportSize
        FOVCircle.Position = Vector2.new(s.X / 2, s.Y / 2)
    end)

    -- Trigger Bot key listener
    self.TriggerConn = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Aimbot.Settings.TriggerKey then
            self._triggerPressed = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Aimbot.Settings.TriggerKey then
            self._triggerPressed = false
        end
    end)

    self:BuildUI()
    self:StartLoop()
    return self
end

function Aimbot:BuildUI()
    if not self.Tab then return end

    -- ============ MAIN ============
    local mainSec = self.Tab:Section({ Title = "Main", Icon = "crosshair", Opened = true })
    mainSec:Toggle({ Title = "Enable Aimbot", Value = false, Callback = function(s)
        Aimbot.Settings.Enabled = s
        if not s and FOVCircle then FOVCircle.Visible = false end
    end })
    mainSec:Toggle({ Title = "Show FOV Circle", Value = true, Callback = function(s) Aimbot.Settings.ShowFOV = s end })
    mainSec:Toggle({ Title = "Auto Shoot", Value = false, Callback = function(s) Aimbot.Settings.AutoShoot = s end })
    mainSec:Slider({ Title = "Shoot Delay", Desc = "Seconds between shots", Step = 0.01, Value = { Min = 0, Max = 0.5, Default = 0.1 }, Callback = function(v) Aimbot.Settings.ShootDelay = v end })
    mainSec:Toggle({ Title = "Trigger Bot", Desc = "Press key to shoot", Value = false, Callback = function(s) Aimbot.Settings.TriggerBot = s end })

    -- ============ FOV CIRCLE ============
    local circleSec = self.Tab:Section({ Title = "FOV Circle", Icon = "circle", Opened = true })
    circleSec:Slider({ Title = "FOV Radius", Step = 5, Value = { Min = 50, Max = 500, Default = 150 }, Callback = function(v) Aimbot.Settings.FOV = v end })
    circleSec:Slider({ Title = "Thickness", Step = 0.5, Value = { Min = 1, Max = 5, Default = 2 }, Callback = function(v) Aimbot.Settings.FOVThickness = v end })
    circleSec:Slider({ Title = "Sides", Desc = "Circle smoothness", Step = 8, Value = { Min = 8, Max = 128, Default = 64 }, Callback = function(v) Aimbot.Settings.FOVNumSides = v; FOVCircle.NumSides = v end })
    circleSec:Toggle({ Title = "Filled", Value = false, Callback = function(s) Aimbot.Settings.FOVFilled = s; FOVCircle.Filled = s end })
    circleSec:Slider({ Title = "Fill Alpha", Step = 0.1, Value = { Min = 0, Max = 1, Default = 0.9 }, Callback = function(v) Aimbot.Settings.FOVFillTransparency = v; FOVCircle.Transparency = v end })

    -- ============ COLORS ============
    local colorSec = self.Tab:Section({ Title = "Colors", Icon = "palette", Opened = true })
    colorSec:Colorpicker({ Title = "Normal Color", Default = Aimbot.Settings.FOVColor, Transparency = 0, Callback = function(c) Aimbot.Settings.FOVColor = c end })
    colorSec:Colorpicker({ Title = "Locked Color", Default = Aimbot.Settings.LockedColor, Transparency = 0, Callback = function(c) Aimbot.Settings.LockedColor = c end })
    colorSec:Colorpicker({ Title = "Fill Color", Default = Aimbot.Settings.FOVFillColor, Transparency = 0, Callback = function(c) Aimbot.Settings.FOVFillColor = c end })

    -- ============ AIM SETTINGS ============
    local aimSec = self.Tab:Section({ Title = "Aim Settings", Icon = "target", Opened = true })
    aimSec:Slider({ Title = "Smoothness", Desc = "0 = instant | 1 = slow", Step = 0.01, Value = { Min = 0, Max = 1, Default = 0.1 }, Callback = function(v) Aimbot.Settings.Smoothness = v end })
    aimSec:Slider({ Title = "Prediction", Desc = "Predict enemy movement", Step = 0.01, Value = { Min = 0, Max = 0.5, Default = 0 }, Callback = function(v) Aimbot.Settings.Prediction = v end })
    aimSec:Dropdown({ Title = "Aim Part", Values = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, Value = "Head", Callback = function(v) Aimbot.Settings.AimPart = v end })
    aimSec:Dropdown({ Title = "Priority", Desc = "How to choose target", Values = {"Distance", "Health", "Angle"}, Value = "Distance", Callback = function(v) Aimbot.Settings.Priority = v end })
    aimSec:Toggle({ Title = "Team Check", Value = false, Callback = function(s) Aimbot.Settings.TeamCheck = s end })
    aimSec:Toggle({ Title = "Visible Check", Value = false, Callback = function(s) Aimbot.Settings.VisibleCheck = s end })
    aimSec:Toggle({ Title = "Wall Check", Desc = "Don't aim through walls", Value = true, Callback = function(s) Aimbot.Settings.WallCheck = s end })

    -- ============ SKELETON AIM ============
    local skelSec = self.Tab:Section({ Title = "Skeleton Aim", Icon = "bone", Opened = false })
    skelSec:Toggle({ Title = "Skeleton Aim", Desc = "Aim at any bone", Value = false, Callback = function(s) Aimbot.Settings.SkeletonAim = s end })
    skelSec:Dropdown({ Title = "Bone", Values = SkeletonBones, Value = "Head", Callback = function(v) Aimbot.Settings.SkeletonBone = v end })

    -- ============ HUMANIZER ============
    local shakeSec = self.Tab:Section({ Title = "Humanizer", Icon = "radio", Opened = false })
    shakeSec:Toggle({ Title = "Shake", Desc = "Add random shake to aim", Value = false, Callback = function(s) Aimbot.Settings.Shake = s end })
    shakeSec:Slider({ Title = "Shake Amount", Step = 0.1, Value = { Min = 0.1, Max = 5, Default = 1 }, Callback = function(v) Aimbot.Settings.ShakeAmount = v end })
    shakeSec:Toggle({ Title = "Random Smooth", Desc = "Vary smoothness randomly", Value = false, Callback = function(s) Aimbot.Settings.SmoothRandom = s end })
    shakeSec:Slider({ Title = "Random Range", Step = 0.01, Value = { Min = 0.01, Max = 0.2, Default = 0.05 }, Callback = function(v) Aimbot.Settings.SmoothRandomRange = v end })
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

    -- Update FOV Circle
    if Aimbot.Settings.ShowFOV then
        FOVCircle.Visible = true
        FOVCircle.Radius = Aimbot.Settings.FOV
        FOVCircle.Thickness = Aimbot.Settings.FOVThickness
        FOVCircle.NumSides = Aimbot.Settings.FOVNumSides
        FOVCircle.Filled = Aimbot.Settings.FOVFilled
        FOVCircle.Transparency = Aimbot.Settings.FOVFillTransparency
    else
        FOVCircle.Visible = false
    end

    -- Random smoothness variation
    if Aimbot.Settings.SmoothRandom then
        SmoothRandomOffset = (math.random() - 0.5) * Aimbot.Settings.SmoothRandomRange * 2
    end

    -- Get best target
    Target = self:GetBestTarget(center)

    if Target then
        FOVCircle.Color = Aimbot.Settings.LockedColor
        self:AimAt(Target)

        -- Auto Shoot
        if Aimbot.Settings.AutoShoot then
            self:MobileShoot()
        end

        -- Trigger Bot
        if Aimbot.Settings.TriggerBot and self._triggerPressed then
            self:MobileShoot()
        end
    else
        FOVCircle.Color = Aimbot.Settings.FOVColor
    end
end

-- =============================================
-- VISIBILITY CHECK
-- =============================================
function Aimbot:IsVisible(player)
    if not Aimbot.Settings.VisibleCheck then return true end
    local char = player.Character
    if not char then return false end
    local part = char:FindFirstChild(Aimbot.Settings.AimPart) or char:FindFirstChild("Head")
    if not part then return false end

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.IgnoreWater = true

    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * 500
    local result = workspace:Raycast(origin, direction, rayParams)
    if result then
        return result.Instance:IsDescendantOf(char)
    end
    return true
end

-- =============================================
-- WALL CHECK
-- =============================================
function Aimbot:IsNotBehindWall(player)
    if not Aimbot.Settings.WallCheck then return true end
    local char = player.Character
    if not char then return false end
    local part = char:FindFirstChild(Aimbot.Settings.AimPart) or char:FindFirstChild("Head")
    if not part then return false end

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, char}
    rayParams.IgnoreWater = true

    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude
    local result = workspace:Raycast(origin, direction, rayParams)
    if result then
        return false
    end
    return true
end

-- =============================================
-- GET BEST TARGET (Priority System)
-- =============================================
function Aimbot:GetBestTarget(center)
    local targets = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Aimbot.Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end

        local char = player.Character
        if not char then continue end

        local part
        if Aimbot.Settings.SkeletonAim then
            part = char:FindFirstChild(Aimbot.Settings.SkeletonBone)
        else
            part = char:FindFirstChild(Aimbot.Settings.AimPart) or char:FindFirstChild("Head")
        end
        if not part then continue end

        if not self:IsVisible(player) then continue end
        if not self:IsNotBehindWall(player) then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        local distToCenter = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if distToCenter > Aimbot.Settings.FOV then continue end

        local hum = char:FindFirstChildOfClass("Humanoid")
        local health = hum and hum.Health or 100

        table.insert(targets, {
            Player = player,
            Part = part,
            DistToCenter = distToCenter,
            Health = health,
            Distance = (Camera.CFrame.Position - part.Position).Magnitude,
        })
    end

    if #targets == 0 then return nil end

    -- Sort by priority
    if Aimbot.Settings.Priority == "Distance" then
        table.sort(targets, function(a, b) return a.DistToCenter < b.DistToCenter end)
    elseif Aimbot.Settings.Priority == "Health" then
        table.sort(targets, function(a, b) return a.Health < b.Health end)
    elseif Aimbot.Settings.Priority == "Angle" then
        table.sort(targets, function(a, b) return a.DistToCenter < b.DistToCenter end)
    end

    return targets[1].Player
end

-- =============================================
-- AIM AT TARGET
-- =============================================
function Aimbot:AimAt(target)
    local char = target.Character
    if not char then return end

    local part
    if Aimbot.Settings.SkeletonAim then
        part = char:FindFirstChild(Aimbot.Settings.SkeletonBone)
    else
        part = char:FindFirstChild(Aimbot.Settings.AimPart) or char:FindFirstChild("Head")
    end
    if not part then return end

    local targetPos = part.Position

    -- Prediction
    if Aimbot.Settings.Prediction > 0 then
        local vel = part.Velocity or Vector3.zero
        targetPos = targetPos + vel * Aimbot.Settings.Prediction
    end

    -- Shake
    if Aimbot.Settings.Shake then
        local shakeVec = Vector3.new(
            (math.random() - 0.5) * Aimbot.Settings.ShakeAmount * 0.1,
            (math.random() - 0.5) * Aimbot.Settings.ShakeAmount * 0.1,
            (math.random() - 0.5) * Aimbot.Settings.ShakeAmount * 0.1
        )
        targetPos = targetPos + shakeVec
    end

    local camPos = Camera.CFrame.Position
    local dir = (targetPos - camPos).Unit

    -- Smoothness with random variation
    local smoothness = Aimbot.Settings.Smoothness
    if Aimbot.Settings.SmoothRandom then
        smoothness = math.clamp(smoothness + SmoothRandomOffset, 0, 1)
    end

    if smoothness > 0 then
        local current = Camera.CFrame.LookVector
        dir = current:Lerp(dir, smoothness)
    end

    Camera.CFrame = CFrame.new(camPos, camPos + dir)
end

-- =============================================
-- MOBILE SAFE SHOOT (Tool Fire Only)
-- =============================================
function Aimbot:MobileShoot()
    local now = tick()
    if now - LastShot < Aimbot.Settings.ShootDelay then return end
    LastShot = now

    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool and tool.Activate then
                tool:Activate()
                task.wait(0.05)
                if tool.Deactivate then
                    tool:Deactivate()
                end
            end
        end
    end)
end

-- =============================================
-- STOP
-- =============================================
function Aimbot:Stop()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    if self.TriggerConn then
        self.TriggerConn:Disconnect()
        self.TriggerConn = nil
    end
    if FOVCircle then
        FOVCircle.Visible = false
    end
end

return Aimbot
