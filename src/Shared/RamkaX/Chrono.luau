local RunService = game:GetService("RunService")

local Common = game.ReplicatedFirst.Common
local Utility = Common.Utility

local Janitor = require(Utility.Janitor)
local Signal = require(Utility.Signal)

export type ChronoProperties = {
    Framerate: number?,
}

export type ChronoClass = {
    Framerate: number,
    isServerTime: boolean,

    Destroy: () -> nil,
    Connect: (self: ChronoClass, deltaTime: number, elapsedTime: number) -> () -> ChronoClass,
    now: () -> number,
}

export type ChronoConstructor = (props: ChronoProperties) -> ChronoClass

export type ChronoTypes = "PreRender" | "PostSimulation" | "PreAnimation" | "PreSimulation"

-- Private
local ChronoType = {}
ChronoType.__index = ChronoType

function ChronoType.new(chronoType: ChronoTypes, props: ChronoProperties): ChronoClass
    local self = setmetatable({
        Framerate = props.Framerate or 60,

        _localClock = os.clock(),
        _accumulatedDelta = 0,

        _serverTime = (game.Workspace:GetServerTimeNow() - script.Parent:GetAttribute("ServerTimeNow")),

        _Chrono = Janitor.new(),
        _Signal = Signal.new(),
    }, ChronoType)

    local targetDt: number = 1 / self.Framerate

    self._Chrono:Add(RunService[chronoType]:Connect(function(dt)
        self._accumulatedDelta += dt

        if self.Framerate >= 60 then
            self._Signal:Fire(dt, self:now())
            return
        end

        if self._accumulatedDelta >= targetDt then
            self._Signal:Fire(self._accumulatedDelta, self:now())
            self._accumulatedDelta -= targetDt
        end
    end))

    return self
end

function ChronoType:Connect(fn: (deltaTime: number, elapsedTime: number) -> ()) : ChronoClass
    return self._Signal:Connect(fn)
end

function ChronoType:Destroy(): nil
    self._Signal:Destroy()
    self._Chrono:Destroy()
end

function ChronoType:now(): number
    return self._serverTime + (os.clock() - self._localClock)
end

-- Public
local Chrono = {}

function Chrono.PreRender(props: ChronoProperties): ChronoClass
    if RunService:IsClient() then
        return ChronoType.new("PreRender", props or {})
    else
        warn("PreRender is not supported on the server. Defaulting to PostSimulation.")
        return ChronoType.new("PostSimulation", props or {})
    end
end

function Chrono.PreAnimation(props: ChronoProperties): ChronoClass
    return ChronoType.new("PreAnimation", props or {})
end

function Chrono.PreSimulation(props: ChronoProperties): ChronoClass
    return ChronoType.new("PreSimulation", props or {})
end

function Chrono.PostSimulation(props: ChronoProperties): ChronoClass
    return ChronoType.new("PostSimulation", props or {})
end

return Chrono