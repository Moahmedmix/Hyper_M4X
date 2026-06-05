--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║           HYPER UI - ESP SYSTEM - ULTRA PRO v4               ║
    ║    Premium: 10 Styles + Full Customization + 3D Box + Chams  ║
    ║              By M4X | EVA | AMAL                            ║
    ╚══════════════════════════════════════════════════════════════╝

    Features:
    - 10 Box Styles: Corner, Full, 3D, Circle, Diamond, Crosshair, Triangle, Hexagon, Arrow, Dynamic
    - Full customization: colors, thickness, transparency, fill, glow
    - Chams (Highlight) with fill/outline
    - Off-screen arrows with distance
    - Dynamic scaling based on distance
    - Animated effects: pulse, rainbow, gradient
    - Team check, vis check, wall check
    - Health bar: left/right/top/bottom + gradient colors
    - Armor bar, stamina bar
    - Name: custom font, size, color, outline, shadow
    - Distance: brackets, units, color by distance
    - Weapon: icon, name, ammo
    - Tracers: 5 origins, bezier curves, animated
    - Snaplines: dynamic color by distance
    - Skeleton: full body, color by bone, thickness
    - Info panel: stats, ping, FPS, KDR
    - Head dot: circle, cross, dot
    - Look direction: arrow from head
    - Velocity vector: movement prediction line
    - Rank/Level display
    - Status: AFK, reloading, crouching, jumping
    - Kill feed overlay
    - Minimap radar
    - Target priority: closest, lowest HP, weakest, highest rank
    - FOV circle for ESP targeting
    - Sound ESP (visual indicators for gunshots)
    - Loot ESP (items, weapons, ammo)
    - Vehicle ESP
    - Objective ESP
    - All settings save/load
    - FULL UI with ALL buttons, toggles, sliders, colorpickers, dropdowns
--]]

local ESP = {}
ESP.__index = ESP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- =============================================
-- SETTINGS
-- =============================================
ESP.Settings = {
    -- Main
    Enabled = false,
    MaxDist = 3000,
    TeamCheck = false,
    TeamColor = false,
    Rainbow = false,
    RainbowSpeed = 0.003,
    VisCheck = false,
    WallCheck = true,
    DynamicScale = true,
    MinScale = 0.3,
    MaxScale = 1.5,
    
    -- Box Styles
    BoxStyle = "Corner", -- Corner, Full, 3D, Circle, Diamond, Crosshair, Triangle, Hexagon, Arrow, Dynamic
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxThickness = 2,
    BoxTransparency = 1,
    BoxFill = false,
    BoxFillColor = Color3.fromRGB(255, 255, 255),
    BoxFillTransparency = 0.8,
    BoxGlow = false,
    BoxGlowColor = Color3.fromRGB(255, 255, 255),
    BoxGlowThickness = 4,
    BoxAnimated = false,
    BoxAnimationSpeed = 2,
    
    -- 3D Box
    Box3DThickness = 1,
    Box3DColor = Color3.fromRGB(255, 255, 255),
    Box3DFill = false,
    Box3DFillColor = Color3.fromRGB(100, 100, 100),
    Box3DFillTransparency = 0.9,
    
    -- Chams
    Chams = false,
    ChamsFillColor = Color3.fromRGB(255, 0, 0),
    ChamsFillTransparency = 0.5,
    ChamsOutlineColor = Color3.fromRGB(255, 255, 255),
    ChamsOutlineTransparency = 0,
    
    -- Corner Box
    CornerLen = 22,
    CornerStyle = "Sharp", -- Sharp, Rounded, Gap
    CornerGap = 4,
    
    -- Circle Box
    CircleSegments = 32,
    CircleRadius = 1.0,
    
    -- Diamond Box
    DiamondSize = 1.0,
    
    -- Crosshair Box
    CrosshairSize = 15,
    CrosshairGap = 5,
    
    -- Triangle Box
    TriangleSize = 1.0,
    
    -- Hexagon Box
    HexagonSize = 1.0,
    
    -- Arrow Box
    ArrowSize = 1.0,
    ArrowHeadSize = 8,
    
    -- Dynamic Box
    DynamicStyle = "Pulse", -- Pulse, Breathe, Wave
    
    -- Name
    Name = true,
    NameColor = Color3.fromRGB(255, 255, 255),
    NameSize = 13,
    NameFont = 2, -- 0=Legacy, 1=SourceSans, 2=SourceSansBold, 3=Roboto, 4=RobotoMono
    NameOutline = true,
    NameOutlineColor = Color3.fromRGB(0, 0, 0),
    NameShadow = false,
    NameShadowColor = Color3.fromRGB(0, 0, 0),
    NameShadowOffset = Vector2.new(1, 1),
    NameBold = false,
    NameItalic = false,
    NameUppercase = false,
    NameGlow = false,
    NameGlowColor = Color3.fromRGB(255, 255, 255),
    NameGlowRadius = 5,
    
    -- Distance
    Dist = true,
    DistColor = Color3.fromRGB(180, 180, 180),
    DistSize = 12,
    DistFont = 2,
    DistOutline = true,
    DistBrackets = true,
    DistUnits = "m", -- m, ft, studs
    DistColorByRange = false,
    DistCloseColor = Color3.fromRGB(255, 50, 50),
    DistMidColor = Color3.fromRGB(255, 255, 50),
    DistFarColor = Color3.fromRGB(50, 255, 50),
    DistCloseRange = 50,
    DistMidRange = 150,
    
    -- Health
    HP = true,
    HPPos = "Left", -- Left, Right, Top, Bottom
    HPThick = 3,
    HPHeight = 40,
    HPWidth = 4,
    HPBG = Color3.fromRGB(20, 20, 20),
    HPGradient = true,
    HPColorHigh = Color3.fromRGB(50, 200, 50),
    HPColorMid = Color3.fromRGB(255, 170, 0),
    HPColorLow = Color3.fromRGB(255, 50, 50),
    HPText = true,
    HPTextColor = Color3.fromRGB(255, 255, 255),
    HPTextSize = 10,
    HPSmooth = true,
    HPSmoothSpeed = 0.1,
    
    -- Armor
    Armor = false,
    ArmorPos = "Right",
    ArmorThick = 3,
    ArmorColor = Color3.fromRGB(0, 150, 255),
    ArmorBG = Color3.fromRGB(20, 20, 20),
    ArmorText = true,
    
    -- Stamina
    Stamina = false,
    StaminaPos = "Bottom",
    StaminaColor = Color3.fromRGB(255, 200, 0),
    StaminaBG = Color3.fromRGB(20, 20, 20),
    
    -- Tracer
    Tracer = false,
    TracerColor = Color3.fromRGB(255, 255, 255),
    TracerOrigin = "Bottom", -- Bottom, Top, Middle, Mouse, Center
    TracerThick = 1,
    TracerStyle = "Line", -- Line, Bezier, Dashed, Dotted
    TracerDashLength = 5,
    TracerGapLength = 3,
    TracerAnimated = false,
    TracerAnimationSpeed = 2,
    TracerGradient = false,
    TracerGradientStart = Color3.fromRGB(255, 0, 0),
    TracerGradientEnd = Color3.fromRGB(0, 0, 255),
    
    -- Snapline
    Snap = false,
    SnapColor = Color3.fromRGB(255, 255, 255),
    SnapThick = 1,
    SnapStyle = "Line",
    SnapAnimated = false,
    SnapColorByDist = false,
    
    -- Weapon
    Weapon = false,
    WeaponColor = Color3.fromRGB(255, 200, 50),
    WeaponSize = 11,
    WeaponIcon = false,
    WeaponAmmo = false,
    WeaponAmmoColor = Color3.fromRGB(200, 200, 200),
    
    -- Skeleton
    Skeleton = false,
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    SkeletonThick = 1,
    SkeletonColorByBone = false,
    SkeletonHeadColor = Color3.fromRGB(255, 0, 0),
    SkeletonTorsoColor = Color3.fromRGB(0, 255, 0),
    SkeletonArmColor = Color3.fromRGB(0, 0, 255),
    SkeletonLegColor = Color3.fromRGB(255, 255, 0),
    SkeletonDynamic = false,
    
    -- Head Dot
    HeadDot = false,
    HeadDotColor = Color3.fromRGB(255, 255, 255),
    HeadDotSize = 4,
    HeadDotStyle = "Circle", -- Circle, Cross, Dot, Square
    HeadDotFilled = true,
    HeadDotOutline = true,
    HeadDotOutlineColor = Color3.fromRGB(0, 0, 0),
    
    -- Look Direction
    LookDir = false,
    LookDirColor = Color3.fromRGB(255, 255, 255),
    LookDirLength = 50,
    LookDirThick = 1,
    
    -- Velocity
    Velocity = false,
    VelocityColor = Color3.fromRGB(255, 255, 0),
    VelocityThick = 1,
    VelocityLength = 30,
    
    -- Info Panel
    InfoPanel = false,
    InfoColor = Color3.fromRGB(255, 255, 255),
    InfoSize = 11,
    InfoBG = Color3.fromRGB(0, 0, 0),
    InfoBGTransparency = 0.7,
    InfoBorder = true,
    InfoBorderColor = Color3.fromRGB(255, 255, 255),
    InfoItems = {"Name", "Health", "Distance", "Weapon", "Armor", "Rank"},
    
    -- Rank/Level
    Rank = false,
    RankColor = Color3.fromRGB(255, 215, 0),
    RankSize = 10,
    
    -- Status
    Status = false,
    StatusColor = Color3.fromRGB(200, 200, 200),
    StatusSize = 10,
    StatusItems = {"AFK", "Reloading", "Crouching", "Jumping", "Sprinting"},
    
    -- Off-Screen Arrows
    OffScreen = false,
    OffScreenColor = Color3.fromRGB(255, 255, 255),
    OffScreenSize = 15,
    OffScreenDist = true,
    OffScreenDistColor = Color3.fromRGB(180, 180, 180),
    OffScreenDistSize = 10,
    
    -- FOV Circle
    FOV = false,
    FOVColor = Color3.fromRGB(255, 255, 255),
    FOVLockedColor = Color3.fromRGB(255, 0, 0),
    FOVRadius = 150,
    FOVThick = 2,
    FOVFilled = false,
    FOVFillColor = Color3.fromRGB(255, 255, 255),
    FOVFillTransparency = 0.9,
    
    -- Sound ESP
    SoundESP = false,
    SoundColor = Color3.fromRGB(255, 0, 0),
    SoundSize = 10,
    SoundDuration = 2,
    SoundMaxDist = 500,
    
    -- Loot ESP
    LootESP = false,
    LootColor = Color3.fromRGB(0, 255, 255),
    LootSize = 12,
    LootItems = {"Gun", "Ammo", "Medkit", "Armor", "Key"},
    
    -- Vehicle ESP
    VehicleESP = false,
    VehicleColor = Color3.fromRGB(255, 100, 0),
    VehicleSize = 12,
    
    -- Objective ESP
    ObjectiveESP = false,
    ObjectiveColor = Color3.fromRGB(0, 255, 0),
    ObjectiveSize = 14,
    
    -- Target Priority
    TargetPriority = "Closest", -- Closest, LowestHP, Weakest, HighestRank, FOV
    TargetFOV = 150,
    
    -- Minimap
    Minimap = false,
    MinimapSize = 150,
    MinimapPos = "TopRight", -- TopLeft, TopRight, BottomLeft, BottomRight
    MinimapRange = 500,
    MinimapColor = Color3.fromRGB(255, 255, 255),
    MinimapBG = Color3.fromRGB(0, 0, 0),
    MinimapBGTransparency = 0.5,
    
    -- Kill Feed
    KillFeed = false,
    KillFeedColor = Color3.fromRGB(255, 255, 255),
    KillFeedSize = 12,
    KillFeedDuration = 5,
    KillFeedMax = 5,
    
    -- Animation
    PulseSpeed = 2,
    BreatheSpeed = 1,
    WaveSpeed = 3,
    WaveAmplitude = 5,
    
    -- Performance
    UpdateRate = 0, -- 0 = every frame, >0 = skip frames
    MaxRender = 50, -- max players to render
    LODDist = 1000, -- distance to switch to low detail
}

