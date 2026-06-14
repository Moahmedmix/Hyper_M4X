--[[
    Roblox API Mock for Unit Testing
    Provides minimal mock implementations of Roblox globals
    so that module logic can be tested outside the Roblox engine.
]]

-- Vector2 mock
local Vector2 = {}
Vector2.__index = Vector2

function Vector2.new(x, y)
    return setmetatable({ X = x or 0, Y = y or 0 }, Vector2)
end

function Vector2.__sub(a, b)
    return Vector2.new(a.X - b.X, a.Y - b.Y)
end

function Vector2.__add(a, b)
    return Vector2.new(a.X + b.X, a.Y + b.Y)
end

function Vector2.__mul(a, b)
    if type(b) == "number" then
        return Vector2.new(a.X * b, a.Y * b)
    end
    return Vector2.new(a.X * b.X, a.Y * b.Y)
end

Vector2.__index.Magnitude = nil
setmetatable(Vector2, {
    __index = function(t, k)
        if k == "zero" then return Vector2.new(0, 0) end
    end,
    __call = function(_, x, y) return Vector2.new(x, y) end,
})

-- Override Magnitude as a computed property
local vector2_mt = {
    __index = function(self, k)
        if k == "Magnitude" then
            return math.sqrt(self.X * self.X + self.Y * self.Y)
        end
        return Vector2[k]
    end,
    __sub = Vector2.__sub,
    __add = Vector2.__add,
    __mul = Vector2.__mul,
}

function Vector2.new(x, y)
    return setmetatable({ X = x or 0, Y = y or 0 }, vector2_mt)
end

-- Vector3 mock
local Vector3 = {}
Vector3.__index = Vector3

local vector3_mt

function Vector3.new(x, y, z)
    return setmetatable({ X = x or 0, Y = y or 0, Z = z or 0 }, vector3_mt)
end

vector3_mt = {
    __index = function(self, k)
        if k == "Magnitude" then
            return math.sqrt(self.X * self.X + self.Y * self.Y + self.Z * self.Z)
        end
        if k == "Unit" then
            local mag = math.sqrt(self.X * self.X + self.Y * self.Y + self.Z * self.Z)
            if mag == 0 then return Vector3.new(0, 0, 0) end
            return Vector3.new(self.X / mag, self.Y / mag, self.Z / mag)
        end
        return Vector3[k]
    end,
    __sub = function(a, b)
        return Vector3.new(a.X - b.X, a.Y - b.Y, a.Z - b.Z)
    end,
    __add = function(a, b)
        return Vector3.new(a.X + b.X, a.Y + b.Y, a.Z + b.Z)
    end,
    __mul = function(a, b)
        if type(b) == "number" then
            return Vector3.new(a.X * b, a.Y * b, a.Z * b)
        elseif type(a) == "number" then
            return Vector3.new(a * b.X, a * b.Y, a * b.Z)
        end
        return Vector3.new(a.X * b.X, a.Y * b.Y, a.Z * b.Z)
    end,
}

Vector3.zero = Vector3.new(0, 0, 0)

-- Color3 mock
local Color3 = {}
Color3.__index = Color3

function Color3.new(r, g, b)
    return setmetatable({ R = r or 0, G = g or 0, B = b or 0 }, Color3)
end

function Color3.fromRGB(r, g, b)
    return Color3.new((r or 0) / 255, (g or 0) / 255, (b or 0) / 255)
end

function Color3.fromHSV(h, s, v)
    return Color3.new(h, s, v) -- simplified
end

-- CFrame mock
local CFrame = {}
CFrame.__index = CFrame

function CFrame.new(...)
    local args = {...}
    local pos = Vector3.new(0, 0, 0)
    if #args >= 3 then
        pos = Vector3.new(args[1], args[2], args[3])
    elseif #args == 1 and type(args[1]) == "table" then
        pos = args[1]
    end
    return setmetatable({ Position = pos, LookVector = Vector3.new(0, 0, -1), RightVector = Vector3.new(1, 0, 0) }, CFrame)
end

function CFrame.Angles(rx, ry, rz)
    return CFrame.new(0, 0, 0)
