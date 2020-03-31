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

local elements = {}

function Gui.pre_draw()
    Gui.char = gfx.getchar()
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
    last_mouse_cap = gfx.mouse_cap
    last_x, last_y = gfx.mouse_x, gfx.mouse_y
    gfx.mouse_wheel = 0 -- reset gfx.mouse_wheel
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

--------------------------------------------------------------------------------
---   Simple Element Class   ---------------------------------------------------
--------------------------------------------------------------------------------
Gui.Element = Class.new()
function Gui.Element:new(opts)
    opts = opts or {}
    local elm = {}
    -- current holds the current (for this frame) opts for the element
    elm.persistent = opts
    elm.volatile = Table.deepcopy(opts)
    setmetatable(elm, self)
    self.__index = self

    elements[#elements + 1] = elm
    return elm
end

function Gui.Element:pre_draw()
    self.volatile = Table.deepcopy(self.persistent)
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
function Gui.Element:pointIN(p_x, p_y)
    local v = self.volatile
    return p_x >= v.x and p_x <= v.x + v.w and p_y >= v.y and p_y <= v.y + v.h
end

function Gui.Element:isMouseOver()
    return self:pointIN(gfx.mouse_x, gfx.mouse_y)
end
--------
function Gui.Element:mouseIN()
    return gfx.mouse_cap & 1 == 0 and self:pointIN(gfx.mouse_x, gfx.mouse_y)
end

------------------------
function Gui.Element:mouseDown()
    return gfx.mouse_cap & 1 == 1 and self:pointIN(mouse_ox, mouse_oy)
end
--------
function Gui.Element:mouseUp() -- its actual for sliders and knobs only!
    return gfx.mouse_cap & 1 == 0 and self:pointIN(mouse_ox, mouse_oy)
end
--------
function Gui.Element:mouseClick()
    return gfx.mouse_cap & 1 == 0 and last_mouse_cap & 1 == 1 and self:pointIN(gfx.mouse_x, gfx.mouse_y) and
        self:pointIN(mouse_ox, mouse_oy)
end
------------------------
function Gui.Element:mouseR_Down()
    return gfx.mouse_cap & 2 == 2 and self:pointIN(mouse_ox, mouse_oy)
end
--------
function Gui.Element:mouseM_Down()
    return gfx.mouse_cap & 64 == 64 and self:pointIN(mouse_ox, mouse_oy)
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
    gfx.setfont(1, opts.fnt, opts.fnt_sz) -- set label fnt
    local text_w, text_h = gfx.measurestr(opts.text)
    opts.h = text_h + 2 * btnOpts.padding
    opts.w = opts.w or text_w + 2 * btnOpts.padding

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

    local p = self.persistent
    local text_w, text_h = gfx.measurestr(p.text)
    -- that's for center
    -- gfx.x = x + (w - text_w) / 2
    -- gfx.y = y + (h - text_h) / 2
    gfx.x = x
    gfx.y = y
    gfx.drawstr(p.text)
end
------------------------

function Gui.Button:draw()
    local v = self.volatile
    local p = self.persistent

    local r, g, b, a = v.r, v.g, v.b, v.a
    local fnt, fnt_sz = v.fnt, v.fnt_sz
    -- Get mouse state ---------
    -- in element --------
    -- self:pre_draw()
    if self.onMouseMove and self:mouseIN() then
        self.onMouseMove(v, p)
    end
    if self.onMouseDown and self:mouseDown() then
        self.onMouseDown(v, p)
    end
    if self.onClick and self:mouseClick() then
        self.onClick(v, p)
    end
    self:draw_border()
    self:draw_background()
    self:draw_label()
end

Gui.Input = Class.extend(Gui.Button)
Gui.Input.opts = {
    focus = "focus",
    onEnter = "onEnter"
}

-- function Gui.Input.
function Gui.Input:new(opts)
    local inputOpts = {focus = false}

    return Gui.Button.new(self, Table.merge(inputOpts, opts))
end

function Gui.Input:draw()
    -- get gfx char
    if self[Gui.Input.opts.focus] then
        local c = Gui.char
        if Chars.isPrintable(c) then
            self.persistent.text = string.char(c)
        end
    end
    Gui.Button.draw(self)
end

-- interface to be implemented
Gui.ILayout = Class.extend(Gui.Element)
-- TODO do a generic layout and call the impl_pos(el) ?
Gui.ILayout.opts = {
    elements = "elements",
    spacing = "spacing"
}

function Gui.ILayout:new(opts)
    local layoutOpts = {
        elements = {},
        spacing = 5
    }
    opts = Table.merge(layoutOpts, opts)
    return Gui.Element.new(self, opts)
end

function Gui.ILayout:draw()
    local run_x, run_y = 0, 0
    for i, el in ipairs(self.volatile.elements) do
        el.volatile.x = self.volatile.x + run_x
        el.volatile.y = self.volatile.y + run_y
        el:draw()
        local x, y = self:advance_xy(el) -- children layouts must implement this
        run_x = run_x + x
        run_y = run_y + y
    end
end

-- TODO
Gui.VLayout = Class.extend(Gui.ILayout)
function Gui.VLayout:advance_xy(el)
    return 0, el.volatile.h + self.volatile.spacing
end

return Gui
