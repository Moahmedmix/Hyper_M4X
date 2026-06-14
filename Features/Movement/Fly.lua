--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║           HYPER UI - FLY SYSTEM                              ║
    ║         Standalone | Anti-Cheat Bypass                       ║
    ║              By M4X | EVA | AMAL                            ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

local Services = require(script.Parent.Parent.Core.Services)
local PlayerUtils = require(script.Parent.Parent.Core.PlayerUtils)
local ConnectionManager = require(script.Parent.Parent.Core.ConnectionManager)

local Fly = {}
Fly.__index = Fly

local UserInputService = Services.UserInputService
local TweenService = Services.TweenService
local LocalPlayer = Services.LocalPlayer
local Camera = Services.Camera

Fly.Settings = {
    Enabled = false,
    Speed = 50,
    Mode = "CFrame",
    NoClip = false,
    AntiKick = true,
    Invisible = false,
}

Fly.Keys = { W = false, S = false, A = false, D = false, Space = false, Ctrl = false, Shift = false }

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local k = input.KeyCode
    if k == Enum.KeyCode.W then Fly.Keys.W = true elseif k == Enum.KeyCode.S then Fly.Keys.S = true
    elseif k == Enum.KeyCode.A then Fly.Keys.A = true elseif k == Enum.KeyCode.D then Fly.Keys.D = true
    elseif k == Enum.KeyCode.Space then Fly.Keys.Space = true elseif k == Enum.KeyCode.LeftControl then Fly.Keys.Ctrl = true
    elseif k == Enum.KeyCode.LeftShift or k == Enum.KeyCode.RightShift then Fly.Keys.Shift = true end
end)

UserInputService.InputEnded:Connect(function(input)
    local k = input.KeyCode
    if k == Enum.KeyCode.W then Fly.Keys.W = false elseif k == Enum.KeyCode.S then Fly.Keys.S = false
    elseif k == Enum.KeyCode.A then Fly.Keys.A = false elseif k == Enum.KeyCode.D then Fly.Keys.D = false
    elseif k == Enum.KeyCode.Space then Fly.Keys.Space = false elseif k == Enum.KeyCode.LeftControl then Fly.Keys.Ctrl = false
    elseif k == Enum.KeyCode.LeftShift or k == Enum.KeyCode.RightShift then Fly.Keys.Shift = false end
end)

function Fly:Start()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")
    pcall(function() hum.PlatformStand = true end)

    if not Fly.ConnManager then Fly.ConnManager = ConnectionManager.new() end
    Fly.ConnManager:OnHeartbeat("fly_loop", function()
        if not Fly.Settings.Enabled then return end
        local char, root = PlayerUtils.GetLocalCharacterParts()
        if not root then return end

        if Fly.Settings.AntiKick then root.Velocity = Vector3.zero; root.RotVelocity = Vector3.zero end

        local dir = Vector3.zero
        local cam = Camera.CFrame
        if Fly.Keys.W then dir += cam.LookVector end
        if Fly.Keys.S then dir -= cam.LookVector end
        if Fly.Keys.A then dir -= cam.RightVector end
        if Fly.Keys.D then dir += cam.RightVector end
        if Fly.Keys.Space then dir += Vector3.new(0, 1, 0) end
        if Fly.Keys.Ctrl then dir -= Vector3.new(0, 1, 0) end
        if Fly.Keys.Shift then dir *= 2 end

        if dir.Magnitude > 0 then
            dir = dir.Unit * Fly.Settings.Speed * 0.033
            if Fly.Settings.Mode == "CFrame" then
                root.CFrame += dir
            elseif Fly.Settings.Mode == "Velocity" then
                root.Velocity = dir / 0.033
            elseif Fly.Settings.Mode == "Tween" then
                TweenService:Create(root, TweenInfo.new(0.05), {CFrame = root.CFrame + dir}):Play()
            elseif Fly.Settings.Mode == "BodyVelocity" then
                local bv = root:FindFirstChild("FlyBV")
                if not bv then bv = Instance.new("BodyVelocity"); bv.Name = "FlyBV"; bv.MaxForce = Vector3.new(1e10,1e10,1e10); bv.Parent = root end
                bv.Velocity = dir / 0.033
            end
        end

        if Fly.Settings.Invisible and root.Position.Y > -10 then
            root.CFrame = CFrame.new(root.Position.X, -50, root.Position.Z)
        end
    end)
end

function Fly:Stop()
    if Fly.ConnManager then Fly.ConnManager:DisconnectAll() end
    local char, root, _, hum = PlayerUtils.GetLocalCharacterParts()
    if root and root:FindFirstChild("FlyBV") then root.FlyBV:Destroy() end
    if hum then hum.PlatformStand = false end
end

function Fly:Init(tab, library, flags)
    Fly.ConnManager = ConnectionManager.new()
    local Sec = tab:Section({ Title = "Fly", Icon = "feather", Opened = true })
    Sec:Toggle({ Title = "Enable", Value = false, Callback = function(v) Fly.Settings.Enabled = v; if v then Fly:Start() else Fly:Stop() end end })
    Sec:Slider({ Title = "Speed", Step = 1, Value = { Min = 10, Max = 500, Default = 50 }, Callback = function(v) Fly.Settings.Speed = v end })
    Sec:Dropdown({ Title = "Mode", Values = { "CFrame", "Velocity", "Tween", "BodyVelocity" }, Value = "CFrame", Callback = function(v) Fly.Settings.Mode = v; if Fly.Settings.Enabled then Fly:Stop(); Fly:Start() end end })
    Sec:Toggle({ Title = "NoClip", Value = false, Callback = function(v) Fly.Settings.NoClip = v end })
    Sec:Toggle({ Title = "Anti-Kick", Value = true, Callback = function(v) Fly.Settings.AntiKick = v end })
    Sec:Toggle({ Title = "Invisible", Value = false, Callback = function(v) Fly.Settings.Invisible = v end })
end

return Fly
