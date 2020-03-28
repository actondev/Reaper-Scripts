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

function module.fromItem(item)
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
end

function module.selectChildrenSelected()
    Common.cmd('_SWS_SELCHILDREN2')
end

function module.selectedCount()
    return reaper.CountSelectedTracks(0)
end
function module.selected()
    local selCount = reaper.CountSelectedTracks(0)
    local tracks = {}

    for i=0,selCount-1 do
        local track = reaper.GetSelectedTrack(0, i)
        table.insert(tracks,track)
    end

    return tracks
end

function module.selectAll()
    -- Track: Select all tracks
    Common.cmd(40296)
end

function module.selectAllTopLevel()
    -- Track: Select all top level tracks
    Common.cmd(41803)
end

function module.setSelected(track, selected)
    local flag = 0
    if selected then
        flag = 1
    end
    reaper.SetMediaTrackInfo_Value( track, "I_SELECTED", flag )
end

function module.unselectWithRegex(regex)
    local tracks = module.selected()
    for _, track in pairs(tracks) do
        local trackName = module.name(track)
        if string.match(trackName, regex) then
            module.setSelected(track, false)
        end
    end
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