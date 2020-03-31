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
local Table = require('utils.table')

Gui.char = 0

function Gui.prew_draw()
    Gui.char = gfx.getchar()
    if
        gfx.mouse_cap & 1 == 1 and last_mouse_cap & 1 == 0 or -- L mouse
            gfx.mouse_cap & 2 == 2 and last_mouse_cap & 2 == 0 or -- R mouse
            gfx.mouse_cap & 64 == 64 and last_mouse_cap & 64 == 0 -- M mouse
     then
        mouse_ox, mouse_oy = gfx.mouse_x, gfx.mouse_y
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
    local elm = opts
    elm._opts = Table.deepcopy(opts)
    -- current holds the current (for this frame) opts for the element
    elm.current = Table.deepcopy(opts)
    setmetatable(elm, self)
    self.__index = self
    return elm
end

function Gui.Element:draw()
    if self.impl_draw then
        self.current = Table.deepcopy(self._opts)
        self:impl_draw()
    end
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
    return p_x >= self.x and p_x <= self.x + self.w and p_y >= self.y and p_y <= self.y + self.h
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
    local opts = self.current
    gfx.r = opts.border.r
    gfx.g = opts.border.g
    gfx.b = opts.border.b
    gfx.a = opts.border.a or 1

    local x, y, w, h = opts.x, opts.y, opts.w, opts.h
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
    opts.h = text_h + 2*btnOpts.padding
    opts.w = opts.w or text_w + 2*btnOpts.padding
    
    return Gui.Element.new(self, opts)
end

function Gui.Button:draw_background()
    local opts = self.current
    gfx.r = opts.bg.r
    gfx.g = opts.bg.g
    gfx.b = opts.bg.b
    gfx.a = opts.bg.a or 1

    local x, y, w, h = opts.x, opts.y, opts.w, opts.h
    gfx.rect(x, y, w, h, true)
end
--------
function Gui.Button:draw_label()
    local opts = self.current
    local x, y = opts.x + opts.padding, opts.y + opts.padding
    gfx.r = opts.fg.r
    gfx.g = opts.fg.g
    gfx.b = opts.fg.b
    gfx.a = opts.fg.a or 1

    gfx.setfont(1, opts.fnt, opts.fnt_sz) -- set label fnt

    local text_w, text_h = gfx.measurestr(self.text)
    -- that's for center
    -- gfx.x = x + (w - text_w) / 2
    -- gfx.y = y + (h - text_h) / 2
    gfx.x = x
    gfx.y = y
    gfx.drawstr(self.text)
end
------------------------

function Gui.Button:impl_draw()
    local r, g, b, a = self.r, self.g, self.b, self.a
    local fnt, fnt_sz = self.fnt, self.fnt_sz
    -- Get mouse state ---------
    -- in element --------
    -- self:pre_draw()
    if self.onMouseMove and self:mouseIN() then
        self.onMouseMove(self)
    end
    if self.onMouseDown and self:mouseDown() then
        self.onMouseDown(self)
    end
    if self.onClick and self:mouseClick() then
        self.onClick(self)
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

function Gui.Input:impl_draw()
    -- get gfx char
    if self[Gui.Input.opts.focus] then
        local c = Gui.char
        if Chars.isPrintable(c) then
            self.text = self.text .. string.char(c)
        end
    end
    Gui.Button.impl_draw(self)
end

Gui.Layout = Class.extend(Gui.Element)
-- TODO do a generic layout and call the impl_pos(el) ?
Gui.Layout.opts =
{
    elements = 'elements',
    spacing = 'spacing',
}

function Gui.Layout:new(opts)

end

-- TODO
Gui.VLayout = Class.extend(Gui.Layout)
function Gui.VLayout:impl_peek(el)
    -- keeping track of each element,
    -- adjusting internal y
end

return Gui
