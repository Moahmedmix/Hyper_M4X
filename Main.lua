
--[[
    ╔══════════════════════════════════════════════════╗
    ║           HYPER UI - Complete Framework          ║
    ║              Version: v1.0.0                      ║
    ║         By M4X | EVA | AMAL                      ║
    ║    Repository: github.com/Moahmedmix/Hyper_M4X    ║
    ╚══════════════════════════════════════════════════╝
    
    هذا الملف يحتوي على:
    - نظام الحماية والتحقق من الملفات
    - لوجر متكامل للكونسول
    - تحميل آمن للملفات الخارجية
    - الواجهة الرئيسية كاملة
    - Skip للملفات اللي فشلت
--]]

local REPO_URL = "https://raw.githubusercontent.com/Moahmedmix/Hyper_M4X/main/"
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- =============================================
-- LOGGER SYSTEM
-- =============================================
local Logger = { History = {} }
function Logger:Log(icon, msg)
    local text = "[Hyper] [" .. icon .. "] " .. msg
    print(text)
    table.insert(self.History, {Icon = icon, Msg = msg, Time = os.time()})
end
function Logger:Info(msg)  self:Log("ℹ", msg) end
function Logger:Good(msg)  self:Log("✅", msg) end
function Logger:Warn(msg)  self:Log("⚠", msg) end
function Logger:Fail(msg)  self:Log("❌", msg) end
function Logger:Skip(msg)  self:Log("⏭", msg) end
function Logger:Dead(msg)  self:Log("⛔", msg) end
function Logger:Line()     print("[Hyper] ─────────────────────────────") end

-- =============================================
-- MODULE LOADER WITH FULL PROTECTION
-- =============================================
local Loaded = {}
local Failed = {}
local Skipped = {}

local function LoadModule(path, required)
    local name = path:match("([^/]+)%.lua$") or path
    local url = REPO_URL .. path
    
    Logger:Info("Loading: " .. name)
    
    -- HTTP Request
    local httpOk, content = pcall(function() return game:HttpGet(url) end)
    if not httpOk then
        local errMsg = tostring(content)
        if required then
            Logger:Dead("NETWORK: " .. name .. " → " .. errMsg)
            table.insert(Failed, {Name = name, Reason = "Network: " .. errMsg})
            return nil
        else
            Logger:Skip("Network: " .. name .. " → " .. errMsg)
            table.insert(Skipped, {Name = name, Reason = "Network"})
            return nil
        end
    end
    
    -- Syntax Check
    local chunk, syntaxErr = loadstring(content)
    if not chunk then
        local errMsg = tostring(syntaxErr)
        if required then
            Logger:Dead("SYNTAX: " .. name .. " → " .. errMsg)
            table.insert(Failed, {Name = name, Reason = "Syntax: " .. errMsg})
            return nil
        else
            Logger:Skip("Syntax: " .. name .. " → " .. errMsg)
            table.insert(Skipped, {Name = name, Reason = "Syntax"})
            return nil
        end
    end
    
    -- Runtime Execution
    local runOk, result = pcall(chunk)
    if not runOk then
        local errMsg = tostring(result)
        if required then
            Logger:Dead("RUNTIME: " .. name .. " → " .. errMsg)
            table.insert(Failed, {Name = name, Reason = "Runtime: " .. errMsg})
            return nil
        else
            Logger:Skip("Runtime: " .. name .. " → " .. errMsg)
            table.insert(Skipped, {Name = name, Reason = "Runtime"})
            return nil
        end
    end
    
    Logger:Good("Loaded: " .. name)
    table.insert(Loaded, name)
    return result
end

-- =============================================
-- STARTUP
-- =============================================
print([[
  ╔══════════════════════════════════════╗
  ║         HYPER UI - v1.0.0           ║
  ║      By M4X | EVA | AMAL           ║
  ╚══════════════════════════════════════╝
]])
Logger:Info("Initializing...")
Logger:Info("Player: " .. LocalPlayer.Name)
Logger:Info("Place: " .. game.PlaceId)
Logger:Info("Time: " .. os.date("%H:%M:%S"))
Logger:Line()

-- =============================================
-- LOAD EXTERNAL CORE FILES
-- =============================================
Logger:Info("Loading Core Modules...")

