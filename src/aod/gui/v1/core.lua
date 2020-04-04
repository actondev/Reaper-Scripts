local module = {}
local Class = require("aod.utils.class")
local Table = require("utils.table")
local Chars = require("aod.text.chars")
local Text = require("aod.text.input")
local Log = require("aod.utils.log")

module = {
    frame = 0,
    cap = 0, -- the current mouse_cap
    pcap = 0, -- the previous mouse_cap
    CAP = {
        NONE = 0,
        LMB = 1, -- left mouse button
        RMB = 2, -- right mouse button
        MMB = 64, -- middle mouse button
        COMMAND = 4,
        SHIFT = 8,
        OPTION = 16,
        ALT = 16,
        CONTROL = 32
    },
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
        RETURN = "return",
        CLICK = "click"
    }
}

function module.pre_draw()
    module.char = gfx.getchar()
    module.mouse.x = gfx.mouse_x
    module.mouse.y = gfx.mouse_y
    module.cap = gfx.mouse_cap
    -- if
    --     gfx.mouse_cap & 1 == 1 and last_mouse_cap & 1 == 0 or -- L mouse
    --         gfx.mouse_cap & 2 == 2 and last_mouse_cap & 2 == 0 or -- R mouse
    --         gfx.mouse_cap & 64 == 64 and last_mouse_cap & 64 == 0
    --  then -- M mouse
    --     mouse_ox, mouse_oy = gfx.mouse_x, gfx.mouse_y
    -- end

    module.modifiers.none = module.cap == module.CAP.NONE
    module.modifiers.control = module.cap & module.CAP.CONTROL > 0
    module.modifiers.shift = module.cap & module.CAP.SHIFT > 0
    module.modifiers.alt = module.cap & module.CAP.ALT > 0
end

function module.post_draw()
    module.frame = module.frame + 1
    module.mouse.px = module.mouse.x
    module.mouse.py = module.mouse.y
    module.pcap = module.cap
end

module.Element = Class.create()
function module.Element:__construct(data)
    local defaults = {
        x = 0,
        y = 0,
        w = 0,
        h = 0,
        padding = 0
    }
    data = Table.merge(defaults, data)
    self.data = Table.deepcopy(data)
    self._watches = {}
    self._listeners = {}
end

local function contained(x, y, x0, y0, x1, y1)
    return x >= x0 and x <= x1 and y >= y0 and y <= y1
end

function module.Element:hasSignalListeners(signal)
    return self._listeners[signal] ~= nil
end

function module.Element:safeEmit(signal, data)
    local listeners = self._listeners[signal]
    if listeners == nil then
        return
    end
    for _, callback in ipairs(listeners) do
        callback(self, data)
    end
end

function module.Element:emit(signal, data)
    for _, callback in ipairs(self._listeners[signal]) do
        callback(self, data)
    end
end

function module.Element:hasListeners(signal)
    return self._listeners[signal] ~= nil
end

function module.Element:capRise(cap)
    return module.cap & cap == cap and module.pcap & cap == 0
end

function module.Element:capFall(cap)
    return module.pcap & cap == cap and module.cap & cap == 0
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

function module.Element:width()
    return self.data.w
end
function module.Element:outterWidth()
    return self:width() + 2 * self.data.padding
end
function module.Element:height()
    return self.data.h
end
function module.Element:outterHeight()
    return self:height() + 2 * self.data.padding
end
function module.Element:isMouseOver()
    local d = self.data
    return contained(module.mouse.x, module.mouse.y, d.x, d.y, d.x + self:outterWidth(), d.y + self:outterHeight())
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
    local bc = self.data.borderColor
    gfx.r = bc.r
    gfx.g = bc.g
    gfx.b = bc.b
    gfx.a = bc.a or 1
    local width = self.data.borderWidth

    local d = self.data
    draw_border(d.x, d.y, self:outterWidth(), self:outterHeight(), width)
end

function module.Element:draw_background()
    local bg = self.data.bg
    gfx.r = bg.r
    gfx.g = bg.g
    gfx.b = bg.b
    gfx.a = bg.a or 1

    local d = self.data
    gfx.rect(d.x, d.y, self:outterWidth(), self:outterHeight(), true) -- frame1
end

function module.Element:draw()
    -- Log.debug("draw id ", self.data.id)
    local d = self.data
    gfx.x = self.data.x
    gfx.y = self.data.y
    if d.bg then
        self:draw_background()
    end
    if d.borderWidth then
        self:draw_border()
    end

    -- if self:isMouseOver() and not self:wasMouseOver() then
    -- Log.debug("mouse enter", self.data.id)
    -- end
    local isMouseOver = self:isMouseOver()
    local wasMouseOver = self:wasMouseOver()

    if isMouseOver and not wasMouseOver then
        self:safeEmit(module.SIGNALS.MOUSE_ENTER)
    end
    if not isMouseOver and wasMouseOver then
        self:safeEmit(module.SIGNALS.MOUSE_LEAVE)
    end
    if isMouseOver then
        -- click event: on mouse press (or should be on release?)
        if self:hasSignalListeners(module.SIGNALS.CLICK) and self:capRise(module.CAP.LMB) then
            self:emit(module.SIGNALS.CLICK)
        end
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

