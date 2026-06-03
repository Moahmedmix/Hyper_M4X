--[[
    ╔══════════════════════════════════════════════════╗
    ║           HYPER UI - ESP System                  ║
    ║              Version: v1.0.0                      ║
    ║         By M4X | EVA | AMAL                      ║
    ╚══════════════════════════════════════════════════╝
    
    Features:
    - Dynamic Hitbox ESP (GetExtentsSize)
    - Distance-based transparency fade
    - Name, Health, Distance display
    - Visibility check
    - Team Color support
    - Full color customization
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
    Color = Color3.fromRGB(255, 255, 255),
    TeamColor = false,
    TeamCheck = false,
    ShowName = true,
    ShowHealth = true,
    ShowDistance = true,
    ShowBox = true,
    BoxThickness = 1.5,
    TextSize = 14,
    MaxDistance = 1000,
    FadeSpeed = 0.15,
    MaxOpacity = 0.35,
}

ESP.Elements = {}
ESP.Connection = nil
ESP.ScreenGui = nil

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

    -- Main
    local main = self.Tab:Section({ Title = "ESP Main", Icon = "eye", Opened = true })
    
    main:Toggle({ Title = "Enable ESP", Value = false,
        Callback = function(s) ESP.Settings.Enabled = s; if s then self:Start() else self:Stop() end end
    })

    main:Toggle({ Title = "Team Check", Value = false,
        Callback = function(s) ESP.Settings.TeamCheck = s end
    })

    main:Toggle({ Title = "Team Color", Value = false,
        Callback = function(s) ESP.Settings.TeamColor = s end
    })

    main:Slider({ Title = "Max Distance", Min = 100, Max = 5000, Step = 100, Value = 1000,
        Suffix = " studs", Callback = function(v) ESP.Settings.MaxDistance = v end
    })

    -- Box
    local box = self.Tab:Section({ Title = "Box", Icon = "square", Opened = true })
    
    box:Toggle({ Title = "Show Box", Value = true,
        Callback = function(s) ESP.Settings.ShowBox = s end
    })

    box:ColorPicker({ Title = "Box Color", Default = ESP.Settings.Color,
        Callback = function(c) ESP.Settings.Color = c end
    })

    box:Slider({ Title = "Box Thickness", Min = 1, Max = 5, Step = 0.5, Value = 1.5,
        Suffix = "px", Callback = function(v) ESP.Settings.BoxThickness = v end
    })

    -- Text
    local text = self.Tab:Section({ Title = "Text", Icon = "type", Opened = true })
    
    text:Toggle({ Title = "Show Name", Value = true,
        Callback = function(s) ESP.Settings.ShowName = s end
    })

    text:Toggle({ Title = "Show Health", Value = true,
        Callback = function(s) ESP.Settings.ShowHealth = s end
    })

    text:Toggle({ Title = "Show Distance", Value = true,
        Callback = function(s) ESP.Settings.ShowDistance = s end
    })

    text:Slider({ Title = "Text Size", Min = 10, Max = 20, Step = 1, Value = 14,
        Suffix = "px", Callback = function(v) ESP.Settings.TextSize = v end
    })

    -- Fade
    local fade = self.Tab:Section({ Title = "Fade", Icon = "sun-dim", Opened = true })
    
    fade:Slider({ Title = "Fade Speed", Min = 0.05, Max = 0.5, Step = 0.05, Value = 0.15,
        Callback = function(v) ESP.Settings.FadeSpeed = v end
    })

    fade:Slider({ Title = "Max Opacity", Min = 0.1, Max = 1, Step = 0.05, Value = 0.35,
        Callback = function(v) ESP.Settings.MaxOpacity = v end
    })
end

function ESP:Start()
    if self.ScreenGui then self.ScreenGui:Destroy() end
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "Hyper_ESP"
    self.ScreenGui.Parent = CoreGui
    self.ScreenGui.ResetOnSpawn = false
    ESP.Elements = {}

    -- Track current players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            self:TrackPlayer(player)
        end
    end

    -- Track new players
    self.PlayerAddedCon = Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            self:TrackPlayer(player)
        end
    end)

    -- Untrack leaving players
    self.PlayerRemovingCon = Players.PlayerRemoving:Connect(function(player)
        self:UntrackPlayer(player)
    end)

    -- Update loop
    self.Connection = RunService.RenderStepped:Connect(function()
        self:Update()
    end)

    if self.Library then
        self.Library:Notify({ Title = "ESP", Description = "ESP Activated", Duration = 2 })
    end
end

function ESP:Stop()
    if self.Connection then self.Connection:Disconnect(); self.Connection = nil end
    if self.PlayerAddedCon then self.PlayerAddedCon:Disconnect(); self.PlayerAddedCon = nil end
    if self.PlayerRemovingCon then self.PlayerRemovingCon:Disconnect(); self.PlayerRemovingCon = nil end
    if self.ScreenGui then self.ScreenGui:Destroy(); self.ScreenGui = nil end
    ESP.Elements = {}

    if self.Library then
        self.Library:Notify({ Title = "ESP", Description = "ESP Deactivated", Duration = 2 })
    end
end

