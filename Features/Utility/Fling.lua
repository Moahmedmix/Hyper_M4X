--[[
    ╔══════════════════════════════════════════════════╗
    ║           HYPER UI - Fling System                 ║
    ║              Version: v1.0.0                      ║
    ║         By M4X | EVA | AMAL                      ║
    ╚══════════════════════════════════════════════════╝
--]]

local Fling = {}
Fling.__index = Fling

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

Fling.Settings = {
    Enabled = false,
    Target = nil,
    TargetName = "",
    Power = 50,
    Interval = 0.3,
    AntiVoid = true,
}

Fling.Active = false
Fling.Conn = nil

function Fling:Init(tab, library, flags)
    local self = setmetatable({}, Fling)
    self.Tab = tab
    self.Library = library
    self.Flags = flags

    if flags then
        flags:Create("Fling_Target", "")
        flags:Create("Fling_Power", 50)
    end

    self:BuildUI()
    return self
end

function Fling:BuildUI()
    if not self.Tab then return end

    local Sec = self.Tab:Section({ Title = "Fling", Icon = "wind", Opened = true })

    -- Player list
    local function GetPlayers()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(list, p.Name) end
        end
        return list
    end

    Sec:Dropdown({ Title = "Select Player", Values = GetPlayers(), Value = "", Callback = function(v)
        Fling.Settings.Target = Players:FindFirstChild(v)
        Fling.Settings.TargetName = v or ""
        if self.Flags then self.Flags:Set("Fling_Target", v or "") end
    end })

    Sec:Button({ Title = "Start Fling", Callback = function()
        if not Fling.Settings.Target then
            self.Library:Notify({ Title = "Fling", Description = "Select a player first!", Duration = 2 })
            return
        end
        Fling:Start()
        self.Library:Notify({ Title = "Fling", Description = "Flinging " .. Fling.Settings.TargetName .. "!", Duration = 2 })
    end })

    Sec:Button({ Title = "Stop Fling", Callback = function()
        Fling:Stop()
        self.Library:Notify({ Title = "Fling", Description = "Stopped!", Duration = 2 })
    end })

    Sec:Slider({ Title = "Power", Step = 1, Value = { Min = 10, Max = 200, Default = 50 }, Callback = function(v)
        Fling.Settings.Power = v
        if self.Flags then self.Flags:Set("Fling_Power", v) end
    end })

    Sec:Slider({ Title = "Interval", Desc = "Time between flings", Step = 0.1, Value = { Min = 0.1, Max = 2, Default = 0.3 }, Callback = function(v)
        Fling.Settings.Interval = v
    end })

    Sec:Toggle({ Title = "Anti Void", Desc = "Prevent falling off map", Value = true, Callback = function(v)
        Fling.Settings.AntiVoid = v
    end })
end

function Fling:Start()
    if Fling.Active then return end
    Fling.Active = true

    Fling.Conn = RunService.Heartbeat:Connect(function()
        if not Fling.Active then return end

        local target = Fling.Settings.Target
        if not target or not target.Parent then
            Fling:Stop()
            return
        end

        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = hum and hum.RootPart
        if not hum or not root then return end

        local targetChar = target.Character
        if not targetChar then return end
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        local targetHead = targetChar:FindFirstChild("Head")
        if not targetRoot and not targetHead then return end

        local targetPart = targetRoot or targetHead

        -- Anti void
        if Fling.Settings.AntiVoid and root.Position.Y < -50 then
            root.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, 10, 0))
        end

        -- Fling
        local angle = (tick() * 500) % 360
        root.CFrame = CFrame.new(targetPart.Position) * CFrame.new(0, 2, 0) * CFrame.Angles(0, math.rad(angle), 0)
        root.Velocity = Vector3.new(math.random(-Fling.Settings.Power, Fling.Settings.Power) * 1000, Fling.Settings.Power * 100, math.random(-Fling.Settings.Power, Fling.Settings.Power) * 1000)
        root.RotVelocity = Vector3.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
    end)
end

function Fling:Stop()
    Fling.Active = false
    if Fling.Conn then
        Fling.Conn:Disconnect()
        Fling.Conn = nil
    end
end

return Fling
