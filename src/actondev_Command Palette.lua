package.path = debug.getinfo(1, "S").source:match [[^@?(.*[\/])[^\/]-$]] .. "?.lua;" .. package.path

local w = 500
local h = 300
local Log = require("aod.utils.log")
Log.LEVEL = Log.DEBUG

local Common = require("aod.reaper.common")
local Gui = require("aod.gui.v1.core")
local Components = require("aod.gui.v1.components")
local Chars = require("gui.chars")
local Table = require("aod.utils.table")

local Themed = require("aod.gui.v1.themed")
local Theme = require("aod.gui.v1.theme")

local Actions = require("aod.reaper.actions")
local Observe = require("aod.reaper.observe")

local actions = Actions.getActions(Actions.SECTION.MAIN)

local actionResultFn = function(result)
    local btn = Themed.Button({text = result.name, w = "100%", armed = false, borderWidth = 0})
    btn.result = result
    btn:watch_mod(
        "selected",
        function(el, old, new)
            if new then
                return {
                    [{"bg"}] = Themed.rgb(Theme.COLOR.Window_list_selected_row),
                    [{"fg"}] = Themed.rgb(Theme.COLOR.Window_list_selected_text)
                }
            end
        end
    )

    btn:watch_mod(
        "armed",
        function(el, old, new)
            -- Log.debug("armed!!!", old, new)
            if new then
                return {
                    [{"bg"}] = Themed.rgb(Theme.COLOR.Media_item_background_even)
                }
            end
        end
    )

    return btn
end

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
            focus = true,
            placeholder = "Search for actions"
        },
        resultFn = actionResultFn
    }
)

local app =
    Gui.Object(
    {
        markedAction = nil,
        markedActionLabel = Themed.Label(),
        observer = Observe.never()
    }
)

app:watch(
    "markedAction",
    function(el, old, new)
        app.data.markedActionLabel:set("text", "Run: " .. new.name)
    end
)

function app:setBackWindow()
    self.data.hwndBack = Common.getForegroundWindow()
end

function app:setScriptWindow()
    self.data.hwndScript = Common.getForegroundWindow()
end

function app:positionScript()
    local _, left, top, right, bottom = reaper.BR_Win32_GetWindowRect(self.data.hwndBack)
    -- local hwndStr = reaper.BR_Win32_HwndToString(self.data.hwndScript)
    local _, leftScript, topScript, rightScript, bottomScript = reaper.BR_Win32_GetWindowRect(self.data.hwndScript)
    local x = math.floor(left + (right - left) / 2 - gfx.w / 2)
    local y = math.floor(bottom + (top - bottom) / 2 - gfx.h / 2)
    reaper.BR_Win32_SetWindowPos(self.data.hwndScript, "", x, y, gfx.w, bottomScript - topScript, 0)
end

function app:markAction(action)
    app:set("markedAction", action)
end

function app:setObserver(observer)
    app:set("observer", observer.init())
end

function app:runAction(action)
    Common.cmd(action.id)
    if self.data.hwndScript then
        reaper.BR_Win32_SetFocus(self.data.hwndScript)
    end
end

function app:checkAndRunMarkedAction()
    if self.data.observer.changed() then
        -- Log.debug("running action", self.data.markedAction)
        Common.cmd(self.data.markedAction.id)
    end
end

autoComplete:on(
    Components.AutoComplete.SIGNALS.RETURN,
    function(data)
        local selection = data.selection
        local btn = data.item
        if Gui.modifiers.control then
            app:markAction(selection)
            btn:set("armed", true)
        else
            app:runAction(selection)
        end
    end
)

local observeResultFn = function(result)
    local btn = Themed.Button({text = result.name, w = "100%", armed = false})
    btn.result = result
    btn:watch_mod(
        "selected",
        function(el, old, new)
            if new then
                return {
                    [{"bg"}] = Themed.rgb(Theme.COLOR.Window_list_selected_row),
                    [{"fg"}] = Themed.rgb(Theme.COLOR.Window_list_selected_text)
                }
            end
        end
    )

    btn:watch_mod(
        "armed",
        function(el, old, new)
            -- Log.debug("armed!!!", old, new)
            if new then
                return {
                    [{"bg"}] = Themed.rgb(Theme.COLOR.Media_item_background_even)
                }
            end
        end
    )

    return btn
end

local autoCompleteObserve =
    Themed.AutoComplete(
    {
        search = {
            entries = Observe.getAll(),
            query = "query", -- the query to search over the entries
            limit = 5,
            key = "name", -- the key of the entries to perform the search to
            showAll = true
        },
        input = {
            focus = true,
            placeholder = "Search for triggers"
        },
        resultFn = observeResultFn
    }
)

-- TODO the signal should maybe not call the callback with "self" as first argument, but only the relevant data
autoCompleteObserve:on(
    Components.AutoComplete.SIGNALS.RETURN,
    function(data)
        local selection = data.selection
        local btn = data.item
        -- btn:set("mar")
        -- Log.debug("observe : selection is", selection)
        app:setObserver(selection.handler)
    end
)

-- demo
--  app:markAction({["id"] = 40012, ["name"] = "Item: Split items at edit or play cursor"})

local layoutActions =
    Gui.VLayout(
    {
        padding = 0,
        w = 100, -- will be set on redraw
        elements = {
            autoComplete
            -- autoCompleteObserve
        },
        spacing = 0
    }
)

local layoutMarkedAction =
    Gui.VLayout(
    {
        padding = 0,
        w = 100, -- will be set on redraw
        elements = {
            app.data.markedActionLabel,
            autoCompleteObserve
        },
        spacing = 0
    }
)

function init()
    gfx.init("actondev/Command Palette", w, layoutActions:height())
    gfx.clear = Themed.clear
end

function mainloop()
    Gui.pre_draw()
    layoutActions:set("w", gfx.w)
    layoutMarkedAction:set("w", gfx.w)
    if app:get("markedAction") == nil then
        layoutActions:draw()
    else
        layoutMarkedAction:draw()
        app:checkAndRunMarkedAction()
    end
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

local backWindow = Common.getForegroundWindow()
app:setBackWindow()
init()
app:setScriptWindow()
app:positionScript()
mainloop()
