local RunService = game:GetService("RunService")
local Janitor = require(script.Parent.Parent.Library.Janitor)

export type chronoProperties = {
    Name: string,
    FrameRate: number,
}

export type chronoEvent = {
    deltaTime: number,
    elapsedTime: number,
}

local ChronoType = {}
ChronoType.__index = ChronoType
    
function ChronoType.new(chronoType, chronoProperties)
    local self = setmetatable({
        Name = chronoProperties.Name,
        FrameRate = chronoProperties.FrameRate,
    }, ChronoType)

    RunService.chronoType:Connect(function(deltaTime)
        
    end)

    return self
end

local Chrono

function Chrono.Heartbeat(chronoProperties: chronoProperties): RBXScriptConnection
    
end

return Chrono