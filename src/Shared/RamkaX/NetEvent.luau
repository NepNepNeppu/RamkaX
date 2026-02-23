local IsClient = game:GetService("RunService"):IsClient()

local function addinstance(instance: string, name: string, parent: Instance)
    local Item = Instance.new(instance)
    Item.Name = name
    Item.Parent = parent
    return Item
end

local function getNetworkingStorage()
    if IsClient then
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

    if IsClient then
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

local NetEvent = {}
NetEvent.__index = NetEvent

function NetEvent.new(remoteEventName: string)
    local signal : RemoteEvent = createNew(remoteEventName, "RemoteEvent")
    
    local self = setmetatable({
        Signal = signal,
    }, NetEvent)

    return self
end

-- Shorthand for NetEvent.new(remoteEventName):Connect(fn)
function NetEvent.OnSignal(remoteSignalName: string, fn : (any) -> ()) : (typeof(NetEvent.new()), RBXScriptConnection)
    local signal = NetEvent.new(remoteSignalName)
    return signal, signal:Connect(fn)
end

-- Shorthand for RemoteEvent.OnServerEvent or RemoteEvent.OnClientEvent
function NetEvent:Connect(fn : (any) -> ()) : RBXScriptConnection
    if IsClient then
        return self.Signal.OnClientEvent:Connect(fn)
    else
        return self.Signal.OnServerEvent:Connect(fn)
    end
end

if IsClient then
    -- (Client) FireServer
    function NetEvent:Send(...)
        self.Signal:FireServer(...)
    end
else
    -- (Server) FireClient
    function NetEvent:Send(player: Player, ...)
        self.Signal:FireClient(player, ...)
    end

    -- (Server) FireAllClients
    function NetEvent:SendAll(...)
        self.Signal:FireAllClients(...)
    end
end

return NetEvent