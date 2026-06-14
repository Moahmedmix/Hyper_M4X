--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║           HYPER UI - TELEPORT SYSTEM                         ║
    ║         Standalone | Select Player + Button                  ║
    ║              By M4X | EVA | AMAL                            ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

local Services = require(script.Parent.Parent.Core.Services)
local PlayerUtils = require(script.Parent.Parent.Core.PlayerUtils)

local TP = {}
TP.__index = TP

local TweenService = Services.TweenService
local LocalPlayer = Services.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

TP.Settings = { Saved = nil, History = {}, Target = "", Offset = 3, Hidden = false }

local function DoTP(pos)
    local char, root = PlayerUtils.GetLocalCharacterParts()
    if not root then return false end

    table.insert(TP.Settings.History, root.CFrame)

    pcall(function() root.CFrame = CFrame.new(pos) end)
    if (root.Position - pos).Magnitude > 10 then
        pcall(function() char:SetPrimaryPartCFrame(CFrame.new(pos)) end)
    end
    if (root.Position - pos).Magnitude > 10 then
        pcall(function() char:MoveTo(pos) end)
    end
    if (root.Position - pos).Magnitude > 10 then
        TweenService:Create(root, TweenInfo.new(0.05), {CFrame = CFrame.new(pos)}):Play()
    end
    return true
end

function TP:Init(tab, library, flags)
    local Sec = tab:Section({ Title = "Teleport", Icon = "map-pin", Opened = true })

    Sec:Dropdown({ Title = "Select Player", Values = PlayerUtils.GetOtherPlayers(), Value = "", Callback = function(v) TP.Settings.Target = v end })

    Sec:Button({ Title = "Teleport", Callback = function()
        if TP.Settings.Target == "" then library:Notify({ Title = "TP", Description = "Select player first!", Duration = 2 }) return end
        local p = Services.Players:FindFirstChild(TP.Settings.Target)
        if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            DoTP(p.Character.HumanoidRootPart.Position + Vector3.new(0, TP.Settings.Offset, 0))
            library:Notify({ Title = "TP", Description = "Teleported!", Duration = 2 })
        end
    end })

    Sec:Button({ Title = "Behind Player", Callback = function()
        if TP.Settings.Target == "" then library:Notify({ Title = "TP", Description = "Select player first!", Duration = 2 }) return end
        local p = Services.Players:FindFirstChild(TP.Settings.Target)
        if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local cf = p.Character.HumanoidRootPart.CFrame
            DoTP((cf - cf.LookVector * 5).Position + Vector3.new(0, TP.Settings.Offset, 0))
            library:Notify({ Title = "TP", Description = "Behind!", Duration = 2 })
        end
    end })

    Sec:Slider({ Title = "Offset Y", Step = 1, Value = { Min = -20, Max = 50, Default = 3 }, Callback = function(v) TP.Settings.Offset = v end })
    Sec:Button({ Title = "TP to Mouse", Callback = function() DoTP(Mouse.Hit.Position + Vector3.new(0, 3, 0)) end })
    Sec:Button({ Title = "Save Position", Callback = function()
        local char, root = PlayerUtils.GetLocalCharacterParts()
        if root then TP.Settings.Saved = root.CFrame; library:Notify({ Title = "TP", Description = "Saved!", Duration = 2 }) end
    end })
    Sec:Button({ Title = "Load Position", Callback = function() if TP.Settings.Saved then DoTP(TP.Settings.Saved) end end })
    Sec:Button({ Title = "TP Up 50", Callback = function()
        local char, root = PlayerUtils.GetLocalCharacterParts()
        if root then DoTP(root.Position + Vector3.new(0, 50, 0)) end
    end })
    Sec:Button({ Title = "TP Down 50", Callback = function()
        local char, root = PlayerUtils.GetLocalCharacterParts()
        if root then DoTP(root.Position - Vector3.new(0, 50, 0)) end
    end })
    Sec:Button({ Title = "Undo", Callback = function() if #TP.Settings.History > 0 then DoTP(table.remove(TP.Settings.History)) end end })
    Sec:Toggle({ Title = "Hidden", Value = false, Callback = function(v)
        TP.Settings.Hidden = v
        local char, root = PlayerUtils.GetLocalCharacterParts()
        if not root then return end
        if v then TP.Settings.Saved = root.CFrame; DoTP(root.Position - Vector3.new(0, 1000, 0))
        elseif TP.Settings.Saved then DoTP(TP.Settings.Saved) end
    end })
end

return TP
