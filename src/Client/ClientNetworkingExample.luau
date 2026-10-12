local RamkaX = require(game.ReplicatedFirst.RamkaX)

local FirstTest = RamkaX.CreateTask {
    Name = "FirstTest",

    RemoteEventNote = "Remote Event Signal!"
}

function FirstTest:RemoteEvent()
    -- self.RemoteEventNote refers to "RemoteEventNote" inside the CreateTask table
    RamkaX.Event.new("ServerEventTest"):Send(self.RemoteEventNote)

    -- Sugar for RemoteEvent.OnClientEvent where you specify the remote and resulting action
    RamkaX.Event.OnEvent("ServerEventTest", function(Player: Player, signal)
        print(`{signal}`)
    end)
end

function FirstTest:RamkaStart()
    -- RamkaX provides you with simple networking API for RemoteEvents and RemoteFunctions.

    self:RemoteEvent()

    -- RemoveFunction, print result
    print(RamkaX.Function.new("SpecialFunction"):Invoke())
end

function FirstTest:RamkaInit()
    
end

return FirstTest
