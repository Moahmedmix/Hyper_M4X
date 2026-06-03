--[[
    ╔══════════════════════════════════════════════════╗
    ║           HYPER UI - Themes System               ║
    ║              Version: v1.0.0                      ║
    ║         By M4X | EVA | AMAL                      ║
    ╚══════════════════════════════════════════════════╝
    
    Full theme system using WindUI official API.
    - 10 custom themes registered via WindUI:AddTheme
    - Dropdown to select theme
    - Quick switch buttons
    - Instant theme application
--]]

local Themes = {}
Themes.__index = Themes

-- =============================================
-- THEME DATA
-- =============================================
local ThemeData = {

    ["Hyper Dark"] = {
        Name = "Hyper Dark",
        Accent = Color3.fromHex("#18181b"),
        Background = Color3.fromHex("#09090b"),
        BackgroundTransparency = 0,
        Outline = Color3.fromHex("#27272a"),
        Text = Color3.fromHex("#ffffff"),
        Placeholder = Color3.fromHex("#71717a"),
        Button = Color3.fromHex("#3f3f46"),
        Icon = Color3.fromHex("#a1a1aa"),
        Hover = Color3.fromHex("#ffffff"),
        WindowBackground = Color3.fromHex("#09090b"),
        WindowShadow = Color3.fromHex("#000000"),
        WindowTopbarButtonIcon = Color3.fromHex("#a1a1aa"),
        WindowTopbarTitle = Color3.fromHex("#ffffff"),
        WindowTopbarAuthor = Color3.fromHex("#a1a1aa"),
        WindowTopbarIcon = Color3.fromHex("#ffffff"),
        TabBackground = Color3.fromHex("#18181b"),
        TabTitle = Color3.fromHex("#ffffff"),
        TabIcon = Color3.fromHex("#a1a1aa"),
        ElementBackground = Color3.fromHex("#18181b"),
        ElementTitle = Color3.fromHex("#ffffff"),
        ElementDesc = Color3.fromHex("#a1a1aa"),
        ElementIcon = Color3.fromHex("#a1a1aa"),
        PopupBackground = Color3.fromHex("#09090b"),
        PopupBackgroundTransparency = 0,
        PopupTitle = Color3.fromHex("#ffffff"),
        PopupContent = Color3.fromHex("#a1a1aa"),
        PopupIcon = Color3.fromHex("#a1a1aa"),
        DialogBackground = Color3.fromHex("#09090b"),
        DialogBackgroundTransparency = 0,
        DialogTitle = Color3.fromHex("#ffffff"),
        DialogContent = Color3.fromHex("#a1a1aa"),
        DialogIcon = Color3.fromHex("#a1a1aa"),
        Toggle = Color3.fromHex("#3f3f46"),
        ToggleBar = Color3.fromHex("#ffffff"),
        Checkbox = Color3.fromHex("#3f3f46"),
        CheckboxIcon = Color3.fromHex("#ffffff"),
        Slider = Color3.fromHex("#3f3f46"),
        SliderThumb = Color3.fromHex("#ffffff"),
    },

    ["Hyper Red"] = {
        Name = "Hyper Red",
        Accent = Color3.fromHex("#ef4444"),
        Background = Color3.fromHex("#0c0000"),
        BackgroundTransparency = 0,
        Outline = Color3.fromHex("#450a0a"),
        Text = Color3.fromHex("#fef2f2"),
        Placeholder = Color3.fromHex("#7f1d1d"),
        Button = Color3.fromHex("#991b1b"),
        Icon = Color3.fromHex("#fca5a5"),
        Hover = Color3.fromHex("#fecaca"),
        WindowBackground = Color3.fromHex("#0c0000"),
        WindowShadow = Color3.fromHex("#000000"),
        WindowTopbarButtonIcon = Color3.fromHex("#fca5a5"),
        WindowTopbarTitle = Color3.fromHex("#fef2f2"),
        WindowTopbarAuthor = Color3.fromHex("#fca5a5"),
        WindowTopbarIcon = Color3.fromHex("#ef4444"),
        TabBackground = Color3.fromHex("#1a0000"),
        TabTitle = Color3.fromHex("#fef2f2"),
        TabIcon = Color3.fromHex("#fca5a5"),
        ElementBackground = Color3.fromHex("#1a0000"),
        ElementTitle = Color3.fromHex("#fef2f2"),
        ElementDesc = Color3.fromHex("#fca5a5"),
        ElementIcon = Color3.fromHex("#fca5a5"),
        PopupBackground = Color3.fromHex("#0c0000"),
        PopupBackgroundTransparency = 0,
        PopupTitle = Color3.fromHex("#fef2f2"),
        PopupContent = Color3.fromHex("#fca5a5"),
        PopupIcon = Color3.fromHex("#fca5a5"),
        DialogBackground = Color3.fromHex("#0c0000"),
        DialogBackgroundTransparency = 0,
        DialogTitle = Color3.fromHex("#fef2f2"),
        DialogContent = Color3.fromHex("#fca5a5"),
        DialogIcon = Color3.fromHex("#fca5a5"),
        Toggle = Color3.fromHex("#991b1b"),
        ToggleBar = Color3.fromHex("#fef2f2"),
        Checkbox = Color3.fromHex("#991b1b"),
        CheckboxIcon = Color3.fromHex("#fef2f2"),
        Slider = Color3.fromHex("#991b1b"),
        SliderThumb = Color3.fromHex("#fef2f2"),
    },

    ["Hyper Blue"] = {
        Name = "Hyper Blue",
        Accent = Color3.fromHex("#3b82f6"),
        Background = Color3.fromHex("#000814"),
        BackgroundTransparency = 0,
        Outline = Color3.fromHex("#1e3a5f"),
        Text = Color3.fromHex("#eff6ff"),
        Placeholder = Color3.fromHex("#3b82f6"),
        Button = Color3.fromHex("#1d4ed8"),
        Icon = Color3.fromHex("#93c5fd"),
        Hover = Color3.fromHex("#bfdbfe"),
        WindowBackground = Color3.fromHex("#000814"),
        WindowShadow = Color3.fromHex("#000000"),
        WindowTopbarButtonIcon = Color3.fromHex("#93c5fd"),
        WindowTopbarTitle = Color3.fromHex("#eff6ff"),
        WindowTopbarAuthor = Color3.fromHex("#93c5fd"),
        WindowTopbarIcon = Color3.fromHex("#3b82f6"),
        TabBackground = Color3.fromHex("#001a33"),
        TabTitle = Color3.fromHex("#eff6ff"),
        TabIcon = Color3.fromHex("#93c5fd"),
        ElementBackground = Color3.fromHex("#001a33"),
        ElementTitle = Color3.fromHex("#eff6ff"),
        ElementDesc = Color3.fromHex("#93c5fd"),
        ElementIcon = Color3.fromHex("#93c5fd"),
        PopupBackground = Color3.fromHex("#000814"),
        PopupBackgroundTransparency = 0,
        PopupTitle = Color3.fromHex("#eff6ff"),
        PopupContent = Color3.fromHex("#93c5fd"),
        PopupIcon = Color3.fromHex("#93c5fd"),
        DialogBackground = Color3.fromHex("#000814"),
        DialogBackgroundTransparency = 0,
        DialogTitle = Color3.fromHex("#eff6ff"),
        DialogContent = Color3.fromHex("#93c5fd"),
        DialogIcon = Color3.fromHex("#93c5fd"),
        Toggle = Color3.fromHex("#1d4ed8"),
        ToggleBar = Color3.fromHex("#eff6ff"),
        Checkbox = Color3.fromHex("#1d4ed8"),
        CheckboxIcon = Color3.fromHex("#eff6ff"),
        Slider = Color3.fromHex("#1d4ed8"),
        SliderThumb = Color3.fromHex("#eff6ff"),
    },

    ["Hyper Green"] = {
        Name = "Hyper Green",
        Accent = Color3.fromHex("#22c55e"),
        Background = Color3.fromHex("#000d02"),
        BackgroundTransparency = 0,
        Outline = Color3.fromHex("#14532d"),
        Text = Color3.fromHex("#f0fdf4"),
        Placeholder = Color3.fromHex("#22c55e"),
        Button = Color3.fromHex("#15803d"),
        Icon = Color3.fromHex("#86efac"),
        Hover = Color3.fromHex("#bbf7d0"),
        WindowBackground = Color3.fromHex("#000d02"),
        WindowShadow = Color3.fromHex("#000000"),
        WindowTopbarButtonIcon = Color3.fromHex("#86efac"),
        WindowTopbarTitle = Color3.fromHex("#f0fdf4"),
        WindowTopbarAuthor = Color3.fromHex("#86efac"),
        WindowTopbarIcon = Color3.fromHex("#22c55e"),
        TabBackground = Color3.fromHex("#002b08"),
        TabTitle = Color3.fromHex("#f0fdf4"),
        TabIcon = Color3.fromHex("#86efac"),
        ElementBackground = Color3.fromHex("#002b08"),
        ElementTitle = Color3.fromHex("#f0fdf4"),
        ElementDesc = Color3.fromHex("#86efac"),
        ElementIcon = Color3.fromHex("#86efac"),
        PopupBackground = Color3.fromHex("#000d02"),
        PopupBackgroundTransparency = 0,
        PopupTitle = Color3.fromHex("#f0fdf4"),
        PopupContent = Color3.fromHex("#86efac"),
        PopupIcon = Color3.fromHex("#86efac"),
        DialogBackground = Color3.fromHex("#000d02"),
        DialogBackgroundTransparency = 0,
        DialogTitle = Color3.fromHex("#f0fdf4"),
        DialogContent = Color3.fromHex("#86efac"),
        DialogIcon = Color3.fromHex("#86efac"),
        Toggle = Color3.fromHex("#15803d"),
        ToggleBar = Color3.fromHex("#f0fdf4"),
        Checkbox = Color3.fromHex("#15803d"),
        CheckboxIcon = Color3.fromHex("#f0fdf4"),
        Slider = Color3.fromHex("#15803d"),
        SliderThumb = Color3.fromHex("#f0fdf4"),
    },

    ["Hyper Purple"] = {
        Name = "Hyper Purple",
        Accent = Color3.fromHex("#a855f7"),
        Background = Color3.fromHex("#05000d"),
        BackgroundTransparency = 0,
        Outline = Color3.fromHex("#4c1d95"),
        Text = Color3.fromHex("#faf5ff"),
        Placeholder = Color3.fromHex("#a855f7"),
        Button = Color3.fromHex("#7c3aed"),
        Icon = Color3.fromHex("#c4b5fd"),
        Hover = Color3.fromHex("#ddd6fe"),
        WindowBackground = Color3.fromHex("#05000d"),
        WindowShadow = Color3.fromHex("#000000"),
        WindowTopbarButtonIcon = Color3.fromHex("#c4b5fd"),
        WindowTopbarTitle = Color3.fromHex("#faf5ff"),
        WindowTopbarAuthor = Color3.fromHex("#c4b5fd"),
        WindowTopbarIcon = Color3.fromHex("#a855f7"),
        TabBackground = Color3.fromHex("#15002b"),
        TabTitle = Color3.fromHex("#faf5ff"),
        TabIcon = Color3.fromHex("#c4b5fd"),
        ElementBackground = Color3.fromHex("#15002b"),
        ElementTitle = Color3.fromHex("#faf5ff"),
        ElementDesc = Color3.fromHex("#c4b5fd"),
        ElementIcon = Color3.fromHex("#c4b5fd"),
        PopupBackground = Color3.fromHex("#05000d"),
        PopupBackgroundTransparency = 0,
        PopupTitle = Color3.fromHex("#faf5ff"),
        PopupContent = Color3.fromHex("#c4b5fd"),
        PopupIcon = Color3.fromHex("#c4b5fd"),
        DialogBackground = Color3.fromHex("#05000d"),
        DialogBackgroundTransparency = 0,
        DialogTitle = Color3.fromHex("#faf5ff"),
        DialogContent = Color3.fromHex("#c4b5fd"),
        DialogIcon = Color3.fromHex("#c4b5fd"),
        Toggle = Color3.fromHex("#7c3aed"),
        ToggleBar = Color3.fromHex("#faf5ff"),
        Checkbox = Color3.fromHex("#7c3aed"),
        CheckboxIcon = Color3.fromHex("#faf5ff"),
        Slider = Color3.fromHex("#7c3aed"),
        SliderThumb = Color3.fromHex("#faf5ff"),
    },

    ["Hyper Ocean"] = {
        Name = "Hyper Ocean",
        Accent = Color3.fromHex("#06b6d4"),
        Background = Color3.fromHex("#000d0d"),
        BackgroundTransparency = 0,
        Outline = Color3.fromHex("#155e75"),
        Text = Color3.fromHex("#ecfeff"),
        Placeholder = Color3.fromHex("#06b6d4"),
        Button = Color3.fromHex("#0e7490"),
        Icon = Color3.fromHex("#67e8f9"),
        Hover = Color3.fromHex("#a5f3fc"),
        WindowBackground = Color3.fromHex("#000d0d"),
        WindowShadow = Color3.fromHex("#000000"),
        WindowTopbarButtonIcon = Color3.fromHex("#67e8f9"),
        WindowTopbarTitle = Color3.fromHex("#ecfeff"),
        WindowTopbarAuthor = Color3.fromHex("#67e8f9"),
        WindowTopbarIcon = Color3.fromHex("#06b6d4"),
        TabBackground = Color3.fromHex("#002b2b"),
        TabTitle = Color3.fromHex("#ecfeff"),
        TabIcon = Color3.fromHex("#67e8f9"),
        ElementBackground = Color3.fromHex("#002b2b"),
        ElementTitle = Color3.fromHex("#ecfeff"),
        ElementDesc = Color3.fromHex("#67e8f9"),
        ElementIcon = Color3.fromHex("#67e8f9"),
        PopupBackground = Color3.fromHex("#000d0d"),
        PopupBackgroundTransparency = 0,
        PopupTitle = Color3.fromHex("#ecfeff"),
        PopupContent = Color3.fromHex("#67e8f9"),
        PopupIcon = Color3.fromHex("#67e8f9"),
        DialogBackground = Color3.fromHex("#000d0d"),
        DialogBackgroundTransparency = 0,
        DialogTitle = Color3.fromHex("#ecfeff"),
        DialogContent = Color3.fromHex("#67e8f9"),
        DialogIcon = Color3.fromHex("#67e8f9"),
        Toggle = Color3.fromHex("#0e7490"),
        ToggleBar = Color3.fromHex("#ecfeff"),
        Checkbox = Color3.fromHex("#0e7490"),
        CheckboxIcon = Color3.fromHex("#ecfeff"),
        Slider = Color3.fromHex("#0e7490"),
        SliderThumb = Color3.fromHex("#ecfeff"),
    },

    ["Hyper Gold"] = {
        Name = "Hyper Gold",
        Accent = Color3.fromHex("#eab308"),
        Background = Color3.fromHex("#0d0a00"),
        BackgroundTransparency = 0,
        Outline = Color3.fromHex("#854d0e"),
        Text = Color3.fromHex("#fefce8"),
        Placeholder = Color3.fromHex("#eab308"),
        Button = Color3.fromHex("#a16207"),
        Icon = Color3.fromHex("#fde047"),
        Hover = Color3.fromHex("#fef08a"),
        WindowBackground = Color3.fromHex("#0d0a00"),
        WindowShadow = Color3.fromHex("#000000"),
        WindowTopbarButtonIcon = Color3.fromHex("#fde047"),
        WindowTopbarTitle = Color3.fromHex("#fefce8"),
        WindowTopbarAuthor = Color3.fromHex("#fde047"),
        WindowTopbarIcon = Color3.fromHex("#eab308"),
        TabBackground = Color3.fromHex("#2b1f00"),
        TabTitle = Color3.fromHex("#fefce8"),
        TabIcon = Color3.fromHex("#fde047"),
        ElementBackground = Color3.fromHex("#2b1f00"),
        ElementTitle = Color3.fromHex("#fefce8"),
        ElementDesc = Color3.fromHex("#fde047"),
        ElementIcon = Color3.fromHex("#fde047"),
        PopupBackground = Color3.fromHex("#0d0a00"),
        PopupBackgroundTransparency = 0,
        PopupTitle = Color3.fromHex("#fefce8"),
        PopupContent = Color3.fromHex("#fde047"),
        PopupIcon = Color3.fromHex("#fde047"),
        DialogBackground = Color3.fromHex("#0d0a00"),
        DialogBackgroundTransparency = 0,
        DialogTitle = Color3.fromHex("#fefce8"),
        DialogContent = Color3.fromHex("#fde047"),
        DialogIcon = Color3.fromHex("#fde047"),
        Toggle = Color3.fromHex("#a16207"),
        ToggleBar = Color3.fromHex("#fefce8"),
        Checkbox = Color3.fromHex("#a16207"),
        CheckboxIcon = Color3.fromHex("#fefce8"),
        Slider = Color3.fromHex("#a16207"),
        SliderThumb = Color3.fromHex("#fefce8"),
    },

    ["Hyper Pink"] = {
        Name = "Hyper Pink",
        Accent = Color3.fromHex("#ec4899"),
        Background = Color3.fromHex("#0d0008"),
        BackgroundTransparency = 0,
        Outline = Color3.fromHex("#9d174d"),
        Text = Color3.fromHex("#fdf2f8"),
        Placeholder = Color3.fromHex("#ec4899"),
        Button = Color3.fromHex("#be185d"),
        Icon = Color3.fromHex("#f9a8d4"),
        Hover = Color3.fromHex("#fbcfe8"),
        WindowBackground = Color3.fromHex("#0d0008"),
        WindowShadow = Color3.fromHex("#000000"),
        WindowTopbarButtonIcon = Color3.fromHex("#f9a8d4"),
        WindowTopbarTitle = Color3.fromHex("#fdf2f8"),
        WindowTopbarAuthor = Color3.fromHex("#f9a8d4"),
        WindowTopbarIcon = Color3.fromHex("#ec4899"),
        TabBackground = Color3.fromHex("#2b001a"),
        TabTitle = Color3.fromHex("#fdf2f8"),
        TabIcon = Color3.fromHex("#f9a8d4"),
        ElementBackground = Color3.fromHex("#2b001a"),
        ElementTitle = Color3.fromHex("#fdf2f8"),
        ElementDesc = Color3.fromHex("#f9a8d4"),
        ElementIcon = Color3.fromHex("#f9a8d4"),
        PopupBackground = Color3.fromHex("#0d0008"),
        PopupBackgroundTransparency = 0,
        PopupTitle = Color3.fromHex("#fdf2f8"),
        PopupContent = Color3.fromHex("#f9a8d4"),
        PopupIcon = Color3.fromHex("#f9a8d4"),
        DialogBackground = Color3.fromHex("#0d0008"),
        DialogBackgroundTransparency = 0,
        DialogTitle = Color3.fromHex("#fdf2f8"),
        DialogContent = Color3.fromHex("#f9a8d4"),
        DialogIcon = Color3.fromHex("#f9a8d4"),
        Toggle = Color3.fromHex("#be185d"),
        ToggleBar = Color3.fromHex("#fdf2f8"),
        Checkbox = Color3.fromHex("#be185d"),
        CheckboxIcon = Color3.fromHex("#fdf2f8"),
        Slider = Color3.fromHex("#be185d"),
        SliderThumb = Color3.fromHex("#fdf2f8"),
    },

    ["Hyper Mint"] = {
        Name = "Hyper Mint",
        Accent = Color3.fromHex("#10b981"),
        Background = Color3.fromHex("#000d08"),
        BackgroundTransparency = 0,
        Outline = Color3.fromHex("#065f46"),
        Text = Color3.fromHex("#ecfdf5"),
        Placeholder = Color3.fromHex("#10b981"),
        Button = Color3.fromHex("#047857"),
        Icon = Color3.fromHex("#6ee7b7"),
        Hover = Color3.fromHex("#a7f3d0"),
        WindowBackground = Color3.fromHex("#000d08"),
        WindowShadow = Color3.fromHex("#000000"),
        WindowTopbarButtonIcon = Color3.fromHex("#6ee7b7"),
        WindowTopbarTitle = Color3.fromHex("#ecfdf5"),
        WindowTopbarAuthor = Color3.fromHex("#6ee7b7"),
        WindowTopbarIcon = Color3.fromHex("#10b981"),
        TabBackground = Color3.fromHex("#002b1a"),
        TabTitle = Color3.fromHex("#ecfdf5"),
        TabIcon = Color3.fromHex("#6ee7b7"),
        ElementBackground = Color3.fromHex("#002b1a"),
        ElementTitle = Color3.fromHex("#ecfdf5"),
        ElementDesc = Color3.fromHex("#6ee7b7"),
        ElementIcon = Color3.fromHex("#6ee7b7"),
        PopupBackground = Color3.fromHex("#000d08"),
        PopupBackgroundTransparency = 0,
        PopupTitle = Color3.fromHex("#ecfdf5"),
        PopupContent = Color3.fromHex("#6ee7b7"),
        PopupIcon = Color3.fromHex("#6ee7b7"),
        DialogBackground = Color3.fromHex("#000d08"),
        DialogBackgroundTransparency = 0,
        DialogTitle = Color3.fromHex("#ecfdf5"),
        DialogContent = Color3.fromHex("#6ee7b7"),
        DialogIcon = Color3.fromHex("#6ee7b7"),
        Toggle = Color3.fromHex("#047857"),
        ToggleBar = Color3.fromHex("#ecfdf5"),
        Checkbox = Color3.fromHex("#047857"),
        CheckboxIcon = Color3.fromHex("#ecfdf5"),
        Slider = Color3.fromHex("#047857"),
        SliderThumb = Color3.fromHex("#ecfdf5"),
    },
}

