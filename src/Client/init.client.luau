local RamkaX = require(game.ReplicatedFirst.RamkaX)

-- RamkaX will initialize tasks in the order they are registered, be sure to register your tasks.
-- Be careful when requiring other tasks, as RamkaX may register the task out of order, in which case you
-- can do RamkaX.GetTask("TaskName") to get the task before it's registered (will return nil if ramka is initializing).
RamkaX.RegisterTask(script.ClientNetworkingExample)
RamkaX.RegisterTask(script.BasicTask)
RamkaX.RegisterTask(script.ChronoExample)

RamkaX.Start():andThen(function()
    print("Ramka Client Started!")
end):catch(warn)