local Services = require(script.Parent.Services)

local PlayerUtils = {}

local Players = Services.Players
local LocalPlayer = Services.LocalPlayer
local Camera = Services.Camera

function PlayerUtils.GetOtherPlayers()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    return list
end

function PlayerUtils.GetCharacterParts(player)
    local char = player and player.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    local hum = char:FindFirstChildOfClass("Humanoid")
    return char, root, head, hum
end

function PlayerUtils.GetLocalCharacterParts()
    return PlayerUtils.GetCharacterParts(LocalPlayer)
end

function PlayerUtils.IsTeammate(player)
    if not player or not LocalPlayer then return false end
    return player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team
end

function PlayerUtils.RaycastCheck(targetPart, filterInstances)
    if not targetPart then return true end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = filterInstances or {}
    rayParams.IgnoreWater = true

    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude

    return workspace:Raycast(origin, direction, rayParams)
end

function PlayerUtils.IsVisible(player, aimPart)
    local char = player and player.Character
    if not char then return false end
    local part = char:FindFirstChild(aimPart or "Head")
    if not part then return false end

    local localChar = LocalPlayer and LocalPlayer.Character
    local result = PlayerUtils.RaycastCheck(part, {localChar})
    if result then
        return result.Instance:IsDescendantOf(char)
    end
    return true
end

function PlayerUtils.IsNotBehindWall(player, aimPart)
    local char = player and player.Character
    if not char then return false end
    local part = char:FindFirstChild(aimPart or "Head")
    if not part then return false end

    local localChar = LocalPlayer and LocalPlayer.Character
    local result = PlayerUtils.RaycastCheck(part, {localChar, char})
    return result == nil
end

return PlayerUtils
