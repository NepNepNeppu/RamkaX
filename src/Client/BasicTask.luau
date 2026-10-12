local RamkaX = require(game.ReplicatedFirst.RamkaX)

-- Other Tasks can be required like a normal.
local ChronoExample = require(script.Parent.ChronoExample)

local BasicTask = RamkaX.CreateTask {
    Name = "BasicTask",

    SimpleVariable = "Hello, world!",
}

--[[
Follows after all RamkaInit finish and will not yield succeeding code.
]]
function BasicTask:RamkaStart()
    print(self.SimpleVariable)
    print(ChronoExample.Name)
end

--[[
RamkaInit will run first in the bootstrapper and can yield succeding succeeding code.
]]
function BasicTask:RamkaInit()
    -- You can reference methods from other Tasks
    ChronoExample:ExampleRequireFunction()
end

return BasicTask
