local Common = require('utils.common')
local Log = require('utils.log')
local Store = require('utils.store')
local Track = require('utils.track')
local Item = require('utils.item')
local TimeSelection = require('utils.time_selection')

local module = {}

-- select mode "enum"
local SELECT_MODE = {
    ALL = 0,
    SIBLINGS = 1,
    CHILDREN = 2
}

local function getSelectMode(track)
    local trackName = Track.name(track)
    local firstChar = string.sub(trackName, 1, 1)
    
    if firstChar == "*" then
        return SELECT_MODE.ALL
    elseif firstChar == ">" then
        return SELECT_MODE.SIBLINGS
    else
        return SELECT_MODE.CHILDREN
    end
end

local function selectAll()
    Track.selectAllTopLevel()
    Track.unselectWithRegex("-(.+)")
    Track.selectChildren()
end

local function selectSiblings(track)
    Track.selectSiblings(track)
    Track.unselectWithRegex("-(.+)")
end

local function selectChildren()
    Track.selectChildren()
    Track.unselectWithRegex("-(.+)")
end

function module.select(regionItem)
    Common.undoBeginBlock()
    Common.preventUIRefresh(1)
    
    Item.unselectAll()
    Item.setSelected(regionItem, true)
    
    TimeSelection.setToSelectedItems()
    local track = Track.fromItem(regionItem)
    local selMode = getSelectMode(track)
    if selMode == SELECT_MODE.SIBLINGS then
        selectSiblings(track)
    elseif selMode == SELECT_MODE.ALL then
        selectAll()
    elseif selMode == SELECT_MODE.CHILDREN then
        selectChildren()
    end
    Item.selectInTimeSelectionAcrossSelectedTracks()
    
    TimeSelection.remove()
    
    Track.selectOnly(track)
    
    Common.preventUIRefresh(-1)
    Common.undoEndBlock("ActonDev/Region items: select")
end

local function shouldPropagate(source, target)
    if source == target then
        return false
    end
    
    local sourceType = Item.type(source)
    local targetType = Item.type(target)
    
    if sourceType ~= targetType then
        return false
    end
    
    if sourceType == Item.TYPE.EMPTY then
        return Item.notes(source) == Item.notes(target)
    end
    local sourceName = Item.name(source)
    local targetName = Item.name(target)
    
    return sourceName == targetName
end

-- propagates/copies this region (item) to other matching ones in the same track
function module.propagate(regionItem)
    Common.undoBeginBlock()
    Store.storeArrangeView()
    Store.storeCursorPosition()
    Common.preventUIRefresh(1)
    
    local track = Track.fromItem(regionItem)
    Track.selectOnly(track)
    Item.selectAllInSelectedTrack()
    
    local items = Item.selected()
    
    module.select(regionItem)
    Item.copySelected()
    Item.unselectAll()
    
    for _, item in pairs(items) do
        if shouldPropagate(regionItem, item) then
            -- Log.debug("propagating from " .. Item.notes(regionItem) .. " to " .. Item.notes(item))
            module.select(item)
            Item.deleteSelected()
            Item.paste()
        end
    end
    
    Item.unselectAll()
    Item.setSelected(regionItem, true)
    
    Store.restoreArrangeView()
    Store.restoreCursorPosition()
    Common.preventUIRefresh(-1)
    Common.undoEndBlock("ActonDev/Region items: propagate")
end

function module.clear(regionItem)
    Common.undoBeginBlock()
    Common.preventUIRefresh(1)
    
    module.select(regionItem)
    Item.setSelected(regionItem, false)
    Item.deleteSelected()
    
    Common.preventUIRefresh(-1)
    Common.undoEndBlock("ActonDev/Region items: clear")
end

return module
