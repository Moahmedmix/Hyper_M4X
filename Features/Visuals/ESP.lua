--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                    HYPER UI - ESP v2.0                       ║
    ║               By M4X | EVA | AMAL                           ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

local ESP = {}
ESP.__index = ESP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local V3New = Vector3.new

ESP.Settings = {
    Enabled = false,
    Rainbow = false,
    RainbowSpeed = 3,
    Box_Enabled = true,
    Box_Type = "2D",
    Box_Color = Color3.fromRGB(255, 255, 255),
    Box_Thickness = 1.5,
    Box_Filled = false,
    Box_FillColor = Color3.fromRGB(255, 255, 255),
    Box_FillTransparency = 0.7,
    Box_Outline = true,
    Box_OutlineColor = Color3.fromRGB(0, 0, 0),
    Corner_Color = Color3.fromRGB(0, 255, 255),
    Corner_Thickness = 2,
    Corner_Length = 15,
    Name_Enabled = true,
    Name_Color = Color3.fromRGB(255, 255, 255),
    Name_Size = 14,
    Name_Font = "GothamBold",
    Distance_Enabled = true,
    Distance_Color = Color3.fromRGB(200, 200, 200),
    Distance_Size = 13,
    Health_Enabled = true,
    Health_Position = "Left",
    Health_BarWidth = 4,
    Health_BGColor = Color3.fromRGB(30, 30, 30),
    HealthText_Enabled = true,
    HealthText_Color = Color3.fromRGB(255, 255, 255),
    Tracer_Enabled = false,
    Tracer_Color = Color3.fromRGB(255, 255, 255),
    Tracer_Thickness = 1,
    Tracer_Origin = "Bottom",
    Tracer_Transparency = 0.3,
    HeadDot_Enabled = false,
    HeadDot_Color = Color3.fromRGB(255, 0, 0),
    HeadDot_Size = 8,
    Snapline_Enabled = false,
    Snapline_Color = Color3.fromRGB(255, 255, 255),
    Snapline_Thickness = 1,
    Arrow_Enabled = false,
    Arrow_Color = Color3.fromRGB(255, 0, 0),
    Arrow_Size = 15,
    Arrow_Distance = 30,
    Fade_Enabled = true,
    Fade_Speed = 0.12,
    Fade_MaxOpacity = 0.35,
    Fade_MinOpacity = 0,
    TeamCheck = false,
    TeamColor = false,
    MaxDistance = 2500,
    ShowDead = false,
    UpdateRate = 30,
}

ESP.Elements = {}
ESP.ScreenGui = nil
ESP.Connection = nil
ESP.PlayerAddedCon = nil
ESP.PlayerRemovingCon = nil

local FontMap = {
    Gotham = Enum.Font.Gotham,
    GothamBold = Enum.Font.GothamBold,
    SourceSans = Enum.Font.SourceSans,
    FredokaOne = Enum.Font.FredokaOne,
    Ubuntu = Enum.Font.Ubuntu,
    LuckiestGuy = Enum.Font.LuckiestGuy,
    SciFi = Enum.Font.SciFi,
    Fantasy = Enum.Font.Fantasy,
}

local function GetRainbowColor(speed)
    return Color3.fromHSV((tick() * (speed or 1) * 60) % 360 / 360, 1, 1)
end

local function GetColor(player, baseColor)
    if ESP.Settings.Rainbow then return GetRainbowColor(ESP.Settings.RainbowSpeed) end
    if ESP.Settings.TeamColor and player.Team then return player.Team.TeamColor.Color end
    return baseColor
end

function ESP:Init(tab, library, flags)
    local self = setmetatable({}, ESP)
    self.Tab = tab
    self.Library = library
    self.Flags = flags
    self:BuildUI()
    return self
end

