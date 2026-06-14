--[[
    Extracted Flags module from Main.lua for unit testing.
    This mirrors the Flags implementation in Main.lua.
]]

local Flags = {}
local FlagStorage = {}

function Flags:Reset()
    FlagStorage = {}
end

function Flags:Create(name, default)
    if FlagStorage[name] then return FlagStorage[name] end

    local flag = {
        Name = name,
        Value = default,
        Connections = {},
    }

    function flag:Get() return self.Value end
    function flag:Set(newValue)
        local old = self.Value
        self.Value = newValue
        for _, cb in ipairs(self.Connections) do
            pcall(cb, newValue, old)
        end
    end
    function flag:Toggle() self:Set(not self.Value) end
    function flag:Connect(callback)
        table.insert(self.Connections, callback)
        return { Disconnect = function()
            for i, cb in ipairs(self.Connections) do
                if cb == callback then table.remove(self.Connections, i) break end
            end
        end }
    end

    FlagStorage[name] = flag
    return flag
end

function Flags:Get(name) return FlagStorage[name] end
function Flags:Set(name, value) if FlagStorage[name] then FlagStorage[name]:Set(value) end end
function Flags:GetValue(name) return FlagStorage[name] and FlagStorage[name]:Get() or nil end
function Flags:Count()
    local count = 0
    for _ in pairs(FlagStorage) do count = count + 1 end
    return count
end

return Flags
