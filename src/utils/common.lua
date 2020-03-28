local module = {}
local Log = require('utils.log')
function module.cmd(id)
    if type(id) == "string" then
        reaper.Main_OnCommand(reaper.NamedCommandLookup(id), 0)
    else
        reaper.Main_OnCommand(id, 0)
    end
end

function module.undoBeginBlock()
    reaper.Undo_BeginBlock()
end

function module.undoEndBlock(undoMsg)
    -- extra parameter: extra flags.. what is -1 for?
    reaper.Undo_EndBlock(undoMsg, -1)
end

function module.preventUIRefresh(prevent_count)
    reaper.PreventUIRefresh(prevent_count)
end

function module.updateArrange()
    reaper.UpdateArrange()
end

function module.moveWindowToMouse()
    module.cmd("_BR_MOVE_WINDOW_TO_MOUSE_H_M_V_B")
end

local function split(str, pat)
    local t = {}-- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(t, cap)
        end
        last_end = e + 1
        s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(t, cap)
    end
    return t
end

--[[
    example opts
    {[1] = {title = 'Region item name',
                     default = 'region'},
              [2] = {title = 'Tick division (eg 16th notes)',
                     default = '16'}}
]]
function module.getUserInput(title, opts)
    local titlesCsv = ""
    local valuesCsv = ""
    for _, entry in ipairs(opts) do
        titlesCsv = titlesCsv .. entry['title'] .. ","
        valuesCsv = valuesCsv .. entry['default'] .. ","
    end
    
    titlesCsv = titlesCsv:sub(1, #titlesCsv - 1)
    valuesCsv = valuesCsv:sub(1, #valuesCsv - 1)
    
    local retval, valuesCsv = reaper.GetUserInputs(title, 2, titlesCsv, valuesCsv)
    if not retval then
        return nil
    end

    local valuesTable = split(valuesCsv,"[,]+")
    return valuesTable
end

module.EDIT_CONTEXT = {
    ITEM = 'item',
    TRAK = 'track'
}

-- returns if we should edit/act upon media items or media tracks
function module.getEditContext()
    if reaper.GetCursorContext2(true) == 1 and reaper.CountSelectedMediaItems(0)>0 then
        return module.EDIT_CONTEXT.ITEM
    else
        return module.EDIT_CONTEXT.TRAK
    end
end

return module
