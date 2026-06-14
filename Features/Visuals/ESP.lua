--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║           HYPER UI - ESP SYSTEM - NO GHOST (Billboard)       ║
    ║              By M4X | EVA | AMAL                            ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

local Services = require(script.Parent.Parent.Core.Services)
local PlayerUtils = require(script.Parent.Parent.Core.PlayerUtils)
local ConnectionManager = require(script.Parent.Parent.Core.ConnectionManager)

local ESP = {}
ESP.__index = ESP

local Players = Services.Players
local Camera = Services.Camera
local LocalPlayer = Services.LocalPlayer
local CoreGui = Services.CoreGui

ESP.Settings = {
    Enabled = false, MaxDist = 3000, TeamCheck = false, TeamColor = false, Rainbow = false,
    BoxColor = Color3.fromRGB(255, 255, 255), BoxThickness = 2, CornerLen = 22,
    Name = true, NameColor = Color3.fromRGB(255, 255, 255), NameSize = 13,
    Dist = true, DistColor = Color3.fromRGB(180, 180, 180),
    HP = true, HPPos = "Left", HPThick = 3,
    Tracer = false, Snap = false, Weapon = false, Skeleton = false, HeadDot = false,
}

ESP.Active = {}
ESP.ScreenGui = nil
ESP.RainbowHue = 0

function ESP:GetColor(p)
    if ESP.Settings.Rainbow then ESP.RainbowHue=(ESP.RainbowHue+0.003)%1 return Color3.fromHSV(ESP.RainbowHue,1,1) end
    if ESP.Settings.TeamColor and PlayerUtils.IsTeammate(p) then
        return Color3.fromRGB(50,255,50)
    elseif ESP.Settings.TeamColor and p.Team then
        return Color3.fromRGB(255,50,50)
    end
    return ESP.Settings.BoxColor
end

function ESP:CreateBillboard(player)
    local bill = Instance.new("BillboardGui")
    bill.Name = "ESP_" .. player.Name
    bill.AlwaysOnTop = true
    bill.Size = UDim2.new(0, 200, 0, 120)
    bill.StudsOffset = Vector3.new(0, 2.5, 0)
    bill.MaxDistance = ESP.Settings.MaxDist
    bill.Parent = ESP.ScreenGui
    bill.Adornee = player.Character and player.Character:FindFirstChild("Head")

    local name = Instance.new("TextLabel", bill)
    name.Name = "Name"
    name.Size = UDim2.new(1, 0, 0, 20)
    name.Position = UDim2.new(0, 0, 0, -24)
    name.BackgroundTransparency = 1
    name.Text = player.DisplayName
    name.TextColor3 = ESP.Settings.NameColor
    name.TextSize = ESP.Settings.NameSize
    name.Font = Enum.Font.GothamBold
    name.TextStrokeTransparency = 0.5

    local dist = Instance.new("TextLabel", bill)
    dist.Name = "Dist"
    dist.Size = UDim2.new(1, 0, 0, 18)
    dist.Position = UDim2.new(0, 0, 1, 4)
    dist.BackgroundTransparency = 1
    dist.Text = ""
    dist.TextColor3 = ESP.Settings.DistColor
    dist.TextSize = 12
    dist.Font = Enum.Font.Gotham
    dist.TextStrokeTransparency = 0.5

    local hpBg = Instance.new("Frame", bill)
    hpBg.Name = "HPBg"
    hpBg.Size = UDim2.new(0, 4, 1, 0)
    hpBg.Position = UDim2.new(0, -8, 0, 0)
    hpBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    hpBg.BorderSizePixel = 0

    local hpFill = Instance.new("Frame", hpBg)
    hpFill.Name = "HPFill"
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    hpFill.BorderSizePixel = 0

    local box = Instance.new("Frame", bill)
    box.Name = "Box"
    box.Size = UDim2.new(1, 0, 1, 0)
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0

    local stroke = Instance.new("UIStroke", box)
    stroke.Name = "Stroke"
    stroke.Color = ESP.Settings.BoxColor
    stroke.Thickness = ESP.Settings.BoxThickness
    stroke.LineJoinMode = Enum.LineJoinMode.Miter

    return bill
end

function ESP:UpdateBillboard(player, bill)
    local char, root, head, hum = PlayerUtils.GetCharacterParts(player)
    if not char or not head or not root then return end

    local dist = (Camera.CFrame.Position - root.Position).Magnitude

    bill.Adornee = head
    bill.MaxDistance = ESP.Settings.MaxDist

    local distLabel = bill:FindFirstChild("Dist")
    if distLabel then
        distLabel.Text = ESP.Settings.Dist and "[" .. math.floor(dist) .. "m]" or ""
        distLabel.TextColor3 = ESP.Settings.DistColor
    end

    local nameLabel = bill:FindFirstChild("Name")
    if nameLabel then
        nameLabel.Visible = ESP.Settings.Name
        nameLabel.TextColor3 = ESP.Settings.NameColor
        nameLabel.TextSize = ESP.Settings.NameSize
    end

    local hpBg = bill:FindFirstChild("HPBg")
    if hpBg then
        hpBg.Visible = ESP.Settings.HP and hum ~= nil
        local hpFill = hpBg:FindFirstChild("HPFill")
        if hpFill and hum then
            local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            hpFill.Size = UDim2.new(1, 0, pct, 0)
            if pct > 0.5 then hpFill.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            elseif pct > 0.25 then hpFill.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
            else hpFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50) end
        end
    end

    local box = bill:FindFirstChild("Box")
    if box then
        local stroke = box:FindFirstChild("Stroke")
        if stroke then
            stroke.Color = ESP:GetColor(player)
            stroke.Thickness = ESP.Settings.BoxThickness
        end
    end