end

function CFrame.__add(a, b)
    if type(b) == "table" and b.X then
        return CFrame.new(a.Position.X + b.X, a.Position.Y + b.Y, a.Position.Z + b.Z)
    end
    return a
end

function CFrame.__sub(a, b)
    if type(b) == "table" and b.X then
        return CFrame.new(a.Position.X - b.X, a.Position.Y - b.Y, a.Position.Z - b.Z)
    end
    return a
end

function CFrame.__mul(a, b)
    return a
end

-- UDim2 mock
local UDim2 = {}
UDim2.__index = UDim2

function UDim2.new(xs, xo, ys, yo)
    return setmetatable({ XScale = xs, XOffset = xo, YScale = ys, YOffset = yo }, UDim2)
end

-- Instance mock
local Instance = {}
Instance.__index = Instance

function Instance.new(className, parent)
    local inst = setmetatable({
        ClassName = className,
        Name = className,
        Parent = parent,
        _children = {},
        _props = {},
    }, Instance)
    if parent and parent._children then
        table.insert(parent._children, inst)
    end
    return inst
end

function Instance:FindFirstChild(name)
    for _, child in ipairs(self._children or {}) do
        if child.Name == name then return child end
    end
    return nil
end

function Instance:FindFirstChildOfClass(className)
    for _, child in ipairs(self._children or {}) do
        if child.ClassName == className then return child end
    end
    return nil
end

function Instance:IsDescendantOf(ancestor)
    local current = self.Parent
    while current do
        if current == ancestor then return true end
        current = current.Parent
    end
    return false
end

function Instance:GetPropertyChangedSignal(prop)
    return { Connect = function(_, cb) return { Disconnect = function() end } end }
end

function Instance:Destroy()
    self.Parent = nil
end

-- Enum mock
local Enum = {
    KeyCode = {
        W = "W", S = "S", A = "A", D = "D",
        Space = "Space", LeftControl = "LeftControl",
        LeftShift = "LeftShift", RightShift = "RightShift",
    },
    Font = { GothamBold = "GothamBold", Gotham = "Gotham" },
    RaycastFilterType = { Blacklist = "Blacklist" },
    LineJoinMode = { Miter = "Miter" },
}

-- RaycastParams mock
local RaycastParams = {}
RaycastParams.__index = RaycastParams
function RaycastParams.new()
    return setmetatable({ FilterType = nil, FilterDescendantsInstances = {}, IgnoreWater = false }, RaycastParams)
end

-- task mock
local task_mock = {
    wait = function(t) end,
    delay = function(t, fn) end,
    spawn = function(fn) fn() end,
}

-- Drawing mock
local Drawing = {}
function Drawing.new(className)
    return {
        Visible = false, Color = Color3.new(1, 1, 1),
        Thickness = 1, NumSides = 32, Radius = 100,
        Filled = false, Position = Vector2.new(0, 0), ZIndex = 0,
    }
end

-- Workspace mock
local workspace_mock = {
    CurrentCamera = {
        ViewportSize = Vector2.new(1920, 1080),
        CFrame = CFrame.new(0, 0, 0),
        GetPropertyChangedSignal = function(self, prop)
            return { Connect = function(_, cb) return { Disconnect = function() end } end }
        end,
        WorldToViewportPoint = function(self, pos)
            return Vector3.new(pos.X, pos.Y, pos.Z), true
        end,
    },
    Raycast = function(self, origin, direction, params)
        return nil -- no hit by default
    end,
}

-- Players mock
local Players_mock = {
    LocalPlayer = {
        Name = "TestPlayer",
        DisplayName = "TestPlayer",
        Team = nil,
        UserId = 12345,
        Character = nil,
        GetMouse = function() return { Hit = { Position = Vector3.new(0, 0, 0) } } end,
        CharacterAdded = { Wait = function() end },
    },
    GetPlayers = function(self)
        return {}
    end,
}

-- RunService mock
local RunService_mock = {
    Heartbeat = {
        Connect = function(self, cb)
            return { Disconnect = function() end, cb = cb }
        end,
    },
    RenderStepped = {
        Connect = function(self, cb)
            return { Disconnect = function() end, cb = cb }
        end,
    },
}