local FlagsModule = LoadModule("Core/Flags.lua", true)
local ThemesModule = LoadModule("Core/Themes.lua", true)
local ConfigModule = LoadModule("Core/Config.lua", true)
local IconsModule = LoadModule("Core/Icons.lua", false)
local LibraryModule = LoadModule("Core/Library.lua", true)

-- Check critical failures
if #Failed > 0 then
    Logger:Dead("CRITICAL FAILURES DETECTED. Aborting.")
    for _, f in ipairs(Failed) do
        Logger:Dead("  → " .. f.Name .. ": " .. f.Reason)
    end
    error("[Hyper] Cannot start due to critical failures.")
    return
end

Logger:Line()

-- =============================================
-- INITIALIZE CORE MODULES
-- =============================================
local Flags = FlagsModule
local Themes = ThemesModule
local Config = ConfigModule
local Icons = IconsModule or {}
local Library = LibraryModule

-- =============================================
-- UI LIBRARY (BUILT-IN)
-- =============================================
local UI = {
    Name = "Hyper",
    Version = "v1.0.0",
    Author = "M4X | EVA | AMAL",
    Windows = {},
    Notifications = {},
    Flags = Flags or {},
}

-- Default Properties
UI.Defaults = {
    ScreenGui = { ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling },
    Frame = { BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(25,25,25) },
    TextLabel = { BackgroundTransparency = 1, BorderSizePixel = 0, RichText = true, TextColor3 = Color3.fromRGB(255,255,255), TextSize = 14, Font = Enum.Font.Gotham },
    TextButton = { BackgroundColor3 = Color3.fromRGB(25,25,25), BorderSizePixel = 0, AutoButtonColor = false, TextColor3 = Color3.fromRGB(255,255,255), TextSize = 14, Font = Enum.Font.Gotham },
    ImageLabel = { BackgroundTransparency = 1, BorderSizePixel = 0 },
    ScrollingFrame = { ScrollBarImageTransparency = 1, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(25,25,25) },
    TextBox = { BackgroundColor3 = Color3.fromRGB(35,35,35), BorderColor3 = Color3.fromRGB(50,50,50), ClearTextOnFocus = false, TextColor3 = Color3.fromRGB(255,255,255), TextSize = 14, Font = Enum.Font.Gotham },
    UIListLayout = { SortOrder = Enum.SortOrder.LayoutOrder },
    UICorner = {},
    UIPadding = {},
    UIGradient = {},
}

function UI:Create(className, props, children)
    local obj = Instance.new(className)
    for k, v in pairs(self.Defaults[className] or {}) do pcall(function() obj[k] = v end) end
    for k, v in pairs(props or {}) do pcall(function() obj[k] = v end) end
    for _, child in ipairs(children or {}) do child.Parent = obj end
    return obj
end

