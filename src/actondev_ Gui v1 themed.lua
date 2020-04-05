package.path = debug.getinfo(1, "S").source:match [[^@?(.*[\/])[^\/]-$]] .. "?.lua;" .. package.path

local w = 500
local h = 500
local Log = require("aod.utils.log")
Log.LEVEL = Log.DEBUG

local Gui = require("aod.gui.v1.core")
local Chars = require("gui.chars")
local Table = require("aod.utils.table")

local Themed = require("aod.gui.v1.themed")

local btn =
    Themed.Button(
    {
        id = "btn",
        x = 10,
        y = 50,
        text = "hello world",
        padding = 10,
        borderWidth = 0,
    }
)

local input =
    Themed.Input(
        {
            id = "input1",
            text = "..",
            padding = 5,
            w = 200, -- TODO: parent layout percentage
            focus = true,
            -- fg = {r = 1, g =0, b=0},
            fontSize = 20
        }
)

local layout =
    Gui.VLayout(
    {
        padding = 0,
        elements = {
            input,
            btn
        },
        spacing = 0,
    }
)

function init()
    gfx.init("actondev/Gui v1 demo", w, h)
    local R, G, B = 0.3, 0.3, 0.3 -- 0..255 form
    local Wnd_bgd = R * 255 + G * 255 * 256 + B * 255 * 65536 -- red+green*256+blue*65536
    gfx.clear = math.floor(Wnd_bgd)
    gfx.clear = Wnd_bgd

    gfx.clear = Themed.clear
end

function mainloop()
    Gui.pre_draw()
    btn:set("text", tostring(Gui.frame / 10))
    input:set("w", gfx.w)
    layout:draw()
    Gui.post_draw()

    if Gui.char == Chars.CHAR.EXIT then
        return
    end
    if Gui.char == Chars.CHAR.ESCAPE then
        return
    end
    reaper.defer(mainloop)
    gfx.update()
end

init()
mainloop()