ESP.Boxes = {}
ESP.Conn = nil
ESP.RainbowHue = 0
ESP.FrameCount = 0
ESP.KillFeedList = {}
ESP.SoundIndicators = {}
ESP.MinimapDrawings = {}

local RootNames = {"HumanoidRootPart","UpperTorso","Torso","LowerTorso","RootPart","Root","Chest","Body","Base","Main","Center","Core","Hip","Waist","Spine","Pelvis"}
local HeadNames = {"Head","head","HEAD","Hat","Helmet","Face","Skull","Cranium","Brain","Top"}

local SkeletonBones = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}

local BoneColors = {
    Head = Color3.fromRGB(255, 0, 0),
    UpperTorso = Color3.fromRGB(0, 255, 0),
    LowerTorso = Color3.fromRGB(0, 255, 0),
    LeftUpperArm = Color3.fromRGB(0, 0, 255),
    LeftLowerArm = Color3.fromRGB(0, 0, 255),
    LeftHand = Color3.fromRGB(0, 0, 255),
    RightUpperArm = Color3.fromRGB(0, 0, 255),
    RightLowerArm = Color3.fromRGB(0, 0, 255),
    RightHand = Color3.fromRGB(0, 0, 255),
    LeftUpperLeg = Color3.fromRGB(255, 255, 0),
    LeftLowerLeg = Color3.fromRGB(255, 255, 0),
    LeftFoot = Color3.fromRGB(255, 255, 0),
    RightUpperLeg = Color3.fromRGB(255, 255, 0),
    RightLowerLeg = Color3.fromRGB(255, 255, 0),
    RightFoot = Color3.fromRGB(255, 255, 0),
}

-- =============================================
-- UTILITY FUNCTIONS
-- =============================================
function ESP:FindRoot(c)
    for _,n in ipairs(RootNames) do 
        local p=c:FindFirstChild(n) 
        if p and p:IsA("BasePart") then return p end 
    end
    for _,p in ipairs(c:GetChildren()) do 
        if p:IsA("BasePart") and p.Name~="Head" then return p end 
    end
    return nil
end

function ESP:FindHead(c)
    for _,n in ipairs(HeadNames) do 
        local p=c:FindFirstChild(n) 
        if p and p:IsA("BasePart") then return p end 
    end
    local hi,hy=nil,-math.huge
    for _,p in ipairs(c:GetChildren()) do 
        if p:IsA("BasePart") then 
            local y=p.Position.Y 
            if y>hy then hy=y hi=p end 
        end 
    end
    return hi
end

function ESP:GetColor(p)
    if ESP.Settings.Rainbow then 
        ESP.RainbowHue=(ESP.RainbowHue+ESP.Settings.RainbowSpeed)%1 
        return Color3.fromHSV(ESP.RainbowHue,1,1) 
    end
    if ESP.Settings.TeamColor and p.Team and LocalPlayer.Team then
        if p.Team==LocalPlayer.Team then return Color3.fromRGB(50,255,50) end
        return Color3.fromRGB(255,50,50)
    end
    return ESP.Settings.BoxColor
end

function ESP:GetDistColor(dist)
    if not ESP.Settings.DistColorByRange then return ESP.Settings.DistColor end
    if dist <= ESP.Settings.DistCloseRange then
        return ESP.Settings.DistCloseColor
    elseif dist <= ESP.Settings.DistMidRange then
        return ESP.Settings.DistMidColor
    else
        return ESP.Settings.DistFarColor
    end
