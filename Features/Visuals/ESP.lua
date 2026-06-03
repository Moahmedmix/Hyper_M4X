--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                    HYPER UI - ESP v2.0                       ║
    ║               By M4X | EVA | AMAL                           ║
    ║                                                              ║
    ║  Features:                                                   ║
    ║  - Dynamic Hitbox (GetExtentsSize)                           ║
    ║  - Distance-based smooth fade                                ║
    ║  - Boxes: 2D / Corner / Filled / Outline                     ║
    ║  - Health Bar: Left / Right / Bottom / Top                   ║
    ║  - Tracers: Bottom / Top / Middle / Mouse                    ║
    ║  - Head Dot with size control                                ║
    ║  - Name, Distance, Health display                            ║
    ║  - Skeleton overlay                                          ║
    ║  - Snaplines                                                 ║
    ║  - Visibility Check                                          ║
    ║  - Team Check / Team Color                                   ║
    ║  - Full color control per element                            ║
    ║  - Custom fonts & sizes                                      ║
    ║  - Offscreen arrow indicator                                 ║
    ║  - Rainbow mode                                              ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

local ESP = {}
ESP.__index = ESP

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Constants
local V2New = Vector2.new
local V3New = Vector3.new
local WTVP = Camera.WorldToViewportPoint
local Mouse = LocalPlayer:GetMouse()

-- =============================================
-- SETTINGS
-- =============================================
ESP.Settings = {
    -- Master
    Enabled = false,
    Rainbow = false,
    RainbowSpeed = 3,

    -- Boxes
    Box_Enabled = true,
    Box_Type = "2D", -- 2D / Corner / Both
    Box_Color = Color3.fromRGB(255, 255, 255),
    Box_Thickness = 1.5,
    Box_Filled = false,
    Box_FillColor = Color3.fromRGB(255, 255, 255),
    Box_FillTransparency = 0.7,
    Box_Outline = true,
    Box_OutlineColor = Color3.fromRGB(0, 0, 0),

    -- Corner Box
    Corner_Color = Color3.fromRGB(0, 255, 255),
    Corner_Thickness = 2,
    Corner_Length = 15,

    -- Names
    Name_Enabled = true,
    Name_Color = Color3.fromRGB(255, 255, 255),
    Name_Size = 14,
    Name_Font = "GothamBold",
    Name_Outline = true,
    Name_OutlineColor = Color3.fromRGB(0, 0, 0),

    -- Distance
    Distance_Enabled = true,
    Distance_Color = Color3.fromRGB(200, 200, 200),
    Distance_Size = 13,
    Distance_Outline = true,

    -- Health Bar
    Health_Enabled = true,
    Health_Position = "Left", -- Left / Right / Bottom / Top
    Health_BarWidth = 4,
    Health_BarHeight = 0,
    Health_BGColor = Color3.fromRGB(30, 30, 30),

    -- Health Text
    HealthText_Enabled = true,
    HealthText_Color = Color3.fromRGB(255, 255, 255),

    -- Tracers
    Tracer_Enabled = false,
    Tracer_Color = Color3.fromRGB(255, 255, 255),
    Tracer_Thickness = 1,
    Tracer_Origin = "Bottom", -- Bottom / Top / Middle / Mouse
    Tracer_Transparency = 0.3,

    -- Head Dot
    HeadDot_Enabled = false,
    HeadDot_Color = Color3.fromRGB(255, 0, 0),
    HeadDot_Size = 8,
    HeadDot_Filled = true,

    -- Snaplines
    Snapline_Enabled = false,
    Snapline_Color = Color3.fromRGB(255, 255, 255),
    Snapline_Thickness = 1,

    -- Offscreen Arrow
    Arrow_Enabled = false,
    Arrow_Color = Color3.fromRGB(255, 0, 0),
    Arrow_Size = 15,
    Arrow_Distance = 30,

    -- Fade
    Fade_Enabled = true,
    Fade_Speed = 0.12,
    Fade_MaxOpacity = 0.35,
    Fade_MinOpacity = 0,

    -- Filters
    TeamCheck = false,
    TeamColor = false,
    MaxDistance = 2500,
    VisCheck = false,
    ShowLocalTeam = false,
    ShowDead = false,
    UpdateRate = 1,
}

