local RunService = game:GetService("RunService")

local Networking = {}

local function addinstance(instance: string, name: string, parent: Instance)
    local Item = Instance.new(instance)
    Item.Name = name
    Item.Parent = parent
    return Item
end

local function getNetworkingStorage()
    if game:GetService("RunService"):IsClient() then
        return game.ReplicatedStorage:WaitForChild("RamkaX_Networking")
    else
        local hasSignal = game.ReplicatedStorage:FindFirstChild("RamkaX_Networking")
        if not hasSignal then
            local RemoteSignal = addinstance("Folder", "RamkaX_Networking", game.ReplicatedStorage)
            return RemoteSignal
        end
        return hasSignal
    end
end

local function createNew(instanceName, instanceType)
    local NetworkingStorage = getNetworkingStorage()

    if RunService:IsClient() then
        return NetworkingStorage:WaitForChild(instanceName)
    else
        local hasInstance = NetworkingStorage:FindFirstChild(instanceName)
        if hasInstance then
            return hasInstance
        else
            return addinstance(instanceType, instanceName, NetworkingStorage)
        end
    end
end

function Networking.RemoteEvent(remoteEventName: string)
    return createNew(remoteEventName, "RemoteEvent")
end

function Networking.RemoteFunction(remoteFunctionName: string)
    return createNew(remoteFunctionName, "RemoteFunction")
end

return Networking