-- Build sorted theme list
Themes.List = {}
for name, _ in pairs(ThemeData) do
    table.insert(Themes.List, name)
end
table.sort(Themes.List)

Themes.CurrentName = "Hyper Dark"

-- =============================================
-- REGISTER ALL THEMES WITH WIND UI
-- =============================================
for name, data in pairs(ThemeData) do
    pcall(function()
        WindUI:AddTheme(data)
    end)
end

-- =============================================
-- INIT
-- =============================================
function Themes:Init(tab, library, flags)
    local self = setmetatable({}, Themes)
    self.Tab = tab
    self.Library = library
    self.Flags = flags

    if flags then
        flags:Create("CurrentTheme", Themes.CurrentName)
    end

    self:BuildUI()
    return self
end

-- =============================================
-- BUILD UI
-- =============================================
function Themes:BuildUI()
    if not self.Tab then return end

    -- Info Section
    local infoSection = self.Tab:Section({ 
        Title = "Current Theme", 
        Icon = "info",
        Opened = true 
    })
    
    infoSection:Label({ Title = "Theme: " .. Themes.CurrentName })

    -- Dropdown Section
    local selectSection = self.Tab:Section({ 
        Title = "Select Theme", 
        Icon = "palette",
        Opened = true 
    })

    selectSection:Dropdown({
        Title = "Theme",
        Description = "Choose your theme",
        Values = Themes.List,
        Value = Themes.CurrentName,
        Callback = function(selected)
            self:ApplyTheme(selected)
        end
    })

    -- Quick Switch Sections
    local darkSection = self.Tab:Section({ 
        Title = "Dark Themes", 
        Icon = "moon",
        Opened = false 
    })

    for _, name in ipairs({"Hyper Dark", "Hyper Blue", "Hyper Purple", "Hyper Ocean"}) do
        darkSection:Button({
            Title = name,
            Callback = function()
                self:ApplyTheme(name)
            end
        })
    end

    local colorSection = self.Tab:Section({ 
        Title = "Colorful Themes", 
        Icon = "sun",
        Opened = false 
    })

    for _, name in ipairs({"Hyper Red", "Hyper Green", "Hyper Gold", "Hyper Orange"}) do
        colorSection:Button({
            Title = name,
            Callback = function()
                self:ApplyTheme(name)
            end
        })
    end

    local softSection = self.Tab:Section({ 
        Title = "Soft Themes", 
        Icon = "heart",
        Opened = false 
    })

    for _, name in ipairs({"Hyper Pink", "Hyper Mint"}) do
        softSection:Button({
            Title = name,
            Callback = function()
                self:ApplyTheme(name)
            end
        })
    end
end

-- =============================================
-- APPLY THEME
-- =============================================
function Themes:ApplyTheme(name)
    if not ThemeData[name] then
        if self.Library then
            self.Library:Notify({ 
                Title = "Theme Error", 
                Description = "Theme not found: " .. name, 
                Duration = 3 
            })
        end
        return false
    end

    Themes.CurrentName = name

    if self.Flags then
        self.Flags:Set("CurrentTheme", name)
    end

    -- Try to apply via WindUI
    local applied = false
    pcall(function()
        WindUI:SetTheme(ThemeData[name])
        applied = true
    end)
    
    if not applied then
        pcall(function()
            WindUI:SetTheme(name)
            applied = true
        end)
    end

    if self.Library then
        self.Library:Notify({ 
            Title = "Theme Applied", 
            Description = name .. (applied and "" or " | Refresh to see full effect"), 
            Duration = 3 
        })
    end

    return true
end

function Themes:GetCurrentTheme()
    return Themes.CurrentName
end

return Themes
