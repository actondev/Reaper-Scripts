local module = {}

function module.chunk(item)
    local retval, itemChunk = reaper.GetItemStateChunk(item, '')
    return itemChunk
end

function module.position(item)
    return reaper.GetMediaItemInfo_Value(item, "D_POSITION")
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

return module;
