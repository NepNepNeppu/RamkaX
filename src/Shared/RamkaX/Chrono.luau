local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Janitor = require(script.Parent.Parent.Library.Janitor)
local Signal = require(script.Parent.Parent.Library.Signal)

-- Types
export type ChronoProperties = {
    Name: string,
    FrameRate: number?,       -- target FPS
    isServerTime: boolean?,
}

export type ChronoClass = {
    Name: string,
    FrameRate: number,
    isServerTime: boolean,
    Destroy: () -> nil,
    Connect: (self: ChronoClass, deltaTime: number, elapsedTime: number) -> () -> ChronoClass,
}

-- The constructor type
export type ChronoConstructor = (props: ChronoProperties) -> ChronoClass

export type ChronoTypes = "Heartbeat" | "Stepped" | "RenderStepped"

-- ChronoType class
local ChronoType = {}
ChronoType.__index = ChronoType

function ChronoType.new(chronoType: ChronoTypes, props: ChronoProperties): ChronoClass
    local self = setmetatable({
        Name = props.Name or HttpService:GenerateGUID(false),
        FrameRate = props.FrameRate or 60,
        isServerTime = props.isServerTime or false,

        _accumulatedTime = 0,
        _lastTime = 0,

        Chrono = Janitor.new(),
        Signal = Signal.new(),
    }, ChronoType)

    self._lastTime = self:now()

    local targetDt = 1 / self.FrameRate

    self.Chrono:Add(RunService[chronoType]:Connect(function(dt)
        if self.FrameRate == 60 then
            self.Signal:Fire(dt, self:now())
            return
        end

        local now = self:now()
        local frameDelta = now - self._lastTime
        self._lastTime = now

        self._accumulatedTime += frameDelta

        while self._accumulatedTime >= targetDt do
            self._accumulatedTime -= targetDt
            self.Signal:Fire(targetDt, now)
        end
    end))

    return self
end

function ChronoType:Connect(fn: (deltaTime: number, elapsedTime: number) -> ()) : ChronoClass
    self.Signal:Connect(fn)
    return self
end

function ChronoType:Destroy()
    self.Signal:Destroy()
    self.Chrono:Destroy()
end

function ChronoType:now(): number
    if self.isServerTime then
        return game.Workspace:GetServerTimeNow()
    else
        return os.clock()
    end
end

-- Chrono module
local Chrono = {}

function Chrono.PreRender(props: ChronoProperties): ChronoClass
    if RunService:IsClient() then
        return ChronoType.new("RenderStepped", props or {})
    else
        warn("PreRender is not supported on the server. Defaulting to Stepped.")
        return ChronoType.new("Heartbeat", props or {})
    end
end

function Chrono.PreAnimation(props: ChronoProperties): ChronoClass
    return ChronoType.new("Stepped", props or {})
end

function Chrono.PreSimulation(props: ChronoProperties): ChronoClass
    return ChronoType.new("PreSimulation", props or {})
end

function Chrono.PostSimulation(props: ChronoProperties): ChronoClass
    return ChronoType.new("PostSimulation", props or {})
end

return Chrono