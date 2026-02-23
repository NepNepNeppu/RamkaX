local RamkaX = require(game.ReplicatedFirst.RamkaX)

-- RamkaX will initialize tasks in the order they are registered, be sure to register your tasks.
RamkaX.RegisterTask(script.ServerNetworkingExample)

RamkaX.Start():andThen(function()
    print("Ramka Server Started!")
end):catch(warn)