function ESP:BuildUI()
    if not self.Tab then return end

    local master = self.Tab:Section({ Title = "ESP Master", Icon = "eye", Opened = true })

    master:Toggle({ Title = "Enable ESP", Value = false,
        Callback = function(s) ESP.Settings.Enabled = s; if s then self:Start() else self:Stop() end end
    })

    master:Toggle({ Title = "Rainbow Mode", Value = false,
        Callback = function(s) ESP.Settings.Rainbow = s end
    })

    master:Slider({ Title = "Rainbow Speed", Min = 1, Max = 10, Step = 0.5, Value = 3,
        Suffix = "x", Callback = function(v) ESP.Settings.RainbowSpeed = v end
    })

    master:Toggle({ Title = "Team Check", Value = false,
        Callback = function(s) ESP.Settings.TeamCheck = s end
    })

    master:Toggle({ Title = "Team Color", Value = false,
        Callback = function(s) ESP.Settings.TeamColor = s end
    })

    master:Toggle({ Title = "Show Dead", Value = false,
        Callback = function(s) ESP.Settings.ShowDead = s end
    })

    master:Slider({ Title = "Max Distance", Min = 100, Max = 10000, Step = 100, Value = 2500,
        Suffix = " studs", Callback = function(v) ESP.Settings.MaxDistance = v end
    })

    -- Boxes
    local boxes = self.Tab:Section({ Title = "Boxes", Icon = "square", Opened = true })
    boxes:Toggle({ Title = "Enable Boxes", Value = true, Callback = function(s) ESP.Settings.Box_Enabled = s end })
    boxes:Dropdown({ Title = "Box Type", Values = {"2D", "Corner", "Both"}, Value = "2D", Callback = function(v) ESP.Settings.Box_Type = v end })
    boxes:ColorPicker({ Title = "Box Color", Default = ESP.Settings.Box_Color, Callback = function(c) ESP.Settings.Box_Color = c end })
    boxes:Slider({ Title = "Box Thickness", Min = 1, Max = 6, Step = 0.5, Value = 1.5, Suffix = "px", Callback = function(v) ESP.Settings.Box_Thickness = v end })
    boxes:Toggle({ Title = "Filled Box", Value = false, Callback = function(s) ESP.Settings.Box_Filled = s end })
    boxes:ColorPicker({ Title = "Fill Color", Default = ESP.Settings.Box_FillColor, Callback = function(c) ESP.Settings.Box_FillColor = c end })
    boxes:Slider({ Title = "Fill Transparency", Min = 0, Max = 1, Step = 0.05, Value = 0.7, Callback = function(v) ESP.Settings.Box_FillTransparency = v end })
    boxes:Toggle({ Title = "Box Outline", Value = true, Callback = function(s) ESP.Settings.Box_Outline = s end })
    boxes:ColorPicker({ Title = "Outline Color", Default = ESP.Settings.Box_OutlineColor, Callback = function(c) ESP.Settings.Box_OutlineColor = c end })
    boxes:ColorPicker({ Title = "Corner Color", Default = ESP.Settings.Corner_Color, Callback = function(c) ESP.Settings.Corner_Color = c end })
    boxes:Slider({ Title = "Corner Length", Min = 5, Max = 50, Step = 1, Value = 15, Suffix = "px", Callback = function(v) ESP.Settings.Corner_Length = v end })
    boxes:Slider({ Title = "Corner Thickness", Min = 1, Max = 5, Step = 0.5, Value = 2, Suffix = "px", Callback = function(v) ESP.Settings.Corner_Thickness = v end })

    -- Names
    local names = self.Tab:Section({ Title = "Names", Icon = "type", Opened = true })
    names:Toggle({ Title = "Enable Names", Value = true, Callback = function(s) ESP.Settings.Name_Enabled = s end })
    names:ColorPicker({ Title = "Name Color", Default = ESP.Settings.Name_Color, Callback = function(c) ESP.Settings.Name_Color = c end })
    names:Slider({ Title = "Name Size", Min = 10, Max = 24, Step = 1, Value = 14, Suffix = "px", Callback = function(v) ESP.Settings.Name_Size = v end })
    names:Dropdown({ Title = "Font", Values = {"Gotham", "GothamBold", "SourceSans", "FredokaOne", "Ubuntu", "LuckiestGuy", "SciFi", "Fantasy"}, Value = "GothamBold", Callback = function(v) ESP.Settings.Name_Font = v end })

    -- Distance
    local dist = self.Tab:Section({ Title = "Distance", Icon = "ruler", Opened = true })
    dist:Toggle({ Title = "Enable Distance", Value = true, Callback = function(s) ESP.Settings.Distance_Enabled = s end })
    dist:ColorPicker({ Title = "Distance Color", Default = ESP.Settings.Distance_Color, Callback = function(c) ESP.Settings.Distance_Color = c end })
    dist:Slider({ Title = "Distance Size", Min = 10, Max = 20, Step = 1, Value = 13, Suffix = "px", Callback = function(v) ESP.Settings.Distance_Size = v end })

    -- Health
    local health = self.Tab:Section({ Title = "Health Bar", Icon = "activity", Opened = true })
    health:Toggle({ Title = "Enable Health Bar", Value = true, Callback = function(s) ESP.Settings.Health_Enabled = s end })
    health:Dropdown({ Title = "Position", Values = {"Left", "Right", "Bottom", "Top"}, Value = "Left", Callback = function(v) ESP.Settings.Health_Position = v end })
    health:Slider({ Title = "Bar Width", Min = 2, Max = 10, Step = 0.5, Value = 4, Suffix = "px", Callback = function(v) ESP.Settings.Health_BarWidth = v end })
    health:ColorPicker({ Title = "BG Color", Default = ESP.Settings.Health_BGColor, Callback = function(c) ESP.Settings.Health_BGColor = c end })
    health:Toggle({ Title = "Health Text", Value = true, Callback = function(s) ESP.Settings.HealthText_Enabled = s end })
    health:ColorPicker({ Title = "Health Text Color", Default = ESP.Settings.HealthText_Color, Callback = function(c) ESP.Settings.HealthText_Color = c end })

    -- Tracers
    local tracers = self.Tab:Section({ Title = "Tracers", Icon = "trending-up", Opened = false })
    tracers:Toggle({ Title = "Enable Tracers", Value = false, Callback = function(s) ESP.Settings.Tracer_Enabled = s end })
    tracers:ColorPicker({ Title = "Tracer Color", Default = ESP.Settings.Tracer_Color, Callback = function(c) ESP.Settings.Tracer_Color = c end })
    tracers:Slider({ Title = "Thickness", Min = 1, Max = 5, Step = 0.5, Value = 1, Suffix = "px", Callback = function(v) ESP.Settings.Tracer_Thickness = v end })
    tracers:Dropdown({ Title = "Origin", Values = {"Bottom", "Top", "Middle", "Mouse"}, Value = "Bottom", Callback = function(v) ESP.Settings.Tracer_Origin = v end })

    -- Head Dot
    local dot = self.Tab:Section({ Title = "Head Dot", Icon = "circle", Opened = false })
    dot:Toggle({ Title = "Enable Head Dot", Value = false, Callback = function(s) ESP.Settings.HeadDot_Enabled = s end })
    dot:ColorPicker({ Title = "Dot Color", Default = ESP.Settings.HeadDot_Color, Callback = function(c) ESP.Settings.HeadDot_Color = c end })
    dot:Slider({ Title = "Dot Size", Min = 4, Max = 20, Step = 1, Value = 8, Suffix = "px", Callback = function(v) ESP.Settings.HeadDot_Size = v end })

    -- Snaplines
    local snap = self.Tab:Section({ Title = "Snaplines", Icon = "minus", Opened = false })
    snap:Toggle({ Title = "Enable Snaplines", Value = false, Callback = function(s) ESP.Settings.Snapline_Enabled = s end })
    snap:ColorPicker({ Title = "Snapline Color", Default = ESP.Settings.Snapline_Color, Callback = function(c) ESP.Settings.Snapline_Color = c end })
    snap:Slider({ Title = "Thickness", Min = 1, Max = 5, Step = 0.5, Value = 1, Suffix = "px", Callback = function(v) ESP.Settings.Snapline_Thickness = v end })

    -- Arrow
    local arrow = self.Tab:Section({ Title = "Offscreen Arrow", Icon = "navigation", Opened = false })
    arrow:Toggle({ Title = "Enable Arrow", Value = false, Callback = function(s) ESP.Settings.Arrow_Enabled = s end })
    arrow:ColorPicker({ Title = "Arrow Color", Default = ESP.Settings.Arrow_Color, Callback = function(c) ESP.Settings.Arrow_Color = c end })
    arrow:Slider({ Title = "Arrow Size", Min = 10, Max = 30, Step = 1, Value = 15, Suffix = "px", Callback = function(v) ESP.Settings.Arrow_Size = v end })
    arrow:Slider({ Title = "Screen Distance", Min = 10, Max = 80, Step = 5, Value = 30, Suffix = "px", Callback = function(v) ESP.Settings.Arrow_Distance = v end })

    -- Fade
    local fade = self.Tab:Section({ Title = "Fade", Icon = "sun-dim", Opened = true })
    fade:Toggle({ Title = "Enable Fade", Value = true, Callback = function(s) ESP.Settings.Fade_Enabled = s end })
    fade:Slider({ Title = "Fade Speed", Min = 0.05, Max = 0.5, Step = 0.01, Value = 0.12, Callback = function(v) ESP.Settings.Fade_Speed = v end })
    fade:Slider({ Title = "Max Opacity", Min = 0.1, Max = 1, Step = 0.05, Value = 0.35, Callback = function(v) ESP.Settings.Fade_MaxOpacity = v end })
