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

local NetFunction = {}
NetFunction.__index = NetFunction

function NetFunction.new(remoteEventName: string)
    local signal : RemoteFunction = createNew(remoteEventName, "RemoteFunction")

    local self = setmetatable({
        Signal = signal,
    }, NetFunction)

    return self
end

-- Shorthand for NetFunction.new(remoteSignalName):Bind(fn)
function NetFunction.OnCallback(remoteSignalName: string, fn : (any) -> ()) : typeof(NetFunction.new())
    local signal = NetFunction.new(remoteSignalName)
    signal:Bind(fn)
    return signal
end

-- Shorthand for RemoteFunction.OnClientInvoke or RemoteFunction.OnServerInvoke
function NetFunction:Bind(fn : (any) -> ())
    if IsClient then
        self.Signal.OnClientInvoke = fn
    else
        self.Signal.OnServerInvoke = fn
    end
end

if IsClient then
    -- (Client) Client > Server > Client
    function NetFunction:Invoke(...)
        return self.Signal:InvokeServer(...)
    end
else
    --[[
    (Server) Server > Client > Server

    Check for edge cases where the client may have left
    ]]
    function NetFunction:Invoke(...)
        return self.Signal:InvokeServer(...)
    end
end

return NetFunction