local RamkaX = require(game.ReplicatedFirst.RamkaX)

-- RamkaX can require tasks out of order and not cause register ordering issues.
local ChronoExample = require(script.Parent.ChronoExample)

local BasicTask = RamkaX.CreateTask {
    Name = "BasicTask",

    SimpleVariable = "Hello, world!",
}

--[[
Yielding code inside will not stop other tasks from starting.

RamkaStart follows the completion of RamkaInit
]]
function BasicTask:RamkaStart()
    print(self.SimpleVariable)
    print(ChronoExample.Name)
end

--[[
RamkaInit will yield the initialization process of RamkaX.

RamkaInit runs first in the RamkaX pipeline.
]]
function BasicTask:RamkaInit()
    
end

return BasicTask