-- return width,height
function module.Button:textWidthHeight(text)
    local d = self.data
    gfx.setfont(1, d.font, d.fontSize) -- set label fnt
    return gfx.measurestr(text or d.text)
end

function module.Button:_calculate_height_width()
    local d = self.data
    gfx.setfont(1, d.font, d.fontSize) -- set label fnt
    local text_w, _ = gfx.measurestr(d.text)
    local _, text_h = gfx.measurestr(" ")
    d.h = text_h + 2 * (d.borderWidth)
    d.w = text_w + 2 * (d.borderWidth)
end
function module.Button:__construct(data)
    local defaults = {
        text = "",
        padding = 2,
        font = "Arial",
        fontSize = 14,
        borderColor = {
            r = 1,
            g = 1,
            b = 1,
        },
        borderWidth = 1,
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
    local x, y = d.x + d.padding + d.borderWidth, d.y + d.padding + d.borderWidth
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
module.Input.elements = {}
function module.Input:__construct(data)
    local defaults = {
        focus = false,
        blinkFrameInterval = 20,
        cursorVisible = true
    }
    data = Table.merge(defaults, data)

    module.Button.__construct(self, data)
    self._text = Text(data.text)
    self._frame_counter = 1
    module.Input.elements[#module.Input.elements + 1] = self
    self:on(
        module.SIGNALS.CLICK,
        function(el)
            el:set("focus", true)
        end
    )
    self:watch(
        "focus",
        function(el, old, new)
            if new == false then
                return
            end
            el:cursor_reset()
            -- if the element gains focus, set focus to false to the other inputs
            for _, other in ipairs(module.Input.elements) do
                if other ~= el then
                    other:set("focus", false)
                end
            end
        end
    )
end

function module.Input:draw_cursor()
    if not self.data.cursorVisible then
        return
    end
    local leftStr = self._text:textLeftOfCursor()
    local strWidth, h = self:textWidthHeight(leftStr)
    w, h = self:textWidthHeight("|")
    local d = self.data
    local x = d.x + d.borderWidth + d.padding + strWidth
    local y = d.y + d.borderWidth + d.padding

    gfx.r = d.fg.r
    gfx.g = d.fg.g
    gfx.b = d.fg.b
    gfx.a = d.fg.a or 1

    gfx.rect(x, y, w * 0.3, h)
end

function module.Input:cursor_reset()
    self._frame_counter = 1
    self:set("cursorVisible", true)
end

function module.Input:draw()
    if self.data.focus then
        local c = module.char
        if c == Chars.CHAR.RETURN then
            self:emit(module.SIGNALS.RETURN)
        else
            self._text:handle(c)
            self:set("text", self._text:getText())
        end

        if self._frame_counter % self.data.blinkFrameInterval == 0 then
            self:set("cursorVisible", not self.data.cursorVisible)
        end
        self._frame_counter = self._frame_counter + 1
        self:draw_cursor()
    end

    module.Button.draw(self)
end

--[[
    Layout

    Layouts must implement the _advance function
    this sets in the temp self._layout table with the
    'runx' and 'runy' indices. The are used as the x and y for the next element
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
    local elements = data.elements
    data.elements = nil
    -- Important! not passing the elments in the constructor
    -- the constructor performs a deep copy of the data table. In that case, we would loose the original references
    module.Element.__construct(self, data)
    -- now setting again the originally passed elements
    self.data.elements = elements
end

function module.ILayout:draw()
    -- TODO: no need to calculate width & height every time
    -- instead, watch children width for changes
    self:set("w", self:width())
    self:set("h", self:height())
    module.Element.draw(self)
    local d = self.data
    self._layout = {
        h = 0,
        w = 0,
        runx = d.x + d.padding,
        runy = d.y + d.padding
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
    self._layout.runy = self._layout.runy + el:outterHeight() + d.spacing
end

function module.VLayout:width()
    local width = 0
    for i, el in ipairs(self.data.elements) do
        width = math.max(width, el:outterWidth())
    end
    return width
end

function module.VLayout:height()
    local height = 0
    local d = self.data
    for i, el in ipairs(d.elements) do
        height = height + el:outterHeight() + d.spacing
    end
    return height - d.spacing
end

module.HLayout = Class.extend(module.ILayout)
function module.HLayout:_advance(el)
    local d = self.data
    self._layout.runx = self._layout.runx + el:outterWidth() + d.spacing
end

function module.HLayout:width()
    local width = 0
    local d = self.data
    for i, el in ipairs(d.elements) do
        width = width + el:outterWidth() + d.spacing
    end
    return width - d.spacing
end

function module.HLayout:height()
    local height = 0
    for i, el in ipairs(self.data.elements) do
        height = math.max(height, el:outterHeight())
    end
    return height
end

return module
