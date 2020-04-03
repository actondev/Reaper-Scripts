local module = {}
local Class = require("aod.utils.class")
local Table = require("utils.table")
local Chars = require("aod.gui.v1.chars")
local Log = require("aod.utils.log")

module = {
    frame = 0,
    mouse = {
        x = 0,
        y = 0,
        px = 0,
        py = 0
    },
    modifiers = {
        none = true,
        control = false,
        alt = false,
        shit = false
    },
    SIGNALS = {
        MOUSE_ENTER = "mouseEnter",
        MOUSE_LEAVE = "mouseLeave",
        RETURN = "return"
    }
}

function module.pre_draw()
    module.char = gfx.getchar()
    module.mouse.x = gfx.mouse_x
    module.mouse.y = gfx.mouse_y
    -- if
    --     gfx.mouse_cap & 1 == 1 and last_mouse_cap & 1 == 0 or -- L mouse
    --         gfx.mouse_cap & 2 == 2 and last_mouse_cap & 2 == 0 or -- R mouse
    --         gfx.mouse_cap & 64 == 64 and last_mouse_cap & 64 == 0
    --  then -- M mouse
    --     mouse_ox, mouse_oy = gfx.mouse_x, gfx.mouse_y
    -- end

    module.modifiers.none = gfx.mouse_cap == 0
    module.modifiers.control = gfx.mouse_cap & 4 > 0
    module.modifiers.shift = gfx.mouse_cap & 8 > 0
    module.modifiers.alt = gfx.mouse_cap & 16 > 0
end

function module.post_draw()
    module.frame = module.frame + 1
    module.mouse.px = module.mouse.x
    module.mouse.py = module.mouse.y
end

module.Element = Class.create()
function module.Element:__construct(data)
    self.data = Table.deepcopy(data)
    self._watches = {}
    self._listeners = {}
end

local function contained(x, y, x0, y0, x1, y1)
    return x >= x0 and x <= x1 and y >= y0 and y <= y1
end

function module.Element:emit(signal, data)
    local listeners = self._listeners[signal]
    if listeners == nil then
        return
    end
    for _, callback in ipairs(listeners) do
        callback(self, data)
    end
end

function module.Element:hasListeners(signal)
    return self._listeners[signal] ~= nil
end

function module.Element:isMouseOver()
    local d = self.data
    return contained(module.mouse.x, module.mouse.y, d.x, d.y, d.x + d.w, d.y + d.h)
end

function module.Element:wasMouseOver()
    local d = self.data
    return contained(module.mouse.px, module.mouse.py, d.x, d.y, d.x + d.w, d.y + d.h)
end