end

function ESP:CleanupPlayer(p)
    if ESP.Active[p] then
        ESP.Active[p]:Destroy()
        ESP.Active[p] = nil
    end
end

function ESP:Update()
    local processed = {}

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then
            ESP:CleanupPlayer(p)
            continue
        end
        if ESP.Settings.TeamCheck and PlayerUtils.IsTeammate(p) then
            ESP:CleanupPlayer(p)
            continue
        end

        local char, root, head = PlayerUtils.GetCharacterParts(p)
        if not char or not head or not root then
            ESP:CleanupPlayer(p)
            continue
        end

        local dist = (Camera.CFrame.Position - root.Position).Magnitude
        if dist > ESP.Settings.MaxDist then
            ESP:CleanupPlayer(p)
            continue
        end

        if not ESP.Active[p] then
            ESP.Active[p] = ESP:CreateBillboard(p)
        end

        ESP:UpdateBillboard(p, ESP.Active[p])
        processed[p] = true
    end

    for p, bill in pairs(ESP.Active) do
        if not processed[p] then
            bill:Destroy()
            ESP.Active[p] = nil
        end
    end
end

function ESP:Start()
    if ESP.ScreenGui then ESP.ScreenGui:Destroy() end
    ESP.ScreenGui = Instance.new("ScreenGui", CoreGui)
    ESP.ScreenGui.Name = "Hyper_ESP"
    ESP.ScreenGui.ResetOnSpawn = false
    ESP.Active = {}
    if not ESP.ConnManager then ESP.ConnManager = ConnectionManager.new() end
    ESP.ConnManager:OnRenderStepped("esp_loop", function() ESP:Update() end)
end

function ESP:Stop()
    if ESP.ConnManager then ESP.ConnManager:DisconnectAll() end
    if ESP.ScreenGui then ESP.ScreenGui:Destroy(); ESP.ScreenGui = nil end
    ESP.Active = {}
end

Players.PlayerRemoving:Connect(function(p)
    ESP:CleanupPlayer(p)
end)

function ESP:Init(tab, library, flags)
    local self = setmetatable({}, ESP)
    self.Tab = tab; self.Library = library; self.Flags = flags
    ESP.ConnManager = ConnectionManager.new()

    local Sec = tab:Section({ Title = "ESP", Icon = "eye", Opened = true })
    Sec:Toggle({ Title = "Enable ESP", Value = false, Callback = function(v) ESP.Settings.Enabled = v; if v then ESP:Start() else ESP:Stop() end end })
    Sec:Slider({ Title = "Max Distance", Step = 100, Value = { Min = 100, Max = 10000, Default = 3000 }, Callback = function(v) ESP.Settings.MaxDist = v end })
    Sec:Toggle({ Title = "Team Check", Value = false, Callback = function(v) ESP.Settings.TeamCheck = v end })
    Sec:Toggle({ Title = "Team Color", Value = false, Callback = function(v) ESP.Settings.TeamColor = v end })

    local SecBox = tab:Section({ Title = "Box", Icon = "square", Opened = true })
    SecBox:Colorpicker({ Title = "Color", Default = ESP.Settings.BoxColor, Transparency = 0, Callback = function(v) ESP.Settings.BoxColor = v end })
    SecBox:Slider({ Title = "Thickness", Step = 0.5, Value = { Min = 1, Max = 6, Default = 2 }, Callback = function(v) ESP.Settings.BoxThickness = v end })

    local SecInfo = tab:Section({ Title = "Info", Icon = "user", Opened = true })
    SecInfo:Toggle({ Title = "Name", Value = true, Callback = function(v) ESP.Settings.Name = v end })
    SecInfo:Colorpicker({ Title = "Name Color", Default = ESP.Settings.NameColor, Transparency = 0, Callback = function(v) ESP.Settings.NameColor = v end })
    SecInfo:Slider({ Title = "Name Size", Step = 1, Value = { Min = 10, Max = 22, Default = 13 }, Callback = function(v) ESP.Settings.NameSize = v end })
    SecInfo:Toggle({ Title = "Distance", Value = true, Callback = function(v) ESP.Settings.Dist = v end })
    SecInfo:Colorpicker({ Title = "Dist Color", Default = ESP.Settings.DistColor, Transparency = 0, Callback = function(v) ESP.Settings.DistColor = v end })

    local SecHP = tab:Section({ Title = "Health", Icon = "heart", Opened = true })
    SecHP:Toggle({ Title = "HP Bar", Value = true, Callback = function(v) ESP.Settings.HP = v end })

    return self
end

return ESP
