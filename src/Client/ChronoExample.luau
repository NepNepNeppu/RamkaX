local RamkaX = require(game.ReplicatedFirst.RamkaX)

local ChronoExample = RamkaX.CreateTask {Name = "ChronoExample"}

-- RamkaStart or RamkaInit can be excluded if unused 

-- RamkaX Tasks work exactly like a metatable, passing self as the table provided in CreateTask (line 3)
function ChronoExample:ExampleRequireFunction()
    print("ChronoExample used ExampleRequireFunction!")
end

function ChronoExample:RamkaInit()
    --[[
        RamkaX uses similar API as RunService events with a couple benefits:

        * Custom framerate, leaving the space blank or setting it 60 will run it at your devices framerate (120hz, 240hz, etc)
        * Delta time and Elapsed time are always provided (elapsedTime value is synced the server, and therefore syncs clients as well)
    ]]

    RamkaX.PostSimulation{ Framerate = 1 }:Connect(function(deltaTime, elapsedTime)
        print(deltaTime, elapsedTime)
    end)

    RamkaX.PreRender():Connect(function(deltaTime, elapsedTime)
        --
    end)
end

return ChronoExample