end

function ESP:GetHPColor(pct)
    if not ESP.Settings.HPGradient then
        if pct > 0.5 then return ESP.Settings.HPColorHigh
        elseif pct > 0.25 then return ESP.Settings.HPColorMid
        else return ESP.Settings.HPColorLow end
    end
    -- Gradient interpolation
    if pct > 0.5 then
        local t = (pct - 0.5) / 0.5
        return ESP.Settings.HPColorMid:Lerp(ESP.Settings.HPColorHigh, t)
    else
        local t = pct / 0.5
        return ESP.Settings.HPColorLow:Lerp(ESP.Settings.HPColorMid, t)
    end
end

function ESP:LerpColor(c1, c2, t)
    return Color3.new(
        c1.R + (c2.R - c1.R) * t,
        c1.G + (c2.G - c1.G) * t,
        c1.B + (c2.B - c1.B) * t
    )
end

function ESP:WorldToScreen(pos)
    local sp, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X, sp.Y), sp.Z, onScreen
end

function ESP:IsOnScreen(sp)
    local vp = Camera.ViewportSize
    return sp.Z > 0 and sp.X >= -100 and sp.X <= vp.X + 100 and sp.Y >= -100 and sp.Y <= vp.Y + 100
end

function ESP:GetScale(dist)
    if not ESP.Settings.DynamicScale then return 1 end
    local scale = math.clamp(1 - (dist / ESP.Settings.MaxDist), ESP.Settings.MinScale, ESP.Settings.MaxScale)
    return scale
end

function ESP:GetBoxDimensions(h, r, scale)
    local headPos = h.Position + Vector3.new(0, 0.5, 0)
    local rootPos = r.Position - Vector3.new(0, 3.5, 0)
    local hsp, _, honScreen = ESP:WorldToScreen(headPos)
    local rsp, _, ronScreen = ESP:WorldToScreen(rootPos)
    
    if not honScreen or not ronScreen then return nil end
    
    local bh = math.abs(hsp.Y - rsp.Y) * scale
    local bw = bh * 0.5 * scale
    local x = rsp.X - bw / 2
    local y = hsp.Y
    
    return {x = x, y = y, w = bw, h = bh, centerX = rsp.X, centerY = rsp.Y}
end

function ESP:CheckWall(player)
    if not ESP.Settings.WallCheck then return true end
    local char = player.Character
    if not char then return false end
    local part = ESP:FindHead(char) or ESP:FindRoot(char)
    if not part then return false end
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, char}
    rayParams.IgnoreWater = true
    
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude
    
    local result = workspace:Raycast(origin, direction, rayParams)
    if result then return false end
    return true
end

function ESP:CheckVisible(player)
    if not ESP.Settings.VisCheck then return true end
    local char = player.Character
    if not char then return false end
    local part = ESP:FindHead(char) or ESP:FindRoot(char)
    if not part then return false end
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.IgnoreWater = true
    
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * 500
    
    local result = workspace:Raycast(origin, direction, rayParams)
    if result then
        return result.Instance:IsDescendantOf(char)
    end
    return true
end

-- =============================================
-- CREATE PLAYER DRAWINGS
-- =============================================
function ESP:CreatePlayer(p)
    local b = {}
    
    -- Box lines (max 50 for complex shapes)
    for i = 1, 50 do
        b[i] = Drawing.new("Line")
        b[i].Visible = false
        b[i].Transparency = 1
    end
    
    -- Text elements
    b.Name = Drawing.new("Text")
    b.Name.Center = true
    b.Name.Visible = false
    
    b.Dist = Drawing.new("Text")
    b.Dist.Center = true
    b.Dist.Visible = false
    
    b.Weapon = Drawing.new("Text")
    b.Weapon.Center = true
    b.Weapon.Visible = false
    
    b.WeaponAmmo = Drawing.new("Text")
    b.WeaponAmmo.Center = true
    b.WeaponAmmo.Visible = false
    
    b.Info = Drawing.new("Text")
    b.Info.Center = false
    b.Info.Visible = false
    
    b.Rank = Drawing.new("Text")
    b.Rank.Center = true
    b.Rank.Visible = false
    
    b.Status = Drawing.new("Text")
    b.Status.Center = true
    b.Status.Visible = false
    
    b.HPText = Drawing.new("Text")
    b.HPText.Center = true
    b.HPText.Visible = false
    
    b.ArmorText = Drawing.new("Text")
    b.ArmorText.Center = true
    b.ArmorText.Visible = false
    
    -- Squares
    b.HPBg = Drawing.new("Square")
    b.HPBg.Filled = true
    b.HPBg.Visible = false
    
    b.HPFill = Drawing.new("Square")
    b.HPFill.Filled = true
    b.HPFill.Visible = false
    
    b.ArmorBg = Drawing.new("Square")
    b.ArmorBg.Filled = true
    b.ArmorBg.Visible = false
    
    b.ArmorFill = Drawing.new("Square")
    b.ArmorFill.Filled = true
    b.ArmorFill.Visible = false
    
    b.StaminaBg = Drawing.new("Square")
    b.StaminaBg.Filled = true
    b.StaminaBg.Visible = false
    
    b.StaminaFill = Drawing.new("Square")
    b.StaminaFill.Filled = true
    b.StaminaFill.Visible = false
    
    b.BoxFill = Drawing.new("Square")
    b.BoxFill.Filled = true
    b.BoxFill.Visible = false
    
    b.InfoBG = Drawing.new("Square")
    b.InfoBG.Filled = true
    b.InfoBG.Visible = false
    
    -- Circles
    b.HeadDot = Drawing.new("Circle")
    b.HeadDot.Visible = false
    
    b.FOV = Drawing.new("Circle")
    b.FOV.Visible = false
    
    -- Lines
    b.Tracer = Drawing.new("Line")
    b.Tracer.Visible = false
    
    b.Snap = Drawing.new("Line")
    b.Snap.Visible = false
    
    b.LookDir = Drawing.new("Line")
    b.LookDir.Visible = false
    
    b.Velocity = Drawing.new("Line")
    b.Velocity.Visible = false
    
    -- Off-screen arrow
    b.OffScreenArrow = Drawing.new("Triangle")
    b.OffScreenArrow.Visible = false
    
    b.OffScreenDist = Drawing.new("Text")
    b.OffScreenDist.Center = true
    b.OffScreenDist.Visible = false
    
    -- Chams (Highlight)
    b.Chams = nil -- Will be created when needed
    
    -- 3D Box corners
    b.Box3D = {}
    for i = 1, 12 do
        b.Box3D[i] = Drawing.new("Line")
        b.Box3D[i].Visible = false
    end
    
    -- Glow effect
    b.Glow = {}
    for i = 1, 4 do
        b.Glow[i] = Drawing.new("Line")
        b.Glow[i].Visible = false
        b.Glow[i].Transparency = 0.3
    end
    
    ESP.Boxes[p] = b
end

