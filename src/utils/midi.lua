local module = {}
local Item = require('utils.item')

--  reaper.MIDI_InsertTextSysexEvt( take, selected, muted, ppqpos, type, bytestr )

function module.insertTextEvent(item, qn, text)
    local take = Item.activeTake(item)
    local startQn = reaper.MIDI_GetProjQNFromPPQPos( take, 0 )
    local ppq = reaper.MIDI_GetPPQPosFromProjQN( take, startQn + qn )
    reaper.MIDI_InsertTextSysexEvt( take, false, false, ppq, 1, text )
end

function module.ppqLength(item)
    return reaper.BR_GetMidiSourceLenPPQ( Item.activeTake(item))
end

function module.qnLength(item)
    return module.qnFromPpq(item, module.ppqLength(item))-
    module.qnFromPpq(item, 0)
end

function module.qnFromPpq(item, ppq)
    return reaper.MIDI_GetProjQNFromPPQPos( Item.activeTake(item), ppq )
end

return module