--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║           HYPER UI - SPEED SYSTEM                            ║
    ║         Standalone | Bunny Hop                               ║
    ║              By M4X | EVA | AMAL                            ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

local Services = require(script.Parent.Parent.Core.Services)
local PlayerUtils = require(script.Parent.Parent.Core.PlayerUtils)
local ConnectionManager = require(script.Parent.Parent.Core.ConnectionManager)

local Speed = {}
Speed.__index = Speed

local LocalPlayer = Services.LocalPlayer

Speed.Settings = { Enabled = false, Value = 50, BHop = false }

function Speed:Start()
    if not Speed.ConnManager then Speed.ConnManager = ConnectionManager.new() end
    Speed.ConnManager:OnHeartbeat("speed_loop", function()
        if not Speed.Settings.Enabled then return end
        local char, root, _, hum = PlayerUtils.GetLocalCharacterParts()
        if not hum then return end

        hum.WalkSpeed = Speed.Settings.Value

        if Speed.Settings.BHop and hum.MoveDirection.Magnitude > 0 then
            if root and root.Velocity.Y == 0 then root.Velocity = Vector3.new(root.Velocity.X, 20, root.Velocity.Z) end
            if root then root.Velocity = hum.MoveDirection * Speed.Settings.Value end
        end
    end)
end

function Speed:Stop()
    if Speed.ConnManager then Speed.ConnManager:DisconnectAll() end
    local char, _, _, hum = PlayerUtils.GetLocalCharacterParts()
    if hum then hum.WalkSpeed = 16 end
end

function Speed:Init(tab, library, flags)
    Speed.ConnManager = ConnectionManager.new()
    local Sec = tab:Section({ Title = "Speed", Icon = "gauge", Opened = true })
    Sec:Toggle({ Title = "Enable", Value = false, Callback = function(v) Speed.Settings.Enabled = v; if v then Speed:Start() else Speed:Stop() end end })
    Sec:Slider({ Title = "Speed", Step = 1, Value = { Min = 16, Max = 1000, Default = 50 }, Callback = function(v) Speed.Settings.Value = v end })
    Sec:Toggle({ Title = "Bunny Hop", Value = false, Callback = function(v) Speed.Settings.BHop = v end })
end

return Speed
