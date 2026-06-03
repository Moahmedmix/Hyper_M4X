--[[
    ╔══════════════════════════════════════════════════╗
    ║           HYPER UI - ESP System                  ║
    ║              Version: v1.0.0                      ║
    ║         By M4X | EVA | AMAL                      ║
    ╚══════════════════════════════════════════════════╝
--]]

local ESP = {}
ESP.__index = ESP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

ESP.Objects = {}
ESP.Settings = {
    Enabled = false,
    Boxes = false,
    Names = false,
    Distance = false,
    Health = false,
    Tracers = false,
    Color = Color3.fromRGB(255, 255, 255),
    MaxDistance = 1000,
    UpdateRate = 60,
}

function ESP:Init(tab, library, flags)
    local self = setmetatable({}, ESP)
    self.Tab = tab
    self.Library = library
    self.Flags = flags

    if flags then
        flags:Create("ESP_Enabled", false)
        flags:Create("ESP_Boxes", false)
        flags:Create("ESP_Names", false)
        flags:Create("ESP_Distance", false)
        flags:Create("ESP_Health", false)
        flags:Create("ESP_Tracers", false)
        flags:Create("ESP_MaxDistance", 1000)
    end

    self:BuildUI()
    self:StartLoop()
    return self
end

function ESP:BuildUI()
    if not self.Tab then return end

    local mainSection = self.Tab:Section({ 
        Title = "ESP Settings", 
        Icon = "eye",
        Opened = true 
    })

    mainSection:Toggle({
        Title = "Enable ESP",
        Description = "Turn ESP on/off",
        Value = false,
        Callback = function(state)
            ESP.Settings.Enabled = state
            if self.Flags then self.Flags:Set("ESP_Enabled", state) end
            if not state then self:ClearAll() end
        end
    })

    mainSection:Toggle({
        Title = "Boxes",
        Description = "Show 2D boxes around players",
        Value = false,
        Callback = function(state)
            ESP.Settings.Boxes = state
            if self.Flags then self.Flags:Set("ESP_Boxes", state) end
        end
    })

    mainSection:Toggle({
        Title = "Names",
        Description = "Show player names",
        Value = false,
        Callback = function(state)
            ESP.Settings.Names = state
            if self.Flags then self.Flags:Set("ESP_Names", state) end
        end
    })

    mainSection:Toggle({
        Title = "Distance",
        Description = "Show distance to player",
        Value = false,
        Callback = function(state)
            ESP.Settings.Distance = state
            if self.Flags then self.Flags:Set("ESP_Distance", state) end
        end
    })

    mainSection:Toggle({
        Title = "Health Bar",
        Description = "Show player health",
        Value = false,
        Callback = function(state)
            ESP.Settings.Health = state
            if self.Flags then self.Flags:Set("ESP_Health", state) end
        end
    })

    mainSection:Toggle({
        Title = "Tracers",
        Description = "Show lines to players",
        Value = false,
        Callback = function(state)
            ESP.Settings.Tracers = state
            if self.Flags then self.Flags:Set("ESP_Tracers", state) end
        end
    })

    local colorSection = self.Tab:Section({ 
        Title = "ESP Color", 
        Icon = "palette",
        Opened = true 
    })

    colorSection:ColorPicker({
        Title = "ESP Color",
        Description = "Choose ESP color",
        Default = ESP.Settings.Color,
        Callback = function(color)
            ESP.Settings.Color = color
        end
    })

    local rangeSection = self.Tab:Section({ 
        Title = "Range", 
        Icon = "maximize",
        Opened = true 
    })

    rangeSection:Slider({
        Title = "Max Distance",
        Description = "Maximum ESP render distance",
        Min = 100,
        Max = 5000,
        Step = 100,
        Value = ESP.Settings.MaxDistance,
        Suffix = " studs",
        Callback = function(value)
            ESP.Settings.MaxDistance = value
            if self.Flags then self.Flags:Set("ESP_MaxDistance", value) end
        end
    })
end

function ESP:StartLoop()
    task.spawn(function()
        while true do
            if ESP.Settings.Enabled then
                self:UpdateESP()
            end
            task.wait(1 / ESP.Settings.UpdateRate)
        end
    end)
end

function ESP:UpdateESP()
    local myPos = Camera.CFrame.Position

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local character = player.Character
        if not character then
            self:ClearPlayer(player)
            continue
        end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        local head = character:FindFirstChild("Head")
        
        if not humanoidRootPart or not humanoid or not head then
            self:ClearPlayer(player)
            continue
        end
        
        local distance = (myPos - humanoidRootPart.Position).Magnitude
        if distance > ESP.Settings.MaxDistance then
            self:ClearPlayer(player)
            continue
        end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
        
        if onScreen then
            self:DrawPlayer(player, humanoidRootPart, head, humanoid, screenPos, distance)
        else
            self:ClearPlayer(player)
        end
    end
    
    -- Clean up players who left
    for player, _ in pairs(ESP.Objects) do
        if not player.Parent then
            self:ClearPlayer(player)
        end
    end
