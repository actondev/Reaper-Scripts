--[[
    Text input module
    Handling cursor position and signals like backspace, left right arrows

    TODO
    - selection
]]
local Table = require("aod.utils.table")
local Chars = require("aod.gui.v1.chars")
local Class = require("aod.utils.class")
local Log = require("aod.utils.log")

local defaultMods = {
    {
        control = false,
        alt = false,
        shit = false
    }
}

local module = Class.new()

function module:__construct(data)
    if type(data) == "string" then
        self.data = {
            text = data,
            cursor = string.len(data)
        }
    elseif type(data) == "table" then
        self.data = Table.copy(data)
    end
end

function module:getPreviousCursor()
    return math.max(0, self.data.cursor - 1)
end

function module:handleLeft()
    self.data.cursor = self:getPreviousCursor()
end

function module:handleHome()
    self.data.cursor = 0
end

function module:getNextCursor()
    return math.min(self.data.text:len(), self.data.cursor + 1)
end

function module:handleRight()
    self.data.cursor = self:getNextCursor()
end

function module:handleEnd()
    self.data.cursor = self.data.text:len()
end

function module:handleBackspace()
    local d = self.data
    -- Log.debug("curs,", d.cursor)
    local left = d.text:sub(0, self:getPreviousCursor())
    -- Log.debug("left ", left, 0, self:getPreviousCursor())
    local right = d.text:sub(self.data.cursor + 1, d.text:len())
    -- Log.debug("right ", right, self.data.cursor+1, d.text:len())

    self:handleLeft()
    self.data.text = left .. right
end

function module:handeDelete()
    local d = self.data
    local left = d.text:sub(0, self.data.cursor)
    local right = d.text:sub(self:getNextCursor() + 1, d.text:len())

    self.data.text = left .. right
end

function module:left()
    local d = self.data
    return d.text:sub(0, d.cursor)
end

function module:right()
    local d = self.data
    return d.text:sub(d.cursor + 1, d.text:len())
end

function module:insert(str)
    self.data.text = self:left() .. str .. self:right()
    self.data.cursor = self.data.cursor + str:len()
end

local actions = {
    [Chars.CHAR.BACKSPACE] = module.handleBackspace,
    [Chars.CHAR.LEFT] = module.handleLeft,
    [Chars.CHAR.RIGHT] = module.handleRight,
    [Chars.CHAR.DELETE] = module.handeDelete,
    [Chars.CHAR.HOME] = module.handleHome,
    [Chars.CHAR.END] = module.handleEnd
}

function module:handle(c, mods)
    if c == 0 then
        return
    end
    mods = Table.merge(defaultMods, mods or {})

    if Chars.isPrintable(c) then
        self:insert(string.char(c))
    elseif actions[c] then
        actions[c](self)
    else
        Log.debug("unkown action", c)
    end
end

function module:getText()
    return self.data.text
end

function module:getCursor()
    return self.data.cursor
end

function module:getTextWithCursor()
    return self:left() .. "|" .. self:right()
end

return module
