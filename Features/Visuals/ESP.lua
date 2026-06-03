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
}

function ESP:Init(tab, library, flags)
    local self = setmetatable({}, ESP)
    self.Tab = tab
    self.Library = library
    self.Flags = flags
    self.Container = nil
    self.Highlights = {}
    self.Connection = nil

    self:BuildUI()
    return self
end

function ESP:BuildUI()
    if not self.Tab then return end

    local section = self.Tab:Section({ 
        Title = "ESP Settings", 
        Icon = "eye",
        Opened = true 
    })

    section:Toggle({
        Title = "Enable ESP",
        Description = "Show players through walls",
        Value = false,
        Callback = function(state)
            ESP.Settings.Enabled = state
            if state then
                self:StartESP()
            else
                self:StopESP()
            end
        end
    })

    section:ColorPicker({
        Title = "ESP Color",
        Description = "Choose highlight color",
        Default = ESP.Settings.Color,
        Callback = function(color)
            ESP.Settings.Color = color
            self:UpdateAllColors()
        end
    })
end

function ESP:StartESP()
    if self.Connection then return end
    
    self.Connection = RunService.Heartbeat:Connect(function()
        self:Update()
    end)
    
    if self.Library then
        self.Library:Notify({ Title = "ESP", Description = "ESP Started!", Duration = 2 })
    end
end

function ESP:StopESP()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    self:ClearAll()
    
    if self.Library then
        self.Library:Notify({ Title = "ESP", Description = "ESP Stopped!", Duration = 2 })
    end
end

function ESP:Update()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then
            self:RemoveHighlight(player)
            continue
        end
        
        local char = player.Character
        if not char then
            self:RemoveHighlight(player)
            continue
        end
        
        -- Apply highlight
        if not self.Highlights[player] then
            local hl = Instance.new("Highlight")
            hl.Name = "HyperESP"
            hl.FillTransparency = 0.7
            hl.OutlineTransparency = 0.3
            hl.OutlineColor = ESP.Settings.Color
            hl.FillColor = ESP.Settings.Color
            hl.Parent = char
            self.Highlights[player] = hl
        else
            local hl = self.Highlights[player]
            if hl.Parent ~= char then
                hl.Parent = char
            end
            hl.OutlineColor = ESP.Settings.Color
            hl.FillColor = ESP.Settings.Color
        end
    end
    
    -- Remove highlights for disconnected players
    for player, hl in pairs(self.Highlights) do
        if not player.Parent or not player.Character then
            self:RemoveHighlight(player)
        end
    end
end

function ESP:UpdateAllColors()
    for _, hl in pairs(self.Highlights) do
        hl.OutlineColor = ESP.Settings.Color
        hl.FillColor = ESP.Settings.Color
    end
end

function ESP:RemoveHighlight(player)
    if self.Highlights[player] then
        pcall(function() self.Highlights[player]:Destroy() end)
        self.Highlights[player] = nil
    end
end

function ESP:ClearAll()
    for player in pairs(self.Highlights) do
        self:RemoveHighlight(player)
    end
    self.Highlights = {}
end

return ESP
