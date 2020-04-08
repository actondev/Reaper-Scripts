package.path = debug.getinfo(1, "S").source:match [[^@?(.*[\/])[^\/]-$]] .. "?.lua;" .. package.path

local w = 500
local h = 300
local Log = require("aod.utils.log")
Log.LEVEL = Log.DEBUG

local Gui = require("aod.gui.v1.core")
local Chars = require("gui.chars")
local Table = require("aod.utils.table")

local Themed = require("aod.gui.v1.themed")

local Actions = require("aod.reaper.actions")

local actions = Actions.getActions(Actions.SECTION.MAIN)

local autoComplete =
    Themed.AutoComplete(
    {
        search = {
            entries = actions,
            query = "query", -- the query to search over the entries
            limit = 5,
            key = "name", -- the key of the entries to perform the search to
            showAll = true
        },
        input = {
            focus = true
        },
        action = function(result)
            Log.debug("hey there", result)
        end
    }
)

local layout =
    Gui.VLayout(
    {
        padding = 0,
        w = 100, -- will be set on redraw
        elements = {
            autoComplete
        },
        spacing = 0
    }
)

function init()
    gfx.init("actondev/Command Palette", w, layout:height())
    gfx.clear = Themed.clear
end

function mainloop()
    Gui.pre_draw()
    layout:set("w", gfx.w)
    layout:draw()
    Gui.post_draw()

    if Gui.char == Chars.CHAR.EXIT then
        return
    end
    if Gui.char == Chars.CHAR.ESCAPE then
        if autoComplete.input.data.text == "" then
            return
        else
            -- clearing input text on escape
            -- does this belong here..?
            autoComplete.input:clear()
        end
    end
    reaper.defer(mainloop)
    gfx.update()
end

init()
mainloop()
