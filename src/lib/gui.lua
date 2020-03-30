-- TODO remove after done
package.path = debug.getinfo(1, "S").source:match [[^@?(.*[\/])[^\/]-$]] .. "../?.lua;" .. package.path
local Log = require("utils.log")

-- from
-- https://github.com/EUGEN27771/ReaScripts/blob/272bb620a7e967d804b75704cd5f7e9b49348f97/Templates/GUI/gen_Simple%20GUI%20template%20for%20scripts.lua

-- Init mouse last --
local last_mouse_cap = 0
local last_x, last_y = 0, 0
local mouse_ox, mouse_oy = -1, -1

local Gui = {}

function Gui.prew_draw()
  if
    gfx.mouse_cap & 1 == 1 and last_mouse_cap & 1 == 0 or -- L mouse
      gfx.mouse_cap & 2 == 2 and last_mouse_cap & 2 == 0 or -- R mouse
      gfx.mouse_cap & 64 == 64 and last_mouse_cap & 64 == 0
   then -- M mouse
    mouse_ox, mouse_oy = gfx.mouse_x, gfx.mouse_y
  end
end

function Gui.post_draw()
  last_mouse_cap = gfx.mouse_cap
  last_x, last_y = gfx.mouse_x, gfx.mouse_y
  gfx.mouse_wheel = 0 -- reset gfx.mouse_wheel
end

Gui.OPTS = {
  x = "x",
  y = "y",
  w = "w", -- width
  h = "h", -- h
  font = "fnt",
  fontSize = "fnt_sz",
  label = "lbl",
  scale_h = "scale_h",
  scale_w = "scale_w",
  onMouseMove = "onMouseMove", -- whenever the mouse is on top of the element
  onMouseDown = "onMouseDown",
  onClick = "onClick"
}

Gui.Element = {}

local function merge(t1, t2)
  for k, v in pairs(t2) do
    t1[k] = v
  end
  return t1
end

local function shallowcopy(orig)
  return merge({}, orig)
end

function deepcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
      copy = {}
      for orig_key, orig_value in next, orig, nil do
          copy[deepcopy(orig_key)] = deepcopy(orig_value)
      end
      setmetatable(copy, deepcopy(getmetatable(orig)))
  else -- number, string, boolean, etc
      copy = orig
  end
  return copy
end

--------------------------------------------------------------------------------
---   Simple Element Class   ---------------------------------------------------
--------------------------------------------------------------------------------
function Gui.Element:new(opts)
  opts = opts or {}
  local elm = opts
  elm._opts = deepcopy(opts)
  -- current holds the current (for this frame) opts for the element
  elm.current = deepcopy(opts)
  setmetatable(elm, self)
  self.__index = self
  return elm
end

function Gui.Element:pre_draw()
  self.current = deepcopy(self._opts)
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

Gui.Button = {}
extended(Gui.Button, Gui.Element)

function Gui.Button:new(opts)
  local btnOpts = {
    fg = {r = 0, g = 0, b = 0, a = 1},
    border = {r = 0.2, g = 0.2, b = 0.2, a = 1},
    bg = {r = 0.5, g = 0.5, b = 0.5, a = 1},
    [Gui.OPTS.font] = "Arial",
    [Gui.OPTS.fontSize] = 16
  }
  opts = merge(btnOpts, opts)
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
  local x, y, w, h = opts.x, opts.y, opts.w, opts.h
  gfx.r = opts.fg.r
  gfx.g = opts.fg.g
  gfx.b = opts.fg.b
  gfx.a = opts.fg.a or 1

  gfx.setfont(1, opts.fnt, opts.fnt_sz) -- set label fnt

  local lbl_w, lbl_h = gfx.measurestr(self.lbl)
  gfx.x = x + (w - lbl_w) / 2
  gfx.y = y + (h - lbl_h) / 2
  gfx.drawstr(opts.lbl)
end
------------------------

function Gui.Button:draw()
  local r, g, b, a = self.r, self.g, self.b, self.a
  local fnt, fnt_sz = self.fnt, self.fnt_sz
  -- Get mouse state ---------
  -- in element --------
  self:pre_draw()
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

return Gui
