--[[
    ╔══════════════════════════════════════════════════╗
    ║           HYPER UI - UI Settings                 ║
    ║              Version: v1.0.0                      ║
    ║         By M4X | EVA | AMAL                      ║
    ╚══════════════════════════════════════════════════╝
    
    UI Settings Module - Controls window behavior
    ToggleKey, transparency, resizable, etc.
--]]

local Settings = {}
Settings.__index = Settings

-- Default settings
Settings.Defaults = {
    ToggleKey = "RightShift",
    Transparent = false,
    Resizable = true,
    ScrollBarEnabled = true,
    HideSearchBar = true,
    SideBarWidth = 190,
    Theme = "Dark",
}

-- Current settings
Settings.Current = {}

function Settings:Init(tab, library, flags)
    local self = setmetatable({}, Settings)
    self.Tab = tab
    self.Library = library
    self.Flags = flags
    
    -- Load defaults
    for k, v in pairs(Settings.Defaults) do
        if not Settings.Current[k] then
            Settings.Current[k] = v
        end
    end
    
    -- Register flags
    if flags then
        flags:Create("UITransparent", Settings.Current.Transparent or false)
        flags:Create("UIResizable", Settings.Current.Resizable or true)
        flags:Create("UIScrollBar", Settings.Current.ScrollBarEnabled or true)
        flags:Create("UIHideSearch", Settings.Current.HideSearchBar or true)
        flags:Create("UISideBarWidth", Settings.Current.SideBarWidth or 190)
    end
    
    -- Build UI
    self:BuildUI()
    
    return self
end

function Settings:BuildUI()
    if not self.Tab then return end
    
    local section = self.Tab:Section({ 
        Title = "UI Settings", 
        Icon = "settings",
        Opened = true 
    })
    
    -- ToggleKey display (informational)
    self.Tab:Label({ 
        Title = "Toggle Key: Right Shift" 
    })
    
    -- Transparency toggle
    section:Toggle({
        Title = "Transparent Background",
        Description = "Make the window background transparent",
        Value = Settings.Current.Transparent or false,
        Callback = function(state)
            Settings.Current.Transparent = state
            if self.Flags then self.Flags:Set("UITransparent", state) end
            self.Library:Notify({ 
                Title = "UI Settings", 
                Description = "Transparency: " .. (state and "ON" or "OFF"), 
                Duration = 2 
            })
        end
    })
    
    -- Resizable toggle
    section:Toggle({
        Title = "Resizable Window",
        Description = "Allow window resizing",
        Value = Settings.Current.Resizable or true,
        Callback = function(state)
            Settings.Current.Resizable = state
            if self.Flags then self.Flags:Set("UIResizable", state) end
            self.Library:Notify({ 
                Title = "UI Settings", 
                Description = "Resizable: " .. (state and "ON" or "OFF"), 
                Duration = 2 
            })
        end
    })
    
    -- Scrollbar toggle
    section:Toggle({
        Title = "Scroll Bar",
        Description = "Show scrollbar in tabs",
        Value = Settings.Current.ScrollBarEnabled or true,
        Callback = function(state)
            Settings.Current.ScrollBarEnabled = state
            if self.Flags then self.Flags:Set("UIScrollBar", state) end
            self.Library:Notify({ 
                Title = "UI Settings", 
                Description = "Scrollbar: " .. (state and "ON" or "OFF"), 
                Duration = 2 
            })
        end
    })
    
    -- Hide search bar toggle
    section:Toggle({
        Title = "Hide Search Bar",
        Description = "Hide the tab search bar",
        Value = Settings.Current.HideSearchBar or true,
        Callback = function(state)
            Settings.Current.HideSearchBar = state
            if self.Flags then self.Flags:Set("UIHideSearch", state) end
            self.Library:Notify({ 
                Title = "UI Settings", 
                Description = "Search Bar: " .. (state and "Hidden" or "Visible"), 
                Duration = 2 
            })
        end
    })
    
    -- Sidebar width slider
    section:Slider({
        Title = "Sidebar Width",
        Description = "Adjust the sidebar width",
        Min = 150,
        Max = 300,
        Step = 5,
        Value = Settings.Current.SideBarWidth or 190,
        Suffix = "px",
        Callback = function(value)
            Settings.Current.SideBarWidth = value
            if self.Flags then self.Flags:Set("UISideBarWidth", value) end
        end
    })
    
    -- Reset to defaults button
    local resetSection = self.Tab:Section({ 
        Title = "Reset", 
        Icon = "rotate-ccw",
        Opened = false 
    })
    
    resetSection:Button({
        Title = "Reset UI Settings",
        Description = "Restore all settings to default",
        Callback = function()
            for k, v in pairs(Settings.Defaults) do
                Settings.Current[k] = v
            end
            self.Library:Notify({ 
                Title = "UI Settings", 
                Description = "All settings reset to default!", 
                Duration = 3 
            })
        end
    })
end

function Settings:Get(key)
    return Settings.Current[key] or Settings.Defaults[key]
end

function Settings:Set(key, value)
    Settings.Current[key] = value
end

function Settings:GetAll()
    local all = {}
    for k, v in pairs(Settings.Defaults) do
        all[k] = Settings.Current[k] or v
    end
    return all
end

return Settings
