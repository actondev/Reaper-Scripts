-- TODO remove after done
local Log = require("utils.log")

-- from
-- https://github.com/EUGEN27771/ReaScripts/blob/272bb620a7e967d804b75704cd5f7e9b49348f97/Templates/GUI/gen_Simple%20GUI%20template%20for%20scripts.lua

-- Init mouse last --
local last_mouse_cap = 0
local last_x, last_y = 0, 0
local mouse_ox, mouse_oy = -1, -1

local Gui = {}
local Class = require("utils.class")
local Chars = require("gui.chars")
local Table = require("utils.table")

Gui.char = 0
Gui.frame = 0
Gui.mouse = {
    x = 0,
    y = 0,
    px = 0,
    py = 0
}

local elements = {}

function Gui.pre_draw()
    Gui.char = gfx.getchar()
    Gui.mouse.x = gfx.mouse_x
    Gui.mouse.y = gfx.mouse_y
    if
        gfx.mouse_cap & 1 == 1 and last_mouse_cap & 1 == 0 or -- L mouse
            gfx.mouse_cap & 2 == 2 and last_mouse_cap & 2 == 0 or -- R mouse
            gfx.mouse_cap & 64 == 64 and last_mouse_cap & 64 == 0
     then -- M mouse
        mouse_ox, mouse_oy = gfx.mouse_x, gfx.mouse_y
    end

    -- running elements pre_draw
    for _, elm in ipairs(elements) do
        if elm.pre_draw then
            elm:pre_draw()
        end
    end
end

function Gui.post_draw()
    for _, elm in ipairs(elements) do
        if elm.post_draw then
            elm:post_draw()
        end
    end

    last_mouse_cap = gfx.mouse_cap
    last_x, last_y = gfx.mouse_x, gfx.mouse_y
    gfx.mouse_wheel = 0 -- reset gfx.mouse_wheel
    Gui.frame = Gui.frame + 1
    Gui.mouse.px = Gui.mouse.x
    Gui.mouse.py = Gui.mouse.y


end

-- TODO refactor this..
-- Gui.Element.opts
-- Gui.Button.opts
-- Gui.Input.opts
Gui.OPTS = {
    x = "x",
    y = "y",
    w = "w", -- width
    h = "h", -- h
    font = "fnt",
    fontSize = "fnt_sz",
    text = "text",
    scale_h = "scale_h",
    scale_w = "scale_w",
    onMouseMove = "onMouseMove", -- whenever the mouse is on top of the element
    onMouseDown = "onMouseDown",
    onClick = "onClick"
}

Gui.Element = {}

local deepCopyIgnoreKeys = {persistent = true, volatile = true, prev = true}

