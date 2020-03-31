package.path = debug.getinfo(1, "S").source:match [[^@?(.*[\/])[^\/]-$]] .. "?.lua;" .. package.path

local Log = require("utils.log")
local Actions = require("utils.actions")
local GuiUtils = require("utils.gui")
local Common = require("utils.common")
local Gui = require("gui.core")
local Chars = require("gui.chars")

local Button = Gui.Button

Log.isdebug = true

-- Actions.getActions(Actions.SECTION.MAIN, 10)
local res = Actions.search(Actions.SECTION.MAIN, "split item", false)

if #res > 1 then
-- Log.debug("first match: " .. res[1].name)
-- Common.cmd(res[1].id)
end

-- Log.debug(Log.dump(res))

function init()
    gfx.init("actondev/Command Palette", 400, 100)
    Common.moveWindowToMouse()
    local R, G, B = 60, 60, 60 -- 0..255 form
    local Wnd_bgd = R + G * 256 + B * 65536 -- red+green*256+blue*65536
    gfx.clear = Wnd_bgd
end

local g = Gui.OPTS
local btn =
    Button:new(
    {
        x = 20,
        y = 20,
        fg = {r = 0, g= 0, b=0},
        [g.text] = "hi there",
        bg = {r = 0.5, g=0.5, b=0.5}
    }
)
-- btn[g.mod_hover] = function(opts)
--     opts.g = 1
--     opts.b = 1
-- end

btn.onMouseMove = function(el)
    -- Log.debug("hover")
    el.current.bg.a = 0.2
    -- el.current.b = 1
end

btn.onMouseDown = function(el)
    Log.debug("mouse down")
    el.current.bg.r = 0
    el.current.bg.g = 1
    el.current.bg.b = 0
end

btn.onMouseOver = function(el)
    Log.debug("mouse over")
    el.current.bg.a = 0.2
end

btn.onClick = function(el)
    Log.debug("CLICK")
    el.current.r = 0
    el.current.g = 0
    el.current.b = 1
end

local input = Gui.Input:new(
    {
        x = 20,
        y = 60,
        w = 200,
        fg = {r = 0, g= 0, b=0},
        [g.text] = "hi there",
        bg = {r = 0.5, g=0.5, b=0.5},
        [Gui.Input.opts.focus] = true
    }
)

function mainloop()
    Gui.prew_draw()
    ---
    btn:draw()
    input:draw()
    ---
    Gui.post_draw()

    local c = Gui.char
    if c ~= Chars.CHAR.ESCAPE and c ~= Chars.CHAR.EXIT then
        reaper.defer(mainloop)
    end

    gfx.update()
end

init()
mainloop()
