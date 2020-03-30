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
    -- or 0: could be an empty item
    local regionItemOffset = Item.getActiveTakeInfo(regionItem, Item.TAKE_PARAM.START_OFFSET) or 0
    
    if length == nil then
        length = tend - tstart
    end
    if startOffset == nil then
        startOffset = regionItemOffset
    end
    
    local subregionStart = tstart + startOffset - regionItemOffset
    local subregionEnd = subregionStart + length
    
    -- have to see which part I should update: intersection of this region against the subregion
    local intersectionStart = math.max(tstart, subregionStart)
    local intersectionEnd = math.min(tend, subregionEnd)
    if intersectionStart < intersectionEnd then
        TimeSelection.set(intersectionStart, intersectionEnd)
        
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
        -- no common time between this region and the passed subregion
        end
    Track.selectOnly(track)
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

function module.propagateFromTo(sourceRegionItem, targetRegionItem)
    local sourceStart, sourceEnd = Item.startEnd(sourceRegionItem)

    -- TODO.. better copy always? there are problems concerning the first item
    -- if shouldCopy then
        module.select(sourceRegionItem)
        -- unselecting region item: we don't copy it
        Item.setSelected(sourceRegionItem, false)
        -- copying only the area of the source region
        TimeSelection.set(sourceStart, sourceEnd)
        Item.copySelectedArea()
    -- end
    
    -- we need the first selected item to later select this item's track when pasting:
    -- in order for the items to be pasted in the correct track
    local firstSelItem = Item.firstSelected()
    local sourceRegionOffset = Item.getActiveTakeInfo(sourceRegionItem, Item.TAKE_PARAM.START_OFFSET)
    
    -- Note: sourceRegion could be a subregion and targetRegion the full region.
    -- In that case we want to update only the corresponding subregion inside the full region
    if shouldPropagate(sourceRegionItem, targetRegionItem) then
        -- Log.debug("target " .. Item.notes(targetRegion))
        module.clear(targetRegionItem, sourceRegionOffset, sourceEnd - sourceStart)
        local tstart, tend = Item.startEnd(targetRegionItem)
        
        if firstSelItem then
            -- need to "touch" the first track that I copy the items from
            -- if not they get pasted in wrong places
            local firstTrack = Track.fromItem(firstSelItem)
            Track.selectOnly(firstTrack)
            EditCursor.setPosition(tstart)
            Item.paste()
        end
        
        local targetRegionOffset = Item.getActiveTakeInfo(targetRegionItem, Item.TAKE_PARAM.START_OFFSET)
        Item.adjustInfoSelected(Item.PARAM.POSITION, sourceRegionOffset - targetRegionOffset)
        
        -- trimming pasted items to this region time range
        Item.splitSelected(tstart)
        Item.splitSelected(tend)
        Item.deleteSelectedOutsideOfRange(tstart, tend)
        
        -- adjusting pitch
        local targetPitch = Item.getActiveTakeInfo(targetRegionItem, Item.TAKE_PARAM.PITCH)
        Item.adjustActiveTakeInfoSelected(Item.TAKE_PARAM.PITCH, targetPitch)
        
        -- manipulating target region
        local targetRegionNotes = Item.notes(targetRegionItem)
        local manipulationOpts = Parse.parsedTaggedJson(targetRegionNotes, ItemManipulation.TAG_V1)
        ItemManipulation.manipulateSelected(manipulationOpts)
    end
end

function module.propagate(regionItem)
    if regionItem == nil then
        return
    end
    
    local track = Track.fromItem(regionItem)
    Track.selectOnly(track)
    Item.selectAllInSelectedTrack()
    
    Item.setSelected(regionItem, false)
    local otherRegionItems = Item.selected()
    
    for _i, targetRegion in ipairs(otherRegionItems) do
        module.propagateFromTo(regionItem, targetRegion)
    end
    
    Track.selectOnly(track)
    Item.unselectAll()
    Item.setSelected(regionItem, true)
end

local function isSubregionOf(regionItem, otherRegion)
    local tstart, tend = Item.startEnd(regionItem)
    local length = tend - tstart
    local regionStart = Item.getActiveTakeInfo(regionItem, Item.TAKE_PARAM.START_OFFSET)
    local regionEnd = regionStart + length

    local tstartOther, tendOther = Item.startEnd(otherRegion)
    local lengthOther = tendOther - tstartOther
    local regionStartOther = Item.getActiveTakeInfo(otherRegion, Item.TAKE_PARAM.START_OFFSET)
    local regionEndOther = regionStartOther + lengthOther

    return regionStartOther <= regionStart and regionEndOther >= regionEnd
end

-- we scan across the track items to find a (master) region that contains the given (slave) region time
-- and then we update its (slave's) contents
function module.pull(regionItem)
    local track = Track.fromItem(regionItem)
    Track.selectOnly(track)
    Item.selectAllInSelectedTrack()
    
    Item.setSelected(regionItem, false)
    local otherRegionItems = Item.selected()

    for _i, otherRegion in ipairs(otherRegionItems) do
        if isSubregionOf(regionItem, otherRegion) then
            -- Log.debug("pulling from " .. Item.notes(otherRegion))
            module.propagateFromTo(otherRegion, regionItem)
            break
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
    Item.splitSelectedTimeSelection()
    Item.deleteSelected()
end

return module
