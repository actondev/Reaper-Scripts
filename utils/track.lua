local Navigation = require('utils.navigation')
local Common = require('utils.common')
-- local Log = require('utils.log')
local module = {}

function module.selectAndMoveToPreviousItem()
    -- Item navigation: Select and move to previous item
    Common.cmd(40416)
end

function module.name(track)
    local name = ""
    _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false )

    return name
end

function module.getFromItem(item)
    return reaper.GetMediaItem_Track(item)
end

function module.selectOnly(track)
    reaper.SetOnlyTrackSelected(track)
end

-- also return the sibling tracks
function module.selectSiblings(track)
    reaper.SetOnlyTrackSelected(track)
    Common.cmd('_SWS_SELPARENTS')
    Common.cmd('_SWS_SELCHILDREN')
    reaper.SetTrackSelected(track, false)
    local siblingsCount = reaper.CountSelectedTracks(0)

    local siblings = {}

    for i=0,siblingsCount-1 do
        local track = reaper.GetSelectedTrack(0, i)
        table.insert(siblings,track)
    end

    return siblings
end

-- has side effects: track selections
function module.previousItem(track)
    reaper.SetOnlyTrackSelected(track)

    Navigation.storeEditCursorPosition()
    module.selectAndMoveToPreviousItem()
    Navigation.recallEditCursorPosition()
    
    return reaper.GetSelectedMediaItem(0, 0)
end

function module.insertCopyOfItem(track, item, position)
    local new_item = reaper.AddMediaItemToTrack(track)
	local new_item_guid = reaper.BR_GetMediaItemGUID(new_item)
    local _, item_chunk =  reaper.GetItemStateChunk(item, '')
    new_item_chunk = string.gsub(item_chunk, 'IGUID {(.-)}', 'IGUID ' .. new_item_guid )
	reaper.SetItemStateChunk(new_item, new_item_chunk)
	reaper.SetMediaItemInfo_Value(new_item, "D_POSITION", position)
	reaper.UpdateItemInProject(new_item)
	
	return new_item
end

return module