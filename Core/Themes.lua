--[[
    ╔══════════════════════════════════════════════════╗
    ║           HYPER UI - Themes System               ║
    ║              Version: v1.0.0                      ║
    ║         By M4X | EVA | AMAL                      ║
    ╚══════════════════════════════════════════════════╝
    
    Complete theme management system
    with built-in themes and theme switching.
--]]

local Themes = {}
Themes.__index = Themes

-- =============================================
-- BUILT-IN THEMES
-- =============================================
Themes.List = {
    Default = {
        Name = "Default",
        Description = "Clean dark blue theme",
        Primary = Color3.fromRGB(0, 120, 255),
        Secondary = Color3.fromRGB(100, 100, 255),
        Background = Color3.fromRGB(20, 20, 20),
        Panel = Color3.fromRGB(30, 30, 30),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(180, 180, 180),
        Accent = Color3.fromRGB(0, 170, 255),
        Success = Color3.fromRGB(50, 200, 50),
        Danger = Color3.fromRGB(255, 50, 50),
        Warning = Color3.fromRGB(255, 170, 0),
        Border = Color3.fromRGB(60, 60, 60),
    },
    
    Dark = {
        Name = "Dark",
        Description = "Deep dark theme",
        Primary = Color3.fromRGB(80, 80, 255),
        Secondary = Color3.fromRGB(60, 60, 200),
        Background = Color3.fromRGB(10, 10, 10),
        Panel = Color3.fromRGB(18, 18, 18),
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(160, 160, 160),
        Accent = Color3.fromRGB(100, 100, 255),
        Success = Color3.fromRGB(40, 180, 40),
        Danger = Color3.fromRGB(220, 40, 40),
        Warning = Color3.fromRGB(220, 150, 0),
        Border = Color3.fromRGB(50, 50, 50),
    },
    
    Light = {
        Name = "Light",
        Description = "Bright clean theme",
        Primary = Color3.fromRGB(0, 100, 220),
        Secondary = Color3.fromRGB(80, 80, 200),
        Background = Color3.fromRGB(240, 240, 245),
        Panel = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(20, 20, 20),
        SubText = Color3.fromRGB(100, 100, 100),
        Accent = Color3.fromRGB(0, 120, 255),
        Success = Color3.fromRGB(40, 180, 40),
        Danger = Color3.fromRGB(220, 40, 40),
        Warning = Color3.fromRGB(220, 150, 0),
        Border = Color3.fromRGB(200, 200, 200),
    },
    
    Red = {
        Name = "Red",
        Description = "Aggressive red theme",
        Primary = Color3.fromRGB(220, 40, 40),
        Secondary = Color3.fromRGB(180, 30, 30),
        Background = Color3.fromRGB(15, 5, 5),
        Panel = Color3.fromRGB(25, 10, 10),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(200, 150, 150),
        Accent = Color3.fromRGB(255, 60, 60),
        Success = Color3.fromRGB(50, 200, 50),
        Danger = Color3.fromRGB(255, 30, 30),
        Warning = Color3.fromRGB(255, 170, 0),
        Border = Color3.fromRGB(80, 30, 30),
    },
    
    Midnight = {
        Name = "Midnight",
        Description = "Purple midnight theme",
        Primary = Color3.fromRGB(100, 60, 255),
        Secondary = Color3.fromRGB(70, 40, 200),
        Background = Color3.fromRGB(8, 5, 20),
        Panel = Color3.fromRGB(15, 10, 30),
        Text = Color3.fromRGB(230, 220, 255),
        SubText = Color3.fromRGB(150, 140, 180),
        Accent = Color3.fromRGB(130, 90, 255),
        Success = Color3.fromRGB(50, 200, 100),
        Danger = Color3.fromRGB(255, 60, 60),
        Warning = Color3.fromRGB(255, 180, 30),
        Border = Color3.fromRGB(60, 40, 100),
    },
    
    Green = {
        Name = "Green",
        Description = "Nature green theme",
        Primary = Color3.fromRGB(40, 180, 40),
        Secondary = Color3.fromRGB(30, 140, 30),
        Background = Color3.fromRGB(5, 15, 5),
        Panel = Color3.fromRGB(10, 25, 10),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(150, 200, 150),
        Accent = Color3.fromRGB(60, 255, 60),
        Success = Color3.fromRGB(50, 200, 50),
        Danger = Color3.fromRGB(255, 50, 50),
        Warning = Color3.fromRGB(255, 170, 0),
        Border = Color3.fromRGB(30, 80, 30),
    },
    
    Ocean = {
        Name = "Ocean",
        Description = "Deep ocean blue theme",
        Primary = Color3.fromRGB(0, 150, 200),
        Secondary = Color3.fromRGB(0, 100, 150),
        Background = Color3.fromRGB(5, 10, 20),
        Panel = Color3.fromRGB(10, 18, 30),
        Text = Color3.fromRGB(220, 240, 255),
        SubText = Color3.fromRGB(140, 180, 200),
        Accent = Color3.fromRGB(0, 200, 255),
        Success = Color3.fromRGB(50, 200, 100),
        Danger = Color3.fromRGB(255, 60, 60),
        Warning = Color3.fromRGB(255, 180, 30),
        Border = Color3.fromRGB(30, 60, 100),
    },
}

