--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║           HYPER UI - SPEED SYSTEM                            ║
    ║         Standalone | Bunny Hop                               ║
    ║              By M4X | EVA | AMAL                            ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

local Speed = {}
Speed.__index = Speed

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

Speed.Settings = { Enabled = false, Value = 50, BHop = false }
Speed.Conn = nil

function Speed:Start()
    Speed.Conn = RunService.Heartbeat:Connect(function()
        if not Speed.Settings.Enabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum then return end

        hum.WalkSpeed = Speed.Settings.Value

        if Speed.Settings.BHop and hum.MoveDirection.Magnitude > 0 then
            if root and root.Velocity.Y == 0 then root.Velocity = Vector3.new(root.Velocity.X, 20, root.Velocity.Z) end
            if root then root.Velocity = hum.MoveDirection * Speed.Settings.Value end
        end
    end)
end

function Speed:Stop()
    if Speed.Conn then Speed.Conn:Disconnect(); Speed.Conn = nil end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end

function Speed:Init(tab, library, flags)
    local Sec = tab:Section({ Title = "Speed", Icon = "gauge", Opened = true })
    Sec:Toggle({ Title = "Enable", Value = false, Callback = function(v) Speed.Settings.Enabled = v; if v then Speed:Start() else Speed:Stop() end end })
    Sec:Slider({ Title = "Speed", Step = 1, Value = { Min = 16, Max = 1000, Default = 50 }, Callback = function(v) Speed.Settings.Value = v end })
    Sec:Toggle({ Title = "Bunny Hop", Value = false, Callback = function(v) Speed.Settings.BHop = v end })
end

return Speed