--------------------------------------------------------------------------------
---   Simple Element Class   ---------------------------------------------------
--------------------------------------------------------------------------------
Gui.Element = Class.new()
function Gui.Element:new(opts)
    local defaultOpts = {
        x = 0,
        y = 0,
        w = 0,
        h = 0,
        mouse = {over = false, enter = false, out = false}
    }
    opts = opts or {}
    opts = Table.merge(defaultOpts, opts)
    local elm = opts
    -- current holds the current (for this frame) opts for the element
    -- local copy = Table.deepcopy(opts)
    elm.persistent = opts
    -- elm.volatile = Ta
    elm.volatile = Table.deepcopy(opts, deepCopyIgnoreKeys)
    elm.prev = elm.volatile
    -- self.volatile = Table.deepcopy(self,)
    setmetatable(elm, self)
    self.__index = self

    elements[#elements + 1] = elm
    return elm
end

function Gui.Element:pre_draw()
    self.volatile = Table.deepcopy(self, deepCopyIgnoreKeys)
    self.mouse.over = self:isMouseOver(Gui.mouse.x, Gui.mouse.y)
    self.mouse.enter = not self.prev.mouse.over and self.mouse.over
    self.mouse.leave = not self.mouse.leave and self.prev.mouse.over
end

function Gui.Element:post_draw()
    self.prev = self.volatile
end

--------------------------------------------------------------
--- Function for Child Classes(args = Child,Parent Class) ----
--------------------------------------------------------------
local function extended(Child, Parent)
    setmetatable(Child, {__index = Parent})
end
--------------------------------------------------------------
---   Element Class Methods(Main Methods)   ------------------
--------------------------------------------------------------

------------------------
function Gui.Element:isMouseOver(p_x, p_y)
    local v = self.persistent
    return p_x >= v.x and p_x <= v.x + v.w and p_y >= v.y and p_y <= v.y + v.h
end

function Gui.Element:mouseEnter()
    return not self.prev.mouseOver and self.mouseOver
end

--------
function Gui.Element:mouseIN()
    return gfx.mouse_cap & 1 == 0 and self.mouseOver
end

------------------------
function Gui.Element:mouseDown()
    return gfx.mouse_cap & 1 == 1 and self:isMouseOver(mouse_ox, mouse_oy)
end
--------
function Gui.Element:mouseUp() -- its actual for sliders and knobs only!
    return gfx.mouse_cap & 1 == 0 and self:isMouseOver(mouse_ox, mouse_oy)
end
--------
function Gui.Element:mouseClick()
    return gfx.mouse_cap & 1 == 0 and last_mouse_cap & 1 == 1 and self:isMouseOver(gfx.mouse_x, gfx.mouse_y) and
        self:isMouseOver(mouse_ox, mouse_oy)
end
------------------------
function Gui.Element:mouseR_Down()
    return gfx.mouse_cap & 2 == 2 and self:isMouseOver(mouse_ox, mouse_oy)
end
--------
function Gui.Element:mouseM_Down()
    return gfx.mouse_cap & 64 == 64 and self:isMouseOver(mouse_ox, mouse_oy)
end
------------------------
function Gui.Element:draw_border()
    local v = self.volatile
    gfx.r = v.border.r
    gfx.g = v.border.g
    gfx.b = v.border.b
    gfx.a = v.border.a or 1

    local x, y, w, h = v.x, v.y, v.w, v.h
    gfx.rect(x, y, w, h, false) -- frame1
    gfx.roundrect(x, y, w - 1, h - 1, 3, true) -- frame2
end

-- Gui.Button = Class(Gui.Element)
-- extended(Gui.Button, Gui.Element)

-- Gui.Input = {}
-- extended(Gui.Input, Gui.Button)

Gui.Button = Class.extend(Gui.Element)

function Gui.Button:new(opts)
    local btnOpts = {
        fg = {r = 0, g = 0, b = 0, a = 1},
        padding = 5, -- across all sides
        border = {r = 0.2, g = 0.2, b = 0.2, a = 1},
        bg = {r = 0.5, g = 0.5, b = 0.5, a = 1},
        [Gui.OPTS.font] = "Arial",
        [Gui.OPTS.fontSize] = 16
    }

    opts = Table.merge(btnOpts, opts)

    return Gui.Element.new(self, opts)
end

function Gui.Button:draw_background()
    local v = self.volatile
    gfx.r = v.bg.r
    gfx.g = v.bg.g
    gfx.b = v.bg.b
    gfx.a = v.bg.a or 1

    local x, y, w, h = v.x, v.y, v.w, v.h
    gfx.rect(x, y, w, h, true)
end
--------
function Gui.Button:draw_label()
    local v = self.volatile
    local x, y = v.x + v.padding, v.y + v.padding
    gfx.r = v.fg.r
    gfx.g = v.fg.g
    gfx.b = v.fg.b
    gfx.a = v.fg.a or 1

    gfx.setfont(1, v.fnt, v.fnt_sz) -- set label fnt
    gfx.x = x
    gfx.y = y
    gfx.drawstr(v.text)
end
------------------------

function Gui.Button:draw()
    local v = self.volatile
    local p = self.persistent

    gfx.setfont(1, v.fnt, v.fnt_sz) -- set label fnt
    local text_w, _ = gfx.measurestr(v.text)
    local _, text_h = gfx.measurestr(" ")
    -- persistent & volatile m ess
    p.h = text_h + 2 * v.padding
    p.w = v.w or text_w + 2 * v.padding
    v.h = p.h
    v.w = p.w

    if self.onMouseMove and self.mouse.over then
        self.onMouseMove(v, p)
    end
    if self.onMouseDown and self:mouseDown() then
        self.onMouseDown(v, p)
    end
    if self.onClick and self:mouseClick() then
        self.onClick(v, p)
    end
    if self.onMouseEnter and self.mouse.enter then
        self.onMouseEnter(v, p)
    end
    if self.onMouseLeave and self.mouse.leave then
        self.onMouseLeave(v, p)
    end
    if self.prev.text ~= self.volatile.text and self.onChange then
        self.onChange(v, p)
    end

    self:draw_border()
    self:draw_background()
    self:draw_label()
end

Gui.Input = Class.extend(Gui.Button)
Gui.Input.opts = {
    hasFocus = "focus",
    onEnter = "onEnter"
}

function Gui.Input:new(opts)
    local inputOpts = {focus = false}

    return Gui.Button.new(self, Table.merge(inputOpts, opts))
end

function Gui.Input:draw()
    -- get gfx char
    if self.volatile[Gui.Input.opts.hasFocus] then
        local c = Gui.char
        if Chars.isPrintable(c) then
            self._input_last_update = self._input_last_update or 0
            if self._input_last_update ~= Gui.frame then
                self.persistent.text = self.persistent.text .. string.char(c)
                self._input_last_update = Gui.frame
            end
        elseif c == Chars.CHAR.RETURN then
            if self.onEnter then
                self.onEnter(self.volatile, self.persistent)
            end
        end
    end
    Gui.Button.draw(self)
end

-- interface to be implemented
Gui.ILayout = Class.extend(Gui.Element)
Gui.ILayout.opts = {
    elements = "elements",
    spacing = "spacing"
}

function Gui.ILayout:draw()
    local run_x, run_y = 0, 0
    for i, el in ipairs(self.persistent.elements) do
        -- persistent and volatile mess
        el.persistent.x = self.volatile.x + run_x
        el.persistent.y = self.volatile.y + run_y
        el.volatile.x = el.persistent.x
        el.volatile.y = el.persistent.y
        -- el:pre_draw() -- to update the calculations x,y
        el:draw()
        local x, y = self:advance_xy(el) -- children layouts must implement this
        run_x = run_x + x
        run_y = run_y + y
    end
end

-- TODO
Gui.VLayout = Class.extend(Gui.ILayout)
function Gui.VLayout:advance_xy(el)
    return 0, (el.volatile.h or 0) + self.volatile.spacing
end

Gui.List = Class.extend(Gui.VLayout)
Gui.List.options = {
    hasFocus = "hasFocus", -- listening for up/down key presses
    selectedIndex = "selectedIndex",
    whenSelected = "whenSelected" -- callback to modify the selected item
}

function Gui.List:new(opts)
    local listOpts = {
        selectedIndex = 0, -- note: 1-based
        whenSelected = nil, -- function
        hasFocus = false
    }
    opts = Table.merge(listOpts, opts)
    return Gui.VLayout.new(self, opts)
end

function Gui.List:select(target)
    for i, el in ipairs(self.elements) do
        if el == target then
            self.selectedIndex = i
            return
        end
    end
end

function Gui.List:draw()
    -- resetting index
    if #self.elements == 0 then
        self.selectedIndex = 1
    end
    if self.selectedIndex > 0 and #self.elements > 0 then
        if self.hasFocus then
            if Gui.char == Chars.CHAR.DOWN then
                self.selectedIndex = self.selectedIndex + 1
            elseif Gui.char == Chars.CHAR.UP then
                self.selectedIndex = self.selectedIndex - 1
            elseif Gui.char == Chars.CHAR.RETURN then
                local sel = self.elements[self.selectedIndex]
                if self.onEnter then
                    self.onEnter(sel.volatile, sel.persistent)
                end
            end
        end
        -- wrapping index
        if self.selectedIndex > #self.elements then
            self.selectedIndex = 1
        end
        if self.selectedIndex < 1 then
            self.selectedIndex = #self.elements
        end

        local el = self.elements[self.selectedIndex]
        if self.whenSelected then
            self.whenSelected(el.volatile, el.persistent)
        end
    end

    Gui.VLayout.draw(self)
end

return Gui
