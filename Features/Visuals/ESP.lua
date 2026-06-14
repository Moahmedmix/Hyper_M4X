--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║           HYPER UI - ESP SYSTEM - NO GHOST (Billboard)       ║
    ║              By M4X | EVA | AMAL                            ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

local ESP = {}
ESP.__index = ESP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

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
ESP.Conn = nil
ESP.RainbowHue = 0

function ESP:GetColor(p)
    if ESP.Settings.Rainbow then ESP.RainbowHue=(ESP.RainbowHue+0.003)%1 return Color3.fromHSV(ESP.RainbowHue,1,1) end
    if ESP.Settings.TeamColor and p.Team and LocalPlayer.Team then
        if p.Team==LocalPlayer.Team then return Color3.fromRGB(50,255,50) end
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

    -- Name
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

    -- Distance
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

    -- HP BG
    local hpBg = Instance.new("Frame", bill)
    hpBg.Name = "HPBg"
    hpBg.Size = UDim2.new(0, 4, 1, 0)
    hpBg.Position = UDim2.new(0, -8, 0, 0)
    hpBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    hpBg.BorderSizePixel = 0

    -- HP Fill
    local hpFill = Instance.new("Frame", hpBg)
    hpFill.Name = "HPFill"
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    hpFill.BorderSizePixel = 0

    -- Corner lines (4 lines around the billboard)
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
    local char = player.Character
    if not char then return end

    local head = char:FindFirstChild("Head")
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not head or not root then return end

    local dist = (Camera.CFrame.Position - root.Position).Magnitude

    -- Update adornee
    bill.Adornee = head
    bill.MaxDistance = ESP.Settings.MaxDist

    -- Update distance
    local distLabel = bill:FindFirstChild("Dist")
    if distLabel then
        distLabel.Text = ESP.Settings.Dist and "[" .. math.floor(dist) .. "m]" or ""
        distLabel.TextColor3 = ESP.Settings.DistColor
    end

    -- Update name
    local nameLabel = bill:FindFirstChild("Name")
    if nameLabel then
        nameLabel.Visible = ESP.Settings.Name
        nameLabel.TextColor3 = ESP.Settings.NameColor
        nameLabel.TextSize = ESP.Settings.NameSize
    end

    -- Update HP
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

    -- Update box stroke
    local box = bill:FindFirstChild("Box")
    if box then
        local stroke = box:FindFirstChild("Stroke")
        if stroke then
            stroke.Color = ESP:GetColor(player)
            stroke.Thickness = ESP.Settings.BoxThickness
        end
    end
end

function ESP:Update()
    local mt = LocalPlayer.Team
    local processed = {}

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then
            if ESP.Active[p] then ESP.Active[p]:Destroy(); ESP.Active[p] = nil end
            continue
        end
        if ESP.Settings.TeamCheck and p.Team == mt then
            if ESP.Active[p] then ESP.Active[p]:Destroy(); ESP.Active[p] = nil end
            continue
        end

        local char = p.Character
        if not char then
            if ESP.Active[p] then ESP.Active[p]:Destroy(); ESP.Active[p] = nil end
            continue
        end

        local head = char:FindFirstChild("Head")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not head or not root then
            if ESP.Active[p] then ESP.Active[p]:Destroy(); ESP.Active[p] = nil end
            continue
        end

        local dist = (Camera.CFrame.Position - root.Position).Magnitude
        if dist > ESP.Settings.MaxDist then
            if ESP.Active[p] then ESP.Active[p]:Destroy(); ESP.Active[p] = nil end
            continue
        end

        if not ESP.Active[p] then
            ESP.Active[p] = ESP:CreateBillboard(p)
        end

        ESP:UpdateBillboard(p, ESP.Active[p])
        processed[p] = true
    end

    -- Cleanup
    for p, bill in pairs(ESP.Active) do
        if not processed[p] then
            bill:Destroy()
            ESP.Active[p] = nil
        end
    end
end

function ESP:Start()
    if ESP.ScreenGui then pcall(function() ESP.ScreenGui:Destroy() end) end
    local guiOk, guiErr = pcall(function()
        ESP.ScreenGui = Instance.new("ScreenGui", CoreGui)
        ESP.ScreenGui.Name = "Hyper_ESP"
        ESP.ScreenGui.ResetOnSpawn = false
    end)
    if not guiOk then
        warn("[Hyper] ESP ScreenGui creation failed: " .. tostring(guiErr))
        return
    end
    ESP.Active = {}
    ESP.Conn = RunService.RenderStepped:Connect(function()
        local ok, err = pcall(ESP.Update)
        if not ok then
            warn("[Hyper] ESP update error: " .. tostring(err))
        end
    end)
end

function ESP:Stop()
    if ESP.Conn then ESP.Conn:Disconnect(); ESP.Conn = nil end
    if ESP.ScreenGui then ESP.ScreenGui:Destroy(); ESP.ScreenGui = nil end
    ESP.Active = {}
end

Players.PlayerRemoving:Connect(function(p)
    if ESP.Active[p] then ESP.Active[p]:Destroy(); ESP.Active[p] = nil end
end)

function ESP:Init(tab, library, flags)
    local self = setmetatable({}, ESP)
    self.Tab = tab; self.Library = library; self.Flags = flags

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