-- =============================================
-- HIDE ALL DRAWINGS
-- =============================================
function ESP:HidePlayerDrawings(p)
    local b = ESP.Boxes[p]
    if not b then return end
    
    for i = 1, 50 do
        if b[i] and b[i].Remove then b[i].Visible = false end
    end
    
    local textElements = {"Name", "Dist", "Weapon", "WeaponAmmo", "Info", "Rank", "Status", "HPText", "ArmorText", "OffScreenDist"}
    for _, name in ipairs(textElements) do
        if b[name] and b[name].Remove then b[name].Visible = false end
    end
    
    local squareElements = {"HPBg", "HPFill", "ArmorBg", "ArmorFill", "StaminaBg", "StaminaFill", "BoxFill", "InfoBG"}
    for _, name in ipairs(squareElements) do
        if b[name] and b[name].Remove then b[name].Visible = false end
    end
    
    local circleElements = {"HeadDot", "FOV"}
    for _, name in ipairs(circleElements) do
        if b[name] and b[name].Remove then b[name].Visible = false end
    end
    
    local lineElements = {"Tracer", "Snap", "LookDir", "Velocity"}
    for _, name in ipairs(lineElements) do
        if b[name] and b[name].Remove then b[name].Visible = false end
    end
    
    if b.OffScreenArrow and b.OffScreenArrow.Remove then b.OffScreenArrow.Visible = false end
    
    if b.Box3D then
        for i = 1, 12 do
            if b.Box3D[i] and b.Box3D[i].Remove then b.Box3D[i].Visible = false end
        end
    end
    
    if b.Glow then
        for i = 1, 4 do
            if b.Glow[i] and b.Glow[i].Remove then b.Glow[i].Visible = false end
        end
    end
    
    -- Hide chams
    if b.Chams then
        b.Chams:Destroy()
        b.Chams = nil
    end
end

-- =============================================
-- CLEAN PLAYER
-- =============================================
function ESP:CleanPlayer(p)
    if ESP.Boxes[p] then
        for _, v in pairs(ESP.Boxes[p]) do
            if type(v) == "table" and v.Remove then
                v.Visible = false
                v:Remove()
            end
        end
        if ESP.Boxes[p].Box3D then
            for _, v in ipairs(ESP.Boxes[p].Box3D) do
                if v.Remove then v:Remove() end
            end
        end
        if ESP.Boxes[p].Glow then
            for _, v in ipairs(ESP.Boxes[p].Glow) do
                if v.Remove then v:Remove() end
            end
        end
        if ESP.Boxes[p].Chams then
            ESP.Boxes[p].Chams:Destroy()
        end
        ESP.Boxes[p] = nil
    end
end

function ESP:CleanAll()
    for p in pairs(ESP.Boxes) do ESP:CleanPlayer(p) end
    ESP.Boxes = {}
end

-- =============================================
-- BOX STYLE DRAWERS
-- =============================================
function ESP:DrawCornerBox(b, dims, color, thick, style, gap, animated)
    local x, y, w, h = dims.x, dims.y, dims.w, dims.h
    local cl = math.clamp(w * 0.25, 8, ESP.Settings.CornerLen)
    
    if animated then
        local pulse = (math.sin(tick() * ESP.Settings.PulseSpeed) + 1) / 2
        cl = cl * (0.8 + pulse * 0.4)
    end
    
    local g = gap or 0
    
    -- Top left
    b[1].From = Vector2.new(x, y)
    b[1].To = Vector2.new(x + cl, y)
    b[1].Color = color
    b[1].Thickness = thick
    b[1].Visible = true
    
    b[2].From = Vector2.new(x, y)
    b[2].To = Vector2.new(x, y + cl)
    b[2].Color = color
    b[2].Thickness = thick
    b[2].Visible = true
    
    -- Top right
    b[3].From = Vector2.new(x + w - cl, y)
    b[3].To = Vector2.new(x + w, y)
    b[3].Color = color
    b[3].Thickness = thick
    b[3].Visible = true
    
    b[4].From = Vector2.new(x + w, y)
    b[4].To = Vector2.new(x + w, y + cl)
    b[4].Color = color
    b[4].Thickness = thick
    b[4].Visible = true
    
    -- Bottom left
    b[5].From = Vector2.new(x, y + h)
    b[5].To = Vector2.new(x + cl, y + h)
    b[5].Color = color
    b[5].Thickness = thick
    b[5].Visible = true
    
    b[6].From = Vector2.new(x, y + h - cl)
    b[6].To = Vector2.new(x, y + h)
    b[6].Color = color
    b[6].Thickness = thick
    b[6].Visible = true
    
    -- Bottom right
    b[7].From = Vector2.new(x + w - cl, y + h)
    b[7].To = Vector2.new(x + w, y + h)
    b[7].Color = color
    b[7].Thickness = thick
    b[7].Visible = true
    
    b[8].From = Vector2.new(x + w, y + h - cl)
    b[8].To = Vector2.new(x + w, y + h)
    b[8].Color = color
    b[8].Thickness = thick
    b[8].Visible = true
    
    -- Gap style extra lines
    if style == "Gap" then
        b[9].From = Vector2.new(x + cl + g, y)
        b[9].To = Vector2.new(x + w - cl - g, y)
        b[9].Color = color
        b[9].Thickness = thick
        b[9].Visible = true
        
        b[10].From = Vector2.new(x + cl + g, y + h)
        b[10].To = Vector2.new(x + w - cl - g, y + h)
        b[10].Color = color
        b[10].Thickness = thick
        b[10].Visible = true
        
        b[11].From = Vector2.new(x, y + cl + g)
        b[11].To = Vector2.new(x, y + h - cl - g)
        b[11].Color = color
        b[11].Thickness = thick
        b[11].Visible = true
        
        b[12].From = Vector2.new(x + w, y + cl + g)
        b[12].To = Vector2.new(x + w, y + h - cl - g)
        b[12].Color = color
        b[12].Thickness = thick
        b[12].Visible = true
    end
end

function ESP:DrawFullBox(b, dims, color, thick, fill, fillColor, fillTrans)
    local x, y, w, h = dims.x, dims.y, dims.w, dims.h
    
    -- Fill
    if fill then
        b.BoxFill.Size = Vector2.new(w, h)
        b.BoxFill.Position = Vector2.new(x, y)
        b.BoxFill.Color = fillColor
        b.BoxFill.Transparency = fillTrans
        b.BoxFill.Visible = true
    else
        b.BoxFill.Visible = false
    end
    
    -- Border
    b[1].From = Vector2.new(x, y)
    b[1].To = Vector2.new(x + w, y)
    b[1].Color = color
    b[1].Thickness = thick
    b[1].Visible = true
    
    b[2].From = Vector2.new(x + w, y)
    b[2].To = Vector2.new(x + w, y + h)
    b[2].Color = color
    b[2].Thickness = thick
    b[2].Visible = true
    
    b[3].From = Vector2.new(x + w, y + h)
    b[3].To = Vector2.new(x, y + h)
    b[3].Color = color
    b[3].Thickness = thick
    b[3].Visible = true
    
    b[4].From = Vector2.new(x, y + h)
    b[4].To = Vector2.new(x, y)
    b[4].Color = color
    b[4].Thickness = thick
    b[4].Visible = true
end

function ESP:Draw3DBox(b, char, color, thick, fill, fillColor, fillTrans)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local cf = hrp.CFrame
    local size = hrp.Size + Vector3.new(2, 3, 1)
    
    local corners = {
        cf * CFrame.new(size.X/2, size.Y/2, size.Z/2),
        cf * CFrame.new(-size.X/2, size.Y/2, size.Z/2),
        cf * CFrame.new(-size.X/2, -size.Y/2, size.Z/2),
        cf * CFrame.new(size.X/2, -size.Y/2, size.Z/2),
        cf * CFrame.new(size.X/2, size.Y/2, -size.Z/2),
        cf * CFrame.new(-size.X/2, size.Y/2, -size.Z/2),
        cf * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2),
        cf * CFrame.new(size.X/2, -size.Y/2, -size.Z/2),
    }
    
    local screenCorners = {}
    for i, corner in ipairs(corners) do
        local pos = corner.Position
        local sp, _, onScreen = ESP:WorldToScreen(pos)
        if not onScreen then 
            -- Hide all 3D lines
            for j = 1, 12 do
                if b.Box3D[j] then b.Box3D[j].Visible = false end
            end
            return 
        end
        screenCorners[i] = sp
    end
    
    -- Draw edges
    local edges = {
        {1,2},{2,3},{3,4},{4,1}, -- front
        {5,6},{6,7},{7,8},{8,5}, -- back
        {1,5},{2,6},{3,7},{4,8}, -- connecting
    }
    
    for i, edge in ipairs(edges) do
        if b.Box3D[i] then
            b.Box3D[i].From = screenCorners[edge[1]]
            b.Box3D[i].To = screenCorners[edge[2]]
            b.Box3D[i].Color = color
            b.Box3D[i].Thickness = thick
            b.Box3D[i].Visible = true
        end
    end
