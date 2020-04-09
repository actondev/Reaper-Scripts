package.path = debug.getinfo(1, "S").source:match [[^@?(.*[\/])[^\/]-$]] .. "?.lua;" .. package.path

local w = 500
local h = 300
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
        text = "hello world 11",
        w = "100%",
        padding = 10,
        borderWidth = 2
    }
)

local input =
    Themed.Input(
    {
        id = "input1",
        text = "",
        placeholder = "Start typing to search actions",
        padding = 5,
        w = "100%",
        focus = true,
        fontSize = 20
    }
)

local autoComplete = Themed.AutoComplete(
    {
        search = {
            entries = {
                {name = "split items"},
                {name = "start recording"},
                {name = "do this"},
                {name = "do that"}
            }, -- an array of the searchable entries
            query = "query", -- the query to search over the entries
            limit = 10,
            key = "name", -- the key of the entries to perform the search to
            showAll = true
        },
        input = {
            focus = true,
        },
        action = function(result)
            Log.debug("hey there",result)
        end
    }
)

local layout =
    Gui.VLayout(
    {
        padding = 0,
        w = 100, -- will be set on redraw
        elements = {
            -- input,
            -- btn,
            autoComplete
        },
        spacing = 0
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
    layout:set("w", gfx.w)
    -- btn:set("text", tostring(Gui.frame / 10))
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
