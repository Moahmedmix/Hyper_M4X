-- ================================
-- Hyper UI - ESP System (No Ghost Billboard)
-- By M4X | EVA | AMAL
-- ================================

local ESP = {}
ESP.__index = ESP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- ================================
-- الإعدادات
-- ================================
ESP.Settings = {
    Enabled = false,
    MaxDist = 3000,
    TeamCheck = false,
    TeamColor = false,
    Rainbow = false,
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxThickness = 2,
    CornerLen = 22,
    Name = true,
    NameColor = Color3.fromRGB(255, 255, 255),
    NameSize = 13,
    Dist = true,
    DistColor = Color3.fromRGB(180, 180, 180),
    HP = true,
    HPPos = "Left",
    HPThick = 3,
    Tracer = false,
    Snap = false,
    Weapon = false,
    Skeleton = false,
    HeadDot = false,
}

ESP.Active = {}
ESP.ScreenGui = nil
ESP.Conn = nil
ESP.RainbowHue = 0

-- ================================
-- دوال الألوان
-- ================================
function ESP:GetColor(p)
    if ESP.Settings.Rainbow then
        ESP.RainbowHue = (ESP.RainbowHue + 0.003) % 1
        return Color3.fromHSV(ESP.RainbowHue, 1, 1)
    end
    if ESP.Settings.TeamColor and p.Team and LocalPlayer.Team then
        if p.Team == LocalPlayer.Team then
            return Color3.fromRGB(50, 255, 50)
        end
        return Color3.fromRGB(255, 50, 50)
    end
    return ESP.Settings.BoxColor
end

-- ================================
-- إنشاء Billboard لكل لاعب
-- ================================
function ESP:CreateBillboard(player)
    local bill = Instance.new("BillboardGui")
    bill.Name = "ESP_" .. player.Name
    bill.AlwaysOnTop = true
    bill.Size = UDim2.new(0, 200, 0, 120)
    bill.StudsOffset = Vector3.new(0, 2.5, 0)
    bill.MaxDistance = ESP.Settings.MaxDist
    bill.Parent = ESP.ScreenGui
    bill.Adornee = player.Character and player.Character:FindFirstChild("Head")
    
    -- الاسم
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
    
    -- المسافة
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
    
    -- شريط الصحة (خلفية)
    local hpBg = Instance.new("Frame", bill)
    hpBg.Name = "HPBg"
    hpBg.Size = UDim2.new(0, 4, 1, 0)
    hpBg.Position = UDim2.new(0, -8, 0, 0)
    hpBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    hpBg.BorderSizePixel = 0
    
    -- شريط الصحة (التعبئة)
    local hpFill = Instance.new("Frame", hpBg)
    hpFill.Name = "HPFill"
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    hpFill.BorderSizePixel = 0
    
    -- الإطار (Box)
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

-- ================================
-- تحديث Billboard
-- ================================
function ESP:UpdateBillboard(player, bill)
    local char = player.Character
    if not char then return end
    
    local head = char:FindFirstChild("Head")
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not head or not root then return end
    
    local dist = (Camera.CFrame.Position - root.Position).Magnitude
    
    -- تحديث الـ Adornee
    bill.Adornee = head
    bill.MaxDistance = ESP.Settings.MaxDist
    
    -- تحديث المسافة
    local distLabel = bill:FindFirstChild("Dist")
    if distLabel then
        distLabel.Text = ESP.Settings.Dist and "[" .. math.floor(dist) .. "m]" or ""
        distLabel.TextColor3 = ESP.Settings.DistColor
    end
    
    -- تحديث الاسم
    local nameLabel = bill:FindFirstChild("Name")
    if nameLabel then
        nameLabel.Visible = ESP.Settings.Name
        nameLabel.TextColor3 = ESP.Settings.NameColor
        nameLabel.TextSize = ESP.Settings.NameSize
    end
    
    -- تحديث شريط الصحة
    local hpBg = bill:FindFirstChild("HPBg")
    if hpBg then
        hpBg.Visible = ESP.Settings.HP and hum ~= nil
        local hpFill = hpBg:FindFirstChild("HPFill")
        if hpFill and hum then
            local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            hpFill.Size = UDim2.new(1, 0, pct, 0)
            if pct > 0.5 then
                hpFill.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            elseif pct > 0.25 then
                hpFill.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
            else
                hpFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            end
        end
    end
    
    -- تحديث الإطار
    local box = bill:FindFirstChild("Box")
    if box then
        local stroke = box:FindFirstChild("Stroke")
        if stroke then
            stroke.Color = ESP:GetColor(player)
            stroke.Thickness = ESP.Settings.BoxThickness
        end
    end
end

-- ================================
-- تحديث كل الـ ESP
-- ================================
function ESP:Update()
    local mt = LocalPlayer.Team
    local processed = {}
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then
            if ESP.Active[p] then
                ESP.Active[p]:Destroy()
                ESP.Active[p] = nil
            end
            goto continue
        end
        
        if ESP.Settings.TeamCheck and p.Team == mt then
            if ESP.Active[p] then
                ESP.Active[p]:Destroy()
                ESP.Active[p] = nil
            end
            goto continue
        end
        
        local char = p.Character
        if not char then
            if ESP.Active[p] then
                ESP.Active[p]:Destroy()
                ESP.Active[p] = nil
            end
            goto continue
        end
        
        local head = char:FindFirstChild("Head")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not head or not root then
            if ESP.Active[p] then
                ESP.Active[p]:Destroy()
                ESP.Active[p] = nil
            end
            goto continue
        end
        
        local dist = (Camera.CFrame.Position - root.Position).Magnitude
        if dist > ESP.Settings.MaxDist then
            if ESP.Active[p] then
                ESP.Active[p]:Destroy()
                ESP.Active[p] = nil
            end
            goto continue
        end
        
        if not ESP.Active[p] then
            ESP.Active[p] = ESP:CreateBillboard(p)
        end
        
        ESP:UpdateBillboard(p, ESP.Active[p])
        processed[p] = true
        
        ::continue::
    end
    
    -- تنظيف
    for p, bill in pairs(ESP.Active) do
        if not processed[p] then
            bill:Destroy()
            ESP.Active[p] = nil
        end
    end