end

function ESP:DrawCircleBox(b, dims, color, thick, segments)
    local cx, cy = dims.centerX, dims.centerY
    local r = math.min(dims.w, dims.h) / 2 * ESP.Settings.CircleRadius
    
    local angleStep = 2 * math.pi / segments
    for i = 1, segments do
        local angle1 = (i - 1) * angleStep
        local angle2 = i * angleStep
        
        if b[i] then
            b[i].From = Vector2.new(cx + math.cos(angle1) * r, cy + math.sin(angle1) * r)
            b[i].To = Vector2.new(cx + math.cos(angle2) * r, cy + math.sin(angle2) * r)
            b[i].Color = color
            b[i].Thickness = thick
            b[i].Visible = true
        end
    end
end

function ESP:DrawDiamondBox(b, dims, color, thick)
    local cx, cy = dims.centerX, dims.centerY
    local size = math.min(dims.w, dims.h) / 2 * ESP.Settings.DiamondSize
    
    b[1].From = Vector2.new(cx, cy - size)
    b[1].To = Vector2.new(cx + size, cy)
    b[1].Color = color
    b[1].Thickness = thick
    b[1].Visible = true
    
    b[2].From = Vector2.new(cx + size, cy)
    b[2].To = Vector2.new(cx, cy + size)
    b[2].Color = color
    b[2].Thickness = thick
    b[2].Visible = true
    
    b[3].From = Vector2.new(cx, cy + size)
    b[3].To = Vector2.new(cx - size, cy)
    b[3].Color = color
    b[3].Thickness = thick
    b[3].Visible = true
    
    b[4].From = Vector2.new(cx - size, cy)
    b[4].To = Vector2.new(cx, cy - size)
    b[4].Color = color
    b[4].Thickness = thick
    b[4].Visible = true
end

function ESP:DrawCrosshairBox(b, dims, color, thick)
    local cx, cy = dims.centerX, dims.centerY
    local size = ESP.Settings.CrosshairSize
    local gap = ESP.Settings.CrosshairGap
    
    -- Horizontal
    b[1].From = Vector2.new(cx - size - gap, cy)
    b[1].To = Vector2.new(cx - gap, cy)
    b[1].Color = color
    b[1].Thickness = thick
    b[1].Visible = true
    
    b[2].From = Vector2.new(cx + gap, cy)
    b[2].To = Vector2.new(cx + size + gap, cy)
    b[2].Color = color
    b[2].Thickness = thick
    b[2].Visible = true
    
    -- Vertical
    b[3].From = Vector2.new(cx, cy - size - gap)
    b[3].To = Vector2.new(cx, cy - gap)
    b[3].Color = color
    b[3].Thickness = thick
    b[3].Visible = true
    
    b[4].From = Vector2.new(cx, cy + gap)
    b[4].To = Vector2.new(cx, cy + size + gap)
    b[4].Color = color
    b[4].Thickness = thick
    b[4].Visible = true
end

function ESP:DrawTriangleBox(b, dims, color, thick)
    local cx, cy = dims.centerX, dims.centerY
    local size = math.min(dims.w, dims.h) / 2 * ESP.Settings.TriangleSize
    
    b[1].From = Vector2.new(cx, cy - size)
    b[1].To = Vector2.new(cx + size, cy + size)
    b[1].Color = color
    b[1].Thickness = thick
    b[1].Visible = true
    
    b[2].From = Vector2.new(cx + size, cy + size)
    b[2].To = Vector2.new(cx - size, cy + size)
    b[2].Color = color
    b[2].Thickness = thick
    b[2].Visible = true
    
    b[3].From = Vector2.new(cx - size, cy + size)
    b[3].To = Vector2.new(cx, cy - size)
    b[3].Color = color
    b[3].Thickness = thick
    b[3].Visible = true
end

function ESP:DrawHexagonBox(b, dims, color, thick)
    local cx, cy = dims.centerX, dims.centerY
    local r = math.min(dims.w, dims.h) / 2 * ESP.Settings.HexagonSize
    
    local points = {}
    for i = 0, 5 do
        local angle = i * math.pi / 3
        table.insert(points, Vector2.new(cx + math.cos(angle) * r, cy + math.sin(angle) * r))
    end
    
    for i = 1, 6 do
        local nextI = i % 6 + 1
        b[i].From = points[i]
        b[i].To = points[nextI]
        b[i].Color = color
        b[i].Thickness = thick
        b[i].Visible = true
    end
end

function ESP:DrawArrowBox(b, dims, color, thick)
    local cx, cy = dims.centerY, dims.centerY
    local size = ESP.Settings.ArrowSize
    local headSize = ESP.Settings.ArrowHeadSize
    
    -- Arrow body
    b[1].From = Vector2.new(cx - size/2, cy)
    b[1].To = Vector2.new(cx + size/2, cy)
    b[1].Color = color
    b[1].Thickness = thick
    b[1].Visible = true
    
    -- Arrow head
    b[2].From = Vector2.new(cx, cy - headSize)
    b[2].To = Vector2.new(cx - size/2, cy)
    b[2].Color = color
    b[2].Thickness = thick
    b[2].Visible = true
    
    b[3].From = Vector2.new(cx, cy - headSize)
    b[3].To = Vector2.new(cx + size/2, cy)
    b[3].Color = color
    b[3].Thickness = thick
    b[3].Visible = true
end

function ESP:DrawDynamicBox(b, dims, color, thick)
    local style = ESP.Settings.DynamicStyle
    local t = tick()
    
    if style == "Pulse" then
        local pulse = (math.sin(t * ESP.Settings.PulseSpeed) + 1) / 2
        local newColor = color:Lerp(Color3.fromRGB(255, 255, 255), pulse * 0.5)
        ESP:DrawCornerBox(b, dims, newColor, thick, "Sharp", 0, true)
    elseif style == "Breathe" then
        local breathe = (math.sin(t * ESP.Settings.BreatheSpeed) + 1) / 2
        local scale = 0.9 + breathe * 0.2
        local newDims = {
            x = dims.x + dims.w * (1 - scale) / 2,
            y = dims.y + dims.h * (1 - scale) / 2,
            w = dims.w * scale,
            h = dims.h * scale,
            centerX = dims.centerX,
            centerY = dims.centerY
        }
        ESP:DrawCornerBox(b, newDims, color, thick, "Sharp", 0, false)
    elseif style == "Wave" then
        ESP:DrawCornerBox(b, dims, color, thick, "Sharp", 0, false)
        -- Add wave effect on top
        local wave = math.sin(t * ESP.Settings.WaveSpeed) * ESP.Settings.WaveAmplitude
        b[13].From = Vector2.new(dims.x, dims.y + wave)
        b[13].To = Vector2.new(dims.x + dims.w, dims.y + wave)
        b[13].Color = color
        b[13].Thickness = thick
        b[13].Visible = true
    end
end

