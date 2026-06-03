--[[
    ╔══════════════════════════════════════════════════╗
    ║           HYPER UI - ESP System                  ║
    ║              Version: v1.0.0                      ║
    ║         By M4X | EVA | AMAL                      ║
    ╚══════════════════════════════════════════════════╝
    
    Complete ESP with full color control:
    - Boxes (2D / Corner)
    - Names
    - Distance
    - Health Bar
    - Tracers (Top / Bottom / Middle)
    - Head Dot
    - Skeleton
    - Snaplines
    - Team Check
    - Team Color
    - Max Distance
--]]

local ESP = {}
ESP.__index = ESP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")

ESP.Settings = {
    Enabled = false,

    -- Boxes
    Boxes_Enabled = true,
    Boxes_Color = Color3.fromRGB(255, 255, 255),
    Boxes_Thickness = 1.5,
    Boxes_Type = "2D",

    -- Corner Boxes
    Corner_Enabled = false,
    Corner_Color = Color3.fromRGB(0, 255, 255),
    Corner_Thickness = 2,
    Corner_Length = 15,

    -- Names
    Names_Enabled = true,
    Names_Color = Color3.fromRGB(255, 255, 255),
    Names_Size = 14,
    Names_Font = "GothamBold",

    -- Distance
    Distance_Enabled = true,
    Distance_Color = Color3.fromRGB(200, 200, 200),
    Distance_Size = 13,

    -- Health Bar
    Health_Enabled = true,
    Health_Position = "Left",

    -- Tracers
    Tracers_Enabled = false,
    Tracers_Color = Color3.fromRGB(255, 255, 255),
    Tracers_Thickness = 1,
    Tracers_Origin = "Bottom",

    -- Head Dot
    HeadDot_Enabled = false,
    HeadDot_Color = Color3.fromRGB(255, 0, 0),
    HeadDot_Size = 10,

    -- Skeleton
    Skeleton_Enabled = false,
    Skeleton_Color = Color3.fromRGB(255, 255, 255),
    Skeleton_Thickness = 1,

    -- Snaplines
    Snaplines_Enabled = false,
    Snaplines_Color = Color3.fromRGB(255, 255, 255),
    Snaplines_Thickness = 1,

    -- Filters
    TeamCheck = false,
    TeamColor = false,
    MaxDistance = 1000,
    ShowLocalTeam = false,
}

ESP.Elements = {}

function ESP:Init(tab, library, flags)
    local self = setmetatable({}, ESP)
    self.Tab = tab
    self.Library = library
    self.Flags = flags
    self.ScreenGui = nil
    self.Connection = nil

    self:BuildUI()
    return self
end

