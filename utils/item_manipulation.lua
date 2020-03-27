--[[
Manipulates a collection of items

Example arguments:
- {track = '*', take = 'take to be removed', action = 'delete'}
]]
local module = {}

local Item = require('utils.item')
local Track = require('utils.track')
local Common = require('utils.common')

local Log = require('utils.log')

-- TODO maybe rename to OPERATION?
-- cause an op could be "action".. to denote a reaper action (passing an action id)
module.ACTION = {
    DELETE = 'delete',
    MUTE = 'mute',
    REVERSE = 'reverse',
    SET_PITCH = 'set_pitch'
}

module.TAG_V1 = '@aod.manipulate.v1'

local function applyOperation(item, opts)
    local action = opts['action']
    -- Log.debug("item " .. tostring(item) .. " action " .. action)
    if action == module.ACTION.DELETE then
        Item.delete(item)
    elseif action == module.ACTION.MUTE then
        Item.setInfo(item, Item.PARAM.MUTE, 1)
    elseif action == module.ACTION.REVERSE then
        Item.toggleActiveTakeReverse(item)
    elseif action == module.ACTION.SET_PITCH then
        Item.setActiveTakeInfo(item, Item.TAKE_PARAM.PITCH, opts['value'])
    end
end

-- TODO check validity of action
local function isOptsValid(opts)
    return opts ~= nil and opts['action'] ~= nil
end

local function manipulateItem(item, opts)
    local isItemValid = Item.validate(item)
    if not isItemValid then
        return
    end
    
    local track = Track.fromItem(item)
    local trackName = Track.name(track)
    -- track and take can be missing: if so, default to ".*"
    if isItemValid and string.match(trackName, opts['track'] or ".*") then
        local takeName = Item.name(item)
        if string.match(takeName, opts['take'] or ".*") then
            applyOperation(item, opts)
        end
    end
end

--[[
which way should be better
- apply each rule to all items (loop rules first?)
- apply go through all the items and apply all the rules

Right now I'm looping through all the rules -> applying to all the items
]]
function module.manipulateItems(items, opts)
    if opts == nil then
        return
    end
    if #opts > 0 then
        -- multiple opts -> calling this function again
        for _, opt in pairs(opts) do
            module.manipulateItems(items, opt)
        end
        return
    else
        -- single opt rule
        for _,item in pairs(items) do
            manipulateItem(item, opts)
        end
    end
    
    -- when we delte items, we need to call updateArrange
    Common.updateArrange()
end

function module.manipulateSelected(opts)
    local items = Item.selected()
    module.manipulateItems(items, opts)
end

return module
