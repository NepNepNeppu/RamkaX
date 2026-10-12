local RamkaX = require(game.ReplicatedFirst.RamkaX)

RamkaX.RegisterTask(script.ServerNetworkingExample)

RamkaX.Start():andThen(function()
    print("Ramka Server Started!")
end):catch(warn)