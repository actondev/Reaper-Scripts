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

local rgb = Themed.rgb(Theme.COLOR.Media_item_background_even)
-- Log.debug("rgb", rgb)

local makeArmedButton = function(text)
    local btn =
        Themed.Button(
        {
            text = text,
            w = "100%",
            bg = Themed.rgb(Theme.COLOR.Media_item_background_even)
        }
    )

    return btn
end

local actionResultFn = function(result)
    -- Log.debug("called action result for ", result)
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

    return btn
end

local autoCompleteActions =
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

local observeResultFn = function(result)
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
local app =
    Gui.Mutable(
    {
        markedAction = nil,
        -- markedActionLabel = nil,
        markedActionLabel = makeArmedButton("action.."),
        observer = nil,
        observerName = nil,
        observerHandler = nil,
        observerLabel = makeArmedButton("observer.."),
        armedActionCounter = 0,
        armedActionCounterLabel = Themed.Label({text = "Run: 0 times"}),
        layout = Gui.VLayout(
            {
                padding = 0,
                w = 100, -- will be set on redraw
                elements = {
                    autoCompleteActions
                },
                spacing = 0
            }
        ),
        autocomplete = {
            actions = autoCompleteActions,
            observers = autoCompleteObserve
        }
    }
)
app.data.layout:set("elements", {app.data.autocomplete.actions})

function app:markAction(action)
    app:set("markedAction", action)
end

app:watch(
    "markedAction",
    function(el, old, new)
        local self = app
        if new then
            app.data.markedActionLabel:set("text", self.data.markedAction.name)
            app.data.layout:set("elements", {self.data.markedActionLabel, autoCompleteObserve})
        else
            app.data.layout:set("elements", {self.data.autocomplete.actions})
        end
    end
)

app:watch(
    "armedActionCounter",
    function()
        app.data.armedActionCounterLabel:set("text", "Run: " .. tostring(app.data.armedActionCounter) .. " times")
    end
)
app:set("armedActionCounter", 0, true)

function app:setObserver(observer)
    app:set("observer", observer)
end

app:watch(
    "observer",
    function(el, old, new)
        if new then
            app:set("observerName", new.name)
            app:set("observerHandler", new.handler.init())
            app.data.observerLabel = makeArmedButton(new.name)
            app.data.armedActionCounterLabel:set("text", "Run: " .. tostring(app.data.armedActionCounter) .. " times")
            app.data.layout:set(
                "elements",
                {app.data.markedActionLabel, app.data.observerLabel, app.data.armedActionCounterLabel}
            )
        else
            -- Log.debug("unarmed observer")
            -- layout: marked action and searching for observer
            app.data.layout:set("elements", {app.data.markedActionLabel, app.data.autocomplete.observers})
        end
    end
)

function app:main()
    if Gui.char == Chars.CHAR.ESCAPE then
        if self.data.observer ~= nil then
            -- removing armed observer
            self:set("observer", nil)
            self.data.autocomplete.observers:clear()
        elseif self.data.markedAction ~= nil then
            -- removing armed action
            self:set("markedAction", nil)
            self.data.autocomplete.actions:clear()
        elseif self.data.autocomplete.actions:getText() ~= "" then
            -- removing action search filter/query
            self.data.autocomplete.actions:clear()
        else
            -- .. quitting program
            return false
        end
    end
    if app.data.markedAction and app.data.observer and app.data.observerHandler then
        if self.data.observerHandler.changed() then
            Common.cmd(self.data.markedAction.id)
            self:set("armedActionCounter", self.data.armedActionCounter + 1)
        end
    end
    self.data.layout:set("w", gfx.w)
    self.data.layout:draw()
    return true
end

function app:setBackWindow()
    self.data.hwndBack = Common.getForegroundWindow()
end

function app:setScriptWindow()
    self.data.hwndScript = Common.getForegroundWindow()
    self:positionScript()
end

function app:positionScript()
    local _, left, top, right, bottom = reaper.BR_Win32_GetWindowRect(self.data.hwndBack)
    -- local hwndStr = reaper.BR_Win32_HwndToString(self.data.hwndScript)
    local _, leftScript, topScript, rightScript, bottomScript = reaper.BR_Win32_GetWindowRect(self.data.hwndScript)
    local x = math.floor(left + (right - left) / 2 - gfx.w / 2)
    local y = math.floor(bottom + (top - bottom) / 2 - gfx.h / 2)
    reaper.BR_Win32_SetWindowPos(self.data.hwndScript, "", x, y, gfx.w, bottomScript - topScript, 0)
end

function app:runAction(action)
    Common.cmd(action.id)
    if self.data.hwndScript then
        reaper.BR_Win32_SetFocus(self.data.hwndScript)
    end
end

autoCompleteActions:on(
    Components.AutoComplete.SIGNALS.RETURN,
    function(data)
        local selection = data.selection
        local btn = data.item
        if Gui.modifiers.control then
            app:markAction(selection)
        else
            app:runAction(selection)
        end
    end
)

autoCompleteObserve:on(
    Components.AutoComplete.SIGNALS.RETURN,
    function(data)
        local selection = data.selection
        local btn = data.item
        -- Log.debug("observe : selection is", selection)
        app:setObserver(selection)
    end
)

-- demo
--  app:markAction({["id"] = 40012, ["name"] = "Item: Split items at edit or play cursor"})

function init()
    gfx.init("actondev/Command Palette", w, app.data.layout:height())
    gfx.clear = Themed.clear
end

function mainloop()
    Gui.pre_draw()
    Gui.post_draw()

    if Gui.char == Chars.CHAR.EXIT then
        return
    end
    if not app:main() then
        return
    end

    reaper.defer(mainloop)
    gfx.update()
end

app:setBackWindow()
init()
app:setScriptWindow()
mainloop()