-- UserInputService mock
local UserInputService_mock = {
    InputBegan = { Connect = function(self, cb) return { Disconnect = function() end } end },
    InputEnded = { Connect = function(self, cb) return { Disconnect = function() end } end },
    JumpRequest = { Connect = function(self, cb) return { Disconnect = function() end } end },
}

-- TweenService mock
local TweenService_mock = {
    Create = function(self, inst, info, props)
        return { Play = function() end }
    end,
}

-- TweenInfo mock
local TweenInfo_mock = {}
function TweenInfo_mock.new(...) return {} end

-- HttpService mock
local HttpService_mock = {
    JSONEncode = function(self, data)
        -- Simple JSON encoder for tests
        if type(data) ~= "table" then return tostring(data) end
        local parts = {}
        for k, v in pairs(data) do
            local val
            if type(v) == "string" then val = '"' .. v .. '"'
            elseif type(v) == "boolean" then val = tostring(v)
            elseif type(v) == "number" then val = tostring(v)
            else val = '""' end
            table.insert(parts, '"' .. k .. '":' .. val)
        end
        return "{" .. table.concat(parts, ",") .. "}"
    end,
    JSONDecode = function(self, json)
        -- Simple JSON decoder for basic tests
        local data = {}
        for k, v in json:gmatch('"([^"]+)":([^,}]+)') do
            if v:match('^".*"$') then
                data[k] = v:sub(2, -2)
            elseif v == "true" then
                data[k] = true
            elseif v == "false" then
                data[k] = false
            else
                data[k] = tonumber(v) or v
            end
        end
        return data
    end,
}

-- game mock
local game_mock = {
    PlaceId = 123456,
    GetService = function(self, name)
        local services = {
            Players = Players_mock,
            RunService = RunService_mock,
            UserInputService = UserInputService_mock,
            TweenService = TweenService_mock,
            HttpService = HttpService_mock,
            TeleportService = {},
            CoreGui = Instance.new("CoreGui"),
            ReplicatedStorage = {},
            Workspace = workspace_mock,
            Lighting = {},
            StarterGui = {},
        }
        return services[name]
    end,
    HttpGet = function(self, url)
        return "return {}"
    end,
}

-- Set up globals
_G.Vector2 = Vector2
_G.Vector3 = Vector3
_G.Color3 = Color3
_G.CFrame = CFrame
_G.UDim2 = UDim2
_G.Instance = Instance
_G.Enum = Enum
_G.RaycastParams = RaycastParams
_G.Drawing = Drawing
_G.TweenInfo = TweenInfo_mock
_G.game = game_mock
_G.workspace = workspace_mock
_G.task = task_mock
_G.tick = os.clock
_G.warn = print
_G.rawget = rawget
_G.rawset = rawset
_G.loadstring = load
_G.getfenv = function() return _G end
_G.setfenv = function(fn, env) return fn end
_G.hookfunction = function() end
_G.identifyexecutor = function() return "TestExecutor" end

-- File system mocks for Config module
local _fileSystem = {}
_G.writefile = function(path, content) _fileSystem[path] = content end
_G.readfile = function(path) return _fileSystem[path] end
_G.isfile = function(path) return _fileSystem[path] ~= nil end
_G.isfolder = function(path) return true end
_G.makefolder = function(path) end
_G.delfile = function(path) _fileSystem[path] = nil end

-- Helper to reset file system between tests
_G._resetFileSystem = function() _fileSystem = {} end

return {
    Vector2 = Vector2,
    Vector3 = Vector3,
    Color3 = Color3,
    CFrame = CFrame,
    UDim2 = UDim2,
    Instance = Instance,
    Enum = Enum,
    RaycastParams = RaycastParams,
    Drawing = Drawing,
    TweenInfo = TweenInfo_mock,
    game = game_mock,
    workspace = workspace_mock,
    task = task_mock,
    Players = Players_mock,
    RunService = RunService_mock,
    HttpService = HttpService_mock,
}