function ESP:TrackPlayer(player)
    if ESP.Elements[player] then return end

    local elements = {}
    
    -- Box
    local box = Instance.new("Frame")
    box.Name = "Box"
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Parent = self.ScreenGui
    
    local stroke = Instance.new("UIStroke")
    stroke.Name = "Stroke"
    stroke.Parent = box
    stroke.LineJoinMode = Enum.LineJoinMode.Miter
    
    elements.Box = box
    elements.Stroke = stroke
    elements.Alpha = 0

    -- Text
    local text = Instance.new("TextLabel")
    text.Name = "Text"
    text.BackgroundTransparency = 1
    text.TextStrokeTransparency = 0.5
    text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    text.Font = Enum.Font.GothamBold
    text.Parent = self.ScreenGui
    elements.Text = text

    ESP.Elements[player] = elements
end

function ESP:UntrackPlayer(player)
    if ESP.Elements[player] then
        for _, v in pairs(ESP.Elements[player]) do
            pcall(function() v:Destroy() end)
        end
        ESP.Elements[player] = nil
    end
end

function ESP:IsVisible(character)
    local head = character:FindFirstChild("Head")
    local torso = character:FindFirstChild("HumanoidRootPart")
    if head then
        local _, vis = Camera:WorldToViewportPoint(head.Position)
        if vis then return true end
    end
    if torso then
        local _, vis = Camera:WorldToViewportPoint(torso.Position)
        if vis then return true end
    end
    return false
end

function ESP:GetDistanceTransparency(distance)
    local t = math.clamp(1 - (distance / ESP.Settings.MaxDistance), 0, 1)
    return ESP.Settings.MaxOpacity * t
end

function ESP:Update()
    local myTeam = LocalPlayer.Team

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then self:UntrackPlayer(player) continue end
        if ESP.Settings.TeamCheck and player.Team == myTeam then self:UntrackPlayer(player) continue end

        local character = player.Character
        if not character then self:UntrackPlayer(player) continue end

        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        local head = character:FindFirstChild("Head")

        if not rootPart or not humanoid or not head then self:UntrackPlayer(player) continue end

        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then continue end

        local distance = (rootPart.Position - myRoot.Position).Magnitude
        local color = ESP.Settings.TeamColor and player.Team and player.TeamColor.Color or ESP.Settings.Color

        -- Track if not tracked
        if not ESP.Elements[player] then self:TrackPlayer(player) end
        local elements = ESP.Elements[player]
        if not elements then continue end

        local alpha = elements.Alpha or 0

        if self:IsVisible(character) and distance <= ESP.Settings.MaxDistance then
            local targetAlpha = self:GetDistanceTransparency(distance)
            if targetAlpha > alpha then
                alpha = math.min(alpha + ESP.Settings.FadeSpeed, targetAlpha)
            else
                alpha = math.max(alpha - ESP.Settings.FadeSpeed, targetAlpha)
            end

            local modelSize = character:GetExtentsSize()
            local hrpCF = rootPart.CFrame

            local topLeft = Camera:WorldToViewportPoint((hrpCF * CFrame.new(-modelSize.X/2, modelSize.Y/2, 0)).Position)
            local bottomRight = Camera:WorldToViewportPoint((hrpCF * CFrame.new(modelSize.X/2, -modelSize.Y/2, 0)).Position)

            -- Box
            if ESP.Settings.ShowBox and elements.Box and elements.Stroke then
                elements.Box.Visible = alpha > 0
                elements.Box.Size = UDim2.new(0, bottomRight.X - topLeft.X, 0, bottomRight.Y - topLeft.Y)
                elements.Box.Position = UDim2.new(0, topLeft.X, 0, topLeft.Y)
                elements.Box.BackgroundTransparency = 1 - alpha
                elements.Box.BackgroundColor3 = color
                elements.Stroke.Color = color
                elements.Stroke.Thickness = ESP.Settings.BoxThickness
                elements.Stroke.Transparency = 1 - alpha
            elseif elements.Box then
                elements.Box.Visible = false
            end

            -- Text
            if elements.Text then
                local health = math.floor(humanoid.Health)
                local textStr = ""
                
                if ESP.Settings.ShowName then
                    textStr = "[" .. player.Name .. "]"
                end
                if ESP.Settings.ShowHealth then
                    textStr = textStr .. " | HP: " .. health
                end
                if ESP.Settings.ShowDistance then
                    textStr = textStr .. " | " .. math.floor(distance) .. "m"
                end

                local headPos = Camera:WorldToViewportPoint(head.Position)

                elements.Text.Visible = alpha > 0
                elements.Text.Text = textStr
                elements.Text.TextColor3 = color
                elements.Text.TextSize = ESP.Settings.TextSize
                elements.Text.Size = UDim2.new(0, 300, 0, 20)
                elements.Text.Position = UDim2.new(0, headPos.X - 150, 0, topLeft.Y - 20)
                elements.Text.TextTransparency = 1 - alpha
                elements.Text.TextStrokeTransparency = 0.5 + (alpha * 0.5)
            end
        else
            alpha = math.max(alpha - ESP.Settings.FadeSpeed, 0)
            if elements.Box then elements.Box.Visible = alpha > 0 end
            if elements.Text then elements.Text.Visible = alpha > 0 end
            if elements.Box and elements.Stroke then elements.Stroke.Transparency = 1 - alpha end
            if elements.Text then elements.Text.TextTransparency = 1 - alpha end
        end

        elements.Alpha = alpha
    end

    -- Clean up
    for player, _ in pairs(ESP.Elements) do
        if not player.Parent then self:UntrackPlayer(player) end
    end
end

return ESP