-- =============================================
-- ELEMENTS STORAGE
-- =============================================
ESP.Elements = {}
ESP.ScreenGui = nil
ESP.Connection = nil
ESP.PlayerAddedCon = nil
ESP.PlayerRemovingCon = nil
ESP.RainbowHue = 0

-- =============================================
-- FONT MAP
-- =============================================
local FontMap = {
    Gotham = Enum.Font.Gotham,
    GothamBold = Enum.Font.GothamBold,
    SourceSans = Enum.Font.SourceSans,
    FredokaOne = Enum.Font.FredokaOne,
    Ubuntu = Enum.Font.Ubuntu,
    LuckiestGuy = Enum.Font.LuckiestGuy,
    SciFi = Enum.Font.SciFi,
    Fantasy = Enum.Font.Fantasy,
    Arcade = Enum.Font.Arcade,
}

-- =============================================
-- RAINBOW COLOR
-- =============================================
local function GetRainbowColor(speed)
    local hue = (tick() * (speed or 1) * 60) % 360 / 360
    return Color3.fromHSV(hue, 1, 1)
end

-- =============================================
-- VISIBILITY CHECK
-- =============================================
local IgnoreList = {}
local LastRayUpdate = 0
local RayIgnoreList = {}

local function CheckVisibility(Character, Distance, Position, Unit)
    if Distance > 999 then return false end
    if not Character then return false end

    local Model = Character
    if tick() - LastRayUpdate > 3 then
        LastRayUpdate = tick()
        table.clear(RayIgnoreList)
        if LocalPlayer.Character then
            table.insert(RayIgnoreList, LocalPlayer.Character)
        end
        table.insert(RayIgnoreList, Camera)
        if Mouse.TargetFilter then
            table.insert(RayIgnoreList, Mouse.TargetFilter)
        end
        if #IgnoreList > 64 then
            while #IgnoreList > 64 do
                table.remove(IgnoreList, 1)
            end
        end
        for _, v in ipairs(IgnoreList) do
            table.insert(RayIgnoreList, v)
        end
    end

    local Ray = Ray.new(Position, Unit * Distance)
    local Hit = workspace:FindPartOnRayWithIgnoreList(Ray, RayIgnoreList)

    if Hit and not Hit:IsDescendantOf(Model) then
        if Hit.Transparency >= 0.3 or (not Hit.CanCollide and Hit.ClassName ~= "Terrain") then
            table.insert(IgnoreList, Hit)
        end
        return false
    end

    return true
end

-- =============================================
-- GET COLOR
-- =============================================
local function GetColor(player, baseColor)
    if ESP.Settings.Rainbow then
        return GetRainbowColor(ESP.Settings.RainbowSpeed)
    end
    if ESP.Settings.TeamColor and player.Team then
        return player.Team.TeamColor.Color
    end
    return baseColor
end

-- =============================================
-- CREATE FRAME
-- =============================================
local function CreateFrame(parent, name, size, pos, bgColor, bgTrans, visible)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = size or UDim2.new(0, 0, 0, 0)
    frame.Position = pos or UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = bgColor or Color3.fromRGB(255, 255, 255)
    frame.BackgroundTransparency = bgTrans or 1
    frame.BorderSizePixel = 0
    frame.Visible = visible or true
    frame.Parent = parent
    return frame
end

-- =============================================
-- CREATE TEXT
-- =============================================
local function CreateText(parent, name, text, size, color, font)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Text = text or ""
    label.TextSize = size or 14
    label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    label.Font = font or Enum.Font.Gotham
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.Parent = parent
    return label
end

-- =============================================
-- INIT
-- =============================================
function ESP:Init(tab, library, flags)
    local self = setmetatable({}, ESP)
    self.Tab = tab
    self.Library = library
    self.Flags = flags
    
    self:BuildUI()
    return self
end

