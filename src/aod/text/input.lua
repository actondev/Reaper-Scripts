--[[
    Text input module
    Handling cursor position and signals like backspace, left right arrows

    TODO
    - selection
]]
local Table = require("aod.utils.table")
local Chars = require("aod.text.chars")
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

function module:_getPreviousCursor()
    return math.max(0, self.data.cursor - 1)
end

function module:_handleLeft()
    self.data.cursor = self:_getPreviousCursor()
end

function module:_handleHome()
    self.data.cursor = 0
end

function module:_getNextCursor()
    return math.min(self.data.text:len(), self.data.cursor + 1)
end

function module:_handleRight()
    self.data.cursor = self:_getNextCursor()
end

function module:_handleEnd()
    self.data.cursor = self.data.text:len()
end

function module:_handleBackspace()
    local d = self.data
    -- Log.debug("curs,", d.cursor)
    local left = d.text:sub(0, self:_getPreviousCursor())
    -- Log.debug("left ", left, 0, self:getPreviousCursor())
    local right = d.text:sub(self.data.cursor + 1, d.text:len())
    -- Log.debug("right ", right, self.data.cursor+1, d.text:len())

    self:_handleLeft()
    self.data.text = left .. right
end

function module:_handeDelete()
    local d = self.data
    local left = d.text:sub(0, self.data.cursor)
    local right = d.text:sub(self:_getNextCursor() + 1, d.text:len())

    self.data.text = left .. right
end

function module:textLeftOfCursor()
    local d = self.data
    return d.text:sub(0, d.cursor)
end

function module:textRightOfCursor()
    local d = self.data
    return d.text:sub(d.cursor + 1, d.text:len())
end

function module:insert(str)
    self.data.text = self:textLeftOfCursor() .. str .. self:textRightOfCursor()
    self.data.cursor = self.data.cursor + str:len()
end

local actions = {
    [Chars.CHAR.BACKSPACE] = module._handleBackspace,
    [Chars.CHAR.LEFT] = module._handleLeft,
    [Chars.CHAR.RIGHT] = module._handleRight,
    [Chars.CHAR.DELETE] = module._handeDelete,
    [Chars.CHAR.HOME] = module._handleHome,
    [Chars.CHAR.END] = module._handleEnd
}

-- @param c : ascii int code (eg 0 = null code, 27 = escape)
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
        -- Log.debug("unkown action", c)
    end
end

function module:getText()
    return self.data.text
end

function module:getCursor()
    return self.data.cursor
end

function module:getTextWithCursor()
    return self:textLeftOfCursor() .. "|" .. self:textRightOfCursor()
end

return module
