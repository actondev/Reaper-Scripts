local dirSeparator = package.config:sub(1, 1)
package.path = reaper.GetResourcePath() .. dirSeparator .. 'Scripts' .. dirSeparator .. '?.lua;' .. package.path
local Track = require('ActonDev.utils.track')
local Log = require('ActonDev.utils.log')
local Item = require('Actondev.utils.item')

Log.isdebug = true

local siblings = Track.selectSiblings()

local midiItem = reaper.GetSelectedMediaItem(0, 0)

for _, sibling in pairs(siblings) do
    local itemToInsert = Track.previousItem(sibling)
    local trackName = Track.name(sibling)

    local cb = function(opts)
        local pitchStr = tostring(opts['pitch'])
        local pitch_track_match = string.match(trackName,pitchStr)
        if pitch_track_match then
            Track.insertCopyOfItem(sibling, itemToInsert, opts['tstart'])
        end
    end
    Item.iterateMidiNotes(midiItem, cb)
end

