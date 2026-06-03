local ESP = {}
ESP.__index = ESP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

ESP.Settings = {
    Enabled = false,
    Boxes = true,
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxThickness = 1.5,
    Names = true,
    NameColor = Color3.fromRGB(255, 255, 255),
    NameSize = 14,
    Distance = true,
    DistanceColor = Color3.fromRGB(180, 180, 180),
    HealthBar = true,
    HealthColor = Color3.fromRGB(50, 200, 50),
    Tracers = false,
    TracerColor = Color3.fromRGB(255, 255, 255),
    TracerThickness = 1,
    HeadDot = false,
    HeadDotColor = Color3.fromRGB(255, 0, 0),
    TeamCheck = false,
    TeamColor = false,
    MaxDistance = 1000,
}

function ESP:Init(tab, library, flags)
    local self = setmetatable({}, ESP)
    self.Tab = tab
    self.Library = library
    self.Flags = flags
    self.ScreenGui = nil
    self.Elements = {}
    self.Connection = nil

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

    -- Boxes
    local boxes = self.Tab:Section({ Title = "Boxes", Icon = "square", Opened = true })
    
    boxes:Toggle({ Title = "Show Boxes", Value = true,
        Callback = function(s) ESP.Settings.Boxes = s end
    })

    boxes:ColorPicker({ Title = "Box Color", Default = ESP.Settings.BoxColor,
        Callback = function(c) ESP.Settings.BoxColor = c end
    })

    boxes:Slider({ Title = "Box Thickness", Min = 1, Max = 5, Step = 0.5, Value = 1.5,
        Suffix = "px", Callback = function(v) ESP.Settings.BoxThickness = v end
    })

    -- Names
    local names = self.Tab:Section({ Title = "Names", Icon = "type", Opened = true })
    
    names:Toggle({ Title = "Show Names", Value = true,
        Callback = function(s) ESP.Settings.Names = s end
    })

    names:ColorPicker({ Title = "Name Color", Default = ESP.Settings.NameColor,
        Callback = function(c) ESP.Settings.NameColor = c end
    })

    names:Slider({ Title = "Name Size", Min = 10, Max = 24, Step = 1, Value = 14,
        Suffix = "px", Callback = function(v) ESP.Settings.NameSize = v end
    })

    -- Distance
    local dist = self.Tab:Section({ Title = "Distance", Icon = "ruler", Opened = true })
    
    dist:Toggle({ Title = "Show Distance", Value = true,
        Callback = function(s) ESP.Settings.Distance = s end
    })

    dist:ColorPicker({ Title = "Distance Color", Default = ESP.Settings.DistanceColor,
        Callback = function(c) ESP.Settings.DistanceColor = c end
    })

    -- Health
    local health = self.Tab:Section({ Title = "Health Bar", Icon = "activity", Opened = true })
    
    health:Toggle({ Title = "Show Health", Value = true,
        Callback = function(s) ESP.Settings.HealthBar = s end
    })

    health:ColorPicker({ Title = "Health Color", Default = ESP.Settings.HealthColor,
        Callback = function(c) ESP.Settings.HealthColor = c end
    })

    -- Tracers
    local tracers = self.Tab:Section({ Title = "Tracers", Icon = "trending-up", Opened = true })
    
    tracers:Toggle({ Title = "Show Tracers", Value = false,
        Callback = function(s) ESP.Settings.Tracers = s end
    })

    tracers:ColorPicker({ Title = "Tracer Color", Default = ESP.Settings.TracerColor,
        Callback = function(c) ESP.Settings.TracerColor = c end
    })

    tracers:Slider({ Title = "Tracer Thickness", Min = 1, Max = 5, Step = 0.5, Value = 1,
        Suffix = "px", Callback = function(v) ESP.Settings.TracerThickness = v end
    })

    -- Head Dot
    local dot = self.Tab:Section({ Title = "Head Dot", Icon = "circle", Opened = false })
    
    dot:Toggle({ Title = "Show Head Dot", Value = false,
        Callback = function(s) ESP.Settings.HeadDot = s end
    })

    dot:ColorPicker({ Title = "Dot Color", Default = ESP.Settings.HeadDotColor,
        Callback = function(c) ESP.Settings.HeadDotColor = c end
    })
