--[[
    Extracted ModuleLoader module from Main.lua for unit testing.
    This mirrors the ModuleLoader implementation in Main.lua.
]]

local Logger = require("tests.modules.logger")

local ModuleLoader = {
    Loaded = {},
    Failed = {},
    Skipped = {},
    Stats = { Total = 0, Loaded = 0, Failed = 0, Skipped = 0 },
    MaxRetries = 2,
}

function ModuleLoader:Reset()
    self.Loaded = {}
    self.Failed = {}
    self.Skipped = {}
    self.Stats = { Total = 0, Loaded = 0, Failed = 0, Skipped = 0 }
end

-- Inject a fetch function for testing (avoids calling game:HttpGet)
ModuleLoader._fetchFn = nil

function ModuleLoader:SetFetchFunction(fn)
    self._fetchFn = fn
end

function ModuleLoader:LoadFromURL(url, moduleName, required, retryCount)
    retryCount = retryCount or 0
    self.Stats.Total = self.Stats.Total + 1

    Logger:Info("Loading: " .. moduleName .. (required and " [REQUIRED]" or " [OPTIONAL]"))

    local httpOk, content
    if self._fetchFn then
        httpOk, content = pcall(self._fetchFn, url)
    else
        httpOk, content = false, "No fetch function"
    end

    if not httpOk then
        if retryCount < self.MaxRetries then
            Logger:Warn("Retrying " .. moduleName .. " (" .. (retryCount + 1) .. "/" .. self.MaxRetries .. ")")
            return self:LoadFromURL(url, moduleName, required, retryCount + 1)
        end

        if required then
            Logger:Dead("NETWORK FAILURE: " .. moduleName)
            self.Stats.Failed = self.Stats.Failed + 1
            table.insert(self.Failed, { Name = moduleName, Reason = "Network" })
            return nil
        else
            Logger:Skip("Network: " .. moduleName)
            self.Stats.Skipped = self.Stats.Skipped + 1
            table.insert(self.Skipped, { Name = moduleName, Reason = "Network" })
            return nil
        end
    end

    local chunk, syntaxErr = load(content)
    if not chunk then
        if required then
            Logger:Dead("SYNTAX FAILURE: " .. moduleName)
            self.Stats.Failed = self.Stats.Failed + 1
            table.insert(self.Failed, { Name = moduleName, Reason = "Syntax" })
            return nil
        else
            Logger:Skip("Syntax: " .. moduleName)
            self.Stats.Skipped = self.Stats.Skipped + 1
            table.insert(self.Skipped, { Name = moduleName, Reason = "Syntax" })
            return nil
        end
    end

    local runOk, result = pcall(chunk)
    if not runOk then
        if required then
            Logger:Dead("RUNTIME FAILURE: " .. moduleName)
            self.Stats.Failed = self.Stats.Failed + 1
            table.insert(self.Failed, { Name = moduleName, Reason = "Runtime" })
            return nil
        else
            Logger:Skip("Runtime: " .. moduleName)
            self.Stats.Skipped = self.Stats.Skipped + 1
            table.insert(self.Skipped, { Name = moduleName, Reason = "Runtime" })
            return nil
        end
    end

    Logger:Good("Loaded: " .. moduleName)
    self.Stats.Loaded = self.Stats.Loaded + 1
    table.insert(self.Loaded, { Name = moduleName, Module = result })
    return result
end

function ModuleLoader:LoadFromRepo(path, required)
    local name = path:match("([^/]+)%.lua$") or path
    local url = "https://raw.githubusercontent.com/Moahmedmix/Hyper_M4X/main/" .. path
    return self:LoadFromURL(url, name, required)
end

return ModuleLoader
