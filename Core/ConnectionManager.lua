local Services = require(script.Parent.Services)

local ConnectionManager = {}
ConnectionManager.__index = ConnectionManager

function ConnectionManager.new()
    return setmetatable({ _connections = {} }, ConnectionManager)
end

function ConnectionManager:Add(name, connection)
    if self._connections[name] then
        self._connections[name]:Disconnect()
    end
    self._connections[name] = connection
end

function ConnectionManager:Remove(name)
    if self._connections[name] then
        self._connections[name]:Disconnect()
        self._connections[name] = nil
    end
end

function ConnectionManager:DisconnectAll()
    for name, conn in pairs(self._connections) do
        conn:Disconnect()
    end
    self._connections = {}
end

function ConnectionManager:OnHeartbeat(name, callback)
    self:Add(name, Services.RunService.Heartbeat:Connect(callback))
end

function ConnectionManager:OnRenderStepped(name, callback)
    self:Add(name, Services.RunService.RenderStepped:Connect(callback))
end

return ConnectionManager
