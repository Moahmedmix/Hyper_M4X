--[[
    Extracted FeatureInitializer module from Main.lua for unit testing.
    This mirrors the FeatureInitializer implementation in Main.lua.
]]

local Logger = require("tests.modules.logger")

local FeatureInitializer = {
    Initialized = {},
    Failed = {},
    Skipped = {},
}

function FeatureInitializer:Reset()
    self.Initialized = {}
    self.Failed = {}
    self.Skipped = {}
end

function FeatureInitializer:InitFeature(module, tab, library, flags, name)
    if not module then
        table.insert(self.Skipped, { Name = name, Reason = "Module is nil" })
        return false
    end

    if not module.Init or type(module.Init) ~= "function" then
        table.insert(self.Skipped, { Name = name, Reason = "No Init function" })
        Logger:Skip("No Init: " .. name)
        return false
    end

    Logger:Info("Initializing: " .. name)

    local ok, err = pcall(function()
        module:Init(tab, library, flags)
    end)

    if not ok then
        Logger:Error("Init failed: " .. name .. " - " .. tostring(err))
        table.insert(self.Failed, { Name = name, Reason = tostring(err) })
        return false
    end

    Logger:Good("Initialized: " .. name)
    table.insert(self.Initialized, { Name = name, Module = module })
    return true
end

return FeatureInitializer
