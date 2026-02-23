local RamkaX = require(game.ReplicatedFirst.RamkaX)

local ClientChronoExample = RamkaX.CreateTask {Name = "ClientChronoExample"}

function ClientChronoExample:RamkaStart()
    
end

function ClientChronoExample:RamkaInit()
    --[[
        RamkaX uses similar API as RunService events with a few benefits:

        * Custom framerate, 60 or nil will run as the standard RunService event
        * Always have deltaTime and elapsedTime provided (elapsedTime value will be similar across all clients)
    ]]

    RamkaX.PostSimulation {
        FrameRate = 1,
    }:Connect(function(deltaTime, elapsedTime)
        print(deltaTime, elapsedTime)
    end)
end

return ClientChronoExample
