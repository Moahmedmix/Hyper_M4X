--[[
    Extracted Logger module from Main.lua for unit testing.
    This mirrors the Logger implementation in Main.lua.
]]

local Logger = {
    History = {},
    MaxHistory = 500,
    StartTime = os.clock(),
}

function Logger:Reset()
    self.History = {}
    self.StartTime = os.clock()
end

function Logger:GetTimestamp()
    return string.format("%.3f", os.clock() - self.StartTime)
end

function Logger:GetFormattedTime()
    return os.date("%H:%M:%S")
end

function Logger:Log(level, icon, message)
    local timestamp = self:GetTimestamp()
    local formatted = string.format("[%s] [Hyper] [%s] %s", timestamp, icon, message)

    local entry = {
        Level = level,
        Icon = icon,
        Message = message,
        Timestamp = timestamp,
        Time = self:GetFormattedTime(),
        Epoch = os.time(),
    }

    table.insert(self.History, entry)

    if #self.History > self.MaxHistory then
        table.remove(self.History, 1)
    end

    return entry
end

function Logger:Info(msg)    return self:Log("INFO",  "i", msg) end
function Logger:Good(msg)    return self:Log("OK",    "+", msg) end
function Logger:Warn(msg)    return self:Log("WARN",  "!", msg) end
function Logger:Error(msg)   return self:Log("ERROR", "x", msg) end
function Logger:Skip(msg)    return self:Log("SKIP",  ">", msg) end
function Logger:Dead(msg)    return self:Log("DEAD",  "X", msg) end

function Logger:PrintSummary()
    local counts = { Errors = 0, Skips = 0, Success = 0, Info = 0 }
    for _, entry in ipairs(self.History) do
        if entry.Level == "ERROR" or entry.Level == "DEAD" then counts.Errors = counts.Errors + 1
        elseif entry.Level == "SKIP" then counts.Skips = counts.Skips + 1
        elseif entry.Level == "OK" then counts.Success = counts.Success + 1
        elseif entry.Level == "INFO" then counts.Info = counts.Info + 1 end
    end
    return counts
end

return Logger