end

function ESP:Start()
    if self.ScreenGui then self.ScreenGui:Destroy() end
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "Hyper_ESP_v2"
    self.ScreenGui.Parent = CoreGui
    self.ScreenGui.ResetOnSpawn = false
    ESP.Elements = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then self:CreateElements(player) end
    end

    self.PlayerAddedCon = Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then task.wait(0.5); self:CreateElements(player) end
    end)

    self.PlayerRemovingCon = Players.PlayerRemoving:Connect(function(player)
        self:RemoveElements(player)
    end)

    self.Connection = RunService.RenderStepped:Connect(function()
        self:Update()
    end)

    if self.Library then self.Library:Notify({ Title = "ESP", Description = "ESP Activated", Duration = 2 }) end
end

function ESP:Stop()
    if self.Connection then self.Connection:Disconnect(); self.Connection = nil end
    if self.PlayerAddedCon then self.PlayerAddedCon:Disconnect(); self.PlayerAddedCon = nil end
    if self.PlayerRemovingCon then self.PlayerRemovingCon:Disconnect(); self.PlayerRemovingCon = nil end
    if self.ScreenGui then self.ScreenGui:Destroy(); self.ScreenGui = nil end
    for player in pairs(ESP.Elements) do self:RemoveElements(player) end
    ESP.Elements = {}
    if self.Library then self.Library:Notify({ Title = "ESP", Description = "ESP Deactivated", Duration = 2 }) end