function ESP:BuildUI()
    if not self.Tab then return end

    -- ═══════════════ MAIN ═══════════════
    local main = self.Tab:Section({ Title = "ESP - Main", Icon = "eye", Opened = true })

    main:Toggle({ Title = "Enable ESP", Description = "Master switch", Value = false,
        Callback = function(s) ESP.Settings.Enabled = s; if s then self:Start() else self:Stop() end end
    })

    main:Slider({ Title = "Max Distance", Description = "Render distance limit", Min = 100, Max = 10000, Step = 100, Value = 1000,
        Suffix = " studs", Callback = function(v) ESP.Settings.MaxDistance = v end
    })

    main:Toggle({ Title = "Team Check", Description = "Don't show teammates", Value = false,
        Callback = function(s) ESP.Settings.TeamCheck = s end
    })

    main:Toggle({ Title = "Team Color", Description = "Use team color for ESP", Value = false,
        Callback = function(s) ESP.Settings.TeamColor = s end
    })

    -- ═══════════════ BOXES ═══════════════
    local boxes = self.Tab:Section({ Title = "Boxes", Icon = "square", Opened = true })

    boxes:Toggle({ Title = "Enable Boxes", Value = true,
        Callback = function(s) ESP.Settings.Boxes_Enabled = s end
    })

    boxes:Dropdown({ Title = "Box Type", Values = {"2D", "Corner", "Both"}, Value = "2D",
        Callback = function(v) ESP.Settings.Boxes_Type = v end
    })

    boxes:ColorPicker({ Title = "Box Color", Default = ESP.Settings.Boxes_Color,
        Callback = function(c) ESP.Settings.Boxes_Color = c end
    })

    boxes:Slider({ Title = "Box Thickness", Min = 1, Max = 6, Step = 0.5, Value = 1.5,
        Suffix = "px", Callback = function(v) ESP.Settings.Boxes_Thickness = v end
    })

    -- Corner specific
    boxes:ColorPicker({ Title = "Corner Color", Default = ESP.Settings.Corner_Color,
        Callback = function(c) ESP.Settings.Corner_Color = c end
    })

    boxes:Slider({ Title = "Corner Length", Min = 5, Max = 40, Step = 1, Value = 15,
        Suffix = "px", Callback = function(v) ESP.Settings.Corner_Length = v end
    })

    boxes:Slider({ Title = "Corner Thickness", Min = 1, Max = 5, Step = 0.5, Value = 2,
        Suffix = "px", Callback = function(v) ESP.Settings.Corner_Thickness = v end
    })

    -- ═══════════════ NAMES ═══════════════
    local names = self.Tab:Section({ Title = "Names", Icon = "type", Opened = true })

    names:Toggle({ Title = "Enable Names", Value = true,
        Callback = function(s) ESP.Settings.Names_Enabled = s end
    })

    names:ColorPicker({ Title = "Name Color", Default = ESP.Settings.Names_Color,
        Callback = function(c) ESP.Settings.Names_Color = c end
    })

    names:Slider({ Title = "Name Size", Min = 10, Max = 24, Step = 1, Value = 14,
        Suffix = "px", Callback = function(v) ESP.Settings.Names_Size = v end
    })

    names:Dropdown({ Title = "Name Font", Values = {"Gotham", "GothamBold", "SourceSans", "FredokaOne", "Ubuntu"}, Value = "GothamBold",
        Callback = function(v) ESP.Settings.Names_Font = v end
    })

    -- ═══════════════ DISTANCE ═══════════════
    local dist = self.Tab:Section({ Title = "Distance", Icon = "ruler", Opened = true })

    dist:Toggle({ Title = "Enable Distance", Value = true,
        Callback = function(s) ESP.Settings.Distance_Enabled = s end
    })

    dist:ColorPicker({ Title = "Distance Color", Default = ESP.Settings.Distance_Color,
        Callback = function(c) ESP.Settings.Distance_Color = c end
    })

    dist:Slider({ Title = "Distance Size", Min = 10, Max = 20, Step = 1, Value = 13,
        Suffix = "px", Callback = function(v) ESP.Settings.Distance_Size = v end
    })

    -- ═══════════════ HEALTH ═══════════════
    local health = self.Tab:Section({ Title = "Health Bar", Icon = "activity", Opened = true })

    health:Toggle({ Title = "Enable Health Bar", Value = true,
        Callback = function(s) ESP.Settings.Health_Enabled = s end
    })

    health:Dropdown({ Title = "Position", Values = {"Left", "Right", "Bottom"}, Value = "Left",
        Callback = function(v) ESP.Settings.Health_Position = v end
    })

    -- ═══════════════ TRACERS ═══════════════
    local tracers = self.Tab:Section({ Title = "Tracers", Icon = "trending-up", Opened = false })

    tracers:Toggle({ Title = "Enable Tracers", Value = false,
        Callback = function(s) ESP.Settings.Tracers_Enabled = s end
    })

    tracers:ColorPicker({ Title = "Tracer Color", Default = ESP.Settings.Tracers_Color,
        Callback = function(c) ESP.Settings.Tracers_Color = c end
    })

    tracers:Slider({ Title = "Tracer Thickness", Min = 1, Max = 5, Step = 0.5, Value = 1,
        Suffix = "px", Callback = function(v) ESP.Settings.Tracers_Thickness = v end
    })

    tracers:Dropdown({ Title = "Tracer Origin", Values = {"Bottom", "Top", "Middle"}, Value = "Bottom",
        Callback = function(v) ESP.Settings.Tracers_Origin = v end
    })

    -- ═══════════════ HEAD DOT ═══════════════
    local dot = self.Tab:Section({ Title = "Head Dot", Icon = "circle", Opened = false })

    dot:Toggle({ Title = "Enable Head Dot", Value = false,
        Callback = function(s) ESP.Settings.HeadDot_Enabled = s end
    })

    dot:ColorPicker({ Title = "Dot Color", Default = ESP.Settings.HeadDot_Color,
        Callback = function(c) ESP.Settings.HeadDot_Color = c end
    })

    dot:Slider({ Title = "Dot Size", Min = 4, Max = 20, Step = 1, Value = 10,
        Suffix = "px", Callback = function(v) ESP.Settings.HeadDot_Size = v end
    })

    -- ═══════════════ SKELETON ═══════════════
    local skel = self.Tab:Section({ Title = "Skeleton", Icon = "bone", Opened = false })

    skel:Toggle({ Title = "Enable Skeleton", Value = false,
        Callback = function(s) ESP.Settings.Skeleton_Enabled = s end
    })

    skel:ColorPicker({ Title = "Skeleton Color", Default = ESP.Settings.Skeleton_Color,
        Callback = function(c) ESP.Settings.Skeleton_Color = c end
    })

    skel:Slider({ Title = "Skeleton Thickness", Min = 1, Max = 5, Step = 0.5, Value = 1,
        Suffix = "px", Callback = function(v) ESP.Settings.Skeleton_Thickness = v end
    })

    -- ═══════════════ SNAPLINES ═══════════════
    local snap = self.Tab:Section({ Title = "Snaplines", Icon = "minus", Opened = false })

    snap:Toggle({ Title = "Enable Snaplines", Value = false,
        Callback = function(s) ESP.Settings.Snaplines_Enabled = s end
    })

    snap:ColorPicker({ Title = "Snapline Color", Default = ESP.Settings.Snaplines_Color,
        Callback = function(c) ESP.Settings.Snaplines_Color = c end
    })

    snap:Slider({ Title = "Snapline Thickness", Min = 1, Max = 5, Step = 0.5, Value = 1,
        Suffix = "px", Callback = function(v) ESP.Settings.Snaplines_Thickness = v end
    })
