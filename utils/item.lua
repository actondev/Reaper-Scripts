local Item = {}

function Item.chunk(item)
    local retval, itemChunk = reaper.GetItemStateChunk(item, '')
    return itemChunk
end

function Item.position(item)
    return reaper.GetMediaItemInfo_Value(item, "D_POSITION")
end

function Item.midiNotes(item)
    local notesCounts = reaper
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
