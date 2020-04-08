--[[
    Gui Components
    - Made out of extending and composing the core elements
]]
local Gui = require("aod.gui.v1.core")
local Class = require("aod.utils.class")
local Search = require("aod.utils.search")
local Log = require("aod.utils.log")
local Table = require("aod.utils.table")
local module = {}

local layoutBtnOpts = {
    id = "repeated btn",
    w = "100%",
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

local exampleData = {
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
    action = function(result)
        Log.debug("pressed enter, active is", result)
    end,
    resultFn = function(result) -- to generate a button
        layoutBtnOpts.text = result.name
        local btn = Gui.Button(layoutBtnOpts)
        btn.result = result
        btn:watch_mod(
            "selected",
            function(el, old, new)
                if new then
                    return {
                        [{"borderColor"}] = {r = 1, b = 0, g = 0}
                    }
                end
            end
        )
    
        return btn
    end,
    layout = {
        w = "100%",
        borderColor = {r = 0, g = 0, b = 1, a = 1},
        borderWidth = 2,
        elements = {}
    }, -- options to be passed to the layout
    input = {
        w = "100%",
        placeholder = "start typing to search"
    }
}

module.AutoComplete = Class.extend(Gui.VLayout)

function module.AutoComplete:__construct(data)
    data = data or exampleData
    local input = Gui.Input(data.input)

    local resultList =
        Gui.List(
        {
            focus = true,
            w = "100%",
            elements = {},
            padding = 0,
            spacing = 0,
        }
    )

    input:watch(
        "text",
        function(el, oldV, newV)
            data.search.query = newV
            local results = Search.search(data.search)
            local buttons = Table.map(results, data.resultFn)
            resultList:set("elements", buttons)
        end
    )

    input:set("text", "", true)
    input:on(Gui.SIGNALS.RETURN, function()
        local selected = resultList:selected()
        if selected then
            -- Log.debug("selected is ", selected.result)
            data.action(selected.result)
        end
    end)

    data.layout.elements = {
        input,
        resultList
    }

    Gui.VLayout.__construct(self, data.layout)
end

return module