end

function ESP:Start()
    if self.ScreenGui then self.ScreenGui:Destroy() end
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "Hyper_ESP"
    self.ScreenGui.Parent = game:GetService("CoreGui")
    self.ScreenGui.ResetOnSpawn = false
    self.Elements = {}
    
    self.Connection = RunService.RenderStepped:Connect(function() self:Update() end)
end

function ESP:Stop()
    if self.Connection then self.Connection:Disconnect(); self.Connection = nil end
    if self.ScreenGui then self.ScreenGui:Destroy(); self.ScreenGui = nil end
    self.Elements = {}
end

function ESP:Update()
    local myTeam = LocalPlayer.Team

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then self:RemovePlayer(player) continue end
        if ESP.Settings.TeamCheck and player.Team == myTeam then self:RemovePlayer(player) continue end
        
        local char = player.Character
        if not char then self:RemovePlayer(player) continue end
        
        local head = char:FindFirstChild("Head")
        local root = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChild("Humanoid")
        if not head or not root then self:RemovePlayer(player) continue end
        
        local dist = (Camera.CFrame.Position - root.Position).Magnitude
        if dist > ESP.Settings.MaxDistance then self:RemovePlayer(player) continue end
        
        local headPos, headOn = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.6, 0))
        local legPos, legOn = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.2, 0))
        
        if not headOn and not legOn then self:RemovePlayer(player) continue end
        
        local h = math.abs(headPos.Y - legPos.Y)
        local w = h * 0.6
        local x = headPos.X - w/2
        local y = headPos.Y
        
        local color = ESP.Settings.TeamColor and player.Team and player.Team.TeamColor.Color or ESP.Settings.BoxColor
        
        if not self.Elements[player] then self.Elements[player] = {} end
        local el = self.Elements[player]
        
        -- Box
        if ESP.Settings.Boxes then
            if not el.Box then
                el.Box = Instance.new("Frame")
                el.Box.BackgroundTransparency = 1
                el.Box.BorderSizePixel = 0
                el.Box.Parent = self.ScreenGui
                
                local stroke = Instance.new("UIStroke", el.Box)
                stroke.Name = "Stroke"
            end
            el.Box.Size = UDim2.new(0, w, 0, h)
            el.Box.Position = UDim2.new(0, x, 0, y)
            el.Box.Stroke.Color = color
            el.Box.Stroke.Thickness = ESP.Settings.BoxThickness
        elseif el.Box then
            el.Box:Destroy(); el.Box = nil
        end
        
        -- Name
        if ESP.Settings.Names then
            if not el.Name then
                el.Name = Instance.new("TextLabel")
                el.Name.BackgroundTransparency = 1
                el.Name.TextStrokeTransparency = 0.5
                el.Name.Font = Enum.Font.GothamBold
                el.Name.Parent = self.ScreenGui
            end
            el.Name.Text = player.Name
            el.Name.TextColor3 = ESP.Settings.NameColor
            el.Name.TextSize = ESP.Settings.NameSize
            el.Name.Size = UDim2.new(0, 200, 0, 20)
            el.Name.Position = UDim2.new(0, x + w/2 - 100, 0, y - 20)
        elseif el.Name then
            el.Name:Destroy(); el.Name = nil
        end
        
        -- Distance
        if ESP.Settings.Distance then
            if not el.Dist then
                el.Dist = Instance.new("TextLabel")
                el.Dist.BackgroundTransparency = 1
                el.Dist.TextStrokeTransparency = 0.5
                el.Dist.Font = Enum.Font.Gotham
                el.Dist.Parent = self.ScreenGui
            end
            el.Dist.Text = math.floor(dist) .. "m"
            el.Dist.TextColor3 = ESP.Settings.DistanceColor
            el.Dist.TextSize = 13
            el.Dist.Size = UDim2.new(0, 200, 0, 18)
            el.Dist.Position = UDim2.new(0, x + w/2 - 100, 0, y + h + 2)
        elseif el.Dist then
            el.Dist:Destroy(); el.Dist = nil
        end
        
        -- Health Bar
        if ESP.Settings.HealthBar and humanoid then
            if not el.HealthBg then
                el.HealthBg = Instance.new("Frame")
                el.HealthBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                el.HealthBg.BorderSizePixel = 0
                el.HealthBg.Size = UDim2.new(0, 4, 0, h)
                el.HealthBg.Position = UDim2.new(0, x - 6, 0, y)
                el.HealthBg.Parent = self.ScreenGui
                
                el.HealthFill = Instance.new("Frame")
                el.HealthFill.BorderSizePixel = 0
                el.HealthFill.Size = UDim2.new(1, 0, 1, 0)
                el.HealthFill.Parent = el.HealthBg
            end
            el.HealthBg.Size = UDim2.new(0, 4, 0, h)
            el.HealthBg.Position = UDim2.new(0, x - 6, 0, y)
            local pct = humanoid.Health / humanoid.MaxHealth
            el.HealthFill.Size = UDim2.new(1, 0, pct, 0)
            el.HealthFill.BackgroundColor3 = pct > 0.5 and Color3.fromRGB(50, 200, 50) or pct > 0.25 and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(255, 50, 50)
        elseif el.HealthBg then
            el.HealthBg:Destroy(); el.HealthBg = nil
        end
        
        -- Tracers
        if ESP.Settings.Tracers then
            if not el.Tracer then
                el.Tracer = Instance.new("Frame")
                el.Tracer.BorderSizePixel = 0
                el.Tracer.Parent = self.ScreenGui
            end
            local startX = Camera.ViewportSize.X / 2
            local startY = Camera.ViewportSize.Y
            local endX = x + w/2
            local endY = y + h
            local dx = endX - startX
            local dy = endY - startY
            local length = math.sqrt(dx*dx + dy*dy)
            local angle = math.atan2(dy, dx)
            
            el.Tracer.Size = UDim2.new(0, length, 0, ESP.Settings.TracerThickness)
            el.Tracer.Position = UDim2.new(0, startX, 0, startY)
            el.Tracer.Rotation = math.deg(angle)
            el.Tracer.BackgroundColor3 = ESP.Settings.TracerColor
        elseif el.Tracer then
            el.Tracer:Destroy(); el.Tracer = nil
        end
        
        -- Head Dot
        if ESP.Settings.HeadDot then
            if not el.HeadDot then
                el.HeadDot = Instance.new("Frame")
                el.HeadDot.BorderSizePixel = 0
                el.HeadDot.Parent = self.ScreenGui
                Instance.new("UICorner", el.HeadDot).CornerRadius = UDim.new(1, 0)
            end
            local dotSize = math.clamp(200 / dist * 30, 4, 15)
            el.HeadDot.Size = UDim2.new(0, dotSize, 0, dotSize)
            el.HeadDot.Position = UDim2.new(0, headPos.X - dotSize/2, 0, headPos.Y - dotSize/2)
            el.HeadDot.BackgroundColor3 = ESP.Settings.HeadDotColor
        elseif el.HeadDot then
            el.HeadDot:Destroy(); el.HeadDot = nil
        end
    end
    
    for player in pairs(self.Elements) do
        if not player.Parent then self:RemovePlayer(player) end
    end
end

function ESP:RemovePlayer(player)
    if self.Elements[player] then
        for _, v in pairs(self.Elements[player]) do
            pcall(function() v:Destroy() end)
        end
        self.Elements[player] = nil
    end
end

return ESP