-- =============================================
-- CURRENT THEME
-- =============================================
Themes.Current = nil
Themes.CurrentName = "Default"

-- =============================================
-- THEME FUNCTIONS
-- =============================================
function Themes:Init(tab, library, flags)
    local self = setmetatable({}, Themes)
    self.Tab = tab
    self.Library = library
    self.Flags = flags
    
    -- Set default theme if not set
    if not Themes.Current then
        Themes.Current = Themes.List.Default
        Themes.CurrentName = "Default"
    end
    
    -- Register flag
    if flags then
        flags:Create("CurrentTheme", Themes.CurrentName)
    end
    
    -- Build UI
    self:BuildUI()
    
    return self
end

function Themes:BuildUI()
    if not self.Tab then return end
    
    local section = self.Tab:Section({ 
        Title = "Theme Settings", 
        Icon = "palette",
        Opened = true 
    })
    
    -- Current theme label
    self.Tab:Label({ 
        Title = "Current Theme: " .. Themes.CurrentName 
    })
    
    -- Theme description
    if Themes.Current and Themes.Current.Description then
        self.Tab:Label({ 
            Title = "Description: " .. Themes.Current.Description 
        })
    end
    
    -- Theme selector dropdown
    local themeNames = self:GetThemeList()
    
    section:Dropdown({
        Title = "Select Theme",
        Description = "Choose your preferred theme",
        Values = themeNames,
        Value = Themes.CurrentName,
        Callback = function(selected)
            self:SetTheme(selected)
        end
    })
    
    -- Individual theme buttons
    local buttonsSection = self.Tab:Section({ 
        Title = "Quick Theme Switch", 
        Icon = "zap",
        Opened = false 
    })
    
    for name, theme in pairs(Themes.List) do
        buttonsSection:Button({
            Title = theme.Name .. " Theme",
            Description = theme.Description or "",
            Callback = function()
                self:SetTheme(name)
            end
        })
    end
    
    -- Theme info section
    local infoSection = self.Tab:Section({ 
        Title = "Theme Colors Preview", 
        Icon = "eye",
        Opened = false 
    })
    
    if Themes.Current then
        infoSection:Label({ Title = "Primary: " .. self:ColorToHex(Themes.Current.Primary) })
        infoSection:Label({ Title = "Secondary: " .. self:ColorToHex(Themes.Current.Secondary) })
        infoSection:Label({ Title = "Background: " .. self:ColorToHex(Themes.Current.Background) })
        infoSection:Label({ Title = "Accent: " .. self:ColorToHex(Themes.Current.Accent) })
        infoSection:Label({ Title = "Text: " .. self:ColorToHex(Themes.Current.Text) })
        infoSection:Label({ Title = "Success: " .. self:ColorToHex(Themes.Current.Success) })
        infoSection:Label({ Title = "Danger: " .. self:ColorToHex(Themes.Current.Danger) })
        infoSection:Label({ Title = "Warning: " .. self:ColorToHex(Themes.Current.Warning) })
    end
