local Common = game.ReplicatedFirst.Common
local Library = Common.Library
local Resources = Common.Resources

local Chrono = require(script.Chrono)

local NetEvent = require(script.NetEvent)
local NetFunction = require(script.NetFunction)

local Signal = require(Resources.Signal)
local Promise = require(Resources.Promise)

-- RamkaX internal definitions
local _initCache = {
    started = false,
    completed = false,
    onComplete = Signal.new(),
    preregisteredTasks = {},
    taskCache = {}
}

export type taskDefinition = {
    Name: string,
}

local function ramkax_registertask(ModuleScript: ModuleScript)
    local success, result = pcall(function()
        return require(ModuleScript)
    end)

    if success then
        -- _initCache.preregisteredTasks[ModuleScript.Name] = result
        table.insert(_initCache.taskCache, result)
    else
        warn(("RamkaX: %s ran into an error while registering: %s"):format(ModuleScript.Name, result))
    end
end

local RamkaX = {}

    -- Quick access to client folder
    RamkaX.Client = game.StarterPlayer.StarterPlayerScripts.Client
    -- Quick access to server folder
    RamkaX.Server = game.ServerScriptService:FindFirstChild("Server")

    RamkaX.DebugPoint = function(vect3, lifetime, size)
        local p = Instance.new("Part")
        p.Size = Vector3.one * (size or .2)
        p.Anchored = true
        p.CanCollide = false
        p.CastShadow = false
        p.Transparency = .5
        p.Position = vect3
        p.Shape = Enum.PartType.Ball
        p.Parent = game.Workspace
        game:GetService("Debris"):AddItem(p, lifetime or .2)
    end

    RamkaX.Common = Common
    RamkaX.Library = Library -- Built in Storage
    RamkaX.Resources = Resources -- Built into Ramka

    -- RemoteEvent class for networking communication
    RamkaX.Event = NetEvent
    -- RemoteFunction class for networking communication
    RamkaX.Function = NetFunction

    --[[
    [1st] Client side only, this event allows you to run code and update the world before it's drawn on
    a player's screen. This is useful for last‑minute adjustments such as changing object positions,
    updating animations, or preparing visual effects, but it should be used sparingly as the engine
    cannot start to render the frame until code running in this event has finished executing.
    ]]
    RamkaX.PreRender = Chrono.PreRender :: Chrono.ChronoConstructor
    --[[
    [2nd] This event is useful for modifying animation objects, such as adjusting their speed or priority.
    Once the PreAnimation event is complete, the engine proceeds to run these animations, updating the joint
    transforms which will later be used to update objects during the physics simulation.
    ]]
    RamkaX.PreAnimation = Chrono.PreAnimation :: Chrono.ChronoConstructor
    --[[
    [3rd] This event is useful for adjusting properties like velocity or forces just before they're
    applied as part of the simulation. The simulation then runs, potentially multiple times, as the
    physics solver runs at a higher frequency than other engine systems. Once this is complete,
    the PostSimulation event is fired.
    ]]
    RamkaX.PreSimulation = Chrono.PreSimulation :: Chrono.ChronoConstructor
    --[[
    [4th] This event is useful for making final adjustments to the outcome of the simulation.
    Following this phase, the engine triggers the Heartbeat event.
    ]]
    RamkaX.PostSimulation = Chrono.PostSimulation :: Chrono.ChronoConstructor

    -- Formats table into a metatable that can be used and initialized as a RamkaX task.
    function RamkaX.CreateTask(taskDefinition: taskDefinition) : taskDefinition
        assert(type(taskDefinition) == "table", "Task definition must be a table.")
        assert(type(taskDefinition.Name) == "string", "Task definition must have a name.")

        if _initCache.preregisteredTasks[taskDefinition.Name] then
            return _initCache.preregisteredTasks[taskDefinition.Name]
        end

        _initCache.preregisteredTasks[taskDefinition.Name] = taskDefinition
        return _initCache.preregisteredTasks[taskDefinition.Name]
    end

    function RamkaX.GetTask(taskName)
        return _initCache.preregisteredTasks[taskName]
    end

    -- Register the task into RamkaX initialization. Can Yield.
    function RamkaX.RegisterTask(ModuleScript: ModuleScript)
        assert(typeof(ModuleScript) == "Instance" and ModuleScript:IsA("ModuleScript"), "RegisterTask expects a ModuleScript.")

        ramkax_registertask(ModuleScript)
    end

    --[=[
        @return Promise
        Starts RamkaX. Should only be called once.
        ```lua
        RamkaX.Start():andThen(function()
            print("RamkaX started!")
        end):catch(warn)
        ```
    ]=]
    function RamkaX.Start()
        if _initCache.started then
            return Promise.reject("Ramka already started")
        end

        if game:GetService("RunService"):IsServer() then
            script:SetAttribute("ServerTimeNow", game.Workspace:GetServerTimeNow())
        end
    
        _initCache.started = true

        debug.setmemorycategory("RamkaX")

        -- table.freeze(_initCache.preregisteredTasks)

        return Promise.new(function(resolve)
            -- Init:
            local promisesStartTasks = {}
    
            for _, ramkatask in _initCache.taskCache do
                if ramkatask.RamkaInit and type(ramkatask.RamkaInit) == "function" then
                    table.insert(
                        promisesStartTasks,
                        Promise.new(function(r)
                            debug.setmemorycategory("RamkaX/Init/"..ramkatask.Name)
                            ramkatask:RamkaInit()
                            r()
                        end)
                    )
                end
            end
    
            resolve(Promise.all(promisesStartTasks))
        end):andThen(function()
            -- Start:
            for _, ramkatask in _initCache.taskCache do
                if ramkatask.RamkaStart and type(ramkatask.RamkaStart) == "function" then
                    task.spawn(function()
                        debug.setmemorycategory("RamkaX/Start/"..ramkatask.Name)
                        ramkatask:RamkaStart()
                    end)
                end
            end
    
            _initCache.completed = true
            _initCache.onComplete:Fire()
    
            task.defer(function()
                _initCache.onComplete:Destroy()
            end)
        end)
    end

    --[=[
        @return Promise
        Returns a promise that is resolved once RamkaX has started. This is useful
        for any code that needs to tie into RamkaX tasks but is not the scripts
        that are called using `Start`.
        ```lua
        RamkaX.OnStart():andThen(function()

        end):catch(warn)
        ```
    ]=]
    function RamkaX.OnStart()
        if _initCache.completed then
            return Promise.resolve()
        else
            return Promise.try(function()
                _initCache.onComplete:Wait()
            end)
        end
    end
    

return RamkaX