end

-- ================================
-- تشغيل/إيقاف
-- ================================
function ESP:Start()
    if ESP.ScreenGui then ESP.ScreenGui:Destroy() end
    ESP.ScreenGui = Instance.new("ScreenGui", CoreGui)
    ESP.ScreenGui.Name = "Hyper_ESP"
    ESP.ScreenGui.ResetOnSpawn = false
    ESP.Active = {}
    ESP.Conn = RunService.RenderStepped:Connect(function()
        ESP:Update()
    end)
end

function ESP:Stop()
    if ESP.Conn then
        ESP.Conn:Disconnect()
        ESP.Conn = nil
    end
    if ESP.ScreenGui then
        ESP.ScreenGui:Destroy()
        ESP.ScreenGui = nil
    end
    ESP.Active = {}
end

-- ================================
-- عند خروج اللاعب
-- ================================
Players.PlayerRemoving:Connect(function(p)
    if ESP.Active[p] then
        ESP.Active[p]:Destroy()
        ESP.Active[p] = nil
    end
end)

-- ================================
-- دالة التهيئة للـ WindUI
-- ================================
function ESP:Init(tab)
    local self = setmetatable({}, ESP)
    self.Tab = tab
    
    -- قسم ESP
    local Sec = tab:Section({ Title = "ESP", Side = "Left", Collapsed = false })
    
    -- Enable ESP
    Sec:Toggle({
        Title = "Enable ESP",
        Flag = "ESP_Enable",
        Value = false,
        Callback = function(v)
            ESP.Settings.Enabled = v
            if v then
                ESP:Start()
            else
                ESP:Stop()
            end
        end
    })
    
    -- Max Distance
    Sec:Slider({
        Title = "Max Distance",
        Flag = "ESP_MaxDist",
        Value = { Min = 100, Max = 10000, Default = 3000 },
        Step = 100,
        Callback = function(v)
            ESP.Settings.MaxDist = v
        end
    })
    
    -- Team Check
    Sec:Toggle({
        Title = "Team Check",
        Flag = "ESP_TeamCheck",
        Value = false,
        Callback = function(v)
            ESP.Settings.TeamCheck = v
        end
    })
    
    -- Team Color
    Sec:Toggle({
        Title = "Team Color",
        Flag = "ESP_TeamColor",
        Value = false,
        Callback = function(v)
            ESP.Settings.TeamColor = v
        end
    })
    
    -- Rainbow
    Sec:Toggle({
        Title = "Rainbow",
        Flag = "ESP_Rainbow",
        Value = false,
        Callback = function(v)
            ESP.Settings.Rainbow = v
        end
    })
    
    Sec:Space()
    
    -- ===== قسم Box =====
    local SecBox = tab:Section({ Title = "Box", Side = "Left", Collapsed = true })
    
    SecBox:Colorpicker({
        Title = "Box Color",
        Flag = "ESP_BoxColor",
        Default = ESP.Settings.BoxColor,
        Transparency = 0,
        Callback = function(v)
            ESP.Settings.BoxColor = v
        end
    })
    
    SecBox:Slider({
        Title = "Box Thickness",
        Flag = "ESP_BoxThickness",
        Value = { Min = 1, Max = 6, Default = 2 },
        Step = 0.5,
        Callback = function(v)
            ESP.Settings.BoxThickness = v
        end
    })
    
    SecBox:Space()
    
    -- ===== قسم Info =====
    local SecInfo = tab:Section({ Title = "Info", Side = "Left", Collapsed = true })
    
    SecInfo:Toggle({
        Title = "Show Name",
        Flag = "ESP_Name",
        Value = true,
        Callback = function(v)
            ESP.Settings.Name = v
        end
    })
    
    SecInfo:Colorpicker({
        Title = "Name Color",
        Flag = "ESP_NameColor",
        Default = ESP.Settings.NameColor,
        Transparency = 0,
        Callback = function(v)
            ESP.Settings.NameColor = v
        end
    })
    
    SecInfo:Slider({
        Title = "Name Size",
        Flag = "ESP_NameSize",
        Value = { Min = 10, Max = 22, Default = 13 },
        Step = 1,
        Callback = function(v)
            ESP.Settings.NameSize = v
        end
    })
    
    SecInfo:Toggle({
        Title = "Show Distance",
        Flag = "ESP_Dist",
        Value = true,
        Callback = function(v)
            ESP.Settings.Dist = v
        end
    })
    
    SecInfo:Colorpicker({
        Title = "Distance Color",
        Flag = "ESP_DistColor",
        Default = ESP.Settings.DistColor,
        Transparency = 0,
        Callback = function(v)
            ESP.Settings.DistColor = v
        end
    })
    
    SecInfo:Space()
    
    -- ===== قسم Health =====
    local SecHP = tab:Section({ Title = "Health", Side = "Left", Collapsed = true })
    
    SecHP:Toggle({
        Title = "Show HP Bar",
        Flag = "ESP_HP",
        Value = true,
        Callback = function(v)
            ESP.Settings.HP = v
        end
    })
    
    return self
end

-- ================================
-- تصدير الـ Module
-- ================================
return ESP
