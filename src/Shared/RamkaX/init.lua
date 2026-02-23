local Library = script.Parent.Library
local Resources = script.Parent.Resources

local Promise = require(Library.Promise)

-- RamkaX internal definitions
local _registerCache = {}
local _initCache = {
    started = false,
    completed = false,
    onComplete = Instance.new("BindableEvent"),
    preregisteredTasks = {},
    taskCache = {}
}

local RamkaX = {}

    RamkaX.Library = Library
    RamkaX.Resources = Resources
    
    function RamkaX.Heartbeat(chronoProperties)
        
    end

    function RamkaX.CreateTask(taskDefinition)
        assert(type(taskDefinition) == "table", "Task definition must be a table.")
        assert(type(taskDefinition.Name) == "string", "Task definition must have a name.")

        local hasTask = table.find(_initCache.preregisteredTasks, taskDefinition)
        if hasTask then
            return _initCache.preregisteredTasks[hasTask]
        end

        table.insert(_initCache.preregisteredTasks, taskDefinition)
        return taskDefinition
    end

    function RamkaX.RegisterTask(taskDefinition)
        assert(type(taskDefinition) == "table", "Task definition must be a table.")
        assert(type(taskDefinition.Name) == "string", "Task definition must have a name.")

        table.insert(_registerCache, taskDefinition)
        return taskDefinition
    end

    --[=[
        @return Promise
        Starts RamkaX. Should only be called once.
        ```lua
        Ramka.Start():andThen(function()
            print("Ramka started!")
        end):catch(warn)
        ```
    ]=]
    function RamkaX.Start()
        if _initCache.started then
            return Promise.reject("Ramka already started")
        end
    
        _initCache.started = true

        debug.setmemorycategory("RamkaX")

        return Promise.new(function(resolve)
            -- Init:
            local promisesStartTasks = {}
    
            for _, ramkatask in _registerCache do
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
            for _, ramkatask in _registerCache do
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
            return Promise.fromEvent(_initCache.onComplete.Event)
        end
    end

return RamkaX