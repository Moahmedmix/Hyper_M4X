--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║           HYPER UI - JUMP SYSTEM                             ║
    ║         Standalone | Multi-Jump                              ║
    ║              By M4X | EVA | AMAL                            ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

local Services = require(script.Parent.Parent.Core.Services)
local PlayerUtils = require(script.Parent.Parent.Core.PlayerUtils)

local Jump = {}
Jump.__index = Jump

local UserInputService = Services.UserInputService
local RunService = Services.RunService

Jump.Settings = { Enabled = false, Power = 100, MultiJump = false, MaxJumps = 5 }
Jump.JumpCount = 0

UserInputService.JumpRequest:Connect(function()
    if not Jump.Settings.Enabled then return end
    local char, root = PlayerUtils.GetLocalCharacterParts()
    if not root then return end

    if Jump.Settings.MultiJump then
        Jump.JumpCount += 1
        if Jump.JumpCount > Jump.Settings.MaxJumps then return end
    end

    root.Velocity = Vector3.new(root.Velocity.X, Jump.Settings.Power, root.Velocity.Z)
    pcall(function() root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, Jump.Settings.Power, root.AssemblyLinearVelocity.Z) end)

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bv.Velocity = Vector3.new(0, Jump.Settings.Power, 0)
    bv.Parent = root
    task.delay(0.1, function() bv:Destroy() end)
end)

RunService.Heartbeat:Connect(function()
    if not Jump.Settings.Enabled then return end
    local char, root = PlayerUtils.GetLocalCharacterParts()
    if root and root.Velocity.Y == 0 then Jump.JumpCount = 0 end
end)

function Jump:Init(tab, library, flags)
    local Sec = tab:Section({ Title = "Jump", Icon = "arrow-up", Opened = true })
    Sec:Toggle({ Title = "Enable", Value = false, Callback = function(v) Jump.Settings.Enabled = v; if not v then Jump.JumpCount = 0 end end })
    Sec:Slider({ Title = "Power", Step = 1, Value = { Min = 10, Max = 1000, Default = 100 }, Callback = function(v) Jump.Settings.Power = v end })
    Sec:Toggle({ Title = "Multi-Jump", Value = false, Callback = function(v) Jump.Settings.MultiJump = v; if not v then Jump.JumpCount = 0 end end })
    Sec:Slider({ Title = "Max Jumps", Step = 1, Value = { Min = 1, Max = 20, Default = 5 }, Callback = function(v) Jump.Settings.MaxJumps = v end })
end

return Jump
