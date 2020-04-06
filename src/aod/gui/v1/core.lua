local module = {}
local Class = require("aod.utils.class")
local Table = require("aod.utils.table")
local Chars = require("aod.text.chars")
local Text = require("aod.text.input")
local Log = require("aod.utils.log")

-- https://gist.github.com/jrus/3197011
local random = math.random
local function uuid()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    return string.gsub(
        template,
        "[xy]",
        function(c)
            local v = (c == "x") and random(0, 0xf) or random(8, 0xb)
            return string.format("%x", v)
        end
    )
end

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

module.Object = Class.create()
function module.Object:__construct(data)
    data = data or {}
    self.data = Table.deepcopy(data)
    self.init = Table.deepcopy(data)
    -- Note: there was a bug in deepcoy, giving me the same table for the 2 calls Table.deepcopy on the same table
    self.mods = {} -- keeping track of modifications.. like when on hover
    self._watches = {}
    self._listeners = {}
end

function module.Object:watch(property, cb)
    if self._watches[property] == nil then
        self._watches[property] = {}
    end
    local watches = self._watches[property]
    watches[#watches + 1] = cb
end

function module.Object:on(signal, cb)
    if self._listeners[signal] == nil then
        self._listeners[signal] = {}
    end
    local listeners = self._listeners[signal]
    listeners[#listeners + 1] = cb
end

-- watches the property for changes
-- @param property: the property to watch for changes
-- @param predicate: if the predicate is true, will call the modifier
-- @param modifier
--    a "list" of modifications to apply to the Object while the predicate is true
--    when the predicate gets to false, the applied changes get reverted
--


--[[
    Applies a modification to the Object's data as defined from the return value of callback
    The callback is run whenever the watchProperty is changed
    If the callback returns nil, then the applied modification is reversed/undone

    example usage
btn:watch_mod(
    "hover",
    function(el, oldValue, newValue)
        if newValue then
            -- modifing background green to 1
            return {[{"bg", "g"}] = 1}
        else
            -- upon returning nil, my change is reversed
            return nil
        end
    end
)

]]
function module.Object:watch_mod(watchProperty, callback)
    local reverseKey = uuid()
    self:watch(
        watchProperty,
        function(el, old, new)
            local mod = callback(el, old, new)
            if mod then
                local reverse = Table.setInMultiple(el.data, mod, true)
                if self.mods[reverseKey] == nil then
                    -- storing the reverse
                    self.mods[reverseKey] = reverse
                end
            else
                -- if the returned value of the callback is nill, then reverse
                Table.setInMultiple(el.data, self.mods[reverseKey])
                self.mods[reverseKey] = nil
            end
        end
    )
end

function module.Object:set(property, newValue, force)
    local d = self.data
    local oldValue = d[property]
    if newValue == oldValue and not force then
        return
    end
    d[property] = newValue
    local watches = self._watches[property]
    if watches == nil then
        return
    end
    for _, callback in ipairs(watches) do
        callback(self, oldValue, newValue)
    end
end

function module.Object:hasSignalListeners(signal)
    return self._listeners[signal] ~= nil
end

function module.Object:emit(signal, data)
    local listeners = self._listeners[signal]
    if listeners == nil then
        return
    end
    for _, callback in ipairs(listeners) do
        callback(self, data)
    end
end

function module.Object:hasListeners(signal)
    return self._listeners[signal] ~= nil
end

--[[ Element

    Basic element. x,y,w,h, can draw background and border, handle mouse pointer etc
]]

module.Element = Class.extend(module.Object)
function module.Element:__construct(data)
    local defaults = {
        x = 0,
        y = 0,
        padding = 0,
        hover = false
    }
    data = Table.merge(defaults, data)

    module.Object.__construct(self,data)
end

-- returns example 90 (if "90%") or nil
function module.Element:widthPercentage()
    return self.init.w and string.match(self.init.w, "^([%d][%d]?[%d]?)%%")
end

function module.Element:widthFixed()
    return self.init.w and string.match(self.init.w, "^[%d]+$")
end
function module.Element:widthAuto()
    return self.init.w == nil
end

function module.Element:calculateAutoWidth()
    Log.warn("element's auto width calculation not implemented. init: ", self.data.init)
end

function module.Element:invalidateCachedWidth()
    self.data.w = nil
end

-- height

function module.Element:heightPercentage()
    return self.init.h and string.match(self.init.h, "^([%d][%d]?[%d]?)%%")
end

function module.Element:heightFixed()
    return self.init.h and string.match(self.init.h, "^[%d]+$")
end
function module.Element:heightAuto()
    return self.init.h == nil
end

function module.Element:calculateAutoHeight()
    Log.warn("element's auto Height calculation not implemented. init: ", self.data.init)
end

function module.Element:invalidateCachedHeight()
    self.data.h = nil
end

function module.Element:width()
    local cached = self.data.w
    local newValue = nil
    if self:widthFixed() then
        return cached -- not returning init.w but data.w cause it could be changed since then
    elseif self:widthPercentage() then
        local parent = self.parent
        if parent == nil then
            Log.warn("percentage width is only allow for elements in a layout (with a parent)")
        end
        local factor = self:widthPercentage() / 100
        newValue = factor * self.parent:width()
    elseif self:widthAuto() then
        if cached then
            return cached
        end
        newValue = self:calculateAutoWidth()
    else
        Log.warn("could not figure out the element's width strategy. init values ", self.init)
    end

    -- Log.debug("setting new width", newValue, " to el", self.data.id)
    self:set("w", newValue)
    return newValue
end

-- TODO... pff.. duplicate code...
function module.Element:height()
    local cached = self.data.h
    local newValue = nil
    if cached then
        return cached
    end
    if self:heightFixed() then
        return cached
    elseif self:heightPercentage() then
        local parent = self.parent
        if parent == nil then
            Log.warn("percentage height is only allow for elements in a layout (with a parent)")
        end
        local factor = self:heightPercentage() / 100
        newValue = factor * self.parent:height()
    elseif self:heightAuto() then
        if cached then
            return cached
        end
        newValue = self:calculateAutoHeight()
    else
        Log.warn("could not figure out the element's height strategy. init values ", self.init)
    end

    -- Log.debug("setting new height", newValue, " to el", self.data.id)
    self:set("h", newValue)
    return newValue
end

local function contained(x, y, x0, y0, x1, y1)
    return x >= x0 and x <= x1 and y >= y0 and y <= y1
end

function module.Element:capRise(cap)
    return module.cap & cap == cap and module.pcap & cap == 0
end

function module.Element:capFall(cap)
    return module.pcap & cap == cap and module.cap & cap == 0
end

function module.Element:wasMouseOver()
    local d = self.data
    return contained(module.mouse.px, module.mouse.py, d.x, d.y, d.x + self:width(), d.y + d.h)
end

function module.Element:isMouseOver()
    local d = self.data
    return contained(module.mouse.x, module.mouse.y, d.x, d.y, d.x + self:width(), d.y + self:height())
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
    draw_border(d.x, d.y, self:width(), self:height(), width)
end

function module.Element:draw_background()
    local bg = self.data.bg
    gfx.r = bg.r
    gfx.g = bg.g
    gfx.b = bg.b
    gfx.a = bg.a or 1

    local d = self.data
    gfx.rect(d.x, d.y, self:width(), self:height(), true) -- frame1
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
    self:set("hover", isMouseOver)

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

-- return width,height
function module.Button:textWidthHeight(text)
    local d = self.data
    gfx.setfont(1, d.font, d.fontSize) -- set label fnt
    return gfx.measurestr(text or d.text)
end

-- can be overridden
function module.Button:drawable_text()
    return self.data.text
end

function module.Button:calculateAutoWidth()
    local d = self.data
    gfx.setfont(1, d.font, d.fontSize) -- set label fnt
    local text_w, _ = gfx.measurestr(self:drawable_text())
    return text_w + 2 * (d.borderWidth + d.padding)
end

function module.Button:calculateAutoHeight()
    local d = self.data
    gfx.setfont(1, d.font, d.fontSize) -- set label fnt
    local _, text_h = gfx.measurestr(" ")
    return text_h + 2 * (d.borderWidth + d.padding)
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
            b = 1
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

    if self:widthAuto() then
        -- self._cached_width = self:calculateAutoWidth()
        self:watch(
            "text",
            function(el, old, new)
                self:invalidateCachedWidth()
            end
        )
    end

    if self:heightAuto() then
        -- self._cached_width = self:calculateAutoWidth()
        self:watch(
            "text",
            function(el, old, new)
                self:invalidateCachedHeight()
            end
        )
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
    gfx.drawstr(self:drawable_text())
end

--[[ Input

]]
module.Input = Class.extend(module.Button)
module.Input.elements = {}
function module.Input:__construct(data)
    local defaults = {
        focus = false,
        blinkFrameInterval = 20,
        cursorVisible = true,
        placeholder = "start typing" -- or a text to show when the text input is empty
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

function module.Input:drawable_text()
    if self.data.text == "" and self.data.placeholder then
        return self.data.placeholder
    end
    return self.data.text
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

    gfx.rect(x, y, math.max(1, w * 0.3), h, true)
end

function module.Input:cursor_reset()
    self._frame_counter = 1
    self:set("cursorVisible", true)
end

function module.Input:draw()
    module.Button.draw(self)
    if self.data.focus then
        local c = module.char
        if c == Chars.CHAR.RETURN then
            self:emit(module.SIGNALS.RETURN)
        elseif c ~= 0 then
            self._text:handle(c)
            self:set("text", self._text:getText())
        end

        if self._frame_counter % self.data.blinkFrameInterval == 0 then
            self:set("cursorVisible", not self.data.cursorVisible)
        end
        self._frame_counter = self._frame_counter + 1
        self:draw_cursor()
    end
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

    for _, el in ipairs(elements) do
        el.parent = self
        if self:widthAuto() then
            -- watch changes in childrens' width
            el:watch(
                "w",
                function(_)
                    -- Log.debug("element's width changed, id", el.data.id)
                    self:invalidateCachedWidth()
                end
            )
        end

        if self:heightAuto() then
            -- watch changes in childrens' height
            el:watch(
                "h",
                function(_)
                    -- Log.debug("element's height changed, id", el.data.id)
                    self:invalidateCachedHeight()
                end
            )
        end
    end
end

function module.ILayout:draw()
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
    self._layout.runy = self._layout.runy + el:height() + d.spacing
end

function module.VLayout:calculateAutoWidth()
    -- Log.debug("VLayout auto width calculation")
    local width = 0
    for i, el in ipairs(self.data.elements) do
        width = math.max(width, el:width())
    end
    local res = width + 2 * self.data.padding
    return res
end

function module.VLayout:calculateAutoHeight()
    -- Log.debug("VLayout auto height calculation")
    local height = 0
    local d = self.data
    for i, el in ipairs(d.elements) do
        height = height + el:height() + d.spacing
    end
    return height - d.spacing + 2 * d.padding
end

module.HLayout = Class.extend(module.ILayout)
function module.HLayout:_advance(el)
    local d = self.data
    self._layout.runx = self._layout.runx + el:width() + d.spacing
end

function module.HLayout:calculateAutoWidth()
    -- Log.debug("HLayout auto width calculation")
    local width = 0
    local d = self.data
    for i, el in ipairs(d.elements) do
        width = width + el:width() + d.spacing
    end
    return width - d.spacing + 2 * d.padding
end

function module.HLayout:calculateAutoHeight()
    -- Log.debug("HLayout auto height calculation")
    local height = 0
    for i, el in ipairs(self.data.elements) do
        height = math.max(height, el:height())
    end
    return height + 2 * self.data.padding
end

return module
