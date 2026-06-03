--[[
    ╔══════════════════════════════════════════════════╗
    ║           HYPER UI - UI Settings                 ║
    ║              Version: v1.0.0                      ║
    ║         By M4X | EVA | AMAL                      ║
    ╚══════════════════════════════════════════════════╝
--]]

local Settings = {}
Settings.__index = Settings

Settings.Defaults = {
    ToggleKey = "RightShift",
    Transparent = false,
    Resizable = true,
    ScrollBarEnabled = true,
    HideSearchBar = true,
    SideBarWidth = 190,
}

Settings.Current = {}

function Settings:Init(tab, library, flags)
    local self = setmetatable({}, Settings)
    self.Tab = tab
    self.Library = library
    self.Flags = flags

    for k, v in pairs(Settings.Defaults) do
        if Settings.Current[k] == nil then
            Settings.Current[k] = v
        end
    end

    if flags then
        flags:Create("UITransparent", Settings.Current.Transparent or false)
        flags:Create("UIResizable", Settings.Current.Resizable or true)
        flags:Create("UIScrollBar", Settings.Current.ScrollBarEnabled or true)
        flags:Create("UIHideSearch", Settings.Current.HideSearchBar or true)
        flags:Create("UISideBarWidth", Settings.Current.SideBarWidth or 190)
    end

    self:BuildUI()
    return self
end

function Settings:BuildUI()
    if not self.Tab then return end

    local toggleSection = self.Tab:Section({ 
        Title = "Window Toggles", 
        Icon = "toggle-left",
        Opened = true 
    })

    toggleSection:Toggle({
        Title = "Transparent Background",
        Description = "Make the window background transparent",
        Value = Settings.Current.Transparent or false,
        Callback = function(state)
            Settings.Current.Transparent = state
            if self.Flags then self.Flags:Set("UITransparent", state) end
            self.Library:Notify({ Title = "UI Settings", Description = "Transparency: " .. (state and "ON" or "OFF"), Duration = 2 })
        end
    })

    toggleSection:Toggle({
        Title = "Resizable Window",
        Description = "Allow window resizing",
        Value = Settings.Current.Resizable or true,
        Callback = function(state)
            Settings.Current.Resizable = state
            if self.Flags then self.Flags:Set("UIResizable", state) end
            self.Library:Notify({ Title = "UI Settings", Description = "Resizable: " .. (state and "ON" or "OFF"), Duration = 2 })
        end
    })

    toggleSection:Toggle({
        Title = "Scroll Bar",
        Description = "Show scrollbar in tabs",
        Value = Settings.Current.ScrollBarEnabled or true,
        Callback = function(state)
            Settings.Current.ScrollBarEnabled = state
            if self.Flags then self.Flags:Set("UIScrollBar", state) end
            self.Library:Notify({ Title = "UI Settings", Description = "Scrollbar: " .. (state and "ON" or "OFF"), Duration = 2 })
        end
    })

    toggleSection:Toggle({
        Title = "Hide Search Bar",
        Description = "Hide the tab search bar",
        Value = Settings.Current.HideSearchBar or true,
        Callback = function(state)
            Settings.Current.HideSearchBar = state
            if self.Flags then self.Flags:Set("UIHideSearch", state) end
            self.Library:Notify({ Title = "UI Settings", Description = "Search Bar: " .. (state and "Hidden" or "Visible"), Duration = 2 })
        end
    })

    local sliderSection = self.Tab:Section({ 
        Title = "Sidebar Width: " .. (Settings.Current.SideBarWidth or 190) .. "px", 
        Icon = "sidebar",
        Opened = true 
    })

    sliderSection:Slider({
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

    local resetSection = self.Tab:Section({ 
        Title = "Reset", 
        Icon = "rotate-ccw",
        Opened = false 
    })

    resetSection:Button({
        Title = "Reset All Settings",
        Description = "Restore defaults",
        Callback = function()
            for k, v in pairs(Settings.Defaults) do
                Settings.Current[k] = v
            end
            if self.Flags then
                self.Flags:Set("UITransparent", false)
                self.Flags:Set("UIResizable", true)
                self.Flags:Set("UIScrollBar", true)
                self.Flags:Set("UIHideSearch", true)
                self.Flags:Set("UISideBarWidth", 190)
            end
            self.Library:Notify({ Title = "UI Settings", Description = "Reset to default!", Duration = 3 })
        end
    })
end

function Settings:Get(key)
    return Settings.Current[key] or Settings.Defaults[key]
end

function Settings:Set(key, value)
    Settings.Current[key] = value
end

return Settings
