local module = {}
local Theme = require("aod.gui.v1.theme")
local Gui = require("aod.gui.v1.core")
local Table = require("aod.utils.table")
local Log = require("aod.utils.log")

local themeContent = Theme.content(Theme.file())

local function rgb(key)
    local r, g, b = Theme.colorRGB(themeContent, key)
    return {r = r, g = g, b = b}
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

module.Button = function(data)
    local defaults = {
        fontSize = 15,
        font = "Arial",
        fg = btnFg,
        bg = btnBg,
        borderColor = btnBorder,
        borderWidth = 2,
        padding = 5
    }

    data = Table.merge(defaults, data)
    return Gui.Button(data)
end

module.Input = function(data)
    local defaults = {
        fontSize = 15,
        font = "Arial",
        fg = btnFg,
        bg = inputBG,
        borderColor = btnBorder,
        borderWidth = 5,
        padding = 5
    }

    data = Table.merge(defaults, data)
    return Gui.Input(data)
end

return module
