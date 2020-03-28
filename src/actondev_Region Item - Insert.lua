package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path

local Log = require('utils.log')
local Item = require('utils.item')
local Common = require('utils.common')
local Store = require('utils.store')
local Midi = require('utils.midi')

Common.undoBeginBlock()
Common.preventUIRefresh(1)

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

local opts = {[1] = {title = 'Region item name',
                     default = 'region'},
              [2] = {title = 'Tick division (eg 16th notes)',
                     default = '16'}}
local res = Common.getUserInput("Insert region items",opts)

if res then
    local name = res[1]
    local division = res[2]
    Item.setActiveTakeInfoString(item, Item.TAKE_PARAM.STR_NAME, name)

    local qnLength = Midi.qnLength(item)
    local qnInterval = 4/division
    local marks = qnLength/qnInterval
    for i=0,marks-1 do
        Midi.insertTextEvent(item,i*qnInterval, tostring(i))
    end

end


Store.restoreCursorPosition()
Common.preventUIRefresh(-1)
Common.undoEndBlock("actondev/Region Item: Insert")