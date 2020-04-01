local module = {}
local Item = require("utils.item")

module.itemSelectionChange = function()
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

return module
