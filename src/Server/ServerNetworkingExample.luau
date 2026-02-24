local RamkaX = require(game.ReplicatedFirst.RamkaX)

local ServerTest = RamkaX.CreateTask {Name = "ServerTest"}

function ServerTest:RamkaStart()

end

function ServerTest:RamkaInit()
    --[[
    Be sure to initialize your Events and Functions on the server so the client can access them.
    Simply doing RamkaX.Event.new("EventName") or RamkaX.Function.new("FunctionName") on the server is enough.

    RamkaX provides you with shorthands for connecting to RemoteEvents RbxScriptConnections (OnServerEvent, OnClientEvent) and
    RemoteFunctions Invoke Callbacks (OnServerInvoke, OnClientInvoke), automatically using the appropriate method or connection.
    ]]
    RamkaX.Event.OnSignal("SpecialSignal", function(player, signal)
        print(`SpecialSignal: Received {signal} from {player.Name}`)
    end)
    
    RamkaX.Function.OnCallback("SpecialFunction", function(player)
        return `SpecialFunction: Hello, {player.Name}!`
    end)
end

return ServerTest