-- =============================================
-- BUILD UI
-- =============================================
function ESP:BuildUI()
    if not self.Tab then return end

    -- ═══════════════ MASTER ═══════════════
    local master = self.Tab:Section({ Title = "ESP - Master", Icon = "eye", Opened = true })

    master:Toggle({ Title = "Enable ESP", Description = "Master on/off switch", Value = false,
        Callback = function(s) ESP.Settings.Enabled = s; if s then self:Start() else self:Stop() end end
    })

    master:Toggle({ Title = "Rainbow Mode", Description = "Cycling rainbow colors", Value = false,
        Callback = function(s) ESP.Settings.Rainbow = s end
    })

    master:Slider({ Title = "Rainbow Speed", Description = "Color cycle speed", Min = 1, Max = 10, Step = 0.5, Value = 3,
        Suffix = "x", Callback = function(v) ESP.Settings.RainbowSpeed = v end
    })

    master:Slider({ Title = "Update Rate", Description = "ESP refresh rate", Min = 1, Max = 60, Step = 1, Value = 1,
        Suffix = " fps", Callback = function(v) ESP.Settings.UpdateRate = v end
    })

    -- ═══════════════ FILTERS ═══════════════
    local filters = self.Tab:Section({ Title = "Filters", Icon = "filter", Opened = true })

    filters:Toggle({ Title = "Team Check", Description = "Don't show teammates", Value = false,
        Callback = function(s) ESP.Settings.TeamCheck = s end
    })

    filters:Toggle({ Title = "Team Color", Description = "Use team color for ESP", Value = false,
        Callback = function(s) ESP.Settings.TeamColor = s end
    })

    filters:Toggle({ Title = "Visibility Check", Description = "Only show visible players", Value = false,
        Callback = function(s) ESP.Settings.VisCheck = s end
    })

    filters:Toggle({ Title = "Show Dead", Description = "Show dead players", Value = false,
        Callback = function(s) ESP.Settings.ShowDead = s end
    })

    filters:Slider({ Title = "Max Distance", Description = "Maximum render distance", Min = 100, Max = 10000, Step = 100, Value = 2500,
        Suffix = " studs", Callback = function(v) ESP.Settings.MaxDistance = v end
    })

    -- ═══════════════ BOXES ═══════════════
    local boxes = self.Tab:Section({ Title = "Boxes", Icon = "square", Opened = true })

    boxes:Toggle({ Title = "Enable Boxes", Value = true,
        Callback = function(s) ESP.Settings.Box_Enabled = s end
    })

    boxes:Dropdown({ Title = "Box Type", Values = {"2D", "Corner", "Both"}, Value = "2D",
        Callback = function(v) ESP.Settings.Box_Type = v end
    })

    boxes:ColorPicker({ Title = "Box Color", Default = ESP.Settings.Box_Color,
        Callback = function(c) ESP.Settings.Box_Color = c end
    })

    boxes:Slider({ Title = "Box Thickness", Min = 1, Max = 6, Step = 0.5, Value = 1.5,
        Suffix = "px", Callback = function(v) ESP.Settings.Box_Thickness = v end
    })

    boxes:Toggle({ Title = "Filled Box", Description = "Fill the box interior", Value = false,
        Callback = function(s) ESP.Settings.Box_Filled = s end
    })

    boxes:ColorPicker({ Title = "Fill Color", Default = ESP.Settings.Box_FillColor,
        Callback = function(c) ESP.Settings.Box_FillColor = c end
    })

    boxes:Slider({ Title = "Fill Transparency", Min = 0, Max = 1, Step = 0.05, Value = 0.7,
        Callback = function(v) ESP.Settings.Box_FillTransparency = v end
    })

    boxes:Toggle({ Title = "Box Outline", Description = "Black outline around box", Value = true,
        Callback = function(s) ESP.Settings.Box_Outline = s end
    })

    boxes:ColorPicker({ Title = "Outline Color", Default = ESP.Settings.Box_OutlineColor,
        Callback = function(c) ESP.Settings.Box_OutlineColor = c end
    })

    -- Corner
    boxes:ColorPicker({ Title = "Corner Color", Default = ESP.Settings.Corner_Color,
        Callback = function(c) ESP.Settings.Corner_Color = c end
    })

    boxes:Slider({ Title = "Corner Length", Min = 5, Max = 50, Step = 1, Value = 15,
        Suffix = "px", Callback = function(v) ESP.Settings.Corner_Length = v end
    })

    boxes:Slider({ Title = "Corner Thickness", Min = 1, Max = 5, Step = 0.5, Value = 2,
        Suffix = "px", Callback = function(v) ESP.Settings.Corner_Thickness = v end
    })

    -- ═══════════════ NAMES ═══════════════
    local names = self.Tab:Section({ Title = "Names", Icon = "type", Opened = true })

    names:Toggle({ Title = "Enable Names", Value = true,
        Callback = function(s) ESP.Settings.Name_Enabled = s end
    })

    names:ColorPicker({ Title = "Name Color", Default = ESP.Settings.Name_Color,
        Callback = function(c) ESP.Settings.Name_Color = c end
    })

    names:Slider({ Title = "Name Size", Min = 10, Max = 24, Step = 1, Value = 14,
        Suffix = "px", Callback = function(v) ESP.Settings.Name_Size = v end
    })

    names:Dropdown({ Title = "Font", Values = {"Gotham", "GothamBold", "SourceSans", "FredokaOne", "Ubuntu", "LuckiestGuy", "SciFi", "Fantasy"}, Value = "GothamBold",
        Callback = function(v) ESP.Settings.Name_Font = v end
    })

    names:Toggle({ Title = "Text Outline", Value = true,
        Callback = function(s) ESP.Settings.Name_Outline = s end
    })

    names:ColorPicker({ Title = "Outline Color", Default = ESP.Settings.Name_OutlineColor,
        Callback = function(c) ESP.Settings.Name_OutlineColor = c end
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

    dist:Toggle({ Title = "Distance Outline", Value = true,
        Callback = function(s) ESP.Settings.Distance_Outline = s end
    })

    -- ═══════════════ HEALTH BAR ═══════════════
    local health = self.Tab:Section({ Title = "Health Bar", Icon = "activity", Opened = true })

    health:Toggle({ Title = "Enable Health Bar", Value = true,
        Callback = function(s) ESP.Settings.Health_Enabled = s end
    })

    health:Dropdown({ Title = "Position", Values = {"Left", "Right", "Bottom", "Top"}, Value = "Left",
        Callback = function(v) ESP.Settings.Health_Position = v end
    })

    health:Slider({ Title = "Bar Width", Min = 2, Max = 10, Step = 0.5, Value = 4,
        Suffix = "px", Callback = function(v) ESP.Settings.Health_BarWidth = v end
    })

    health:ColorPicker({ Title = "Background Color", Default = ESP.Settings.Health_BGColor,
        Callback = function(c) ESP.Settings.Health_BGColor = c end
    })

    health:Toggle({ Title = "Health Text", Description = "Show HP numbers", Value = true,
        Callback = function(s) ESP.Settings.HealthText_Enabled = s end
    })

    health:ColorPicker({ Title = "Health Text Color", Default = ESP.Settings.HealthText_Color,
        Callback = function(c) ESP.Settings.HealthText_Color = c end
    })

    -- ═══════════════ TRACERS ═══════════════
    local tracers = self.Tab:Section({ Title = "Tracers", Icon = "trending-up", Opened = false })

    tracers:Toggle({ Title = "Enable Tracers", Value = false,
        Callback = function(s) ESP.Settings.Tracer_Enabled = s end
    })

    tracers:ColorPicker({ Title = "Tracer Color", Default = ESP.Settings.Tracer_Color,
        Callback = function(c) ESP.Settings.Tracer_Color = c end
    })

    tracers:Slider({ Title = "Thickness", Min = 1, Max = 5, Step = 0.5, Value = 1,
        Suffix = "px", Callback = function(v) ESP.Settings.Tracer_Thickness = v end
    })

    tracers:Dropdown({ Title = "Origin", Values = {"Bottom", "Top", "Middle", "Mouse"}, Value = "Bottom",
        Callback = function(v) ESP.Settings.Tracer_Origin = v end
    })

    tracers:Slider({ Title = "Transparency", Min = 0, Max = 1, Step = 0.05, Value = 0.3,
        Callback = function(v) ESP.Settings.Tracer_Transparency = v end
    })

    -- ═══════════════ HEAD DOT ═══════════════
    local dot = self.Tab:Section({ Title = "Head Dot", Icon = "circle", Opened = false })

    dot:Toggle({ Title = "Enable Head Dot", Value = false,
        Callback = function(s) ESP.Settings.HeadDot_Enabled = s end
    })

    dot:ColorPicker({ Title = "Dot Color", Default = ESP.Settings.HeadDot_Color,
        Callback = function(c) ESP.Settings.HeadDot_Color = c end
    })

    dot:Slider({ Title = "Dot Size", Min = 4, Max = 20, Step = 1, Value = 8,
        Suffix = "px", Callback = function(v) ESP.Settings.HeadDot_Size = v end
    })

    -- ═══════════════ SNAPLINES ═══════════════
    local snap = self.Tab:Section({ Title = "Snaplines", Icon = "minus", Opened = false })

    snap:Toggle({ Title = "Enable Snaplines", Value = false,
        Callback = function(s) ESP.Settings.Snapline_Enabled = s end
    })

    snap:ColorPicker({ Title = "Snapline Color", Default = ESP.Settings.Snapline_Color,
        Callback = function(c) ESP.Settings.Snapline_Color = c end
    })

    snap:Slider({ Title = "Thickness", Min = 1, Max = 5, Step = 0.5, Value = 1,
        Suffix = "px", Callback = function(v) ESP.Settings.Snapline_Thickness = v end
    })

    -- ═══════════════ ARROW ═══════════════
    local arrow = self.Tab:Section({ Title = "Offscreen Arrow", Icon = "navigation", Opened = false })

    arrow:Toggle({ Title = "Enable Arrow", Description = "Show arrow for offscreen players", Value = false,
        Callback = function(s) ESP.Settings.Arrow_Enabled = s end
    })

    arrow:ColorPicker({ Title = "Arrow Color", Default = ESP.Settings.Arrow_Color,
        Callback = function(c) ESP.Settings.Arrow_Color = c end
    })

    arrow:Slider({ Title = "Arrow Size", Min = 10, Max = 30, Step = 1, Value = 15,
        Suffix = "px", Callback = function(v) ESP.Settings.Arrow_Size = v end
    })

    arrow:Slider({ Title = "Screen Distance", Min = 10, Max = 80, Step = 5, Value = 30,
        Suffix = "px", Callback = function(v) ESP.Settings.Arrow_Distance = v end
    })

    -- ═══════════════ FADE ═══════════════
    local fade = self.Tab:Section({ Title = "Fade Settings", Icon = "sun-dim", Opened = true })

    fade:Toggle({ Title = "Enable Fade", Description = "Fade with distance", Value = true,
        Callback = function(s) ESP.Settings.Fade_Enabled = s end
    })

    fade:Slider({ Title = "Fade Speed", Min = 0.05, Max = 0.5, Step = 0.01, Value = 0.12,
        Callback = function(v) ESP.Settings.Fade_Speed = v end
    })

    fade:Slider({ Title = "Max Opacity", Min = 0.1, Max = 1, Step = 0.05, Value = 0.35,
        Callback = function(v) ESP.Settings.Fade_MaxOpacity = v end
    })
end

-- =============================================
-- START
-- =============================================
function ESP:Start()
    if self.ScreenGui then self.ScreenGui:Destroy() end
    
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "Hyper_ESP_v2"
    self.ScreenGui.Parent = CoreGui
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.DisplayOrder = 999
    
    ESP.Elements = {}
    
    -- Track existing players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            self:CreateElements(player)
        end
    end
    
    -- Player added
    self.PlayerAddedCon = Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            task.wait(0.5)
            self:CreateElements(player)
        end
    end)
    
    -- Player removed
    self.PlayerRemovingCon = Players.PlayerRemoving:Connect(function(player)
        self:RemoveElements(player)
    end)
    
    -- Update loop
    local lastUpdate = 0
    self.Connection = RunService.RenderStepped:Connect(function(deltaTime)
        local updateInterval = 1 / math.max(ESP.Settings.UpdateRate, 1)
        lastUpdate = lastUpdate + deltaTime
        if lastUpdate >= updateInterval then
            lastUpdate = 0
            self:Update()
        end
    end)
    
    if self.Library then
        self.Library:Notify({ Title = "ESP", Description = "ESP v2.0 Activated!", Duration = 3 })
    end
end

-- =============================================
-- STOP
-- =============================================
function ESP:Stop()
    if self.Connection then self.Connection:Disconnect(); self.Connection = nil end
    if self.PlayerAddedCon then self.PlayerAddedCon:Disconnect(); self.PlayerAddedCon = nil end
    if self.PlayerRemovingCon then self.PlayerRemovingCon:Disconnect(); self.PlayerRemovingCon = nil end
    if self.ScreenGui then self.ScreenGui:Destroy(); self.ScreenGui = nil end
    
    for player, _ in pairs(ESP.Elements) do
        self:RemoveElements(player)
    end
    ESP.Elements = {}
    
    if self.Library then
        self.Library:Notify({ Title = "ESP", Description = "ESP Deactivated", Duration = 3 })
    end
end

-- =============================================
-- CREATE ELEMENTS FOR PLAYER
-- =============================================
function ESP:CreateElements(player)
    if ESP.Elements[player] then return end
    
    local container = CreateFrame(self.ScreenGui, player.Name, UDim2.new(0, 0, 0, 0), UDim2.new(0, 0, 0, 0), nil, 1)
    
    local elements = {
        Container = container,
        Alpha = 0,
        
        -- Boxes
        Box = nil,
        BoxStroke = nil,
        BoxFill = nil,
        BoxOutline = nil,
        
        -- Corners
        CornerTL = nil,
        CornerTR = nil,
        CornerBL = nil,
        CornerBR = nil,
        
        -- Text
        NameText = nil,
        DistanceText = nil,
        HealthText = nil,
        
        -- Health Bar
        HealthBg = nil,
        HealthFill = nil,
        
        -- Tracer
        Tracer = nil,
        
        -- Head Dot
        HeadDot = nil,
        
        -- Snapline
        Snapline = nil,
        
        -- Arrow
        Arrow = nil,
        ArrowText = nil,
    }
    
    -- Create all possible elements
    elements.Box = CreateFrame(container, "Box")
    elements.BoxStroke = Instance.new("UIStroke")
    elements.BoxStroke.Parent = elements.Box
    elements.BoxFill = CreateFrame(container, "BoxFill")
    elements.BoxOutline = CreateFrame(container, "BoxOutline")
    
    elements.CornerTL = CreateFrame(container, "CornerTL")
    elements.CornerTR = CreateFrame(container, "CornerTR")
    elements.CornerBL = CreateFrame(container, "CornerBL")
    elements.CornerBR = CreateFrame(container, "CornerBR")
    
    elements.NameText = CreateText(container, "Name", "", ESP.Settings.Name_Size, ESP.Settings.Name_Color, FontMap[ESP.Settings.Name_Font] or Enum.Font.GothamBold)
    elements.DistanceText = CreateText(container, "Distance", "", ESP.Settings.Distance_Size, ESP.Settings.Distance_Color, Enum.Font.Gotham)
    elements.HealthText = CreateText(container, "HealthText", "", 12, ESP.Settings.HealthText_Color, Enum.Font.Gotham)
    
    elements.HealthBg = CreateFrame(container, "HealthBg", nil, nil, ESP.Settings.Health_BGColor, 0)
    elements.HealthFill = CreateFrame(elements.HealthBg, "HealthFill", nil, nil, Color3.fromRGB(50, 200, 50), 0)
    
    elements.Tracer = CreateFrame(container, "Tracer")
    elements.Snapline = CreateFrame(container, "Snapline")
    
    elements.HeadDot = CreateFrame(container, "HeadDot")
    Instance.new("UICorner", elements.HeadDot).CornerRadius = UDim.new(1, 0)
    
    elements.Arrow = CreateFrame(container, "Arrow")
    elements.ArrowText = CreateText(elements.Arrow, "ArrowText", "▼", 14, Color3.fromRGB(255, 0, 0), Enum.Font.GothamBold)
    elements.ArrowText.AnchorPoint = Vector2.new(0.5, 0.5)
    elements.ArrowText.TextXAlignment = Enum.TextXAlignment.Center
    elements.ArrowText.TextYAlignment = Enum.TextYAlignment.Center
    
    -- Hide by default
    for _, v in pairs(elements) do
        if v and v:IsA("GuiObject") and v ~= container then
            v.Visible = false
        end
    end
    
    ESP.Elements[player] = elements
end

-- =============================================
-- REMOVE ELEMENTS
-- =============================================
function ESP:RemoveElements(player)
    if ESP.Elements[player] then
        pcall(function() ESP.Elements[player].Container:Destroy() end)
        ESP.Elements[player] = nil
    end
end

-- =============================================
-- GET TRACER ORIGIN
-- =============================================
function ESP:GetTracerOrigin()
    local vs = Camera.ViewportSize
    local mousePos = UserInputService:GetMouseLocation()
    
    if ESP.Settings.Tracer_Origin == "Bottom" then
        return vs.X / 2, vs.Y
    elseif ESP.Settings.Tracer_Origin == "Top" then
        return vs.X / 2, 0
    elseif ESP.Settings.Tracer_Origin == "Middle" then
        return vs.X / 2, vs.Y / 2
    elseif ESP.Settings.Tracer_Origin == "Mouse" then
        return mousePos.X, mousePos.Y
    end
    return vs.X / 2, vs.Y
end

-- =============================================
-- GET HEALTH COLOR
-- =============================================
function ESP:GetHealthColor(percent)
    if percent > 0.7 then
        return Color3.fromRGB(50, 200, 50)
    elseif percent > 0.4 then
        return Color3.fromRGB(255, 170, 0)
    elseif percent > 0.15 then
        return Color3.fromRGB(255, 100, 0)
    else
        return Color3.fromRGB(255, 30, 30)
    end
end

-- =============================================
-- DRAW LINE FRAME
-- =============================================
local function SetLine(frame, x1, y1, x2, y2, thickness, color, transparency)
    local dx = x2 - x1
    local dy = y2 - y1
    local len = math.sqrt(dx * dx + dy * dy)
    local angle = math.atan2(dy, dx)
    
    frame.Size = UDim2.new(0, len, 0, thickness or 1)
    frame.Position = UDim2.new(0, x1, 0, y1)
    frame.Rotation = math.deg(angle)
    frame.BackgroundColor3 = color or Color3.fromRGB(255, 255, 255)
    frame.BackgroundTransparency = transparency or 0
    frame.Visible = true
end

-- =============================================
-- UPDATE
-- =============================================
function ESP:Update()
    local myTeam = LocalPlayer.Team
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local camPos = Camera.CFrame.Position
    local vs = Camera.ViewportSize
    
    for _, player in ipairs(Players:GetPlayers()) do
        -- Skip checks
        if player == LocalPlayer then self:RemoveElements(player) continue end
        if ESP.Settings.TeamCheck and player.Team == myTeam then self:RemoveElements(player) continue end
        
        local char = player.Character
        if not char then self:RemoveElements(player) continue end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChild("Humanoid")
        local head = char:FindFirstChild("Head")
        
        if not root or not humanoid or not head then self:RemoveElements(player) continue end
        
        -- Dead check
        if not ESP.Settings.ShowDead and humanoid.Health <= 0 then self:RemoveElements(player) continue end
        
        local distance = myRoot and (root.Position - myRoot.Position).Magnitude or (root.Position - camPos).Magnitude
        
        -- Visibility check
        if ESP.Settings.VisCheck then
            local headPos = head.Position
            local dir = (headPos - camPos).unit
            local vis = CheckVisibility(char, distance, camPos, dir)
            if not vis then self:RemoveElements(player) continue end
        end
        
        -- Create elements if needed
        if not ESP.Elements[player] then self:CreateElements(player) end
        local el = ESP.Elements[player]
        if not el then continue end
        
        -- Get screen positions
        local headPos, headOn = Camera:WorldToViewportPoint(head.Position + V3New(0, 0.6, 0))
        local legPos, legOn = Camera:WorldToViewportPoint(root.Position - V3New(0, 3.2, 0))
        
        local h = math.abs(headPos.Y - legPos.Y)
        local w = h * 0.62
        local x = headPos.X - w / 2
        local y = headPos.Y
        
        local onScreen = headOn or legOn
        local inRange = distance <= ESP.Settings.MaxDistance
        
        -- Color
        local color = GetColor(player, ESP.Settings.Box_Color)
        
        -- Alpha / Fade
        local targetAlpha = 1
        if ESP.Settings.Fade_Enabled then
            targetAlpha = math.clamp(1 - (distance / ESP.Settings.MaxDistance), ESP.Settings.Fade_MinOpacity, ESP.Settings.Fade_MaxOpacity)
        end
        
        local alpha = el.Alpha
        if onScreen and inRange then
            alpha = math.min(alpha + ESP.Settings.Fade_Speed, targetAlpha)
        else
            alpha = math.max(alpha - ESP.Settings.Fade_Speed, 0)
        end
        el.Alpha = alpha
        
        local vis = alpha > 0.01 and onScreen and inRange
        
        -- ═══════════════ BOX ═══════════════
        if ESP.Settings.Box_Enabled and vis then
            if ESP.Settings.Box_Type ==
