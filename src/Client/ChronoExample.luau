local RamkaX = require(game.ReplicatedFirst.RamkaX)

local ChronoExample = RamkaX.CreateTask {Name = "ChronoExample"}

function ChronoExample:RamkaStart()
    
end

function ChronoExample:RamkaInit()
    --[[
        RamkaX uses similar API as RunService events with a couple benefits:

        * Custom framerate, 60 or nil will run as the standard RunService event
        * Always have deltaTime and elapsedTime provided (elapsedTime value is synced across clients and server)
    ]]

    RamkaX.PostSimulation {
        FrameRate = 1,
    }:Connect(function(deltaTime, elapsedTime)
        print(deltaTime, elapsedTime)
    end)
end

return ChronoExample