end

function ESP:DrawPlayer(player, rootPart, head, humanoid, screenPos, distance)
    -- Create or get drawing objects
    if not ESP.Objects[player] then
        ESP.Objects[player] = {
            Box = Drawing.new("Square"),
            NameTag = Drawing.new("Text"),
            DistanceTag = Drawing.new("Text"),
            HealthBar = Drawing.new("Square"),
            HealthFill = Drawing.new("Square"),
            Tracer = Drawing.new("Line"),
        }
    end
    
    local obj = ESP.Objects[player]
    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    local legPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
    local boxHeight = math.abs(headPos.Y - legPos.Y)
    local boxWidth = boxHeight * 0.65
    local boxX = screenPos.X - boxWidth / 2
    local boxY = screenPos.Y - boxHeight / 2
    
    -- Box
    if ESP.Settings.Boxes then
        obj.Box.Visible = true
        obj.Box.Color = ESP.Settings.Color
        obj.Box.Thickness = 1.5
        obj.Box.Filled = false
        obj.Box.Size = Vector2.new(boxWidth, boxHeight)
        obj.Box.Position = Vector2.new(boxX, boxY)
    else
        obj.Box.Visible = false
    end
    
    -- Name
    if ESP.Settings.Names then
        obj.NameTag.Visible = true
        obj.NameTag.Text = player.Name
        obj.NameTag.Color = ESP.Settings.Color
        obj.NameTag.Size = 14
        obj.NameTag.Center = true
        obj.NameTag.Outline = true
        obj.NameTag.Position = Vector2.new(screenPos.X, boxY - 16)
    else
        obj.NameTag.Visible = false
    end
    
    -- Distance
    if ESP.Settings.Distance then
        obj.DistanceTag.Visible = true
        obj.DistanceTag.Text = math.floor(distance) .. "m"
        obj.DistanceTag.Color = ESP.Settings.Color
        obj.DistanceTag.Size = 14
        obj.DistanceTag.Center = true
        obj.DistanceTag.Outline = true
        obj.DistanceTag.Position = Vector2.new(screenPos.X, boxY + boxHeight + 4)
    else
        obj.DistanceTag.Visible = false
    end
    
    -- Health
    if ESP.Settings.Health and humanoid then
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        local barWidth = 3
        local barHeight = boxHeight
        local barX = boxX - barWidth - 2
        local barY = boxY
        
        obj.HealthBar.Visible = true
        obj.HealthBar.Color = Color3.fromRGB(50, 50, 50)
        obj.HealthBar.Filled = true
        obj.HealthBar.Size = Vector2.new(barWidth, barHeight)
        obj.HealthBar.Position = Vector2.new(barX, barY)
        
        local healthColor = healthPercent > 0.5 and Color3.fromRGB(50, 200, 50) 
            or healthPercent > 0.25 and Color3.fromRGB(255, 170, 0) 
            or Color3.fromRGB(255, 50, 50)
        
        obj.HealthFill.Visible = true
        obj.HealthFill.Color = healthColor
        obj.HealthFill.Filled = true
        obj.HealthFill.Size = Vector2.new(barWidth, barHeight * healthPercent)
        obj.HealthFill.Position = Vector2.new(barX, barY + barHeight * (1 - healthPercent))
    else
        obj.HealthBar.Visible = false
        obj.HealthFill.Visible = false
    end
    
    -- Tracers
    if ESP.Settings.Tracers then
        local viewportSize = Camera.ViewportSize
        local tracerOrigin = Vector2.new(viewportSize.X / 2, viewportSize.Y)
        
        obj.Tracer.Visible = true
        obj.Tracer.Color = ESP.Settings.Color
        obj.Tracer.Thickness = 1
        obj.Tracer.From = tracerOrigin
        obj.Tracer.To = Vector2.new(screenPos.X, boxY + boxHeight)
    else
        obj.Tracer.Visible = false
    end
end

function ESP:ClearPlayer(player)
    if ESP.Objects[player] then
        for _, obj in pairs(ESP.Objects[player]) do
            pcall(function() obj:Remove() end)
        end
        ESP.Objects[player] = nil
    end
end

function ESP:ClearAll()
    for player, _ in pairs(ESP.Objects) do
        self:ClearPlayer(player)
    end
end

return ESP
