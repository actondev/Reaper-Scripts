package.path = debug.getinfo(1, "S").source:match [[^@?(.*[\/])[^\/]-$]] .. "?.lua;" .. package.path

local w = 500
local h = 500

local Gui = require("aod.gui.v1.core")
local Chars = require("gui.chars")
local Log = require("aod.utils.log")
Log.LEVEL = Log.DEBUG

local el =
    Gui.Element(
    {
        id = "el",
        x = 10,
        y = 10,
        w = 30,
        h = 30,
        border = {
            r = 1,
            g = 1,
            b = 1,
            width = 5
        },
        bg = {
            r = 0.5,
            g = 0.5,
            b = 0.5
        }
    }
)

local btn =
    Gui.Button(
    {
        id = "btn",
        x = 10,
        y = 50,
        -- w = 50,
        -- h = 50,
        padding = 2,
        border = {
            r = 1,
            g = 1,
            b = 1,
            width = 2
        },
        bg = {
            r = 0.5,
            g = 0.5,
            b = 0.5
        },
        fg = {
            r = 1,
            g = 1,
            b = 1
        },
        text = 'hello world',
        font = "Arial",
        fontSize = 15
    }
)

function init()
    gfx.init("actondev/Command Palette", w, h)
    local R, G, B = 60, 60, 60 -- 0..255 form
    local Wnd_bgd = R + G * 256 + B * 65536 -- red+green*256+blue*65536
    gfx.clear = Wnd_bgd
end

function mainloop()
    local c = gfx.getchar()
    Gui.pre_draw()
    btn:set('text', tostring(Gui.frame/10))
    el:draw()
    btn:draw()
    Gui.post_draw()

    if c == Chars.CHAR.EXIT then
        return
    end
    if c == Chars.CHAR.ESCAPE then
        return
    end
    reaper.defer(mainloop)
    gfx.update()
end

init()
mainloop()
