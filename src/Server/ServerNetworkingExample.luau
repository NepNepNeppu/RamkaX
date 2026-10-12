local RamkaX = require(game.ReplicatedFirst.RamkaX)

local ServerTest = RamkaX.CreateTask {Name = "ServerTest"}

function ServerTest:RamkaInit()
    --[[
    Be sure to initialize Events and Functions on the server because the client
    cannot create them. It's best to either define them as a variable or create
    it inside of RamkaInit for immediate creation. Simply doing RamkaX.Event.new("EventName") 
    is enough

    RamkaX provides you with shorthands for connecting to RemoteEvent (OnServerEvent, OnClientEvent) and
    RemoteFunction Invoke Callbacks (OnServerInvoke, OnClientInvoke), or simply just OnEvent and OnInvoke 
    respectively.
    ]]

    RamkaX.Event.OnEvent("ServerEventTest", function(Player: Player, signal)
        print(`Server Processing: {signal}`)

        RamkaX.Event.new("ServerEventTest"):Send(Player, `Received: {signal}`)
    end)
    
    RamkaX.Function.OnInvoke("SpecialFunction", function(Player: Player)
        return `SpecialFunction: Hello, {Player.Name}!`
    end)
end

return ServerTest
