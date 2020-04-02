package.path = debug.getinfo(1, "S").source:match [[^@?(.*[\/])[^\/]-$]] .. "?.lua;" .. package.path

local w = 500
local h = 500

local Gui = require("aod.gui.v1.core")
local Chars = require("gui.chars")

local el =
    Gui.Element:new(
    {
        x = 10,
        y = 10,
        w = 50,
        h = 50,
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

function init()
    gfx.init("actondev/Command Palette", w, h)
    local R, G, B = 60, 60, 60 -- 0..255 form
    local Wnd_bgd = R + G * 256 + B * 65536 -- red+green*256+blue*65536
    gfx.clear = Wnd_bgd
end

function mainloop()
    local c = gfx.getchar()
    el:draw()

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
