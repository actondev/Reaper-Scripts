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

module.ACTION = {
    DELETE = 'delete',
    MUTE = 'mute',
    REVERSE = 'reverse'
}

module.TAG_V1 = '@aod.manipulate.v1'

local function manipulateItem(item, action)
    -- Log.debug("item " .. tostring(item) .. " action " .. action)
    if action == module.ACTION.DELETE then
        Item.delete(item)
    elseif action == module.ACTION.MUTE then
        Item.setInfo(item, Item.PARAM.MUTE, 1)
    elseif action == module.ACTION.REVERSE then
        Item.toggleActiveTakeReverse(item)
    end
end

-- TODO check validity of action
local function isOptsValid(opts)
    return opts ~= nil and opts['track']~=nil and opts['take']~=nil and opts['action']~=nil
end

function module.manipulate(opts, items)
    if opts == nil then
        return
    end
    if #opts > 0 then
        for _,opt in pairs(opts) do
            module.manipulate(opt, items)
        end
        return
    end

    if not isOptsValid(opts) then
        return
    end

    for key,item in pairs(items) do
        local track = Track.fromItem(item)
        local trackName = Track.name(track)
        if string.match(trackName, opts['track']) then
            local takeName = Item.name(item)
            if string.match(takeName, opts['take']) then
                manipulateItem(item, opts['action'])
                if opts['action'] == module.ACTION.DELETE then
                    -- hack: removing the deleted item
                    -- if not, reaper will complaing that the passed item is not.. a MediaItem
                    table.remove(items, key)
                end
            end
        end
    end
    -- when we delte items, we need to call updateArrange
    Common.updateArrange()
end

function module.manipulateSelected(opts)
    local items = Item.selected()
    module.manipulate(opts, items)
end

return module