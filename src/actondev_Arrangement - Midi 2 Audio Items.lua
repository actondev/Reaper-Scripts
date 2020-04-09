package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path

local Track = require('aod.reaper.track')
local Log = require('aod.utils.log')
local Item = require('aod.reaper.item')
local Common = require('aod.reaper.common')
local Store = require('aod.reaper.store')

Log.isdebug = true

local currentTrack = reaper.GetSelectedTrack(0, 0)
Track.selectSiblings(currentTrack)
local siblings = Track.selected()

local midiItem = reaper.GetSelectedMediaItem(0, 0)

--[[
- maybe match also keywords?
   - kick should translate to 36 (note C1), GM "Bass Drum 1"
   - snare should translate to 38 (note D1), GM "Acoustic Snare"
   - see GM drum maphttps://musescore.org/sites/musescore.org/files/General%20MIDI%20Standard%20Percussion%20Set%20Key%20Map.pdf
]]
function pitchMatchesTrack(pitch, track)
    local pitchStr = tostring(pitch)
    local trackName = Track.name(track)

    return string.match(trackName,pitchStr)
end

Common.undoBeginBlock()
Common.preventUIRefresh(1)
Store.storeArrangeView()

for _, track in pairs(siblings) do
    local itemToInsert = Track.previousItem(track)

    local cb = function(note)
        local pitch = note['pitch']
        if pitchMatchesTrack(pitch, track) then
            local vol = note['vel']/127
            local insertedItem = Track.insertCopyOfItem(track, itemToInsert, note['tstart'])
            Item.setVolume(insertedItem, vol)
        end
    end
    Item.iterateMidiNotes(midiItem, cb)
end

Item.unselectAll()
Item.setSelected(midiItem, true)
Track.selectOnly(currentTrack)

Store.restoreArrangeView()
reaper.UpdateArrange()

Common.preventUIRefresh(-1)
Common.undoEndBlock("Midi item 2 item arrangement")