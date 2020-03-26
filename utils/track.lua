local helper = require('ActonDev.utils.helper')
local Navigation = require('ActonDev.utils.navigation')
local log = require('ActonDev.utils.log')
local Track = {}

function Track.selectAndMoveToPreviousItem()
    -- Item navigation: Select and move to previous item
    helper.reaperCMD(40416)
end

function Track.name(track)
    local name = ""
    _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false )

    return name
end

function Track.selectSiblings()
    local currentTrack = reaper.GetSelectedTrack(0, 0)
    helper.reaperCMD('_SWS_SELPARENTS')
    helper.reaperCMD('_SWS_SELCHILDREN')
    reaper.SetTrackSelected( currentTrack, false)
    local siblingsCount = reaper.CountSelectedTracks(0)

    local siblings = {}

    for i=0,siblingsCount-1 do
        local track = reaper.GetSelectedTrack(0, i)
        table.insert(siblings,track)
    end

    return siblings
end

-- has side effects: track selections
function Track.previousItem(track)
    reaper.SetOnlyTrackSelected(track)

    Navigation.storeEditCursorPosition()
    Track.selectAndMoveToPreviousItem()
    Navigation.recallEditCursorPosition()
    
    return reaper.GetSelectedMediaItem(0, 0)
end

function Track.insertCopyOfItem(track, item, position)
    local new_item = reaper.AddMediaItemToTrack(track)
	local new_item_guid = reaper.BR_GetMediaItemGUID(new_item)
    local _, item_chunk =  reaper.GetItemStateChunk(item, '')
    new_item_chunk = string.gsub(item_chunk, 'IGUID {(.-)}', 'IGUID ' .. new_item_guid )
	reaper.SetItemStateChunk(new_item, new_item_chunk)
	reaper.SetMediaItemInfo_Value(new_item, "D_POSITION", position)
	reaper.UpdateItemInProject(new_item)
	
	return new_item
end

return Track