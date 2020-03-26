local dirSeparator = package.config:sub(1, 1)
-- see https://forum.cockos.com/showthread.php?t=190342
package.path = reaper.GetResourcePath() .. dirSeparator .. 'Scripts' .. dirSeparator .. '?.lua;' .. package.path
local Track = require('ActonDev.utils.track')
local Log = require('ActonDev.utils.log')
local Item = require('Actondev.utils.item')

Log.isdebug = true

local siblings = Track.selectSiblings()

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

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)
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

reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("Midi item 2 item arrangement", -1)