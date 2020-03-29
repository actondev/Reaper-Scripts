local Common = require('utils.common')
local Log = require('utils.log')
local Track = require('utils.track')
local Item = require('utils.item')
local EditCursor = require('utils.edit_cursor')
local TimeSelection = require('utils.time_selection')
local ItemManipulation = require('utils.item_manipulation')
local Parse = require('utils.parse')

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
    Track.selectChildrenSelected()
end

local function selectSiblings(track)
    Track.selectSiblings(track)
    Track.unselectWithRegex("-(.+)")
end

local function selectChildren(track)
    Track.selectOnly(track)
    Track.selectChildrenSelected()
    Track.unselectWithRegex("-(.+)")
end

-- The optinal startOffset and length are used to select a subregion of the item region
-- Also keeps the time selection.. needed for further actions
-- TODO make the variables more sane....
--
-- @param regionItem The region item
-- @param[opt] startOffset
-- @param[opt] length
function module.select(regionItem, startOffset, length)
    if regionItem == nil then
        return
    end
    Item.unselectAll()
    Item.setSelected(regionItem, true)
    
    local track = Track.fromItem(regionItem)
    local tstart, tend = Item.startEnd(regionItem)
    -- Log.debug("tstart tend " .. tostring(tstart) .. " .. " .. tostring(tend))
    -- or 0: could be an empty item
    local regionItemOffset = Item.getActiveTakeInfo(regionItem, Item.TAKE_PARAM.START_OFFSET) or 0

    if length == nil then
        length = tend - tstart
    end
    if startOffset == nil then
        startOffset = regionItemOffset
    end

    -- Log.debug("length startOffset " .. tostring(length) .. " .. " .. tostring(startOffset))
    local t2start = tstart + startOffset - regionItemOffset
    local t2end = t2start + length

    -- Log.debug("t2start end " .. tostring(t2start) .. " .. " .. tostring(t2end))
    
    -- my time selection needs to be the common ground between tstart, tend and t2start and t2end
    local tcstart = math.max(tstart, t2start)
    local tcend = math.min(tend, t2end)
    if tcstart < tcend then
        TimeSelection.set(tcstart, tcend)
        
        local selMode = getSelectMode(track)
        if selMode == SELECT_MODE.SIBLINGS then
            selectSiblings(track)
        elseif selMode == SELECT_MODE.ALL then
            selectAll()
        elseif selMode == SELECT_MODE.CHILDREN then
            selectChildren(track)
        end
        Item.selectInTimeSelectionAcrossSelectedTracks()
    else
        Log.debug("no time between")
        -- TimeSelection.remove()
    end
    Track.selectOnly(track)
    -- Common.updateArrange()
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
    local sourceName = Item.activeTakeName(source)
    local targetName = Item.activeTakeName(target)
    
    return sourceName == targetName
end


function module.propagate(regionItem)
    if regionItem == nil then
        return
    end
    local track = Track.fromItem(regionItem)
    Track.selectOnly(track)
    Item.selectAllInSelectedTrack()
    
    local otherRegionItems = Item.selected()
    module.select(regionItem)
    
    -- unselecting region item: we don't copy it
    -- and selecting first track that has an item
    Item.setSelected(regionItem, false)
    local firstItem = Item.firstSelected()
    -- validating: we have something to copy
    if firstItem == nil then
        Log.debug("nothing to copy?")
        return
    end
    local firstTrack = Track.fromItem(firstItem)
    
    -- source region offset: should that be permitted?
    -- you should only propagate from.. "complete" region items
    -- the target regions could have offsets and be incomplete, but the source.. doesn't make sense
    local sourceRegionOffset = Item.getActiveTakeInfo(regionItem, Item.TAKE_PARAM.START_OFFSET)
    
    -- copying only the area of the source region
    local sourceStart, sourceEnd = Item.startEnd(regionItem)
    TimeSelection.set(sourceStart, sourceEnd)
    Item.copySelectedArea()

    -- Log.debug("other region items")
    -- Log.debug(Log.dump(otherRegionItems))
    
    --[[
    Note: sourceRegion could be a subregion and targetRegion the full region.
    In that case we want to update only the corresponding subregion inside the full region
    ]]
    for _, targetRegion in pairs(otherRegionItems) do
        if shouldPropagate(regionItem, targetRegion) then
            -- should clear a subregion
            Log.debug("target " .. Item.notes(targetRegion))
            module.clear(targetRegion, sourceRegionOffset, sourceEnd - sourceStart)
            
            Track.selectOnly(firstTrack)
            local tstart, tend = Item.startEnd(targetRegion)
            EditCursor.setPosition(tstart)
            Item.paste()
            
            local targetRegionOffset = Item.getActiveTakeInfo(targetRegion, Item.TAKE_PARAM.START_OFFSET)
            Item.adjustInfoSelected(Item.PARAM.POSITION, sourceRegionOffset - targetRegionOffset)
            
            
            -- trimming pasted items to this region time range
            Item.splitSelected(tstart)
            Item.splitSelected(tend)
            Item.deleteSelectedOutsideOfRange(tstart, tend)
            
            -- adjusting pitch
            local targetPitch = Item.getActiveTakeInfo(targetRegion, Item.TAKE_PARAM.PITCH)
            Item.adjustActiveTakeInfoSelected(Item.TAKE_PARAM.PITCH, targetPitch)
            
            -- manipulating target region
            local targetRegionNotes = Item.notes(targetRegion)
            local manipulationOpts = Parse.parsedTaggedJson(targetRegionNotes, ItemManipulation.TAG_V1)
            ItemManipulation.manipulateSelected(manipulationOpts)
        end
    end
    Track.selectOnly(track)
    Item.unselectAll()
    Item.setSelected(regionItem, true)
end

-- @param regionItem The region item
-- @param[opt] startOffset
-- @param[opt] length
function module.clear(regionItem, startOffset, length)
    if regionItem == nil then
        Log.debug("clearing a.. null region item?")
        return
    end
    module.select(regionItem, startOffset, length)
    -- not deleting the regionItem itself, duh
    Item.setSelected(regionItem, false)
    
    -- IMPORTANT!
    -- there is evidently a bug with split at time selection
    -- if no items are selected, it WILL SPLIT my previously UNSELECTED regionItem... shit
    if Item.selectedCount()> 0 then
        Item.splitSelectedTimeSelection()
        Item.deleteSelected()
    end
end

return module
