local module = {}
local Item = require("aod.reaper.item")
local Log = require("aod.utils.log")

module.itemSelection = function()
    local self = {state = nil}
    function self.init()
        self.state = Item.firstSelected()
        return self
    end
    function self.changed()
        local current = Item.firstSelected()
        if current == self.state then
            return false
        else
            self.state = current
            return true
        end
    end

    return self
end

module.activeTakeOffset = function()
    local self = {item = nil, offset = nil}
    function self.init()
        self.item = Item.firstSelected()
        self.offset = Item.getActiveTakeInfo(self.item, Item.TAKE_PARAM.START_OFFSET)
        return self
    end
    function self.changed()
        local item = Item.firstSelected()
        local offset = Item.getActiveTakeInfo(item, Item.TAKE_PARAM.START_OFFSET)
        if item == self.item and offset == self.offset then
            return false
        else
            self.item = item
            self.offset = offset
            return true
        end
    end

    return self
end

module.dummy = function()
    local self = {}
    function self.init()
        return self
    end
    function self.changed()
        return false
    end

    return self
end

module.never = function()
    local self = {}
    function self.init()
        return self
    end
    function self.changed()
        return false
    end

    return self
end

module.cursorPosition = function()
    local self = {state = nil}
    function self.init()
        self.state = reaper.GetCursorPosition()
        return self
    end
    function self.changed()
        local current = reaper.GetCursorPosition()
        if current == self.state then
            return false
        else
            self.state = current
            return true
        end
    end

    return self
end

module.every = function()
    local self = {every = nil, start = nil}
    function self.init()
        self.every = nil
        if interactive == nil then
            Log.warn("Need an interactive function to ask for amount of seconds")
            return
        end
        interactive(
            "nEvery x seconds",
            function(res)
                self.every = res
                self.start = os.clock()
            end
        )
        return self
    end
    function self.changed()
        if self.every == nil then
            return false
        end
        local t = os.clock()
        if t - self.start < self.every then
            return false
        else
            self.start = t
            return true
        end
    end

    return self
end

function module.getAll()
    return {
        {name = "On item selection change", handler = module.itemSelection()},
        {name = "On cursor position change", handler = module.cursorPosition()},
        {name = "On active take offset change", handler = module.activeTakeOffset()},
        {name = "On every x seconds", handler = module.every()}
    }
end

return module