function ESP:DrawGlow(b, dims, color, thick)
    if not ESP.Settings.BoxGlow then return end
    
    local x, y, w, h = dims.x, dims.y, dims.w, dims.h
    local glowThick = ESP.Settings.BoxGlowThickness
    
    b.Glow[1].From = Vector2.new(x - glowThick, y - glowThick)
    b.Glow[1].To = Vector2.new(x + w + glowThick, y - glowThick)
    b.Glow[1].Color = ESP.Settings.BoxGlowColor
    b.Glow[1].Thickness = glowThick
    b.Glow[1].Visible = true
    
    b.Glow[2].From = Vector2.new(x + w + glowThick, y - glowThick)
    b.Glow[2].To = Vector2.new(x + w + glowThick, y + h + glowThick)
    b.Glow[2].Color = ESP.Settings.BoxGlowColor
    b.Glow[2].Thickness = glowThick
    b.Glow[2].Visible = true
    
    b.Glow[3].From = Vector2.new(x + w + glowThick, y + h + glowThick)
    b.Glow[3].To = Vector2.new(x - glowThick, y + h + glowThick)
    b.Glow[3].Color = ESP.Settings.BoxGlowColor
    b.Glow[3].Thickness = glowThick
    b.Glow[3].Visible = true
    
    b.Glow[4].From = Vector2.new(x - glowThick, y + h + glowThick)
    b.Glow[4].To = Vector2.new(x - glowThick, y - glowThick)
    b.Glow[4].Color = ESP.Settings.BoxGlowColor
    b.Glow[4].Thickness = glowThick
    b.Glow[4].Visible = true
end

-- =============================================
-- CHAMS
-- =============================================
function ESP:UpdateChams(p, char, color)
    if not ESP.Settings.Chams then
        if ESP.Boxes[p] and ESP.Boxes[p].Chams then
            ESP.Boxes[p].Chams:Destroy()
            ESP.Boxes[p].Chams = nil
        end
        return
    end
    
    if not ESP.Boxes[p] then return end
    
    if not ESP.Boxes[p].Chams then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESPChams"
        highlight.Parent = char
        ESP.Boxes[p].Chams = highlight
    end
    
    local chams = ESP.Boxes[p].Chams
    chams.FillColor = ESP.Settings.ChamsFillColor
    chams.FillTransparency = ESP.Settings.ChamsFillTransparency
    chams.OutlineColor = ESP.Settings.ChamsOutlineColor
    chams.OutlineTransparency = ESP.Settings.ChamsOutlineTransparency
    chams.Enabled = true
end

-- =============================================
-- HEALTH BAR
-- =============================================
function ESP:DrawHealthBar(b, dims, hum, pos, thick, scale)
    if not hum then return end
    
    local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
    local color = ESP:GetHPColor(pct)
    local hpH = ESP.Settings.HPHeight * scale
    local hpW = ESP.Settings.HPThick
    
    if pos == "Left" then
        local hpx = dims.x - hpW - 4
        b.HPBg.Size = Vector2.new(hpW, hpH)
        b.HPBg.Position = Vector2.new(hpx, dims.y)
        b.HPBg.Color = ESP.Settings.HPBG
        b.HPBg.Visible = true
        
        b.HPFill.Size = Vector2.new(hpW, hpH * pct)
        b.HPFill.Position = Vector2.new(hpx, dims.y + hpH * (1 - pct))
        b.HPFill.Color = color
        b.HPFill.Visible = true
        
        if ESP.Settings.HPText then
            b.HPText.Text = math.floor(pct * 100) .. "%"
            b.HPText.Color = ESP.Settings.HPTextColor
            b.HPText.Size = ESP.Settings.HPTextSize
            b.HPText.Position = Vector2.new(hpx - 20, dims.y + hpH / 2)
            b.HPText.Visible = true
        end
    elseif pos == "Right" then
        local hpx = dims.x + dims.w + 4
        b.HPBg.Size = Vector2.new(hpW, hpH)
        b.HPBg.Position = Vector2.new(hpx, dims.y)
        b.HPBg.Color = ESP.Settings.HPBG
        b.HPBg.Visible = true
        
        b.HPFill.Size = Vector2.new(hpW, hpH * pct)
        b.HPFill.Position = Vector2.new(hpx, dims.y + hpH * (1 - pct))
        b.HPFill.Color = color
        b.HPFill.Visible = true
        
        if ESP.Settings.HPText then
            b.HPText.Text = math.floor(pct * 100) .. "%"
            b.HPText.Color = ESP.Settings.HPTextColor
            b.HPText.Size = ESP.Settings.HPTextSize
            b.HPText.Position = Vector2.new(hpx + hpW + 5, dims.y + hpH / 2)
            b.HPText.Visible = true
        end
    elseif pos == "Top" then
        local hpBarW = dims.w
        local hpy = dims.y - 8
        b.HPBg.Size = Vector2.new(hpBarW, 4)
        b.HPBg.Position = Vector2.new(dims.x, hpy)
        b.HPBg.Color = ESP.Settings.HPBG
        b.HPBg.Visible = true
        
        b.HPFill.Size = Vector2.new(hpBarW * pct, 4)
        b.HPFill.Position = Vector2.new(dims.x, hpy)
        b.HPFill.Color = color
        b.HPFill.Visible = true
    elseif pos == "Bottom" then
        local hpBarW = dims.w
        local hpy = dims.y + dims.h + 4
        b.HPBg.Size = Vector2.new(hpBarW, 4)
        b.HPBg.Position = Vector2.new(dims.x, hpy)
        b.HPBg.Color = ESP.Settings.HPBG
        b.HPBg.Visible = true
        
        b.HPFill.Size = Vector2.new(hpBarW * pct, 4)
        b.HPFill.Position = Vector2.new(dims.x, hpy)
        b.HPFill.Color = color
        b.HPFill.Visible = true
    end
end

-- =============================================
-- ARMOR BAR
-- =============================================
function ESP:DrawArmorBar(b, dims, char, pos, thick, scale)
    -- Check for armor value in character
    local armorVal = char:FindFirstChild("Armor") or char:FindFirstChild("Shield")
    local armor = 0
    local maxArmor = 100
    
    if armorVal then
        if armorVal:IsA("IntValue") or armorVal:IsA("NumberValue") then
            armor = armorVal.Value
            maxArmor = armorVal:FindFirstChild("Max") and armorVal.Max.Value or 100
        end
    end
    
    if armor <= 0 then
        b.ArmorBg.Visible = false
        b.ArmorFill.Visible = false
        b.ArmorText.Visible = false
        return
    end
    
    local pct = math.clamp(armor / maxArmor, 0, 1)
    local armorH = ESP.Settings.HPHeight * scale
    local armorW = ESP.Settings.ArmorThick
    
    if pos == "Left" then
        local armorX = dims.x - armorW - 4
        if ESP.Settings.HP and ESP.Settings.HPPos == "Left" then
            armorX = armorX - armorW - 2
        end
        
        b.ArmorBg.Size = Vector2.new(armorW, armorH)
        b.ArmorBg.Position = Vector2.new(armorX, dims.y)
        b.ArmorBg.Color = ESP.Settings.ArmorBG
        b.ArmorBg.Visible = true
        
        b.ArmorFill.Size = Vector2.new(armorW, armorH * pct)
        b.ArmorFill.Position = Vector2.new(armorX, dims.y + armorH * (1 - pct))
        b.ArmorFill.Color = ESP.Settings.ArmorColor
        b.ArmorFill.Visible = true
        
        if ESP.Settings.ArmorText then
            b.ArmorText.Text = math.floor(pct * 100) .. "%"
            b.ArmorText.Color = ESP.Settings.ArmorColor
            b.ArmorText.Size = 10
            b.ArmorText.Position = Vector2.new(armorX - 20, dims.y + armorH / 2)
            b.ArmorText.Visible = true
        end
    elseif pos == "Right" then
        local armorX = dims.x + dims.w + 4
        if ESP.Settings.HP and ESP.Settings.HPPos == "Right" then
            armorX = armorX + armorW + 2
        end
        
        b.ArmorBg.Size = Vector2.new(armorW, armorH)
        b.ArmorBg.Position = Vector2.new(armorX, dims.y)
        b.ArmorBg.Color = ESP.Settings.ArmorBG
        b.ArmorBg.Visible = true
        
        b.ArmorFill.Size = Vector2.new(armorW, armorH * pct)
        b.ArmorFill.Position = Vector2.new(armorX, dims.y + armorH * (1 - pct))
        b.ArmorFill.Color = ESP.Settings.ArmorColor
        b.ArmorFill.Visible = true
        
        if ESP.Settings.ArmorText then
            b.ArmorText.Text = math.floor(pct * 100) .. "%"
            b.ArmorText.Color = ESP.Settings.ArmorColor
            b.ArmorText.Size = 10
            b.ArmorText.Position = Vector2.new(armorX + armorW + 5, dims.y + armorH / 2)
            b.ArmorText.Visible = true
        end
    end
