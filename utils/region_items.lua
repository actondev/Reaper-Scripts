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

end

local function selectSiblings(track)
    Track.selectSiblings(track)
    Item.selectInTimeSelectionAcrossSelectedTracks()

end

local function selectChildren()

end

function module.select(regionItem)
    Common.undoBeginBlock()
    Common.preventUIRefresh(1)

    TimeSelection.setToSelectedItems()
    local track = Track.getFromItem(regionItem)
    local selMode = getSelectMode(track)
    if selMode == SELECT_MODE.SIBLINGS then
        selectSiblings(track)
    end

    TimeSelection.remove()

    Track.selectOnly(track)
    
    Common.preventUIRefresh(-1)
    Common.undoEndBlock("ActonDev/Region items: select")
end

return module