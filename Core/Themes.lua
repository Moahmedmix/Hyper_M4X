-- Theme Test - Check WindUI Version & Available Methods
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not success or not WindUI then
    print("WindUI failed to load")
    return
end

print("=================================")
print("WindUI Version Check")
print("=================================")

-- Check if WindUI is a table
print("WindUI type: " .. type(WindUI))

-- List all available functions
print("\n--- WindUI Functions ---")
for k, v in pairs(WindUI) do
    print("  " .. k .. " = " .. type(v))
end

-- Check AddTheme
print("\n--- AddTheme Check ---")
if WindUI.AddTheme then
    print("AddTheme: EXISTS")
    
    -- Try to add a test theme
    local ok, err = pcall(function()
        WindUI:AddTheme({
            Name = "TestTheme",
            Accent = Color3.fromRGB(255, 0, 0),
            Background = Color3.fromRGB(0, 0, 0),
            Text = Color3.fromRGB(255, 255, 255),
        })
    end)
    
    if ok then
        print("AddTheme: WORKS!")
    else
        print("AddTheme: ERROR - " .. tostring(err))
    end
else
    print("AddTheme: NOT FOUND")
end

-- Check SetTheme
print("\n--- SetTheme Check ---")
if WindUI.SetTheme then
    print("SetTheme: EXISTS")
else
    print("SetTheme: NOT FOUND")
end

-- Check if Theme can be passed in CreateWindow
print("\n--- CreateWindow Theme Check ---")
local winOk, testWindow = pcall(function()
    return WindUI:CreateWindow({
        Title = "Theme Test",
        Author = "Test",
        Folder = "Test",
        Icon = "zap",
        Theme = "Dark",
        KeySystem = false,
    })
end)

if not winOk or not testWindow then
    print("Failed to create test window: " .. tostring(testWindow))
    return
end
print("Window created with Theme='Dark'")

-- Check available themes in WindUI
print("\n--- Built-in Themes ---")
local builtInThemes = {"Dark", "Light", "Red", "Crimson", "Midnight", "Ocean", "Green", "Purple", "Sunset", "Forest", "Arctic", "Neon", "Gold", "Rose"}
for _, theme in ipairs(builtInThemes) do
    local ok, err = pcall(function()
        WindUI:CreateWindow({
            Title = "Test",
            Theme = theme,
            KeySystem = false,
        }):Destroy()
    end)
    if ok then
        print("  [+] " .. theme .. " - Available")
    else
        print("  [-] " .. theme .. " - Not Available")
    end
end

pcall(function() testWindow:Destroy() end)
print("\n=================================")
print("Check Complete!")
print("=================================")
