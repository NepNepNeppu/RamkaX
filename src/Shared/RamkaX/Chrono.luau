local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Janitor = require(script.Parent.Parent.Library.Janitor)
local Signal = require(script.Parent.Parent.Library.Signal)

export type ChronoProperties = {
    Name: string?,
    FrameRate: number?,
}

export type ChronoClass = {
    Name: string,
    FrameRate: number,
    isServerTime: boolean,
    Destroy: () -> nil,
    Connect: (self: ChronoClass, deltaTime: number, elapsedTime: number) -> () -> ChronoClass,
}

export type ChronoConstructor = (props: ChronoProperties) -> ChronoClass

export type ChronoTypes = "Heartbeat" | "Stepped" | "RenderStepped"

-- Chrono class
local ChronoType = {}
ChronoType.__index = ChronoType

function ChronoType.new(chronoType: ChronoTypes, props: ChronoProperties): ChronoClass
    local self = setmetatable({
        Name = props.Name or HttpService:GenerateGUID(false),
        FrameRate = props.FrameRate or 60,

        _initServerTime = (game.Workspace:GetServerTimeNow() - script.Parent:GetAttribute("ServerTimeNow")),
        _accumulatedServerTime = 0,
        _accumulatedTime = 0,

        Chrono = Janitor.new(),
        Signal = Signal.new(),
    }, ChronoType)

    local targetDt = 1 / self.FrameRate

    self.Chrono:Add(RunService[chronoType]:Connect(function(dt)
        self._accumulatedServerTime += dt

        if self.FrameRate >= 60 then
            self.Signal:Fire(dt, self:now())
            return
        end

        self._accumulatedTime += dt

        if self._accumulatedTime >= targetDt then
            self.Signal:Fire(self._accumulatedTime, self:now())
            self._accumulatedTime -= targetDt
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
    return self._initServerTime + self._accumulatedServerTime
end

-- Chrono
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