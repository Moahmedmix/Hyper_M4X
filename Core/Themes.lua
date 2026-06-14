--[[
    Hyper UI - Themes Module
    Provides theme selection UI for the Settings tab.
--]]

local Themes = {}
Themes.__index = Themes

local AvailableThemes = {
    "Dark", "Light", "Red", "Crimson", "Midnight",
    "Ocean", "Green", "Purple", "Sunset", "Forest",
    "Arctic", "Neon", "Gold", "Rose",
}

function Themes:Init(tab, library, flags)
    local self = setmetatable({}, Themes)
    self.Tab = tab
    self.Library = library
    self.Flags = flags

    local Sec = tab:Section({ Title = "Themes", Icon = "palette", Opened = true })

    Sec:Dropdown({
        Title = "Select Theme",
        Values = AvailableThemes,
        Value = "Dark",
        Callback = function(v)
            pcall(function() library:SetTheme(v) end)
        end,
    })

    return self
end

return Themes
