package.path = debug.getinfo(1, "S").source:match [[^@?(.*[\/])[^\/]-$]] .. "?.lua;" .. package.path

local w = 500
local h = 500

local Gui = require("aod.gui.v1.core")
local Chars = require("gui.chars")
local Log = require("aod.utils.log")
local Table = require("aod.utils.table")
Log.LEVEL = Log.DEBUG

local el =
    Gui.Element(
    {
        id = "el",
        x = 10,
        y = 10,
        w = 30,
        h = 30,
        borderColor = {
            r = 1,
            g = 1,
            b = 1
        },
        borderWidth = 5,
        bg = {
            r = 0.5,
            g = 0.5,
            b = 0.5
        }
    }
)

el:on(
    Gui.SIGNALS.CLICK,
    function(el)
        Log.debug("click on", el.data.id)
    end
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
        borderColor = {
            r = 1,
            g = 1,
            b = 1
        },
        borderWidth = 2,
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
        text = "hello world",
        font = "Arial",
        fontSize = 15
    }
)

-- example of applying a certain style when hovered
el:on(
    Gui.SIGNALS.MOUSE_ENTER,
    function(el)
        el._app_bg = Table.deepcopy(el.data.bg)
        el.data.bg = {r = 1, g = 0, b = 0}
    end
)

el:on(
    Gui.SIGNALS.MOUSE_LEAVE,
    function(el)
        el.data.bg = el._app_bg
        el._app_bg = nil
    end
)

-- a better way to do apply a style when hovered
btn:watch_mod(
    "hover",
    function(el, oldValue, newValue)
        if newValue then
            -- modifing background green to 1
            return {[{"bg", "g"}] = 1}
        else
            -- upon returning nil, the mod applied change is reversed
            return nil
        end
    end
)

local layoutBtnOpts = {
    id = "repeated btn",
    borderColor = {
        r = 1,
        g = 1,
        b = 1
    },
    borderWidth = 2,
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
    text = "button"
}

local input =
    Gui.Input(
    {
        id = "input1",
        text = "..",
        padding = 5,
        focus = true,
        fg = {r = 1, g = 0, b = 0},
        fontSize = 20
    }
)

local input2 =
    Gui.Input(
    {
        id = "input2",
        text = "",
        placeholder = "Input 2: start typing",
        padding = 5,
        focus = false,
        fontSize = 20
    }
)

local hlayout =
    Gui.HLayout(
    {
        id = "hlayout",
        bg = {
            r = 0,
            g = 0.5,
            b = 0.5
        },
        spacing = 10,
        elements = {
            Gui.Button(layoutBtnOpts),
            Gui.Button(layoutBtnOpts),
            Gui.Button(layoutBtnOpts)
        }
    }
)

local layout =
    Gui.VLayout(
    {
        id = "vlayout",
        x = 10,
        y = 100,
        borderColor = {
            r = 1,
            g = 0,
            b = 0
        },
        borderWidth = 1,
        padding = 10,
        spacing = 5,
        elements = {
            Gui.Button(layoutBtnOpts),
            Gui.Button(layoutBtnOpts),
            Gui.Button(layoutBtnOpts),
            input,
            hlayout,
            input2
        }
    }
)

function init()
    gfx.init("actondev/Gui v1 demo", w, h)
    local R, G, B = 0, 0, 0 -- 0..255 form
    local Wnd_bgd = R + G * 256 + B * 65536 -- red+green*256+blue*65536
    gfx.clear = Wnd_bgd
end

function mainloop()
    Gui.pre_draw()
    btn:set("text", tostring(Gui.frame / 10))
    el:draw()
    btn:draw()
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
