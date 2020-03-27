local Common = require('utils.common')
local Log = require('utils.log')
local EditCursor = require('utils.edit_cursor')
local module = {}

module.TYPE = {
    EMPTY = 0,
    MIDI = 1,
    AUDIO = 2
}


function module.chunk(item)
    local _retval, itemChunk = reaper.GetItemStateChunk(item, '')
    return itemChunk
end


-- probably should think of other items in the future.. Project In Project eg?
-- @return the item's type. eg empty,midi,audio
function module.type(item)
    local chunk = module.chunk(item)
	local  itemType = string.match(chunk, "<SOURCE%s(%P%P%P).*\n")
	if itemType == nil then
		return module.TYPE.EMPTY
	elseif itemType == "MID" then
		return module.TYPE.MIDI
	else
		return module.TYPE.AUDIO
	end
end

function module.position(item)
    return reaper.GetMediaItemInfo_Value(item, "D_POSITION")
end

function module.activeTake(item)
    return reaper.GetActiveTake(item)
end

function module.name(item)
    local take = module.activeTake(item)
    local _, name = reaper.GetSetMediaItemTakeInfo_String(take,'P_NAME', '', false)

    return name
end

function module.setVolume(item, vol)
    reaper.SetMediaItemInfo_Value(item, "D_VOL", vol)
end
-- https://www.extremraym.com/cloud/reascript-doc/#GetSetMediaItemInfo_String
function module.getVolume(item)
    return reaper.GetMediaItemInfo_Value( item, "D_VOL")
end

function module.countMidiNotes(item)
    local take = reaper.GetActiveTake(item)
    _retval, notecnt, _ccevtcnt, _textsyxevtcnt = reaper.MIDI_CountEvts(take)
    
    return notecnt
end

function module.iterateMidiNotes(item, cb)
    local take = reaper.GetActiveTake(item)
    
    for i = 0, module.countMidiNotes(item) - 1 do
        local _retval, _selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote(take, i)
        local tstart = reaper.MIDI_GetProjTimeFromPPQPos(take, startppqpos)
        local tend = reaper.MIDI_GetProjTimeFromPPQPos(take, endppqpos)
        local noteMap =
            {muted = muted,
            tstart = tstart,
            tend = tend,
            chan = chan,
            pitch = pitch,
            vel = vel
            }
        cb(noteMap)
    end
end

function module.selectInTimeSelectionAcrossSelectedTracks()
    -- Item: Select all items on selected tracks in current time selection
    Common.cmd(40718)
end

function module.selectAllInSelectedTrack()
    -- Item: Select all items in track
    Common.cmd(40421)
end

function module.unselectAll()
    -- Item: Unselect all items
    Common.cmd(40289)
end

function module.setSelected(item, selected)
    reaper.SetMediaItemSelected( item, selected )
end

function module.firstSelected()
    return reaper.GetSelectedMediaItem(0, 0)
end

function module.selected()
    local selCount = reaper.CountSelectedMediaItems(0)
    local items = {}

    for i=0,selCount-1 do
        local item = reaper.GetSelectedMediaItem(0, i)
        table.insert(items,item)
    end

    return items
end

function module.startEnd(item)
    local tstart =  reaper.GetMediaItemInfo_Value( item, 'D_POSITION')
    local length = reaper.GetMediaItemInfo_Value( item, 'D_LENGTH')
    local tend = tstart + length

    return tstart, tend
end

function module.notes(item)
    return reaper.ULT_GetMediaItemNote(item)
end

function module.copySelected()
    -- Edit: Copy items
    Common.cmd(40698)
end

function module.deleteSelected()
    -- Item: Remove items
    Common.cmd(40006)
end

-- note: should call updateArrange afterwards
function module.deleteSelectedOutsideOfRange(tstart, tend)
    local tolerance = 0.000001
    local selected = module.selected()
    for _,item in pairs(selected) do
        local itemStart, itemEnd = module.startEnd(item)
        local shouldDelete = false
        if itemEnd-tolerance < tstart then
            shouldDelete = true
        elseif itemStart+tolerance > tend then
            shouldDelete = true
        end
        if shouldDelete then
            reaper.DeleteTrackMediaItem( reaper.GetMediaItem_Track(item), item )
        end
    end
    Common.updateArrange()
end

function module.splitSelected(t)
    EditCursor.setPosition(t)
    -- Item: Split items at edit cursor (no change selection)
    Common.cmd(40757)
end

function module.paste()
    -- Item: Paste items/tracks
    Common.cmd(40058)
end

return module;
