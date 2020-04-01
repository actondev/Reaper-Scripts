package.path = debug.getinfo(1, "S").source:match [[^@?(.*[\/])[^\/]-$]] .. "?.lua;" .. package.path

local Log = require("utils.log")
local Actions = require("utils.actions")
local GuiUtils = require("utils.gui")
local Common = require("utils.common")
local Gui = require("gui.core")
local Chars = require("gui.chars")
local Table = require("utils.table")
local Observe = require("aod.observe")

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
        [Gui.Input.opts.hasFocus] = true
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
        bg = {r = 0.5, g = 0.5, b = 0.5},
        onMouseMove = function(el)
            el.bg.a = 0.2
        end,
        onClick = function(v)
            Log.debug("should execute " .. v.text)
        end
    }
)
local actionButtons = {}
local hwnd = 0

local function runAndRefocus(actionId)
    -- hwnd =  reaper.BR_Win32_GetForegroundWindow()
    Common.cmd(actionId)
    reaper.BR_Win32_SetFocus(hwnd)
end

local markedAction = {["name"] = "Item: Split items at play cursor", ["id"] = 40196}
local actionsList =
    Gui.List:new(
    {
        x = padding,
        y = padding,
        spacing = 0,
        elements = actionButtons,
        selectedIndex = 1,
        hasFocus = true,
        whenSelected = function(v)
            v.bg.r = 1
        end,
        onEnter = function(v)
            -- v.text = ""
            Log.debug(v)
            if Gui.modifiers.none then
                runAndRefocus(v.action.id)
            elseif Gui.modifiers.control then
                markedAction = Table.merge(markedAction, v.action)
            end
        end
    }
)

input.onChange = function(v)
    -- Log.debug("on change")
    for k in pairs(actionButtons) do
        actionButtons[k] = nil
    end

    if v.text == "" then
        return
    end

    local results = Actions.search(Actions.SECTION.MAIN, v.text, 5)
    -- Log.debug("results " ..tostring(#results))
    for i, action in ipairs(results) do
        local btn =
            Gui.Button:new(
            {
                x = 0,
                y = 0,
                w = width - 2 * padding,
                fg = {r = 0, g = 0, b = 0},
                [g.text] = action.name,
                action = action,
                bg = {r = 0.5, g = 0.5, b = 0.5},
                onMouseMove = function(v)
                    v.bg.a = 0.2
                    -- v.fnt_sz = v.fnt_sz + 5
                end,
                onMouseEnter = function(v, p)
                    -- v.bg.a = 0.2
                    actionsList:select(p)
                end,
                onClick = function(v)
                    runAndRefocus(v.action.id)
                end
            }
        )
        actionButtons[i] = btn
    end
end

local layoutSearch =
    Gui.VLayout:new(
    {
        spacing = 10,
        elements = {input, actionsList}
    }
)

local markedActionButton =
    Gui.Button:new(
    {
        w = width - 2 * padding,
        fg = {r = 0, g = 0, b = 0},
        [g.text] = function()
            if markedAction ~= nil then
                return markedAction.name
            end
            return ""
        end,
        bg = {r = 0.5, g = 0.5, b = 0.5}
    }
)

local observers = {
    {name = "at item selection change", handler = Observe.itemSelectionChange()},
    {name = "at cursor position change", handler = Observe.cursorPosition()}
}

local activeObserver = Observe.dummy()

local observersList =
    Gui.List:new(
    {
        x = padding,
        y = padding,
        spacing = 0,
        elements = {},
        selectedIndex = 1,
        hasFocus = true,
        whenSelected = function(v)
            v.bg.r = 1
        end,
        onEnter = function(v,p)
            -- v.text = ""
            Log.debug(v)
            activeObserver = p.observer.handler.init()
            -- if Gui.modifiers.none then
                -- runAndRefocus(v.action.id)
            -- elseif Gui.modifiers.control then
                -- markedAction = Table.merge(markedAction, v.action)
            -- end
        end
    }
)

local observersButtons = Table.map(observers,
function(observer)
    return Gui.Button:new(
        {
            x = 0,
            y = 0,
            w = width - 2 * padding,
            fg = {r = 0, g = 0, b = 0},
            [g.text] = observer.name,
            observer = observer,
            bg = {r = 0.5, g = 0.5, b = 0.5},
            onMouseMove = function(v)
                v.bg.a = 0.2
                -- v.fnt_sz = v.fnt_sz + 5
            end,
            onMouseEnter = function(v, p)
                actionsList:select(p)
            end,
            onClick = function(v)
                runAndRefocus(v.action.id)
            end
        }
    )
end
)

-- Log.debug(observersButtons)

observersList.elements = observersButtons

local layoutMarkedAction =
    Gui.VLayout:new(
    {
        x = 0,
        y = 0,
        spacing = 10,
        elements = {markedActionButton, observersList}
    }
)



local layout = layoutMarkedAction

function init()
    input.text = ""
    input.text = "split items"
    Gui:pre_draw()
    layout:draw()
    gfx.init("actondev/Command Palette", layout.w, 202)
    -- Log.debug("height " .. tostring(layout.h))
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

    if activeObserver.changed() then
        Log.debug("observer change")
        Common.cmd(markedAction.id)
    end

    -- doesn't take into account the title bar
    -- reaper.JS_Window_SetStyle( hwnd, "POPUP" )
    -- reaper.JS_Window_Resize( hwnd, layout.w, layout.h)

    -- Log.debug("height " .. tostring(layout.h))

    -- Log.debug(Gui.char)

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
    -- gfx.update()
end

init()
hwnd = reaper.BR_Win32_GetForegroundWindow()
mainloop()
layout:draw()
gfx.update()
-- input.text = "split items"
