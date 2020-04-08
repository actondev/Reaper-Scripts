local module = {}
local Theme = require("aod.gui.v1.theme")
local Gui = require("aod.gui.v1.core")
local Table = require("aod.utils.table")
local Log = require("aod.utils.log")
local Components = require("aod.gui.v1.components")

local themeContent = Theme.content(Theme.file())

local function rgb(key)
    local r, g, b = Theme.colorRGB(themeContent, key)
    return {r = r, g = g, b = b, a = 1}
end

local function clearColor(color)
    local clear = math.floor(color.r * 255) + math.floor(color.g * 255) * 256 + math.floor(color.b * 255) * 65536
    return clear
end

module.clear = clearColor(rgb(Theme.COLOR.Window_background))
local btnFg = rgb(Theme.COLOR.Window_list_text)
local btnBg = rgb(Theme.COLOR.Window_list_background)
local inputBG = rgb(Theme.COLOR.Window_list_selected_row)
local btnBorder = rgb(Theme.COLOR.Window_list_grid_lines)

local defaultsButton = {
    fontSize = 15,
    font = "Arial",
    fg = btnFg,
    bg = btnBg,
    borderColor = btnBorder,
    borderWidth = 2,
    padding = 5
}

module.Button = function(data)
    data = Table.merge(defaultsButton, data)
    return Gui.Button(data)
end

local defaultsInput = {
    fontSize = 15,
    font = "Arial",
    fg = btnFg,
    bg = inputBG,
    borderColor = btnBg,
    borderWidth = 5,
    padding = 5
}

module.Input = function(data)
    data = Table.merge(defaultsInput, data)
    return Gui.Input(data)
end

local defaultsResultFn = function(btnOpts, key)
    return function(result)
        local btnData = Table.merge(btnOpts, {text = result[key]})
        local btn = module.Button(btnData)
        btn.result = result
        btn:watch_mod(
            "selected",
            function(el, old, new)
                if new then
                    return {
                        [{"bg"}] = rgb(Theme.COLOR.Window_list_selected_row),
                        [{"fg"}] = rgb(Theme.COLOR.Window_list_selected_text)
                    }
                end
            end
        )

        return btn
    end
end

local defaultsLayout = {
    w = "100%",
    spacing = 0,
    padding = 0,
    elements = {}
}

--[[
    Need to pass the followin in data
    - search, eg
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
    - action
]]
module.AutoComplete = function(data)
    local defaultsInput2 =
        Table.merge(
        defaultsInput,
        {
            w = "100%",
            bg = rgb(Theme.COLOR.Window_list_selected_row),
            fg = rgb(Theme.COLOR.Window_list_selected_text)
        }
    )
    data.input = Table.merge(defaultsInput2, data.input)
    data.resultFn =
        defaultsResultFn(
        {
            w = "100%",
            borderWidth = 0
        },
        data.search.key
    )
    data.layout = Table.merge(defaultsLayout, data.layout)
    data.action = data.action or function()
            Log.warning("No action specified")
        end

    return Components.AutoComplete(data)
end

return module