function module.Element:watch(property, cb)
    if self._watches[property] == nil then
        self._watches[property] = {}
    end
    local watches = self._watches[property]
    watches[#watches + 1] = cb
end

function module.Element:on(signal, cb)
    if self._listeners[signal] == nil then
        self._listeners[signal] = {}
    end
    local listeners = self._listeners[signal]
    listeners[#listeners + 1] = cb
end

function module.Element:set(property, newValue)
    local d = self.data
    local oldValue = d[property]
    d[property] = newValue
    local watches = self._watches[property]
    if watches == nil then
        return
    end
    for _, callback in ipairs(watches) do
        callback(self, oldValue, newValue)
    end
end

-- draw a rect with a border width (bw)
-- the border is inset : the final rect will not be drawn outside of x,y and x+w, y+h
local function draw_border(x, y, w, h, width)
    if width == 0 then
        return
    end
    if width == 1 then
        gfx.rect(x, y, w, h, false)
    end
    -- if width > 1 then we call gfx.rect with the flag fill set to true
    -- left
    gfx.rect(x, y, width, h, true)
    -- right
    gfx.rect(x + w - width, y, width, h, true)
    -- top
    gfx.rect(x, y, w, width, true)
    -- right
    gfx.rect(x, y + h - width, w, width, true)
end

function module.Element:draw_border()
    local v = self.data.border
    gfx.r = v.r
    gfx.g = v.g
    gfx.b = v.b
    gfx.a = v.a or 1
    local width = v.width or 1

    local d = self.data
    draw_border(d.x, d.y, d.w, d.h, width)
end

function module.Element:draw_background()
    local bg = self.data.bg
    gfx.r = bg.r
    gfx.g = bg.g
    gfx.b = bg.b
    gfx.a = bg.a or 1

    local d = self.data
    gfx.rect(d.x, d.y, d.w, d.h, true) -- frame1
end

function module.Element:draw()
    -- Log.debug("draw id ", self.data.id)
    local d = self.data
    gfx.x = self.data.x
    gfx.y = self.data.y
    if d.bg then
        self:draw_background()
    end
    if d.border then
        self:draw_border()
    end

    -- if self:isMouseOver() and not self:wasMouseOver() then
    -- Log.debug("mouse enter", self.data.id)
    -- end
    local isMouseOver = self:isMouseOver()
    local wasMouseOver = self:wasMouseOver()

    if isMouseOver and not wasMouseOver then
        self:emit(module.SIGNALS.MOUSE_ENTER)
    end
    if not isMouseOver and wasMouseOver then
        self:emit(module.SIGNALS.MOUSE_LEAVE)
    end
end

--[[
    Button

    If no width (w) and height (h) are given, they will be calculated automatically

    TODO
    - calculate only w or h automatically (if one of the 2 is given)
]]
module.Button = Class.extend(module.Element)

function module.Button:_watch_width()
    self:watch(
        "text",
        function(el, ...)
            el:_calculate_height_width()
        end
    )
end

function module.Button:_calculate_height_width()
    local d = self.data
    gfx.setfont(1, d.font, d.fontSize) -- set label fnt
    local text_w, _ = gfx.measurestr(d.text)
    local _, text_h = gfx.measurestr(" ")
    d.h = text_h + 2 * (d.padding + d.border.width)
    d.w = text_w + 2 * (d.padding + d.border.width)
end
function module.Button:__construct(data)
    local defaults = {
        text = "",
        padding = 2,
        font = "Arial",
        fontSize = 14,
        border = {
            r = 1,
            g = 1,
            b = 1,
            width = 1
        },
        fg = {
            r = 1,
            g = 1,
            b = 1
        }
    }
    data = Table.merge(defaults, data)
    module.Element.__construct(self, data)

    if data.w == nil or data.h == nil then
        self:_watch_width()
        self:_calculate_height_width()
    end
end

function module.Button:draw()
    module.Element.draw(self)
    -- drawing text
    local d = self.data
    local x, y = d.x + d.padding + d.border.width, d.y + d.padding + d.border.width
    gfx.r = d.fg.r
    gfx.g = d.fg.g
    gfx.b = d.fg.b
    gfx.a = d.fg.a or 1

    gfx.setfont(1, d.font, d.fontSize)
    gfx.x = x
    gfx.y = y
    gfx.drawstr(d.text)
end

--[[
    Input
]]
module.Input = Class.extend(module.Button)
function module.Input:__construct(data)
    local defaults = {
        hasFocus = false
    }
    data = Table.merge(defaults, data)

    module.Button.__construct(self, data)
end

function module.Input:draw()
    if self.data.hasFocus then
        local c = module.char
        if Chars.isPrintable(c) then
            self:set("text", self.data.text .. string.char(c))
        elseif c == Chars.CHAR.RETURN then
            self:emit(module.SIGNALS.RETURN)
        end
    end

    module.Button.draw(self)
end

--[[
    Layout

    Layouts must implement the _advance function
    this sets in the temp self._layout the
    runx and runy variable, which is to be used as x and y for the next element
]]
module.ILayout = Class.extend(module.Element)

function module.ILayout:__construct(data)
    local defaults = {
        spacing = 5,
        -- the layout's height and width are calculated on each :draw call
        h = 0,
        w = 0,
        elements = {}
    }
    data = Table.merge(defaults, data)
    module.Element.__construct(self, data)
end

function module.ILayout:draw()
    module.Element.draw(self)
    local d = self.data
    self._layout = {
        h = 0,
        w = 0,
        runx = d.x,
        runy = d.y
    } -- storing temp layout values
    for i, el in ipairs(d.elements) do
        el:set("x", self._layout.runx)
        el:set("y", self._layout.runy)
        el:draw()
        self:_advance(el) -- layout implementations must implement this
    end
    self._layout = nil
end

module.VLayout = Class.extend(module.ILayout)
function module.VLayout:_advance(el)
    local d = self.data
    self._layout.runy = self._layout.runy + el.data.h + d.spacing
    self:set("h", self._layout.runy - d.spacing - self.data.y)
    self:set("w", math.max(d.w, el.data.w))
end

return module
