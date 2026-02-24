local RamkaX = require(game.ReplicatedFirst.RamkaX)

local FirstTest = RamkaX.CreateTask {Name = "FirstTest"}

function FirstTest:RamkaStart()
    --[[
    Although not the cleanest API, Ramka provides you with simple networking API for RemoteEvents and RemoteFunctions.
    ]]
    RamkaX.Event.new("SpecialSignal"):Send("Secret Signal!")

    local specialSignal = RamkaX.Function.new("SpecialFunction"):Invoke()
    print(specialSignal)
end

function FirstTest:RamkaInit()
    
end

return FirstTest
