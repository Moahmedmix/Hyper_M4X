--[[
    ╔══════════════════════════════════════════════════╗
    ║           HYPER UI - Themes System               ║
    ║              Version: v1.0.0                      ║
    ║         By M4X | EVA | AMAL                      ║
    ╚══════════════════════════════════════════════════╝
    
    Complete theme management system
    with full WindUI theme switching.
--]]

local Themes = {}
Themes.__index = Themes

-- =============================================
-- AVAILABLE WIND UI THEMES
-- =============================================
Themes.List = {
    "Default",
    "Dark",
    "Light",
    "Red",
    "Crimson",
    "Midnight",
    "Ocean",
    "Green",
    "Purple",
    "Sunset",
    "Forest",
    "Arctic",
    "Neon",
    "Gold",
    "Rose",
}

-- Current theme
Themes.CurrentName = "Dark"

-- Theme display names and descriptions
Themes.Descriptions = {
    Default  = "Clean blue theme",
    Dark     = "Deep dark theme",
    Light    = "Bright white theme",
    Red      = "Aggressive red theme",
    Crimson  = "Blood red theme",
    Midnight = "Purple midnight theme",
    Ocean    = "Deep ocean blue",
    Green    = "Nature green theme",
    Purple   = "Royal purple theme",
    Sunset   = "Orange sunset theme",
    Forest   = "Dark forest green",
    Arctic   = "Ice cold blue",
    Neon     = "Bright neon lights",
    Gold     = "Golden luxury theme",
    Rose     = "Soft rose pink",
}

function Themes:Init(tab, library, flags)
    local self = setmetatable({}, Themes)
    self.Tab = tab
    self.Library = library
    self.Flags = flags
    
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
    
    -- Current theme display
    local infoSection = self.Tab:Section({ 
        Title = "Theme Information", 
        Icon = "info",
        Opened = true 
    })
    
    infoSection:Label({ 
        Title = "Current Theme: " .. Themes.CurrentName 
    })
    
    infoSection:Label({ 
        Title = "Description: " .. (Themes.Descriptions[Themes.CurrentName] or "No description") 
    })
    
    -- Theme selector dropdown
    local selectSection = self.Tab:Section({ 
        Title = "Select Theme", 
        Icon = "palette",
        Opened = true 
    })
    
    selectSection:Dropdown({
        Title = "Choose Theme",
        Description = "Select your preferred theme",
        Values = Themes.List,
        Value = Themes.CurrentName,
        Callback = function(selected)
            self:ApplyTheme(selected)
        end
    })
    
    -- Quick theme buttons
    local quickSection = self.Tab:Section({ 
        Title = "Quick Switch", 
        Icon = "zap",
        Opened = false 
    })
    
    for _, name in ipairs({"Dark", "Light", "Default", "Red", "Midnight", "Ocean", "Green", "Sunset"}) do
        quickSection:Button({
            Title = name .. " Theme",
            Description = Themes.Descriptions[name] or "",
            Callback = function()
                self:ApplyTheme(name)
            end
        })
    end
    
    -- More themes
    local moreSection = self.Tab:Section({ 
        Title = "More Themes", 
        Icon = "plus-circle",
        Opened = false 
    })
    
    for _, name in ipairs({"Crimson", "Purple", "Forest", "Arctic", "Neon", "Gold", "Rose"}) do
        moreSection:Button({
            Title = name .. " Theme",
            Description = Themes.Descriptions[name] or "",
            Callback = function()
                self:ApplyTheme(name)
            end
        })
    end
end

function Themes:ApplyTheme(name)
    -- Check if theme exists
    local found = false
    for _, t in ipairs(Themes.List) do
        if t == name then
            found = true
            break
        end
    end
    
    if not found then
        if self.Library then
            self.Library:Notify({ 
                Title = "Theme Error", 
                Description = "Theme '" .. name .. "' not found!", 
                Duration = 3 
            })
        end
        return false
    end
    
    -- Apply theme using WindUI
    local success, err = pcall(function()
        WindUI:SetTheme(name)
    end)
    
    if success then
        Themes.CurrentName = name
        
        -- Update flag
        if self.Flags then
            self.Flags:Set("CurrentTheme", name)
        end
        
        -- Notify
        if self.Library then
            self.Library:Notify({ 
                Title = "Theme Changed", 
                Description = "Switched to " .. name .. " theme!", 
                Duration = 3 
            })
        end
        
        print("[Hyper] [Themes] Applied: " .. name)
        return true
    else
        if self.Library then
            self.Library:Notify({ 
                Title = "Theme Error", 
                Description = "Failed to apply theme: " .. tostring(err), 
                Duration = 3 
            })
        end
        return false
    end
end

function Themes:GetCurrentTheme()
    return Themes.CurrentName
end

function Themes:GetThemeList()
    return Themes.List
end

return Themes