end

-- =============================================
-- STAMINA BAR
-- =============================================
function ESP:DrawStaminaBar(b, dims, char, scale)
    local staminaVal = char:FindFirstChild("Stamina") or char:FindFirstChild("Energy")
    local stamina = 100
    local maxStamina = 100
    
    if staminaVal then
        if staminaVal:IsA("IntValue") or staminaVal:IsA("NumberValue") then
            stamina = staminaVal.Value
            maxStamina = staminaVal:FindFirstChild("Max") and staminaVal.Max.Value or 100
        end
    end
    
    local pct = math.clamp(stamina / maxStamina, 0, 1)
    local barW = dims.w
    local barH = 3
    
    local barY = dims.y + dims.h + 4
    if ESP.Settings.HP and ESP.Settings.HPPos == "Bottom" then
        barY = barY + 8
    end
    
    b.StaminaBg.Size = Vector2.new(barW, barH)
    b.StaminaBg.Position = Vector2.new(dims.x, barY)
    b.StaminaBg.Color = ESP.Settings.StaminaBG
    b.StaminaBg.Visible = true
    
    b.StaminaFill.Size = Vector2.new(barW * pct, barH)
    b.StaminaFill.Position = Vector2.new(dims.x, barY)
    b.StaminaFill.Color = ESP.Settings.StaminaColor
    b.StaminaFill.Visible = true
end

-- =============================================
-- HEAD DOT
-- =============================================
function ESP:DrawHeadDot(b, head, color, scale)
    if not head then return end
    
    local sp, _, onScreen = ESP:WorldToScreen(head.Position)
    if not onScreen then
        b.HeadDot.Visible = false
        return
    end
    
    local size = ESP.Settings.HeadDotSize * scale
    
    b.HeadDot.Position = sp
    b.HeadDot.Radius = size
    b.HeadDot.Color = color
    b.HeadDot.Filled = ESP.Settings.HeadDotFilled
    b.HeadDot.Thickness = ESP.Settings.HeadDotOutline and 1 or 0
    b.HeadDot.Visible = true
    
    -- Outline
    if ESP.Settings.HeadDotOutline then
        -- Drawing API doesn't support circle outline color directly, use second circle
        -- Simplified: just use thickness for outline effect
    end
end

-- =============================================
-- LOOK DIRECTION
-- =============================================
function ESP:DrawLookDir(b, head, color, thick)
    if not head then return end
    
    local origin = head.Position
    local dir = head.CFrame.LookVector * ESP.Settings.LookDirLength
    local endPos = origin + dir
    
    local sp1, _, onScreen1 = ESP:WorldToScreen(origin)
    local sp2, _, onScreen2 = ESP:WorldToScreen(endPos)
    
    if not onScreen1 or not onScreen2 then
        b.LookDir.Visible = false
        return
    end
    
    b.LookDir.From = sp1
    b.LookDir.To = sp2
    b.LookDir.Color = color
    b.LookDir.Thickness = thick
    b.LookDir.Visible = true
end

-- =============================================
-- VELOCITY VECTOR
-- =============================================
function ESP:DrawVelocity(b, root, color, thick)
    if not root then return end
    
    local vel = root.Velocity
    if vel.Magnitude < 0.1 then
        b.Velocity.Visible = false
        return
    end
    
    local origin = root.Position
    local endPos = origin + vel.Unit * ESP.Settings.VelocityLength
    
    local sp1, _, onScreen1 = ESP:WorldToScreen(origin)
    local sp2, _, onScreen2 = ESP:WorldToScreen(endPos)
    
    if not onScreen1 or not onScreen2 then
        b.Velocity.Visible = false
        return
    end
    
    b.Velocity.From = sp1
    b.Velocity.To = sp2
    b.Velocity.Color = color
    b.Velocity.Thickness = thick
    b.Velocity.Visible = true
end

-- =============================================
-- TRACER
-- =============================================
function ESP:DrawTracer(b, targetPos, color, thick, style)
    local vp = Camera.ViewportSize
    local cx, cy = vp.X / 2, vp.Y
    
    local origin
    if ESP.Settings.TracerOrigin == "Bottom" then
        origin = Vector2.new(cx, cy)
    elseif ESP.Settings.TracerOrigin == "Top" then
        origin = Vector2.new(cx, 0)
    elseif ESP.Settings.TracerOrigin == "Middle" then
        origin = Vector2.new(cx, cy / 2)
    elseif ESP.Settings.TracerOrigin == "Mouse" then
        local mousePos = UserInputService:GetMouseLocation()
        origin = mousePos
    elseif ESP.Settings.TracerOrigin == "Center" then
        origin = Vector2.new(cx, cy / 2)
    end
    
    if style == "Line" then
        b.Tracer.From = origin
        b.Tracer.To = targetPos
        b.Tracer.Color = color
        b.Tracer.Thickness = thick
        b.Tracer.Visible = true
    elseif style == "Bezier" then
        -- Simplified bezier - use midpoint curve
        local mid = (origin + targetPos) / 2
        mid = mid + Vector2.new(0, math.abs(origin.Y - targetPos.Y) * 0.3)
        
        b.Tracer.From = origin
        b.Tracer.To = mid
        b.Tracer.Color = color
        b.Tracer.Thickness = thick
        b.Tracer.Visible = true
        
        -- Second line for bezier
        b[20].From = mid
        b[20].To = targetPos
        b[20].Color = color
        b[20].Thickness = thick
        b[20].Visible = true
    elseif style == "Dashed" then
        -- Draw dashed line using multiple segments
        local dir = (targetPos - origin)
        local dist = dir.Magnitude
        local unit = dir.Unit
        local dashLen = ESP.Settings.TracerDashLength
        local gapLen = ESP.Settings.TracerGapLength
        local total = dashLen + gapLen
        local segments = math.floor(dist / total)
        
        local idx = 20
        for i = 0, segments - 1 do
            local startPos = origin + unit * (i * total)
            local endPos = origin + unit * (i * total + dashLen)
            if b[idx] then
                b[idx].From = startPos
                b[idx].To = endPos
                b[idx].Color = color
                b[idx].Thickness = thick
                b[idx].Visible = true
            end
            idx = idx + 1
        end
    end
end

-- =============================================
-- SNAPLINE
-- =============================================
function ESP:DrawSnapline(b, targetPos, color, thick)
    local vp = Camera.ViewportSize
    local origin = Vector2.new(vp.X / 2, vp.Y)
    
    b.Snap.From = origin
    b.Snap.To = targetPos
    b.Snap.Color = color
    b.Snap.Thickness = thick
    b.Snap.Visible = true
end