function UI:Tween(obj, dur, props, ease, dir)
    return TweenService:Create(obj, TweenInfo.new(dur, ease or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props)
end

function UI:Notify(cfg)
    local title = cfg.Title or "Hyper"
    local content = cfg.Content or ""
    local duration = cfg.Duration or 3
    
    print("[Hyper Notification] " .. title .. ": " .. content)
    
    -- Create notification GUI
    local notif = self:Create("Frame", {
        Name = "Notification",
        Parent = self.ActiveWindow and self.ActiveWindow.ScreenGui or CoreGui,
        Size = UDim2.new(0, 300, 0, 60),
        Position = UDim2.new(1, 320, 0, 20 + (#self.Notifications * 70)),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BackgroundTransparency = 0.1,
    }, {
        self:Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        self:Create("TextLabel", {
            Text = title,
            Position = UDim2.new(0, 15, 0, 8),
            Size = UDim2.new(1, -30, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Color3.fromRGB(0, 170, 255),
            TextSize = 14,
            Font = Enum.Font.GothamBold,
        }),
        self:Create("TextLabel", {
            Text = content,
            Position = UDim2.new(0, 15, 0, 28),
            Size = UDim2.new(1, -30, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextSize = 12,
            Font = Enum.Font.Gotham,
        }),
    })
    
    table.insert(self.Notifications, notif)
    
    -- Slide in
    self:Tween(notif, 0.3, {Position = UDim2.new(1, -310, 0, 20 + ((#self.Notifications - 1) * 70))}):Play()
    
    -- Auto remove
    task.delay(duration, function()
        self:Tween(notif, 0.3, {Position = UDim2.new(1, 320, notif.Position.Y)}):Play()
        task.delay(0.3, function()
            notif:Destroy()
            for i, n in ipairs(self.Notifications) do
                if n == notif then
                    table.remove(self.Notifications, i)
                    break
                end
            end
        end)
    end)
end

-- =============================================
-- CREATE WINDOW
-- =============================================
function UI:CreateWindow(cfg)
    local Window = {
        Name = cfg.Name or "Hyper",
        Tabs = {},
        Config = cfg,
        UI = self,
    }
    
    -- ScreenGui
    local Gui = self:Create("ScreenGui", {
        Name = "Hyper_" .. Window.Name,
        Parent = CoreGui,
    })
    Window.ScreenGui = Gui
    self.ActiveWindow = Window
    
    -- Main Frame
    local Main = self:Create("Frame", {
        Name = "Main",
        Parent = Gui,
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5, -300, 0.5, -200),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
    }, {
        self:Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
    })
    Window.Main = Main
    
    -- Title Bar
    local TitleBar = self:Create("Frame", {
        Name = "TitleBar",
        Parent = Main,
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
    }, {
        self:Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
        self:Create("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        }),
        self:Create("TextLabel", {
            Text = Window.Name .. " " .. (cfg.Subtitle or ""),
            Position = UDim2.new(0, 12, 0, 0),
            Size = UDim2.new(1, -50, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
        }),
    })
    
    -- Close Button
    local CloseBtn = self:Create("TextButton", {
        Name = "Close",
        Parent = TitleBar,
        Position = UDim2.new(1, -30, 0, 5),
        Size = UDim2.new(0, 24, 0, 24),
        Text = "✕",
        TextSize = 14,
        BackgroundColor3 = Color3.fromRGB(200, 50, 50),
    }, {
        self:Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
    })
    CloseBtn.MouseButton1Click:Connect(function()
        Gui:Destroy()
    end)
    
    -- Tab Bar
    local TabBar = self:Create("Frame", {
        Name = "TabBar",
        Parent = Main,
        Size = UDim2.new(0, 120, 1, -35),
        Position = UDim2.new(0, 0, 0, 35),
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
    }, {
        self:Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
        self:Create("UIListLayout", {
            Padding = UDim.new(0, 2),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
        }),
    })
    
    -- Tab Content Area
    local ContentArea = self:Create("Frame", {
        Name = "Content",
        Parent = Main,
        Size = UDim2.new(1, -120, 1, -35),
        Position = UDim2.new(0, 120, 0, 35),
        BackgroundColor3 = Color3.fromRGB(22, 22, 22),
    }, {
        self:Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
    })
    
    Window.ContentArea = ContentArea
    Window.TabBar = TabBar
    Window.Tabs = {}
    
    -- Create Tab Function
    function Window:CreateTab(name, icon)
        local Tab = {
            Name = name,
            Icon = icon,
            Elements = {},
            Parent = Window,
        }
        
        -- Tab Button
        local TabBtn = self:Create("TextButton", {
            Name = name .. "_Btn",
            Parent = TabBar,
            Size = UDim2.new(1, -8, 0, 30),
            Text = (icon and (" " .. icon .. "  ") or "") .. name,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundColor3 = Color3.fromRGB(15, 15, 15),
            Font = Enum.Font.Gotham,
        }, {
            self:Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        })
        
        -- Tab Content Page
        local Page = self:Create("Frame", {
            Name = name .. "_Page",
            Parent = ContentArea,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = (#Window.Tabs == 0),
            BackgroundTransparency = 1,
        })
        
        -- Scrolling Frame for elements
        local Scroll = self:Create("ScrollingFrame", {
            Name = "Scroll",
            Parent = Page,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100),
        }, {
            self:Create("UIListLayout", {
                Padding = UDim.new(0, 4),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
            }),
            self:Create("UIPadding", {
                PaddingTop = UDim.new(0, 8),
                PaddingBottom = UDim.new(0, 8),
            }),
        })
        
        -- Update canvas on child change
        Scroll.ChildAdded:Connect(function()
            local totalHeight = 16
            for _, child in ipairs(Scroll:GetChildren()) do
                if child:IsA("Frame") then
                    totalHeight = totalHeight + child.AbsoluteSize.Y + 4
                end
            end
            Scroll.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
        end)
        
        Tab.Page = Page
        Tab.Scroll = Scroll
        Tab.Btn = TabBtn
        
        -- Tab Switching
        TabBtn.MouseButton1Click:Connect(function()
            for _, t in ipairs(Window.Tabs) do
                t.Page.Visible = false
                t.Btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            end
            Page.Visible = true
            TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        end)
        
        -- If first tab, select it
        if #Window.Tabs == 0 then
            TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        end
        
        -- Element Creation Functions
        function Tab:CreateSection(name)
            local Section = self:Create("Frame", {
                Name = name .. "_Section",
                Parent = Scroll,
                Size = UDim2.new(1, -16, 0, 28),
                BackgroundTransparency = 1,
            }, {
                self:Create("TextLabel", {
                    Text = name,
                    Position = UDim2.new(0, 12, 0, 4),
                    Size = UDim2.new(1, -24, 0, 20),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextSize = 11,
                    TextColor3 = Color3.fromRGB(150, 150, 150),
                    Font = Enum.Font.GothamBold,
                }),
            })
            table.insert(self.Elements, {Type = "Section", Obj = Section, Name = name})
            return Section
        end
        
        function Tab:CreateLabel(text)
            local Label = self:Create("Frame", {
                Name = "Label",
                Parent = Scroll,
                Size = UDim2.new(1, -16, 0, 22),
                BackgroundTransparency = 1,
            }, {
                self:Create("TextLabel", {
                    Text = text,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -24, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextSize = 12,
                    TextColor3 = Color3.fromRGB(200, 200, 200),
                    Font = Enum.Font.Gotham,
                }),
            })
            table.insert(self.Elements, {Type = "Label", Obj = Label, Text = text})
            return Label
        end
        
        function Tab:CreateButton(cfg)
            local BtnFrame = self:Create("Frame", {
                Name = cfg.Name .. "_BtnFrame",
                Parent = Scroll,
                Size = UDim2.new(1, -16, 0, 32),
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
            }, {
                self:Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                self:Create("TextButton", {
                    Text = cfg.Name or "Button",
                    Size = UDim2.new(1, 0, 1, 0),
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    BackgroundTransparency = 1,
                }),
            })
            
            local Btn = BtnFrame:FindFirstChildWhichIsA("TextButton")
            if Btn then
                Btn.MouseButton1Click:Connect(function()
                    if cfg.Callback then
                        pcall(cfg.Callback)
                    end
                end)
            end
            
            table.insert(self.Elements, {Type = "Button", Obj = BtnFrame, Name = cfg.Name, Callback = cfg.Callback})
            return BtnFrame
        end
        
        function Tab:CreateToggle(cfg)
            local ToggleFrame = self:Create("Frame", {
                Name = cfg.Name .. "_Toggle",
                Parent = Scroll,
                Size = UDim2.new(1, -16, 0, 32),
                BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            }, {
                self:Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                self:Create("TextLabel", {
                    Text = cfg.Name or "Toggle",
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(0, 200, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                }),
            })
            
            local ToggleBtn = self:Create("TextButton", {
                Name = "Switch",
                Parent = ToggleFrame,
                Position = UDim2.new(1, -40, 0.5, -10),
                Size = UDim2.new(0, 28, 0, 16),
                Text = "",
                BackgroundColor3 = cfg.CurrentValue and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(80, 80, 80),
            }, {
                self:Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                self:Create("Frame", {
                    Name = "Knob",
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = cfg.CurrentValue and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                }, {
                    self:Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                }),
            })
            
            local toggled = cfg.CurrentValue or false
            
            ToggleBtn.MouseButton1Click:Connect(function()
                toggled = not toggled
                ToggleBtn.BackgroundColor3 = toggled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(80, 80, 80)
                local knob = ToggleBtn:FindFirstChild("Knob")
                if knob then
                    UI:Tween(knob, 0.15, {
                        Position = toggled and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
                    }):Play()
                end
                if cfg.Callback then
                    pcall(cfg.Callback, toggled)
                end
                if cfg.Flag and UI.Flags then
                    UI.Flags:Set(cfg.Flag, toggled)
                end
            end)
            
            -- Register flag
            if cfg.Flag and UI.Flags then
                UI.Flags:Create(cfg.Flag, cfg.CurrentValue or false)
            end
            
            table.insert(self.Elements, {Type = "Toggle", Obj = ToggleFrame, Name = cfg.Name, Flag = cfg.Flag, Value = toggled})
            return ToggleFrame
        end
        
        function Tab:CreateSlider(cfg)
            local min = cfg.Min or 0
            local max = cfg.Max or 100
            local val = cfg.CurrentValue or min
            
            local SliderFrame = self:Create("Frame", {
                Name = cfg.Name .. "_Slider",
                Parent = Scroll,
                Size = UDim2.new(1, -16, 0, 50),
                BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            }, {
                self:Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                self:Create("TextLabel", {
                    Text = cfg.Name .. ": " .. val,
                    Position = UDim2.new(0, 12, 0, 4),
                    Size = UDim2.new(1, -24, 0, 18),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                }),
            })
            
            local SliderBar = self:Create("Frame", {
                Name = "Bar",
                Parent = SliderFrame,
                Position = UDim2.new(0, 12, 0, 30),
                Size = UDim2.new(1, -24, 0, 6),
                BackgroundColor3 = Color3.fromRGB(60, 60, 60),
            }, {
                self:Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
                self:Create("Frame", {
                    Name = "Fill",
                    Size = UDim2.new((val - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = Color3.fromRGB(0, 170, 255),
                }, {
                    self:Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
                }),
            })
            
            -- Register flag
            if cfg.Flag and UI.Flags then
                UI.Flags:Create(cfg.Flag, val)
            end
            
            table.insert(self.Elements, {Type = "Slider", Obj = SliderFrame, Name = cfg.Name, Flag = cfg.Flag, Min = min, Max = max, Value = val})
            return SliderFrame
        end
        
        function Tab:CreateDropdown(cfg)
            local options = cfg.Options or {}
            local selected = cfg.CurrentOption or options[1] or "None"
            
            local DropFrame = self:Create("Frame", {
                Name = cfg.Name .. "_Dropdown",
                Parent = Scroll,
                Size = UDim2.new(1, -16, 0, 32),
                BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            }, {
                self:Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                self:Create("TextLabel", {
                    Text = selected,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -24, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                }),
            })
            
            -- Register flag
            if cfg.Flag and UI.Flags then
                UI.Flags:Create(cfg.Flag, selected)
            end
            
            table.insert(self.Elements, {Type = "Dropdown", Obj = DropFrame, Name = cfg.Name, Flag = cfg.Flag, Options = options, Value = selected})
            return DropFrame
        end
        
        table.insert(Window.Tabs, Tab)
        return Tab
    end
    
    -- Drag functionality
    local dragging = false
    local dragStart, startPos
    local dragFrame = self:Create("TextButton", {
        Name = "DragHandle",
        Parent = TitleBar,
        Size = UDim2.new(1, -35, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
    })
    
    dragFrame.MouseButton1Down:Connect(function(x, y)
        dragging = true
        dragStart = Vector2.new(x, y)
        startPos = Main.Position
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Config functions
    function Window:LoadConfiguration()
        if Config and Config.Load then
            Config:Load()
        end
    end
    
    function Window:SaveConfiguration()
        if Config and Config.Save then
            Config:Save()
        end
    end
    
    function Window:Destroy()
        Gui:Destroy()
    end
    
    table.insert(UI.Windows, Window)
    return Window
end

-- =============================================
-- CREATE MAIN HYPER WINDOW
-- =============================================
local Window = UI:CreateWindow({
    Name = "Hyper",
    Subtitle = "v1.0.0",
    Icon = "",
    LoadingTitle = "Hyper UI • Loading...",
    LoadingSubtitle = "By M4X | EVA | AMAL",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Hyper_Configs",
        FileName = "HyperSettings"
    },
    Discord = {
        Enabled = false,
        Invite = ""
    },
    KeySystem = false,
    SaveOnClose = true
})

-- =============================================
-- CREATE TABS
-- =============================================
local HomeTab      = Window:CreateTab("Home",      "⌂")
local AimbotTab    = Window:CreateTab("Aimbot",    "◎")
local VisualsTab   = Window:CreateTab("Visuals",   "👁")
local MovementTab  = Window:CreateTab("Movement",  "⚡")
local UtilityTab   = Window:CreateTab("Utility",   "⚙")
local ConfigTab    = Window:CreateTab("Config",    "💾")

-- =============================================
-- HOME TAB CONTENT
-- =============================================
HomeTab:CreateSection("Welcome")
HomeTab:CreateLabel("Hyper UI Framework v1.0.0")
HomeTab:CreateLabel("By M4X | EVA | AMAL")
HomeTab:CreateLabel("Welcome, " .. LocalPlayer.Name .. "!")

HomeTab:CreateSection("Quick Actions")
HomeTab:CreateButton({
    Name = "🔄 Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

HomeTab:CreateButton({
    Name = "🧹 Clean Workspace",
    Callback = function()
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Model") and obj ~= LocalPlayer.Character then
                pcall(function() obj:Destroy() end)
            end
        end
        UI:Notify({ Title = "Hyper", Content = "Workspace cleaned!", Duration = 2 })
    end
})

HomeTab:CreateButton({
    Name = "📋 Copy Discord",
    Callback = function()
        local invite = "" -- ضع رابط الديسكورد هنا
        pcall(function() setclipboard(invite) end)
        UI:Notify({ Title = "Hyper", Content = "Discord copied!", Duration = 2 })
    end
})

HomeTab:CreateButton({
    Name = "🔃 Refresh UI",
    Callback = function()
        loadstring(game:HttpGet(REPO_URL .. "Main.lua"))()
    end
})

HomeTab:CreateButton({
    Name = "❌ Destroy UI",
    Callback = function()
        Window:Destroy()
    end
})

HomeTab:CreateSection("Toggles")
HomeTab:CreateToggle({ Name = "Auto Updater", CurrentValue = true, Flag = "AutoUpdater", Callback = function(v) end })
HomeTab:CreateToggle({ Name = "Anti AFK", CurrentValue = false, Flag = "AntiAFK", Callback = function(v) end })
HomeTab:CreateToggle({ Name = "White Screen", CurrentValue = false, Flag = "WhiteScreen", Callback = function(v) end })

-- =============================================
-- LOAD EXTERNAL FEATURES
-- =============================================
Logger:Line()
Logger:Info("Loading External Features...")

local FeatureList = {
    {"Aimbot/Silent",      "Features/Aimbot/Silent.lua",      AimbotTab},
    {"Aimbot/FOV",         "Features/Aimbot/FOV.lua",         AimbotTab},
    {"Aimbot/Trigger",     "Features/Aimbot/Trigger.lua",     AimbotTab},
    {"Aimbot/Prediction",  "Features/Aimbot/Prediction.lua",  AimbotTab},
    {"Visuals/ESP",        "Features/Visuals/ESP.lua",        VisualsTab},
    {"Visuals/Boxes",      "Features/Visuals/Boxes.lua",      VisualsTab},
    {"Visuals/Skeletons",  "Features/Visuals/Skeletons.lua",  VisualsTab},
    {"Visuals/Chams",      "Features/Visuals/Chams.lua",      VisualsTab},
    {"Visuals/World",      "Features/Visuals/World.lua",      VisualsTab},
    {"Movement/Speed",     "Features/Movement/Speed.lua",     MovementTab},
    {"Movement/Fly",       "Features/Movement/Fly.lua",       MovementTab},
    {"Movement/Jump",      "Features/Movement/Jump.lua",      MovementTab},
    {"Movement/Teleport",  "Features/Movement/Teleport.lua",  MovementTab},
    {"Utility/AntiAFK",    "Features/Utility/AntiAFK.lua",    UtilityTab},
    {"Utility/AutoFarm",   "Features/Utility/AutoFarm.lua",   UtilityTab},
    {"Utility/StreamSniper","Features/Utility/StreamSniper.lua", UtilityTab},
    {"Utility/WhiteScreen","Features/Utility/WhiteScreen.lua", UtilityTab},
}

local loadedCount = 0
local skippedCount = 0

for _, feat in ipairs(FeatureList) do
    local name, path, tab = feat[1], feat[2], feat[3]
    local module = LoadModule(path, false)
    if module then
        if module.Init and type(module.Init) == "function" then
            local ok, err = pcall(function()
                module:Init(tab, UI, Flags)
            end)
            if ok then
                loadedCount = loadedCount + 1
            else
                Logger:Fail("Init error in " .. name .. ": " .. tostring(err))
                table.insert(Failed, {