end

function ESP:Start()
    if self.ScreenGui then self.ScreenGui:Destroy() end
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "Hyper_ESP"
    self.ScreenGui.Parent = CoreGui
    self.ScreenGui.ResetOnSpawn = false
    ESP.Elements = {}

    self.Connection = RunService.RenderStepped:Connect(function() self:Update() end)

    if self.Library then
        self.Library:Notify({ Title = "ESP", Description = "ESP Activated", Duration = 2 })
    end
end

function ESP:Stop()
    if self.Connection then self.Connection:Disconnect(); self.Connection = nil end
    if self.ScreenGui then self.ScreenGui:Destroy(); self.ScreenGui = nil end
    for player in pairs(ESP.Elements) do
        self:ClearElements(player)
    end
    ESP.Elements = {}

    if self.Library then
        self.Library:Notify({ Title = "ESP", Description = "ESP Deactivated", Duration = 2 })
    end
end

function ESP:GetColor(player)
    if ESP.Settings.TeamColor and player.Team then
        return player.Team.TeamColor.Color
    end
    return ESP.Settings.Boxes_Color
end

function ESP:Update()
    local myTeam = LocalPlayer.Team

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then self:ClearElements(player) continue end
        if ESP.Settings.TeamCheck and player.Team == myTeam then self:ClearElements(player) continue end

        local char = player.Character
        if not char then self:ClearElements(player) continue end

        local head = char:FindFirstChild("Head")
        local root = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChild("Humanoid")
        if not head or not root then self:ClearElements(player) continue end

        local dist = (Camera.CFrame.Position - root.Position).Magnitude
        if dist > ESP.Settings.MaxDistance then self:ClearElements(player) continue end

        local headPos, headOn = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.6, 0))
        local legPos, legOn = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.2, 0))

        if not headOn and not legOn then self:ClearElements(player) continue end

        local h = math.abs(headPos.Y - legPos.Y)
        local w = h * 0.6
        local x = headPos.X - w / 2
        local y = headPos.Y

        local color = self:GetColor(player)

        if not ESP.Elements[player] then ESP.Elements[player] = {} end
        local el = ESP.Elements[player]

        -- Boxes
        if ESP.Settings.Boxes_Enabled then
            if ESP.Settings.Boxes_Type == "2D" or ESP.Settings.Boxes_Type == "Both" then
                if not el.Box then
                    el.Box = Instance.new("Frame")
                    el.Box.BackgroundTransparency = 1
                    el.Box.BorderSizePixel = 0
                    el.Box.Parent = self.ScreenGui
                    Instance.new("UIStroke", el.Box)
                end
                el.Box.Size = UDim2.new(0, w, 0, h)
                el.Box.Position = UDim2.new(0, x, 0, y)
                el.Box.UIStroke.Color = color
                el.Box.UIStroke.Thickness = ESP.Settings.Boxes_Thickness
            elseif el.Box then el.Box:Destroy(); el.Box = nil end

            if ESP.Settings.Boxes_Type == "Corner" or ESP.Settings.Boxes_Type == "Both" then
                if not el.CornerTL then
                    el.CornerTL = Instance.new("Frame"); el.CornerTL.BorderSizePixel = 0; el.CornerTL.Parent = self.ScreenGui
                    el.CornerTR = Instance.new("Frame"); el.CornerTR.BorderSizePixel = 0; el.CornerTR.Parent = self.ScreenGui
                    el.CornerBL = Instance.new("Frame"); el.CornerBL.BorderSizePixel = 0; el.CornerBL.Parent = self.ScreenGui
                    el.CornerBR = Instance.new("Frame"); el.CornerBR.BorderSizePixel = 0; el.CornerBR.Parent = self.ScreenGui
                end
                local cl = ESP.Settings.Corner_Length
                local ct = ESP.Settings.Corner_Thickness
                el.CornerTL.Size = UDim2.new(0, cl, 0, ct); el.CornerTL.Position = UDim2.new(0, x, 0, y); el.CornerTL.BackgroundColor3 = ESP.Settings.Corner_Color
                el.CornerTR.Size = UDim2.new(0, ct, 0, cl); el.CornerTR.Position = UDim2.new(0, x + w - ct, 0, y); el.CornerTR.BackgroundColor3 = ESP.Settings.Corner_Color
                el.CornerBL.Size = UDim2.new(0, ct, 0, cl); el.CornerBL.Position = UDim2.new(0, x, 0, y + h - cl); el.CornerBL.BackgroundColor3 = ESP.Settings.Corner_Color
                el.CornerBR.Size = UDim2.new(0, cl, 0, ct); el.CornerBR.Position = UDim2.new(0, x + w - cl, 0, y + h - ct); el.CornerBR.BackgroundColor3 = ESP.Settings.Corner_Color
            else
                if el.CornerTL then el.CornerTL:Destroy(); el.CornerTL = nil end
                if el.CornerTR then el.CornerTR:Destroy(); el.CornerTR = nil end
                if el.CornerBL then el.CornerBL:Destroy(); el.CornerBL = nil end
                if el.CornerBR then el.CornerBR:Destroy(); el.CornerBR = nil end
            end
        else
            if el.Box then el.Box:Destroy(); el.Box = nil end
            if el.CornerTL then el.CornerTL:Destroy(); el.CornerTL = nil end
        end

        -- Names
        if ESP.Settings.Names_Enabled then
            if not el.Name then
                el.Name = Instance.new("TextLabel")
                el.Name.BackgroundTransparency = 1
                el.Name.TextStrokeTransparency = 0.6
                el.Name.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                el.Name.Parent = self.ScreenGui
            end
            el.Name.Text = player.DisplayName ~= player.Name and player.DisplayName .. " (@" .. player.Name .. ")" or player.Name
            el.Name.TextColor3 = ESP.Settings.Names_Color
            el.Name.TextSize = ESP.Settings.Names_Size
            el.Name.Font = Enum.Font[ESP.Settings.Names_Font]
            el.Name.Size = UDim2.new(0, 300, 0, 22)
            el.Name.Position = UDim2.new(0, x + w / 2 - 150, 0, y - 24)
        elseif el.Name then el.Name:Destroy(); el.Name = nil end

        -- Distance
        if ESP.Settings.Distance_Enabled then
            if not el.Dist then
                el.Dist = Instance.new("TextLabel")
                el.Dist.BackgroundTransparency = 1
                el.Dist.TextStrokeTransparency = 0.6
                el.Dist.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                el.Dist.Parent = self.ScreenGui
            end
            el.Dist.Text = "[" .. math.floor(dist) .. "m]"
            el.Dist.TextColor3 = ESP.Settings.Distance_Color
            el.Dist.TextSize = ESP.Settings.Distance_Size
            el.Dist.Font = Enum.Font.Gotham
            el.Dist.Size = UDim2.new(0, 200, 0, 18)
            el.Dist.Position = UDim2.new(0, x + w / 2 - 100, 0, y + h + 2)
        elseif el.Dist then el.Dist:Destroy(); el.Dist = nil end

        -- Health
        if ESP.Settings.Health_Enabled and humanoid then
            local pct = humanoid.Health / humanoid.MaxHealth
            local hc = pct > 0.5 and Color3.fromRGB(50, 200, 50) or pct > 0.25 and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(255, 50, 50)

            if ESP.Settings.Health_Position == "Left" then
                if not el.HealthBg then
                    el.HealthBg = Instance.new("Frame"); el.HealthBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30); el.HealthBg.BorderSizePixel = 0; el.HealthBg.Parent = self.ScreenGui
                    el.HealthFill = Instance.new("Frame"); el.HealthFill.BorderSizePixel = 0; el.HealthFill.Parent = el.HealthBg
                end
                el.HealthBg.Size = UDim2.new(0, 4, 0, h); el.HealthBg.Position = UDim2.new(0, x - 6, 0, y)
                el.HealthFill.Size = UDim2.new(1, 0, pct, 0); el.HealthFill.BackgroundColor3 = hc
            elseif ESP.Settings.Health_Position == "Right" then
                if not el.HealthBg then
                    el.HealthBg = Instance.new("Frame"); el.HealthBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30); el.HealthBg.BorderSizePixel = 0; el.HealthBg.Parent = self.ScreenGui
                    el.HealthFill = Instance.new("Frame"); el.HealthFill.BorderSizePixel = 0; el.HealthFill.Parent = el.HealthBg
                end
                el.HealthBg.Size = UDim2.new(0, 4, 0, h); el.HealthBg.Position = UDim2.new(0, x + w + 2, 0, y)
                el.HealthFill.Size = UDim2.new(1, 0, pct, 0); el.HealthFill.BackgroundColor3 = hc
            else
                if not el.HealthBg then
                    el.HealthBg = Instance.new("Frame"); el.HealthBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30); el.HealthBg.BorderSizePixel = 0; el.HealthBg.Parent = self.ScreenGui
                    el.HealthFill = Instance.new("Frame"); el.HealthFill.BorderSizePixel = 0; el.HealthFill.Parent = el.HealthBg
                end
                el.HealthBg.Size = UDim2.new(0, w, 0, 3); el.HealthBg.Position = UDim2.new(0, x, 0, y + h + 2)
                el.HealthFill.Size = UDim2.new(pct, 0, 1, 0); el.HealthFill.BackgroundColor3 = hc
            end
        elseif el.HealthBg then el.HealthBg:Destroy(); el.HealthBg = nil end

        -- Tracers
        if ESP.Settings.Tracers_Enabled then
            if not el.Tracer then
                el.Tracer = Instance.new("Frame"); el.Tracer.BorderSizePixel = 0; el.Tracer.Parent = self.ScreenGui
            end
            local sx, sy
            if ESP.Settings.Tracers_Origin == "Bottom" then sx, sy = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y
            elseif ESP.Settings.Tracers_Origin == "Top" then sx, sy = Camera.ViewportSize.X / 2, 0
            else sx, sy = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2 end

            local ex, ey = x + w / 2, y + h
            local dx, dy = ex - sx, ey - sy
            local len = math.sqrt(dx * dx + dy * dy)
            local ang = math.atan2(dy, dx)
            el.Tracer.Size = UDim2.new(0, len, 0, ESP.Settings.Tracers_Thickness)
            el.Tracer.Position = UDim2.new(0, sx, 0, sy)
            el.Tracer.Rotation = math.deg(ang)
            el.Tracer.BackgroundColor3 = ESP.Settings.Tracers_Color
        elseif el.Tracer then el.Tracer:Destroy(); el.Tracer = nil end

        -- Head Dot
        if ESP.Settings.HeadDot_Enabled then
            if not el.HeadDot then
                el.HeadDot = Instance.new("Frame"); el.HeadDot.BorderSizePixel = 0; el.HeadDot.Parent = self.ScreenGui
                Instance.new("UICorner", el.HeadDot).CornerRadius = UDim.new(1, 0)
            end
            local ds = ESP.Settings.HeadDot_Size
            el.HeadDot.Size = UDim2.new(0, ds, 0, ds)
            el.HeadDot.Position = UDim2.new(0, headPos.X - ds / 2, 0, headPos.Y - ds / 2)
            el.HeadDot.BackgroundColor3 = ESP.Settings.HeadDot_Color
        elseif el.HeadDot then el.HeadDot:Destroy(); el.HeadDot = nil end

        -- Snaplines
        if ESP.Settings.Snaplines_Enabled then
            if not el.Snapline then
                el.Snapline = Instance.new("Frame"); el.Snapline.BorderSizePixel = 0; el.Snapline.Parent = self.ScreenGui
            end
            local sx, sy = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y
            local ex, ey = x + w / 2, y + h
            local dx, dy = ex - sx, ey - sy
            local len = math.sqrt(dx * dx + dy * dy)
            local ang = math.atan2(dy, dx)
            el.Snapline.Size = UDim2.new(0, len, 0, ESP.Settings.Snaplines_Thickness)
            el.Snapline.Position = UDim2.new(0, sx, 0, sy)
            el.Snapline.Rotation = math.deg(ang)
            el.Snapline.BackgroundColor3 = ESP.Settings.Snaplines_Color
        elseif el.Snapline then el.Snapline:Destroy(); el.Snapline = nil end
    end

    for player in pairs(ESP.Elements) do
        if not player.Parent then self:ClearElements(player) end
    end
end

function ESP:ClearElements(player)
    if ESP.Elements[player] then
        for _, v in pairs(ESP.Elements[player]) do
            pcall(function() v:Destroy() end)
        end
        ESP.Elements[player] = nil
    end
end

return ESP
