local RamkaX = require(game.ReplicatedFirst.RamkaX)

RamkaX.RegisterTask(script.FirstTest)

RamkaX.Start():andThen(function()
    print("Ramka Client Started!")
end):catch(warn)