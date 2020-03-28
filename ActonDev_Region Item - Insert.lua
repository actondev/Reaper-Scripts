package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path

local Log = require('utils.log')
local Item = require('utils.item')
local Common = require('utils.common')
local Store = require('utils.store')

Common.undoBeginBlock()
-- Common.preventUIRefresh(1)

-- Log.isdebug = true
Store.storeCursorPosition()

Item.insertMidiItem()

--Take: Toggle take pan envelope
Common.cmd(40694)

local item = Item.firstSelected()
local take = Item.activeTake(item)
local envelope = reaper.GetTakeEnvelope(take, 0)

-- boolean reaper.InsertEnvelopePoint(TrackEnvelope envelope, number time, number value, integer shape, number tension, boolean selected, optional boolean noSortIn)
reaper.InsertEnvelopePoint(envelope, 0, 1, 0, 0, false)
reaper.InsertEnvelopePoint(envelope, Item.getInfo(item, Item.PARAM.LENGTH), -1, 0, 0, false)

local retval,name  = reaper.GetUserInputs("Insert Item Title", 1, "Region Item Title", "")
if retval then
    Item.setActiveTakeInfoString(item, Item.TAKE_PARAM.STR_NAME, name)
end

-- TODO? add 16th note midi text events? useful



Store.restoreCursorPosition()
-- Common.preventUIRefresh(-1)
Common.undoEndBlock("actondev/Region Item: Insert")
-- Item properties: Toggle show media item/take properties
-- Common.cmd(41589)