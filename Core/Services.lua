local Services = {}

local cache = {}

local serviceNames = {
    "Players", "TeleportService", "HttpService", "RunService",
    "UserInputService", "TweenService", "CoreGui", "ReplicatedStorage",
    "Workspace", "Lighting", "StarterGui",
}

for _, name in ipairs(serviceNames) do
    local ok, service = pcall(function() return game:GetService(name) end)
    if ok and service then
        cache[name] = service
    end
end

function Services:Get(name)
    if cache[name] then return cache[name] end
    local ok, service = pcall(function() return game:GetService(name) end)
    if ok and service then
        cache[name] = service
        return service
    end
    return nil
end

Services.Players = cache.Players
Services.RunService = cache.RunService
Services.TweenService = cache.TweenService
Services.UserInputService = cache.UserInputService
Services.HttpService = cache.HttpService
Services.TeleportService = cache.TeleportService
Services.CoreGui = cache.CoreGui

Services.LocalPlayer = cache.Players and cache.Players.LocalPlayer
Services.Camera = workspace.CurrentCamera

return Services