-- =============================================
-- OFF-SCREEN ARROW
-- =============================================
function ESP:DrawOffScreenArrow(b, char, color, dist)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local pos = hrp.Position
    local sp, _, onScreen = ESP:WorldToScreen(pos)
    
    if onScreen and ESP:IsOnScreen({X = sp.X, Y = sp.Y, Z = 1}) then
        b.OffScreenArrow.Visible = false
        b.OffScreenDist.Visible = false
        return
    end
    
    local vp = Camera.ViewportSize
    local cx, cy = vp.X / 2, vp.Y / 2
    
    -- Calculate angle
    local camCF = Camera.CFrame
    local relativePos = camCF:PointToObjectSpace(pos)
    local angle = math.atan2(relativePos.Z, relativePos.X)
    
    -- Arrow position on screen edge
    local edgeDist = math.min(vp.X, vp.Y) * 0.4
    local arrowX = cx + math.cos(angle - math.pi/2) * edgeDist
    local arrowY = cy + math.sin(angle - math.pi/2) * edgeDist
    
    -- Clamp to screen
    arrowX = math.clamp(arrowX, 30, vp.X - 30)
    arrowY = math.clamp(arrowY, 30, vp.Y - 30)
    
    local size = ESP.Settings.OffScreenSize
    
    -- Draw triangle arrow pointing to target
    b.OffScreenArrow.PointA = Vector2.new(arrowX + math.cos(angle) * size, arrowY + math.sin(angle) * size)
    b.OffScreenArrow.PointB = Vector2.new(arrowX + math.cos(angle + 2.5) * size, arrowY + math.sin(angle + 2.5) * size)
    b.OffScreenArrow.PointC = Vector2.new(arrowX + math.cos(angle - 2.5) * size, arrowY + math.sin(angle - 2.5) * size)
    b.OffScreenArrow.Color = color
    b.OffScreenArrow.Filled = true
    b.OffScreenArrow.Visible = true
    
    -- Distance text
    if ESP.Settings.OffScreenDist then
        b.OffScreenDist.Text = math.floor(dist) .. ESP.Settings.DistUnits
        b.OffScreenDist.Color = ESP.Settings.OffScreenDistColor
        b.OffScreenDist.Size = ESP.Settings.OffScreenDistSize
        b.OffScreenDist.Position = Vector2.new(arrowX, arrowY + size + 10)
        b.OffScreenDist.Visible = true
    end
end

-- =============================================
-- FOV CIRCLE
-- =============================================
function ESP:DrawFOV(b, targetPos, color)
    if not ESP.Settings.FOV then
        b.FOV.Visible = false
        return
    end
    
    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    
    b.FOV.Position = center
    b.FOV.Radius = ESP.Settings.FOVRadius
    b.FOV.Color = color
    b.FOV.Thickness = ESP.Settings.FOVThick
    b.FOV.Filled = ESP.Settings.FOVFilled
    b.FOV.Transparency = ESP.Settings.FOVFillTransparency
    b.FOV.Visible = true
end

-- =============================================
-- INFO PANEL
-- =============================================
function ESP:DrawInfoPanel(b, dims, p, char, hum, dist)
    if not ESP.Settings.InfoPanel then return end
    
    local info = ""
    local items = ESP.Settings.InfoItems
    
    for _, item in ipairs(items) do
        if item == "Name" then
            info = info .. "Name: " .. p.DisplayName .. "\n"
        elseif item == "Health" and hum then
            info = info .. "HP: " .. math.floor(hum.Health) .. "/" .. hum.MaxHealth .. "\n"
        elseif item == "Distance" then
            info = info .. "Dist: " .. math.floor(dist) .. ESP.Settings.DistUnits .. "\n"
        elseif item == "Weapon" then
            local wep = nil
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") then wep = tool.Name break end
            end
            if wep then info = info .. "Wep: " .. wep .. "\n" end
        elseif item == "Armor" then
            local armor = char:FindFirstChild("Armor")
            if armor then info = info .. "Armor: " .. armor.Value .. "\n" end
        elseif item == "Rank" then
            local rank = p:FindFirstChild("leaderstats") and p.leaderstats:FindFirstChild("Rank")
            if rank then info = info .. "Rank: " .. rank.Value .. "\n" end
        end
    end
    
    b.Info.Text = info
    b.Info.Color = ESP.Settings.InfoColor
    b.Info.Size = ESP.Settings.InfoSize
    b.Info.Position = Vector2.new(dims.x + dims.w + 10, dims.y)
    b.Info.Visible = true
    
    -- Background
    if ESP.Settings.InfoBG then
        local textBounds = b.Info.TextBounds or Vector2.new(100, 60)
        b.InfoBG.Size = textBounds + Vector2.new(10, 10)
        b.InfoBG.Position = Vector2.new(dims.x + dims.w + 5, dims.y - 5)
        b.InfoBG.Color = ESP.Settings.InfoBG
        b.InfoBG.Transparency = ESP.Settings.InfoBGTransparency
        b.InfoBG.Visible = true
    end
    
    -- Border
    if ESP.Settings.InfoBorder then
        -- Simplified border using lines
    end
end

-- =============================================
-- RANK/LEVEL
-- =============================================
function ESP:DrawRank(b, dims, p)
    if not ESP.Settings.Rank then return end
    
    local rank = p:FindFirstChild("leaderstats") and p.leaderstats:FindFirstChild("Rank")
    local level = p:FindFirstChild("leaderstats") and p.leaderstats:FindFirstChild("Level")
    
    local text = ""
    if rank then text = "[" .. rank.Value .. "]" end
    if level then text = text .. " Lv." .. level.Value end
    
    if text ~= "" then
        b.Rank.Text = text
        b.Rank.Color = ESP.Settings.RankColor
        b.Rank.Size = ESP.Settings.RankSize
        b.Rank.Position = Vector2.new(dims.centerX, dims.y - 30)
        b.Rank.Visible = true
    end
end

-- =============================================
-- STATUS
-- =============================================
function ESP:DrawStatus(b, dims, char, hum)
    if not ESP.Settings.Status then return end
    
    local statuses = {}
    
    -- Check various states
    if hum then
        if hum.Health <= 0 then table.insert(statuses, "DEAD")
        elseif hum.Health < hum.MaxHealth * 0.25 then table.insert(statuses, "CRITICAL")
        end
        
        -- Movement states
        if hum:GetState() == Enum.HumanoidStateType.Jumping then table.insert(statuses, "Jumping")
        elseif hum:GetState() == Enum.HumanoidStateType.Freefall then table.insert(statuses, "Falling")
        elseif hum:GetState() == Enum.HumanoidStateType.Ragdoll then table.insert(statuses, "Ragdoll")
        end
    end
    
    -- Check for crouching
    if char:FindFirstChild("Crouching") then table.insert(statuses, "Crouching") end
    -- Check for sprinting
    if char:FindFirstChild("Sprinting") then table.insert(statuses, "Sprinting") end
    -- Check for reloading
    if char:FindFirstChild("Reloading") then table.insert(statuses, "Reloading") end
    
    if #statuses > 0 then
        b.Status.Text = table.concat(statuses, " | ")
        b.Status.Color = ESP.Settings.StatusColor
        b.Status.Size = ESP.Settings.StatusSize
        b.Status.Position = Vector2.new(dims.centerX, dims.y + dims.h + 40)
        b.Status.Visible = true
    end
end

-- =============================================
-- SKELETON
-- =============================================
function ESP:DrawSkeleton(b, char, color, thick, colorByBone)
    local si = 25
    
    for _, bone in ipairs(SkeletonBones) do
        local p1 = char:FindFirstChild(bone[1])
        local p2 = char:FindFirstChild(bone[2])
        
        if p1 and p2 then
            local sp1, _, onScreen1 = ESP:WorldToScreen(p1.Position)
            local sp2, _, onScreen2 = ESP:WorldToScreen(p2.Position)
            
            if ESP:IsOnScreen({X = sp1.X, Y = sp1.Y, Z = 1}) and ESP:IsOnScreen({X = sp2.X, Y = sp2.Y, Z = 1}) then
                local boneColor = color
                if colorByBone then
                    boneColor = BoneColors[bone[1]] or color
                end
                
                if b[si] then
                    b[si].From = sp1
                    b[si].To = sp2
                    b[si].Color = boneColor
                    b[si].Thickness = thick
                    b[si].Visible = true
                    si = si + 1
                end
            end
        end
    end
    
    -- Dynamic skeleton (pulse effect)
    if ESP.Settings.SkeletonDynamic then
        local pulse = (
