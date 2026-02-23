local RamkaX = require(game.ReplicatedFirst.RamkaX)

-- RamkaX will initialize tasks in the order they are registered, be sure to register your tasks.
RamkaX.RegisterTask(script.ClientNetworkingExample)
RamkaX.RegisterTask(script.ChronoExample)

RamkaX.Start():andThen(function()
    print("Ramka Client Started!")
end):catch(warn)