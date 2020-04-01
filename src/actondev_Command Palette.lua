package.path = debug.getinfo(1, "S").source:match [[^@?(.*[\/])[^\/]-$]] .. "?.lua;" .. package.path

local Log = require("utils.log")
local Actions = require("utils.actions")
local GuiUtils = require("utils.gui")
local Common = require("utils.common")
local Gui = require("gui.core")
local Chars = require("gui.chars")

Log.isdebug = true

-- Actions.getActions(Actions.SECTION.MAIN, 10)
local res = Actions.search(Actions.SECTION.MAIN, "split asd", false)

if #res > 1 then
    Log.debug("first match: " .. res[1].name)
-- Common.cmd(res[1].id)
end

-- Log.debug(Log.dump(res))

local width = 500
local padding = 10

local g = Gui.OPTS

local input =
    Gui.Input:new(
    {
        -- x y don't matter if we put into a layout
        x = 0,
        y = 0,
        w = width - 2 * padding,
        fg = {r = 0, g = 0, b = 0},
        [g.text] = "",
        bg = {r = 0.5, g = 0.5, b = 0.5},
        [Gui.Input.opts.focus] = true
    }
)

local testBtn =
    Gui.Button:new(
    {
        x = 0,
        y = 0,
        w = width - 2 * padding,
        fg = {r = 0, g = 0, b = 0},
        [g.text] = "test action",
        _action_id = 1,
        bg = {r = 0.5, g = 0.5, b = 0.5},
        onMouseMove = function(el)
            el.bg.a = 0.2
        end,
        onClick = function(v)
            Log.debug("should execute " .. v.text)
            Log.debug("action id " .. v._action_id)
        end
    }
)
local actionButtons = {testBtn}

input.onChange = function(v)
    for k in pairs(actionButtons) do
        actionButtons[k] = nil
    end

    if v.text == "" then
        return
    end

    local results = Actions.search(Actions.SECTION.MAIN, v.text, 5)
    for i, action in ipairs(results) do
        local btn =
            Gui.Button:new(
            {
                x = 0,
                y = 0,
                w = width - 2 * padding,
                fg = {r = 0, g = 0, b = 0},
                [g.text] = action.name,
                _action_id = action.id,
                bg = {r = 0.5, g = 0.5, b = 0.5},
                onMouseMove = function(el)
                    -- Log.debug("mouse over")
                    el.bg.a = 0.2
                end,
                onClick = function(v)
                    Log.debug("should execute " .. v.text)
                    Log.debug("action id " .. v._action_id)
                end
            }
        )
        actionButtons[i] = btn
    end
end

local actionsList =
    Gui.List:new(
    {
        x = padding,
        y = padding,
        spacing = 0,
        elements = actionButtons,
        selectedIndex = 1,
        whenSelected = function(v)
            v.bg.r = 1
        end
    }
)

local layout =
    Gui.VLayout:new(
    {
        x = padding,
        y = padding,
        spacing = 10,
        elements = {input, actionsList}
    }
)

function init()
    gfx.init("actondev/Command Palette", width, 200)
    Common.moveWindowToMouse()
    local R, G, B = 60, 60, 60 -- 0..255 form
    local Wnd_bgd = R + G * 256 + B * 65536 -- red+green*256+blue*65536
    gfx.clear = Wnd_bgd
end

function mainloop()
    Gui.pre_draw()
    ---
    layout:draw()
    ---
    Gui.post_draw()

    if Gui.char == Chars.CHAR.EXIT then
        return
    end
    if Gui.char == Chars.CHAR.ESCAPE then
        if input.text == "" then
            return
        else
            input.text = ""
        end
    end
    reaper.defer(mainloop)
    gfx.update()
end

init()
mainloop()
