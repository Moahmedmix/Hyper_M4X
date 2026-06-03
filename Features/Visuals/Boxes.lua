--[[
    ╔══════════════════════════════════════════════════╗
    ║           HYPER UI - Boxes System                ║
    ║              Version: v1.0.0                      ║
    ║         By M4X | EVA | AMAL                      ║
    ╚══════════════════════════════════════════════════╝
--]]

local Boxes = {}
Boxes.__index = Boxes

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

Boxes.Objects = {}
Boxes.Settings = {
    Enabled = false,
    BoxType = "2D",
    Thickness = 1.5,
    Color = Color3.fromRGB(255, 255, 255),
    TeamColor = false,
    TeamCheck = false,
    MaxDistance = 1000,
    Filled = false,
    FillTransparency = 0.3,
    Outline = false,
    OutlineColor = Color3.fromRGB(0, 0, 0),
}

local BoxTypes = {"2D", "Corner", "3D"}

function Boxes:Init(tab, library, flags)
    local self = setmetatable({}, Boxes)
    self.Tab = tab
    self.Library = library
    self.Flags = flags

    if flags then
        flags:Create("Boxes_Enabled", false)
        flags:Create("Boxes_BoxType", "2D")
        flags:Create("Boxes_Thickness", 1.5)
        flags:Create("Boxes_TeamColor", false)
        flags:Create("Boxes_TeamCheck", false)
        flags:Create("Boxes_MaxDistance", 1000)
        flags:Create("Boxes_Filled", false)
        flags:Create("Boxes_Outline", false)
    end

    self:BuildUI()
    self:StartLoop()
    return self
end

function Boxes:BuildUI()
    if not self.Tab then return end

    local mainSection = self.Tab:Section({ 
        Title = "Boxes Settings", 
        Icon = "square",
        Opened = true 
    })

    mainSection:Toggle({
        Title = "Enable Boxes",
        Description = "Show boxes around players",
        Value = false,
        Callback = function(state)
            Boxes.Settings.Enabled = state
            if self.Flags then self.Flags:Set("Boxes_Enabled", state) end
            if not state then self:ClearAll() end
        end
    })

    mainSection:Dropdown({
        Title = "Box Type",
        Description = "Choose box style",
        Values = BoxTypes,
        Value = "2D",
        Callback = function(option)
            Boxes.Settings.BoxType = option
            if self.Flags then self.Flags:Set("Boxes_BoxType", option) end
        end
    })

    local styleSection = self.Tab:Section({ 
        Title = "Style", 
        Icon = "paintbrush",
        Opened = true 
    })

    styleSection:Slider({
        Title = "Thickness",
        Description = "Box line thickness",
        Min = 1,
        Max = 5,
        Step = 0.5,
        Value = 1.5,
        Suffix = "px",
        Callback = function(value)
            Boxes.Settings.Thickness = value
            if self.Flags then self.Flags:Set("Boxes_Thickness", value) end
        end
    })

    styleSection:Toggle({
        Title = "Filled Box",
        Description = "Fill the box with color",
        Value = false,
        Callback = function(state)
            Boxes.Settings.Filled = state
            if self.Flags then self.Flags:Set("Boxes_Filled", state) end
        end
    })

    styleSection:Toggle({
        Title = "Outline",
        Description = "Add black outline to box",
        Value = false,
        Callback = function(state)
            Boxes.Settings.Outline = state
            if self.Flags then self.Flags:Set("Boxes_Outline", state) end
        end
    })

    local colorSection = self.Tab:Section({ 
        Title = "Colors", 
        Icon = "palette",
        Opened = true 
    })

    colorSection:ColorPicker({
        Title = "Box Color",
        Description = "Choose box color",
        Default = Boxes.Settings.Color,
        Callback = function(color)
            Boxes.Settings.Color = color
        end
    })

    colorSection:Toggle({
        Title = "Team Color",
        Description = "Use player's team color",
        Value = false,
        Callback = function(state)
            Boxes.Settings.TeamColor = state
            if self.Flags then self.Flags:Set("Boxes_TeamColor", state) end
        end
    })

    local filterSection = self.Tab:Section({ 
        Title = "Filters", 
        Icon = "filter",
        Opened = true 
    })

    filterSection:Toggle({
        Title = "Team Check",
        Description = "Don't show boxes for teammates",
        Value = false,
        Callback = function(state)
            Boxes.Settings.TeamCheck = state
            if self.Flags then self.Flags:Set("Boxes_TeamCheck", state) end
        end
    })

    filterSection:Slider({
        Title = "Max Distance",
        Description = "Maximum render distance",
        Min = 100,
        Max = 5000,
        Step = 100,
        Value = Boxes.Settings.MaxDistance,
        Suffix = " studs",
        Callback = function(value)
            Boxes.Settings.MaxDistance = value
            if self.Flags then self.Flags:Set("Boxes_MaxDistance", value) end
        end
    })
end

function Boxes:StartLoop()
    task.spawn(function()
        while true do
            if Boxes.Settings.Enabled then
                self:UpdateBoxes()
            end
            task.wait(1 / 60)
        end
    end)
end

function Boxes:GetPlayerColor(player)
    if Boxes.Settings.TeamColor and player.Team then
        return player.Team.TeamColor.Color
    end
    return Boxes.Settings.Color
end

