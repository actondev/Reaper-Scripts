local Common = require('utils.common')
local Track = require('utils.track')
local Item = require('utils.item')
local TimeSelection = require('utils.time_selection')

local module = {}

local SELECT_MODE = {
    ALL = 0,
    SIBLINGS = 1,
    CHILDREN = 2
}

local function getSelectMode(track)
    local trackName = Track.name(track)
    local firstChar = string.sub(trackName, 1,1)

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

    TimeSelection.setToSelectedItems()
    local track = Track.getFromItem(regionItem)
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

return module