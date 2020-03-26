local Item = {}

function Item.chunk(item)
    local retval, itemChunk = reaper.GetItemStateChunk(item, '')
    return itemChunk
end

function Item.position(item)
    return reaper.GetMediaItemInfo_Value(item, "D_POSITION")
end

function Item.setVolume(item, vol)
    reaper.SetMediaItemInfo_Value(item, "D_VOL", vol)
end
-- https://www.extremraym.com/cloud/reascript-doc/#GetSetMediaItemInfo_String
function Item.getVolume(item)
    return reaper.GetMediaItemInfo_Value( item, "D_VOL")
end

function Item.countMidiNotes(item)
    local take = reaper.GetActiveTake(item)
    _retval, notecnt, _ccevtcnt, _textsyxevtcnt = reaper.MIDI_CountEvts(take)
    
    return notecnt
end

function Item.iterateMidiNotes(item, cb)
    local take = reaper.GetActiveTake(item)
    
    for i = 0, Item.countMidiNotes(item) - 1 do
        local retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote(take, i)
        local tstart = reaper.MIDI_GetProjTimeFromPPQPos(take, startppqpos)
        local tend = reaper.MIDI_GetProjTimeFromPPQPos(take, endppqpos)
        local opts =
            {muted = muted,
            tstart = tstart,
            tend = tend,
            chan = chan,
            pitch = pitch,
            vel = vel
            }
        cb(opts)
    end
end

return Item;
