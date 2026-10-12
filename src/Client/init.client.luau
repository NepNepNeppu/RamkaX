local RamkaX = require(game.ReplicatedFirst.RamkaX)

-- RamkaX will initialize tasks in the order they are registered, first doing 
-- the RamkaInit pass (yielding) and then RamkaStart (not yielding). 

-- Be sure to register your tasks!

RamkaX.RegisterTask(script.ClientNetworkingExample)
RamkaX.RegisterTask(script.BasicTask)
RamkaX.RegisterTask(script.ChronoExample)

RamkaX.Start():andThen(function()
    print("Ramka Client Started!")
end):catch(warn)