function Boxes:ShouldDraw(player)
    if player == LocalPlayer then return false end
    if not player.Character then return false end
    
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    
    local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
    if distance > Boxes.Settings.MaxDistance then return false end
    
    if Boxes.Settings.TeamCheck and player.Team == LocalPlayer.Team then
        return false
    end
    
    return true
end

function Boxes:UpdateBoxes()
    for _, player in ipairs(Players:GetPlayers()) do
        if not self:ShouldDraw(player) then
            self:ClearPlayer(player)
            continue
        end
        
        local character = player.Character
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")
        
        if not rootPart or not head then
            self:ClearPlayer(player)
            continue
        end
        
        local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local legPos, legOnScreen = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3.5, 0))
        
        if not headOnScreen and not legOnScreen then
            self:ClearPlayer(player)
            continue
        end
        
        local color = self:GetPlayerColor(player)
        self:DrawBox(player, headPos, legPos, color)
    end
    
    -- Cleanup
    for player, _ in pairs(Boxes.Objects) do
        if not player.Parent or not self:ShouldDraw(player) then
            self:ClearPlayer(player)
        end
    end
end

function Boxes:DrawBox(player, headPos, legPos, color)
    if not Boxes.Objects[player] then
        Boxes.Objects[player] = {}
        local obj = Boxes.Objects[player]
        
        if Boxes.Settings.BoxType == "2D" then
            obj.Main = Drawing.new("Square")
            if Boxes.Settings.Filled then
                obj.Fill = Drawing.new("Square")
            end
            if Boxes.Settings.Outline then
                obj.OutlineBox = Drawing.new("Square")
            end
        elseif Boxes.Settings.BoxType == "Corner" then
            obj.TopLeft = Drawing.new("Line")
            obj.TopRight = Drawing.new("Line")
            obj.BottomLeft = Drawing.new("Line")
            obj.BottomRight = Drawing.new("Line")
        elseif Boxes.Settings.BoxType == "3D" then
            obj.Main = Drawing.new("Square")
        end
    end
    
    local obj = Boxes.Objects[player]
    local height = math.abs(headPos.Y - legPos.Y)
    local width = height * 0.65
    local x = headPos.X - width / 2
    local y = headPos.Y
    
    local boxType = Boxes.Settings.BoxType
    local thickness = Boxes.Settings.Thickness
    
    if boxType == "2D" then
        if obj.Main then
            obj.Main.Visible = true
            obj.Main.Color = color
            obj.Main.Thickness = thickness
            obj.Main.Filled = false
            obj.Main.Size = Vector2.new(width, height)
            obj.Main.Position = Vector2.new(x, y)
        end
        
        if obj.Fill then
            obj.Fill.Visible = Boxes.Settings.Filled
            obj.Fill.Color = color
            obj.Fill.Filled = true
            obj.Fill.Transparency = Boxes.Settings.FillTransparency
            obj.Fill.Size = Vector2.new(width, height)
            obj.Fill.Position = Vector2.new(x, y)
        end
        
        if obj.OutlineBox and Boxes.Settings.Outline then
            obj.OutlineBox.Visible = true
            obj.OutlineBox.Color = Boxes.Settings.OutlineColor
            obj.OutlineBox.Thickness = thickness + 2
            obj.OutlineBox.Filled = false
            obj.OutlineBox.Size = Vector2.new(width, height)
            obj.OutlineBox.Position = Vector2.new(x, y)
        end
        
    elseif boxType == "Corner" then
        local cornerLength = height * 0.25
        local cornerThickness = thickness + 1
        
        -- Top Left
        obj.TopLeft.Visible = true
        obj.TopLeft.Color = color
        obj.TopLeft.Thickness = cornerThickness
        obj.TopLeft.From = Vector2.new(x, y + cornerLength)
        obj.TopLeft.To = Vector2.new(x, y)
        
        -- Top Right
        obj.TopRight.Visible = true
        obj.TopRight.Color = color
        obj.TopRight.Thickness = cornerThickness
        obj.TopRight.From = Vector2.new(x + width, y)
        obj.TopRight.To = Vector2.new(x + width, y + cornerLength)
        
        -- Bottom Left
        obj.BottomLeft.Visible = true
        obj.BottomLeft.Color = color
        obj.BottomLeft.Thickness = cornerThickness
        obj.BottomLeft.From = Vector2.new(x, y + height - cornerLength)
        obj.BottomLeft.To = Vector2.new(x, y + height)
        
        -- Bottom Right
        obj.BottomRight.Visible = true
        obj.BottomRight.Color = color
        obj.BottomRight.Thickness = cornerThickness
        obj.BottomRight.From = Vector2.new(x + width, y + height)
        obj.BottomRight.To = Vector2.new(x + width, y + height - cornerLength)
        
        -- Hide main box if exists
        if obj.Main then obj.Main.Visible = false end
        if obj.Fill then obj.Fill.Visible = false end
        if obj.OutlineBox then obj.OutlineBox.Visible = false end
    end
end

function Boxes:ClearPlayer(player)
    if Boxes.Objects[player] then
        for _, obj in pairs(Boxes.Objects[player]) do
            pcall(function() obj:Remove() end)
        end
        Boxes.Objects[player] = nil
    end
end

function Boxes:ClearAll()
    for player, _ in pairs(Boxes.Objects) do
        self:ClearPlayer(player)
    end
end

return Boxes