end

function ESP:CreateElements(player)
    if ESP.Elements[player] then return end

    local container = Instance.new("Frame")
    container.Name = player.Name
    container.Size = UDim2.new(0, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Parent = self.ScreenGui

    local box = Instance.new("Frame", container); box.Name = "Box"; box.BackgroundTransparency = 1; box.BorderSizePixel = 0
    local stroke = Instance.new("UIStroke", box)
    local boxFill = Instance.new("Frame", container); boxFill.Name = "BoxFill"; boxFill.BorderSizePixel = 0; boxFill.Visible = false
    local boxOutline = Instance.new("Frame", container); boxOutline.Name = "BoxOutline"; boxOutline.BackgroundTransparency = 1; boxOutline.BorderSizePixel = 0; boxOutline.Visible = false
    local outlineStroke = Instance.new("UIStroke", boxOutline)

    local cornerTL = Instance.new("Frame", container); cornerTL.BorderSizePixel = 0; cornerTL.Visible = false
    local cornerTR = Instance.new("Frame", container); cornerTR.BorderSizePixel = 0; cornerTR.Visible = false
    local cornerBL = Instance.new("Frame", container); cornerBL.BorderSizePixel = 0; cornerBL.Visible = false
    local cornerBR = Instance.new("Frame", container); cornerBR.BorderSizePixel = 0; cornerBR.Visible = false

    local nameText = Instance.new("TextLabel", container)
    nameText.Name = "Name"; nameText.BackgroundTransparency = 1; nameText.TextStrokeTransparency = 0.5
    nameText.TextStrokeColor3 = Color3.fromRGB(0,0,0); nameText.Font = Enum.Font.GothamBold

    local distText = Instance.new("TextLabel", container)
    distText.Name = "Distance"; distText.BackgroundTransparency = 1; distText.TextStrokeTransparency = 0.5
    distText.TextStrokeColor3 = Color3.fromRGB(0,0,0); distText.Font = Enum.Font.Gotham

    local healthBg = Instance.new("Frame", container)
    healthBg.Name = "HealthBg"; healthBg.BorderSizePixel = 0; healthBg.BackgroundColor3 = Color3.fromRGB(30,30,30)

    local healthFill = Instance.new("Frame", healthBg)
    healthFill.Name = "HealthFill"; healthFill.BorderSizePixel = 0

    local healthText = Instance.new("TextLabel", container)
    healthText.Name = "HealthText"; healthText.BackgroundTransparency = 1; healthText.TextStrokeTransparency = 0.5
    healthText.TextStrokeColor3 = Color3.fromRGB(0,0,0); healthText.Font = Enum.Font.Gotham; healthText.TextSize = 11

    local tracer = Instance.new("Frame", container); tracer.Name = "Tracer"; tracer.BorderSizePixel = 0; tracer.Visible = false
    local snapline = Instance.new("Frame", container); snapline.Name = "Snapline"; snapline.BorderSizePixel = 0; snapline.Visible = false

    local headDot = Instance.new("Frame", container); headDot.Name = "HeadDot"; headDot.BorderSizePixel = 0; headDot.Visible = false
    Instance.new("UICorner", headDot).CornerRadius = UDim.new(1, 0)

    local arrow = Instance.new("Frame", container); arrow.Name = "Arrow"; arrow.BorderSizePixel = 0; arrow.Visible = false
    local arrowText = Instance.new("TextLabel", arrow)
    arrowText.Name = "ArrowText"; arrowText.BackgroundTransparency = 1; arrowText.Text = "▼"; arrowText.TextSize = 14
    arrowText.Font = Enum.Font.GothamBold; arrowText.AnchorPoint = Vector2.new(0.5,0.5)
    arrowText.TextXAlignment = Enum.TextXAlignment.Center; arrowText.TextYAlignment = Enum.TextYAlignment.Center
    arrowText.Size = UDim2.new(1,0,1,0)

    ESP.Elements[player] = {
        Container = container, Alpha = 0,
        Box = box, BoxStroke = stroke, BoxFill = boxFill, BoxOutline = boxOutline, OutlineStroke = outlineStroke,
        CornerTL = cornerTL, CornerTR = cornerTR, CornerBL = cornerBL, CornerBR = cornerBR,
        NameText = nameText, DistText = distText, HealthBg = healthBg, HealthFill = healthFill, HealthText = healthText,
        Tracer = tracer, Snapline = snapline, HeadDot = headDot, Arrow = arrow, ArrowText = arrowText,
    }
end

function ESP:RemoveElements(player)
    if ESP.Elements[player] then
        pcall(function() ESP.Elements[player].Container:Destroy() end)
        ESP.Elements[player] = nil
    end
end

local function SetLine(frame, x1, y1, x2, y2, thickness, color, transparency)
    local dx, dy = x2 - x1, y2 - y1
    local len = math.sqrt(dx*dx + dy*dy)
    frame.Size = UDim2.new(0, len, 0, thickness or 1)
    frame.Position = UDim2.new(0, x1, 0, y1)
    frame.Rotation = math.deg(math.atan2(dy, dx))
    frame.BackgroundColor3 = color or Color3.fromRGB(255,255,255)
    frame.BackgroundTransparency = transparency or 0
    frame.Visible = true
end

function ESP:Update()
    local myTeam = LocalPlayer.Team
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local camPos = Camera.CFrame.Position
    local vs = Camera.ViewportSize

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then self:RemoveElements(player) continue end
        if ESP.Settings.TeamCheck and player.Team == myTeam then self:RemoveElements(player) continue end

        local char = player.Character
        if not char then self:RemoveElements(player) continue end

        local root = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChild("Humanoid")
        local head = char:FindFirstChild("Head")

        if not root or not humanoid or not head then self:RemoveElements(player) continue end
        if not ESP.Settings.ShowDead and humanoid.Health <= 0 then self:RemoveElements(player) continue end

        local distance = myRoot and (root.Position - myRoot.Position).Magnitude or (root.Position - camPos).Magnitude
        if distance > ESP.Settings.MaxDistance then self:RemoveElements(player) continue end

        if not ESP.Elements[player] then self:CreateElements(player) end
        local el = ESP.Elements[player]
        if not el then continue end

        local headPos, headOn = Camera:WorldToViewportPoint(head.Position + V3New(0, 0.6, 0))
        local legPos, legOn = Camera:WorldToViewportPoint(root.Position - V3New(0, 3.2, 0))

        local bh = math.abs(headPos.Y - legPos.Y)
        local bw = bh * 0.62
        local bx = headPos.X - bw / 2
        local by = headPos.Y

        local onScreen = headOn or legOn
        local color = GetColor(player, ESP.Settings.Box_Color)

        local targetAlpha = ESP.Settings.Fade_Enabled and math.clamp(1 - (distance / ESP.Settings.MaxDistance), 0, ESP.Settings.Fade_MaxOpacity) or 1
        local alpha = el.Alpha
        if onScreen then alpha = math.min(alpha + ESP.Settings.Fade_Speed, targetAlpha)
        else alpha = math.max(alpha - ESP.Settings.Fade_Speed, 0) end
        el.Alpha = alpha
        local vis = alpha > 0.01 and onScreen

        -- Box 2D
        if ESP.Settings.Box_Enabled and vis and (ESP.Settings.Box_Type == "2D" or ESP.Settings.Box_Type == "Both") then
            el.Box.Visible = true
            el.Box.Size = UDim2.new(0, bw, 0, bh)
            el.Box.Position = UDim2.new(0, bx, 0, by)
            el.BoxStroke.Color = color
            el.BoxStroke.Thickness = ESP.Settings.Box_Thickness
            el.BoxStroke.Transparency = 1 - alpha

            if ESP.Settings.Box_Filled then
                el.BoxFill.Visible = true
                el.BoxFill.Size = UDim2.new(0, bw, 0, bh)
                el.BoxFill.Position = UDim2.new(0, bx, 0, by)
                el.BoxFill.BackgroundColor3 = ESP.Settings.Box_FillColor
                el.BoxFill.BackgroundTransparency = 1 - (alpha * (1 - ESP.Settings.Box_FillTransparency))
            else el.BoxFill.Visible = false end

            if ESP.Settings.Box_Outline then
                el.BoxOutline.Visible = true
                el.BoxOutline.Size = UDim2.new(0, bw + 2, 0, bh + 2)
                el.BoxOutline.Position = UDim2.new(0, bx - 1, 0, by - 1)
                el.OutlineStroke.Color = ESP.Settings.Box_OutlineColor
                el.OutlineStroke.Thickness = ESP.Settings.Box_Thickness + 2
                el.OutlineStroke.Transparency = 1 - alpha
            else el.BoxOutline.Visible = false end
        else
            el.Box.Visible = false; el.BoxFill.Visible = false; el.BoxOutline.Visible = false
        end

        -- Corner
        if ESP.Settings.Box_Enabled and vis and (ESP.Settings.Box_Type == "Corner" or ESP.Settings.Box_Type == "Both") then
            local cl, ct = ESP.Settings.Corner_Length, ESP.Settings.Corner_Thickness
            el.CornerTL.Visible = true; el.CornerTL.Size = UDim2.new(0, cl, 0, ct); el.CornerTL.Position = UDim2.new(0, bx, 0, by); el.CornerTL.BackgroundColor3 = ESP.Settings.Corner_Color; el.CornerTL.BackgroundTransparency = 1 - alpha
            el.CornerTR.Visible = true; el.CornerTR.Size = UDim2.new(0, ct, 0, cl); el.CornerTR.Position = UDim2.new(0, bx + bw - ct, 0, by); el.CornerTR.BackgroundColor3 = ESP.Settings.Corner_Color; el.CornerTR.BackgroundTransparency = 1 - alpha
            el.CornerBL.Visible = true; el.CornerBL.Size = UDim2.new(0, ct, 0, cl); el.CornerBL.Position = UDim2.new(0, bx, 0, by + bh - cl); el.CornerBL.BackgroundColor3 = ESP.Settings.Corner_Color; el.CornerBL.BackgroundTransparency = 1 - alpha
            el.CornerBR.Visible = true; el.CornerBR.Size = UDim2.new(0, cl, 0, ct); el.CornerBR.Position = UDim2.new(0, bx + bw - cl, 0, by + bh - ct); el.CornerBR.BackgroundColor3 = ESP.Settings.Corner_Color; el.CornerBR.BackgroundTransparency = 1 - alpha
        else
            el.CornerTL.Visible = false; el.CornerTR.Visible = false; el.CornerBL.Visible = false; el.CornerBR.Visible = false
        end

        -- Name
        if ESP.Settings.Name_Enabled and vis then
            el.NameText.Visible = true
            el.NameText.Text = player.Name
            el.NameText.TextColor3 = ESP.Settings.Name_Color
            el.NameText.TextSize = ESP.Settings.Name_Size
            el.NameText.Font = FontMap[ESP.Settings.Name_Font] or Enum.Font.GothamBold
            el.NameText.Size = UDim2.new(0, 300, 0, 22)
            el.NameText.Position = UDim2.new(0, bx + bw/2 - 150, 0, by - 24)
            el.NameText.TextTransparency = 1 - alpha
        else el.NameText.Visible = false end

        -- Distance
        if ESP.Settings.Distance_Enabled and vis then
            el.DistText.Visible = true
            el.DistText.Text = "[" .. math.floor(distance) .. "m]"
            el.DistText.TextColor3 = ESP.Settings.Distance_Color
            el.DistText.TextSize = ESP.Settings.Distance_Size
            el.DistText.Size = UDim2.new(0, 200, 0, 18)
            el.DistText.Position = UDim2.new(0, bx + bw/2 - 100, 0, by + bh + 2)
            el.DistText.TextTransparency = 1 - alpha
        else el.DistText.Visible = false end

        -- Health
        if ESP.Settings.Health_Enabled and vis and humanoid then
            local pct = humanoid.Health / humanoid.MaxHealth
            local hc = pct > 0.7 and Color3.fromRGB(50,200,50) or pct > 0.4 and Color3.fromRGB(255,170,0) or pct > 0.15 and Color3.fromRGB(255,100,0) or Color3.fromRGB(255,30,30)
            local bw2 = ESP.Settings.Health_BarWidth

            el.HealthBg.Visible = true
            if ESP.Settings.Health_Position == "Left" then
                el.HealthBg.Size = UDim2.new(0, bw2, 0, bh); el.HealthBg.Position = UDim2.new(0, bx - bw2 - 2, 0, by)
            elseif ESP.Settings.Health_Position == "Right" then
                el.HealthBg.Size = UDim2.new(0, bw2, 0, bh); el.HealthBg.Position = UDim2.new(0, bx + bw + 2, 0, by)
            elseif ESP.Settings.Health_Position == "Bottom" then
                el.HealthBg.Size = UDim2.new(0, bw, 0, bw2); el.HealthBg.Position = UDim2.new(0, bx, 0, by + bh + 2)
            else
                el.HealthBg.Size = UDim2.new(0, bw, 0, bw2); el.HealthBg.Position = UDim2.new(0, bx, 0, by - bw2 - 2)
            end

            if ESP.Settings.Health_Position == "Left" or ESP.Settings.Health_Position == "Right" then
                el.HealthFill.Size = UDim2.new(1, 0, pct, 0)
            else
                el.HealthFill.Size = UDim2.new(pct, 0, 1, 0)
            end
            el.HealthFill.BackgroundColor3 = hc
            el.HealthBg.BackgroundTransparency = 1 - alpha
            el.HealthFill.BackgroundTransparency = 1 - alpha

            if ESP.Settings.HealthText_Enabled then
                el.HealthText.Visible = true
                el.HealthText.Text = math.floor(humanoid.Health)
                el.HealthText.TextColor3 = ESP.Settings.HealthText_Color
                el.HealthText.TextTransparency = 1 - alpha
                if ESP.Settings.Health_Position == "Left" then
                    el.HealthText.Size = UDim2.new(0, 30, 0, 14); el.HealthText.Position = UDim2.new(0, bx - bw2 - 20, 0, by + bh - 14)
                elseif ESP.Settings.Health_Position == "Right" then
                    el.HealthText.Size = UDim2.new(0, 30, 0, 14); el.HealthText.Position = UDim2.new(0, bx + bw + bw2 + 4, 0, by + bh - 14)
                else
                    el.HealthText.Size = UDim2.new(0, 30, 0, 14); el.HealthText.Position = UDim2.new(0, bx + bw + 2, 0, by + bh - 10)
                end
            else el.HealthText.Visible = false end
        else
            el.HealthBg.Visible = false; el.HealthText.Visible = false
        end

        -- Tracer
        if ESP.Settings.Tracer_Enabled and vis then
            local ox, oy
            local mousePos = UserInputService:GetMouseLocation()
            if ESP.Settings.Tracer_Origin == "Bottom" then ox, oy = vs.X/2, vs.Y
            elseif ESP.Settings.Tracer_Origin == "Top" then ox, oy = vs.X/2, 0
            elseif ESP.Settings.Tracer_Origin == "Middle" then ox, oy = vs.X/2, vs.Y/2
            else ox, oy = mousePos.X, mousePos.Y end
            SetLine(el.Tracer, ox, oy, bx + bw/2, by + bh, ESP.Settings.Tracer_Thickness, ESP.Settings.Tracer_Color, 1 - alpha * (1 - ESP.Settings.Tracer_Transparency))
        else el.Tracer.Visible = false end

        -- Snapline
        if ESP.Settings.Snapline_Enabled and vis then
            SetLine(el.Snapline, vs.X/2, vs.Y, bx + bw/2, by + bh, ESP.Settings.Snapline_Thickness, ESP.Settings.Snapline_Color, 1 -
