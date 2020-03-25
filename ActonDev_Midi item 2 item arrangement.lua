local dirSeparator = package.config:sub(1, 1)
package.path = reaper.GetResourcePath() .. dirSeparator .. 'Scripts' .. dirSeparator .. '?.lua;' .. package.path
local Track = require('ActonDev.utils.track')
local Log = require('ActonDev.utils.log')
local Item = require('Actondev.utils.item')

Log.isdebug = true

Log.debug(reaper.GetResourcePath())
Log.debug(package.config:sub(1, 1))
Log.debug(package.path)

local siblings = Track.selectSiblings()
Log.debug(Log.dump(siblings))

local midiItem = reaper.GetSelectedMediaItem(0, 0)
local pos = Item.position(midiItem)

for _, sibling in pairs(siblings) do
    Log.debug("sibling")
    Log.debug(sibling)
    local lastItem = Track.trackPreviousItem(sibling)
    Log.debug("last item")
    Log.debug(Item.chunk(lastItem))
    Track.insertCopyOfItem(sibling, lastItem, pos)
end

-- for i=0,2 do
--     Log.debug(i) -- prints 0,1,2
-- end