end

function Themes:SetTheme(name)
    local theme = Themes.List[name]
    if not theme then
        if self.Library then
            self.Library:Notify({ 
                Title = "Theme Error", 
                Description = "Theme '" .. name .. "' not found!", 
                Duration = 3 
            })
        end
        return false
    end
    
    Themes.Current = theme
    Themes.CurrentName = name
    
    -- Update flag
    if self.Flags then
        self.Flags:Set("CurrentTheme", name)
    end
    
    -- Notify
    if self.Library then
        self.Library:Notify({ 
            Title = "Theme Changed", 
            Description = "Switched to " .. theme.Name .. " theme!", 
            Duration = 3 
        })
    end
    
    print("[Hyper] [Themes] Switched to: " .. theme.Name)
    
    -- Refresh UI if needed
    pcall(function()
        if self.Library and self.Library.RefreshTheme then
            self.Library:RefreshTheme(theme)
        end
    end)
    
    return true
end

function Themes:GetTheme(name)
    return Themes.List[name or Themes.CurrentName] or Themes.List.Default
end

function Themes:GetCurrentTheme()
    return Themes.Current or Themes.List.Default
end

function Themes:GetThemeList()
    local list = {}
    for name, _ in pairs(Themes.List) do
        table.insert(list, name)
    end
    table.sort(list)
    return list
end

function Themes:GetColor(colorName)
    local theme = Themes.Current or Themes.List.Default
    return theme[colorName] or Color3.fromRGB(255, 255, 255)
end

function Themes:CreateCustomTheme(name, colors)
    if not name or type(name) ~= "string" then return false end
    if not colors or type(colors) ~= "table" then return false end
    
    Themes.List[name] = {
        Name = name,
        Description = colors.Description or "Custom theme",
        Primary = colors.Primary or Color3.fromRGB(0, 120, 255),
        Secondary = colors.Secondary or Color3.fromRGB(100, 100, 255),
        Background = colors.Background or Color3.fromRGB(20, 20, 20),
        Panel = colors.Panel or Color3.fromRGB(30, 30, 30),
        Text = colors.Text or Color3.fromRGB(255, 255, 255),
        SubText = colors.SubText or Color3.fromRGB(180, 180, 180),
        Accent = colors.Accent or Color3.fromRGB(0, 170, 255),
        Success = colors.Success or Color3.fromRGB(50, 200, 50),
        Danger = colors.Danger or Color3.fromRGB(255, 50, 50),
        Warning = colors.Warning or Color3.fromRGB(255, 170, 0),
        Border = colors.Border or Color3.fromRGB(60, 60, 60),
    }
    
    return true
end

function Themes:DeleteTheme(name)
    if name == "Default" then return false end
    if Themes.List[name] then
        Themes.List[name] = nil
        
        if Themes.CurrentName == name then
            self:SetTheme("Default")
        end
        
        return true
    end
    return false
end

function Themes:ColorToHex(color)
    if not color then return "#FFFFFF" end
    local r = math.floor(color.R * 255 + 0.5)
    local g = math.floor(color.G * 255 + 0.5)
    local b = math.floor(color.B * 255 + 0.5)
    return string.format("#%02X%02X%02X", r, g, b)
end

function Themes:HexToColor(hex)
    hex = hex:gsub("#", "")
    local r = tonumber("0x" .. hex:sub(1, 2)) / 255
    local g = tonumber("0x" .. hex:sub(3, 4)) / 255
    local b = tonumber("0x" .. hex:sub(5, 6)) / 255
    return Color3.fromRGB(r * 255, g * 255, b * 255)
end

-- =============================================
-- RETURN
-- =============================================
return Themes
